-- driftmania
-- by @maxbize

--------------------
-- Global State
--------------------
local objects = {}
local player = nil
local level_m = nil
local trail_m = nil
local particle_front_m = nil
local particle_back_m = nil
local particle_water_m = nil

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
local map_road_data = '0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001020203000000000000000000000000000000000000000000000000000004050505030000000000000000000000000000000000000000000000000004050505050300000000000000000000000000000000000000000000000006050505050503000000000000000000000000000000000000000000000000060505050505030000000000000000000000000000000000000000000000000605050505050300000000000000000000000000000000000000000000000006050505050502020202020202020700000000000000000000000000000000060505050508080808080809050a00000000000000000000000000000000000605050b0000000000000c0d0a000000000000000000000000000000000000040a0000000000000000040a000000000000000000000000000000000000040a0000000000000000040a0000000000000000000000000000000000000e0f0000000000000000040a00000000000000000000000000000000000000000000000000000000040a00000000000000000000000000000000000000000000000000000000040a00000000000000000000000000000000000010070000000000000000040a000000000000000000000000000000000000040a0000000000000000040a0000000000000000000000000000000000000411120000000000001314111200000000000000000000000000000000000405150202020202021605051502020202070000000000000000000000000e080808080808080809050517080809050a0000000000000000000000000000000000000000000c0d181900000c0d0a00000000000000000000000000000000000000000000040a00000000040a00000000000000000000000000000000000000000000040a00000000040a00000000000000000000000000000000000000000000041112000013140a00000000000000000000000000000000000000000000040515020216050a000000000000000000000000000000000000000000000e0808080808080f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
local map_decals_data = '0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a000000000000000000000000000000000000000000000000000000001b000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000001d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e1f000000000000000000000000000000000000000000000000000000002021000000000000000000000000000000000000000000000000000000000000000000000000000022230000000000000000000000000000000000000000000000000000000024250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000260000000000000026000000000000000000000000000000000000000000000000002700000000000000270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000028000000000000000000000000000000000000000000000000000000000000290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
local map_props_data = '000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002a2b2b2c000000000000000000000000000000000000000000000000002d2e00002f3000000000000000000000000000000000000000000000000031003233002f30000000000000000000000000000000000000000000000031002f3433002f30000000000000000000000000000000000000000000003533002f3433002f30000000000000000000000000000000000000000000003633002f3433002f30000000000000000000000000000000000000000000003633002f3433002f372b2b2b2b2b2b2b2b38000000000000000000000000003633002f3433000000000000000000003100000000000000000000000000003633002f3433000000000000000000310000000000000000000000000000003633002f392b2b2b2b2b2b38000031000000000000000000000000000000003a00003100000000000031000031000000000000000000000000000000003100003100000000000031000031000000000000000000000000000000003100003100000000000031000031000000000000000000000000000000003100003100000000000031000031000000000000000000000000000000003100003100000000000031000031000000000000000000000000000000003100003100000000000031000031000000000000000000000000000000003100003100000000000031000031000000000000000000000000000000003100003b2b2b2b2b2b2b3c00003b2b2b2b2b2b38000000000000000000003100000000000000000000000000000000000031000000000000000000003100000000000000000000000000000000000031000000000000000000003b2b2b2b2b2b2b2b2b2b3800003d2b2b3800003100000000000000000000000000000000000000003100003100003100003100000000000000000000000000000000000000003100003100003100003100000000000000000000000000000000000000003100003b2b2b3c00003100000000000000000000000000000000000000003100000000000000003100000000000000000000000000000000000000003100000000000000003100000000000000000000000000000000000000003b2b2b2b2b2b2b2b2b3c00000000000000000000000000000000000000000000000000000000000000'
local map_settings = {laps=3, size=30, spawn_x=27*8, spawn_y=20*8, spawn_dir=0.375}
--local map_settings = {laps=3, size=21, spawn_x=22*8, spawn_y=39*8, spawn_dir=0.5}
local map_checkpoints = {{x=236,y=124,dx=-1,dy=1,l=40},{x=188,y=172,dx=-1,dy=1,l=40},{x=604,y=604,dx=1,dy=1,l=72}}
local gradients =     {0, 1, 1, 2, 1, 13, 6, 2, 4, 9, 3, 1, 5, 13, 14}
local gradients_rev = {12, 8, 11, 9, 13, 14, 7, 8, 10, 7, 11, 12, 14, 15, 7}
local outline_cache = {}
local bbox_cache = {}

