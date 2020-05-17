-- portal deal
-- by @maxbize

-------------------
-- global vars
-------------------
-- gameobject management / main loops
local _to_start = {} -- all gameobjects that still haven't had start() called
local gameobjects = {} -- global list of all objects
local actions = {} -- coroutines
for i=1,4 do
  add(gameobjects, {}) -- 4 layers: background, default, foreground, UI
end

-- game data
local level = 0
local walls = { -- indexed by sprite number
  [1]={up=true, right=true, down=true, left=true},
  [2]={up=false, right=false, down=false, left=false},
  [3]={up=false, right=true, down=false, left=true},
  [4]={up=true, right=false, down=true, left=false},
  [5]={up=true, right=false, down=false, left=false},
  [6]={up=false, right=true, down=false, left=false},
  [7]={up=false, right=false, down=true, left=false},
  [8]={up=false, right=false, down=false, left=true},
}

-- singletons (_m == manager)
local portals_m = nil

-------------------
-- main methods
-------------------
function _init()
  printh('')
  printh('--------------')
  printh('')

  poke(0x5f2d, 1) -- enable mouse

  portals_m = gameobject:new()
  portals_m:add_component(portal_manager_t:new())
  instantiate(portals_m)

  cash = gameobject:new{x=10, y=90}
  cash:add_component(rigidbody_t:new{width=3, height=3, vx=3, vy=-3})
  cash:add_component(cash_t:new())
  instantiate(cash)
end

function _update60()
  if (paused) then
    return
  end

  if (not btnp(4)) then
    --return
  end

  for c in all(actions) do
    if costatus(c) ~= "dead" then
      coresume(c)
    else
      del(actions, c)
    end
  end

  for go in all(_to_start) do
    go:start_components()
    add(gameobjects[go.layer], go)
  end
  _to_start = {}

  for layer in all(gameobjects) do
    for go in all(layer) do
      go:update_components()
    end
  end
end

