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

function angle_vector(theta, magnitude)
  return magnitude * cos(theta),
         magnitude * sin(theta)
end

function dist(dx, dy)
  return sqrt(dx * dx + dy * dy)
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
    angle_vel = 0,
    speed = 0,
    turn_rate_fwd = 0.015,
    turn_rate_vel = 0.01,
    accel = 0.1,
    max_speed_fwd = 2,
    max_speed_rev = -1,
    f_friction = 0.05,
    f_corrective = 0.05,
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
    self.angle_fwd = round_8th(self.angle_fwd)
  end
  if self.angle_fwd < 0 then
    self.angle_fwd += 1
  elseif self.angle_fwd >= 1 then
    self.angle_fwd -= 1
  end

  -- Velocity Rotation
  -- TODO: Cleanup ;)
  if abs(self.angle_vel - self.angle_fwd) < self.turn_rate_vel * 1.1 then
    self.angle_vel = self.angle_fwd
  else
    local a = self.angle_fwd - self.angle_vel
    if a < 0 then
      a += 1
    end
    if a < 0.5 then
      self.angle_vel += self.turn_rate_vel
    else
      self.angle_vel -= self.turn_rate_vel
    end
    if self.angle_vel < 0 then
      self.angle_vel += 1
    elseif self.angle_vel > 1 then
      self.angle_vel -= 1
    end
  end

  -- Acceleration
  self.speed += move_fwd * self.accel

  -- Friction
  if self.speed > 0 then
    self.speed = max(0, self.speed - self.f_friction)
  elseif self.speed < 0 then
    self.speed = min(0, self.speed + self.f_friction)
  end

  -- Corrective force


  -- Speed limit
  self.speed = mid(self.speed, self.max_speed_fwd, self.max_speed_rev)

  -- Apply Movement
  local speed_x, speed_y = angle_vector(self.angle_vel, self.speed)
  self.x += speed_x
  self.y += speed_y

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
