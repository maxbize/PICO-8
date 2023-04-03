pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
#include driftmania.lua

__gfx__
00000000555555556666666655555555655555555555555665555555633333333333333655555556000000000000000000000000000000000000000000000000
00000000555555555555555555555555655555555555555636555555563333333333336555555563000330000000000000044000000000000000004444000000
00000000555555555555555555555555655555555555555633655555556333333333365555555633000330000000000000044000000000000000044004400000
00000000555555555555555555555555655555555555555633365555555633333333655555556333000330000333333000044000044444400000440000440000
00000000555555555555555555555555655555555555555633336555555563333336555555563333000330000333333000044000044444400004400000044000
00000000555555555555555555555555655555555555555633333655555556333365555555633333000330000000000000044000000000000044000000004400
00000000555555555555555555555555655555555555555633333365555555633655555556333333000330000000000000044000000000000440000000000440
00000000555555555555555566666666655555555555555633333336555555566555555563333333000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000aaaaaaaaa0000000aaaaaaaaaaaaaaaa0000000a333333330000000000000000000000000000000000000000
0000000000000000000000000000000000000000aaaaaaaaaa0000000aaaaaaaaaaaaaa0000000aa333333330000003333000000000000000000000000000000
0000000000000000000000000000000000000000aaaaaaaaaaa0000000aaaaaaaaaaaa0000000aaa333333330000033003300000000000000000000000000000
0000000000000000000000000000000000000000aaaaaaaaaaaa0000000aaaaaaaaaa0000000aaaa333333330000330000330000000000000000000000000000
0000000000000000000000000000000000000000aaaaaaaaaaaaa0000000aaaaaaaa0000000aaaaa333333330003300000033000000000000000000000000000
0000000000000000000000000000000000000000aaaaaaaaaaaaaa0000000aaaaaa0000000aaaaaa333333330033000000003300000000000000000000000000
0000000000000000000000000000000000000000aaaaaaaaaaaaaaa0000000aaaa0000000aaaaaaa333333330330000000000330000000000000000000000000
0000000000000000000000000000000000000000aaaaaaaaaaaaaaaa0000000aa0000000aaaaaaaa333333330000000000000000000000000000000000000000
00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000677600000000000000000000000000
00000000ff10101111010fffff60002222000fffff7222211222fffffff88182122122ffffffff18881f88ff0000000000677600000000000000000000000000
00000000ff11111111111fffff62222222222fffff882221122222fffff881111211ffffffffff18881ff8ff7000000000677600000000070000000000000000
00000000ff11111111111fffff62222222222fffff882221122222fffffaacc112ccffffffffffcaaacffaff7700000000677600000000770000000000000000
00000000ff11111111111fffff62222222222fffff882221122222fffffaa1111211ffffffffff1aaa1ffaff7770000000677600000007770000000000000000
00000000ff11111111111fffff62222222222fffff882221122222fffff881111211ffffffffff18881ff8ff6777000000677600000077760000000000000000
00000000ff10101111010fffff60002222000fffff7222211222fffffff88182122122ffffffff18881f88ff6677700000677600000777660000000000000000
00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0667770000677600007776600000000000000000
00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0066777000000000077766000000000000000000
00000000ff10101111010fffff60003333000fffffa333311333fffffffbb1b3133133ffffffff1bbb1fbbff0046677700000000777664000000000000000000
00000000ff11111111111fffff63333333333fffffab3331133333fffffba1111311ffffffffff1aaa1ffbff0004667777777777776640000000000000000000
00000000ff11111111111fffff63333333333fffffbb3331133333fffffbacc113ccffffffffffcaaacffbff0000466777777777766400000000000000000000
00000000ff11111111111fffff63333333333fffffbb3331133333fffffba1111311ffffffffff1aaa1ffbff0000006666666666660000000000000000000000
00000000ff11111111111fffff63333333333fffffab3331133333fffffba1111311ffffffffff1aaa1ffbff0000000666666666600000000000000000000000
00000000ff10101111010fffff60003333000fffffa333311333fffffffbb1b3133133ffffffff1bbb1fbbff0000000000044400000000000000000000000000
00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000
__label__
60000000000000000066777000000000000000000000000000000000000000000066777000000000000000000000000000000000077766000000000000000000
56000000000000000046677700000000000000000000000000000000000000000046677700000000000000000000000000000000777664000000000000000000
55600000000000000004667770000000000000000000000000000000000000000004667777777777777777777777777777777777776640000000000000000000
55560000000000000000466777000000000000000000000000000000000000000000466777777777777777777777777777777777766400000000000000000000
55556000000000000000006677700000000000000000000000000000000000000000006666666666666666666666666666666666660000000000000000000000
55555600000000000000000667770000000000000000000000000000000000000000000666666666666666666666666666666666600000000000000000000000
55555560000000000000000066777000000000000000000000000000000000000000000000044400000444000004440000044400000000000000000000000000
55555556000000000000000006677700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555600000000000000000667770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555560000000000000000466777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555556000000000000000046677700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555600000000000000004667770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555560000000000000000066777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555556000000000000000006677700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555600000000000000000667770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555560000000000000000066777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555556000000000000000006677700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555600000000000000004667770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555560000000000000000466777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555556000000000000000046677700000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555600000000000000000667770000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555560000000000000000066777000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555556000000000000000006677700000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555600000000000000000667770000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555560000000000000000066777000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555556000000000000000046677700000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555600000000000000004667777777777777777777777777777777777777777777777777777777777777777777777777777777777
55555555555555555555555555560000000000000000466777777777777777777777777777777777777777777777777777777777777777777777777777777777
55555555555555555555555555556000000000000000006666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555555555555555555555600000000000000000666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555555555555555555555560000000000000000000044400000444000004440000044400000444000004440000044400000444000004440000044400
55555555555555555555555555555556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555555600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555555556666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555533555555555188815885555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555533555555881188811285555555555555555555555555555555555555555555555555555555555
555555555555555555555555555555555555555555555555555335555578811aaa115a5555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555533555558aa1caaac12a5555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555533555558aac18881c285555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555558881188811885555555555555555555555555555555555555555555555555555555555
65555555555555555555555555555555555555555555555555555555558881821221225555555555555555555555555555555555555555555555555555555555
06555555555555555555555555555555555555555555555555533555557222211222255555555555555555555555555555555555555555555555555555555555
00655555555555555555555555555555555555555555555555533555556000222200055555555555555555555555555555555555555555555555555555555555
00065555555555555555555555555555555555555555555555533555551010111101055555555555555555555555555555555555555555555555555555555555
00006555555555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
00000655555555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
00000065555555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
00000006555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
00000000655555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
00000000065555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
00000000006555555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
00000000000655555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
00000000000065555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
00000000000006555555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
00000000000000655555555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
00000000000000065555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
00000000000000006555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
00000000000000000655555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
70000000000000000065555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
77000000000000000006555555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
77700000000000000000655555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
67770000000000000000065555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
66777000000000000000006555555555555555555555555555533555555555555555555555555555555555555555555555555555555555555555555555555555
06677700000000000000000666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
00667770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00466777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00046677700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004667770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000006677700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000667770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006677700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004667770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000466777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
00000000000046677777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
00000000000000666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
00000000000000066666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
00000000000000000004440000044400000444000004440000044400000444000004440000044400000444000004440000044400000444000004440000044400
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__map__
1a1a1a1a1a08020202071a1a0401010101010601010202070101010101010101050101091a1a060101010802070101051a1a1a1a1a1a040101010202020201040101010101010101091a1a01010500000000000000001b00000e00000e0000000000000015151515000000000f00000f000000000000000000000000002d0000
1a1a1a1a080101010101071a0401010101011a060101010501010101010101010501091a1a1a1a0401010401050101051a1a1a1a1a1a0401010101010101010401010101010101051a1a1a010105000000001b00001b00000e00000000000019160000001515151500001500000f00000f00002d3c3c3c3c3c2b00002d3d0000
1a1a1a0801010101010101070401010101011a1a06010105030303030301010105091a1a1a1a1a040101060309010101071a1a1a1a080101010101010101010603030103030101051a1a1a0303090000001b00001b00000e000000000000191515160000181718170000000000000f0000002d3d00000000003b2b002c000000
3d000000003b2b0000002c003c2b00000000002c003b2b002b00000000003b2b003b2b00003b2b2d3d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000003b2b00002c00003b2b000000003b2b003b2b3b3c3c2b0000002c2d002c0000003b3d000000002d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000003b2b002c0000003b2b000000003b00003b0000003b2b00002d3d002c00000000000000002d3d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000292a
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002728
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002526
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002324
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002122
