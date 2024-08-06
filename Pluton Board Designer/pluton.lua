------------------
-- Global State
------------------

-- Definitions:
-- - Grid: 32x32 grid composed of 2x2 cells on the 64x64 playfield
-- - Cell: A 2x2 chunk that's grid-aligned

-- Clip offsets due to us using a 64x64 centered portion of the screen
local clip_offset_x = (160-64)/2
local clip_offset_y = (90-64)/2

-- TODO: Which color to drop for alpha? For now, dropped 0x2e222f
local palette = {0x000000,0x3e3546,0x625565,0x966c6c,0xab947a,0x694f62,0x7f708a,0x9babb2,0xc7dcd0,0xffffff,0x6e2727,0xb33831,0xea4f36,0xf57d4a,0xae2334,0xe83b3b,0xfb6b1d,0xf79617,0xf9c22b,0x7a3045,0x9e4539,0xcd683d,0xe6904e,0xfbb954,0x4c3e24,0x676633,0xa2a947,0xd5e04b,0xfbff86,0x165a4c,0x239063,0x1ebc73,0x91db69,0xcddf6c,0x313638,0x374e4a,0x547e64,0x92a984,0xb2ba90,0x0b5e65,0x0b8a8f,0x0eaf9b,0x30e1b9,0x8ff8e2,0x323353,0x484a77,0x4d65b4,0x4d9be6,0x8fd3ff,0x45293f,0x6b3e75,0x905ea9,0xa884f3,0xeaaded,0x753c54,0xa24b6f,0xcf657f,0xed8099,0x831c5d,0xc32454,0xf04f78,0xf68181,0xfca790,0xfdcbb0}
local game_modes = {menu=0, editor=1, designer=2, simulator=3}
local game_mode = game_modes.editor

local map_traces = nil -- 32x32 boolean for trace locations
local map_parts = nil -- Flat array of parts

-- Notes:
-- - Runtime information to be stored separately
-- - width, height, port_offsets are in grid-space
-- - traces are their own thing and not in parts
-- - anchor: the top-left corner of the ground plane of the sprite. Offset is in pixels, but points to the top-left pixel in grid-space
-- - port offsets are relative to the anchor
local part_definitions = {
  source = {
    name = 'SOURCE',
    sprite = 1,
    width = 5,
    height = 5,
    anchor_x = 3,
    anchor_y = 6,
    port_offsets = {
      {x = 0, y= 2},
      {x = 4, y= 2},
      {x = 2, y= 4},
    }
  }
}

------------------
-- Built-in Methods
------------------

function _init()
  setup_palette()
  setup_camera()

  -- Load PICO-8 font
  poke(0x4000, get(fetch("/system/fonts/p8.font")))

  if game_mode == game_modes.editor then
    editor_init()
  end

end

function _update()
  if game_mode == game_modes.editor then
    editor_update()
  end
end

function _draw()
  -- Clarify draw area
  cls(0)
  rectfill(0,0,63,63,1)

  if game_mode == game_modes.editor then
    editor_draw()
  end

  -- Debug draws
  print(flr(stat(1)*100)..'%', 1, 1, 2) -- CPU

end

--------------------------
-- Initialization
--------------------------

function setup_palette()
  -- Load Resurrect-64 palette
  for i,c in ipairs(palette) do
    poke4(0x5000 + 4 * (i-1), c)
  end

  -- Copy palette to gfx and map editors
  send_palette()

  -- Enable transparency for fillp with drawing functions
  poke(0x550b,0x3f)
end

function setup_camera()
  -- Sets resolution to 160x90
  vid(4)
  -- Remap (0,0) from top-left of screen to top-left of 64x64 centered rect
  camera(-clip_offset_x, -clip_offset_y)
  -- Clip to 64x64 centered rect to avoid drawing OOB
  clip(clip_offset_x,clip_offset_y,64,64)
end