--------------------
-- Built-in Methods
--------------------

function _init()
  init_outline_cache(outline_cache, 30.5)
  init_outline_cache(bbox_cache, 28.5)

  map_road_chunks, map_road_tiles = load_map(map_road_data, map_settings.size, 3)
  map_decl_chunks, map_decl_tiles = load_map(map_decals_data, map_settings.size, 3)
  map_prop_chunks, map_prop_tiles = load_map(map_props_data, map_settings.size, 3)

  spawn_level_manager()
  spawn_player()
  spawn_trail_manager()
  particle_back_m = spawn_particle_manager_vol()
  particle_front_m = spawn_particle_manager_vol()
  particle_water_m = spawn_particle_manager_water()
end

function _update60()
  --if true then return end
  for obj in all(objects) do
    obj.update(obj)
  end

  -- 3% CPU
  _car_update(player)

  -- 0% CPU (idle)
  _particle_manager_vol_update(particle_front_m)
  --_particle_manager_vol_update(particle_back_m)
  
  -- 2% CPU (idle)
  _particle_manager_water_update(particle_water_m)

end

function _draw()
  cls(3) -- Most grass is drawn as part of cls
  -- CPU debugging
  -- 23% CPU for full screen map, 0% for sprite 0
  --map(7, 12, player.x - 64, player.y - 64, 16, 16)
  -- 1-2% CPU
  --rectfill(player.x - 64, player.y - 64, player.x + 64, player.y + 64, 7)
  -- 25% CPU
  --for i = 1, 16 do
  --  for j = 1, 16 do
  --    spr(21, player.x, player.y)
  --  end
  --end
  --if true then return end

  -- 7% CPU
  draw_map(map_road_chunks, map_settings.size, 3, true, true)
  -- 3% CPU
  draw_map(map_decl_chunks, map_settings.size, 3, true, true)
  -- 9% CPU
  _trail_manager_draw(trail_m)

  -- 0% CPU (idle)
  _particle_manager_vol_draw_bg(particle_front_m)

  -- 11% CPU
  draw_map(map_prop_chunks, map_settings.size, 3, false, true)

  -- 0% CPU
  for obj in all(objects) do
    obj.draw(obj)
  end

  -- ?% CPU
  --_particle_manager_vol_draw(particle_back_m)

  -- 2% CPU (idle)
  _particle_manager_water_draw(particle_water_m)

  -- 7% CPU
  _car_draw(player)

  -- 12% CPU
  draw_map(map_prop_chunks, map_settings.size, 3, true, false)

  -- 1% CPU (idle)
  _particle_manager_vol_draw_fg(particle_front_m)

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

