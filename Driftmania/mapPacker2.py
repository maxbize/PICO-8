'''
Given a Tiled map of individual tiles, generate a map string with tiles arranged into n*n chunks

TODO: So much code cleanup ;)

TODO: Could optimize further by trimming the edges of the map that are all blank
TODO: Could optimize further by setting all grass tiles to sprite 0 and using cls(grass_color)
'''

import math
import sys
import xml.etree.ElementTree as ET

# Using pico-8 extended charset for data requires the terminal to support utf-8
sys.stdout.reconfigure(encoding='utf-8')

# https://gist.githubusercontent.com/joelsgp/bf930961230731fe370e5c25ba05c5d3/raw/d837ae7bff7b5b6375f684dc69b6e9195f02e78a/p8scii.json
# Note: the single quote (') has an extra escape in front of it so that it will not end the string when pasting as Lua code
p8scii = ["\\0", "\\*", "\\#", "\\-", "\\|", "\\+", "\\^", "\\a", "\\b", "\\t", "\\n", "\\v", "\\f", "\\r", "\\014", "\\015", "▮", "■", "□", "⁙", "⁘", "‖", "◀", "▶", "「", "」", "¥", "•", "、", "。", "゛", "゜", " ", "!", "\"", "#", "$", "%", "&", "\\'", "(", ")", "*", "+", ",", "-", ".", "/", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?", "@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", "\\", "]", "^", "_", "`", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{", "|", "}", "~", "○", "█", "▒", "🐱", "⬇️", "░", "✽", "●", "♥", "☉", "웃", "⌂", "⬅️", "😐", "♪", "🅾️", "◆", "…", "➡️", "★", "⧗", "⬆️", "ˇ", "∧", "❎", "▤", "▥", "あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", "も", "や", "ゆ", "よ", "ら", "り", "る", "れ", "ろ", "わ", "を", "ん", "っ", "ゃ", "ゅ", "ょ", "ア", "イ", "ウ", "エ", "オ", "カ", "キ", "ク", "ケ", "コ", "サ", "シ", "ス", "セ", "ソ", "タ", "チ", "ツ", "テ", "ト", "ナ", "ニ", "ヌ", "ネ", "ノ", "ハ", "ヒ", "フ", "ヘ", "ホ", "マ", "ミ", "ム", "メ", "モ", "ヤ", "ユ", "ヨ", "ラ", "リ", "ル", "レ", "ロ", "ワ", "ヲ", "ン", "ッ", "ャ", "ュ", "ョ", "◜", "◝"]

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
	with open(sys.argv[3], 'r') as f:
		lines = f.readlines()
	for i, line in enumerate(lines):
		if '__map__' in line:
			lines[i+1:i+1+len(p8_map_str)] = p8_map_str
			break
	with open(sys.argv[3], 'w') as f:
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
#  3: 7 bit index, 7 bit count as unicode (2 chars per token). Requires <= 2**7 chunks
#  4: 6 bit index + 1 bit count flag, 7 bit count as unicode (1-2 chars per token). Requires <= 2**6 chunks
# TODO: None of the compressions have been tested ;) There's probably bugs
# TODO: If the num_chunks is per layer, and sprites aren't shared between layers, you could use higher compression
def compress_map_str(map_hex, num_chunks, compression_level):
	if compression_level == 0:
		return map_hex
	if ([0, 2**8, 2**7, 2**7, 2**6])[compression_level] < num_chunks:
		raise Exception(f'Cannot use compression level {compression_level} - too many chunks ({num_chunks})')
	max_count = ([0, 2**8, 2**8, 2**7, 2**7])[compression_level]
	map_str_comp = ""
	i = 0
	val = map_hex[i:i+2]
	current_val = val
	count = 0
	while i < len(map_hex):
		next_val = map_hex[i:i+2]
		i += 2
		if val == next_val and count < max_count:
			count += 1
		else:
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
				map_str_comp += f'{p8scii[val_int+16]}{p8scii[count+16]}'
			elif compression_level == 4:
				if count == 1:
					map_str_comp += f'{p8scii[val_int+16]}'
				else:
					val_int |= 1<<6 # Flag is 7th bit
					map_str_comp += f'{p8scii[val_int+16]}{p8scii[count+16]}'
			val = next_val
			count = 1

	return map_str_comp

# Write the string representation into lua code
def write_map_str_to_lua(map_str, name):
	name = name.lower()
	prefix = f"local map_{name}_data ="
	full = f"{prefix} '{map_str}'"
	replace_lua_str(prefix, full)

def replace_lua_str(prefix, full):
	with open(sys.argv[2], 'r') as f:
		lines = f.readlines()
	for i, line in enumerate(lines):
		if prefix in line:
			lines[i] = f"{full}\n"
			break
	with open(sys.argv[2], 'w') as f:
		f.writelines(lines)

def build_map(data_map, n, pad_x, pad_y):
	chunks = {} # string of index,index,.. -> chunk index
	chunk_counts = {} # Helps keep track if there's some chunks that have low use and should be altered

	for name in data_map:
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
		map_str_comp = compress_map_str(map_hex, num_chunks, 3)

		#print(f'\n{name} map_data (raw):\n{map_hex}')
		#print(f'\n{name} map_data (compressed):\n{map_str_comp}')
		write_map_str_to_lua(map_hex, name)

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
wall_sprites = [43, 44, 45, 59, 60, 61, 62]
def build_checkpoints(data_map):
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
	s = 'local map_checkpoints = {'
	for line in checkpoints:
		p1 = line[0]
		p2 = line[1]
		delta_x = p2[0] - p1[0]
		delta_y = p2[1] - p1[1]
		s += f'{{x={p1[0]*8+4},y={p1[1]*8+4},dx={delta_x},dy={delta_y},l={(len(line)-1)*8}}},'
	s = s[:-1] + '}'
	#print(s)
	replace_lua_str('local map_checkpoints =', s)


# Grab the raw data
root = ET.parse(sys.argv[1]).getroot()
# Data has forward and trailing blank lines
data_list = [layer.find("data").text[1:-1] for layer in root.findall("layer")]
layer_names = [layer.get("name") for layer in root.findall("layer")]
# Data has trailing commas
# Data is 1-indexed so subtract one. Side effect: 0 is used for "empty" which we want to keep at 0 (rather than -1)
for i, data in enumerate(data_list):
	data = [[int(cell) - 1 if int(cell) > 0 else 0 for cell in row.rstrip(',').split(',')] for row in data.split("\n")]
	data_list[i] = data
# Data is now indexed by [row][col] aka [y][x]
data_map = {layer_names[i]: data_list[i] for i in range(len(data_list))}

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


build_map(data_map, 3, 0, 0)
build_checkpoints(data_map)
