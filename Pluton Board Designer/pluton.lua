------------------
-- Global State
------------------

-- Clip offsets due to us using a 64x64 centered portion of the screen
local clip_offset_x = (160-64)/2
local clip_offset_y = (90-64)/2

-- TODO: Which color to drop for alpha? For now, dropped 0x2e222f
local palette = {0x000000,0x3e3546,0x625565,0x966c6c,0xab947a,0x694f62,0x7f708a,0x9babb2,0xc7dcd0,0xffffff,0x6e2727,0xb33831,0xea4f36,0xf57d4a,0xae2334,0xe83b3b,0xfb6b1d,0xf79617,0xf9c22b,0x7a3045,0x9e4539,0xcd683d,0xe6904e,0xfbb954,0x4c3e24,0x676633,0xa2a947,0xd5e04b,0xfbff86,0x165a4c,0x239063,0x1ebc73,0x91db69,0xcddf6c,0x313638,0x374e4a,0x547e64,0x92a984,0xb2ba90,0x0b5e65,0x0b8a8f,0x0eaf9b,0x30e1b9,0x8ff8e2,0x323353,0x484a77,0x4d65b4,0x4d9be6,0x8fd3ff,0x45293f,0x6b3e75,0x905ea9,0xa884f3,0xeaaded,0x753c54,0xa24b6f,0xcf657f,0xed8099,0x831c5d,0xc32454,0xf04f78,0xf68181,0xfca790,0xfdcbb0}
local game_modes = {menu=0, editor=1, designer=2, simulator=3}
local game_mode = game_modes.editor


local map_traces = nil -- 32x32 boolean for trace locations

------------------
-- Built-in Methods
------------------

function _init()
  setup_palette()
  setup_camera()

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
end

--------------------------
-- Initialization
--------------------------

function setup_palette()
  -- Load Resurrect-64 palette
  for i,c in ipairs(palette) do
    poke4(0x5000 + 4 * (i-1), c)
  end
  send_palette()
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

--------------------------
-- (Level) Editor
--------------------------

-- Proposed trace
local trace_start_x = nil
local trace_start_y = nil

function editor_init(level)
  -- TODO: load map traces from a stored level definition
  map_traces = {}
  for x = 1, 32 do
    add(map_traces, {})
    for y = 1, 32 do
      add(map_traces[x], false)
    end
  end
end

function editor_update()
  local mouse_x, mouse_y, mouse_b = mouse_corrected(true)
  -- Start a new trace
  if mouse_b & 0x1 > 0 and trace_start_x == nil then
    local grid_x = flr(mouse_x/2) + 1
    local grid_y = flr(mouse_y/2) + 1
    if mid(1, grid_x, 32) == grid_x and mid(1, grid_y, 32) == grid_y then
      trace_start_x = grid_x
      trace_start_y = grid_y
    end
  
  -- Commit the current proposed trace
  elseif mouse_b & 0x1 == 0 and trace_start_x ~= nil then
    local trace_positions = get_projected_trace(mouse_x, mouse_y)
    for i = 1, validate_projected_trace(trace_positions) do
      map_traces[trace_positions[i].x][trace_positions[i].y] = true
    end

    trace_start_x = nil
    trace_start_y = nil
  end
end

function editor_draw()
  local mouse_x, mouse_y = mouse_corrected(true)

  -- Render set traces
  for x = 1, 32 do
    for y = 1, 32 do
      if map_traces[x][y] then
        draw_trace_piece(x, y)
      end
    end
  end

  -- Render proposed trace
  if trace_start_x ~= nil then
    local trace_positions = get_projected_trace(mouse_x, mouse_y)
    local last_valid_pos = validate_projected_trace(trace_positions)
    for i = 1, count(trace_positions) do
      draw_trace_piece(trace_positions[i].x, trace_positions[i].y, i > last_valid_pos and 6 or 9)
      -- checkerboard pattern
      if i == last_valid_pos then
        fillp(0b10101010,
              0b01010101,
              0b10101010,
              0b01010101,
              0b10101010,
              0b01010101,
              0b10101010,
              0b01010101)
        poke(0x550b,0x3f)
        palt(0, true)
      end
    end
    fillp()
    palt()
  end

  -- Render cursor
  rectfill(mouse_x, mouse_y, mouse_x + 1, mouse_y + 1, 15)
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
-- - TODO: Does not cross parts
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
      return i-1
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
  if mid(1, grid_x, 31) ~= grid_x or mid(1, grid_y, 31) ~= grid_y then
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

