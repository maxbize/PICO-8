--keep: driftmania
--keep: by max bize

--------------------
-- Global State
--------------------
local objects = {}
local player = nil
local level_m = nil
local trail_m = nil
local particle_vol_m = nil
local particle_water_m = nil
local customization_m = nil
local game_state = 3 -- 0=race, 1=customization, 2=level select, 3=main menu
local level_index = 1
local pause_frames = 0
local camera_x = 0
local camera_y = 0
local menu_anim_frame = 21 -- menu transition animation
local menu_anim_cb = nil -- delayed button press processing

-- Current map sprites / chunks. map[x][y] -> sprite/chunk index
local map_road_tiles = nil
local map_road_chunks = nil
local map_decal_tiles = nil
local map_decal_chunks = nil
local map_prop_tiles = nil
local map_prop_chunks = nil
local map_bounds_chunks = nil
local map_settings = nil
local map_checkpoints = nil
local map_jumps = nil
local map_jump_frames = nil

-- Ghost cars
local ghost = nil
local ghost_recording = {}
local ghost_playback = {}
local ghost_best_time = 0x7fff
-- Allocate buffers on init (256 KB per buffer)
for i = 1, 0x7fff do
  add(ghost_recording, -1)
  add(ghost_playback, -1)
end

-- Settings
cartdata('mbdriftmania1')
local ghost_enabled = dget(10) == 0

--------------------
-- Token saving convenience methods
--------------------

-- Creates a table of [v]=true
function parse_hash_set(csv)
  local t = {}
  for num in all(split(csv)) do
    t[num] = true
  end
  return t
end

-- Creates a table of [v1]=v2
function parse_hash_map(csv)
  local t = {}
  local csv_arr = split(csv)
  for i = 1, #csv_arr, 2 do
    t[csv_arr[i]] = csv_arr[i+1]
  end
  return t
end

-- Creates a table of [header]=val
function parse_table(headers, csv)
  local t = {}
  local headers_arr = split(headers)
  local csv_arr = split(csv)
  for i = 1, #headers_arr do
    t[headers_arr[i]] = csv_arr[i]
  end
  return t
end

-- Creates a list of tables of [header]=val
-- Assume obj separator is '|' and that the first entry is empty
function parse_table_arr(headers, csv)
  local a = {}
  local csv_arr = split(csv, '|')
  for i = 2, #csv_arr do
    add(a, parse_table(headers, csv_arr[i]))
  end
  return a
end

-- Jumps is a table<int, table<int, int>>. Usage: jumps[x][y] = jump_id
-- Ex in:  " 19 |  13, 1, 22, 2 | 20 |  13, 1, 22, 2 "
-- Ex out: {[19]={[13]=1,[22]=2},[20]={[13]=1,[22]=2}}
function parse_jumps_str(s)
  local a = {}
  local csv_arr = split(s, '|')
  for i = 2, #csv_arr, 2 do
    a[csv_arr[i]] = parse_hash_map(csv_arr[i+1])
  end
  return a
end

-- Parse a string of multiple things through func with args1/2
--function parse_multi(s, func, arg1, arg2)
--  local a = {}
--  local csv_arr = split(s, '$')
--  for i = 2, #csv_arr do
--    add(a, func(csv_arr[i], arg1, arg2))
--  end
--  return a
--end

