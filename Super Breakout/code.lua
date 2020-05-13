-- pad variables
pad_speed = 1.5

-- ball variables
ball_speed = 1.5

-- brick variables
num_bricks_x = 14
num_bricks_y = 25
brick_width = 8
brick_height = 4
brick_gap = 1
bricks = {}

-- game management variables
-- 0 = menu, 1 = game, 2 = editor
game_mode = 0
level = 1
current_music = -1

-- stats
start_time = 0
num_resets = 0

-- level editor variables; made in editor
levels = {
  'a112b42a196',
  'a58ji8ja32nb8na6b6a9k4a215',
  'a35la11b5a8b7a8b5a11la108ca5ca6b3apab3a128',
  'a16b2a2b2a2b2a2b28a14bapab3apab2a105b3a6b7qb6a28boa6boaba100',
  'a16f2a6f2a4f2a6f2a4f2a6f2a4b10a4ba8ba4b4a2b4a4b2cb4cb2a4b4a2b4a4ba8ba4ba8ba4ba3d2a3ba4ba3g2a3ba4ba8ba4b10a142',
  'a2ba2ba2ba2ba4ba2ba2ba2ba4ba2ba2ba2ba4ba2ba2ba2ba4ba2ba2ba2ba4qa2qa2qa2qa4ba2ba2ba2ba4ba2ba2ba2ba4ba2ba2ba2ba4ba2ba2ba2ba4ba2ba2ba2ba4ba2ba2ba2ba2b14a168',
  'a4ra4ra8rab2ara8ra4ra8ra4ra8rab2ara8ra4ra8ra4ra8rab2ara8ra4ra8ra4ra8rab2ara8ra4ra8ra4ra4r5g4r5a154',
  'a57f2af2af2af2a3f2af2af2af2a3f2af2af2af2a59ca4pa5ca29dadadadadadada2dadadadadadada126',
  'ja12iaja10ia3ja8ia5ja6ia7ja4ia9ja2ia6na4jia4na7ija11ia2ja9ia4ja7ia6ja5ia8ja3ia10jaia5l2a5jaia10ja3ia8ja5ia6ja7ia4ja9ia2ja11ija12jia11ja2ia47',
  'a10ba5ba2ba8ba7ba9haba19ba4ba2ha2ba10ba22ba2ba18ba6ba2haba19ba24ba7ba23ba2ha3ba23ba5ba88',
  'a141i2a8i2a2i2a3mca3i2a2f2a8f2a2f2a8f2a2f2a8f2a15j6a2j6a112',
  'a30q2a2p2a2q2a16b6jab7a4bjaba4b2af2abjabaf2ab2af2abjabaf2ab2af2abjabaf2ab2a4bjaba4b4nb2jab2nb3a90o2a104',
  'a71qa10qa34gb2ga10bk2ba10ge2ga75ra12rhna10nhrb2db2d2b2db2ra84',
  'ia14ia14ia14ia14ia14ia14ia14ia14ia14ia14ia14ia14ia14ia42i14a98',
  'ca13ca13r13a30r13a28r13a30r13a28r13a30r13a28r13a57',
  'a38ba12blba7ea4ba4oa2ecea12ea45ea12ecea8oa3ea20ea12ecea3ba8ea3bmba12ba118',
  'a47ia2ia10rajra10rjara8iarajraia6r3jar3a6ra6ra5jra6rja2ja2ra6ra2jamara6rama4ra2rga2ra3ja2ra2eca2ra2ja2jra6rja3kara6raka4ra6ra5jra6rja2ja2r8a2ja84',
  'a4ra9pb13apb12a4ra13ra11oara2ba10ra2ba10rajnja5r5a2ba13ba8ba13ba12jnja12ba13ba34d3a12oa101',
  'ja12j2a11jaja10ja2ja9ja3ja8ja4ja7ja5ja6ja6ja5ja7ja4ja8ja3ja9ja2ja38bgb10gbiaiaiaijiaiaia8ja6b3nb2g2b2nb3a112',
  'a42r14a44ma8na3r3a2b2a2r3a2rirab4arira2rira2b2a2rira2rira6rira2rira6rira2rj10ra2r2a8r2a141',
  'a42b5ebpbeb4a42bebpbebqbebpbea3ba7ba5ba7ba5ea7ea5ba7ba5qbebpbebqa5ba7ba5ea7ea5ba7ba5ba7ba2bebpbeb3ebpbea98',
  'a15rara6rara3oa8oa58bcdef2ghijklmna4f2a12f2a51qa2pa7qa155'
}
level_buffer = nil -- level editor buffer

-- Save 100-150 tokens by parsing brick data as string
editor_bricks_data = "a,0,erase,b,1,regular,c,2,6 ball,d,3,one-way,e,4,3 hits,f,5,big,g,6,green balls,h,7,expander,i,8,move (vertical),j,9,move (horizontal),k,10,powerup (blue safety),l,26,powerup (green safety),m,42,powerup (paddle glue),n,58,powerup (wider paddle),o,11,teleport,p,12,laser (horizontal),q,44,laser (vertical),r,13,invulnerable,"
editor_bricks = {}           -- straight list
editor_bricks_by_sprite = {} -- map of sprite -> config
editor_bricks_by_symbol = {} -- map of symbol -> config

