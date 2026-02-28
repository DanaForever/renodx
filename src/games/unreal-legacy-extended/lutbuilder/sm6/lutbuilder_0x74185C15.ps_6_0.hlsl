#include "../lutbuilderoutput.hlsli"

// Found in Stellar Blade, Demo

cbuffer cb0 : register(b0) {
  float cb0_026x : packoffset(c026.x);
  float cb0_026y : packoffset(c026.y);
  float cb0_026z : packoffset(c026.z);
  float cb0_027y : packoffset(c027.y);
  float cb0_027z : packoffset(c027.z);
  float cb0_028x : packoffset(c028.x);
  float cb0_028y : packoffset(c028.y);
  float cb0_028z : packoffset(c028.z);
  float cb0_028w : packoffset(c028.w);
  float cb0_029x : packoffset(c029.x);
  float cb0_029y : packoffset(c029.y);
  float cb0_029z : packoffset(c029.z);
  float cb0_029w : packoffset(c029.w);
  float cb0_030x : packoffset(c030.x);
  float cb0_030y : packoffset(c030.y);
  float cb0_030z : packoffset(c030.z);
  float cb0_030w : packoffset(c030.w);
  float cb0_031x : packoffset(c031.x);
  float cb0_031y : packoffset(c031.y);
  float cb0_031z : packoffset(c031.z);
  float cb0_031w : packoffset(c031.w);
  float cb0_032x : packoffset(c032.x);
  float cb0_032y : packoffset(c032.y);
  float cb0_033x : packoffset(c033.x);
  float cb0_033y : packoffset(c033.y);
  float cb0_033z : packoffset(c033.z);
  float cb0_034x : packoffset(c034.x);
  float cb0_034y : packoffset(c034.y);
  float cb0_034z : packoffset(c034.z);
  float cb0_035x : packoffset(c035.x);
  float cb0_035y : packoffset(c035.y);
  float cb0_035z : packoffset(c035.z);
  float cb0_036x : packoffset(c036.x);
  float cb0_036y : packoffset(c036.y);
  float cb0_036z : packoffset(c036.z);
  float cb0_036w : packoffset(c036.w);
  float cb0_037x : packoffset(c037.x);
  float cb0_042y : packoffset(c042.y);
  float cb0_042z : packoffset(c042.z);
  float cb0_042w : packoffset(c042.w);
  float cb0_043x : packoffset(c043.x);
  float cb0_043y : packoffset(c043.y);
  float cb0_043z : packoffset(c043.z);
  float cb0_043w : packoffset(c043.w);
  int cb0_044x : packoffset(c044.x);
  int cb0_044y : packoffset(c044.y);
  int cb0_044z : packoffset(c044.z);
  float cb0_044w : packoffset(c044.w);
  float cb0_045x : packoffset(c045.x);
  float cb0_046x : packoffset(c046.x);
  float cb0_046y : packoffset(c046.y);
  float cb0_046z : packoffset(c046.z);
  float cb0_046w : packoffset(c046.w);
  float cb0_047x : packoffset(c047.x);
  float cb0_047y : packoffset(c047.y);
  float cb0_047z : packoffset(c047.z);
  float cb0_047w : packoffset(c047.w);
  float cb0_048x : packoffset(c048.x);
  float cb0_048y : packoffset(c048.y);
  float cb0_048z : packoffset(c048.z);
  float cb0_048w : packoffset(c048.w);
  float cb0_049x : packoffset(c049.x);
  float cb0_049y : packoffset(c049.y);
  float cb0_049z : packoffset(c049.z);
  float cb0_049w : packoffset(c049.w);
  float cb0_050x : packoffset(c050.x);
  float cb0_050y : packoffset(c050.y);
  float cb0_050z : packoffset(c050.z);
  float cb0_050w : packoffset(c050.w);
  float cb0_051x : packoffset(c051.x);
  float cb0_051y : packoffset(c051.y);
  float cb0_051z : packoffset(c051.z);
  float cb0_051w : packoffset(c051.w);
  float cb0_052x : packoffset(c052.x);
  float cb0_052y : packoffset(c052.y);
  float cb0_052z : packoffset(c052.z);
  float cb0_052w : packoffset(c052.w);
  float cb0_053x : packoffset(c053.x);
  float cb0_053y : packoffset(c053.y);
  float cb0_053z : packoffset(c053.z);
  float cb0_053w : packoffset(c053.w);
  float cb0_054x : packoffset(c054.x);
  float cb0_054y : packoffset(c054.y);
  float cb0_054z : packoffset(c054.z);
  float cb0_054w : packoffset(c054.w);
  float cb0_055x : packoffset(c055.x);
  float cb0_055y : packoffset(c055.y);
  float cb0_055z : packoffset(c055.z);
  float cb0_055w : packoffset(c055.w);
  float cb0_056x : packoffset(c056.x);
  float cb0_056y : packoffset(c056.y);
  float cb0_056z : packoffset(c056.z);
  float cb0_056w : packoffset(c056.w);
  float cb0_057x : packoffset(c057.x);
  float cb0_057y : packoffset(c057.y);
  float cb0_057z : packoffset(c057.z);
  float cb0_057w : packoffset(c057.w);
  float cb0_058x : packoffset(c058.x);
  float cb0_058y : packoffset(c058.y);
  float cb0_058z : packoffset(c058.z);
  float cb0_058w : packoffset(c058.w);
  float cb0_059x : packoffset(c059.x);
  float cb0_059y : packoffset(c059.y);
  float cb0_059z : packoffset(c059.z);
  float cb0_059w : packoffset(c059.w);
  float cb0_060x : packoffset(c060.x);
  float cb0_060y : packoffset(c060.y);
  float cb0_060z : packoffset(c060.z);
  float cb0_060w : packoffset(c060.w);
  float cb0_061x : packoffset(c061.x);
  float cb0_061y : packoffset(c061.y);
  float cb0_061z : packoffset(c061.z);
  float cb0_061w : packoffset(c061.w);
  float cb0_062x : packoffset(c062.x);
  float cb0_062y : packoffset(c062.y);
  float cb0_062z : packoffset(c062.z);
  float cb0_062w : packoffset(c062.w);
  float cb0_063x : packoffset(c063.x);
  float cb0_063y : packoffset(c063.y);
  float cb0_063z : packoffset(c063.z);
  float cb0_063w : packoffset(c063.w);
  float cb0_064x : packoffset(c064.x);
  float cb0_064y : packoffset(c064.y);
  float cb0_064z : packoffset(c064.z);
  float cb0_064w : packoffset(c064.w);
  float cb0_065x : packoffset(c065.x);
  float cb0_065y : packoffset(c065.y);
  float cb0_065z : packoffset(c065.z);
  float cb0_065w : packoffset(c065.w);
  float cb0_066x : packoffset(c066.x);
  float cb0_066y : packoffset(c066.y);
  float cb0_066z : packoffset(c066.z);
  float cb0_066w : packoffset(c066.w);
  float cb0_067x : packoffset(c067.x);
};

