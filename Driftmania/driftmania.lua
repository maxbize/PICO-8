-- driftmania
-- by @maxbize

--------------------
-- Global State
--------------------
local objects = {}
local player = nil
local level_m = nil
local trail_m = nil
local particle_m = nil

-- Current map sprites / chunks. map[x][y] -> sprite/chunk index
local map_road_tiles = nil
local map_road_chunks = nil
local map_decl_tiles = nil
local map_decl_chunks = nil
local map_prop_tiles = nil
local map_prop_chunks = nil

-- Ghost cars
local ghost_recording = {}
local ghost_playback = {}
local ghost_start_last = {} -- x, y, etc for first frame
local ghost_start_best = {} -- x, y, etc for first frame
-- Allocate buffers on init
for i = 1, 0x7fff do
  add(ghost_recording, 0)
  add(ghost_playback, 0)
end

--------------------
-- Data
--------------------
local map_road_data = '000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001020303040501020303060700000000000000000008090a0b090c0d090a0e090f0700000000000000001011121314090911120015090f070000000000000010160000100909160000001509170000000000000010160000100909160000000010160000000000000010160000100909160000000010160000000000000010160000180909190000001a091b0000000000000010160000131c1d1200001a091e1f000000000000002009210000000000001a091e1f000000000000000022230921000000001a091e1f0000000000000000000022230903030303091e1f00000000000000000000000022240e0e0e0e251f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
local map_decl_data = '262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262627282626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626292626262626262626262626262626262626262626292626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626'
local map_prop_data = '26262626262626262626262626262626262626262626262a2b2c2c2d2e2a2b2c2c2c2f26262626262626262a3026262626313226262626332f2626262626262634262626262635362626262626332f262626262626372626383926353626382d2e2626332f262626262637262637372635362637263a2e26263726262626263726263737263536263726263b26263726262626263726263737263c3d263726263e2626372626262626372626373f262626263e26404126263726262626263726263f4243262640414041262644452626262626372626424342464741404126264445262626262626332f262642462c2c4741262644452626262626262626332f2626262626262626444526262626262626262626332f2626262626264445262626262626262626262626332c2c2c2c2c2c45262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626'
local map_settings = {laps=3}
local map_checkpoints = {{x=19.5*8, y=35*8, w=2, h=8*8, spawn_x=21*8, spawn_y=39*8, spawn_dir=0.5}, {x=24*8, y=14*8+3, w=8*8, h=2}}

--------------------
-- Built-in Methods
--------------------

function _init()
  map_road_chunks, map_road_tiles = load_map(map_road_data, 21, 3)
  map_decl_chunks, map_decl_tiles = load_map(map_decl_data, 21, 3)
  map_prop_chunks, map_prop_tiles = load_map(map_prop_data, 21, 3)

  spawn_level_manager()
  spawn_player()
  spawn_trail_manager()
  spawn_particle_manager()
end

function _update60()
  for obj in all(objects) do
    obj.update(obj)
  end

  _car_update(player)
  _particle_manager_update(particle_m)

end

function _draw()
  cls(0)

  draw_map(map_road_chunks, 21, 3, true, true)
  draw_map(map_decl_chunks, 21, 3, true, true)
  _trail_manager_draw(trail_m)
  draw_map(map_prop_chunks, 21, 3, false, true)

  for obj in all(objects) do
    obj.draw(obj)
  end

  _particle_manager_draw(particle_m)
  _car_draw(player)

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
-- Car class (player + ghost)
--------------------
function spawn_player()
  local x = level_m.checkpoints[1].spawn_x
  local y = level_m.checkpoints[1].spawn_y
  local dir = level_m.checkpoints[1].spawn_dir  

  player = create_car(x, y, 0, 0, 0, 0, dir, false)
  _set_ghost_start(player)

  -- Not adding to objects to have better control over draw order
  --add(objects, player)
end

function spawn_ghost()
  local gs = ghost_start_best
  local ghost = create_car(gs.x, gs.y, gs.x_remainder, gs.y_remainder, gs.v_x, gs.v_y, gs.dir, true)
  ghost.update = _ghost_update
  ghost.buffer = ghost_playback
  ghost.frame = 1
  add(objects, ghost)
end

