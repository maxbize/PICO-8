-- driftmania
-- by max bize

-- TODO: Token optimization around duplicated lookups of car state, wheel offsets, etc

--------------------
-- Global State
--------------------
local objects = {}
local player = nil
local level_m = nil
local trail_m = nil
local particle_vol_m = nil
local particle_water_m = nil
local game_state = 3 -- 0=race, 1=customization, 2=level select, 3=main menu
local level_index = 1
local pause_frames = 0
local camera_x = 0
local camera_y = 0

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
cartdata('mbize_driftmania_v1')
local dynamic_camera_disabled = dget(9) == 1 -- flag is _disabled so that default is on
local ghost_enabled = dget(10) == 1

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
  for i = 1, count(csv_arr), 2 do
    t[csv_arr[i]] = csv_arr[i+1]
  end
  return t
end

-- Creates a table of [header]=val
function parse_table(headers, csv)
  local t = {}
  local headers_arr = split(headers)
  local csv_arr = split(csv)
  for i = 1, count(headers_arr) do
    t[headers_arr[i]] = csv_arr[i]
  end
  return t
end

-- Creates a list of tables of [header]=val
-- Assume obj separator is '|' and that the first entry is empty
function parse_table_arr(headers, csv)
  local a = {}
  local csv_arr = split(csv, '|')
  for i = 2, count(csv_arr) do
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
  for i = 2, count(csv_arr), 2 do
    a[csv_arr[i]] = parse_hash_map(csv_arr[i+1])
  end
  return a
end

-- Parse a string of multiple things through func with args1/2
--function parse_multi(s, func, arg1, arg2)
--  local a = {}
--  local csv_arr = split(s, '$')
--  for i = 2, count(csv_arr) do
--    add(a, func(csv_arr[i], arg1, arg2))
--  end
--  return a
--end