do
  local left, right = 1, 1
  local strs = {}
  while (left < #editor_bricks_data) do
    while (sub(editor_bricks_data, right, right) ~= ",") do
      right += 1
    end
    add(strs, sub(editor_bricks_data, left, right - 1))
    right += 1
    left = right
    if (#strs == 3) then
      local brick_config = {symbol=strs[1], sprite=tonum(strs[2]), description=strs[3], index=#editor_bricks+1}
      add(editor_bricks, brick_config)
      editor_bricks_by_sprite[brick_config.sprite] = brick_config
      editor_bricks_by_symbol[brick_config.symbol] = brick_config
      strs = {}
    end
  end
end

-- set default brick to normal
editor_brick = editor_bricks[2]

-- lighting / 3d
-- maps every color to the darker version
gradients = {0, 1, 1, 2, 1, 13, 6, 2, 4, 9, 3, 1, 5, 13, 14}

-- engine stuff
paused = false
pause_every_step = false
ticks_per_step = 1
ticks = 0
screen_shake = 0

-- base gameobject class
gameobject = {
  go = nil, -- gameobject
  rb = nil, -- cached rigidbody
  col = nil, -- cached collider
  renderer = nil, -- cached renderer
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
  if (instanceof(component, rigidbody)) then
    self.rb = component
  elseif (instanceof(component, rectcollider)) then
    self.col = component
  elseif (instanceof(component, renderer)) then
    self.renderer = component
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

-- renderer components
renderer = gameobject:new()

spriterenderer = renderer:new{
  sprite=0,
  width=8,
  height=4,
  flip_x=false;
}

function spriterenderer:draw()
  sspr((self.sprite % 16) * 8,
       flr(self.sprite / 16) * 8 + 2,
       8,
       4,
       self.go.x - self.width  / 2,
       self.go.y - self.height / 2,
       self.width,
       self.height,
       self.flip_x)
end

ssprrenderer = renderer:new{
  sx=0,
  sy=0,
  sw=0,
  sh=0,
  dw=-1,
  dh=-1,
  flip_x=false;
}

function ssprrenderer:start()
  if (self.dw == -1) then
    self.dw = self.sw
  end
  if (self.dh == -1) then
    self.dh = self.sh
  end
end

function ssprrenderer:draw()
  sspr(self.sx,
       self.sy,
       self.sw,
       self.sh,
       self.go.x - self.sw  / 2,
       self.go.y - self.sh / 2,
       self.dw,
       self.dh,
       self.flip_x)
end

-- physics components
rigidbody = gameobject:new{
  vx = 0,
  vy = 0,
  ax = 0,
  ay = 0
}

function rigidbody:update()
  self.vx += self.ax
  self.vy += self.ay

  self.go.x += self.vx
  self.go.y += self.vy
end

rectcollider = gameobject:new{
  width = 0,
  height = 0
}

-- gameobject management / main loops
_to_start = {} -- all gameobjects that still haven't had start() called
gameobjects = {} -- global list of all objects
actions = {} -- coroutines
for i=1,4 do
  add(gameobjects, {}) -- 4 layers
end
static_bricks = {} -- all bricks that don't move

-- unlike the unity version, does not clone!
function instantiate(gameobject)
  add(_to_start, gameobject)
  return gameobject
end

function destroy(gameobject)
  del(gameobjects[gameobject.layer], gameobject)
end

function _update60()
  if (paused) then
    return
  elseif (pause_every_step) then
    paused = true
  end

  camera(-(screen_shake % 2), 0)
  if (screen_shake > 0) then
    screen_shake -= 1
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
  cls(5)

  for i=1,count(gameobjects) do
    for go in all(gameobjects[i]) do
      go:draw_components()
    end

    if (i == 1 and game_mode ~= 0) then
      map(0, 0, 0, 0, 16, 16)
    end
  end

  -- hide the rightmost column to keep the border even on both sides
  rectfill(127,0,127,128,0)

  --print((stat(1) < 0.1 and '0' or '')..flr(stat(1) * 100), 0, 6, 0)
  --print(dget(2))
end

function _check_collision(go1, go2)
  if (  abs(go1.x - go2.x) < (go1.col.width + go2.col.width) / 2
    and abs(go1.y - go2.y) < (go1.col.height + go2.col.height) / 2) then
    for component in all(go1.components) do
      if (component.on_collision ~= nil) then
        component:on_collision(go2)
      end
    end
    for component in all(go2.components) do
      if (component.on_collision ~= nil) then
        component:on_collision(go1)
      end
    end
    return true
  end
  return false
end

-- utilities

function round(n)
  return n%1 < 0.5 and flr(n) or -flr(-n)
end

function dist(x1, y1, x2, y2)
  return sqrt((x2 - x1)^2 + (y2 - y1)^2)
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

-- end engine code
x_offset = -4
y_offset = -2

function brick_pos_to_index(x, y)
  local x_index = (x - x_offset) / (brick_width + brick_gap)
  local y_index = (y - y_offset) / (brick_height + brick_gap)

  local x_delta = x_index % 1 > 0.5 and 1 or 0
  x_index = flr(x_index) + x_delta

  local y_delta = y_index % 1 > 0.5 and 1 or 0
  y_index = flr(y_index) + y_delta

  return x_index, y_index, x_delta, y_delta
end

function brick_at_index(x, y)
  if (x > 0 and x <= num_bricks_x and y > 0 and y <= num_bricks_y) then
    return static_bricks[x][y]
  else
    return nil
  end
end

function brick_at_pos(x, y)
  x_index, y_index = brick_pos_to_index(x, y)
  return static_bricks[x_index][y_index]
end

function static_bricks_near_pos(x, y)
  local bricks = {}

  local x_index, y_index, x_delta, y_delta = brick_pos_to_index(x, y)

  for i=0,1 do
    for j=0,1 do
      local x_index_neighbor = x_index - x_delta * i
      if (x_index_neighbor > 0 and x_index_neighbor <= num_bricks_x) then
        local brick_neighbor = static_bricks[x_index_neighbor][y_index - y_delta * j]
        if (brick_neighbor ~= nil) then
          local found = false
          for b in all(bricks) do
            if (b == brick_neighbor) then
              found = true
            end
          end
          if (not found) then
            add(bricks, brick_neighbor)
          end
        end
      end
    end
  end

  return bricks
end

function load_brick(i, j, brick_type)
  if (static_bricks[i][j]) then
    return
  end
  local x = x_offset + i * (brick_width + brick_gap)
  local y = y_offset + j * (brick_height + brick_gap)

  local brick_obj = gameobject:new{x=x, y=y}
  brick_obj:add_component(spriterenderer:new{sprite=brick_type, flip_x=rnd(1)>0.5})
  brick_obj:add_component(rectcollider:new{width=brick_width, height=brick_height})
  instantiate(brick_obj)

  local brick_comp = brick_obj:add_component(brick:new{x_index=i, y_index=j})
  if (brick_type == 3 or brick_type == 4 or brick_type == 6) then
    brick_comp.health = 3 -- need to be able to override this so it's not in brick:start
  end
  if (brick_type ~= 11 and brick_type ~= 13 and j ~= num_bricks_y) then
    lm.num_bricks += 1
  end
  static_bricks[i][j] = brick_obj
  if (brick_type == 5) then
    for i2=0,1 do
      for j2=0,2 do
        local x_index = min(i+i2, num_bricks_x)
        local other_brick_obj = static_bricks[x_index][j+j2]
        if (other_brick_obj ~= nil and other_brick_obj ~= brick_obj) then
          other_brick_obj:get_component(brick):destroy()
        end
        static_bricks[x_index][j+j2] = brick_obj
      end
    end
  end
  return brick_obj
end

function clear_balls()
  lm.num_balls = 0
  for layer in all(gameobjects) do
    for go in all(layer) do
      if (go:get_component(ball) ~= nil) then
        destroy(go)
      end
    end
  end
end

function clear_level()
  lm.num_bricks = 0
  static_bricks = {}
  for i = 1, num_bricks_x do
    add(static_bricks, {})
  end

  clear_balls()
  for layer in all(gameobjects) do
    for go in all(layer) do
      if (go:get_component(brick) ~= nil 
        or go:get_component(powerup) ~= nil) then
        destroy(go)
      end
    end
  end
end

function load_level_compressed(level)
  clear_level()
  local i, left, right, next_type, num = 0, 1
  while (left <= #level) do
    next_type = editor_bricks_by_symbol[sub(level, left, left)].sprite
    right = left + 1
    local num_attempt = 1
    while (num_attempt ~= nil and right <= #level + 1) do
      num = num_attempt
      num_attempt = tonum(sub(level, left + 1, right))
      right += 1
    end
    for c = 1, num do
      if (next_type > 0) then
        load_brick((i % num_bricks_x) + 1, flr(i / num_bricks_x) + 1, next_type)
      end
      i += 1
    end
    left = right - 1
  end
end

function dump_level_compressed()
  local last_brick_type = -1
  local brick_count = 1
  local level_str = ""
  for y = 1, num_bricks_y do
    for x = 1, num_bricks_x do
      local next_brick_type = static_bricks[x][y] == nil and 0 or static_bricks[x][y].renderer.sprite
      if (next_brick_type ~= last_brick_type) then
        if (last_brick_type ~= -1) then
          level_str = level_str .. editor_bricks_by_sprite[last_brick_type].symbol .. (brick_count > 1 and tostr(brick_count) or "")
        end
        brick_count = 0
      end
      last_brick_type = next_brick_type
      brick_count += 1
    end
  end
  level_str = level_str .. editor_bricks_by_sprite[last_brick_type].symbol .. (brick_count > 1 and tostr(brick_count) or "")
  return level_str
end

level_manager = gameobject:new{
  num_balls = 0,
  num_bricks = 0 -- only destructible bricks!
}

function level_manager:update()
  if (game_mode ~= 1) then
    return
  end

  if (level_buffer == nil) then
    dset(0, level)
    dset(1, time() - start_time)
    dset(2, num_resets)
  end

  if (self.num_bricks == 0 and count(actions) == 0) then
    sfx(28)
    sfx(29)
    sfx(30)
    if (level_buffer == nil) then
      cb:interrupt_action()
      if (level < #levels) then
        level += 1
        init_level(levels[level])
      else
        local total_t = time() - start_time
        local total_str = tostr(flr(total_t/3600)..":"..tostr(flr(total_t/60)%60)..":"..tostr(flr(total_t%60)))
        cb:start_action(-1, nil, "yay! you win!\ntime: "..total_str.."\nresets: "..num_resets)
        paused = true
      end
    else
      --init_level_editor()
    end
  elseif (self.num_balls == 0) then
    num_resets += 1
    make_ball(0, 0, true)
  end

  -- reset ball
  if (btn(2)) then
    cb:start_action(2,
      function()
        num_resets += 1
        clear_balls()
        make_ball(0, 0, true)
      end,
      "reset balls")
  -- restart level
  elseif (btn(3)) then
    cb:start_action(3,
      function()
        if (level_buffer == nil) then
          num_resets += 1
          init_level(levels[level])
        else
          init_level_editor()
        end
      end,
    level_buffer == nil and "restart level" or "back to editor")
  end


end

level_editor = gameobject:new()

function level_editor:update()
  if (game_mode ~= 2) then
    return
  end
  
  self.go.x = stat(32)
  self.go.y = stat(33)

  local x, y = brick_pos_to_index(self.go.x, self.go.y)

  if (x > 0 and x <= num_bricks_x and y > 0 and y <= num_bricks_y) then
    local brick_obj = static_bricks[x][y]
    if (stat(34) == 1 and editor_brick.sprite > 0) then
      if (brick_obj ~= nil and brick_obj.renderer.sprite ~= editor_brick.sprite) then
        brick_obj:get_component(brick):destroy()
        brick_obj = nil
      end
      if (brick_obj == nil) then
        load_brick(x, y, editor_brick.sprite)
        sfx(0, 0, 0, 1)
      end
    elseif (stat(34) == 2) then
      editor_brick = brick_obj == nil and editor_bricks[1] or editor_bricks_by_sprite[brick_obj.renderer.sprite]
    elseif (stat(34) == 4 or (stat(34) == 1 and editor_brick.sprite == 0)) then
      if (brick_obj ~= nil) then
        sfx(0, 1, 8, 1)
        brick_obj:get_component(brick):destroy()
      end
    end
  end

  -- left/right arrows
  if (btnp(0)) then
    editor_brick = editor_bricks[editor_brick.index - 1]
    if (editor_brick == nil) then
      editor_brick = editor_bricks[#editor_bricks]
    end
  elseif (btnp(1)) then
    editor_brick = editor_bricks[editor_brick.index + 1]
    if (editor_brick == nil) then
      editor_brick = editor_bricks[1]
    end
  end

  -- paste
  if (btn(5)) then
    cb:start_action(5, 
      function()
        clear_level()
        load_level_compressed(stat(4))
      end,
      "paste level")
  -- copy
  elseif (btn(4)) then
    cb:start_action(4,
      function() 
        printh(dump_level_compressed(), '@clip') 
      end,
      "copy level")
  -- playtest
  elseif (btnp(2)) then
    cb:start_action(2,
      function()
        level_buffer = dump_level_compressed()
        init_level(level_buffer)
      end,
      "play level")
  end
end

function level_editor:draw()
  if (game_mode ~= 2) then
    return
  end

  sspr(123, 59, 2, 2, self.go.x - 1, self.go.y - 1)
  print('brick:'..editor_brick.description, 1, 122, 0)
end

ball = gameobject:new{
  next_ball = 5,
  paddle_flag = false, -- eligible to decrement next ball
  last_brick = nil, -- last brick this ball hit
  glued = false
}

function ball:update()
  -- paddle will handle the ball
  if (self.glued) then
    return
  end

  -- increase speed according to distance from paddle
  local newSpeed = (180 - self.go.y) / 60
  local mag = dist(0, 0, self.go.rb.vx, self.go.rb.vy)
  self.go.rb.vx /= (mag / newSpeed)
  self.go.rb.vy /= (mag / newSpeed)

  -- check bounds
  if (self.go.y > 130) then
    lm.num_balls -= 1
    destroy(self.go)
  elseif (self.go.y < self.go.col.height / 2) then
    self.go.y = self.go.col.height / 2
    self.go.rb.vy *= -1
  end

  if (self.go.x < self.go.col.width / 2) then
    self.go.x = self.go.col.width / 2
    self.go.rb.vx *= -1
  elseif (self.go.x > 127 - self.go.col.width / 2) then
    self.go.x = 127 - self.go.col.width / 2
    self.go.rb.vx *= -1
  end

  if (self.go.y < paddle_obj.y - (paddle_obj.col.height + self.go.col.height) / 2 - 1) then
    self.paddle_flag = true
  end

  -- update background particles
  bgp:near_particle(self.go, self.go.rb.vx, self.go.rb.vy)

  -- check for brick collisions
  local collided = false
  for brick in all(static_bricks_near_pos(self.go.x, self.go.y)) do
    -- brick first so that we can inspect ball velocity
    if (brick == self.last_brick) then
      collided = true -- not quite accurate. it could be a near miss
    else
      collided = collided or _check_collision(brick, self.go)
    end
  end

  if (not collided) then
    self.last_brick = nil
  end

  -- check for paddle collision
  _check_collision(self.go, paddle_obj)

end

function ball:draw()
  sspr(124 - (self.next_ball - 1) * 3, 16, 2, 3, self.go.x - 0.5, self.go.y - 0.5)
end

function angle_vector(theta, magnitude)
  return magnitude * cos(0.25 + (theta/360)),
         magnitude * sin(0.25 + (theta/360))
end

function rotate_vector(x, y, theta)
  local st = sin(theta/360)
  local ct = cos(theta/360)
  return 
    x * ct - y * st,
    y * st + y * ct
end

function ball:on_collision(other)
  local pad = other:get_component(paddle)
  if (pad ~= nil) then
    -- paddle is a one-way, one-time collider
    
    if (pad.glue and self.paddle_flag and not btn(5)) then
      pad:glue_ball(self.go)
      self.paddle_flag = false
      return
    end

    if (self.go.rb.vy > 0) then
      sfx(0, 0, 0, 1)
      local mag = dist(0, 0, self.go.rb.vx, self.go.rb.vy)
      local dx = other.x - self.go.x
      local theta = (dx / (other.col.width/2)) * 60 -- -60 to 60
      self.go.rb.vx, self.go.rb.vy = angle_vector(theta, mag)
      if (self.paddle_flag) then
        self.next_ball -= 1

        for i=1, 5 do
          pm:add_voxel(self.go.x, self.go.y, rnd(2)-1, -(rnd(1)), 0, 0, 4, rnd(15)+5, 2)
          pm:add_voxel(self.go.x, self.go.y, rnd(2)-1, -(rnd(1)), 0, 0, 9, rnd(15)+5, 2)
        end
      end
      self.paddle_flag = false

      if (self.next_ball <= 0) then
        make_ball(self.go.x, self.go.y)
        self.next_ball = 5
        for i=1, 10 do
          pm:add_voxel(self.go.x, self.go.y, rnd(2)-1, -(rnd(1)), 0, 0, 10, rnd(30)+10, 2)
          pm:add_voxel(self.go.x, self.go.y, rnd(2)-1, -(rnd(1)), 0, 0, 11, rnd(30)+10, 2)
        end
      end

      pad.animation_ticks = 12
    end
    return
  end

  if (other.renderer.sprite == 11) then
    return
  else
    self.last_brick = other
  end

  -- one-way brick
  if (other.renderer.sprite % 16 == 3 and self.go.rb.vy < 0) then
    return
  end

  -- dx/dy from other nearest edge to self center
  local dx, dy = 0
  local dx = self.go.x - (other.x + other.col.width / 2 * (self.go.x > other.x and 1 or -1))
  local dy = self.go.y - (other.y + other.col.height / 2 * (self.go.y > other.y and 1 or -1))

  -- dir from other center to nearest edge
  local dir_x = self.go.x > other.x and 1 or -1
  local dir_y = self.go.y > other.y and 1 or -1

  local collided_x = false
  local collided_y = false

  -- find which direction we collided from
  if (abs(dx) <= 1 and abs(dy) <= 1) then
    if (sgn(dir_y) == -sgn(self.go.rb.vy)) then
      collided_y = true
    end
    if (sgn(dir_x) == -sgn(self.go.rb.vx)) then
      collided_x = true
    end
  elseif (abs(dx) > abs(dy)) then
    if (sgn(dir_y) == -sgn(self.go.rb.vy)) then
      collided_y = true
    else
      collided_x = true
    end
  else
    if (sgn(dir_x) == -sgn(self.go.rb.vx)) then
      collided_x = true
    else
      collided_y = true
    end
  end

  -- check that collision from the sides/top/bottom was possible
  -- doesn't quite work on big bricks and i'm out of tokens so let's just ignore :)
  if (other.renderer.sprite % 16 ~= 5) then
    local brick_x, brick_y = brick_pos_to_index(other.x, other.y)
    if (collided_x and (
         (sgn(self.go.rb.vx) > 0 and brick_at_index(brick_x - 1, brick_y)) 
      or (sgn(self.go.rb.vx) < 0 and brick_at_index(brick_x + 1, brick_y)))) then
      collided_x = false
      collided_y = true
    elseif (collided_y and (
         (sgn(self.go.rb.vy) > 0 and brick_at_index(brick_x, brick_y - 1)) 
      or (sgn(self.go.rb.vy) < 0 and brick_at_index(brick_x, brick_y + 1)))) then
      collided_y = false
      collided_x = true
    end
  end

  -- flip velocity
  if (collided_x) then
    self.go.rb.vx *= (-0.975 - rnd(0.05))
  end
  if (collided_y) then
    self.go.rb.vy *= (-0.975 - rnd(0.05))
  end
end

brick = gameobject:new{
  x_index=0,
  y_index=0,
  health=1,
  ticks=0,
  size_damage=0,
  dir_y=0,
  dir_x=0
}

function brick:start()
  local brick_type = self.go.renderer.sprite
  if (brick_type == 5) then
    self.health = 8
    self.go.x += 5
    self.go.y += 5
    self.go.renderer.width =  0
    self.go.renderer.height = 0
    self.go.col.width = 17
    self.go.col.height = 14
  elseif (brick_type == 8) then
    self.dir_y = 1
  elseif (brick_type == 9 or brick_type == 24) then
    self.dir_x = 1
  elseif (brick_type == 11) then
    for go in all(gameobjects[2]) do
      local other_brick = go:get_component(brick)
      if (other_brick ~= nil and go ~= self.go and go.renderer.sprite == 11) then
        self.other_tp = go
        other_brick.other_tp = self.go
      end
    end
  elseif (brick_type % 16 == 12) then
    self.go.renderer.flip_x = false
  end
end

function brick:draw()
  if (self.go.renderer.sprite % 16 == 5) then
    sspr(17 * flr((8-self.health)/2),
         32 + 14 * (self.health % 2),
         17,
         14,
         self.go.x-17/2,
         self.go.y-14/2)
  end
end

function brick:on_collision(other)
  sfx(0, 1, 8, 1)

  local sr = self.go.renderer

  -- special brick that turns balls green
  local b = other:get_component(ball)
  if (b ~= nil and (sr.sprite == 6 or sr.sprite == 22 or sr.sprite == 38)) then
    b.next_ball = 1
  end

  -- special brick that launches a bunch of balls
  if (sr.sprite == 2) then
    for i=1,8 do
      if (i ~= 2 and i ~= 6) then
        b = make_ball(self.go.x, self.go.y)
        local rb = b:get_component(rigidbody)
        rb.vx, rb.vy = angle_vector(360/8*i, ball_speed)
      end
    end
  end

  -- special brick that doesn't break
  if (sr.sprite == 13) then
    return
  end

  -- special brick that teleports balls
  if (sr.sprite == 11) then
    other.x = self.other_tp.x
    other.y = self.other_tp.y
    b.last_brick = self.other_tp
    local distance = dist(self.go.x, self.go.y, self.other_tp.x, self.other_tp.y)
    local to_target_x = (self.other_tp.x - self.go.x) / distance
    local to_target_y = (self.other_tp.y - self.go.y) / distance
    for i=1,20 do
      local vx = (rnd(i/20)-0.5)
      local vy = (rnd(i/20)-0.5)
      local c = rnd(1) > 0.5 and 8 or 12
      local f = i * 1.5 + 2
      pm:add_voxel(self.go.x + to_target_x * (distance/21) * i,
                    self.go.y + to_target_y * (distance/21) * i,
                    vx, vy, -vx/f/2, -vy/f/2, c, f, 2)
    end
    self:hit_particles(self.other_tp.x, self.other_tp.y)
    return
  end

  -- special brick that drops powerups
  if (sr.sprite % 16 == 10) then
    local power_obj = gameobject:new{x=self.go.x, y=self.go.y, layer=3}
    power_obj:add_component(powerup:new{kind=flr(sr.sprite/16)})
    power_obj:add_component(rigidbody:new{vy=-0.5})
    power_obj:add_component(rectcollider:new{width=3, height=4})
    if (sr.sprite == 10) then
      power_obj:add_component(ssprrenderer:new{sx=88, sy=8, sw=3, sh=4})
    elseif (sr.sprite == 26) then
      power_obj:add_component(ssprrenderer:new{sx=92, sy=8, sw=3, sh=4})
    elseif (sr.sprite == 42) then
      power_obj:add_component(ssprrenderer:new{sx=88, sy=12, sw=3, sh=4})
    elseif (sr.sprite == 58) then
      power_obj:add_component(ssprrenderer:new{sx=92, sy=12, sw=3, sh=4})
    end
    instantiate(power_obj)
  end

  -- special brick that shoots lasers
  if (sr.sprite % 16 == 12) then
    if (self.ticks == 0) then
      sr.sprite += 16
      self.ticks = 180
      local sx = (sr.sprite % 16) * 8 + 4
      local sy = flr(sr.sprite / 16) * 8 + 3
      if (sr.sprite == 28) then
        local laser_obj = gameobject:new{x=self.go.x-self.go.col.width/2, y=self.go.y}
        laser_obj:add_component(laser:new{dir_x=-1, ticks=self.ticks})
        instantiate(laser_obj)
        laser_obj = gameobject:new{x=self.go.x+self.go.col.width/2, y=self.go.y}
        laser_obj:add_component(laser:new{dir_x=1, ticks=self.ticks})
        instantiate(laser_obj)
      elseif (sr.sprite == 60) then
        local laser_obj = gameobject:new{x=self.go.x+1, y=self.go.y - self.go.col.height/2}
        laser_obj:add_component(laser:new{dir_y=-1, ticks=self.ticks})
        instantiate(laser_obj)
        local laser_obj = gameobject:new{x=self.go.x+1, y=self.go.y + self.go.col.height/2}
        laser_obj:add_component(laser:new{dir_y=1, ticks=self.ticks})
        instantiate(laser_obj)
      end
    end
    return
  end

  -- take damage and increment sprite
  if (sr.sprite % 16 == 3) then
    if (b == nil or other.rb.vy > 0) then
      self.health -= 1
      self:hit_particles(self.go.x, self.go.y)
      sr.sprite += 16
    end
  elseif (sr.sprite == 5) then
    self:hit_particles(other.x, other.y)
    self:hit_particles(other.x, other.y)
    self.health -= 1
    if (self.health == 0) then
      self:hit_particles(self.go.x, self.go.y)
      self:hit_particles(self.go.x+rnd(5), self.go.y+rnd(5))
      self:hit_particles(self.go.x+rnd(5), self.go.y-rnd(5))
      self:hit_particles(self.go.x-rnd(5), self.go.y+rnd(5))
      sr.sprite += 16
      self:hit_particles(self.go.x-rnd(5), self.go.y-rnd(5))
    end
  elseif (sr.sprite == 7) then
    self:hit_particles(other.x, self.go.y)
    self.size_damage += 16
  else
    self.health -= 1
    self:hit_particles(self.go.x, self.go.y)
    sr.sprite += 16
  end

  -- remove brick from world
  if (self.health <= 0) then
    self:destroy()
  end
end

function brick:hit_particles(spawn_x, spawn_y, sprite)
  local sprite_x_start = (self.go.renderer.sprite % 16) * 8
  local sprite_y_start = flr(self.go.renderer.sprite / 16) * 8 + 2

  sprite_particles(sprite_x_start, sprite_y_start, 8, 4, spawn_x, spawn_y, self.health)
end

function sprite_particles(sx, sy, sw, sh, spawn_x, spawn_y, skips)
  for i=0, (sw*sh)-1, 1+skips do
    local vx = rnd(1) - 0.5
    local vy = rnd(1) - 0.5

    local x = spawn_x - (i % sw - (sw/2) + 1)
    local y = spawn_y + flr(i / sw) - 2

    local color = sget(sx + i%sw, sy + flr(i/sw))
    pm:add_particle(x, y, vx, vy, -vx/90, -vy/90, color, rnd(60), 2)
    pm:add_particle(x, y+1, vx, vy, -vx/90, -vy/90, gradients[color], rnd(60), 2)
    pm:add_particle(x+1, y, vx, vy, -vx/90, -vy/90, color, rnd(60), 2)
    pm:add_particle(x+1, y+1, vx, vy, -vx/90, -vy/90, gradients[color], rnd(60), 2)
    
    if (i % 6 == 0) then
      --bgp:add_debris(x, y, color, vx, vy)
    end

  end
end

function brick:destroy()
  -- hack - can't reliably find the dynamic tiles
  local found_j = 0
  for i=1,num_bricks_x do
    for j=1,num_bricks_y do
      if (static_bricks[i][j] == self.go) then
        static_bricks[i][j] = nil
        found_j = j
      end
    end
  end
  if (found_j ~= num_bricks_y) then
    lm.num_bricks -= 1
  end
  if (game_mode == 1) then
    screen_shake = 1
  end
  destroy(self.go)
end

function brick:update()
  if (game_mode ~= 1) then
    return
  end
  
  if (self.go.renderer.sprite == 7) then
    -- expand horizontal
    self.ticks += 1
    if (self.ticks > 4*0) then
      self.ticks = 0

      local x_index = -flr(-((self.go.x + self.go.col.width / 2 - x_offset - 3) / (brick_width + brick_gap)))
      local y_index = (self.go.y - y_offset) / (brick_height + brick_gap)

      if (self.go.x + self.go.col.width / 2 < 126 
          and (static_bricks[x_index][y_index] == nil
          or  static_bricks[x_index][y_index] == self.go)) then
        static_bricks[x_index][y_index] = self.go
        self.go.renderer.width += 1
        self.go.col.width += 1
        self.go.x += 0.5
      end

      x_index = flr((self.go.x - self.go.col.width / 2 - x_offset + 3) / (brick_width + brick_gap))

      if (self.go.x - self.go.col.width / 2 > 1
          and (static_bricks[x_index][y_index] == nil
          or  static_bricks[x_index][y_index] == self.go)) then
        static_bricks[x_index][y_index] = self.go
        self.go.renderer.width += 1
        self.go.col.width += 1
        self.go.x -= 0.5
      end

    end

    if (self.size_damage > 0) then
      self.size_damage -= 1

      local y_index = (self.go.y - y_offset) / (brick_height + brick_gap)
      local right_x_index_before = -flr(-((self.go.x + self.go.col.width / 2 - x_offset - 3) / (brick_width + brick_gap)))
      local left_x_index_before = flr((self.go.x - self.go.col.width / 2 - x_offset + 3) / (brick_width + brick_gap))

      self.go.renderer.width -= 1
      self.go.col.width -= 1

      local right_x_index_after = -flr(-((self.go.x + self.go.col.width / 2 - x_offset - 3) / (brick_width + brick_gap)))
      local left_x_index_after = flr((self.go.x - self.go.col.width / 2 - x_offset + 3) / (brick_width + brick_gap))

      if (right_x_index_before <= num_bricks_x and right_x_index_before ~= right_x_index_after and static_bricks[right_x_index_before][y_index] == self.go) then
        static_bricks[right_x_index_before][y_index] = nil
      end
      if (left_x_index_before > 0 and left_x_index_before ~= left_x_index_after and static_bricks[left_x_index_before][y_index] == self.go) then
        static_bricks[left_x_index_before][y_index] = nil
      end

      if (self.go.col.width <= 0) then
        self.health = 0
        self:hit_particles(self.go.x, self.go.y)
        self:destroy()
      else
        self.health = 4
        self.ticks = -120
      end
    end
  elseif (self.go.renderer.sprite % 16 == 8 or self.go.renderer.sprite == 9) then
    -- move vertically / horizontally
    bgp:near_particle(self.go, self.dir_x, self.dir_y)
    local next_x_index, next_y_index = brick_pos_to_index(self.go.x + self.dir_x * (self.go.col.width/2 + 1), self.go.y + self.dir_y * (self.go.col.height/2 + 1))
    if (next_x_index < 1 or next_x_index > num_bricks_x or next_y_index < 1 or next_y_index > num_bricks_y - 3
      or (static_bricks[next_x_index][next_y_index] ~= nil and static_bricks[next_x_index][next_y_index] ~= self.go)) then
      
      if (self.go.renderer.sprite == 24) then
        self.last_x = self.dir_x == 0 and self.last_x or self.dir_x
        self.dir_x = self.dir_x == 0 and -self.last_x or 0
        self.dir_y = 1 - self.dir_y
      else
        self.dir_x *= -1
        self.dir_y *= -1
      end
    else
      local prev_neg_x_index, prev_neg_y_index = brick_pos_to_index(self.go.x - self.dir_x * self.go.col.width / 2, self.go.y - self.dir_y * self.go.col.height / 2)
      local prev_pos_x_index, prev_pos_y_index = brick_pos_to_index(self.go.x + self.dir_x * self.go.col.width / 2, self.go.y + self.dir_y * self.go.col.height / 2)

      self.go.x += self.dir_x
      self.go.y += self.dir_y

      local next_neg_x_index, next_neg_y_index = brick_pos_to_index(self.go.x - self.dir_x * self.go.col.width / 2, self.go.y - self.dir_y * self.go.col.height / 2)
      local next_pos_x_index, next_pos_y_index = brick_pos_to_index(self.go.x + self.dir_x * self.go.col.width / 2, self.go.y + self.dir_y * self.go.col.height / 2)

      if (prev_neg_x_index ~= next_neg_x_index or prev_neg_y_index ~= next_neg_y_index) then
        static_bricks[prev_neg_x_index][prev_neg_y_index] = nil
      end

      if (prev_pos_x_index ~= next_pos_x_index or prev_pos_y_index ~= next_pos_y_index) then
        static_bricks[next_pos_x_index][next_pos_y_index] = self.go
      end
    end
  elseif (self.go.renderer.sprite % 16 == 12) then
    -- lasers
    if (self.ticks > 0) then
      self.ticks -= 1
      if (self.ticks == 0) then
        self.health = 0
        self:hit_particles(self.go.x, self.go.y)
        self:destroy()
      end
    end
  end
end

laser = gameobject:new{
  origin_x = 0,
  origin_y = 0,
  dir_x = 0,
  dir_y = 0,
  size = 0,
  ticks = 0
}

function laser:start()
  self.origin_x = self.go.x
  self.origin_y = self.go.y
end

function laser:update()
  self.ticks -= 1
  if (self.ticks == 0) then
    for i=1,self.size do
      local color = flr(rnd(3))+8
      local vx, vy = rnd(1)-0.5, rnd(1)-0.5
      pm:add_voxel(self.origin_x+self.dir_x*i,
                      self.origin_y-1+self.dir_y*i,
                      vx,
                      vy,
                      0, 0, color, rnd(20)+10)
    end
    destroy(self.go)
  end

  -- todo: simplify to just walk the entire path every frame
  for i=1,6 do
    local next_x = self.origin_x + self.dir_x * (self.size + 1)
    local next_y = self.origin_y + self.dir_y * (self.size + 1)

    local color = flr(rnd(3))+8
    local vx = rnd(1) * -self.dir_x + (rnd(1) - 0.5) * self.dir_y
    local vy = rnd(1) * -self.dir_y + (rnd(1) - 0.5) * self.dir_x
    pm:add_voxel(next_x, next_y,   vx, vy, 0, 0, color, rnd(5)+5)
    pm:add_voxel(next_x, next_y,   vx, vy, 0, 0, color, rnd(5)+5)

    local frames = min(self.ticks, self.size/abs(self.dir_x + self.dir_y)/4)
    pm:add_particle(self.origin_x-1, self.origin_y-1, self.dir_x * 4, self.dir_y * 4, 0, 0, color, frames)
    pm:add_particle(self.origin_x-1+self.dir_x, self.origin_y-1+self.dir_y, self.dir_x * 4, self.dir_y * 4, 0, 0, color, frames)

    if (next_x <= 1 or next_y <= 1 or next_x >= 127 or next_y >= 127) then
      return
    end

    local next_brick = brick_at_pos(next_x, next_y)
    if (next_brick == nil) then
      self.size += 1
    elseif (rnd(1) > 0.95) then
      next_brick:get_component(brick):on_collision(self.go)
      return
    else
      return
    end
  end
end

powerup = gameobject:new{
  kind = 0
}

function powerup:update()
  _check_collision(self.go, paddle_obj)
  if (self.go.rb.vy < 2) then
    self.go.rb.vy += 0.02
  end
  if (self.go.y > 130) then
    destroy(self.go)
  end
end

function powerup:on_collision()
  sfx(1)
  if (self.kind == 0 or self.kind == 1) then
    -- safety bricks. 0 = blue, 1 = green
    local safety_sprite = self.kind == 0 and 4 or 6
    add(actions, cocreate(function()
      for x=1,num_bricks_x do
        local existing = static_bricks[x][num_bricks_y]
        local brick_comp = nil
        if (existing ~= nil) then
          brick_comp = existing:get_component(brick)
          if (brick_comp.health < 3) then
            brick_comp.health += 1
          end
          existing.renderer.sprite = safety_sprite + 16 * (3 - brick_comp.health)
        else
          local new = load_brick(x, num_bricks_y, safety_sprite)
          brick_comp = new:get_component(brick)
          brick_comp.health = 1
          new.renderer.sprite += 32
        end
        sfx(0, -1, 15+x, 1)
        brick_comp:hit_particles(brick_comp.go.x, brick_comp.go.y)
        yield()
        yield()
        yield()
      end
    end))
  elseif (self.kind == 2) then
    -- paddle glue
    paddle_obj:get_component(paddle):activate_glue()
  else
    -- bigger paddle
    paddle_obj:get_component(paddle):widen()
  end
  local r = self.go.renderer
  sprite_particles(r.sx, r.sy, r.sw, r.sh, self.go.x, self.go.y-2, 0)
  destroy(self.go)
end

particle_manager = gameobject:new({
  particles = {},
  index = 1,
  max_particles = 1000
})

function particle_manager:start()
  for i=1,self.max_particles do
    self.particles[i] = {
      x = -1,
      y = -1,
      vx = 0,
      vy = 0,
      ax = 0,
      ay = 0,
      frames = 0,
      color = 0,
      shadow = false
    }
  end
end

function particle_manager:update()
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

function particle_manager:draw()
  for p in all(self.particles) do
    if (p.frames > 0) then
      pset(p.x, p.y, p.color)
      if (p.shadow) then
        pset(p.x, p.y + 1, gradients[p.color])
      end
    end
  end
end

function particle_manager:add_particle(x, y, vx, vy, ax, ay, color, frames, layer, shadow)
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
  p.shadow = shadow

end

function particle_manager:add_voxel(x, y, vx, vy, ax, ay, color, frames, layer)
  self:add_particle(x, y, vx, vy, ax, ay, color, frames, layer, true)
end

paddle = gameobject:new({
  glued_balls = {}, -- each entry has obj and dx
  glue = false, -- glue powerup active
  sides = 0, -- size of side paddle extentions
  target_sides = 0, -- size of side paddle extentions
  animation = 'rest',
  animation_ticks = 0,
  animation_x = {
    rest = 56,
    left = 52,
    right = 48,
    left_boost = 39,
    right_boost = 35,
    surprise = 43
  }
})

function paddle:reset()
  self.go.x = 64
  self.target_sides = 0
  self.glue = false
  self.glued_balls = {}
end

function paddle:update()
  if (game_mode ~= 1) then
    return
  end

  -- left/right movement
  local boost = btn(4) and 2 or 1
  if (btn(0)) then
    self.go.rb.vx = -pad_speed * boost
  elseif (btn(1)) then
    self.go.rb.vx = pad_speed * boost
  else
    self.go.rb.vx *= 0.7
  end

  -- size changes
  if (self.target_sides ~= self.sides) then
    self.animation_ticks += 2
    self.sides += sgn(self.target_sides - self.sides)
    self.go.col.width = 20 + 2 * self.sides
  end

  -- border detection
  if (self.go.x <= self.go.col.width / 2 + 1) then
    self.go.x = self.go.col.width / 2 + 1
    for ball_ref in all(self.glued_balls) do
      if (btn(0)) then
        ball_ref.dx -= 1
      end
      if (ball_ref.dx < -(self.go.col.width - ball_ref.obj.col.width)/ 2) then
        ball_ref.dx = -(self.go.col.width - ball_ref.obj.col.width) / 2
      end
    end
  elseif (self.go.x >= 127 - self.go.col.width / 2) then
    for ball_ref in all(self.glued_balls) do
      if (btn(1)) then
        ball_ref.dx += 1
      end
      if (ball_ref.dx > (self.go.col.width - ball_ref.obj.col.width)/ 2) then
        ball_ref.dx = (self.go.col.width - ball_ref.obj.col.width) / 2
      end
    end
    self.go.x = 127 - self.go.col.width / 2
  end

  -- move / release glued balls
  for ball_ref in all(self.glued_balls) do
    ball_ref.obj.x = self.go.x + ball_ref.dx
    ball_ref.obj.y = flr(self.go.y - self.go.col.height / 2 - ball_ref.obj.col.height / 2)
    if (btn(5)) then
      ball_ref.obj.x += rnd(1) - 0.5
      ball_ref.obj.rb.vy = ball_speed
      local b = ball_ref.obj:get_component(ball)
      b.paddle_flag = true
      b.glued = false
      b:on_collision(self.go)
    end
  end
  if (btn(5)) then
    self.glued_balls = {}
  end

  -- wind particles
  if (abs(self.go.rb.vx) > 1) then
    for i = 1, btn(4) and 2 or 1 do
      pm:add_particle(self.go.x, self.go.y + (rnd(1) > 0.5 and 1 or -2), 
        self.go.rb.vx * 0.25, 0, 0, 0, 8 + flr(rnd(2)), 12+rnd(5), 2)
    end
  end
  bgp:near_particle(self.go, self.go.rb.vx, 0)

  -- animation
  if (self.animation_ticks > 0) then
    self.animation = 'surprise'
    self.animation_ticks -= 1
  else
    if (btn(0)) then
      self.animation = 'left' .. (btn(4) and '_boost' or '')
    elseif (btn(1)) then
      self.animation = 'right' .. (btn(4) and '_boost' or '')
    else
      self.animation = 'rest'
    end
  end

end

function paddle:draw()
  if (game_mode ~= 1) then
    return
  end

  local sx = self.glue and 76 or 96
  local base_width = 20
  local surprise = self.animation == 'surprise' and 1 or 0
  sspr(sx, self.animation_x[self.animation], base_width, 4 + surprise, self.go.x - base_width / 2, self.go.y - 2 - surprise)

  if (self.sides > 0) then
    sspr(sx, 60, 1, 4, self.go.x - base_width / 2 - self.sides, self.go.y - 2)
    sspr(sx, 60, 1, 4, self.go.x + base_width / 2 + self.sides - 1, self.go.y - 2)
    for i=0,self.sides do
      sspr(sx+1, 60, 1, 4, self.go.x - base_width / 2 - (self.sides - 1), self.go.y - 2, self.sides - 1, 4)
      sspr(sx+1, 60, 1, 4, self.go.x + base_width / 2, self.go.y - 2, self.sides - 1, 4)
    end
  end
end

function paddle:activate_glue()
  if (not self.glue) then
    self.glue = true
    sprite_particles(76, 56, 20, 4, self.go.x, self.go.y, 2)
  end
end

function paddle:widen()
  self.target_sides = min(128 - 20, self.target_sides + 5)
end

function paddle:glue_ball(ball_obj)
  local dx = ball_obj.x - paddle_obj.x
  ball_obj.rb.vx = 0
  ball_obj.rb.vy = 0
  ball_obj:get_component(ball).glued = true
  add(self.glued_balls, {obj=ball_obj, dx=dx})
end

function make_ball(x, y, glued)
  lm.num_balls += 1
  local ball_obj = gameobject:new{x=x, y=y, layer=3}
  ball_obj:add_component(ball:new())
  ball_obj:add_component(rectcollider:new{width=2, height=2})
  local vx, vy = angle_vector(rnd(90) - 45, ball_speed)
  ball_obj:add_component(rigidbody:new{vx=vx, vy=vy})
  if (glued) then
    ball_obj.x = paddle_obj.x
    paddle_obj:get_component(paddle):glue_ball(ball_obj)
  end
  return instantiate(ball_obj)
  --ball_obj:add_component(rigidbody:new{vx=0, vy=-0})
end

background_particles = gameobject:new({
  particles={}
})

function background_particles:start()
  self.particles = {}
  for j=0, 7 do
    for i=0, 7 do
      --add(self.particles, {})
      add(self.particles, {{
        base_x=i*16,
        base_y=j*16,
        x=rnd(16),
        y=rnd(16),
        vx=0,
        vy=0,
        c=13
      }})
    end
  end
end

function background_particles:update()
  for layer in all(self.particles) do
    for p in all(layer) do
      p.x = max(min(15, p.x + p.vx), 0)
      p.y = max(min(15, p.y + p.vy), 0)
      p.vx *= 0.95
      p.vy *= 0.95
    end
  end
end

function background_particles:draw()
  if (game_mode ~= 1) then
    return
  end

  for layer in all(self.particles) do
    for p in all(layer) do
      pset(p.base_x + p.x, p.base_y + p.y, p.c)
    end
  end
end

function background_particles:near_particle(go, vx, vy)
  local layer = self.particles[-flr(-go.x/16) + flr(go.y/16)*8]
  if (layer ~= nil) then
    for p in all(layer) do
      p.vx += vx/50 * (rnd(0.5) + 0.5)
      p.vy += vy/50 * (rnd(0.5) + 0.5)
    end
  end
end

function background_particles:add_debris(x, y, c, vx, vy)
  local i, j = flr(x/16), flr(y/16)
  local layer = self.particles[i+1 + j*8]
  add(layer, {
    base_x= i*16,
    base_y= j*16,
    x=x-i*16,
    y=y-j*16,
    vx=vx,
    vy=vy,
    c=c
  })
end

main_menu = gameobject:new{
  index = 0,
  has_save = true
}

function main_menu:start()
  cartdata("maxbize_superbreakout_1")
  if (dget(0) <= 1) then
    self.has_save = false
    self.index = 1
  else

  end
end

function main_menu:update()
  pm:add_voxel(22,  58,  2, 0, 0, 0, flr(rnd(3)+8), 22, 1)
  pm:add_voxel(106, 58, -2, 0, 0, 0, flr(rnd(3)+8), 21, 1)

  if (btnp(2)) then
    sfx(0, 1, 4, 1)
    self.index -= 1
    if (self.index == (self.has_save and -1 or 0)) then
      self.index = 2
    end
  elseif (btnp(3)) then
    sfx(0, 1, 4, 1)
    self.index += 1
    if (self.index == 3) then
      self.index = self.has_save and 0 or 1
    end
  end

  if (btnp(4) or btnp(5)) then
    if (self.index < 2) then
      if (self.index == 0) then
        level = dget(0)
      end
      init_level(levels[level])
      start_time = time() - (level > 1 and dget(1) or 0)
      num_resets = num_resets + (level > 1 and (dget(2) + 1) or 0)
      pm:start()
      destroy(self.go)
    else
      init_level_editor()
      pm:start()
      destroy(self.go)
    end
  end
end

function print_shadowed(text, x, y, color)
  print(text, x, y+1, gradients[gradients[color]])
  print(text, x, y, color)
end

function main_menu:draw()
  rectfill(0, 0, 128, 128, 1)
  rectfill(0, 73, 128, 99, 12)

  sspr(32, 64, 80, 32, 24, 24)
  spr(95, 40, 74 + self.index * 8)
  print_shadowed("continue",  48, 76, self.has_save and 7 or 13)
  print_shadowed("new game",  48, 84, 7)
  print_shadowed("editor",    48, 92, 7)
  print_shadowed("@ maxbize", 44, 118, 7)
  print_shadowed("v1.0", 108, 118, 12)
end

confirmation_box = gameobject:new{
  button = -2, -- button = -1 means permanent box
  ticks = 0,
  text = "",
  callback = nil
}

function confirmation_box:update()
  if (not btn(self.button) and self.button ~= -1) then
    self.ticks = 0
    self.button = -2
  end
  if (self.ticks > 0) then
    self.ticks -= 1
    if (self.ticks == 0) then
      self.callback()
    end
  end
end

function confirmation_box:draw()
  if (self.ticks > 0 or self.button == -1) then
    local height = self.button == -1 and 7 or 0
    rectfill(32, 20, 95, 35 + height, 12)
    rectfill(33, 21, 94, 34 + height, 6)
    if (self.button ~= -1) then
      rectfill(35, 30, 35 + self.ticks, 32, 9)
    end
    print(self.text, 35, 23, 1)
  end
end

function confirmation_box:start_action(button, callback, text)
  if (self.button ~= button) then
    self.ticks = 60
    self.button = button
    self.callback = callback
    self.text = text
  end
end

function confirmation_box:interrupt_action()
  self.ticks = 0
end

function set_music(track)
  if (current_music ~= track) then
    music(track)
    current_music = track
  end
end

function init_level_editor()
  game_mode = 2
  set_music(60)
  load_level_compressed(level_buffer or "a350")
end

function init_level(level_str)
  game_mode = 1
  set_music(0)
  reset_bgp()
  paddle_obj:get_component(paddle):reset()
  load_level_compressed(level_str)
  make_ball(0, 0, true)
end

function reset_bgp()
  if (bgp ~= nil) then
    destroy(bgp.go)
  end
  local bgp_obj = gameobject:new{layer=1}
  bgp = bgp_obj:add_component(background_particles:new())
  instantiate(bgp_obj)
end

paddle_obj = nil -- global variable hack!
bgp = nil -- global variable hack!
pm = nil -- global variable hack!
le = nil -- global variable hack!
lm = nil -- global variable hack!
cb = nil -- global variable hack!
function _init()
  set_music(58)

  local cb_obj = gameobject:new{layer=4}
  cb = cb_obj:add_component(confirmation_box:new())
  instantiate(cb_obj)

  local pm_obj = gameobject:new{layer=3}
  pm = pm_obj:add_component(particle_manager:new())
  instantiate(pm_obj)

  mm = gameobject:new{layer=1}
  mm:add_component(main_menu)
  instantiate(mm)

  paddle_obj = gameobject:new{x=64, y=115, layer=4}
  paddle_obj:add_component(rectcollider:new{width=20, height=3})
  paddle_obj:add_component(paddle:new())
  paddle_obj:add_component(rigidbody:new())
  instantiate(paddle_obj)

  lm_obj = gameobject:new()
  lm = lm_obj:add_component(level_manager)
  instantiate(lm_obj)

  poke(0x5f2d, 1) -- enable mouse
  le = gameobject:new{layer=3}
  le:add_component(level_editor:new())
  instantiate(le)

end