-- Random between -num, +num
function rnd2(n)
  n = abs(n)
  return rnd(2*n) - n
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
  local x = map_settings.spawn_x
  local y = map_settings.spawn_y
  local dir = map_settings.spawn_dir

  player = create_car(x, y, 0, 0, 0, 0, dir, false)
  _set_ghost_start(player)
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
    flash_frames = 0,
    started_boost_last_frame = false,
    water_wheels = 0,
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
  -- TODO: Find better way to pass in map size
  local chunk_size = 3
  camera(mid(0, self.x - 64, map_settings.size*chunk_size*8 - 128), mid(0, self.y - 64, map_settings.size*chunk_size*8 - 128))
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
  if rnd(1) < 10.1 then
    --_wheel_particles(self, 10)
  end
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
  local first_boost_frame = false

  -- Get the wheel modifiers (boost, road, grass, etc)
  local grass_wheels = 0
  local boost_wheels = 0
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
    if collides_boost_at(check_x, check_y) then
      boost_wheels += 1
    end
  end

  -- Apply the wheel modifiers
  local mod_turn = 1
  local mod_corrective = 1
  local mod_max_vel = 1
  local mod_friction = 1
  local mod_accel = 1
  local mod_brake = 1
  if grass_wheels >= 2 then
    mod_turn = 0.25
    mod_corrective = 0.25
    --mod_max_vel = 0.9
    mod_accel = 0.5
    mod_brake = 0.25
  end
  if boost_wheels >= 1 then
    --first_boost_frame = true
    if not self.started_boost_last_frame then
      self.started_boost_last_frame = true
      self.flash_frames = 5
    end
    self.drift_boost_frames = 90
  else
    self.started_boost_last_frame = false
  end

  -- Visual Rotation
  self.angle_fwd = (self.angle_fwd + move_side * self.turn_rate_fwd * (d_brake and 1.5 * abs(vel_dot_fwd) or 1)) % 1
  if move_side == 0 then
    -- If there's no more side input, snap to the nearest 1/8th
    self.angle_fwd = round_nth(self.angle_fwd, 32)
  end

  -- Drift boost
  local buildup_threshold = 10000
  local boost_duration = 45
  self.flash_frames -= 1
  if d_brake then
    local speed = dist(self.v_x, self.v_y)
    if abs(vel_dot_fwd) < 0.85 and speed > 1 then
      self.drift_boost_buildup += 1
      if self.drift_boost_buildup >= buildup_threshold then
        if self.drift_boost_buildup == buildup_threshold then
          self.flash_frames = 6
        end
        self.drift_boost_buildup = buildup_threshold + 30 -- hold frames
      end
      --_wheel_particles(self, 10)
      --_wheel_particles(self, self.drift_boost_buildup >= buildup_threshold and 12 or 10)
    else
      --if self.drift_boost_buildup >= buildup_threshold then
      --  _wheel_particles(self, 12)
      --end
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
    if rnd(boost_duration) < self.drift_boost_frames then
      _wheel_particles(self, 10)
    end
    self.drift_boost_frames -= 1
    mod_max_vel *= 1 + (0.5 * self.drift_boost_frames / boost_duration)
    if grass_wheels < 2 then
      --mod_turn *= 1 + min(2.5, (2.5 * self.drift_boost_frames / boost_duration))
    end
    if first_boost_frame then
      for i = 1, 10 do
        _wheel_particles(self, 10)
      end
      local angle_vel = atan2(self.v_x, self.v_y)
      self.v_x, self.v_y = angle_vector(angle_vel, self.max_speed_fwd * mod_max_vel)
    end
  end

  -- Update wheel offsets
  local wheel_idx = 1
  for i = -1, 1, 2 do
    for j = -1, 1, 2 do
      local wheel_x = round(cos(self.angle_fwd + 0.1 * i) * 5 * j)
      local wheel_y = round(sin(self.angle_fwd + 0.1 * i) * 4 * j)
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
  if self.drift_boost_frames > 0 then
    -- Force move forward when boosting
    self.v_x += fwd_x * self.accel * mod_accel
    self.v_y += fwd_y * self.accel * mod_accel
  elseif d_brake then
    local f_stop = (move_fwd > 0 and self.f_friction * 0.5
                or (move_fwd == 0 and self.f_friction * 2 
                or (move_fwd < 0 and self.brake * 2 * mod_brake or 1000)))
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
      self.v_x -= mid(v_x_normalized * self.brake * mod_brake, self.v_x, -self.v_x)
      self.v_y -= mid(v_y_normalized * self.brake * mod_brake, self.v_y, -self.v_y)
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
    local particle_m = particle_back_m
    if i == 1 and self.angle_fwd > 0.25 and self.angle_fwd < 0.75 then
      particle_m = particle_front_m
    end
    if i == 3 and (self.angle_fwd < 0.25 or self.angle_fwd > 0.75) then
      particle_m = particle_front_m
    end
    --add_particle(particle_m, wheel_x, wheel_y, 0, c, rnd(0.5)-0.25, rnd(0.5)-0.25, rnd(0.5)+1.25, 60)
    --add_particle(particle_m, wheel_x, wheel_y, 2, c, rnd(0.5)-0.25, 0, rnd(0.5)+0.5, 60)
    
  end
  local cone_angle = 0.1
  local offset_x, offset_y = angle_vector(self.angle_fwd+0.5 + rnd(cone_angle/2)-cone_angle/4, 1)
  local wheel_x = flr(self.x) + offset_x * 6
  local wheel_y = flr(self.y) + offset_y * 6
  add_particle_vol(particle_front_m, wheel_x, wheel_y, 2, rnd(1) < 0.5 and 10 or 9, offset_x*5, offset_y*5, rnd(0.5)-0.25, 30, 4)
end

