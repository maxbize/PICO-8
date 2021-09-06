-- portal golf
-- by @maxbize

-------------------
-- global vars
-------------------
-- gameobject management / main loops
local _to_start = {} -- all gameobjects that still haven't had start() called
local gameobjects = {} -- global list of all objects
local actions = {} -- coroutines
local time_scale = 1
for i=1,5 do
  add(gameobjects, {}) -- 5 layers: background, default, foreground, UI, mouse
end

local gradients = {0, 1, 1, 2, 1, 13, 6, 2, 4, 9, 3, 1, 5, 13, 14}

-- game data
--local walls = { -- indexed by sprite number
--  [1]={up=true, right=true, down=true, left=true},
--  [2]={up=false, right=false, down=false, left=false},
--  [3]={up=false, right=true, down=false, left=true},
--  [4]={up=true, right=false, down=true, left=false},
--  [5]={up=true, right=false, down=false, left=false},
--  [6]={up=false, right=true, down=false, left=false},
--  [7]={up=false, right=false, down=true, left=false},
--  [8]={up=false, right=false, down=false, left=true},
--  [9]={up=false, right=true, down=true, left=true},
--  [10]={up=true, right=false, down=true, left=true},
--  [11]={up=true, right=true, down=false, left=true},
--  [12]={up=true, right=true, down=true, left=false},
--  [13]={up=true, right=false, down=false, left=true},
--  [14]={up=true, right=true, down=false, left=false},
--  [15]={up=false, right=true, down=true, left=false},
--  [16]={up=false, right=false, down=true, left=true},
--}
function tobool(s) -- very simple since we only have one case
  return s == "true"
end
local walls_str = "true,true,true,true,false,false,false,false,false,true,false,true,true,false,true,false,true,false,false,false,false,true,false,false,false,false,true,false,false,false,false,true,false,true,true,true,true,false,true,true,true,true,false,true,true,true,true,false,true,false,false,true,true,true,false,false,false,true,true,false,false,false,true,true"
local walls = {}
local walls_split = split(walls_str, ",")
for i=1,#walls_split,4 do
  add(walls, {up=tobool(walls_split[i]), right=tobool(walls_split[i+1]), down=tobool(walls_split[i+2]), left=tobool(walls_split[i+3])})
end

local level = 1
--local levels = {
--  {start_x=60, start_y=78, start_vx=0, start_vy=1, gold=4, silver=8, bronze=12}, -- easy
--  {start_x=22, start_y=30, start_vx=-1, start_vy=0, gold=6, silver=10, bronze=16}, -- medium
--  {start_x=30, start_y=95, start_vx=3, start_vy=-2, gold=6, silver=10, bronze=16}, -- easy
--  {start_x=60, start_y=97, start_vx=1, start_vy=0, gold=5, silver=8, bronze=15}, -- hard
--  {start_x=66, start_y=95, start_vx=0, start_vy=0, gold=4, silver=6, bronze=10}, -- hard
--  {start_x=114, start_y=20, start_vx=0, start_vy=-3, gold=14, silver=15, bronze=20}, -- medium-hard
--  {start_x=100, start_y=40, start_vx=2, start_vy=0, gold=7, silver=10, bronze=15}, -- very hard
--  {start_x=42, start_y=100, start_vx=1, start_vy=1, gold=8, silver=12, bronze=16}, -- medium-hard
--  {start_x=66, start_y=30, start_vx=0, start_vy=0, gold=10, silver=12, bronze=16}, -- very hard
--  {start_x=66, start_y=64, start_vx=-3, start_vy=-3, gold=20, silver=30, bronze=40} -- hard (bonus)
--}
local levels_str = "60,78,0,1,4,8,12,22,30,-1,0,6,10,16,30,95,3,-2,6,10,16,60,97,1,0,5,8,15,66,95,0,0,4,6,10,114,20,0,-3,14,15,20,100,40,2,0,7,10,15,42,100,1,1,8,12,16,66,30,0,0,10,12,16,66,64,-3,-3,20,30,40"
local levels = {}
local levels_split = split(levels_str, ",")
for i=1,#levels_split,7 do
  add(levels, {start_x=levels_split[i], start_y=levels_split[i+1], start_vx=levels_split[i+2], start_vy=levels_split[i+3], gold=levels_split[i+4], silver=levels_split[i+5], bronze=levels_split[i+6]})
end

-- singletons (_m == manager)
local portal_m = nil   -- type portal_manager_t
local cash = nil       -- type gameobject
local level_m = nil    -- type level_manager_t
local particle_m = nil -- type particle_manager_t
local menu_m = nil     -- type menu_manager_t
local end_menu_m = nil -- type end_level_menu_t
local level_ui_m = nil -- type level_ui_t
local mouse_m = nil    -- type mouse_t
local help_m = nil     -- type help_menu_t
local api_m = nil      -- type api_manager_t

local current_track = -1 -- music

-------------------
-- main methods
-------------------
function _init()
  printh('')
  printh('--------------')
  printh('')

  cartdata('maxbize_portalgolf_1')

  poke(0x5f2d, 1) -- enable mouse

  local portal = gameobject:new()
  portal_m = portal:add_component(portal_manager_t:new())

  cash = gameobject:new{x=60, y=91, layer=3}
  cash:add_component(rigidbody_t:new{width=3, height=3})
  cash:add_component(cash_t:new())

  local level_manager = gameobject:new()
  level_m = level_manager:add_component(level_manager_t:new())

  local api_manager = gameobject:new()
  api_m = api_manager:add_component(api_manager_t:new())

  local menu_manager = gameobject:new{layer=4}
  menu_m = menu_manager:add_component(menu_manager_t:new())

  local end_menu = gameobject:new{layer=4}
  end_menu_m = end_menu:add_component(end_level_menu_t:new())

  local level_ui = gameobject:new{layer=4}
  level_ui_m = level_ui:add_component(level_ui_t:new())

  local help_menu = gameobject:new{layer=4}
  help_m = help_menu:add_component(help_menu_t:new())

  local particle_manager = gameobject:new{layer=1}
  particle_m = particle_manager:add_component(particle_manager_t:new())

  local mouse = gameobject:new{layer=5}
  mouse_m = mouse:add_component(mouse_t:new())
end