-- Thanks for OkPal drakmaniso!
function send_palette()
  -- Convert palette to userdata
  local palette_data = userdata("i32", 64)
  for c = 0, 63 do
    palette_data:set(c, palette[c+1])
  end

  -- Find the pids of gfx and map and send the palette
  local processes = fetch("/ram/system/processes.pod")
  for i = 1, count(processes) do
    if processes[i].name == "gfx" then
      send_message(processes[i].id, { event = "set_palette", palette = palette_data })
    elseif processes[i].name == "map" then
      send_message(processes[i].id, { event = "set_palette", palette = palette_data })
    end
  end
end

--------------------------
-- Utility Methods
--------------------------

-- Returns mouse() with 0,0 as the top-left of the 64x64 square
function mouse_corrected(grid_aligned)
  local mouse_x, mouse_y, mouse_b = mouse()

  mouse_x -= clip_offset_x
  mouse_y -= clip_offset_y

  -- Align cursor to 2x2 grid (only needed for)
  if (grid_aligned) then
    mouse_x = flr(mouse_x/2)*2
    mouse_y = flr(mouse_y/2)*2
  end

  return mouse_x, mouse_y, mouse_b
end

-- Checks if x and y are within 1, bound
function in_bounds(x, y, bound)
  return mid(1, x, bound) == x and mid(1, y, bound) == y
end

function fillp_checkerboard()
  fillp(0b10101010,
        0b01010101,
        0b10101010,
        0b01010101,
        0b10101010,
        0b01010101,
        0b10101010,
        0b01010101)
end

-- Converts an array of trace positions to a map[x][y]
-- TODO: Could be more generic if needed for other purposes
function trace_arry_to_map(arr)


  -- Create the empty map
  local map = {}
  for x = 1, 32 do
    add(map, {})
    for y = 1, 32 do
      add(map[x], false)
    end
  end

  -- Override the defaults with array items
  for item in all(arr) do
    if in_bounds(item.x, item.y, 32) then
      map[item.x][item.y] = true
    end
  end

  return map
end

-- Helper method to enforce consistency on map part schema
function new_map_part(grid_x, grid_y, definition)
  return {
    def=definition,
    x=grid_x,
    y=grid_y
  }
end

-- Convert from 32x32 grid space to 64x64 pixel space
function grid_to_px(grid_x, grid_y)
  return (grid_x - 1) * 2, (grid_y - 1) * 2
end

-- Only searches parts, not traces/etc!
-- TODO: store 32x32 grid with references back to parts *if* too slow
function get_part_at(grid_x, grid_y)
  for i, part in ipairs(map_parts) do
    if    mid(part.x, grid_x, part.x + part.def.width - 1) == grid_x
      and mid(part.y, grid_y, part.y + part.def.height - 1) == grid_y
    then
      return i, part
    end
  end
  return 0, nil
end

--------------------------
-- (Level) Editor
--------------------------

local editor_brushes = {trace='TRACE', source='SOURCE'}
local editor_brush = editor_brushes.trace

-- Trace editing
local trace_start_x = 0
local trace_start_y = 0
local trace_actions = {none=0, add=1, del=2}
local trace_action = trace_actions.none




function editor_init(level)
  -- TODO: load map info from a stored level definition
  map_traces = {}
  for x = 1, 32 do
    add(map_traces, {})
    for y = 1, 32 do
      add(map_traces[x], false)
    end
  end

  map_parts = {}
end