function _car_draw(self)
  --self.angle_fwd = 8/32 -- 0,8,16,24 = correct, 1-7 = 0,1, 9-15 = 1,0, 17-23 = 0,-1, 25-31 = -1,0
  palt(0, false)
  palt(15, true)

  pal(11, self.drift_boost_frames > 10 and 8 or 2)

  local scale = 1
  if self.is_ghost then
    pal(8, 2)
    pal(10, 4)
    pal(12, 13)
    pal(7, 6)
    pal(6, 1)
  elseif self.flash_frames > 0 then
    for i = 0, 15 do
      pal(i, 7)
    end
  end

  draw_water_outline(round_nth(self.angle_fwd, 32))

  -- Costs 6% of CPU budget
  for i = self.water_wheels < 2 and 0 or 1, 4 do
    pd_rotate(self.x,self.y-i*scale+(self.water_wheels<2 and 0 or 1),round_nth(self.angle_fwd, 32),127,30.5 - i*2,2,true,scale)
    --break
  end
  pal()

  local w = 11
  local ii = 11
  for i = -1, 1, 2 do
    for j = -1, 1, 2 do
      local wheel_x = round(cos(self.angle_fwd + 0.083 * i) * 5 * j)
      local wheel_y = round(sin(self.angle_fwd + 0.083 * i) * 5 * j)
      --pset(player.x+wheel_x, round(player.y-0.5+wheel_y), ii)
      ii += 1
    end
  end

  --line(player.x, player.y, player.x, player.y, 15)

  --print(self.x, self.x, self.y - 20)
  --print(self.y, self.x + 20, self.y - 20)
  --local cpi = level_m.cp_cache[self.x] ~= nil and level_m.cp_cache[self.x][self.y]
  --print(cpi, self.x + 20, self.y - 30)
  --line(map_checkpoints2[1].x1, map_checkpoints2[1].y1, map_checkpoints2[1].x2, map_checkpoints2[1].y2, 15)
  --line(map_checkpoints2[2].x1, map_checkpoints2[2].y1, map_checkpoints2[2].x2, map_checkpoints2[2].y2, 14)
  --line(map_checkpoints2[3].x1, map_checkpoints2[3].y1, map_checkpoints2[3].x2, map_checkpoints2[3].y2, 14)
  --for x, l in pairs(level_m.cp_cache) do
  --  for y, i in pairs(l) do
  --    pset(x, y, 12 + i)
  --  end
  --end
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
  self.water_wheels = 0
  for i, offset in pairs(self.wheel_offsets) do
    local check_x = flr(x) + offset.x
    local check_y = flr(y) + offset.y
    local checkpoint = collides_checkpoint_at(check_x, check_y)
    if checkpoint ~= nil then
      on_checkpoint_crossed(level_m, checkpoint)
    end
    if i % 2 == 0 then -- front wheels
      local collides_water = collides_water_at(check_x, check_y)
      if collides_water then
        self.water_wheels += 1
        local side = i == 4 and 1 or -1
        add_particle_water(particle_water_m, check_x, check_y, 7, rnd2(self.v_y*0.05), rnd2(-self.v_x*0.05), rnd(20)+15, true)
        add_particle_water(particle_water_m, check_x, check_y, 7, self.v_y*0.175*side, -self.v_x*0.175*side, rnd(20)+20)
      end
      local collides_grass = collides_grass_at(check_x, check_y)
      if collides_grass and not collides_water then
        self.dirt_frames[i] = 10
        add_trail_point(trail_m, check_x, check_y, 4)
      end
    end
    if i % 2 == 1 and self.drifting then -- back wheels
      add_trail_point(trail_m, check_x, check_y, 0)
    end
  end
end

function _player_collides_at(self, x, y, angle)
  for offset in all(bbox_cache[round_nth(angle,32)]) do
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
local wall_collision_sprites = {[43]=true, [44]=true, [45]=true, [59]=true, [60]=true, [61]=true, [62]=true}
function collides_wall_at(x, y)
  return collides_part_at(x, y, map_prop_tiles, {}, wall_collision_sprites, 6)
end

local grass_sprites_full = {[0]=true, [26]=true,}
local grass_sprites_part = {[6]=true, [7]=true, [8]=true, [9]=true, [26]=true,}
function collides_grass_at(x, y)
  return collides_part_at(x, y, map_road_tiles, grass_sprites_full, grass_sprites_part, 3)
end

