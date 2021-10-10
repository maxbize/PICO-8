import sys
import xml.etree.ElementTree as ET

# Grab the raw data
root = ET.parse(sys.argv[1]).getroot()
data = root.find("layer").find("data").text
data = data.replace("\n", "").split(",")

# Build the data string to feed to PICO-8
map_hex = ""  # The map tile values. 8 bits per tile
flag_hex = "" # Flip flags for tiles. 4 bits per tile (could be 3 but that's messy)
for str_val in data:
	val = int(str_val)
	
	# Read and clear the flip flags. See https://doc.mapeditor.org/en/stable/reference/tmx-map-format/#tmx-tilelayer-tile
	flags = 0
	flags += (val & 0x80000000) >> 29
	flags += (val & 0x40000000) >> 29
	flags += (val & 0x20000000) >> 29
	val &= ~0xe0000000

	# Write the tile ID and flags
	map_hex += f'{val:0{2}x}' # 0{2} == pad to two digits
	flag_hex += f'{flags:x}'

print(map_hex)
print(flag_hex)