function create_car(x, y, x_remainder, y_remainder, v_x, v_y, dir, is_ghost)
  return {
    update = _car_update,
    draw = _car_draw,
    x = x,
    y = y,
    x_remainder = x_remainder,
    y_remainder = y_remainder,
    angle_fwd = dir,
    v_x = v_x,
    v_y = v_y,
    turn_rate_fwd = 0.008,
    turn_rate_vel = 0.005,
    accel = 0.075,
    brake = 0.05,
    max_speed_fwd = 2,
    max_speed_rev = -1, -- TODO: fix
    f_friction = 0.01,
    f_corrective = 0.1,
    is_ghost = is_ghost,
    drifting = false,
    wheel_offsets = {{x=0, y=0}, {x=0, y=0}, {x=0, y=0}, {x=0, y=0}},
    dirt_frames = {0, 0, 0, 0},
    drift_boost_buildup = 0,
    drift_boost_frames = 0,
  }
end

function _set_ghost_start(self)
  ghost_start_last = {
    x = self.x,
    y = self.y,
    x_remainder = self.x_remainder,
    y_remainder = self.y_remainder,
    dir = self.angle_fwd,
    v_x = self.v_x,
    v_y = self.v_y,
  }
end

function _car_update(self)
  _car_move(self, btn())

  -- Record ghost
  if level_m.frame == 0 then
    throw()
  end
  ghost_recording[level_m.frame] = btn()

  -- Move camera
  camera(self.x - 64, self.y - 64)
end

function _ghost_update(self)
  local btns = self.buffer[self.frame]
  if btns == -1 then
    del(objects, self)
  else
    _car_move(self, btns)
  end
  self.frame += 1
end

