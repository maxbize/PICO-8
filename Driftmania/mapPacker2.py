'''
Given a Tiled map of individual tiles, generate a map string with tiles arranged into n*n chunks

TODO: So much code cleanup ;)
'''

import codecs
import glob
import math
import re
import sys
import xml.etree.ElementTree as ET

# Using pico-8 extended charset for data requires the terminal to support utf-8
sys.stdout.reconfigure(encoding='utf-8')

# https://gist.githubusercontent.com/joelsgp/bf930961230731fe370e5c25ba05c5d3/raw/d837ae7bff7b5b6375f684dc69b6e9195f02e78a/p8scii.json
# https://www.lexaloffle.com/bbs/?tid=38692
p8scii = ["\\0", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "\\t", "\\n", "ᵇ", "ᶜ", "\\r", "ᵉ", "ᶠ", "▮", "■", "□", "⁙", "⁘", "‖", "◀", "▶", "「", "」", "¥", "•", "、", "。", "゛", "゜", " ", "!", "\\\"", "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?", "@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", "\\\\", "]", "^", "_", "`", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{", "|", "}", "~", "○", "█", "▒", "🐱", "⬇️", "░", "✽", "●", "♥", "☉", "웃", "⌂", "⬅️", "😐", "♪", "🅾️", "◆", "…", "➡️", "★", "⧗", "⬆️", "ˇ", "∧", "❎", "▤", "▥", "あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", "も", "や", "ゆ", "よ", "ら", "り", "る", "れ", "ろ", "わ", "を", "ん", "っ", "ゃ", "ゅ", "ょ", "ア", "イ", "ウ", "エ", "オ", "カ", "キ", "ク", "ケ", "コ", "サ", "シ", "ス", "セ", "ソ", "タ", "チ", "ツ", "テ", "ト", "ナ", "ニ", "ヌ", "ネ", "ノ", "ハ", "ヒ", "フ", "ヘ", "ホ", "マ", "ミ", "ム", "メ", "モ", "ヤ", "ユ", "ヨ", "ラ", "リ", "ル", "レ", "ロ", "ワ", "ヲ", "ン", "ッ", "ャ", "ュ", "ョ", "◜", "◝"]

# Chunk state is global so that chunks are shared across maps
chunks = {'Road': {}, 'Props': {}, 'Decals': {}} # string of index,index,.. -> chunk index
chunk_counts = {} # Helps keep track if there's some chunks that have low use and should be altered
# Seed the first chunks with solid colors
for name, idx in [('Road', 0), ('Road', 1), ('Road', 26), ('Props', 0), ('Decals', 0), ('Decals', 21), ('Decals', 64)]:
	chunk_size = 3
	chunk = ''.join([f'{idx:003}' for _ in range(chunk_size**2)])
	chunks[name][chunk] = len(chunks[name])
	chunk_counts[chunk] = chunk_counts.get(chunk, 0) + 1

# Get index,index,.. of chunk size n*n starting at x,y
def get_chunk(data, x, y, n):
	chunk = ''
	for i in range(n):
		for j in range(n):
			if y + i < 0 or x + j < 0 or y + i >= len(data) or x + j >= len(data[0]):
				chunk += '000'
			else:
				chunk += f'{data[y + i][x + j]:03}' # Encode number to string to build chunk key
	return chunk

# Write into the __map__ of the .p8 file. Each line is one row of hex indices
def write_map(chunk_layers, n):
	chunks_per_row = math.floor(128 / n) # Map is 128 tiles wide
	num_chunks = sum([len(chunk_layer) for chunk_layer in chunk_layers.values()])
	num_rows = math.ceil(num_chunks / chunks_per_row)
	p8_map = [[0 for _ in range(128)] for row in range(num_rows * n)]
	for i in range(num_chunks):

		# Update the current chunk map
		if i == 0:
			chunks_by_index = {chunk_layers['Road'][k]: k for k in chunk_layers['Road']}
			j = 0
		elif i == len(chunk_layers['Road']):
			chunks_by_index = {chunk_layers['Decals'][k]: k for k in chunk_layers['Decals']}
			j = 0
		elif i == len(chunk_layers['Road']) + len(chunk_layers['Decals']):
			chunks_by_index = {chunk_layers['Props'][k]: k for k in chunk_layers['Props']}
			j = 0

		for x in range(n):
			for y in range(n):
				start_index = (x + y * n) * 3 # 3 chars per int
				val = int(chunks_by_index[j][start_index:start_index+3])
				p8_map[math.floor(i / chunks_per_row) * n + y][(i % chunks_per_row) * n + x] = val

		j += 1



	# Convert top 32 map lines to string
	# Lines 0-31 can get written directly into __map__
	p8_map_str = [f"{''.join([f'{val:0{2}x}' for val in row])}\n" for row in p8_map[:32]]

	# Convert bottom 32 map lines to string
	# Lines 32-63 need to go into the shared space in __gfx__
	# Format for __gfx__:
		# Each token is 2 hex chars: bottom 4 bits _then_ top 4 bits
		# 128 chars per line -> 64 tokens
		# Line 32 -> x=0..63, y=32 on map
		# Line 33 -> x=64..127, y=32 on map
	p8_gfx_str = []
	for row in p8_map[32:]:
		p8_gfx_str.append(f"{''.join([f'{val:0{2}x}'[::-1] for val in row[:64]])}\n")
		p8_gfx_str.append(f"{''.join([f'{val:0{2}x}'[::-1] for val in row[64:]])}\n")

	# Write the __map__ into the .p8 file itself
	with codecs.open(sys.argv[2], 'r', 'utf-8') as f:
		lines = f.readlines()
	for i, line in enumerate(lines):
		if '__map__' in line:
			lines[i+1:i+1+len(p8_map_str)] = p8_map_str
		if '__gfx__' in line:
			lines[i+1+64:i+1+64+len(p8_gfx_str)] = p8_gfx_str
	with codecs.open(sys.argv[2], 'w', 'utf-8') as f:
		f.writelines(lines)

# Rotate bits to get more characters in the non UTF range
def rotate_val(val):
	return int(val, 16) # todo if I run out of chars / compressed space :)

# Compress string from chunks to tokens. Each token encodes chunk index, chunk count
# Note: chr/ord stores 7 bits per character (valid range 16-255), hex stores 4 bits per character
# Note: "flag" refers to a single bit flag specifying if the next value will be an index (0) or count (1)
# Compression levels:
#  0: uncompressed
#  1: 8 bit index, 8 bit count as hex (4 chars per token)
#  2: 7 bit index + 1 bit count flag, 8 bit count as hex (2-4 chars per token). Requires <= 2**7 chunks
#  3: 16 bit index, 8 bit count as unicode (3 chars per token). Requires <= 2**16 chunks
#  4: 8 bit index, 8 bit count as unicode (2 chars per token). Requires <= 2**8 chunks
#  5: 7 bit index + 1 bit count flag, 8 bit count as unicode (1-2 chars per token). Requires <= 2**7 chunks
# TODO: None of the compressions have been tested ;) There's probably bugs
# TODO: If the num_chunks is per layer, and sprites aren't shared between layers, you could use higher compression
def compress_map_str(map_hex, num_chunks, compression_level):
	if compression_level == 0:
		return map_hex
	if ([0, 2**8, 2**7, 2**16, 2**8, 2**7])[compression_level] < num_chunks:
		raise Exception(f'Cannot use compression level {compression_level} - too many chunks ({num_chunks})')
	max_count = 255
	map_str_comp = ""
	i = 0
	val = rotate_val(map_hex[i:i+2])
	count = 0
	total_count = 0
	while i < len(map_hex):
		next_val = rotate_val(map_hex[i:i+2])
		i += 2
		if val == next_val:
			count += 1
		if val != next_val or count == max_count or i >= len(map_hex):
			val_int = val
			# Build out the map string depending on the compression level
			if compression_level == 1:
				exit('no longer supported')
			elif compression_level == 2:
				exit('no longer supported')
			elif compression_level == 3:
				if val_int == 0 and p8scii[count] in [str(c) for c in range(10)]:
					map_str_comp += f'\\000\\000{p8scii[count]}'
				else:
					map_str_comp += f'{p8scii[val_int >> 8]}{p8scii[val_int & 0xff]}{p8scii[count]}'
			elif compression_level == 4:
				if val_int == 0 and p8scii[count] in [str(c) for c in range(10)]:
					map_str_comp += f'\\000{p8scii[count]}'
				else:
					map_str_comp += f'{p8scii[val_int]}{p8scii[count]}'
			elif compression_level == 5:
				if count == 1:
					map_str_comp += f'{p8scii[val_int]}'
				else:
					val_int |= 1<<7 # Flag is 8th bit
					map_str_comp += f'{p8scii[val_int]}{p8scii[count]}'
			val = next_val
			total_count += count
			count = 1 if count < max_count else 0

	#print('>>>>', total_count)
	return map_str_comp

def replace_lua_str(filename, data_type, s):
	modified = False
	filename = filename.split('\\')[-1]
	marker = f'{filename} {data_type}'
	with codecs.open(sys.argv[1], 'r', 'utf-8') as f:
		lines = f.readlines()
	for i, line in enumerate(lines):
		if marker in line:
			new_line = f"  {s} -- {marker}\r\n" # Windows will force \r so make sure to use it in comparison
			if line != new_line:
				lines[i] = new_line
				modified = True
			break
	if modified:
		with codecs.open(sys.argv[1], 'w', 'utf-8') as f:
			f.writelines(lines)

def build_map(filename, data_map, n, pad_x, pad_y):
	for name in data_map:
		if name.lower() == 'markers':
			continue

		layer_chunks = chunks[name]
		data = data_map[name]
		map_hex = ""  # The map tile values. 16 bits per tile
		num_rows = len(data)
		num_cols = len(data[0])

		# Process the map in chunks
		for y in range(math.ceil(num_rows / n)):
			for x in range(math.ceil(num_cols / n)):
				chunk = get_chunk(data, x * n - pad_x, y * n - pad_y, n)
				if chunk not in layer_chunks:
					layer_chunks[chunk] = len(layer_chunks)
				chunk_counts[chunk] = chunk_counts.get(chunk, 0) + 1
				map_hex += f'{layer_chunks[chunk]:0{2}x}' # 0{4} == pad to four digits
		num_chunks = len(layer_chunks)

		# TODO: Re-index chunks by count. Helps to find chunks that are rarely used

		# Compress the string. First byte is index, second byte is count
		#print(f'\n>>{filename} {name}:\n{map_hex}\n')
		map_str_comp = compress_map_str(map_hex, num_chunks, 4)

		#print(f'\n{name} map_data (raw):\n{map_hex}')
		#print(f'\n{name} map_data (compressed):\n{map_str_comp}')
		replace_lua_str(filename, name.lower(), f'"{map_str_comp}",')

	#if n == 6 and pad_x == 0 and pad_y == 0:
	write_map(chunks, n)
	num_chunks = sum([len(chunk_layer) for chunk_layer in chunks.values()])
	num_chunks_per_layer = {k: len(chunks[k]) for k in chunks}
	print()
	print(f'For n = {n}, pad_x = {pad_x}, pad_y = {pad_y}')
	print(f'Map string length (raw): {len(map_hex)}')
	print(f'Map string length (comp): {len(map_str_comp)}')
	print(f'Number of chunks: {num_chunks} - {num_chunks_per_layer}')
	print(f'Chunk space on map: {num_chunks * n * n} (out of {128*32})')
	print()

	return len(map_hex), len(map_str_comp), num_chunks

# Find all sprites in data that are in the sprites list
def find_all_sprites(data, sprites):
	all_sprites = []
	num_rows = len(data)
	num_cols = len(data[0])
	for y in range(num_rows):
		for x in range(num_cols):
			if data[y][x] in sprites:
				all_sprites.append((x, y))
	return all_sprites

# Find any neighboring sprite from the list (8-directional)
def find_neighbor_sprite(data, sprites, x, y):
	for i in range(-1, 2):
		for j in range(-1, 2):
			if i == 0 and j == 0:
				continue
			if data[y + j][x + i] in sprites:
				return x + i, y + j

# Starting from x, y, walk by +/- delta_x/y until you hit a sprite in sprites
# Includes borders in the response (DON'T HAVE CHECKPOINT ON THE OTHER SIDE OF A SINGLE WALL!)
def walk_line(data, sprites, x, y, delta_x, delta_y):
	line = []

	# Find a border
	while data[y][x] not in sprites:
		x -= delta_x
		y -= delta_y

	# Add the border
	line.append((x, y))
	x += delta_x
	y += delta_y

	# Walk back to the other side
	while data[y][x] not in sprites:
		line.append((x, y))
		x += delta_x
		y += delta_y

	# Add the border and return
	line.append((x, y))
	return line

# Given a line (list of (x,y) tuples) generate the line properties x, y, dx, dy, l
def get_line_props(line, props_data):
	# Get the gfx definition
	with codecs.open(sys.argv[2], 'r', 'utf-8') as f:
		p8_lines = f.readlines()
	start = 0
	end = 0
	for i, p8_line in enumerate(p8_lines):
		if '__gfx__' in p8_line:
			start = i+1
		if '__label__' in p8_line:
			end = i
	gfx_lines = p8_lines[start:end]

	# gfx lookups equivalent to sget(y, x)
	gfx = [[int(c, 16) for c in gfx_line[:-1]] for gfx_line in gfx_lines]

	# Get dx/dy (direction is sprite 0 -> sprite n)
	p1 = line[0]
	p2 = line[1]
	dx = p2[0] - p1[0]
	dy = p2[1] - p1[1]

	# Walk backwards from sprite 1 -> sprite 0 and find starting x/y
	# +4 to get to center of sprite, which contains a checkpoint line on all sprites
	start_x = p2[0]*8 + 4
	start_y = p2[1]*8 + 4
	while not collides_wall_at(start_x, start_y, gfx, props_data):
		start_x -= dx
		start_y -= dy

	# Walk forwards from start to find length
	l = 1
	end_x = start_x + dx
	end_y = start_y + dy
	while not collides_wall_at(end_x, end_y, gfx, props_data):
		l += 1
		end_x += dx
		end_y += dy

	return start_x, start_y, dx, dy, l

# Duplicate of collides_part_at in lua code
def collides_wall_at(x, y, gfx, props_data):
	sprite_index = props_data[math.floor(y/8)][math.floor(x/8)]
	if sprite_index in wall_sprites:
		sprite_x = (sprite_index % 16) * 8 + x % 8
		sprite_y = math.floor(sprite_index / 16) * 8 + y % 8
		return gfx[sprite_y][sprite_x] == 6
	return False

# DFS search on each checkpoint tile to build a list of checkpoints
# Note: assumes all checkpoints are homogenous straight lines!
green_checkpoint_sprites = [10, 11, 27, 28]
brown_checkpoint_sprites = [12, 13, 14, 15]
wall_sprites = [29, 31, 42, 43, 44, 45, 46, 47, 58, 59, 60, 61, 62]
def build_checkpoints(filename, data_map):
	# Setup
	props_data = data_map['Props']
	decal_data = data_map['Decals']
	num_rows = len(props_data)
	num_cols = len(props_data[0])
	checkpoints = []

	# Search for the green checkpoint. ASSUMING THERE IS ONLY ONE GREEN CHECKPOINT
	first_x, first_y = find_all_sprites(decal_data, green_checkpoint_sprites)[0]
	next_x, next_y = find_neighbor_sprite(decal_data, green_checkpoint_sprites, first_x, first_y)
	delta_x = next_x - first_x
	delta_y = next_y - first_y
	line = walk_line(props_data, wall_sprites, first_x, first_y, delta_x, delta_y)
	checkpoints.append(line)

	# Find all brown checkpoints
	checkpoint_xys = find_all_sprites(decal_data, brown_checkpoint_sprites)
	for checkpoint_xy in checkpoint_xys:
		if any(checkpoint_xy in line for line in checkpoints):
			continue # Already visited
		first_x, first_y = checkpoint_xy
		if props_data[first_y][first_x] in wall_sprites:
			continue # Line walking messes up when starting on a wall
		next_x, next_y = find_neighbor_sprite(decal_data, brown_checkpoint_sprites, first_x, first_y)
		delta_x = next_x - first_x
		delta_y = next_y - first_y
		line = walk_line(props_data, wall_sprites, first_x, first_y, delta_x, delta_y)
		checkpoints.append(line)

	# Write the lua code
	s = ''
	#shorten = 6 # How many pixels to shorten the line on either side
	for line in checkpoints:
		#p1 = line[0]
		#p2 = line[1]
		#dx = p2[0] - p1[0]
		#dy = p2[1] - p1[1]
		#x = p1[0]*8 + abs(dx)*shorten
		#y = p1[1]*8 + abs(dy)*shorten
		#l = len(line)*8 - shorten*2
		#s += f'|{p1[0]*8+4},{p1[1]*8+4},{dx},{dy},{(len(line)-1)*8}'
		x, y, dx, dy, l = get_line_props(line, props_data)
		s += f'|{x},{y},{dx},{dy},{l}'

	#print(s)
  	#parse_table_arr(map_checkpoints_data_header, '|236,124,-1,1,40|188,172,-1,1,40|604,604,1,1,72'), -- driftmaniaLevel1.tmx checkpoints

	replace_lua_str(filename, 'checkpoints', f"parse_table_arr(map_checkpoints_data_header, '{s}'),")

# Builds a map[chunk x][chunk y] => jump index
jump_sprites = [37, 38, 39, 40, 41]
def build_jumps(filename, decal_data, n):
	jump_map = {}
	jump_id = 1

	# Build up jump map
	for pos in find_all_sprites(decal_data, jump_sprites):
		chunk_x = math.floor(pos[0] / n)
		chunk_y = math.floor(pos[1] / n)

		if chunk_x not in jump_map or chunk_y not in jump_map[chunk_x]:
			jump_dfs(jump_map, decal_data, chunk_x, chunk_y, jump_id, n)
			jump_id += 1

	# Format Lua string
	# Ex: 19 |  13, 1, 22, 2 | 20 |  13, 1, 22, 2  
	if len(jump_map) > 0:
		s = 'parse_jumps_str("'
		for jump_x in jump_map:
			s += f'|{jump_x}|' + ','.join(f'{di[0]},{di[1]}' for di in jump_map[jump_x].items())
		s += '"),'
	else:
		s = '{},'
	replace_lua_str(filename, 'jumps', s)

# Finds all connected neighboring chunks to assign the same jump_id
def jump_dfs(jump_map, decal_data, chunk_x, chunk_y, jump_id, n):
	s = len(decal_data)

	if chunk_x not in jump_map:
		jump_map[chunk_x] = {}
	jump_map[chunk_x][chunk_y] = jump_id

	for sprite_x in range(chunk_x * n, chunk_x * n + 3):
		for sprite_y in range(chunk_y * n, chunk_y * n + 3):
			for neighbor_x in range(sprite_x - 1, sprite_x + 2):
				for neighbor_y in range(sprite_y - 1, sprite_y + 2):
					if sprite_x < 0 or sprite_y < 0 or neighbor_x < 0 or neighbor_y < 0:
						continue
					if sprite_x >= s or sprite_y >= s or neighbor_x >= s or neighbor_y >= s:
						continue
					neighbor_chunk_x = math.floor(neighbor_x / n)
					neighbor_chunk_y = math.floor(neighbor_y / n)
					if chunk_x == neighbor_chunk_x and chunk_y == neighbor_chunk_y:
						continue
					this_spr = decal_data[sprite_y][sprite_x]
					neighbor_spr = decal_data[neighbor_y][neighbor_x]
					if this_spr not in jump_sprites or neighbor_spr not in jump_sprites:
						continue

					# Found a connected neighbor. Assign the same jump_id
					if neighbor_chunk_x not in jump_map:
						jump_map[neighbor_chunk_x] = {}
					if neighbor_chunk_y not in jump_map[neighbor_chunk_x]:
						jump_dfs(jump_map, decal_data, neighbor_chunk_x, neighbor_chunk_y, jump_id, n)

in_bound_sprites = [10,11,12,13,14,15,27,28,37,38,39,40,41] # Checkpoints and jumps
def build_bounds(filename, data_map, n):
	decal_data = data_map['Decals']
	props_data = data_map['Props']
	num_chunks = math.floor(len(decal_data) / n)

	# Seed map with 0 (out of bounds)
	bounds_map = {y: {x: 0 for x in range(num_chunks)} for y in range(num_chunks)}

	# Find all in-bound sprites and fan out
	for pos in find_all_sprites(decal_data, in_bound_sprites):
		bounds_dfs(bounds_map, props_data, pos[0], pos[1], n)
	
	# Build string in the same style as layer maps
	s = ''
	for row in bounds_map:
		for col in bounds_map[row]:
			s += f'{bounds_map[row][col]:0{2}x}' # 0{2} == pad to two digits

	bounds_str_comp = compress_map_str(s, num_chunks, 4)

	replace_lua_str(filename, 'bounds', f'"{bounds_str_comp}",')

def bounds_dfs(bounds_map, props_data, start_x, start_y, n):
	chunk_x = math.floor(start_x / n)
	chunk_y = math.floor(start_y / n)
	if bounds_map[chunk_y][chunk_x] == 1:
		return # Already visited

	visited = set()
	q = [(start_x, start_y)]

	while len(q) > 0:
		x, y = q[0]
		q = q[1:]
		if (x, y) in visited:
			continue
		visited.add((x, y))

		chunk_x = math.floor(x / n)
		chunk_y = math.floor(y / n)
		bounds_map[chunk_y][chunk_x] = 1

		for i in range(-1,2):
			for j in range(-1, 2):
				neighbor_x = x + i
				neighbor_y = y + j
				if neighbor_x < 0 or neighbor_x >= len(props_data[0]) or neighbor_y < 0 or neighbor_y >= len(props_data):
					continue
				if props_data[neighbor_y][neighbor_x] in wall_sprites:
					# Record as in bounds but don't continue DFS beyond wall
					bounds_map[math.floor(neighbor_y/n)][math.floor(neighbor_x/n)] = 1
				else:
					q.append((neighbor_x, neighbor_y))

# Ex: local map_settings = {laps=3, size=30, spawn_x=23*8, spawn_y=32*8, spawn_dir=0.375}
# Note: +256 is because the first 256 indices are taken by the other tileset
spawn_sprites = [i + 256 for i in range(9)]
def build_settings(filename, data_map, props, n):
	markers_data = data_map.get('Markers')
	size = math.floor(len(markers_data) / n)
	spawn_x, spawn_y = find_all_sprites(markers_data, spawn_sprites)[0]
	spawn_dir = (markers_data[spawn_y][spawn_x] - 256) / 8 # Sprite index divided by 8
	#settings = f'{{laps={laps},size={size},spawn_x={spawn_x*8},spawn_y={spawn_y*8},spawn_dir={spawn_dir}}}'
	name = props["name"].split()[0] # TODO: Add support for longer names in UI
	bronze = to_frames(props["bronze"])
	silver = to_frames(props["silver"])
	gold   = to_frames(props["gold"])
	plat   = to_frames(props["plat"])
	settings = f'"|{name},{props["req_medals"]},{props["laps"]},{size},{spawn_x*8},{spawn_y*8},{spawn_dir},{bronze},{silver},{gold},{plat}" ..'

	replace_lua_str(filename, 'settings', settings)

def to_frames(time):
	return math.ceil(float(time)*60)

def build_globals():
	# Offsets for start of chunks in __map__
	decals_offset = len(chunks['Road'])
	decals_offset_str = f'map_decal_chunks, map_decal_tiles = load_map(map_decals_data[level_index], {decals_offset}, map_settings.size)'
	replace_lua_str('global', 'decals_offset', decals_offset_str)
	props_offset = decals_offset + len(chunks['Decals'])
	props_offset_str = f'map_prop_chunks, map_prop_tiles = load_map(map_props_data[level_index], {props_offset}, map_settings.size)'
	replace_lua_str('global', 'props_offset', props_offset_str)

	# Solid chunk mapping
	mapping = f'0,0,1,5,2,3,{decals_offset},0,{decals_offset+1},10,{decals_offset+2},12,{props_offset},0'
	replace_lua_str('global', 'solid_chunks', f"local solid_chunks = parse_hash_map('{mapping}')")

def process_file(filename):
	# Grab the raw data
	root = ET.parse(filename).getroot()
	# Data has forward and trailing blank lines
	data_list = [layer.find("data").text[1:-1] for layer in root.findall("layer")]
	layer_names = [layer.get("name") for layer in root.findall("layer")]
	# Data has trailing commas
	# Data is 1-indexed so subtract one. Side effect: 0 is used for "empty" which we want to keep at 0 (rather than -1)
	for i, data in enumerate(data_list):
		data = [[int(cell) - 1 if int(cell) > 0 else 0 for cell in row.rstrip(',').split(',')] for row in data.split("\n")]
		data = [[cell if cell != 26 else 0 for cell in row] for row in data] # Set full grass sprite to 0 since it'll be drawn in cls(3)
		data_list[i] = data
	# Data is now indexed by [row][col] aka [y][x]
	data_map = {layer_names[i]: data_list[i] for i in range(len(data_list))}
	properties = {p.get('name'): p.get('value') for p in root.find('properties').findall('property')}

	# Iterate all possibilities to find the best result
	#results = []
	#for i in range(1, 7):
	#	for pad_x in range(i):
	#		for pad_y in range(i):
	#			map_len, map_len_comp, chunk_len = build_map(data_list, i, pad_x, pad_y)
	#			results.append([i, pad_x, pad_y, map_len, map_len_comp, chunk_len, chunk_len * i * i])

	# Uncomment to see other possibilities
	#print('i, pad_x, pad_y, map_str_len, map_str_comp_len, num_chunks, map_tile_size')
	#print('\n'.join(str(r) for r in results))

	build_map(filename, data_map, chunk_size, 0, 0)
	build_checkpoints(filename, data_map)
	build_jumps(filename, data_map['Decals'], chunk_size)
	build_bounds(filename, data_map, chunk_size)
	build_settings(filename, data_map, properties, chunk_size)


for filename in sys.argv[3:]:
	if '*' in filename:
		for glob_file in glob.glob(filename):
			process_file(glob_file)
	else:
		process_file(filename)
build_globals()

