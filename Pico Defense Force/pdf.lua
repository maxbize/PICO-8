-- pico defense force
-- by @maxbize

--------------------
-- Global State
--------------------
local objects = {}
local player = nil
local projectile_m = nil

--------------------
-- Built-in Methods
--------------------
function _init()
  -- Use blue as alpha
  palt(0, false)
  palt(1, true)

  -- Init singletons
  create_projectile_manager()
  spawn_player()

  for i=1,100 do
    spawn_ant(rnd(128), rnd(128))
  end

end

function _update60()
  for obj in all(objects) do
    obj.update(obj)
  end
end

function _draw()
  cls(6)

  for obj in all(objects) do
    obj.draw(obj)
  end

  rectfill(0, 0, 53, 6, 7, true)
  print('cpu:'..(stat(1) < 0.1 and '0' or '')..flr(stat(1) * 100), 1, 1, 0)
  print('mem:'..(stat(0) / 2048 * 100 < 10 and '0' or '')..flr(stat(0) / 2048 * 100), 28, 1, 0)
end


--------------------
-- Utility Methods
--------------------

-- rotate a sprite
-- col 15 is transparent
-- sx,sy - sprite sheet coords
-- x,y - screen coords
-- a - angle
-- w - width in tiles
function rspr(sx,sy,x,y,a,w)
    local ca,sa=cos(a),sin(a)
    local srcx,srcy
    local ddx0,ddy0=ca,sa
    local mask=shl(0xfff8,(w-1))
    w*=4
    ca*=w-0.5
    sa*=w-0.5
    local dx0,dy0=sa-ca+w,-ca-sa+w
    w=2*w-1
    for ix=0,w do
        srcx,srcy=dx0,dy0
        for iy=0,w do
            if band(bor(srcx,srcy),mask)==0 then
                local c=sget(sx+srcx,sy+srcy)
    -- set transparent color here
                if (c~=15) pset(x+ix,y+iy,c)
            end
            srcx-=ddy0
            srcy+=ddx0
        end
        dx0+=ddx0
        dy0+=ddy0
    end
end

-- todo: E should be 0, S should be 90, etc...
-- todo: optimize tokens
function draw_rotated_anim(x, y, angle, start_frame, frame)
  frame += start_frame

  if     angle <  22.5 then spr(frame + 32, x, y, 1, 1, true , false) -- E
  elseif angle <  67.5 then spr(frame + 16, x, y, 1, 1, true , true ) -- SE
  elseif angle < 112.5 then spr(frame     , x, y, 1, 1, false, true ) -- S
  elseif angle < 157.5 then spr(frame + 16, x, y, 1, 1, false, true ) -- SW
  elseif angle < 202.5 then spr(frame + 32, x, y, 1, 1, false, false) -- W
  elseif angle < 247.5 then spr(frame + 16, x, y, 1, 1, false, false) -- NW
  elseif angle < 292.5 then spr(frame     , x, y, 1, 1, false, false) -- N
  elseif angle < 337.5 then spr(frame + 16, x, y, 1, 1, true , false) -- NE
  else                      spr(frame + 32, x, y, 1, 1, true , false) -- E
  end
end

function rand(l, r)
  if r == nil then
    r = l
    l = 0
  end

  return rnd(r-l) - (r-l)/2
end

--------------------
-- Player class
--------------------
function spawn_player()
  player = {
    update = _player_update,
    draw = _player_draw,
    x = 64,
    y = 64,
    angle = 0,
    speed = 0.5,
    frame = 0
  }
  add(objects, player)
end