--------------------
-- Data
--------------------
local map_road_data = {
  "\0そ⁙¹⁶³\n¹\0」⁸¹¹¹に¹¹¹\r¹\0」⁸¹•¹ぬ¹▮¹\r¹\0」⁸¹\r¹\0¹⁸¹\r¹\0「⁘¹‖¹\r¹\0¹⁸¹\r¹\0\r⁙¹⁶\n「¹¹¹\r¹\0¹⁸¹\r¹\0\r⁸¹¹¹¥¹ᵇ\n□¹\0¹⁸¹\r¹\0\r⁸¹•¹、¹\0ᵇ⁘¹‖¹\r¹\0\r⁸¹\r¹\0¹⁙¹⁶\n「¹¹¹\r¹\0\r⁸¹\r¹\0¹⁸¹¹¹¥¹ᵇ\n□¹\0\r⁸¹\r¹\0¹⁸¹•¹、¹\0「⁸¹\r¹\0¹⁸¹◀¹▶¹\0「⁸¹\r¹\0¹⁸¹¹¹」¹⁶⁴\n¹\0⁙⁸¹\r¹\0¹■¹ᵇ⁴ᶜ¹¹¹\r¹\0⁙⁸¹\r¹\0⁶ᶠ¹▮¹\r¹\0⁙⁸¹\r¹\0⁷⁸¹\r¹\0⁙⁸¹◀¹▶¹\0⁵⁘¹‖¹\r¹\0⁙⁸¹¹¹」¹⁶⁵「¹¹¹\r¹\0⁙■¹ᵇ\t□¹\0り", -- driftmaniaLevelA1.tmx road
  "\0け⁵¹⁶⁵⁷¹\0◀⁵¹¹¹☉¹ᵇ³ひ¹¹¹⁷¹\0⁘⁵¹¹¹⬅️¹😐¹\0³🅾️¹◆¹¹¹⁷¹\0⁙⁸¹ふ¹😐¹\0⁵🅾️¹へ¹\r¹\0⁙⁸¹\r¹\0⁷⁸¹\r¹\0⁙⁸¹\r¹\0⁷⁸¹\r¹\0⁙⁸¹ほ¹▒¹\0⁵ま¹み¹\r¹\0⁙\t¹¹¹🐱¹▒¹\0³ま¹む¹¹¹ᵉ¹\0⁘\t¹¹¹🐱¹▒¹\0¹ま¹む¹¹¹ᵉ¹\0◀\t¹¹¹め¹▶¹も¹¹¹ᵉ¹\0「や¹ゆ¹よ¹ら¹り¹\0」る¹れ¹ゆ¹よ¹ろ¹\0「⁵¹¹¹わ¹ᶠ¹▮¹🐱¹▒¹\0◀⁵¹¹¹⬅️¹😐¹\0¹\t¹¹¹🐱¹▒¹\0⁘⁵¹¹¹⬅️¹😐¹\0³\t¹¹¹🐱¹▒¹\0⁙⁸¹ふ¹😐¹\0⁵\t¹¹¹⬇️¹\0⁙⁸¹\r¹\0⁷⁸¹\r¹\0⁙⁸¹\r¹\0⁷⁸¹\r¹\0⁙⁸¹\r¹\0⁷⁸¹\r¹\0⁙⁸¹◀¹▶¹\0⁵⁘¹‖¹\r¹\0⁙⁸¹¹¹」¹⁶⁵「¹¹¹\r¹\0⁙■¹ᵇ\t□¹\0c", -- driftmaniaLevelA2.tmx road
  "\0ヲ⁵¹⁶⁵⁷¹\0◀⁵¹¹²ᵇ³¹²⁷¹\0‖⁸¹¹¹ᵉ¹\0³\t¹¹¹\r¹\0‖⁸¹◀¹▶¹\0⁴⁸¹\r¹\0‖⁸¹¹¹」¹⁶²\n¹\0¹⁸¹\r¹\0¹⁙¹⁶⁴\n¹\0ᵉ■¹ᵇ⁴□¹\0¹⁸¹\r¹\0¹■¹ᵇ²ᶜ¹¹¹\r¹\0‖⁸¹\r¹\0⁴ᶠ¹▮¹\r¹\0‖⁸¹\r¹\0⁴⁘¹‖¹\r¹\0▮⁙¹⁶²\n¹\0¹⁸¹\r¹\0¹⁙¹⁶²「¹¹¹\r¹\0▮⁸¹¹¹¥¹□¹\0¹⁸¹\r¹\0¹■¹ᵇ⁴□¹\0▮⁸¹•¹、¹\0²⁸¹\r¹\0▶⁸¹\r¹\0³⁸¹\r¹\0▶⁸¹◀¹▶¹\0¹⁘¹‖¹\r¹\0▶⁸¹¹¹」¹⁶¹「¹¹¹\r¹\0▶■¹ᵇ⁵□¹\0ナ", -- driftmaniaLevel2.tmx road
  "\0?⁵¹⁶²⁷¹\0¥⁸¹¹³⁷¹\0」⁸¹¹⁴⁷¹\0「\t¹¹⁵⁷¹\0「\t¹¹⁵⁷¹\0「\t¹¹⁵⁷¹\0「\t¹¹⁵⁶⁸\n¹\0▮\t¹¹⁴ᵇ⁶ᶜ¹¹¹\r¹\0■\t¹¹²ᵉ¹\0⁶ᶠ¹▮¹\r¹\0□⁸¹\r¹\0⁸⁸¹\r¹\0□⁸¹\r¹\0⁸⁸¹\r¹\0□■¹□¹\0⁸⁸¹\r¹\0、⁸¹\r¹\0、⁸¹\r¹\0□⁙¹\n¹\0⁸⁸¹\r¹\0□■¹□¹\0⁸⁸¹\r¹\0•⁘¹‖¹◀¹▶¹\0⁘⁙¹⁶⁵「¹¹²」¹⁶⁵\n¹\0ᵉ■¹ᵇ⁵ᶜ¹¹²¥¹ᵇ³ᶜ¹¹¹\r¹\0⁘ᶠ¹▮¹•¹、¹\0³ᶠ¹▮¹\r¹\0‖⁸¹\r¹\0⁵⁸¹\r¹\0‖⁸¹\r¹\0⁵⁸¹\r¹\0‖⁸¹\r¹\0⁵⁸¹\r¹\0‖⁸¹◀¹▶¹\0³⁘¹‖¹\r¹\0‖⁸¹¹¹」¹⁶³「¹¹¹\r¹\0‖■¹ᵇ⁷□¹\0>", -- driftmaniaLevel1.tmx road
  "\0ト⁵¹⁶²█¹▒¹\0」⁸¹¹¹¥¹¹¹🐱¹▒¹\0「⁸¹•¹、¹\t¹¹¹⬇️¹\0▶⁘¹‖¹\r¹\0²⁸¹\r¹\0□⁘¹░¹⁶³「¹¹¹\r¹\0²⁸¹\r¹\0□✽¹¹¹¥¹ᶜ¹¹³\r¹\0²⁸¹\r¹\0□⁸¹•¹、¹ᶠ¹▮¹¹²\r¹\0²⁸¹\r¹\0□⁸¹\r¹\0²⁸¹¹²\r¹\0²⁸¹◀¹▶¹\0■⁸¹\r¹\0²⁸¹¹²\r¹\0²■¹ᶜ¹」¹⁶²\n¹\0ᵉ⁸¹\r¹\0²⁸¹¹²\r¹\0³ᶠ¹▮¹¹²\r¹\0ᵉ⁸¹\r¹\0²●¹¹²♥¹\0³⁵¹¹¹☉¹ᵇ¹□¹\0ᵉ⁸¹\r¹\0²ᶠ¹웃¹⌂¹、¹\0²⁵¹¹¹⬅️¹😐¹\0▮♪¹¹¹⁷¹\0⁶⁵¹¹¹⬅️¹😐¹\0■🅾️¹◆¹¹¹⁷¹\0⁴⁵¹¹¹⬅️¹😐¹\0⁙🅾️¹◆¹¹¹⁶⁴¹¹⬅️¹😐¹\0‖🅾️¹…¹ᵇ⁴➡️¹😐¹\0ト", -- driftmaniaLevel3.tmx road
  "\0を⁘¹░¹⁶³⁷¹\0▶⁘¹サ¹¹¹¥¹ᶜ¹¹²⁷¹\0‖⁘¹サ¹¹¹シ¹、¹ス¹¹²\r¹\0⁘⁘¹サ¹¹¹シ¹、¹⁵¹¹¹☉¹¹¹\r¹\0⁙⁘¹サ¹¹¹シ¹、¹⁵¹¹¹⬅️¹😐¹⁸¹\r¹\0□⁘¹サ¹¹¹シ¹、¹⁵¹¹¹⬅️¹😐¹ま¹み¹\r¹\0■⁘¹サ¹¹¹シ¹、¹⁵¹¹¹⬅️¹😐¹ま¹む¹¹¹ᵉ¹\0▮⁘¹サ¹¹¹シ¹、¹⁵¹¹¹⬅️¹😐¹ま¹む¹¹¹ᵉ¹\0▮⁘¹サ¹¹¹シ¹、¹⁵¹¹¹⬅️¹😐¹ま¹む¹¹¹ᵉ¹\0▮⁘¹サ¹¹¹シ¹、¹⁵¹¹¹⬅️¹😐¹ま¹む¹¹¹ᵉ¹\0▮⁘¹サ¹¹¹シ¹、¹⁵¹¹¹⬅️¹😐¹ま¹む¹¹¹ᵉ¹\0▮⁘¹サ¹¹¹シ¹、¹⁵¹¹¹⬅️¹😐¹ま¹む¹¹¹ᵉ¹\0■✽¹¹¹シ¹、¹セ¹◆¹⬅️¹😐¹ま¹む¹¹¹ᵉ¹\0□⁸¹¹¹ソ¹\0²🅾️¹😐¹ま¹む¹¹¹ᵉ¹\0⁙\t¹¹¹🐱¹▒¹\0²ま¹む¹¹¹ᵉ¹\0‖\t¹¹¹🐱¹▒¹ま¹む¹¹¹ᵉ¹\0▶\t¹¹¹タ¹チ¹¹¹ᵉ¹\0」\t¹ᵇ²ᵉ¹\0ろ", -- driftmaniaLevelExp1.tmx road
}
local map_decals_data = {
  "\0っね¹\0•(¹3¹の¹'¹\0¥(¹\0²(¹\0」。¹I¹\0²(¹\0⁘う¹\0⁴L¹\0⁘★¹C²\0¹う¹\0「3¹r¹\0ᵇ。¹I¹\0¥K²L¹M¹\0⁙★¹\0\nO¹\0■3¹r¹\0、6¹゛¹\0。=¹K²\0゛&¹\0◀s¹\0⁶゜¹'¹\0‖s¹\0⁷(¹\0‖6¹゛¹\0⁵。¹I¹\0◀=¹\0³K²L¹M¹\0゛O¹\0り", -- driftmaniaLevelA1.tmx decals
  "\0◝\0」を²\0⁷ˇ²\0➡️ん¹*¹\0、っ¹ゃ¹\0」ゅ¹ょ¹\0。ア¹\0?イ¹ウ¹\0、エ¹オ¹\0⁘ˇ²\0。s¹\0。s¹\0。6¹゛¹\0⁵。¹I¹\0◀=¹\0³K²L¹\0⬇️", -- driftmaniaLevelA2.tmx decals
  "\0◝\0▶d¹\0。e¹f¹\0¹g¹\0¥6¹゛¹\0¹h¹\0•=¹K²\0⁵i¹j¹\0³k¹\0「l¹m¹\0¹&¹$¹\0¥g¹\0¹゜¹'¹\0¥h¹\0¹。¹I¹\0⁙n¹o¹\0⁵K²L¹\0⁘p¹q¹\0•3¹r¹\0²(¹\0」s¹\0³(¹\0」6¹゛¹\0¹。¹I¹\0」$¹=¹K¹L¹\0」t¹\0ヒ", -- driftmaniaLevel2.tmx decals
  "\0^。¹゛¹\0、゜¹ ¹゛¹\0¹!¹\0•\"¹#¹\0、$¹\0、%¹\0H&¹\0。゜¹'¹\0。(¹\0。)¹*¹\0、+¹,¹\0□-¹.¹\0⁸/¹0¹\0□1¹2¹\0。3¹\0⁸4¹5¹\0⁙6¹\0⁸7¹8¹\0□-¹9¹:¹\0•;¹⁴¹<¹=¹\0⁷>¹\0□?¹@¹A¹\0⁴B¹\0⁶C²&¹\0▶D¹*¹\0⁴゜¹'¹\0◀+¹,¹\0‖E¹F¹\0⁵/¹0¹\0⁵(¹\0ᶠG¹H¹\0ᶜ(¹\0▶6¹゛¹\0³。¹I¹\0◀J¹\0¹=¹K²\0¹L¹M¹\0◀N¹\0⁷O¹\0>", -- driftmaniaLevel1.tmx decals
  "\0◝\0\0★¹\0、3¹r¹⧗¹\0•s¹\0²(¹\0¥s¹\0「★¹&¹\0•3¹r¹゜¹'¹\0¹⬆️¹ˇ¹\0²ˇ²\0⁙s¹\0³∧¹\0」s¹\0³∧¹\0⁵&¹\0▶❎¹▤¹\0⁴゜¹▥¹あ¹\0、い¹L¹\0•い¹\0、い¹\0、い¹\0「う¹\0³い¹\0」う¹\0ノ", -- driftmaniaLevel3.tmx decals
  "\0◝\0=D¹ツ¹テ¹\0」ト¹\0¹ナ¹ニ¹\0•O¹\0•D¹ヌ¹\0¹ネ¹ノ¹\0¹D¹ツ¹テ¹\0‖ハ¹ヒ¹\0²フ¹\0¹ナ¹ニ¹\0◀ヘ¹\0⁴ホ¹\0•D¹ヌ¹\0¹M¹\0◀g¹\0³ハ¹ヒ¹\0「マ¹ミ¹\0²ヘ¹\0」ム¹0¹\0◝\0=", -- driftmaniaLevelExp1.tmx decals
}
local map_props_data = {
  "\0웃c¹Q⁵^¹\0▶W¹\0⁵W¹\0▶W¹\0⁵W¹\0▶W¹\0²は¹\0²W¹\0▶W¹\0²W¹\0²W¹\0ᵇc¹Qᵇb¹\0²W¹\0²W¹\0ᵇW¹\0ᵉW¹\0²W¹\0ᵇW¹\0ᵉW¹\0²W¹\0ᵇW¹\0²c¹Qᵇb¹\0²W¹\0ᵇW¹\0²W¹\0ᵉW¹\0ᵇW¹\0²W¹\0ᵉW¹\0ᵇW¹\0²W¹\0²~¹Qᵇb¹\0ᵇW¹\0²W¹\0²○¹Q⁵^¹\0■W¹\0²W¹\0⁸W¹\0■W¹\0²W¹\0⁸W¹\0■W¹\0²z¹Q⁵^¹\0²W¹\0■W¹\0²W¹\0⁵W¹\0²W¹\0■W¹\0²a¹Q⁵b¹\0²W¹\0■W¹\0ᵇW¹\0■W¹\0ᵇW¹\0■a¹Qᵇb¹\0け", -- driftmaniaLevelA1.tmx props
  "\0░P¹Q⁵R¹\0◀u¹T¹\0⁵U¹V¹\0⁘u¹T¹\0⁷U¹V¹\0□S¹T¹\0²c¹Q³^¹\0²U¹v¹\0■W¹\0²c¹b¹\0³a¹^¹\0²W¹\0■W¹\0²W¹\0⁵W¹\0²W¹\0■W¹\0²W¹\0⁵W¹\0²W¹\0■W¹\0²a¹^¹\0³c¹b¹\0²W¹\0■[¹Y¹\0²a¹^¹\0¹c¹b¹\0²X¹カ¹\0□\\¹Y¹\0²a¹キ¹b¹\0²X¹く¹\0⁘\\¹Y¹\0²て¹\0²X¹く¹\0◀\\¹ク¹Y¹U¹V¹X¹く¹\0▶u¹T¹\\¹Y¹U¹ケ¹^¹\0◀u¹T¹\0²`¹\0²a¹^¹\0⁘u¹T¹\0²c¹コ¹Y¹\0²a¹^¹\0□S¹T¹\0²c¹b¹\0¹\\¹Y¹\0²a¹^¹\0■W¹\0²c¹b¹\0³\\¹Y¹\0²W¹\0■W¹\0²W¹\0⁵`¹\0²W¹\0■W¹\0²W¹\0⁵W¹\0²W¹\0■W¹\0²W¹\0⁵W¹\0²W¹\0■W¹\0²a¹Q⁵b¹\0²W¹\0■W¹\0ᵇW¹\0■W¹\0ᵇW¹\0■a¹Qᵇb¹\0D", -- driftmaniaLevelA2.tmx props
  "\0ソP¹Q⁵R¹\0◀u¹T¹\0⁵U¹V¹\0⁘S¹T¹\0⁷U¹v¹\0⁙W¹\0²X¹w³Y¹\0²W¹\0⁙W¹\0²x¹Q³y¹\0²z¹Q⁶^¹\0ᶜW¹\0⁶W¹\0²W¹\0⁶W¹\0ᶜW¹\0⁶W¹\0²W¹\0⁶W¹\0ᶜa¹Q⁶{¹\0²z¹Q³|¹\0²W¹\0ᵉc¹Q⁴{¹\0²z¹Q³}¹\0²W¹\0ᵉW¹\0⁴W¹\0²W¹\0⁶W¹\0ᵉW¹\0⁴W¹\0²W¹\0⁶W¹\0ᵉW¹\0²~¹Q¹{¹\0²z¹Q⁶b¹\0ᵉW¹\0²W¹\0¹W¹\0²W¹\0‖W¹\0²○¹Q¹}¹\0²W¹\0‖W¹\0⁷W¹\0‖W¹\0⁷W¹\0‖a¹Q⁷b¹\0り", -- driftmaniaLevel2.tmx props
  "\0!P¹Q²R¹\0」S¹T¹\0²U¹V¹\0「W¹\0¹X¹Y¹\0¹U¹V¹\0▶W¹\0¹U¹Z¹Y¹\0¹U¹V¹\0◀[¹Y¹\0¹U¹Z¹Y¹\0¹U¹V¹\0◀\\¹Y¹\0¹U¹Z¹Y¹\0¹U¹V¹\0◀\\¹Y¹\0¹U¹Z¹Y¹\0¹U¹]¹Q⁸^¹\0\r\\¹Y¹\0¹U¹Z¹Y¹\0\nW¹\0ᵉ\\¹Y¹\0¹U¹Z¹Y¹\0\tW¹\0ᶠ\\¹Y¹\0¹U¹_¹Q⁶^¹\0²W¹\0▮`¹\0²W¹\0⁶W¹\0²W¹\0▮W¹\0²W¹\0⁶W¹\0²W¹\0▮W¹\0²W¹\0⁶W¹\0²W¹\0▮W¹\0²W¹\0⁶W¹\0²W¹\0▮W¹\0²W¹\0⁶W¹\0²W¹\0▮W¹\0²W¹\0⁶W¹\0²W¹\0▮W¹\0²W¹\0⁶W¹\0²W¹\0▮W¹\0²a¹Q⁶b¹\0²a¹Q⁶^¹\0\tW¹\0⁙W¹\0\tW¹\0⁙W¹\0\ta¹Q\t^¹\0²c¹Q³^¹\0²W¹\0⁙W¹\0²W¹\0³W¹\0²W¹\0⁙W¹\0²W¹\0³W¹\0²W¹\0⁙W¹\0²W¹\0³W¹\0²W¹\0⁙W¹\0²a¹Q³b¹\0²W¹\0⁙W¹\0\tW¹\0⁙W¹\0\tW¹\0⁙a¹Q\tb¹\0゜", -- driftmaniaLevel1.tmx props
  "\0りP¹Q³^¹\0「S¹T¹\0³a¹^¹\0▶W¹\0⁵a¹^¹\0◀W¹\0²え¹Y¹\0²W¹\0■X¹お¹Q²か¹き¹\0²W¹`¹\0²W¹\0▮X¹く¹\0⁴け¹こ¹\0¹W²\0²W¹\0▮さ¹\0⁵し¹す¹\0¹W²\0²W¹\0▮W¹\0²~¹|¹\0¹し¹す¹\0¹W²\0²W¹\0▮W¹\0²W²\0¹し¹す¹\0¹W²\0²○¹Q³^¹\0ᶜW¹\0²W²\0¹し¹す¹\0¹W²\0⁶W¹\0ᶜW¹\0²W²\0¹せ¹そ¹\0¹W¹○¹Q¹た¹ち¹つ¹\0²W¹\0ᶜW¹\0²W¹て¹\0⁴と¹\0¹u¹T¹\0⁴W¹\0ᶜW¹\0²て¹U¹V¹\0²u¹T¹u¹T¹\0²c¹Q²b¹\0ᶜW¹\0²U¹V¹U¹]¹な¹T¹u¹T¹\0²c¹b¹\0ᶠa¹^¹\0²U¹]¹Q²な¹T¹\0²c¹b¹\0■a¹^¹\0⁸c¹b¹\0⁙a¹^¹\0⁶c¹b¹\0‖a¹Q⁶b¹\0り", -- driftmaniaLevel3.tmx props
  "\0そX¹お¹Q³R¹\0▶X¹く¹\0⁴U¹V¹\0‖X¹く¹\0⁶U¹v¹\0⁙X¹く¹\0³メ¹\0⁴W¹\0□X¹く¹\0³u¹T¹\0⁴W¹\0■X¹く¹\0³u¹T¹\0²モ¹\0²W¹\0▮X¹く¹\0³u¹T¹\0²c¹b¹\0²W¹\0ᶠX¹く¹\0³u¹T¹\0²c¹b¹\0²X¹カ¹\0ᵉX¹く¹\0³u¹T¹\0²c¹b¹\0²X¹く¹\0ᵉX¹く¹\0³u¹T¹\0²c¹b¹\0²X¹く¹\0ᵉX¹く¹\0³u¹T¹\0²c¹b¹\0²X¹く¹\0ᵉX¹く¹\0³u¹T¹\0²c¹b¹\0²X¹く¹\0ᵉX¹く¹\0³u¹T¹\0²c¹b¹\0²X¹く¹\0ᶠさ¹\0³ヤ¹ユ¹\0²c¹b¹\0²X¹く¹\0▮W¹\0⁴a¹^¹c¹b¹\0²X¹く¹\0■[¹Y¹\0⁴a¹b¹\0²X¹く¹\0⁙\\¹Y¹\0⁶X¹く¹\0‖\\¹Y¹\0⁴X¹く¹\0▶\\¹Y¹\0²X¹く¹\0」ヨ¹Q²ラ¹\0す", -- driftmaniaLevelExp1.tmx props
}
local map_bounds_data = {
  "\0웃¹⁷\0▶¹⁷\0▶¹⁷\0▶¹⁷\0▶¹⁷\0ᵇ¹⁙\0ᵇ¹⁙\0ᵇ¹⁙\0ᵇ¹⁙\0ᵇ¹⁙\0ᵇ¹⁙\0ᵇ¹⁙\0ᵇ¹\r\0■¹\r\0■¹\r\0■¹\r\0■¹⁴\0⁵¹⁴\0■¹\r\0■¹\r\0■¹\r\0■¹\r\0け", -- driftmaniaLevelA1.tmx bounds
  "\0░¹⁷\0◀¹\t\0⁘¹ᵇ\0□¹\r\0■¹⁵\0³¹⁵\0■¹⁴\0⁵¹⁴\0■¹⁴\0⁵¹⁴\0■¹⁵\0³¹⁵\0■¹⁶\0¹¹⁶\0□¹ᵇ\0⁘¹\t\0◀¹⁷\0▶¹⁷\0◀¹\t\0⁘¹ᵇ\0□¹⁶\0¹¹⁶\0■¹⁵\0³¹⁵\0■¹⁴\0⁵¹⁴\0■¹⁴\0⁵¹⁴\0■¹⁴\0⁵¹⁴\0■¹\r\0■¹\r\0■¹\r\0■¹\r\0D", -- driftmaniaLevelA2.tmx bounds
  "\0ソ¹⁷\0◀¹\t\0⁘¹ᵇ\0⁙¹ᵇ\0⁙¹□\0ᶜ¹□\0ᶜ¹□\0ᶜ¹□\0ᵉ¹▮\0ᵉ¹▮\0ᵉ¹▮\0ᵉ¹▮\0ᵉ¹⁴\0¹¹⁴\0‖¹\t\0‖¹\t\0‖¹\t\0‖¹\t\0り", -- driftmaniaLevel2.tmx bounds
  "\0!¹⁴\0」¹⁶\0「¹⁷\0▶¹⁸\0◀¹\t\0◀¹\t\0◀¹□\0\r¹■\0ᵉ¹▮\0ᶠ¹ᶠ\0▮¹⁴\0⁶¹⁴\0▮¹⁴\0⁶¹⁴\0▮¹⁴\0⁶¹⁴\0▮¹⁴\0⁶¹⁴\0▮¹⁴\0⁶¹⁴\0▮¹⁴\0⁶¹⁴\0▮¹⁴\0⁶¹⁴\0▮¹‖\0\t¹‖\0\t¹‖\0\t¹‖\0⁙¹⁴\0³¹⁴\0⁙¹⁴\0³¹⁴\0⁙¹⁴\0³¹⁴\0⁙¹ᵇ\0⁙¹ᵇ\0⁙¹ᵇ\0⁙¹ᵇ\0゜", -- driftmaniaLevel1.tmx bounds
  "\0り¹⁵\0「¹⁷\0▶¹⁸\0◀¹⁸\0■¹\r\0▮¹ᵉ\0▮¹ᵉ\0▮¹ᵉ\0▮¹□\0ᶜ¹□\0ᶜ¹□\0ᶜ¹\n\0¹¹⁷\0ᶜ¹□\0ᶜ¹ᶠ\0ᶠ¹ᵉ\0■¹ᶜ\0⁙¹\n\0‖¹⁸\0り", -- driftmaniaLevel3.tmx bounds
  "\0そ¹⁶\0▶¹⁸\0‖¹\n\0⁙¹ᵇ\0□¹ᶜ\0■¹\r\0▮¹ᵉ\0ᶠ¹ᶠ\0ᵉ¹ᶠ\0ᵉ¹ᶠ\0ᵉ¹ᶠ\0ᵉ¹ᶠ\0ᵉ¹ᶠ\0ᶠ¹ᵉ\0▮¹\r\0■¹ᶜ\0⁙¹\n\0‖¹⁸\0▶¹⁶\0」¹⁴\0す", -- driftmaniaLevelExp1.tmx bounds
}