function _car_move(self, btns)
  -- Input
  local move_side = 0
  local move_fwd = 0
  if btns & 0x1 > 0 then move_side += 1 end
  if btns & 0x2 > 0 then move_side -= 1 end
  if btns & 0x4 > 0 then move_fwd  += 1 end
  if btns & 0x8 > 0 then move_fwd  -= 1 end
  local d_brake = btns & 0x10 > 0

  -- Misc data
  local fwd_x, fwd_y = angle_vector(self.angle_fwd, 1)
  local v_x_normalized, v_y_normalized = normalized(self.v_x, self.v_y)
  local vel_dot_fwd = dot(fwd_x, fwd_y, v_x_normalized, v_y_normalized)

  -- Get the wheel modifiers (boost, road, grass, etc)
  local grass_wheels = 0
  for i, offset in pairs(self.wheel_offsets) do
    local check_x = flr(self.x) + offset.x
    local check_y = flr(self.y) + offset.y
    -- Visual only when on the road?
    local collides_grass = collides_grass_at(check_x, check_y)
    if collides_grass then
      grass_wheels += 1
    end
    if not collides_grass and self.dirt_frames[i] > 0 then
      add_trail_point(trail_m, check_x, check_y, 4)
      self.dirt_frames[i] -= 1
    end
  end

  -- Apply the wheel modifiers
  local mod_turn = 1
  local mod_corrective = 1
  local mod_max_vel = 1
  local mod_friction = 1
  local mod_accel = 1
  if grass_wheels >= 2 then
    mod_turn = 0.25
    mod_corrective = 0.25
    --mod_max_vel = 0.9
    mod_accel = 0.5
  end

  -- Visual Rotation
  self.angle_fwd = (self.angle_fwd + move_side * self.turn_rate_fwd * (d_brake and 1.5 * abs(vel_dot_fwd) or 1)) % 1
  if move_side == 0 then
    -- If there's no more side input, snap to the nearest 1/8th
    self.angle_fwd = round_nth(self.angle_fwd, 32)
  end

  -- Drift boost
  local buildup_threshold = 15
  local boost_duration = 45
  local first_boost_frame = false
  if d_brake then
    local speed = dist(self.v_x, self.v_y)
    if abs(vel_dot_fwd) < 0.85 and speed > 1 then
      self.drift_boost_buildup += 1
      if self.drift_boost_buildup >= buildup_threshold then
        self.drift_boost_buildup = buildup_threshold + 30 -- hold frames
      end
      _wheel_particles(self, self.drift_boost_buildup >= buildup_threshold and 12 or 10)
    else
      if self.drift_boost_buildup >= buildup_threshold then
        _wheel_particles(self, 12)
      end
      self.drift_boost_buildup -= 1
    end
  else
    if self.drift_boost_buildup >= buildup_threshold then
      self.drift_boost_frames = boost_duration
      first_boost_frame = true
    end
    self.drift_boost_buildup = 0
  end
  if self.drift_boost_frames > 0 then
    self.drift_boost_frames -= 1
    mod_max_vel *= 1 + (0.5 * self.drift_boost_frames / boost_duration)
    mod_turn *= 1 + (5 * self.drift_boost_frames / boost_duration)
    if first_boost_frame then
      for i = 1, 10 do
        _wheel_particles(self, 8)
      end
      local angle_vel = atan2(self.v_x, self.v_y)
      self.v_x, self.v_y = angle_vector(angle_vel, self.max_speed_fwd * mod_max_vel)
    end
  end

  -- Update wheel offsets
  local wheel_idx = 1
  for i = -1, 1, 2 do
    for j = -1, 1, 2 do
      local wheel_x = cos(self.angle_fwd + 0.1 * i) * 5 * j
      local wheel_y = sin(self.angle_fwd + 0.1 * i) * 4 * j
      self.wheel_offsets[wheel_idx] = {x=wheel_x, y=wheel_y}
      wheel_idx += 1
    end
  end

  -- If we can't turn because of colliding nudge the car a little
  local collides, collides_x, collides_y = _player_collides_at(self, self.x, self.y, self.angle_fwd)
  while collides do
    local to_collision_x, to_collision_y = normalized(collides_x - self.x, collides_y - self.y)
    self.x -= round(to_collision_x)
    self.y -= round(to_collision_y)
    collides, collides_x, collides_y = _player_collides_at(self, self.x, self.y, self.angle_fwd)
  end

  -- Acceleration, friction, breaking. Note: mid is to stop over-correction
  if d_brake then
    local f_stop = (move_fwd > 0 and self.f_friction * 0.5
                or (move_fwd == 0 and self.f_friction * 2 
                or (move_fwd < 0 and self.brake * 2 or 1000)))
    self.v_x -= mid(v_x_normalized * f_stop, self.v_x, -self.v_x)
    self.v_y -= mid(v_y_normalized * f_stop, self.v_y, -self.v_y)
  else
    if move_fwd > 0 then
      self.v_x += fwd_x * self.accel * mod_accel
      self.v_y += fwd_y * self.accel * mod_accel
    elseif move_fwd == 0 then
      self.v_x -= mid(v_x_normalized * self.f_friction * mod_friction, self.v_x, -self.v_x)
      self.v_y -= mid(v_y_normalized * self.f_friction * mod_friction, self.v_y, -self.v_y)
    elseif move_fwd < 0 then
      self.v_x -= mid(v_x_normalized * self.brake, self.v_x, -self.v_x)
      self.v_y -= mid(v_y_normalized * self.brake, self.v_y, -self.v_y)
    end
  end

  -- Corrective side force
  -- Note: (x, y, 0) cross (0, 0, 1) -> (y, -x, 0)
  local right_x, right_y = fwd_y, -fwd_x
  local vel_dot_right = dot(right_x, right_y, v_x_normalized, v_y_normalized)
  self.drifting = d_brake --abs(vel_dot_right) > 0.65
  if not d_brake then
    self.v_x -= mid((1 - abs(vel_dot_fwd)) * right_x * sgn(vel_dot_right) * self.f_corrective * mod_corrective, self.v_x, -self.v_x)
    self.v_y -= mid((1 - abs(vel_dot_fwd)) * right_y * sgn(vel_dot_right) * self.f_corrective * mod_corrective, self.v_y, -self.v_y)
  end

  -- Speed limit
  local angle_vel = atan2(self.v_x, self.v_y)
  self.v_x, self.v_y = angle_vector(v_theta, mid(dist(self.v_x, self.v_y), self.max_speed_fwd * mod_max_vel, self.max_speed_rev))

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
      angle_vel += self.turn_rate_vel * abs(vel_dot_right) * mod_turn
    else
      angle_vel -= self.turn_rate_vel * abs(vel_dot_right) * mod_turn
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
end

function _wheel_particles(self, c)
  for i = 1, 3, 2 do -- back wheels
    local wheel_x = flr(self.x) + self.wheel_offsets[i].x
    local wheel_y = flr(self.y) + self.wheel_offsets[i].y
    add_particle(particle_m, wheel_x, wheel_y, c, rnd(0.5)-0.25, rnd(0.5)-0.25, 15)
  end
