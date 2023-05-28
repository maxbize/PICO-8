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
0000000088888888888888880000000000000000aaaaaaaaa0000000aaaaaaaaaaaaaaaa0000000a333333330000000000000000000000000000000000000000
7760000080000000000000080000000000000000aaaaaaaaaa0000000aaaaaaaaaaaaaa0000000aa333333330000003333000000000000000000000000000000
7776000080000000000000080000000000000000aaaaaaaaaaa0000000aaaaaaaaaaaa0000000aaa333333330000033003300000000000000000000000000000
7777600080000000000000080000000000000000aaaaaaaaaaaa0000000aaaaaaaaaa0000000aaaa333333330000330000330000000000000000000000000000
7777600080000000000000080000000000000000aaaaaaaaaaaaa0000000aaaaaaaa0000000aaaaa333333330003300000033000000000000000000000000000
7777600080000000000000080000000000000000aaaaaaaaaaaaaa0000000aaaaaa0000000aaaaaa333333330033000000003300000000000000000000000000
7776000080000000000000080000000000000000aaaaaaaaaaaaaaa0000000aaaa0000000aaaaaaa333333330330000000000330000000000000000000000000
7760000080000000000000080000000880000000aaaaaaaaaaaaaaaa0000000aa0000000aaaaaaaa333333330000000000000000000000000000000000000000
0000000080000000000000080000000880000000fffffffff8000000ffffffffffffffff0000008f000000000000000000677600000000000067760000677600
0000000080000000000000080000000000000000ffffffffff8000008ffffffffffffff8000008ff000000000000000000677600000000000067760000677600
0000000080000000000000080000000000000000fffffffffff8000008ffffffffffff8000008fff000000007000000000677600000000070067777777777600
0000000080000000000000080000000000000000ffffffffffff8000008ffffffffff8000008ffff000000007700000000677600000000770067777777777600
0000000080000000000000080000000000000000fffffffffffff8000008ffffffff8000008fffff000000007770000000677600000007770067766666677600
0000000080000000000000080000000000000000ffffffffffffff8000008ffffff8000008ffffff000000006777000000677600000077760067766666677600
0000000080000000000000080000000000000000fffffffffffffff8000008ffff8000008fffffff000000006677700000677600000777660067760000677600
0000000088888888888888880000000000000000ffffffffffffffff0000008ff8000000ffffffff000000000667770000677600007776600067760000677600
00000000000777777777770000000000000000008000000000000000888888880000000800000000000000000066777000000000077766000066777000000000
00000000007000000000007000077777777777008000000000000000000000000000000800000000000000000046677700000000777664000046677700000000
00000000007000000000007000070000000007008000000000000000000000000000000800000000000000000004667777777777776640007004667700000000
00000000007000000000007000070000000007008000000000000000000000000000000800000000000000000000466777777777766400007700466700000000
00000000007000000000007000070000000007008000000000000000000000000000000800000000000000000000006666666666660000007770006600000000
00000000007000000000007000070000000007008000000000000000000000000000000800000000000000000000000666666666600000006777000600000000
00000000007000000000007000077777777777008000000000000000000000000000000800000000000000000000000000044400000000006677700000000000
00000000000777777777770000000000000000008000000088888888000000000000000800000000000000000000000000000000000000000667770000000000
cccccccc00000077770000007ccccccccccccccc00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
cccccccc000077cccc7700007ccccccccccccccc00000000fffe010eeee010fffff60002222000fffff7222244222fffffff88482422422ffffffff48884f88f
cccccccc0007cccccccc70007ccccccccccccccc00000000fffeeeeeeeeeeefffff6222222222bfffff8822244222bbfffff884444244ffffffffff48884ff8f
cccccccc007cccccccccc7007ccccccccccccccc00000000fffeeeeeeeeeeefffff6222222222bfffff8822244222bbfffffaacc442ccffffffffffcaaacffaf
cccccccc07cccccccccccc707ccccccccccccccc00000000fffeeeeeeeeeeefffff6222222222bfffff8822244222bbfffffaa4444244ffffffffff4aaa4ffaf
cccccccc07cccccccccccc707ccccccccccccccc00000000fffeeeeeeeeeeefffff6222222222bfffff8822244222bbfffff884444244ffffffffff48884ff8f
cccccccc7cccccccccccccc77ccccccccccccccc00000000fffe010eeee010fffff60002222000fffff7222244222fffffff88482422422ffffffff48884f88f
cccccccc7cccccccccccccc77ccccccc7777777700000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000007cccccccccccccc777777777ccccccc700000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000007cccccccccccccc7ccccccccccccccc700000000fffe010eeee010effff60002222000bffff72222244222bffff888848242248fffffffff48888fff
0000000007cccccccccccc70ccccccccccccccc700000000fffeeeeeeeeeeeeffff62222222222bffff88222244222bffff888844442448fffffffff48888fff
0000000007cccccccccccc70ccccccccccccccc700000000fffeeeeeeeeeeeeffff62222222222bffff88222244222bffffaa8acc44244afffffffffcaaaafff
00000000007cccccccccc700ccccccccccccccc700000000fffeeeeeeeeeeeeffff62222222222bffff88222244222bffffaa8a4444244afffffffff4aaaafff
000000000007cccccccc7000ccccccccccccccc700000000fffeeeeeeeeeeeeffff62222222222bffff88222244222bffff888844442448fffffffff48888fff
00000000000077cccc770000ccccccccccccccc700000000fffe010eeee010effff60002222000bffff72222244222bffff888848242248fffffffff48888fff
000000000000007777000000ccccccccccccccc700000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000fffe010eeeee010efff600022222000bfff222224422222bfff7884824218888fffffff4888fffff
000000000000000000000000000000000000000000000000fffeeeeeeeeeeeeefff622222222222bfff882224421111bfff88844444ffff8fffffff4888fffff
000000000000000000000000000000000000000000000000fffeeeeeeeeeeeeefff622222222222bfff882224422221bfff88acc444ffffafffffffcaaafffff
000000000000000000000000000000000000000000000000fffeeeeeeeeeeeeefff622222222222bfff882224422221bfff88a44444ffffafffffff4aaafffff
000000000000000000000000000000000000000000000000fffeeeeeeeeeeeeefff622222222222bfff882224421111bfff88844444ffff8fffffff4888fffff
000000000000000000000000000000000000000000000000fffe010eeeee010efff600022222000bfff222224422222bfff7884824218888fffffff4888fffff
000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000fffe010eeee010effff60002222000bffff72222442222bfffff884824224b8ffffffff4888888ff
000000000000000000000000000000000000000000000000fffeeeeeeeeeeeeffff62222222222bffff882224422224fffff88444444444ffffffff4848888ff
000000000000000000000000000000000000000000000000fffeeeeeeeeeeeeffff62222222222b0fff8822244222240ffff8acc44444440fffffffc848aa8ff
000000000000000000000000000000000000000000000000fffeeeeeeeeeeeeffff62222222222b0fff882224422224dffff8a4444444440fffffff4848aa8ff
000000000000000000000000000000000000000000000000fffeeeeeeeeeeeeffff62222222222b0fff8822244222240ffff884444444440fffffff4848888ff
000000000000000000000000000000000000000000000000fffe010eeee010effff60002222000bffff72222442222bfffff884824224b8ffffffff4888888ff
000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
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
0000000101011515151a1a1a4040400802020202020202070401010101010101010101010101050101010900000000060101010102020401010101050000000401010202010101010900000101050000000000001c000013361400000000000038253515000000000e00000038253500000000001500000e0000000000000000
0000000101011515151a1a1a404040040101010101010105040101010101010101010101010105010105000000000000040101010101040101010105000000040101010101010105000000010105000000001c00001c00382535150000000e00382535150000000e00000000233724000015000015000e0000002d3c3c3c0000
0000000101011515151a1a1a40404004010101010101010504010101030303030303030101010501010107000000000004010101010106030303030900000801010101010101010500000001010107000000001c00001c3825351500000e00002337240000000e0000133614000000000015000000000000002d3d0000000000
000000002c00000000002c00003b2b002c00000000002c000000002d3d00002c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2b0000002c00003c3c002e3c00003b3c2f003c2b003c3d00002d3c3d0000003b3c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b2b00002c00000000002c00000000002c00002c00000000002c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3724001413361400003825350000003724002324002324231336362525353825350013363614000000001336361400382535001336143825213636222535383825212225352535003825354153420000000013360015153500000015150038252c000000002c000000000000000000002c00002c002c000000002c002c000000
3614003538253500002337241336140000000000000000003825253737243825351329252535133614003825252614382535003825352327252525252824383825252525352824003825354340540015160038250015153500000015180038252c000000002c000000000000000000002c00002c002c000000002c0000000000
2824002423372400133636143825350000000000000000003825110000003825353825283724382535002337122535382535002337240023373737372400382337373737242400002337245144520015150038250015153500000000000023372c000000002c002c002c000000002c002c000000000000000000000000000000
003b2b2d3d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00003b3d000000002d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000002d3d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333400002324
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000313200002122
__sfx__
a510000000c5001c5002c5003c5004c5005c5006c5007c5008c5009c500ac500bc500cc500dc500ec500fc5010c5011c5012c5013c5014c5015c5016c5017c5018c5018c5018c5018c5018c5018c5018c5018c50
000200000764007640076400764006630056300462002610006100061005600046000360002600026000560000600006000060000600006000060000600006000060000600006000060000600006000060000600
000200002361016610196100d610246102a6102a61001610116100f61000600006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001f7501d7501c7501c7501e75021750267502c7503675031750347503d7503f7501c7002170024700297002e700347003f700007000070000700007000070000700007000070000700007000070000700
010100000c4200d4200c4200d4200c4000d4200c4200d4200c4200d4200c4200d4200c4200d4200c4000d4200c4200d4000c4200d4200c4200d4200c4200d4200c4200d4200c4200d4200c4000d4200c4200d420
010800000367405670076700367005670066700267000670026700467003670006700367001670006600066000660006600166003650016500064000640006300160000624006000062407600076000000000000
010800001d0501d0502b0502b05500004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0108000021050210502f0502f05500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a510000000c5001c5002c5003c5004c5005c5006c5007c5008c5009c500ac500bc500cc500dc500ec500fc5010c5011c5012c5013c5014c5015c5016c5017c5018c5018c5018c5018c5018c5018c5018c5018c50
000200000764007640076400764006630056300462002610006100061005600046000360002600026000560000600006000060000600006000060000600006000060000600006000060000600006000060000600
000200002361016610196100d610246102a6102a61001610116100f61000600006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001f7501d7501c7501c7501e75021750267502c7503675031750347503d7503f7501c7002170024700297002e700347003f700007000070000700007000070000700007000070000700007000070000700
010100000c4200d4200c4200d4200c4000d4200c4200d4200c4200d4200c4200d4200c4200d4200c4000d4200c4200d4000c4200d4200c4200d4200c4200d4200c4200d4200c4200d4200c4000d4200c4200d420
a00800000365405650076500365005650066500265000650026500465003650006500365001650006300063000630006300163003620016200061000610006100160000624006000062407600076000000000000
010800001d0501d0502b0502b05500004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0108000021050210502f0502f05500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00424344