local map_settings_data = parse_table_arr("name,req_medals,laps,size,spawn_x,spawn_y,spawn_dir,bronze,silver,gold,plat",
  "|a1,0,3,30,312,264,0.5,2880,2340,2100,1980" .. -- driftmaniaLevelA1.tmx settings
  "|a2,0,3,30,264,240,0.25,2500,2000,1740,1650" .. -- driftmaniaLevelA2.tmx settings
  "|b1,4,4,30,192,248,0.125,3100,2700,2375,2015" .. -- driftmaniaLevel2.tmx settings
  "|b2,4,3,30,192,136,0.375,4100,2600,2300,2220" .. -- driftmaniaLevel1.tmx settings
  "|c1,8,4,30,288,528,0.5,3170,2670,2370,2250" .. -- driftmaniaLevel3.tmx settings
  "|a2,0,3,30,400,344,0.125,2500,2000,1740,1650" .. -- driftmaniaLevelExp1.tmx settings
  ""
)
local map_checkpoints_data_header = "x,y,dx,dy,l"
local map_checkpoints_data = {
  parse_table_arr(map_checkpoints_data_header, '|300,229,0,1,71|486,294,1,1,72|342,510,1,1,72'), -- driftmaniaLevelA1.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|229,228,1,0,69|445,228,1,0,69|229,516,1,0,69'), -- driftmaniaLevelA2.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|178,210,1,1,56|557,283,-1,1,68|277,491,-1,1,68'), -- driftmaniaLevel2.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|213,99,-1,1,44|165,147,-1,1,44|606,606,1,1,72'), -- driftmaniaLevel1.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|276,493,0,1,71|317,324,1,0,53|397,324,1,0,69'), -- driftmaniaLevel3.tmx checkpoints
  parse_table_arr(map_checkpoints_data_header, '|390,310,1,1,52|334,262,1,1,52|438,366,1,1,52'), -- driftmaniaLevelExp1.tmx checkpoints
}
local map_jumps_data = {
  {}, -- driftmaniaLevelA1.tmx jumps
  parse_jumps_str("|16|14,1,15,1|17|15,1"), -- driftmaniaLevelA2.tmx jumps
  parse_jumps_str("|11|11,1|17|12,2,13,2|18|15,3|12|16,4,17,4"), -- driftmaniaLevel2.tmx jumps
  parse_jumps_str("|19|13,1,22,2|20|13,1,22,2"), -- driftmaniaLevel1.tmx jumps
  {}, -- driftmaniaLevel3.tmx jumps
  parse_jumps_str("|17|10,1,11,1,17,4|20|13,2,14,2|13|14,3,18,5|14|14,3|16|17,4|12|18,5"), -- driftmaniaLevelExp1.tmx jumps
}
local gradients =     split('0,1,1,2,1,13,6,2,4,9,3,1,5,13,14')
local gradients_rev = split('12,8,11,9,13,14,7,7,10,7,7,7,14,15,7')
local outline_cache = {}
local bbox_cache = {}
local wall_height = 3
local chunk_size = 3
local chunk_size_x8 = 24
local chunks_per_row = 42 -- flr(128/chunk_size)