--------------------
-- Data
--------------------
local map_road_data = {
  "0ス3143510I61117111810I6191:1;1810I61810161810H<1=1810161810=314:>111810161810=6111?1@:A10161810=6191B10;<1=1810=618101314:>111810=6181016111?1@:A10=6181016191B10H61810161C1D10H6181016111E144510C618101F1@4G111810C618106H1;1810C61810761810C61C1D105<1=1810C6111E145>111810CF1@9A10ヨ", -- A1.tmx road
  "0ひI145J10FI111K1@3L111J10DI111M1N103O1P111J10C61Q1N105O1R1810C61810761810C61810761810C61S1T105U1V1810CW111X1T103U1Y111Z10DW111X1T101U1Y111Z10FW111[1D1\\111Z10H]1^1_1`1a10Ib1c1^1_1d10HI111e1H1;1X1T10FI111M1N101W111X1T10DI111M1N103W111X1T10C61Q1N105W111f10C61810761810C61810761810C61810761810C61C1D105<1=1810C6111E145>111810CF1@9A10ね", -- A2.tmx road
  "0…314@510<6111?1@<G111810<6191B10<H1;1810<61810>61810<61810>61810<61810=<1=1810<618101314;>111810<6181016111?1@;A10<6181016191B10H61810161810I61810161810I618101g111J10H618101O1P111J10G618102O1P111J10F618103O1P111J10E618104O1P111J10D618105O1P111J10C618106O1P111J10B618107O1P111J10A618108O1P111J10@618109O1R1810@61C1D108<1=1810@6111E148>111810@F1@<A10⬆️", -- A3.tmx road
  "0★U1h147J10CU1Y111@5G111810BU1Y111Z105H1;1810Bi111Z10761810B61810861810Bg111J10761810BO1P111J10661C1D10BO1P111J1056111E144J10>O1P111J104F1@4G111810?O1R18109H1;1810@618109U1V1810@618108U1Y111Z10@6181013146j111Z10A6181016111?1@5Z10B6181016191B10G<1=1810161810E3142>111810161810E6111?1@2A10161810E61k1l103<1=1810E6111E143>111810EF1@7Z10リ", -- A4.tmx road
  "0⁙I149J10C6111?1@5G111810C6191B105m1n1810C618101I144>111810C6181016111?1@4Z10C6181016191B10H61810161810;I144J10861810161810;6111?1G1118107I111o10161810;6191B1H1;18106I111M1N1U1V1810;618102618105I111M1N1U1Y111Z10;61810261C1D103I111M1N1U1Y111Z10<6181026111E14311M1N1U1Y111Z10=618102W1@5p1N1U1Y111Z10>61C1D108U1Y111Z10?6111E148j111Z10@W1@;Z10ラ", -- B1.tmx road
  "0oI142J10J6113J10I6114J10HW115J10HW115J10HW115J10HW11548J10@W114@6G111810AW112Z106H1;1810B61810861810B61810861810BF1A10861810L61810L61810B31510861810BF1A10861810K<1=1C1D10D3145>112E145J10>F1@5G112?1@3G111810DH1;191B103H1;1810E61810561810E61810561810E61810561810E61C1D103<1=1810E6111E143>111810EW1@7Z10n", -- B2.tmx road
  "0▤U1h143J10GU1Y111@2L111J10EU1Y111Z102O1P111J10CU1Y111Z104O1P111J10>3143j111Z106O1P111J10=F1@4Z108O1R1810L61810BI145510361810AI111K1@2G111810361810@I111M1N102H1;1810361810=314211M1N103<1=1810361810=F1@2p1N101q142>1118103g111J10B6111?1@2A103O1P111J10A6191B107O1P111J10@618109O1P111J10?61810:O1P1Z10?61C1D10:r10@6111E141s1T10HW1@311X1T10KW111X1t10KW1Z10モ", -- B3.tmx road
  "0(I145J10FI112@312J10E6111Z103W111810E61C1D10461810E6111E14251016181013144510>F1@4A101618101F1@2G111810E618104H1;1810E618104<1=1810@314251016181013142>111810@6111?1A101618101F1@4A10@6191B10261810G61810361810G61C1D101<1=1810G6111E141>111810GF1@5A10▮", -- B4.tmx road
  "0みU1h141s1T10HU1Y111u111f10GU1Y111Z10161810Fv1w1@1Z10261810L61810;U1h146x1U1h141y1I141510161810;i111?1@4z1{1w1@1Z1|1G111810161810;6191B10:H1;1810161810;618104U1h141y10461810161C1D10:618103U1Y111Z1056181016111E143510661C1D101U1Y111Z106618101F1@4118106g111E141j111Z107618105U1V18106O1}1@3Z108F1A104U1Y111Z10IU1Y111Z10@314251013151013141j111Z10A6111?1A101F1A101F1@2Z10B6191B10K61810331510G61810361810G61C1D101<1=1810G6111E141>111810GF1@5A10は", -- C1.tmx road
  "0TI144s1T10FI111K1@311X1T1033143510<I111M1N103W111f10361117111810;I111M1N104<1=181036191:1;1810:I111M1N102U1h141>111810361810161S1T10961Q1N102U1Y111@3A103618101W111X1T108618103i111Z107618102W111X1T10761810361C1D107618103W111f1076181036111E142s1T103618103U1V1S1T106618103F1@411X1T102618102U1Y112X1T10561C1D107W111X1T101618101U1Y111~1○111X1T1046111E1455102W111X1T1618101i111Z102W111f104F1@7A103W111█111810161810461810AW1@2A10161810461810F61810461810Fg111J102I111o10FO1P111▒1🐱111M1N10GO1R112M1N10H<1=111Q1N10H31>112810I6111?1@1A10I61k1l10K6111E143510B⬇️141J102F1@3G111810BO1P111J105m1n1810CO1P11145>111810DO1}1@7A10o", -- C2.tmx road
  "0~31510LF1A10✽31510LF1A10H31510831510BF1A108F1A10せ31510LF1A10f31510LF1A10え31510LF1A10…31510LF1A10ˇ", -- C3.tmx road
  "0ᶠI142s1T10I6111?111X1T10H6191B1W111f10G<1=1810261810B<1░143>111810261810B✽111?1G113810261810B6191B1H1;112810261810B6181026112810261C1D10A61810261128102F1G1E142510>61810261128103H1;112810>618102●112♥103I111K1@1A10>618102H1☉1z1B102I111M1N10@g111J106I111M1N10AO1P111J104I111M1N10CO1P1114411M1N10EO1}1@4p1N10ᶠ", -- D1.tmx road
  "0チq1s1T10I<1d1W111X1T10G<1웃1X1⌂1⬅️111😐10F<1웃111♪1B1🅾️111😐10E<1웃111♪1B1I111M1N10D<1웃111♪1B1I111M1N10D<1웃111♪1B1I111M1N10D<1웃111♪1B10161Q1N10D<1웃111♪1B10261810D<1웃111♪1B10361810?U1h143>111♪1B10461810>U1Y111@4z1B10561810=U1Y111Z10;61810<U1Y111Z105I143J10261810<◆111…105I111M1➡️111810261810<◆111★104I111M1N10161810261810<O1P111J102I111M1N102g111J1<1=1810=O1P111▒1🐱111M1N103O1P111>111810>O1P112M1N105O1}1@2Z10?O1⧗2N10セ", -- D2.tmx road
  "0□3141510K6111810JU1V171S1T10Ii191:1;1f10>I148J10161810161810>6111?1@4G111810161810161810>6191B104m1n18101618101g111J10=618101I143>1118101618101O1P111J10<6181016111?1@3Z101618102O1P11144J10761810161k1l104<1=18103O1}1@2G11181076181016111E144>1118107🅾️111o107618101W1@8Z106I111M1N10761C1D10?I111M1N1086111E14?11M1N109W1@Ap1N10&", -- D3.tmx road
  "0|U1h144s1T10EU1Y116X1T10Di113?1G113f10D611291B1H1;112810D611281026112810D611281026112810DW112Z1026112810E6181036112810E6181036112810E6181036112810DI111o1036112810=314611M1N1036112810=F1@6p1N1046112810J6112810J6112810JW112Z10:31J10?61810;61810?61810;61810>U1V1810;61810=U1Y111Z10;61810<U1Y111Z10<61810<i111Z10=61810<61810>618101I148J10161810>6181016111?1@4G111810161810>61C1⬆️1=191B104H1;1C1⬆️1=1810>W1@1ˇ1@1Z106W1@1ˇ1@1Z10W", -- D4.tmx road
--  "0🅾️314F5106611F8106611F8106611F8106611F8106611F8106611F8106611F8106611F8106611F8106611F8106611F8106611F8106611F8106611F8106611F8106611F8106611F8106611F8106611F8106611F8106611F8106611F8106611F8106F1@FA10n", -- WIP1.tmx road
}
local map_decals_data = {
  "0ヲ310K415161710J4102410I819102410D:104;10D<1=201:10H51>10;81910J?2;1@10C<10:A10A51>10LB1C10MD1?20NE10FF106G1710EF107410EB1C10581910FD103?2;1@10NA10ヨ", -- A1.tmx decals
  "0*H207I20りJ1K10LL1M10そN1O10LP1Q10DI20MF10MF10MB1C10581910FD103?2;10カ", -- A2.tmx decals
  "0∧R10I<1=201R108E10?51>10<G1710M410M410=S1T10=81910J?2;10C<10L51>10LF10MF10ちU1V10LW10くF10MF109X1Y10BB1C10881910CD1:105?2;10E:10お", -- A3.tmx decals
  "0はZ101=2E10MG1710D[1\\10L]1^108_10D`108F10MB1C10La1D10Kb102c1=1E10K`101G1710_H20Od10N@1<1=2Z10Ee10351>10G81910J?2;103410Gf1g10441h10Fi1j10381910Gk1l1?201;10⁙", -- A4.tmx decals
  "0。m10E<103=2E1a10E51>105n1o10EF106;10FF103<1=20FH20251>10Kp1q10Lr1s10=<1E10K51>1G171F10IF1t1u101F10IF1v1w101B1C10MD1O1x10Ly1z10FB1C10La1D1?20I{10◜", -- B1.tmx decals
  "0🅾️81C10LG1|1C101}10KX1~10La10L{10xE10MG1710M410C○1█108410C▒1🐱108⬇️1░10B✽1g108●1♥10B☉1웃10M5108⌂1⬅️10CB108😐1♪10B✽1🅾️1◆10K…121➡️1D107★10B⧗1⬆️1ˇ104∧106=2E10MG1710F⬇️1░10L●1♥105410M410GB1C10381910HD1?201;1@10N❎10n", -- B2.tmx decals
  "0/0_▤1I2▥10@H20D=2E10MG1710L81910L;1@10K<1=2A10I51>10LF10MF10MB1C10MD10にあ10MR10MR10Mい10r", -- B3.tmx decals
  "0/0Gう10Mえ1お101か10JB1C101き10KD1?205く1け103こ10Hさ1し101E1a10Jか101G1710Jき10181910Cす1x105?2;10Dせ1z10K51>102410IF103410IB1C10181910Ia1D1?1;10Ib10◀", -- B4.tmx decals
  "0セそ10Lた101410Hち1つ1て1t1u1410Gと1な1に101v1w1410Bぬ1ね101の1は1ひ1ふ1へ101こ10@<102ほ1ま1み1む1め1も1や1ゆ1よ1a10@51>104ら1り1る101k1れ1ろ1710@F10@B1C10;F103わ10<a1D1?209B1C101を101ん10:b103=10:D1?1っ109r1s105を1ゃ10E[1ゅ104を1>10Fょ1ア104>10Dx1f1イ1ウ1エ1オ1に10Gカ1キ1ク1ケ1コ1キ1サ10F51>102シ1ス10HF103セ1ソ10HF103410IB1C10181910Ia1D1?1;10Ib10み", -- C1.tmx decals
  "0v=10Nタ107310E8191055161710D;106F10E=107F104m10?チ10<a10?B1C10MD101R10;ツ1テ10@R10EB1C109G1ト107ナ1ニ108a1D1?208G1ト1410>b10=ヌ10%<1=10Kネ1ノ10MD101R10K=2ハ10Mn1o10Fヒ102フ101フ1ヘ10Jホ101ホ1:10q", -- C2.tmx decals
  "0~R10MR10♥R10MR10Rd10CH209A10せR10MR10hこ10Lb10かR10MR10➡️R10MR10ˇ", -- C3.tmx decals
  "0/00<10L51>1タ10KF102410JF10H<1E10K51>1G17101マ1I102I20CF103ミ10IF103ミ105E10Gム1メ104G1モ1ヤ10Lユ1;10Kユ10Lユ10Lユ10H:103ユ10I:10⁘", -- D1.tmx decals
  "0ンヨ1イ10Mラ10Lを1>10Kを1>1リ1⬅️10J>1ル1@1レ10Kロ1ワ1❎10E★1ヲ10Kン1P1ッ10J★1ヲ1ャ10KP1ッ10Eュ1ョ1⬅️10K◜1@1◝10Kロ1\00010L¹108²104410?³1⁴1084103410@⁵1⁶101チ105⁷10281910A⁸1\t106X102;10ᶜ", -- D2.tmx decals
  "0⁙\n10Mᵇ10Mᶜ10M61710JH20C<1=20J51>104\r1ᵉ1ᶠ10I?2;103410M410E\r1ᵉ1ᶠ104819108E10:F103D1?202;109▮10:F10Aチ10;B1C1\n105\n105\n103@10;a1D1■105■105■104❎109{105□105□10G`105`10ᶠ", -- D3.tmx decals
  "0か\n10Kみ1む1■10Kら1り1⁙10l⁘1‖10LL1◀10Fの1K10L▶1「10QI40♥⁘1‖10LL1◀10w」1░10L¥1•10j、1。10L、1。10LI20mチ1゛1゜103:104410B41 104:104410@B1!19108B1!1910A\"10:\"10Y", -- D4.tmx decals
--  "0/0K'10M(1)101*101*101*101*101*101*10@(1)101*101*101*101*101*101*10@+102*101*101*101*101*101*10C*101*101*101*101*101*10C*101*101*101*101*101*10C*101*101*101*101*101*10C*101*101*101*101*101*10C*101*101*101*101*101*10C*101*101*101*101*101*10C*101*101*101*101*101*10/0a", -- WIP1.tmx decals
}
local map_props_data = {
  "0み1125310G4105410G4105410G41025102410G41024102410;112;61024102410;410>4102410;410>4102410;4102112;6102410;4102410>410;4102410>410;41024102712;610;410241028125310A41024108410A41024108410A410291253102410A410241054102410A4102:1256102410A410;410A410;410A:12;610キ", -- A1.tmx props
  "0∧;125<10F=1>105?1@10D=1>107?1@10BA1>10211233102?1B10A4102116103:13102410A410241054102410A410241054102410A4102:13103116102410AC1D102:13101116102E1F10BG1D102:1H16102E1I10DG1D102J102E1I10FG1K1D1?1@1E1I10G=1>1G1D1?1L1310F=1>102M102:1310D=1>10211N1D102:1310BA1>102116101G1D102:1310A4102116103G1D102410A41024105M102410A410241054102410A410241054102410A4102:1256102410A410;410A410;410A:12;610★", -- A2.tmx props
  "0q112B310:410B410:410B410:4103;129O104410:4102A1>1094104410:4102410:4104410:4102912:P104410:4102410?410:4102410?410:41024103712;610:41024103410F41024103410F41024103J10F4102Q1D102?1@10E410241G1D102?1@10D41024101G1D102?1@10C41024102G1D102?1@10B41024103G1D102?1@10A41024104G1D102?1@10@41024105G1D102?1@10?41024106M103?1B10>4102C1D1054104410>4103R125P104410>410>410>410>410>:12>610u", -- A3.tmx props
  "0t1128<10C116108?1B10A11610:410@116102E1S124O102410@4102E1I1054102410@4102T1064102410@4102?1@1054102410@:13102?1@10441028124<10<:13102?1@1034107?1B10<:13102?1B1024108410=:131024102:125O102410>41024107116102410>410291276102E1F10>41024109E1I10?41024108E1I10@410241027125U10=1123P1024102410C41064102410C41064102410C4102V123P102410C4109410C4108E1F10C:128U10コ", -- A4.tmx props
  "0レ;129<10BA1>109?1B10A410;410A4102E1S124W102410A4102X108410A41024107E1F10A410241021124U105;124<107410241024109A1>104?1B106Y1024102410941064105=1>10241024109410271O1024104=1>1021161024109410242024103=1>102116102E1F10941024202:122Z1>102116102E1I10:41024208116102E1I10;41024207116102E1I10<4102:1[1276102E1I10=410=E1I10>C1D10;E1I10@R12;U10ケ", -- B1.tmx props
  "0Q;122<10IA1>102?1@10H4101E1D101?1@10G4101?1\\1D101?1@10FC1D101?1\\1D101?1@10FG1D101?1\\1D101?1@10FG1D101?1\\1D101?1]127<10>G1D101?1\\1D109?1B10>G1D101?1\\1D109410?G1D101?1^1263102410@M10241064102410@410241064102410@410241064102410@410241064102410@410241064102410@410241064102410@410241064102410@4102:1266102:125<10:410B?1B109410C4109:129310211233102410C410241034102410C410241034102410C410241034102410C4102:1236102410C4109410CC1D107E1F10DR127U10P", -- B2.tmx props
  "0z1124<10G116104?1@10E116106?1@10C116102E1S1213102?1@10;11266102E1I102:13102?1@109116108E1I104:13102?1B107116108E1I106:1310241074102E1S125_1263101410241074102X105=1>1064101410241074102J104=1>1074101410241074102?1]122Z1>1021122O102410141024107:13108`1a122P10241014102J108:1310611b10641014102?1@108:1266141064101:13102?1@10?410271236102:13102?1@10>41024107:13102?1@10=41024108:13102?1B10<410281223106:13102410<4105:131064102410<C1D105:131054102410=R122c1D102:131044102410AG1D102:131034102410BG1D102:1236102410CG1D108410DG1D106E1F10ER126U10m", -- B3.tmx props
  "0\n;125<10F=1>105?1@10DA1>107?1B10C4102E1d3D102410C4102e123f1029126310<410641024106410<410641024106410<:126g1029123O102410>1124g1029123P102410>410441024106410>410441024106410>41027121g1029126610>410241014102410E41028121P102410E4107410E4107410E:127610ヨ", -- B4.tmx props
  "0い1123310H116103:1310F116105410E116102E1h102410D116102E1I14102410:11296103e121g102410911610?41024109410@4102410941021123i103E1S12131024102410941024102116102E1I10241024102:124310441024101116102E1I1034102410741044102:1216102E1I1044102410741044106E1I10541029123i1034104:13104E1I10641024102116102E1F105:124U1021124P10281226102E1I10>410<E1I10?410;E1I10@41027121O1027123U10A410241014102410E410241014102410E41028121P102410E4107410E4107410E:127610⬆️", -- C1.tmx props
  "06;125310F=1>105:131021125310;=1>107:131014105410:=1>1021122c1D102410141054109=1>10211611122j1024101410251024108A1>1021161116105410141024102:131074102116111610641014102Q1D102:13106410241014102E1S1236101410241G1D102:13105410241014102e123310241024101G1D1024105410241014106:131014102410111k102:13104410241014107:131410241116104:131034102:121[124c1D102:1l102m16102E1D102:13102410:G1D1054102E1I1G1D1024102410;G1D1044102X102M1024102:128<103G1D103410241024102410;?1@103G1n122g102J102Y102410<?1@103G1D1014102?1@1=1>102410=?1@103M101:13102?1>10211610>?1B1024102:1310411610@410241017121P10311610A410241014105410B410241014105410B410241014102V122o121310@4102J1014107410@4102?1@14107410@:13102?1p124W102410A:1310:410B:13109410C:129610P", -- C2.tmx props
  "0Y;12:<10AA1>10:?1B10@410<410@4103;122q122O102410@4102A1>102:131014102410@41024104:1314102410@41024105:1l102410@41024102r1D105410@4102410241G1D104410@410241024101G1D102E1F10@410241024102R122U10A410241028127<10>116102410:?1B10<116102E1s10;410;116102E1I1?1t125u1213102410:116102E1I101116105?1B141024109116102E1I101116107420241094102E1I101116102E1S1i103420241094102?1@1116102E1I1116102E1F1Y1024109:13102?1v102E1I1116102E1I1=1>102410::13104E1I1116102E1I1=1>10211610;:13102E1I1014102E1I1=1>10211610=:122U1024102X1=1>10211610D4102w1>10211610E410511610F410411610GC1D10211610IR122610Y", -- C3.tmx props
  "0ヨ;123310HA1>103:1310G4105:1310F4102r1D102410AE1S122c1x10241M102410@E1I104y1z1014202410@X105{1|1014202410@410271O101{1|1014202410@41024201{1|10142028123310<41024201{1|1014206410<41024201}1~101418121○1█1▒102410<410241J104Y101=1>104410<4102J1?1@102=1>1=1>1021122610<4102?1@1?1]1Z1>1=1>10211610?:13102?1]122Z1>10211610A:1310811610C:1310611610E:126610ヨ", -- D1.tmx props
  "0やE1S121310IE1I102:1310GE1I104:1z10EE1I106|10DE1I103=103|10CE1I103=1>10211k10BE1I103=1>10211610BE1I103🐱1>10211610BE1I103=1⬇️10211610BE1I103=1>14102410>1124U103=1>1014102410=116107=1>1024102410<116107=1>1034102410;116102E1S123░1✽122<1014102410:●16102E1I103=1>103?1B14102410:{103♥103=1>1054202410:{103:13101=1>10211☉102J14102410:웃13103:1⌂1>10211614102?1⬅️102410;:13106116101:13105410<:13104116103:13103E1F10=:13102116105:123U10?😐1♪2🅾️10め", -- D2.tmx props
  "0リ1123310I4103410I41015101410H1161014101:1310=;128<141024102410<A1>108?1◆1024102410<410:41024102J10<4102E1S124W10141024102?1@10;4102X1074102…13102?1]123<10641024107Y10241:13106?1B10541024101V124Z1>1024101:1310641054102410:4102:122➡️10341054102J10:4104=1>1021161054102?1]129[123Z1>102116106410D116107C1D10B116109R12B610⁸", -- D3.tmx props
  "0^1126310E116106:1310C116101E1★1⧗2⬆️1D101:1310B4101E1ˇ1>102?1\\1D101410B4101{1|10171O101{1|101410B4101{1|1014201∧1❎101410B4101}1~1014201|1{101410BC1D102E1F14101▤1▥101410CM102X1014104410C410241014104410CY10241014104410;1126Z1>10241014104410;41091161014101あ1い101410;41081161024101|1{101410;:12861034101▤1▥101410H410441081121<10=C1D102E1F1084101?1B10=M102X1094102410=410241094102410<11610241094102410;116102E1F1094102410:116102E1I10:4102410:4102E1I10;41029129<14102X10<41024109?1◆102410<4102410:4102410<4102う1027124O102う102410<C1D103E1F104C1D103E1F10=R123U106R123U109", -- D4.tmx props
--  "0/0K21C10☉21C10/0/0@", -- WIP1.tmx props
}
local map_bounds_data = {
  "1/1/1/1ほ", -- A1.tmx bounds
  "0∧170F190D1;0B1=0A1503150A1405140A1405140A1503150A1601160B1;0D190F170G170F190D1;0B1601160A1503150A1405140A1405140A1405140A1=0A1=0A1=0A1=0★", -- A2.tmx bounds
  "1/1/1/1ほ", -- A3.tmx bounds
  "1/1/1/1ほ", -- A4.tmx bounds
  "0レ1;0B1=0A1=0A1=0A1=0A1=0A1<051607170918061709180518091804190918031:091D0:1C0;1B0<1A0=1@0>1?0@1=0ケ", -- B1.tmx bounds
  "0Q140I160H170G180F190F190F1A0>1A0>1@0?1?0@1406140@1406140@1406140@1406140@1406140@1406140@1406140@1D0:1E091E091E0C1403140C1403140C1403140C1;0C1;0C1;0D190P", -- B2.tmx bounds
  "1/1/1/1ほ", -- B3.tmx bounds
  "0\n170F190D1;0C1;0C1B0<1B0<1B0<1B0>1@0>1@0>1@0>1@0>1401140E190E190E190E190ヨ", -- B4.tmx bounds
  "0い150H170F180E190D1:0:1D091E091E091E09140216021<04140116031<041:041<0419051<0418061402160516021@0>1?0?1>0@1=0A1401140E1401140E190E190E190E190⬆️", -- C1.tmx bounds
  "1/1/1/1ほ", -- C2.tmx bounds
  "1/1/1/1ほ", -- C3.tmx bounds
  "1/1/1/1ほ", -- D1.tmx bounds
  "1/1/1/1ほ", -- D2.tmx bounds
  "1/1/1/1ほ", -- D3.tmx bounds
  "0^180E1:0C1<0B1<0B1<0B1<0B1<0B1<0C1401160C1401160C1401160;1<01160;1<01160;1;02160;1:03160H1608130=1608140=1409140=1409140<1509140;1609140:160:140:150;1B0<1B0<1B0<1B0<1704170=15061509", -- D4.tmx bounds
--  "1/1/1/1ほ", -- WIP1.tmx bounds
}

