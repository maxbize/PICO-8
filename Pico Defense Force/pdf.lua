-- pico defense force
-- by @maxbize

--------------------
-- Global State
--------------------
local objects = {}
local ants = {}
local player = nil
local projectile_m = nil

--------------------
-- Built-in Methods
--------------------
function _init()
  -- Use blue as alpha
  palt(0, false)
  palt(1, true)

  srand(0) -- debugging. const random seed

  -- Init singletons
  create_projectile_manager()
  spawn_player()

  for i = 1, 100 do
    spawn_ant(28*32 + rnd(120), 27*32 + rnd(60))
  end

end

function _update60()
  for ant in all(ants) do
    ant.update(ant)
  end

  for obj in all(objects) do
    obj.update(obj)
  end
end

function _draw()
  cls(1)

  draw_map()

  for ant in all(ants) do
    ant.draw(ant)
  end

  for obj in all(objects) do
    obj.draw(obj)
  end

  draw_gui()
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

  if     angle < 0.0625 or angle >= 0.9375 then spr(frame + 32, x, y, 1, 1, true , false) -- E
  elseif angle < 0.1875                    then spr(frame + 16, x, y, 1, 1, true , true ) -- SE
  elseif angle < 0.3125                    then spr(frame     , x, y, 1, 1, false, true ) -- S
  elseif angle < 0.4375                    then spr(frame + 16, x, y, 1, 1, false, true ) -- SW
  elseif angle < 0.5625                    then spr(frame + 32, x, y, 1, 1, false, false) -- W
  elseif angle < 0.6875                    then spr(frame + 16, x, y, 1, 1, false, false) -- NW
  elseif angle < 0.8125                    then spr(frame     , x, y, 1, 1, false, false) -- N
  else                                          spr(frame + 16, x, y, 1, 1, true , false) -- NE
  end
end

function rand(l, r)
  if r == nil then
    r = l
    l = 0
  end

  return rnd(r-l) - (r-l)/2
end

function angle_vector(theta, magnitude)
  return magnitude * cos(theta),
         magnitude * sin(theta)
end

function dist(dx, dy)
  return sqrt(dx * dx + dy * dy)
end

function normalized(x, y)
  local mag = dist(x, y)
  return x / mag, y / mag
end

function round(n)
  return n%1 < 0.5 and flr(n) or -flr(-n)
end

function pad(str, len, char)
  if #str < len then
    return pad(char .. str, len, char)
  end
  return str
end

