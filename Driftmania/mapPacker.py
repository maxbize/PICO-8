import sys
import xml.etree.ElementTree as ET

# Grab the raw data
root = ET.parse(sys.argv[1]).getroot()
data = root.find("layer").find("data").text
data = data.replace("\n", "").split(",")

# Build the data string to feed to PICO-8
map_hex = ""  # The map tile values. 8 bits per tile
for str_val in data:
	val = int(str_val)
	
	# Write the tile ID and flags
	map_hex += f'{val:0{2}x}' # 0{2} == pad to two digits

print(map_hex)

