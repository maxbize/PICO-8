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
  poke(0x5f2d, 1) -- enable mouse

  mouse = gameobject:new()
  mouse:add_component(mouse_t:new())
end

function _update60()
  if (paused) then
    return
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
  cls(0)

  map(0, 0, 0, 0, 16, 16)


  for i=1,count(gameobjects) do
    for go in all(gameobjects[i]) do
      go:draw_components()
    end
  end

  -- hide the rightmost column to keep the border even on both sides
  rectfill(127,0,127,128,0)

  --print('mem: '..stat(0), 1, 1, 0)
  --print('cpu: '..(stat(1) < 0.1 and '0' or '')..flr(stat(1) * 100), 1, 7, 0)
  --print('obj: '..#gameobjects[1]..' '..#gameobjects[2]..' '..#gameobjects[3]..' '..#gameobjects[4], 1, 13, 0)
  --print(dget(2))
end

-------------------
-- component system
-------------------
-- base gameobject class
gameobject = {
  go = nil, -- gameobject
  components = {},  
  x = 0,
  y = 0,
  layer = 2 -- 1:background, 2:default, 3:foreground, 4:ui
}

function gameobject:new(o)
  local o = o or {}
  o.components = {}
  o.go = self
  setmetatable(o, self)
  self.__index = self

  return instantiate(o)
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

-- unlike the unity version, does not clone!
function instantiate(gameobject)
  add(_to_start, gameobject)
  return gameobject
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

-------------------
-- game types
-------------------
mouse_t = gameobject:new{
  dirs = nil, -- dist, dir_x, dir_y
  candidate = nil -- x, y, dir_x, dir_y
}

function mouse_t:update()
  -- update mouse position
  self.go.x = stat(32)
  self.go.y = stat(33)

  -- find candidate wall for portal
  local d_up = self.go.y % 8
  local d_lt = self.go.x % 8
  local d_dn = 7 - d_up
  local d_rt = 7 - d_lt

  self.dirs = sort_dirs(
    {dist=d_up, dir_x= 0, dir_y=-1},
    {dist=d_dn, dir_x= 0, dir_y= 1},
    {dist=d_rt, dir_x= 1, dir_y= 0},
    {dist=d_lt, dir_x=-1, dir_y= 0}
  )

  local cell_x, cell_y = cell_at_point(self.go.x, self.go.y)
  local wall = walls[mget(cell_x, cell_y)]
  self.candidate = nil

  for dir in all(self.dirs) do
    -- check interior walls of current cell
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
    -- check exterior walls of neighboring cell
  end

end

function mouse_t:draw()
  local close = self.dirs[1]
  if (self.candidate ~= nil) then
    line(self.candidate.x1,
         self.candidate.y1,
         self.candidate.x2,
         self.candidate.y2,
         11)
  end
  
  print(close.dist..' '..close.dir_x..' '..close.dir_y..' '..self.go.x + close.dir_x * close.dist..' '..self.go.y + close.dir_y * close.dist, 0, 0, 0, 0, 0, 0)

  sspr(2, 18, 3, 3, self.go.x - 1, self.go.y - 1)
  sspr(3, 19, 1, 1, self.go.x, self.go.y)
end

