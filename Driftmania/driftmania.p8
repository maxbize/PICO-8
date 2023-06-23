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
009999999999990000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
097aa77aaaaaaa9005000000000000500000000000000000fffe010eeeee010efff600022222000bfff222224422222bfff7884824218888fffffff4888fffff
07999999999999a000800000000008000000000000000000fffeeeeeeeeeeeeefff622222222222bfff882224421111bfff88844444ffff8fffffff4888fffff
0a999999999999a000080000000080000000000000000000fffeeeeeeeeeeeeefff622222222222bfff882224422221bfff88acc444ffffafffffffcaaafffff
07999994499999a000008000000800000000000000000000fffeeeeeeeeeeeeefff622222222222bfff882224422221bfff88a44444ffffafffffff4aaafffff
07999947a49999a000000500005000000000000000000000fffeeeeeeeeeeeeefff622222222222bfff882224421111bfff88844444ffff8fffffff4888fffff
0a99947aaa4999a000000000000000000000000000000000fffe010eeeee010efff600022222000bfff222224422222bfff7884824218888fffffff4888fffff
0a9997aaaaa999a000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0a999aaaaaa999a000000000000000000588850000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0a99999aa99999a000000000000000000000000000000005fffe010eeee010effff60002222000bffff72222442222bfffff884824224b8ffffffff4888888ff
0a99999aa99999a050000000000000000000000000000008fffeeeeeeeeeeeeffff62222222222bffff882224422224fffff88444444444ffffffff4848888ff
0a29999aa99994a080000000000000000000000000000008fffeeeeeeeeeeeeffff62222222222b0fff8822244222240ffff8acc44444440fffffffc848aa8ff
00a2999999994a0080000000000000000000000000000008fffeeeeeeeeeeeeffff62222222222b0fff882224422224dffff8a4444444440fffffff4848aa8ff
000a29999994a00080000000000000000000000000000005fffeeeeeeeeeeeeffff62222222222b0fff8822244222240ffff884444444440fffffff4848888ff
0000a444444a000050000000000000000000000000000000fffe010eeee010effff60002222000bffff72222442222bfffff884824224b8ffffffff4888888ff
00000aaaaaa0000000000000005888500000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00000000000000070000000000000007000000007000000000077777777770007666666777777777777777777777777777777777666666660000000000000000
00000000000000760000000000000076000000006700000000766666666667007666666776666666766666676666666766666666666666660000000000000000
00000000000007660000000000000766000000006670000007666666666666707666666776666666766666676666666766666666666666660000000000000000
00007700000076660077000000007666000000006667000076666666666666677666666776666666766666676666666766666666666666660000000000000000
00076700000076660076700000076666000770006666700076666666666666677666666776666666766666676666666766666666666666660000000000000000
00766700000007660076670000077777007667007777700076666666666666677666666776666666766666676666666766666666666666660000000000000000
07666700000000760076667000000000076666700000000076666666666666677666666776666666766666676666666766666666666666660000000000000000
76666700000000070076666700000000766666670000000076666667766666677777777777777777766666677777777777777777666666660000000000000000
76666700700000000076666700000000766666670000000076666667766666676666666666666777766666677776666676666667000000000000000000000000
07666700670000000076667000000000076666700000000076666666666666676666666666666666766666676666666676666667000000000000000000000000
00766700667000000076670000077777007667007777700076666666666666676666666666666666766666676666666676666667000000000000000000000000
00076700666700000076700000076666000770006666700076666666666666676666666666666666666666666666666676666667000000000000000000000000
00007700666700000077000000007666000000006667000076666666666666676666666666666666666666666666666676666667000000000000000000000000
00000000667000000000000000000766000000006670000007666666666666707666666766666666666666666666666676666667000000000000000000000000
00000000670000000000000000000076000000006700000000766666666667007666666766666666666666666666666676666667000000000000000000000000
00000000700000000000000000000007000000007000000000077777777770007666666766666777666666667776666676666667000000000000000000000000
__label__
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336776333333333365555555aaaaaaaa
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336776333333333365555555aaaaaaaa
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336776333333333365555555aaaaaaaa
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336776333333333365555555aaaaaaaa
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336776333333333365555555aaaaaaaa
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336776333333333365555555aaaaaaaa
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336776333333333365555555aaaaaaaa
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336776333333333365555555aaaaaaaa
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336776333333333365555555aaaaaaaa
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336776333333333365555555aaaaaaaa
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336776333333333365555555aaaaaaa5
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336776333333333365555555aaaaaa55
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336776333333333365555555aaaaa555
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336776333333333365555555aaaa5555
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336776333333333365555555aaa55555
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336776333333333365555555aa555555
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336776333333333365555555a5555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333337776633333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333377766433333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333777664333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333337776643333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333377766333333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333777663333333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333337776633333333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333377766333333333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333777663333333333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333337776643333333333333333336555555555555555
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777766433333333333333333336555555555555555
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777664333333333333333333336555555555555555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666633333333333333333333336555555555555555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666333333333333333333333336555555555555555
33344433333444333334443333344433333444333334443333344433333444333334443333344433333444333333333333333333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333365555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333655555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336555555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333365555555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333655555555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336555555555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333365555555555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333655555555555555555555555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555a5555555
555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555aa555555
555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555aaa55555
555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555aaaa5555
555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555aaaaa555
555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555aaaaaa55
555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555aaaaaaa5
555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555aaaaaaaa
555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555aaaaaaaa
55555555555555555555555555555555555555555555555555555555555cccc22cccc555555555555555555555555555555555555555555555555555aaaaaaa5
55555555555555555555555555555555555544444444455555555555555cccc22cccc555555555555555555555555555555555555555555555555555aaaaaa55
5555555555555555111111552222255555544aaa4aaa4455555777555c29999829c99555555555555555555555555555555555555555555555555555aaaaa555
55555555555555114444441129992244454aaaaaaaaaaa42277777775c229999229c9955555555555555555555555555555555555555555555555555aaaa5555
555555555555551444444449999999aa444aaaaaaaaaaa99977777775c92cccc22cccc55555555555555555555555555555555555555555555555555aaa55555
555555555555514444444444999999aaaaaaaaaaaaaaaaa9999777777c92cccc22cccc55555555555555555555555555555555555555555555555555aa555555
5555555555555144444444449999999aaaaaaaaaaaaaaaa99997777770c21121c1111655555555555555555555555555555555555555555555555555a5555555
5555555555555144444444449999999aaaaaaaaaaaaaaaa99999777771c211221100075555555555555555555555555555555555555555555555555555555555
5555555555555114444444499999999aaaaaaaaaaaaaaa999999777711c100111001005555555555555555555555555555555555555555555555555555555555
555555555555511144444419999999aaaaaaaaaaaaaaaa999999777711c010000555555555555555555555555555555555555555555555555555555555555555
555555555555551299999999999999aaaaaaaaaa4aaa999999977711110055555555555555555555555555555555555555555555555555555555555555555555
5555555555555511999999922999aaaaaaaaaa444444999999921111155555555555555555555555555555555555555555555555555555555555555555555555
55555555555511444994449111aaaaaaaaaaaa411111229992211111555555555555555555555555555555555555555555555555555555555555555555555555
55555555555214444444444444aaaaaaaaaa44115551122222111115555555555555555555555555555555555555555555555555555555555555555555555555
555555555229444444444444444aaaaaaaa441115555111111155555555555555555555555555555555555555555555555555555555555555555555555555555
5555555552994444444444444444aaaaaa4411155555511111555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555529994444444444444444aaaaaa4111555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555299994444444444444441aaa441115555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555299999444114444444414444411155555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555529999911111999444111111111555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555122999221112299911111111115555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555111222111111122211111111155555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555111111111111111111115555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555511111111111111111555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555511111115551115555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555111555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666555555555555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333655555555555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333365555555555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336555555555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333655555555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333365555555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336555555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333655555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333365555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336555555555555555
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777333333333333333333333336555555555555555
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777733333333333333333333336555555555555555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666667773333333333333333333336555555555555555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666777333333333333333333336555555555555555
33344433333444333334443333344433333444333334443333344433333444333334443333344433333444336677733333333333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333667773333333333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333366777333333333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333346677733333333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333334667773333333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333466777333333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336677733333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333667773333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333366777333333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333336677733333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333677633333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333777077707770336570707770707055
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333677033707070336570707070707055
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333777077707770336577057770777055
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333707670337070336570707055707055
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333777077707770336570707055707055
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333677633333333336555555555555555
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333677633333333336555555555555558
3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333370763333333333657705557077708f
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333337076377037703365570557055570ff
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333337076707070703365570557055770ff
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333337076777077703365570557055870ff
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333337770707070333365777070557770ff
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333677633333333336555555558ffffff
3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333367763333333333655555558fffffff

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d82901d088f870ff0000000000000000
__map__
0000000101011515151a1a1a4040400802020202020202070401010101010101010101010101050101010900000000060101010102020401010101050000000401010202010101010900000101050000000000001c000000131400000000000038253517151500000e00000038253500000013140015151838253500000e0000
0000000101011515151a1a1a404040040101010101010105040101010101010101010101010105010105000000000000040101010101040101010105000000040101010101010105000000010105000000001c00001c00132935001900000e00232735001700000e00000000233724001600382614001800382824000e000000
0000000101011515151a1a1a40404004010101010101010504010101030303030303030101010501010107000000000004010101010106030303030900000801010101010101010500000001010107000000001c00001c3825351915150e00000023240000000e00001336140000001515163825350000002324000000000000
000000000000000000002c00000000002c00003b2b002c00000000002c000000002d3d00002c00000008070000060101010109000000000000009c009c000000000000001b00000e0000004153535353535353420000434040404040545144404040400051404040404040540051444452000000800000000000000000000000
00002d3c3c3c2b0000002c00003c3c002e3c00003b3c2f003c2b003c3d00002d3c3d0000003b3c000801010700000601010900000000000000939a959c0000000000001b000000000000414040404040404040540000514040404040540000514040400000434040404040540000000000000081998c87004153535353420000
002d3d0000003b2b00002c00000000002c00000000002c00002c00000000002c0000000000000008010101010700000609000000868c8700000094008800001b00001b0000000000000043404040404040404054000000434040404054000000514040000051444040404052000000000000000090009c004340404040540000
009c00434040404054000000000000000000009c008200000015151515000000000000004340404054000000000000000000004340404040404054000016000000d2939a950000000000000013292614000000000000c9ccc600002337372400839885009c0000d5ccccd6000000000000000f00000000cd009c000000000000
008800514444444452008a0000001916000000968c9b9100001515151500535353534200434040405400001600c9898c8c8700434040404040405400001800000000d3940000000000000013292525261400008900c30000cd0000000000000000968c8c97000000000000000000c3008400000f000000d5cc968c8c8b000000
000000000000000000009c00001915151600000000920000001817181700404040405400434040405400001800000000cd9c00514444444444445200000000000000000000000013140000232725252824008400c2d8c400cd0000000000000000000000000000000000000000c2d883988500000f0000000000000000000000
0f000000000000000000002d3d000000003b2b00000000000000003e2b00002c003b2b002b00003e2b003b2b00020207000000010107010107000802000801040101010105010101010101010101010101010900040101000601010101010101010101000000000000000000000a00000000000000000000002c00002d3d0000
000f00002d3c3c2b00002d3d0000000000003b2b000000000000003b3e2b003b2b003b2b3b3c3c3b3e3c002c00010101070000010101010105080101080101060101010109010101060101010109010101090000040101000006010101010101010101000d0d0d0d0d001916000a00002d2b2d3c3c3c3c2b002c002d3d000000
0000002d3d00003b2b002c00000000000000003b2b00002d2b0000003b3e00003b00003b000000002c00002c00010101010700010101010105010101040101000601010900010103000603030900010109000000060101000000060101060303030309000000000000001518000a00002c3b3d000000003b2b2c003d00000000
3b3e2b000000002d3d00002c2c000000002c2c0000000000000000000000002c00002c0000002d00002d01010109000600000072000000000063006200000000000072000000868774740000940000000000000063000074747400007500000000747400000000000000968b9200000000750000620000000000000000900000
003b3e2b0000002c0000002c2c000000002c2c00003c3c3c3c3c3c3c3c2b002c00002c00002d3d3c3c3d010101000000000000720000000075000000720000000000720000009c880000000000000000000000000000000000000000750000000000008200000000000000000000000000750000000000800000000000000000
00002c2c0000002c0000002c2c000000003b3d00002d3c3c3c3c3c3c3c3d003b2b2d3d002d3d00000000010301000000007300720000000075000000720000000063000000939a950000000000000073737373730000000000000000006200000000009b91007373000000000000000000750000000081998c87000000000000
8997000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000002c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000002c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
011000000065000650006500065000650006500065000650006500065000650006500065000650006500065000650006500065000650006500065000650006500065000650006500065000650006500065000650
000200000764007640076400764006630056300462002610006100061005600046000360002600026000560000600006000060000600006000060000600006000060000600006000060000600006000060000600
000200002361016610196100d610246102a6102a61001610116100f61000600006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001f7501d7501c7501c7501e75021750267502c7503675031750347503d7503f7501c7002170024700297002e700347003f700007000070000700007000070000700007000070000700007000070000700
010100000c4200d4200c4200d4200c4000d4200c4200d4200c4200d4200c4200d4200c4200d4200c4000d4200c4200d4000c4200d4200c4200d4200c4200d4200c4200d4200c4200d4200c4000d4200c4200d420
010800000367405670076700367005670066700267000670026700467003670006700367001670006600066000660006600166003650016500064000640006300160000624006000062407600076000000000000
010800001d0501d0501d0550000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104000021050210552f0050000021050210550000000000210502105500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a510000000c5001c5002c5003c5004c5005c5006c5007c5008c5009c500ac500bc500cc500dc500ec500fc5010c5011c5012c5013c5014c5015c5016c5017c5018c5019c501ac501bc501cc501dc501ec501fc50
010100000784007840078400784006840058400484002840008300083007830068300582004820028100081000800008000080000800008000080000800008000080000800008000080000800008000080000800
000200002361016610196100d610246102a6102a61001610116100f61000600006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001f7501d7501c7501c7501e75021750267502c7503675031750347503d7503f7501c7002170024700297002e700347003f700007000070000700007000070000700007000070000700007000070000700
010100000c4200d4200c4200d4200c4000d4200c4200d4200c4200d4200c4200d4200c4200d4200c4000d4200c4200d4000c4200d4200c4200d4200c4200d4200c4200d4200c4200d4200c4000d4200c4200d420
a10800002744305654076540365005650066500265400650026500465003650006500365001650006340063000630006300163003624016200061000610006100160000624006000062407600076000000000000
010800001d0501d0501d0552b00500004000000000000000005550000000000000000000000000000000000004555045050000000000000000000000000000000000000000000000000000000000000000000000
0105000021050210552f0050000021050210550000000000210502105500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
110b00001875018750187501875500700007000070000700187501875018750187550070000700007000070024750247502475024750247502475500700007000070000700007000070000700007000070000700
a503000030b2031b203eb003fb0034b0035b0036b0037b0038b0039b003ab003bb0030b0031b0032b0033b0034b0035b0036b0037b0038b0039b003ab003bb0030b0031b0032b0033b0034b0035b0036b0037b00
010300063c125191253c125191253d125191253010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105
__music__
00 00424344