--------------------
-- GUI
--------------------
-- TODO: All of this could be moved to strings to save tokens
function draw_gui()
  local camera_x = peek2(0x5f28)
  local camera_y = peek2(0x5f2a)

  -- Health
  rect(camera_x + 2, camera_y +  75, camera_x + 11, camera_y + 115, 0)
  rectfill(camera_x + 2, camera_y + 115, camera_x + 22, camera_y + 125, 0)
  rect(camera_x + 3, camera_y +  76, camera_x + 10, camera_y + 116, 7)
  rect(camera_x + 3, camera_y + 116, camera_x + 21, camera_y + 124, 7)
  rectfill(camera_x + 4, camera_y +  77, camera_x + 9, camera_y +  77 + (38 * (1 - player.health / player.max_health)), 5)
  rectfill(camera_x + 4, camera_y + 115, camera_x + 9, camera_y + 115 - (38 *     (player.health / player.max_health)),  3)
  line(camera_x + 4, camera_y +  86, camera_x +  6, camera_y +  86, 6)
  line(camera_x + 4, camera_y +  96, camera_x +  6, camera_y +  96, 6)
  line(camera_x + 4, camera_y + 106, camera_x +  6, camera_y + 106, 6)
  print(pad(tostr(player.health), 4, ' '), camera_x + 5, camera_y + 118, 3)

  -- Weapon + Ammo
  local name_len = #player.weapon.name
  local ammo_len = #tostr(player.weapon.capacity) * 2 + 1
  rectfill(camera_x + 125 - name_len * 4 - 4, camera_y + 107, camera_x + 125, camera_y + 117, 0)
  rectfill(camera_x + 125 - ammo_len * 4 - 4, camera_y + 115, camera_x + 125, camera_y + 125, 0)
  rect(camera_x + 126 - name_len * 4 - 4, camera_y + 108, camera_x + 124, camera_y + 116, 7)
  rect(camera_x + 126 - ammo_len * 4 - 4, camera_y + 116, camera_x + 124, camera_y + 124, 7)
  rect(camera_x + 126 - min(ammo_len, name_len) * 4 - 3, camera_y + 116, camera_x + 123, camera_y + 116, 6)
  print(player.weapon.name, camera_x + 124 - name_len * 4, camera_y + 110, 3)
  print(pad(tostr(player.weapon.ammo), #tostr(player.weapon.capacity), '0') .. '/' .. player.weapon.capacity, camera_x + 124 - ammo_len * 4, camera_y + 118, 3)

  -- Reload
  if player.weapon.reload_frames_remaining > 0 then
    local reload_percent = 1 - player.weapon.reload_frames_remaining / player.weapon.reload_frames
    rect(           camera_x + 49, camera_y + 28, camera_x + 79,                       camera_y + 37,  0)
    rect(           camera_x + 50, camera_y + 29, camera_x + 78,                       camera_y + 36,  7)
    rectfill(       camera_x + 51, camera_y + 30, camera_x + 52 + 26 * reload_percent, camera_y + 35, 11)
    line(           camera_x + 51, camera_y + 30, camera_x + 77,                       camera_y + 30,  3)
    line(           camera_x + 53, camera_y + 31, camera_x + 75,                       camera_y + 31,  3)
    line(           camera_x + 53, camera_y + 32, camera_x + 75,                       camera_y + 32,  3)
    print('reload', camera_x + 53, camera_y + 27,                                                      8)
  end

  -- Debug info  
  rectfill(camera_x, camera_y, camera_x + 53, camera_y + 6, 7, true)
  print('cpu:'..(stat(1) < 0.1 and '0' or '')..flr(stat(1) * 100), camera_x + 1, camera_y + 1, 0)
  print('mem:'..(stat(0) / 2048 * 100 < 10 and '0' or '')..flr(stat(0) / 2048 * 100), camera_x + 28, camera_y + 1, 0)
end

--------------------
-- World Map
--------------------
-- TODO: Compression. Can save 50% using binary string (https://www.lexaloffle.com/bbs/?tid=38692). Maybe more with LZ compression
local map_data = "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061616161616100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000616161616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101010261020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041414141410201010102220200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222222222202010101026102000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002142014221020101010261020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021620162210201010102610200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000410101014102010101026102000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004101010141020101010261020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
local flag_data = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000808000008000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"

function draw_map()

  -- Perf notes:
  -- 24% CPU for full-screen map
  --  0% cost for drawing off-screen pixels!!
  --  0% cost for drawing sprite 0 in map
  -- 26% CPU for 256 spr calls
  --map(0, 0, 0, 0, 16, 16)


  -- Find the map index of the top-left map segment
  local camera_x = peek2(0x5f28)
  local camera_y = peek2(0x5f2a)
  local top_left = flr((camera_x + 64) / 32) + 64 * flr((camera_y + 64) / 32)

  -- Draw all map segments surrounding the player
  for x = -2, 2 do
    for y = -2, 2 do
      local data_index = top_left + x + 64 * y
      local map_tile = tonum("0x" .. sub(map_data, data_index * 2 + 1, data_index * 2 + 2))
      local flags = tonum("0x" .. sub(flag_data, data_index, data_index + 1))
      map_tile -= 1 -- Tiled uses index 0 for "empty" but we use it as tile 0

      if flags == 0 then
        map(map_tile % 32 * 4, flr(map_tile / 32) * 4, data_index % 64 * 32, flr(data_index / 64) * 32, 4, 4)
      elseif flags & 0x2 > 0 then
        error("Diagonal flip not supported -- too expensive!")

        -- +34% CPU to support rotation via tline...
        -- 90 degree rotation
--      local draw_x = data_index % 64 * 32
--      local draw_y = flr(data_index / 64) * 32
--      local map_x = map_tile % 32 * 4
--      local map_y = flr(map_tile / 32) * 4
--      for i = 0, 31 do
--        tline(draw_x + i, draw_y, draw_x + i, draw_y + 32, map_x, map_y + i / 8)
--      end
      else
        -- +13% CPU to support flipping via mget / spr if every tile is flipped on screen
        local h_flip = flags & 0x8 > 0
        local v_flip = flags & 0x4 > 0
        local draw_x = data_index % 64 * 32 + (h_flip and 24 or 0)
        local draw_y = flr(data_index / 64) * 32 + (v_flip and 24 or 0)
        local map_x = map_tile % 32 * 4
        local map_y = flr(map_tile / 32) * 4
        for i = 0, 3 do
          for j = 0, 3 do
            local s = mget(map_x + i, map_y + j)
            if s > 0 then
              spr(s, draw_x + i * 8 * (h_flip and -1 or 1), draw_y + j * 8 * (v_flip and -1 or 1), 1, 1, h_flip, v_flip)
            end
          end
        end
      end
    end
  end


end

--------------------
-- Weapons
--------------------
-- TODO: add more weapons :)
local weapon_data = {
  -- static config
  name = "af14",
  type = "aSSAULT rIFLE",
  capacity = 120,
  reload_frames = 90,
  damage = 10,
  aoe = 0,
  fire_rate = 5, -- Frames per bullet. Fractional not yet supported
  projectile_lifetime = 30,
  projectile_color = 10,
  projectile_speed = 2,
  projectile_speed_random = 0.2,
  projectile_spread = 0.05,
  projectiles_per_fire = 1,

  -- runtime data
  ammo = 120,
  reload_frames_remaining = 0,
  fire_frames_remaining = 0,
}

-- Temporary until we have proper weapon data string
local weapon_data2 = {
  -- static config
  name = "sTINGRAY m1",
  type = "rOCKET lAUNCHER",
  capacity = 2,
  reload_frames = 108,
  damage = 100,
  aoe = 5,
  fire_rate = 60, -- Frames per bullet. Fractional not yet supported
  projectile_lifetime = 60,
  projectile_color = 9,
  projectile_speed = 1,
  projectile_speed_random = 0,
  projectile_spread = 0.005,
  projectiles_per_fire = 1,

  -- runtime data
  ammo = 2,
  reload_frames_remaining = 0,
  fire_frames_remaining = 0
}

--------------------
-- Player class
--------------------
function spawn_player()
  player = {
    update = _player_update,
    draw = _player_draw,
    x = 30 * 32,
    y = 30 * 32,
    angle = 0.25,
    frame = 0,
    weapon = weapon_data,
    weapon2 = weapon_data2, -- Un-equipped weapon
    cam_x = 30 * 32,
    cam_y = 30 * 32,
    health = 200,
    max_health = 200,
    last_move = 0,
  }
  add(objects, player)
end

function _player_update(self)
  -- Movement
  local move_x = 0
  local move_y = 0

  if btn(0) then
    move_x -= 1
  end
  if btn(1) then
    move_x += 1
  end
  if btn(2) then
    move_y -= 1
  end
  if btn(3) then
    move_y += 1
  end

  -- Translation
  -- We only move in whole pixels to remove camera jitter. One pixel per two frames, any direction
  self.last_move += 1
  local overlapping = overlaps_ant(self.x + 3 + move_x, self.y + 3 + move_y, 1, 1)
  if not overlapping and self.last_move >= 2 then
    self.x += move_x
    self.y += move_y
    self.last_move = 0
  end

  -- Rotation
  if not btn(5) and (move_x ~= 0 or move_y ~= 0) then
    self.angle = atan2(move_x, move_y)
  end

  -- Weapons
  if btnp(4) then
    local tmp = self.weapon
    self.weapon = self.weapon2
    self.weapon2 = tmp
  end

  self.weapon.reload_frames_remaining -= 1
  if self.weapon.reload_frames_remaining == 0 then
    self.weapon.ammo = self.weapon.capacity
  end
  self.weapon.fire_frames_remaining -= 1
  if btn(5) and self.weapon.ammo > 0 and self.weapon.fire_frames_remaining <= 0 then
    for i = 1, self.weapon.projectiles_per_fire do
      local vx, vy = angle_vector(self.angle + rand(-self.weapon.projectile_spread, self.weapon.projectile_spread), self.weapon.projectile_speed + rand(-self.weapon.projectile_speed_random, self.weapon.projectile_speed_random))
      add_projectile(self.x+4, self.y+4, vx, vy, self.weapon.projectile_lifetime, self.weapon.projectile_color, self.weapon.damage, self.weapon.aoe)
      self.weapon.fire_frames_remaining = self.weapon.fire_rate
      self.weapon.ammo -= 1
      if self.weapon.ammo == 0 then
        self.weapon.reload_frames_remaining = self.weapon.reload_frames
      end
    end
  end

  -- Camera locked to player at an offset.
  -- Camera lerps the relative offset, but not the absolute position in order to avoid jitter
  local target_x, target_y = angle_vector(self.angle, 10)
  self.cam_x += (target_x - self.cam_x) * 0.15
  self.cam_y += (target_y - self.cam_y) * 0.15
  camera(self.x - 60 + self.cam_x, self.y - 60 + self.cam_y)
end

function _player_draw(self)
  draw_rotated_anim(self.x, self.y, self.angle, 4, self.frame)
end

--------------------
-- Ant class
--------------------
function spawn_ant(x, y)
  local ant = {
    update = _ant_update,
    draw = _ant_draw,
    x = flr(x),
    y = flr(y),
    angle = 0,           -- animation angle (0-1)
    i = rnd(4),          -- animation timer
    frame = flr(rnd(4)), -- animation frame
    health = 60, -- TODO: this should be the health on easy
    flash_frames = 0, -- flash on hit
    speed = 0.25,
    move_pause_frames = 0,
    move_x = 0,
    move_y = 0,
  }
  add(ants, ant)
end

function _ant_update(self)
  -- advance animation state
  self.i += 1
  if self.i > 3 then
    self.i = 0
    self.frame = (self.frame + 1) % 4
  end

  -- collision registration
  local num_in_part = register_ant(self)

  -- move towards player
  local move_x = 0
  local move_y = 0
  local to_player_x, to_player_y = normalized(player.x - self.x, player.y - self.y)
  local player_dist = dist(player.x - self.x, player.y - self.y)
  if player_dist <= 8 then
    if num_in_part < 6 then
      self.angle = atan2(to_player_x, to_player_y)
      self.move_pause_frames = 0
    elseif self.move_pause_frames == 0 then
      self.move_pause_frames = 60
      self.angle = atan2(-to_player_x, -to_player_y)
    else
      local vx, vy = angle_vector(self.angle, self.speed)
      self.move_x += vx
      self.move_y += vy
      self.move_pause_frames -= 1
    end
  elseif self.move_pause_frames == 0 then
    if (num_in_part < 3) then
      if (player_dist > 8) then
        self.move_x += to_player_x * self.speed
        self.move_y += to_player_y * self.speed
        self.angle = atan2(to_player_x, to_player_y)
      end
    else
      self.move_pause_frames = 60
      self.angle = atan2(to_player_x + rand(-5, 5), to_player_y + rand(-5, 5))
    end
  else
    local vx, vy = angle_vector(self.angle, self.speed)
    self.move_x += vx
    self.move_y += vy
    self.move_pause_frames -= 1
  end    

  -- Decrease jitter by synchronizing ant movement to player movement.
  -- Only move when player is moving or when they're standing still
  if player.last_move == 0 or player.last_move >= 2 then
    -- Only move in integer increments. TODO: token optimization?
    -- TODO: Still required? Maybe we can let collision accuracy suffer a bit for perf/tokens?
    self.x += flr(self.move_x) + (self.move_x > 0 and 0 or 1)
    self.y += flr(self.move_y) + (self.move_y > 0 and 0 or 1)
    self.move_x = self.move_x > 0 and self.move_x % 1 or (1 - self.move_x % 1) * -1
    self.move_y = self.move_y > 0 and self.move_y % 1 or (1 - self.move_y % 1) * -1
    --self.x += self.move_x
    --self.y += self.move_y
    --self.move_x = 0
    --self.move_y = 0
  end
end

function _ant_draw(self)
  if self.flash_frames > 0 then
    self.flash_frames -= 1
    pal(5, 7)
    draw_rotated_anim(self.x, self.y, self.angle, 0, self.frame)
    pal(5, 5)
  else
    draw_rotated_anim(self.x, self.y, self.angle, 0, self.frame)
  end
  --rspr(self.frame * 8, 0, self.x, self.y, 0.125, 1) 
end

function damage_ant(self, damage)
  self.health -= damage
  self.flash_frames = 3
  if self.health <= 0 then
    del(ants, self)
  end
end

--------------------
-- Projectile Manager
--------------------
function create_projectile_manager()
  projectile_m = {
    update = _projectile_manager_update,
    draw = _projectile_manager_draw,
    max_projectiles = 250,
    projectiles = {},
    index = 1, -- insertion index
    partitions = {}, -- shootable objects of the world indexed by 8x8 chunked positions
    last_partitions = {}, -- cache of the partitioned objects from the previous frame
  }
  add(objects, projectile_m)

  for i = 1, projectile_m.max_projectiles do
    projectile_m.projectiles[i] = {
      x = 0,
      y = 0,
      vx = 0,
      vy = 0,
      frames = 0,
      color = 0,
      damage = 0,
      aoe = 0
    }
  end
end

function add_projectile(x, y, vx, vy, frames, color, damage, aoe)
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
  p.damage = damage
  p.aoe = aoe
end

-- TODO: We can save 1-3% CPU per 100 ants by inlining this (tested on single insertion)
-- Note: With a 4096x4096 playable world, the min chunk size is 16x16 or we'll overflow the int.
--         We could do 8x8 if we use the fractional bits. e.g. index 1.00, 1.25, 1.5, 1.75 would be the four quadrants of index 1
function register_ant(ant)
  -- Single insertion at center (fast)
--  local index = flr((ant.x + 3) / 16) + flr(ant.y + 3) * 16
--
--  if projectile_m.partitions[index] == nil then
--    projectile_m.partitions[index] = {}
--  end
--  add(projectile_m.partitions[index], ant)

  -- Four corner insertion (accurate but +13% CPU at 100 ants vs single insert)
  local max_corner = 1
  for i = 0, 1 do
    for j = 0, 1 do
      -- TODO: if we make a 4096 map, index will overflow to negative on the bottom half of the map. Is that OK?
      local index = flr((ant.x + i*7) / 16) + flr((ant.y + j*7) / 16) * 256
    
      if projectile_m.partitions[index] == nil then
        projectile_m.partitions[index] = {}
      end

      local parts = projectile_m.partitions[index]
      if parts[#parts] ~= ant then
        add(parts, ant)
        local last_parts = projectile_m.last_partitions[index]
        max_corner = max(last_parts ~= nil and #last_parts or 0, max_corner)
      end

    end
  end

  return max_corner
end

function _projectile_manager_update(self)
  for p in all(self.projectiles) do
    if (p.frames > 0) then
      -- update projectiles
      p.x += p.vx
      p.y += p.vy
      p.frames -= 1

      -- check collisions
      local index = flr(p.x / 16) + flr(p.y / 16) * 256
      for ant in all(self.partitions[index]) do
        -- todo: is there a faster way to check a pixel overlapping a box???
        if not ((p.x > ant.x + 7) or (p.x < ant.x) or (p.y > ant.y + 7) or (p.y < ant.y)) then
          p.frames = 0
          if p.aoe == 0 then
            damage_ant(ant, p.damage)
          else
            handle_explosion(p.x, p.y, p.aoe, p.damage)
          end
          break
        end
      end
    end
  end

  -- clear partitions
  self.last_partitions = self.partitions
  self.partitions = {}
end

-- somehow, collision and projectiles code got tangled xD
function overlaps_ant(x, y, w, h)
  -- Check top-left and bottom-left corners in case they're in different parts
  for i = 0, 1 do
    local index = flr((x + w * i) / 16) + flr((y + h * i) / 16) * 256
    for ant in all(projectile_m.last_partitions[index]) do
      if not ((x > ant.x + 7) or (x + w < ant.x) or (y > ant.y + 7) or (y + h < ant.y)) then
        return true
      end
    end
  end
  return false
end

-- current maximum radius = 12 pixels
function handle_explosion(x, y, r, damage)
  for ant in all(ants) do
    if not ((x - r > ant.x + 8) or (x + r < ant.x) or (y - r > ant.y + 8) or (y + r < ant.y)) then
      damage_ant(ant, damage)
    end
  end

  -- Smoke effect
  for i = 1, 10 do
    add(objects, {
      frames = 35,
      fill = 0b0.1,
      vx = rnd(2)-1,
      vy = rnd(2)-1,
      x = x,
      y = y,
      r = r,
      update = function(self)
        self.x += self.vx
        self.y += self.vy
        self.r -= 0.1
        self.vx *= 0.95
        self.vy *= 0.95

        self.frames -= 1
        if self.frames == 0 then
          del(objects, self)
        elseif self.frames == 20 then
          self.fill = 0b0011001111001100.1
        elseif self.frames == 08 then
          self.fill = 0b1101111011110111.1
        elseif self.frames == 02 then
          self.fill = 0b1111011110111111.1
        end
      end,
      draw = function(self)
        if self.frames > 25 then
          circfill(x, y, self.r * 2, self.frames > 25 and 7)
        end
        if self.frames < 28 then
          fillp(self.fill)
          circfill(self.x, self.y + 1, self.r, 8)
          circfill(self.x    , self.y    , self.r, 9)
          fillp()
        end
        
      end
    })
  end
end

function _projectile_manager_draw(self)
  for p in all(self.projectiles) do
    if (p.frames > 0) then
      pset(p.x, p.y, p.color)
    end
  end

end