local water_sprites_full = {[64]=true, [69]=true, [70]=true, [85]=true, [86]=true,}
local water_sprites_part = {[65]=true, [66]=true, [67]=true, [68]=true, [81]=true, [82]=true, [83]=true, [84]=true,}
function collides_water_at(x, y)
  return collides_part_at(x, y, map_decl_tiles, water_sprites_full, water_sprites_part, 12, 7)
end

local boost_sprites_full = {[21]=true,}
local boost_sprites_part = {[22]=true, [23]=true, [24]=true, [25]=true,}
function collides_boost_at(x, y)
  return collides_part_at(x, y, map_decl_tiles, boost_sprites_full, boost_sprites_part, 10)
end

function collides_part_at(x, y, tile_map, full_col_sprites, part_col_sprites, c1, c2)
  c2 = c2 or -1
  local sprite_index = tile_map[flr(x/8)][flr(y/8)]
  if sprite_index == nil then
    return false
  end
  if full_col_sprites[sprite_index] then
    return true
  elseif part_col_sprites[sprite_index] then
    local sx = (sprite_index % 16) * 8 + x % 8
    local sy = flr(sprite_index / 16) * 8 + y % 8
    local col = sget(sx, sy)
    return col == c1 or col == c2
  end
  return false
end

function collides_checkpoint_at(x, y)
  if level_m.cp_cache[x] ~= nil and level_m.cp_cache[x][y] ~= nil then
    return level_m.cp_cache[x][y]
  end
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
    next_checkpoint = 2,
    checkpoint_frames = {}, -- Order: 2, 3, 4, ... 1
    best_checkpoint_frames = {},
    frame = 0,
    cp_cache = {}, -- table[x][y] -> cp index
    cp_crossed = {}, -- table[cp_index] -> true/false
  }
  cache_checkpoints(level_m, map_checkpoints)
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
  local sub_sec = tostr(flr(frames%60/60*100))
  return min .. ':' .. (#sec == 1 and '0' or '') .. sec .. '.' .. (#sub_sec == 1 and '0' or '') .. sub_sec
end

function on_checkpoint_crossed(self, cp_index)
  -- Check if this checkpoint was valid to cross next
  if cp_index == 1 and self.next_checkpoint ~= 1 then
      return
  elseif cp_index > 1 and self.cp_crossed[cp_index] then
      return
  end
  self.cp_crossed[cp_index] = true

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
      local camera_x = peek2(0x5f28)
      local camera_y = peek2(0x5f2a)
      print(frame_to_time_str(self.time), camera_x + 50, camera_y + 32, 7)
      if self.best_time ~= 0 then
        print((self.best_time > self.time and '-' or '+') 
          .. frame_to_time_str(abs(self.best_time - self.time)), camera_x + 46, camera_y + 38,
          self.best_time >= self.time and 11 or 8)
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
    --spawn_ghost() -- TODO: Ghost is not accurate
    _set_ghost_start(player)
    self.frame = 1
    for i = 1, count(self.cp_crossed) do
      self.cp_crossed[i] = false
    end
  end

  -- Advance checkpoint marker
  self.next_checkpoint = (self.next_checkpoint % count(self.cp_crossed)) + 1
end

function cache_checkpoints(self, checkpoints)
  self.cp_cache = {} -- table[x][y] -> cp index
  self.cp_crossed = {} -- table[cp_index] -> true/false
  for i = 1, #checkpoints do
    add(self.cp_crossed, false)
    local cp = checkpoints[i]
    local x = cp.x
    local y = cp.y
    for j = 1, cp.l do
      if self.cp_cache[x] == nil then
        self.cp_cache[x] = {}
      end
      self.cp_cache[x][y] = i
      x += cp.dx
      y += cp.dy
    end
  end
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
  [62] = {y_intercept = 0, slope = 1}, -- This one has two y_intercepts so this might not always work
}
-- Sorting takes 24% CPU
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

      chunk_x = mid(chunk_x + i, 0, map_size - 1)
      chunk_y = mid(chunk_y + j, 0, map_size - 1)

      local chunk_index = map_chunks[chunk_x][chunk_y]

      -- top left corner of chunk in pico8 tile map
      local tile_x = (chunk_index % chunks_per_row) * chunk_size
      local tile_y = flr(chunk_index / chunks_per_row) * chunk_size

      -- top left corner of chunk in world
      local world_x = chunk_x * chunk_size * 8
      local world_y = chunk_y * chunk_size * 8

      if draw_above_player and draw_below_player then
        -- draw whole chunk
        -- TODO: Create table of chunk index -> rectfill color for solid chunks
        if tile_x == 15 and tile_y == 0 then
          rectfill(world_x, world_y, world_x + chunk_size * 8, world_y + chunk_size * 8, 5)
        else
          map(tile_x, tile_y, world_x, world_y, chunk_size, chunk_size)
        end
      else
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
end

