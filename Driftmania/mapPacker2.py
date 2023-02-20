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
				chunk += f'{data[y + i][x + j]:03}'
	return chunk

def build_map(data, n, pad_x, pad_y):
	map_hex = ""  # The map tile values. 8 bits per tile
	chunks = {} # string of index,index,.. -> chunk index
	chunk_counts = {} # Helps keep track if there's some chunks that have low use and should be altered
	num_rows = len(data)
	num_cols = len(data[0])

	# Process the map in chunks
	for x in range(math.ceil(num_cols / n)):
		for y in range(math.ceil(num_rows / n)):
			chunk = get_chunk(data, x * n - pad_x, y * n - pad_y, n)
			if chunk not in chunks:
				chunks[chunk] = len(chunks)
			chunk_counts[chunk] = chunk_counts.get(chunk, 0) + 1
			map_hex += f'{chunks[chunk]:0{2}x}' # 0{2} == pad to two digits

	# Compress the string. First byte is index, second byte is count
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

	if n == 3 and pad_x == 0 and pad_y == 0:
		print(map_hex_comp)
		print()
		print(f'For n = {n}, pad_x = {pad_x}, pad_y = {pad_y}')
		print(f'Map string length (raw): {len(map_hex)}')
		print(f'Map string length (comp): {len(map_hex_comp)}')
		print(f'Number of chunks: {len(chunks)}')
		print(f'Chunk space on map: {len(chunks) * n * n} (out of {128*32})')
		print()
	return len(map_hex), len(map_hex_comp), len(chunks)

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
			results.append([i, pad_x, pad_y, map_len, map_len_comp, chunk_len * i * i])

print('i, pad_x, pad_y, map_str_len, map_str_comp_len, map_tile_size')
print('\n'.join(str(r) for r in results))