--------------------
-- Built-in Methods
--------------------

function _init()
  printh('\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n')

  -- Reset high scores for debugging
  --for i = 11, 64 do
  --  dset(i, 0)
  --end

  -- Disable btnp repeat
  poke(0x5f5c, 255)

  init_outline_cache(outline_cache, 30.5)
  init_outline_cache(bbox_cache, 28.5)

  load_level(false)

  spawn_main_menu_manager()
  spawn_level_select_manager()
  spawn_customization_manager()
  particle_vol_m = spawn_particle_manager_vol()
  particle_water_m = spawn_particle_manager_water()

  set_menu_items()
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

  cls(3) -- Most grass is drawn as part of cls

  if game_state == 0 then
    -- 7% CPU
    draw_map(map_road_chunks, map_settings.size, 3, true, true, false)
    -- 3% CPU
    draw_map(map_decal_chunks, map_settings.size, 3, true, true, true)

    draw_cp_highlights(level_m)

    -- 2% CPU (idle)
    _particle_manager_water_draw(particle_water_m)

    -- 9% CPU
    _trail_manager_draw(trail_m)

    -- Tutorial. Only used once so special case here
    if level_index == 1 then
      rectfill_outlined(512, 216, 543, 240, 6, 1)
      print('drift!', 517, 220, 7)
      print('hold z!', 515, 232, 7)
    end

    if ghost ~= nil then
      draw_car_shadow(ghost)
    end
    draw_car_shadow(player)

    -- 0% CPU (idle)
    _particle_manager_vol_draw_bg(particle_vol_m)

    -- 11% CPU
    draw_map(map_prop_chunks, map_settings.size, 3, player.z > wall_height, true, false)

    --draw_map(map_bounds_chunks, map_settings.size, 3, true, true, true)

    if ghost ~= nil then
      _car_draw(ghost)
    end

    -- 7% CPU
    _car_draw(player)
  
    -- 12% CPU
    if player.z <= wall_height then
      draw_map(map_prop_chunks, map_settings.size, 3, true, false, false)
    end

    -- 1% CPU (idle)
    _particle_manager_vol_draw_fg(particle_vol_m)

    _level_manager_draw(level_m)
  end

  -- 0% CPU
  for obj in all(objects) do
    obj.draw(obj)
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
function decomp_str(s)
  local arr = {}

  for i = 1, #s, 2 do
    local index = ord(s, i)
    local cnt = ord(s, i + 1)
    for j = 1, cnt do
      add(arr, index)
    end
  end

  return arr