function editor_update()
  local mouse_x, mouse_y, mouse_b = mouse_corrected(true)
  local grid_x = flr(mouse_x/2) + 1
  local grid_y = flr(mouse_y/2) + 1
  local grid_in_bounds = in_bounds(grid_x, grid_y, 32)
  local left_click = mouse_b & 0x1 > 0
  local right_click = mouse_b & 0x2 > 0

  -------------
  -- Brush selection
  -------------
  -- Switch brush
  if keyp('1') then editor_brush = editor_brushes.trace end
  if keyp('2') then editor_brush = editor_brushes.source end


  -------------
  -- Trace brush
  -------------
  if editor_brush == editor_brushes.trace then
    if trace_action == trace_actions.none then
      -- Start a new trace
      if grid_in_bounds and (left_click or right_click) then
        trace_start_x = grid_x
        trace_start_y = grid_y
        trace_action = left_click and trace_actions.add or trace_actions.del
      end
    elseif trace_action == trace_actions.add then
      -- Commit the current proposed trace addition
      if not left_click then
        trace_action = trace_actions.none
        local trace_positions = get_projected_trace(mouse_x, mouse_y)
        for i = 1, validate_projected_trace(trace_positions) do
          map_traces[trace_positions[i].x][trace_positions[i].y] = true
        end
      end
    elseif trace_action == trace_actions.del then
      -- Commit the current proposed trace deletion
      if not right_click then
        trace_action = trace_actions.none
        local trace_positions = get_projected_trace(mouse_x, mouse_y)
        for i = 1, count(trace_positions) do
          if in_bounds(trace_positions[i].x, trace_positions[i].y, 32) then
            map_traces[trace_positions[i].x][trace_positions[i].y] = false
          end
        end
      end
    end

  -------------
  -- Source brush
  -------------
  elseif editor_brush == editor_brushes.source then
    -- Add source
    if left_click then
      -- Shift grid_x, grid_y to center of new source instead of top-left corner
      local center_x = grid_x - flr(part_definitions.source.width/2)
      local center_y = grid_y - flr(part_definitions.source.height/2)

      add_source(center_x, center_y)
    -- Delete source
    elseif right_click then
      delete_source(grid_x, grid_y)
    end
  end
end

