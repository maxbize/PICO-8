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
    max_speed_x = 2,
    max_speed_y = 2,
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
    a = self.target_angle - self.angle
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

  -- Speed limit
  if abs(self.speed_x) > self.max_speed_x then
    self.speed_x = sgn(self.speed_x) * self.max_speed_x
  end
  if abs(self.speed_y) > self.max_speed_y then
    self.speed_y = sgn(self.speed_y) * self.max_speed_y
  end

  -- Apply Movement
  self.x += self.speed_x
  self.y += self.speed_y

end

function _player_draw(self)
  i = flr(self.angle * 8)
  sspr(i * 12, 12, 12, 12, self.x, self.y)
end