local map_settings_data = parse_table_arr(--[[member]]"name,req_medals,laps,size,spawn_x,spawn_y,spawn_dir,bronze,silver,gold,plat",
  "|a1,0,3,30,312,264,0.5,2880,2433,2160,1980" .. -- A1.tmx settings
  "|a2,1,3,30,264,216,0.25,2928,2136,1794,1650" .. -- A2.tmx settings
  "|a3,2,3,30,208,624,0.0,3144,2640,2286,2130" .. -- A3.tmx settings
  "|a4,3,3,30,264,360,0.25,3846,2652,2295,2043" .. -- A4.tmx settings
  "|b1,6,4,30,432,312,0.25,4296,3450,2787,2430" .. -- B1.tmx settings
  "|b2,7,3,30,192,136,0.375,4080,2816,2412,2214" .. -- B2.tmx settings
  "|b3,8,2,30,552,264,0.25,3084,2364,1956,1743" .. -- B3.tmx settings
  "|b4,9,4,30,192,248,0.125,3489,2706,2256,1978" .. -- B4.tmx settings
  "|c1,12,3,30,232,328,0.625,4389,3366,2925,2400" .. -- C1.tmx settings
  "|c2,13,2,30,600,648,0.5,3483,2652,2232,2025" .. -- C2.tmx settings
  "|c3,14,2,30,288,208,0.75,3666,2691,2211,2013" .. -- C3.tmx settings
  "|d1,17,4,30,288,528,0.5,4137,3066,2490,2181" .. -- D1.tmx settings
  "|d2,18,4,30,352,344,0.125,3720,2664,2214,1956" .. -- D2.tmx settings
  "|d3,19,3,30,384,264,0.75,4500,3252,2811,2625" .. -- D3.tmx settings
  "|d4,20,3,30,360,624,0.5,3324,2445,2097,2016" .. -- D4.tmx settings
--  "|a1,0,3,30,296,264,0.0,2880,2340,2100,1980" .. -- WIP1.tmx settings
  ""
)
local map_checkpoints_data_header = --[[member]]"x,y,dx,dy,l"
local map_checkpoints_data = {
  parse_table_arr(map_checkpoints_data_header, '|300,229,0,1,71|486,294,1,1,72|342,510,1,1,72'), -- A1.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|229,204,1,0,69|445,204,1,0,69|229,492,1,0,69'), -- A2.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|228,586,0,1,74|300,61,0,1,71|353,407,-1,1,56'), -- A3.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|229,348,1,0,69|445,227,-1,1,68|301,349,1,1,73'), -- A4.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|397,300,1,0,69|669,171,-1,1,57|137,511,-1,1,64'), -- B1.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|213,99,-1,1,44|165,147,-1,1,44|606,606,1,1,64'), -- B2.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|517,252,1,0,69|61,252,1,0,69|394,322,1,1,68|564,589,0,1,71'), -- B3.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|178,210,1,1,56|557,283,-1,1,68|277,491,-1,1,68'), -- B4.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|198,318,1,1,52|466,206,-1,1,77|545,295,-1,1,79|349,563,-1,1,68'), -- C1.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|588,613,0,1,71|569,151,-1,1,52|276,205,0,1,71|113,271,-1,1,72|588,541,0,1,71'), -- C2.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|253,228,1,0,69|444,37,0,1,71|396,109,0,1,188|493,181,1,1,69|540,301,0,1,171|489,375,-1,1,69|252,481,0,1,83|444,569,0,1,103'), -- C3.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|276,493,0,1,71|317,324,1,0,53|397,324,1,0,69'), -- D1.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|334,310,1,1,52|518,230,1,1,52|150,390,1,1,52'), -- D2.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|349,276,1,0,69|542,446,1,1,52|165,459,-1,1,68'), -- D3.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|348,589,0,1,71|493,276,1,0,117|109,564,1,0,69'), -- D4.tmx checkpoints
--  parse_table_arr(map_checkpoints_data_header, '|308,229,0,1,71'), -- WIP1.tmx checkpoints
}
local map_jumps_data = {
  {}, -- A1.tmx jumps
  parse_jumps_str("|16|13,1,14,1|17|14,1"), -- A2.tmx jumps
  {}, -- A3.tmx jumps
  {}, -- A4.tmx jumps
  parse_jumps_str("|20|14,1|21|14,1|5|17,2|11|19,3,20,3"), -- B1.tmx jumps
  parse_jumps_str("|9|12,1,13,1|10|12,1,13,1|19|13,2,14,2,22,3,23,3|20|13,2,14,2,22,3,23,3"), -- B2.tmx jumps
  {}, -- B3.tmx jumps
  parse_jumps_str("|11|11,1|17|12,2,13,2|18|15,3|12|16,4,17,4"), -- B4.tmx jumps
  parse_jumps_str("|15|7,1|16|7,1|18|7,2,15,5,18,7,19,7|9|9,3,10,3|10|9,3|13|9,4,10,4|12|10,4|14|9,4,10,4,18,6,19,6|17|15,5,18,7,19,7"), -- C1.tmx jumps
  {}, -- C2.tmx jumps
  {}, -- C3.tmx jumps
  {}, -- D1.tmx jumps
  {}, -- D2.tmx jumps
  {}, -- D3.tmx jumps
  parse_jumps_str("|22|8,1,15,3|23|8,1,15,3|16|10,2|17|10,2|5|18,4|6|18,4|9|25,5"), -- D4.tmx jumps
--  {}, -- WIP1.tmx jumps
}
local gradients =     split('0,1,1,2,1,13,6,2,4,9,3,1,5,13,14')
local gradients_rev = split('12,8,11,9,13,14,7,7,10,7,7,7,14,15,7')
local outline_cache = {}
local bbox_cache = {}
-- local wall_height = 3 - hardcoded to save compressed space
local chunk_size = 3
-- local chunk_size_x8 = 24 - hardcoded to save compressed space
local chunks_per_row = 42 -- flr(128/chunk_size)

-- Hardcoded wheel offsets to get them pixel perfect :D
local wheel_offsets_raw = split('-4,-3,3,2,-4,2,3,-3,-5,-2,3,2,-4,3,2,-3,-5,-1,3,1,-3,4,1,-3,-5,0,4,0,-2,4,1,-4,-5,1,3,0,-1,5,0,-3,-4,2,4,-1,0,5,-1,-3,-4,3,3,-2,1,5,-1,-3,-3,4,3,-2,2,5,-2,-3,-3,4,2,-3,2,4,-3,-3,-2,5,2,-3,3,4,-3,-2,-1,5,1,-3,4,3,-3,-2,0,5,0,-4,4,2,-4,-1,1,5,0,-3,5,1,-3,0,2,4,-1,-4,5,0,-4,0,3,4,-1,-3,5,-1,-3,2,4,3,-2,-3,5,-2,-3,2,4,3,-3,-2,4,-2,-3,3,5,2,-3,-2,4,-3,-2,3,5,1,-3,-1,3,-4,-1,3,5,0,-4,0,2,-4,-1,4,5,-1,-3,0,1,-5,0,3,4,-2,-4,1,0,-5,0,4,4,-3,-3,2,-1,-5,1,3,3,-4,-3,2,-2,-5,2,3,3,-4,-2,3,-2,-4,3,3,2,-5,-2,3,-3,-4,3,2,1,-5,-1,3,-4,-3,3,2,0,-5,0,4,-4,-2,4,1,-1,-5,0,3,-5,-1,3,0,-2,-4,1,4,-5,0,4,0,-3,-4,2,3,-5,1,3,-1,-4,-3,2,3,-5,2,3,-2,-4,-3,3,2,-4,2,3,-3')
local wheel_offsets_cache = {}
for wheel_offset_i = 1, #wheel_offsets_raw, 8 do
  local offsets = {}
  for wheel_offset_j = 0, 7, 2 do
    add(offsets, {x=wheel_offsets_raw[wheel_offset_i+wheel_offset_j], y=wheel_offsets_raw[wheel_offset_i+wheel_offset_j+1]})
  end
  wheel_offsets_cache[(wheel_offset_i-1)/256] = offsets
end

--------------------
-- Built-in Methods
--------------------

function _init()
  --printh('\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n')

  -- Reset high scores for debugging
  --for i = 11, 64 do
  --  dset(i, 0)
  --end

  -- Disable btnp repeat
  poke(0x5f5c, 255)

  -- Enable full keyboard (for R to restart level)
  poke(0x5f2d,1)

  init_outline_cache(outline_cache, 112)
  init_outline_cache(bbox_cache, 109)

  load_level(false)

  spawn_level_select_manager()
  spawn_customization_manager()
  spawn_main_menu_manager()
  particle_vol_m = spawn_particle_manager_vol()
  particle_water_m = spawn_particle_manager_water()

  set_menu_items()
  music(0)

  -- Re-submit best times for achievement tracking
  for level_index, map_settings in pairs(map_settings_data) do
    local data_index = get_lap_time_index(level_index, map_settings.laps)
    local best_time = dget(data_index)
    post_time_to_gpio(level_index, best_time)
  end
end

function _update60()
  if pause_frames > 0 then
    pause_frames -= 1
    return
  end

  for obj in all(objects) do
    obj.update(obj)
  end

  if game_state == 0 then
    if ghost ~= nil then
      _ghost_update(ghost)
    end

    -- 3% CPU
    _car_update(player)

    _level_manager_update(level_m)
  end

  -- 0% CPU (idle)
  _particle_manager_vol_update(particle_vol_m)

  camera_x = %0x5f28
  camera_y = %0x5f2a
end

