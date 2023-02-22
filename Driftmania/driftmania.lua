-- driftmania
-- by @maxbize

--------------------
-- Global State
--------------------
local objects = {}
local player = nil
local projectile_m = nil

--------------------
-- Data
--------------------
local map_data = '000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001020303040501020303060700000000000000000008090a0b090c08090a0d090e0700000000000000000f10111213140f10110015090e07000000000000000f1400000f140f14000000150916000000000000000f1400000f140f14000000000f14000000000000000f1400000f140f14000000000f14000000000000000f1400001709091800000019091a000000000000000f140000121b1c11000019091d1e000000000000001f092000000000000019091d1e0000000000000000212209200000000019091d1e0000000000000000000021220903030303091d1e00000000000000000000000021230d0d0d0d241e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'

--------------------
-- Built-in Methods
--------------------

function _init()
  spawn_player()
end

function _update60()
  for obj in all(objects) do
    obj.update(obj)
  end

end

function _draw()
  cls(0)

  draw_map()

  for obj in all(objects) do
    obj.draw(obj)
  end

  draw_props()

end


--------------------
-- Utility Methods
--------------------

-- Given an angle and a magnitude return x, y components
function angle_vector(theta, magnitude)
  return magnitude * cos(theta),
         magnitude * sin(theta)
end

-- Dot product
function dot(x1, y1, x2, y2)
  return x1 * x2 + y1 * y2
end

function dist(dx, dy)
  return sqrt(dx * dx + dy * dy)
end

function normalized(x, y)
  local mag = dist(x, y)
  if mag == 0 then
    return 0, 0
  end
  return x / mag, y / mag
end

-- Round a number 0-1 to its nearest 1/n th
function round_nth(x, n)
  local lower = flr(x * n) / n
  return x - lower < (0.5 / n) and lower or lower + 1 / n
end

function round(n)
  return n%1 < 0.5 and flr(n) or -flr(-n)
end

-- Courtesy TheRoboZ
function pd_rotate(x,y,rot,mx,my,w,flip,scale)
  scale=scale or 1
  w*=scale*4

  local cs, ss = cos(rot)*.125/scale,sin(rot)*.125/scale
  local sx, sy = mx+cs*-w, my+ss*-w
  local hx = flip and -w or w

  local halfw = -w
  for py=y-w, y+w do
    tline(x-hx, py, x+hx, py, sx-ss*halfw, sy+cs*halfw, cs, ss)
    halfw+=1
  end
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
    angle_fwd = 0,
    v_x = 0,
    v_y = 0,
    turn_rate_fwd = 0.008,
    turn_rate_vel = 0.005,
    accel = 0.075,
    brake = 0.05,
    max_speed_fwd = 2,
    max_speed_rev = -1, -- TODO: fix
    f_friction = 0.005,
    f_corrective = 0.1,
  }
  add(objects, player)
end

function _player_update(self)
  -- Input
  local move_side = 0
  local move_fwd = 0
  if btn(0) then move_side += 1 end
  if btn(1) then move_side -= 1 end
  if btn(2) then move_fwd  += 1 end
  if btn(3) then move_fwd  -= 1 end

  -- Visual Rotation
  self.angle_fwd += move_side * self.turn_rate_fwd
  if move_side == 0 then
    -- If there's no more side input, snap to the nearest 1/8th
    self.angle_fwd = round_nth(self.angle_fwd, 32)
  end
  if self.angle_fwd < 0 then
    self.angle_fwd += 1
  elseif self.angle_fwd >= 1 then
    self.angle_fwd -= 1
  end

  local fwd_x, fwd_y = angle_vector(self.angle_fwd, 1)
  local v_x_normalized, v_y_normalized = normalized(self.v_x, self.v_y)

  -- Acceleration, friction, breaking. Note: mid is to stop over-correction
  if move_fwd > 0 then
    self.v_x += fwd_x * self.accel
    self.v_y += fwd_y * self.accel
  elseif move_fwd == 0 then
    self.v_x -= mid(v_x_normalized * self.f_friction, self.v_x, -self.v_x)
    self.v_y -= mid(v_y_normalized * self.f_friction, self.v_y, -self.v_y)
  elseif move_fwd < 0 then
    self.v_x -= mid(v_x_normalized * self.brake, self.v_x, -self.v_x)
    self.v_y -= mid(v_y_normalized * self.brake, self.v_y, -self.v_y)
  end

  -- Corrective side force
  -- Note: (x, y, 0) cross (0, 0, 1) -> (y, -x, 0)
  local right_x, right_y = fwd_y, -fwd_x
  local vel_dot_fwd = dot(fwd_x, fwd_y, v_x_normalized, v_y_normalized)
  local vel_dot_right = dot(right_x, right_y, v_x_normalized, v_y_normalized)
  self.v_x -= mid((1 - abs(vel_dot_fwd)) * right_x * sgn(vel_dot_right) * self.f_corrective, self.v_x, -self.v_x)
  self.v_y -= mid((1 - abs(vel_dot_fwd)) * right_y * sgn(vel_dot_right) * self.f_corrective, self.v_y, -self.v_y)

  -- Speed limit
  local angle_vel = atan2(self.v_x, self.v_y)
  self.v_x, self.v_y = angle_vector(v_theta, mid(dist(self.v_x, self.v_y), self.max_speed_fwd, self.max_speed_rev))

  -- Velocity rotation
  -- TODO: Cleanup ;)
  local a = self.angle_fwd - angle_vel
  if abs(a) < self.turn_rate_vel * 1.1 then
    angle_vel = self.angle_fwd
  else
    if a < 0 then
      a += 1
    end
    if a < 0.5 then
      angle_vel += self.turn_rate_vel * abs(vel_dot_right)
    else
      angle_vel -= self.turn_rate_vel * abs(vel_dot_right)
    end
    if angle_vel < 0 then
      angle_vel += 1
    elseif angle_vel > 1 then
      angle_vel -= 1
    end
  end
  self.v_x, self.v_y = angle_vector(angle_vel, dist(self.v_x, self.v_y))

  -- Apply Movement
  self.x += self.v_x
  self.y += self.v_y

  camera(self.x - 64, self.y - 64)