function _update60()
  --if (not btnp(5) and time_scale == 1) then
  --  return
  --end

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

  for i=1,count(gameobjects) do
    for go in all(gameobjects[i]) do
      go:draw_components()
    end

    if (i == 1) then
      draw_map()
    end
  end

  --print('cpu: '..(stat(1) < 0.1 and '0' or '')..flr(stat(1) * 100), 1, 1, 0)
  --print('obj: '..#gameobjects[1]..' '..#gameobjects[2]..' '..#gameobjects[3]..' '..#gameobjects[4], 1, 7, 0)
  --print('mem: '..stat(0), 1, 13, 0)
end

-------------------
-- component system
-------------------
-- base gameobject class
gameobject = {
  components = nil,
  x = 0,
  y = 0,
  rb = nil, -- cached rigidbody
  layer = 2 -- 1:background, 2:default, 3:foreground, 4:ui
}

function gameobject:new(o)
  local o = o or {}
  o.components = {}
  setmetatable(o, self)
  self.__index = self

  -- instantiate
  add(_to_start, o)
  return o
end

function gameobject:start_components()
  for comp in all(self.components) do
    if (comp.start ~= nil) then
      comp:start()
    end
  end
end

function gameobject:update_components()
  for comp in all(self.components) do
    if (comp.update ~= nil) then
      comp:update()
    end
  end
end

function gameobject:draw_components()
  for comp in all(self.components) do
    if (comp.draw ~= nil) then
      comp:draw()
    end
  end
end

function gameobject:add_component(comp)
  add(self.components, comp)
  comp.go = self

  if (instanceof(comp, rigidbody_t)) then
    self.rb = comp
  end

  return comp
end

function gameobject:get_component(prototype)
  for comp in all(self.components) do
    if (instanceof(comp, prototype)) then
      return comp
    end
  end
  return nil
end

-- base component class
component = {
  go = nil -- parent gameobject
}

function component:new(o)
  local o = o or {}
  setmetatable(o, self)
  self.__index = self

  return o
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

function destroy(gameobject)
  del(gameobjects[gameobject.layer], gameobject)
end

-------------------
-- generic helper methods
-------------------
function print_shadowed(text, x, y, color)
  if color == 9 then -- for this game, lots of background UI uses the normal gradient for 9
    print(text, x, y-1, 5)
  else
    print(text, x, y-1, gradients[color])
  end
  print(text, x, y, color)
end

-- print with auto text wrapping and marker support (e.g. "word is %marked")
--   % = shadowed
function print_formatted(text, start_x, start_y, start_color)
  local x = start_x
  local y = start_y
  local c = start_color

  for word in all(split(text, " ", false)) do
    -- check for markers
    local shadowed = false
    if sub(word, 1, 1) == '%' then
      shadowed = true
      word = sub(word, 2)
    end
    if sub(word, 1, 1) == '#' then
      c = tonum(sub(word, 2, 3))
      if c == nil then
        c = tonum(sub(word, 2, 2))
        word = sub(word, 3)
      else
        word = sub(word, 4)
      end
    end

    -- check for word wrap
    local l = #word * 4
    if x + l >= 128 then
      y += 8
      x = start_x
    end

    -- print
    if shadowed then
      print_shadowed(word, x, y, c)
    else
      print(word, x, y, c)
    end
    
    -- advanced print pointer
    x += l + 4
    c = start_color
  end

  -- return next suggested y
  return y + 8
end

-- returns the cell index at x, y
function cell_at_point(x, y)
  return flr(x / 8), flr(y / 8)
end

-- returns the top-left corner of the cell at index
function cell_location(cell_x, cell_y)
  return cell_x * 8, cell_y * 8
end

function solid_at_point(x, y)
  return fget(mget2(cell_at_point(x, y)), 0)
end

function round(n)
  return n%1 < 0.5 and flr(n) or -flr(-n)
end

function dist(x1, y1, x2, y2)
  return sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

--function printh_nums(prefix, n1, n2, n3, n4)
--  local s = (prefix ~= nil and prefix or '') .. ' '
--  s = n1 ~= nil and s..tostr(n1)..' ' or s
--  s = n2 ~= nil and s..tostr(n2)..' ' or s
--  s = n3 ~= nil and s..tostr(n3)..' ' or s
--  s = n4 ~= nil and s..tostr(n4)..' ' or s
--  printh(s)
--end

-- draws a dotted line, animated by tweaking phase (0-1)
function draw_dotted_line(x1, y1, x2, y2, color)
  local length = dist(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  local phase = time() * 2 % 1
  local num_dots = 10 -- not really ;)
  local skip = 4
  for i = -1, num_dots, skip do
    local t1 = (i + phase*skip)     / (num_dots)
    local t2 = (i + phase*skip + 1) / (num_dots)
    t2 = max(0, min(1, t2))
    t1 = max(0, min(1, t1))
    line(x1 + dx * t1, y1 + dy * t1, x1 + dx * t2, y1 + dy * t2, color)
  end
end

function _yield(frames)
  frames = frames or 1
  for i=1,frames do
    yield()
  end
end

-------------------
-- game-specific helper methods
-------------------
-- level aware mget
function mget2(cell_x, cell_y)
  cell_x += 16 * (level % 8)
  cell_y += 16 * flr(level / 8)

  return mget(cell_x, cell_y)
end

function draw_map()
  local cell_x = 16 * (level % 8)
  local cell_y = 16 * flr(level / 8)

  map(cell_x, cell_y, 0, 0, 16, 16, 1)
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


-- checks if aabb overlaps any solid geometry at the given position
-- returns:
--   0 - no overlaps
--   1 - overlaps portals
--   2 - overlaps walls
function overlaps_solids(x, y, w, h)
  -- need to keep track of individual corners separately to not conflate
  -- an overlap from one brick with a non-overlap from another brick that has
  -- a portal
  local any_in_portal = false
  local portal_ref = nil

  -- run check for each corner
  for i= 0, 3 do
    -- check against the map (-1 since that's the edge of the collider)
    local x_map = x + (w - 1) * (i%2)
    local y_map = y + (h - 1) * flr(i/2)

    local cell_x, cell_y = cell_at_point(x_map, y_map)

    if (fget(mget2(cell_x, cell_y), 0)) then
      -- collides with a wall. Let's see if it's a portal
      local in_portal = false

      if (#portal_m.chain > 1) then
        for portal in all(portal_m.chain) do
          if (portal.cell_x == cell_x and portal.cell_y == cell_y) then
            local overlaps = overlaps_portal(portal, x, y, w, h)
            if overlaps then
              portal_ref = portal
              in_portal = true
            end
          end
        end
      end

      any_in_portal = any_in_portal or in_portal

      -- hit a solid wall. no need to check anything else
      if (not in_portal) then
        return 2, nil
      end
    end
  end

  return any_in_portal and 1, portal_ref or 0, nil
end

-- checks if the collider overlaps with the given portal
function overlaps_portal(portal, x, y, w, h)

  local px, py, pw, ph = portal_positions(portal)

  return not (x > px + pw-1 
           or y > py + ph-1 
           or x +  w-1 < px 
           or y +  h-1 < py)

end

function portal_positions(portal)
  local x, y = cell_location(portal.cell_x, portal.cell_y)
  local w, h
  if (portal.dir_x ~= 0) then
    x += (portal.dir_x == 1 and 7 or 0)
    w = 1
    h = 8
  else
    y += (portal.dir_y == 1 and 7 or 0)
    w = 8
    h = 1
  end
  return x, y, w, h
end

function portals_equal(p1, p2)
  return p1.cell_x == p2.cell_x
     and p1.cell_y == p2.cell_y
     and p1.dir_x == p2.dir_x
     and p1.dir_y == p2.dir_y
end

-------------------
-- game types
-------------------
particle_manager_t = component:new({
  particles = {},
  index = 1,
  max_particles = 1000
})

function particle_manager_t:start()
  for i=1,self.max_particles do
    self.particles[i] = {
      x = -1,
      y = -1,
      vx = 0,
      vy = 0,
      ax = 0,
      ay = 0,
      frames = 0,
      color = 0
    }
  end
end

function particle_manager_t:update()
  for p in all(self.particles) do
    if (p.frames > 0) then
      p.vx += p.ax
      p.vy += p.ay
      p.x += p.vx
      p.y += p.vy
      p.frames -= 1
    end
  end
end

function particle_manager_t:draw()
  for p in all(self.particles) do
    if (p.frames > 0) then
      pset(p.x, p.y, p.color)
    end
  end
end

-- Adds a second particle underneath with the gradient color
function particle_manager_t:add_particle_shadowed(x, y, vx, vy, ax, ay, color, frames)
  self:add_particle(x, y, vx, vy, ax, ay, color, frames)
  self:add_particle(x, y+1, vx, vy, ax, ay, gradients[color], frames)
end

-- "shifts" to the gradient color at the end
function particle_manager_t:add_particle_faded(x, y, vx, vy, ax, ay, color, frames)
  self:add_particle(x, y, vx, vy, ax, ay, gradients[color], frames)
  self:add_particle(x, y, vx, vy, ax, ay, color, frames * 0.9)
end

function particle_manager_t:add_particle(x, y, vx, vy, ax, ay, color, frames)
  local seek = 10
  while (seek > 0) do
    seek -= 1
    self.index += 1
    if (self.index > self.max_particles) then
      self.index = 1
    end
    if (self.particles[self.index].frames < 5) then
      seek = 0
    end
  end

  local p = self.particles[self.index]

  p.x = x
  p.y = y
  p.vx = vx
  p.vy = vy
  p.ax = ax
  p.ay = ay
  p.color = color
  p.frames = frames
end

portal_manager_t = component:new{
  candidate = nil,   -- cell_x, cell_y, dir_x, dir_x
  chain = nil, -- [{cell_x, cell_y, dir_x, dir_x}]
  move_index = 0, -- if we're moving a portal, this is the index of that portal
  highlighted_portal = nil
}

function portal_manager_t:start()
  self.chain = {}
end

function portal_manager_t:update()
  if (menu_m.active or end_menu_m.active or help_m.active) then
    return
  end

  -- find candidate wall for portal
  local d_up = mouse_m.go.y % 8
  local d_lt = mouse_m.go.x % 8
  local d_dn = 7 - d_up
  local d_rt = 7 - d_lt

  local dirs = sort_dirs(
    {dist=d_up, dir_x= 0, dir_y=-1},
    {dist=d_dn, dir_x= 0, dir_y= 1},
    {dist=d_rt, dir_x= 1, dir_y= 0},
    {dist=d_lt, dir_x=-1, dir_y= 0}
  )

  local cell_x, cell_y = cell_at_point(mouse_m.go.x, mouse_m.go.y)
  self.candidate = nil

  for dir in all(dirs) do
    -- check interior walls of current cell
    local wall = walls[mget2(cell_x, cell_y)]
    if (wall ~= nil) then
      if ((dir.dir_x == 1 and wall.right) or (dir.dir_x == -1 and wall.left)) then
        self.candidate = {cell_x=cell_x, cell_y=cell_y, dir_x = dir.dir_x, dir_y = dir.dir_y}
        break
      elseif ((dir.dir_y == 1 and wall.down) or (dir.dir_y == -1 and wall.up)) then
        self.candidate = {cell_x=cell_x, cell_y=cell_y, dir_x = dir.dir_x, dir_y = dir.dir_y}
        break
      end
    end

    -- check exterior walls of neighboring cell. not exact copy/paste from above
    wall = walls[mget2(cell_x + dir.dir_x, cell_y + dir.dir_y)]
    if (wall ~= nil) then
      if ((dir.dir_x == 1 and wall.left) or (dir.dir_x == -1 and wall.right)) then
        self.candidate = {cell_x=cell_x + dir.dir_x, cell_y=cell_y + dir.dir_y, dir_x = -dir.dir_x, dir_y = -dir.dir_y}
        break
      elseif ((dir.dir_y == 1 and wall.up) or (dir.dir_y == -1 and wall.down)) then
        self.candidate = {cell_x=cell_x + dir.dir_x, cell_y=cell_y + dir.dir_y, dir_x = -dir.dir_x, dir_y = -dir.dir_y}
        break
      end
    end
  end

  -- handle user input
  if (time_scale == 1) then
    return
  end

  if (self.move_index ~= 0 and not mouse_m.left_mouse) then
    self.move_index = 0
  end
  
  if (mouse_m.left_mouse_down) then
    local existing, index = self:find_in_chain(self.candidate)
    if (existing == nil and self.candidate ~= nil) then
      sfx(12)
      add(self.chain, self.candidate)
      self.move_index = #self.chain
    else
      self.move_index = index
    end
  elseif (self.move_index ~= 0) then
    self:move_portal(self.candidate, self.move_index)
  elseif (mouse_m.right_mouse_down) then
    self:remove_portal(self.candidate)
  end
end

function portal_manager_t:find_in_chain(candidate)
  if (candidate == nil) then
    return
  end

  for i = 1, #self.chain do
    if (portals_equal(self.chain[i], self.candidate)) then
      return self.chain[i], i
    end
  end
end

function portal_manager_t:remove_portal(candidate)
  if del(self.chain, self:find_in_chain(candidate)) ~= nil then
    sfx(13)
  end
end

function portal_manager_t:move_portal(candidate, index)
  if (candidate ~= nil) then
    -- Make sure we're not overwriting an existing portal
    for portal in all(self.chain) do
      if portals_equal(candidate, portal) then
        return
      end
    end
    self.chain[index] = candidate
  end
end

function portal_manager_t:draw()
  if (self.candidate ~= nil and time_scale == 0) then
    self:draw_portal(self.candidate, 11)
  end

  self.highlighted_portal = nil

  for i = 1, #self.chain do
    self:draw_portal(self.chain[i], i < #self.chain and 9 or 12)
    if (time_scale == 0 and not end_menu_m.active) then
      self:draw_portal_number(i)
      if (self.candidate ~= nil and portals_equal(self.chain[i], self.candidate)) then
        self.highlighted_portal = i
      end
    end
  end

  if (self.highlighted_portal ~= nil and #self.chain > 1 and time_scale == 0 and not end_menu_m.active) then
    local p0x, p0y, p0w, p0h = portal_positions(self.chain[self.highlighted_portal == 1 and #self.chain or self.highlighted_portal-1])
    local p1x, p1y, p1w, p1h = portal_positions(self.chain[self.highlighted_portal])
    local p2x, p2y, p2w, p2h = portal_positions(self.chain[(self.highlighted_portal%#self.chain)+1])
    
    draw_dotted_line(p0x + flr(p0w/2), p0y + flr(p0h/2), p1x + flr(p1w/2), p1y + flr(p1h/2), 14, time()*5%1, 5)
    draw_dotted_line(p1x + flr(p1w/2), p1y + flr(p1h/2), p2x + flr(p2w/2), p2y + flr(p2h/2), 15, time()*5%1, 5)
  end
end

function portal_manager_t:draw_portal(portal, color)
  local x, y, w, h = portal_positions(portal)
  line(x, y, x + w - 1, y + h - 1, color)
end

function portal_manager_t:draw_portal_number(num)
  portal = self.chain[num]
  local l = #tostr(num) - 1
  local cell_x, cell_y = cell_location(portal.cell_x, portal.cell_y)
  if portal.dir_x == 1 then
    print(tostr(num), cell_x + 3 - l * 4, cell_y + 2, 0)
  elseif portal.dir_x == -1 then
    print(tostr(num), cell_x + 2, cell_y + 2, 0)
  elseif portal.dir_y == 1 then
    print(tostr(num), cell_x + 3 - l * 2, cell_y + 1, 0)
  else
    print(tostr(num), cell_x + 3 - l * 2, cell_y + 2, 0)
  end
end

-- rigidbody is any freefalling object in the world.
-- handles dynamic pixel-perfect movement
rigidbody_t = component:new{
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
  max_vx = 3, -- max velocity
  max_vy = 3,
  angle = 0, -- angle and angular velocity for animation purposes only!
  angular_vel = 0,
  particle_trail = {}, -- ring buffer of historical positions
  trail_index = 1, -- index into ring buffer
  trail_size = 50, -- size of ring buffer
  trail_on = true, -- whether or not to render trail
  portal_offset = 0, -- offset from the center of the last portal we went through
}

function rigidbody_t:update()
  -- apply ground friction and gravity
  local grounded = self:is_grounded()
  if (grounded) then
    self.angular_vel = self.vx * 40; -- * 60 (speed per sec instead of frame) / 1.5 (radius)
    self.vx *= self.friction

    -- if we're stopped and grounded but are mostly over open space, add a little movement to "fall off" the ledge
    if self.vx == 0 and self.vy == 0 then
      local left_overlap   = overlaps_solids(self.go.x,   self.go.y + 1, 1, self.height)
      local middle_overlap = overlaps_solids(self.go.x+1, self.go.y + 1, 1, self.height)
      local right_overlap  = overlaps_solids(self.go.x+2, self.go.y + 1, 1, self.height)
      if middle_overlap ~= 2 and right_overlap ~= 2 then
        self.vx += 0.1
      elseif middle_overlap ~= 2 and left_overlap ~= 2 then
        self.vx -= 0.1
      end
    end
  end

  if (not grounded or self.vy < 0) then
    self.vy += self.ay * time_scale
  end

  -- acceleration and velocity cap
  if (abs(self.vy) > self.max_vy) then
    self.vy = self.max_vy * sgn(self.vy)
  end
  if (abs(self.vx) > self.max_vx) then
    self.vx = self.max_vx * sgn(self.vx)
  end

  -- angular velocity
  self.angle = (self.angle + self.angular_vel) % 360

  -- movement
  local vx = self.vx * time_scale
  local vy = self.vy * time_scale

  -- DEBUGGING!
  --vx = 0
  --vy = 0
  --if btn(0) then vx = -1.0 end
  --if btn(1) then vx =  1.0 end
  --if btn(2) then vy = -1.0 end
  --if btn(3) then vy =  1.0 end

  local x = flr(abs(vx)) + 1
  local y = flr(abs(vy)) + 1
  for i=1, max(x, y) do
    if (x > 0) then
      x -= 1
      self:move_x(sgn(vx) * (x > 0 and 1 or (abs(vx) % 1)),
        function()
          if (self:handle_portal()) then
            x = 0
            y = 0
          end
        end,
        function()
          sfx(3)
          for i=1, flr(abs(self.vx)*5) do
            particle_m:add_particle_faded(self.go.x+1.5+sgn(self.vx), self.go.y+1.5, rnd(0.1)*sgn(-self.vx), rnd(0.5)-0.25, 0, 0, 7, 10+rnd(20))
          end
          self.angular_vel = -vy * 40; -- * 60 (speed per sec instead of frame) / 1.5 (radius)
          self.vx *= -self.bounciness
          self.vy *= self.bounce_friction
          x = 0
        end
      )
    end

    if (y > 0) then
      y -= 1
      self:move_y(sgn(vy) * (y > 0 and 1 or (abs(vy) % 1)),
        function()
          if (self:handle_portal()) then
            x = 0
            y = 0
          end
        end,
        function()
          sfx(3)
          for i=1, flr(abs(self.vy)*5) do
            particle_m:add_particle_faded(self.go.x+1.5, self.go.y+1.5+sgn(self.vy), rnd(0.5)-0.25, rnd(0.1)*sgn(-self.vy), 0, 0, 7, 10+rnd(20))
          end
          self.angular_vel = vx * 40; -- * 60 (speed per sec instead of frame) / 1.5 (radius)
          self.vy *= -self.bounciness
          if (abs(self.vy) < 0.5) then
            self.vy = 0
          end
          self.vx *= self.bounce_friction
          y = 0
        end
      )
    end
  end
end

function rigidbody_t:is_grounded()
  local overlap_state = overlaps_solids(self.go.x, self.go.y + 1, self.width, self.height)
  return overlap_state == 2
end

function rigidbody_t:move_x(amount, portal_callback, wall_callback)
  self.x_remainder += amount
  local move = round(self.x_remainder)

  if (move ~= 0) then
    self.x_remainder -= move
    local sign = sgn(move)

    while (move ~= 0) do
      overlap_state = overlaps_solids(self.go.x + sign, self.go.y, self.width, self.height)
      if (overlap_state == 1) then
        self:record_trail(sign, 0)
        self.go.x += sign
        portal_callback()
        break
      elseif (overlap_state == 2) then
        wall_callback()
        break
      else
        self:record_trail(sign, 0)
        self.go.x += sign
        move -= sign
      end
    end
  end
end

function rigidbody_t:move_y(amount, portal_callback, wall_callback)
  self.y_remainder += amount
  local move = round(self.y_remainder)

  if (move ~= 0) then
    self.y_remainder -= move
    local sign = sgn(move)

    while (move ~= 0) do
      overlap_state = overlaps_solids(self.go.x, self.go.y + sign, self.width, self.height)
      if (overlap_state == 1) then
        self:record_trail(0, sign)
        self.go.y += sign
        portal_callback()
        break
      elseif (overlap_state == 2) then
        wall_callback()
        break
      else
        self:record_trail(0, sign)
        self.go.y += sign
        move -= sign
      end
    end
  end
end

-- Record history for the particle trail. move_x/y state what our next move will be
function rigidbody_t:record_trail(move_x, move_y)
  if (#self.particle_trail == 0) then
    for i=1,self.trail_size do 
      add(self.particle_trail, {x=self.go.x, y=self.go.y})
    end
  end

  local next_index = self.trail_index == self.trail_size and 1 or self.trail_index + 1

  local dx = abs(self.go.x + move_x - self.particle_trail[self.trail_index].x)
  local dy = abs(self.go.y + move_y - self.particle_trail[self.trail_index].y)
  if dx + dy >= 4 or dx >= 3 or dy >= 3 then
    self.particle_trail[next_index] = {x = self.go.x, y = self.go.y}
    self.trail_index = next_index
  end

end

function rigidbody_t:handle_portal()
  local num_portals = #portal_m.chain
  for i = 1, num_portals do
    if (self:edge_in_portal(portal_m.chain[i])) then
      p1 = portal_m.chain[i]
      p2 = portal_m.chain[(i%num_portals)+1]
      local p1x, p1y, p1w, p1h = portal_positions(p1)
      local p2x, p2y, p2w, p2h = portal_positions(p2)

      if (p1.dir_x == 0) then
        self.portal_offset = self.go.x - p1x - 2
      else
        self.portal_offset = self.go.y - p1y - 2
      end

      self.go.x = flr(p2x + p2w/2 - self.width/2)
      self.go.y = flr(p2y + p2h/2 - self.height/2)
      self.angle = (self.angle + portal_angle_delta(p1, p2)) % 360

      local v_normal  = p1.dir_x == 0 and self.vy or self.vx
      local v_tangent = p1.dir_x == 0 and self.vx or self.vy

      if (p2.dir_x ~= 0) then
        self.vx = abs(v_normal) * p2.dir_x
        self.vy = p1.dir_x == 0 and -abs(v_tangent) or v_tangent
      else
        self.vx = v_tangent
        self.vy = abs(v_normal) * p2.dir_y
      end

      local dx = p2x - p1x
      local dy = p2y - p1y
      for i = 1, 20 do
        particle_m:add_particle_faded(self.go.x + 1, self.go.y + 1, rnd(2)-1 + p2.dir_x, rnd(2)-1 + p2.dir_y, 0, 0.1, i <= 10 and 12 or 1, rnd(10)+10)
        local t = i / 21
        particle_m:add_particle_faded(p1x + dx * t, p1y + dy * t, rnd(0.5)-0.25, rnd(0.5)-0.25, 0, 0, 12, i)
      end

      sfx(1, -1, 0, 1)

--      local speed = dist(0, 0, self.vx, self.vy)
--      self.vx = speed * p2.dir_x
--      -- needed to preserve momentum if the teleport threshold is in the center
--      --self.vy = (speed + self.ay) * p2.dir_y
--      self.vy = speed * p2.dir_y

      return true
    end
  end

  return false
end

-- checks to see if the outer middle pixel overlaps the portal
function rigidbody_t:edge_in_portal(p)
  if (p.dir_x ~= 0) then
    local x = self.go.x + (p.dir_x == 1 and self.width - 1 or 0)
    for i=0, self.height-1 do
      if (overlaps_portal(p, x, self.go.y + i, 1, 1)) then
        return true
      end
    end
  else
    local y = self.go.y + (p.dir_y == 1 and self.height - 1 or 0)
    for i=0, self.width-1 do
      if (overlaps_portal(p, self.go.x + i, y, 1, 1)) then
        return true
      end
    end
  end

  return false
end

-- the main object the player has to get to the end
cash_t = component:new{
  draw_index = 1, -- index into the particle trail for the highlight
  draw_pause = 0, -- how many frames to pause the highlight
}

function cash_t:draw()
  -- Draw particle trail
  local trail_length = #self.go.rb.particle_trail
  if trail_length == 0 then
    self.draw_index = 1
  end
  if self.go.rb.trail_on then
    for particle in all(self.go.rb.particle_trail) do
        pset(particle.x + 1, particle.y + 1, 13)
    end
    if time_scale == 0 and trail_length > 0 and not end_menu_m.active then
      for i=1,10 do
        --local index = (self.go.rb.trail_index + self.draw_index + i) % trail_length + 1
        local index = self.draw_index + i
        if index >= 0 and index < self.go.rb.trail_size then
          local particle = self.go.rb.particle_trail[(self.go.rb.trail_index + self.draw_index + i) % trail_length + 1]
          pset(particle.x + 1, particle.y + 1, 7)
        end
      end
      if self.draw_pause > 0 then
        self.draw_pause -= 1
      else
        self.draw_index = self.draw_index < trail_length and self.draw_index + 1 or -20
        self.draw_pause = 2
      end
    end
  end

  -- Check for partial portal overlaps
  local state, p1 = overlaps_solids(self.go.x, self.go.y, self.go.rb.width, self.go.rb.height)
  if (state == 1) then
    -- Check if we're entering or exiting this portal
    local p1x, p1y, p1w, p1h = portal_positions(p1)
    local dir = 0
    local delta = 0 -- how many pixels from centerline of portal to center of collector

    local sx = 72 + flr(self.go.rb.angle / 45) * 4
    local sy = 10
    local sw = 3
    local sh = 3

    if (p1.dir_x == 0) then
      dir = sgn(self.go.rb.vy) == sgn(p1.dir_y) and -1 or 1
      delta = abs((self.go.y + 1) - p1y)

      local cutoff = 1 - delta -- how much to cut off for the front of the sprite
      if p1.dir_y == 1 then
        sspr(sx, sy + cutoff, sw, sh - cutoff, self.go.x, self.go.y + cutoff)
      else
        sspr(sx, sy, sw, sh - cutoff, self.go.x, self.go.y)
      end

    else
      dir = sgn(self.go.rb.vx) == sgn(p1.dir_x) and -1 or 1
      delta = abs((self.go.x + 1) - p1x)

      local cutoff = 1 - delta -- how much to cut off for the front of the sprite
      if p1.dir_x == 1 then
        sspr(sx + cutoff, sy, sw - cutoff, sh, self.go.x + cutoff, self.go.y)
      else
        sspr(sx, sy, sw - cutoff, sh, self.go.x, self.go.y)
      end

    end

    -- Find the portal we're supposed to do a preview on
    local p2 = nil
    for i=1,#portal_m.chain do
      if (portals_equal(p1, portal_m.chain[i])) then
        local idx = i + dir
        if idx == 0 then 
          idx = #portal_m.chain
        end
        if idx > #portal_m.chain then
          idx = 1
        end
        p2 = portal_m.chain[idx]
        break
      end
    end

    -- Draw the preview at that portal
    local p2x, p2y, p2w, p2h = portal_positions(p2)
    local cutoff = delta + 1 -- how much to cut off for the back of the sprite
    sx = 72 + flr((self.go.rb.angle + portal_angle_delta(p1, p2)) % 360 / 45) * 4
    if (p2.dir_x == 0) then
      local x = flr(p2x + p2w/2 - self.go.rb.width/2)
      local y = (p2y - 1) - delta * p2.dir_y
      if dir == -1 then
        x += self.go.rb.portal_offset
      end
      if p2.dir_y == 1 then
        sspr(sx, sy + cutoff, sw, sh - cutoff, x, y + cutoff)
      else
        sspr(sx, sy, sw, sh - cutoff, x, y)
      end
    else
      local x = (p2x - 1) - delta * p2.dir_x
      local y = flr(p2y + p2h/2 - self.go.rb.height/2)
      if dir == -1 then
        y += self.go.rb.portal_offset
      end
      if p2.dir_x == 1 then
        sspr(sx + cutoff, sy, sw - cutoff, sh, x + cutoff, y)
      else
        sspr(sx, sy, sw - cutoff, sh, x, y)
      end
    end

  else
    -- No overlaps - simple cash draw
    sspr(72 + flr(self.go.rb.angle / 45) * 4, 10, 3, 3, self.go.x, self.go.y)
  end

  -- Draw arrow at start of level
  if (time_scale == 0 and not end_menu_m.active) then
    local end_x = (self.go.x + self.go.rb.vx * 5) + 1
    local end_y = (self.go.y + self.go.rb.vy * 5) + 1
    line(self.go.x + 1, self.go.y + 1, end_x, end_y, 12)
    circ(end_x, end_y, 1, 1)
    pset(self.go.x + 1, self.go.y + 1, 7)
  end
end

-- 0-3 for N, E, S, W
function portal_dir(p)
  if p.dir_y == -1 then return 0
  elseif p.dir_x == 1 then return 1
  elseif p.dir_y == 1 then return 2
  elseif p.dir_x == -1 then return 3
  end
end

function portal_angle_delta(p1, p2)
  return (portal_dir(p1) - portal_dir(p2)) * 90 + 180
end

level_manager_t = component:new{
  num_pickups = 0,
  last_loaded_level = 0,
}

function level_manager_t:start()
  time_scale = 0
  play_music(33)
end

function level_manager_t:update()
  if (menu_m.active or end_menu_m.active or help_m.active) then
    return
  end

  -- handle input
  if (btnp(4) and time_scale == 0) then
    self:play_sim()
  elseif (btnp(4) and time_scale == 1) then
    self:stop_sim()
  end

  -- check/advance to next level
  if (self.num_pickups == 0) then
    sfx(2, -1, 0, 2)
    local num_portals = #portal_m.chain
    if (dget(level) == 0 or dget(level) > num_portals) then
      dset(level, num_portals)
    end
    api_m:level_complete(level, num_portals, true)

    end_menu_m:activate()
  end
end

function level_manager_t:play_sim()
  play_music(0)
  sfx(4, -1, 0, 2)
  time_scale = 1
  level_ui_m.btn_play.text = "stop"
  cash.rb.particle_trail = {}
end

function level_manager_t:stop_sim()
  --sfx(3)
  level_ui_m.btn_play.text = "play"
  self:restart_level()
end

function level_manager_t:notify_pickup()
  self.num_pickups -= 1
  if self.num_pickups > 0 then
    sfx(0, -1, 31 - self.num_pickups, 1)
  end
end

function level_manager_t:restart_level()
  -- reset time
  time_scale = 0
  play_music(33)

  -- reset cash
  l = levels[level]
  cash.x = l.start_x
  cash.y = l.start_y
  cash.rb.vx = l.start_vx
  cash.rb.vy = l.start_vy
  cash.rb.x_remainder = 0
  cash.rb.y_remainder = 0
  cash.rb.angle = 0
  cash.rb.angular_vel = 0

  -- clear remaining pickups
  local remaining = {}
  for layer in all(gameobjects) do
    for go in all(layer) do
      if (go:get_component(pickup_t) ~= nil) then
        remaining[go.x + go.y*16] = true
        destroy(go)
      end
    end
  end

  -- create new pickups
  self.num_pickups = 0
  for x = 0, 15 do
    for y = 0, 15 do
      -- 34 == pickup sprite
      if (mget2(x, y) == 34) then
        self.num_pickups += 1
        local pickup = gameobject:new{x=x*8, y=y*8}
        pickup:add_component(pickup_t:new{collected_last_run=(remaining[x*8 + y*8*16] == nil and self.last_loaded_level == level) and true or false})
      end
    end
  end

  self.last_loaded_level = level
end

pickup_t = component:new{
  chase_time = 0,
  collected_last_run = false,
}

function pickup_t:start()
  self.spawn_x = self.go.x
  self.spawn_y = self.go.y
end

function pickup_t:update()
  -- 4 == half sprite width/height
  local distance = dist(self.go.x + 4, self.go.y + 3, cash.x + cash.rb.width/2, cash.y + cash.rb.height/2)
  

  if (self.chase_time == 0 and distance < 7.5) then
    self.chase_time = time()
  end

  if (self.chase_time > 0) then
    self.go.x += (cash.x + cash.rb.width/2  - self.go.x - 4) * 0.8
    self.go.y += (cash.y + cash.rb.height/2 - self.go.y - 3) * 0.8
  end

  local distance = dist(self.go.x + 4, self.go.y + 3, cash.x + cash.rb.width/2, cash.y + cash.rb.height/2)

  if (distance < 1) then
    for i = 1, 10 do
      particle_m:add_particle_shadowed(self.go.x + 4, self.go.y + 3, rnd(2)-1, rnd(2)-1, 0, 0, i <= 3 and 9 or 10, rnd(5)+5)
    end
    level_m:notify_pickup()
    destroy(self.go)
  end
end

function pickup_t:draw()
  if self.collected_last_run then
    spr(50, self.go.x, self.go.y)
  else
    spr(34, self.go.x + sin(time() - self.spawn_x/128), self.go.y + cos(time() - self.spawn_y/128))
  end
end

menu_manager_t = component:new{
  active = true,
  selected_level = -1,
}

function menu_manager_t:update()
  if (not self.active) then
    return
  end

  if (mouse_m.go.y >= 25 and mouse_m.go.y < 116) then
    self.selected_level = flr((mouse_m.go.y - 26)/9) + 1
  else
    self.selected_level = -1
  end

  if (mouse_m.left_mouse_down and self.selected_level > -1) then
    local unlocked = self.selected_level == 1 or dget(self.selected_level - 1) > 0
    if (unlocked) then
      sfx(12)
      self.active = false
      level = self.selected_level
      level_m:restart_level()
    else
      sfx(13)
    end
  end

  --particle_m:add_particle(12, 6+rnd(14), -1, 0, 0, 0, 9, 15)
  --if rnd(1) < 0.25 then
  --  particle_m:add_particle(112, 6+rnd(2), 1, 0, 0, 0, 12, 16)
  --end
  --if rnd(1) < 0.25 then
  --  particle_m:add_particle(110, 12+rnd(2), 1, 0, 0, 0, 12, 18)
  --end
end

function menu_manager_t:draw()
  if (not self.active) then
    return
  end

  rectfill(0, 0, 128, 128, 15)
  rectfill(0, 25, 128, 116, 4)

  sspr(0, 32, 128, 20, 0, 2)
  print_shadowed('@maxbize', 48, 120, 7)
  print_shadowed('v 1.1', 103, 120, 7)

  if (self.selected_level > 0) then
    local i = self.selected_level - 1
    rectfill(0, 26 + i * 9, 128, 34 + i * 9, 2)
  end

  for i = 1, 10 do
    local best = dget(i)
    local unlocked = i == 1 or dget(i-1) > 0
    local x = 19
    local y = 19

    print_shadowed('level '..(i < 10 and ' ' or '')..i, x, y + i * 9, unlocked and 7 or 1)
    
    if (best ~= 0) then
      spr(best <= levels[i].gold   and 36 or 39, x+44, (y-1) + i * 9)
      spr(best <= levels[i].silver and 37 or 39, x+52, (y-1) + i * 9)
      spr(best <= levels[i].bronze and 38 or 39, x+60, (y-1) + i * 9)
    else
      spr(39, x+44, (y-1) + i * 9)
      spr(39, x+52, (y-1) + i * 9)
      spr(39, x+60, (y-1) + i * 9)
    end
    print_shadowed(best, best < 10 and x+84 or x+80, y + i * 9, unlocked and 7 or 1)

  end

  particle_m:draw()

end

end_level_menu_t = component:new{
  active = false,
  draw_medals = 0, -- 0-3 for none, bronze, etc
  flash_medal = 0, -- 0-3 for none, bronze, etc
  offsets = {0, 0, 0}, -- offsets to draw medals/backgrounds for a little shake. Bronze, silver, gold
  menu_offset = 0, -- offset for the entire menu so that we can slide it in
  activate_action = nil, -- reference to the reveal coroutine
  buttons = {}, -- list of buttons we've created for our UI
}

function end_level_menu_t:start()
  add(self.buttons, make_button(34, 84, 0, -128, "retry", function(btn)
    self:hide()
  end))

  add(self.buttons, make_button(72, 84, 0, -128, "next", function(btn)
    portal_m.chain = {}
    if (level < #levels) then
      cash.rb.particle_trail = {}
      level += 1
    else
      menu_m.active = true
    end
    self:hide()
  end))
end

function end_level_menu_t:shake_medal_background(num)
  sfx(5)
  x = 75 - 18 * (num - 1)
  for i=1,10 do
    self.offsets[num] = (self.offsets[num] + 1) % 2
    yield()
  end
  for i=1,6 do
    self.offsets[num] = (self.offsets[num] + 1) % 2
    _yield(2)
  end
  _yield(20)
end

function end_level_menu_t:reveal_medal(color, num)
  x = 75 - 18 * (num - 1)
  self:shake_medal_background(num)
  self.draw_medals = num
  self.flash_medal = num
  sfx(3)
  _yield(4)
  self.flash_medal = 0
  for i=1,75 do
    particle_m:add_particle_shadowed(x + rnd(13), 32 + rnd(15), rnd(1.5)-0.75, rnd(1)-1.75, 0, 0.06, color,            100)
  end
  for i=1,25 do
    particle_m:add_particle_shadowed(x + rnd(13), 32 + rnd(15), rnd(1.5)-0.75, rnd(1)-1.75, 0, 0.06, gradients[color], 100)
  end
  for i=0,num-1 do
    sfx(6 + i)
  end

  _yield(15)
end

function end_level_menu_t:activate()
  -- Reset state
  self.active = true
  self.draw_medals = 0
  self.flash_medal = 0
  self.offsets = {0, 0, 0}
  self.menu_offset = 128

  self.activate_action = cocreate(function()

    -- Wait up to 3 sec for the collector to mostly stop
    for i=1,180 do
      if (abs(cash.rb.vx) < 0.01 and abs(cash.rb.vy) == 0) then
        break
      end
      yield()
    end

    -- Stop the sim
    time_scale = 0

    -- Slide in menu
    for i=1,16 do
      self.menu_offset *= 0.70
      for btn in all(self.buttons) do
        btn.offset = -self.menu_offset
      end
      yield()
    end
    self.menu_offset = 0
    for btn in all(self.buttons) do
      btn.offset = 0
    end

    -- Perform medal animations
    local num_portals = #portal_m.chain
    if num_portals <= levels[level].bronze then 
      self:reveal_medal(9 , 1)
      if num_portals > levels[level].silver then
        self:shake_medal_background(2)
        self.draw_medals = 2
      end
    end
    if num_portals <= levels[level].silver then 
      self:reveal_medal(7 , 2) 
      if num_portals > levels[level].gold then
        self:shake_medal_background(3)
        self.draw_medals = 3
      end
    end
    if num_portals <= levels[level].gold then 
      self:reveal_medal(10, 3) 
    end
  end)

  add(actions, self.activate_action)
end

function end_level_menu_t:hide()
  del(actions, self.activate_action)
  self.active = false
  particle_m:start()
  level_m:restart_level()
  for btn in all(self.buttons) do
    btn.offset = -128
  end
  level_ui_m.btn_play.text = "play"
end

-- Draws background, medal, and requirement text
function end_level_menu_t:draw_medal(num, req)
  local draw_x = 75 - 18 * (num - 1)

  if self.flash_medal == num then
    -- Draw medal flash
    sspr(110, 53, 15, 17, draw_x - 1, 31)
    -- Print medal requirements
    print_shadowed("?", draw_x+5, 50, 7)

  elseif self.draw_medals >= num then 
    -- Print medal requirements
    print_shadowed(tostr(req), req < 10 and draw_x+5 or draw_x+3, 50 - self.menu_offset, 7)

    if #portal_m.chain <= req then
      -- Draw medal
      sspr(96 - 15 * (num - 1), 15, 13, 15, draw_x + self.offsets[num], 32) 
    else
      -- Draw medal background
      sspr(111, 15, 13, 15, draw_x + self.offsets[num], 32 - self.menu_offset)
    end
  else
    -- Draw medal background
    sspr(111, 15, 13, 15, draw_x + self.offsets[num], 32 - self.menu_offset)

    -- Print medal requirements
    print_shadowed("?", draw_x+5, 50 - self.menu_offset, 7)
  end
end

function end_level_menu_t:draw()
  if (not self.active) then
    return
  end

  -- Draw background
  rectfill(20, 20 - self.menu_offset, 128-21, 128-21 - self.menu_offset, 15)
  rectfill(22, 22 - self.menu_offset, 128-23, 128-23 - self.menu_offset, 4)

  -- Draw medals
  self:draw_medal(1, levels[level].bronze)
  self:draw_medal(2, levels[level].silver)
  self:draw_medal(3, levels[level].gold)

  -- Print level clear/stats
  print_shadowed("level " .. level .. " cleared!",      33, 63 - self.menu_offset, 7)
  print_shadowed("portals: " .. tostr(#portal_m.chain), 33, 72 - self.menu_offset, 7)

  -- HACK! Draw particles again so they draw over the UI
  particle_m:draw()

end

-- UI at the bottom of the screen
level_ui_t = component:new{
  btn_play = nil, -- the play button
  buttons = {},   -- list of all buttons we've created
}

function level_ui_t:start()
  self.btn_play = make_button(5, 119, 1, 0, "play", function(btn) 
    if btn.text == "play" then
      btn.text = "stop"
      level_m:play_sim()
    else
      level_m:stop_sim()
    end
  end)
  add(self.buttons, self.btn_play)

  add(self.buttons, make_button(31, 119, 1, 0, "reset", function(btn)
    level_m:stop_sim()
    portal_m.chain = {}
    cash.rb.particle_trail = {}
  end))

  --add(btns_bottom, make_button( 49, 119, 1, 0, "trail", function(btn)
  --  cash.rb.trail_on = not cash.rb.trail_on
  --end))
  
  add(self.buttons, make_button(76, 119, 1, 0, "help", function(btn)
    help_m.page = 1
    help_m.active = true
    level_m:stop_sim()
  end))

  add(self.buttons, make_button(102, 119, 1, 0, "exit", function(btn)
    level_m:stop_sim()
    portal_m.chain = {}
    cash.rb.particle_trail = {}
    menu_m.active = true
  end))

end

function make_button(x, y, top_cut, offset, text, cb)
  local button_obj = gameobject:new{x=x, y=y, layer=4}
  return button_obj:add_component(button_t:new{top_cut=top_cut, offset=offset, text=text, click_cb=cb})
end

function level_ui_t:draw()
  if menu_m.active then
    return
  end
  
  rectfill(0, 120, 128, 128, 4)
  line(0, 120, 128, 120, 15)
end

function level_ui_t:update()
  for btn in all(self.buttons) do
    if end_menu_m.active and btn.offset < 10 then
      btn.offset += 1
    elseif not end_menu_m.active and btn.offset > 0 then
      btn.offset -= 1
    end
  end
end

-- Note: x,y is of upper-left corner
button_t = component:new{
  text = nil, -- displayed text on button
  click_cb = nil, -- On click callback
  offset = 0, -- y offset for slide-in
  top_cut = 0 -- how much border to cut off the top
}

function button_t:update()
  if menu_m.active or help_m.active then
    return
  end

  if mouse_m.left_mouse_down and self:mouse_over() then
    sfx(12)
    self.click_cb(self)
  end
end

function button_t:draw()
  if menu_m.active or help_m.active then
    return
  end

  local x = self.go.x
  local y = self.go.y
  local len = #self.text * 4 + 4

  local is_mouse_over = self:mouse_over()
  if is_mouse_over then
    mouse_m.on_button = true
  end

  rect               (x,     y + self.top_cut     + self.offset, x + len,     y + 10 + self.offset, 15)
  rectfill           (x + 1, y + self.top_cut + 1 + self.offset, x + len - 1, y +  9 + self.offset, is_mouse_over and 6 or 5)
  print   (self.text, x + 3, y                + 3 + self.offset,                                    7)

end

function button_t:mouse_over()
  local len = #self.text * 4 + 4

  return mouse_m.go.x >= self.go.x 
     and mouse_m.go.x <= self.go.x + len 
     and mouse_m.go.y >= self.go.y + self.offset + self.top_cut 
     and mouse_m.go.y <= self.go.y + 10 + self.offset
end

mouse_t = component:new{
  last_mouse = 0, -- Mouse button stat from last frame
  left_mouse = false, -- Left mouse button is being held down this frame
  left_mouse_down = false, -- left/right mouse buttons are being clicked this frame
  right_mouse_down = false,
  on_button = false, -- Buttons will tell the mouse if it's over one of them
}

function mouse_t:update()
  -- Mouse position
  self.go.x = stat(32)
  self.go.y = stat(33)

  -- Mouse buttons
  local this_mouse      = stat(34)
  self.left_mouse       = this_mouse & 0x1 == 1
  self.left_mouse_down  = self.last_mouse & 0x1 == 0 and this_mouse & 0x1 == 1
  self.right_mouse_down = self.last_mouse & 0x2 == 0 and this_mouse & 0x2 == 2

  self.last_mouse = this_mouse
  self.on_button = false
end

function mouse_t:draw()
  if (menu_m.active or end_menu_m.active or help_m.active) then
    sspr(2, 18, 3, 3, self.go.x - 1, self.go.y - 1)
  else
    if self.on_button then
      sspr(2, 18, 3, 3, self.go.x - 1, self.go.y - 1)
    elseif portal_m.candidate == nil then
      sspr(24, 24, 7, 7, self.go.x - 3, self.go.y - 3)
    elseif portal_m.highlighted_portal == nil then
      sspr(2, 18, 3, 3, self.go.x - 1, self.go.y - 1)
    elseif portal_m.move_index == 0 then
      sspr(0, 24, 7, 7, self.go.x - 3, self.go.y - 3)
    else
      sspr(8, 24, 7, 7, self.go.x - 3, self.go.y - 3)
    end
  end
end

-- reset state for this frame. Useful for not using click on multiple items
function mouse_t:reset()
  self.left_mouse = false
  self.left_mouse_down = false
  self.right_mouse_down = false
end

help_menu_t = component:new{
  active = false,
  page = 1, -- which help page number are we on
  max_page = 3, -- which help page number are we on
}

function help_menu_t:draw()
  if not self.active then
    return
  end

  -- background
  rectfill(0, 0, 127, 127, 15)
  rectfill(2, 2, 125, 125,  4)

  -- body
  palt(0, false) -- draw black pixels
  local title = "title"
  if self.page == 1 then
    title = "overview"
    local y = print_formatted("your %objective is to collect all the %#10gold with the %#11ball using as few %#9portals as possible", 5, 20, 7)
    y = print_formatted("you cannot control the %#11ball - %chain %#9portals around the level to get it where you need it", 5, y+4, 7)
    rect(5, y+3, 15, y+37, 15)
    sspr(8, 58, 9, 33, 6, y + 4)
    y = print_formatted(" - %wall (place %#9portal here)", 16, y+6, 7)
    y = print_formatted(" - %#11ball",     16, y, 7)
    y = print_formatted(" - %#10gold",     16, y, 7)
    y = print_formatted(" - %#9portal (number indicates            order in %chain)", 16, y, 7)
  elseif self.page == 2 then
    title = "managing portals"
    local y = print_formatted("%create %#9portals on any %white wall by %left %clicking it", 5, 20, 7)
    y = print_formatted("%move %#9portals by %left %clicking one and %dragging it to a new %white wall", 5, y + 4, 7)
    y = print_formatted("%delete %#9portals by %right %clicking them", 5, y + 4, 7)
    y = print_formatted("%#9portals form %chains. %#9portal #001 will lead to %#9portal #002, etc.", 5, y + 4, 7)
    for i=0,3 do
      sspr(32 + i*4, 26, 3, 5, 65 + i*12, y + 4)
    end
    rect(5, y+1, 54, y+18, 15)
    sspr(28, 66, 48, 16, 6, y+2)
    y = print_formatted("1  2  3  4  1",    59, y + 4, 0)
    y = print_formatted("this would work!", 59, y, 7)
  elseif self.page == 3 then
    title = "tips"
    local y = print_formatted("the physics are %deterministic. every play with the %same %setup will have the %same %result", 5, 20, 7)
    y = print_formatted("press %c to %start/stop", 5, y+4, 7)
    y = print_formatted("use %gravity to your advantage", 5, y+4, 7)
    y = print_formatted("if you missed any %#10gold - %stop, %tweak, and %try %again", 5, y+4, 7)
    y = print_formatted("your progress is %saved %automatically. take a %break and come back %later", 5, y+4, 7)
    y = print_formatted("- %#12have %#12fun! -", 38, y+3, 7)
  end
  palt(0, true)

  -- header
  local l = #title*4
  print_shadowed(title, 64 - l/2, 6, 7)
  line(63 - l/2, 12, 63 + l/2, 12, 7)
  print_shadowed(self.page .. "/" .. self.max_page, 111, 6, 7)
end

function help_menu_t:update()
  if not self.active then
    return
  end

  if mouse_m.left_mouse_down then
    self.page += 1
    sfx(12)
  end
  if mouse_m.right_mouse_down then
    self.page -= 1
    sfx(13)
  end
  if self.page == 0 or self.page > self.max_page then
    self.active = false
    mouse_m:reset()
  end
end

-- leaderboards and achievements
api_manager_t = component:new{
  queue = {}, -- portal queue
  records = {},
}

function api_manager_t:start()
  -- re-trigger all earned achievements
  for i=1,10 do
    self.records[i] = 100
  end
  for i=1,10 do
    self:level_complete(i, dget(i), false)
  end
end

function api_manager_t:update()
  if #self.queue > 0 and get_pin(0) == 0 then
    for achievement in all(self.queue) do
      set_pin(0, achievement)
      --printh("Requested achievement unlock: " .. achievement)
      del(self.queue, achievement)
      break -- is there a better way to do a queue than for all / break?
    end
  end
end

function api_manager_t:level_complete(level, portals, report_leaderboard)
  if report_leaderboard then
    set_pin(level, portals)
  end

  -- achievements: 1/5/10x bronze/silver/gold, 1/2/3x stars
  if self.records[level] > portals then
    local medals_before = self:num_medals()
    self.records[level] = portals
    local medals_after = self:num_medals()
    
    if     medals_after.bronze ==  1 and medals_before.bronze == 0 then add(self.queue, 77)
    elseif medals_after.bronze ==  5 and medals_before.bronze == 4 then add(self.queue, 80)
    elseif medals_after.bronze == 10 and medals_before.bronze == 9 then add(self.queue, 83)
    end

    if     medals_after.silver ==  1 and medals_before.silver == 0 then add(self.queue, 78)
    elseif medals_after.silver ==  5 and medals_before.silver == 4 then add(self.queue, 81)
    elseif medals_after.silver == 10 and medals_before.silver == 9 then add(self.queue, 84)
    end

    if     medals_after.gold ==  1 and medals_before.gold == 0 then add(self.queue, 79)
    elseif medals_after.gold ==  5 and medals_before.gold == 4 then add(self.queue, 82)
    elseif medals_after.gold == 10 and medals_before.gold == 9 then add(self.queue, 85)
    end

    if     medals_after.star == 1 and medals_before.star == 0 then add(self.queue, 86)
    elseif medals_after.star == 2 and medals_before.star == 1 then add(self.queue, 87)
    elseif medals_after.star == 3 and medals_before.star == 2 then add(self.queue, 88)
    end
  end
end

function api_manager_t:num_medals()
  local medals = {bronze=0, silver=0, gold=0, star=0}
  for i=1,10 do
    if self.records[i] < levels[i].gold then
      medals.star += 1
    end
    if self.records[i] <= levels[i].gold then
      medals.gold += 1
    end
    if self.records[i] <= levels[i].silver then
      medals.silver += 1
    end
    if self.records[i] <= levels[i].bronze then
      medals.bronze += 1
    end
  end
  return medals
end

-- pin 0 == medal to unlock. Only last two digits are sent
-- pins 1-10 == leaderboard scores
function get_pin(pin, value)
  return peek(0x5f80+pin)
end

function set_pin(pin, value)
  poke(0x5f80+pin, value)
end

local music_offsets = {[0]=0, [33]=-1} -- start from -1 because the loop point is on the second measure
local music_lengths = {[0]=4, [33]=20}
function play_music(track)
  if current_track ~= track then
    if current_track ~= -1 then
      if music_offsets[current_track] >= 0 or stat(25) > 0 then
        music_offsets[current_track] = (music_offsets[current_track] + stat(25)) % music_lengths[current_track]
      end
    end
    music(track + music_offsets[track])
    current_track = track
  end
end
