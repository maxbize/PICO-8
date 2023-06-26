'''
Given a Tiled map of individual tiles, generate a map string with tiles arranged into n*n chunks

TODO: So much code cleanup ;)
'''

import codecs
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
chunks = {} # string of index,index,.. -> chunk index
chunk_counts = {} # Helps keep track if there's some chunks that have low use and should be altered
# Seed the first chunks with solid colors
for idx in [0, 1, 21, 26, 64]:
	chunk_size = 3
	chunk = ''.join([f'{idx:003}' for _ in range(chunk_size**2)])
	chunks[chunk] = len(chunks)
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
# Manually copy into .p8 for now ;)
def write_map(chunks, n):
	chunks_by_index = {chunks[k]: k for k in chunks}
	chunks_per_row = math.floor(128 / n) # Map is 128 tiles wide
	num_rows = math.ceil(len(chunks) / chunks_per_row)
	p8_map = [[0 for _ in range(128)] for row in range(num_rows * n)]
	for i in range(len(chunks)):
		for x in range(n):
			for y in range(n):
				start_index = (x + y * n) * 3 # 3 chars per int
				val = int(chunks_by_index[i][start_index:start_index+3])
				p8_map[math.floor(i / chunks_per_row) * n + y][(i % chunks_per_row) * n + x] = val

	# Convert map to string
	p8_map_str = [f"{''.join([f'{val:0{2}x}' for val in row])}\n" for row in p8_map]

	# Write the __map__ into the .p8 file itself
	with codecs.open(sys.argv[2], 'r', 'utf-8') as f:
		lines = f.readlines()
	for i, line in enumerate(lines):
		if '__map__' in line:
			lines[i+1:i+1+len(p8_map_str)] = p8_map_str
			break
	with codecs.open(sys.argv[2], 'w', 'utf-8') as f:
		f.writelines(lines)

	#print('\n__map__')
	#print(''.join(p8_map_str))
	#print()

# Compress string from chunks to tokens. Each token encodes chunk index, chunk count
# Note: chr/ord stores 7 bits per character (valid range 16-255), hex stores 4 bits per character
# Note: "flag" refers to a single bit flag specifying if the next value will be an index (0) or count (1)
# Compression levels:
#  0: uncompressed
#  1: 8 bit index, 8 bit count as hex (4 chars per token)
#  2: 7 bit index + 1 bit count flag, 8 bit count as hex (2-4 chars per token). Requires <= 2**7 chunks
#  3: 8 bit index, 8 bit count as unicode (2 chars per token). Requires <= 2**8 chunks
#  4: 7 bit index + 1 bit count flag, 8 bit count as unicode (1-2 chars per token). Requires <= 2**7 chunks
# TODO: None of the compressions have been tested ;) There's probably bugs
# TODO: If the num_chunks is per layer, and sprites aren't shared between layers, you could use higher compression
def compress_map_str(map_hex, num_chunks, compression_level):
	if compression_level == 0:
		return map_hex
	if ([0, 2**8, 2**7, 2**8, 2**7])[compression_level] < num_chunks:
		raise Exception(f'Cannot use compression level {compression_level} - too many chunks ({num_chunks})')
	max_count = 255
	map_str_comp = ""
	i = 0
	val = map_hex[i:i+2]
	count = 0
	total_count = 0
	while i < len(map_hex):
		next_val = map_hex[i:i+2]
		i += 2
		if val == next_val:
			count += 1
		if val != next_val or count == max_count or i >= len(map_hex):
			val_int = int(val, 16)
			# Build out the map string depending on the compression level
			if compression_level == 1:
				map_str_comp += f'{val}{count:0{2}x}'
			elif compression_level == 2:
				if count == 1:
					map_str_comp += f'{val}'
				else:
					val_int |= 1<<7 # Flag is 8th bit
					map_str_comp += f'{val_int:0{2}x}{count:0{2}x}'
			elif compression_level == 3:
				if val_int == 0 and p8scii[count] in [str(c) for c in range(10)]:
					map_str_comp += f'\\000{p8scii[count]}'
				else:
					map_str_comp += f'{p8scii[val_int]}{p8scii[count]}'
			elif compression_level == 4:
				if count == 1:
					map_str_comp += f'{p8scii[val_int]}'
				else:
					val_int |= 1<<7 # Flag is 8th bit
					map_str_comp += f'{p8scii[val_int]}{p8scii[count]}'
			val = next_val
			total_count += count
			count = 1 if count < max_count else 0

	print('>>>>', total_count)
	return map_str_comp