function _draw()
  if pause_frames > 0 then
    pause_frames -= 1
    return
  elseif pause_frames < 0 then
    pause_frames = -pause_frames
  end

  if game_state == 0 then
    -- Most grass is drawn as part of cls
    cls(3)

    -- 7% CPU
    draw_map(map_road_chunks, map_settings.size, true, true, false)
    -- 3% CPU
    draw_map(map_decal_chunks, map_settings.size, true, true, true)

    draw_cp_highlights(level_m)

    -- 2% CPU (idle)
    _particle_manager_water_draw(particle_water_m)

    -- 9% CPU
    _trail_manager_draw(trail_m)

    -- Tutorial. Only used once so special case here
    if level_index == 1 then
      rectfill_outlined(512, 216, 543, 240, 6, 1)
      print('drift!', 517, 220, 7)
      print('hold x!', 515, 232, 7)
    end

    if ghost ~= nil then
      draw_car_shadow(ghost)
    end
    draw_car_shadow(player)

    -- 0% CPU (idle)
    _particle_manager_vol_draw_bg(particle_vol_m)

    -- 11% CPU
    draw_map(map_prop_chunks, map_settings.size, player.z > 3, true, false)

    --draw_map(map_bounds_chunks, map_settings.size, true, true, true)

    if ghost ~= nil then
      _car_draw(ghost)
    end

    -- 7% CPU
    _car_draw(player)
  
    -- 12% CPU
    if player.z <= 3 then
      draw_map(map_prop_chunks, map_settings.size, true, false, false)
    end

    -- 1% CPU (idle)
    _particle_manager_vol_draw_fg(particle_vol_m)

    _level_manager_draw(level_m)
  else
    cls(0)
  end

  -- 0% CPU
  for obj in all(objects) do
    obj.draw(obj)
  end

  -- Menu transition animation
  if menu_anim_frame > 0 then
    palt(0b0000000000000001)
    for x = 0, 128, 8 do
      for y = 0, 128, 8 do
        spr(mid(144, 175, 129 + menu_anim_frame + x / 16 + y / 16), x + camera_x, y + camera_y)
      end
    end
    palt()
    if menu_anim_frame == 22 then
      menu_anim_cb()
    end
    menu_anim_frame -= 1
  end

  --_player_debug_draw(player)
  --print(stat(0), player.x, player.y - 20, 0)
  --print(level_m.frame, player.x, player.y - 30, 0)
  --print(dist(player.v_x, player.v_y), player.x, player.y - 20, 0)

  --rectfill(player.x - 64, player.y - 58, player.x + 64, player.y - 43, 1)
  --rect(player.x - 65, player.y - 58, player.x + 64, player.y - 43, 12)
  --rectfill(player.x - 64, player.y + 42, player.x + 64, player.y + 57, 1)
  --rect(player.x - 65, player.y + 42, player.x + 64, player.y + 57, 12)
  --print_shadowed('\^t\^woPEN bETA', player.x - 35, player.y - 55, 7)
  --print_shadowed('\^t\^wpLAY nOW!', player.x - 35, player.y + 45, 7)

  --for cp in all(map_checkpoints) do
  --  line(cp.x, cp.y, cp.x + cp.dx * cp.l, cp.y + cp.dy * cp.l, 12)
  --end

  --for offset in all(bbox_cache[round_nth(player.angle_fwd)]) do
  --  pset(player.x + offset.x, player.y + offset.y, 8)
  --end

  --if not btn(5) then
  --  for offset in all(player.wheel_offsets) do
  --    pset(player.x + offset.x, player.y + offset.y, 9)
  --    print(player.angle_fwd*32, player.x, player.y - 15, 7)
  --  end
  --end

end

--------------------
-- Utility Methods
--------------------

-- Given an angle and a magnitude return x, y components
function angle_vector(theta, magnitude)
  return magnitude * cos(theta),
         magnitude * sin(theta)
end

-- Dot product
function dot(x1, y1, x2, y2)
  return x1 * x2 + y1 * y2
end

function dist(dx, dy)
  return sqrt(dx * dx + dy * dy)
end

function normalized(x, y)
  local mag = dist(x, y)
  if mag == 0 then
    return 0, 0
  end
  return x / mag, y / mag
end

-- Round a number 0-1 to its nearest 1/n th
--function round_nth(x, n)
--  local lower = flr(x * n) / n
--  return x - lower < (0.5 / n) and lower or lower + 1 / n
--end
-- Hardcoded to 32 to save tokens
function round_nth(x)
  local lower = flr(x * 32) / 32
  return x - lower < 0.015625 and lower or lower + 0.03125
end


-- Random between -num, +num
function rnd2(n)
  n = abs(n)
  return rnd(2*n) - n
end

function round(n)
  return n%1 < 0.5 and flr(n) or -flr(-n)
end

-- Courtesy TheRoboZ
function pd_rotate(x,y,rot,mx,my,w,flip,scale)
  scale=scale or 1
  w*=scale*4

  local cs, ss = cos(rot)*.125/scale,sin(rot)*.125/scale
  local sx, sy = mx+cs*-w, my+ss*-w
  local hx = flip and -w or w

  local halfw = -w
  for py=y-w, y+w do
    tline(x-hx, py, x+hx, py, sx-ss*halfw, sy+cs*halfw, cs, ss)
    halfw+=1
  end
end

function print_shadowed(s, x, y, c)
  print(s, x+1, y, 0)
  print(s, x, y, c)
end

function rectfill_outlined(x1, y1, x2, y2, c1, c2)
  rect(x1-1, y1-1, x2+1, y2+1, c1)
  rectfill(x1, y1, x2, y2, c2)
end

-- Basic run length encoding compression
-- Values are base-256 encoded and rotated by 48 to get more chars in the ASCII range (better compressed cart size)
function decomp_str(s, offset)
  local arr = {}

  for i = 1, #s, 2 do
    local index = (ord(s, i) - 48) % 256
    local cnt = (ord(s, i + 1) - 48) % 256
    for j = 1, cnt do
      add(arr, index + offset)
    end
  end

  return arr
end

--------------------
-- Car class (player + ghost)
--------------------
function create_car(x, y, dir, is_ghost)
  -- Car creation is split into static and dynamic parts to save tokens
  local car = parse_table(--[[member]]'z,x_remainder,y_remainder,z_remainder,v_x,v_y,v_z,turn_rate_fwd,turn_rate_vel,accel,brake,max_speed_fwd,max_speed_rev,f_friction,f_corrective,boost_frames,flash_frames,water_wheels,water_frames,scale,respawn_frames,respawn_start_x,respawn_start_y,engine_pitch,ghost_frame,wall_penalty_frames,next_checkpoint',
    '0,0,0,0,0,0,0,0.0060,0.0050,0.075,0.05,2.2,0.5,0.02,0.1,0,0,0,0,1,0,0,0,0,1,0,2')

  car.x = x
  car.y = y
  car.angle_fwd = dir
  car.is_ghost = is_ghost
  car.drifting = false
  car.wheel_offsets = {}
  car.dirt_frames = split('0,0,0,0')
  car.last_checkpoint_x = x
  car.last_checkpoint_y = y
  car.last_checkpoint_angle = dir
  car.camera_target_x = x - 64
  car.camera_target_y = y - 64
  car.cp_crossed = {}
  return car
end

function _car_update(self)
  local d_brake, move_fwd
  if self.respawn_frames == 0 then
    d_brake, move_fwd = _car_move(self, level_m.state == 2 and btn() or 0)
    if level_m.state ~= 3 then
      local fwd_x, fwd_y = angle_vector(self.angle_fwd, 1)
      local speed = dist(self.v_x, self.v_y)
      local lead = min(speed * 9.9, 30)
      local target_x = self.x - 64 + flr(fwd_x * lead)
      local target_y = self.y - 64 + flr(fwd_y * lead)
      self.camera_target_x += (target_x - self.camera_target_x) * 0.5
      self.camera_target_y += (target_y - self.camera_target_y) * 0.5
      camera(self.camera_target_x, self.camera_target_y)
    end
  else
    d_brake, move_fwd = _car_move(self, 0)

    if self.respawn_frames < 30 then
      -- Ease in/out quadratic curve
      local lerp_t = mid(0, 1, (30 - self.respawn_frames) / 20)
      lerp_t = lerp_t < 0.5 and 2 * lerp_t ^ 2 or 1 - (-2 * lerp_t + 2) ^ 2 / 2

      local cam_x = self.respawn_start_x + (self.last_checkpoint_x - self.respawn_start_x) * lerp_t - 64
      local cam_y = self.respawn_start_y + (self.last_checkpoint_y - self.respawn_start_y) * lerp_t - 64
      self.camera_target_x = cam_x
      self.camera_target_y = cam_y
      camera(cam_x, cam_y)
    end
  end

  -- Sound effects
  local speed = dist(self.v_x, self.v_y)
  local target_pitch = 0
  if self.z > 6 then
    target_pitch = 24
  elseif level_m.state == 3 then
    if speed > 0 then
      target_pitch = speed * 8
    else
      target_pitch = -1
    end
  else
    if move_fwd < 0 then
      target_pitch = speed * 4
    elseif d_brake or move_fwd == 0 then
      target_pitch = speed * 6
    else
      target_pitch = speed * 8
    end
  end

  if self.engine_pitch ~= target_pitch then
    self.engine_pitch += sgn(target_pitch - self.engine_pitch) * 0.25
  end
  if self.engine_pitch >= 0 then
    sfx(50, 3, self.engine_pitch, 0)
  else
    sfx(50, -2) -- stop sfx
  end

  if d_brake then
    sfx(58, 2)
  end
end

function _ghost_update(self)
  local btns = self.buffer[self.ghost_frame]
  if btns ~= -1 then
    _car_move(self, btns)
    self.ghost_frame += 1
  else
    _car_move(self, 0)
  end
end