end

function _player_draw(self)
  palt(0, false)
  palt(15, true)
  local scale = 1
  -- Costs 6% of CPU budget
  for i = 0, 4 do
    pd_rotate(self.x,self.y-i*scale,round_nth(self.angle_fwd, 32),127,30.5 - i*2,2,true,scale)
  end
  palt(0, true)
  palt(15, false)

  --function pd_rotate(x,y,rot,mx,my,w,flip,scale)
  --pd_rotate(self.x,self.y,-self.angle_fwd,72,3,2,false,1)

  -- debugging
  --local look_x, look_y = angle_vector(self.angle_fwd, self.speed + 5)
  --line(self.x, self.y, self.x + look_x * 5, self.y + look_y * 5, 1)
  --local speed_x, speed_y = angle_vector(self.angle_vel, self.speed + 5)
  --line(self.x, self.y, self.x + speed_x * 5, self.y + speed_y * 5, 3)
end

--------------------
-- Map
--------------------

function draw_map()
  -- Constants for the map string (todo: move to string header)
  local chunk_size = 3
  local pix_per_chunk = chunk_size * 8
  local map_size = 21 -- 21x21 chunk map (63x63 tiles)
  local chunks_per_row = flr(128/chunk_size)

  -- Find the map index of the top-left map segment
  local camera_x = peek2(0x5f28)
  local camera_y = peek2(0x5f2a)
  local top_left = flr((camera_x + 64) / 32) + 64 * flr((camera_y + 64) / 32)

  -- Draw all map segments surrounding the player
  for x = -2, 2 do
    for y = -2, 2 do
      --local data_index = top_left + x + 64 * y
      --local map_tile = tonum("0x" .. sub(map_data, data_index * 2 + 1, data_index * 2 + 2))
      --map_tile -= 1 -- Tiled uses index 0 for "empty" but we use it as tile 0
      --map(map_tile % 32 * 4, flr(map_tile / 32) * 4, data_index % 64 * 32, flr(data_index / 64) * 32, 4, 4)
    end
  end

--  for x = 0, map_size - 1 do
--    for y = 0, map_size - 1 do
--      local data_index = y * map_size + x
--      local map_tile = tonum("0x" .. sub(map_data, data_index * 2 + 1, data_index * 2 + 2))
--      map(map_tile % pix_per_chunk * chunk_size, flr(map_tile / pix_per_chunk) * chunk_size, x * pix_per_chunk, y * pix_per_chunk, chunk_size, chunk_size)
--    end
--  end

-- MAP(TILE_X, TILE_Y, [SX, SY], [TILE_W, TILE_H], [LAYERS])

  for i = 0, #map_data / 2 - 1 do
    -- The actual chunk index
    local chunk_index = tonum("0x" .. sub(map_data, i * 2 + 1, i * 2 + 2))

    -- top left corner of chunk in pico8 tile map
    local tile_x = chunk_index * chunk_size
    local tile_y = 0 -- todo: multi-row maps

    -- Re-interpret i into a "chunk map" x, y
    local x_index = i % map_size
    local y_index = flr(i / map_size)

    -- top left corner of chunk in world
    local world_x = x_index * chunk_size * 8
    local world_y = y_index * chunk_size * 8

    map(tile_x, tile_y, world_x, world_y, chunk_size, chunk_size)

  end

end


function draw_props()

  local camera_y = peek2(0x5f2a)
  local delta = mid(round((camera_y+30)/20), -1, 1)
  print(camera_y)

  for x = 0, 10 do
    for i = 0, 2 do
      spr(43 + i, 75 + x * 8, 30 - i * delta)
    end
  end

  for x = 0, 10 do
    for i = 0, 3 do
      --spr(59 + i, 75-8 - x * 8, 30+8 + x * 8 - i * delta)
    end
  end


end