end

--------------------
-- Car class (player + ghost)
--------------------
function create_car(x, y, dir, is_ghost)
  -- Car creation is split into static and dynamic parts to save tokens
  local car = parse_table('z,x_remainder,y_remainder,z_remainder,v_x,v_y,v_z,turn_rate_fwd,turn_rate_vel,accel,brake,max_speed_fwd,max_speed_rev,f_friction,f_corrective,boost_frames,flash_frames,water_wheels,scale,respawn_frames,respawn_start_x,respawn_start_y,engine_pitch,ghost_frame,wall_penalty_frames,next_checkpoint',
    '0,0,0,0,0,0,0,0.0060,0.0050,0.075,0.05,2.2,0.5,0.02,0.1,0,0,0,1,0,0,0,0,1,0,2')

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
      if dynamic_camera_disabled then
        camera(self.x - 64, self.y - 64)
      else
        local fwd_x, fwd_y = angle_vector(self.angle_fwd, 1)
        local speed = dist(self.v_x, self.v_y)
        local lead = min(speed * 9.9, 30)
        local target_x = self.x - 64 + flr(fwd_x * lead)
        local target_y = self.y - 64 + flr(fwd_y * lead)
        self.camera_target_x += (target_x - self.camera_target_x) * 0.5
        self.camera_target_y += (target_y - self.camera_target_y) * 0.5
        camera(self.camera_target_x, self.camera_target_y)
      end
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
    sfx(8, 0, self.engine_pitch, 0)
  else
    sfx(8, -2) -- stop sfx
  end

  if d_brake then
    sfx(17, 1, 0, 0)
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
  if btns & 0x1 > 0 then move_side += 1 end
  if btns & 0x2 > 0 then move_side -= 1 end
  if btns & 0x4 > 0 then move_fwd  += 1 end
  if btns & 0x8 > 0 then move_fwd  -= 1 end
  local d_brake = btns & 0x10 > 0

  -- Misc data
  local fwd_x, fwd_y = angle_vector(self.angle_fwd, 1)
  local v_x_normalized, v_y_normalized = normalized(self.v_x, self.v_y)
  local vel_dot_fwd = dot(fwd_x, fwd_y, v_x_normalized, v_y_normalized)
  local speed = dist(self.v_x, self.v_y)

  -- Jump checked on move and at start of each frame in case we're stopped
  check_jump(self, self.x, self.y, self.z)

  -- Get the wheel modifiers (boost, road, grass, etc)
  local grass_wheels = 0
  local boost_wheels = 0
  local water_wheels = self.water_wheels
  local jump_wheels = 0
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
  local mod_max_vel = 1
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
  end
  if boost_wheels >= 1 then
    if self.boost_frames <= 87 and not self.is_ghost then
      self.flash_frames = 5
      pause_frames = -2
      sfx(13)
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
  end

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
    if self.boost_frames == 0 then
      mod_accel = 0.2
      mod_max_vel = 0.8
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
  local wheel_idx = 1
  for i = -1, 1, 2 do
    for j = -1, 1, 2 do
      local wheel_x = round(cos(self.angle_fwd + 0.1 * i) * 5 * j)
      local wheel_y = round(sin(self.angle_fwd + 0.1 * i) * 4 * j)
      self.wheel_offsets[wheel_idx] = {x=wheel_x, y=wheel_y}
      wheel_idx += 1
    end
  end

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
    self.v_x += fwd_x * self.accel * mod_accel
    self.v_y += fwd_y * self.accel * mod_accel
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
      sfx(9)
    end
  end

  -- Check bounds
  local chunk_x = flr(self.x / chunk_size_x8)
  local chunk_y = flr(self.y / chunk_size_x8)
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
  local cone_angle = 0.1
  local offset_x, y = angle_vector(self.angle_fwd+0.5 + rnd(cone_angle/2)-cone_angle/4, 6)
  add_particle_vol(particle_vol_m, self.x + offset_x, self.y + y, self.z + 2, rnd(1) < 0.5 and 10 or 9, offset_x, y, rnd(0.5)-0.25, 30, 4)
end

local ghost_palette = parse_hash_map('8,2,10,4,6,1,7,6,12,13,14,1,4,1,11,2')
function _car_draw(self)
  --self.angle_fwd = 8/32 -- 0,8,16,24 = correct, 1-7 = 0,1, 9-15 = 1,0, 17-23 = 0,-1, 25-31 = -1,0
  palt(0, false)
  palt(15, true)

  -- Water outline
  draw_water_outline(round_nth(self.angle_fwd))
  
  -- Palette customization / ghost
  if self.is_ghost then
    for c1, c2 in pairs(ghost_palette) do
      pal(c1, c2)
    end
  else
    for d in all(customization_m.data) do
      if d.text ~= 'tYPE' then
        local c = d.chosen
        pal(d.original, c)
        if d.text == 'bODY' then -- body - set gradient color
          local gradient_c = gradients[c]
          pal(2, gradient_c)
          pal(11, self.boost_frames > 10 and c or gradient_c)
        elseif d.text == 'wINDOWS' then -- windows - set highlight color
          pal(12, gradients_rev[c])
        end
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
    pd_rotate(self.x,self.y-self.z-i*self.scale+(self.water_wheels<2 and 0 or 1),round_nth(self.angle_fwd),127,30.5 - i*2,2,true,self.scale)
    --break
  end
  pal()
end

function draw_car_shadow(self)
  -- Shadow / Underglow
  palt(15, true)
  palt(0, false)
  pal(14, 1)
  pal(0, 1)
  local height = 0
  if collides_jump_at(self.x, self.y, 0) then
    height = flr(map_jump_frames[map_jumps[flr(self.x/chunk_size_x8)][flr(self.y/chunk_size_x8)]] / 8)
  end
  pd_rotate(self.x,self.y-height,round_nth(self.angle_fwd),127,30.5,2,true,self.scale)
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
        _on_player_moved(self, x, y, z, self.angle_fwd)
      end
    end
  end
  return x, y, z, remainder, false
end

-- Called whenever the player occupies a new position. Can be called multiple times per frame
function _on_player_moved(self, x, y, z, angle)
  self.water_wheels = 0
  for i, offset in pairs(self.wheel_offsets) do
    local check_x = flr(x) + offset.x
    local check_y = flr(y) + offset.y

    check_jump(self, check_x, check_y, z)
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
        if rnd(1) > 0.25 then
          add_particle_water(particle_water_m, check_x, check_y, 7, rnd2(self.v_y*0.05), rnd2(-self.v_x*0.05), rnd(20)+15, true)
        end
        add_particle_water(particle_water_m, check_x, check_y, 7, self.v_y*0.175*side, -self.v_x*0.175*side, rnd(20)+20)
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
end