static const float _global_0[6] = { -4.0f, -4.0f, -3.157376527786255f, -0.48524999618530273f, 1.847732424736023f, 1.847732424736023f };
static const float _global_1[6] = { -0.7185482382774353f, 2.0810306072235107f, 3.668124198913574f, 4.0f, 4.0f, 4.0f };
static const float _global_2[10] = { -4.9706220626831055f, -3.0293781757354736f, -2.126199960708618f, -1.5104999542236328f, -1.057800054550171f, -0.4668000042438507f, 0.11937999725341797f, 0.7088134288787842f, 1.2911865711212158f, 1.2911865711212158f };
static const float _global_3[10] = { 0.8089132308959961f, 1.191086769104004f, 1.5683000087738037f, 1.9483000040054321f, 2.308300018310547f, 2.638400077819824f, 2.859499931335449f, 2.9872608184814453f, 3.0127391815185547f, 3.0127391815185547f };
static const float _global_4[10] = { -2.301029920578003f, -2.301029920578003f, -1.9312000274658203f, -1.5204999446868896f, -1.057800054550171f, -0.4668000042438507f, 0.11937999725341797f, 0.7088134288787842f, 1.2911865711212158f, 1.2911865711212158f };
static const float _global_5[10] = { 0.8019952178001404f, 1.1980048418045044f, 1.5943000316619873f, 1.9973000288009644f, 2.3782999515533447f, 2.768399953842163f, 3.051500082015991f, 3.2746293544769287f, 3.3274307250976562f, 3.3274307250976562f };