end

function _car_draw(self)
  palt(0, false)
  palt(15, true)
  local scale = 1
  if self.is_ghost then
    pal(8, 2)
    pal(10, 4)
    pal(12, 13)
    pal(7, 6)
    pal(6, 1)
  end
  -- Costs 6% of CPU budget
  for i = 0, 4 do
    pd_rotate(self.x,self.y-i*scale,round_nth(self.angle_fwd, 32),127,30.5 - i*2,2,true,scale)
  end
  pal()
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
      if _player_collides_at(self, x + sign * x_mask, y + sign * y_mask, self.angle_fwd) then
        return x, y, remainder, true
      else
        x += sign * x_mask
        y += sign * y_mask
        move -= sign
        if not self.is_ghost then
          _on_player_moved(self, x, y, self.angle_fwd)
        end
      end
    end
  end
  return x, y, remainder, false
end

-- Called whenever the player occupies a new position. Can be called multiple times per frame
function _on_player_moved(self, x, y, angle)
  for i, offset in pairs(self.wheel_offsets) do
    local check_x = flr(x) + offset.x
    local check_y = flr(y) + offset.y
    if (collides_checkpoint_at(check_x, check_y)) then
      on_checkpoint_crossed(level_m)
    end
    if i % 2 == 0 and collides_grass_at(check_x, check_y) then -- front wheels
      self.dirt_frames[i] = 10
      add_trail_point(trail_m, check_x, check_y, 4)
    end
    if i % 2 == 1 and self.drifting then -- back wheels
      add_trail_point(trail_m, check_x, check_y, 0)
    end
  end
end

function _player_collides_at(self, x, y, angle)
  for offset in all(self.wheel_offsets) do
    local check_x = flr(x) + offset.x
    local check_y = flr(y) + offset.y
    if (collides_wall_at(check_x, check_y)) then
      return true, check_x, check_y
    end
  end
  return false
end

function _player_debug_draw(self)
  -- Collision point visualization
  pset(self.x, self.y, 3)

  -- Front/back collision points
  for i, offset in pairs(self.wheel_offsets) do
    local x = flr(self.x) + offset.x
    local y = flr(self.y) + offset.y
    pset(x, y, collides_wall_at(x, y) and 8 or 11)
    --checkpoint_check(x, y)
  end

--  -- Side collision points
--  for i = -1, 1, 2 do
--    local x = flr(self.x) + cos(self.angle_fwd + 0.25 * i) * 2
--    local y = flr(self.y) + sin(self.angle_fwd + 0.25 * i) * 2
--    pset(x, y, collides_wall_at(x, y) and 8 or 11)
--  end

end

-- Checks if the given position on the map overlaps a wall
local wall_collision_sprites = {[43]=true, [44]=true, [45]=true, [59]=true, [60]=true, [61]=true}
function collides_wall_at(x, y)
  local sprite_index = map_prop_tiles[flr(x/8)][flr(y/8)]
  if sprite_index == nil then
    return false
  end
  if wall_collision_sprites[sprite_index] then
    local sx = (sprite_index % 16) * 8 + x % 8
    local sy = flr(sprite_index / 16) * 8 + y % 8
    local col = sget(sx, sy)
    return col == 6
  end
  return false
end

-- TODO: lots of duplication with above function
local grass_sprites = {[6]=true, [7]=true, [8]=true, [9]=true, [26]=true,}
function collides_grass_at(x, y)
  local sprite_index = map_road_tiles[flr(x/8)][flr(y/8)]
  if sprite_index == nil then
    return false
  end
  if grass_sprites[sprite_index] then
    local sx = (sprite_index % 16) * 8 + x % 8
    local sy = flr(sprite_index / 16) * 8 + y % 8
    local col = sget(sx, sy)
    return col == 3
  end
  return false
end

function collides_checkpoint_at(x, y)
  local cp = level_m.checkpoints[level_m.next_checkpoint]
  local overlaps = 
    x >= cp.x and
    x < cp.x + cp.w and
    y >= cp.y and
    y < cp.y + cp.h
  return overlaps
end

--------------------
-- Level Management
--------------------
function spawn_level_manager()
  level_m = {
    update = _level_manager_update,
    draw = _level_manager_draw,
    index = index,
    settings = map_settings,
    checkpoints = map_checkpoints,
    next_checkpoint = 2,
    checkpoint_frames = {}, -- Order: 2, 3, 4, ... 1
    best_checkpoint_frames = {},
    frame = 0,
  }
  add(objects, level_m)
