pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
#include portal_deal.lua
__gfx__
00000000777777776666666676666667777777777777777766666667666666667666666676666667777777777777777777777777777777777777777766666667
00000000766666676666666676666667666666666666666666666667666666667666666676666667766666667666666766666667766666666666666766666667
00000000766666676666666676666667666666666666666666666667666666667666666676666667766666667666666766666667766666666666666766666667
00000000766666676666666676666667666666666666666666666667666666667666666676666667766666667666666766666667766666666666666766666667
00000000766666676666666676666667666666666666666666666667666666667666666676666667766666667666666766666667766666666666666766666667
00000000766666676666666676666667666666666666666666666667666666667666666676666667766666667666666766666667766666666666666766666667
00000000766666676666666676666667666666666666666666666667666666667666666676666667766666667666666766666667766666666666666766666667
00000000777777776666666676666667777777776666666666666667777777777666666677777777777777777666666777777777766666666666666777777777
76666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666000000000000000000000000000000000000000000000000000000000000000033b03330b330bb30bbb0bbb0bbb03bb0000000000000000000000000
76666666000000000000000000000000000000000000000000000000000000000000000037b0b7b0b730b730b730b7b037b037b0000000000000000000000000
766666660000000000000000000000000000000000000000000000000000000000000000bbb0bbb0bbb0bb30b330333033b03bb0000000000000000000000000
76666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777777770000000000000000000000000000000000000000000000000000000000000007aa000000000000777000000000000a99000000000000111000000000
000000000000000000000000000a0000000aa000000770000009900000011000000007aaaaaa00000000777777700000000a9999990000000011111110000000
000000000000000000000000009a900000aaaa0000777700009999000011110000007aaaaaaaa000000777777777000000a99999999000000111111111000000
000800000003b3000000000004aaa4000aa9aaa00776777009929990011111100007aaaaaaaaaa0000777777777770000a999999999900001111111111100000
00808000000b7b000007aa00aaaaaaa00aa99aa0077667700992299001111110000aaaa99aaaaa00007777667777700009999229999900001111111111100000
000800000003b3000009990009aaa9000aa9aa90077677600992992001111110007aaaa999aaaaa00777776667777700a9999222999990011111111111110000
0000000000000000000000000a949a0000aaa90000777600009992000011110000aaaaa9999aaaa0077777666677770099999222299990011111111111110000
000000000000000000000000a90009a0000a900000076000000920000001100000aaaaa9999aaaa0077777666677770099999222299990011111111111110000
000000000000000000000000000000000000000000000000000000000000000000aaaaa9999aaaa0077777666677770099999222299990011111111111110000
000000000000000000000000000000000000000000000000000000000000000000aaaaa999aaaa90077777666777760099999222999920011111111111110000
0008000000000000000000000000000000000000000000000000000000000000000aaaa99aaaaa00007777667777700009999229999900001111111111100000
000e0000000e00000000000000020000e440d4405440a4400000000000000000000aaaaaaaaaa900007777777777600009999999999200001111111111100000
08e0e80000e0e000000a990000202000ee40dd405540aa4000000000000000000000aaaaaaaa9000000777777776000000999999992000000111111111000000
000e0000000e00000004440000020000eee0ddd05550aaa0000000000000000000000aaaaa990000000077777660000000099999220000000011111110000000
00080000000000000000000000000000ee40dd405540aa4000000000000000000000000aa9000000000000776000000000000992000000000000111000000000
00000000000000000000000000000000e440d4405440a44000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000004666666660666666660666666660666666066666666066600000000000000166666666066666666066600000066666666610000000000000000
00000000000009777777770777777770777777770777777077777777077700000000000000c777777770777777770777000000777777777c0000000000000000
00000000000009777777770777777770777777770777777077777777077700000000000000c777777770777777770777000000777777777c0000000000000000
00000000000009777007770777007770777007770007770077700777077700000000000000c77700000077700777077700000077700000000000000000000000
00000000000009777007770777007770777007770007770077700777077700000000000000c77700000077700777077700000077700000000000000000000000
00000000000009777007770777007770777007770007770077700777077700000000000000c77700000077700777077700000077700000000000000000000000
00000000000009777667770777007770777667770007770077766777077700000000000000c77706666077700777077700000077766661000000000000000000
00000000000009777777770777007770777777770007770077777777077700000000000000c7770777707770077707770000007777777c000000000000000000
00000000000009777777770777007770777777770007770077777777077700000000000000c7770777707770077707770000007777777c000000000000000000
00000000000009777000000777007770777777000007770077700777077700000000000000c77700777077700777077700000077700000000000000000000000
00000000000009777000000777007770777777600007770077700777077700000000000000c77700777077700777077700000077700000000000000000000000
00000000000009777000000777007770777777760007770077700777077700000000000000c77700777077700777077700000077700000000000000000000000
00000000000009777000000777667770777077776007770077700777077766664000000000c77766777077766777077766666077700000000000000000000000
00000000000009777000000777777770777007777007770077700777077777779000000000c77777777077777777077777777077700000000000000000000000
00000000000009777000000777777770777000777007770077700777077777779000000000c77777777077777777077777777077700000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777770000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777777777000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007777777777700000
00000000666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007777777777700000
00000000666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777777777770000
00000000666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777777777770000
00000000666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777777777770000
00000000666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777777777770000
00000000666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777777777770000
00000000666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007777777777700000
00000000777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007777777777700000
00000000555555555000000066666667555555557666666955555555966666675555555576666666000000000000000000000000000000000777777777000000
00000000555555555000000066666667555555557666666955555555966666675555555576666666000000000000000000000000000000000077777770000000
00000000555555555000000066666667555555557660006955555555960006675555555576666666000000000000000000000000000000000000777000000000
000000005555555550000000666666675533b55576666069557aa55596660667557aa55576666666000000000000000000000000000000000000000000000000
0000000055533b5550000000666666675537b5557660006955999555966006675599955576666666000000000000000000000000000000000000000000000000
0000000055537b55500000006666666755bbb5557660666955555555966606675555555576666666000000000000000000000000000000000000000000000000
00000000555bbb555000000066666667555555557660006955555555960006675555555576666666000000000000000000000000000000000000000000000000
00000000555555555000000066666667555555557666666955555555966666675555555576666666000000000000000000000000000000000000000000000000
000000005555555550000000666666669999999966666d667777777766665666cccccccc66666666000000000000000000000000000000000000000000000000
0000000055555555500000006666666666666666666e6d666666666666d656666666666666666666000000000000000000000000000000000000000000000000
0000000055555555500000006666666666600666666e6d666666666666d656666660606666666666000000000000000000000000000000000000000000000000
000000005557aa5550000000666666666666066eeeee6dddddddddddddd655555660606666666666000000000000000000000000000000000000000000000000
00000000555999555000000066666666666606666666666666666666666666666660006666666666000000000000000000000000000000000000000000000000
0000000055555555500000006666666666660666aaaaaaaaaaaaaaaaaaaaaaaaaa66606666666666000000000000000000000000000000000000000000000000
00000000555555555000000066666666666000666666666666666666666666666666606666666666000000000000000000000000000000000000000000000000
00000000555555555000000066666666666666666666666666666666666666666666666666666666000000000000000000000000000000000000000000000000
00000000555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666000666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666660666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666000666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666066666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666000666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff66666666666666666666
66666666666666666666ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff44444444444444444444447aa444444444444444777444444444444444a9944444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444447aaaaaa44444444444777777744444444444a999999444444444444444444444ff66666666666666666666
66666666666666666666ff44444444444444444447aaaaaaaa444444444777777777444444444a9999999944444444444444444444ff66666666666666666666
66666666666666666666ff4444444444444444447aaaaaaaaaa4444444777777777774444444a99999999994444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444aaaa99aaaaa4444444777766777774444444999922999994444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444447aaaa999aaaaa44444777776667777744444a999922299999444444444444444444ff66666666666666666666
66666666666666666666ff44444444444444444aaaaa9999aaaa444447777766667777444449999922229999444444444444444444ff66666666666666666666
66666666666666666666ff44444444444444444aaaaa9999aaaa444447777766667777444449999922229999444444444444444444ff66666666666666666666
66666666666666666666ff44444444444444444aaaaa9999aaaa444447777766667777444449999922229999444444444444444444ff66666666666666666666
66666666666666666666ff44444444444444444aaaaa999aaaa9444447777766677776444449999922299992444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444aaaa99aaaaa4444444777766777774444444999922999994444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444aaaaaaaaaa94444444777777777764444444999999999924444444444444444444ff66666666666666666666
66666666666666666666ff4444444444444444444aaaaaaaa944444444477777777644444444499999999244444444444444444444ff66666666666666666666
66666666666666666666ff44444444444444444444aaaaa99444444444447777766444444444449999922444444444444444444444ff66666666666666666666
66666666666666666666ff4444444444444444444444aa944444444444444477644444444444444499244444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444464644444444444444466644444444444446644666444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444474744444444444444477744444444444447744777444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444476744444444444444476744444444444444744667444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444477744444444444444477744444444444444744777444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444744444444444444476744444444444446764766444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444744444444444444477744444444444447774777444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444446444666464646664644444446644444446646444666466646664666466444644444444444ff66666666666666666666
66666666666666666666ff444444444447444777474747774744444447744444467747444777477747774777477644744444444444ff66666666666666666666
66666666666666666666ff444444444447444764474747644744444444744444474447444764476747674764474744744444444444ff66666666666666666666
66666666666666666666ff444444444447444774476747744744444444744444474447444774477747764774474744744444444444ff66666666666666666666
66666666666666666666ff444444444447664766477747664766444446764444476647664766474747474766476744644444444444ff66666666666666666666
66666666666666666666ff444444444447774777447447774777444447774444447747774777474747474777477744744444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444446664466466646664666464444664444444446664444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444447774677477747774777474446774464444447774444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444447674747476744744767474447664474444447474444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444447774747477644744777474447774464444447474444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444447444767474744744747476646674474444447674444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444447444774474744744747477747744444444447774444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444443bb4444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff4444444444444444444444444444444444444437b4444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444443cb4444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444c44444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444c44444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444144444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444666666666666666666666666641c14444444446666666666666666666664444444444444ff66666666666666666666
66666666666666666666ff444444444444655555555555555555555555644144444444446555555555555555555564444444444444ff66666666666666666666
66666666666666666666ff444444444444655555555555555555555555644444444444446555555555555555555564444444444444ff66666666666666666666
66666666666666666666ff444444444444655777577757775777575755644444444444446557755777575757775564444444444444ff66666666666666666666
66666666666666666666ff444444444444655757575555755757575755644444444444446557575755575755755564444444444444ff66666666666666666666
66666666666666666666ff444444444444655775577555755775577755644444444444446557575775557555755564444444444444ff66666666666666666666
66666666666666666666ff444444444444655757575555755757555755644444444444446557575755575755755564444444444444ff66666666666666666666
66666666666666666666ff444444444444655757577755755757577755644444444444446557575777575755755564444444444444ff66666666666666666666
66666666666666666666ff444444444444655555555555555555555555644444444444446555555555555555555564444444444444ff66666666666666666666
66666666666666666666ff444444444444655555555555555555555555644444444444446555555555555555555564444444444444ff66666666666666666666
66666666666666666666ff444444444444666666666666666666666666644444444444446666666666666666666664444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ff444444444444444444444444444444444444444444444444444444444444444444444444444444444444ff66666666666666666666
66666666666666666666ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff66666666666666666666
66666666666666666666ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff66666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666

