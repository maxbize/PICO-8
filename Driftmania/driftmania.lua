-- driftmania
-- by @maxbize

--------------------
-- Global State
--------------------
local objects = {}
local player = nil

-- Current map sprites / chunks. map[x][y] -> sprite/chunk index
local map_road_tiles = nil
local map_road_chunks = nil
local map_prop_tiles = nil
local map_prop_chunks = nil

--------------------
-- Data
--------------------
local map_road_data = '000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001020303040501020303060700000000000000000008090a0b090c08090a0d090e0700000000000000000f10111213140f10110015090e07000000000000000f1400000f140f14000000150916000000000000000f1400000f140f14000000000f14000000000000000f1400000f140f14000000000f14000000000000000f1400001709091800000019091a000000000000000f140000121b1c11000019091d1e000000000000001f092000000000000019091d1e0000000000000000212209200000000019091d1e0000000000000000000021220903030303091d1e00000000000000000000000021230d0d0d0d241e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
local map_prop_data = '000000000000000000000000000000000000000000000025262727282925262727272a0000000000000000252b000000002c2b000000002d2a000000000000002e0000000000000000000000002d2a0000000000002f000030310000000030282900002d2a00000000002f00002f2f000000002f002c2900002f00000000002f00002f2f000000002f00003200002f00000000002f00002f2f000000002f00003300002f00000000002f00002f34000000003300353600002f00000000002f00003437380000353635360000393a00000000002f00003738373b3c3635360000393a0000000000002d2a0000373b27273c360000393a00000000000000002d2a0000000000000000393a000000000000000000002d2a000000000000393a0000000000000000000000002d2727272727273a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'

--------------------
-- Built-in Methods
--------------------

function _init()
  map_road_chunks, map_road_tiles = load_map(map_road_data, 21, 3)
  map_prop_chunks, map_prop_tiles = load_map(map_prop_data, 21, 3)

  spawn_player()
end

function _update60()
  for obj in all(objects) do
    obj.update(obj)
  end

end

function _draw()
  cls(0)

  draw_map(map_road_chunks, 21, 3, true, true)
  draw_map(map_prop_chunks, 21, 3, false, true)

  for obj in all(objects) do
    obj.draw(obj)
  end

  draw_map(map_prop_chunks, 21, 3, true, false)

  --_player_debug_draw(player)

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
    x_remainder = 0,
    y_remainder = 0,
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
  local new_angle = (self.angle_fwd + move_side * self.turn_rate_fwd) % 1
  if move_side == 0 then
    -- If there's no more side input, snap to the nearest 1/8th
    new_angle = round_nth(self.angle_fwd, 32)
  end
  self.angle_fwd = new_angle
  -- TODO: If we can't turn because of colliding, move the car to a position it can turn
  local collides, collides_x, collides_y = _player_collides_at(self.x, self.y, new_angle)
  while collides do
    local to_collision_x, to_collision_y = normalized(collides_x - self.x, collides_y - self.y)
    self.x -= round(to_collision_x)
    self.y -= round(to_collision_y)
    collides, collides_x, collides_y = _player_collides_at(self.x, self.y, new_angle)
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
  self.x, _, self.x_remainder, x_blocked = _player_move(self, self.v_x, self.x_remainder, 1, 0)
  _, self.y, self.y_remainder, y_blocked = _player_move(self, self.v_y, self.y_remainder, 0, 1)
  if x_blocked then
    self.v_x *= 0.25
  end
  if y_blocked then
    self.v_y *= 0.25
  end

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
end

-- Modified from https://maddymakesgames.com/articles/celeste_and_towerfall_physics/index.html
-- Returns final x, y pos and whether the move was blocked
function _player_move(self, amount, remainder, x_mask, y_mask)
  local x = self.x
  local y = self.y
  remainder += amount;
  local move = round(remainder);
  if move ~= 0 then
    remainder -= move;
    local sign = sgn(move);
    while move ~= 0 do
      if _player_collides_at(x + sign * x_mask, y + sign * y_mask, self.angle_fwd) then
        return x, y, remainder, true
      else
        x += sign * x_mask
        y += sign * y_mask
        move -= sign
      end
    end
  end
  return x, y, remainder, false
end

function _player_collides_at(x, y, angle)
  for i = -1, 1, 2 do
    for j = -1, 1, 2 do
      local check_x = flr(x) + cos(angle + 0.1 * i) * 5 * j
      local check_y = flr(y) + sin(angle + 0.1 * i) * 4 * j
      if (collides_at(check_x, check_y)) then
        return true, check_x, check_y
      end
    end
  end
  return false
end

function _player_debug_draw(self)
  -- Collision point visualization
  pset(self.x, self.y, 3)

  -- Front/back collision points
  for i = -1, 1, 2 do
    for j = -1, 1, 2 do
      local x = flr(self.x) + cos(self.angle_fwd + 0.1 * i) * 5 * j
      local y = flr(self.y) + sin(self.angle_fwd + 0.1 * i) * 4 * j
      --pset(x, y, collides_at(x, y) and 8 or 11)
    end
  end