function add_trail_point(self, x, y, c)
  self.points[self.points_i] = {x=x, y=y, c=c}
  self.points_i = (self.points_i % self.max_points) + 1
end

function _trail_manager_update(self)
end

function _trail_manager_draw(self)
  for p in all(self.points) do
    pset(p.x, p.y, p.c)
  end
end


-- Similar to Trail Manager, but particles are more complex and short-lived
function spawn_particle_manager()
  local particle_m = {
    update = _particle_manager_update,
    draw = _particle_manager_draw,
    points = {},
    points_i = 1,
    max_points = 75,
  }

  for i = 1, particle_m.max_points do
    add(particle_m.points, {x=0, y=0, z=0, c=0, v_x=0, v_y=0, v_z=0, t=0, b=0})
  end

  return particle_m
end

function add_particle(self, x, y, z, c, v_x, v_y, v_z, t)
  self.points[self.points_i] = {x=x, y=y, z=z, c=c, v_x=v_x, v_y=v_y, v_z=v_z, t=t, b=0, r=round(rnd(1.5))}
  self.points_i = (self.points_i % self.max_points) + 1
end

function _particle_manager_update(self)
  for p in all(self.points) do
    p.x += p.v_x
    p.y += p.v_y
    p.v_z -= 0.1 -- gravity
    p.z += p.v_z
    if p.z < 0 then
      p.b += 1 -- bounces
      p.v_z *= -0.8
      p.z = -p.z
      p.c = gradients[p.c]
      p.v_x *= 0.5
      if p.c == 0 then
        p.t = 0
      end
    end
    p.t -= 1
  end
end

function _particle_manager_draw(self)
  for p in all(self.points) do
    if p.t > 0 then
      local r = max(0, p.r - p.b/2)
      rectfill(p.x, p.y - p.z, p.x + r, p.y - p.z + r, p.c)
    end
  end
end


-- Volumetric particle manager
function spawn_particle_manager_vol()
  local particle_m = {
    update = _particle_manager_vol_update,
    draw = _particle_manager_vol_draw,
    points = {},
    points_i = 1,
    max_points = 30,
  }

  for i = 1, particle_m.max_points do
    add(particle_m.points, {x=0, y=0, z=0, c=0, v_x=0, v_y=0, v_z=0, t=0, t_start=0, r=0, d=1})
  end

  return particle_m
end

function add_particle_vol(self, x, y, z, c, v_x, v_y, v_z, t, r)
  --self.points[self.points_i] = {x=x, y=y, z=z, c=c, v_x=v_x, v_y=v_y, v_z=v_z, t=t, t_start=t, r=r, d=rnd(0.05)+0.85}
  self.points[self.points_i] = {x=x-player.x, y=y-player.y, z=z, c=c, v_x=v_x, v_y=v_y, v_z=v_z, t=t, t_start=t, r=r, d=rnd(0.05)+0.85}
  self.points_i = (self.points_i % self.max_points) + 1
end

function _particle_manager_vol_update(self)
  for p in all(self.points) do
    if p.t > 0 then
      p.x += p.v_x
      p.y += p.v_y
      p.z += p.v_z
      p.v_x *= p.d
      p.v_y *= p.d
      p.v_z *= p.d
      p.t -= 1
      if (p.t * 3) % p.t_start == 0 then
        p.c = gradients[p.c]
        p.r -= 1
        p.v_z += 0.5
      end
      if p.t < 5 and p.r > 0 then
        p.r -= 0.5
      end
    end
  end
end

function _particle_manager_vol_draw_bg(self)
  -- Shadow pass
  for p in all(self.points) do
    if p.t > 0 then
      circfill(p.x+player.x, p.y+player.y, p.r + 1, 1)
    end
  end  
end