function _player_update(self)

  -- movement
  local move_x = 0
  local move_y = 0

  if btn(0) then
    move_x -= self.speed
  end
  if btn(1) then
    move_x += self.speed
  end
  if btn(2) then
    move_y -= self.speed
  end
  if btn(3) then
    move_y += self.speed
  end

  -- don't let the player speed walk diagonally. todo: remove???
  if move_x ~= 0 and move_y ~= 0 then
    move_x *= 0.707
    move_y *= 0.707
  end

  -- translation
  self.x += move_x
  self.y += move_y

  -- rotation
  if not btn(5) and (move_x ~= 0 or move_y ~= 0) then
    self.angle = atan2(move_x, move_y) * 360
  end

  -- weapons
  if btn(5) then
    add_projectile(self.x+4, self.y+4, rand(-0.3, 0.3), -1, 90, 10)
  end
end

function _player_draw(self)
  draw_rotated_anim(self.x, self.y, self.angle, 8, self.frame)
end

--------------------
-- Ant class
--------------------
function spawn_ant(x, y)
  local ant = {
    update = _ant_update,
    draw = _ant_draw,
    x = x,
    y = y,
    angle = 0,           -- animation angle (0-360)
    i = rnd(4),          -- animation timer
    frame = flr(rnd(4)), -- animation frame
  }
  add(objects, ant)
end

function _ant_update(self)

  -- advance animation state
  self.i += 1
  if self.i > 3 then
    self.i = 0
    self.frame = (self.frame + 1) % 4
  end

  -- face player
  self.angle = atan2(player.x - self.x, player.y - self.y) * 360

  -- collision registration
  register_ant(self)
end

function _ant_draw(self)
  draw_rotated_anim(self.x, self.y, self.angle, 0, self.frame)
  --rspr(self.frame * 8, 0, self.x, self.y, 0.125, 1) 
end

--------------------
-- Projectile Manager
--------------------
function create_projectile_manager()
  projectile_m = {
    update = _projectile_manager_update,
    draw = _projectile_manager_draw,
    max_projectiles = 100,
    projectiles = {},
    index = 1, -- insertion index
    partitions = {}, -- shootable objects of the world indexed by 8x8 chunked positions
  }
  add(objects, projectile_m)

  for i = 1, projectile_m.max_projectiles do
    projectile_m.projectiles[i] = {
      x = 0,
      y = 0,
      vx = 0,
      vy = 0,
      frames = 0,
      color = 0
    }
  end
end

function add_projectile(x, y, vx, vy, frames, color)
  projectile_m.index += 1
  if (projectile_m.index > projectile_m.max_projectiles) then
    projectile_m.index = 1
  end

  local p = projectile_m.projectiles[projectile_m.index]

  p.x = x
  p.y = y
  p.vx = vx
  p.vy = vy
  p.frames = frames
  p.color = color
end

-- todo: we can save 1-3% CPU per 100 ants by inlining this
-- note: with a 4096x4096 playable world, the min chunk size is 16x16 or we'll overflow the int.
--         We could do 8x8 if we use the fractional bits. e.g. index 1.00, 1.25, 1.5, 1.75 would be the four quadrants of index 1
function register_ant(ant)
  local index = flr((ant.x + 3) / 16) + flr(ant.y + 3) * 16

  if projectile_m.partitions[index] == nil then
    projectile_m.partitions[index] = {}
  end
  add(projectile_m.partitions[index], ant)
end

function _projectile_manager_update(self)
  for p in all(self.projectiles) do
    if (p.frames > 0) then
      -- update projectiles
      p.x += p.vx
      p.y += p.vy
      p.frames -= 1

      -- check collisions
      local index = flr(p.x / 16) + flr(p.y) * 16
      for ant in all(self.partitions[index]) do
        -- todo: is there a faster way to check a pixel overlapping a box???
        if p.x >= ant.x and p.x < ant.x + 8 and p.y >= ant.y and p.y < ant.y + 8 then
          p.frames = 0
          del(objects, ant)
          break
        end
      end
    end

  end


  -- clear partitions
  self.partitions = {}
end

function _projectile_manager_draw(self)
  for p in all(self.projectiles) do
    if (p.frames > 0) then
      pset(p.x, p.y, p.color)
    end
  end
end