function _car_move(self, btns)
  -- Input
  local move_side = 0
  local move_fwd = 0
  if btns & 0x01 > 0 then move_side += 1 end
  if btns & 0x02 > 0 then move_side -= 1 end
  if btns & 0x14 > 0 then move_fwd  += 1 end -- Allow Up or O
  if btns & 0x08 > 0 then move_fwd  -= 1 end
  local d_brake = btns & 0x20 > 0

  -- Misc data
  local fwd_x, fwd_y = angle_vector(self.angle_fwd, 1)
  local v_x_normalized, v_y_normalized = normalized(self.v_x, self.v_y)
  local vel_dot_fwd = dot(fwd_x, fwd_y, v_x_normalized, v_y_normalized)
  local speed = dist(self.v_x, self.v_y)

  -- Get the wheel modifiers (boost, road, grass, etc)
  local grass_wheels = 0
  local boost_wheels = 0
  local water_wheels = self.water_wheels
  for i, offset in pairs(self.wheel_offsets) do
    local check_x = flr(self.x) + offset.x
    local check_y = flr(self.y) + offset.y
    -- Visual only when on the road?
    local collides_grass = collides_grass_at(check_x, check_y, self.z)
    local collides_water = collides_water_at(check_x, check_y, self.z)
    if collides_grass and not collides_water then
      grass_wheels += 1
    end
    if collides_water then
      self.dirt_frames[i] = 0
    end
    if not collides_grass and self.z == 0 and self.dirt_frames[i] > 0 then
      add_trail_point(trail_m, check_x, check_y, 4)
      self.dirt_frames[i] -= 1
    end
    if collides_boost_at(check_x, check_y, self.z) then
      boost_wheels += 1
    end
  end

  -- Apply the wheel modifiers
  local mod_turn = 1
  local mod_corrective = 1
  local mod_friction = 1
  local mod_accel = 1
  local mod_brake = 1
  local mod_turn_rate = 1
  if grass_wheels >= 2 and water_wheels == 0 then
    mod_turn = 0.25
    mod_corrective = 0.25
    --mod_max_vel = 0.9
    mod_accel = 0.5
    mod_brake = 0.25
    if speed > 1 and not self.is_ghost then
      sfx(59, 0)
    end
  end
  if boost_wheels >= 1 then
    if self.boost_frames <= 87 and not self.is_ghost then
      self.flash_frames = 5
      pause_frames = -2
      sfx(54, 1)
    end
    self.boost_frames = 90
  end
  if water_wheels >= 2 then
    if self.boost_frames > 0 then
      mod_accel = move_side == 0 and 0.6 or 0.2
    elseif speed < 0.5 then
      mod_accel = move_side == 0 and 0.5 or 0.2
    else
      mod_accel = move_side == 0 and 0.5 or 0.0
    end
    mod_brake = 0.5
    mod_turn = 0.1
    mod_turn_rate = 0.75
    mod_corrective = 2
    d_brake = false -- no d-brake in water
    poke(16264, 144) -- Disable all mods on SFX 50 except dampen
  else
    poke(16264, 164) -- Enable dampen, buzz, detune on SFX 50
  end
  self.water_frames = mid(0, 45, self.water_frames + (self.water_wheels > 0 and 5 or -1))
  local mod_max_vel = 1 - self.water_frames / 112.5 -- / 45 * 0.4

  -- Note: allowing air control close to ground feels better
  if self.z > 6 and self.boost_frames == 0 then
    mod_accel = 0
    mod_brake = 0
    mod_corrective = 0
    mod_turn = 0
  end

  -- No d-brake when not grounded
  if self.z > 0 then
    d_brake = false
  end

  -- Reduced turning when going slow
  if speed < 0.5 then
    move_side *= speed * 2
    d_brake = false
  end

  -- Penalty for hitting a wall
  if self.wall_penalty_frames > 0 then
    self.wall_penalty_frames -= 1
    mod_max_vel *= 0.8
    if self.boost_frames == 0 then
      mod_accel = 0.2
    end
  end

  -- Visual Rotation
  --self.angle_fwd = (self.angle_fwd + move_side * self.turn_rate_fwd * mod_turn_rate * (d_brake and 1.5 * abs(vel_dot_fwd) or 1)) % 1
  self.angle_fwd = (self.angle_fwd + move_side * self.turn_rate_fwd * mod_turn_rate * (d_brake and 1.35 or 1)) % 1
  if move_side == 0 then
    -- If there's no more side input, snap to the nearest 1/8th
    self.angle_fwd = round_nth(self.angle_fwd)
  end

  -- Boost
  local boost_duration = 45
  self.flash_frames = max(self.flash_frames - 1, 0)
  if self.boost_frames > 0 then
    if rnd(boost_duration) < self.boost_frames then
      boost_particles(self)
    end
    self.boost_frames -= 1
    mod_max_vel *= 1 + (0.5 * self.boost_frames / boost_duration)
  end

  -- Update wheel offsets
  self.wheel_offsets = wheel_offsets_cache[round_nth(self.angle_fwd)]  

  -- If we can't turn because of colliding nudge the car a little
  local collides, collides_x, collides_y = _player_collides_at(self, self.x, self.y, self.z, self.angle_fwd)
  while collides do
    local to_collision_x, to_collision_y = normalized(collides_x - self.x, collides_y - self.y)
    self.x -= round(to_collision_x)
    self.y -= round(to_collision_y)
    collides, collides_x, collides_y = _player_collides_at(self, self.x, self.y, self.z, self.angle_fwd)
  end

  -- Acceleration, friction, breaking. Note: mid is to stop over-correction
  if self.boost_frames > 0 then
    -- Force move forward when boosting
    local mid_x, mid_y = normalized(v_x_normalized + fwd_x, v_y_normalized + fwd_y)
    self.v_x += (d_brake and mid_x or fwd_x) * self.accel * mod_accel
    self.v_y += (d_brake and mid_y or fwd_y) * self.accel * mod_accel
  elseif d_brake then
    local f_stop = (move_fwd > 0 and self.f_friction * 0.25
                or (move_fwd == 0 and self.f_friction * 1.5
                or (move_fwd < 0 and self.brake * mod_brake or 1000)))
    self.v_x -= mid(v_x_normalized * f_stop, self.v_x, -self.v_x)
    self.v_y -= mid(v_y_normalized * f_stop, self.v_y, -self.v_y)
  else
    if move_fwd > 0 then
      self.v_x += fwd_x * self.accel * mod_accel
      self.v_y += fwd_y * self.accel * mod_accel
    elseif move_fwd == 0 then
      self.v_x -= mid(v_x_normalized * self.f_friction * mod_friction, self.v_x, -self.v_x)
      self.v_y -= mid(v_y_normalized * self.f_friction * mod_friction, self.v_y, -self.v_y)
    elseif move_fwd < 0 then
      self.v_x -= fwd_x * self.brake * mod_brake
      self.v_y -= fwd_y * self.brake * mod_brake
    end
  end

  -- Corrective side force
  -- Note: (x, y, 0) cross (0, 0, 1) -> (y, -x, 0)
  local right_x, right_y = fwd_y, -fwd_x
  local vel_dot_right = dot(right_x, right_y, v_x_normalized, v_y_normalized)
  self.drifting = d_brake --abs(vel_dot_right) > 0.65
  if not d_brake then
    self.v_x -= mid((1 - abs(vel_dot_fwd)) * right_x * sgn(vel_dot_right) * self.f_corrective * mod_corrective, self.v_x, -self.v_x)
    self.v_y -= mid((1 - abs(vel_dot_fwd)) * right_y * sgn(vel_dot_right) * self.f_corrective * mod_corrective, self.v_y, -self.v_y)
  end

  -- Speed limit
  local angle_vel = atan2(self.v_x, self.v_y)
  speed = dist(self.v_x, self.v_y)
  local limit = (vel_dot_fwd < -0.8 and self.max_speed_rev or self.max_speed_fwd) * mod_max_vel
  if speed > limit then
    speed = max(speed * 0.94, limit)
    self.v_x, self.v_y = angle_vector(angle_vel, speed)
  end

  -- Velocity rotation
  angle_vel += self.turn_rate_vel * abs(vel_dot_right) * mod_turn * ((self.angle_fwd - angle_vel) % 1 < 0.5 and 1 or -1)
  self.v_x, self.v_y = angle_vector(angle_vel, dist(self.v_x, self.v_y))

  -- Gravity
  if self.z > 0 then
    self.v_z -= 0.1
  end

  -- Apply Movement
  self.x, _, _, self.x_remainder, x_blocked = _player_move(self, self.v_x, self.x_remainder, 1, 0, 0)
  _, self.y, _, self.y_remainder, y_blocked = _player_move(self, self.v_y, self.y_remainder, 0, 1, 0)
  _, _, self.z, self.z_remainder, z_blocked = _player_move(self, self.v_z, self.z_remainder, 0, 0, 1)
  if x_blocked then
    self.v_x *= 0.25
    self.v_y *= 0.90
  end
  if y_blocked then
    self.v_x *= 0.90
    self.v_y *= 0.25
  end
  if z_blocked then
    self.v_z = 0
    if self.z == 0 and not self.is_ghost then
      sfx(51)
      smoke_particles(self, 10)
    end
  end

  -- Check bounds
  local chunk_x = flr(self.x / 24)
  local chunk_y = flr(self.y / 24)
  if self.respawn_frames == 0 and self.z == 0 and map_bounds_chunks[chunk_x][chunk_y] == 0 then
    self.respawn_frames = 60
    self.respawn_start_x = self.x
    self.respawn_start_y = self.y
  end

  -- Reset car at end of OOB animation
  if self.respawn_frames > 0 then
    self.respawn_frames -= 1
    if self.respawn_frames < 20 then
      self.x = self.last_checkpoint_x
      self.y = self.last_checkpoint_y
      self.angle_fwd = self.last_checkpoint_angle
      self.v_x = 0
      self.v_y = 0
      self.x_remainder = 0
      self.y_remainder = 0
      self.dirt_frames = split('0,0,0,0')
      self.boost_frames = 0
    end
  end


  -- Record ghost
  if not self.is_ghost and self.ghost_frame < 0x7fff then
    ghost_recording[self.ghost_frame] = btns
    self.ghost_frame += 1
  end

  -- Return results for processing
  return d_brake, move_fwd
end

function boost_particles(self)
  --local cone_angle = 0.1
  --local offset_x, y = angle_vector(self.angle_fwd+0.5 + rnd(cone_angle/2)-cone_angle/4, 6)
  local offset_x, y = angle_vector(self.angle_fwd+0.5 + rnd(0.05)-0.025, 6)
  add_particle_vol(particle_vol_m, self.x + offset_x, self.y + y, self.z + 2, rnd(1) < 0.5 and 10 or 9, offset_x, y, rnd(0.5)-0.25, self.is_ghost and 2 or 30, 4, 1)
end

function smoke_particles(self, n)
  for i = 1, n do
    add_particle_vol(particle_vol_m, self.x, self.y, 0, rnd(1) < 0.5 and 6 or 7, rnd2(1.5), rnd2(1.5), 0, 30, 4, 0)
  end
end

function _car_draw(self)
  palt(0b0000000000000001)

  -- Water outline
  draw_water_outline(round_nth(self.angle_fwd), self.x, self.y, self.z)
  
  -- Palette customization / ghost
  for d in all(customization_m.data) do
    if d.text ~= 'tYPE' then
      local c = self.is_ghost and gradients[d.chosen] or d.chosen
      if c >= 16 then -- Easter Egg for those with all medals
        c += flr(time() * 10)
      end
      pal(d.original, c)
      if d.text == 'bODY' then -- body - set gradient color
        local gradient_c = gradients[c%16]
        pal(2, gradient_c)
        pal(11, self.boost_frames > 10 and c or gradient_c)
      elseif d.text == 'wINDOWS' then -- windows - set highlight color
        pal(12, gradients_rev[c])
      end
    end
  end

  -- Flash frames
  if self.flash_frames > 0 then
    for i = 0, 15 do
      pal(i, 7)
    end
  end

  -- Costs 6% of CPU budget
  --self.scale = 1 + self.z / 40
  for i = self.water_wheels < 2 and 0 or 1, 4 do
    pd_rotate(self.x,self.y-self.z-i*self.scale+(self.water_wheels<2 and 0 or 1),round_nth(self.angle_fwd),127 - i*3,63.5,2,true,self.scale)
    --if btn(5) then break end
  end
  pal()
end

function draw_car_shadow(self)
  -- Shadow / Underglow
  palt(0b0000000000000001)
  pal(14, 1)
  pal(0, 1)
  local height = 0
  if collides_jump_at(self.x, self.y, 0) then
    height = flr(map_jump_frames[map_jumps[flr(self.x/24)][flr(self.y/24)]] / 8)
  end
  pd_rotate(self.x,self.y-height,round_nth(self.angle_fwd),127,63.5,2,true,self.scale)
  palt()
  pal()
end

-- Modified from https://maddymakesgames.com/articles/celeste_and_towerfall_physics/index.html
-- Returns final x, y pos and whether the move was blocked
function _player_move(self, amount, remainder, x_mask, y_mask, z_mask)
  local x = self.x
  local y = self.y
  local z = self.z
  remainder += amount;
  local move = round(remainder);
  if move ~= 0 then
    remainder -= move;
    local sign = sgn(move);
    while move ~= 0 do
      if _player_collides_at(self, x + sign * x_mask, y + sign * y_mask, z + sign * z_mask, self.angle_fwd, true) then
        return x, y, z, remainder, true
      else
        x += sign * x_mask
        y += sign * y_mask
        z += sign * z_mask
        move -= sign
        if _on_player_moved(self, x, y, z, self.angle_fwd) then
          -- handle jumped
          self.v_z = 2 -- Hack! Modifying velocity in colision / movement code
          z = 2
          if not self.is_ghost then
            pause_frames = -3
            sfx(53, 0)
          end
        end
      end
    end
  end
  return x, y, z, remainder, false
end

-- Called whenever the player occupies a new position. Can be called multiple times per frame
-- Returns true if the player is on a jump. Processing defered to do all wheel checks + properly handle impact
function _on_player_moved(self, x, y, z, angle)
  self.water_wheels = 0
  local jumped = false

  for i, offset in pairs(self.wheel_offsets) do
    local check_x = x + offset.x
    local check_y = y + offset.y

    if collides_jump_at(check_x, check_y, z) then
      map_jump_frames[map_jumps[flr(check_x/24)][flr(check_y/24)]] = 30
      jumped = true
    end
    local checkpoint = collides_checkpoint_at(check_x, check_y)
    if checkpoint ~= nil then
      local new_cp = on_checkpoint_crossed(level_m, self, checkpoint)
      if new_cp then
        self.last_checkpoint_x = x
        self.last_checkpoint_y = y
        self.last_checkpoint_angle = angle
      end
    end

    local collides_water = collides_water_at(check_x, check_y, z)
    if i % 2 == 0 then -- front wheels
      if collides_water then
        self.water_wheels += 1
        local side = i == 4 and 1 or -1
        add_particle_water(particle_water_m, check_x, check_y, rnd2(self.v_y*0.05), rnd2(-self.v_x*0.05), rnd(25)+20)
        add_particle_water(particle_water_m, check_x, check_y, self.v_y*0.175*side, -self.v_x*0.175*side, rnd(20)+20)
      end
      local collides_grass = collides_grass_at(check_x, check_y, z)
      if collides_grass and not collides_water then
        self.dirt_frames[i] = 10
        add_trail_point(trail_m, check_x, check_y, 4)
      end
    end
    if i % 2 == 1 and self.drifting and not collides_water then -- back wheels
      add_trail_point(trail_m, check_x, check_y, 0)
    end
  end

  return jumped
end

function _player_collides_at(self, x, y, z, angle, penalize)
  if z < 0 then
    return true
  end
  for offset in all(bbox_cache[round_nth(angle)]) do
    local check_x = flr(x) + offset.x
    local check_y = flr(y) + offset.y
    if collides_wall_at(check_x, check_y, z) then
      -- No penalty when on top of wall ;)
      if penalize and z < 3 then
        self.wall_penalty_frames = 20
        -- Really annoying to have the car crash effects on level end when it goes off screen
        if level_m.state ~= 3 and not self.is_ghost then
          sfx(52)
          smoke_particles(self, rnd(2)+1)
        end
      end
      return true, check_x, check_y
    end
  end
  return false
end

-- Checks if the given position on the map overlaps a wall
local wall_collision_sprites = parse_hash_set('29,31,42,43,44,45,46,47,58,59,60,61,62,63')
function collides_wall_at(x, y, z)
  return collides_part_at(x, y, z, 3, map_prop_tiles, {}, wall_collision_sprites, 6)
end

local grass_sprites_full = parse_hash_set('0,26')
local grass_sprites_part = parse_hash_set('6,7,8,9,26')
function collides_grass_at(x, y, z)
  return collides_part_at(x, y, z, 0, map_road_tiles, grass_sprites_full, grass_sprites_part, 3)
end

local water_sprites_full = parse_hash_set('64,69,70,85,86')
local water_sprites_part = parse_hash_set('65,66,67,68,81,82,83,84')
function collides_water_at(x, y, z)
  return collides_part_at(x, y, z, 0, map_decal_tiles, water_sprites_full, water_sprites_part, 12, 7)
end

local boost_sprites_full = parse_hash_set('21')
local boost_sprites_part = parse_hash_set('22,23,24,25')
function collides_boost_at(x, y, z)
  return collides_part_at(x, y, z, 0, map_decal_tiles, boost_sprites_full, boost_sprites_part, 10)