function check_jump(self, x, y, z)
  if collides_jump_at(x, y, z) then
    map_jump_frames[map_jumps[flr(x/chunk_size_x8)][flr(y/chunk_size_x8)]] = 30
    self.v_z = 2
    self.z = 1
    if not self.is_ghost then
      pause_frames = -2
      sfx(11)
    end
  end
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
      if penalize and z < wall_height then
        self.wall_penalty_frames = 20
        -- Really annoying to have the car crash effects on level end when it goes off screen
        if level_m.state ~= 3 and not self.is_ghost then
          sfx(10)
        end
      end
      return true, check_x, check_y
    end
  end
  return false
end

-- Checks if the given position on the map overlaps a wall
local wall_collision_sprites = parse_hash_set('29,31,42,43,44,45,46,47,58,59,60,61,62')
function collides_wall_at(x, y, z)
  return collides_part_at(x, y, z, wall_height, map_prop_tiles, {}, wall_collision_sprites, 6)
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
  local sprite_index = tile_map[flr(x/8)][flr(y/8)]
  if sprite_index == nil then
    return false
  end
  if full_col_sprites[sprite_index] then
    return true
  elseif part_col_sprites[sprite_index] then
    local sx = (sprite_index % 16) * 8 + x % 8
    local sy = flr(sprite_index / 16) * 8 + y % 8
    local col = sget(sx, sy)
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

  map_road_chunks, map_road_tiles = load_map(map_road_data[level_index], map_settings.size)
  map_decal_chunks, map_decal_tiles = load_map(map_decals_data[level_index], map_settings.size)
  map_prop_chunks, map_prop_tiles = load_map(map_props_data[level_index], map_settings.size)
  map_bounds_chunks = load_map(map_bounds_data[level_index], map_settings.size)

  spawn_level_manager()
  player = create_car(map_settings.spawn_x, map_settings.spawn_y, map_settings.spawn_dir, false)
  ghost = nil -- If someone switched ghost enabled -> disabled make sure we clear out the existing one
  if start and ghost_playback[1] ~= -1 and ghost_enabled then
    ghost = create_car(map_settings.spawn_x, map_settings.spawn_y, map_settings.spawn_dir, false)
    ghost.buffer = ghost_playback
  end
  spawn_trail_manager()

  if start then
    game_state = 0
  end
end

function spawn_level_manager()
  level_m = {
    lap = 1,
    frame = 1,
    anim_frame = 0,
    cp_cache = {}, -- table[x][y] -> cp index
    cp_sprites = {}, -- table[cp_index] -> list of x, y, sprite to draw after crossing checkpoint
    state = 1, -- 1=intro, 2=playing, 3=ending
    last_best = 0, -- Previous best time for the track that just finished
    lap_frames = {}, -- list of frames for this attempt of the track
  }
  cache_checkpoints(level_m, map_checkpoints)

  local buttons = {
    new_button(0, 0, 'rETRY', function() load_level(true) end),
    new_button(0, 10, 'qUIT', quit_level),
  }
  level_m.menu = new_menu(50, -10, buttons, 'vert', 120)
end

function quit_level()
  load_level(false) 
  sfx(8, -2) 
  game_state = 2
end

