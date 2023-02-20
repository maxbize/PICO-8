'''
Given a Tiled map of individual tiles, generate a map string with tiles arranged into n*n chunks

TODO: Could optimize further by trimming the edges of the map that are all blank
TODO: Could optimize further by using 7 bits for the index, 1 bit to indicate if the next num is a count or the next index
'''

import math
import sys
import xml.etree.ElementTree as ET

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
				p8_map[math.floor(i / chunks_per_row) + y][(i % chunks_per_row) * n + x] = val

	# Convert map to string
	p8_map_str = [''.join([f'{val:0{2}x}' for val in row]) for row in p8_map]

	print('\n__map__')
	print('\n'.join(p8_map_str))
	print()

# Given the full uncompressed map string, compress it -> less bits, repeats have counts
# Compress string from chunks to tokens. Each token encodes chunk index, chunk count
# Note: chr/ord stores 7 bits per character (valid range 33-255), hex stores 4 bits per character
def compress_map_str(map_hex, num_chunks):
	if (num_chunks <= 2**6 and False):
		# Compression mode: 6 bits index stored in chr, 1 bit flag to specify if next chr is index or count (1-2 chars per token)
		pass
	elif(num_chunks <= 2**7 and False):
		# Compression mode: 7 bits stored in chr, 7 bits count (2 chars per token)
		# Note: could also do 7 bits stored in hex, 1 bit flag (2-4 chars per token)
		pass
	elif(num_chunks <= 2**8):
		# Compression mode: 8 bits stored in hex, 8 bits count (4 chars per token)
		i = 2
		val = map_hex[i:i+2]
		map_hex_comp = val
		count = 1
		while i < len(map_hex):
			next_val = map_hex[i:i+2]
			if val == next_val and count < 0xff:
				count += 1
			else:
				val = next_val
				map_hex_comp += f'{count:0{2}x}{next_val}'
				count = 1
			i += 2
		return map_hex_comp
	return

def build_map(data, n, pad_x, pad_y):
	map_hex = ""  # The map tile values. 8 bits per tile
	chunks = {} # string of index,index,.. -> chunk index
	chunk_counts = {} # Helps keep track if there's some chunks that have low use and should be altered
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
	map_str_comp = compress_map_str(map_hex, num_chunks)

	if n == 3 and pad_x == 0 and pad_y == 0:
		write_map(chunks, n)
		print(f'\nmap_data (compressed):\n{map_str_comp}')
		print(f'\nmap_data (raw):\n{map_hex}')
		print()
		print(f'For n = {n}, pad_x = {pad_x}, pad_y = {pad_y}')
		print(f'Map string length (raw): {len(map_hex)}')
		print(f'Map string length (comp): {len(map_str_comp)}')
		print(f'Number of chunks: {num_chunks}')
		print(f'Chunk space on map: {num_chunks * n * n} (out of {128*32})')
		print()
	return len(map_hex), len(map_str_comp), num_chunks


# Grab the raw data
root = ET.parse(sys.argv[1]).getroot()
# Data has forward and trailing blank lines
data = root.find("layer").find("data").text[1:-1]
# Data has trailing commas
# Data is 1-indexed so subtract one. Side effect: 0 is used for "empty" which we want to keep at 0 (rather than -1)
data = [[int(cell) - 1 if int(cell) > 0 else 0 for cell in row.rstrip(',').split(',')] for row in data.split("\n")]
# Data is now indexed by [row][col] aka [y][x]

# Iterate all possibilities to find the best result
results = []
for i in range(1, 7):
	for pad_x in range(i):
		for pad_y in range(i):
			map_len, map_len_comp, chunk_len = build_map(data, i, pad_x, pad_y)
			results.append([i, pad_x, pad_y, map_len, map_len_comp, chunk_len, chunk_len * i * i])

# To see other possibilities - uncomment
#print('i, pad_x, pad_y, map_str_len, map_str_comp_len, num_chunks, map_tile_size')
#print('\n'.join(str(r) for r in results))


