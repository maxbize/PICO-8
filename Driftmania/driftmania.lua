-- driftmania
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
  spawn_player()
end

function _update60()
  for obj in all(objects) do
    obj.update(obj)
  end

end

function _draw()
  cls(0)

  map(0, 0, 0, 0)

  for obj in all(objects) do
    obj.draw(obj)
  end

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
  return x / mag, y / mag
end

-- Round a number 0-1 to its nearest 1/8th
function round_8th(x)
  local lower = flr(x * 8) / 8
  return x - lower < .0625 and lower or lower + 0.125
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
    turn_rate = 0.015,
    accel = 0.1,
    brake = 0.1,
    max_speed_fwd = 2,
    max_speed_rev = -1, -- TODO: fix
    f_friction = 0.025,
    f_corrective = 0.04,
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
  self.angle_fwd += move_side * self.turn_rate
  if move_side == 0 then
    -- If there's no more side input, snap to the nearest 1/8th
    self.angle_fwd = round_8th(self.angle_fwd)
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
  local vel_dot_fwd = dot(fwd_x, fwd_y, v_x_normalized, v_y_normalized)
  self.v_x -= mid((1 - abs(vel_dot_fwd)) * v_x_normalized * self.f_corrective, self.v_x, -self.v_x)
  self.v_y -= mid((1 - abs(vel_dot_fwd)) * v_y_normalized * self.f_corrective, self.v_y, -self.v_y)

  -- Speed limit
  local v_theta = atan2(self.v_x, self.v_y)
  self.v_x, self.v_y = angle_vector(v_theta, mid(dist(self.v_x, self.v_y), self.max_speed_fwd, self.max_speed_rev))

  -- Apply Movement
  self.x += self.v_x
  self.y += self.v_y
end

function _player_draw(self)
  i = round_8th(self.angle_fwd) * 8
  if i == 8 then
    i = 0
  end
  sspr(i * 12, 0, 12, 12, self.x, self.y)

  -- debugging
  --local look_x, look_y = angle_vector(self.angle_fwd, self.speed + 5)
  --line(self.x, self.y, self.x + look_x * 5, self.y + look_y * 5, 1)
  --local speed_x, speed_y = angle_vector(self.angle_vel, self.speed + 5)
  --line(self.x, self.y, self.x + speed_x * 5, self.y + speed_y * 5, 3)
end
