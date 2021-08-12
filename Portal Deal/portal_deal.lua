-- portal deal
-- by @maxbize

-------------------
-- global vars
-------------------
-- gameobject management / main loops
local _to_start = {} -- all gameobjects that still haven't had start() called
local gameobjects = {} -- global list of all objects
local actions = {} -- coroutines
local time_scale = 1
for i=1,4 do
  add(gameobjects, {}) -- 4 layers: background, default, foreground, UI
end

local gradients = {0, 1, 1, 2, 1, 13, 6, 2, 4, 9, 3, 1, 5, 13, 14}

-- game data
local walls = { -- indexed by sprite number
  [1]={up=true, right=true, down=true, left=true},
  [2]={up=false, right=false, down=false, left=false},
  [3]={up=false, right=true, down=false, left=true},
  [4]={up=true, right=false, down=true, left=false},
  [5]={up=true, right=false, down=false, left=false},
  [6]={up=false, right=true, down=false, left=false},
  [7]={up=false, right=false, down=true, left=false},
  [8]={up=false, right=false, down=false, left=true},
  [9]={up=false, right=true, down=true, left=true},
  [10]={up=true, right=false, down=true, left=true},
  [11]={up=true, right=true, down=false, left=true},
  [12]={up=true, right=true, down=true, left=false},
  [13]={up=true, right=false, down=false, left=true},
  [14]={up=true, right=true, down=false, left=false},
  [15]={up=false, right=true, down=true, left=false},
  [16]={up=false, right=false, down=true, left=true},
}

local level = 1
local levels = {
  {start_x=60, start_y=78, start_vx=0, start_vy=1, gold=4, silver=8, bronze=12}, -- easy
  {start_x=22, start_y=30, start_vx=-1, start_vy=0, gold=6, silver=10, bronze=16}, -- medium
  {start_x=30, start_y=95, start_vx=3, start_vy=-2, gold=6, silver=10, bronze=16}, -- easy
  {start_x=60, start_y=105, start_vx=1, start_vy=0, gold=5, silver=8, bronze=15}, -- hard
  {start_x=66, start_y=95, start_vx=0, start_vy=0, gold=4, silver=6, bronze=10}, -- hard
  {start_x=114, start_y=20, start_vx=0, start_vy=-3, gold=14, silver=15, bronze=20}, -- medium-hard
  {start_x=100, start_y=48, start_vx=2, start_vy=0, gold=7, silver=10, bronze=15}, -- very hard
  {start_x=42, start_y=100, start_vx=1, start_vy=1, gold=8, silver=12, bronze=16}, -- medium-hard
  {start_x=66, start_y=30, start_vx=0, start_vy=0, gold=10, silver=12, bronze=16}, -- very hard
  {start_x=64, start_y=64, start_vx=-3, start_vy=-3, gold=20, silver=30, bronze=40} -- easy (bonus)
}

-- singletons (_m == manager)
local portal_m = nil   -- type portal_manager_t
local cash = nil       -- type gameobject
local level_m = nil    -- type level_manager_t
local particle_m = nil -- type particle_manager_t
local menu_m = nil     -- type menu_manager_t

-------------------
-- main methods
-------------------
function _init()
  printh('')
  printh('--------------')
  printh('')

  cartdata('maxbize_portaldeal_1')

  poke(0x5f2d, 1) -- enable mouse

  local portal = gameobject:new()
  portal_m = portal:add_component(portal_manager_t:new())
  instantiate(portal)

  cash = gameobject:new{x=60, y=91, layer=3}
  cash:add_component(rigidbody_t:new{width=3, height=3})
  cash:add_component(cash_t:new())
  instantiate(cash)

  level_manager = gameobject:new()
  level_m = level_manager:add_component(level_manager_t:new())
  instantiate(level_manager)

  menu_manager = gameobject:new{layer=4}
  menu_m = menu_manager:add_component(menu_manager_t:new())
  instantiate(menu_manager)

  particle_manager = gameobject:new{layer=1}
  particle_m = particle_manager:add_component(particle_manager_t:new())
  instantiate(particle_manager)
