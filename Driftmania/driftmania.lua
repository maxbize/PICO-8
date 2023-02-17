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
    target_angle = 0,
    turn_rate = 0.03,
    speed_x = 0,
    speed_y = 0,
    accel_x = 0.1,
    accel_y = 0.1,
    max_speed = 2,
    f_friction = 0.05,
    f_corrective = 0.05,
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

  -- Rotation
  if move_x ~= 0 or move_y ~= 0 then
    self.target_angle = atan2(move_x, move_y)
  end

  -- TODO: Cleanup ;)
  if abs(self.angle - self.target_angle) < self.turn_rate * 1.1 then
    self.angle = self.target_angle
  else
    local a = self.target_angle - self.angle
    if a < 0 then
      a += 1
    end
    if a < 0.5 then
      self.angle += self.turn_rate
    else
      self.angle -= self.turn_rate
    end
    if self.angle < 0 then
      self.angle += 1
    elseif self.angle > 1 then
      self.angle -= 1
    end
  end

  -- Acceleration
  self.speed_x += move_x * self.accel_x
  self.speed_y += move_y * self.accel_y

  -- Friction
--  if self.speed_x > 0 then
--    self.speed_x = max(0, self.speed_x - self.f_friction)
--  else
--    self.speed_x = min(0, self.speed_x + self.f_friction)
--  end
--  if self.speed_y > 0 then
--    self.speed_y = max(0, self.speed_y - self.f_friction)
--  else
--    self.speed_y = min(0, self.speed_y + self.f_friction)
--  end

  -- Corrective force


  -- Speed limit
  -- This is a more proper speed limit (doesn't let the car go faster diagonally) but it unintentionally changes the car's 
  --  movement direction. Need to not instead increase speed when already at limit
  --local theta = atan2(self.speed_x, self.speed_y)
  --self.speed_x, self.speed_y = angle_vector(theta, min(self.max_speed, dist(self.speed_x, self.speed_y)))

  if abs(self.speed_x) > self.max_speed then
    self.speed_x = sgn(self.speed_x) * self.max_speed
  end
  if abs(self.speed_y) > self.max_speed then
    self.speed_y = sgn(self.speed_y) * self.max_speed
  end

  -- Apply Movement
  self.x += self.speed_x
  self.y += self.speed_y

end

function _player_draw(self)
  i = flr(self.angle * 8)
  sspr(i * 12, 12, 12, 12, self.x, self.y)
end