end

local jump_sprites_full = parse_hash_set('37')
local jump_sprites_part = parse_hash_set('38,39,40,41')
function collides_jump_at(x, y, z)
  return collides_part_at(x, y, z, 0, map_decal_tiles, jump_sprites_full, jump_sprites_part, 15)
end

function collides_part_at(x, y, z, h, tile_map, full_col_sprites, part_col_sprites, c1, c2)
  if z > h then
    return false
  end

  c2 = c2 or -1
  local tile_column = tile_map[flr(x/8)]
  if tile_column == nil then
    return false
  end
  local sprite_index = tile_column[flr(y/8)]
  if sprite_index == nil then
    return false
  end
  if full_col_sprites[sprite_index] then
    return true
  elseif part_col_sprites[sprite_index] then
    --local sx = (sprite_index % 16) * 8 + x % 8
    --local sy = flr(sprite_index / 16) * 8 + y % 8
    --local col = sget(sx, sy)
    local col = sget((sprite_index % 16) * 8 + x % 8, flr(sprite_index / 16) * 8 + y % 8)
    return col == c1 or col == c2
  end
  return false
end

function collides_checkpoint_at(x, y)
  if level_m.cp_cache[x] ~= nil and level_m.cp_cache[x][y] ~= nil then
    return level_m.cp_cache[x][y]
  end
end

--------------------
-- Level Management
--------------------
function load_level(start)
  map_settings = map_settings_data[level_index]
  map_checkpoints = map_checkpoints_data[level_index]
  map_jumps = map_jumps_data[level_index]
  map_jump_frames = split('0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0')

  -- Note: offsets automated by mapPacker
  map_road_chunks, map_road_tiles = load_map(map_road_data[level_index], 0, map_settings.size)
  map_decal_chunks, map_decal_tiles = load_map(map_decals_data[level_index], 102, map_settings.size) -- global decals_offset
  map_prop_chunks, map_prop_tiles = load_map(map_props_data[level_index], 345, map_settings.size) -- global props_offset
  map_bounds_chunks = load_map(map_bounds_data[level_index], 0, map_settings.size)

  load_minimap()

  spawn_level_manager()
  player = create_car(map_settings.spawn_x, map_settings.spawn_y, map_settings.spawn_dir, false)
  ghost = nil -- If someone switched ghost enabled -> disabled make sure we clear out the existing one
  if start and ghost_playback[1] ~= -1 and ghost_enabled then
    ghost = create_car(map_settings.spawn_x, map_settings.spawn_y, map_settings.spawn_dir, true)
    ghost.buffer = ghost_playback
  end
  spawn_trail_manager()

  if start then
    game_state = 0
    music(-1, 1000)
  end
end

function spawn_level_manager()
  level_m = {
    lap = 1,
    frame = 1,
    anim_frame = 0,
    --cp_cache = {}, -- table[x][y] -> cp index
    --cp_sprites = {}, -- table[cp_index] -> list of x, y, sprite to draw after crossing checkpoint
    state = 1, -- 1=intro, 2=playing, 3=ending
    last_best = 0, -- Previous best time for the track that just finished
    lap_frames = {}, -- list of frames for this attempt of the track
  }
  cache_checkpoints(level_m, map_checkpoints)

  local buttons = {
    new_button(0, 0, 'rETRY', function() load_level(true) end, true),
    new_button(0, 10, 'qUIT', quit_level, true),
  }
  level_m.menu = new_menu(50, -10, buttons, 1, 120)
end

function quit_level()
  load_level(false) 
  sfx(50, -2) 
  game_state = 2
  music(0)
end

function _level_manager_update(self)
  if (self.frame < 0x7fff) and self.state == 2 then
    self.frame += 1
  end

  -- Restart level
  if stat(28, 21) then
    load_level(true)
  end

  if self.anim_frame < 0x0fff then
    self.anim_frame += 1
  end

  for k, v in pairs(map_jump_frames) do
    if v > 0 then
      map_jump_frames[k] -= 1
    end
  end

  if self.state == 3 then
    self.menu.update()
  end

end