function _level_manager_update(self)
  if (self.frame < 0x7fff) and self.state == 2 then
    self.frame += 1
  end

  -- Restart level
  if btnp(5) then
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
      sfx(16)
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
    local y = camera_y + 19 - max(0, (75 - self.anim_frame)*4)

    rectfill_outlined(camera_x, y, camera_x + 128, y + 89, 12, 1)

    local data_index = get_lap_time_index(level_index, self.lap)
    print_shadowed('rACE\ncOMPLETE', x, y+4, 7)
    print_shadowed('tIME\n' .. frame_to_time_str(self.frame), x, y+20, 7)
    if self.last_best_time ~= 0 then 
      print_shadowed((self.last_best_time >= self.frame and '-' or '+') 
        .. frame_to_time_str(abs(self.last_best_time - self.frame)), x-4, y+32,
        self.last_best_time >= self.frame and 11 or 8)
    end

    draw_medals(x + 7, y + 45, get_num_medals(self.frame, map_settings))
    draw_minimap(x + 33, y)

    self.menu.x = x + 8
    self.menu.y = y + 70
    self.menu.draw()
  end

  -- Level UI
  local kph = tostr(flr(dist(player.v_x, player.v_y) * 71.01))
  print_shadowed('\*' .. (3 - #kph) .. ' ' .. kph .. ' kph', camera_x + 98, camera_y + 114, 7)
  print_shadowed('lAP ' .. self.lap .. '/' .. map_settings.laps, camera_x + 98, camera_y + 121, 7)

end

function frame_to_time_str(frames)
  -- mm:ss.mm. Max time 546.13 sec
  local min = '0' .. tostr(flr(frames/3600))
  local sec = tostr(flr(frames/60%60))
  local sub_sec = tostr(flr(frames%60/60*100))
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
    for i = 1, count(map_checkpoints) do
      car.cp_crossed[i] = false
    end

    if not car.is_ghost then
      -- Save/Load best time for this lap
      local data_index = get_lap_time_index(level_index, self.lap)
      self.last_best_time = dget(data_index)
      add(self.lap_frames, self.frame)

      self.anim_frame = 1

      -- Completed the track
      if self.lap == map_settings.laps then
        self.state = 3

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
      sfx(15, -1, 0, 10)
    end
  elseif not car.is_ghost then
    sfx(14, -1, 0, 3)
  end

  -- Advance checkpoint marker
  car.next_checkpoint = (car.next_checkpoint % count(map_checkpoints)) + 1
  return true
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

  for i = 1, count(checkpoints) do
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

function load_map(data, map_size)
  -- Initialize tables
  local map_tiles = {}
  local map_chunks = {}

  -- Parse data
  local data_decomp = decomp_str(data)
  local num_chunks = count(data_decomp)
  for i = 0, num_chunks - 1 do
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

local sprite_sorts_raw = parse_table_arr('y_intercept,slope',[[
|4,1
|-99,0
|11,-1
|3,0
|3,0
|-4,1
|3,0
|3,-1,
|0,1]])
-- Table of [sprite_index] = {y_intercept=y_int, slope=s}
local sprite_sorts = {}
for __i, __spr_index in pairs(split('43,44,45,46,47,59,60,61,62')) do
  sprite_sorts[__spr_index] = sprite_sorts_raw[__i]
end
local solid_chunks = split('5,10,3,12')
-- Sorting takes 24% CPU
function draw_map(map_chunks, map_size, chunk_size, draw_below_player, draw_above_player, has_jumps)
  -- Find the map index of the top-left map segment
  --local draw_distance = 6 -- ceil(16/chunk_size)

  for i = 0, 6 do
    for j = 0, 6 do
      local chunk_x = mid(flr(camera_x / chunk_size_x8) + i, 0, map_size - 1)
      local chunk_y = mid(flr(camera_y / chunk_size_x8) + j, 0, map_size - 1)

      local jump_frames = 0
      if has_jumps and map_jumps[chunk_x] ~= nil and map_jumps[chunk_x][chunk_y] ~= nil then
        jump_frames = map_jump_frames[map_jumps[chunk_x][chunk_y]]
      end

      local chunk_index = map_chunks[chunk_x][chunk_y]
      if chunk_index ~= 0 then
        -- top left corner of chunk in pico8 tile map
        local tile_x = (chunk_index % chunks_per_row) * chunk_size
        local tile_y = flr(chunk_index / chunks_per_row) * chunk_size

        -- top left corner of chunk in world
        local world_x = chunk_x * chunk_size_x8
        local world_y = chunk_y * chunk_size_x8

        if draw_above_player and draw_below_player then
          -- draw whole chunk
          if chunk_index == 0 then
            -- pass
          elseif chunk_index <= 4 then
            rectfill(world_x, world_y, world_x + chunk_size_x8-1, world_y + chunk_size_x8-1, solid_chunks[chunk_index])
          elseif jump_frames > 0 then
            local height = flr(jump_frames/8)
            pal(15, 2)
            map(tile_x, tile_y, world_x, world_y, chunk_size, chunk_size)
            palt(7, true)
            palt(8, true)
            palt(12, true)
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
            local contains_player = player.y - 9 < strip_world_y + 9 and player.y + 7 > strip_world_y and player.x - 6 < world_x + chunk_size_x8 and player.x + 5 > world_x - 2
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
    draw = _trail_manager_draw,
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
    add(particle_m.points, {x=0, y=0, z=0, c=0, v_x=0, v_y=0, v_z=0, t=0, t_start=0, r=0, d=1})
  end

  return particle_m
end

function add_particle_vol(self, x, y, z, c, v_x, v_y, v_z, t, r)
  --self.points[self.points_i] = {x=x, y=y, z=z, c=c, v_x=v_x, v_y=v_y, v_z=v_z, t=t, t_start=t, r=r, d=rnd(0.05)+0.85}
  self.points[self.points_i] = {x=x-player.x, y=y-player.y, z=z, c=c, v_x=v_x, v_y=v_y, v_z=v_z, t=t, t_start=t, r=r, d=rnd(0.05)+0.85}
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
      circfill(p.x+player.x, p.y+player.y, p.r + 1, 1)
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
      circfill(p.x+player.x, p.y-p.z+player.y, p.r + 1, gradients[gradients[p.c]])
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
      circfill(p.x+player.x, p.y-p.z+player.y, p.r, c)
      --clip(0, p.y - camera_y, 128, 128) -- clip top
      --if p.z <= p.r then
      --  ovalfill(p.x - p.r + u, p.y - p.r/2, p.x + p.r - u, p.y + p.r/2 - u, c)
      --end
    end
  end
  clip()
end


-- Water trail/wake
function spawn_particle_manager_water()
  local particle_m = {
    draw = _particle_manager_water_draw, -- updates handled in draw so we can pget for performance
    points = {},
    points_i = 1,
    max_points = 500,
  }

  for i = 1, particle_m.max_points do
    add(particle_m.points, {x=0, y=0, c=0, v_x=0, v_y=0, t=0})
  end

  return particle_m
end

function add_particle_water(self, x, y, c, v_x, v_y, t, double)
  --if rnd(1) > 0.5 then return end
  self.points[self.points_i] = {x=x, y=y, c=c, v_x=v_x, v_y=v_y, t=round(t),}
  self.points_i = (self.points_i % self.max_points) + 1
  if double then
    local v_x_greater = abs(v_x) > abs(v_y)
    self.points[self.points_i] = {x=x+(v_x_greater and 1 or 0), y=y+(v_x_greater and 0 or 1), c=c, v_x=v_x, v_y=v_y, t=round(t+rnd2(t*.2)),}
    self.points_i = (self.points_i % self.max_points) + 1
  end
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
        p.x += p.v_x
        p.v_y *= -1
        p.y += p.v_y
      end
      p.t -= 1

      if p.t == 8 then 
        p.c = 6
      end

      pset(p.x, p.y, p.c)
    end
  end
end


function init_outline_cache(t, y)
  camera(-64,-64)
  for i = 0, 32 do
    cls()
    local rot = i/32
    t[rot] = {}
    pd_rotate(0,0,i/32,123,y,2,true,1)
    for x = -15, 15 do
      for y = -15, 15 do
        local c = pget(x, y)
        if c == 7 then
          add(t[rot], {x=x, y=y})
        end
      end
    end
  end
end

function draw_water_outline(rot)
  for offset in all(outline_cache[rot]) do
    local x = player.x+offset.x
    local y = player.y+offset.y
    if collides_water_at(x, y, player.z) then
      pset(x, y, 7)
    end
  end
end

--------------------
-- UI
--------------------

-- Built-in PICO-8 menu
function set_menu_items()
  menuitem(1, 'quit level', quit_level)
  menuitem(2, 'camera: ' .. (dynamic_camera_disabled and 'static' or 'dynamic'), function()
    dynamic_camera_disabled = not dynamic_camera_disabled
    dset(9, dynamic_camera_disabled and 1 or 0)
    set_menu_items()
    return true
  end)
  menuitem(3, 'ghost: ' .. (ghost_enabled and 'on' or 'off'), function()
    ghost_enabled = not ghost_enabled
    dset(10, ghost_enabled and 1 or 0)
    set_menu_items()
    return true
  end)
end

function new_button(x, y, txt, update)
  local obj = {x=x, y=y, txt=txt}
  obj.update = function(index, input) update(obj, index, input) end
  return obj
end

-- A menu is just a list of buttons + navigation
-- type one of 'vert', 'hor'
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

  -- up/down & left/right
  if btnp(self.type == 'vert' and 3 or 1) then
    self.index = (self.index % count(self.buttons)) + 1
    sfx(14, -1, 8, 1)
  elseif btnp(self.type == 'vert' and 2 or 0) then
    self.index = self.index == 1 and count(self.buttons) or self.index - 1
    sfx(14, -1, 8, 1)
  end

  -- update active button
  local button = self.buttons[self.index]
  local input = (btnp(4) and 1 or 0) - (btnp(5) and 1 or 0)
  if input ~= 0 then
    sfx(14, -1, 16, 1)
    button.update(self.index, input)
    self.frames = 5
  end
end

function _menu_draw(self)
  for i = 1, count(self.buttons) do
    local b = self.buttons[i]
    print_shadowed(b.txt, self.x + b.x + (i == self.index and 1 or 0), self.y + b.y, i == self.index and self.idle_frames == 0 and 7 or 6)
  end
  spr(16, self.x + self.buttons[self.index].x - (self.frames == 0 and 8 or 7), self.y + self.buttons[self.index].y - 2)
end

function btn_customization(self, index, input)
  if input ~= 0 then
    local opt = customization_m.data[index]
    opt.chosen = (opt.chosen + input) % (opt.text == 'tYPE' and 4 or 16)
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
    data = parse_table_arr('text,original,chosen,target_angle',[[
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
  for i = 1, count(customization_m.data) do
    d = customization_m.data[i]
    if dget(0) ~= 0 then
      d.chosen = dget(i)
    end
    add(buttons, new_button(0, i * 10, d.text, btn_customization))
  end
  add(buttons, new_button(46, 92, 'bACK', function(self) self.menu.index = 1 game_state = 3 end))
  customization_m.menu = new_menu(15, 15, buttons, 'vert', 1)
  _customization_manager_save(customization_m)

  add(objects, customization_m)
end

function _customization_manager_draw(self)
  if game_state ~= 1 then
    return
  end

  cls(0)
  rectfill_outlined(0, 11, 128, 117, 12, 1)
  print_shadowed('gARAGE', 54, 18, 7)
  rectfill_outlined(61, 33, 121, 95, 12, 13)

  local c = self.data[2].chosen
  ovalfill(69, 50, 113, 86, 5)
  oval    (69, 50, 113, 86, 6)
  for i = -1, 1, 2 do
    clip(83 + sin(time() * 0.25) * 22 * i, 60 - cos(time() * 0.25) * 18 * i, 16, 16)
    oval(69, 50, 113, 86, c)
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
    mset(126, 30 - i * 2, 70 + i * 2 + 16 * type)
    mset(127, 30 - i * 2, 71 + i * 2 + 16 * type)
  end

  -- save settings
  dset(0, 1) -- marker that settings are no longer default
  for i = 1, count(customization_m.data) do
    dset(i, customization_m.data[i].chosen)
  end
end

function spawn_level_select_manager()
  local buttons = {
    new_button(0, 0, 'lEVEL ' .. map_settings.name, function(self, index, input)
      -- 1-index hell :(
      local max_level = 1
      local total_medals = get_total_num_medals()
      while map_settings_data[max_level].req_medals <= total_medals and max_level < count(map_settings_data) do
        max_level += 1
      end
      level_index = ((level_index - 1 + input) % max_level) + 1
      load_level(false)
      self.txt = 'lEVEL ' .. map_settings.name
    end),
    new_button(44, 0, 'sTART', function(self)
      if map_settings.req_medals <= get_total_num_medals() then
        self.menu.index = 1
        game_state = 0 
        ghost_best_time = 0x7fff
        ghost_playback = {}
        for i = 1, 0x7fff do
          add(ghost_playback, -1)
        end
      end
    end),
    new_button(80, 0, 'bACK', function(self) self.menu.index = 1 game_state = 3 end)
  }

  add(objects, {
    update = _level_select_manager_update,
    draw = _level_select_manager_draw,
    menu = new_menu(15, 23, buttons, 'hor', 1)
  })
end

function _level_select_manager_draw(self)
  if game_state ~= 2 then
    return
  end

  cls(0)
  rectfill_outlined(0, 5, 128, 122, 12, 1)
  print_shadowed('sELECT tRACK', 40, 11, 7)

  self.menu.draw()
  rectfill_outlined(0, 33, 128, 122, 12, 3)


  local medals_to_unlock = map_settings.req_medals - get_total_num_medals()
  local x = 3
  local y = 61

  if medals_to_unlock <= 0 then
    draw_minimap(83 - map_settings.size*chunk_size/2, 33)

    local data_index = get_lap_time_index(level_index, map_settings.laps)
    local best_time = dget(data_index)
    rectfill_outlined(0, y - 4, 36, y + 37, 12, 1)
    print_shadowed('bEST', x, y, 7)
    print_shadowed(frame_to_time_str(best_time), x, y+8, 7)

    if best_time > 0 then
      draw_medals(x + 7, y + 18, get_num_medals(best_time, map_settings))
    end
  else
    -- need 4 more medals
  --rectfill_outlined(0, 32, 128, 123, 12, 3)
    rectfill_outlined(0, 57, 128,  98, 12, 1)
    --spr(32, 39, y+5)
    --spr(32, 80, y+5)
    spr(32, 9, y+13)
    spr(32, 110, y+13)
    print_shadowed('lOCKED!', 50, y+8, 7)
    local medals_str = medals_to_unlock == 1 and ' MORE MEDAL' or ' MORE MEDALS'
    print_shadowed('nEED ' .. medals_to_unlock .. medals_str, 28, y+16, 7)
  end
end

-- From the original sprite: c1 = white, c2 = yellow, c3 = orange, c4 = brown, c5 = purple
local medal_pal = {
  split('7,9,10,9,9,4,4,2,2,2'), -- bronze
  split('7,6,10,6,9,5,4,13,2,13'), -- silver
  split('7,10,10,10,9,9,4,4,2,2'), -- gold
  split('7,7,10,12,9,13,4,2,2,1'), -- plat
}

function draw_medals(x, y, n)
  local dx = 4
  local dy = -1

  x -= dx * (n - 1) / 2
  y -= dy * (n - 1) / 2

  for i = 1, n do
    pal()
    local medal_p = medal_pal[i]
    for j = 1, count(medal_p), 2 do
      pal(medal_p[j], medal_p[j+1])
    end
    sspr(0, 48, 16, 16, x + dx*(i-1), y + dy*(i-1))
  end
  pal()
end

function get_num_medals(time, settings)
  local num_medals = 0
  if time <= settings.bronze then num_medals += 1 end
  if time <= settings.silver then num_medals += 1 end
  if time <= settings.gold then num_medals += 1 end
  if time <= settings.plat then num_medals += 1 end
  return num_medals
end

function get_total_num_medals()
  local num_medals = 0
  for i = 1, count(map_settings_data) do
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
    new_button(0, 0, 'rACE', function() game_state = 2 end),
    new_button(0, 10, 'gARAGE', function() game_state = 1 end)
  }

  add(objects, {
    update = _main_menu_manager_update,
    draw = _main_menu_manager_draw,
    menu = new_menu(55, 82, buttons, 'vert', 1),
    car = {
      x = 90,
      y = 60,
      z = 0,
      boost_frames = 0,
      flash_frames = 0,
      angle_fwd = 0,
      water_wheels = 0,
      scale = 2
    }
  })
end

function _main_menu_manager_draw(self)
  if game_state ~= 3 then
    return
  end

  local border = 5
  cls(0)
  rectfill_outlined(0, border, 128, 128 - border, 12, 1)
  rectfill_outlined(0, self.car.y - 22, 128, self.car.y + 13, 6, 5)
  rect(-1, self.car.y - 22, 128, self.car.y + 13, 6)


  _particle_manager_vol_draw_bg(particle_vol_m)
  _particle_manager_vol_draw_fg(particle_vol_m)

  _car_draw(self.car)

  print_shadowed('\^t\^wdriftmania', 25, 18, 7)
  --line(25, 30, 102, 30, 7)
  line(35, 32, 92, 32, 7)
  print_shadowed('cREATED bY', 3, 107, 6)
  print_shadowed('mAX bIZE', 7, 115, 6)
  print_shadowed('V 0.6.0', 98, 115, 6)

  self.menu.draw()
end

function _main_menu_manager_update(self)
  if game_state ~= 3 then
    return
  end
  camera()

  if rnd(1) < 0.5 then
    add_particle_vol(particle_vol_m, self.car.x - 15, self.car.y, 4, rnd(1) < 0.5 and 10 or 9, -5 + rnd2(-1, 1), rnd2(-1, 1), rnd(0.5)-0.25, 60, 6)
  end

  self.menu.update()
end

-- todo: minimap should be cached in sprite sheet
-- todo: find enough spare tokens to enable this?
--local decal_pset_map = {[10]=11,[11]=11,[27]=11,[28]=11,[12]=9,[13]=9,[14]=9,[15]=9,[21]=10,[22]=10,[23]=10,[24]=10,[25]=10,[64]=12,[67]=12,[68]=12,[83]=12,[84]=12}
--function draw_minimap2()
--  local offset = 0--128 - map_settings.size
--  --rect(player.x + offset, player.y + offset, player.x + 30 + offset - 1, player.y + 30 + offset - 1, 6)
--  for tile_x = 0, count(map_road_tiles) - 1 do
--    for tile_y = 0, count(map_road_tiles[0]) - 1 do
--      local road_tile = map_road_tiles[tile_x][tile_y]
--      if road_tile >= 1 and road_tile <= 5 then
--        pset(offset + camera_x + tile_x, offset + camera_y + tile_y, 5)
--      end
--      local decal_tile = map_decal_tiles[tile_x][tile_y]
--      if decal_pset_map[decal_tile] ~= nil then
--        pset(offset + camera_x + tile_x, offset + camera_y + tile_y, decal_pset_map[decal_tile])
--      end
--      local prop_tile = map_prop_tiles[tile_x][tile_y]
--      if prop_tile > 0 then
--        pset(offset + camera_x + tile_x, offset + camera_y + tile_y, 7)
--      end
--    end
--  end
--  pset(flr(offset + camera_x + player.x/8), flr(offset + camera_y + player.y/8), 7)
--end

-- todo: minimap should not be redrawn every frame. Where to store 90x90 sprite though... :(
local pset_map = parse_hash_map("1,5,2,5,3,5,4,5,5,5,10,11,11,11,27,11,28,11,12,9,13,9,14,9,15,9,21,10,22,10,23,10,24,10,25,10,37,15,38,15,39,15,40,15,41,15,43,7,44,7,45,7,46,7,47,7,59,7,60,7,61,7,62,7,64,12,67,12,68,12,83,12,84,12")
function draw_minimap(x, y)
  for chunk_x = 0, count(map_road_chunks) do
    for chunk_y = 0, count(map_road_chunks) do

      -- Duplicated logic is purposely inlined to reduce CPU cost while redrawing every frame
      if map_road_chunks[chunk_x][chunk_y] ~= 0 then
        draw_minimap_chunk(map_road_tiles, x, y, chunk_x * chunk_size, chunk_y * chunk_size)
      end
      if map_decal_chunks[chunk_x][chunk_y] ~= 0 then
        draw_minimap_chunk(map_decal_tiles, x, y, chunk_x * chunk_size, chunk_y * chunk_size)
      end
      if map_prop_chunks[chunk_x][chunk_y] ~= 0 then
        draw_minimap_chunk(map_prop_tiles, x, y, chunk_x * chunk_size, chunk_y * chunk_size)
      end

    end
  end
  pset(flr(x + map_settings.spawn_x/8), flr(y + map_settings.spawn_y/8), 8)
end

function draw_minimap_chunk(tile_map, x, y, chunk_x, chunk_y)
  for tile_x = chunk_x, chunk_x + chunk_size - 1 do
    for tile_y = chunk_y, chunk_y + chunk_size - 1 do
      local tile = tile_map[tile_x][tile_y]
      if pset_map[tile] ~= nil then
        pset(x + tile_x, y + tile_y, pset_map[tile])
      end
    end
  end
end