end

function _update60()
  if (paused) then
    return
  end

  if (not btnp(5) and time_scale == 1) then
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
function print_shadowed(text, x, y, color)
  print(text, x, y-1, gradients[color])
  print(text, x, y, color)
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
  -- sanity check all inputs are integers. can remove before shipping
  --check_int(x, 'x')
  --check_int(y, 'y')
  --check_int(w, 'w')
  --check_int(h, 'h')

  -- need to keep track of individual corners separately to not conflate
  -- an overlap from one brick with a non-overlap from another brick that has
  -- a portal
  local any_in_portal = false

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
            in_portal = in_portal or overlaps_portal(portal, x, y, w, h)
          end
        end
      end

      any_in_portal = any_in_portal or in_portal

      -- hit a solid wall. no need to check anything else
      if (not in_portal) then
        return 2
      end
    end


    -- check against moving platforms
  end

  return any_in_portal and 1 or 0
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
particle_manager_t = gameobject:new({
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

function particle_manager_t:add_particle_shadowed(x, y, vx, vy, ax, ay, color, frames, layer)
  self:add_particle(x, y, vx, vy, ax, ay, color, frames, layer)
  self:add_particle(x, y+1, vx, vy, ax, ay, gradients[color], frames, layer)
end

function particle_manager_t:add_particle(x, y, vx, vy, ax, ay, color, frames, layer)
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

portal_manager_t = gameobject:new{
  candidate = nil,   -- cell_x, cell_y, dir_x, dir_x
  chain = nil, -- [{cell_x, cell_y, dir_x, dir_x}]
  last_mouse = 0, -- stat(34) from last frame
  move_index = 0 -- if we're moving a portal, this is the index of that portal
}

function portal_manager_t:start()
  self.chain = {}
end

function portal_manager_t:update()
  if (menu_m.active) then
    return
  end

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

  local this_mouse       = stat(34)
  local left_mouse       = this_mouse & 0x1 == 1
  local left_mouse_down  = self.last_mouse & 0x1 == 0 and this_mouse & 0x1 == 1
  local right_mouse_down = self.last_mouse & 0x2 == 0 and this_mouse & 0x2 == 2
  
  if (self.move_index ~= 0 and not left_mouse) then
    self.move_index = 0
  end
  
  if (left_mouse_down) then
    local existing, index = self:find_in_chain(self.candidate)
    if (existing == nil and self.candidate ~= nil) then
      self:place_portal(self.candidate)
      self.move_index = #self.chain
    else
      self.move_index = index
    end
  elseif (self.move_index ~= 0) then
    self:move_portal(self.candidate, self.move_index)
  elseif (right_mouse_down) then
    self:remove_portal(self.candidate)
  elseif (stat(36) ~= 0 and #self.chain > 1) then
    -- Not sure this is a good idea - changes the order of everything else in the process
    --self:reorder_portal(self.candidate, sgn(stat(36)))
  end
  self.last_mouse = this_mouse
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
  del(self.chain, self:find_in_chain(candidate))
end

function portal_manager_t:place_portal(candidate)
  if (candidate == nil) then
    return
  end

  add(self.chain, candidate)
end

function portal_manager_t:move_portal(candidate, index)
  if (candidate ~= nil) then
    self.chain[index] = candidate
  end
end

function portal_manager_t:reorder_portal(candidate, dir)
  if (candidate ~= nil) then
    local existing, index = self:find_in_chain(self.candidate)
    if (existing ~= nil) then
      local swapIndex = index + dir
      if swapIndex > #self.chain then
        swapIndex = swapIndex % #self.chain
      elseif swapIndex <= 0 then
        swapIndex = #self.chain - swapIndex % #self.chain
      end
      self.chain[index] = self.chain[swapIndex]
      self.chain[swapIndex] = existing
    end
  end
end

function portal_manager_t:draw()
  if (self.candidate ~= nil and time_scale == 0) then
    self:draw_portal(self.candidate, 11)
  end

  local highlighted_portal = nil

  for i = 1, #self.chain do
    self:draw_portal(self.chain[i], i < #self.chain and 9 or 12)
    if (time_scale == 0) then
      self:draw_portal_number(i)
      if (self.candidate ~= nil and portals_equal(self.chain[i], self.candidate)) then
        highlighted_portal = i
      end
    end
  end

  if (highlighted_portal ~= nil and #self.chain > 1 and time_scale == 0) then
    --self:draw_portal_number(highlighted_portal == 1 and #self.chain or highlighted_portal-1)
    --self:draw_portal_number(highlighted_portal)
    --self:draw_portal_number((highlighted_portal%#self.chain)+1)

    local p0x, p0y, p0w, p0h = portal_positions(self.chain[highlighted_portal == 1 and #self.chain or highlighted_portal-1])
    local p1x, p1y, p1w, p1h = portal_positions(self.chain[highlighted_portal])
    local p2x, p2y, p2w, p2h = portal_positions(self.chain[(highlighted_portal%#self.chain)+1])
    
    draw_dotted_line(p0x + flr(p0w/2), p0y + flr(p0h/2), p1x + flr(p1w/2), p1y + flr(p1h/2), 14, time()*5%1, 5)
    draw_dotted_line(p1x + flr(p1w/2), p1y + flr(p1h/2), p2x + flr(p2w/2), p2y + flr(p2h/2), 15, time()*5%1, 5)
  end

  -- Draw cursor
  if self.candidate == nil then
    sspr(24, 24, 7, 7, self.go.x - 3, self.go.y - 3)
  elseif highlighted_portal == nil then
    sspr(2, 18, 3, 3, self.go.x - 1, self.go.y - 1)
  elseif self.move_index == 0 then
    sspr(0, 24, 7, 7, self.go.x - 3, self.go.y - 3)
  else
    sspr(8, 24, 7, 7, self.go.x - 3, self.go.y - 3)
  end
end

function portal_manager_t:draw_portal(portal, color)
  local x, y, w, h = portal_positions(portal)
  line(x, y, x + w - 1, y + h - 1, color)
end

function portal_manager_t:draw_portal_number(num)
  portal = self.chain[num]
  local x, y, w, h = portal_positions(portal)
  if w == 1 then
    print(tostr(num), portal.dir_x > 0 and x - 4 or x + 2, y + 2, 0)
  else
    print(tostr(num), x + 1, portal.dir_y > 0 and y - 6 or y + 2, 0)
  end
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
  max_vx = 3, -- max velocity
  max_vy = 3,
  angle = 0, -- angle and angular velocity for animation purposes only!
  angular_vel = 0,
}

function rigidbody_t:start()
  --self.x_remainder = self.go.x
  --self.y_remainder = self.go.y
end

function rigidbody_t:update()
  -- apply ground friction and gravity
  local grounded = self:is_grounded()
  if (grounded) then
    self.angular_vel = self.vx * 40; -- * 60 (speed per sec instead of frame) / 1.5 (radius)
    self.vx *= self.friction
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
          --sfx(3, -1, 0, 1)
          self.angular_vel = -self.vy * 40; -- * 60 (speed per sec instead of frame) / 1.5 (radius)
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
          --sfx(3, -1, 0, 1)
          self.angular_vel = self.vx * 40; -- * 60 (speed per sec instead of frame) / 1.5 (radius)
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

  -- if there's nothing below us, we're grounded
  if (not solid_at_point(self.go.x + flr(self.width / 2), self.go.y + self.height)) then
    return false
  end

  -- if we're in or above an active portal, we're not grounded
  if (#portal_m.chain < 2) then
    return true
  end
  for portal in all(portal_m.chain) do
    if (overlaps_portal(portal, self.go.x - 1, self.go.y - 1, self.width + 2, self.height + 2)) then
      return false
    end
  end

  return true
end

function rigidbody_t:move_x(amount, portal_callback, wall_callback)
  self.x_remainder += amount
  local move = round(self.x_remainder)

  if (move ~= 0) then
    self.x_remainder -= move
    sign = sgn(move)

    while (move ~= 0) do
      overlap_state = overlaps_solids(self.go.x + sign, self.go.y, self.width, self.height)
      if (overlap_state == 1) then
        self.go.x += sign
        portal_callback()
        break
      elseif (overlap_state == 2) then
        wall_callback()
        break
      else
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
    sign = sgn(move)

    while (move ~= 0) do
      overlap_state = overlaps_solids(self.go.x, self.go.y + sign, self.width, self.height)
      if (overlap_state == 1) then
        self.go.y += sign
        portal_callback()
        break
      elseif (overlap_state == 2) then
        wall_callback()
        break
      else
        self.go.y += sign
        move -= sign
      end
    end
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
      self.go.x = flr(p2x + p2w/2 - self.width/2)
      self.go.y = flr(p2y + p2h/2 - self.height/2)

      local v_normal  = p1.dir_x == 0 and self.vy or self.vx
      local v_tangent = p1.dir_x == 0 and self.vx or self.vy

      if (p2.dir_x ~= 0) then
        self.vx = abs(v_normal) * p2.dir_x
        self.vy = p1.dir_x == 0 and -abs(v_tangent) or v_tangent
      else
        self.vx = v_tangent
        self.vy = abs(v_normal) * p2.dir_y
      end

      dx = p2x - p1x
      dy = p2y - p1y
      for i = 1, 20 do
        particle_m:add_particle(self.go.x + 1, self.go.y + 1, rnd(2)-1 + p2.dir_x, rnd(2)-1 + p2.dir_y, 0, 0.1, i <= 10 and 12 or 1, rnd(10)+10)
        local t = i / 21
        particle_m:add_particle(p1x + dx * t, p1y + dy * t, rnd(0.5)-0.25, rnd(0.5)-0.25, 0, 0, 12, i)
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
cash_t = gameobject:new{
}

function cash_t:update()

end

function cash_t:draw()
  --sspr(11, 18, 3, 3, self.go.x, self.go.y)
  sspr(72 + flr(self.go.rb.angle / 45) * 4, 10, 3, 3, self.go.x, self.go.y)
  if (time_scale == 0) then
    local end_x = (self.go.x + self.go.rb.vx * 5) + 1
    local end_y = (self.go.y + self.go.rb.vy * 5) + 1
    line(self.go.x + 1, self.go.y + 1, end_x, end_y, 12)
    circ(end_x, end_y, 1, 1)
    pset(self.go.x + 1, self.go.y + 1, 7)
  end
end

level_manager_t = gameobject:new{
  num_pickups = 0
}

function level_manager_t:start()
  time_scale = 0
end

function level_manager_t:update()
  if (menu_m.active) then
    return
  end

  -- handle input
  if (btnp(4) and time_scale == 0) then
    sfx(3, -1, 0, 2)
    time_scale = 1
  elseif (btnp(4) and time_scale == 1) then
    sfx(3, -1, 0, 2)
    self:restart_level()
--elseif (btnp(5) and time_scale == 0) then
--  portal_m.chain = {}
  end

  -- check/advance to next level
  if (self.num_pickups == 0) then
    self.num_pickups = 1
    sfx(2, -1, 0, 2)
    local num_portals = #portal_m.chain
    if (dget(level) == 0 or dget(level) > num_portals) then
      dset(level, num_portals)
    end

    level_end = gameobject:new()
    level_end:add_component(end_level_menu_t:new{medals=1})
    instantiate(level_end)

    --portal_m.chain = {}
    --if (level < #levels) then
    --  level += 1
    --else
    --  menu_m.active = true
    --end
    --self:restart_level()
  end
end

function level_manager_t:notify_pickup()
  self.num_pickups -= 1
  sfx(0, -1, 31 - self.num_pickups, 1)
end

function level_manager_t:restart_level()
  -- reset time
  time_scale = 0

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
  for layer in all(gameobjects) do
    for go in all(layer) do
      if (go:get_component(pickup_t) ~= nil) then
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
        pickup = gameobject:new{x=x*8, y=y*8}
        pickup:add_component(pickup_t:new())
        instantiate(pickup)
      end
    end
  end
end

pickup_t = gameobject:new{
  chase_time = 0
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
  spr(34, self.go.x + sin(time() - self.spawn_x/128), self.go.y + cos(time() - self.spawn_y/128))
  --pset(self.go.x + 4, self.go.y + 3, 0)
end

menu_manager_t = gameobject:new{
  active = true,
  selected_level = -1,
  last_mouse = 0
}

function menu_manager_t:update()
  if (not self.active) then
    return
  end

  -- update mouse position
  self.go.x = stat(32)
  self.go.y = stat(33)

  if (self.go.y >= 25 and self.go.y < 115) then
    self.selected_level = flr((self.go.y - 25)/9) + 1
  else
    self.selected_level = -1
  end

  local this_mouse = stat(34)
  local left_mouse_down = self.last_mouse & 0x1 == 0 and this_mouse & 0x1 == 1
  if (left_mouse_down and self.selected_level > -1) then
    local unlocked = self.selected_level == 1 or dget(self.selected_level - 1) > 0
    if (unlocked) then
      -- todo: clean up hacks
      self.active = false
      level = self.selected_level
      portal_m.last_mouse = this_mouse
      level_m:restart_level()
    end
  end
  self.last_mouse = this_mouse
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

  if (self.selected_level ~= -1) then
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

  sspr(2, 18, 3, 3, self.go.x - 1, self.go.y - 1)
end

end_level_menu_t = gameobject:new{
  draw_medals = 0, -- 0-3 for none, bronze, etc
  flash_medal = 0, -- 0-3 for none, bronze, etc
  offsets = {0, 0, 0}, -- offsets to draw medals/backgrounds for a little shake. Bronze, silver, gold
  menu_offset = 0, -- offset for the entire menu so that we can slide it in
}

function end_level_menu_t:shake_medal_background(num)
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
  _yield(4)
  self.flash_medal = 0
  for i=1,75 do
    particle_m:add_particle_shadowed(x + rnd(13), 32 + rnd(15), rnd(1.5)-0.75, rnd(1)-1.75, 0, 0.06, color,            100)
  end
  for i=1,25 do
    particle_m:add_particle_shadowed(x + rnd(13), 32 + rnd(15), rnd(1.5)-0.75, rnd(1)-1.75, 0, 0.06, gradients[color], 100)
  end
  _yield(30)
end

function end_level_menu_t:start()
  self.menu_offset = 128
  add(actions, cocreate(function()
    num_portals = #portal_m.chain
    for i=1,16 do
      self.menu_offset *= 0.70
      yield()
    end
    self.menu_offset = 0

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
  end))
end

function end_level_menu_t:update()

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

  -- Draw/print buttons
  rect                   (34, 84 - self.menu_offset, 58, 94 - self.menu_offset, 6)
  rectfill               (35, 85 - self.menu_offset, 57, 93 - self.menu_offset, 5)
  print         ("retry", 37, 87 - self.menu_offset,                            7)
  rect                   (72, 84 - self.menu_offset, 92, 94 - self.menu_offset, 6)
  rectfill               (73, 85 - self.menu_offset, 91, 93 - self.menu_offset, 5)
  print         ("next",  75, 87 - self.menu_offset,                            7)

  -- DEBUG! Draw particles again so they draw over the UI
  particle_m:draw()

end


