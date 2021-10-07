-- pico defense force
-- by @maxbize

--------------------
-- Global State
--------------------
objects = {}


--------------------
-- Built-in Methods
--------------------
function _init()
  -- Use blue as alpha
  palt(0, false)
  palt(1, true)

  for i=1,100 do
    spawn_ant(rnd(128), rnd(128))
  end

  spawn_player()
end

function _update60()
  for obj in all(objects) do
    obj.update(obj)
  end
end

function _draw()
  cls(1)

  for obj in all(objects) do
    obj.draw(obj)
  end

  print('cpu: '..(stat(1) < 0.1 and '0' or '')..flr(stat(1) * 100), 1, 1, 0)
  --print('mem: '..stat(0), 1, 13, 0)
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

--------------------
-- Player class
--------------------
function spawn_player()
  local player = {
    update = _player_update,
    draw = _player_draw,
    x = 64,
    y = 64,
    angle = 0,
    speed = 0.8
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

  self.x += move_x
  self.y += move_y
end

function _player_draw(self)
  spr(8, self.x, self.y)
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
end

-- todo: optimize tokens
function _ant_draw(self)
  if     self.angle <  22.5 then spr(self.frame     , self.x, self.y, 1, 1, false, false) -- S
  elseif self.angle <  67.5 then spr(self.frame + 16, self.x, self.y, 1, 1, false, false) -- SW
  elseif self.angle < 112.5 then spr(self.frame + 32, self.x, self.y, 1, 1, false, false) -- W
  elseif self.angle < 157.5 then spr(self.frame + 16, self.x, self.y, 1, 1, false, true ) -- NW
  elseif self.angle < 202.5 then spr(self.frame     , self.x, self.y, 1, 1, false, true ) -- N
  elseif self.angle < 247.5 then spr(self.frame + 16, self.x, self.y, 1, 1, true , true ) -- NE
  elseif self.angle < 292.5 then spr(self.frame + 32, self.x, self.y, 1, 1, true , false) -- E
  elseif self.angle < 337.5 then spr(self.frame + 16, self.x, self.y, 1, 1, true , false) -- SE
  else                           spr(self.frame     , self.x, self.y, 1, 1, false, false) -- S
  end
  --rspr(self.frame * 8, 0, self.x, self.y, 0.125, 1) 
end

--------------------
-- 
--------------------

