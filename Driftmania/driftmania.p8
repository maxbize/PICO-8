pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
#include driftmania-min.lua


__gfx__
00000000555555556666666655555555655555555555555665555555600000000000000655555556000000000000000000000000000000000000000000000000
00000000555555555555555555555555655555555555555606555555560000000000006555555560000330000000000000044000000000000000004444000000
00000000555555555555555555555555655555555555555600655555556000000000065555555600000330000000000000044000000000000000044004400000
00000000555555555555555555555555655555555555555600065555555600000000655555556000000330000333333000044000044444400000440000440000
00000000555555555555555555555555655555555555555600006555555560000006555555560000000330000333333000044000044444400004400000044000
00000000555555555555555555555555655555555555555600000655555556000065555555600000000330000000000000044000000000000044000000004400
00000000555555555555555555555555655555555555555600000065555555600655555556000000000330000000000000044000000000000440000000000440
00000000555555555555555566666666655555555555555600000006555555566555555560000000000000000000000000000000000000000000000000000000
0000000088888888888888880000000000000000aaaaaaaaa0000000aaaaaaaaaaaaaaaa0000000a333333330000000000000000000000000000000007776600
7760000080000000000000080000000000000000aaaaaaaaaa0000000aaaaaaaaaaaaaa0000000aa333333330000003333000000000000000000000077766400
7776000080000000000000080000000000000000aaaaaaaaaaa0000000aaaaaaaaaaaa0000000aaa333333330000033003300000700000070000000077764000
7777600080000000000000080000000000000000aaaaaaaaaaaa0000000aaaaaaaaaa0000000aaaa333333330000330000330000770000770000000077740000
7777600080000000000000080000000000000000aaaaaaaaaaaaa0000000aaaaaaaa0000000aaaaa333333330003300000033000777007770000000077700000
7777600080000000000000080000000000000000aaaaaaaaaaaaaa0000000aaaaaa0000000aaaaaa333333330033000000003300677777760000000067770000
7776000080000000000000080000000000000000aaaaaaaaaaaaaaa0000000aaaa0000000aaaaaaa333333330330000000000330667777660000000066777000
7760000080000000000000080000000880000000aaaaaaaaaaaaaaaa0000000aa0000000aaaaaaaa333333330000000000000000066776600000000006677700
0555550080000000000000080000000880000000fffffffff8000000ffffffffffffffff0000008f000000000000000000677600000000000067760000677600
0666660080000000000000080000000000000000ffffffffff8000008ffffffffffffff8000008ff000000000000000000677600000000000067760000677600
0600060080000000000000080000000000000000fffffffffff8000008ffffffffffff8000008fff777777777000000000677600000000070067777777777600
0655560080000000000000080000000000000000ffffffffffff8000008ffffffffff8000008ffff777777777700000000677600000000770067777777777600
0777770080000000000000080000000000000000fffffffffffff8000008ffffffff8000008fffff666776667770000000677600000007770067766666677600
0775770080000000000000080000000000000000ffffffffffffff8000008ffffff8000008ffffff666776666777000000677600000077760067766666677600
0775770080000000000000080000000000000000fffffffffffffff8000008ffff8000008fffffff006776006677700000677600000777660067760000677600
0777770088888888888888880000000000000000ffffffffffffffff0000008ff8000000ffffffff006776000667770000677600007776600067760000677600
00000000000777777777770000000000000000008000000000000000888888880000000800000000006776000066777000000000077766000066777000000000
00000000007000000000007000007777777777008000000000000000000000000000000800000000006776000046677700000000777664000046677700000000
00000000007000000000007000070000000007008000000000000000000000000000000800000000777777770004667777777777776640007004667700000000
00000000007000000000007000070000000007008000000000000000000000000000000800000000777777770000466777777777766400007700466700000000
00000000007000000000007000070000000007008000000000000000000000000000000800000000666666660000006666666666660000007770006600000000
00000000007000000000007000070000000007008000000000000000000000000000000800000000666666660000000666666666600000006777000600000000
00000000007000000000007000007777777777008000000000000000000000000000000800000000000444000000000000044400000000006677700000000000
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
__label__
6666666666666666666666ddd6777777dcccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaa99444444222222222222222244
677777777766666666666666dddd6777dccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaa9994444444442222222222244444
777777777777666666666666dddddd67dccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaa99994444444444442222222244444
77777777777666ddd66666666dddddd7dcccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaa9999444999aaaaa94222222444444
777777777766676ddddd666666dddd7776dddcccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaa9999944999999aaaaa422224499999
6677777776677776ddddd666666677777776ddcccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaa999994999999999aaaa42224999422
66677777767777776ddd00000000000000000000000000000000000000000000000000000000000000000000000000000009999999999999999aa92244942222
6666777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000009999999999999999aa94249922222
6666777777777777777000d777777777700000d777777777777dd0000007777000d77777777777d0006777777777777d000a9999999999999999aa4449422222
666667777777777777000d777777777777000d7777777777777777d0000777700077777777777d0006777777777777d0000aaa99999999999999994499422444
7776677777777777770007777777777777700777777777777777777d000777700d7777777777d0006777777777777d00009999999aaaaa999999994499424444
77777677777777777000000000000d77777d00000000000000d7777700d777d0077700000000000000007777700000000999999aaaaaaaa99999994444444444
777777777777777770000000000000777777000000000000000777770077770007770000000000000000777770000000a99999aaaaaaaaaa9999944422224444
7777777777777777000d777000000077777700000000000000d7777700777700d777000000000000000d7777d00aaaaaaa999aaaaaaaaaaaa999994222224444
77777777777666670007777000000077777700d7777777777777777d00777d0077777777777d000000077777000a999aaa99aaaaaaa999aaaa99999222224444
7777777777776dd000d777d0000000777777007777777777777777700d7770007777777777d00000000777770099999aaaaaaaaaa9999999aa99999942249aaa
77777777777777d00077770000000077777d0d777777777777777d000777700d777777777d00000000d7777d0099aaaaaaaaaaa9999999999a9999999499aaaa
66667777777777000d77770000000d777770077777777777777d000007777007777000000000000000777770009aaaaaaaaaaa99999999999aa99999999aaaa9
7666677777777000077777000000d77777d0d7777d0000077777d0000777d007777000000000000000777770099aaaaaaaaaaa999999999999a9999999aaaa94
776666777777700007777777777777777d0077777000000d77777d00d77700d777700000000000000d7777d0099aaaaaaaaaaa999999999999a999999aaaa444
7777666777770000d77777777777777d000d7777d00000007777770077770077777000000000000007777700099aaa99aaaaaa999999999999aaaa999aa94422
7777760000000000777777777777d0000007777700000000d7777700777700777770000000000000077777000000000000000000000000000000aaaa9a944222
77777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000999aa9942222
777700000000000000000000000000000d777d00000000000d770000000000000d77d000000000d777000000000777700d7777000000000d7700099999942222
77777766677777777777777777777d000777770000000000d777000000000000d777700000000077777000000007777007777700000000d77770099999942222
77777766677777777777777777776000d77777000000000d777700000000000d77777d00000000777777000000d777d00777770000000d777777009999942222
33333333333333333333333333333000777777d0000000d777770000000000d77777770000000d777777700000777700d77777000000d7777777009999942222
1111555555555555dddddddddddd000d7777777000000d777777000000000d77777777d0000007777777770000777d0077777d00000d77777777700999442222
111155555555555555555555555500077777777d0000d777777700000000d77777d7777000000777777777700d7770007777700000d777777777700994444222
111155555555555555555555555000d777777777000d777777770000000d77777007777d0000d7777d7777770777700d777770000d77777d7777770044444422
33333335555555555555555555500077777d7777d0d777777777000000d77777000d77770000777770d777777777d0077777d000d77777007777770044444444
33333333222111111111111111000d777770777777777707777700000d77777000007777d0007777700d7777777700077777000d77777000d777777004444444
3333333a22211333333333333300077777d0d7777777700777770000d77777000000d777700d77777000d777777700d7777d00d7777700000777777004444444
3333333aa4411333333333333000d77777000777777700077777000d77777000000007777d077777d0000d77777d007777700d77777000000d77777700444444
33333333a4a113333b3b3333300077777d000d7777700007777700d7777700000000077777077777000000d7777000777770d777770000000077777700222222
babbbbbbbaa3333333b33333000d77777000007777000007777777777770d77777777777777777770000000d777000777777777770d777777777777770022222
bbbbaaaaaaabbb00000000000007777770000077700000077777777777777777777777777777777700000000d770007777777777777777777777777770022222
abbaaaaaaabab0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222
bbabaaaaaaab00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042222
bbbaaaaaaababbbbbbbbbbbbbbbbbbbbbbbbbbb33bb333332feeeeeeeeeeeeeeeeeaaaaaaaaaaaaaaa888888888888882a449999999999222999999222442222
888888888d67777776bbbbbbbbbbbbbbbbbbb3baa33b3332feeeeeeeeeeeeeeeee9aaaaaaaaaaaaaaa888888888888882a949999999999222999999222442222
88888888d6777777777777777776bbbbbbbb3aaaaaaab02feeeeeeeeeeeeeeeeeeaaaaaaaaaaaaaaa9888888888888882a949999999999222999999222442222
288888886777777777777777776d8888888888888aabbb2fffffffeeeeeeeeeeeeaaaaaaaaaaaaaaa8888888888888882a999999999999222994444222442222
22222222dddddddd6677777776d8888888888888d67772eeffffffffffffffffffff777aaaaaaaaaa8888888888888882aa99999999994224444444422242222
00000002dddddddddddddddddd22888888888888677772ee21111111111222888aaaaa7777777777777eeeeeeeee88882aaa9999999942224444444442242222
00000000000000000000dddddd22222222222222dddd28e811777777711111111cccccbaaaaa7777777eeeeeeeeeee882aaa9999999922244444444444222222
5555511100000000000000000000000000222222dddd2ee217ccccccc777777777777cccccccbbaaa88888888888eee82a9aa999999422499444444444222222
555555555555555555111000000000000000000000028e817ccccccccccc3111cccc77777cccccccc111111111128eee2a49a999999444999444444442222222
55555555555555555555555555555555111000000002ee17ccccccccccc31111ccccccccc777777713333333333128ee20449a99999449994444444442222222
55555555555555555555555555555555555555555552e817cccccccccc311111cccccccc7777777c11111111113318ee20444449999449944444444422222222
55555555555555555555555555555555555555555528e17cccccccccc3111113ccccccc7777777cc111111111113188e20444444444499444444444222222222
5555555555555555555555555555555555555555552e817ccccccccc3111111cccccccc777777cc3111111111111188e20444444444444442222222222222222
5555555555555555555555555555555555555555528e17ccccccccc31111111ccccccc777777ccc1111111111111188e20444444444444422222222222222122
555555555555555555555555555555555555555552e217cccccccc311111111cccccc777777cccc1111111111111188820444444422222222222222222222122
555555555555555555555555555555555555555528e17cccccccc3111111113ccccc777777ccccc1111111111111188820444442222222222222222222222122
55555555555555555555555555555555555555552e217777c3111111111111ccccc777777ccccc31111111111111188820444222222222222222222122221122
55555555555555555555555555555555555555552e111113ccccccccc33333cccc777777cccccc11111111111111188820442222222222222222222112211122
5555555555555555555555555555555555555552eeeeee21111111111111337777777777777ccc11111111111111188820442222222222222222222211111222
555555555555555555555555555555555555552ee8888eeeeeeeeee2111113cccccccccccc777731111111111111188820042222222222222222222221111122
55555555555555555555555555555555555552eeeeee888888888eeeeeeeeaaaaaaaaaabcccccc13333333511113188820004222222222212222222222222112
5555555555555555555555555555555555552eeeeeeeeeeeeee8888888889aaaaaaaaaaaaaaaa811111113333333188820000222222222112222222222222211
555555555555555555555555555555555552eeeeeeeeeeeeeeeeeeeee8889999999999aaaaaaa888822111111111188820000222222222112222222222222211
55555555555555555555555555555555552eeeeeeeeeeeeeeeeeeeeeee9aaaaaaaaa999999992222888888888888888820000022222221122222222222222111
5555555555555555555555555555555552eeeeeeeeeeeeeeeeeeeeeeeeaaaaaaaaaaaaaaaaa92222222222222222288820000012222111122222222222221112
555555555555555555555555555555552eeeeeeeeeeeeeeeeeeeeeeee9aaaaaaaaaaaaaaaaaa8888888888882222288820000001221111211222221222211112
55555555555555555555555555555552eeeeeeeeeeeeeeeeeeeeeeeeeaaaaaaaaaaaaaaaaaa98888888888888888888820000000122222101122221111111121
5555555555555555555555555555552eeeeeeeeeeeeeeeeeeeeeeeee9aaaaaaaaaaaaaaaaaa88888888888888888888820000000011111000012222211111221
555555555555555555555555555552eeeeeeeeeeeeeeeeeeeeeeeeeeaaaaaaaaaaaaaaaaaaa88888888888888888888820000000000000000001122222222211
555555555555555555555555555528eeeeeeeeeeeeeeeeeeeeeeeee9aaaaaaaaaaaaaaaaaaa88888888888888888888820000000000000000000011111111100
55555555555555555555555555528e88eeeeeeeeeeeeeeeeeeeeeeeaaaaaaaaaaaaaaaaaaa988888888888888888888820000000000000000000000000000000
5555555555555555555555555528f8888eeeeeeeeeeeeeeeeeeeee9aaaaaaaaaaaaaaaaaaa888888888888888888888820011100000000000000000000000000
555555555555555555555555528ffe8888eeeeeeeeeeeeeeeeeeeeaaaaaaaaaaaaaaaaaaaa888888888888888888888820011111111111111000000000000000
55555555555555555555555528ffff88888eeeeeeeeeeeeeeeeee9aaaaaaaaaaaaaaaaaaaa888888888888888888888820011111111111111155551110000000
555555555555555555555551888fffffffeeeeeeeeeeeeeeeeeeeaaaaaaaaaaaaaaaaaaaa9888888888888888888888820011111111111111155555555510000
555555555555555555555518888888effffffffeeeeeeeeeeeee9aaaaaaaaaaaaaaaaaaaa8888888888888888888888820011111111111111155555555555510
555555555555555555555188888888888888fffffffffeeeeee9aaaaaaaaaaaaaaaaaaaaa8888888888888888888888e20011111111111111155555555555555
5555555555555555555551866d888888888888888fffffffff77aaaaaaaaaaaaaaaaaaaaa8888888888888888888888e20011111111111111155555555555555
55555555555555555555518666776888888888888888888fff777777aaaaaaaaaaaaaaaa98888888888888888888828e20011111111111111155555555555555
55555555555555555555518666777888888888888888888888999a777777aaaaaaaaaaaa88888888888888888888228e20011111111111111155555555555555
55555555555555555555518666777888888888888888888888888889aa7777777aaaaaaa88888888888888888882228e20011111111111111155555555555555
55555555555555555555518d66777888888888888888888888888888888889aa7777777a88888888888888888822228e20011111111111111555555555555555
5555555555555555555551888d677888888888888888888888888888882222222289aae7eee88888888888882222228e20011111111111111555555555555555
5555555555555555555577688888888888888888888888888888888888222222222222228eeeeeeeee888822222222ee20011111111111115555555555555555
555555555555555555557776888888888888888888888888888888888222222222222222222228eeeeeeeeee88222eee20011111111111115555555555555555
555555555555555555557777776688888888888888888888888888888222222222222222222222222228eeeeeeeeeeee20011111111111155555555555555555
555555555555555555557777777777666888888888888888888888888222222222222222222222222222222228eeeee810011111111111155555555555555555
55555555555555555555777777777777777776688888888888888888822222222222222222222222222222222222288810000001111111555555555555555555
55555555555555555555577777777777777777777666888888888888222222222222222222222222222222222222222850000000000000055555555555555555
55555555555555555555577777777777777777777777776668888888222222222222222222222222222222677777622250000000000000000055555555555555
555555555555555555555577777777777777777777777777776666882222222222222222222222222222267777777622d1000000000000000000001555555555
5555555555555555555555511177777777777777777777777777777666d2222222222222222222222222277777777722d1000000000000000000000001555555
555555555555555555555555111111177777777777777777776666777777666d22222222222222222222277777777722d5000000000000000000000000001555
5555555555555555555555555111111111dd7777777777777766666666777777766d2222222222222222267777777722dd000000000000000000000000000001
555555555555555555555555555111111111111d7777777776666666666666677777766d2222222222222e7777777622dd000000000000000000000000000000
5555555555555555555555555555001111111111111d777776666666666666666666777766d22222222222e6777762226d000000000000000000000000000000
555555555555555555555555555550000001111111112222d6666666666666666666666666666dd222222222222222226d000000000000000000000000000000
5555555555555555555555555555510000000001111112222222d66666666666666666666666666666dd2222222222226d000000000000000000000000000000
55555555555555555555555555555510000000000000112222222222266666666666666666ddddddd666666dd222222d6d000000000000000000000000000000
5555555555555555555555555555555510000000000000000122222222222666666666666ddddddddddddd66666666666d000000000000000000000000000000
5555555555555555555555555555555555551000000000000000011222222222266666666dddddddddddddddddddddd666011111111000000000000000000000
5555555555555555555555555555555555555555110000000011100000122222222266666dddddddddddddddddddddd666011111111555550000000000000000
5555555555555555555555555550005555555555555510000001111111000112222222222dddddddddddddddddddddd666011111115555555555551000000000
555555555555555555555555000000000055555555555555100111111111111111122222222222ddddddddddddddddd666011111115555555555555551000000
55555555555555555555000000d676d0000000555555555555551111111111111111111222222222222dddddddddddd666011111115555555555555555510000
55555555555555555000000d677777ff88200000005555555555555111111111111111111112222222222222ddddddd66d011111115555555555555555555100
5555555555555500000d6777777777ffeeeee8200000005555555555555111111111111111111112222222222222dd66d0011111115555555555555555555510
5555555555000000d6777777776666e8888eeeeee820000000555555555555511111111111111111111222222222220000111111115555555555555555555551
5555555000000d677777777666666e888888888eeeeee82000000055555555555551111111111111111111122222220001111111115555555555555555555555
555500000d677777777766666666e88888888888888eeeeee8200000005555555555555111111111111111111111111111111111115555555555555555555555
500000d6777777777666666666668888888888888888888eeeeee820000000555555555555511111111111111111111111111111115555555555555555555555
000d67777777776666666666666e88888888888888888888888eeeeffd5500000055555555555511111111111111111111111111115555555555555555555555
d6f77777777666666666666666e888888888888888888888888888eff777ffd50000005555555555551111111111111111111111115555555555555555555555
6fff777666666666666666666e88888888888888888888888888886666777777ffd5000005555555555555111111111111111111115555555555555555555555
eff7666666666666666666d552888888888888888888888888888e666666667777777fd500000555555555555511111111111111115555555555555555555555
ee66666666666666666d5555522228888888888888888888888886666666666666777777ffd50000055555555555551111111111155555555555555555555555
e8e66666666666666d5555555222222888888888888888888888e66666666666666666777777ffd5000005555555555555111111555555555555555555555555
888e6666666666d55555551552222222228888888888888888886666666666666666666666777777ffd500000555555555555555555555555555555555555555
8888e6666666d55551151111322322222222288888888888888e66666666666666666666666666777777ffd50000055555555555555555555555555555555555
88888e666d555555311111113bb3222222322222888888888886666666666666666666666666666666777777ffd5000005555555555555555555555555555555
8888886d5555513b3111331313bb222223b222222228888888e66666666666666666666666666666666666777777f20000000555555555555555555555555555
88882255551111b3b113b333b3bb32222ab222222222228888666666666666666666666666666666666666666677f88882100000055555555555555555555555
82222253511111bb3133b333b33333333b3321122221222226666666666666666666666666666666666666666666e88888882100000005555555555555555555
222211333111133b333bb3b1131ab3b333113331b33122322155dd66666666666666666666666666666666666666e88888888888210000005555555555555555
2211113113113333333b3bb1133aabaa31133333ba31b33311155555d66666666666666666666666666666666666888888888888888821000000555555555555
11111111133133331333333311bbabab31ba33333b3aa33311155155555d66666666666666666666666666666666888888888888888888821000000055555555
11111111111131131b3333bbbbbbbbbb3bba3bb3333b113313311155555555d66666666666666666666666666666888888888888888888888882100000005555
11111111111333133b3b3bbbabaabbabbbbbbbb313311133331111111155555555d666666666666666666666666e888888888888888888888888888210000000
111111111111333bbbbbbbbbbbaabaabbabbbbbb311113311311111111111555555555d666666666666666666668888888888888888888888888888888821000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d82901d088f870ff0000000000000000
__map__
0000000101011515151a1a1a40404000000802020207000004010106010102020701010101010101010501010900000601010104010101010508020200000004010101010500000002020101020201010101010109000000000000000000006200620000000000620000001b00000e00000e0000000000007200007200000000
0000000101011515151a1a1a404040000801010101010700040101000601010105010101010101010105010900000000040101040101010105040101000000040101010105000000010101010101010101010105000000000000000000000000620062000000000062001b00000e000000000000007200007200007200000000
0000000101011515151a1a1a4040400801010101010101070401010000060101050303030303010101050900000000000401010603030303090401010000080101010101010700000101010101010103030101050000000000636200000000000062001b00000000001b00000e00000000007373007200007200007200130000
0000000013292614000000000000000023373724004340404040540000000000000000000000750015151515000000000000004340404054000074740000004340404040404054000015160000000000000000c9ccc60000d5ccccd6007200000000007474747474000f00000000cd0f000000000000000000000000002d0000
00000013292525261441535353534200000000000051444444445200007500001916000000007500151515150053535353420043404040540000000000191643404040404040540000151800000000000000c30000cd000000000000007200000000c3000000000000000f000000d5000f00002d3c3c3c3c3c2b00002d3d0000
140000232725252824434040404054000000000000000000000000000075001915151600000000001817181700404040405400434040405400000000001715514444444444445200000000737373000013c2d8c400cd0000000000000000000000c2d800000000000000000f0000000000002d3d00000000003b2b002c000000
3d000000003b2b0000002c000000000000003e2b00002c003b2b002b00000000003e2b003b2b00003b2b2d3d0000000000000000001c00000000000038253500131400000000000038253517151500000013140015151838253563000000007500000e00002d2b0000000000002d3d3b2b00002c00002c00000000002c000000
0000000000003b2b00002c000000000000003b3e2b003b2b003b2b3b3c3c2b00003b3e3c002c0000003b3d000000002d1c00000000001c6300000000233724132935001900000e00232735001700001600382614001800382824000000000075000e00002d3d3b2b00000000003b3c3c2f00002e3c3c2f003c2b003c3d000000
000000000000003b2b002c0000002d2b0000003b3e00003b00003b0000003b2b00002c00002c00000000000000002d3d001c000000006300001336140000003825351915150e00000023240000001515163825350073732324000000000000750000002d3d00002c003c3c3c000000002c00002c00002c00002c000000000000
000000002c00020207000000010107010107000802000801040101010105010101010101010101010101010900040101000601010101010101010101000000620000000000000000007500007500007200737373737300000000000a00000000000000000000002c00002d3d3b3e2b000000002d3d00002c2c000000002c0000
002d3c003b3c010101070000010101010105080101080101060101010109010101060101010109010101090000040101000006010101010101010101000000006200000d0d0d0d0d007500007500007200000000000062001916000a00002d2b2d3c3c3c3c2b002c002d3d00003b3e2b0000002c0000002c2c000000002c0000
002c00000000010101010700010101010105010101040101000601010900010103000603030900010109000000060101000000060101060303030309007373000062000000000000007500000062630000000000000063001518000a00002c3b3d000000003b2b2c003d000000002c2c0000002c0000002c2c000000003b0000
2c0000000000000000000000002c00002c0000002d010101090006000000630062000000010101010101010101010105000000040101080101010107080101060303010101010700000601010109000000000006000000010107000000131400006227261400000000000000000062000000000000000017151518002c000000
2c00003c3c3c3c3c3c3c3c2b002c00002c003c3c3d010101000000000000000000002c000101010101010101010101010000080101010101010101050401010000000601010101070000060309000008020700000000000101050b0b0b3826140000623724000000746200000000750000151516000000001718002d3d000000
3d00002d3c3c3c3c3c3c3c3d003b2b2d3d00000000010301000000007300000000002c000301010101050401010101010008010101010101010101010601010000000006010101010700000000000801010107000207000101090000006227260000000000000000000062000000000000151515160000000000003d00000000
0000000000003c3c1f2d2f00000801010101000004000008050000010102020101001336140000000000000038252824000000000000000000001329253500001c0023372400000038252614000000002300000000000000002d3d00003b2b00002d3d0000000000000000000000000000000000000000000000000000000000
2b002d00000000003b3d3b2b080101010109000801000006050000010101010101132925350000000f0000002337240000000000001c00000013292528240000001c000000000000232725261400000000002d3d00000000003b2b0000003b3c3c3d000000000000000000000000000000000000000000000000000000000000
3b1d3d2a3c3c00000000003b01010101090008010100000001070001010101010129252824000000000f0000000000003614000000001c000038252824000000000000000000000f0023272535000000002d3d00002d000000003b2b000000000000000000000000000000000000000000000000000000000000000000000000
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

