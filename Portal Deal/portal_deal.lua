-- portal deal
-- by @maxbize

-------------------
-- global vars
-------------------
-- gameobject management / main loops
_to_start = {} -- all gameobjects that still haven't had start() called
gameobjects = {} -- global list of all objects
actions = {} -- coroutines
for i=1,4 do
  add(gameobjects, {}) -- 4 layers: background, default, foreground, UI
end

-- game data
level = 0
walls = { -- indexed by sprite number
  [1]={up=true, right=true, down=true, left=true},
  [2]={up=false, right=false, down=false, left=false},
  [3]={up=false, right=true, down=false, left=true},
  [4]={up=true, right=false, down=true, left=false},
  [5]={up=true, right=false, down=false, left=false},
  [6]={up=false, right=true, down=false, left=false},
  [7]={up=false, right=false, down=true, left=false},
  [8]={up=false, right=false, down=false, left=true},
}

-- singletons


-------------------
-- main methods
-------------------
function _init()
  printh('')
  printh('--------------')
  printh('')

  poke(0x5f2d, 1) -- enable mouse

  portal_manager = gameobject:new()
  portal_manager:add_component(portal_manager_t:new())
  instantiate(portal_manager)

  cash = gameobject:new{x=38, y=10}
  cash:add_component(rigidbody_t:new{width=3, height=3})
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
-- game-specific helper methods
-------------------
function cell_at_point(x, y)
  x, y = flr(x), flr(y)

  return x / 8 + level % 16, y / 8 + level / 16
end

-- sorting network, ascending
function sort_dirs(a, b, c, d)
  if (a.dist > b.dist) then a, b = b, a end
  if (c.dist > d.dist) then c, d = d, c end
  if (a.dist > c.dist) then a, c = c, a end
  if (b.dist > d.dist) then b, d = d, b end
  if (b.dist > c.dist) then b, c = c, b end

  return {a, b, c, d}
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

function printh_nums(prefix, hex, n1, n2, n3, n4)
  local s = (prefix ~= nil and prefix or '') .. ' '
  s = n1 ~= nil and s..tostr(n1, hex)..' ' or s
  s = n2 ~= nil and s..tostr(n2, hex)..' ' or s
  s = n3 ~= nil and s..tostr(n3, hex)..' ' or s
  s = n4 ~= nil and s..tostr(n4, hex)..' ' or s
  printh(s)
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

    if (mget(x_map / 8, y_map / 8, 1) > 0) then
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
  x_exact = 0, -- fractional movement. gameobject x, y only allowed ints
  y_exact = 0,
  vx = 0, -- velocity
  vy = 0,
  width = 1, -- collider size
  height = 1,
  ay = 0.1, -- acceleration
  max_vx = 3, -- max velocity
  max_vy = 3
}

function rigidbody_t:start()
  self.x_exact = self.go.x
  self.y_exact = self.go.y
end

function rigidbody_t:update()
  -- acceleration and max velocity
  self.vy += self.ay
  if (abs(self.vy) > self.max_vy) then
    self.vy = self.max_vy * sgn(self.vy)
  end
  if (abs(self.vx) > self.max_vx) then
    self.vx = self.max_vx * sgn(self.vx)
  end

  -------------------------------------------------------
  -- voxelised raycast to find the collision point
  -- adapted from http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.42.3443&rep=rep1&type=pdf
  -------------------------------------------------------
  local x = self.x_exact
  local y = self.y_exact

  local step_x = sgn(self.vx)
  local step_y = sgn(self.vy)

  local t_max_x = self.vx > 0 and ((1 - (x % 1)) / self.vx) or ((x % 1) / abs(self.vx))
  local t_max_y = self.vy > 0 and ((1 - (y % 1)) / self.vy) or ((y % 1) / abs(self.vy))

  local t_delta_x = 1 / abs(self.vx)
  local t_delta_y = 1 / abs(self.vy)

  local t = 0
  local steps = 0
  local dt = 0

--  printh_nums('exact, vel:', true, x, y, self.vx, self.vy)
--  printh_nums('exact, vel:', false, y, self.vy)
--  printh_nums('deltas, maxes:', false, t_delta_y, t_max_y)

  while t < 1 do
    steps += 1

    if (t_max_x < t_max_y) then
      dt = min(1 - t, t_delta_x)
      t_max_x += dt
      t += dt
      x += self.vx * dt
    else
      dt = min(1 - t, t_delta_y)
      t_max_y += dt
      t += dt
      y += self.vy * dt
    end

    if (flr(x) > self.go.x or flr(y) > self.go.y) then
      if (overlaps_solids(flr(x), flr(y), self.width, self.height)) then
        x = self.go.x
        y = self.go.y
        self.vx = 0
        self.vy = 0
      else
        self.go.x = flr(x)
        self.go.y = flr(y)
      end
    end
  end

  self.x_exact = x
  self.y_exact = y
end

-- the main object the player has to get to the end
cash_t = gameobject:new{

}

function cash_t:draw()
  sspr(11, 18, 3, 3, self.go.x, self.go.y)
end