end

function _level_manager_update(self)
  if (self.frame < 0x7fff) then
    self.frame += 1
  end
end

function _level_manager_draw(self)
end

function frame_to_time_str(frames)
  -- mm:ss.mm. Max time 546.13 sec
  local min = '0' .. tostr(flr(frames/3600))
  local sec = tostr(flr(frames/60%60))
  local sub_sec = tostr(flr(frames%60))
  return min .. ':' .. (#sec == 1 and '0' or '') .. sec .. '.' .. (#sub_sec == 1 and '0' or '') .. sub_sec
end

function on_checkpoint_crossed(self)
  -- Record checkpoint time
  self.checkpoint_frames[self.next_checkpoint] = self.frame

  -- Display checkpoint time and delta
  add(objects, {
    time = self.frame,
    best_time = count(self.best_checkpoint_frames) > 0 and self.best_checkpoint_frames[self.next_checkpoint] or 0,
    life = 60,
    update = function(self)
      self.life -= 1
      if self.life == 0 then
        del(objects, self)
      end
    end,
    draw = function(self)
      print(frame_to_time_str(self.time), player.x - 14, player.y - 32, 7)
      if self.best_time ~= 0 then
        print((self.best_time > self.time and '-' or '+') 
          .. frame_to_time_str(abs(self.best_time - self.time)), player.x - 18, player.y - 26,
          self.best_time > self.time and 11 or 8)
      end
    end,
  })

  -- Completed a lap
  if self.next_checkpoint == 1 then
    if count(self.best_checkpoint_frames) == 0 or self.best_checkpoint_frames[1] > self.frame then
      self.best_checkpoint_frames = {}
      for frame in all(self.checkpoint_frames) do
        add(self.best_checkpoint_frames, frame)
      end
      ghost_recording, ghost_playback = ghost_playback, ghost_recording
      ghost_playback[self.frame + 1] = -1
      ghost_start_best = ghost_start_last
    end
    --pawn_ghost() -- TODO: Ghost is not accurate
    _set_ghost_start(player)
    self.frame = 1
  end

  -- Advance checkpoint marker
  self.next_checkpoint = (self.next_checkpoint % count(self.checkpoints)) + 1
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

--------------------
-- VFX
--------------------

function spawn_trail_manager()
  trail_m = {
    update = _trail_manager_update,
    draw = _trail_manager_draw,
    points = {},
    points_i = 1,
    max_points = 1000, -- 10% CPU per 1k
  }

  for i = 1, trail_m.max_points do
    add(trail_m.points, {x=0, y=0, c=0})
  end

  -- Not adding to objects to have better control over draw order
  --add(objects, trail_m)
end

function add_trail_point(self, x, y, c)
  self.points[self.points_i] = {x=x, y=y, c=c}
  self.points_i = (self.points_i % self.max_points) + 1
end

function _trail_manager_update(self)
end

function _trail_manager_draw(self)
  for i = 1, self.max_points do
    local p = self.points[i]
    pset(p.x, p.y, p.c)
  end
end


-- Similar to Trail Manager, but particles are more complex and short-lived
function spawn_particle_manager()
  particle_m = {
    update = _particle_manager_update,
    draw = _particle_manager_draw,
    points = {},
    points_i = 1,
    max_points = 100,
  }

  for i = 1, particle_m.max_points do
    add(particle_m.points, {x=0, y=0, c=0, v_x=0, v_y=0, t=0})
  end

  -- Not adding to objects to have better control over draw order
  --add(objects, trail_m)
end

function add_particle(self, x, y, c, v_x, v_y, t)
  self.points[self.points_i] = {x=x, y=y, c=c, v_x=v_x, v_y=v_y, t=t}
  self.points_i = (self.points_i % self.max_points) + 1
end

function _particle_manager_update(self)
  for i = 1, self.max_points do
    local p = self.points[i]
    p.x += p.v_x
    p.y += p.v_y
    p.t -= 1
  end
end

function _particle_manager_draw(self)
  for i = 1, self.max_points do
    local p = self.points[i]
    if p.t > 0 then
      pset(p.x, p.y, p.c)
    end
  end
end