function _level_manager_draw(self)
  -- intro sequence
  if self.anim_frame <= 180 and self.lap == 1 and self.state ~= 3 then
    local x = camera_x + 41
    local y = camera_y + 24 - max(0, (15 - self.anim_frame)*4) - max(0, (self.anim_frame - 150)*4)
    local c = self.anim_frame > 135 and 11 or self.anim_frame > 90 and 9 or self.anim_frame > 45 and 8 or 1
    if self.anim_frame == 45 then
      sfx(57)
    end

    -- Background + perimiter (85 tokens)
    circfill(x + 9,  y + 9, 10, c)
    circfill(x + 37, y + 9, 10, c)
    rectfill_outlined(x + 8, y, x + 38, y + 18, c, 0)
    circfill(x + 9,  y + 9, 9, 0)
    circfill(x + 37, y + 9, 9, 0)

    -- Middle circles
    for i = 0, 2 do
      local circle_x = x + 9 + 14*i
      local circly_y = y + 9
      circfill(circle_x, circly_y, 5, self.anim_frame > 45*(i+1) and c or 1)
      circ(circle_x, circly_y, 5, 6)
    end

    if self.anim_frame >= 135 then
      self.state = 2
    end
  end

  -- End sequence
  if self.state == 3 then
    local x = camera_x + 5
    local y = camera_y + 12 - max(0, (75 - self.anim_frame)*4)

    rectfill_outlined(camera_x, y, camera_x + 128, y + 99, 12, 1)

    print_shadowed('rACE\ncOMPLETE', x, y+4, 7)
    print_shadowed('tIME\n' .. frame_to_time_str(self.frame), x, y+20, 7)
    if self.last_best_time ~= 0 then 
      print_shadowed((self.last_best_time >= self.frame and '-' or '+') 
        .. frame_to_time_str(abs(self.last_best_time - self.frame)), x-4, y+32,
        self.last_best_time >= self.frame and 11 or 8)
    end

    draw_medals(x + 7, y + 42, self.frame)
    draw_minimap(x + 33, y + 5)

    self.menu.x = x + 8
    self.menu.y = y + 81
    self.menu.draw()
  end

  -- Level UI
  local kph = tostr(flr(dist(player.v_x, player.v_y) * 64.55))
  print_shadowed('\*' .. (3 - #kph) .. ' ' .. kph .. ' kph', camera_x + 98, camera_y + 114, 7)
  print_shadowed('lAP ' .. self.lap .. '/' .. map_settings.laps, camera_x + 98, camera_y + 121, 7)

end

function frame_to_time_str(frames)
  -- mm:ss.mm. Max time 546.13 sec
  local min = '0' .. tostr(flr(frames/3600))
  local sec = tostr(flr(frames/60%60))
  local sub_sec = tostr(flr(frames%60*100/60))
  return min .. ':' .. (#sec == 1 and '0' or '') .. sec .. '.' .. (#sub_sec == 1 and '0' or '') .. sub_sec
end

function on_checkpoint_crossed(self, car, cp_index)
  -- Check if this checkpoint was valid to cross next
  if cp_index == 1 and car.next_checkpoint ~= 1 then
      return false
  elseif cp_index > 1 and car.cp_crossed[cp_index] then
      return false
  end
  car.cp_crossed[cp_index] = true
  if not car.is_ghost then
    self.cp_sprites[cp_index][1].frames = 30
  end

  -- Completed a lap
  if car.next_checkpoint == 1 then
    -- Reset crossed checkpoints
    for i = 1, #map_checkpoints do
      car.cp_crossed[i] = false
    end

    if not car.is_ghost then
      -- Save/Load best time for this lap
      self.last_best_time = dget(get_lap_time_index(level_index, self.lap))
      add(self.lap_frames, self.frame)

      self.anim_frame = 1

      -- Completed the track
      if self.lap == map_settings.laps then
        self.state = 3
        music(20, 1000)

        -- If this is the new best time we have a recording of, save it
        if player.ghost_frame <= ghost_best_time then
          ghost_best_time = player.ghost_frame
          ghost_playback = ghost_recording
        end
        ghost_recording = {}
        for i = 1, 0x7fff do
          add(ghost_recording, -1)
        end

        -- If this is a new record update ALL lap times
        if self.last_best_time == 0 or self.last_best_time > self.frame then
          local start_index = get_lap_time_index(level_index, 0)
          for i = 1, map_settings.laps do
            dset(start_index + i, self.lap_frames[i])
          end
        end

        -- Always post time for leaderboard
        post_time_to_gpio(level_index, self.frame)

        -- Race Against Ghost achievement
        if ghost ~= nil then
          poke(0x5fff, 1)
        end

      else
        -- Display checkpoint time and delta
        add(objects, {
          time = self.frame,
          best_time = self.last_best_time,
          frames = 60,
          update = function(self)
            self.frames -= 1
            if self.frames == 0 then
              del(objects, self)
            end
          end,
          draw = function(self)
            print_shadowed(frame_to_time_str(self.time), camera_x + 50, camera_y + 32, 7)
            if self.best_time ~= 0 then
              print_shadowed((self.best_time >= self.time and '-' or '+') 
                .. frame_to_time_str(abs(self.best_time - self.time)), camera_x + 46, camera_y + 38,
                self.best_time >= self.time and 11 or 8)
            end
          end,
        })

        self.lap += 1
      end
      sfx(56, 1)
    end
  elseif not car.is_ghost then
    sfx(55, 1)
  end

  -- Advance checkpoint marker
  car.next_checkpoint = (car.next_checkpoint % #map_checkpoints) + 1
  return true
end

function post_time_to_gpio(level, frames)
  poke4(0x5f80 + level * 4, flr(frames/60) + (frames % 60 / 60 * 100 >> 16))
end

function get_lap_time_index(level_idx, lap)
  local data_index = 10 -- end of car customization + settings
  for i = 1, level_idx - 1 do
    data_index += map_settings_data[i].laps
  end
  data_index += lap
  return data_index
end

-- todo: token optimization? Could parse a big string for all this, but it would be a lot of chars...
function cache_checkpoints(self, checkpoints)
  self.cp_cache = {} -- table[x][y] -> cp index
  self.cp_sprites = {} -- table[cp_index] -> list of x, y, sprite to draw after crossing checkpoint

  for i = 1, #checkpoints do
    add(self.cp_sprites, {})
    local cp = checkpoints[i]
    local x = cp.x
    local y = cp.y
    local last_sprite_x = 0
    local last_sprite_y = 0
    for j = 1, cp.l do
      if self.cp_cache[x] == nil then
        self.cp_cache[x] = {}
      end
      self.cp_cache[x][y] = i

      local sprite_x = flr(x/8)
      local sprite_y = flr(y/8)
      if last_sprite_x ~= sprite_x or last_sprite_y ~= sprite_y then
        local sprite_index = map_decal_tiles[sprite_x][sprite_y]
        add(self.cp_sprites[i], {x=sprite_x*8, y=sprite_y*8, sprite=sprite_index, frames=0})
        last_sprite_x = sprite_x
        last_sprite_y = sprite_y
      end

      x += cp.dx
      y += cp.dy
    end
  end
end

function draw_cp_highlights(self)
  pal(4, 9)
  pal(3, 11)
  for i, crossed in pairs(player.cp_crossed) do
    local cp_data = self.cp_sprites[i]
    if crossed or cp_data[1].frames % 10 > 3 then
      for data in all(cp_data) do
        spr(data.sprite, data.x, data.y)
      end
    end
    if not crossed then
      cp_data[1].frames = max(cp_data[1].frames - 1, 0)
    end
  end
  pal()
end

--------------------
-- Map
--------------------

function load_map(data, data_offset, map_size)
  -- Initialize tables
  local map_tiles = {}
  local map_chunks = {}

  -- Parse data
  local data_decomp = decomp_str(data, data_offset)
  for i = 0, #data_decomp - 1 do
    -- The actual chunk index
    local chunk_index = data_decomp[i+1]

    -- "chunk map" x, y
    local chunk_x = i % map_size
    local chunk_y = flr(i / map_size)
    if map_chunks[chunk_x] == nil then map_chunks[chunk_x] = {} end
    map_chunks[chunk_x][chunk_y] = chunk_index

    -- top left corner of chunk in pico8 tile map
    local top_left_tile_x = (chunk_index % chunks_per_row) * chunk_size
    local top_left_tile_y = flr(chunk_index / chunks_per_row) * chunk_size
    for x = 0, 2 do
      for y = 0, 2 do
        local sprite_index = mget(top_left_tile_x + x, top_left_tile_y + y)
        local tile_x = chunk_x * chunk_size + x
        local tile_y = chunk_y * chunk_size + y
        if map_tiles[tile_x] == nil then map_tiles[tile_x] = {} end
        map_tiles[tile_x][tile_y] = sprite_index
      end
    end
  end

  return map_chunks, map_tiles
end

local sprite_sorts_raw = parse_table_arr(--[[member]]'y_intercept,slope',[[
|4,1
|-99,0
|11,-1
|3,0
|3,0
|3,0
|-4,1
|3,0
|3,-1,
|0,1]])
-- Table of [sprite_index] = {y_intercept=y_int, slope=s}
local sprite_sorts = {}
for __i, __spr_index in pairs(split('43,44,45,46,47,58,59,60,61,62')) do
  sprite_sorts[__spr_index] = sprite_sorts_raw[__i]
end
-- Table of chunk index -> color. Color 0 == nothing. Note: automated by mapPacker
  local solid_chunks = parse_hash_map('0,0,1,5,2,3,102,0,103,10,104,12,345,0') -- global solid_chunks
-- Sorting takes 24% CPU
function draw_map(map_chunks, map_size, draw_below_player, draw_above_player, has_jumps)
  -- Find the map index of the top-left map segment
  --local draw_distance = 6 -- ceil(16/chunk_size)

  for i = 0, 6 do
    for j = 0, 6 do
      local chunk_x = mid(flr(camera_x / 24) + i, 0, map_size - 1)
      local chunk_y = mid(flr(camera_y / 24) + j, 0, map_size - 1)

      local jump_frames = 0
      if has_jumps and map_jumps[chunk_x] ~= nil and map_jumps[chunk_x][chunk_y] ~= nil then
        jump_frames = map_jump_frames[map_jumps[chunk_x][chunk_y]]
      end

      local chunk_index = map_chunks[chunk_x][chunk_y] or 0
      if solid_chunks[chunk_index] ~= 0 then
        -- top left corner of chunk in pico8 tile map
        local tile_x = (chunk_index % chunks_per_row) * chunk_size
        local tile_y = flr(chunk_index / chunks_per_row) * chunk_size

        -- top left corner of chunk in world
        local world_x = chunk_x * 24
        local world_y = chunk_y * 24

        if draw_above_player and draw_below_player then
          -- draw whole chunk
          if solid_chunks[chunk_index] == 0 then
            -- pass
          elseif solid_chunks[chunk_index] ~= nil then
            rectfill(world_x, world_y, world_x + 23, world_y + 23, solid_chunks[chunk_index]) -- 23 == chunk_size * 8 - 1
          elseif jump_frames > 0 then
            local height = flr(jump_frames/8)
            pal(15, 2)
            map(tile_x, tile_y, world_x, world_y, chunk_size, chunk_size)
            palt(0b1000000110001000)
            for i = 1, height - 1 do
              map(tile_x, tile_y, world_x, world_y - i, chunk_size, chunk_size)
            end
            pal(15, height == 3 and 7 or 15)
            map(tile_x, tile_y, world_x, world_y - height, chunk_size, chunk_size)
            palt()
            pal()
          else
            map(tile_x, tile_y, world_x, world_y, chunk_size, chunk_size)
          end
        else
          -- draw map with proper sorting
          for i = 0, chunk_size - 1 do
            local strip_world_y = world_y + i * 8 -- map strip
            local above_player = strip_world_y < player.y
            local contains_player = player.y - 9 < strip_world_y + 9 and player.y + 7 > strip_world_y and player.x - 6 < world_x + 24 and player.x + 5 > world_x - 2
            if (above_player and draw_above_player) or (not above_player and draw_below_player) or contains_player then
              if not contains_player then
                map(tile_x, tile_y + i, world_x, strip_world_y, chunk_size, 1)
              else
                for j = 0, chunk_size - 1 do
                  local sprite_index = mget(tile_x + j, tile_y + i)
                  local draw = true
                  local sprite_x = world_x + j * 8
                  local sprite_y = world_y + i * 8
                  if sprite_sorts[sprite_index] ~= nil then
                    -- Project a line and see if the car is above or below it
                    local sprite_y_intercept = sprite_y + sprite_sorts[sprite_index].y_intercept
                    local car_y_intercept = player.y + (sprite_x - player.x) * sprite_sorts[sprite_index].slope
                    above_player = sprite_y_intercept < car_y_intercept
                    draw = (above_player and draw_above_player) or (not above_player and draw_below_player)
                  end
                  if draw then
                    spr(sprite_index, sprite_x, sprite_y)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

--------------------
-- VFX
--------------------

function spawn_trail_manager()
  trail_m = {
    --draw = _trail_manager_draw,
    points = {},
    points_i = 1,
    max_points = 1000, -- 10% CPU per 1k
  }

  for i = 1, trail_m.max_points do
    --poke2(0x8000 + i*6, 0, 0, 0)
    add(trail_m.points, {x=0,y=0,c=0})
  end
end

function add_trail_point(self, x, y, c)
  --poke2(0x8000 + self.points_i*6, x, y, c)
  self.points[self.points_i] = {x=x, y=y, c=c}
  self.points_i = (self.points_i % self.max_points) + 1
end

function _trail_manager_draw(self)
  --for i = 0x8000, 0x8000+self.max_points*6, 6 do
  --  pset(%i, %(i+2), %(i+4))
  --end
  for p in all(self.points) do
    pset(p.x, p.y, p.c)
  end
end

-- Volumetric particle manager
function spawn_particle_manager_vol()
  local particle_m = {
    points = {},
    points_i = 1,
    max_points = 40,
  }

  for i = 1, particle_m.max_points do
    --add(particle_m.points, {x=0, y=0, z=0, c=0, v_x=0, v_y=0, v_z=0, t=0, t_start=0, r=0, d=1, relative=0})
    add(particle_m.points, {t=0})
  end

  return particle_m
end

function add_particle_vol(self, x, y, z, c, v_x, v_y, v_z, t, r, relative)
  --self.points[self.points_i] = {x=x, y=y, z=z, c=c, v_x=v_x, v_y=v_y, v_z=v_z, t=t, t_start=t, r=r, d=rnd(0.05)+0.85}
  self.points[self.points_i] = {x=x-player.x*relative, y=y-player.y*relative, z=z, c=c, v_x=v_x, v_y=v_y, v_z=v_z, t=t, t_start=t, r=r, d=rnd(0.05)+0.85, relative=relative}
  self.points_i = (self.points_i % self.max_points) + 1
end

function _particle_manager_vol_update(self)
  for p in all(self.points) do
    if p.t > 0 then
      p.x += p.v_x
      p.y += p.v_y
      p.z += p.v_z
      p.v_x *= p.d
      p.v_y *= p.d
      p.v_z *= p.d
      p.t -= 1
      if (p.t * 3) % p.t_start == 0 then
        p.c = gradients[p.c]
        p.r -= 1
        p.v_z += 0.5
      end
      if p.t < 5 and p.r > 0 then
        p.r -= 0.5
      end
    end
  end
end

function _particle_manager_vol_draw_bg(self)
  -- Shadow pass
  for p in all(self.points) do
    if p.t > 0 then
      circfill(p.x+player.x*p.relative, p.y+player.y*p.relative, p.r + 1, 1)
    end
  end  
end

function _particle_manager_vol_draw_fg(self)
  -- Outline pass
  for i = 1, self.max_points do
    local p = self.points[(self.points_i - i) % self.max_points + 1]
    if p.t > 0 and p.t ~= p.t_start - 1 then
      --local x = mid(camera_x + p.r, p.x, camera_x +128-p.r)
      --local y = mid(camera_y + p.r, p.y-p.z, camera_y +128-p.r)
      --circfill(x, y, p.r + 1, gradients[gradients[p.c]])
      --circfill(p.x, p.y-p.z, p.r + 1, gradients[gradients[p.c]])
      circfill(p.x+player.x*p.relative, p.y-p.z+player.y*p.relative, p.r + 1, gradients[gradients[p.c]])
    end
  end

  -- Front pass
  for i = 1, self.max_points do
    local p = self.points[(self.points_i - i) % self.max_points + 1]
    if p.t > 0 then
      local c = p.t == p.t_start - 1 and 7 or p.c
      --local x = mid(camera_x + p.r, p.x, camera_x +128-p.r)
      --local y = mid(camera_y + p.r, p.y-p.z, camera_y +128-p.r)
      --local u = flr(abs(p.z)/2) -- underground correction
      --clip(0, 0, 128, p.y - camera_y) -- clip bottom
      --circfill(x, y, p.r, c)
      --circfill(p.x, p.y-p.z, p.r, c)
      circfill(p.x+player.x*p.relative, p.y-p.z+player.y*p.relative, p.r, c)
      --clip(0, p.y - camera_y, 128, 128) -- clip top
      --if p.z <= p.r then
      --  ovalfill(p.x - p.r + u, p.y - p.r/2, p.x + p.r - u, p.y + p.r/2 - u, c)
      --end
    end
  end
  --clip()
end


-- Water trail/wake
function spawn_particle_manager_water()
  local particle_m = {
    --draw = _particle_manager_water_draw, -- updates handled in draw so we can pget for performance
    points = {},
    points_i = 1,
    max_points = 500,
  }

  for i = 1, particle_m.max_points do
    --add(particle_m.points, {x=0, y=0, c=0, v_x=0, v_y=0, t=0})
    add(particle_m.points, {t=0})
  end

  return particle_m
end

function add_particle_water(self, x, y, v_x, v_y, t)--, double)
  --if rnd(1) > 0.5 then return end
  self.points[self.points_i] = {x=x, y=y, v_x=v_x, v_y=v_y, t=round(t),}
  self.points_i = (self.points_i % self.max_points) + 1
-- Too many tokens. Cutting this
--  if double then
--    local v_x_greater = abs(v_x) > abs(v_y)
--    self.points[self.points_i] = {x=x+(v_x_greater and 1 or 0), y=y+(v_x_greater and 0 or 1), c=c, v_x=v_x, v_y=v_y, t=round(t+rnd2(t*.2)),}
--    self.points_i = (self.points_i % self.max_points) + 1
--  end
end

function _particle_manager_water_draw(self)
  for p in all(self.points) do
    if p.t > 0 then
--      local x_before = flr(p.x)
--      local y_before = flr(p.y)
      p.x += p.v_x
      p.y += p.v_y
      -- collides_water_at() is more accurate but too expensive
--      if (flr(p.x) ~= x_before or flr(p.y) ~= y_before) and not collides_water_at(p.x, p.y) then
      local c = pget(p.x, p.y)
      if c == 5 or c == 3 then
        p.v_x *= -1
        p.v_y *= -1
        p.x += p.v_x
        p.y += p.v_y
      end
      p.t -= 1

      pset(p.x, p.y, p.t > 8 and 7 or 6)
    end
  end
end


function init_outline_cache(t, x)
  camera(-64,-64)
  cls()
  for i = 0, 32 do
    local rot = i/32
    t[rot] = {}
    pd_rotate(0,0,i/32,x,63.5,2,true,1)
    for x = -15, 15 do
      for y = -15, 15 do
        if pget(x, y) == 7 then
          add(t[rot], {x=x, y=y})
        end
      end
    end
    cls()
  end
end

function draw_water_outline(rot, car_x, car_y, car_z)
  for offset in all(outline_cache[rot]) do
    -- Repeated math is to save on compressed space
    if collides_water_at(car_x + offset.x, car_y + offset.y, car_z) then
      pset(car_x + offset.x, car_y + offset.y, 7)
    end
  end
end

--------------------
-- UI
--------------------

-- Built-in PICO-8 menu
function set_menu_items()
  menuitem(1, 'restart level', function() load_level(true) end)
  menuitem(2, 'quit level', quit_level)
  menuitem(3, 'ghost: ' .. (ghost_enabled and 'on' or 'off'), function()
    ghost_enabled = not ghost_enabled
    dset(10, ghost_enabled and 0 or 1)
    set_menu_items()
    return true
  end)
end

-- transition -> true when we should trigger the menu transition animation when activating this button
-- arrows_can_update -> true when arrows can be used instead of Z/X
function new_button(x, y, txt, update, transition, arrows_can_update)
  local obj = {x=x, y=y, txt=txt, transition=transition, arrows_can_update=arrows_can_update}
  obj.update = function(index, input) update(obj, index, input) end
  return obj
end

-- A menu is just a list of buttons + navigation
-- type one of 0 (horizontal) or 1 (vertical)
function new_menu(x, y, buttons, type, idle_duration)
  local obj = {x=x, y=y, buttons=buttons, type=type, idle_duration=idle_duration, index=1, frames=0, last_time=0, idle_frames=0}
  obj.update = function() return _menu_update(obj) end
  obj.draw = function() return _menu_draw(obj) end
  for button in all(buttons) do
    button.menu = obj
  end
  return obj
end

function _menu_update(self)
  self.frames = max(0, self.frames - 1)

  -- check if the menu was recently activated
  if time() - self.last_time > 0.1 then
    self.idle_frames = self.idle_duration
  end
  self.last_time = time()
  if self.idle_frames > 0 then
    self.idle_frames -= 1
    self.frames = 0
    return
  end

  -- Skip button updates during menu animations
  if menu_anim_frame >= 22 then
    return
  end

  -- up/down & left/right
  if btnp(self.type == 1 and 3 or 1) then
    self.index = (self.index % #self.buttons) + 1
    sfx(60)
  elseif btnp(self.type == 1 and 2 or 0) then
    self.index = self.index == 1 and #self.buttons or self.index - 1
    sfx(60)
  end

  -- update active button
  local button = self.buttons[self.index]
  local input = (btnp(5) and 1 or 0) - (btnp(4) and 1 or 0)
  if button.arrows_can_update then
--    if self.type == 1 then
--      input += (btnp(1) and 1 or 0) - (btnp(0) and 1 or 0)
--    else
--      input += (btnp(2) and 1 or 0) - (btnp(3) and 1 or 0)
--    end
    -- Condensed to save bytes. Equivalent to above
    input += (btnp(self.type == 1 and 1 or 2) and 1 or 0) 
           - (btnp(self.type == 1 and 0 or 3) and 1 or 0)
  end
  local cb = function() button.update(self.index, input) end
  if input ~= 0 then
    sfx(61)
    self.frames = 5
    if button.transition then
      menu_anim_frame = 45
      menu_anim_cb = cb
    else
      cb()
    end
  end
end

function _menu_draw(self)
  for i = 1, #self.buttons do
    local b = self.buttons[i]
    print_shadowed(b.txt, self.x + b.x + (i == self.index and 1 or 0), self.y + b.y, i == self.index and self.idle_frames == 0 and 7 or 6)
  end
  spr(16, self.x + self.buttons[self.index].x - (self.frames == 0 and 8 or 7), self.y + self.buttons[self.index].y - 2)
end

function btn_customization(self, index, input)
  if input ~= 0 then
    local opt = customization_m.data[index]
    --local num_colors = get_total_num_medals() == 60 and 32 or 16 -- Allow extra colors if user unlocked all medals
    --opt.chosen = (opt.chosen + input) % (opt.text == 'tYPE' and 4 or num_colors)
    opt.chosen = (opt.chosen + input) % (opt.text == 'tYPE' and 4 or (get_total_num_medals() == 60 and 32 or 16))
    -- Customization achievement
    poke(0x5ffe, 1)
  end
end

function spawn_customization_manager()
  customization_m = {
    update = _customization_manager_update,
    draw = _customization_manager_draw,
    car = {
      x = 91,
      y = 68,
      z = 0,
      boost_frames = 0,
      flash_frames = 0,
      angle_fwd = 0,
      water_wheels = 0,
      scale = 2
    },
    data = parse_table_arr(--[[member]]'text,original,chosen,target_angle',[[
|tYPE,0,0,0.875
|bODY,8,8,0
|sTRIPE,10,10,0.125
|wINDOWS,4,1,0.625
|wHEELS,0,0,0.375
|uNDERGLOW,14,1,0.5
|hEADLIGHTS,7,7,0.875
|bUMPER,6,6,0.625
]]),
  }

  local buttons = {}
  for i = 1, #customization_m.data do
    local d = customization_m.data[i]
    if dget(0) ~= 0 then
      d.chosen = dget(i)
    end
    add(buttons, new_button(0, i * 10, d.text, btn_customization, false, true))
  end
  add(buttons, new_button(46, 92, 'bACK', function(self) self.menu.index = 1 game_state = 3 end, true))
  customization_m.menu = new_menu(15, 15, buttons, 1, 1)
  _customization_manager_save(customization_m)

  add(objects, customization_m)
end

function _customization_manager_draw(self)
  if game_state ~= 1 then
    return
  end

  rectfill_outlined(0, 11, 128, 117, 12, 1)
  print_shadowed('gARAGE', 54, 18, 7)
  rectfill_outlined(61, 33, 121, 95, 12, 13)

  color_dot(80, 20)

  ovalfill(69, 50, 113, 86, 5)
  oval    (69, 50, 113, 86, 6)
  for i = -1, 1, 2 do
    clip(83 + sin(time() * 0.25) * 22 * i, 60 - cos(time() * 0.25) * 18 * i, 16, 16)
    oval(69, 50, 113, 86, self.data[2].chosen)
  end
  clip()

  _car_draw(self.car)
  self.menu.draw()
end

function _customization_manager_update(self)
  if game_state ~= 1 then
    return
  end

  camera()
  --self.car.angle_fwd += 0.003
  local a = self.data[min(self.menu.index, 8)].target_angle
  local b = self.car.angle_fwd

  if abs(a-b) > 0.5 then
    if a > b then
      b += 1
    else
      a += 1
    end
  end

  self.car.angle_fwd = (self.car.angle_fwd + (a - b) * .25) % 1
  --self.car.angle_fwd = 0.5

  self.menu.update()
  _customization_manager_save(self)
end

function _customization_manager_save(self)
  -- sync car to map
  for i = 0, 4 do
    local type = self.data[1].chosen
    mset(126 - i * 3, 63, 70 + i * 2 + 16 * type)
    mset(127 - i * 3, 63, 71 + i * 2 + 16 * type)
  end

  -- save settings
  dset(0, 1) -- marker that settings are no longer default
  for i = 1, #customization_m.data do
    dset(i, customization_m.data[i].chosen)
  end
end

function spawn_level_select_manager()
  local buttons = {
    new_button(0, 0, 'lEVEL ' .. map_settings.name, function(self, index, input)
      -- 1-index hell :(
      local max_level = 1
      while map_settings_data[max_level].req_medals <= get_total_num_medals() and max_level < #map_settings_data do
        max_level += 1
      end
      level_index = ((level_index - 1 + input) % max_level) + 1
      load_level(false)
      self.txt = 'lEVEL ' .. map_settings.name
    end, false, true),
    new_button(44, 0, 'sTART', function(self)
      if map_settings.req_medals <= get_total_num_medals() then
        music(-1, 1000)
        self.menu.index = 1
        game_state = 0
        ghost_best_time = 0x7fff
        ghost_playback = {}
        for i = 1, 0x7fff do
          add(ghost_playback, -1)
        end
      end
    end, true),
    new_button(80, 0, 'bACK', function(self) self.menu.index = 1 game_state = 3 end, true)
  }

  add(objects, {
    update = _level_select_manager_update,
    draw = _level_select_manager_draw,
    menu = new_menu(15, 23, buttons, 0, 1)
  })
end

function _level_select_manager_draw(self)
  if game_state ~= 2 then
    return
  end

  rectfill_outlined(0, 5, 128, 122, 12, 1)
  print_shadowed('sELECT tRACK', 40, 11, 7)

  self.menu.draw()
  rectfill_outlined(0, 33, 128, 122, 12, 3)


  local medals_to_unlock = map_settings.req_medals - get_total_num_medals()

  if medals_to_unlock <= 0 then
    draw_minimap(83 - map_settings.size*chunk_size/2, 33)

    local data_index = get_lap_time_index(level_index, map_settings.laps)
    local best_time = dget(data_index)
    rectfill_outlined(0, 48, 36, 106, 12, 1)
    print_shadowed('bEST', 3, 52, 7)
    print_shadowed(frame_to_time_str(best_time), 3, 60, 7)

    if best_time > 0 then
      draw_medals(10, 70, best_time)
    end
  else
    -- need 4 more medals
  --rectfill_outlined(0, 32, 128, 123, 12, 3)
    rectfill_outlined(0, 57, 128,  98, 12, 1)
    --spr(32, 39, y+5)
    --spr(32, 80, y+5)
    spr(32, 9, 74)
    spr(32, 110, 74)
    print_shadowed('lOCKED!', 50, 71, 7)
    local medals_str = medals_to_unlock == 1 and ' MORE MEDAL' or ' MORE MEDALS'
    print_shadowed('nEED ' .. medals_to_unlock .. medals_str, 28, 79, 7)
  end
end

-- From the original sprite: c1 = white, c2 = yellow, c3 = orange, c4 = brown, c5 = purple
local medal_pal = {
  split('7,9,10,9,9,4,4,2,2,2'), -- bronze
  split('7,6,10,6,9,5,4,13,2,13'), -- silver
  split('7,10,10,10,9,9,4,4,2,2'), -- gold
  split('7,7,10,12,9,13,4,2,2,1'), -- plat
}

function draw_medals(x, y, time)
  local num_medals = get_num_medals(time, map_settings)

  -- Display time requirement for next medal
  -- Plat medal times are secret until you average gold across all tracks
  if num_medals < 3 or (num_medals < 4 and get_total_num_medals() >= 45) then
    print_shadowed('nEXT mDL', x - 7, y + 20, 6)
    local next_medal_frames =
      map_settings.bronze < time and map_settings.bronze 
      or map_settings.silver < time and map_settings.silver 
      or map_settings.gold < time and map_settings.gold 
      or map_settings.plat
    print_shadowed(frame_to_time_str(next_medal_frames), x - 7, y + 28, 6)
  end

  -- Draw the medals themselves
  local dx = 4
  local dy = -1

  x -= dx * (num_medals - 1) / 2
  y -= dy * (num_medals - 1) / 2

  for i = 1, num_medals do
    pal()
    local medal_p = medal_pal[i]
    for j = 1, #medal_p, 2 do
      pal(medal_p[j], medal_p[j+1])
    end
    sspr(0, 48, 16, 16, x + dx*(i-1), y + dy*(i-1))
  end
  pal()
end

function get_num_medals(time, settings)
  return 
       time <= settings.plat and 4
    or time <= settings.gold and 3
    or time <= settings.silver and 2
    or time <= settings.bronze and 1
    or 0
end

function get_total_num_medals()
  local num_medals = 0
  for i = 1, #map_settings_data do
    local best_time = dget(get_lap_time_index(i, map_settings_data[i].laps))
    if best_time > 0 then
      num_medals += get_num_medals(best_time, map_settings_data[i])
    end
  end
  return num_medals
end

function _level_select_manager_update(self)
  if game_state ~= 2 then
    return
  end
  camera()

  self.menu.update()
end

function spawn_main_menu_manager()
  local buttons = {
    new_button(0, 0, 'rACE', function() game_state = 2 end, true),
    new_button(0, 10, 'gARAGE', function() game_state = 1 end, true),
    new_button(-49, 30, 'mAX bIZE', function() poke(0x5ffd) end) -- GPIO signal to open external link
  }

  add(objects, {
    update = _main_menu_manager_update,
    draw = _main_menu_manager_draw,
    menu = new_menu(60, 85, buttons, 1, 1),
    car = {
      --x = 90,
      --y = 65,
      z = 0,
      boost_frames = 0,
      flash_frames = 0,
      angle_fwd = 0,
      water_wheels = 0,
      scale = 2
    },
    time = 0,
  })
end

function _main_menu_manager_draw(self)
  if game_state ~= 3 then
    return
  end

  rectfill_outlined(0, 5, 128, 123, 12, 1)
  rectfill_outlined(0, 43, 128, 78, 6, 5)
  rect(-1, 43, 128, 78, 6)

  palt(0b0000000000000001)
  sspr(0, 88, 119, 33, 4, 7)
  palt()
  print_shadowed('cREATED bY', 3, 107, 6)
  print_shadowed('V 1.1.0', 98, 115, 6)

  map(124, 44, flr(200 - (time() * 200) % 500), 54)

  _particle_manager_vol_draw_bg(particle_vol_m)
  _particle_manager_vol_draw_fg(particle_vol_m)

  color_dot(86, 97)

  _car_draw(self.car)

  self.menu.draw()
end

-- Color-changing rect to indicate easter egg
function color_dot(x, y)
  if get_total_num_medals() == 60 then -- end of development - hardcoding number of maps
    rect(x, y, x+1, y+1, time()*10)
  end
end

function _main_menu_manager_update(self)
  if game_state ~= 3 then
    self.time = 0
    return
  end
  camera()

  self.car.x = min(90, self.time * 100) + flr(cos(self.time * 0.3) * 3.9)
  self.car.y = 65 + cos(self.time * 0.25)
  self.time = (self.time + 0.016666) % 327 -- flr(0x7fff/100) so that we don't overflow car.x

  if rnd(1) < 0.5 then
    add_particle_vol(particle_vol_m, self.car.x - 15, self.car.y, 4, rnd(1) < 0.5 and 10 or 9, -5 + rnd2(-1, 1), rnd2(-1, 1), rnd(0.5)-0.25, 60, 6, 1)
  end

  self.menu.update()
end

local pset_map = parse_hash_map("1,5,2,5,3,5,4,5,5,5,10,11,11,11,27,11,28,11,12,9,13,9,14,9,15,9,21,10,22,10,23,10,24,10,25,10,29,7,31,7,37,15,38,15,39,15,40,15,41,15,42,7,43,7,44,7,45,7,46,7,47,7,58,7,59,7,60,7,61,7,62,7,63,7,64,12,67,12,68,12,83,12,84,12")
local minimap = {} -- Storage
function load_minimap()
  minimap = {}
  for i = 0, #map_road_tiles do
    minimap[i] = {}
    for j = 0, #map_road_tiles do
      -- Neat trick: we only want to draw the top-most non-null layer. Chain `nil` -> or evaluation to find it
      minimap[i][j] = pset_map[map_prop_tiles[i][j]] or pset_map[map_decal_tiles[i][j]] or pset_map[map_road_tiles[i][j]]
    end
  end
end

function draw_minimap(x, y)
  for i = 0, #map_road_tiles do
    for j = 0, #map_road_tiles do
      local c = minimap[i][j]
      if c ~= nil then
        pset(x + i, y + j, c)
      end
    end
  end
end