float4 main(
    noperspective float2 TEXCOORD: TEXCOORD,
    noperspective float4 SV_Position: SV_Position,
    nointerpolation uint SV_RenderTargetArrayIndex: SV_RenderTargetArrayIndex) : SV_Target {
  float4 SV_Target;
  float _5 = TEXCOORD.x + -0.015625f;
  float _6 = TEXCOORD.y + -0.015625f;
  float _9 = float((uint)(int)(SV_RenderTargetArrayIndex));
  bool _13 = ((uint)cb0_044y > (uint)2);
  float _14 = select(_13, 0.9749136567115784f, 0.613191545009613f);
  float _15 = select(_13, 0.019597629085183144f, 0.3395121395587921f);
  float _16 = select(_13, 0.005503520369529724f, 0.04736635088920593f);
  float _17 = select(_13, 0.0021823181305080652f, 0.07020691782236099f);
  float _18 = select(_13, 0.9955400228500366f, 0.9163357615470886f);
  float _19 = select(_13, 0.002285400405526161f, 0.01345000695437193f);
  float _20 = select(_13, 0.004797322675585747f, 0.020618872717022896f);
  float _21 = select(_13, 0.024532120674848557f, 0.1095672994852066f);
  float _22 = select(_13, 0.9705423712730408f, 0.8696067929267883f);
  float _23 = select(_13, 1.02579927444458f, 1.7050515413284302f);
  float _24 = select(_13, -0.020052503794431686f, -0.6217905879020691f);
  float _25 = select(_13, -0.0057713985443115234f, -0.0832584798336029f);
  float _26 = select(_13, -0.0022350111976265907f, -0.13025718927383423f);
  float _27 = select(_13, 1.0045825242996216f, 1.1408027410507202f);
  float _28 = select(_13, -0.002352306619286537f, -0.010548528283834457f);
  float _29 = select(_13, -0.005014004185795784f, -0.024003278464078903f);
  float _30 = select(_13, -0.025293385609984398f, -0.1289687603712082f);
  float _31 = select(_13, 1.0304402112960815f, 1.152971863746643f);
  float _50;
  float _51;
  float _52;
  float _53;
  float _54;
  float _55;
  float _56;
  float _57;
  float _58;
  float _113;
  float _114;
  float _115;
  float _349;
  float _350;
  float _351;
  float _352;
  float _353;
  float _354;
  float _355;
  float _356;
  float _357;
  float _444;
  float _445;
  float _446;
  float _899;
  float _932;
  float _946;
  float _1010;
  float _1289;
  float _1290;
  float _1291;
  float _1367;
  float _1378;
  float _1500;
  float _1533;
  float _1547;
  float _1586;
  float _1679;
  float _1738;
  float _1797;
  float _1880;
  float _1945;
  float _2010;
  float _2127;
  float _2160;
  float _2174;
  float _2213;
  float _2306;
  float _2365;
  float _2424;
  float _2504;
  float _2566;
  float _2628;
  float _2792;
  float _2793;
  float _2794;
  if (!(cb0_044z == 1)) {
    if (!(cb0_044z == 2)) {
      if (!(cb0_044z == 3)) {
        bool _39 = (cb0_044z == 4);
        _50 = select(_39, 1.0f, 1.7050515413284302f);
        _51 = select(_39, 0.0f, -0.6217905879020691f);
        _52 = select(_39, 0.0f, -0.0832584798336029f);
        _53 = select(_39, 0.0f, -0.13025718927383423f);
        _54 = select(_39, 1.0f, 1.1408027410507202f);
        _55 = select(_39, 0.0f, -0.010548528283834457f);
        _56 = select(_39, 0.0f, -0.024003278464078903f);
        _57 = select(_39, 0.0f, -0.1289687603712082f);
        _58 = select(_39, 1.0f, 1.152971863746643f);
      } else {
        _50 = 0.6954522132873535f;
        _51 = 0.14067870378494263f;
        _52 = 0.16386906802654266f;
        _53 = 0.044794563204050064f;
        _54 = 0.8596711158752441f;
        _55 = 0.0955343171954155f;
        _56 = -0.005525882821530104f;
        _57 = 0.004025210160762072f;
        _58 = 1.0015007257461548f;
      }
    } else {
      _50 = 1.02579927444458f;
      _51 = -0.020052503794431686f;
      _52 = -0.0057713985443115234f;
      _53 = -0.0022350111976265907f;
      _54 = 1.0045825242996216f;
      _55 = -0.002352306619286537f;
      _56 = -0.005014004185795784f;
      _57 = -0.025293385609984398f;
      _58 = 1.0304402112960815f;
    }
  } else {
    _50 = 1.379158854484558f;
    _51 = -0.3088507056236267f;
    _52 = -0.07034677267074585f;
    _53 = -0.06933528929948807f;
    _54 = 1.0822921991348267f;
    _55 = -0.012962047010660172f;
    _56 = -0.002159259282052517f;
    _57 = -0.045465391129255295f;
    _58 = 1.0477596521377563f;
  }
  if (_13) {
    float _66 = exp2(log2(_5 * 1.0322580337524414f) * 0.012683313339948654f);
    float _67 = exp2(log2(_6 * 1.0322580337524414f) * 0.012683313339948654f);
    float _68 = exp2(log2(_9 * 0.032258063554763794f) * 0.012683313339948654f);
    _113 = (exp2(log2(max(0.0f, (_66 + -0.8359375f)) / (18.8515625f - (_66 * 18.6875f))) * 6.277394771575928f) * 100.0f);
    _114 = (exp2(log2(max(0.0f, (_67 + -0.8359375f)) / (18.8515625f - (_67 * 18.6875f))) * 6.277394771575928f) * 100.0f);
    _115 = (exp2(log2(max(0.0f, (_68 + -0.8359375f)) / (18.8515625f - (_68 * 18.6875f))) * 6.277394771575928f) * 100.0f);
  } else {
    _113 = ((exp2((_5 * 14.45161247253418f) + -6.07624626159668f) * 0.18000000715255737f) + -0.002667719265446067f);
    _114 = ((exp2((_6 * 14.45161247253418f) + -6.07624626159668f) * 0.18000000715255737f) + -0.002667719265446067f);
    _115 = ((exp2((_9 * 0.4516128897666931f) + -6.07624626159668f) * 0.18000000715255737f) + -0.002667719265446067f);
  }
  float _118 = cb0_044w * 1.0005563497543335f;
  float _132 = select((_118 <= 7000.0f), (((((2967800.0f - (4604438528.0f / cb0_044w)) / _118) + 99.11000061035156f) / _118) + 0.24406300485134125f), (((((1901800.0f - (2005284352.0f / cb0_044w)) / _118) + 247.47999572753906f) / _118) + 0.23703999817371368f));
  float _146 = ((((cb0_044w * 1.2864121856637212e-07f) + 0.00015411825734190643f) * cb0_044w) + 0.8601177334785461f) / ((((cb0_044w * 7.081451371959702e-07f) + 0.0008424202096648514f) * cb0_044w) + 1.0f);
  float _156 = ((((cb0_044w * 4.204816761443908e-08f) + 4.228062607580796e-05f) * cb0_044w) + 0.31739872694015503f) / ((1.0f - (cb0_044w * 2.8974181986995973e-05f)) + ((cb0_044w * cb0_044w) * 1.6145605741257896e-07f));
  float _161 = ((_146 * 2.0f) + 4.0f) - (_156 * 8.0f);
  float _162 = (_146 * 3.0f) / _161;
  float _164 = (_156 * 2.0f) / _161;
  bool _165 = (cb0_044w < 4000.0f);
  float _171 = rsqrt(dot(float2(_146, _156), float2(_146, _156)));
  float _172 = cb0_045x * 0.05000000074505806f;
  float _175 = _146 - ((_172 * _156) * _171);
  float _178 = ((_172 * _146) * _171) + _156;
  float _183 = (4.0f - (_178 * 8.0f)) + (_175 * 2.0f);
  float _189 = (((_175 * 3.0f) / _183) - _162) + select(_165, _162, _132);
  float _190 = (((_178 * 2.0f) / _183) - _164) + select(_165, _164, (((_132 * 2.869999885559082f) + -0.2750000059604645f) - ((_132 * _132) * 3.0f)));
  float _191 = max(_190, 1.000000013351432e-10f);
  float _192 = _189 / _191;
  float _195 = ((1.0f - _189) - _190) / _191;
  float _205 = 0.9413792490959167f / mad(-0.16140000522136688f, _195, ((_192 * 0.8950999975204468f) + 0.266400009393692f));
  float _206 = 1.0404363870620728f / mad(0.03669999912381172f, _195, (1.7135000228881836f - (_192 * 0.7501999735832214f)));
  float _207 = 1.089766502380371f / mad(1.0296000242233276f, _195, ((_192 * 0.03889999911189079f) + -0.06849999725818634f));
  float _208 = mad(_206, -0.7501999735832214f, 0.0f);
  float _209 = mad(_206, 1.7135000228881836f, 0.0f);
  float _210 = mad(_206, 0.03669999912381172f, -0.0f);
  float _211 = mad(_207, 0.03889999911189079f, 0.0f);
  float _212 = mad(_207, -0.06849999725818634f, 0.0f);
  float _213 = mad(_207, 1.0296000242233276f, 0.0f);
  float _216 = mad(0.1599626988172531f, _211, mad(-0.1470542997121811f, _208, (_205 * 0.883457362651825f)));
  float _219 = mad(0.1599626988172531f, _212, mad(-0.1470542997121811f, _209, (_205 * 0.26293492317199707f)));
  float _222 = mad(0.1599626988172531f, _213, mad(-0.1470542997121811f, _210, (_205 * -0.15930065512657166f)));
  float _225 = mad(0.04929120093584061f, _211, mad(0.5183603167533875f, _208, (_205 * 0.38695648312568665f)));
  float _228 = mad(0.04929120093584061f, _212, mad(0.5183603167533875f, _209, (_205 * 0.11516613513231277f)));
  float _231 = mad(0.04929120093584061f, _213, mad(0.5183603167533875f, _210, (_205 * -0.0697740763425827f)));
  float _234 = mad(0.9684867262840271f, _211, mad(0.04004279896616936f, _208, (_205 * -0.007634039502590895f)));
  float _237 = mad(0.9684867262840271f, _212, mad(0.04004279896616936f, _209, (_205 * -0.0022720457054674625f)));
  float _240 = mad(0.9684867262840271f, _213, mad(0.04004279896616936f, _210, (_205 * 0.0013765322510153055f)));
  if (_13) {
    float _243 = mad(_219, 0.26270660758018494f, (_216 * 0.6369736194610596f));
    float _246 = mad(_222, 0.028072800487279892f, mad(_219, 0.6779996156692505f, (_216 * 0.1446171998977661f)));
    float _249 = mad(_222, 1.0608437061309814f, mad(_219, 0.059293799102306366f, (_216 * 0.16885849833488464f)));
    float _251 = mad(_228, 0.26270660758018494f, (_225 * 0.6369736194610596f));
    float _254 = mad(_231, 0.028072800487279892f, mad(_228, 0.6779996156692505f, (_225 * 0.1446171998977661f)));
    float _257 = mad(_231, 1.0608437061309814f, mad(_228, 0.059293799102306366f, (_225 * 0.16885849833488464f)));
    float _259 = mad(_237, 0.26270660758018494f, (_234 * 0.6369736194610596f));
    float _262 = mad(_240, 0.028072800487279892f, mad(_237, 0.6779996156692505f, (_234 * 0.1446171998977661f)));
    float _265 = mad(_240, 1.0608437061309814f, mad(_237, 0.059293799102306366f, (_234 * 0.16885849833488464f)));
    _349 = mad(-0.2533600926399231f, _259, mad(-0.35566210746765137f, _251, (_243 * 1.7166084051132202f)));
    _350 = mad(-0.2533600926399231f, _262, mad(-0.35566210746765137f, _254, (_246 * 1.7166084051132202f)));
    _351 = mad(-0.2533600926399231f, _265, mad(-0.35566210746765137f, _257, (_249 * 1.7166084051132202f)));
    _352 = mad(0.015768500044941902f, _259, mad(1.616477608680725f, _251, (_243 * -0.6666828989982605f)));
    _353 = mad(0.015768500044941902f, _262, mad(1.616477608680725f, _254, (_246 * -0.6666828989982605f)));
    _354 = mad(0.015768500044941902f, _265, mad(1.616477608680725f, _257, (_249 * -0.6666828989982605f)));
    _355 = mad(0.9422286748886108f, _259, mad(-0.04277630150318146f, _251, (_243 * 0.017642199993133545f)));
    _356 = mad(0.9422286748886108f, _262, mad(-0.04277630150318146f, _254, (_246 * 0.017642199993133545f)));
    _357 = mad(0.9422286748886108f, _265, mad(-0.04277630150318146f, _257, (_249 * 0.017642199993133545f)));
  } else {
    float _296 = mad(_222, 0.01933390088379383f, mad(_219, 0.2126729041337967f, (_216 * 0.4124563932418823f)));
    float _299 = mad(_222, 0.11919199675321579f, mad(_219, 0.7151522040367126f, (_216 * 0.3575761020183563f)));
    float _302 = mad(_222, 0.9503040909767151f, mad(_219, 0.07217500358819962f, (_216 * 0.18043750524520874f)));
    float _305 = mad(_231, 0.01933390088379383f, mad(_228, 0.2126729041337967f, (_225 * 0.4124563932418823f)));
    float _308 = mad(_231, 0.11919199675321579f, mad(_228, 0.7151522040367126f, (_225 * 0.3575761020183563f)));
    float _311 = mad(_231, 0.9503040909767151f, mad(_228, 0.07217500358819962f, (_225 * 0.18043750524520874f)));
    float _314 = mad(_240, 0.01933390088379383f, mad(_237, 0.2126729041337967f, (_234 * 0.4124563932418823f)));
    float _317 = mad(_240, 0.11919199675321579f, mad(_237, 0.7151522040367126f, (_234 * 0.3575761020183563f)));
    float _320 = mad(_240, 0.9503040909767151f, mad(_237, 0.07217500358819962f, (_234 * 0.18043750524520874f)));
    _349 = mad(-0.4986107647418976f, _314, mad(-1.5373831987380981f, _305, (_296 * 3.2409698963165283f)));
    _350 = mad(-0.4986107647418976f, _317, mad(-1.5373831987380981f, _308, (_299 * 3.2409698963165283f)));
    _351 = mad(-0.4986107647418976f, _320, mad(-1.5373831987380981f, _311, (_302 * 3.2409698963165283f)));
    _352 = mad(0.04155505821108818f, _314, mad(1.8759675025939941f, _305, (_296 * -0.9692436456680298f)));
    _353 = mad(0.04155505821108818f, _317, mad(1.8759675025939941f, _308, (_299 * -0.9692436456680298f)));
    _354 = mad(0.04155505821108818f, _320, mad(1.8759675025939941f, _311, (_302 * -0.9692436456680298f)));
    _355 = mad(1.056971549987793f, _314, mad(-0.20397695899009705f, _305, (_296 * 0.05563008040189743f)));
    _356 = mad(1.056971549987793f, _317, mad(-0.20397695899009705f, _308, (_299 * 0.05563008040189743f)));
    _357 = mad(1.056971549987793f, _320, mad(-0.20397695899009705f, _311, (_302 * 0.05563008040189743f)));
  }
  float _360 = mad(_351, _115, mad(_350, _114, (_349 * _113)));
  float _363 = mad(_354, _115, mad(_353, _114, (_352 * _113)));
  float _366 = mad(_357, _115, mad(_356, _114, (_355 * _113)));
  float _369 = mad(_16, _366, mad(_15, _363, (_360 * _14)));
  float _372 = mad(_19, _366, mad(_18, _363, (_360 * _17)));
  float _375 = mad(_22, _366, mad(_21, _363, (_360 * _20)));

  // SetUngradedAP1(float3(_369, _372, _375));

  float3 ungraded_ap1 = float3(_369, _372, _375);
  // ungraded_ap1 = expandGamut(ungraded_ap1, shader_injection.unreal_expand_gamut);
  float ap_l = renodx::color::y::from::AP1(ungraded_ap1);

  _369 = ungraded_ap1.x;
  _372 = ungraded_ap1.y;
  _375 = ungraded_ap1.z;

  bool _377 = (cb0_044x == 0);
  if (_377) {
    float _379 = dot(float3(_369, _372, _375), float3(0.2722287178039551f, 0.6740817427635193f, 0.053689517080783844f));

    float _383 = (_369 / _379) + -1.0f;
    float _384 = (_372 / _379) + -1.0f;
    float _385 = (_375 / _379) + -1.0f;
    float _397 = (1.0f - exp2(((_379 * _379) * -4.0f) * cb0_066w)) * (1.0f - exp2(dot(float3(_383, _384, _385), float3(_383, _384, _385)) * -4.0f));
    _444 = (((mad(mad(0.005107104778289795f, _31, mad(0.15656079351902008f, _28, (_25 * 0.8157691955566406f))), _375, mad(mad(0.005107104778289795f, _30, mad(0.15656079351902008f, _27, (_24 * 0.8157691955566406f))), _372, (mad(0.005107104778289795f, _29, mad(0.15656079351902008f, _26, (_23 * 0.8157691955566406f))) * _369))) - _369) * _397) + _369);
    _445 = (((mad(mad(0.0013581141829490662f, _31, mad(0.9758075475692749f, _28, (_25 * 0.025632236152887344f))), _375, mad(mad(0.0013581141829490662f, _30, mad(0.9758075475692749f, _27, (_24 * 0.025632236152887344f))), _372, (mad(0.0013581141829490662f, _29, mad(0.9758075475692749f, _26, (_23 * 0.025632236152887344f))) * _369))) - _372) * _397) + _372);
    _446 = (((mad(mad(1.0444426536560059f, _31, mad(0.03275501728057861f, _28, (_25 * 0.002078155754134059f))), _375, mad(mad(1.0444426536560059f, _30, mad(0.03275501728057861f, _27, (_24 * 0.002078155754134059f))), _372, (mad(1.0444426536560059f, _29, mad(0.03275501728057861f, _26, (_23 * 0.002078155754134059f))) * _369))) - _375) * _397) + _375);
  } else {
    _444 = _369;
    _445 = _372;
    _446 = _375;
  }
  float _447 = dot(float3(_444, _445, _446), float3(0.2722287178039551f, 0.6740817427635193f, 0.053689517080783844f));
  float _461 = cb0_050w + cb0_055w;
  float _475 = cb0_049w * cb0_054w;
  float _489 = cb0_048w * cb0_053w;
  float _503 = cb0_047w * cb0_052w;
  float _517 = cb0_046w * cb0_051w;
  float _521 = _444 - _447;
  float _522 = _445 - _447;
  float _523 = _446 - _447;
  float _581 = saturate(_447 / cb0_066x);
  float _585 = (_581 * _581) * (3.0f - (_581 * 2.0f));
  float _586 = 1.0f - _585;
  float _595 = cb0_050w + cb0_065w;
  float _604 = cb0_049w * cb0_064w;
  float _613 = cb0_048w * cb0_063w;
  float _622 = cb0_047w * cb0_062w;
  float _631 = cb0_046w * cb0_061w;
  float _693 = saturate((_447 - cb0_066y) / (1.0f - cb0_066y));
  float _697 = (_693 * _693) * (3.0f - (_693 * 2.0f));
  float _706 = cb0_050w + cb0_060w;
  float _715 = cb0_049w * cb0_059w;
  float _724 = cb0_048w * cb0_058w;
  float _733 = cb0_047w * cb0_057w;
  float _742 = cb0_046w * cb0_056w;
  float _800 = _585 - _697;
  float _811 = ((_697 * (((cb0_050x + cb0_065x) + _595) + (((cb0_049x * cb0_064x) * _604) * exp2(log2(exp2(((cb0_047x * cb0_062x) * _622) * log2(max(0.0f, ((((cb0_046x * cb0_061x) * _631) * _521) + _447)) * 5.55555534362793f)) * 0.18000000715255737f) * (1.0f / ((cb0_048x * cb0_063x) * _613)))))) + (_586 * (((cb0_050x + cb0_055x) + _461) + (((cb0_049x * cb0_054x) * _475) * exp2(log2(exp2(((cb0_047x * cb0_052x) * _503) * log2(max(0.0f, ((((cb0_046x * cb0_051x) * _517) * _521) + _447)) * 5.55555534362793f)) * 0.18000000715255737f) * (1.0f / ((cb0_048x * cb0_053x) * _489))))))) + ((((cb0_050x + cb0_060x) + _706) + (((cb0_049x * cb0_059x) * _715) * exp2(log2(exp2(((cb0_047x * cb0_057x) * _733) * log2(max(0.0f, ((((cb0_046x * cb0_056x) * _742) * _521) + _447)) * 5.55555534362793f)) * 0.18000000715255737f) * (1.0f / ((cb0_048x * cb0_058x) * _724))))) * _800);
  float _813 = ((_697 * (((cb0_050y + cb0_065y) + _595) + (((cb0_049y * cb0_064y) * _604) * exp2(log2(exp2(((cb0_047y * cb0_062y) * _622) * log2(max(0.0f, ((((cb0_046y * cb0_061y) * _631) * _522) + _447)) * 5.55555534362793f)) * 0.18000000715255737f) * (1.0f / ((cb0_048y * cb0_063y) * _613)))))) + (_586 * (((cb0_050y + cb0_055y) + _461) + (((cb0_049y * cb0_054y) * _475) * exp2(log2(exp2(((cb0_047y * cb0_052y) * _503) * log2(max(0.0f, ((((cb0_046y * cb0_051y) * _517) * _522) + _447)) * 5.55555534362793f)) * 0.18000000715255737f) * (1.0f / ((cb0_048y * cb0_053y) * _489))))))) + ((((cb0_050y + cb0_060y) + _706) + (((cb0_049y * cb0_059y) * _715) * exp2(log2(exp2(((cb0_047y * cb0_057y) * _733) * log2(max(0.0f, ((((cb0_046y * cb0_056y) * _742) * _522) + _447)) * 5.55555534362793f)) * 0.18000000715255737f) * (1.0f / ((cb0_048y * cb0_058y) * _724))))) * _800);
  float _815 = ((_697 * (((cb0_050z + cb0_065z) + _595) + (((cb0_049z * cb0_064z) * _604) * exp2(log2(exp2(((cb0_047z * cb0_062z) * _622) * log2(max(0.0f, ((((cb0_046z * cb0_061z) * _631) * _523) + _447)) * 5.55555534362793f)) * 0.18000000715255737f) * (1.0f / ((cb0_048z * cb0_063z) * _613)))))) + (_586 * (((cb0_050z + cb0_055z) + _461) + (((cb0_049z * cb0_054z) * _475) * exp2(log2(exp2(((cb0_047z * cb0_052z) * _503) * log2(max(0.0f, ((((cb0_046z * cb0_051z) * _517) * _523) + _447)) * 5.55555534362793f)) * 0.18000000715255737f) * (1.0f / ((cb0_048z * cb0_053z) * _489))))))) + ((((cb0_050z + cb0_060z) + _706) + (((cb0_049z * cb0_059z) * _715) * exp2(log2(exp2(((cb0_047z * cb0_057z) * _733) * log2(max(0.0f, ((((cb0_046z * cb0_056z) * _742) * _523) + _447)) * 5.55555534362793f)) * 0.18000000715255737f) * (1.0f / ((cb0_048z * cb0_058z) * _724))))) * _800);
  float _818 = mad(_25, _815, mad(_24, _813, (_811 * _23)));
  float _821 = mad(_28, _815, mad(_27, _813, (_811 * _26)));
  float _824 = mad(_31, _815, mad(_30, _813, (_811 * _29)));

  // SetUntonemappedAP1(float3(_811, _813, _815));

  UECbufferConfig cb_config = CreateCbufferConfig();

  // --------------------------------------------------
  // UE Filmic (confirmed in this shader)
  // --------------------------------------------------
  cb_config.ue_filmslope = asfloat(cb0_036x);
  cb_config.ue_filmtoe = asfloat(cb0_036y);
  cb_config.ue_filmshoulder = asfloat(cb0_036z);
  cb_config.ue_filmblackclip = asfloat(cb0_036w);
  cb_config.ue_filmwhiteclip = asfloat(cb0_037x);

  // --------------------------------------------------
  // Tone Curve Amount (filmic blend)
  // --------------------------------------------------
  cb_config.ue_tonecurveammount = asfloat(cb0_067x);

  // --------------------------------------------------
  // Blue Correction (used both pre & post tonemap)
  // --------------------------------------------------
  cb_config.ue_bluecorrection = asfloat(cb0_066z);

  // -------- Blue Correction --------
  cb_config.ue_bluecorrection = asfloat(cb0_066z);

  // -------- Polynomial Mapping --------
  cb_config.ue_mappingpolynomial.x = asfloat(cb0_026x);
  cb_config.ue_mappingpolynomial.y = asfloat(cb0_026y);
  cb_config.ue_mappingpolynomial.z = asfloat(cb0_026z);

  // -------- Overlay / Scale --------
  cb_config.ue_colorscale.x = asfloat(cb0_042y);
  cb_config.ue_colorscale.y = asfloat(cb0_042z);
  cb_config.ue_colorscale.z = asfloat(cb0_042w);

  cb_config.ue_overlaycolor.x = asfloat(cb0_043x);
  cb_config.ue_overlaycolor.y = asfloat(cb0_043y);
  cb_config.ue_overlaycolor.z = asfloat(cb0_043z);
  cb_config.ue_overlaycolor.w = asfloat(cb0_043w);

  // -------- Tone Curve Amount --------
  cb_config.ue_tonecurveammount = 1.0f;

  // float4 lutweights[2] = { float4(asfloat(cb0_038x), asfloat(cb0_039x), 0.f, 0.f), float4(0.f, 0.f, 0.f, 0.f) };
  // cb_config.ue_lutweights = lutweights;  // Only Lutweights[0].xy is used

  cb_config.ue_gamma = asfloat(cb0_027y);
  cb_config.ue_inv_gamma = asfloat(cb0_027z);

  // -------- Legacy Color Curve --------
  cb_config.ColorCurve_Cm0Cd0_Cd2_Ch0Cm1_Ch3.x = asfloat(cb0_031x);
  cb_config.ColorCurve_Cm0Cd0_Cd2_Ch0Cm1_Ch3.y = asfloat(cb0_031y);
  cb_config.ColorCurve_Cm0Cd0_Cd2_Ch0Cm1_Ch3.z = asfloat(cb0_031z);
  cb_config.ColorCurve_Cm0Cd0_Cd2_Ch0Cm1_Ch3.w = asfloat(cb0_031w);

  cb_config.ColorCurve_Ch1_Ch2.x = asfloat(cb0_032x);
  cb_config.ColorCurve_Ch1_Ch2.y = asfloat(cb0_032y);
  // cb_config.ColorCurve_Ch1_Ch2.z = asfloat(cb0_032z);
  // cb_config.ColorCurve_Ch1_Ch2.w = asfloat(cb0_032w);

  cb_config.ColorMatrixR_ColorCurveCd1.x = asfloat(cb0_028x);
  cb_config.ColorMatrixR_ColorCurveCd1.y = asfloat(cb0_028y);
  cb_config.ColorMatrixR_ColorCurveCd1.z = asfloat(cb0_028z);
  cb_config.ColorMatrixR_ColorCurveCd1.w = asfloat(cb0_028w);

  cb_config.ColorMatrixG_ColorCurveCd3Cm3.x = asfloat(cb0_029x);
  cb_config.ColorMatrixG_ColorCurveCd3Cm3.y = asfloat(cb0_029y);
  cb_config.ColorMatrixG_ColorCurveCd3Cm3.z = asfloat(cb0_029z);
  cb_config.ColorMatrixG_ColorCurveCd3Cm3.w = asfloat(cb0_029w);

  cb_config.ColorMatrixB_ColorCurveCm2.x = asfloat(cb0_030x);
  cb_config.ColorMatrixB_ColorCurveCm2.y = asfloat(cb0_030y);
  cb_config.ColorMatrixB_ColorCurveCm2.z = asfloat(cb0_030z);
  cb_config.ColorMatrixB_ColorCurveCm2.w = asfloat(cb0_030w);

  cb_config.ColorShadow_Luma.x = asfloat(cb0_033x);
  cb_config.ColorShadow_Luma.y = asfloat(cb0_033y);
  cb_config.ColorShadow_Luma.z = asfloat(cb0_033z);

  cb_config.ColorShadow_Tint1.x = asfloat(cb0_034x);
  cb_config.ColorShadow_Tint1.y = asfloat(cb0_034y);
  cb_config.ColorShadow_Tint1.z = asfloat(cb0_034z);

  cb_config.ColorShadow_Tint2.x = asfloat(cb0_035x);
  cb_config.ColorShadow_Tint2.y = asfloat(cb0_035y);
  cb_config.ColorShadow_Tint2.z = asfloat(cb0_035z);

  uint device = asuint(cb0_044y);

  float3 untonemapped_ap1 = float3(_818, _821, _824);
  float3 untonemapped_bt709 = renodx::color::bt709::from::AP1(untonemapped_ap1);
  float4 output = CreateUnrealLUT(untonemapped_ap1, untonemapped_bt709, cb_config, device);

  SV_Target.x = (output.x);
  SV_Target.y = (output.y);
  SV_Target.z = (output.z);

  SV_Target.w = 0.0f;

  return SV_Target;

  
}