function _particle_manager_vol_draw_fg(self)
  --local camera_x = peek2(0x5f28)
  --local camera_y = peek2(0x5f2a)

  -- Outline pass
  for i = 1, self.max_points do
    local p = self.points[(self.points_i - i) % self.max_points + 1]
    if p.t > 0 and p.t ~= p.t_start - 1 then
      --local x = mid(camera_x + p.r, p.x, camera_x +128-p.r)
      --local y = mid(camera_y + p.r, p.y-p.z, camera_y +128-p.r)
      --circfill(x, y, p.r + 1, gradients[gradients[p.c]])
      --circfill(p.x, p.y-p.z, p.r + 1, gradients[gradients[p.c]])
      circfill(p.x+player.x, p.y-p.z+player.y, p.r + 1, gradients[gradients[p.c]])
    end
  end

  -- Front pass
  for i = 1, self.max_points do
    local p = self.points[(self.points_i - i) % self.max_points + 1]
    if p.t > 0 then
      local c = p.t == p.t_start - 1 and 7 or p.c
      --local x = mid(camera_x + p.r, p.x, camera_x +128-p.r)
      --local y = mid(camera_y + p.r, p.y-p.z, camera_y +128-p.r)
      --local u = flr(abs(p.z)/2) -- underground correction
      --clip(0, 0, 128, p.y - camera_y) -- clip bottom
      --circfill(x, y, p.r, c)
      --circfill(p.x, p.y-p.z, p.r, c)
      circfill(p.x+player.x, p.y-p.z+player.y, p.r, c)
      --clip(0, p.y - camera_y, 128, 128) -- clip top
      --if p.z <= p.r then
      --  ovalfill(p.x - p.r + u, p.y - p.r/2, p.x + p.r - u, p.y + p.r/2 - u, c)
      --end
    end
  end
  clip()
end


-- Water trail/wake
function spawn_particle_manager_water()
  local particle_m = {
    update = _particle_manager_water_update,
    draw = _particle_manager_water_draw,
    points = {},
    points_i = 1,
    max_points = 500,
  }

  for i = 1, particle_m.max_points do
    add(particle_m.points, {x=0, y=0, c=0, v_x=0, v_y=0, t=0})
  end

  return particle_m
end

function add_particle_water(self, x, y, c, v_x, v_y, t, double)
  --if rnd(1) > 0.5 then return end
  self.points[self.points_i] = {x=x, y=y, c=c, v_x=v_x, v_y=v_y, t=round(t),}
  self.points_i = (self.points_i % self.max_points) + 1
  if double then
    local v_x_greater = abs(v_x) > abs(v_y)
    self.points[self.points_i] = {x=x+(v_x_greater and 1 or 0), y=y+(v_x_greater and 0 or 1), c=c, v_x=v_x, v_y=v_y, t=round(t+rnd2(t*.2)),}
    self.points_i = (self.points_i % self.max_points) + 1
  end
end

function _particle_manager_water_update(self)
  for p in all(self.points) do
    if p.t > 0 then
      local x_before = flr(p.x)
      p.x += p.v_x
      if flr(p.x) ~= x_before and not collides_water_at(p.x, p.y) then
        p.v_x *= -1
        p.x += p.v_x
      end
      local y_before = flr(p.y)
      p.y += p.v_y
      if flr(p.y) ~= y_before and not collides_water_at(p.x, p.y) then
        p.v_y *= -1
        p.y += p.v_y
      end
      p.t -= 1

      if p.t == 2 then
        --p.c = 13
      elseif p.t == 8 then 
        p.c = 6
      end
    end
  end
end

function _particle_manager_water_draw(self)
  for p in all(self.points) do
    if p.t > 0 then
      pset(p.x, p.y, p.c)
    end
  end
end


function init_outline_cache(t, y)
  camera(-64,-64)
  for i = 0, 32 do
    cls()
    local rot = i/32
    t[rot] = {}
    pd_rotate(0,0,i/32,123,y,2,true,1)
    for x = -15, 15 do
      for y = -15, 15 do
        local c = pget(x, y)
        if c == 7 then
          add(t[rot], {x=x, y=y})
        end
      end
    end
  end
end

function draw_water_outline(rot)
  for offset in all(outline_cache[rot]) do
    local x = player.x+offset.x
    local y = player.y+offset.y
    if collides_water_at(x, y) then
      pset(x, y, 7)
    end
  end
end