function editor_draw()
  local mouse_x, mouse_y = mouse_corrected(true)
  local trace_positions = get_projected_trace(mouse_x, mouse_y)
  local last_valid_pos = validate_projected_trace(trace_positions)
  local trace_map = trace_arry_to_map(trace_positions)

  -- Render set traces, minus proposed deletions
  for x = 1, 32 do
    for y = 1, 32 do
      if map_traces[x][y] and (trace_action ~= trace_actions.del or not trace_map[x][y]) then
        draw_trace_piece(x, y)
      end
    end
  end

  -- Render proposed trace addition
  if trace_action == trace_actions.add then
    for i, trace_pos in ipairs(trace_positions) do
      draw_trace_piece(trace_pos.x, trace_pos.y, i > last_valid_pos and 6 or 9)
      if i == last_valid_pos then
        --fillp_checkerboard() Doesn't look great
        palt(0, true)
      end
    end
    fillp()
    palt()
  end

  -- Render parts
  for part in all(map_parts) do
    local draw_x, draw_y = grid_to_px(part.x, part.y)
    spr(part.def.sprite, draw_x - part.def.anchor_x, draw_y - part.def.anchor_y)
  end

  -- Current brush
  print(editor_brush, 64 - #editor_brush*4, 1, 3)

  -- Render cursor
  rectfill(mouse_x, mouse_y, mouse_x + 1, mouse_y + 1, 15)
end

function add_source(grid_x, grid_y)

  -- Create a candidate part (not stored yet)
  local source = new_map_part(grid_x, grid_y, part_definitions.source)

  -- Check if source can be added at this location
  for check_x = grid_x, grid_x + source.def.width - 1 do
    for check_y = grid_y, grid_y + source.def.height - 1 do
      -- Check overlaps an existing part
      if get_part_at(check_x, check_y) > 0 then
        return
      end

      -- Check overlaps out of bounds
      if not in_bounds(check_x, check_y, 32) then
        return
      end
    end
  end

  -- Delete any overlapping traces
  -- Note: We _could_ block part creation, but this might be less annoying as a user
  for check_x = grid_x, grid_x + source.def.width - 1 do
    for check_y = grid_y, grid_y + source.def.height - 1 do
      map_traces[check_x][check_y] = false
    end
  end

  -- Store it
  add(map_parts, source)

  -- Debugging: add ports to traces for validation
  --for port_offset in all(source.def.port_offsets) do
  --  map_traces[source.x + port_offset.x][source.y + port_offset.y] = true
  --end
end

function delete_source(grid_x, grid_y)
  local i, part = get_part_at(grid_x, grid_y)
  if i > 0 and part.def == part_definitions.source then
    deli(map_parts, i)
  end
end

-- Returns an array of (x,y) tuples of projected/snapped trace positions
-- mouse_x, mouse_y assumed to be 2x2 grid-snapped
function get_projected_trace(mouse_x, mouse_y)
  local trace_positions = {}

  trace_end_x, trace_end_y = get_snapped_trace_end(mouse_x, mouse_y)
  local dist = abs(trace_end_x - trace_start_x) + abs(trace_end_y - trace_start_y)
  local dx = trace_end_x == trace_start_x and 0 or sgn(trace_end_x - trace_start_x)
  local dy = trace_end_y == trace_start_y and 0 or sgn(trace_end_y - trace_start_y)
  for i = 0, dist do
    add(trace_positions, {x=trace_start_x + dx * i, y=trace_start_y + dy * i})
  end

  return trace_positions
end

-- Returns the index of the last valid trace piece, or 0 if the start is invalid.
-- Validations:
-- - No squares in the traces (i.e. solid 2x2)
function validate_projected_trace(trace_positions)
  for i = 1, count(trace_positions) do
    local trace_x = trace_positions[i].x
    local trace_y = trace_positions[i].y

    -- Check for squares
    if   check_trace_square(trace_x-1, trace_y-1, trace_positions, i)
      or check_trace_square(trace_x-1, trace_y  , trace_positions, i)
      or check_trace_square(trace_x  , trace_y-1, trace_positions, i)
      or check_trace_square(trace_x  , trace_y  , trace_positions, i)
    then
      return i - 1
    end

    -- Check in bounds
    if not in_bounds(trace_x, trace_y, 32) then
      return i - 1
    end

    -- Check for parts
    if get_part_at(trace_x, trace_y) > 0 then
      return i - 1
    end

  end

  -- Entire projected path is valid
  return count(trace_positions)
end

-- For a given 32x32 grid (x,y), check if adding trace_position[trace_i] will create a square
-- (x,y) is the top-left corner of the square
-- Returns true/false
function check_trace_square(grid_x, grid_y, trace_positions, trace_i)
  -- If either grid position is out of bounds then a square is impossible
  -- Note the use of 31 - the whole square has to be within the grid
  if not in_bounds(grid_x, grid_y, 31) then
    return false
  end

  -- Check if any spot in the square is open
  for dx = 0, 1 do
    for dy = 0, 1 do
      local check_x = grid_x + dx
      local check_y = grid_y + dy

      local in_trace_map = map_traces[check_x][check_y]
      local in_trace_pos = trace_positions[trace_i].x == check_x and trace_positions[trace_i].y == check_y
      local in_prev_trace_pos = trace_i > 1 and trace_positions[trace_i-1].x == check_x and trace_positions[trace_i-1].y == check_y

      -- Open spot - not committed or proposed
      if not in_trace_map and not in_trace_pos and not in_prev_trace_pos then
        return false
      end
    end
  end

  -- Adding a trace piece here will create a square
  return true
end

-- grid_x, grid_y assumed to be 32x32 grid
function draw_trace_piece(grid_x, grid_y, c)
  c = c or 9
  local draw_x = (grid_x - 1) * 2
  local draw_y = (grid_y - 1) * 2
  rectfill(draw_x, draw_y, draw_x + 1, draw_y + 1, c)
end

-- mouse_x, mouse_y assumed to be 2x2 grid-snapped
function get_snapped_trace_end(mouse_x, mouse_y)
  -- Get end of trace from mouse
  local trace_end_x = flr(mouse_x/2) + 1
  local trace_end_y = flr(mouse_y/2) + 1

  -- Correct trace end with snapping
  local dist_if_x_snapped = abs(trace_end_y - trace_start_y)
  local dist_if_y_snapped = abs(trace_end_x - trace_start_x)
  if dist_if_x_snapped > dist_if_y_snapped then
    trace_end_x = trace_start_x
  else
    trace_end_y = trace_start_y
  end

  return trace_end_x, trace_end_y
end


--------------------------
-- Simulation
--------------------------