__gff__
0001010101010101010101010101010101000000000000000000000000010000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0207070707070707070707070707070202020202020202020202020202020202020202020202020202020202020202020207070707070702020707070707070202070707070707070707070707070702020202020202020202020202020202020207070707070707070707070707070202020202020707070707070202020202
0600000000000000000000000000000802020202020202020202020202020202020202020202020202020202020202020600000000000008060000000000000806220000000000000000000000000008020202020202020202020202020202020600000000000022220000000000000802000000000000000000000000000002
06000000000000000000000000000008020202020202020202020202020202020207070707070707020707070707070206000000000000080600000000000008060022000000000000000000000000080202020622222222222222220802020206000d0505050e00000d0504050e000802000000000000000000000000000002
0600000000000000000000000000000802020202020202020202020202020202060000000000000003000000000000080600002222000008060000222200000806000022000000000000000000000008020202070707070707070707070202020600080622080600000802220206000802000000000000000300000000000002
0600000000000000000000000000000802020202020707070707070202020202060000002222000003000000000000080600002222000008060000222200000806000000220000000000000000000008020206000000000000000000000802020600080202020600000802050206000806000000000000000300000000000002
060000000000000000000000000000080202020206222222222222080202020202040404040c000003000000000000080600000000000008060000000000000806000000002200000000010000000008020206000000000000000000000802020600100707070f0000100707070f000806000000000122220322010000000008
0600000000000000000000000000000802020202062222222222220802020202060000000000000003000022220000080600000000000008060000000000000806000000000022000000000000000008020206000000000000000000000802020622000000000022220000000000220806000000002200000300220000000008
06000000000000000000000000000008020202020622220d0e22220802020202060000000000000003000022220000080205050505050502020505050505050206000000000000220000000000000008020206000000000000000000000802020622000000000022220000000000220806000000002200000000220000000008
0600000000000000000000000000000802020202062222100f222208020202020600000022220000030000000000000802070707070707020207070707070702060000000000000022000000000000080202060000000000000000000008020206000d0505050e00000d0505050e000806000000000122222222010000000008
0600000000000000000000000000000802020202062222000022220802020202060000000a0404040f000000000000080600000000000008060000000000000806000000000000000022000000000008020206000000000000000000000802020600080207020600000802020206000806000000000000000000000000000008
0600000000000000000000000000000802020202062222000022220802020202060000000000000000000000000000080600000000000008060000000000000806000000000100000000220000000008020206000000000000000000000802020600080222020600000806220806000802000000000000000000000000000008
0600000000000000000000000000000802020202020505050505050202020202060000000000000000000000000000080600000000000008060000222200000806000000000000000000002200000008020206000000000000000000000802020600080205020600000802020206000802000005222204040404040000000002
0600000000000000000000000000000802020202020202020202020202020202060000000000000000000000000000080600000000000008060000222200000806000000000000000000000022000008020206000000000000000000000802020600100707070f0000100707070f000802000000000000000000000000000002
0600000000000000000000000000000802020202020202020202020202020202020505050505050505050505050505020600000000000008060000000000000806000000000000000000000000222208020202050505050505050505050202020600000000000022220000000000000802000000000000000000000000000002
0600000000000000000000000000000802020202020202020202020202020202020202020202020202020202020202020205050505050502020505050505050202050505050505050505050505050502020202020202020202020202020202020205050505050505050505050505050202050505050505050505050505050502
0205050505050505050505050505050202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202070707070707070707070707070702020707070707070707070707070707020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020206002200000000000000000000220008060000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0206000000000000000000000000080206000200220000000000002200020008062200220000222200002200002200080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0206000022002200000000000000080206000200020022000022000200020008062200220022000022002200002200080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0206000000010000000000000000080206000200020002000002000200020008062200220022000022002200002200080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0206000022002200002200220000080206000200020002000002000200020008060022000022000022002200002200080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0206000000000000000001000000080206000200020002000002000200020008060022000022000022002200002200080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0206000022002200002200220000080206000200020002000002000200020008060022000000222200000022220000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0206000000010000000000000000080206000200020002000002000200020008062200220022002200220000000022080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0206000022002200002200220000080206220222022202000002220222022208062200220022002200222200000022080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0206000000000000000001000000080206000200020002000002000200020008062200220022002200220022000022080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0206000000000000002200220000080206000200020002000002000200020008062200220022002200220000220022080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0206000000000000000000000000080206000200020002000002000200020008062200220022002200220000002222080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0206000000000000000000000000080206000200020002000002000200020008060022002200002200220000000022080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202050505050505050505050505020202050205020502050502050205020502020505050505050505050505050505020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010800001175512755137551475515755167551775518755197551a7551b7551c7551d7551e7551f755207552175522755237552475525755267552775528755297552a7552b7552c7552d7552e7552f75530755
010a00003c55300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000307503c755000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000e61500600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000073130731000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
310800000462404624046240462404624000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5d0800001c220182001c2201c2201c2201c2251820018200202301820020230202302023020235182001820023240000002324023240232402324518200182001820018200182001820018700187001870000700
011200000d1500d1500e1510e1550010000100091500915009150091500915009150091550070000700001000d1500d1500e1510e150091500915008150081500815008150081500815008155001000010000100
011200001015010150111511115503100031000c1500c1500c1500c1500c1500c1500c155037000370003100101501015011151111500c1500c1500b1500b1500b1500b1500b1500b1500b155031000300003000
011200000000000000000000000000000000001515015155151501515514150141501515115150151501515015155000000000000000000000000015150151551515015155171501715015150151501415014150
011200001415014150141501415500000000001515015155151501515514150141501515115150151501515015155000000000000000000000000015150151551515015155171501715015150151501415014150
__music__
00 07424344
00 07424344
00 08424344
00 07424344
00 07094344
00 070a4344