def replace_lua_str(filename, data_type, s):
	marker = f'{filename} {data_type}'
	with codecs.open(sys.argv[1], 'r', 'utf-8') as f:
		lines = f.readlines()
	for i, line in enumerate(lines):
		if marker in line:
			lines[i] = f"  {s} -- {marker}\n"
			break
	with codecs.open(sys.argv[1], 'w', 'utf-8') as f:
		f.writelines(lines)

def build_map(filename, data_map, n, pad_x, pad_y):
	for name in data_map:
		if name.lower() == 'markers':
			continue

		data = data_map[name]
		map_hex = ""  # The map tile values. 8 bits per tile
		num_rows = len(data)
		num_cols = len(data[0])

		# Process the map in chunks
		for y in range(math.ceil(num_rows / n)):
			for x in range(math.ceil(num_cols / n)):
				chunk = get_chunk(data, x * n - pad_x, y * n - pad_y, n)
				if chunk not in chunks:
					chunks[chunk] = len(chunks)
				chunk_counts[chunk] = chunk_counts.get(chunk, 0) + 1
				map_hex += f'{chunks[chunk]:0{2}x}' # 0{2} == pad to two digits
		num_chunks = len(chunks)

		# TODO: Re-index chunks by count. Helps to find chunks that are rarely used

		# Compress the string. First byte is index, second byte is count
		print(f'\n>>{filename} {name}:\n{map_hex}\n')
		map_str_comp = compress_map_str(map_hex, num_chunks, 3)

		#print(f'\n{name} map_data (raw):\n{map_hex}')
		#print(f'\n{name} map_data (compressed):\n{map_str_comp}')
		replace_lua_str(filename, name.lower(), f'"{map_str_comp}",')

	#if n == 6 and pad_x == 0 and pad_y == 0:
	write_map(chunks, n)
	print()
	print(f'For n = {n}, pad_x = {pad_x}, pad_y = {pad_y}')
	print(f'Map string length (raw): {len(map_hex)}')
	print(f'Map string length (comp): {len(map_str_comp)}')
	print(f'Number of chunks: {num_chunks}')
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

# DFS search on each checkpoint tile to build a list of checkpoints
# Note: assumes all checkpoints are homogenous straight lines!
green_checkpoint_sprites = [10, 11, 27, 28]
brown_checkpoint_sprites = [12, 13, 14, 15]
wall_sprites = [43, 44, 45, 46, 47, 59, 60, 61, 62]
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
	for line in checkpoints:
		p1 = line[0]
		p2 = line[1]
		delta_x = p2[0] - p1[0]
		delta_y = p2[1] - p1[1]
		s += f'|{p1[0]*8+4},{p1[1]*8+4},{delta_x},{delta_y},{(len(line)-1)*8}'

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
	# Lua: {[10]={[14]=1},[11]={[14]=1},[20]={[23]=2,[15]=3},[21]={[23]=2,[15]=3}}
	# Py : {11: {14: 1}, 10: {14: 1}, 21: {15: 2, 23: 3}, 20: {15: 2, 23: 3}}
	s = str(jump_map)
	s = re.sub(r'([0-9]+):\s *', r'[\1]=', s)
	s = re.sub(' ', '', s)
	s += ','
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

	bounds_str_comp = compress_map_str(s, num_chunks, 3)

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
	settings = f'"|{name},{props["laps"]},{size},{spawn_x*8},{spawn_y*8},{spawn_dir},{props["bronze"]},{props["silver"]},{props["gold"]},{props["plat"]}" ..'

	replace_lua_str(filename, 'settings', settings)

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
	process_file(filename)

bin_s = ''
for char in p8scii:
	bin_s += char
replace_lua_str('bin_test', 'bin_test', f'local bintst = "{bin_s}"')