--  -- Side collision points
--  for i = -1, 1, 2 do
--    local x = flr(self.x) + cos(self.angle_fwd + 0.25 * i) * 2
--    local y = flr(self.y) + sin(self.angle_fwd + 0.25 * i) * 2
--    pset(x, y, collides_at(x, y) and 8 or 11)
--  end

end

-- Checks if the given position on the map overlaps a wall
local collision_sprites = {[43]=true, [44]=true, [45]=true, [59]=true, [60]=true, [61]=true}
function collides_at(x, y)
  local sprite_index = map_prop_tiles[flr(x/8)][flr(y/8)]
  if sprite_index == nil then
    return false
  end
  if collision_sprites[sprite_index] then
    local sx = (sprite_index % 16) * 8 + x % 8
    local sy = flr(sprite_index / 16) * 8 + y % 8
    local col = sget(sx, sy)
    return col == 6
  end
  return false
end

--------------------
-- Map
--------------------

-- TODO: move map_size, chunk_size to data header?
function load_map(data, map_size, chunk_size)
  local chunks_per_row = flr(128/chunk_size)
  
  -- Initialize tables
  local map_tiles = {}
  local map_chunks = {}

  -- Parse data
  local num_chunks = #data / 2 -- todo: when we move to compression we should store this in the header
  for i = 0, num_chunks - 1 do
    -- The actual chunk index
    local chunk_index = tonum("0x" .. sub(data, i * 2 + 1, i * 2 + 2))

    -- "chunk map" x, y
    local chunk_x = i % map_size
    local chunk_y = flr(i / map_size)
    if map_chunks[chunk_x] == nil then map_chunks[chunk_x] = {} end
    map_chunks[chunk_x][chunk_y] = chunk_index

    -- top left corner of chunk in pico8 tile map
    local top_left_tile_x = (chunk_index % chunks_per_row) * chunk_size
    local top_left_tile_y = flr(chunk_index / chunks_per_row) * chunk_size
    for x = 0, 2 do
      for y = 0, 2 do
        local sprite_index = mget(top_left_tile_x + x, top_left_tile_y + y)
        local tile_x = chunk_x * chunk_size + x
        local tile_y = chunk_y * chunk_size + y
        if map_tiles[tile_x] == nil then map_tiles[tile_x] = {} end
        map_tiles[tile_x][tile_y] = sprite_index
      end
    end
  end

  return map_chunks, map_tiles
end

local sprite_sorts = {
  [43] = {y_intercept = 4, slope = 1}, 
  [44] = {y_intercept = -99, slope = 0}, -- Always draw car above vertical walls. To flip behavior, comment this out
  [45] = {y_intercept = 11, slope = -1}, 
  [59] = {y_intercept = -4, slope = 1}, 
  [60] = {y_intercept = 3, slope = 0}, 
  [61] = {y_intercept = 3, slope = -1}, 
}
function draw_map(map_chunks, map_size, chunk_size, draw_below_player, draw_above_player)
  -- Find the map index of the top-left map segment
  local camera_x = peek2(0x5f28)
  local camera_y = peek2(0x5f2a)
  local chunks_per_row = flr(128/chunk_size)
  local draw_distance = -flr(-16/chunk_size) -- -flr(-x) == ceil(x)

  for i = 0, draw_distance do
    for j = 0, draw_distance do
      local chunk_x = flr(camera_x / 8 / chunk_size)
      local chunk_y = flr(camera_y / 8 / chunk_size)

      chunk_x = mid(chunk_x + i, 0, map_size)
      chunk_y = mid(chunk_y + j, 0, map_size)

      local chunk_index = map_chunks[chunk_x][chunk_y]

      -- top left corner of chunk in pico8 tile map
      local tile_x = (chunk_index % chunks_per_row) * chunk_size
      local tile_y = flr(chunk_index / chunks_per_row) * chunk_size

      -- top left corner of chunk in world
      local world_x = chunk_x * chunk_size * 8
      local world_y = chunk_y * chunk_size * 8

      -- draw map with proper sorting
      for i = 0, chunk_size - 1 do
        local strip_world_y = world_y + i * 8 -- map strip
        local above_player = strip_world_y < player.y
        local contains_player = player.y - 9 < strip_world_y + 9 and player.y + 7 > strip_world_y and player.x - 6 < world_x + chunk_size * 8 and player.x + 5 > world_x - 2
        if (above_player and draw_above_player) or (not above_player and draw_below_player) or contains_player then
          if not contains_player then
            map(tile_x, tile_y + i, world_x, strip_world_y, chunk_size, 1)
          else
            for j = 0, chunk_size - 1 do
              local sprite_index = mget(tile_x + j, tile_y + i)
              local draw = true
              local sprite_x = world_x + j * 8
              local sprite_y = world_y + i * 8
              if sprite_sorts[sprite_index] ~= nil then
                -- Project a line and see if the car is above or below it
                local sprite_y_intercept = sprite_y + sprite_sorts[sprite_index].y_intercept
                local car_y_intercept = player.y + (sprite_x - player.x) * sprite_sorts[sprite_index].slope
                above_player = sprite_y_intercept < car_y_intercept
                draw = (above_player and draw_above_player) or (not above_player and draw_below_player)
              end
              if draw then
                spr(sprite_index, sprite_x, sprite_y)
              end
            end
          end
        end
      end

    end
  end
end