function _draw()
  cls(5)

  map(0, 0, 0, 0, 16, 16)


  for i=1,count(gameobjects) do
    for go in all(gameobjects[i]) do
      go:draw_components()
    end
  end

  print('cpu: '..(stat(1) < 0.1 and '0' or '')..flr(stat(1) * 100), 1, 1, 0)
  --print('mem: '..stat(0), 1, 7, 0)
  --print('obj: '..#gameobjects[1]..' '..#gameobjects[2]..' '..#gameobjects[3]..' '..#gameobjects[4], 1, 13, 0)
end

-------------------
-- component system
-------------------
-- base gameobject class
gameobject = {
  go = nil, -- gameobject
  components = nil,
  x = 0,
  y = 0,
  rb = nil, -- cached rigidbody
  layer = 2 -- 1:background, 2:default, 3:foreground, 4:ui
}

function gameobject:new(o)
  local o = o or {}
  o.components = {}
  o.go = self
  setmetatable(o, self)
  self.__index = self

  return o
end

function gameobject:start_components()
  for component in all(self.components) do
    if (component.start ~= nil) then
      component:start()
    end
  end
end

function gameobject:update_components()
  for component in all(self.components) do
    if (component.update ~= nil) then
      component:update()
    end
  end
end

function gameobject:draw_components()
  for component in all(self.components) do
    if (component.draw ~= nil) then
      component:draw()
    end
  end
end

function gameobject:add_component(component)
  add(self.components, component)
  component.go = self

  if (instanceof(component, rigidbody_t)) then
    self.rb = component
  end

  return component
end

function gameobject:get_component(prototype)
  for component in all(self.components) do
    if (instanceof(component, prototype)) then
      return component
    end
  end
  return nil
end

function instanceof(obj, typ)
  while obj do
    obj = getmetatable(obj)
    if typ == obj then 
      return obj
    end
  end
  return false
end

-- unlike the unity version, does not clone!
function instantiate(gameobject)
  add(_to_start, gameobject)
end

function destroy(gameobject)
  del(gameobjects[gameobject.layer], gameobject)
end

-------------------
-- generic helper methods
-------------------
function cell_at_point(x, y)
  x, y = flr(x), flr(y)

  return x / 8 + level % 16, y / 8 + level / 16
end

function solid_at_point(x, y)

  return fget(mget(cell_at_point(x, y)), 0)
end

function check_int(i, name)
  if (flr(i) ~= i) then
    printh('Error! '..name..' is not an int: '..i)
    error()
  end
end

function round(n)
  return n%1 < 0.5 and flr(n) or -flr(-n)
end

function dist(x1, y1, x2, y2)
  return sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function printh_nums(prefix, n1, n2, n3, n4)
  local s = (prefix ~= nil and prefix or '') .. ' '
  s = n1 ~= nil and s..tostr(n1)..' ' or s
  s = n2 ~= nil and s..tostr(n2)..' ' or s
  s = n3 ~= nil and s..tostr(n3)..' ' or s
  s = n4 ~= nil and s..tostr(n4)..' ' or s
  printh(s)
end
-------------------
-- game-specific helper methods
-------------------

-- sorting network, ascending
function sort_dirs(a, b, c, d)
  if (a.dist > b.dist) then a, b = b, a end
  if (c.dist > d.dist) then c, d = d, c end
  if (a.dist > c.dist) then a, c = c, a end
  if (b.dist > d.dist) then b, d = d, b end
  if (b.dist > c.dist) then b, c = c, b end

  return {a, b, c, d}
end


-- checks if aabb overlaps any solid geometry at the given position
function overlaps_solids(x, y, w, h)
  -- sanity check all inputs are integers. can remove before shipping
  --check_int(x, 'x')
  --check_int(y, 'y')
  --check_int(w, 'w')
  --check_int(h, 'h')

  --printh('original '..x..' '..y..' '..w..' '..h)
  -- run check for each corner
  for i= 0, 3 do
    -- check against the map (-1 since that's the edge of the collider)
    local x_map = x + (w - 1) * (i%2)
    local y_map = y + (h - 1) * flr(i/2)

    --printh('checking map at '..x_map..' '..y_map)

    --if (fget(mget(x_map / 8, y_map / 8), 0)) then
    if (fget(mget(x_map / 8, y_map / 8), 0)) then
      -- returns x, y of direction to wall
      --return i%2 == 0 and -1 or 1, flr(i/2) == 0 and -1 or 1
      return true
    end

    -- check against moving platforms
  end

  return false
end

-------------------
-- game types
-------------------
portal_manager_t = gameobject:new{
  candidate = nil,   -- x1, y1, x2, y2
  left_portal = nil, -- x1, y1, x2, y2
  right_portal = nil -- x1, y1, x2, y2
}

function portal_manager_t:update()
  -- update mouse position
  self.go.x = stat(32)
  self.go.y = stat(33)

  -- find candidate wall for portal
  local d_up = self.go.y % 8
  local d_lt = self.go.x % 8
  local d_dn = 7 - d_up
  local d_rt = 7 - d_lt

  local dirs = sort_dirs(
    {dist=d_up, dir_x= 0, dir_y=-1},
    {dist=d_dn, dir_x= 0, dir_y= 1},
    {dist=d_rt, dir_x= 1, dir_y= 0},
    {dist=d_lt, dir_x=-1, dir_y= 0}
  )

  local cell_x, cell_y = cell_at_point(self.go.x, self.go.y)
  self.candidate = nil

  for dir in all(dirs) do
    -- check interior walls of current cell
    local wall = walls[mget(cell_x, cell_y)]
    if (wall ~= nil) then
      if ((dir.dir_x == 1 and wall.right) or (dir.dir_x == -1 and wall.left)) then
        local x = self.go.x + dir.dist * dir.dir_x
        local y = flr(self.go.y / 8) * 8
        self.candidate = {x1=x, y1=y, x2=x, y2=y + 7}
        break
      elseif ((dir.dir_y == 1 and wall.down) or (dir.dir_y == -1 and wall.up)) then
        local x = flr(self.go.x / 8) * 8
        local y = self.go.y + dir.dist * dir.dir_y
        self.candidate = {x1=x, y1=y, x2=x + 7, y2=y}
        break
      end
    end

    -- check exterior walls of neighboring cell. not exact copy/paste from above
    wall = walls[mget(cell_x + dir.dir_x, cell_y + dir.dir_y)]
    if (wall ~= nil) then
      dir.dist += 1
      if ((dir.dir_x == 1 and wall.left) or (dir.dir_x == -1 and wall.right)) then
        local x = self.go.x + dir.dist * dir.dir_x
        local y = flr(self.go.y / 8) * 8
        self.candidate = {x1=x, y1=y, x2=x, y2=y + 7}
        break
      elseif ((dir.dir_y == 1 and wall.up) or (dir.dir_y == -1 and wall.down)) then
        local x = flr(self.go.x / 8) * 8
        local y = self.go.y + dir.dist * dir.dir_y
        self.candidate = {x1=x, y1=y, x2=x + 7, y2=y}
        break
      end
    end
  end

  -- place portals if requested
  if (stat(34) & 0x1 == 1) then
    self:place_portal(0, self.candidate)
  elseif (stat(34) & 0x2 == 2) then
    self:place_portal(1, self.candidate)
  end
end

function portal_manager_t:place_portal(side, candidate)
  if (side == 0) then
    self.left_portal = candidate
  else
    self.right_portal = candidate
  end

end

function portal_manager_t:draw()
  if (self.candidate ~= nil) then
    line(self.candidate.x1,
         self.candidate.y1,
         self.candidate.x2,
         self.candidate.y2,
         11)
  end

  if (self.left_portal ~= nil) then
    line(self.left_portal.x1,
         self.left_portal.y1,
         self.left_portal.x2,
         self.left_portal.y2,
         9)
  end

  if (self.right_portal ~= nil) then
    line(self.right_portal.x1,
         self.right_portal.y1,
         self.right_portal.x2,
         self.right_portal.y2,
         12)
  end

  sspr(2, 18, 3, 3, self.go.x - 1, self.go.y - 1)
end

-- rigidbody is any freefalling object in the world.
-- handles dynamic pixel-perfect movement
rigidbody_t = gameobject:new{
  x_remainder = 0, -- fractional movement. gameobject x, y only allowed ints
  y_remainder = 0,
  vx = 0, -- velocity
  vy = 0,
  width = 1, -- collider size
  height = 1,
  ay = 0.1, -- acceleration
  friction = 0.9,
  bounciness = 0.4,
  bounce_friction = 0.9, -- bounciness on the tangent
  max_vx = 9, -- max velocity
  max_vy = 9
}

function rigidbody_t:start()
  --self.x_remainder = self.go.x
  --self.y_remainder = self.go.y
end

function rigidbody_t:update()
  -- apply ground friction and gravity
  local grounded = solid_at_point(self.go.x + flr(self.width / 2), self.go.y + self.height)
  if (grounded) then
    self.vx *= self.friction
  end
  if (not grounded or self.vy < 0) then
    self.vy += self.ay
  end


  -- acceleration and velocity cap
  if (abs(self.vy) > self.max_vy) then
    self.vy = self.max_vy * sgn(self.vy)
  end
  if (abs(self.vx) > self.max_vx) then
    self.vx = self.max_vx * sgn(self.vx)
  end

  -- movement
  local x = flr(abs(self.vx)) + 1
  local y = flr(abs(self.vy)) + 1
  for i=1, max(x, y) do
    if (x > 0) then
      x -= 1
      self:move_x(sgn(self.vx) * (x > 0 and 1 or (abs(self.vx) % 1)),
        function()
          self.vx *= -self.bounciness
          self.vy *= self.bounce_friction
          x = 0
        end)
    end

    if (y > 0) then
      y -= 1
      self:move_y(sgn(self.vy) * (y > 0 and 1 or (abs(self.vy) % 1)),
        function()
          self.vy *= -self.bounciness
          self.vx *= self.bounce_friction
          y = 0
        end)
    end
  end


end

function rigidbody_t:move_x(amount, callback)
  self.x_remainder += amount
  local move = round(self.x_remainder)

  if (move ~= 0) then
    self.x_remainder -= move
    sign = sgn(move)

    while (move ~= 0) do
      if (overlaps_solids(self.go.x + sign, self.go.y, self.width, self.height)) then
        if (callback ~= nil) then
          callback()
        end
        break
      else
        self.go.x += sign
        move -= sign
      end
    end
  end
end

function rigidbody_t:move_y(amount, callback)
  self.y_remainder += amount
  local move = round(self.y_remainder)

  if (move ~= 0) then
    self.y_remainder -= move
    sign = sgn(move)

    while (move ~= 0) do
      if (overlaps_solids(self.go.x, self.go.y + sign, self.width, self.height)) then
        if (callback ~= nil) then
          callback()
        end
        break
      else
        self.go.y += sign
        move -= sign
      end
    end
  end
end

-- the main object the player has to get to the end
cash_t = gameobject:new{

}

function cash_t:draw()
  sspr(11, 18, 3, 3, self.go.x, self.go.y)
end