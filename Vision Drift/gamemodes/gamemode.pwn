/*
Credits:
 Gamemode based on Vision Drift created by Tazmaniax
 Edited by Dawidoskyy#0329
 Added:
 -Anty Weapon Hack
 -Onede Arena
 -Minigun Arena
 -New Textdraws
 -Drift Count
 -Ban/Kick in Textdraws
 -/Hay minigame
 -New objects
*/
// ================================ INCLUDE ====================================
#pragma tabsize 0

#include 					<a_samp>
#include 					<zcmd>
#include 					<sscanf2>
#include 					<streamer>
#include 					<mSelection>
#include 					<foreach>
#include 					<fixes>
#include 					<TimestampToDate>
#include 					<GetVehicleColor>
#include 					"../include/gl_common.inc"
#include 					<YSI\y_ini>
// =============================================================================
native WP_Hash(buffer[],len,const str[]); // Whirlpool native, add it at the top of your script under includes
// ================================ Defines ====================================
#define RANGEOFSTARTER 		20
#define TELE_DIALOG 		3300
#define carmenu 4450
#define ORANGE2     0xFF990080
#define COLOR_AC     0xFF990080
#define WHITE      0xFFFEFF80
#define ORANGE     0xFF990080
#define dregister 2011
#define dlogin 2012
// PATH
#define UserPath "Users/%s.ini"
#define BANPATH "/Bans/%s.ini"
#define IPPATH "/IP/%s.ini"
// ===
#define GMT_H 0  // Enter the value of the gmt hour u want otherwise keep it zero
#define GMT_M 0  // Enter the value of the gmt mintues u want otherwise keep it zero
#define COLOR_Label 		0xFFFFFFFF
#define Grey 0xC0C0C0FF // Defining the color 'Grey'
#define ConvertTime(%0,%1,%2,%3,%4) \
	new \
	    Float: %0 = floatdiv(%1, 60000) \
	;\
	%2 = floatround(%0, floatround_tozero); \
	%3 = floatround(floatmul(%0 - %2, 60), floatround_tozero); \
	%4 = floatround(floatmul(floatmul(%0 - %2, 60) - %3, 1000), floatround_tozero)
#define HAY_X            4
#define HAY_Y 	        4
#define HAY_Z           30
#define HAY_B          146
#define HAY_R            4
#define SPEED_FACTOR     3000.0
#define ID_HAY_OBJECT    3374
#define COLOR_LabelOut 		0x00000040
#define COLOR_ValueOut 		0xFFFFFF40
#define COLOR_Value 		0x000000FF
#define COLOR_GREY 			0xAFAFAFAA
#define COLOR_GREEN 		0x33AA33AA
#define COLOR_RED 			0xFF444499
#define COLOR_YELLOW 		0xFFFF00AA
#define COLOR_WHITE 		0xFFFFFFAA
#define COLOR_BLUE 			0x0000FFAA
#define COLOR_BROWN 		0x993300AA
#define COLOR_ORANGE 		0xFF9933AA
#define COLOR_CYAN 			0x99FFFFAA
#define COLOR_PINK 			0xFF66FFAA
#define COLOR_BLACK 		0x2C2727AA
#define COLOR_LIGHTCYAN 	0xAAFFCC33
#define COLOR_LEMON 		0xDDDD2357
#define COLOR_AQUA 			0x7CFC00AA
#define COLOR_WHITEYELLOW 	0xFFE87DFF
#define COLOR_BLUEAQUA 		0x7E60FFFF
#define COLOR_DARKBLUE 		0x15005EFF
#define COLOR_ALIEN 		0x90FF87FF
#define COLOR_GOLD 			0xB8860BAA
#define KICK_COLOR 			0xFF0000FF
#define COLOR_GANGGREEN 	0x00FF0096
#define COLOR_BLACK 		0x2C2727AA
#define COLOR_SBLUE 		0x00BFFFAA
#define COLOR_LBLUE 		0x15D4EDAA
#define CYAN 				0x15D4EDAA
#define CANT    			"[INFO]: {FFFFFF}You are not authorized to use this commands"

#define C_WHITE		"{FFFFFF}"
// ============================== New ==========================================
new bool:Karau;
new Text:Kary, NapisTimer;
new String[512];

enum weapons
{
    Melee,
    Thrown,
    Pistols,
    Shotguns,
    SubMachine,
    Assault,
    Rifles,
    Heavy,
    Handheld,

}
new Weapons[MAX_PLAYERS][weapons];

new gangzone0, gangzone1, gangzone2;
new strg[256];
new count;
new total_vehicles_from_files=0;
new afk[MAX_PLAYERS];
new Text:vd, Text:vd1,Text:vd2,Text:Textdraw0,Text:Textdraw2,Text:carname,Text:Login0,Text:Login1,Text:Login2,Text:Login3,Text:Login4,Text:Login5;
new Float:svx[MAX_PLAYERS];
new Float:svy[MAX_PLAYERS];
new Float:svz[MAX_PLAYERS];
new Float:s1[MAX_PLAYERS];
new s2[MAX_PLAYERS]; 
new s3[MAX_PLAYERS][256]; 
new Text:speedo[MAX_PLAYERS];
new stimer[MAX_PLAYERS];
new Text:box[MAX_PLAYERS];
new AdminRank[71];
new Text3D:serverowner[MAX_PLAYERS];
new Text:textstring;
new Float:X, Float:Y, Float:Z, Float:Angle;
new CurrentSpawnedVehicle[MAX_PLAYERS];
new bikeslist = mS_INVALID_LISTID;
new car1 = mS_INVALID_LISTID;
new car2 = mS_INVALID_LISTID;
new car3 = mS_INVALID_LISTID;
new car4 = mS_INVALID_LISTID;
new helicopter = mS_INVALID_LISTID;
new planes = mS_INVALID_LISTID;
new boat = mS_INVALID_LISTID;
new trains = mS_INVALID_LISTID;
new trailers = mS_INVALID_LISTID;
new rcveh = mS_INVALID_LISTID;
new god[MAX_PLAYERS];
new minigun[MAX_PLAYERS];
new onede[MAX_PLAYERS];
new Text:Time, Text:Date;
new pcarmenu[3];
new teleportmenu[3];
new superman[MAX_PLAYERS];
new ln[MAX_PLAYERS]=0,revseen[][MAX_PLAYERS];
new cameradone[MAX_PLAYERS];
new Text:godbox, Text:god1;

new Float:SpecX[MAX_PLAYERS], Float:SpecY[MAX_PLAYERS], Float:SpecZ[MAX_PLAYERS], vWorld[MAX_PLAYERS], Inter[MAX_PLAYERS];
new IsSpecing[MAX_PLAYERS], Name[MAX_PLAYER_NAME], IsBeingSpeced[MAX_PLAYERS],spectatorid[MAX_PLAYERS];

new Text:ServerTextDrawOne;
new Text:ServerTextDrawTwo;
new Text:ServerTextDrawThree[MAX_PLAYERS];
new Text:ServerTextDrawFour[MAX_PLAYERS];
new Text:ServerTextDrawFive[MAX_PLAYERS];
new ServerTimerOne;
new ServerTimerTwo;
new PlayerUseDriftCounter[MAX_PLAYERS];
new PlayerMoney[MAX_PLAYERS];
new PlayerScore[MAX_PLAYERS];
new PlayerCombo[MAX_PLAYERS];
new Float:PlayerPositionX[MAX_PLAYERS];
new Float:PlayerPositionY[MAX_PLAYERS];
new Float:PlayerPositionZ[MAX_PLAYERS];
new PlayerTimerOne[MAX_PLAYERS];

new JoinedHay[MAX_PLAYERS] = -1;
new WhatLevel[MAX_PLAYERS] = -1;
new TimeInHay[MAX_PLAYERS];
new Speed_xy;
new Speed_z;
new Center_x;
new Center_y;
new Matrix[HAY_X][HAY_Y][HAY_Z];
new Hays[HAY_B];
new Text:HAYTD[MAX_PLAYERS];

new Text:TeleportText;
new MessageStr[170]; //string line 3
new MessageStrl2[170]; //string line 2
new MessageStrl3[170]; //string line 1
new cForced[MAX_PLAYERS];
//==============================================================================
#if !defined Loop
#define Loop(%0,%1) \
        for(new %0 = 0; %0 != %1; %0++)
#endif

#if !defined function
#define function%0(%1) \
        forward%0(%1); public%0(%1)
#endif

#if !defined PURPLE
#define PURPLE \
    0xBF60FFFF
#endif

#if !defined GREEN
#define GREEN \
    0x94D317FF
#endif

#if !defined TIME
#define TIME \
    180000
#endif

new
        xCharacters[][] =
        {
            "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
            "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
                "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
            "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
        },
        xChars[16] = "",
        xReactionTimer,
        xCash,
        xScore,
        bool: xTestBusy
;
new AutoMessage[][] =
{
	"{FFFF00}:: {FFFFFF}vDR {FFFF00}:: {87CEFA}there are many teleport in server. you can use {FFFF00}/teles",
    "{FF9933}Juki: {FFFFFF}Every year over one million earthquakes shake the Earth.",
	"{FFFF00}:: {FFFFFF}vDR {FFFF00}:: {87CEFA}Be sure you follow the {FFFF00}/rules {87CEFA}yet.",
 	"{FF9933}Juki: {FFFFFF}Our oldest radio broadcasts of the 1930s have already traveled past 100,000 stars.",
    "{FFFF00}:: {FFFFFF}vDR {FFFF00}:: {87CEFA}You can spawn vehicle by using {FFFF00}/car or /v",
    "{FFFF00}:: {FFFFFF}vDR {FFFF00}:: {87CEFA}Want to take some shoot? type {FFFF00}/camera",
    "{FF9933}Juki: {FFFFFF}There are 60,000 miles of blood vessels in the human body.",
    "{FFFF00}:: {FFFFFF}vDR {FFFF00}:: {87CEFA}Change your own skin by using {FFFF00}/skin",
    "{FF9933}Juki: {FFFFFF}The largest desert in the world, the Sahara, is 3,500,000 square miles.",
    "{FFFF00}:: {FFFFFF}vDR {FFFF00}:: {87CEFA}see server commands type {FFFF00}/cmds",
    "{FF9933}Juki: {FFFFFF}Every hour the Universe expands by a billion miles in all directions.",
    "{FF9933}Juki: {FFFFFF} It takes 8 minutes 17 seconds for light to travel from the Sun’s surface to the Earth."
};

enum PlayerInfo
{
    Pass[129], //User's password
    Admin, //User's admin level
    VIPlevel, //User's vip level
    Money, //User's money
    Scores, //User's scores
    Kills, //User's kills
    Deaths,
    pColor,
    pSkin,
}
new pInfo[MAX_PLAYERS][PlayerInfo];

new Float:RandomSpawns[][] =
{
	{382.9828, -2079.0854, 7.8359, 0.1992}, // LS beach
	{1129.3685, -1457.6368, 15.7969, 359.2794}, // LS Mall
	{1240.7915,-2028.6777,59.9840,271.6392}, // LS Groove
	{1447.9894, -2287.4590, 13.5469, 91.0623} // Monas
};

new Float:MinigunSpawns[][] =
{
	{544.46,-3430.75,28.91,180.2427},
	{442.29,-3429.68,28.93,90.6284},
	{540.78,-3530.18,28.92,85.9284},
	{443.13,-3533.20,28.93,1.0142},
	{527.50,-3433.47,12.90,1.0142},
	{542.19,-3458.03,17.14,267.0133},
	{471.52,-3526.91,12.95,268.6036}
};

new Float:OnedeSpawns[][] =
{
    {288.745971, 169.350997, 1007.171875},
	{273.3204, 188.1061, 1007.1719},
	{263.6746, 170.5629, 1003.0234},
	{236.7647, 195.1310, 1008.1719},
	{257.2431, 185.3781, 1008.1719},
	{213.7057, 147.3681, 1003.0234},
	{212.9781, 166.3744, 1003.0234},
	{197.2282, 158.1888, 1003.0234},
	{210.9119, 184.9424, 1003.0313}
};

forward loadaccount_user(playerid, name[], value[]); //forwarding a new function to load user's data
forward Counting(playerid);
forward Counting2(playerid);
forward Counting1(playerid);
forward CountingGO(playerid);
forward speedometer(playerid);
forward RandomMessage();
forward kicktime();
forward settime(playerid);

forward TimerMove ();
forward TimerScore ();
forward FinishTimer (id, xq, yq, zq);
forward TDScore ();

forward PlayerUpdate();
forward PlayerDrift();
forward PlayerDriftEnd(Player);

new VehicleNames[212][] = {
{"Landstalker"},{"Bravura"},{"Buffalo"},{"Linerunner"},{"Perrenial"},{"Sentinel"},{"Dumper"},
{"Firetruck"},{"Trashmaster"},{"Stretch"},{"Manana"},{"Infernus"},{"Voodoo"},{"Pony"},{"Mule"},
{"Cheetah"},{"Ambulance"},{"Leviathan"},{"Moonbeam"},{"Esperanto"},{"Taxi"},{"Washington"},
{"Bobcat"},{"Mr Whoopee"},{"BF Injection"},{"Hunter"},{"Premier"},{"Enforcer"},{"Securicar"},
{"Banshee"},{"Predator"},{"Bus"},{"Rhino"},{"Barracks"},{"Hotknife"},{"Trailer 1"},{"Previon"},
{"Coach"},{"Cabbie"},{"Stallion"},{"Rumpo"},{"RC Bandit"},{"Romero"},{"Packer"},{"Monster"},
{"Admiral"},{"Squalo"},{"Seasparrow"},{"Pizzaboy"},{"Tram"},{"Trailer 2"},{"Turismo"},
{"Speeder"},{"Reefer"},{"Tropic"},{"Flatbed"},{"Yankee"},{"Caddy"},{"Solair"},{"Berkley's RC Van"},
{"Skimmer"},{"PCJ-600"},{"Faggio"},{"Freeway"},{"RC Baron"},{"RC Raider"},{"Glendale"},{"Oceanic"},
{"Sanchez"},{"Sparrow"},{"Patriot"},{"Quad"},{"Coastguard"},{"Dinghy"},{"Hermes"},{"Sabre"},
{"Rustler"},{"ZR-350"},{"Walton"},{"Regina"},{"Comet"},{"BMX"},{"Burrito"},{"Camper"},{"Marquis"},
{"Baggage"},{"Dozer"},{"Maverick"},{"News Chopper"},{"Rancher"},{"FBI Rancher"},{"Virgo"},{"Greenwood"},
{"Jetmax"},{"Hotring"},{"Sandking"},{"Blista Compact"},{"Police Maverick"},{"Boxville"},{"Benson"},
{"Mesa"},{"RC Goblin"},{"Hotring Racer A"},{"Hotring Racer B"},{"Bloodring Banger"},{"Rancher"},
{"Super GT"},{"Elegant"},{"Journey"},{"Bike"},{"Mountain Bike"},{"Beagle"},{"Cropdust"},{"Stunt"},
{"Tanker"}, {"Roadtrain"},{"Nebula"},{"Majestic"},{"Buccaneer"},{"Shamal"},{"Hydra"},{"FCR-900"},
{"NRG-500"},{"HPV1000"},{"Cement Truck"},{"Tow Truck"},{"Fortune"},{"Cadrona"},{"FBI Truck"},
{"Willard"},{"Forklift"},{"Tractor"},{"Combine"},{"Feltzer"},{"Remington"},{"Slamvan"},
{"Blade"},{"Freight"},{"Streak"},{"Vortex"},{"Vincent"},{"Bullet"},{"Clover"},{"Sadler"},
{"Firetruck LA"},{"Hustler"},{"Intruder"},{"Primo"},{"Cargobob"},{"Tampa"},{"Sunrise"},{"Merit"},
{"Utility"},{"Nevada"},{"Yosemite"},{"Windsor"},{"Monster A"},{"Monster B"},{"Uranus"},{"Jester"},
{"Sultan"},{"Stratum"},{"Elegy"},{"Raindance"},{"RC Tiger"},{"Flash"},{"Tahoma"},{"Savanna"},
{"Bandito"},{"Freight Flat"},{"Streak Carriage"},{"Kart"},{"Mower"},{"Duneride"},{"Sweeper"},
{"Broadway"},{"Tornado"},{"AT-400"},{"DFT-30"},{"Huntley"},{"Stafford"},{"BF-400"},{"Newsvan"},
{"Tug"},{"Trailer 3"},{"Emperor"},{"Wayfarer"},{"Euros"},{"Hotdog"},{"Club"},{"Freight Carriage"},
{"Trailer 3"},{"Andromada"},{"Dodo"},{"RC Cam"},{"Launch"},{"Police Car (LSPD)"},{"Police Car (SFPD)"},
{"Police Car (LVPD)"},{"Police Ranger"},{"Picador"},{"S.W.A.T. Van"},{"Alpha"},{"Phoenix"},{"Glendale"},
{"Sadler"},{"Luggage Trailer A"},{"Luggage Trailer B"},{"Stair Trailer"},{"Boxville"},{"Farm Plow"},
{"Utility Trailer"}
};

new playerColors[100] = {
0xFF8C13FF,0xC715FFFF,0x20B2AAFF,0xDC143CFF,0x6495EDFF,0xf0e68cFF,0x778899FF,0xFF1493FF,0xF4A460FF,0xEE82EEFF,0xFFD720FF,
0x8b4513FF,0x4949A0FF,0x148b8bFF,0x14ff7fFF,0x556b2fFF,0x0FD9FAFF,0x10DC29FF,0x534081FF,0x0495CDFF,0xEF6CE8FF,0xBD34DAFF,
0x247C1BFF,0x0C8E5DFF,0x635B03FF,0xCB7ED3FF,0x65ADEBFF,0x5C1ACCFF,0xF2F853FF,0x11F891FF,0x7B39AAFF,0x53EB10FF,0x54137DFF,
0x275222FF,0xF09F5BFF,0x3D0A4FFF,0x22F767FF,0xD63034FF,0x9A6980FF,0xDFB935FF,0x3793FAFF,0x90239DFF,0xE9AB2FFF,0xAF2FF3FF,
0x057F94FF,0xB98519FF,0x388EEAFF,0x028151FF,0xA55043FF,0x0DE018FF,0x93AB1CFF,0x95BAF0FF,0x369976FF,0x18F71FFF,0x4B8987FF,
0x491B9EFF,0x829DC7FF,0xBCE635FF,0xCEA6DFFF,0x20D4ADFF,0x2D74FDFF,0x3C1C0DFF,0x12D6D4FF,0x2A51E2FF,0xE3AC12FF,
0xFC42A8FF,0x2FC827FF,0x1A30BFFF,0xB740C2FF,0x42ACF5FF,0x2FD9DEFF,0xFAFB71FF,0x05D1CDFF,0xC471BDFF,0x94436EFF,0xC1F7ECFF,
0xCE79EEFF,0xBD1EF2FF,0x93B7E4FF,0x3214AAFF,0x184D3BFF,0xAE4B99FF,0x7E49D7FF,0x4C436EFF,0xFA24CCFF,0xCE76BEFF,0xA04E0AFF,
0x9F945CFF,0xDCDE3DFF,0x10C9C5FF,0x70524DFF,0x0BE472FF,0x8A2CD7FF,0x6152C2FF,0xCF72A9FF,0xE59338FF,0xEEDC2DFF,0xD8C762FF,
0x3FE65CFF
};

main()
{
	print("\n------ |S|W|R|E|D|D|E|R| ----------");
	print(" V I S I O N -- D R I F T I N G");
	print("------ SCRIPTED FROM STRACTH ------\n");
}

forward RespawnVehicles();

public OnGameModeInit()
{
	SetWorldTime(6);
	Create3DTextLabel("{00FF00}LS Beach\n{FFFFFF}Vision Drifting", 0x008080FF, 382.9828, -2079.0854, 7.8359, 40.0, 0, 0);
    Create3DTextLabel("{00FF00}LS Mall\n{FFFFFF}Vision Drifting", 0x008080FF, 1129.3685, -1457.6368, 15.7969, 40.0, 0, 0);
	Create3DTextLabel("{00FF00}LS Monas\n{FFFFFF}Vision Drifting", 0x008080FF, 1447.9894, -2287.4590, 13.5469, 40.0, 0, 0);
	gangzone0 = GangZoneCreate( 1560.246, -2370.721, 1350.246, -2202.721 ); // color = 366276010
	gangzone1 = GangZoneCreate( 1030.658, -1598.296, 1212.658, -1416.296 ); // color = 366276010
	gangzone2 = GangZoneCreate( 453.531, -1943.430, 286.698, -2156.611 ); // color = 366276010
    SetTimer("SendMessage", 60000, 1); //Ubah Sesuka Kalian
	RestartEveryThing ();
	for(new i=0; i<MAX_PLAYERS; i++)
	{
		HAYTD[i] = TextDrawCreate(549.000000,397.000000,"~h~~y~Hay Minigame~n~~r~Level: ~w~0/31 ~n~~r~Time: ~w~00:00:00");
		TextDrawFont(HAYTD[i] , 1);
		TextDrawSetProportional(HAYTD[i], 1);
		TextDrawSetOutline(HAYTD[i], 0);
		TextDrawColor(HAYTD[i],-65281);
		TextDrawLetterSize(HAYTD[i] ,0.310000,1.400000);
		TextDrawTextSize(HAYTD[i] , 640.000000,0.000000);
		TextDrawAlignment(HAYTD[i],1);
		TextDrawSetShadow(HAYTD[i], 0);
  		TextDrawUseBox(HAYTD[i], 1);
		TextDrawBoxColor(HAYTD[i], 255);
		TextDrawBackgroundColor(HAYTD[i], 255);
	}
	if(!fexist("unban_log.txt"))
	{
		fcreate("unban_log.txt");
		print("unban_log.txt didnt existed so it was created.");
	}
	if(!fexist("BannedPlayers.txt"))
	{
		fcreate("BannedPlayers.txt");
		print("BannedPlayers.txt didnt existed so it was created.");
	}
	Kary = TextDrawCreate(20.000000,288.000000,"_");
    TextDrawTextSize(Kary,344.000000,0.000000);
    TextDrawAlignment(Kary,0);
    TextDrawBackgroundColor(Kary,0x000000ff);
    TextDrawFont(Kary,1);
    TextDrawLetterSize(Kary,0.299999,1.000000);
    TextDrawLetterSize(Kary, 0.340000, 1.000000);
    TextDrawColor(Kary,0xffffffff);
    TextDrawSetOutline(Kary,1);
    TextDrawSetProportional(Kary,1);
    TextDrawSetShadow(Kary,1);
	pcarmenu[0] = CreatePickup(19132, 2, 1436.4440, -2291.3367, 13.5469, 0);
	pcarmenu[1] = CreatePickup(19132, 2, 376.7691, -2039.7360, 7.8301, 0);
	pcarmenu[2] = CreatePickup(19132, 2, 1122.5250, -1441.0884, 15.7969, 0);
	teleportmenu[0] = CreatePickup(19130, 2, 1436.8319, -2282.7190, 13.5469, 0);
	teleportmenu[1] = CreatePickup(19130, 2, 362.5185, -2040.8689, 7.8359, 0);
	teleportmenu[2] = CreatePickup(19130, 2, 1135.6782,-1441.0883,15.7969, 0);
	Create3DTextLabel("{15D4ED}Vehicle Menu", -1, 1436.4440, -2291.3367, 13.5469, 40.0, 0);
	Create3DTextLabel("{15D4ED}Vehicle Menu", -1, 376.7691, -2039.7360, 7.8301, 40.0, 0);
	Create3DTextLabel("{15D4ED}Vehicle Menu", -1, 1122.5250, -1441.0884, 15.7969, 40.0, 0);
	Create3DTextLabel("{FFE4C4}Teleport", -1, 1436.8319, -2282.7190, 13.5469, 40.0, 0);
	Create3DTextLabel("{FFE4C4}Teleport", -1, 362.5185, -2040.8689, 7.8359, 40.0, 0);
	Create3DTextLabel("{FFE4C4}Teleport", -1, 1135.6782,-1441.0883,15.7969, 40.0, 0);
	for(new i = 0; i < 300; i++)
	{
	  	if(IsValidSkin(i))
	  	{
			AddPlayerClass(i, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, -1, -1, -1);
		}
	}
    count = 0;
    SetTimer("RandomMessage",8000,1);
	SetTimer("RespawnVehicles", 360000, true);
	DisableInteriorEnterExits();
	UsePlayerPedAnims();
	EnableStuntBonusForAll(0);
	SetGameModeText("VD-Drift v.10");
	xReactionTimer = SetTimer("xReactionTest", TIME, 1);
	bikeslist = LoadModelSelectionMenu("bikes.txt");
	car1 = LoadModelSelectionMenu("car1.txt");
	car2 = LoadModelSelectionMenu("car2.txt");
	car3 = LoadModelSelectionMenu("car3.txt");
	car4 = LoadModelSelectionMenu("car4.txt");
	helicopter = LoadModelSelectionMenu("helicopter.txt");
	planes = LoadModelSelectionMenu("planes.txt");
	boat = LoadModelSelectionMenu("boat.txt");
	trains = LoadModelSelectionMenu("trains.txt");
	trailers = LoadModelSelectionMenu("trailers.txt");
	rcveh = LoadModelSelectionMenu("rcveh.txt");
        // SPECIAL
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/trains.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/pilots.txt");
    // LAS VENTURAS
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_gen.txt");
    // SAN FIERRO
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_gen.txt");
    // LOS SANTOS
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_gen_inner.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_gen_outer.txt");
    // OTHER AREAS
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/whetstone.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/bone.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/flint.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/tierra.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/red_county.txt");
    printf("Total vehicles from files: %d",total_vehicles_from_files);
	
	ServerTextDrawOne = TextDrawCreate(320.000000,240.000000,"-");
	TextDrawAlignment(ServerTextDrawOne,2);
	TextDrawBackgroundColor(ServerTextDrawOne,80);
	TextDrawFont(ServerTextDrawOne,1);
	TextDrawLetterSize(ServerTextDrawOne,15.000000,30.000000);
	TextDrawColor(ServerTextDrawOne,80);
	TextDrawSetOutline(ServerTextDrawOne,0);
	TextDrawSetProportional(ServerTextDrawOne,1);
	TextDrawSetShadow(ServerTextDrawOne,1);
	ServerTextDrawTwo = TextDrawCreate(320.000000,385.000000,"~W~~H~Drift Counter");
	TextDrawAlignment(ServerTextDrawTwo,2);
	TextDrawBackgroundColor(ServerTextDrawTwo,255);
	TextDrawFont(ServerTextDrawTwo,3);
	TextDrawLetterSize(ServerTextDrawTwo,0.500000,1.000000);
	TextDrawColor(ServerTextDrawTwo,-1);
	TextDrawSetOutline(ServerTextDrawTwo,1);
	TextDrawSetProportional(ServerTextDrawTwo,1);
	for(new Player; Player < GetMaxPlayers(); Player++)
	{
		ServerTextDrawThree[Player] = TextDrawCreate(250.000000,395.000000," ");
		TextDrawBackgroundColor(ServerTextDrawThree[Player],255);
		TextDrawFont(ServerTextDrawThree[Player],2);
		TextDrawLetterSize(ServerTextDrawThree[Player],0.200000,1.000000);
		TextDrawColor(ServerTextDrawThree[Player],-1);
		TextDrawSetOutline(ServerTextDrawThree[Player],1);
		TextDrawSetProportional(ServerTextDrawThree[Player],1);
		ServerTextDrawFour[Player] = TextDrawCreate(250.000000,405.000000," ");
		TextDrawBackgroundColor(ServerTextDrawFour[Player],255);
		TextDrawFont(ServerTextDrawFour[Player],2);
		TextDrawLetterSize(ServerTextDrawFour[Player],0.200000,1.000000);
		TextDrawColor(ServerTextDrawFour[Player],-1);
		TextDrawSetOutline(ServerTextDrawFour[Player],1);
		TextDrawSetProportional(ServerTextDrawFour[Player],1);
		ServerTextDrawFive[Player] = TextDrawCreate(250.000000,415.000000," ");
		TextDrawBackgroundColor(ServerTextDrawFive[Player],255);
		TextDrawFont(ServerTextDrawFive[Player],2);
		TextDrawLetterSize(ServerTextDrawFive[Player],0.200000,1.000000);
		TextDrawColor(ServerTextDrawFive[Player],-1);
		TextDrawSetOutline(ServerTextDrawFive[Player],1);
		TextDrawSetProportional(ServerTextDrawFive[Player],1);
	}
	ServerTimerOne = SetTimer("PlayerUpdate",1000,1);
	ServerTimerTwo = SetTimer("PlayerDrift",500,1);
    
    SetTimer("settime",1000,true);
	Date = TextDrawCreate(547.000000,11.000000,"--");
 	TextDrawFont(Date,3);
  	TextDrawLetterSize(Date,0.399999,1.600000);
    TextDrawColor(Date,0xffffffff);
    Time = TextDrawCreate(547.000000,28.000000,"--");
    TextDrawFont(Time,3);
    TextDrawLetterSize(Time,0.399999,1.600000);
    TextDrawColor(Time,0xffffffff);
    
	godbox = TextDrawCreate(617.000000, 103.000000, "_");
	TextDrawBackgroundColor(godbox, 255);
	TextDrawFont(godbox, 1);
	TextDrawLetterSize(godbox, -0.530000, 1.499999);
	TextDrawColor(godbox, -1);
	TextDrawSetOutline(godbox, 0);
	TextDrawSetProportional(godbox, 1);
	TextDrawSetShadow(godbox, 1);
	TextDrawUseBox(godbox, 1);
	TextDrawBoxColor(godbox, 80);
	TextDrawTextSize(godbox, 485.000000, -3.000000);

    TeleportText = TextDrawCreate(472.000000, 410.000000, "~r~[DM] ~w~BadLuckBrian(34) has joined to /mini");
	TextDrawBackgroundColor(TeleportText, 255);
	TextDrawFont(TeleportText, 1);
	TextDrawLetterSize(TeleportText, 0.230000, 1.299999);
	TextDrawColor(TeleportText, -1);
	TextDrawSetOutline(TeleportText, 1);
	TextDrawSetProportional(TeleportText, 1);
	
	TeleportText = TextDrawCreate(472.000000, 410.000000, "~r~[DM] ~w~BadLuckBrian(34) has joined to /onede");
	TextDrawBackgroundColor(TeleportText, 255);
	TextDrawFont(TeleportText, 1);
	TextDrawLetterSize(TeleportText, 0.230000, 1.299999);
	TextDrawColor(TeleportText, -1);
	TextDrawSetOutline(TeleportText, 1);
	TextDrawSetProportional(TeleportText, 1);

	god1 = TextDrawCreate(493.000000, 100.000000, "GODMODE ENABLED");
	TextDrawBackgroundColor(god1, 255);
	TextDrawFont(god1, 2);
	TextDrawLetterSize(god1, 0.290000, 1.799998);
	TextDrawColor(god1, -856817409);
	TextDrawSetOutline(god1, 1);
	TextDrawSetProportional(god1, 1);
    
    carname = TextDrawCreate(499.000000, 310.000000, "infernus");
	TextDrawBackgroundColor(carname, 13238271);
	TextDrawFont(carname, 2);
	TextDrawLetterSize(carname, 0.620000, 2.799998);
	TextDrawColor(carname, 10092543);
	TextDrawSetOutline(carname, 1);
	TextDrawSetProportional(carname, 1);
    //==========================================================================
    vd = TextDrawCreate(5.000000, 407.000000, "v");
	TextDrawBackgroundColor(vd, 255);
	TextDrawFont(vd, 2);
	TextDrawLetterSize(vd, 0.730000, 2.400001);
	TextDrawColor(vd, 10092543);
	TextDrawSetOutline(vd, 1);
	TextDrawSetProportional(vd, 1);

	vd1 = TextDrawCreate(18.000000, 403.000000, "DR");
	TextDrawBackgroundColor(vd1, 255);
	TextDrawFont(vd1, 2);
	TextDrawLetterSize(vd1, 0.559999, 3.000000);
	TextDrawColor(vd1, -1);
	TextDrawSetOutline(vd1, 1);
	TextDrawSetProportional(vd1, 1);

	vd2 = TextDrawCreate(9.000000, 428.000000, "Vision Drifting");
	TextDrawBackgroundColor(vd2, 255);
	TextDrawFont(vd2, 2);
	TextDrawLetterSize(vd2, 0.299999, 1.100000);
	TextDrawColor(vd2, -1);
	TextDrawSetOutline(vd2, 1);
	TextDrawSetProportional(vd2, 1);
    
    //==================== Server Information ==================================
	Textdraw2 = TextDrawCreate(183.000000, 430.000000, "~w~*use ~y~/cmds~w~ to see server commands*");
	TextDrawBackgroundColor(Textdraw2, 255);
	TextDrawFont(Textdraw2, 2);
	TextDrawLetterSize(Textdraw2, 0.250000, 1.01);
	TextDrawColor(Textdraw2, -1);
	TextDrawSetOutline(Textdraw2, 1);
	TextDrawSetProportional(Textdraw2, 1);
	
	//=========================== Textstring ===================================
	textstring = TextDrawCreate(150.000000, 359.000000, "~w~You have spawned ~b~Infernus~w~.");
	TextDrawBackgroundColor(textstring, 255);
	TextDrawFont(textstring, 1);
	TextDrawLetterSize(textstring, 0.319999, 1.600000);
	TextDrawColor(textstring, -1);
	TextDrawSetOutline(textstring, 1);
	TextDrawSetProportional(textstring, 1);
	
	// =========================== login =======================================
	Login0 = TextDrawCreate(660.000000, -11.000000, "_");
	TextDrawBackgroundColor(Login0, 255);
	TextDrawFont(Login0, 1);
	TextDrawLetterSize(Login0, 0.500000, 12.899999);
	TextDrawColor(Login0, -1);
	TextDrawSetOutline(Login0, 0);
	TextDrawSetProportional(Login0, 1);
	TextDrawSetShadow(Login0, 1);
	TextDrawUseBox(Login0, 1);
	TextDrawBoxColor(Login0, 255);
	TextDrawTextSize(Login0, -30.000000, 0.000000);

	Login1 = TextDrawCreate(660.000000, 366.000000, "_");
	TextDrawBackgroundColor(Login1, 255);
	TextDrawFont(Login1, 1);
	TextDrawLetterSize(Login1, 0.500000, 10.000000);
	TextDrawColor(Login1, -1);
	TextDrawSetOutline(Login1, 0);
	TextDrawSetProportional(Login1, 1);
	TextDrawSetShadow(Login1, 1);
	TextDrawUseBox(Login1, 1);
	TextDrawBoxColor(Login1, 255);
	TextDrawTextSize(Login1, -30.000000, 0.000000);

	Login2 = TextDrawCreate(660.000000, 363.000000, "_");
	TextDrawBackgroundColor(Login2, 255);
	TextDrawFont(Login2, 1);
	TextDrawLetterSize(Login2, 0.500000, 0.399999);
	TextDrawColor(Login2, -858993409);
	TextDrawSetOutline(Login2, 0);
	TextDrawSetProportional(Login2, 1);
	TextDrawSetShadow(Login2, 1);
	TextDrawUseBox(Login2, 1);
	TextDrawBoxColor(Login2, 1881153791);
	TextDrawTextSize(Login2, -30.000000, 0.000000);

	Login3 = TextDrawCreate(660.000000, 101.000000, "_");
	TextDrawBackgroundColor(Login3, 255);
	TextDrawFont(Login3, 1);
	TextDrawLetterSize(Login3, 0.500000, 0.399999);
	TextDrawColor(Login3, -858993409);
	TextDrawSetOutline(Login3, 0);
	TextDrawSetProportional(Login3, 1);
	TextDrawSetShadow(Login3, 1);
	TextDrawUseBox(Login3, 1);
	TextDrawBoxColor(Login3, 1881153791);
	TextDrawTextSize(Login3, -30.000000, 0.000000);

	Login4 = TextDrawCreate(243.000000, 378.000000, "~r~Vision ~w~Drifting");
	TextDrawBackgroundColor(Login4, 255);
	TextDrawFont(Login4, 3);
	TextDrawLetterSize(Login4, 0.500000, 2.300000);
	TextDrawColor(Login4, -1);
	TextDrawSetOutline(Login4, 1);
	TextDrawSetProportional(Login4, 1);

	Login5 = TextDrawCreate(189.000000, 400.000000, "where drift is your life");
	TextDrawBackgroundColor(Login5, 255);
	TextDrawFont(Login5, 2);
	TextDrawLetterSize(Login5, 0.450000, 2.200001);
	TextDrawColor(Login5, -1);
	TextDrawSetOutline(Login5, 1);
	TextDrawSetProportional(Login5, 1);
	
    CreateDynamicObject(19550, 494.43411, -3482.30664, 11.85794,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 2507.18457, -1677.93433, 12.54454,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(3472, 2510.08203, -1670.51636, 12.54454,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(3472, 2508.97827, -1662.74744, 12.54454,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(3472, 2503.33887, -1656.30774, 12.54454,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(3472, 2493.72803, -1653.62305, 12.54454,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(3472, 2484.54150, -1653.70911, 12.54454,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(3472, 2473.57544, -1653.64807, 12.54454,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(3472, 2501.93335, -1682.50293, 12.54454,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(3472, 2490.38330, -1684.32166, 12.54454,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(3472, 2478.77417, -1683.36548, 12.54454,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(3472, 2469.56665, -1674.92847, 12.54454,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(3472, 2466.84375, -1665.39355, 12.54454,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(3749, 2461.80664, -1658.71033, 18.23940,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(11489, 2507.09668, -1663.55139, 12.37963,   0.00000, 0.00000, -75.05997);
    CreateDynamicObject(14467, 2505.46997, -1671.20056, 15.08571,   0.00000, 0.00000, -110.75999);
    CreateDynamicObject(18648, 2507.18530, -1665.42981, 14.28305,   0.00000, 0.00000, -16.98000);
    CreateDynamicObject(18648, 2506.67432, -1667.10791, 14.28305,   0.00000, 0.00000, -16.98000);
    CreateDynamicObject(18648, 2506.23535, -1661.89929, 14.28305,   0.00000, 0.00000, 47.22001);
    CreateDynamicObject(18648, 2504.88745, -1660.64514, 14.28305,   0.00000, 0.00000, 47.22001);
    CreateDynamicObject(18647, 2507.13452, -1663.56091, 15.51470,   90.00000, 0.00000, 0.00000);
    CreateDynamicObject(18647, 2507.13452, -1663.56091, 17.51694,   90.00000, 0.00000, 0.00000);
    CreateDynamicObject(18647, 2507.13452, -1663.56091, 19.46809,   90.00000, 0.00000, 0.00000);
    CreateDynamicObject(18647, 2507.15234, -1663.55188, 21.47298,   90.00000, 0.00000, 0.00000);
    CreateDynamicObject(18647, 2507.15234, -1663.55188, 23.45931,   90.00000, 0.00000, 0.00000);
    CreateDynamicObject(18647, 2507.15601, -1663.55957, 25.45558,   90.00000, 0.00000, 0.00000);
    CreateDynamicObject(18647, 2507.17505, -1663.55310, 27.45185,   90.00000, 0.00000, 0.00000);
    CreateDynamicObject(18647, 2507.17603, -1663.55652, 29.43658,   90.00000, 0.00000, 0.00000);
    CreateDynamicObject(18647, 2507.17603, -1663.55652, 30.43396,   90.00000, 0.00000, 0.00000);
    CreateDynamicObject(3279, 544.66650, -3430.86987, 11.83169,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(3279, 443.11221, -3429.60376, 11.85026,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(3279, 443.17963, -3532.85986, 11.84797,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(3279, 540.49542, -3529.65576, 11.84352,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(7317, 451.26273, -3459.46118, 17.81391,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(7025, 538.07483, -3503.00854, 15.22034,   0.00000, 0.00000, -3.18000);
    CreateDynamicObject(3502, 530.49371, -3437.29126, 13.42044,   0.00000, 0.00000, 38.69999);
    CreateDynamicObject(3502, 525.00507, -3430.45142, 13.42044,   0.00000, 0.00000, 38.69999);
    CreateDynamicObject(11293, 505.68842, -3452.01733, 17.46231,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1358, 450.03244, -3512.96045, 13.05023,   0.00000, 0.00000, 125.16003);
    CreateDynamicObject(1358, 447.78778, -3509.81299, 13.05023,   0.00000, 0.00000, 125.16003);
    CreateDynamicObject(16093, 542.93646, -3458.09082, 16.00565,   0.00000, 0.00000, 85.92001);
    CreateDynamicObject(3073, 522.52087, -3456.46143, 13.47526,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(12913, 472.74277, -3480.91382, 14.37832,   0.00000, 0.00000, 34.20000);
    CreateDynamicObject(16337, 457.44287, -3498.82178, 12.71433,   0.00000, 0.00000, 16.43999);
    CreateDynamicObject(16327, 447.48581, -3484.49683, 11.84139,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19321, 470.76755, -3527.79053, 13.31398,   0.00000, 0.00000, -28.14000);
    CreateDynamicObject(19321, 475.14160, -3524.24463, 13.31398,   0.00000, 0.00000, 60.90002);
    CreateDynamicObject(3279, 491.83374, -3474.73755, 11.85026,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(17026, 561.93445, -3438.33496, 10.78653,   0.00000, 0.00000, -32.94009);
    CreateDynamicObject(17026, 561.70032, -3492.63257, 10.78653,   0.00000, 0.00000, -32.94009);
    CreateDynamicObject(17026, 561.25793, -3542.65259, 10.78653,   0.00000, 0.00000, -32.94009);
    CreateDynamicObject(17026, 536.20013, -3550.27905, 10.78650,   0.00000, 0.00000, 236.69991);
    CreateDynamicObject(17026, 485.10077, -3549.43799, 10.78650,   0.00000, 0.00000, 236.69991);
    CreateDynamicObject(17026, 435.23520, -3548.43823, 10.78650,   0.00000, 0.00000, 236.69991);
    CreateDynamicObject(17026, 426.01422, -3525.12817, 10.78650,   0.00000, 0.00000, 507.71924);
    CreateDynamicObject(17026, 426.12292, -3475.50464, 10.78650,   0.00000, 0.00000, 507.71924);
    CreateDynamicObject(17026, 426.90109, -3426.73193, 10.78650,   0.00000, 0.00000, 507.71924);
    CreateDynamicObject(17026, 453.60464, -3413.54395, 10.78650,   0.00000, 0.00000, 415.37970);
    CreateDynamicObject(17026, 502.31305, -3414.66919, 10.78650,   0.00000, 0.00000, 415.37970);
    CreateDynamicObject(17026, 551.82813, -3415.57324, 10.78650,   0.00000, 0.00000, 415.37970);
    CreateDynamicObject(7317, 500.88934, -3504.74756, 17.81391,   0.00000, 0.00000, 41.52001);
    CreateDynamicObject(900, 507.98669, -3536.08179, 14.33366,   0.00000, 0.00000, 31.32000);
    CreateDynamicObject(11497, 529.41644, -3476.87329, 11.80659,   0.00000, 0.00000, -89.28004);
    CreateDynamicObject(7317, 500.88934, -3504.74756, 25.78823,   0.00000, 0.00000, 41.52001);
    CreateDynamicObject(17000, 485.57306, -3436.29980, 11.78166,   0.00000, 0.00000, 13.02000);
    CreateDynamicObject(17000, 473.44049, -3503.43042, 11.78166,   0.00000, 0.00000, 13.02000);
	
	CreateDynamicObject(985, -2030.71033, 533.49207, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2030.65881, 526.44354, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2022.80127, 520.52301, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2030.65625, 520.50964, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2038.51160, 520.49634, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2038.50061, 527.56244, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2038.56262, 533.50848, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2038.53540, 540.57153, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2030.65356, 540.58447, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2030.68262, 547.70300, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2038.56213, 547.71558, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2046.38074, 547.69995, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2046.37231, 540.58289, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2046.36865, 533.52051, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2046.39319, 527.55762, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2046.32556, 520.51056, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2054.18579, 547.71790, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2054.16479, 540.57593, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2054.20825, 533.53137, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2054.16699, 527.54913, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2054.10986, 520.56561, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2062.04761, 547.71149, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2062.04492, 540.60956, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2062.04102, 533.54565, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2062.01904, 527.54089, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2061.91504, 520.66913, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2069.85645, 547.70801, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2069.87695, 540.57166, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2069.89380, 533.52991, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2069.94800, 527.62872, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2069.77026, 520.65094, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2077.68579, 547.70935, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2077.67847, 540.54260, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2077.73682, 533.52222, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2077.77222, 527.54260, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2077.66064, 520.65973, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2085.54907, 547.69641, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2085.53687, 540.57227, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2085.58691, 533.51270, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2085.60571, 527.52863, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2085.51563, 520.66217, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2093.38477, 547.67175, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2093.39014, 540.58679, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2093.41187, 533.56592, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2093.49585, 527.56580, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2093.45508, 520.68311, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2101.18701, 547.68640, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2101.22729, 540.56476, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2101.30322, 533.56372, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2101.29028, 527.55896, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2101.35547, 520.69757, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2109.01074, 547.68860, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2108.99292, 540.58221, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2109.10010, 533.55939, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2108.88379, 527.57739, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2108.98706, 520.69611, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2116.80298, 527.63593, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2054.19727, 551.46021, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2046.40967, 551.43091, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(985, -2062.00659, 551.43225, 80.80000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(2930, -2026.93396, 532.60327, 83.40000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2930, -2026.93396, 532.60327, 86.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2930, -2068.01831, 535.84399, 80.80000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(13607, 3220.00000, -1173.00000, 182.00000,   0.00000, 8.00000, 0.00000);
	CreateDynamicObject(19786, 2111.27686, 1003.14398, 47.00000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(18648, 2111.23486, 1003.19849, 47.60000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 2111.23486, 1003.19849, 46.40000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(0, 2105.88745, 1003.35992, 45.25200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(620, 2088.02344, 1002.68750, 9.50781,   356.85840, 0.00000, -1.57080);
	CreateDynamicObject(2745, 2475.52222, -1748.84998, 13.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2745, 2475.52197, -1752.08838, 13.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(638, 2486.38135, -1751.73450, 13.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(638, 2486.38330, -1743.69702, 13.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(638, 2486.38330, -1746.37964, 13.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(638, 2486.38184, -1749.06274, 13.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(638, 2486.38037, -1754.39636, 13.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(638, 2486.37524, -1757.04468, 13.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1237, 1121.55762, 1309.47314, 9.82069,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1237, 1153.90161, 1295.76404, 9.75929,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1422, 1119.58789, 1240.52856, 10.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1422, 1119.58325, 1237.83264, 10.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1422, 1119.57129, 1235.20154, 10.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1422, 1120.22827, 1232.80090, 10.20000,   0.00000, 0.00000, 120.00000);
	CreateDynamicObject(1422, 1121.58130, 1230.46594, 10.20000,   0.00000, 0.00000, 120.00000);
	CreateDynamicObject(1422, 1123.24402, 1228.51050, 10.20000,   0.00000, 0.00000, 140.00000);
	CreateDynamicObject(1422, 1125.29651, 1226.78284, 10.20000,   0.00000, 0.00000, 140.00000);
	CreateDynamicObject(1422, 1127.52893, 1225.52002, 10.20000,   0.00000, 0.00000, 160.00000);
	CreateDynamicObject(1422, 1130.03027, 1224.60596, 10.20000,   0.00000, 0.00000, 160.00000);
	CreateDynamicObject(1422, 1132.55945, 1224.15955, 10.20000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1422, 1135.26282, 1224.16321, 10.20000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(18647, 1119.56665, 1240.76599, 10.61097,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18647, 1119.56335, 1238.88574, 10.61097,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18647, 1119.56079, 1236.88501, 10.61097,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18647, 1119.56543, 1235.06177, 10.61097,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18647, 1120.01746, 1233.16345, 10.61100,   0.00000, 0.00000, 30.00000);
	CreateDynamicObject(18647, 1120.99146, 1231.48474, 10.61100,   0.00000, 0.00000, 30.00000);
	CreateDynamicObject(18647, 1121.78247, 1230.11597, 10.61100,   0.00000, 0.00000, 30.00000);
	CreateDynamicObject(18647, 1123.07605, 1228.64111, 10.61100,   0.00000, 0.00000, 50.00000);
	CreateDynamicObject(18647, 1124.59009, 1227.36682, 10.61100,   0.00000, 0.00000, 50.00000);
	CreateDynamicObject(18647, 1125.48340, 1226.61975, 10.61100,   0.00000, 0.00000, 50.00000);
	CreateDynamicObject(18647, 1127.18530, 1225.64307, 10.61100,   0.00000, 0.00000, 70.00000);
	CreateDynamicObject(18647, 1129.01355, 1224.98010, 10.61100,   0.00000, 0.00000, 70.00000);
	CreateDynamicObject(18647, 1130.36487, 1224.47729, 10.61100,   0.00000, 0.00000, 70.00000);
	CreateDynamicObject(18647, 1132.27808, 1224.13928, 10.61100,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18647, 1134.17969, 1224.13464, 10.61100,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18647, 1135.30225, 1224.12659, 10.61100,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1422, 1167.99622, 1319.65857, 10.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1422, 1168.00867, 1322.34985, 10.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1422, 1167.37378, 1324.73926, 10.20000,   0.00000, 0.00000, 120.00000);
	CreateDynamicObject(1422, 1166.03625, 1327.05273, 10.20000,   0.00000, 0.00000, 120.00000);
	CreateDynamicObject(1422, 1164.40820, 1328.99805, 10.20000,   0.00000, 0.00000, 140.00000);
	CreateDynamicObject(1422, 1162.36304, 1330.72046, 10.20000,   0.00000, 0.00000, 140.00000);
	CreateDynamicObject(1422, 1160.15002, 1332.00659, 10.20000,   0.00000, 0.00000, 160.00000);
	CreateDynamicObject(18647, 1168.00659, 1319.34387, 10.61198,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18647, 1168.01074, 1321.32312, 10.61198,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18647, 1168.01855, 1322.68506, 10.61198,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18647, 1167.51306, 1324.54224, 10.61200,   0.00000, 0.00000, 30.00000);
	CreateDynamicObject(18647, 1166.53027, 1326.25623, 10.61200,   0.00000, 0.00000, 30.00000);
	CreateDynamicObject(18647, 1165.93408, 1327.29626, 10.61200,   0.00000, 0.00000, 30.00000);
	CreateDynamicObject(18647, 1164.69128, 1328.78589, 10.61200,   0.00000, 0.00000, 50.00000);
	CreateDynamicObject(18647, 1163.26208, 1329.98206, 10.61200,   0.00000, 0.00000, 50.00000);
	CreateDynamicObject(18647, 1162.03894, 1331.01306, 10.61200,   0.00000, 0.00000, 50.00000);
	CreateDynamicObject(18647, 1160.36902, 1331.95630, 10.61200,   0.00000, 0.00000, 70.00000);
	CreateDynamicObject(1422, 11.22830, 1232.80090, 10.20000,   0.00000, 0.00000, 120.00000);
	CreateDynamicObject(1422, 11812283.00000, 1232.80090, 10.20000,   0.00000, 0.00000, 120.00000);
	CreateDynamicObject(1422, 11145813.00000, 1230.46594, 10.20000,   0.00000, 0.00000, 120.00000);
	CreateDynamicObject(1237, 1134.54761, 1275.52002, 9.82069,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1237, 1119.08618, 1346.75830, 9.82069,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3749, 2462.74976, -1658.78784, 18.00000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18750, 2440.90723, -1641.41919, 50.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(3279, 2092.81934, 989.46069, 9.77460,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(13831, 2182.63550, 1040.50562, 46.00000,   0.00000, 35.00000, -69.42000);
	CreateDynamicObject(1240, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1242, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1240, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1242, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8485, -239.92999, 1785.52002, 1992.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(8485, -205.92000, 1806.55005, 1992.12000,   0.00000, 90.00000, -269.45999);
	CreateDynamicObject(8485, -199.63000, 1848.10999, 1992.12000,   0.00000, 90.00000, -449.94000);
	CreateDynamicObject(8485, -143.89999, 1829.51001, 1992.12000,   0.00000, 90.00000, -540.71997);
	CreateDynamicObject(8485, -212.80000, 1766.46997, 2055.87012,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(18652, -195.75999, 1845.06006, 2034.68005,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18652, -191.42000, 1809.75000, 2034.37000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18652, -236.82001, 1830.59998, 2036.66003,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18652, -146.98000, 1827.56995, 2036.02002,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18652, -190.30000, 1828.41003, 2025.27002,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(4238, -203.66000, 1809.65002, 2038.06995,   0.00000, 0.00000, 210.80000);
	CreateDynamicObject(4238, -178.03999, 1809.91003, 2038.06995,   0.00000, 0.00000, 210.75000);
	CreateDynamicObject(4988, -215.81000, 1845.02002, 2039.78003,   0.00000, 0.00000, -169.92000);
	CreateDynamicObject(4988, -171.39000, 1845.06995, 2039.78003,   0.00000, 0.00000, -169.92000);
	CreateDynamicObject(7900, -146.99001, 1826.40002, 2042.23999,   0.00000, 0.00000, -89.28000);
	CreateDynamicObject(7901, -146.99001, 1826.40002, 2031.56006,   0.00000, 0.00000, -89.28000);
	CreateDynamicObject(7903, -242.74001, 1830.92004, 2043.12000,   0.00000, 0.00000, -67.08000);
	CreateDynamicObject(18830, -155.38000, 1827.82996, 2050.83008,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18830, -165.92999, 1827.95996, 2050.83008,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18830, -177.31000, 1828.06006, 2050.83008,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18830, -188.80000, 1828.17004, 2050.83008,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18830, -200.56000, 1828.33997, 2050.83008,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18830, -211.84000, 1828.40002, 2050.83008,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18830, -223.49001, 1828.45996, 2050.83008,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18830, -235.41000, 1828.28003, 2050.83008,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(8485, -212.80000, 1766.46997, 2022.44995,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19074, 1700.00000, 1200.00000, 200.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1693.31702, 1198.37976, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1693.31702, 1195.01440, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1693.31702, 1191.62646, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1693.31702, 1201.76501, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1693.31702, 1205.15002, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1693.31702, 1208.36145, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1691.62512, 1193.31567, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1691.62512, 1196.69910, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1691.62512, 1200.07495, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1691.62512, 1203.45996, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1691.62512, 1206.76001, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1695.00000, 1193.31567, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1695.00000, 1196.69910, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1695.00000, 1200.07495, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1695.00000, 1203.45996, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1695.00000, 1206.76001, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1696.67700, 1191.62646, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1696.67700, 1195.01440, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1696.67700, 1198.37976, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1696.67700, 1201.76501, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1696.67700, 1205.15002, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1696.67700, 1208.36145, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1698.34998, 1193.31567, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1698.34998, 1196.69910, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1698.34998, 1206.76001, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1698.34998, 1203.45996, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1698.34998, 1200.07495, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1700.03699, 1191.62646, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1700.03699, 1195.01440, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1700.03699, 1198.37976, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1700.03699, 1201.76501, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1700.03699, 1205.15002, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1700.03699, 1208.36145, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1701.72998, 1193.31567, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1701.72998, 1196.69910, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1701.72998, 1200.07495, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1701.72998, 1203.45996, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1701.72998, 1206.76001, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1703.41699, 1191.62646, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1703.41699, 1195.01440, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1703.41699, 1198.37976, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1703.41699, 1201.76501, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1703.41699, 1205.15002, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1703.41650, 1208.38147, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1705.10999, 1193.31567, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1705.10999, 1206.76001, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1705.10999, 1203.45996, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1705.10999, 1200.07495, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1705.10999, 1196.69910, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1706.73706, 1191.62646, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1708.37000, 1193.31567, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1708.37000, 1206.76001, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1708.37000, 1203.45996, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1708.37000, 1200.07495, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1708.37000, 1196.69910, 199.26250,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1706.73706, 1208.38147, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1706.73706, 1205.15002, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1706.73706, 1201.76501, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1706.73706, 1198.37976, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1706.73706, 1195.01440, 199.26250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1690.83997, 1193.26514, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1690.83997, 1196.64502, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1690.83997, 1200.00500, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1690.83997, 1203.40503, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1690.83997, 1206.70496, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1694.21997, 1193.26514, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1694.21997, 1196.64502, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1694.21997, 1200.00500, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1694.21997, 1203.40503, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1694.21997, 1206.70496, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1697.56006, 1193.26514, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1697.56006, 1196.64502, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1697.56006, 1200.00549, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1697.56006, 1203.40503, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1697.56006, 1206.70496, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1700.93994, 1193.26514, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1700.93994, 1196.64502, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1700.93994, 1200.00549, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1700.93994, 1203.40503, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1700.93994, 1206.70496, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1704.31995, 1193.26514, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1704.31995, 1196.64502, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1704.31995, 1200.00549, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1704.31995, 1203.40503, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1704.31995, 1206.70496, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1707.59998, 1193.26514, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1707.59998, 1196.64502, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1707.59998, 1200.00549, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1707.59998, 1203.40503, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1707.59998, 1206.70496, 197.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1693.36597, 1190.88904, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1696.72595, 1190.88904, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1700.10596, 1190.88904, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1703.46594, 1190.88904, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1706.78601, 1190.88904, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1706.78601, 1194.26904, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1703.46594, 1194.26904, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1700.10596, 1194.26904, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1696.72595, 1194.26904, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1693.36597, 1194.26904, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1706.78601, 1197.62903, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1703.46594, 1197.62903, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1700.10596, 1197.62903, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1696.72595, 1197.62903, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1693.36597, 1197.62903, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1706.78601, 1201.02905, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1703.46594, 1201.02905, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1700.10596, 1201.02905, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1696.72595, 1201.02905, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1693.36597, 1201.02905, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1706.78601, 1204.40906, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1703.46594, 1204.40906, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1700.10596, 1204.40906, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1696.72595, 1204.40906, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1693.36597, 1204.40906, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1706.78601, 1207.62903, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1703.46594, 1207.62903, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1700.10596, 1207.62903, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1696.72595, 1207.62903, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1523, 1693.36597, 1207.62903, 197.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(9833, 2488.54688, -1668.38293, 15.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18649, 2488.92920, -1668.31580, 18.47837,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18649, 2489.05762, -1668.31055, 18.47840,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19378, 88.73032, -2384.82080, 30.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 88.72451, -2375.19800, 30.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 99.20164, -2384.82080, 30.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 99.20856, -2375.19702, 30.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 99.20754, -2365.63208, 30.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 88.73355, -2365.61084, 30.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 109.68343, -2384.78491, 30.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 109.68749, -2375.14429, 30.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 109.67536, -2365.65332, 30.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 88.75135, -2356.01758, 30.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 99.24065, -2356.00464, 30.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 109.69273, -2356.00952, 30.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 83.52943, -2356.00854, 35.10430,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19378, 83.52792, -2365.62842, 35.10430,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19378, 83.49045, -2384.81567, 35.10430,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19378, 83.52235, -2375.19775, 35.10430,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19378, 114.83595, -2356.01709, 35.10430,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19378, 114.83213, -2365.63989, 35.10430,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19378, 114.83614, -2375.20703, 35.10430,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19378, 114.84150, -2384.80884, 35.10430,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19378, 110.12732, -2351.11426, 35.10430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19378, 100.49529, -2351.10547, 35.10430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19378, 90.98637, -2351.09790, 35.10430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19378, 86.92976, -2351.09570, 35.10430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19378, 88.32421, -2389.69092, 35.10430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19378, 97.95940, -2389.68896, 35.10430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19378, 107.56312, -2389.69629, 35.10430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19378, 112.92503, -2389.70557, 35.10430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19378, 88.75140, -2356.01758, 40.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 99.24060, -2356.00464, 40.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 109.69270, -2356.00952, 40.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 88.73360, -2365.61084, 40.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 99.20750, -2365.63208, 40.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 109.67540, -2365.65332, 40.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 88.72450, -2375.19800, 40.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 99.20860, -2375.19702, 40.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 109.68750, -2375.14429, 40.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 109.68340, -2384.78491, 40.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 88.73030, -2384.82080, 40.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19378, 99.20160, -2384.82080, 40.03670,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19129, 104.81065, -2379.62646, 30.11290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19129, 84.79025, -2379.66406, 30.11290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19129, 104.72959, -2359.60791, 30.11290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19129, 84.81635, -2359.63135, 30.11290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18649, 114.72350, -2389.60229, 30.39400,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18649, 114.72350, -2389.60229, 32.39400,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18649, 114.72350, -2389.60229, 34.39400,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18649, 114.72350, -2389.60229, 36.39400,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18649, 114.72350, -2389.60229, 38.39400,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18649, 114.72350, -2389.60229, 40.39400,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 83.58380, -2389.59131, 31.03630,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 83.58380, -2389.59131, 33.03630,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 83.58380, -2389.59131, 35.03630,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 83.58380, -2389.59131, 37.03630,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 83.58380, -2389.59131, 39.03630,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18647, 83.63080, -2351.20142, 30.27400,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18647, 83.63080, -2351.20142, 32.27400,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18647, 83.63080, -2351.20142, 34.27400,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18647, 83.63080, -2351.20142, 36.27400,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18647, 83.63080, -2351.20142, 38.27400,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18647, 83.63080, -2351.20142, 40.27400,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18651, 114.74600, -2351.22119, 30.33860,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18651, 114.74600, -2351.22119, 32.33860,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18651, 114.74600, -2351.22119, 34.33860,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18651, 114.74600, -2351.22119, 36.33860,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18651, 114.74600, -2351.22119, 38.33860,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18651, 114.74600, -2351.22119, 40.33860,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18654, 114.86868, -2372.29907, 36.55892,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18653, 97.71351, -2389.76025, 36.13300,   0.00000, 0.00000, 260.00000);
	CreateDynamicObject(18655, 83.53459, -2368.87207, 36.34980,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(18655, 100.92280, -2351.07104, 36.56910,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 101.85480, -2387.88379, 31.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 95.04071, -2387.98462, 31.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 95.04489, -2385.92725, 31.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 101.86143, -2385.74390, 31.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 100.04336, -2384.08374, 31.00000,   90.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 96.69727, -2384.09277, 31.00000,   90.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 100.06780, -2385.73999, 32.52000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 96.87969, -2385.73755, 32.52000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 96.87788, -2388.94580, 32.52000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 100.21829, -2388.93872, 32.52000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 96.69730, -2384.09277, 32.00000,   90.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 100.04340, -2384.08374, 32.00000,   90.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 101.85929, -2385.72412, 32.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 95.03811, -2385.72705, 32.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 96.87970, -2385.73755, 33.52000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 100.06780, -2385.73999, 33.52000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(14820, 96.35084, -2386.71484, 33.70610,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14820, 100.19296, -2386.74683, 33.70610,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1582, 98.39567, -2386.52612, 33.60643,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2683, 99.20631, -2385.86353, 33.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2683, 97.58765, -2385.94775, 33.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19787, 98.41630, -2385.17578, 34.03000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2229, 94.81313, -2384.00317, 30.20000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2229, 101.46103, -2383.96997, 30.20000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(18648, 95.32460, -2384.00195, 30.59300,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 101.59274, -2383.98779, 30.59300,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(14416, 103.81066, -2389.45435, 29.40000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14416, 93.09872, -2389.46655, 29.40000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(11686, 85.65659, -2373.38794, 30.20000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(11686, 85.65720, -2368.61377, 30.20000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(19366, 96.69730, -2384.09277, 32.00000,   90.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 83.49993, -2375.68970, 29.68000,   90.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 83.74971, -2366.30322, 29.68000,   90.00000, 90.00000, 0.00000);
	CreateDynamicObject(1775, 114.26530, -2360.99487, 31.30000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1776, 114.32468, -2362.20850, 31.30000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1209, 114.44075, -2363.36914, 30.20000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2754, 114.33860, -2364.34644, 30.98088,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2779, 114.32967, -2366.40967, 30.20000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2779, 114.29922, -2368.52881, 30.20000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2779, 114.27274, -2370.45947, 30.20000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2779, 114.25181, -2372.49316, 30.20000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2125, 113.26987, -2368.57593, 30.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2125, 113.27350, -2370.54199, 30.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2125, 113.29918, -2372.56689, 30.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2125, 113.27282, -2366.50171, 30.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1723, 95.38139, -2353.68628, 30.10000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1723, 95.37406, -2356.63428, 30.10000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1723, 102.09029, -2351.68066, 30.10000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1723, 102.08905, -2354.62012, 30.10000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2357, 98.89780, -2353.96704, 30.61000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19580, 98.92257, -2352.61646, 31.02000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19580, 98.90777, -2355.53052, 31.02000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19580, 98.92076, -2354.05469, 31.02000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2683, 98.89299, -2354.79712, 31.10000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2683, 98.92957, -2353.29956, 31.10000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19786, 98.94308, -2351.19653, 33.01672,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 99.52441, -2355.07300, 30.94104,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 99.52591, -2353.05127, 30.94104,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 98.27503, -2352.85962, 30.94104,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 98.27187, -2354.84106, 30.94104,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11489, 2503.70239, -1661.76636, 12.38610,   0.00000, 0.00000, -30.00000);
	CreateDynamicObject(18652, 2500.10425, -1661.22620, 14.28760,   0.00000, 0.00000, 92.00000);
	CreateDynamicObject(18652, 2502.06323, -1661.15796, 14.28760,   0.00000, 0.00000, 92.00000);
	CreateDynamicObject(18652, 2506.09229, -1664.74451, 14.28720,   0.00000, 0.00000, 30.00000);
	CreateDynamicObject(18652, 2505.10474, -1663.02673, 14.28720,   0.00000, 0.00000, 30.00000);
	CreateDynamicObject(18824, 2536.38794, -1825.32886, 22.90000,   180.00000, 60.00000, 90.00000);
	CreateDynamicObject(19447, 2540.06445, -1851.64575, 37.50840,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19447, 2536.56982, -1851.63879, 37.50840,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19447, 2533.09253, -1851.63904, 37.50840,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19447, 2529.61694, -1851.63879, 37.50840,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19447, 2529.62476, -1841.99670, 37.50840,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19447, 2543.56445, -1851.63855, 37.50840,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19447, 2543.55615, -1842.05481, 37.50840,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19447, 2545.21826, -1851.62463, 39.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2545.24194, -1842.01001, 39.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2540.31763, -1856.41650, 39.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2532.70337, -1856.41113, 39.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2527.87158, -1841.90503, 39.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2532.75952, -1837.10327, 39.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2540.32397, -1837.10608, 39.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2540.31763, -1856.41650, 42.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2532.70337, -1856.41113, 42.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObjectEx(3374, 1091.23035, 1535.84351, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1091.22888, 1539.83667, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1091.23560, 1531.88245, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1091.23035, 1527.89075, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1095.19458, 1527.89124, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1095.20227, 1531.87683, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1095.21912, 1535.89001, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1095.22339, 1539.83154, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1099.20544, 1539.81860, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1099.20728, 1535.85986, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1099.20862, 1531.88037, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1099.19373, 1527.88245, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1103.19214, 1539.82251, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1103.18164, 1535.82043, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1103.17651, 1531.81787, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1103.17065, 1527.87781, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1107.12317, 1527.88123, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1107.13013, 1531.86279, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1107.14783, 1535.85071, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1107.14612, 1539.84058, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1107.15063, 1543.82141, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1103.16089, 1543.82117, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1099.19934, 1543.80957, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1095.23889, 1543.80176, 300.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObjectEx(3374, 1091.21826, 1543.79382, 300.00000,   0.00000, 0.00000, 0.00000);
	////////////////////////////////////////////////SEJF///////////////////////////////////////////////////////////
	CreateDynamicObject(17698, 2401.89307, -1707.46179, 15.50286,   0.00000, 0.00000, 90.04841);
	CreateDynamicObject(17698, 2401.89307, -1707.46179, 15.50286,   0.00000, 0.00000, 90.04841);
	CreateDynamicObject(17566, 2398.07959, -1716.80054, 14.35603,   0.00000, 0.00000, 270.27847);
	CreateDynamicObject(19365, 2408.01587, -1700.09668, 15.75107,   0.00000, 0.00000, 0.39998);
	CreateDynamicObject(19365, 2408.02808, -1708.84106, 14.44807,   0.00000, 0.00000, 0.39998);
	CreateDynamicObject(19365, 2408.02808, -1708.84106, 14.44807,   0.00000, 0.00000, 0.39998);
	CreateDynamicObject(19365, 2408.03052, -1708.83801, 15.75408,   0.00000, 0.00000, 0.39998);
	CreateDynamicObject(19365, 2408.07715, -1705.72656, 15.78164,   0.00000, 0.00000, 0.39998);
	CreateDynamicObject(19365, 2408.06836, -1702.60718, 15.75207,   0.00000, 0.00000, 0.39998);
	CreateDynamicObject(19365, 2408.02197, -1700.09668, 14.44807,   0.00000, 0.00000, 0.39998);
	CreateDynamicObject(19365, 2408.06934, -1702.61230, 14.44807,   0.00000, 0.00000, 0.39998);
	CreateDynamicObject(19365, 2408.07715, -1705.72656, 14.44707,   0.00000, 0.00000, 0.39998);
	CreateDynamicObject(19365, 2408.05298, -1711.99829, 14.44807,   0.00000, 0.00000, 0.39998);
	CreateDynamicObject(19365, 2397.36841, -1708.65454, 15.84674,   0.00000, 0.00000, 271.43210);
	CreateDynamicObject(19365, 2408.05298, -1711.99829, 15.75408,   0.00000, 0.00000, 0.39998);
	CreateDynamicObject(19365, 2408.04370, -1712.19971, 11.55200,   0.00000, 0.00000, 0.39998);
	CreateDynamicObject(19365, 2408.04370, -1712.19971, 14.93308,   0.00000, 0.00000, 0.39998);
	CreateDynamicObject(19365, 2408.04370, -1712.19971, 15.73508,   0.00000, 0.00000, 0.39998);
	CreateDynamicObject(19365, 2406.36279, -1713.53735, 14.33681,   0.00000, 0.00000, 270.20139);
	CreateDynamicObject(19365, 2406.36279, -1713.53735, 15.73882,   0.00000, 0.00000, 270.20139);
	CreateDynamicObject(19365, 2401.11426, -1713.47754, 12.16838,   0.00000, 0.00000, 270.20139);
	CreateDynamicObject(19365, 2405.92847, -1713.49707, 15.72099,   0.00000, 0.00000, 268.99124);
	CreateDynamicObject(19365, 2399.46680, -1713.49133, 14.41698,   0.00000, 0.00000, 270.20139);
	CreateDynamicObject(19365, 2400.13818, -1711.86279, 15.94270,   0.00000, 0.00000, 182.08331);
	CreateDynamicObject(19365, 2398.49268, -1708.63611, 15.84470,   0.00000, 0.00000, 91.12875);
	CreateDynamicObject(19365, 2400.07544, -1710.19751, 15.86205,   0.00000, 0.00000, 181.98131);
	CreateDynamicObject(19365, 2398.49268, -1708.63611, 14.33870,   0.00000, 0.00000, 91.12875);
	CreateDynamicObject(19365, 2395.77490, -1700.12683, 14.92706,   0.00000, 0.00000, 180.08966);
	CreateDynamicObject(19365, 2400.08545, -1710.09802, 14.33870,   0.00000, 0.00000, 182.18231);
	CreateDynamicObject(19365, 2400.13818, -1711.86279, 14.33870,   0.00000, 0.00000, 182.08331);
	CreateDynamicObject(19356, 2406.30518, -1709.40308, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2402.67261, -1712.44141, 13.12509,   0.00000, 90.00000, -0.48000);
	CreateDynamicObject(19356, 2399.18237, -1712.43604, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2399.22583, -1709.25037, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2402.66455, -1709.22852, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2397.32471, -1709.10706, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2397.32666, -1706.16748, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2400.71191, -1706.10010, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2404.18066, -1706.18750, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2406.30762, -1699.97522, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2406.20044, -1711.93640, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2406.10034, -1711.93799, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2406.20825, -1706.23547, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2406.16016, -1703.10474, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2402.72241, -1703.06335, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2399.30078, -1703.06116, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2397.34229, -1703.03845, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2397.19556, -1699.97058, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2400.56470, -1700.03674, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19356, 2403.73096, -1700.01697, 13.12509,   0.00000, 90.00000, 359.84982);
	CreateDynamicObject(19365, 2399.46680, -1713.49133, 15.72099,   0.00000, 0.00000, 270.20139);
	CreateDynamicObject(19365, 2401.18066, -1713.44128, 14.91998,   0.00000, 0.00000, 270.20139);
	CreateDynamicObject(19365, 2400.98022, -1713.43225, 15.71999,   0.00000, 0.00000, 270.20139);
	CreateDynamicObject(19365, 2397.36792, -1708.64697, 14.33870,   0.00000, 0.00000, 271.43210);
	CreateDynamicObject(19365, 2395.78638, -1707.11389, 14.29261,   0.00000, 0.00000, 180.08966);
	CreateDynamicObject(19365, 2395.78638, -1707.11389, 15.90472,   0.00000, 0.00000, 180.08966);
	CreateDynamicObject(19365, 2395.79053, -1703.93738, 14.80471,   0.00000, 0.00000, 180.08966);
	CreateDynamicObject(19365, 2395.79053, -1703.93738, 15.92607,   0.00000, 0.00000, 180.08966);
	CreateDynamicObject(19365, 2395.78174, -1700.72864, 14.92406,   0.00000, 0.00000, 180.08966);
	CreateDynamicObject(19365, 2406.37500, -1698.58899, 12.61607,   0.00000, 0.00000, 90.32404);
	CreateDynamicObject(19365, 2395.75269, -1700.10938, 15.92707,   0.00000, 0.00000, 180.08966);
	CreateDynamicObject(19394, 2403.49487, -1713.47534, 15.03433,   0.00000, 0.00000, 269.02487);
	CreateDynamicObject(19365, 2405.96313, -1713.59082, 13.27539,   0.00000, 0.00000, 270.20139);
	CreateDynamicObject(19365, 2405.86328, -1713.59473, 12.16838,   0.00000, 0.00000, 270.20139);
	CreateDynamicObject(19365, 2395.78174, -1700.72961, 15.92607,   0.00000, 0.00000, 180.08966);
	CreateDynamicObject(19365, 2397.39893, -1698.62671, 14.93920,   0.00000, 0.00000, 90.32404);
	CreateDynamicObject(19365, 2397.39893, -1698.62610, 15.64020,   0.00000, 0.00000, 90.32404);
	CreateDynamicObject(19365, 2400.66431, -1698.64636, 14.92809,   0.00000, 0.00000, 90.32404);
	CreateDynamicObject(19365, 2400.66431, -1698.64636, 15.62809,   0.00000, 0.00000, 90.32404);
	CreateDynamicObject(19365, 2403.77563, -1698.66187, 14.92709,   0.00000, 0.00000, 90.32404);
	CreateDynamicObject(19365, 2403.77563, -1698.66187, 15.72909,   0.00000, 0.00000, 90.32404);
	CreateDynamicObject(19365, 2406.37500, -1698.58899, 15.72909,   0.00000, 0.00000, 90.32404);
	CreateDynamicObject(19365, 2401.16455, -1700.03540, 15.82839,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19365, 2401.17163, -1703.24744, 15.81627,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19365, 2401.16455, -1700.03540, 14.21327,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19365, 2401.17163, -1703.24744, 15.81627,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19394, 2401.12573, -1707.00806, 15.78954,   0.00000, 0.00000, 357.49680);
	CreateDynamicObject(19365, 2401.17163, -1703.24744, 14.21327,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19365, 2399.44873, -1708.61719, 15.90355,   0.00000, 0.00000, 271.99802);
	CreateDynamicObject(19365, 2401.18164, -1703.85339, 15.83562,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19365, 2401.18164, -1703.85339, 14.21327,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19365, 2401.18555, -1704.65417, 12.35940,   0.00000, 0.00000, 359.99899);
	CreateDynamicObject(19365, 2401.06128, -1709.31921, 12.35940,   0.00000, 0.00000, 359.99899);
	CreateDynamicObject(19365, 2401.06128, -1709.31921, 15.81057,   0.00000, 0.00000, 359.99899);
	CreateDynamicObject(19365, 2399.47461, -1710.84961, 14.80656,   0.00000, 0.00000, 271.89801);
	CreateDynamicObject(19365, 2399.47461, -1710.84961, 15.80656,   0.00000, 0.00000, 271.89801);
	CreateDynamicObject(19365, 2399.44873, -1708.61719, 14.90255,   0.00000, 0.00000, 271.99802);
	CreateDynamicObject(2313, 2407.33765, -1702.16260, 13.19065,   0.00000, 0.00000, 271.05884);
	CreateDynamicObject(1752, 2407.43677, -1702.92798, 13.73880,   0.00000, 0.00000, 271.37253);
	CreateDynamicObject(2818, 2403.92407, -1703.02014, 13.25755,   0.00000, 0.00000, 270.50848);
	CreateDynamicObject(2637, 2404.40723, -1703.40674, 13.70218,   0.00000, 0.00000, 270.74286);
	CreateDynamicObject(2240, 2401.73950, -1699.27942, 13.68537,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1723, 2401.82275, -1704.29517, 13.20018,   0.00000, 0.00000, 90.42944);
	CreateDynamicObject(1725, 2399.36890, -1702.23718, 13.06973,   0.00000, 0.00000, 0.10001);
	CreateDynamicObject(2195, 2396.38452, -1699.26233, 13.75639,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2528, 2396.36206, -1706.74951, 13.21242,   0.00000, 0.00000, 90.87653);
	CreateDynamicObject(19365, 2397.49878, -1698.62256, 14.93920,   0.00000, 0.00000, 90.32404);
	CreateDynamicObject(19365, 2397.49878, -1698.62195, 15.64020,   0.00000, 0.00000, 90.32404);
	CreateDynamicObject(19362, 5034.87988, -11363.89844, 500.74258,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2406.50244, -1703.16895, 17.21711,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2397.53857, -1705.28125, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2402.39819, -1702.47681, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2402.38647, -1704.66907, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2402.37866, -1707.74695, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2402.36377, -1710.92920, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2402.36816, -1711.82996, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2405.74707, -1711.81091, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2406.24854, -1711.80786, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2406.28223, -1706.31946, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2405.82910, -1708.67969, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2405.71265, -1705.61707, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2405.68628, -1702.50305, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2405.80933, -1700.01843, 17.21711,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2406.42432, -1700.00281, 17.21711,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2406.22949, -1708.65173, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2402.37402, -1699.34839, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2398.96802, -1699.27478, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2397.56274, -1699.24402, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2397.65088, -1702.35864, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2398.95093, -1702.31421, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2399.23071, -1705.14478, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2399.22144, -1707.05518, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2397.61792, -1707.23267, 17.21510,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19394, 2403.49487, -1713.47534, 15.63534,   0.00000, 0.00000, 269.02487);
	CreateDynamicObject(19365, 2400.98022, -1713.43225, 14.91998,   0.00000, 0.00000, 270.20139);
	CreateDynamicObject(19356, 2406.10400, -1709.40332, 13.12509,   0.00000, 90.00000, 359.84982);
	///////////////////////////////////////////////////////////////////////////////////////////////////////////
	CreateDynamicObject(19447, 2545.21826, -1851.62463, 42.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18840, 2130.55737, 883.62323, 17.00000,   180.00000, 60.00000, 90.00000);
	CreateDynamicObject(18840, 2130.48267, 869.81329, 58.00000,   0.00000, 23.00000, 90.00000);
	CreateDynamicObject(18852, 2130.57471, 933.57355, 91.70000,   110.00000, 0.00000, 0.00000);
	CreateDynamicObject(18852, 2130.52759, 1027.20605, 125.70000,   110.00000, 0.00000, 0.00000);
	CreateDynamicObject(18987, 2130.67871, 1100.19531, 141.95390,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18852, 2130.67407, 1162.63196, 142.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18855, 2162.34985, 1242.47839, 142.00000,   -90.00000, 90.00000, 0.00000);
	CreateDynamicObject(18855, 2225.98730, 1178.99036, 142.00000,   -90.00000, -90.00000, 0.00000);
	CreateDynamicObject(18852, 2257.82007, 1260.66724, 142.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18994, 2257.80054, 1312.93091, 147.00000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(18855, 2225.98853, 1278.96924, 153.00000,   -90.00000, -90.00000, 0.00000);
	CreateDynamicObject(18852, 2194.14795, 1360.61243, 153.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18852, 2194.13452, 1460.58618, 153.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18784, 2191.47314, 1512.48401, 149.98981,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18784, 2187.72095, 1575.60645, 147.98981,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(18784, 2187.70166, 1595.59070, 143.13000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(18784, 2187.70117, 1615.56702, 138.13000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(18852, 2187.94116, 1675.06372, 140.00000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(18852, 2187.95142, 1774.73792, 140.00000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(18852, 2187.94238, 1874.65808, 140.00000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(18852, 2187.92188, 1974.64868, 140.00000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(18784, 2188.29175, 2034.06909, 137.39999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(8467, 2162.83618, 913.20831, 7.81250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(5820, 2117.02539, 958.86066, 11.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2545.22925, -1842.03528, 42.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2540.32397, -1837.10608, 42.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2532.75952, -1837.10327, 42.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2527.87158, -1841.90503, 42.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2527.86768, -1851.50476, 42.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18809, 2502.98633, -1854.00964, 42.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19447, 2527.86743, -1844.35156, 39.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18824, 2458.01660, -1854.00415, 53.73000,   180.00000, 46.00000, 0.00000);
	CreateDynamicObject(18824, 2454.49048, -1854.00098, 89.00000,   0.00000, 35.00000, 0.00000);
	CreateDynamicObject(18809, 2497.05225, -1854.01099, 104.20000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(18809, 2547.04443, -1854.03345, 104.20000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(18824, 2591.82202, -1853.99500, 115.90000,   180.00000, 46.00000, 180.00000);
	CreateDynamicObject(18824, 2594.11035, -1853.96716, 150.00000,   0.00000, 140.00000, 0.00000);
	CreateDynamicObject(18809, 2550.24414, -1853.94983, 163.71001,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(18809, 2500.32935, -1853.94971, 163.71001,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(18809, 2450.40649, -1853.95447, 163.71001,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(18809, 2400.47925, -1853.93445, 163.71001,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(13593, 2373.90649, -1856.87561, 159.41769,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(13593, 2373.83813, -1854.06567, 159.41769,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(13593, 2373.76587, -1851.30237, 159.41769,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 1131.15405, -1811.71228, 34.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 1131.14307, -1808.54736, 34.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 1132.82422, -1806.85608, 34.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 1135.97949, -1806.85388, 34.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 1137.67188, -1808.52917, 34.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 1137.67261, -1811.71741, 34.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 1135.97852, -1813.39673, 34.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 1132.79761, -1813.39795, 34.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 1135.82910, -1808.57385, 35.98000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 1132.32922, -1808.57483, 35.98000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 1132.31836, -1811.75720, 35.98000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 1135.81384, -1811.78271, 35.98000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 1139.33447, -1813.41736, 34.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 1142.52026, -1813.41748, 34.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 1139.36096, -1806.83313, 34.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 1142.50537, -1806.82837, 34.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 1144.02368, -1808.52063, 34.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 1144.02979, -1811.76709, 34.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 1144.02332, -1811.57141, 34.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 1139.51172, -1808.53064, 35.98000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 1139.51697, -1811.71582, 35.98000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 1143.00610, -1811.71094, 35.98000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 1143.01233, -1808.51770, 35.98000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 1131.10620, -1815.08899, 34.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 1131.10071, -1818.29822, 34.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 1137.49011, -1815.07275, 34.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 1137.48645, -1818.25525, 34.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 1135.82715, -1819.76062, 34.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 1132.64465, -1819.75964, 34.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 1135.63831, -1815.09534, 35.98000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 1135.65369, -1818.27014, 35.98000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 1132.16113, -1818.26062, 35.98000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 1132.14734, -1815.06580, 35.98000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 1137.64868, -1815.10681, 34.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 1137.64258, -1818.30957, 34.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 1144.19690, -1815.11768, 34.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 1144.19958, -1818.30603, 34.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 1142.51672, -1819.81799, 34.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 1139.31750, -1819.81042, 34.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 1139.48914, -1815.10583, 35.98000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 1142.98376, -1815.09534, 35.98000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 1142.98804, -1818.28821, 35.98000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 1139.48364, -1818.30054, 35.98000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(14825, 2150.58252, 1011.40509, 400.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2158.33154, 999.82861, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2158.80566, 1003.56940, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2157.13403, 1005.24078, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2155.34302, 1007.07538, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2154.80615, 1001.71490, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2153.65405, 1012.27173, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2155.32520, 1014.06189, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2156.98804, 1012.40033, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2156.98926, 1015.87158, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2156.99243, 1018.81091, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2157.74756, 1007.07013, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2148.33545, 1014.11987, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2150.02124, 1016.49731, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2151.82251, 1017.60492, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2158.80444, 1015.82062, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2151.83301, 1010.60742, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2150.02466, 1013.84070, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2150.01855, 1018.87299, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2148.24658, 1020.53198, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2150.18384, 1008.80292, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2150.19141, 1005.30182, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2150.18188, 1003.22742, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2148.33911, 1001.56622, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2146.68066, 1003.33667, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2151.83130, 1020.53210, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2151.83203, 1015.69202, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2149.71802, 1004.88440, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2151.78809, 1004.88391, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2146.66846, 1015.78052, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2149.64478, 1017.60168, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2146.66504, 1017.55103, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2141.41626, 1005.00372, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2143.08911, 1003.20313, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2143.06006, 1006.81207, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2144.73413, 1008.45587, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2146.38574, 1010.12927, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2140.34497, 1008.62079, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2144.68848, 1011.78369, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2143.03198, 1013.46667, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19447, 2140.13062, 1015.15387, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2141.32104, 1017.56378, 400.00000,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19447, 2143.03833, 1019.22058, 400.00000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19003, 3109.56055, -1661.12036, 400.00000,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19003, 3129.47681, -1661.15076, 400.00000,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19003, 3129.47461, -1641.16858, 400.00000,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19003, 3109.53174, -1641.15601, 400.00000,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19003, 3109.53857, -1621.20984, 400.00000,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19003, 3129.46509, -1621.18103, 400.00000,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19003, 3149.45215, -1621.19202, 400.00000,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19003, 3149.45288, -1641.16260, 400.00000,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19003, 3149.42432, -1661.11926, 400.00000,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19003, 3169.40991, -1661.11267, 400.00000,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19003, 3169.44067, -1641.11670, 400.00000,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19003, 3169.39917, -1621.19763, 400.00000,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19003, 3169.39160, -1601.23535, 400.00000,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19003, 3149.42065, -1601.22876, 400.00000,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19003, 3129.43872, -1601.20557, 400.00000,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19003, 3109.51807, -1601.22888, 400.00000,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19003, 3109.53125, -1591.28003, 409.00000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19003, 3129.49292, -1591.28687, 409.00000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19003, 3149.46582, -1591.28186, 409.00000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19003, 3169.44165, -1591.28833, 409.00000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19003, 3179.33960, -1601.29236, 409.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19003, 3179.33887, -1621.27502, 409.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19003, 3179.32202, -1641.24902, 409.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19003, 3179.31323, -1661.21130, 409.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19003, 3169.39893, -1671.10242, 409.00000,   0.00000, 90.00000, 270.00000);
	CreateDynamicObject(19003, 3149.43604, -1671.12598, 409.00000,   0.00000, 90.00000, 270.00000);
	CreateDynamicObject(19003, 3129.45557, -1671.13232, 409.00000,   0.00000, 90.00000, 270.00000);
	CreateDynamicObject(19003, 3109.51758, -1671.15918, 409.00000,   0.00000, 90.00000, 270.00000);
	CreateDynamicObject(19003, 3099.55811, -1661.14111, 409.00000,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(19003, 3099.50928, -1601.08508, 409.00000,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(6189, 3061.46118, -1632.43347, 347.00000,   -40.00000, 0.00000, 90.00000);
	CreateDynamicObject(6189, 2969.00146, -1632.40149, 269.39999,   -40.00000, 0.00000, 90.00000);
	CreateDynamicObject(6189, 2886.26489, -1632.35474, 200.00000,   -40.00000, 0.00000, 90.00000);
	CreateDynamicObject(18786, 2817.32397, -1622.63123, 171.00000,   0.00000, -5.00000, 0.00000);
	CreateDynamicObject(18786, 2817.29297, -1642.40906, 171.00000,   0.00000, -5.00000, 0.00000);
	CreateDynamicObject(11489, 2179.45630, 985.85175, 9.79670,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(11490, -2344.99463, -1610.37048, 482.00000,   356.85840, 0.00000, 65.00000);
	CreateDynamicObject(18829, -2256.83472, -1601.40662, 483.70001,   0.00000, 90.00000, 9.00000);
	CreateDynamicObject(18829, -2207.58203, -1593.60303, 483.70001,   0.00000, 90.00000, 9.00000);
	CreateDynamicObject(18829, -2158.44214, -1585.80994, 483.70001,   0.00000, 90.00000, 9.00000);
	CreateDynamicObject(18829, -2109.09229, -1577.98779, 483.70001,   0.00000, 90.00000, 9.00000);
	CreateDynamicObject(18829, -2059.76099, -1570.17139, 483.70001,   0.00000, 90.00000, 9.00000);
	CreateDynamicObject(18829, -2010.44043, -1562.35425, 483.70001,   0.00000, 90.00000, 9.00000);
	CreateDynamicObject(19005, -1981.15796, -1557.86255, 478.87820,   0.00000, 0.00000, -84.00000);
	CreateDynamicObject(3279, -940.27643, 2027.88855, 59.89630,   0.00000, 0.00000, 42.00000);
	CreateDynamicObject(17529, -926.22321, 2011.79431, 61.00000,   0.00000, 0.00000, 41.00000);
	CreateDynamicObject(16778, -889.34479, 2000.79626, 59.88000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18809, -2256.77930, -1635.47998, 487.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(18809, -2206.84253, -1635.51404, 487.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(18826, -2171.54980, -1651.66479, 487.50000,   270.00000, 190.00000, 9.00000);
	CreateDynamicObject(18826, -2193.25098, -1683.08337, 487.50000,   270.00000, 10.00000, 9.00000);
	CreateDynamicObject(18826, -2172.63843, -1715.29285, 487.50000,   270.00000, 190.00000, 9.00000);
	CreateDynamicObject(18826, -2194.38306, -1746.76746, 487.50000,   270.00000, 10.00000, 9.00000);
	CreateDynamicObject(18826, -2173.75269, -1778.99524, 487.50000,   270.00000, 190.00000, 9.00000);
	CreateDynamicObject(18826, -2195.51245, -1810.48291, 487.50000,   270.00000, 10.00000, 9.00000);
	CreateDynamicObject(18826, -2174.91528, -1842.67261, 487.50000,   270.00000, 190.00000, 9.00000);
	CreateDynamicObject(18826, -2196.66675, -1874.12708, 487.50000,   270.00000, 10.00000, 9.00000);
	CreateDynamicObject(18826, -2176.03369, -1906.36780, 487.50000,   270.00000, 190.00000, 9.00000);
	CreateDynamicObject(18826, -2197.79565, -1937.83923, 487.50000,   270.00000, 10.00000, 9.00000);
	CreateDynamicObject(18648, -2187.50513, -1954.98254, 482.34970,   -10.00000, 2.00000, -1.00000);
	CreateDynamicObject(18648, -2187.47388, -1953.01379, 482.34970,   10.00000, 2.00000, -1.00000);
	CreateDynamicObject(18648, -2187.43408, -1951.18005, 483.01999,   30.00000, 2.00000, -1.00000);
	CreateDynamicObject(18648, -2187.53052, -1956.80762, 483.01999,   -30.00000, 2.00000, -1.00000);
	CreateDynamicObject(997, 2158.34204, 941.09863, 10.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(997, 2158.30005, 944.68286, 10.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19005, 2069.12256, 1136.02795, 9.65837,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19005, 2068.99365, 1155.31555, 9.65840,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3471, 2190.27148, 1001.65430, 11.00000,   0.00000, 0.00000, 200.00000);
	CreateDynamicObject(3471, 2193.48999, 993.18256, 11.00000,   0.00000, 0.00000, 200.00000);
	CreateDynamicObject(3515, 2190.97070, 996.95599, 9.80443,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18646, 2191.00977, 996.97522, 10.69745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2158.51587, 983.58093, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2153.21997, 983.52008, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2147.93359, 983.46411, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2142.63184, 983.41559, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2137.33545, 983.36621, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2132.03247, 983.31323, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2126.79492, 983.31189, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2121.54517, 983.30743, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2116.29980, 983.29987, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2111.07422, 983.29150, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2105.81885, 983.28339, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2100.56519, 983.27911, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2095.31714, 983.28540, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2090.05005, 983.28052, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2087.45728, 985.89716, 9.81750,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19869, 2087.44775, 991.16797, 9.81750,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19869, 2087.45898, 996.42590, 9.81750,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19869, 2087.46216, 1001.67352, 9.81750,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19869, 2087.45801, 1006.93219, 9.81750,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19869, 2087.45630, 1012.19916, 9.81750,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19869, 2087.46313, 1017.47638, 9.81750,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19869, 2087.45142, 1019.23395, 9.81750,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19869, 2176.56958, 983.55194, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2181.84033, 983.55182, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2187.09668, 983.54901, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2192.37451, 983.54987, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2194.13599, 983.57526, 9.81745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19869, 2196.70142, 986.22638, 9.81750,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19869, 2196.71094, 991.50354, 9.81750,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(11489, 2156.22168, 985.84247, 9.79670,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(18647, 2158.05420, 986.23785, 11.69520,   0.00000, 0.00000, 121.00000);
	CreateDynamicObject(18647, 2159.76904, 987.26477, 11.69520,   0.00000, 0.00000, 121.00000);
	CreateDynamicObject(18651, 2154.36548, 986.26849, 11.69910,   0.00000, 0.00000, 60.00000);
	CreateDynamicObject(18651, 2152.65552, 987.25537, 11.69910,   0.00000, 0.00000, 60.00000);
	CreateDynamicObject(18648, 2177.58545, 986.28967, 11.69930,   0.00000, 0.00000, 60.00000);
	CreateDynamicObject(18648, 2175.86548, 987.27747, 11.69930,   0.00000, 0.00000, 60.00000);
	CreateDynamicObject(18649, 2181.33472, 986.28577, 11.70070,   0.00000, 0.00000, 121.00000);
	CreateDynamicObject(18649, 2182.99976, 987.28479, 11.70070,   0.00000, 0.00000, 121.00000);
	CreateDynamicObject(5837, 2173.22974, 1005.41089, 11.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(997, 2172.77686, 984.81958, 10.00000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(997, 2172.77368, 988.02692, 10.00000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(997, 2162.91479, 984.85773, 10.00000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(997, 2162.91333, 988.03833, 10.00000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3472, 1283.06226, -1390.18469, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1282.32141, -1411.03992, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1240.43872, -1411.15320, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1240.00305, -1390.09973, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1211.51135, -1411.13354, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1212.94836, -1388.52905, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1177.97498, -1411.21094, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1178.52600, -1390.04089, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1150.36194, -1389.99890, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1150.24719, -1411.14539, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1114.96545, -1411.14966, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1114.68689, -1390.04846, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1078.84131, -1390.40942, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1078.31226, -1411.47644, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1034.38989, -1411.33142, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1034.39832, -1389.92761, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1003.25592, -1389.92065, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1002.85754, -1411.16150, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 957.69641, -1411.12390, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 958.08002, -1390.06567, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 924.45837, -1388.35010, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 925.18073, -1412.34253, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 884.11908, -1411.39575, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 884.78857, -1389.80066, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 847.84680, -1389.75342, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 847.52887, -1411.43433, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 813.18878, -1411.34277, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 813.29230, -1389.96118, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 772.21179, -1389.94629, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 772.04004, -1411.24719, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 734.03827, -1411.17102, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 734.85608, -1389.62170, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 690.07520, -1389.69788, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 690.68500, -1411.11462, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 657.52252, -1410.99939, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 656.99023, -1389.53821, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1327.85107, -1389.97314, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1328.45679, -1411.44629, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1266.02332, -1368.01660, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1250.02051, -1368.08386, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1249.97339, -1323.03430, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1265.89355, -1322.54407, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1265.89282, -1292.55652, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1250.45789, -1292.60583, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1234.26099, -1286.23303, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1235.86011, -1275.52185, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1212.70496, -1288.18567, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1209.11572, -1273.71338, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1189.84937, -1310.34924, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1211.72107, -1309.77930, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1189.89526, -1348.00391, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1211.81348, -1347.53223, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1189.56604, -1386.36072, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1172.88745, -1286.32336, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1173.42627, -1275.43079, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1134.86414, -1286.23560, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1135.38586, -1275.32410, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1078.59021, -1286.26526, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1078.45386, -1275.35754, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1048.16003, -1304.91638, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1067.88477, -1306.12439, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1068.10168, -1344.42212, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1048.45349, -1343.89587, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1048.36230, -1380.98804, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1068.00244, -1380.71948, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1068.57910, -1272.05664, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1048.35571, -1272.62341, 12.42193,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1048.18152, -1232.61414, 15.71295,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1068.24438, -1233.21924, 15.71295,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1068.16467, -1181.17224, 21.09246,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1048.38196, -1182.90076, 20.80383,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1041.78650, -1155.09204, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1042.71399, -1135.11316, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 989.23578, -1135.08386, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 989.01398, -1155.09216, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 951.74677, -1155.16309, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 951.30133, -1135.26575, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 912.63965, -1135.40308, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 912.52856, -1154.50391, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 861.66504, -1154.80188, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 861.91266, -1135.38879, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 814.40509, -1135.01184, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 814.29797, -1154.29187, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 814.29797, -1154.29187, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1096.51721, -1155.15198, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1096.66455, -1135.37134, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1145.67175, -1135.36890, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1145.71448, -1154.89294, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1186.46057, -1155.06531, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1186.29236, -1135.19751, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1224.07678, -1155.60120, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1224.06909, -1135.51526, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1255.40771, -1134.69287, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1255.46606, -1154.93726, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1303.10999, -1155.18896, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1303.17261, -1135.34229, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1334.28394, -1155.46826, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1334.62744, -1134.84741, 22.81878,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(5153, 2075.82104, -1775.01208, 13.00000,   0.00000, 0.00000, 170.00000);
	CreateDynamicObject(5153, 2071.87451, -1774.30811, 14.75000,   0.00000, 0.00000, 170.00000);
	CreateDynamicObject(5153, 2070.93433, -1774.13342, 15.16500,   0.00000, 0.00000, 170.00000);
	CreateDynamicObject(16367, 2065.23999, -1785.86194, 17.34000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(13638, 2059.60767, -1796.89490, 19.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19433, 2053.96338, -1795.25427, 25.26000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19433, 2053.96582, -1791.75378, 25.26000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19433, 2053.96558, -1788.28088, 25.26000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19005, 2053.47729, -1772.97644, 28.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 2057.45313, -1754.49597, 34.69770,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 2054.01880, -1754.48950, 34.69770,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 2050.51733, -1754.49377, 34.69770,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 2050.52295, -1751.28296, 34.69770,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 2054.00513, -1751.27991, 34.69770,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 2057.44458, -1751.27637, 34.69770,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 2050.52148, -1748.07520, 34.69770,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 2054.00952, -1748.07385, 34.69770,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 2057.44165, -1748.06909, 34.69770,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 2057.65381, -1746.59424, 36.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 2054.46606, -1746.61902, 36.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 2051.28662, -1746.61902, 36.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 2050.38208, -1746.62903, 36.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18649, 2051.43677, -1746.70081, 36.21070,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18649, 2052.41479, -1746.72205, 37.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18649, 2052.41479, -1746.72205, 36.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18649, 2052.41479, -1746.72205, 35.22000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18649, 2055.17578, -1746.72522, 37.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18649, 2045.99634, -1762.65869, 36.21070,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18649, 2055.37793, -1746.73962, 36.52000,   40.00000, 0.00000, 270.00000);
	CreateDynamicObject(18649, 2055.07031, -1746.74146, 36.26200,   40.00000, 0.00000, 270.00000);
	CreateDynamicObject(18649, 2054.92139, -1746.69299, 35.31000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19687, 2071.39014, -1751.44629, 35.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19687, 23.39010, -1751.44629, 35.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19687, 2096.34814, -1751.43384, 35.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19687, 2121.34326, -1751.43848, 35.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19687, 2146.33276, -1751.43909, 35.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18649, 2054.70776, -1746.74231, 35.95800,   40.00000, 0.00000, 270.00000);
	CreateDynamicObject(19687, 2171.34888, -1751.50281, 35.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19652, 2182.95679, -1767.31165, 45.66000,   0.00000, 0.00000, 178.00000);
	CreateDynamicObject(19652, 2182.87402, -1767.27783, 65.70000,   0.00000, 0.00000, 178.00000);
	CreateDynamicObject(18840, 2205.52954, -1760.75464, 76.50000,   280.00000, 135.00000, 0.00000);
	CreateDynamicObject(13645, 2216.08350, -1782.93506, 68.10000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(13645, 2213.27979, -1782.97656, 68.10000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(13645, 2210.56860, -1783.04736, 68.10000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(13645, 2218.88110, -1782.86804, 68.10000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(18647, 2214.70410, -1782.85291, 68.00000,   160.00000, 0.00000, 0.00000);
	CreateDynamicObject(13645, 2216.08350, -1782.93506, 68.10000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(18647, 2213.30127, -1782.89575, 68.00000,   160.00000, 0.00000, 0.00000);
	CreateDynamicObject(18647, 2216.14478, -1782.86157, 68.00000,   160.00000, 0.00000, 0.00000);
	CreateDynamicObject(8171, 2323.06006, 526.20001, 0.95000,   0.00000, 0.00000, 89.30000);
	CreateDynamicObject(8171, 2322.60010, 486.53000, 0.92000,   0.00000, 0.00000, 89.30000);
	CreateDynamicObject(8171, 2321.67993, 450.41000, 1.02000,   0.00000, 0.00000, 89.30000);
	CreateDynamicObject(8171, 2321.77002, 411.79999, 1.13000,   0.00000, 0.00000, 89.30000);
	CreateDynamicObject(8171, 2410.71997, 483.35999, 0.93000,   0.00000, 0.00000, 178.75999);
	CreateDynamicObject(8171, 2449.42993, 481.41000, 0.91000,   0.00000, 0.00000, 177.98000);
	CreateDynamicObject(8171, 2440.36011, 565.65002, 0.92000,   0.00000, 0.00000, 269.14999);
	CreateDynamicObject(8171, 2436.87988, 393.63000, 0.86000,   0.00000, 0.00000, 269.12000);
	CreateDynamicObject(8171, 2487.41992, 476.29999, 0.99000,   -0.06000, 0.24000, 178.67999);
	CreateDynamicObject(8171, 2233.98999, 488.20999, 1.02000,   0.00000, 0.00000, 179.19000);
	CreateDynamicObject(8171, 2194.32007, 488.41000, 1.02000,   0.00000, 0.00000, 179.09000);
	CreateDynamicObject(8171, 2241.94995, 399.16000, 1.12000,   0.00000, 0.00000, 268.97000);
	CreateDynamicObject(8149, 2506.31006, 460.73001, 3.11000,   0.00000, 0.00000, 178.63000);
	CreateDynamicObject(8342, 2507.95996, 547.33002, 3.23000,   0.00000, 0.00000, 269.38000);
	CreateDynamicObject(987, 2435.95996, 565.94000, 2.71000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 2423.92993, 565.98999, 2.71000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 2423.94995, 565.97998, 7.76000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 2411.90991, 566.08002, 7.76000,   0.00000, 0.00000, 359.62000);
	CreateDynamicObject(987, 2399.94995, 566.16998, 7.76000,   0.00000, 0.00000, 359.62000);
	CreateDynamicObject(987, 2396.56006, 566.14001, 7.76000,   0.00000, 0.00000, 359.62000);
	CreateDynamicObject(8149, 2174.59009, 479.03000, 3.11000,   0.00000, 0.00000, 359.16000);
	CreateDynamicObject(19129, 2489.13257, -1672.98193, 12.33000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19129, 2489.11938, -1660.66382, 12.36000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19129, 2477.91821, -1660.70569, 12.35000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19129, 2478.02222, -1673.01172, 12.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19129, 2504.09204, -1672.98987, 12.33000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19129, 2506.64673, -1658.19971, 12.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8342, 2173.72998, 399.04999, 3.13000,   0.00000, 0.00000, 449.98001);
	CreateDynamicObject(987, 2245.89990, 380.57001, 0.14000,   0.00000, 0.00000, 177.45000);
	CreateDynamicObject(987, 2257.75000, 380.10999, 5.37000,   0.00000, 0.00000, 177.45000);
	CreateDynamicObject(987, 2245.89990, 380.57001, 0.14000,   0.00000, 0.00000, 177.45000);
	CreateDynamicObject(987, 2245.87988, 380.45001, 5.39000,   0.00000, 0.00000, 177.55000);
	CreateDynamicObject(987, 2176.02002, 559.97998, 5.92000,   0.00000, 0.00000, 353.10999);
	CreateDynamicObject(987, 2187.83008, 558.47998, 5.92000,   0.00000, 0.00000, 353.10999);
	CreateDynamicObject(987, 2199.75000, 557.04999, 5.92000,   0.00000, 0.00000, 356.82001);
	CreateDynamicObject(987, 2211.71997, 556.38000, 5.92000,   0.00000, 0.00000, 4.27000);
	CreateDynamicObject(987, 2223.68994, 557.22998, 5.92000,   0.00000, 0.00000, 7.51000);
	CreateDynamicObject(987, 2235.72998, 558.78003, 5.95000,   -1.26000, -2.73000, 86.89000);
	CreateDynamicObject(18825, 2307.25000, 482.84000, 5.97000,   89.94000, 3.66000, 81.70000);
	CreateDynamicObject(18825, 2340.31006, 500.51001, 6.50000,   268.32001, 177.24001, 83.71000);
	CreateDynamicObject(18827, 2420.66992, 472.10999, 7.15000,   0.00000, 0.00000, 88.26000);
	CreateDynamicObject(18831, 2360.31006, 478.12000, 7.10000,   89.16000, 38.58000, 7.18000);
	CreateDynamicObject(18841, 2479.57007, 470.81000, 22.90000,   -0.60000, 180.66000, 0.00000);
	CreateDynamicObject(18850, 2454.45996, 471.37000, 11.44000,   0.00000, 0.00000, 357.76001);
	CreateDynamicObject(18850, 2428.37988, 472.29999, 11.44000,   0.00000, 0.00000, 357.76001);
	CreateDynamicObject(18850, 2402.39990, 473.35999, 11.44000,   0.00000, 0.00000, 357.76001);
	CreateDynamicObject(18850, 2376.31006, 474.23001, 11.44000,   0.00000, 0.00000, 358.29999);
	CreateDynamicObject(18786, 2373.12012, 474.47000, 25.73000,   0.00000, 0.00000, 357.42999);
	CreateDynamicObject(18789, 2266.94995, 484.64001, 24.37000,   0.00000, 0.00000, 357.95999);
	CreateDynamicObject(18789, 2266.81006, 469.14999, 24.37000,   0.00000, 0.00000, 357.95999);
	CreateDynamicObject(18778, 2196.23999, 486.01999, 25.82000,   -6.36000, 0.54000, 88.47000);
	CreateDynamicObject(18824, 2172.12988, 461.01999, 30.35000,   -93.00000, 53.82000, 3.98000);
	CreateDynamicObject(18811, 2157.00000, 419.00000, 34.88000,   81.66000, -12.36000, 9.21000);
	CreateDynamicObject(18824, 2165.01001, 374.73001, 42.32000,   -101.64000, -45.00000, 351.67001);
	CreateDynamicObject(18815, 2204.31006, 364.94000, 12.97000,   0.00000, 0.00000, 2.84000);
	CreateDynamicObject(8397, 2490.37012, 550.26001, 8.27000,   0.00000, 0.00000, 87.36000);
	CreateDynamicObject(8397, 2489.66992, 521.69000, 8.08000,   0.00000, 0.00000, 87.36000);
	CreateDynamicObject(8397, 2488.60010, 491.85999, 8.08000,   0.00000, 0.00000, 87.36000);
	CreateDynamicObject(18778, 2404.37988, 515.78998, 1.39000,   1.26000, -0.66000, -91.62000);
	CreateDynamicObject(18788, 2425.57007, 515.40997, 9.24000,   0.34000, -23.16000, 358.50000);
	CreateDynamicObject(18783, 2453.51001, 512.38000, 15.73000,   -0.68000, -0.96000, 356.92001);
	CreateDynamicObject(18788, 2501.11011, 525.22998, 12.94000,   0.00000, 0.00000, 88.14000);
	CreateDynamicObject(18824, 2474.67993, 501.01999, 25.95000,   238.14000, 45.18000, -4.70000);
	CreateDynamicObject(7392, 2448.71997, 420.10999, 7.73000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7392, 2448.35010, 449.32001, 7.73000,   0.00000, 0.00000, 178.02000);
	CreateDynamicObject(7905, 2465.78003, 399.09000, 9.77000,   0.00000, 0.00000, 352.53000);
	CreateDynamicObject(1222, 2204.90991, 365.56000, 8.47000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7073, 2494.31006, 433.09000, 18.76000,   0.00000, 0.00000, 0.83000);
	CreateDynamicObject(19005, 2435.87988, 434.98001, 0.67000,   -10.38000, 0.24000, 269.60001);
	CreateDynamicObject(18750, 2340.97998, 610.47998, 27.17000,   78.96000, 0.12000, 359.59000);
	CreateDynamicObject(11470, 2240.27002, 552.50000, 10.40000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11470, 2240.34009, 563.89001, 10.40000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11470, 2392.79004, 552.39001, 10.40000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11470, 2392.68994, 562.97998, 10.40000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11470, 2221.02002, 498.82999, 4.13000,   0.00000, 0.00000, -91.92000);
	CreateDynamicObject(11470, 2232.32007, 498.62000, 3.97000,   0.00000, 0.00000, -91.92000);
	CreateDynamicObject(3374, 2220.20996, 504.29001, 2.39000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 2224.94995, 504.26001, 2.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 2230.17993, 504.20999, 2.29000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 2235.12012, 504.12000, 2.55000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 2235.43994, 494.32001, 2.38000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 2230.28003, 494.26999, 2.49000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 2225.62012, 494.23001, 2.59000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 2220.72998, 494.32999, 2.48000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18778, 2228.66992, 516.83002, 2.37000,   0.00000, 0.00000, 182.81000);
	CreateDynamicObject(18778, 2226.75000, 481.45001, 2.41000,   0.00000, 0.00000, 359.76001);
	CreateDynamicObject(1222, 2203.11011, 363.98999, 8.47000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1222, 2200.94995, 365.56000, 8.47000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1222, 2202.45996, 367.26001, 8.47000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, 2197.51001, 421.78000, 0.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, 2213.88989, 422.62000, -0.02000,   0.00000, 0.00000, 0.72000);
	CreateDynamicObject(645, 2224.92993, 422.41000, -0.02000,   0.00000, 0.00000, 0.72000);
	CreateDynamicObject(645, 2236.02002, 422.79999, -0.02000,   0.00000, 0.00000, 0.72000);
	CreateDynamicObject(645, 2245.96997, 422.01999, -0.02000,   0.00000, 0.00000, 0.72000);
	CreateDynamicObject(645, 2196.62012, 437.48999, 0.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, 2196.77002, 453.06000, 0.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, 2196.77002, 465.60001, 0.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, 2196.81006, 477.76999, 0.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, 2196.80005, 488.06000, 0.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, 2196.69995, 499.23999, 0.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, 2196.72998, 510.73999, 0.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, 2196.75000, 510.75000, 0.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, 2197.12012, 521.69000, 0.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, 2197.71997, 534.22998, 0.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, 2198.13989, 545.16998, 0.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8040, 3388.27832, -2067.04492, 45.94532,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18450, 3467.65649, -2067.42139, 44.81237,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18450, 3547.53662, -2067.43604, 44.81237,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3458, 3607.01855, -2065.39014, 42.60728,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(3458, 3607.00854, -2069.91943, 42.60728,   88.19473, 0.00116, 179.94354);
	CreateDynamicObject(18450, 3658.72070, -2067.71875, 43.68730,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8947, 3704.18457, -2071.73828, 40.92646,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18789, 3704.54956, -2149.09912, 43.60109,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18789, 3704.55103, -2298.77393, 43.60109,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18794, 3704.52759, -2385.62451, 42.96986,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(18794, 3704.50684, -2417.16064, 51.09491,   0.00000, 345.50000, 270.00000);
	CreateDynamicObject(18794, 3704.49390, -2445.89429, 67.34492,   0.00000, 329.99805, 270.00000);
	CreateDynamicObject(18794, 3704.47998, -2468.80371, 91.07492,   0.00000, 311.99640, 270.00000);
	CreateDynamicObject(18794, 3704.46460, -2474.15112, 97.32492,   0.00000, 298.99518, 270.00000);
	CreateDynamicObject(18806, 4573.21387, -2379.23828, 39.17690,   0.00000, 190.00000, 352.00000);
	CreateDynamicObject(13593, 894.91528, -1564.33838, 135255.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19633, 1350.35205, -1400.22009, 12.29622,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 1312.67737, -1369.62170, 17.27900,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18648, 1310.69299, -1369.62085, 17.27900,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18648, 1308.85657, -1369.62305, 17.27900,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18648, 1307.70129, -1369.62329, 17.27900,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3472, 1316.13757, -1370.08398, 12.78796,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1316.01514, -1377.50574, 12.78796,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1315.89929, -1384.87646, 12.78796,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1305.42065, -1370.24878, 12.54649,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1305.26294, -1377.56787, 12.54649,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 1305.09998, -1384.90662, 12.54649,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1280, 1316.27747, -1373.51135, 13.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1280, 1316.12122, -1381.78833, 13.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1280, 1305.03455, -1373.77673, 13.00000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1280, 1305.07727, -1381.23730, 13.10000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(640, 1315.49255, -1367.88269, 13.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(640, 1304.84094, -1367.93115, 13.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18647, 1313.78650, -1368.26147, 12.55430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18647, 1315.75720, -1368.25708, 12.55430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18647, 1317.14905, -1368.26990, 12.57430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18647, 1306.52563, -1368.31433, 12.57430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18647, 1304.54041, -1368.31946, 12.57430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18647, 1303.11902, -1368.31665, 12.57430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18651, 1313.07080, -1366.81091, 13.57820,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18651, 1313.07080, -1366.81091, 15.57820,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18651, 1313.07080, -1366.81091, 16.57820,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18651, 1307.19910, -1366.86353, 13.57820,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18651, 1307.19910, -1366.86353, 15.57820,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18651, 1307.19910, -1366.86353, 16.57820,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(18794, 3704.58496, -2495.48779, 12.24307,   0.00000, 344.00000, 270.00000);
	CreateDynamicObject(18794, 3704.58496, -2495.48730, 12.24307,   0.00000, 352.24841, 270.00000);
	CreateDynamicObject(18794, 3704.63110, -2467.85962, 8.39307,   0.00000, 8.49365, 270.00000);
	CreateDynamicObject(19633, 632.32904, -1400.01978, 12.29149,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19076, 2290.66138, -1528.37695, 25.85921,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19076, 2317.05469, -1527.43982, 24.33318,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19056, 2291.01294, -1525.54443, 26.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19056, 2288.01099, -1528.14063, 26.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19056, 2290.82202, -1530.94287, 26.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19056, 2293.21313, -1528.16089, 26.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19056, 2316.72217, -1530.07837, 24.90000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19056, 2319.30591, -1527.62781, 24.90000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19056, 2314.20703, -1527.76074, 24.90000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19056, 2316.96411, -1524.96570, 24.90000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19128, 2316.76221, -1527.51746, 24.33520,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19128, 2290.61646, -1528.25195, 25.86980,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19005, 2315.50024, -1885.83826, 12.36716,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 2309.26416, -1890.95874, 12.41914,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 2312.70557, -1890.96106, 12.41914,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 2321.57959, -1890.43689, 12.59100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 2316.37134, -1891.02490, 12.41914,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19799, 2090.40063, -1530.73486, 171294.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19005, 2092.92700, -1558.44641, 12.10489,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 2097.41748, -1563.69971, 12.14191,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18648, 2087.46094, -1563.63123, 12.14191,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1257, 1535.70459, -1650.07629, 13.76460,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14467, 1546.67603, -1680.38416, 15.31480,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(14467, 1546.68152, -1671.42993, 15.31480,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(18648, 1547.02026, -1681.05347, 12.55550,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18648, 1547.00854, -1679.15173, 12.55550,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18648, 1547.02515, -1672.06104, 12.55550,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18648, 1547.03833, -1670.20447, 12.55550,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18794, 3704.59717, -2472.27979, 8.31807,   0.00000, 4.74243, 270.00000);
	CreateDynamicObject(18794, 3877.41382, -2279.43677, 16.12997,   0.00000, 17.99243, 172.00000);
	CreateDynamicObject(18789, 3704.42554, -2320.11572, 15.61900,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(8947, 3704.84131, -2238.51929, 12.86391,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18789, 3786.96509, -2237.66455, 15.56900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18801, 3858.31055, -2247.46289, 38.66761,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18801, 3859.37158, -2267.18530, 38.66761,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18794, 3704.62012, -2449.07129, 10.39307,   0.00000, 18.98987, 270.00000);
	CreateDynamicObject(18794, 3910.23511, -2284.06763, 27.21495,   0.00000, 33.74014, 171.99646);
	CreateDynamicObject(18794, 3939.23389, -2288.13574, 47.61497,   0.00000, 50.48901, 171.99646);
	CreateDynamicObject(8357, 4142.92725, -2317.73560, 49.47150,   0.00000, 0.00000, 82.00000);
	CreateDynamicObject(8392, 4098.42822, -2275.45654, 23.63800,   0.00000, 0.00000, 352.00000);
	CreateDynamicObject(8392, 4098.42773, -2275.45605, 77.62799,   0.00000, 0.00000, 351.99646);
	CreateDynamicObject(8392, 4085.07324, -2344.04102, 23.63800,   0.00000, 0.00000, 351.99646);
	CreateDynamicObject(8392, 4548.79346, -2354.23877, -7.74830,   0.00000, 90.00000, 169.99646);
	CreateDynamicObject(8392, 4096.56885, -2289.49219, 110.06799,   36.00000, 0.00000, 351.99646);
	CreateDynamicObject(8392, 4090.54761, -2326.90405, 110.77798,   328.00000, 0.00000, 351.99646);
	CreateDynamicObject(18789, 4321.17773, -2343.75342, 49.06838,   0.00000, 0.00000, 352.00000);
	CreateDynamicObject(18779, 4411.79199, -2350.37988, 59.22931,   0.00000, 0.00000, 171.99646);
	CreateDynamicObject(8392, 4085.07324, -2344.04102, 78.58799,   0.00000, 0.00000, 351.99646);
	CreateDynamicObject(8392, 4542.96240, -2398.30371, -7.74830,   0.00000, 90.00000, 169.99146);
	CreateDynamicObject(18806, 3704.49512, -2510.11621, 53.08065,   0.00000, 239.99634, 90.00000);
	CreateDynamicObject(18789, 4759.30713, -2405.75391, 25.43112,   0.00000, 0.00000, 352.00000);
	CreateDynamicObject(18789, 4907.69531, -2426.63550, 25.43112,   0.00000, 0.00000, 351.99646);
	CreateDynamicObject(18450, 4973.84766, -2431.54688, 25.89305,   23.24561, 0.00000, 351.99646);
	CreateDynamicObject(18450, 4973.98096, -2430.55518, 26.49304,   34.74158, 0.00000, 351.99097);
	CreateDynamicObject(18450, 4974.34668, -2429.42676, 27.49305,   50.48877, 0.00000, 351.99097);
	CreateDynamicObject(18450, 4974.38330, -2428.80420, 28.34303,   67.48767, 0.00000, 351.99097);
	CreateDynamicObject(18450, 4974.40771, -2428.38037, 29.69301,   80.73352, 0.00000, 351.99097);
	CreateDynamicObject(18450, 4974.40820, -2428.27783, 31.99301,   90.00000, 0.00000, 351.99097);
	CreateDynamicObject(18450, 4973.11035, -2435.77539, 25.41804,   0.00000, 0.00000, 351.99097);
	CreateDynamicObject(18450, 5081.19629, -2446.65723, 25.41804,   0.00000, 0.00000, 351.99097);
	CreateDynamicObject(18450, 5160.35059, -2457.78027, 25.41804,   0.00000, 0.00000, 351.99097);
	CreateDynamicObject(8947, 5204.97754, -2468.38574, 22.68958,   0.00000, 0.00000, 352.00000);
	CreateDynamicObject(3510, 5202.11914, -2456.20557, 25.74312,   0.00000, 0.00000, 112.00000);
	CreateDynamicObject(3510, 5207.44238, -2457.05444, 25.74312,   0.00000, 0.00000, 111.99463);
	CreateDynamicObject(3510, 5213.45166, -2458.33203, 25.74312,   0.00000, 0.00000, 111.99463);
	CreateDynamicObject(3510, 5212.54004, -2463.63989, 25.74312,   0.00000, 0.00000, 111.99463);
	CreateDynamicObject(3510, 5211.49414, -2469.17310, 25.74312,   0.00000, 0.00000, 111.99463);
	CreateDynamicObject(3510, 5210.71143, -2474.12085, 25.74312,   0.00000, 0.00000, 111.99463);
	CreateDynamicObject(3510, 5209.72412, -2480.56299, 25.74312,   0.00000, 0.00000, 111.99463);
	CreateDynamicObject(18789, 5194.79590, -2545.70483, 25.35828,   0.00000, 0.00000, 81.99646);
	CreateDynamicObject(8947, 5184.43848, -2622.57031, 22.68958,   0.00000, 0.00000, 351.99646);
	CreateDynamicObject(18789, 5253.23486, -2636.32617, 64.94826,   0.00000, 328.00000, 351.99646);
	CreateDynamicObject(8947, 5320.52734, -2655.07642, 105.29486,   0.00000, 326.25000, 351.74646);
	CreateDynamicObject(3510, 5326.50879, -2644.20215, 111.87949,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3510, 5312.37842, -2652.78296, 104.38219,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3510, 5324.75488, -2654.88770, 111.74463,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3510, 5322.83008, -2667.30371, 111.66290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18779, 5171.10742, -2646.47852, 25.24247,   0.00000, 324.25000, 351.99646);
	CreateDynamicObject(18779, 5143.00146, -2642.51514, 36.34247,   0.00000, 14.24502, 351.99097);
	CreateDynamicObject(18779, 5134.57715, -2641.29907, 62.22247,   0.00000, 64.24377, 351.99097);
	CreateDynamicObject(18789, 5168.49121, -2643.22363, 75.73827,   0.00000, 0.00000, 81.99646);
	CreateDynamicObject(18789, 5174.66113, -2644.86621, 83.08827,   270.00000, 0.00000, 81.99646);
	CreateDynamicObject(18789, 5174.66113, -2644.86621, 97.82827,   269.99451, 0.00000, 81.99646);
	CreateDynamicObject(18789, 5174.66113, -2644.86621, 113.03827,   269.99451, 0.00000, 81.99646);
	CreateDynamicObject(8947, 5180.30469, -2560.73047, 72.93259,   0.00000, 0.00000, 351.99097);
	CreateDynamicObject(8947, 5155.73584, -2728.01318, 72.98260,   0.00000, 0.00000, 351.99646);
	CreateDynamicObject(18789, 5250.99316, -2651.72852, 64.94826,   0.00000, 327.99683, 351.99097);
	CreateDynamicObject(18789, 5237.20703, -2735.98730, 75.68836,   0.00000, 0.00000, 171.99646);
	CreateDynamicObject(18789, 5261.09619, -2574.67896, 75.63836,   0.00000, 0.00000, 171.99646);
	CreateDynamicObject(8947, 5317.72314, -2742.68164, 72.98260,   0.00000, 0.00000, 351.99097);
	CreateDynamicObject(8947, 5339.02295, -2590.14331, 72.90759,   0.00000, 0.00000, 351.99097);
	CreateDynamicObject(18789, 5328.83838, -2665.47705, 75.68827,   0.00000, 0.00000, 81.99646);
	CreateDynamicObject(3510, 5325.62988, -2650.91113, 111.74463,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3510, 5326.23926, -2647.42676, 111.74463,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3510, 5324.63770, -2658.63770, 111.74463,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3510, 5323.73926, -2663.36426, 111.74463,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3510, 5324.30957, -2661.12988, 111.74463,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3510, 5316.96436, -2642.48315, 104.70451,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3510, 5319.84668, -2643.31738, 106.45451,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3510, 5322.62793, -2643.60229, 108.20451,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3510, 5324.73096, -2643.79590, 110.25449,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3510, 5321.08398, -2667.06372, 109.85447,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3510, 5318.87891, -2666.66626, 108.77940,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3510, 5316.58838, -2666.39258, 107.02939,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3510, 5314.33447, -2666.05347, 105.00426,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8947, 5337.27295, -2661.59326, 73.90759,   0.00000, 344.50000, 351.99097);
	CreateDynamicObject(18789, 5417.46680, -2673.57178, 78.38853,   0.00000, 0.00000, 171.99646);
	CreateDynamicObject(18789, 5556.98096, -2693.23950, 43.21342,   0.00000, 332.00000, 171.99646);
	CreateDynamicObject(18789, 5688.56592, -2711.74023, 12.44854,   0.00000, 0.00000, 171.99646);
	CreateDynamicObject(18789, 5987.01123, -2854.47656, 27.87119,   0.00000, 0.00000, 95.99646);
	CreateDynamicObject(18450, 5950.04346, -2748.48242, 12.43548,   0.00000, 0.00000, 351.99097);
	CreateDynamicObject(18450, 5949.83105, -2750.01904, 12.56048,   347.75000, 0.00000, 351.99097);
	CreateDynamicObject(18450, 5949.71143, -2750.88159, 12.83547,   339.74472, 0.00000, 351.99097);
	CreateDynamicObject(18450, 5949.59473, -2751.71924, 13.21047,   327.74118, 0.00000, 351.99097);
	CreateDynamicObject(18450, 5949.45801, -2752.70508, 14.03545,   309.98862, 0.00000, 351.99097);
	CreateDynamicObject(18450, 5949.34521, -2753.51880, 15.31044,   293.98474, 0.00000, 351.99097);
	CreateDynamicObject(18450, 5949.29346, -2753.88843, 16.36042,   278.73325, 0.00000, 351.99097);
	CreateDynamicObject(18450, 5949.29297, -2753.88770, 20.11042,   270.00000, 180.00000, 171.99097);
	CreateDynamicObject(6342, 6020.42627, -2754.59106, 8.00000,   0.00000, 0.00000, 148.00000);
	CreateDynamicObject(18450, 5949.34473, -2753.51855, 15.63543,   287.73315, 0.00000, 351.99097);
	CreateDynamicObject(6342, 6074.91162, -2704.26953, 8.00000,   0.00000, 0.00000, 191.99683);
	CreateDynamicObject(6342, 6081.01660, -2633.84253, 8.00000,   0.00000, 0.00000, 231.99158);
	CreateDynamicObject(18789, 6016.54297, -2551.62598, 6.19854,   0.00000, 0.00000, 125.99646);
	CreateDynamicObject(8947, 5972.77832, -2482.65698, 3.44507,   0.00000, 0.00000, 303.99097);
	CreateDynamicObject(18789, 6029.47070, -2539.44434, 23.14854,   0.00000, 13.00000, 127.99121);
	CreateDynamicObject(8947, 5979.16357, -2478.31616, 3.42007,   0.00000, 0.00000, 303.98621);
	CreateDynamicObject(6342, 6105.03467, -2630.31519, 24.38000,   0.00000, 0.00000, 231.98730);
	CreateDynamicObject(6342, 6104.84619, -2630.14966, 55.92999,   0.00000, 0.00000, 231.98730);
	CreateDynamicObject(18789, 5836.80664, -2732.57617, 12.44854,   0.00000, 0.00000, 171.99646);
	CreateDynamicObject(18789, 5987.33594, -2857.45264, 19.34120,   0.00000, 7.50000, 95.99304);
	CreateDynamicObject(18789, 5988.73047, -2870.67627, 13.34120,   0.00000, 14.74817, 95.98755);
	CreateDynamicObject(8040, 6002.57666, -3016.53638, 26.77732,   0.00000, 0.00000, 96.00000);
	CreateDynamicObject(7584, 3688.58667, -2582.18457, 48.63445,   0.00000, 0.00000, 332.00000);
	CreateDynamicObject(7584, 3688.59082, -2582.23438, 138.22452,   0.00000, 0.00000, 331.99585);
	CreateDynamicObject(8391, 3723.80420, -2248.04224, 16.04193,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(8391, 3749.38086, -2272.90771, 16.04193,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(4002, 4301.29102, -2295.28955, 34.36288,   0.00000, 0.00000, 312.00000);
	CreateDynamicObject(4002, 4297.62207, -2387.87915, 34.36288,   0.00000, 0.00000, 215.99524);
	CreateDynamicObject(3781, 4757.56885, -2363.29614, 12.73010,   0.00000, 0.00000, 80.00000);
	CreateDynamicObject(3781, 4756.73047, -2443.11450, 8.44337,   0.00000, 0.00000, 179.99695);
	CreateDynamicObject(3458, 5192.07910, -2636.18579, 28.79179,   284.13931, 277.96814, 270.21365);
	CreateDynamicObject(8392, 5730.20166, -2691.74097, 4.26000,   0.00000, 0.00000, 354.00000);
	CreateDynamicObject(8392, 5720.83594, -2738.55688, 4.26000,   0.00000, 0.00000, 353.99597);
	CreateDynamicObject(18749, -1393.17773, -281.59961, 25.10567,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18750, -1398.37622, -281.46249, 43.45081,   83.99997, 179.99957, 308.99973);
	CreateDynamicObject(18728, -1359.21863, -312.98322, 24.48750,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18728, -1368.67651, -303.33472, 24.48750,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18728, -1388.86829, -272.74783, 26.84572,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18728, -1403.24182, -257.97861, 24.48750,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18728, -1420.65051, -241.72417, 24.48750,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18653, -1344.90430, -303.33243, 24.43750,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18655, -1418.38269, -230.86688, 24.43750,   0.00000, 0.00000, 278.00000);
	CreateDynamicObject(18657, -1343.91650, -303.61371, 26.37810,   14.00000, 0.00000, 66.00000);
	CreateDynamicObject(1337, -1415.88770, -231.90918, 31.93445,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18658, -1418.84521, -229.58826, 26.62654,   14.00000, 0.00000, 202.00000);
	CreateDynamicObject(18655, -1404.36621, -240.20020, 18.62762,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18655, -1398.40771, -232.26842, 13.14844,   0.00000, 0.00000, 170.00000);
	CreateDynamicObject(18653, -1391.61292, -238.86275, 13.14844,   0.00000, 0.00000, 313.25000);
	CreateDynamicObject(18648, -1394.09778, -236.17444, 13.17188,   0.00000, 0.00000, 42.00000);
	CreateDynamicObject(18649, -1395.98120, -234.02924, 13.17188,   0.00000, 0.00000, 38.00000);
	CreateDynamicObject(18651, -1391.23804, -236.19305, 13.17188,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 366.60660, -2550.26636, 30512.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19550, 360.42679, -2550.58154, 1.01530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19550, 360.38541, -2425.58301, 1.01530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 299.55750, -2363.25952, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 302.75732, -2363.27832, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 305.93213, -2363.25977, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 309.12085, -2363.25757, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 312.32761, -2363.25757, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 315.51535, -2363.25977, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 318.71140, -2363.25659, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 321.92279, -2363.25708, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 325.08151, -2363.25586, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 328.20657, -2363.25366, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 331.38974, -2363.25366, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 334.56155, -2363.25562, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 337.74075, -2363.25952, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 340.93655, -2363.25684, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 344.11115, -2363.26099, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 347.29199, -2363.26050, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 350.44318, -2363.25342, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 353.61575, -2363.25293, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 356.78375, -2363.25000, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 359.97696, -2363.24585, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 363.11002, -2363.23853, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 366.28400, -2363.24194, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 369.44507, -2363.24438, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 372.62134, -2363.23779, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 375.82822, -2363.25220, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 379.00858, -2363.23853, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 382.20599, -2363.23071, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 385.35648, -2363.23584, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 388.54309, -2363.23120, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 391.70444, -2363.22949, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 394.90375, -2363.22314, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 398.07684, -2363.21948, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 401.26129, -2363.22119, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 404.44064, -2363.22925, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 407.62125, -2363.21045, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 410.84375, -2363.21460, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 414.02097, -2363.21387, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 417.22565, -2363.21387, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 420.43387, -2363.22412, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 299.55429, 2.70000, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 299.55750, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 302.75650, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 305.93210, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 309.12079, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 312.32761, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 315.51541, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 318.71140, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 321.92279, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 325.08151, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 328.18661, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 331.38971, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 334.56161, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 337.74081, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 340.93661, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 344.11111, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 347.29199, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 350.44321, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 353.61581, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 356.78381, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 359.97699, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 363.10999, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 366.28400, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 369.44510, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 372.62131, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 375.82739, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 379.00861, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 382.20599, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 385.35651, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 388.54309, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 391.70441, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 394.90369, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 398.07681, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 401.26129, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 404.43979, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 407.64120, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 410.84381, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 414.02100, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 417.22559, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 420.43301, -2613.03125, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 297.99033, -2611.37061, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 298.04016, -2608.15283, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.96817, -2605.00049, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95544, -2601.80786, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94571, -2598.61646, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95792, -2595.46704, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93811, -2592.26831, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93451, -2589.10938, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93576, -2585.95850, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93744, -2582.77466, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93887, -2579.59106, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93942, -2576.43750, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93311, -2573.27734, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93677, -2570.13281, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.91000, -2566.95581, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93036, -2563.82251, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.92386, -2560.65942, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.92874, -2557.49683, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.92715, -2554.30371, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.91531, -2551.11621, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.92010, -2547.92749, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93866, -2544.72900, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.92529, -2541.57202, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93906, -2538.42847, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93259, -2535.26343, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93460, -2532.07324, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93164, -2528.88159, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95197, -2525.70703, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95889, -2522.50977, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93243, -2519.32324, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93130, -2516.14038, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93307, -2512.93408, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93237, -2509.70093, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94061, -2506.51563, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94214, -2503.37280, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94272, -2500.15552, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93948, -2497.01392, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.96649, -2493.84619, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94196, -2490.74487, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.91357, -2487.52197, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93866, -2484.37695, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93570, -2481.18408, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93250, -2478.02271, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93234, -2474.81665, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93622, -2471.61646, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94360, -2468.45093, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94403, -2465.24756, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93649, -2462.09521, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94049, -2458.93262, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94077, -2455.72583, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94815, -2452.58716, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95349, -2449.43872, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95282, -2446.30835, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95544, -2443.12036, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95984, -2440.02563, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95859, -2436.93433, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95636, -2433.83472, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95667, -2430.74463, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95099, -2427.56812, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94681, -2424.37036, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93866, -2421.18042, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94467, -2418.07275, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95035, -2414.86792, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94357, -2411.68408, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94611, -2408.54980, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94446, -2405.34839, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94855, -2402.14478, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93985, -2399.01025, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94357, -2395.82227, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95859, -2392.64526, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93253, -2389.46704, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93906, -2386.25781, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94189, -2383.08789, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93903, -2379.92407, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94934, -2376.75220, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95712, -2373.61938, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95963, -2370.50610, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93451, -2364.74219, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, -2611.50122, 2.70000, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.99030, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 298.00119, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.96820, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95541, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94571, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93689, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93811, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93451, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93579, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93741, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93890, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93939, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93311, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93680, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.92999, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93039, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.92389, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.92871, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.92719, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.91531, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.92010, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.92068, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.92529, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93909, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93259, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93460, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93161, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93201, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93890, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93240, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93130, 422.04669, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93311, -2512.93408, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2611.37061, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2608.17480, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2605.00049, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2601.80786, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2598.61646, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2595.44800, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2592.26831, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2589.10938, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2585.95850, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2582.77466, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2579.59106, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2576.43750, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2573.27734, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2570.13281, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2566.95581, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.83282, -2563.82275, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85248, -2560.63940, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2557.49683, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2554.30371, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2551.11621, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2547.92749, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2544.77002, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2541.57202, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2538.42847, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2535.26343, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2532.07324, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2528.88159, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85309, -2525.72803, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.83282, -2522.51099, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2519.32324, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2516.14038, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2512.93408, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2509.72095, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85254, -2506.49561, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2503.35278, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2500.15552, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2497.01392, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85309, -2493.88696, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2490.72485, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2487.52197, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2484.37695, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.83282, -2481.18433, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2478.02271, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2474.81665, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2471.61646, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2468.45093, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2465.24756, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2462.09521, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2458.93262, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2455.72583, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2452.58716, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85400, -2449.45874, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2446.30835, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2443.12036, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2440.02563, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2436.93433, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2433.83472, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2430.74463, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2427.56812, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2424.37036, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2421.20044, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2418.05273, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2414.86792, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2411.68408, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2408.54980, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2405.34839, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2402.14478, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2399.01025, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2395.82227, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2392.64526, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2389.46704, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2386.25781, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.83286, -2383.08911, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2379.92407, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2376.75220, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.83286, -2373.62061, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2370.50610, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2367.32153, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2364.74219, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2364.74219, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2367.32153, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2370.50610, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.83289, -2373.62061, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2376.75220, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2379.92407, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.83289, -2383.08911, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2386.25781, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2389.46704, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2392.64526, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2395.82227, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2402.14478, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2399.01025, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2405.34839, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2408.54980, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2411.68408, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2414.86792, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2418.05273, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2421.20044, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2424.37036, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2427.56812, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2430.74463, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2433.83472, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2436.93433, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2440.02563, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2443.12036, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2446.30835, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85400, -2449.45874, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2452.58716, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2455.72583, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2458.93262, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2462.09521, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2465.24756, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2468.45093, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2471.61646, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2474.81665, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2478.02271, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.83279, -2481.18433, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2484.37695, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2487.52197, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2490.72485, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85309, -2493.88696, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2497.01392, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2500.15552, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2503.35278, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85251, -2506.49561, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2509.72095, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2512.93408, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2516.14038, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2519.32324, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2525.70801, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.83279, -2522.51099, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2528.88159, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2532.07324, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2535.26343, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2538.42847, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2541.57202, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2544.77002, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2547.92749, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2551.11621, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2554.30371, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2557.49683, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85251, -2560.63940, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.83279, -2563.82275, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2566.95581, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2570.13281, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2573.27734, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2576.43750, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2579.59106, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2582.77466, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2585.95850, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2589.10938, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2595.44800, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2592.26831, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2598.61646, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2601.80786, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2605.00049, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2608.17480, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 421.85281, -2611.37061, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 420.43301, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 417.22559, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 414.02100, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 410.84381, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 407.64120, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 404.43979, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 401.26129, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 398.07681, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 394.90369, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 391.70441, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 388.54309, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 385.35651, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 382.20599, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 375.82739, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 379.00861, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 372.62131, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 369.44510, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 366.28400, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 359.97699, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 363.10999, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 356.78381, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 353.61581, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 350.44321, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 347.29199, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 344.11111, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 340.93661, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 337.73505, -2613.03882, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 334.56161, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 331.38971, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 328.18661, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 325.08151, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 321.92279, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 318.71140, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 315.51541, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 312.32761, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 309.12079, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 305.93210, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 302.75650, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 299.55750, -2613.03125, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 297.99030, -2611.37061, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 298.04019, -2608.15283, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.96820, -2605.00049, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95541, -2601.80786, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94571, -2598.61646, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95789, -2595.46704, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93811, -2592.26831, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93451, -2589.10938, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93579, -2585.95850, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93741, -2582.77466, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93890, -2579.59106, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93939, -2576.43750, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93311, -2573.27734, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93680, -2570.13281, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.91000, -2566.95581, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93039, -2563.82251, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.92389, -2560.65942, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.92871, -2557.49683, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.92719, -2554.30371, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.91531, -2551.11621, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.92010, -2547.92749, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93869, -2544.72900, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.92529, -2541.57202, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93909, -2538.42847, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93259, -2535.26343, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93460, -2532.07324, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93161, -2528.88159, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95200, -2525.70703, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95889, -2522.50977, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93240, -2519.32324, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93130, -2516.14038, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93311, -2512.93408, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93240, -2509.70093, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94061, -2506.51563, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94211, -2503.37280, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94269, -2500.15552, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93951, -2497.01392, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.96649, -2493.84619, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94199, -2490.74487, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.91360, -2487.52197, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93570, -2481.18408, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93869, -2484.37695, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93250, -2478.02271, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93231, -2474.81665, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94360, -2468.45093, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93619, -2471.61646, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94400, -2465.24756, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93649, -2462.09521, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94049, -2458.93262, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94080, -2455.72583, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94821, -2452.58716, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95349, -2449.43872, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95541, -2443.12036, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95279, -2446.30835, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95981, -2440.02563, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95859, -2436.93433, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95639, -2433.83472, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95670, -2430.74463, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95099, -2427.56812, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94681, -2424.37036, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93869, -2421.18042, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94470, -2418.07275, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95029, -2414.86792, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94360, -2411.68408, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94611, -2408.54980, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94449, -2405.34839, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94849, -2402.14478, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93979, -2399.01025, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94360, -2395.82227, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95859, -2392.64526, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93250, -2389.46704, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93909, -2386.25781, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94189, -2383.08789, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93900, -2379.92407, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.94931, -2376.75220, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95709, -2373.61938, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95959, -2370.50610, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.95361, -2367.32153, 6.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 299.55750, -2363.25952, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 302.75729, -2363.27832, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 305.93210, -2363.25977, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 309.12079, -2363.25757, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 312.32761, -2363.25757, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 318.71140, -2363.25659, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 315.51541, -2363.25977, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 321.92279, -2363.25708, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 325.08151, -2363.25586, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 328.20660, -2363.25366, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 331.38971, -2363.25366, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 334.56161, -2363.25562, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 337.74081, -2363.25952, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 344.11111, -2363.26099, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 340.93661, -2363.25684, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 350.44321, -2363.25342, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 347.29199, -2363.26050, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 353.61581, -2363.25293, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 356.78381, -2363.25000, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 359.97699, -2363.24585, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 363.10999, -2363.23853, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 366.28400, -2363.24194, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 369.44510, -2363.24438, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 372.62131, -2363.23779, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 375.82819, -2363.25220, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 379.00861, -2363.23853, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 382.20599, -2363.23071, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 385.35651, -2363.23584, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 391.70441, -2363.22949, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 388.54309, -2363.23120, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 394.90369, -2363.22314, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 401.26129, -2363.22119, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 398.07681, -2363.21948, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 404.44061, -2363.22925, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 407.62119, -2363.21045, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 410.84381, -2363.21460, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 414.02100, -2363.21387, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 417.22559, -2363.21387, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 420.43390, -2363.22412, 6.20000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 420.16473, -2396.55835, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 417.02798, -2396.56421, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 420.15790, -2391.19092, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 416.97714, -2391.19336, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 420.02576, -2395.04077, 4.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 417.19492, -2395.04297, 4.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 417.19324, -2392.71216, 4.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 420.68265, -2392.71265, 4.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 297.95364, -2367.32153, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 297.93451, -2364.74219, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 299.59592, -2458.44385, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 302.76532, -2458.44116, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 299.62625, -2453.97168, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 302.79877, -2453.96313, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 302.60828, -2456.92603, 4.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 302.59607, -2455.50049, 4.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 299.09622, -2455.49536, 4.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 299.11752, -2456.93481, 4.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 315.74191, -2611.33984, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 315.74332, -2608.15137, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 320.75064, -2611.34741, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 320.75113, -2608.16284, 2.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 317.41235, -2608.15161, 4.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 319.01416, -2608.15332, 4.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 319.01236, -2611.35815, 4.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 317.40515, -2611.34570, 4.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 420.17349, -2590.73755, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 417.02417, -2590.74170, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 420.15918, -2595.14819, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 417.06516, -2595.14893, 2.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 417.16913, -2592.25415, 4.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 417.17645, -2593.58398, 4.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 420.65695, -2593.57471, 4.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19366, 420.66592, -2592.24683, 4.50000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(847, 385.76120, -2601.45166, 3.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(847, 386.36993, -2532.92334, 3.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(847, 331.73605, -2455.16357, 3.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(847, 385.42618, -2384.03882, 3.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1303, 345.97681, -2531.21777, 1.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1303, 320.42026, -2573.72192, 1.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1303, 355.65112, -2455.74341, 1.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1303, 321.23785, -2402.87988, 1.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(899, 358.99789, -2498.80103, 0.91079,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(17029, 377.83609, -2419.72705, -1.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19966, 316.23712, -2606.76294, 1.01170,   0.00000, 0.00000, 40.00000);
	CreateDynamicObject(19966, 320.30295, -2606.68677, 1.01100,   0.00000, 0.00000, -40.00000);
	CreateDynamicObject(19966, 415.68271, -2594.70898, 1.01110,   0.00000, 0.00000, 120.00000);
	CreateDynamicObject(19966, 416.01770, -2591.34302, 1.01110,   0.00000, 0.00000, 76.00000);
	CreateDynamicObject(19966, 415.74429, -2396.09131, 1.01020,   0.00000, 0.00000, 120.00000);
	CreateDynamicObject(19966, 415.67380, -2391.69946, 1.01060,   0.00000, 0.00000, 75.00000);
	CreateDynamicObject(19966, 303.96918, -2454.47339, 1.01030,   0.00000, 0.00000, -60.00000);
	CreateDynamicObject(19966, 304.06436, -2457.94116, 1.01030,   0.00000, 0.00000, 230.00000);
	CreateDynamicObject(13591, 386.60077, -2584.14307, 0.96246,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(13591, 384.65540, -2584.65942, 1.48090,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3593, 384.78796, -2586.51440, 2.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3571, 331.14301, -2602.81250, 2.36000,   0.00000, 0.00000, 100.00000);
	CreateDynamicObject(3571, 327.61227, -2595.16699, 2.36000,   0.00000, 0.00000, 130.00000);
	CreateDynamicObject(3571, 324.17975, -2588.65039, 2.36000,   0.00000, 0.00000, 70.00000);
	CreateDynamicObject(1358, 403.05878, -2583.82349, 2.00000,   0.00000, 0.00000, 50.00000);
	CreateDynamicObject(1358, 317.03171, -2485.35767, 2.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(13025, 404.76306, -2595.94995, 3.00000,   0.00000, 0.00000, -30.00000);
	CreateDynamicObject(13025, 325.18652, -2437.78296, 3.00000,   0.00000, 0.00000, -30.00000);
	CreateDynamicObject(3573, 318.34900, -2532.47388, 3.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3573, 336.44437, -2395.02148, 3.70000,   0.00000, 0.00000, 60.00000);
	CreateDynamicObject(8407, 305.58762, -2460.38770, 2.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18228, 399.22989, -2547.02856, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11489, 344.71756, -2553.16577, 0.98660,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18271, 391.56750, -2488.39722, 23.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(714, 366.05811, -2458.69922, 0.93289,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2932, 322.15100, -2472.58374, 2.30000,   0.00000, 0.00000, 120.00000);
	CreateDynamicObject(3585, 417.75446, -2484.38916, 2.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3585, 341.89529, -2508.11523, 2.00000,   0.00000, 0.00000, 30.00000);
	CreateDynamicObject(5259, 363.18130, -2531.77222, 0.98374,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18996, 355.26477, -2579.35254, 0.97412,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(12843, 346.74689, -2376.59033, 1.10000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19640, 349.75043, -2372.12793, 1.00596,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1842, 340.96600, -2377.28979, 1.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1842, 346.08548, -2377.33521, 1.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1847, 351.21942, -2375.01758, 1.00640,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2012, 351.22131, -2378.96094, 1.00790,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2582, 348.02588, -2371.86450, 2.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1847, 337.30066, -2374.08472, 1.00950,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1848, 344.75790, -2372.15918, 1.00746,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1887, 340.76294, -2372.16357, 1.01088,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(6066, 345.21991, -2437.96948, 3.50000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(687, 386.51273, -2495.27393, 0.96486,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(687, 399.54178, -2491.07642, 0.97422,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(687, 406.04291, -2494.70679, 0.99627,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(687, 392.73343, -2493.41504, 0.99182,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(687, 386.08344, -2475.66650, 0.97740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(687, 399.89828, -2497.53735, 0.99658,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(696, 396.30539, -2501.33936, 0.97117,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(696, 403.08713, -2498.65063, 0.97243,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(696, 403.96771, -2486.97388, 0.98851,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(696, 395.89151, -2482.27881, 0.98650,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(696, 392.23648, -2490.59399, 0.98218,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(696, 402.02408, -2477.01807, 0.99061,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(696, 407.43924, -2482.65503, 0.99138,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(721, 409.56931, -2499.89233, -1.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(721, 416.44080, -2491.92871, -1.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(721, 393.92029, -2471.18213, -1.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(721, 381.57080, -2478.36182, -1.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 400.67276, -2502.99512, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 391.44186, -2497.28955, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 398.14539, -2494.30371, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 393.80026, -2484.99829, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 399.90707, -2479.27173, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 408.20877, -2477.79932, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 403.44122, -2484.43188, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 403.29492, -2490.54858, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 398.11926, -2487.05029, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 388.17172, -2489.90649, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 392.37613, -2490.92407, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 392.37613, -2490.92407, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 399.13504, -2497.97754, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 405.40738, -2496.10327, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 409.26022, -2491.85962, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 412.85226, -2497.07324, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 411.02704, -2487.64966, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 409.72452, -2481.60718, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 406.87186, -2486.77563, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 404.72372, -2480.06494, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 401.05270, -2473.25488, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 406.04425, -2473.30859, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 394.63745, -2477.11743, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 389.16754, -2475.20801, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 386.50217, -2480.78149, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 390.56897, -2481.61011, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 387.84296, -2486.02124, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 382.44138, -2484.96753, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 383.16116, -2491.38525, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 386.63522, -2495.31958, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 386.75269, -2500.37427, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 392.53601, -2502.83374, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 389.35263, -2506.60962, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 396.73660, -2506.71802, 0.98347,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11703, 340.00275, -2487.17358, 5.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2934, 302.84134, -2588.51733, 2.40000,   0.00000, 0.00000, 60.00000);
	CreateDynamicObject(18652, -1395.24902, -232.05676, 13.17188,   0.00000, 0.00000, 272.00000);
	CreateDynamicObject(18647, -1391.28369, -232.57681, 13.17188,   0.00000, 0.00000, 40.00000);
	CreateDynamicObject(18650, -1393.59338, -233.79500, 13.17188,   0.00000, 0.00000, 302.00000);
	CreateDynamicObject(18728, -1388.58203, -234.94467, 13.19844,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18728, -1395.22180, -227.58139, 13.19844,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18739, -1395.44275, -237.82225, 13.19844,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18739, -1398.27368, -234.71124, 13.19844,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18786, -1275.07483, -171.64481, 15.64844,   0.00000, 0.00000, 316.00000);
	CreateDynamicObject(18786, -1311.80908, -135.50398, 15.64844,   0.00000, 0.00000, 133.99976);
	CreateDynamicObject(18777, -1313.37231, -83.08613, 15.64845,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18777, -1313.78406, -84.95361, 41.61970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18777, -1313.86084, -86.47108, 67.59314,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18788, -1293.85974, -66.97174, 90.05876,   0.00000, 0.00000, 269.25000);
	CreateDynamicObject(18778, -1293.52942, -43.33597, 92.43375,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18846, -1377.75684, -235.67882, 18.10305,   0.00000, 0.00000, 226.00000);
	CreateDynamicObject(1634, -1180.94629, -219.26758, 14.44576,   0.00000, 0.00000, 275.99854);
	CreateDynamicObject(1337, -1131.07520, -221.20215, 25.56804,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18843, -1182.94202, -217.70235, 64.51524,   0.00000, 0.00000, 38.00000);
	CreateDynamicObject(1337, -1356.63477, 103.86914, 32.00848,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1634, -1715.29602, -243.73309, 14.44576,   0.00000, 0.00000, 190.00000);
	CreateDynamicObject(18844, -1715.57947, -241.79744, 64.81364,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1634, -1618.11133, -633.33105, 14.44576,   0.00000, 0.00000, 147.99683);
	CreateDynamicObject(18845, -1619.82288, -636.27740, 54.68982,   0.00000, 0.00000, 60.00000);
	CreateDynamicObject(18858, -1293.38770, -154.27370, 24.68484,   0.00000, 0.00000, 40.00000);
	CreateDynamicObject(18859, -1450.52344, 34.48682, 24.51679,   0.00000, 0.00000, 316.00000);
	CreateDynamicObject(18859, -1487.28284, -3.42758, 24.70601,   0.00000, 0.00000, 136.00000);
	CreateDynamicObject(18834, -1579.56812, -54.05391, 33.93995,   0.00000, 0.00000, 320.00000);
	CreateDynamicObject(18834, -1567.86816, -39.05664, 33.82524,   0.00000, 0.00000, 345.99573);
	CreateDynamicObject(18809, -1519.04883, -161.50098, 28.97700,   294.06006, 154.79187, 112.74170);
	CreateDynamicObject(1632, -1503.71118, -142.13205, 14.44855,   0.00000, 0.00000, 140.00000);
	CreateDynamicObject(18809, -1548.97009, -196.19809, 47.96255,   295.88275, 156.56097, 112.69296);
	CreateDynamicObject(18822, -1578.34912, -227.27528, 70.95313,   0.00000, 310.00000, 46.00000);
	CreateDynamicObject(18788, -1601.57361, -261.38565, 85.14461,   0.00000, 0.00000, 62.00000);
	CreateDynamicObject(18788, -1615.90759, -296.90915, 85.13508,   0.00000, 0.00000, 73.99585);
	CreateDynamicObject(18779, -1621.42236, -336.35645, 95.98354,   0.00000, 0.00000, 74.00000);
	CreateDynamicObject(18801, -1411.90918, -87.94434, 35.88602,   0.00000, 0.00000, 333.99536);
	CreateDynamicObject(18801, -1401.29639, -71.41965, 35.77812,   0.00000, 0.00000, 335.99536);
	CreateDynamicObject(18801, -1389.75452, -55.89094, 35.82813,   0.00000, 0.00000, 335.99487);
	CreateDynamicObject(18813, -1266.60913, -213.01154, 35.74533,   358.38208, 36.01660, 21.17590);
	CreateDynamicObject(18780, -1281.71069, -367.67053, 24.83267,   0.00000, 0.00000, 106.00000);
	CreateDynamicObject(7073, -1291.74316, -335.30762, 71.61242,   0.00000, 0.00000, 285.74890);
	CreateDynamicObject(18779, -1248.34509, -31.66846, 23.14063,   0.00000, 0.00000, 136.00000);
	CreateDynamicObject(1632, -1206.88770, -88.45996, 25.04882,   0.00000, 0.00000, 225.99976);
	CreateDynamicObject(18778, -1236.57507, 13.34186, 15.89220,   20.50000, 0.00000, 130.00000);
	CreateDynamicObject(18778, -1240.24585, 10.33731, 22.36645,   44.49500, 0.00000, 129.99573);
	CreateDynamicObject(18778, -1242.13208, 8.30724, 30.11034,   52.99463, 0.00000, 129.99573);
	CreateDynamicObject(18781, -1093.59436, 394.57394, 23.90034,   0.00000, 0.00000, 316.00000);
	CreateDynamicObject(18841, -1283.46082, 247.44424, 60.12366,   0.00000, 0.00000, 319.99475);
	CreateDynamicObject(18862, -1357.81079, -233.32098, 18.32487,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18820, -1308.15625, 43.52441, 18.76572,   358.34259, 277.82269, 306.35828);
	CreateDynamicObject(18825, -1389.08691, 135.67383, 33.75121,   0.00000, 0.00000, 317.74658);
	CreateDynamicObject(18850, -1224.49280, 181.03572, 24.94455,   0.00000, 0.00000, 44.00000);
	CreateDynamicObject(18780, -1262.19043, 146.63445, 9.07471,   0.00000, 0.00000, 44.00000);
	CreateDynamicObject(18782, -1360.93518, 10.33832, 14.38437,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18782, -1365.60754, 25.05677, 14.48438,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18779, -1439.54016, 81.14368, 23.32183,   0.00000, 0.00000, 346.00000);
	CreateDynamicObject(18829, -1287.96240, 193.66513, 27.12346,   293.99997, 0.00000, 315.50000);
	CreateDynamicObject(18820, -1258.22998, 225.30276, 45.19177,   292.00000, 0.00000, 318.50000);
	CreateDynamicObject(2940, -1236.10889, 204.86967, 43.27872,   12.00000, 0.00000, 222.00000);
	CreateDynamicObject(18836, -1549.54578, -80.31123, 49.42933,   0.00000, 0.00000, 228.00000);
	CreateDynamicObject(18841, -1547.18958, -130.82031, 48.95005,   270.00000, 180.00000, 322.00000);
	CreateDynamicObject(18801, -1540.33667, -103.17419, 67.13602,   0.00000, 0.00000, 327.99536);
	CreateDynamicObject(18808, -1586.50391, -125.32854, 48.79399,   270.00000, 180.00000, 62.00000);
	CreateDynamicObject(1632, -1612.43188, -111.15921, 44.87353,   0.00000, 0.00000, 64.00000);
	CreateDynamicObject(18825, -1329.18872, 71.22033, 37.88273,   0.00000, 0.00000, 310.49658);
	CreateDynamicObject(717, -1401.93665, -227.01492, 13.37344,   0.00000, 0.00000, 316.00000);
	CreateDynamicObject(717, -1387.99829, -241.37907, 13.37345,   0.00000, 0.00000, 315.99976);
	CreateDynamicObject(18829, -1530.63770, -46.19758, 49.95353,   0.00000, 268.00000, 350.00000);
	CreateDynamicObject(1632, -1502.55139, -51.35044, 46.85208,   0.00000, 0.00000, 262.00000);
	CreateDynamicObject(7073, -1504.84412, -3.01294, 54.70085,   0.00000, 0.00000, 225.74890);
	CreateDynamicObject(7073, -1430.74658, 30.16626, 54.41053,   0.00000, 0.00000, 225.74707);
	CreateDynamicObject(1632, -1164.49988, -124.30048, 25.66185,   0.00000, 0.00000, 225.99976);
	CreateDynamicObject(18788, -1045.90686, 438.08600, 30.04517,   0.00000, 0.00000, 46.00000);
	CreateDynamicObject(18800, -996.39929, 456.86880, 41.92051,   0.00000, 0.00000, 47.50000);
	CreateDynamicObject(18800, -943.98077, 394.96600, 62.09731,   0.00000, 0.00000, 37.49939);
	CreateDynamicObject(18841, -996.61737, 403.32639, 57.51069,   84.93121, 180.00037, 223.32800);
	CreateDynamicObject(1632, -957.05371, 356.79959, 75.47707,   0.00000, 0.00000, 124.00000);
	CreateDynamicObject(18858, -983.10999, 340.02704, 87.19101,   347.38318, 179.99994, 307.38318);
	CreateDynamicObject(18860, -1661.37146, -131.87012, 79.38470,   0.00000, 0.00000, 52.00000);
	CreateDynamicObject(18831, -1720.58972, -416.38913, 24.67662,   0.00000, 328.00000, 56.00000);
	CreateDynamicObject(18831, -1717.94006, -413.52557, 46.24487,   3.69006, 52.14941, 57.26300);
	CreateDynamicObject(18842, -1698.57471, -383.81943, 49.36895,   270.00000, 180.00000, 327.99988);
	CreateDynamicObject(18841, -1681.56348, -353.96725, 65.07432,   6.00000, 0.00000, 236.50000);
	CreateDynamicObject(18801, -1698.10303, -356.38055, 98.56342,   0.00000, 0.00000, 57.99133);
	CreateDynamicObject(18809, -1721.96094, -368.76563, 85.05584,   281.99997, 180.00000, 139.75000);
	CreateDynamicObject(1632, -1741.36206, -391.16742, 86.23597,   0.00000, 0.00000, 140.00000);
	CreateDynamicObject(18779, -1524.74146, -355.80743, 10.36719,   0.00000, 0.00000, 182.00000);
	CreateDynamicObject(18779, -1474.86633, -407.37173, 8.69535,   0.00000, 0.00000, 267.99951);
	CreateDynamicObject(18779, -1461.58203, -339.10904, 23.69328,   0.00000, 0.00000, 224.00000);
	CreateDynamicObject(18779, -1626.87097, -160.87344, 23.48492,   0.00000, 0.00000, 328.00000);
	CreateDynamicObject(1632, -1595.27979, -481.66333, 22.56292,   0.00000, 0.00000, 301.99878);
	CreateDynamicObject(1632, -1628.25049, -502.02237, 22.45310,   0.00000, 0.00000, 155.99768);
	CreateDynamicObject(1634, -1551.54980, -623.91309, 14.44127,   0.00000, 0.00000, 209.99683);
	CreateDynamicObject(1634, -1548.96191, -628.44769, 18.54176,   28.00000, 0.00000, 210.49268);
	CreateDynamicObject(1634, -1547.15979, -631.58600, 24.87245,   41.99866, 0.00000, 210.49255);
	CreateDynamicObject(1634, -1537.87256, -656.79456, 37.11086,   0.00000, 0.00000, 179.99268);
	CreateDynamicObject(1634, -1529.33032, -676.17249, 39.43713,   0.00000, 0.00000, 271.98901);
	CreateDynamicObject(1634, -1502.01428, -668.91321, 39.49764,   0.00000, 0.00000, 353.98853);
	CreateDynamicObject(1634, -1510.18518, -645.73291, 40.07419,   0.00000, 0.00000, 91.98499);
	CreateDynamicObject(4585, -1212.27454, -410.71725, 22.30301,   62.00000, 0.00000, 0.00000);
	CreateDynamicObject(18826, -1291.21667, -496.18573, 33.52203,   0.00000, 0.00000, 92.00000);
	CreateDynamicObject(18811, -1294.99915, -460.77283, 51.03612,   274.00000, 0.00000, 8.50000);
	CreateDynamicObject(18841, -1316.20825, -428.55957, 52.59707,   270.00000, 179.99451, 100.24829);
	CreateDynamicObject(18841, -1342.50256, -455.89691, 52.32652,   270.00000, 179.99451, 287.99475);
	CreateDynamicObject(18841, -1366.83813, -443.53104, 67.87629,   1.99854, 0.00000, 303.74719);
	CreateDynamicObject(18836, -1345.81689, -471.68420, 83.65784,   0.00000, 0.00000, 219.49927);
	CreateDynamicObject(1634, -1252.32666, -610.42474, 14.44576,   0.00000, 0.00000, 165.99854);
	CreateDynamicObject(1634, -1296.83032, -653.22815, 24.07396,   0.00000, 0.00000, 89.99792);
	CreateDynamicObject(1634, -1360.67188, -656.70789, 23.65463,   0.00000, 0.00000, 89.99451);
	CreateDynamicObject(1634, -1422.83057, -657.01013, 23.65821,   0.00000, 0.00000, 89.99451);
	CreateDynamicObject(1634, -1462.55542, -639.39398, 27.55688,   0.00000, 0.00000, 359.99451);
	CreateDynamicObject(18788, -1461.18640, -597.78467, 30.65931,   0.00000, 0.00000, 266.00000);
	CreateDynamicObject(1634, -1457.26599, -579.34955, 32.86288,   0.00000, 0.00000, 343.98901);
	CreateDynamicObject(1634, -1409.45032, -514.11334, 25.68717,   0.00000, 0.00000, 303.98743);
	CreateDynamicObject(18631, -1344.70764, -564.56036, 13.30803,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18759, -1288.10547, -571.57983, 13.14844,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1634, -1271.86157, -521.59589, 14.44128,   0.00000, 0.00000, 159.99792);
	CreateDynamicObject(18786, -1317.91333, -574.16785, 25.39844,   0.00000, 0.00000, 16.00000);
	CreateDynamicObject(18769, -1358.81543, -582.88184, 28.46383,   0.00000, 0.00000, 13.25000);
	CreateDynamicObject(18768, -1401.23828, -586.37299, 29.07338,   0.00000, 0.00000, 12.50000);
	CreateDynamicObject(1634, -1370.57593, -592.77252, 29.88146,   0.00000, 0.00000, 101.99792);
	CreateDynamicObject(18761, -1463.01172, -620.53223, 18.00423,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18761, -1414.92969, -588.78809, 34.35393,   0.00000, 0.00000, 281.50000);
	CreateDynamicObject(1632, -1660.84448, -617.10822, 14.44855,   0.00000, 0.00000, 108.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 0.00000, 0.00000, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(9833, 2394.01611, 1156.47925, 30.03040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(9833, 2395.73633, 1149.13354, 29.98040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(9833, 2386.38525, 1153.50916, 29.95540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(9833, 2389.68774, 1146.54651, 30.05540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16109, -865.31128, 2110.53442, 77.60010,   0.00000, 0.00000, 78.75000);
	CreateDynamicObject(16109, -973.24469, 2270.55493, 118.84680,   0.00000, 0.00000, 123.74990);
	CreateDynamicObject(16109, -1162.09521, 2307.88306, 160.14841,   0.00000, 0.00000, 168.75000);
	CreateDynamicObject(3816, -1227.05798, 2182.30591, 193.19749,   0.00000, 0.00000, 171.40550);
	CreateDynamicObject(16133, -1080.58911, 2224.28394, 142.95200,   0.00000, 0.00000, 292.50000);
	CreateDynamicObject(16133, -1094.10852, 2293.37183, 147.14481,   352.26511, 359.14059, 191.25000);
	CreateDynamicObject(16139, -937.23181, 2197.82983, 101.87070,   347.10840, 17.18870, 224.06329);
	CreateDynamicObject(16133, -958.94092, 2155.64331, 99.66280,   0.00000, 0.00000, 78.75000);
	CreateDynamicObject(16133, -1233.29565, 2277.92822, 180.88341,   357.42169, 0.00000, 346.09439);
	CreateDynamicObject(16133, -1212.79993, 2341.05273, 179.20050,   357.42169, 0.00000, 121.09430);
	CreateDynamicObject(16133, -1189.71753, 2341.86133, 169.98230,   357.42169, 315.30930, 199.84441);
	CreateDynamicObject(16133, -986.75891, 2326.60498, 138.03540,   4.29720, 354.84341, 65.06670);
	CreateDynamicObject(16133, -1015.67419, 2198.82471, 126.63400,   4.29720, 354.84341, 65.06670);
	CreateDynamicObject(16133, -832.37189, 2157.90283, 99.63890,   4.29720, 354.84341, 20.06680);
	CreateDynamicObject(16133, -885.73389, 2182.62036, 97.92350,   356.56229, 354.84341, 256.31680);
	CreateDynamicObject(16133, -952.54529, 2115.15845, 91.46040,   356.56229, 354.84341, 155.06670);
	CreateDynamicObject(615, -1206.81396, 2234.49243, 184.80240,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, -1160.15942, 2368.86694, 162.93510,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, -1092.53186, 2232.82129, 144.00420,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, -960.15430, 2337.67798, 130.34669,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, -916.57977, 2180.32275, 101.77780,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, -804.58130, 2105.73193, 79.65550,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(622, -1005.54309, 2235.81519, 133.68520,   0.00000, 0.00000, 67.50000);
	CreateDynamicObject(622, -1004.81781, 2234.22632, 132.95090,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(622, -1004.30060, 2233.84668, 133.28670,   0.00000, 0.00000, 112.50000);
	CreateDynamicObject(622, -1003.65747, 2232.77002, 132.09489,   0.00000, 0.00000, 135.00000);
	CreateDynamicObject(622, -1002.76813, 2232.22339, 131.60970,   0.00000, 0.00000, 157.50000);
	CreateDynamicObject(622, -1001.92407, 2231.90405, 131.34460,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(622, -1001.07269, 2231.60474, 131.07941,   0.00000, 0.00000, 202.50000);
	CreateDynamicObject(622, -1000.09851, 2231.70410, 130.82130,   0.00000, 0.00000, 225.00000);
	CreateDynamicObject(645, -1133.33350, 2279.02173, 169.12030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, -1111.52209, 2324.70166, 153.89880,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, -1030.43567, 2309.06982, 141.64371,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, -974.23792, 2264.07104, 126.70300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, -1002.49237, 2233.58691, 131.80009,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, -912.51990, 2153.93555, 100.36480,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, -866.84412, 2090.39795, 85.39430,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, -1198.33997, 2304.83667, 181.67160,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, -1053.62366, 2291.27783, 143.12230,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, -1033.15479, 2263.37646, 139.84621,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(669, -950.48523, 2269.25757, 125.34450,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(669, -958.59497, 2187.47852, 103.68340,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(669, -867.71332, 2147.15723, 99.23920,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(669, -824.73291, 2097.95483, 74.66220,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(671, -906.73779, 2176.07031, 101.19750,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(671, -926.67310, 2313.15552, 121.88720,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(671, -999.23907, 2295.17578, 140.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(671, -1151.29736, 2359.61890, 161.49690,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(671, -1128.39490, 2241.36865, 171.28751,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(671, -1182.98914, 2319.74048, 181.80450,   0.00000, 0.00000, 337.50000);
	CreateDynamicObject(672, -1188.63037, 2260.82739, 178.35500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, -1153.18835, 2221.79468, 176.51990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, -1130.50903, 2367.29810, 160.07800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, -1095.09900, 2259.06421, 146.21201,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, -1016.38312, 2279.34009, 140.28770,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, -947.61023, 2325.22119, 124.79040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, -918.76099, 2133.43188, 94.71040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, -914.78851, 2043.56543, 63.70220,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(691, -1234.63770, 2245.14258, 185.37930,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(691, -1153.57080, 2254.61377, 171.94580,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(691, -931.47083, 2298.19263, 118.45450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(691, -806.97589, 2135.79639, 81.94280,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, -1170.66858, 2236.81934, 174.23900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, -1149.25317, 2266.50854, 170.81090,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, -1143.47192, 2335.53540, 159.41890,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, -1062.09180, 2253.79004, 144.13550,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, -928.76672, 2252.84644, 113.66350,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, -925.01428, 2077.30811, 88.81360,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3819, -1179.98279, 2386.22095, 164.47569,   0.00000, 0.00000, 157.50000);
	CreateDynamicObject(3819, -1174.51367, 2394.61670, 163.94650,   0.00000, 0.00000, 123.74990);
	CreateDynamicObject(3819, -1166.12378, 2399.74683, 163.39780,   0.00000, 0.00000, 101.25000);
	CreateDynamicObject(3819, -931.63428, 2339.40039, 123.31030,   0.00000, 0.00000, 112.50000);
	CreateDynamicObject(3819, -922.11603, 2341.86450, 122.83310,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3819, -912.23309, 2339.64355, 122.25380,   0.00000, 0.00000, 56.25000);
	CreateDynamicObject(3819, -787.56958, 2128.87891, 81.97960,   0.00000, 0.00000, 67.50000);
	CreateDynamicObject(3819, -779.32013, 2124.05615, 81.50050,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(3819, -773.86823, 2115.83252, 80.93960,   0.00000, 0.00000, 11.25000);
	CreateDynamicObject(7392, -1177.71021, 2397.61841, 170.57770,   0.00000, 0.00000, 303.75000);
	CreateDynamicObject(13562, -1192.35254, 2386.71118, 165.06020,   0.00000, 0.00000, 348.75000);
	CreateDynamicObject(11417, -900.67200, 2336.39917, 125.70210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(13667, -922.79572, 2346.55786, 137.29340,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(14608, -935.12988, 2344.65698, 124.11740,   0.00000, 0.00000, 157.50000);
	CreateDynamicObject(16776, -781.42981, 2135.66772, 80.86020,   0.00000, 0.00000, 337.50000);
	CreateDynamicObject(16778, -766.42499, 2118.23560, 80.09250,   0.00000, 0.00000, 11.25000);
	CreateDynamicObject(8417, 925.28168, -1959.89514, 0.77170,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8417, 925.24158, -1999.74036, 0.80870,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(969, 904.83429, -1940.10828, 0.89950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(969, 913.64349, -1940.08582, 0.89950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(969, 922.37872, -1940.23218, 0.89950,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(969, 904.69891, -1940.16528, 0.89950,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(969, 922.25238, -1948.89758, 0.89950,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(969, 904.69012, -1948.95325, 0.89950,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(969, 904.90369, -1957.74646, 0.89950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 918.20471, -1957.89868, 1.57290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 924.49731, -1957.88953, 1.57290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 929.33557, -1953.14575, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 927.10431, -1940.06860, 1.57290,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(973, 936.19672, -1940.07288, 1.57290,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(973, 934.03778, -1944.85071, 1.57290,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 933.71887, -1957.77344, 1.57290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 938.60809, -1952.96326, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 941.10907, -1940.07837, 1.57290,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(973, 945.84131, -1944.77490, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 945.83917, -1954.12195, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 945.82843, -1963.50293, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 941.10388, -1968.17297, 1.57290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 932.32343, -1968.15662, 1.57290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 923.67877, -1965.58191, 1.57290,   0.00000, 0.00000, 326.25000);
	CreateDynamicObject(973, 915.21637, -1963.07007, 1.57290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 910.71899, -1967.63916, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 904.93439, -1967.96838, 1.57290,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 904.93573, -1976.73035, 1.57290,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 904.96472, -1985.99927, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 910.77179, -1976.93762, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 909.66821, -1991.01782, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 915.34222, -1981.48157, 1.60990,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(973, 915.49622, -1991.03833, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(974, 920.03058, -1986.05127, 1.62240,   71.33320, 0.00000, 89.14050);
	CreateDynamicObject(974, 925.39362, -1986.10461, 2.44740,   89.38140, 0.00000, 270.00000);
	CreateDynamicObject(974, 930.70172, -1986.08228, 1.54740,   71.33320, 0.85940, 269.14059);
	CreateDynamicObject(973, 933.08087, -1982.53418, 1.60990,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(973, 938.17908, -1987.22437, 1.60990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 938.18152, -1990.20691, 1.60990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 933.37982, -1994.88696, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 924.37762, -1994.89526, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 919.54828, -1995.57007, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 921.37152, -1978.30359, 1.57290,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 928.82147, -1978.34827, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 925.28540, -1971.08020, 1.57290,   0.00000, 0.00000, 213.75000);
	CreateDynamicObject(973, 933.34320, -1973.88501, 1.57290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 945.86090, -1972.79968, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 941.28088, -1977.44702, 1.57290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 936.86328, -1977.44055, 1.57790,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 945.82031, -1981.75708, 1.60990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 945.82532, -1990.84631, 1.60990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 945.81512, -1999.96057, 1.60990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 941.06348, -2004.68311, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 936.48767, -2003.42920, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 931.90259, -1998.80090, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 927.36761, -2003.38342, 1.60990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 919.56897, -2002.34314, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 931.89630, -2008.01794, 1.60990,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(973, 927.33838, -2008.38367, 1.60990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 922.52777, -2013.00610, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 915.92603, -2013.02600, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 911.15710, -2008.13342, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 911.13422, -1999.38464, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 905.06897, -1995.46436, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 905.06073, -2004.40393, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 905.04919, -2013.23938, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 909.69373, -2018.03223, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 918.83228, -2018.07507, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 927.77429, -2018.09363, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 932.69922, -2016.82007, 1.60990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 937.29211, -2012.23376, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(974, 948.31689, -2008.10974, 0.57240,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 953.80792, -2008.30725, 0.53050,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(973, 941.33807, -2012.10388, 1.78450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 904.76282, -1961.23462, 1.13840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 904.62543, -1959.55042, 1.13840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 927.86432, -1956.74097, 1.13840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 933.04498, -1941.27881, 1.13840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 930.28412, -1956.32422, 1.13840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 935.53278, -1941.20715, 1.13840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 943.55750, -1966.08765, 1.13840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 905.81439, -1989.60120, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 919.92133, -1990.23267, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 919.94513, -1982.18250, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 944.40009, -1969.05188, 1.13840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 940.44202, -2003.33643, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 938.16229, -2001.70166, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 926.02570, -2011.02698, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 917.65668, -1992.73291, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 938.17542, -2006.52759, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(974, 959.22449, -2008.39502, 0.51280,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 964.67719, -2008.55640, 0.49170,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 970.05151, -2008.71216, 0.52200,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(970, 925.38788, -1989.37781, 3.00670,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 925.44489, -1982.92090, 3.00610,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 922.67511, -1982.58374, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 922.07971, -1990.41479, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 913.13989, -1954.74902, 0.23410,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(970, 913.14240, -1951.46252, 0.23410,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1263, 913.56128, -1957.43555, 1.51980,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(1263, 913.97333, -1949.39429, 1.51980,   0.00000, 0.00000, 33.75000);
	CreateDynamicObject(9833, 931.49323, -2002.84863, -2.32780,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 917.35858, -1964.91846, 3.46300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 914.59741, -1979.64819, 3.46300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 922.28717, -1972.71143, 3.42040,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(1231, 942.91339, -2012.53186, 3.33200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 935.06293, -2006.97571, 3.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 935.59912, -1999.60083, 3.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 927.95648, -1999.84595, 3.40000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 928.59790, -2006.96765, 3.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 910.82813, -2018.43005, 4.80740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 945.42828, -1940.56946, 3.46300,   0.00000, 0.00000, 326.25000);
	CreateDynamicObject(1231, 945.43188, -1977.05396, 3.46300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 905.15277, -1940.27051, 3.46300,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(1655, 974.44202, -2009.01782, 0.73110,   350.54620, 0.85940, 267.42169);
	CreateDynamicObject(3749, 986.74371, -2009.55127, 8.74970,   355.70279, 0.85940, 86.56220);
	CreateDynamicObject(1225, 980.74261, -2015.01624, 2.68630,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 982.08600, -2002.21265, 2.49670,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 979.97198, -2003.58289, 2.05050,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 984.49487, -2001.06702, 3.04620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 983.20972, -2016.37634, 3.35030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 978.52948, -2013.70166, 2.01240,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1262, 914.19739, -1950.12573, 2.04230,   0.00000, 0.00000, 146.25000);
	CreateDynamicObject(1262, 913.96411, -1956.62537, 1.84230,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(1238, 990.38647, -2015.70361, 5.31750,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 994.06732, -2014.58289, 6.30430,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 997.31378, -2011.79419, 7.10850,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 999.46722, -2006.96021, 7.53210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 999.36963, -1999.72571, 7.29710,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 999.12970, -1995.27405, 7.17200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 999.62482, -2003.29651, 7.44140,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 998.98480, -1989.75647, 7.04850,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 993.97278, -1989.69275, 5.36240,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 988.56781, -1989.30676, 3.83860,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 982.09271, -1988.58008, 2.00340,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 975.29852, -1988.34180, 0.69470,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 983.71680, -1999.63782, 2.86370,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 979.95282, -1999.05286, 1.79090,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 975.09949, -1998.92773, 0.90850,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(974, 973.21790, -1993.60583, 0.50070,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 967.79822, -1993.43591, 0.49320,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 962.36932, -1993.28992, 0.50700,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 956.94232, -1993.10803, 0.52510,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 952.13678, -1992.88464, 1.46350,   67.89540, 359.14059, 269.14059);
	CreateDynamicObject(974, 947.20660, -1992.75037, 3.51470,   67.89540, 359.14059, 269.14059);
	CreateDynamicObject(974, 941.90161, -1992.59155, 4.56800,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 936.70972, -1992.46887, 5.28300,   73.91150, 359.14059, 269.14059);
	CreateDynamicObject(974, 931.31543, -1992.29407, 6.06000,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 925.92682, -1992.18347, 6.02960,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 920.47717, -1992.02612, 6.04260,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 915.12140, -1991.86987, 6.06400,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 909.84698, -1991.71204, 6.08310,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 904.69427, -1991.52698, 6.10300,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 899.42407, -1991.39514, 6.09680,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 900.22168, -1985.34375, 6.12840,   90.24080, 0.00000, 0.00000);
	CreateDynamicObject(974, 900.18951, -1979.92175, 6.14940,   90.24080, 0.00000, 0.00000);
	CreateDynamicObject(974, 900.16333, -1974.48291, 6.19250,   90.24080, 0.00000, 0.00000);
	CreateDynamicObject(974, 900.15198, -1969.11682, 6.25690,   90.24080, 0.00000, 0.00000);
	CreateDynamicObject(974, 900.16217, -1963.73401, 6.26960,   90.24080, 0.00000, 0.00000);
	CreateDynamicObject(974, 900.14209, -1958.41101, 6.26080,   90.24080, 0.00000, 0.00000);
	CreateDynamicObject(974, 894.27502, -1959.04724, 6.36690,   90.24080, 0.00000, 90.00000);
	CreateDynamicObject(974, 888.86682, -1959.03442, 6.36290,   90.24080, 0.00000, 90.00000);
	CreateDynamicObject(974, 888.92920, -1952.45007, 6.37230,   90.24080, 0.00000, 270.00000);
	CreateDynamicObject(974, 894.27802, -1952.46960, 6.44200,   90.24080, 0.00000, 270.00000);
	CreateDynamicObject(974, 899.63751, -1952.44128, 6.51380,   90.24080, 0.00000, 270.00000);
	CreateDynamicObject(1633, 906.91333, -1952.39673, 7.12730,   353.98389, 0.00000, 270.00000);
	CreateDynamicObject(970, 901.31927, -1955.84119, 6.82920,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 897.17712, -1955.87024, 6.91530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 893.00989, -1955.87109, 6.93090,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 896.84662, -1989.94434, 6.87920,   0.00000, 0.00000, 268.28110);
	CreateDynamicObject(973, 907.99512, -1988.38074, 6.93830,   0.00000, 0.00000, 178.28120);
	CreateDynamicObject(973, 903.46228, -1983.67590, 6.93570,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 896.91498, -1967.44043, 7.11430,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 903.38843, -1960.77441, 7.09830,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 886.29523, -1957.50146, 7.22150,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 886.28302, -1953.73450, 7.21070,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 891.12738, -1949.25879, 7.28090,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(973, 898.08698, -1949.30774, 7.30450,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(970, 941.96790, -1989.32874, 5.12700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 941.61578, -1995.89221, 5.12920,   0.00000, 0.00000, 357.42169);
	CreateDynamicObject(970, 973.74658, -1990.36060, 1.05820,   0.00000, 0.00000, 359.14059);
	CreateDynamicObject(970, 972.90259, -1996.89087, 1.06070,   0.00000, 0.00000, 358.28110);
	CreateDynamicObject(1231, 886.31927, -1949.34387, 9.10140,   0.00000, 0.00000, 33.75000);
	CreateDynamicObject(1231, 886.92078, -1962.27600, 9.10900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 896.87628, -1994.55139, 8.80910,   0.00000, 0.00000, 326.25000);
	CreateDynamicObject(1231, 954.73291, -1989.94360, 3.27250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 999.43860, -1991.06348, 8.57660,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 998.52869, -2009.50549, 9.00150,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 975.64319, -1997.38257, 3.38220,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1231, 979.60278, -2015.67603, 4.71680,   0.00000, 0.00000, 78.75000);
	CreateDynamicObject(621, 1005.14532, -1993.67554, 7.24400,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(621, 1002.63843, -2015.25610, 7.61560,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(621, 993.90332, -1975.98865, 4.99500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(621, 977.74622, -1970.70764, 0.79620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(621, 988.96552, -2033.63965, 4.86560,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(621, 973.26611, -2041.40137, 0.76480,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 903.26508, -1978.03040, 6.57090,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 903.33423, -1975.33801, 6.60250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 903.15997, -1972.43250, 6.61470,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 903.16101, -1969.39050, 6.66930,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 903.10498, -1966.08472, 6.67320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 925.97241, -1988.92920, 6.44300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 925.72913, -1995.38013, 6.44080,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 996.82739, -1992.66467, 6.35660,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 977.23523, -1990.52136, 1.10770,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 887.21838, -1950.39734, 6.77870,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 895.88678, -1962.40137, 6.72370,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(981, 797.32422, -1389.05127, 13.49970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(981, 797.75873, -1411.90759, 13.35280,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(981, 916.98993, -1412.08728, 13.17530,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(981, 918.02283, -1389.06128, 13.37720,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(981, 1057.89307, -1389.04993, 13.21120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(981, 1063.01428, -1412.43542, 13.13700,   0.00000, 0.00000, 180.00011);
	CreateDynamicObject(981, 1201.19983, -1388.72449, 12.94980,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(981, 1194.90283, -1412.46704, 12.98680,   0.00000, 0.00000, 180.00011);
	CreateDynamicObject(981, 1257.41479, -1388.70813, 12.95450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(981, 1349.82031, -1386.35266, 13.45290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(981, 1349.96960, -1412.19495, 13.31430,   0.00000, 0.00000, 180.00020);
	CreateDynamicObject(981, 1386.15649, -1401.07178, 13.33430,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(981, 632.80841, -1413.90015, 13.15310,   0.00000, 0.00000, 180.00020);
	CreateDynamicObject(981, 616.48560, -1400.08020, 13.12490,   0.00000, 0.00000, 90.00040);
	CreateDynamicObject(981, 632.59637, -1349.91528, 13.10930,   0.00000, 0.00000, 0.00060);
	CreateDynamicObject(979, 663.32361, -1410.63379, 13.25100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(979, 663.59113, -1405.19092, 13.23900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(979, 663.99103, -1400.15857, 13.23870,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(979, 664.26678, -1394.87805, 13.24340,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(978, 663.48352, -1405.86816, 13.24110,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(978, 663.88092, -1400.73987, 13.24550,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(978, 664.27368, -1395.63513, 13.23210,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(978, 663.83008, -1390.23376, 13.31700,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1290, 664.19379, -1395.26428, 18.35890,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1290, 664.09027, -1405.50403, 18.53170,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1215, 682.64862, -1395.24084, 12.95560,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 682.02710, -1400.44653, 12.96480,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 682.24939, -1405.54395, 12.95740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 754.35748, -1395.37793, 12.93150,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 848.66669, -1395.41980, 12.75320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 966.74878, -1395.33081, 12.53300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 1092.37939, -1395.54810, 13.03750,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 1225.62781, -1395.35107, 12.71700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 754.28741, -1400.48218, 12.93150,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 753.61511, -1405.53027, 12.93130,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 848.28583, -1400.54016, 12.85310,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 848.04761, -1405.57971, 12.85760,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 966.78198, -1400.49463, 12.71450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 966.43298, -1405.55664, 12.72730,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 1092.49194, -1400.67773, 13.03000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 1091.96716, -1405.82666, 13.03190,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 1225.58447, -1400.52441, 12.71600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 1224.56323, -1405.65271, 12.69070,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 1380.69409, -1393.00244, 13.93350,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 1380.75671, -1397.87805, 13.87680,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 1380.75696, -1403.06812, 13.87680,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 1380.82251, -1408.29810, 13.87680,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 671.12988, -1395.29724, 12.45980,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 674.47870, -1395.23926, 12.46100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 677.85901, -1395.29541, 12.45980,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 681.18683, -1395.25073, 12.46040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 670.89337, -1400.48523, 12.47410,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 674.42810, -1400.43787, 12.47420,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 677.92651, -1400.41846, 12.46730,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 681.44849, -1400.43970, 12.46930,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 670.60199, -1405.46802, 12.46680,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 674.18628, -1405.52490, 12.46730,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 677.72131, -1405.49780, 12.46670,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 681.39203, -1405.48804, 12.46190,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 1375.92017, -1392.88660, 13.95700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 1375.85437, -1398.11597, 13.88450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 1375.63635, -1403.20544, 13.87680,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 1375.58972, -1408.22766, 13.88530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3851, 1332.77576, -1395.64709, 14.37150,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3851, 1332.77759, -1405.44800, 14.37990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3851, 1337.10986, -1394.05090, 14.38600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3851, 1342.24353, -1404.60229, 14.32610,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3851, 1347.42078, -1393.82983, 14.39370,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3851, 1352.11755, -1405.47485, 14.33450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3851, 1357.46924, -1393.42297, 14.38410,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3851, 1362.35681, -1405.24072, 14.42520,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2780, 1390.03284, -1400.91516, 12.38280,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 631.77417, -1399.96899, 12.16260,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3528, 646.54608, -1385.43115, 20.01640,   0.00000, 0.00000, 213.75000);
	CreateDynamicObject(7392, 615.01563, -1428.68311, 40.72260,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(13562, 647.80957, -1384.21643, 23.02410,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8040, 747.38812, 2493.42407, 479.92319,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(16384, 650.45209, 2494.42749, 428.24130,   0.00000, 318.74701, 0.00000);
	CreateDynamicObject(16384, 531.15869, 2494.47070, 323.63400,   0.00000, 318.74701, 0.00000);
	CreateDynamicObject(16384, 428.68231, 2494.56812, 203.65790,   0.00000, 301.55841, 0.00000);
	CreateDynamicObject(16384, 382.19571, 2494.60522, 127.87260,   0.00000, 301.55841, 0.00000);
	CreateDynamicObject(1655, 336.78549, 2498.23926, 54.49660,   31.79920, 0.00000, 270.00000);
	CreateDynamicObject(1655, 336.78769, 2489.99487, 54.40060,   34.37750, 358.28110, 270.85950);
	CreateDynamicObject(4567, 326.46841, 2495.13501, 51.54200,   0.00000, 359.14059, 179.14059);
	CreateDynamicObject(1655, 263.31641, 2489.46753, 53.22380,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1655, 263.24600, 2496.30420, 53.26150,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1655, 263.24500, 2501.42041, 53.29760,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3381, 297.80609, 2502.88696, 61.13910,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(972, 319.46109, 2483.65356, 51.87700,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(972, 295.73831, 2483.89136, 51.80980,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(972, 315.90060, 2504.69873, 51.85540,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(972, 290.76611, 2504.49512, 51.86400,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(18450, 431.90710, 2495.46826, 251.79269,   179.62230, 43.83130, 0.00000);
	CreateDynamicObject(8355, 446.76309, 2484.31787, 234.36180,   299.83939, 94.53800, 91.71890);
	CreateDynamicObject(8355, 450.67450, 2503.91528, 237.80460,   61.02000, 88.52200, 271.09140);
	CreateDynamicObject(1655, 331.43149, 2489.18994, 51.20700,   350.54620, 0.85940, 270.00000);
	CreateDynamicObject(1655, 331.68350, 2499.21509, 51.35220,   349.68680, 1.71890, 270.00000);
	CreateDynamicObject(1655, 331.94269, 2492.65259, 51.36860,   351.40561, 0.85940, 270.00000);
	CreateDynamicObject(12990, 760.27441, 2526.57959, 480.43790,   0.00000, 356.56229, 0.00000);
	CreateDynamicObject(11495, 760.09192, 2541.47900, 480.22791,   358.28110, 1.71890, 90.00000);
	CreateDynamicObject(3877, 785.65619, 2510.58203, 480.83090,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 786.05243, 2476.25708, 480.82330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 764.53809, 2476.25537, 480.82330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 709.92133, 2476.40283, 480.82330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 709.53918, 2509.88477, 480.82330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 764.61761, 2510.61816, 480.82330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 758.44623, 2510.93286, 480.82330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 742.20361, 2475.61426, 480.82330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 738.90863, 2509.70044, 480.82330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7392, 786.66449, 2491.48291, 488.76770,   358.28110, 0.00000, 0.00000);
	CreateDynamicObject(3534, 758.12811, 2539.61084, 481.69351,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 762.56122, 2539.43286, 481.94360,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 277.19730, 2486.57861, 53.54110,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 270.64371, 2487.09326, 53.63950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 270.61731, 2501.96973, 53.64330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 276.94879, 2501.43677, 53.54820,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 273.40302, 2501.97534, 51.71620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 273.87161, 2487.25366, 51.95580,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 459.66019, 2494.59082, 277.79440,   0.00000, 178.76289, 0.00000);
	CreateDynamicObject(7617, 709.53741, 2494.64355, 490.35281,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3243, 708.75293, 2485.89380, 479.20029,   0.00000, 0.00000, 281.25000);
	CreateDynamicObject(3243, 709.36890, 2503.40430, 479.19260,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(16121, 1920.76953, -277.77679, 2.22490,   350.54620, 354.84341, 326.25000);
	CreateDynamicObject(16121, 1951.02808, -309.08701, 5.58930,   11.17270, 6.01610, 115.15550);
	CreateDynamicObject(16120, 1920.63049, -325.23999, 10.95650,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16120, 1963.90320, -333.75281, 13.53290,   11.17270, 0.00000, 191.25011);
	CreateDynamicObject(16119, 1955.99475, -399.50699, 19.69150,   8.59440, 347.96790, 258.75000);
	CreateDynamicObject(16116, 1934.75256, -354.73331, 15.43200,   0.00000, 0.00000, 301.09439);
	CreateDynamicObject(8650, 1917.11462, -395.64081, 21.70500,   352.26511, 0.00000, 292.50000);
	CreateDynamicObject(8650, 1919.13464, -397.36261, 21.85130,   352.26511, 0.00000, 292.50000);
	CreateDynamicObject(16113, 1907.90686, -375.71759, 19.96270,   0.00000, 0.00000, 258.75000);
	CreateDynamicObject(16113, 1920.21436, -423.20331, 20.08030,   0.00000, 0.00000, 67.50000);
	CreateDynamicObject(16111, 1889.70825, -409.78210, 22.08860,   22.34540, 57.58220, 303.75000);
	CreateDynamicObject(16114, 1873.70581, -387.19861, 28.68830,   0.00000, 15.46990, 333.98489);
	CreateDynamicObject(16116, 1869.92871, -437.20779, 25.45500,   0.00000, 20.62650, 337.50000);
	CreateDynamicObject(16114, 1863.98718, -415.57959, 39.61130,   11.17270, 33.51800, 30.23490);
	CreateDynamicObject(16117, 1917.35620, -447.53241, 24.23890,   0.00000, 0.00000, 78.75000);
	CreateDynamicObject(16118, 1878.43738, -481.09250, 16.07360,   0.00000, 0.00000, 191.25000);
	CreateDynamicObject(16121, 1925.94312, -497.10660, 11.40090,   0.00000, 0.00000, 202.50000);
	CreateDynamicObject(16121, 1934.94324, -546.21472, 13.73470,   0.00000, 0.00000, 157.50000);
	CreateDynamicObject(16121, 1888.92224, -522.68573, 13.61450,   0.00000, 0.00000, 33.75000);
	CreateDynamicObject(16121, 1903.31531, -561.92493, 21.85240,   341.95181, 0.00000, 337.50000);
	CreateDynamicObject(16121, 1908.86621, -599.63788, 35.73240,   328.20081, 0.00000, 348.75000);
	CreateDynamicObject(16121, 1939.12585, -579.41663, 22.55780,   21.48590, 0.00000, 168.75011);
	CreateDynamicObject(16121, 1945.74207, -616.54022, 41.74660,   27.50200, 0.00000, 168.75011);
	CreateDynamicObject(16112, 1928.73389, -624.65833, 44.72530,   3.43770, 17.18870, 123.75010);
	CreateDynamicObject(16121, 1920.44690, -479.66370, 27.54040,   353.12451, 33.51800, 191.25000);
	CreateDynamicObject(749, 1937.01575, -394.86420, 21.53070,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(750, 1933.04102, -383.26071, 23.56160,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(751, 1918.75781, -400.37659, 20.48760,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(750, 1927.08862, -403.10971, 26.30810,   334.21689, 0.00000, 0.00000);
	CreateDynamicObject(750, 1919.27905, -384.88599, 25.86460,   334.21689, 0.00000, 157.50000);
	CreateDynamicObject(615, 1943.14246, -271.55200, 0.00650,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, 1915.81067, -307.74399, 14.60820,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, 1966.46313, -345.30801, 22.80030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, 1917.49817, -392.65909, 19.99020,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, 1898.26575, -511.79990, 17.47170,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, 1932.08191, -570.74329, 28.36760,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1980.35449, -284.66971, 4.78800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1911.44434, -353.12100, 16.25570,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1931.68689, -477.27631, 20.49220,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1891.46631, -556.26770, 25.54790,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, 1941.62964, -310.46149, 14.65970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, 1952.55225, -330.79910, 21.86940,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, 1918.63855, -381.33209, 26.76610,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, 1880.78503, -411.30801, 30.38250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, 1907.43604, -441.71790, 18.97760,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, 1926.46399, -514.26611, 18.14090,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, 1914.04492, -584.77832, 34.75080,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(671, 1907.74548, -504.94980, 16.86580,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1918.11853, -514.98401, 17.94310,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(688, 1906.39587, -508.57419, 16.59270,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, 1940.16882, -623.24402, 55.39690,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, 1938.96338, -363.31631, 24.46990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, 1930.87488, -281.08301, 7.22480,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1902.11975, -442.92691, 20.69270,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1898.64221, -444.25760, 20.53790,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1893.77527, -443.11929, 22.07040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1890.33032, -440.27951, 23.92580,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1893.38525, -439.45010, 23.12260,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1897.83691, -440.18481, 21.19920,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1901.47754, -438.08951, 20.94760,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1896.12830, -433.39670, 22.49600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1892.93896, -434.15189, 23.92110,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1889.17078, -434.30319, 25.02160,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1887.84863, -430.27951, 25.92010,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1891.82117, -429.68951, 24.81420,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1895.48584, -428.96579, 23.09120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3515, 1912.95325, -398.66711, 19.33040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14608, 1932.33887, -625.05463, 58.59690,   350.54620, 0.00000, 316.71890);
	CreateDynamicObject(3461, 1936.81616, -282.11719, 6.57570,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1925.17834, -308.91550, 18.84280,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1938.41565, -332.54919, 21.64070,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1954.29517, -352.28021, 24.80300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1942.58826, -376.92340, 26.51370,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1932.10413, -393.29361, 22.54820,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1929.68005, -388.77811, 22.07120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1903.14026, -405.90121, 25.12330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1901.35681, -400.82571, 26.53310,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1884.14722, -425.41739, 29.84490,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1898.22339, -453.86050, 25.60920,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1890.63940, -488.20630, 21.96190,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1917.76270, -506.92099, 19.05190,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1913.13843, -530.37292, 23.23520,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1924.90698, -558.30737, 26.23510,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1915.45618, -576.96332, 35.59030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1931.65015, -595.16492, 43.57780,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1924.42273, -609.31409, 55.08420,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1938.23059, -609.47388, 55.70900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(790, 1920.14648, -390.00671, 24.37620,   0.00000, 0.00000, 326.25000);
	CreateDynamicObject(4108, 1894.92920, -620.15588, 64.18620,   12.89160, 12.89160, 81.32830);
	CreateDynamicObject(1634, 2202.53174, 963.43970, 11.61760,   8.59440, 0.00000, 180.00000);
	CreateDynamicObject(1634, 2198.43530, 963.47357, 11.59260,   8.59440, 0.00000, 180.00000);
	CreateDynamicObject(9833, 2394.01611, 1156.47925, 30.03040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(9833, 2395.73633, 1149.13354, 29.98040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(9833, 2389.68774, 1146.54651, 30.05540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(9833, 2386.38525, 1153.50916, 29.95540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3749, 1947.09338, 2406.62646, 15.67870,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1966.68250, 2448.85938, 9.82830,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1966.69702, 2436.92432, 9.82030,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1966.75134, 2424.98608, 9.82030,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1966.71497, 2419.99219, 9.82030,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1966.46033, 2408.13550, 9.80450,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 1937.43542, 2408.49805, 9.81300,   0.00000, 0.00000, 193.75110);
	CreateDynamicObject(987, 1925.84912, 2405.66284, 9.82030,   0.00000, 0.00000, 221.48500);
	CreateDynamicObject(987, 1916.85388, 2397.72559, 9.82030,   0.00000, 0.00000, 216.87880);
	CreateDynamicObject(987, 1898.93274, 2390.62744, 9.82030,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 1907.26318, 2390.58569, 9.82030,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(10562, 1898.52429, 2440.48877, 9.92590,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(10562, 1898.09802, 2430.24878, 9.87660,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(10562, 1893.50085, 2414.03442, 9.87740,   0.00000, 0.00000, 128.04720);
	CreateDynamicObject(11490, 1920.36536, 2431.10425, 10.01690,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11491, 1920.34436, 2420.02197, 11.47800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2780, 1920.24866, 2423.13037, 20.79780,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1920.76965, 2423.47534, 9.87470,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1920.47461, 2423.46899, 9.89970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1920.07898, 2423.46802, 9.89970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1919.78589, 2423.49414, 9.87470,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14446, 1917.49548, 2433.50879, 12.08740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1828, 1920.43994, 2428.93896, 11.47240,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(2718, 1917.76746, 2435.16846, 13.67320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11665, 1923.21045, 2433.68750, 12.19840,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1724, 1922.51099, 2432.67993, 11.49770,   0.00000, 0.00000, 157.50000);
	CreateDynamicObject(2224, 1921.74683, 2434.61426, 11.49550,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(2224, 1923.23071, 2434.62451, 11.49550,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(14806, 1924.27271, 2427.45190, 12.58570,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1723, 1921.95752, 2426.48853, 11.49780,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(11665, 1917.42859, 2427.44751, 12.22340,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3279, 1960.17883, 2414.59009, 10.05460,   0.00000, 0.00000, 90.00010);
	CreateDynamicObject(16644, 1947.44141, 2415.01587, 26.95950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16644, 1943.01599, 2415.08130, 26.95950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3279, 1932.55432, 2414.02515, 10.03110,   0.00000, 0.00000, 90.00010);
	CreateDynamicObject(984, 1950.96802, 2415.85791, 27.61940,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(984, 1941.86023, 2415.84326, 27.61940,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(984, 1941.87146, 2413.47021, 27.64590,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(984, 1951.21155, 2413.48169, 27.64590,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3279, 1902.43884, 2394.88477, 10.01320,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14637, 1947.20654, 2403.10254, 16.94200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(14467, 1940.08643, 2402.78955, 11.85410,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(14467, 1954.90833, 2402.40332, 11.85410,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3528, 1946.78198, 2402.50293, 17.12870,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(12991, 1964.20349, 2431.98340, 16.00290,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(8613, 1960.17737, 2424.86084, 12.62540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1491, 1963.75830, 2429.02905, 15.78670,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1828, 1963.96460, 2432.00439, 16.00130,   0.00000, 0.00000, 225.00000);
	CreateDynamicObject(3280, 2192.39087, 998.96198, 10.53150,   0.00000, 270.61859, 20.62650);
	CreateDynamicObject(3409, 1894.07849, 2416.83252, 10.34160,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(970, 1896.39661, 2416.84058, 10.72970,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(970, 1894.31067, 2418.91943, 10.72970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 1892.22241, 2418.92651, 10.72970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 1890.19116, 2416.90088, 10.72970,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(970, 1890.21680, 2412.78711, 10.72970,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(970, 1890.22253, 2408.63379, 10.72970,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(970, 1892.31018, 2406.61670, 10.72970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 1896.40222, 2408.67334, 10.72970,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(970, 1894.31738, 2406.63428, 10.72970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, 1893.78381, 2409.29517, 10.34160,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3409, 1893.96594, 2412.98608, 10.34160,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3508, 1924.62549, 2405.45117, 9.95390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3508, 1919.19910, 2401.01709, 9.95390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3508, 1913.80334, 2396.39893, 9.95390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3508, 1907.87830, 2392.75977, 9.94040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3508, 1965.36328, 2418.52100, 9.97740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3508, 1966.48315, 2424.02515, 9.97740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3508, 1965.31641, 2440.01367, 10.17660,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(967, 1939.55103, 2409.49170, 9.95480,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3666, 1940.25659, 2410.71191, 10.46840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3666, 1940.26392, 2411.54663, 10.46840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3666, 1938.85669, 2411.56738, 10.46840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3666, 1938.87036, 2410.71558, 10.46840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1966.47095, 2408.13379, 14.60470,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 1966.68811, 2419.76270, 14.65400,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1966.71826, 2430.07471, 14.72900,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1966.70215, 2445.55591, 14.77820,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1937.38672, 2408.35327, 14.67370,   0.00000, 0.00000, 193.82829);
	CreateDynamicObject(987, 1925.87280, 2405.36792, 14.82030,   0.00000, 0.00000, 219.61160);
	CreateDynamicObject(987, 1916.81628, 2397.61353, 14.82970,   0.00000, 0.00000, 218.04720);
	CreateDynamicObject(987, 1907.31348, 2390.48291, 14.51590,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 1895.30823, 2390.51880, 14.50800,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(974, 1964.47253, 2431.70410, 15.96130,   269.75909, 0.00000, 90.00000);
	CreateDynamicObject(18014, 1919.86597, 2417.87354, 10.43620,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(18014, 1915.37634, 2417.86890, 10.43620,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(18014, 1913.41504, 2420.43506, 10.43620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18014, 1913.40845, 2423.08740, 10.43620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2254, 1915.79504, 2431.39307, 13.04020,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1364, 1906.18286, 2427.99976, 10.78810,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1364, 1935.15369, 2427.63745, 10.78030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1360, 1925.92041, 2419.80347, 10.77600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1360, 1925.87476, 2422.34717, 10.77600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(936, 1965.95923, 2433.89917, 16.32770,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(936, 1965.97046, 2432.16064, 16.32770,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(936, 1965.99329, 2430.46680, 16.32770,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(936, 1966.01111, 2430.10034, 16.32770,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1671, 1964.40039, 2433.48511, 16.46320,   0.00000, 0.00000, 67.50000);
	CreateDynamicObject(1671, 1964.60071, 2431.63330, 16.46320,   0.00000, 0.00000, 112.50000);
	CreateDynamicObject(1671, 1964.75659, 2430.04639, 16.46320,   0.00000, 0.00000, 101.25000);
	CreateDynamicObject(2495, 1923.92920, 2427.42432, 13.10900,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2499, 1917.17932, 2426.16455, 16.16800,   286.94791, 0.00000, 270.00000);
	CreateDynamicObject(2500, 1966.43896, 2429.67432, 16.80070,   0.00000, 0.00000, 270.00009);
	CreateDynamicObject(2500, 1966.43567, 2433.67334, 16.80070,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1280, 1915.48938, 2416.21484, 10.40540,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1280, 1918.93848, 2416.19873, 10.40540,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1280, 1911.89221, 2420.33130, 10.40540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(4866, 2139.00488, 1612.28271, 455.92230,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3491, 2177.28809, 1644.39612, 464.51440,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 2009.95325, 1446.04456, 9.79520,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3749, 1988.31421, 1444.66052, 15.33740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1981.03491, 1446.51135, 9.82030,   0.00000, 0.00000, 199.76711);
	CreateDynamicObject(987, 1925.70142, 1283.52124, 9.82030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1914.50232, 1287.66675, 9.81290,   0.00000, 0.00000, 339.37350);
	CreateDynamicObject(9241, 1900.10828, 1329.30786, 25.35260,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(9241, 1899.68750, 1359.95947, 25.37770,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(11490, 1876.55261, 1303.26111, 54.36880,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11490, 1859.39307, 1318.04004, 54.37950,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(11491, 1876.51086, 1292.23254, 55.85900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11491, 1848.32727, 1318.08826, 55.77200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(980, 1901.24597, 1305.82471, 55.94630,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(980, 1907.07288, 1300.03320, 55.94630,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(980, 1901.31384, 1294.27576, 55.97140,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(980, 1901.26416, 1303.08875, 58.67160,   89.27700, 0.00000, 0.00000);
	CreateDynamicObject(980, 1901.30554, 1297.05542, 58.69660,   90.24070, 0.00000, 0.00000);
	CreateDynamicObject(987, 1881.58411, 1377.42395, 23.71870,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1893.45361, 1377.27942, 23.71870,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 1881.61584, 1365.35156, 23.71870,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1905.31165, 1377.24512, 23.71870,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 1916.39771, 1377.20044, 23.71870,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 1916.28955, 1365.34656, 23.71870,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(987, 1916.39063, 1353.27966, 23.71870,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(987, 1916.44104, 1341.33142, 23.71870,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(987, 1916.33704, 1329.45923, 23.71870,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(987, 1916.11743, 1317.80652, 23.71870,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(987, 1916.11096, 1313.23584, 23.71870,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(987, 1904.42273, 1313.73962, 23.71870,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1892.45605, 1313.79578, 23.71870,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1881.69714, 1313.79395, 23.71870,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1881.81824, 1325.68262, 23.71870,   0.00000, 0.00000, 269.99991);
	CreateDynamicObject(987, 1881.93872, 1337.57275, 23.71870,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1881.98425, 1349.56531, 23.71870,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2714, 1946.83191, 1277.97485, 16.11750,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14416, 1879.28174, 1351.60864, 20.54260,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(14416, 1874.18066, 1351.62524, 16.89270,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(16151, 1880.10107, 1302.74744, 56.26820,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(974, 1852.08936, 1349.71326, 54.35070,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1852.01245, 1356.21545, 54.37030,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1851.95654, 1362.87256, 54.37580,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1852.14404, 1343.06885, 54.35070,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1852.23523, 1336.46301, 54.34130,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1852.30603, 1329.81531, 54.35680,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1852.37146, 1323.22180, 54.34570,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(8148, 2032.01807, 1364.86450, 12.92120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3749, 1947.85107, 1283.48474, 15.59340,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 2021.92554, 1446.05676, 9.82030,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 2032.27832, 1446.03101, 9.82030,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 2020.31226, 1283.45093, 9.82030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 2008.33777, 1283.41345, 9.82030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1996.37524, 1283.43042, 9.82030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1984.47034, 1283.46045, 9.81290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1972.64355, 1283.43530, 9.82030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1960.84521, 1283.45325, 9.82030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1954.78796, 1283.11230, 9.82030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(974, 1880.88245, 1289.51245, 54.20050,   269.75909, 0.00000, 0.00000);
	CreateDynamicObject(974, 1887.50867, 1289.45715, 54.22570,   269.75909, 0.00000, 0.00000);
	CreateDynamicObject(974, 1894.13086, 1289.45923, 54.25070,   269.75909, 0.00000, 0.00000);
	CreateDynamicObject(974, 1900.68506, 1289.43848, 54.27560,   269.75909, 0.00000, 0.00000);
	CreateDynamicObject(974, 1907.34790, 1289.44543, 54.28740,   269.75909, 0.00000, 0.00000);
	CreateDynamicObject(974, 1870.87915, 1310.95386, 54.32560,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.80322, 1317.60046, 54.31610,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.74097, 1324.22595, 54.32580,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.68213, 1330.87366, 54.32560,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.61865, 1337.52795, 54.31460,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.53625, 1344.21704, 54.32560,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.45996, 1350.81104, 54.32580,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.36755, 1357.44006, 54.29650,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.31836, 1364.10046, 54.29890,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1877.60071, 1308.73572, 54.29480,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.29456, 1370.77332, 54.29350,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1869.72656, 1376.00305, 54.28300,   269.75909, 0.00000, 179.51781);
	CreateDynamicObject(974, 1863.05542, 1376.07544, 54.27800,   269.75909, 0.00000, 179.51781);
	CreateDynamicObject(982, 1873.50732, 1324.89832, 54.99160,   0.00000, 359.14050, 0.85930);
	CreateDynamicObject(982, 1873.17395, 1350.48596, 55.00690,   0.00000, 359.14050, 0.85930);
	CreateDynamicObject(984, 1872.97705, 1369.65637, 54.91170,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(983, 1872.98181, 1375.47107, 54.95660,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(982, 1849.49158, 1337.17334, 55.02450,   0.00000, 358.28101, 0.45460);
	CreateDynamicObject(984, 1866.59888, 1378.82104, 54.91510,   0.00000, 0.00000, 269.75900);
	CreateDynamicObject(983, 1864.36304, 1373.30725, 54.95240,   0.00000, 0.00000, 269.75909);
	CreateDynamicObject(983, 1867.64526, 1370.07471, 54.97880,   0.00000, 0.00000, 181.23711);
	CreateDynamicObject(983, 1864.49756, 1366.88452, 55.05650,   0.00000, 0.00000, 90.13680);
	CreateDynamicObject(984, 1849.31335, 1356.45544, 55.01030,   0.00000, 0.00000, 0.85930);
	CreateDynamicObject(974, 1851.95862, 1364.18176, 54.37570,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(984, 1855.62122, 1367.52393, 54.99470,   0.00000, 0.00000, 269.75900);
	CreateDynamicObject(983, 1849.24646, 1364.34656, 55.06120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(983, 1859.75354, 1375.62683, 54.95460,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(983, 1876.90247, 1312.10693, 54.99450,   0.00000, 0.00000, 270.61850);
	CreateDynamicObject(974, 1874.55994, 1308.71558, 54.31620,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(983, 1880.34155, 1308.87781, 54.99860,   0.00000, 0.00000, 180.37750);
	CreateDynamicObject(982, 1890.40247, 1286.79675, 54.88150,   0.00000, 0.00000, 269.75900);
	CreateDynamicObject(983, 1877.56555, 1290.03955, 54.87360,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(984, 1904.17786, 1286.75757, 54.85170,   0.00000, 0.85930, 269.75900);
	CreateDynamicObject(984, 1910.62585, 1293.10754, 54.85960,   0.00000, 0.85930, 179.51801);
	CreateDynamicObject(8149, 1841.69678, 1371.55615, 19.02330,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(8209, 1890.93933, 1442.79626, 19.02330,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(8210, 1944.64734, 1442.79956, 19.02330,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(8210, 1869.35510, 1293.07056, 19.02330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1905.51697, 1293.15625, 15.92230,   0.00000, 0.00000, 359.14050);
	CreateDynamicObject(3279, 1854.57117, 1364.70251, 54.43240,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3528, 1876.75415, 1295.44104, 52.71560,   0.00000, 223.34950, 0.00000);
	CreateDynamicObject(3528, 1852.34460, 1317.47180, 52.87630,   0.00000, 223.34950, 0.00000);
	CreateDynamicObject(1231, 1882.56982, 1292.28711, 57.10350,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2790, 1881.46851, 1357.18372, 21.55690,   0.00000, 0.00000, 269.75900);
	CreateDynamicObject(14467, 1889.79431, 1296.01868, 57.10680,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14806, 1855.90002, 1313.78955, 56.97330,   0.00000, 0.00000, 179.51820);
	CreateDynamicObject(2628, 1854.03162, 1321.88782, 55.88140,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2575, 1860.38586, 1320.06616, 56.26950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1828, 1856.92627, 1318.10095, 55.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1736, 1852.46106, 1318.06201, 58.09180,   0.00000, 0.00000, 90.24080);
	CreateDynamicObject(1736, 1876.56873, 1296.30396, 57.83290,   0.00000, 0.00000, 182.09660);
	CreateDynamicObject(14491, 1848.87732, 1318.06885, 58.25230,   0.00000, 0.00000, 182.95621);
	CreateDynamicObject(1704, 1875.21375, 1301.50244, 55.87340,   0.00000, 0.00000, 317.02811);
	CreateDynamicObject(1723, 1872.52905, 1298.55408, 55.87450,   0.00000, 0.00000, 90.99630);
	CreateDynamicObject(1724, 1876.18115, 1298.56274, 55.87450,   0.00000, 0.00000, 230.98039);
	CreateDynamicObject(1825, 1872.64392, 1292.47705, 55.84140,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1827, 1874.27417, 1299.56995, 55.87500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11631, 1873.09656, 1306.78992, 57.12250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2356, 1873.19531, 1306.13806, 55.87120,   0.00000, 0.00000, 329.91971);
	CreateDynamicObject(2596, 1880.76636, 1297.95886, 58.61440,   0.00000, 0.00000, 263.74310);
	CreateDynamicObject(2232, 1872.36646, 1301.39270, 56.47430,   0.00000, 0.00000, 94.53800);
	CreateDynamicObject(2232, 1872.35974, 1297.70190, 56.47430,   0.00000, 0.00000, 91.10030);
	CreateDynamicObject(2101, 1872.14783, 1303.10095, 55.87960,   0.00000, 0.00000, 88.52200);
	CreateDynamicObject(1828, 1874.66565, 1299.14502, 55.84930,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1665, 1879.12476, 1302.26831, 56.93420,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1551, 1873.83862, 1299.19495, 56.54190,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1551, 1873.91125, 1299.91882, 56.54190,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1551, 1874.54163, 1299.07690, 56.51680,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1551, 1874.18054, 1299.63306, 56.54190,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1665, 1874.68176, 1299.64673, 56.33710,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1485, 1874.92834, 1299.70837, 56.35160,   0.00000, 0.00000, 192.40981);
	CreateDynamicObject(625, 1878.37976, 1292.75830, 56.71900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1364, 1861.68164, 1362.42505, 55.15710,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1364, 1889.22314, 1294.85864, 55.11180,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1361, 1847.83313, 1322.82825, 56.51960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1597, 1865.25537, 1342.04224, 57.03040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1597, 1865.23755, 1334.65283, 57.03040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1597, 1865.28992, 1349.71692, 57.03040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1597, 1865.28210, 1357.28052, 57.03040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, 1855.61243, 1364.76733, 62.27410,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, 1907.92566, 1291.69971, 54.43610,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1597, 1854.74585, 1355.50610, 57.03040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1597, 1854.78345, 1348.20276, 57.03040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1597, 1854.79431, 1341.20032, 57.03040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18449, 2313.15088, 553.18188, 43.87440,   0.00000, 348.82730, 303.75000);
	CreateDynamicObject(18449, 2356.17920, 488.72269, 62.81820,   0.00000, 343.67068, 303.75000);
	CreateDynamicObject(18449, 2397.83423, 426.43970, 89.01690,   0.00000, 337.65460, 303.75000);
	CreateDynamicObject(18449, 2436.38232, 368.87149, 122.37540,   0.00000, 330.77921, 303.75000);
	CreateDynamicObject(18449, 2473.98364, 312.57431, 162.98930,   0.00000, 327.34140, 303.75000);
	CreateDynamicObject(18449, 2508.60742, 260.76511, 206.18240,   0.00000, 323.04419, 303.75000);
	CreateDynamicObject(18449, 2542.05786, 210.70309, 255.92210,   0.00000, 317.88760, 303.75000);
	CreateDynamicObject(18449, 2574.90771, 161.57671, 309.38620,   0.00000, 317.88760, 303.75000);
	CreateDynamicObject(18449, 2607.52539, 112.84410, 362.43289,   0.00000, 317.88760, 303.75000);
	CreateDynamicObject(18449, 2639.95288, 64.35220, 415.16641,   0.00000, 317.88760, 303.75000);
	CreateDynamicObject(18449, 2672.41138, 15.71990, 468.02780,   0.00000, 317.88760, 303.75000);
	CreateDynamicObject(18449, 2703.46460, -30.64070, 518.51270,   0.00000, 317.88760, 303.75000);
	CreateDynamicObject(18449, 2735.89014, -79.11710, 571.27271,   0.00000, 317.88760, 303.75000);
	CreateDynamicObject(8040, 2774.06372, -136.88220, 599.05371,   0.00000, 0.00000, 123.75000);
	CreateDynamicObject(1632, 2285.41968, 587.02142, 37.86520,   0.00000, 0.00000, 33.75000);
	CreateDynamicObject(1632, 2288.90894, 589.35938, 37.92020,   0.00000, 0.00000, 33.75000);
	CreateDynamicObject(1632, 2292.38721, 591.69092, 37.91400,   0.00000, 0.00000, 33.75000);
	CreateDynamicObject(1225, 2246.67529, 633.01892, 53.82760,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 2258.56543, 649.63751, 55.53760,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 2222.37891, 681.14899, 68.08850,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 2230.23535, 710.24451, 78.07760,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 2158.55786, 746.26923, 44.00110,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 2199.41919, 691.28131, 64.17230,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 2177.16553, 746.65167, 44.33660,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16192, 8206.02148, -1661.89966, -39.76140,   0.85940, 354.84341, 358.28110);
	CreateDynamicObject(16061, 8215.81836, -1678.86133, 3.19320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16061, 8236.56934, -1700.83496, 1.40770,   0.00000, 1.71890, 289.52621);
	CreateDynamicObject(16061, 8198.54102, -1683.78992, 2.57930,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(739, 8198.68555, -1718.59241, -37.94920,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(619, 8234.58203, -1731.22742, 3.49250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18259, 8215.67871, -1724.30811, 5.97020,   0.00000, 0.00000, 84.22480);
	CreateDynamicObject(1481, 8224.15332, -1730.51941, 6.70920,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1495, 8214.94824, -1729.40930, 6.05080,   0.00000, 0.00000, 208.73900);
	CreateDynamicObject(14805, 8221.11621, -1725.12427, 6.94290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2297, 8221.36719, -1720.13049, 6.05010,   0.00000, 0.00000, 315.30930);
	CreateDynamicObject(1667, 8221.99316, -1726.35339, 6.81970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1828, 8222.03906, -1722.85754, 6.02880,   0.00000, 0.00000, 84.12080);
	CreateDynamicObject(1829, 8224.08398, -1721.61194, 6.52060,   0.00000, 1.71890, 268.04031);
	CreateDynamicObject(14527, 8221.28223, -1724.78125, 7.00980,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1815, 8223.33887, -1728.32703, 6.05530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1668, 8224.04199, -1727.69434, 6.71840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1669, 8224.04395, -1727.86243, 6.71840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1667, 8223.57520, -1727.67957, 6.64030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1664, 8224.27344, -1727.81958, 6.69340,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1665, 8223.76660, -1727.98816, 6.58720,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1512, 8224.12402, -1728.07434, 6.72420,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2344, 8218.93457, -1725.04163, 32.84900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14446, 8210.63867, -1724.01697, 6.65640,   0.00000, 0.00000, 86.69910);
	CreateDynamicObject(1742, 8208.60840, -1728.13721, 6.05160,   0.00000, 0.00000, 83.26140);
	CreateDynamicObject(2190, 8210.17578, -1719.88831, 6.87670,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2568, 8209.75000, -1720.07129, 6.04830,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1671, 8210.49121, -1720.96667, 6.46440,   0.00000, 0.00000, 210.45799);
	CreateDynamicObject(643, 8222.77637, -1734.05994, 6.50160,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1280, 8222.36035, -1730.18591, 6.45750,   0.00000, 0.00000, 88.41800);
	CreateDynamicObject(1243, 8185.55713, -1824.73962, -1.95240,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1243, 8148.47754, -1789.25305, -2.52650,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11496, 8201.72754, -1768.80591, 1.75260,   0.85940, 0.00000, 226.78729);
	CreateDynamicObject(1608, 8190.76367, -1793.90247, -1.31310,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1608, 8188.05420, -1778.43652, -1.32460,   4.29720, 0.00000, 249.13271);
	CreateDynamicObject(1608, 8173.27295, -1794.74341, -1.20600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16097, 8270.33594, -1702.61768, -10.96830,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1458, 8219.59277, -1740.30408, 5.83180,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1457, 8232.07520, -1728.20459, 7.28150,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 8218.53516, -1759.69580, 3.63590,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2035, 8222.08691, -1725.63379, 6.75550,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(854, 8218.78516, -1759.33838, 5.21850,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1280, 8220.29883, -1759.75110, 5.68580,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1318, 3071.58545, -1510.64526, 1414.88855,   69.61430, 8.59440, 262.02429);
	CreateDynamicObject(8150, -1080.10181, -1055.48206, 131.31290,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(8150, -1017.44373, -993.03278, 131.28870,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(8150, -1079.57068, -931.01971, 131.31979,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8152, -1096.84644, -1025.83069, 131.31979,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(8210, -1176.51819, -973.46619, 131.18800,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(8210, -1148.49744, -930.97418, 131.31979,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3749, -1175.37280, -939.65747, 133.87720,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3279, -1022.73969, -936.76563, 127.99440,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3279, -1022.07257, -1051.78564, 128.19440,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3279, -1171.80872, -1049.72546, 128.24440,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3279, -1170.97070, -952.19537, 128.06940,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3797, -1177.47290, -946.96222, 132.58260,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(9623, -1209.07043, -1073.84668, 129.95990,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(8034, -1033.58032, -987.52380, 132.96320,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3866, -1165.88318, -1041.87329, 135.95731,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3866, -1028.60205, -944.94220, 135.95731,   0.00000, 0.00000, 269.99991);
	CreateDynamicObject(8513, -1105.56555, -990.64850, 132.28070,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3279, -1151.38696, -1006.01099, 127.94440,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(5520, -1089.66345, -1012.88831, 133.16350,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3641, -1144.48633, -994.83942, 130.56129,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3640, -1151.55249, -978.60498, 132.55540,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3624, -1206.99902, -922.83789, 131.64040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(13696, -1091.37317, -962.77032, 128.23160,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(6922, -1123.80212, -960.93768, 130.97200,   0.00000, 0.00000, 269.99991);
	CreateDynamicObject(4178, -1113.76233, -1018.35052, 131.26579,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(17522, -1063.70862, -1040.58435, 130.46320,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3409, -1071.95374, -934.89270, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1067.72803, -935.10211, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1063.82263, -935.29773, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1060.13330, -935.36469, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1071.58264, -939.67822, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1071.70117, -944.25812, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1072.01135, -948.52191, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1067.56738, -939.74011, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1063.66821, -939.90631, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1067.70251, -944.18219, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1068.02466, -948.70752, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1063.69312, -944.28192, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1063.97778, -948.66321, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1060.14551, -939.94952, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1060.12732, -948.52008, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1059.95483, -944.29791, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(640, -1057.96191, -933.56909, 128.91580,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(640, -1057.78101, -948.00220, 128.91580,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(644, -1057.51233, -944.55249, 128.72780,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(644, -1057.75232, -937.12622, 128.72780,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -1208.49023, -1068.36340, 127.88940,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -1177.66138, -1095.67236, 128.62450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -1141.20044, -1094.57153, 128.62450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -1132.58301, -1096.12610, 128.62450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -1093.97119, -1095.26074, 128.62450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -1081.64343, -1095.55847, 128.62450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3279, -1035.49475, -985.67682, 136.77480,   0.00000, 0.00000, 0.00020);
	CreateDynamicObject(16644, -1052.92102, -966.65167, 136.47630,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16644, -1054.55420, -1011.11560, 136.49471,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1553, -1052.37549, -1001.47852, 129.41260,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1553, -1054.24158, -1001.49908, 129.41260,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1553, -1052.36780, -1001.58557, 131.81419,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1553, -1054.30066, -1001.58600, 131.79890,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1425, -1054.69189, -955.24921, 128.67120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18259, -1039.58203, -1049.18103, 129.86780,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1704, -1033.22620, -1052.54138, 129.95061,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1723, -1039.44263, -1053.35254, 129.95180,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1825, -1045.85266, -1050.48242, 129.93190,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2008, -1048.37073, -1045.27014, 129.95370,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2079, -1048.00952, -1046.32996, 130.51450,   0.00000, 0.00000, 225.00000);
	CreateDynamicObject(2125, -1046.00452, -1050.47632, 130.26360,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2166, -1046.38440, -1045.26001, 129.95370,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1670, -1046.06299, -1050.50085, 130.83611,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16770, -1151.76160, -961.95349, 138.11501,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14445, -1092.50867, -987.45349, 134.25340,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14445, -1092.93286, -979.95532, 134.25340,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(17044, -1173.83728, -996.62872, 128.21581,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18234, -1119.60925, -940.86121, 136.49451,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(16386, -1100.13208, -1039.35559, 139.52811,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(12959, -1036.44128, -1024.78711, 127.83210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(974, -1023.69263, -1029.00732, 130.83670,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(974, -1020.52551, -1028.97961, 130.82150,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1407, -1042.10254, -1019.21411, 128.89371,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1407, -1042.10144, -1019.68372, 130.29201,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1407, -1042.15039, -1019.67468, 131.71741,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3797, -1177.47290, -932.03748, 132.23779,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1245, -1182.44458, -908.98102, 129.43140,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3749, -1047.92627, -1312.27563, 132.69769,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1503, -1195.82007, -1332.20398, 151.83620,   0.00000, 0.00000, 168.75000);
	CreateDynamicObject(1632, -1256.34021, -1482.15918, 103.97420,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1632, -1398.64478, -1617.89355, 102.22350,   0.00000, 0.00000, 168.75000);
	CreateDynamicObject(2931, -1429.21448, -957.63647, 199.73869,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3877, -1208.50415, -1079.42310, 128.89940,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, -1039.99268, -1314.37549, 129.20050,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, -1055.87024, -1314.37549, 129.41920,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, -1323.20837, -1377.90039, 115.99820,   0.00000, 0.00000, 33.75000);
	CreateDynamicObject(3877, -1322.23010, -1394.99915, 115.22460,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11387, 26.56055, -179.84863, 4.16689,   0.00000, 0.00000, 267.37427);
	CreateDynamicObject(5340, 56.35268, -159.20813, 1.21843,   0.00000, 0.00000, 87.33951);
	CreateDynamicObject(5340, 52.17810, -159.02910, 1.16002,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(5340, 45.23961, -158.70261, -0.35807,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(5340, 38.22668, -158.35535, -0.33998,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(5340, 31.25660, -158.03607, -0.33998,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(5340, 24.25727, -157.68417, -0.31498,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(5340, 17.27944, -157.35394, -0.29185,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(5340, 10.29852, -157.05975, -0.28998,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(5340, 6.75059, -156.86191, -0.28998,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(5340, 0.14672, -158.26692, -0.27549,   0.00000, 0.00000, 117.11078);
	CreateDynamicObject(5340, -1.17411, -158.87291, -0.28385,   0.00000, 0.00000, 117.10876);
	CreateDynamicObject(5340, -4.61533, -163.96423, -0.27296,   0.00000, 0.00000, 174.67383);
	CreateDynamicObject(5340, -5.13277, -170.94362, -0.26756,   0.00000, 0.00000, 176.65662);
	CreateDynamicObject(5340, -5.67937, -177.93579, -0.25374,   0.00000, 0.00000, 174.67163);
	CreateDynamicObject(5340, -6.08142, -184.84065, -0.27328,   0.00000, 0.00000, 178.64160);
	CreateDynamicObject(5340, 59.58478, -162.95731, 1.23333,   0.00000, 0.00000, 357.26990);
	CreateDynamicObject(5340, 59.22168, -170.10059, 1.24632,   0.00000, 0.00000, 357.25061);
	CreateDynamicObject(5340, 59.32031, -169.52441, 0.77132,   0.00000, 0.00000, 357.49524);
	CreateDynamicObject(5340, 58.86816, -177.09082, 1.25605,   0.00000, 0.00000, 356.26465);
	CreateDynamicObject(5340, 58.86035, -178.10059, 1.22668,   0.00000, 0.00000, 357.26196);
	CreateDynamicObject(2790, 58.62207, -184.26758, -0.68280,   0.00000, 0.00000, 267.68188);
	CreateDynamicObject(2790, 58.42773, -189.41016, -0.68280,   0.00000, 0.00000, 267.68188);
	CreateDynamicObject(2790, 58.23633, -194.56445, -0.68280,   0.00000, 0.00000, 267.68188);
	CreateDynamicObject(2790, 58.17578, -196.39453, -0.68280,   0.00000, 0.00000, 267.68188);
	CreateDynamicObject(4100, 58.45185, -188.00914, 2.19727,   0.00000, 0.00000, 48.13977);
	CreateDynamicObject(4100, 36.43985, -158.20877, 2.94175,   0.00000, 0.00000, 317.58032);
	CreateDynamicObject(4100, 22.70215, -157.54785, 2.94175,   0.00000, 0.00000, 317.57080);
	CreateDynamicObject(4100, 10.28987, -156.99661, 2.96675,   0.00000, 0.00000, 317.57629);
	CreateDynamicObject(4100, -4.76478, -167.13228, 2.66657,   0.00000, 0.00000, 46.15161);
	CreateDynamicObject(4100, -5.72656, -180.82227, 2.63619,   0.00000, 0.00000, 46.14807);
	CreateDynamicObject(4100, 7.19328, -196.63792, 2.32544,   0.00000, 0.00000, 317.07629);
	CreateDynamicObject(4100, 20.92610, -197.44850, 2.29748,   0.00000, 0.00000, 317.06543);
	CreateDynamicObject(4100, 34.63588, -198.17728, 2.27523,   0.00000, 0.00000, 317.06543);
	CreateDynamicObject(971, -0.47949, -158.67480, 0.32820,   0.00000, 0.00000, 27.02087);
	CreateDynamicObject(971, -3.60352, -191.51465, 0.16939,   0.00000, 0.00000, 306.90308);
	CreateDynamicObject(1358, 0.16992, -193.88184, 1.70422,   0.00000, 0.00000, 124.09607);
	CreateDynamicObject(11102, 46.01953, -180.63086, 2.84552,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(11102, 27.27353, -166.00508, 2.93513,   0.00000, 0.00000, 356.51184);
	CreateDynamicObject(11389, 43.05957, -171.22559, 3.92127,   0.00000, 0.00000, 266.96777);
	CreateDynamicObject(11388, 43.09195, -171.15900, 7.49259,   0.00000, 0.00000, 86.99243);
	CreateDynamicObject(11391, 35.43945, -162.72168, 2.03502,   0.00000, 0.00000, 266.68213);
	CreateDynamicObject(2007, 27.91305, -176.51443, 0.80751,   0.00000, 0.00000, 87.88196);
	CreateDynamicObject(1757, 34.11213, -178.86681, 0.80751,   0.00000, 0.00000, 141.29211);
	CreateDynamicObject(2069, 35.94893, -178.88513, 0.80751,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1491, 36.21052, -172.19794, 0.86190,   0.00000, 0.00000, 171.73047);
	CreateDynamicObject(2008, 30.32275, -173.19922, 0.80751,   0.00000, 0.00000, 240.40527);
	CreateDynamicObject(1714, 28.85593, -172.99274, 0.80751,   0.00000, 0.00000, 49.62469);
	CreateDynamicObject(2007, 32.96288, -162.62151, 0.48251,   0.00000, 0.00000, 359.24744);
	CreateDynamicObject(2007, 32.08995, -162.58237, 0.48251,   0.00000, 0.00000, 359.24744);
	CreateDynamicObject(2007, 31.49732, -162.53363, 0.60751,   0.00000, 0.00000, 359.24744);
	CreateDynamicObject(2007, 37.18751, -162.59224, 0.20751,   0.00000, 0.00000, 359.24744);
	CreateDynamicObject(2007, 38.36195, -162.72304, 0.20751,   0.00000, 0.00000, 356.77747);
	CreateDynamicObject(2007, 42.29297, -163.14099, 0.53251,   0.00000, 0.00000, 359.24744);
	CreateDynamicObject(2007, 41.31987, -163.07298, 0.58251,   0.00000, 0.00000, 359.24744);
	CreateDynamicObject(2007, 40.74393, -163.00165, 0.53251,   0.00000, 0.00000, 359.24744);
	CreateDynamicObject(2000, 44.92541, -164.90088, 0.25751,   0.00000, 0.00000, 11.90991);
	CreateDynamicObject(2000, 51.87433, -168.11658, 0.20751,   0.00000, 0.00000, 11.90918);
	CreateDynamicObject(2000, 49.96492, -164.92735, 0.28251,   0.00000, 0.00000, 39.31915);
	CreateDynamicObject(2000, 51.56833, -165.36832, 0.60751,   0.00000, 0.00000, 39.31458);
	CreateDynamicObject(2000, 52.68855, -165.54926, 0.50751,   0.00000, 0.00000, 39.31458);
	CreateDynamicObject(2000, 52.94043, -164.41406, 0.63950,   0.00000, 0.00000, 39.30908);
	CreateDynamicObject(2000, 51.69089, -164.33868, 0.65751,   0.00000, 0.00000, 39.31458);
	CreateDynamicObject(2596, 36.80920, -172.93488, 3.73337,   0.00000, 0.00000, 298.92041);
	CreateDynamicObject(1432, 39.71329, -177.30106, 0.80751,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2893, 54.27148, -169.07520, 2.04404,   7.93762, 0.00000, 356.24268);
	CreateDynamicObject(2893, 56.05827, -169.21112, 2.03404,   7.93762, 0.00000, 357.49512);
	CreateDynamicObject(2893, 56.45573, -163.46516, 1.97140,   343.13269, 0.00000, 355.99512);
	CreateDynamicObject(2893, 54.60925, -163.39313, 1.95904,   343.13049, 0.00000, 355.98999);
	CreateDynamicObject(2893, 45.87572, -168.58266, 2.03404,   7.93762, 0.00000, 356.24268);
	CreateDynamicObject(2893, 47.68534, -168.67912, 2.05904,   7.93762, 0.00000, 356.24268);
	CreateDynamicObject(2893, 46.17090, -162.80762, 2.01091,   343.12500, 0.00000, 357.48962);
	CreateDynamicObject(2893, 47.99295, -162.96185, 1.98404,   343.12500, 0.00000, 357.23962);
	CreateDynamicObject(910, 28.60036, -162.30627, 2.07667,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3399, 38.01497, -160.10847, 2.82655,   0.00000, 0.00000, 358.51501);
	CreateDynamicObject(11390, 43.03790, -171.19501, 5.16304,   0.00000, 0.00000, 266.70410);
	CreateDynamicObject(3465, 32.90332, -192.45117, 2.32615,   0.00000, 0.00000, 87.99500);
	CreateDynamicObject(3465, 31.16260, -192.51579, 2.32615,   0.00000, 0.00000, 87.99500);
	CreateDynamicObject(16442, 59.25047, -134.99010, 2.23747,   0.00000, 323.99496, 313.99686);
	CreateDynamicObject(16442, 60.19197, -136.45178, 1.72030,   0.00000, 357.99500, 317.99683);
	CreateDynamicObject(18451, 69.98685, -171.98593, 0.83994,   0.00000, 0.00000, 28.00000);
	CreateDynamicObject(13591, 63.68237, -188.60506, 0.84462,   0.00000, 0.00000, 62.00000);
	CreateDynamicObject(1650, 44.88538, -164.74315, 1.96856,   0.00000, 0.00000, 232.00000);
	CreateDynamicObject(2190, 41.82040, -162.53230, 2.05441,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1650, 34.89258, -192.45605, 1.31730,   0.00000, 0.00000, 267.99500);
	CreateDynamicObject(622, 2020.82068, 868.35925, 6.89552,   0.00000, 0.00000, 230.00000);
	CreateDynamicObject(622, 1998.00000, 871.67877, 7.62248,   0.00000, 0.00000, 190.00000);
	CreateDynamicObject(622, 1968.00000, 871.67877, 7.65455,   0.00000, 0.00000, 310.00000);
	CreateDynamicObject(622, 1958.00000, 871.67877, 7.58669,   0.00000, 0.00000, 160.00000);
	CreateDynamicObject(622, 1943.90552, 872.85449, 7.77802,   0.00000, 0.00000, 100.00000);
	CreateDynamicObject(622, 1903.34595, 886.24139, 9.82031,   0.00000, 0.00000, 230.00000);
	CreateDynamicObject(622, 1884.53137, 867.72406, 8.06091,   0.00000, 0.00000, 220.00000);
	CreateDynamicObject(622, 1866.01172, 879.42682, 9.01543,   0.00000, 0.00000, 159.99756);
	CreateDynamicObject(622, 1835.51465, 881.36383, 9.38833,   0.00000, 0.00000, 189.99756);
	CreateDynamicObject(622, 1828.00000, 871.67877, 9.69951,   0.00000, 0.00000, 189.99756);
	CreateDynamicObject(622, 1848.00000, 871.67877, 9.03566,   0.00000, 0.00000, 319.99756);
	CreateDynamicObject(622, 2026.00000, 816.99774, 7.38044,   0.00000, 0.00000, 9.99756);
	CreateDynamicObject(622, 2001.23401, 812.07776, 8.07941,   0.00000, 0.00000, 9.99756);
	CreateDynamicObject(622, 1986.00000, 816.99774, 6.96743,   0.00000, 0.00000, 139.99756);
	CreateDynamicObject(622, 1966.00000, 816.99774, 6.88988,   0.00000, 0.00000, 349.99756);
	CreateDynamicObject(622, 1946.00000, 816.99774, 6.77081,   0.00000, 0.00000, 181.99756);
	CreateDynamicObject(622, 1906.00000, 816.99774, 7.52205,   0.00000, 0.00000, 309.99756);
	CreateDynamicObject(622, 1877.17212, 812.68274, 8.89715,   0.00000, 0.00000, 49.99756);
	CreateDynamicObject(622, 1836.00000, 816.99774, 9.38833,   0.00000, 0.00000, 319.99756);
	CreateDynamicObject(622, 1823.24792, 817.92896, 9.80036,   0.00000, 0.00000, 39.99756);
	CreateDynamicObject(655, 1762.26343, 865.13611, 9.39277,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1735.83691, 873.53796, 9.17781,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1705.93872, 873.82703, 8.86212,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(674, 1704.65637, 818.87726, 7.86910,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(680, 1740.29712, 866.91162, 8.84629,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(683, 1691.36060, 822.40576, 9.26803,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(688, 1751.41211, 872.63312, 9.46542,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(691, 1721.23987, 814.43414, 8.71638,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(694, 1741.57581, 813.07855, 9.16937,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(697, 1703.34338, 866.23822, 7.78747,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(698, 1673.81763, 869.22827, 7.52158,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, 1695.60547, 867.97162, 7.81618,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1678.65308, 814.01013, 8.04939,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1648.13074, 879.00702, 8.98481,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(707, 1656.35107, 820.35522, 6.45502,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(708, 1664.67761, 805.60693, 9.35037,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(709, 1649.50671, 803.46619, 9.77064,   0.00000, 0.00000, 80.00000);
	CreateDynamicObject(711, 1646.83606, 867.86774, 12.77526,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(714, 1633.65991, 875.70441, 8.33644,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1639.30078, 866.55115, 6.53950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1658.76392, 868.83008, 7.03055,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1685.46313, 870.42871, 7.98701,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1695.86707, 878.69977, 9.21894,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1721.87769, 874.35461, 9.09256,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(697, 1729.58691, 865.02197, 8.42792,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(688, 1712.38684, 875.85297, 9.08705,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(719, 1615.22437, 816.25507, 7.25995,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(726, 1603.32861, 817.37054, 7.04097,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(726, 1621.75623, 805.72174, 9.32783,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(727, 1643.64795, 861.82800, 9.59064,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(732, 1617.95386, 866.69299, 6.56734,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(763, 1622.80371, 866.68945, 6.56664,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(790, 1597.78967, 881.95514, 8.59229,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(882, 1614.34766, 818.91779, 6.73721,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(641, 1603.48157, 812.26093, 8.04408,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(654, 1602.91846, 807.56262, 8.96643,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1589.57153, 814.21216, 7.66101,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(707, 1609.31396, 798.87006, 9.82031,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1600.10400, 874.50549, 8.82134,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(671, 1533.52429, 865.53839, 18.74180,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(689, 1524.08069, 869.19702, 11.52369,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(694, 1504.98389, 810.01794, 8.49971,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1490.29309, 861.03229, 32.45473,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1482.85852, 812.38440, 8.04125,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1548.79932, 811.24091, 8.24432,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(709, 1541.54626, 872.29309, 7.70359,   0.00000, 0.00000, 79.99695);
	CreateDynamicObject(711, 1515.59863, 866.86896, 12.69181,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(708, 1504.21558, 813.02814, 4.92298,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(715, 1486.78711, 867.51648, 18.15403,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(730, 1527.90747, 818.28668, 6.86111,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1471.70593, 807.24023, 9.03783,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(883, 1486.38647, 871.97070, 16.84325,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3517, 1503.01379, 872.36603, 18.93052,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(622, 1714.60034, 875.65240, 9.06733,   0.00000, 0.00000, 189.99756);
	CreateDynamicObject(622, 1646.00500, 872.95416, 7.79652,   0.00000, 0.00000, 169.99756);
	CreateDynamicObject(622, 1676.94897, 871.34875, 7.86834,   0.00000, 0.00000, 259.99756);
	CreateDynamicObject(622, 1698.15613, 815.11200, 8.26006,   0.00000, 0.00000, 339.99756);
	CreateDynamicObject(622, 1663.33276, 804.68530, 9.53131,   0.00000, 0.00000, 339.99390);
	CreateDynamicObject(622, 1638.28552, 812.32837, 8.03083,   0.00000, 0.00000, 39.99390);
	CreateDynamicObject(622, 1519.72705, 812.85596, 7.92726,   0.00000, 0.00000, 19.99023);
	CreateDynamicObject(707, 1492.59741, 871.00201, 7.46862,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1768.28296, 813.01276, 9.51764,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(697, 1731.74072, 818.56696, 8.62481,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1753.12036, 814.91663, 9.29890,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1772.56458, 873.20947, 9.65022,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(697, 1855.37000, 812.27948, 9.29714,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1822.81995, 809.42786, 9.82031,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1821.28601, 868.38855, 9.77159,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1878.55127, 876.20374, 9.08663,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1960.46082, 813.31171, 7.83717,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1915.31335, 810.53052, 8.68745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 2014.78650, 870.32483, 7.28141,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(726, 1917.66980, 880.61932, 9.62666,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(726, 1925.56323, 867.14307, 6.91916,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(726, 1973.40759, 812.78754, 7.94007,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(726, 2028.02612, 819.67706, 6.59005,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1940.36938, 822.92151, 5.95059,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1983.84912, 870.33997, 7.28438,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1960.93665, 886.19263, 9.82031,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(709, 1887.74255, 813.30768, 8.18679,   0.00000, 0.00000, 79.99695);
	CreateDynamicObject(709, 1950.32007, 874.20612, 8.04337,   0.00000, 0.00000, 79.99695);
	CreateDynamicObject(672, 1824.88538, 822.21857, 9.60912,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1842.82983, 818.48669, 9.30431,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1860.54297, 881.25049, 9.62476,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1856.86743, 866.91064, 8.75491,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1899.67712, 864.45813, 7.28836,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1971.67358, 871.64264, 7.54011,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1998.46240, 874.66223, 8.13291,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(697, 1905.82166, 891.76501, 9.82031,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(697, 1949.43628, 807.17578, 9.04176,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(698, 1863.42786, 812.12164, 9.23175,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(698, 1884.84143, 862.82288, 7.61020,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(698, 2016.62524, 805.04681, 9.45971,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(698, 2009.09656, 871.60907, 7.53352,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(715, 1462.39819, 873.49878, 14.80230,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(715, 1464.87488, 864.59430, 13.84314,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1464.54614, 816.53961, 7.23624,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1454.26929, 805.16815, 9.43927,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1437.64026, 815.28137, 7.48000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1446.53040, 815.53638, 7.43060,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1437.54138, 880.76929, 9.21884,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1453.62903, 888.55078, 9.82031,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1442.94287, 866.72809, 6.23708,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1393.16980, 812.95233, 8.01795,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3532, 2004.18872, 868.94788, 7.69318,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3532, 1900.06311, 865.89081, 8.14523,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19333, 2106.76709, 953.93042, 14.62031,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7996, 1631.58997, 1585.81006, 17.96000,   0.00000, -90.00000, 0.00000);
	CreateDynamicObject(7996, 1585.06006, 1646.40002, 17.96000,   0.00000, -90.00000, 90.00000);
	CreateDynamicObject(7996, 1522.02002, 1598.84998, 17.96000,   0.00000, -90.00000, 180.00000);
	CreateDynamicObject(7996, 1567.05005, 1544.82996, 17.96000,   0.00000, -90.00000, -90.00000);
	CreateDynamicObject(8171, 1539.53003, 1587.02002, 81.70000,   180.00000, 0.00000, 0.00000);
	CreateDynamicObject(8171, 1579.32996, 1583.45996, 81.70000,   180.00000, 0.00000, 0.00000);
	CreateDynamicObject(8171, 1618.47998, 1579.56995, 81.70000,   180.00000, 0.00000, 0.00000);
	CreateDynamicObject(3095, 1587.45996, 1626.02002, 9.80000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(3095, 1572.52002, 1618.06995, 9.80000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(3095, 1584.96997, 1595.16003, 9.80000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(3095, 1603.47998, 1613.22998, 9.80000,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(3095, 1583.89001, 1611.29004, 9.80000,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(3095, 1572.15002, 1594.98999, 9.80000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(3095, 1563.26001, 1586.56995, 9.80000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(3095, 1538.26001, 1619.31006, 9.80000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(3095, 1564.67004, 1564.66003, 9.80000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(3095, 1564.72998, 1606.35999, 9.80000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(3095, 1543.44995, 1602.10999, 9.80000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(3095, 1553.81995, 1619.54004, 9.80000,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(3095, 1558.68994, 1640.56995, 9.80000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(3095, 1535.43005, 1586.02002, 9.80000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(3095, 1545.89001, 1573.28003, 9.80000,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(3095, 1601.85999, 1583.15002, 9.80000,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(3095, 1587.12000, 1571.48999, 9.80000,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(3095, 1618.54004, 1596.38000, 9.80000,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(3095, 1584.35999, 1557.20996, 9.80000,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(3095, 1614.08997, 1562.39001, 9.80000,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(3095, 1616.84998, 1577.35999, 9.80000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(3095, 1616.31995, 1632.04004, 9.80000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(3095, 1594.90002, 1564.82996, 9.80000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(3095, 1578.57996, 1565.90002, 9.80000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(3095, 1597.93005, 1599.41003, 9.80000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(3095, 1621.98999, 1622.29004, 9.80000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(3095, 1583.40002, 1621.52002, 9.80000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(3095, 1560.80005, 1610.26001, 9.80000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(3095, 1573.95996, 1583.44995, 9.80000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(3095, 1550.20996, 1573.03003, 9.80000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(3095, 1540.35999, 1585.76001, 9.80000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(3095, 1543.07996, 1619.21997, 9.80000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(3095, 1613.82996, 1592.41003, 9.80000,   0.00000, 90.00000, 270.00000);
	CreateDynamicObject(3095, 1563.40002, 1636.81006, 9.80000,   0.00000, 90.00000, 270.00000);
	CreateDynamicObject(3095, 1599.48999, 1569.26001, 9.80000,   0.00000, 90.00000, 270.00000);
	CreateDynamicObject(3095, 1582.48999, 1576.08997, 9.80000,   0.00000, 90.00000, 270.00000);
	CreateDynamicObject(18825, 1537.02002, 1555.43994, 9.79000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18825, 1533.42004, 1637.46997, 9.79000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18825, 1618.15002, 1553.57996, 9.79000,   0.00000, 0.00000, -182.70000);
	CreateDynamicObject(18825, 1618.66003, 1638.28003, 9.79000,   0.00000, 0.00000, -182.70000);
	CreateDynamicObject(18825, 1619.69995, 1597.64001, 46.00000,   90.00000, 0.00000, -182.70000);
	CreateDynamicObject(18825, 1543.83997, 1597.51001, 46.00000,   90.00000, 0.00000, -359.70001);
	CreateDynamicObject(18825, 1573.01001, 1602.08997, 68.61000,   90.00000, 0.00000, -447.72000);
	CreateDynamicObject(18825, 1581.07996, 1597.87000, 23.49000,   90.00000, 0.00000, -265.73999);
	CreateDynamicObject(8339, 1641.13000, 1629.41003, 13.82000,   356.85999, 0.00000, 180.25999);
	CreateDynamicObject(8339, 1641.37000, 1548.52002, 13.82000,   356.85999, 0.00000, 180.56000);
	CreateDynamicObject(16109, -865.31128, 2110.53442, 77.60010,   0.00000, 0.00000, 78.75000);
	CreateDynamicObject(16109, -973.24469, 2270.55493, 118.84680,   0.00000, 0.00000, 123.74990);
	CreateDynamicObject(16109, -1162.09521, 2307.88306, 160.14841,   0.00000, 0.00000, 168.75000);
	CreateDynamicObject(3816, -1227.05798, 2182.30591, 193.19749,   0.00000, 0.00000, 171.40550);
	CreateDynamicObject(16133, -1080.58911, 2224.28394, 142.95200,   0.00000, 0.00000, 292.50000);
	CreateDynamicObject(16133, -1094.10852, 2293.37183, 147.14481,   352.26511, 359.14059, 191.25000);
	CreateDynamicObject(16139, -937.23181, 2197.82983, 101.87070,   347.10840, 17.18870, 224.06329);
	CreateDynamicObject(16133, -958.94092, 2155.64331, 99.66280,   0.00000, 0.00000, 78.75000);
	CreateDynamicObject(16133, -1233.29565, 2277.92822, 180.88341,   357.42169, 0.00000, 346.09439);
	CreateDynamicObject(16133, -1212.79993, 2341.05273, 179.20050,   357.42169, 0.00000, 121.09430);
	CreateDynamicObject(16133, -1189.71753, 2341.86133, 169.98230,   357.42169, 315.30930, 199.84441);
	CreateDynamicObject(16133, -986.75891, 2326.60498, 138.03540,   4.29720, 354.84341, 65.06670);
	CreateDynamicObject(16133, -1015.67419, 2198.82471, 126.63400,   4.29720, 354.84341, 65.06670);
	CreateDynamicObject(16133, -832.37189, 2157.90283, 99.63890,   4.29720, 354.84341, 20.06680);
	CreateDynamicObject(16133, -885.73389, 2182.62036, 97.92350,   356.56229, 354.84341, 256.31680);
	CreateDynamicObject(16133, -952.54529, 2115.15845, 91.46040,   356.56229, 354.84341, 155.06670);
	CreateDynamicObject(615, -1206.81396, 2234.49243, 184.80240,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, -1160.15942, 2368.86694, 162.93510,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, -1092.53186, 2232.82129, 144.00420,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, -960.15430, 2337.67798, 130.34669,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, -916.57977, 2180.32275, 101.77780,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, -804.58130, 2105.73193, 79.65550,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(622, -1005.54309, 2235.81519, 133.68520,   0.00000, 0.00000, 67.50000);
	CreateDynamicObject(622, -1004.81781, 2234.22632, 132.95090,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(622, -1004.30060, 2233.84668, 133.28670,   0.00000, 0.00000, 112.50000);
	CreateDynamicObject(622, -1003.65747, 2232.77002, 132.09489,   0.00000, 0.00000, 135.00000);
	CreateDynamicObject(622, -1002.76813, 2232.22339, 131.60970,   0.00000, 0.00000, 157.50000);
	CreateDynamicObject(622, -1001.92407, 2231.90405, 131.34460,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(622, -1001.07269, 2231.60474, 131.07941,   0.00000, 0.00000, 202.50000);
	CreateDynamicObject(622, -1000.09851, 2231.70410, 130.82130,   0.00000, 0.00000, 225.00000);
	CreateDynamicObject(645, -1133.33350, 2279.02173, 169.12030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, -1111.52209, 2324.70166, 153.89880,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, -1030.43567, 2309.06982, 141.64371,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, -974.23792, 2264.07104, 126.70300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, -1002.49237, 2233.58691, 131.80009,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, -912.51990, 2153.93555, 100.36480,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(645, -866.84412, 2090.39795, 85.39430,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, -1198.33997, 2304.83667, 181.67160,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, -1053.62366, 2291.27783, 143.12230,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, -1033.15479, 2263.37646, 139.84621,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(669, -950.48523, 2269.25757, 125.34450,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(669, -958.59497, 2187.47852, 103.68340,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(669, -867.71332, 2147.15723, 99.23920,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(669, -824.73291, 2097.95483, 74.66220,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(671, -906.73779, 2176.07031, 101.19750,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(671, -926.67310, 2313.15552, 121.88720,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(671, -999.23907, 2295.17578, 140.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(671, -1151.29736, 2359.61890, 161.49690,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(671, -1128.39490, 2241.36865, 171.28751,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(671, -1182.98914, 2319.74048, 181.80450,   0.00000, 0.00000, 337.50000);
	CreateDynamicObject(672, -1188.63037, 2260.82739, 178.35500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, -1153.18835, 2221.79468, 176.51990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, -1130.50903, 2367.29810, 160.07800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, -1095.09900, 2259.06421, 146.21201,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, -1016.38312, 2279.34009, 140.28770,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, -947.61023, 2325.22119, 124.79040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, -918.76099, 2133.43188, 94.71040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, -914.78851, 2043.56543, 63.70220,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(691, -1234.63770, 2245.14258, 185.37930,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(691, -1153.57080, 2254.61377, 171.94580,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(691, -931.47083, 2298.19263, 118.45450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(691, -806.97589, 2135.79639, 81.94280,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, -1170.66858, 2236.81934, 174.23900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, -1149.25317, 2266.50854, 170.81090,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, -1143.47192, 2335.53540, 159.41890,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, -1062.09180, 2253.79004, 144.13550,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, -928.76672, 2252.84644, 113.66350,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, -925.01428, 2077.30811, 88.81360,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3819, -1179.98279, 2386.22095, 164.47569,   0.00000, 0.00000, 157.50000);
	CreateDynamicObject(3819, -1174.51367, 2394.61670, 163.94650,   0.00000, 0.00000, 123.74990);
	CreateDynamicObject(3819, -1166.12378, 2399.74683, 163.39780,   0.00000, 0.00000, 101.25000);
	CreateDynamicObject(3819, -931.63428, 2339.40039, 123.31030,   0.00000, 0.00000, 112.50000);
	CreateDynamicObject(3819, -922.11603, 2341.86450, 122.83310,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3819, -912.23309, 2339.64355, 122.25380,   0.00000, 0.00000, 56.25000);
	CreateDynamicObject(3819, -787.56958, 2128.87891, 81.97960,   0.00000, 0.00000, 67.50000);
	CreateDynamicObject(3819, -779.32013, 2124.05615, 81.50050,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(3819, -773.86823, 2115.83252, 80.93960,   0.00000, 0.00000, 11.25000);
	CreateDynamicObject(7392, -1177.71021, 2397.61841, 170.57770,   0.00000, 0.00000, 303.75000);
	CreateDynamicObject(13562, -1192.35254, 2386.71118, 165.06020,   0.00000, 0.00000, 348.75000);
	CreateDynamicObject(11417, -900.67200, 2336.39917, 125.70210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(13667, -922.79572, 2346.55786, 137.29340,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(14608, -935.12988, 2344.65698, 124.11740,   0.00000, 0.00000, 157.50000);
	CreateDynamicObject(16776, -781.42981, 2135.66772, 80.86020,   0.00000, 0.00000, 337.50000);
	CreateDynamicObject(16778, -766.42499, 2118.23560, 80.09250,   0.00000, 0.00000, 11.25000);
	CreateDynamicObject(8417, 925.28168, -1959.89514, 0.77170,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8417, 925.24158, -1999.74036, 0.80870,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(969, 904.83429, -1940.10828, 0.89950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(969, 913.64349, -1940.08582, 0.89950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(969, 922.37872, -1940.23218, 0.89950,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(969, 904.69891, -1940.16528, 0.89950,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(969, 922.25238, -1948.89758, 0.89950,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(969, 904.69012, -1948.95325, 0.89950,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(969, 904.90369, -1957.74646, 0.89950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 918.20471, -1957.89868, 1.57290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 924.49731, -1957.88953, 1.57290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 929.33557, -1953.14575, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 927.10431, -1940.06860, 1.57290,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(973, 936.19672, -1940.07288, 1.57290,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(973, 934.03778, -1944.85071, 1.57290,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 933.71887, -1957.77344, 1.57290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 938.60809, -1952.96326, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 941.10907, -1940.07837, 1.57290,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(973, 945.84131, -1944.77490, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 945.83917, -1954.12195, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 945.82843, -1963.50293, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 941.10388, -1968.17297, 1.57290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 932.32343, -1968.15662, 1.57290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 923.67877, -1965.58191, 1.57290,   0.00000, 0.00000, 326.25000);
	CreateDynamicObject(973, 915.21637, -1963.07007, 1.57290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 910.71899, -1967.63916, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 904.93439, -1967.96838, 1.57290,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 904.93573, -1976.73035, 1.57290,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 904.96472, -1985.99927, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 910.77179, -1976.93762, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 909.66821, -1991.01782, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 915.34222, -1981.48157, 1.60990,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(973, 915.49622, -1991.03833, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(974, 920.03058, -1986.05127, 1.62240,   71.33320, 0.00000, 89.14050);
	CreateDynamicObject(974, 925.39362, -1986.10461, 2.44740,   89.38140, 0.00000, 270.00000);
	CreateDynamicObject(974, 930.70172, -1986.08228, 1.54740,   71.33320, 0.85940, 269.14059);
	CreateDynamicObject(973, 933.08087, -1982.53418, 1.60990,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(973, 938.17908, -1987.22437, 1.60990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 938.18152, -1990.20691, 1.60990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 933.37982, -1994.88696, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 924.37762, -1994.89526, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 919.54828, -1995.57007, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 921.37152, -1978.30359, 1.57290,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 928.82147, -1978.34827, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 925.28540, -1971.08020, 1.57290,   0.00000, 0.00000, 213.75000);
	CreateDynamicObject(973, 933.34320, -1973.88501, 1.57290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 945.86090, -1972.79968, 1.57290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 941.28088, -1977.44702, 1.57290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 936.86328, -1977.44055, 1.57790,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 945.82031, -1981.75708, 1.60990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 945.82532, -1990.84631, 1.60990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 945.81512, -1999.96057, 1.60990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 941.06348, -2004.68311, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 936.48767, -2003.42920, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 931.90259, -1998.80090, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 927.36761, -2003.38342, 1.60990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 919.56897, -2002.34314, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 931.89630, -2008.01794, 1.60990,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(973, 927.33838, -2008.38367, 1.60990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 922.52777, -2013.00610, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 915.92603, -2013.02600, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 911.15710, -2008.13342, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 911.13422, -1999.38464, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 905.06897, -1995.46436, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 905.06073, -2004.40393, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 905.04919, -2013.23938, 1.60990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 909.69373, -2018.03223, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 918.83228, -2018.07507, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 927.77429, -2018.09363, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 932.69922, -2016.82007, 1.60990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 937.29211, -2012.23376, 1.60990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(974, 948.31689, -2008.10974, 0.57240,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 953.80792, -2008.30725, 0.53050,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(973, 941.33807, -2012.10388, 1.78450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 904.76282, -1961.23462, 1.13840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 904.62543, -1959.55042, 1.13840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 927.86432, -1956.74097, 1.13840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 933.04498, -1941.27881, 1.13840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 930.28412, -1956.32422, 1.13840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 935.53278, -1941.20715, 1.13840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 943.55750, -1966.08765, 1.13840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 905.81439, -1989.60120, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 919.92133, -1990.23267, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 919.94513, -1982.18250, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 944.40009, -1969.05188, 1.13840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 940.44202, -2003.33643, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 938.16229, -2001.70166, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 926.02570, -2011.02698, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 917.65668, -1992.73291, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 938.17542, -2006.52759, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(974, 959.22449, -2008.39502, 0.51280,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 964.67719, -2008.55640, 0.49170,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 970.05151, -2008.71216, 0.52200,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(970, 925.38788, -1989.37781, 3.00670,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 925.44489, -1982.92090, 3.00610,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 922.67511, -1982.58374, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 922.07971, -1990.41479, 1.17540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 913.13989, -1954.74902, 0.23410,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(970, 913.14240, -1951.46252, 0.23410,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1263, 913.56128, -1957.43555, 1.51980,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(1263, 913.97333, -1949.39429, 1.51980,   0.00000, 0.00000, 33.75000);
	CreateDynamicObject(9833, 931.49323, -2002.84863, -2.32780,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 917.35858, -1964.91846, 3.46300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 914.59741, -1979.64819, 3.46300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 922.28717, -1972.71143, 3.42040,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(1231, 942.91339, -2012.53186, 3.33200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 935.06293, -2006.97571, 3.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 935.59912, -1999.60083, 3.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 927.95648, -1999.84595, 3.40000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 928.59790, -2006.96765, 3.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 910.82813, -2018.43005, 4.80740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 945.42828, -1940.56946, 3.46300,   0.00000, 0.00000, 326.25000);
	CreateDynamicObject(1231, 945.43188, -1977.05396, 3.46300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 905.15277, -1940.27051, 3.46300,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(1655, 974.44202, -2009.01782, 0.73110,   350.54620, 0.85940, 267.42169);
	CreateDynamicObject(3749, 986.74371, -2009.55127, 8.74970,   355.70279, 0.85940, 86.56220);
	CreateDynamicObject(1225, 980.74261, -2015.01624, 2.68630,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 982.08600, -2002.21265, 2.49670,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 979.97198, -2003.58289, 2.05050,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 984.49487, -2001.06702, 3.04620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 983.20972, -2016.37634, 3.35030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 978.52948, -2013.70166, 2.01240,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1262, 914.19739, -1950.12573, 2.04230,   0.00000, 0.00000, 146.25000);
	CreateDynamicObject(1262, 913.96411, -1956.62537, 1.84230,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(1238, 990.38647, -2015.70361, 5.31750,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 994.06732, -2014.58289, 6.30430,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 997.31378, -2011.79419, 7.10850,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 999.46722, -2006.96021, 7.53210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 999.36963, -1999.72571, 7.29710,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 999.12970, -1995.27405, 7.17200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 999.62482, -2003.29651, 7.44140,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 998.98480, -1989.75647, 7.04850,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 993.97278, -1989.69275, 5.36240,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 988.56781, -1989.30676, 3.83860,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 982.09271, -1988.58008, 2.00340,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 975.29852, -1988.34180, 0.69470,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 983.71680, -1999.63782, 2.86370,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 979.95282, -1999.05286, 1.79090,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1238, 975.09949, -1998.92773, 0.90850,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(974, 973.21790, -1993.60583, 0.50070,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 967.79822, -1993.43591, 0.49320,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 962.36932, -1993.28992, 0.50700,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 956.94232, -1993.10803, 0.52510,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 952.13678, -1992.88464, 1.46350,   67.89540, 359.14059, 269.14059);
	CreateDynamicObject(974, 947.20660, -1992.75037, 3.51470,   67.89540, 359.14059, 269.14059);
	CreateDynamicObject(974, 941.90161, -1992.59155, 4.56800,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 936.70972, -1992.46887, 5.28300,   73.91150, 359.14059, 269.14059);
	CreateDynamicObject(974, 931.31543, -1992.29407, 6.06000,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 925.92682, -1992.18347, 6.02960,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 920.47717, -1992.02612, 6.04260,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 915.12140, -1991.86987, 6.06400,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 909.84698, -1991.71204, 6.08310,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 904.69427, -1991.52698, 6.10300,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 899.42407, -1991.39514, 6.09680,   90.24080, 358.28110, 90.00000);
	CreateDynamicObject(974, 900.22168, -1985.34375, 6.12840,   90.24080, 0.00000, 0.00000);
	CreateDynamicObject(974, 900.18951, -1979.92175, 6.14940,   90.24080, 0.00000, 0.00000);
	CreateDynamicObject(974, 900.16333, -1974.48291, 6.19250,   90.24080, 0.00000, 0.00000);
	CreateDynamicObject(974, 900.15198, -1969.11682, 6.25690,   90.24080, 0.00000, 0.00000);
	CreateDynamicObject(974, 900.16217, -1963.73401, 6.26960,   90.24080, 0.00000, 0.00000);
	CreateDynamicObject(974, 900.14209, -1958.41101, 6.26080,   90.24080, 0.00000, 0.00000);
	CreateDynamicObject(974, 894.27502, -1959.04724, 6.36690,   90.24080, 0.00000, 90.00000);
	CreateDynamicObject(974, 888.86682, -1959.03442, 6.36290,   90.24080, 0.00000, 90.00000);
	CreateDynamicObject(974, 888.92920, -1952.45007, 6.37230,   90.24080, 0.00000, 270.00000);
	CreateDynamicObject(974, 894.27802, -1952.46960, 6.44200,   90.24080, 0.00000, 270.00000);
	CreateDynamicObject(974, 899.63751, -1952.44128, 6.51380,   90.24080, 0.00000, 270.00000);
	CreateDynamicObject(1633, 906.91333, -1952.39673, 7.12730,   353.98389, 0.00000, 270.00000);
	CreateDynamicObject(970, 901.31927, -1955.84119, 6.82920,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 897.17712, -1955.87024, 6.91530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 893.00989, -1955.87109, 6.93090,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(973, 896.84662, -1989.94434, 6.87920,   0.00000, 0.00000, 268.28110);
	CreateDynamicObject(973, 907.99512, -1988.38074, 6.93830,   0.00000, 0.00000, 178.28120);
	CreateDynamicObject(973, 903.46228, -1983.67590, 6.93570,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 896.91498, -1967.44043, 7.11430,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 903.38843, -1960.77441, 7.09830,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(973, 886.29523, -1957.50146, 7.22150,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 886.28302, -1953.73450, 7.21070,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(973, 891.12738, -1949.25879, 7.28090,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(973, 898.08698, -1949.30774, 7.30450,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(970, 941.96790, -1989.32874, 5.12700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 941.61578, -1995.89221, 5.12920,   0.00000, 0.00000, 357.42169);
	CreateDynamicObject(970, 973.74658, -1990.36060, 1.05820,   0.00000, 0.00000, 359.14059);
	CreateDynamicObject(970, 972.90259, -1996.89087, 1.06070,   0.00000, 0.00000, 358.28110);
	CreateDynamicObject(1231, 886.31927, -1949.34387, 9.10140,   0.00000, 0.00000, 33.75000);
	CreateDynamicObject(1231, 886.92078, -1962.27600, 9.10900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 896.87628, -1994.55139, 8.80910,   0.00000, 0.00000, 326.25000);
	CreateDynamicObject(1231, 954.73291, -1989.94360, 3.27250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 999.43860, -1991.06348, 8.57660,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 998.52869, -2009.50549, 9.00150,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1231, 975.64319, -1997.38257, 3.38220,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1231, 979.60278, -2015.67603, 4.71680,   0.00000, 0.00000, 78.75000);
	CreateDynamicObject(621, 1005.14532, -1993.67554, 7.24400,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(621, 1002.63843, -2015.25610, 7.61560,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(621, 993.90332, -1975.98865, 4.99500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(621, 977.74622, -1970.70764, 0.79620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(621, 988.96552, -2033.63965, 4.86560,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(621, 973.26611, -2041.40137, 0.76480,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 903.26508, -1978.03040, 6.57090,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 903.33423, -1975.33801, 6.60250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 903.15997, -1972.43250, 6.61470,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 903.16101, -1969.39050, 6.66930,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 903.10498, -1966.08472, 6.67320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 925.97241, -1988.92920, 6.44300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 925.72913, -1995.38013, 6.44080,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 996.82739, -1992.66467, 6.35660,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 977.23523, -1990.52136, 1.10770,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 887.21838, -1950.39734, 6.77870,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 895.88678, -1962.40137, 6.72370,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(981, 797.32422, -1389.05127, 13.49970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(981, 797.75873, -1411.90759, 13.35280,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(981, 916.98993, -1412.08728, 13.17530,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(981, 918.02283, -1389.06128, 13.37720,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(981, 1057.89307, -1389.04993, 13.21120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(981, 1063.01428, -1412.43542, 13.13700,   0.00000, 0.00000, 180.00011);
	CreateDynamicObject(981, 1201.19983, -1388.72449, 12.94980,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(981, 1194.90283, -1412.46704, 12.98680,   0.00000, 0.00000, 180.00011);
	CreateDynamicObject(981, 1257.41479, -1388.70813, 12.95450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(981, 1349.82031, -1386.35266, 13.45290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(981, 1349.96960, -1412.19495, 13.31430,   0.00000, 0.00000, 180.00020);
	CreateDynamicObject(981, 1386.15649, -1401.07178, 13.33430,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(981, 632.80841, -1413.90015, 13.15310,   0.00000, 0.00000, 180.00020);
	CreateDynamicObject(981, 616.48560, -1400.08020, 13.12490,   0.00000, 0.00000, 90.00040);
	CreateDynamicObject(981, 632.59637, -1349.91528, 13.10930,   0.00000, 0.00000, 0.00060);
	CreateDynamicObject(979, 663.32361, -1410.63379, 13.25100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(979, 663.59113, -1405.19092, 13.23900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(979, 663.99103, -1400.15857, 13.23870,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(979, 664.26678, -1394.87805, 13.24340,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(978, 663.48352, -1405.86816, 13.24110,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(978, 663.88092, -1400.73987, 13.24550,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(978, 664.27368, -1395.63513, 13.23210,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(978, 663.83008, -1390.23376, 13.31700,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1290, 664.19379, -1395.26428, 18.35890,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1290, 664.09027, -1405.50403, 18.53170,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1215, 682.64862, -1395.24084, 12.95560,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 682.02710, -1400.44653, 12.96480,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 682.24939, -1405.54395, 12.95740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 754.35748, -1395.37793, 12.93150,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 848.66669, -1395.41980, 12.75320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 966.74878, -1395.33081, 12.53300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 1092.37939, -1395.54810, 13.03750,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 1225.62781, -1395.35107, 12.71700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 754.28741, -1400.48218, 12.93150,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 753.61511, -1405.53027, 12.93130,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 848.28583, -1400.54016, 12.85310,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 848.04761, -1405.57971, 12.85760,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 966.78198, -1400.49463, 12.71450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 966.43298, -1405.55664, 12.72730,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 1092.49194, -1400.67773, 13.03000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 1091.96716, -1405.82666, 13.03190,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 1225.58447, -1400.52441, 12.71600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 1224.56323, -1405.65271, 12.69070,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 1380.69409, -1393.00244, 13.93350,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 1380.75671, -1397.87805, 13.87680,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 1380.75696, -1403.06812, 13.87680,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 1380.82251, -1408.29810, 13.87680,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 671.12988, -1395.29724, 12.45980,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 674.47870, -1395.23926, 12.46100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 677.85901, -1395.29541, 12.45980,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 681.18683, -1395.25073, 12.46040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 670.89337, -1400.48523, 12.47410,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 674.42810, -1400.43787, 12.47420,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 677.92651, -1400.41846, 12.46730,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 681.44849, -1400.43970, 12.46930,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 670.60199, -1405.46802, 12.46680,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 674.18628, -1405.52490, 12.46730,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 677.72131, -1405.49780, 12.46670,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3526, 681.39203, -1405.48804, 12.46190,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 1375.92017, -1392.88660, 13.95700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 1375.85437, -1398.11597, 13.88450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 1375.63635, -1403.20544, 13.87680,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 1375.58972, -1408.22766, 13.88530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3851, 1332.77576, -1395.64709, 14.37150,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3851, 1332.77759, -1405.44800, 14.37990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3851, 1337.10986, -1394.05090, 14.38600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3851, 1342.24353, -1404.60229, 14.32610,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3851, 1347.42078, -1393.82983, 14.39370,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3851, 1352.11755, -1405.47485, 14.33450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3851, 1357.46924, -1393.42297, 14.38410,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3851, 1362.35681, -1405.24072, 14.42520,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2780, 1390.03284, -1400.91516, 12.38280,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 631.77417, -1399.96899, 12.16260,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3528, 646.54608, -1385.43115, 20.01640,   0.00000, 0.00000, 213.75000);
	CreateDynamicObject(7392, 615.01563, -1428.68311, 40.72260,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(13562, 647.80957, -1384.21643, 23.02410,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8040, 747.38812, 2493.42407, 479.92319,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(16384, 531.15869, 2494.47070, 323.63400,   0.00000, 318.74701, 0.00000);
	CreateDynamicObject(16384, 428.68231, 2494.56812, 203.65790,   0.00000, 301.55841, 0.00000);
	CreateDynamicObject(16384, 382.19571, 2494.60522, 127.87260,   0.00000, 301.55841, 0.00000);
	CreateDynamicObject(1655, 336.78549, 2498.23926, 54.49660,   31.79920, 0.00000, 270.00000);
	CreateDynamicObject(1655, 336.78769, 2489.99487, 54.40060,   34.37750, 358.28110, 270.85950);
	CreateDynamicObject(4567, 326.46841, 2495.13501, 51.54200,   0.00000, 359.14059, 179.14059);
	CreateDynamicObject(1655, 263.31641, 2489.46753, 53.22380,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1655, 263.24600, 2496.30420, 53.26150,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1655, 263.24500, 2501.42041, 53.29760,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3381, 297.80609, 2502.88696, 61.13910,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(972, 319.46109, 2483.65356, 51.87700,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(972, 295.73831, 2483.89136, 51.80980,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(972, 315.90060, 2504.69873, 51.85540,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(972, 290.76611, 2504.49512, 51.86400,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(18450, 431.90710, 2495.46826, 251.79269,   179.62230, 43.83130, 0.00000);
	CreateDynamicObject(8355, 446.76309, 2484.31787, 234.36180,   299.83939, 94.53800, 91.71890);
	CreateDynamicObject(8355, 450.67450, 2503.91528, 237.80460,   61.02000, 88.52200, 271.09140);
	CreateDynamicObject(1655, 331.43149, 2489.18994, 51.20700,   350.54620, 0.85940, 270.00000);
	CreateDynamicObject(1655, 331.68350, 2499.21509, 51.35220,   349.68680, 1.71890, 270.00000);
	CreateDynamicObject(1655, 331.94269, 2492.65259, 51.36860,   351.40561, 0.85940, 270.00000);
	CreateDynamicObject(12990, 760.27441, 2526.57959, 480.43790,   0.00000, 356.56229, 0.00000);
	CreateDynamicObject(11495, 760.09192, 2541.47900, 480.22791,   358.28110, 1.71890, 90.00000);
	CreateDynamicObject(3877, 785.65619, 2510.58203, 480.83090,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 786.05243, 2476.25708, 480.82330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 764.53809, 2476.25537, 480.82330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 709.92133, 2476.40283, 480.82330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 709.53918, 2509.88477, 480.82330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 764.61761, 2510.61816, 480.82330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 758.44623, 2510.93286, 480.82330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 742.20361, 2475.61426, 480.82330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 738.90863, 2509.70044, 480.82330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7392, 786.66449, 2491.48291, 488.76770,   358.28110, 0.00000, 0.00000);
	CreateDynamicObject(3534, 758.12811, 2539.61084, 481.69351,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 762.56122, 2539.43286, 481.94360,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 277.19730, 2486.57861, 53.54110,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 270.64371, 2487.09326, 53.63950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 270.61731, 2501.96973, 53.64330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 276.94879, 2501.43677, 53.54820,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 273.40302, 2501.97534, 51.71620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 273.87161, 2487.25366, 51.95580,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, 459.66019, 2494.59082, 277.79440,   0.00000, 178.76289, 0.00000);
	CreateDynamicObject(7617, 709.53741, 2494.64355, 490.35281,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3243, 708.75293, 2485.89380, 479.20029,   0.00000, 0.00000, 281.25000);
	CreateDynamicObject(3243, 709.36890, 2503.40430, 479.19260,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3866, 833.52533, -236.81149, 25.56990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3575, 805.60602, -262.69141, 19.63400,   0.00000, 352.26511, 0.00000);
	CreateDynamicObject(3722, 797.96960, -240.54210, 19.92470,   6.01610, 0.00000, 297.73401);
	CreateDynamicObject(3502, 815.05701, -230.81461, 19.96710,   8.59440, 0.00000, 81.32830);
	CreateDynamicObject(3502, 806.52887, -229.52940, 21.77000,   15.46990, 0.00000, 81.32830);
	CreateDynamicObject(3502, 798.85437, -229.89000, 24.76630,   25.78310, 0.00000, 103.82830);
	CreateDynamicObject(3502, 792.18481, -233.09869, 28.42980,   25.78310, 0.00000, 126.32830);
	CreateDynamicObject(3502, 787.16107, -238.77560, 32.11510,   25.78310, 0.00000, 148.82829);
	CreateDynamicObject(3502, 784.64893, -245.77390, 35.77840,   25.78310, 0.00000, 171.32829);
	CreateDynamicObject(3502, 777.65472, -251.02361, 36.32780,   336.79520, 0.00000, 81.32830);
	CreateDynamicObject(3502, 769.94318, -249.87601, 32.50430,   331.63861, 0.00000, 81.32830);
	CreateDynamicObject(3502, 762.69672, -248.76660, 27.96110,   324.76309, 3.43770, 81.32830);
	CreateDynamicObject(3502, 755.93848, -247.80051, 22.45780,   317.02820, 3.43770, 81.32830);
	CreateDynamicObject(3502, 749.58081, -246.83009, 16.40370,   317.02820, 3.43770, 81.32830);
	CreateDynamicObject(3502, 782.88287, -258.20319, 36.17010,   23.20480, 3.43770, 352.26511);
	CreateDynamicObject(3502, 783.32281, -265.86938, 32.81290,   23.20480, 3.43770, 14.76510);
	CreateDynamicObject(3502, 786.55719, -272.72821, 29.31600,   23.20480, 3.43770, 37.26510);
	CreateDynamicObject(3502, 792.44202, -277.92740, 25.83500,   23.20480, 3.43770, 59.76510);
	CreateDynamicObject(3502, 799.74182, -280.57251, 22.49800,   23.20480, 3.43770, 82.26510);
	CreateDynamicObject(3502, 789.43988, -252.75340, 35.76830,   23.20480, 3.43770, 82.26510);
	CreateDynamicObject(3502, 796.88959, -252.30060, 32.37230,   23.20480, 3.43770, 104.76500);
	CreateDynamicObject(3502, 804.29053, -249.52870, 28.90450,   23.20480, 3.43770, 116.01500);
	CreateDynamicObject(3502, 811.80798, -246.83270, 26.80330,   5.15660, 3.43770, 104.76500);
	CreateDynamicObject(3502, 819.56458, -244.57291, 27.20070,   347.10840, 3.43770, 104.76500);
	CreateDynamicObject(3502, 827.29919, -243.32510, 26.97420,   15.46990, 3.43770, 93.51500);
	CreateDynamicObject(3502, 834.85242, -242.80560, 23.97380,   26.64250, 3.43770, 93.51500);
	CreateDynamicObject(1553, 783.41119, -251.94231, 35.86040,   89.38140, 359.14059, 353.04721);
	CreateDynamicObject(18267, 769.54211, -251.38240, 13.64340,   0.00000, 353.98389, 0.00000);
	CreateDynamicObject(3279, 753.38702, -233.59030, 10.01690,   0.00000, 0.00000, 326.25000);
	CreateDynamicObject(3279, 831.35168, -271.57120, 20.43310,   0.00000, 0.00000, 157.50000);
	CreateDynamicObject(3797, 830.06671, -270.76520, 29.05210,   0.00000, 0.00000, 292.50000);
	CreateDynamicObject(3797, 759.41309, -232.85710, 15.59240,   0.00000, 0.00000, 281.25000);
	CreateDynamicObject(3885, 786.67249, -269.98300, 15.01000,   0.00000, 350.54620, 0.00000);
	CreateDynamicObject(3374, 794.15448, -262.50711, 16.77620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 794.25439, -260.52960, 19.77620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 796.25488, -260.56549, 22.77620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 796.21881, -262.54709, 25.77620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 794.24048, -262.61609, 28.77620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 794.19592, -260.62891, 31.77620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3374, 796.18170, -260.51239, 34.77620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 775.33740, -252.95120, 14.73850,   0.00000, 352.26511, 0.00000);
	CreateDynamicObject(1225, 789.78699, -245.97099, 20.33990,   10.31320, 55.86330, 81.64640);
	CreateDynamicObject(1225, 815.30408, -246.06020, 28.63160,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 830.67462, -269.18579, 36.91700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 753.56342, -236.01260, 26.50080,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 739.50580, -265.10211, 9.59410,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 784.36377, -269.91519, 15.55130,   95.39740, 3.43770, 327.10941);
	CreateDynamicObject(1225, 797.65680, -261.93430, 36.68800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 821.22748, -229.91020, 18.06400,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 748.65332, -246.62050, 10.18260,   0.00000, 351.40561, 0.00000);
	CreateDynamicObject(6299, 817.66193, -281.00021, 22.26920,   357.42169, 352.26511, 348.75000);
	CreateDynamicObject(12957, 822.33667, -260.43631, 19.42140,   357.42169, 357.42169, 13.90560);
	CreateDynamicObject(13591, 784.31677, -231.71539, 14.77090,   0.00000, 356.56229, 0.00000);
	CreateDynamicObject(615, 785.74011, -253.12320, 9.60430,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 805.38751, -288.17471, 18.17960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, 830.91779, -233.18021, 18.14270,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, 747.54053, -260.23309, 10.22860,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(671, 770.83423, -226.58490, 12.41960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 819.13910, -263.82660, 19.62380,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(744, 754.17908, -251.76981, 10.05470,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(744, 830.51617, -282.16931, 21.53090,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(745, 811.43231, -247.85100, 17.44200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(746, 781.75409, -257.36090, 13.87820,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(747, 796.71143, -229.73489, 15.74520,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(749, 814.49683, -237.45540, 17.20600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(750, 801.46039, -272.60211, 16.83230,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(751, 815.73889, -283.58691, 19.69580,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(758, 769.42218, -266.75150, 11.76870,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(826, 795.77020, -249.47920, 16.74740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(826, 800.18182, -245.87480, 17.50080,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(826, 805.50067, -242.65950, 18.09520,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(826, 797.31567, -252.22121, 17.24640,   0.00000, 0.00000, 67.50000);
	CreateDynamicObject(826, 802.68457, -250.77010, 18.05800,   0.00000, 0.00000, 56.25000);
	CreateDynamicObject(826, 807.38190, -247.52699, 18.47790,   0.00000, 0.00000, 33.75000);
	CreateDynamicObject(826, 807.38660, -251.55409, 18.21210,   0.00000, 0.00000, 33.75000);
	CreateDynamicObject(826, 811.12042, -242.84509, 18.31200,   0.00000, 0.00000, 33.75000);
	CreateDynamicObject(824, 769.36902, -262.82840, 12.72880,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(824, 796.46753, -232.14149, 16.51880,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(824, 825.17297, -243.70290, 18.93270,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 819.75519, -264.12631, 20.14030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 778.64288, -271.38071, 14.32160,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 755.14447, -253.81670, 11.65450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(823, 804.87402, -285.48969, 18.87880,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8417, 734.69891, -252.85851, 28.10400,   90.24080, 0.00000, 270.00000);
	CreateDynamicObject(8417, 752.15289, -221.04100, 28.16390,   90.24080, 0.00000, 213.75000);
	CreateDynamicObject(8417, 789.61823, -213.79340, 28.28550,   90.24080, 0.00000, 168.75000);
	CreateDynamicObject(8417, 830.55621, -217.85381, 28.28440,   90.24080, 0.00000, 180.00000);
	CreateDynamicObject(8417, 851.17810, -238.38280, 28.20040,   90.24080, 0.00000, 90.00000);
	CreateDynamicObject(8417, 851.15479, -279.69720, 28.25100,   90.24080, 0.00000, 90.00000);
	CreateDynamicObject(8417, 830.53363, -300.28131, 28.26770,   90.24080, 0.00000, 360.00000);
	CreateDynamicObject(8417, 790.86548, -292.30490, 28.19150,   90.24080, 0.00000, 337.49991);
	CreateDynamicObject(8417, 752.20892, -277.89310, 28.20450,   90.24080, 0.00000, 341.87451);
	CreateDynamicObject(16121, 1920.76953, -277.77679, 2.22490,   350.54620, 354.84341, 326.25000);
	CreateDynamicObject(16121, 1951.02808, -309.08701, 5.58930,   11.17270, 6.01610, 115.15550);
	CreateDynamicObject(16120, 1920.63049, -325.23999, 10.95650,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16120, 1963.90320, -333.75281, 13.53290,   11.17270, 0.00000, 191.25011);
	CreateDynamicObject(16119, 1955.99475, -399.50699, 19.69150,   8.59440, 347.96790, 258.75000);
	CreateDynamicObject(16116, 1934.75256, -354.73331, 15.43200,   0.00000, 0.00000, 301.09439);
	CreateDynamicObject(8650, 1917.11462, -395.64081, 21.70500,   352.26511, 0.00000, 292.50000);
	CreateDynamicObject(8650, 1919.13464, -397.36261, 21.85130,   352.26511, 0.00000, 292.50000);
	CreateDynamicObject(16113, 1907.90686, -375.71759, 19.96270,   0.00000, 0.00000, 258.75000);
	CreateDynamicObject(16113, 1920.21436, -423.20331, 20.08030,   0.00000, 0.00000, 67.50000);
	CreateDynamicObject(16111, 1889.70825, -409.78210, 22.08860,   22.34540, 57.58220, 303.75000);
	CreateDynamicObject(16114, 1873.70581, -387.19861, 28.68830,   0.00000, 15.46990, 333.98489);
	CreateDynamicObject(16116, 1869.92871, -437.20779, 25.45500,   0.00000, 20.62650, 337.50000);
	CreateDynamicObject(16114, 1863.98718, -415.57959, 39.61130,   11.17270, 33.51800, 30.23490);
	CreateDynamicObject(16117, 1917.35620, -447.53241, 24.23890,   0.00000, 0.00000, 78.75000);
	CreateDynamicObject(16118, 1878.43738, -481.09250, 16.07360,   0.00000, 0.00000, 191.25000);
	CreateDynamicObject(16121, 1925.94312, -497.10660, 11.40090,   0.00000, 0.00000, 202.50000);
	CreateDynamicObject(16121, 1934.94324, -546.21472, 13.73470,   0.00000, 0.00000, 157.50000);
	CreateDynamicObject(16121, 1888.92224, -522.68573, 13.61450,   0.00000, 0.00000, 33.75000);
	CreateDynamicObject(16121, 1903.31531, -561.92493, 21.85240,   341.95181, 0.00000, 337.50000);
	CreateDynamicObject(16121, 1908.86621, -599.63788, 35.73240,   328.20081, 0.00000, 348.75000);
	CreateDynamicObject(16121, 1939.12585, -579.41663, 22.55780,   21.48590, 0.00000, 168.75011);
	CreateDynamicObject(16121, 1945.74207, -616.54022, 41.74660,   27.50200, 0.00000, 168.75011);
	CreateDynamicObject(16112, 1928.73389, -624.65833, 44.72530,   3.43770, 17.18870, 123.75010);
	CreateDynamicObject(16121, 1920.44690, -479.66370, 27.54040,   353.12451, 33.51800, 191.25000);
	CreateDynamicObject(749, 1937.01575, -394.86420, 21.53070,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(750, 1933.04102, -383.26071, 23.56160,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(751, 1918.75781, -400.37659, 20.48760,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(750, 1927.08862, -403.10971, 26.30810,   334.21689, 0.00000, 0.00000);
	CreateDynamicObject(750, 1919.27905, -384.88599, 25.86460,   334.21689, 0.00000, 157.50000);
	CreateDynamicObject(615, 1943.14246, -271.55200, 0.00650,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, 1915.81067, -307.74399, 14.60820,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, 1966.46313, -345.30801, 22.80030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, 1917.49817, -392.65909, 19.99020,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, 1898.26575, -511.79990, 17.47170,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, 1932.08191, -570.74329, 28.36760,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1980.35449, -284.66971, 4.78800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1911.44434, -353.12100, 16.25570,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1931.68689, -477.27631, 20.49220,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1891.46631, -556.26770, 25.54790,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, 1941.62964, -310.46149, 14.65970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, 1952.55225, -330.79910, 21.86940,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, 1918.63855, -381.33209, 26.76610,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, 1880.78503, -411.30801, 30.38250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, 1907.43604, -441.71790, 18.97760,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, 1926.46399, -514.26611, 18.14090,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, 1914.04492, -584.77832, 34.75080,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(671, 1907.74548, -504.94980, 16.86580,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1918.11853, -514.98401, 17.94310,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(688, 1906.39587, -508.57419, 16.59270,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, 1940.16882, -623.24402, 55.39690,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, 1938.96338, -363.31631, 24.46990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, 1930.87488, -281.08301, 7.22480,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1902.11975, -442.92691, 20.69270,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1898.64221, -444.25760, 20.53790,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1893.77527, -443.11929, 22.07040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1890.33032, -440.27951, 23.92580,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1893.38525, -439.45010, 23.12260,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1897.83691, -440.18481, 21.19920,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1901.47754, -438.08951, 20.94760,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1896.12830, -433.39670, 22.49600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1892.93896, -434.15189, 23.92110,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1889.17078, -434.30319, 25.02160,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1887.84863, -430.27951, 25.92010,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1891.82117, -429.68951, 24.81420,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(803, 1895.48584, -428.96579, 23.09120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3515, 1912.95325, -398.66711, 19.33040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14608, 1932.33887, -625.05463, 58.59690,   350.54620, 0.00000, 316.71890);
	CreateDynamicObject(3461, 1936.81616, -282.11719, 6.57570,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1925.17834, -308.91550, 18.84280,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1938.41565, -332.54919, 21.64070,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1954.29517, -352.28021, 24.80300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1942.58826, -376.92340, 26.51370,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1932.10413, -393.29361, 22.54820,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1929.68005, -388.77811, 22.07120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1903.14026, -405.90121, 25.12330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1901.35681, -400.82571, 26.53310,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1884.14722, -425.41739, 29.84490,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1898.22339, -453.86050, 25.60920,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1890.63940, -488.20630, 21.96190,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1917.76270, -506.92099, 19.05190,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1913.13843, -530.37292, 23.23520,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1924.90698, -558.30737, 26.23510,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1915.45618, -576.96332, 35.59030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1931.65015, -595.16492, 43.57780,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1924.42273, -609.31409, 55.08420,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1938.23059, -609.47388, 55.70900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(790, 1920.14648, -390.00671, 24.37620,   0.00000, 0.00000, 326.25000);
	CreateDynamicObject(4108, 1894.92920, -620.15588, 64.18620,   12.89160, 12.89160, 81.32830);
	CreateDynamicObject(987, 2217.09424, 960.36249, 14.67200,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 2217.06421, 948.39398, 14.67200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(987, 2217.04224, 943.33447, 14.67200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(987, 2205.12378, 943.54797, 14.67200,   0.00000, 0.00000, 360.00000);
	CreateDynamicObject(987, 2194.67407, 943.57629, 14.67200,   0.00000, 0.00000, 360.00000);
	CreateDynamicObject(987, 2194.58472, 931.53302, 14.67200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(987, 2194.57251, 925.83801, 14.67200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(987, 2182.64258, 925.98059, 14.67200,   0.00000, 0.00000, 360.00000);
	CreateDynamicObject(987, 2170.71143, 925.97070, 14.67200,   0.00000, 0.00000, 360.00000);
	CreateDynamicObject(987, 2160.12329, 925.95270, 14.67200,   0.00000, 0.00000, 360.00000);
	CreateDynamicObject(987, 2160.25098, 937.91309, 14.67200,   0.00000, 0.00000, 269.99991);
	CreateDynamicObject(987, 2160.25415, 949.85663, 14.67200,   0.00000, 0.00000, 269.99991);
	CreateDynamicObject(987, 2160.26514, 960.55859, 14.67200,   0.00000, 0.00000, 269.99991);
	CreateDynamicObject(987, 2172.13354, 960.48840, 14.67200,   0.00000, 0.00000, 180.00011);
	CreateDynamicObject(987, 2184.16846, 960.40021, 14.67200,   0.00000, 0.00000, 180.00011);
	CreateDynamicObject(987, 2196.16455, 960.30872, 14.67200,   0.00000, 0.00000, 180.00011);
	CreateDynamicObject(1634, 2202.53174, 963.43970, 11.61760,   8.59440, 0.00000, 180.00000);
	CreateDynamicObject(1634, 2198.43530, 963.47357, 11.59260,   8.59440, 0.00000, 180.00000);
	CreateDynamicObject(11490, 2176.30200, 943.78760, 14.66770,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(11491, 2168.46265, 935.93079, 16.17100,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(6356, 2179.07983, 948.84808, 25.57330,   0.00000, 0.00000, 238.82840);
	CreateDynamicObject(669, 2213.83545, 946.46991, 14.84500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(671, 2162.89722, 929.69122, 14.63410,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(673, 2183.99414, 930.74878, 14.86910,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, 2191.12378, 939.31702, 14.98970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, 2175.60962, 957.46088, 14.86590,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(729, 2164.51465, 945.85419, 14.42700,   0.00000, 0.00000, 337.50000);
	CreateDynamicObject(1364, 2163.36328, 949.62842, 15.59550,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1364, 2182.38330, 932.11688, 15.68410,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(1597, 2205.00171, 955.53851, 17.36790,   0.00000, 0.00000, 337.50000);
	CreateDynamicObject(1597, 2199.66357, 947.54578, 17.45040,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(1597, 2191.40576, 958.79938, 17.37240,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1597, 2181.43481, 958.66742, 17.38750,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1597, 2189.34839, 942.89893, 17.48240,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3802, 2180.15137, 947.41718, 19.46570,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(3806, 2178.53369, 933.81238, 19.58460,   0.00000, 0.00000, 225.00000);
	CreateDynamicObject(3806, 2178.44409, 933.85718, 16.59000,   0.00000, 0.00000, 225.00000);
	CreateDynamicObject(744, 2211.84253, 953.98279, 14.53290,   0.00000, 0.00000, 135.00000);
	CreateDynamicObject(745, 2208.78223, 947.89313, 14.64590,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(746, 2207.06104, 951.29279, 14.59970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(747, 2212.41650, 949.25250, 14.63810,   0.00000, 0.00000, 157.50000);
	CreateDynamicObject(748, 2213.02832, 957.45538, 14.62040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(822, 2205.26758, 947.20392, 14.77400,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(822, 2206.83716, 951.58038, 15.67520,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(822, 2209.82715, 956.31848, 14.65960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(822, 2214.19214, 956.77368, 15.02170,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(822, 2213.83154, 952.98383, 14.85070,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(822, 2213.64209, 948.71112, 14.38610,   0.00000, 0.00000, 292.50000);
	CreateDynamicObject(822, 2214.10352, 945.35382, 14.34900,   0.00000, 0.00000, 247.50000);
	CreateDynamicObject(625, 2193.83423, 936.30353, 15.51180,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(9833, 2209.63159, 948.56378, 12.70080,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(9833, 2210.65967, 952.49231, 16.35260,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 2167.44043, 933.11981, 14.92730,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 2191.00415, 950.63562, 14.53930,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16151, 2178.48486, 940.89758, 16.56730,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(1518, 2171.05420, 938.53271, 18.02680,   0.00000, 0.00000, 135.00000);
	CreateDynamicObject(11666, 2173.18799, 940.70477, 17.83820,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(1723, 2169.65649, 942.80157, 16.17360,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(1825, 2174.36719, 946.15649, 16.15370,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2100, 2176.84644, 948.76971, 16.17470,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(1597, 2184.72632, 927.81787, 17.32940,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1597, 2174.84058, 927.80499, 17.32940,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1597, 2165.04590, 927.88507, 17.32940,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(11490, 2386.74023, 1112.81482, 33.25350,   0.00000, 0.00000, 157.50000);
	CreateDynamicObject(11491, 2390.92432, 1122.99683, 34.75680,   0.00000, 0.00000, 157.50000);
	CreateDynamicObject(16151, 2383.74805, 1114.50537, 35.15310,   0.00000, 0.00000, 157.50000);
	CreateDynamicObject(1794, 2389.72559, 1110.93982, 34.79230,   0.00000, 0.00000, 157.50000);
	CreateDynamicObject(1828, 2389.17041, 1116.95557, 34.73400,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1829, 2390.35767, 1112.20679, 35.22580,   0.00000, 0.00000, 247.50000);
	CreateDynamicObject(1723, 2392.33398, 1115.96680, 34.75940,   0.00000, 0.00000, 247.50000);
	CreateDynamicObject(3461, 2389.41455, 1119.53540, 33.14790,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(924, 2389.47998, 1119.50830, 35.08740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1597, 2407.43750, 1095.98877, 35.91520,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(1597, 2365.78198, 1095.75220, 35.91520,   0.00000, 0.00000, 225.00000);
	CreateDynamicObject(1597, 2365.29053, 1167.39502, 35.91520,   0.00000, 0.00000, 135.00000);
	CreateDynamicObject(1597, 2407.04883, 1167.52930, 35.91520,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(1597, 2397.12817, 1170.63367, 35.91520,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1597, 2374.37524, 1170.31433, 35.91520,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1597, 2385.73218, 1170.44617, 35.91020,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1597, 2406.22876, 1143.10071, 35.91520,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1597, 2399.21655, 1114.50159, 35.91520,   0.00000, 0.00000, 22.50000);
	CreateDynamicObject(1597, 2380.53882, 1122.95862, 35.91020,   0.00000, 0.00000, 101.25000);
	CreateDynamicObject(691, 2407.35278, 1130.18958, 32.83020,   0.00000, 0.00000, 292.50000);
	CreateDynamicObject(6965, 2391.21997, 1151.61914, 36.86530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(9833, 2394.01611, 1156.47925, 30.03040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(9833, 2395.73633, 1149.13354, 29.98040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(9833, 2389.68774, 1146.54651, 30.05540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(9833, 2386.38525, 1153.50916, 29.95540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(744, 2387.42065, 1148.33936, 32.73870,   0.00000, 0.00000, 326.25000);
	CreateDynamicObject(745, 2394.38745, 1147.12573, 33.27670,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(746, 2396.06226, 1152.90613, 33.40550,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(747, 2392.32617, 1154.66406, 32.91890,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(748, 2389.08984, 1154.19055, 33.12620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(826, 2393.34717, 1150.51306, 34.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(826, 2390.40796, 1155.60046, 34.49510,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(826, 2387.51245, 1150.23059, 33.52910,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(980, 2373.12280, 1113.43250, 36.03120,   0.00000, 0.00000, 337.50000);
	CreateDynamicObject(980, 2372.06519, 1110.86462, 38.73140,   90.24080, 0.00000, 337.50000);
	CreateDynamicObject(980, 2377.37646, 1108.68262, 33.00130,   0.00000, 90.24080, 247.50000);
	CreateDynamicObject(980, 2366.77759, 1113.09058, 33.03120,   0.00000, 90.24080, 247.50000);
	CreateDynamicObject(3749, 1947.09338, 2406.62646, 15.67870,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1966.68250, 2448.85938, 9.82830,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1966.69702, 2436.92432, 9.82030,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1966.75134, 2424.98608, 9.82030,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1966.71497, 2419.99219, 9.82030,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1966.46033, 2408.13550, 9.80450,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 1937.43542, 2408.49805, 9.81300,   0.00000, 0.00000, 193.75110);
	CreateDynamicObject(987, 1925.84912, 2405.66284, 9.82030,   0.00000, 0.00000, 221.48500);
	CreateDynamicObject(987, 1916.85388, 2397.72559, 9.82030,   0.00000, 0.00000, 216.87880);
	CreateDynamicObject(987, 1898.93274, 2390.62744, 9.82030,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 1907.26318, 2390.58569, 9.82030,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(10562, 1898.52429, 2440.48877, 9.92590,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(10562, 1898.09802, 2430.24878, 9.87660,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(10562, 1893.50085, 2414.03442, 9.87740,   0.00000, 0.00000, 128.04720);
	CreateDynamicObject(11490, 1920.36536, 2431.10425, 10.01690,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11491, 1920.34436, 2420.02197, 11.47800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2780, 1920.24866, 2423.13037, 20.79780,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1920.76965, 2423.47534, 9.87470,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1920.47461, 2423.46899, 9.89970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1920.07898, 2423.46802, 9.89970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 1919.78589, 2423.49414, 9.87470,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14446, 1917.49548, 2433.50879, 12.08740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1828, 1920.43994, 2428.93896, 11.47240,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(2718, 1917.76746, 2435.16846, 13.67320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11665, 1923.21045, 2433.68750, 12.19840,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1724, 1922.51099, 2432.67993, 11.49770,   0.00000, 0.00000, 157.50000);
	CreateDynamicObject(2224, 1921.74683, 2434.61426, 11.49550,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(2224, 1923.23071, 2434.62451, 11.49550,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(14806, 1924.27271, 2427.45190, 12.58570,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1723, 1921.95752, 2426.48853, 11.49780,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(11665, 1917.42859, 2427.44751, 12.22340,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3279, 1960.17883, 2414.59009, 10.05460,   0.00000, 0.00000, 90.00010);
	CreateDynamicObject(16644, 1947.44141, 2415.01587, 26.95950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16644, 1943.01599, 2415.08130, 26.95950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3279, 1932.55432, 2414.02515, 10.03110,   0.00000, 0.00000, 90.00010);
	CreateDynamicObject(984, 1950.96802, 2415.85791, 27.61940,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(984, 1941.86023, 2415.84326, 27.61940,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(984, 1941.87146, 2413.47021, 27.64590,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(984, 1951.21155, 2413.48169, 27.64590,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3279, 1902.43884, 2394.88477, 10.01320,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14637, 1947.20654, 2403.10254, 16.94200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(14467, 1940.08643, 2402.78955, 11.85410,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(14467, 1954.90833, 2402.40332, 11.85410,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3528, 1946.78198, 2402.50293, 17.12870,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(12991, 1964.20349, 2431.98340, 16.00290,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(8613, 1960.17737, 2424.86084, 12.62540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1491, 1963.75830, 2429.02905, 15.78670,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1828, 1963.96460, 2432.00439, 16.00130,   0.00000, 0.00000, 225.00000);
	CreateDynamicObject(3280, 2192.39087, 998.96198, 10.53150,   0.00000, 270.61859, 20.62650);
	CreateDynamicObject(3409, 1894.07849, 2416.83252, 10.34160,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(970, 1896.39661, 2416.84058, 10.72970,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(970, 1894.31067, 2418.91943, 10.72970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 1892.22241, 2418.92651, 10.72970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 1890.19116, 2416.90088, 10.72970,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(970, 1890.21680, 2412.78711, 10.72970,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(970, 1890.22253, 2408.63379, 10.72970,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(970, 1892.31018, 2406.61670, 10.72970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 1896.40222, 2408.67334, 10.72970,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(970, 1894.31738, 2406.63428, 10.72970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, 1893.78381, 2409.29517, 10.34160,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3409, 1893.96594, 2412.98608, 10.34160,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3508, 1924.62549, 2405.45117, 9.95390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3508, 1919.19910, 2401.01709, 9.95390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3508, 1913.80334, 2396.39893, 9.95390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3508, 1907.87830, 2392.75977, 9.94040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3508, 1965.36328, 2418.52100, 9.97740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3508, 1966.48315, 2424.02515, 9.97740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3508, 1965.31641, 2440.01367, 10.17660,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(967, 1939.55103, 2409.49170, 9.95480,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3666, 1940.25659, 2410.71191, 10.46840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3666, 1940.26392, 2411.54663, 10.46840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3666, 1938.85669, 2411.56738, 10.46840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3666, 1938.87036, 2410.71558, 10.46840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1966.47095, 2408.13379, 14.60470,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 1966.68811, 2419.76270, 14.65400,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1966.71826, 2430.07471, 14.72900,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1966.70215, 2445.55591, 14.77820,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1937.38672, 2408.35327, 14.67370,   0.00000, 0.00000, 193.82829);
	CreateDynamicObject(987, 1925.87280, 2405.36792, 14.82030,   0.00000, 0.00000, 219.61160);
	CreateDynamicObject(987, 1916.81628, 2397.61353, 14.82970,   0.00000, 0.00000, 218.04720);
	CreateDynamicObject(987, 1907.31348, 2390.48291, 14.51590,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 1895.30823, 2390.51880, 14.50800,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(974, 1964.47253, 2431.70410, 15.96130,   269.75909, 0.00000, 90.00000);
	CreateDynamicObject(18014, 1919.86597, 2417.87354, 10.43620,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(18014, 1915.37634, 2417.86890, 10.43620,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(18014, 1913.41504, 2420.43506, 10.43620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18014, 1913.40845, 2423.08740, 10.43620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2254, 1915.79504, 2431.39307, 13.04020,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1364, 1906.18286, 2427.99976, 10.78810,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1364, 1935.15369, 2427.63745, 10.78030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1360, 1925.92041, 2419.80347, 10.77600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1360, 1925.87476, 2422.34717, 10.77600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(936, 1965.95923, 2433.89917, 16.32770,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(936, 1965.97046, 2432.16064, 16.32770,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(936, 1965.99329, 2430.46680, 16.32770,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(936, 1966.01111, 2430.10034, 16.32770,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1671, 1964.40039, 2433.48511, 16.46320,   0.00000, 0.00000, 67.50000);
	CreateDynamicObject(1671, 1964.60071, 2431.63330, 16.46320,   0.00000, 0.00000, 112.50000);
	CreateDynamicObject(1671, 1964.75659, 2430.04639, 16.46320,   0.00000, 0.00000, 101.25000);
	CreateDynamicObject(2495, 1923.92920, 2427.42432, 13.10900,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2499, 1917.17932, 2426.16455, 16.16800,   286.94791, 0.00000, 270.00000);
	CreateDynamicObject(2500, 1966.43896, 2429.67432, 16.80070,   0.00000, 0.00000, 270.00009);
	CreateDynamicObject(2500, 1966.43567, 2433.67334, 16.80070,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1280, 1915.48938, 2416.21484, 10.40540,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1280, 1918.93848, 2416.19873, 10.40540,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1280, 1911.89221, 2420.33130, 10.40540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(4866, 2139.00488, 1612.28271, 455.92230,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3491, 2177.28809, 1644.39612, 464.51440,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 2009.95325, 1446.04456, 9.79520,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3749, 1988.31421, 1444.66052, 15.33740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1981.03491, 1446.51135, 9.82030,   0.00000, 0.00000, 199.76711);
	CreateDynamicObject(987, 1925.70142, 1283.52124, 9.82030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1914.50232, 1287.66675, 9.81290,   0.00000, 0.00000, 339.37350);
	CreateDynamicObject(9241, 1900.10828, 1329.30786, 25.35260,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(9241, 1899.68750, 1359.95947, 25.37770,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(11490, 1876.55261, 1303.26111, 54.36880,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11490, 1859.39307, 1318.04004, 54.37950,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(11491, 1876.51086, 1292.23254, 55.85900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11491, 1848.32727, 1318.08826, 55.77200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(980, 1901.24597, 1305.82471, 55.94630,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(980, 1907.07288, 1300.03320, 55.94630,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(980, 1901.31384, 1294.27576, 55.97140,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(980, 1901.26416, 1303.08875, 58.67160,   89.27700, 0.00000, 0.00000);
	CreateDynamicObject(980, 1901.30554, 1297.05542, 58.69660,   90.24070, 0.00000, 0.00000);
	CreateDynamicObject(987, 1881.58411, 1377.42395, 23.71870,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1893.45361, 1377.27942, 23.71870,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 1881.61584, 1365.35156, 23.71870,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1905.31165, 1377.24512, 23.71870,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 1916.39771, 1377.20044, 23.71870,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 1916.28955, 1365.34656, 23.71870,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(987, 1916.39063, 1353.27966, 23.71870,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(987, 1916.44104, 1341.33142, 23.71870,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(987, 1916.33704, 1329.45923, 23.71870,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(987, 1916.11743, 1317.80652, 23.71870,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(987, 1916.11096, 1313.23584, 23.71870,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(987, 1904.42273, 1313.73962, 23.71870,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1892.45605, 1313.79578, 23.71870,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1881.69714, 1313.79395, 23.71870,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1881.81824, 1325.68262, 23.71870,   0.00000, 0.00000, 269.99991);
	CreateDynamicObject(987, 1881.93872, 1337.57275, 23.71870,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(987, 1881.98425, 1349.56531, 23.71870,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2714, 1946.83191, 1277.97485, 16.11750,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14416, 1879.28174, 1351.60864, 20.54260,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(14416, 1874.18066, 1351.62524, 16.89270,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(16151, 1880.10107, 1302.74744, 56.26820,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(974, 1852.08936, 1349.71326, 54.35070,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1852.01245, 1356.21545, 54.37030,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1851.95654, 1362.87256, 54.37580,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1852.14404, 1343.06885, 54.35070,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1852.23523, 1336.46301, 54.34130,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1852.30603, 1329.81531, 54.35680,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1852.37146, 1323.22180, 54.34570,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(8148, 2032.01807, 1364.86450, 12.92120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3749, 1947.85107, 1283.48474, 15.59340,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 2021.92554, 1446.05676, 9.82030,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 2032.27832, 1446.03101, 9.82030,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(987, 2020.31226, 1283.45093, 9.82030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 2008.33777, 1283.41345, 9.82030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1996.37524, 1283.43042, 9.82030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1984.47034, 1283.46045, 9.81290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1972.64355, 1283.43530, 9.82030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1960.84521, 1283.45325, 9.82030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1954.78796, 1283.11230, 9.82030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(974, 1880.88245, 1289.51245, 54.20050,   269.75909, 0.00000, 0.00000);
	CreateDynamicObject(974, 1887.50867, 1289.45715, 54.22570,   269.75909, 0.00000, 0.00000);
	CreateDynamicObject(974, 1894.13086, 1289.45923, 54.25070,   269.75909, 0.00000, 0.00000);
	CreateDynamicObject(974, 1900.68506, 1289.43848, 54.27560,   269.75909, 0.00000, 0.00000);
	CreateDynamicObject(974, 1907.34790, 1289.44543, 54.28740,   269.75909, 0.00000, 0.00000);
	CreateDynamicObject(974, 1870.87915, 1310.95386, 54.32560,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.80322, 1317.60046, 54.31610,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.74097, 1324.22595, 54.32580,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.68213, 1330.87366, 54.32560,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.61865, 1337.52795, 54.31460,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.53625, 1344.21704, 54.32560,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.45996, 1350.81104, 54.32580,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.36755, 1357.44006, 54.29650,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.31836, 1364.10046, 54.29890,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1877.60071, 1308.73572, 54.29480,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1870.29456, 1370.77332, 54.29350,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(974, 1869.72656, 1376.00305, 54.28300,   269.75909, 0.00000, 179.51781);
	CreateDynamicObject(974, 1863.05542, 1376.07544, 54.27800,   269.75909, 0.00000, 179.51781);
	CreateDynamicObject(982, 1873.50732, 1324.89832, 54.99160,   0.00000, 359.14050, 0.85930);
	CreateDynamicObject(982, 1873.17395, 1350.48596, 55.00690,   0.00000, 359.14050, 0.85930);
	CreateDynamicObject(984, 1872.97705, 1369.65637, 54.91170,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(983, 1872.98181, 1375.47107, 54.95660,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(982, 1849.49158, 1337.17334, 55.02450,   0.00000, 358.28101, 0.45460);
	CreateDynamicObject(984, 1866.59888, 1378.82104, 54.91510,   0.00000, 0.00000, 269.75900);
	CreateDynamicObject(983, 1864.36304, 1373.30725, 54.95240,   0.00000, 0.00000, 269.75909);
	CreateDynamicObject(983, 1867.64526, 1370.07471, 54.97880,   0.00000, 0.00000, 181.23711);
	CreateDynamicObject(983, 1864.49756, 1366.88452, 55.05650,   0.00000, 0.00000, 90.13680);
	CreateDynamicObject(984, 1849.31335, 1356.45544, 55.01030,   0.00000, 0.00000, 0.85930);
	CreateDynamicObject(974, 1851.95862, 1364.18176, 54.37570,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(984, 1855.62122, 1367.52393, 54.99470,   0.00000, 0.00000, 269.75900);
	CreateDynamicObject(983, 1849.24646, 1364.34656, 55.06120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(983, 1859.75354, 1375.62683, 54.95460,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(983, 1876.90247, 1312.10693, 54.99450,   0.00000, 0.00000, 270.61850);
	CreateDynamicObject(974, 1874.55994, 1308.71558, 54.31620,   269.75909, 0.00000, 270.61841);
	CreateDynamicObject(983, 1880.34155, 1308.87781, 54.99860,   0.00000, 0.00000, 180.37750);
	CreateDynamicObject(982, 1890.40247, 1286.79675, 54.88150,   0.00000, 0.00000, 269.75900);
	CreateDynamicObject(983, 1877.56555, 1290.03955, 54.87360,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(984, 1904.17786, 1286.75757, 54.85170,   0.00000, 0.85930, 269.75900);
	CreateDynamicObject(984, 1910.62585, 1293.10754, 54.85960,   0.00000, 0.85930, 179.51801);
	CreateDynamicObject(8149, 1841.69678, 1371.55615, 19.02330,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(8209, 1890.93933, 1442.79626, 19.02330,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(8210, 1944.64734, 1442.79956, 19.02330,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(8210, 1869.35510, 1293.07056, 19.02330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(987, 1905.51697, 1293.15625, 15.92230,   0.00000, 0.00000, 359.14050);
	CreateDynamicObject(3279, 1854.57117, 1364.70251, 54.43240,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3528, 1876.75415, 1295.44104, 52.71560,   0.00000, 223.34950, 0.00000);
	CreateDynamicObject(3528, 1852.34460, 1317.47180, 52.87630,   0.00000, 223.34950, 0.00000);
	CreateDynamicObject(1231, 1882.56982, 1292.28711, 57.10350,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2790, 1881.46851, 1357.18372, 21.55690,   0.00000, 0.00000, 269.75900);
	CreateDynamicObject(14467, 1889.79431, 1296.01868, 57.10680,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14806, 1855.90002, 1313.78955, 56.97330,   0.00000, 0.00000, 179.51820);
	CreateDynamicObject(2628, 1854.03162, 1321.88782, 55.88140,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2575, 1860.38586, 1320.06616, 56.26950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1828, 1856.92627, 1318.10095, 55.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1736, 1852.46106, 1318.06201, 58.09180,   0.00000, 0.00000, 90.24080);
	CreateDynamicObject(1736, 1876.56873, 1296.30396, 57.83290,   0.00000, 0.00000, 182.09660);
	CreateDynamicObject(14491, 1848.87732, 1318.06885, 58.25230,   0.00000, 0.00000, 182.95621);
	CreateDynamicObject(1704, 1875.21375, 1301.50244, 55.87340,   0.00000, 0.00000, 317.02811);
	CreateDynamicObject(1723, 1872.52905, 1298.55408, 55.87450,   0.00000, 0.00000, 90.99630);
	CreateDynamicObject(1724, 1876.18115, 1298.56274, 55.87450,   0.00000, 0.00000, 230.98039);
	CreateDynamicObject(1825, 1872.64392, 1292.47705, 55.84140,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1827, 1874.27417, 1299.56995, 55.87500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11631, 1873.09656, 1306.78992, 57.12250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2356, 1873.19531, 1306.13806, 55.87120,   0.00000, 0.00000, 329.91971);
	CreateDynamicObject(2596, 1880.76636, 1297.95886, 58.61440,   0.00000, 0.00000, 263.74310);
	CreateDynamicObject(2232, 1872.36646, 1301.39270, 56.47430,   0.00000, 0.00000, 94.53800);
	CreateDynamicObject(2232, 1872.35974, 1297.70190, 56.47430,   0.00000, 0.00000, 91.10030);
	CreateDynamicObject(2101, 1872.14783, 1303.10095, 55.87960,   0.00000, 0.00000, 88.52200);
	CreateDynamicObject(1828, 1874.66565, 1299.14502, 55.84930,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1665, 1879.12476, 1302.26831, 56.93420,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1551, 1873.83862, 1299.19495, 56.54190,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1551, 1873.91125, 1299.91882, 56.54190,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1551, 1874.54163, 1299.07690, 56.51680,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1551, 1874.18054, 1299.63306, 56.54190,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1665, 1874.68176, 1299.64673, 56.33710,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1485, 1874.92834, 1299.70837, 56.35160,   0.00000, 0.00000, 192.40981);
	CreateDynamicObject(625, 1878.37976, 1292.75830, 56.71900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1364, 1861.68164, 1362.42505, 55.15710,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1364, 1889.22314, 1294.85864, 55.11180,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1361, 1847.83313, 1322.82825, 56.51960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1597, 1865.25537, 1342.04224, 57.03040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1597, 1865.23755, 1334.65283, 57.03040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1597, 1865.28992, 1349.71692, 57.03040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1597, 1865.28210, 1357.28052, 57.03040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, 1855.61243, 1364.76733, 62.27410,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, 1907.92566, 1291.69971, 54.43610,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1597, 1854.74585, 1355.50610, 57.03040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1597, 1854.78345, 1348.20276, 57.03040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1597, 1854.79431, 1341.20032, 57.03040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18449, 2313.15088, 553.18188, 43.87440,   0.00000, 348.82730, 303.75000);
	CreateDynamicObject(18449, 2356.17920, 488.72269, 62.81820,   0.00000, 343.67068, 303.75000);
	CreateDynamicObject(18449, 2397.83423, 426.43970, 89.01690,   0.00000, 337.65460, 303.75000);
	CreateDynamicObject(18449, 2436.38232, 368.87149, 122.37540,   0.00000, 330.77921, 303.75000);
	CreateDynamicObject(18449, 2473.98364, 312.57431, 162.98930,   0.00000, 327.34140, 303.75000);
	CreateDynamicObject(18449, 2508.60742, 260.76511, 206.18240,   0.00000, 323.04419, 303.75000);
	CreateDynamicObject(18449, 2542.05786, 210.70309, 255.92210,   0.00000, 317.88760, 303.75000);
	CreateDynamicObject(18449, 2574.90771, 161.57671, 309.38620,   0.00000, 317.88760, 303.75000);
	CreateDynamicObject(18449, 2607.52539, 112.84410, 362.43289,   0.00000, 317.88760, 303.75000);
	CreateDynamicObject(18449, 2639.95288, 64.35220, 415.16641,   0.00000, 317.88760, 303.75000);
	CreateDynamicObject(18449, 2672.41138, 15.71990, 468.02780,   0.00000, 317.88760, 303.75000);
	CreateDynamicObject(18449, 2703.46460, -30.64070, 518.51270,   0.00000, 317.88760, 303.75000);
	CreateDynamicObject(18449, 2735.89014, -79.11710, 571.27271,   0.00000, 317.88760, 303.75000);
	CreateDynamicObject(8040, 2774.06372, -136.88220, 599.05371,   0.00000, 0.00000, 123.75000);
	CreateDynamicObject(1632, 2285.41968, 587.02142, 37.86520,   0.00000, 0.00000, 33.75000);
	CreateDynamicObject(1632, 2288.90894, 589.35938, 37.92020,   0.00000, 0.00000, 33.75000);
	CreateDynamicObject(1632, 2292.38721, 591.69092, 37.91400,   0.00000, 0.00000, 33.75000);
	CreateDynamicObject(1225, 2246.67529, 633.01892, 53.82760,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 2258.56543, 649.63751, 55.53760,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 2222.37891, 681.14899, 68.08850,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 2230.23535, 710.24451, 78.07760,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 2158.55786, 746.26923, 44.00110,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 2199.41919, 691.28131, 64.17230,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, 2177.16553, 746.65167, 44.33660,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16123, 658.08862, 69.37160, 11.55880,   0.00000, 0.00000, 168.75000);
	CreateDynamicObject(16121, 656.68768, 24.28500, 19.21290,   340.23300, 48.98780, 172.96989);
	CreateDynamicObject(16121, 665.16699, -19.74890, 10.10780,   0.00000, 0.00000, 146.25000);
	CreateDynamicObject(16121, 628.79742, -47.02930, 7.70880,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(16121, 600.09998, -35.59590, 10.26490,   0.00000, 0.00000, 213.75000);
	CreateDynamicObject(16120, 558.82538, -0.62250, 22.28890,   0.00000, 7.73490, 0.00000);
	CreateDynamicObject(16120, 541.34430, 41.64290, 17.55490,   347.96790, 0.00000, 337.50000);
	CreateDynamicObject(16118, 546.20129, 81.60950, 12.00530,   0.00000, 0.00000, 11.25000);
	CreateDynamicObject(16118, 549.21948, 125.35880, 13.05160,   0.00000, 0.00000, 337.50000);
	CreateDynamicObject(16118, 581.12128, 167.05960, 13.39570,   0.00000, 349.68680, 112.50000);
	CreateDynamicObject(16122, 631.83252, 160.30009, 9.34240,   0.00000, 0.00000, 247.50000);
	CreateDynamicObject(16118, 622.33789, 160.81410, 9.05960,   0.00000, 349.68680, 78.75000);
	CreateDynamicObject(16118, 627.07050, 44.37330, -3.40790,   0.00000, 349.68680, 101.25000);
	CreateDynamicObject(16133, 604.28601, 99.22440, -0.31880,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, 631.74231, 65.54940, 1.40270,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(616, 557.53442, 102.52460, 10.68860,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(617, 603.73688, 100.29700, 19.77920,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(654, 639.41382, 104.55280, 6.06660,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(654, 627.90692, 22.37330, 2.45830,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(655, 580.26581, 7.82940, 18.49520,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(655, 604.08948, 47.66550, 0.92980,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 617.59149, -3.68720, 1.92570,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(669, 599.86182, -7.54610, 10.37010,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(670, 581.02252, 123.47540, 12.12630,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(674, 624.56458, 96.75030, 4.15950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(674, 621.39117, 113.50540, 6.30010,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(674, 583.41107, 97.52420, 6.72980,   0.00000, 0.00000, 326.25000);
	CreateDynamicObject(674, 572.44873, 110.10520, 8.74570,   0.00000, 0.00000, 11.25000);
	CreateDynamicObject(674, 571.33807, 136.97099, 11.61310,   0.00000, 0.00000, 326.25000);
	CreateDynamicObject(674, 562.99109, 86.06150, 11.46530,   0.00000, 0.00000, 337.50000);
	CreateDynamicObject(676, 571.72699, 74.08080, 9.13280,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(676, 595.72668, 89.69330, 3.80490,   0.00000, 0.00000, 326.25000);
	CreateDynamicObject(676, 591.16071, 140.99460, 7.41600,   0.00000, 0.00000, 326.25000);
	CreateDynamicObject(676, 633.24512, 109.56820, 6.74610,   0.00000, 0.00000, 326.25000);
	CreateDynamicObject(686, 577.47980, 80.86090, 7.20540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(687, 592.46558, 90.10820, 3.41680,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(690, 617.95251, 59.22320, -0.58480,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(693, 620.87598, 12.96450, 5.21320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(696, 611.60461, 145.08020, 13.47740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, 591.44879, 13.94160, 11.17130,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(719, 583.97198, 57.85060, 7.22920,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(726, 636.60870, -14.30610, 6.09130,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(727, 630.29279, -3.57290, 3.21890,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(730, 621.00592, 77.64630, 2.24960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3593, 592.42828, 96.01260, 4.94610,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3594, 631.04327, 76.38720, 3.92810,   0.00000, 7.73490, 270.00000);
	CreateDynamicObject(12957, 569.39148, 101.26060, 10.09000,   0.00000, 0.00000, 281.25000);
	CreateDynamicObject(18248, 576.30341, 85.25490, 16.49790,   7.73490, 6.01610, 56.25000);
	CreateDynamicObject(16192, 8206.02148, -1661.89966, -39.76140,   0.85940, 354.84341, 358.28110);
	CreateDynamicObject(16061, 8215.81836, -1678.86133, 3.19320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16061, 8236.56934, -1700.83496, 1.40770,   0.00000, 1.71890, 289.52621);
	CreateDynamicObject(16061, 8198.54102, -1683.78992, 2.57930,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(739, 8198.68555, -1718.59241, -37.94920,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(619, 8234.58203, -1731.22742, 3.49250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18259, 8215.67871, -1724.30811, 5.97020,   0.00000, 0.00000, 84.22480);
	CreateDynamicObject(1481, 8224.15332, -1730.51941, 6.70920,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1495, 8214.94824, -1729.40930, 6.05080,   0.00000, 0.00000, 208.73900);
	CreateDynamicObject(14805, 8221.11621, -1725.12427, 6.94290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2297, 8221.36719, -1720.13049, 6.05010,   0.00000, 0.00000, 315.30930);
	CreateDynamicObject(1667, 8221.99316, -1726.35339, 6.81970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1828, 8222.03906, -1722.85754, 6.02880,   0.00000, 0.00000, 84.12080);
	CreateDynamicObject(1829, 8224.08398, -1721.61194, 6.52060,   0.00000, 1.71890, 268.04031);
	CreateDynamicObject(14527, 8221.28223, -1724.78125, 7.00980,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1815, 8223.33887, -1728.32703, 6.05530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1668, 8224.04199, -1727.69434, 6.71840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1669, 8224.04395, -1727.86243, 6.71840,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1667, 8223.57520, -1727.67957, 6.64030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1664, 8224.27344, -1727.81958, 6.69340,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1665, 8223.76660, -1727.98816, 6.58720,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1512, 8224.12402, -1728.07434, 6.72420,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2344, 8218.93457, -1725.04163, 32.84900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14446, 8210.63867, -1724.01697, 6.65640,   0.00000, 0.00000, 86.69910);
	CreateDynamicObject(1742, 8208.60840, -1728.13721, 6.05160,   0.00000, 0.00000, 83.26140);
	CreateDynamicObject(2190, 8210.17578, -1719.88831, 6.87670,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2568, 8209.75000, -1720.07129, 6.04830,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1671, 8210.49121, -1720.96667, 6.46440,   0.00000, 0.00000, 210.45799);
	CreateDynamicObject(643, 8222.77637, -1734.05994, 6.50160,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1280, 8222.36035, -1730.18591, 6.45750,   0.00000, 0.00000, 88.41800);
	CreateDynamicObject(1243, 8185.55713, -1824.73962, -1.95240,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1243, 8148.47754, -1789.25305, -2.52650,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11496, 8201.72754, -1768.80591, 1.75260,   0.85940, 0.00000, 226.78729);
	CreateDynamicObject(1608, 8190.76367, -1793.90247, -1.31310,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1608, 8188.05420, -1778.43652, -1.32460,   4.29720, 0.00000, 249.13271);
	CreateDynamicObject(1608, 8173.27295, -1794.74341, -1.20600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16097, 8270.33594, -1702.61768, -10.96830,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1458, 8219.59277, -1740.30408, 5.83180,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1457, 8232.07520, -1728.20459, 7.28150,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, 8218.53516, -1759.69580, 3.63590,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2035, 8222.08691, -1725.63379, 6.75550,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(854, 8218.78516, -1759.33838, 5.21850,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1280, 8220.29883, -1759.75110, 5.68580,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3502, 3091.57251, -1518.97021, 1324.43066,   269.75919, 0.00000, 0.00000);
	CreateDynamicObject(3502, 3094.22119, -1536.11829, 1205.68860,   269.75919, 0.00000, 0.00000);
	CreateDynamicObject(3502, 3096.57739, -1518.22620, 1002.36389,   269.75919, 0.00000, 0.00000);
	CreateDynamicObject(3502, 3097.68286, -1537.41418, 889.66632,   269.75919, 0.00000, 0.00000);
	CreateDynamicObject(3502, 3100.47363, -1518.81006, 700.34381,   269.75919, 0.00000, 0.00000);
	CreateDynamicObject(3502, 3100.40308, -1538.85828, 517.22150,   269.75919, 0.00000, 0.00000);
	CreateDynamicObject(3502, 3104.97852, -1520.56750, 212.74380,   269.75919, 0.00000, 0.00000);
	CreateDynamicObject(3502, 3105.50586, -1526.22876, 1.89390,   269.75919, 0.00000, 0.00000);
	CreateDynamicObject(5038, 3107.02979, -1529.51135, 248.48860,   0.00000, 89.38140, 0.00000);
	CreateDynamicObject(5038, 3105.55444, -1529.38867, 384.39639,   0.00000, 89.38140, 0.00000);
	CreateDynamicObject(5038, 3104.05835, -1529.28467, 520.29962,   0.00000, 89.38140, 0.00000);
	CreateDynamicObject(5038, 3102.59399, -1529.16602, 655.79199,   0.00000, 89.38140, 0.00000);
	CreateDynamicObject(5038, 3101.11011, -1529.03027, 791.01813,   0.00000, 89.38140, 0.00000);
	CreateDynamicObject(5038, 3099.65479, -1528.91309, 926.62500,   0.00000, 89.38140, 0.00000);
	CreateDynamicObject(5038, 3098.17578, -1528.79419, 1062.50842,   0.00000, 89.38140, 0.00000);
	CreateDynamicObject(5038, 3096.71118, -1528.68103, 1198.09509,   0.00000, 89.38140, 0.00000);
	CreateDynamicObject(5310, 3072.40259, -1527.36865, 1403.36206,   23.20480, 0.00000, 90.00000);
	CreateDynamicObject(3755, 3096.97217, -1532.07556, 1419.34912,   108.28890, 0.00000, 270.00000);
	CreateDynamicObject(3755, 3087.25635, -1503.20288, 1402.39673,   89.38140, 0.00000, 0.00010);
	CreateDynamicObject(3755, 3080.94629, -1550.03406, 1402.38403,   89.38140, 0.00000, 180.00011);
	CreateDynamicObject(3755, 3054.78955, -1523.82532, 1402.39856,   89.38140, 0.00000, 90.00020);
	CreateDynamicObject(5310, 3069.95874, -1515.71863, 1427.67798,   180.48199, 0.00000, 90.00000);
	CreateDynamicObject(5038, 3108.48462, -1529.60107, 114.12340,   0.00000, 89.38140, 0.00000);
	CreateDynamicObject(5038, 3095.21484, -1528.55347, 1333.99170,   0.00000, 89.38140, 0.00000);
	CreateDynamicObject(3524, 3094.69092, -1526.61328, 1404.10986,   30.93970, 0.00000, 270.00000);
	CreateDynamicObject(3524, 3094.68262, -1517.63342, 1404.13965,   30.93970, 0.00000, 270.00000);
	CreateDynamicObject(3524, 3094.65918, -1535.42334, 1404.11523,   30.93970, 0.00000, 270.00000);
	CreateDynamicObject(1318, 3092.39551, -1514.27515, 1408.09302,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1318, 3092.48389, -1522.22693, 1407.85132,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1318, 3092.29590, -1531.15576, 1407.88074,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1318, 3092.11133, -1538.57263, 1407.57153,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1318, 3083.98071, -1511.22925, 1410.31140,   69.61430, 8.59440, 262.02429);
	CreateDynamicObject(1318, 3078.29150, -1510.94763, 1412.39648,   69.61430, 8.59440, 262.02429);
	CreateDynamicObject(1318, 3071.58545, -1510.64526, 1414.88855,   69.61430, 8.59440, 262.02429);
	CreateDynamicObject(1318, 3082.78125, -1542.06104, 1410.69531,   69.61430, 8.59440, 262.02429);
	CreateDynamicObject(1318, 3075.99854, -1542.22583, 1412.05383,   69.61430, 8.59440, 262.02429);
	CreateDynamicObject(1318, 3069.41675, -1542.62012, 1414.96228,   69.61430, 8.59440, 262.02429);
	CreateDynamicObject(1310, 3094.64893, -1523.56799, 1402.79407,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1310, 3094.64893, -1526.59399, 1402.78943,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1310, 3094.64868, -1529.62390, 1402.80432,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1310, 3094.64893, -1532.63452, 1402.79053,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1310, 3094.64893, -1535.59216, 1402.78101,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1310, 3094.64893, -1538.56641, 1402.77551,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1310, 3094.64893, -1520.51660, 1402.79431,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1310, 3094.64893, -1517.56921, 1402.79333,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1310, 3094.64893, -1514.60376, 1402.78308,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1238, 3088.12549, -1526.41797, 1403.62585,   0.00000, 22.34540, 0.00000);
	CreateDynamicObject(1775, 3062.41187, -1526.02893, 1415.20740,   0.00000, 0.00000, 89.92260);
	CreateDynamicObject(8150, -1080.10181, -1055.48206, 131.31290,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(8150, -1017.44373, -993.03278, 131.28870,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(8150, -1079.57068, -931.01971, 131.31979,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8152, -1096.84644, -1025.83069, 131.31979,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(8210, -1176.51819, -973.46619, 131.18800,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(8210, -1148.49744, -930.97418, 131.31979,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3749, -1175.37280, -939.65747, 133.87720,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3279, -1022.73969, -936.76563, 127.99440,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3279, -1022.07257, -1051.78564, 128.19440,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3279, -1171.80872, -1049.72546, 128.24440,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3279, -1170.97070, -952.19537, 128.06940,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3797, -1177.47290, -946.96222, 132.58260,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(9623, -1209.07043, -1073.84668, 129.95990,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(8034, -1033.58032, -987.52380, 132.96320,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3866, -1165.88318, -1041.87329, 135.95731,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3866, -1028.60205, -944.94220, 135.95731,   0.00000, 0.00000, 269.99991);
	CreateDynamicObject(8513, -1105.56555, -990.64850, 132.28070,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3279, -1151.38696, -1006.01099, 127.94440,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(5520, -1089.66345, -1012.88831, 133.16350,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3641, -1144.48633, -994.83942, 130.56129,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3640, -1151.55249, -978.60498, 132.55540,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3624, -1206.99902, -922.83789, 131.64040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(13696, -1091.37317, -962.77032, 128.23160,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(6922, -1123.80212, -960.93768, 130.97200,   0.00000, 0.00000, 269.99991);
	CreateDynamicObject(4178, -1113.76233, -1018.35052, 131.26579,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(17522, -1063.70862, -1040.58435, 130.46320,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3409, -1071.95374, -934.89270, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1067.72803, -935.10211, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1063.82263, -935.29773, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1060.13330, -935.36469, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1071.58264, -939.67822, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1071.70117, -944.25812, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1072.01135, -948.52191, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1067.56738, -939.74011, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1063.66821, -939.90631, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1067.70251, -944.18219, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1068.02466, -948.70752, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1063.69312, -944.28192, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1063.97778, -948.66321, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1060.14551, -939.94952, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1060.12732, -948.52008, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3409, -1059.95483, -944.29791, 128.38210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(640, -1057.96191, -933.56909, 128.91580,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(640, -1057.78101, -948.00220, 128.91580,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(644, -1057.51233, -944.55249, 128.72780,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(644, -1057.75232, -937.12622, 128.72780,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -1208.49023, -1068.36340, 127.88940,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -1177.66138, -1095.67236, 128.62450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -1141.20044, -1094.57153, 128.62450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -1132.58301, -1096.12610, 128.62450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -1093.97119, -1095.26074, 128.62450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -1081.64343, -1095.55847, 128.62450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3279, -1035.49475, -985.67682, 136.77480,   0.00000, 0.00000, 0.00020);
	CreateDynamicObject(16644, -1052.92102, -966.65167, 136.47630,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16644, -1054.55420, -1011.11560, 136.49471,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1553, -1052.37549, -1001.47852, 129.41260,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1553, -1054.24158, -1001.49908, 129.41260,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1553, -1052.36780, -1001.58557, 131.81419,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1553, -1054.30066, -1001.58600, 131.79890,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1425, -1054.69189, -955.24921, 128.67120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18259, -1039.58203, -1049.18103, 129.86780,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1704, -1033.22620, -1052.54138, 129.95061,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1723, -1039.44263, -1053.35254, 129.95180,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1825, -1045.85266, -1050.48242, 129.93190,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2008, -1048.37073, -1045.27014, 129.95370,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2079, -1048.00952, -1046.32996, 130.51450,   0.00000, 0.00000, 225.00000);
	CreateDynamicObject(2125, -1046.00452, -1050.47632, 130.26360,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2166, -1046.38440, -1045.26001, 129.95370,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1670, -1046.06299, -1050.50085, 130.83611,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16770, -1151.76160, -961.95349, 138.11501,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14445, -1092.50867, -987.45349, 134.25340,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14445, -1092.93286, -979.95532, 134.25340,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(17044, -1173.83728, -996.62872, 128.21581,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18234, -1119.60925, -940.86121, 136.49451,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(16386, -1100.13208, -1039.35559, 139.52811,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(12959, -1036.44128, -1024.78711, 127.83210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(974, -1023.69263, -1029.00732, 130.83670,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(974, -1020.52551, -1028.97961, 130.82150,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1407, -1042.10254, -1019.21411, 128.89371,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1407, -1042.10144, -1019.68372, 130.29201,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1407, -1042.15039, -1019.67468, 131.71741,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3797, -1177.47290, -932.03748, 132.23779,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1245, -1182.44458, -908.98102, 129.43140,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3749, -1047.92627, -1312.27563, 132.69769,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1503, -1195.82007, -1332.20398, 151.83620,   0.00000, 0.00000, 168.75000);
	CreateDynamicObject(1632, -1256.34021, -1482.15918, 103.97420,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1632, -1398.64478, -1617.89355, 102.22350,   0.00000, 0.00000, 168.75000);
	CreateDynamicObject(2931, -1429.21448, -957.63647, 199.73869,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3877, -1208.50415, -1079.42310, 128.89940,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, -1039.99268, -1314.37549, 129.20050,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, -1055.87024, -1314.37549, 129.41920,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3877, -1323.20837, -1377.90039, 115.99820,   0.00000, 0.00000, 33.75000);
	CreateDynamicObject(3877, -1322.23010, -1394.99915, 115.22460,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11387, 26.56055, -179.84863, 4.16689,   0.00000, 0.00000, 267.37427);
	CreateDynamicObject(5340, 56.35268, -159.20813, 1.21843,   0.00000, 0.00000, 87.33951);
	CreateDynamicObject(5340, 52.17810, -159.02910, 1.16002,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(5340, 45.23961, -158.70261, -0.35807,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(5340, 38.22668, -158.35535, -0.33998,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(5340, 31.25660, -158.03607, -0.33998,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(5340, 24.25727, -157.68417, -0.31498,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(5340, 17.27944, -157.35394, -0.29185,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(5340, 10.29852, -157.05975, -0.28998,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(5340, 6.75059, -156.86191, -0.28998,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(5340, 0.14672, -158.26692, -0.27549,   0.00000, 0.00000, 117.11078);
	CreateDynamicObject(5340, -1.17411, -158.87291, -0.28385,   0.00000, 0.00000, 117.10876);
	CreateDynamicObject(5340, -4.61533, -163.96423, -0.27296,   0.00000, 0.00000, 174.67383);
	CreateDynamicObject(5340, -5.13277, -170.94362, -0.26756,   0.00000, 0.00000, 176.65662);
	CreateDynamicObject(5340, -5.67937, -177.93579, -0.25374,   0.00000, 0.00000, 174.67163);
	CreateDynamicObject(5340, -6.08142, -184.84065, -0.27328,   0.00000, 0.00000, 178.64160);
	CreateDynamicObject(5340, 59.58478, -162.95731, 1.23333,   0.00000, 0.00000, 357.26990);
	CreateDynamicObject(5340, 59.22168, -170.10059, 1.24632,   0.00000, 0.00000, 357.25061);
	CreateDynamicObject(5340, 59.32031, -169.52441, 0.77132,   0.00000, 0.00000, 357.49524);
	CreateDynamicObject(5340, 58.86816, -177.09082, 1.25605,   0.00000, 0.00000, 356.26465);
	CreateDynamicObject(5340, 58.86035, -178.10059, 1.22668,   0.00000, 0.00000, 357.26196);
	CreateDynamicObject(2790, 58.62207, -184.26758, -0.68280,   0.00000, 0.00000, 267.68188);
	CreateDynamicObject(2790, 58.42773, -189.41016, -0.68280,   0.00000, 0.00000, 267.68188);
	CreateDynamicObject(2790, 58.23633, -194.56445, -0.68280,   0.00000, 0.00000, 267.68188);
	CreateDynamicObject(2790, 58.17578, -196.39453, -0.68280,   0.00000, 0.00000, 267.68188);
	CreateDynamicObject(4100, 58.45185, -188.00914, 2.19727,   0.00000, 0.00000, 48.13977);
	CreateDynamicObject(4100, 36.43985, -158.20877, 2.94175,   0.00000, 0.00000, 317.58032);
	CreateDynamicObject(4100, 22.70215, -157.54785, 2.94175,   0.00000, 0.00000, 317.57080);
	CreateDynamicObject(4100, 10.28987, -156.99661, 2.96675,   0.00000, 0.00000, 317.57629);
	CreateDynamicObject(4100, -4.76478, -167.13228, 2.66657,   0.00000, 0.00000, 46.15161);
	CreateDynamicObject(4100, -5.72656, -180.82227, 2.63619,   0.00000, 0.00000, 46.14807);
	CreateDynamicObject(4100, 7.19328, -196.63792, 2.32544,   0.00000, 0.00000, 317.07629);
	CreateDynamicObject(4100, 20.92610, -197.44850, 2.29748,   0.00000, 0.00000, 317.06543);
	CreateDynamicObject(4100, 34.63588, -198.17728, 2.27523,   0.00000, 0.00000, 317.06543);
	CreateDynamicObject(971, -0.47949, -158.67480, 0.32820,   0.00000, 0.00000, 27.02087);
	CreateDynamicObject(971, -3.60352, -191.51465, 0.16939,   0.00000, 0.00000, 306.90308);
	CreateDynamicObject(1358, 0.16992, -193.88184, 1.70422,   0.00000, 0.00000, 124.09607);
	CreateDynamicObject(11102, 46.01953, -180.63086, 2.84552,   0.00000, 0.00000, 87.33582);
	CreateDynamicObject(11102, 27.27353, -166.00508, 2.93513,   0.00000, 0.00000, 356.51184);
	CreateDynamicObject(11389, 43.05957, -171.22559, 3.92127,   0.00000, 0.00000, 266.96777);
	CreateDynamicObject(11388, 43.09195, -171.15900, 7.49259,   0.00000, 0.00000, 86.99243);
	CreateDynamicObject(11391, 35.43945, -162.72168, 2.03502,   0.00000, 0.00000, 266.68213);
	CreateDynamicObject(2007, 27.91305, -176.51443, 0.80751,   0.00000, 0.00000, 87.88196);
	CreateDynamicObject(1757, 34.11213, -178.86681, 0.80751,   0.00000, 0.00000, 141.29211);
	CreateDynamicObject(2069, 35.94893, -178.88513, 0.80751,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1491, 36.21052, -172.19794, 0.86190,   0.00000, 0.00000, 171.73047);
	CreateDynamicObject(2008, 30.32275, -173.19922, 0.80751,   0.00000, 0.00000, 240.40527);
	CreateDynamicObject(1714, 28.85593, -172.99274, 0.80751,   0.00000, 0.00000, 49.62469);
	CreateDynamicObject(2007, 32.96288, -162.62151, 0.48251,   0.00000, 0.00000, 359.24744);
	CreateDynamicObject(2007, 32.08995, -162.58237, 0.48251,   0.00000, 0.00000, 359.24744);
	CreateDynamicObject(2007, 31.49732, -162.53363, 0.60751,   0.00000, 0.00000, 359.24744);
	CreateDynamicObject(2007, 37.18751, -162.59224, 0.20751,   0.00000, 0.00000, 359.24744);
	CreateDynamicObject(2007, 38.36195, -162.72304, 0.20751,   0.00000, 0.00000, 356.77747);
	CreateDynamicObject(2007, 42.29297, -163.14099, 0.53251,   0.00000, 0.00000, 359.24744);
	CreateDynamicObject(2007, 41.31987, -163.07298, 0.58251,   0.00000, 0.00000, 359.24744);
	CreateDynamicObject(2007, 40.74393, -163.00165, 0.53251,   0.00000, 0.00000, 359.24744);
	CreateDynamicObject(2000, 44.92541, -164.90088, 0.25751,   0.00000, 0.00000, 11.90991);
	CreateDynamicObject(2000, 51.87433, -168.11658, 0.20751,   0.00000, 0.00000, 11.90918);
	CreateDynamicObject(2000, 49.96492, -164.92735, 0.28251,   0.00000, 0.00000, 39.31915);
	CreateDynamicObject(2000, 51.56833, -165.36832, 0.60751,   0.00000, 0.00000, 39.31458);
	CreateDynamicObject(2000, 52.68855, -165.54926, 0.50751,   0.00000, 0.00000, 39.31458);
	CreateDynamicObject(2000, 52.94043, -164.41406, 0.63950,   0.00000, 0.00000, 39.30908);
	CreateDynamicObject(2000, 51.69089, -164.33868, 0.65751,   0.00000, 0.00000, 39.31458);
	CreateDynamicObject(2596, 36.80920, -172.93488, 3.73337,   0.00000, 0.00000, 298.92041);
	CreateDynamicObject(1432, 39.71329, -177.30106, 0.80751,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2893, 54.27148, -169.07520, 2.04404,   7.93762, 0.00000, 356.24268);
	CreateDynamicObject(2893, 56.05827, -169.21112, 2.03404,   7.93762, 0.00000, 357.49512);
	CreateDynamicObject(2893, 56.45573, -163.46516, 1.97140,   343.13269, 0.00000, 355.99512);
	CreateDynamicObject(2893, 54.60925, -163.39313, 1.95904,   343.13049, 0.00000, 355.98999);
	CreateDynamicObject(2893, 45.87572, -168.58266, 2.03404,   7.93762, 0.00000, 356.24268);
	CreateDynamicObject(2893, 47.68534, -168.67912, 2.05904,   7.93762, 0.00000, 356.24268);
	CreateDynamicObject(2893, 46.17090, -162.80762, 2.01091,   343.12500, 0.00000, 357.48962);
	CreateDynamicObject(2893, 47.99295, -162.96185, 1.98404,   343.12500, 0.00000, 357.23962);
	CreateDynamicObject(910, 28.60036, -162.30627, 2.07667,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3399, 38.01497, -160.10847, 2.82655,   0.00000, 0.00000, 358.51501);
	CreateDynamicObject(11390, 43.03790, -171.19501, 5.16304,   0.00000, 0.00000, 266.70410);
	CreateDynamicObject(3465, 32.90332, -192.45117, 2.32615,   0.00000, 0.00000, 87.99500);
	CreateDynamicObject(3465, 31.16260, -192.51579, 2.32615,   0.00000, 0.00000, 87.99500);
	CreateDynamicObject(16442, 59.25047, -134.99010, 2.23747,   0.00000, 323.99496, 313.99686);
	CreateDynamicObject(16442, 60.19197, -136.45178, 1.72030,   0.00000, 357.99500, 317.99683);
	CreateDynamicObject(18451, 69.98685, -171.98593, 0.83994,   0.00000, 0.00000, 28.00000);
	CreateDynamicObject(13591, 63.68237, -188.60506, 0.84462,   0.00000, 0.00000, 62.00000);
	CreateDynamicObject(1650, 44.88538, -164.74315, 1.96856,   0.00000, 0.00000, 232.00000);
	CreateDynamicObject(2190, 41.82040, -162.53230, 2.05441,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1650, 34.89258, -192.45605, 1.31730,   0.00000, 0.00000, 267.99500);
	CreateDynamicObject(622, 2020.82068, 868.35925, 6.89552,   0.00000, 0.00000, 230.00000);
	CreateDynamicObject(622, 1998.00000, 871.67877, 7.62248,   0.00000, 0.00000, 190.00000);
	CreateDynamicObject(622, 1968.00000, 871.67877, 7.65455,   0.00000, 0.00000, 310.00000);
	CreateDynamicObject(622, 1958.00000, 871.67877, 7.58669,   0.00000, 0.00000, 160.00000);
	CreateDynamicObject(622, 1943.90552, 872.85449, 7.77802,   0.00000, 0.00000, 100.00000);
	CreateDynamicObject(622, 1903.34595, 886.24139, 9.82031,   0.00000, 0.00000, 230.00000);
	CreateDynamicObject(622, 1884.53137, 867.72406, 8.06091,   0.00000, 0.00000, 220.00000);
	CreateDynamicObject(622, 1866.01172, 879.42682, 9.01543,   0.00000, 0.00000, 159.99756);
	CreateDynamicObject(622, 1835.51465, 881.36383, 9.38833,   0.00000, 0.00000, 189.99756);
	CreateDynamicObject(622, 1828.00000, 871.67877, 9.69951,   0.00000, 0.00000, 189.99756);
	CreateDynamicObject(622, 1848.00000, 871.67877, 9.03566,   0.00000, 0.00000, 319.99756);
	CreateDynamicObject(622, 2026.00000, 816.99774, 7.38044,   0.00000, 0.00000, 9.99756);
	CreateDynamicObject(622, 2001.23401, 812.07776, 8.07941,   0.00000, 0.00000, 9.99756);
	CreateDynamicObject(622, 1986.00000, 816.99774, 6.96743,   0.00000, 0.00000, 139.99756);
	CreateDynamicObject(622, 1966.00000, 816.99774, 6.88988,   0.00000, 0.00000, 349.99756);
	CreateDynamicObject(622, 1946.00000, 816.99774, 6.77081,   0.00000, 0.00000, 181.99756);
	CreateDynamicObject(622, 1906.00000, 816.99774, 7.52205,   0.00000, 0.00000, 309.99756);
	CreateDynamicObject(622, 1877.17212, 812.68274, 8.89715,   0.00000, 0.00000, 49.99756);
	CreateDynamicObject(622, 1836.00000, 816.99774, 9.38833,   0.00000, 0.00000, 319.99756);
	CreateDynamicObject(622, 1823.24792, 817.92896, 9.80036,   0.00000, 0.00000, 39.99756);
	CreateDynamicObject(655, 1762.26343, 865.13611, 9.39277,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1735.83691, 873.53796, 9.17781,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1705.93872, 873.82703, 8.86212,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(674, 1704.65637, 818.87726, 7.86910,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(680, 1740.29712, 866.91162, 8.84629,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(683, 1691.36060, 822.40576, 9.26803,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(688, 1751.41211, 872.63312, 9.46542,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(691, 1721.23987, 814.43414, 8.71638,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(694, 1741.57581, 813.07855, 9.16937,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(697, 1703.34338, 866.23822, 7.78747,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(698, 1673.81763, 869.22827, 7.52158,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, 1695.60547, 867.97162, 7.81618,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1678.65308, 814.01013, 8.04939,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1648.13074, 879.00702, 8.98481,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(707, 1656.35107, 820.35522, 6.45502,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(708, 1664.67761, 805.60693, 9.35037,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(709, 1649.50671, 803.46619, 9.77064,   0.00000, 0.00000, 80.00000);
	CreateDynamicObject(711, 1646.83606, 867.86774, 12.77526,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(714, 1633.65991, 875.70441, 8.33644,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1639.30078, 866.55115, 6.53950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1658.76392, 868.83008, 7.03055,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1685.46313, 870.42871, 7.98701,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1695.86707, 878.69977, 9.21894,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1721.87769, 874.35461, 9.09256,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(697, 1729.58691, 865.02197, 8.42792,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(688, 1712.38684, 875.85297, 9.08705,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(719, 1615.22437, 816.25507, 7.25995,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(726, 1603.32861, 817.37054, 7.04097,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(726, 1621.75623, 805.72174, 9.32783,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(727, 1643.64795, 861.82800, 9.59064,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(732, 1617.95386, 866.69299, 6.56734,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(763, 1622.80371, 866.68945, 6.56664,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(790, 1597.78967, 881.95514, 8.59229,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(882, 1614.34766, 818.91779, 6.73721,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(641, 1603.48157, 812.26093, 8.04408,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(654, 1602.91846, 807.56262, 8.96643,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1589.57153, 814.21216, 7.66101,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(707, 1609.31396, 798.87006, 9.82031,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1600.10400, 874.50549, 8.82134,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(671, 1533.52429, 865.53839, 18.74180,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(689, 1524.08069, 869.19702, 11.52369,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(694, 1504.98389, 810.01794, 8.49971,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1490.29309, 861.03229, 32.45473,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1482.85852, 812.38440, 8.04125,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1548.79932, 811.24091, 8.24432,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(709, 1541.54626, 872.29309, 7.70359,   0.00000, 0.00000, 79.99695);
	CreateDynamicObject(711, 1515.59863, 866.86896, 12.69181,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(708, 1504.21558, 813.02814, 4.92298,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(715, 1486.78711, 867.51648, 18.15403,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(730, 1527.90747, 818.28668, 6.86111,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1471.70593, 807.24023, 9.03783,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(883, 1486.38647, 871.97070, 16.84325,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3517, 1503.01379, 872.36603, 18.93052,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(622, 1714.60034, 875.65240, 9.06733,   0.00000, 0.00000, 189.99756);
	CreateDynamicObject(622, 1646.00500, 872.95416, 7.79652,   0.00000, 0.00000, 169.99756);
	CreateDynamicObject(622, 1676.94897, 871.34875, 7.86834,   0.00000, 0.00000, 259.99756);
	CreateDynamicObject(622, 1698.15613, 815.11200, 8.26006,   0.00000, 0.00000, 339.99756);
	CreateDynamicObject(622, 1663.33276, 804.68530, 9.53131,   0.00000, 0.00000, 339.99390);
	CreateDynamicObject(622, 1638.28552, 812.32837, 8.03083,   0.00000, 0.00000, 39.99390);
	CreateDynamicObject(622, 1519.72705, 812.85596, 7.92726,   0.00000, 0.00000, 19.99023);
	CreateDynamicObject(707, 1492.59741, 871.00201, 7.46862,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1768.28296, 813.01276, 9.51764,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(697, 1731.74072, 818.56696, 8.62481,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1753.12036, 814.91663, 9.29890,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1772.56458, 873.20947, 9.65022,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(697, 1855.37000, 812.27948, 9.29714,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1822.81995, 809.42786, 9.82031,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1821.28601, 868.38855, 9.77159,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1878.55127, 876.20374, 9.08663,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1960.46082, 813.31171, 7.83717,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 1915.31335, 810.53052, 8.68745,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(705, 2014.78650, 870.32483, 7.28141,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(726, 1917.66980, 880.61932, 9.62666,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(726, 1925.56323, 867.14307, 6.91916,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(726, 1973.40759, 812.78754, 7.94007,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(726, 2028.02612, 819.67706, 6.59005,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1940.36938, 822.92151, 5.95059,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1983.84912, 870.33997, 7.28438,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(664, 1960.93665, 886.19263, 9.82031,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(709, 1887.74255, 813.30768, 8.18679,   0.00000, 0.00000, 79.99695);
	CreateDynamicObject(709, 1950.32007, 874.20612, 8.04337,   0.00000, 0.00000, 79.99695);
	CreateDynamicObject(672, 1824.88538, 822.21857, 9.60912,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1842.82983, 818.48669, 9.30431,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1860.54297, 881.25049, 9.62476,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1856.86743, 866.91064, 8.75491,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1899.67712, 864.45813, 7.28836,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1971.67358, 871.64264, 7.54011,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(672, 1998.46240, 874.66223, 8.13291,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(697, 1905.82166, 891.76501, 9.82031,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(697, 1949.43628, 807.17578, 9.04176,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(698, 1863.42786, 812.12164, 9.23175,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(698, 1884.84143, 862.82288, 7.61020,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(698, 2016.62524, 805.04681, 9.45971,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(698, 2009.09656, 871.60907, 7.53352,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(715, 1462.39819, 873.49878, 14.80230,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(715, 1464.87488, 864.59430, 13.84314,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1464.54614, 816.53961, 7.23624,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1454.26929, 805.16815, 9.43927,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1437.64026, 815.28137, 7.48000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1446.53040, 815.53638, 7.43060,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1437.54138, 880.76929, 9.21884,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1453.62903, 888.55078, 9.82031,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1442.94287, 866.72809, 6.23708,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, 1393.16980, 812.95233, 8.01795,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3532, 2004.18872, 868.94788, 7.69318,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3532, 1900.06311, 865.89081, 8.14523,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19333, 2106.77710, 953.99286, 14.62031,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19333, 2106.77710, 953.99286, 14.62031,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2361.34399, 1161.68042, 34.93000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2361.36841, 1141.70520, 34.93000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2361.38379, 1121.72668, 34.93000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2361.39771, 1101.73401, 34.93000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2371.40649, 1091.77527, 34.93000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2391.35620, 1091.78271, 34.93000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2401.30396, 1091.89014, 34.93000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2411.27051, 1121.88428, 34.93000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2411.26685, 1141.87073, 34.93000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2411.28735, 1161.81641, 34.93000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2401.29956, 1171.76819, 34.93000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2381.31348, 1171.78125, 34.93000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2371.29785, 1171.77795, 34.93000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2361.34399, 1161.68042, 38.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2361.36841, 1141.70520, 38.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2361.38379, 1121.72668, 38.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2371.29785, 1171.77795, 41.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2401.29956, 1171.76819, 38.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2381.31348, 1171.78125, 38.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2411.28735, 1161.81641, 38.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2411.26685, 1141.87073, 38.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2411.27051, 1121.88428, 38.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2411.26660, 1101.90625, 34.93000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2411.26660, 1101.90625, 38.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2401.30396, 1091.89014, 38.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2391.35620, 1091.78271, 38.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2371.40649, 1091.77527, 38.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2361.39771, 1101.73401, 38.30000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2371.29785, 1171.77795, 38.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2381.31348, 1171.78125, 41.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2401.29956, 1171.76819, 41.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2411.28735, 1161.81641, 41.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2361.34399, 1161.68042, 41.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2361.36841, 1141.70520, 41.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2361.38379, 1121.72668, 41.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2361.39771, 1101.73401, 41.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2371.40649, 1091.77527, 41.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2391.35620, 1091.78271, 41.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2401.30396, 1091.89014, 41.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2411.26660, 1101.90625, 41.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2411.27051, 1121.88428, 41.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2411.26685, 1141.87073, 41.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2411.26660, 1101.90625, 45.00000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2411.26660, 1101.90625, 41.70000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2411.27051, 1121.88428, 45.00000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2401.30396, 1091.89014, 45.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2391.35620, 1091.78271, 45.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2371.40649, 1091.77527, 45.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2361.39771, 1101.73401, 45.00000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2361.38379, 1121.72668, 45.00000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2361.36841, 1141.70520, 45.00000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2361.34399, 1161.68042, 45.00000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2371.29785, 1171.77795, 45.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2401.29956, 1171.76819, 45.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2381.31348, 1171.78125, 45.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7657, 2411.28735, 1161.81641, 45.00000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7657, 2411.26685, 1141.87073, 45.00000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19536, 2385.64990, 1130.77637, 46.72390,   180.00000, 0.00000, 90.00000);
	
	return 1;
}

public TimerMove ()
{
	new rand;
	new Hay;
	new Move = -1;
	new xq, yq, zq;
	new Float:x2, Float:y2, Float:z2;
	new Timez;
	new Float:Speed;

	rand = random (HAY_B);
	Hay = Hays[rand];
	if(IsObjectMoving(Hay))
	{
		SetTimer ("TimerMove", 200, 0);
		return 1;
	}
	Move = random (6);
	GetObjectPos (Hay, x2, y2, z2);
	xq = floatround (x2/-4.0);
	yq = floatround (y2/-4.0);
	zq = floatround (z2/3.0)-1;
	if ((Move == 0)  && (xq != 0) && (Matrix[xq-1][yq][zq] == 0))
	{
		Timez = 4000 - Speed_xy * zq;
		Speed = SPEED_FACTOR / float (Timez);
		SetTimerEx ("FinishTimer", Timez, 0, "iiii", rand, xq, yq, zq);
		xq = xq - 1;
		Matrix[xq][yq][zq] = 1;
		MoveObject (Hay, x2+4.0, y2, z2, Speed);
	}

	else if ((Move == 1) && (xq != HAY_X-1) && (Matrix[xq+1][yq][zq] == 0))
	{
		Timez = 4000 - Speed_xy * zq;
		Speed = SPEED_FACTOR / float (Timez);
		SetTimerEx ("FinishTimer", Timez, 0, "iiii", rand, xq, yq, zq);
		xq = xq + 1;
		Matrix[xq][yq][zq] = 1;
		MoveObject (Hay, x2-4.0, y2, z2, Speed);
	}

	else if ((Move == 2) && (yq != 0) && (Matrix[xq][yq-1][zq] == 0))
	{
		Timez = 4000 - Speed_xy * zq;
		Speed = SPEED_FACTOR / float (Timez);
		SetTimerEx ("FinishTimer", Timez, 0, "iiii", rand, xq, yq, zq);
		yq = yq - 1;
		Matrix[xq][yq][zq] = 1;
		MoveObject (Hay, x2, y2+4.0, z2, Speed);
	}


	else if ((Move == 3) && (yq != HAY_Y-1) && (Matrix[xq][yq+1][zq] == 0))
	{
		Timez = 4000 - Speed_xy * zq;
		Speed = SPEED_FACTOR / float (Timez);
		SetTimerEx ("FinishTimer", Timez, 0, "iiii", rand, xq, yq, zq);
		yq = yq + 1;
		Matrix[xq][yq][zq] = 1;
		MoveObject (Hay, x2, y2-4.0, z2, Speed);
	}

	else if ((Move == 4) && (zq != 0) && (Matrix[xq][yq][zq-1] == 0))
	{
		Timez = 3000 - Speed_z * zq;
		Speed = SPEED_FACTOR / float (Timez);
		SetTimerEx ("FinishTimer", Timez, 0, "iiii", rand, xq, yq, zq);
		zq = zq - 1;
		Matrix[xq][yq][zq] = 1;
		MoveObject (Hay, x2, y2, z2-3.0, Speed);
	}

	else if ((Move == 5) && (zq != HAY_Z-1) && (Matrix[xq][yq][zq+1] == 0))
	{
		Timez = 3000 - Speed_z * zq;
		Speed = SPEED_FACTOR / float (Timez);
		SetTimerEx ("FinishTimer", Timez, 0, "iiii", rand, xq, yq, zq);
		zq = zq + 1;
		Matrix[xq][yq][zq] = 1;
		MoveObject (Hay, x2, y2, z2+3.0, Speed);
	}
	else if ((Move == 6) && (zq != HAY_Z-1) && (Matrix[xq][yq][zq+1] == 0))
	{
		Timez = 3000 - Speed_z * zq;
		Speed = SPEED_FACTOR / float (Timez);
		SetTimerEx ("FinishTimer", Timez, 0, "iiii", rand, xq, yq, zq);
		zq = zq + 1;
		Matrix[xq][yq][zq] = 1;
		MoveObject (Hay, x2, y2, z2+3.0, Speed);
	}
	SetTimer ("TimerMove", 200, 0);
	return 1;
}

public FinishTimer (id, xq, yq, zq)
{
	Matrix[xq][yq][zq] = 0;
}

public OnPlayerUpdate(playerid)
{
	CheckWeapons(playerid);
	return 1;
}

public TimerScore ()
{
	new Float:xq, Float:yq, Float:zq;
	for (new i=0 ; i<MAX_PLAYERS ; i++)
	{
	    if (IsPlayerConnected (i))
	    {
	        GetPlayerPos (i, xq, yq, zq);
			if (xq<=2.0 && xq>=-15.0 && yq<=2.0 && yq>=-15.0)
			{
				new Level = (floatround (zq)/3) - 1;
				WhatLevel[i] = Level;
			}
			else
			{
				WhatLevel[i] = 0;
			}
	    }
	}
}
public TDScore()
{
    TimerScore();
	new Level,string[256],PlayerN[MAX_PLAYER_NAME];
	for(new i=0; i<MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(JoinedHay[i] == 1)
			{
			    new tH,tM,tS;
	  			new TimeStamp = GetTickCount();
				new TotalRaceTime = TimeStamp - TimeInHay[i];
				ConvertTime(var, TotalRaceTime, tH, tM, tS);
				Level = WhatLevel[i];
				format(string,sizeof(string),"~h~~y~Hay Minigame~n~~r~Level: ~w~%d/31 ~n~~r~Time: ~w~%02d:%02d\
										",Level,tH,tM,tS);
				TextDrawSetString(HAYTD[i], string);
	      		TextDrawShowForPlayer(i, HAYTD[i]);
			    if(WhatLevel[i] == 31)
				{
					GetPlayerName(i, PlayerN, sizeof(PlayerN));
					format(string, sizeof(string),"[HAY] %s Finished The Hay Minigame In %02d Min %02d Sec", PlayerN,tH,tM,tS);
					SendClientMessageToAll(ORANGE,string);
					TextDrawHideForPlayer(i, HAYTD[i]);
					SetPlayerPos(i,0,0,0);
					SpawnPlayer(i);
			    }
			}
			if(JoinedHay[i] != 1)
			{
				TextDrawHideForPlayer(i, HAYTD[i]);
			}
		}
	}
	return 1;
}

enum pBanInfo
{
	pBanexp,
    pBanres[100],
    pBanPerm,
    pBanAdmin[20],
    pBanIPP[20]
}

new BanInfo[MAX_PLAYERS][pBanInfo];
new pp[50];

forward fcreate(filename[]);
public fcreate(filename[])
{
    if (fexist(filename)){return false;}
    new File:fhandle = fopen(filename,io_write);
    fclose(fhandle);
    return true;
}

forward NapisWylacz();
public NapisWylacz()
{
TextDrawHideForAll(Kary);
KillTimer(NapisTimer);
return 1;
}  

public PlayerUpdate()
{
	for(new Player; Player < GetMaxPlayers(); Player++)
	{
	    if(IsPlayerConnected(Player) && GetPlayerState(Player) == PLAYER_STATE_DRIVER && VehicleIsCar(GetPlayerVehicleID(Player)) && PlayerUseDriftCounter[Player] == 1) GetVehiclePos(GetPlayerVehicleID(Player),PlayerPositionX[Player],PlayerPositionY[Player],PlayerPositionZ[Player]);
	}
	return 1;
}

public PlayerDrift()
{
	for(new Player; Player < GetMaxPlayers(); Player++)
	{
	    if(IsPlayerConnected(Player) && GetPlayerState(Player) == PLAYER_STATE_DRIVER && VehicleIsCar(GetPlayerVehicleID(Player)) && PlayerUseDriftCounter[Player] == 1)
	    {
	        GetVehicleZAngle(GetPlayerVehicleID(Player),Angle);
			if(floatabs(floatsub(Angle,PlayerTheoreticAngle(Player))) < 90.0 && floatabs(floatsub(Angle,PlayerTheoreticAngle(Player))) > 10.0 && VehicleSpeed(GetPlayerVehicleID(Player)) < 300 && VehicleSpeed(GetPlayerVehicleID(Player)) > 30)
			{
			    if(PlayerMoney[Player] == 0 && PlayerScore[Player] == 0 && PlayerCombo[Player] == 1)
			    {
			        TextDrawShowForPlayer(Player,ServerTextDrawOne);
			        TextDrawShowForPlayer(Player,ServerTextDrawTwo);
			        TextDrawShowForPlayer(Player,ServerTextDrawThree[Player]);
		          	TextDrawShowForPlayer(Player,ServerTextDrawFour[Player]);
		          	TextDrawShowForPlayer(Player,ServerTextDrawFive[Player]);
				   	TextDrawSetString(ServerTextDrawThree[Player]," ");
				   	TextDrawSetString(ServerTextDrawFour[Player]," ");
				   	TextDrawSetString(ServerTextDrawFive[Player]," ");
			    }
			    PlayerMoney[Player] += floatround(floatabs(floatsub(Angle,PlayerTheoreticAngle(Player))) * (VehicleSpeed(GetPlayerVehicleID(Player)) * 0.1)) / 10;
			    PlayerScore[Player] += floatround(floatabs(floatsub(Angle,PlayerTheoreticAngle(Player))) * 3 * (VehicleSpeed(GetPlayerVehicleID(Player)) * 0.1)) / 10;
				PlayerCombo[Player] = PlayerScore[Player] / 1000;
				if(PlayerCombo[Player] < 1) PlayerCombo[Player] = 1;
				new String[100];
				format(String,sizeof(String),"~R~~H~Money For Drift: ~W~~H~%d$",PlayerMoney[Player]);
				TextDrawSetString(ServerTextDrawThree[Player],String);
				format(String,sizeof(String),"~R~~H~Drift Points: ~W~~H~%d",PlayerScore[Player]);
				TextDrawSetString(ServerTextDrawFour[Player],String);
				format(String,sizeof(String),"~R~~H~Combo: ~W~~H~X%d",PlayerCombo[Player]);
				TextDrawSetString(ServerTextDrawFive[Player],String);
				KillTimer(PlayerTimerOne[Player]);
			    PlayerTimerOne[Player] = SetTimerEx("PlayerDriftEnd",3000,0,"d",Player);
			}
	    }
	}
	return 1;
}

public PlayerDriftEnd(Player)
{
	TextDrawHideForPlayer(Player,ServerTextDrawOne);
	TextDrawHideForPlayer(Player,ServerTextDrawTwo);
    TextDrawHideForPlayer(Player,ServerTextDrawThree[Player]);
  	TextDrawHideForPlayer(Player,ServerTextDrawFour[Player]);
  	TextDrawHideForPlayer(Player,ServerTextDrawFive[Player]);
   	TextDrawSetString(ServerTextDrawThree[Player]," ");
   	TextDrawSetString(ServerTextDrawFour[Player]," ");
   	TextDrawSetString(ServerTextDrawFive[Player]," ");
	GivePlayerMoney(Player,PlayerMoney[Player]);
	PlayerMoney[Player] = 0;
	PlayerScore[Player] = 0;
	PlayerCombo[Player] = 1;
	return 1;
}
forward LoadBanUser_data(playerid,name[],value[]);
public LoadBanUser_data(playerid,name[],value[])
{
    INI_Int("Banexp",BanInfo[playerid][pBanexp]);
    INI_Int("BanPerm",BanInfo[playerid][pBanPerm]);
	INI_String("BanAdmin", BanInfo[playerid][pBanAdmin], 20);
	INI_String("Reason",BanInfo[playerid][pBanres],100);
 	return 1;
}
forward LoadIPUser_data(playerid,name[],value[]);
public LoadIPUser_data(playerid,name[],value[])
{
	INI_Int("Banexp",BanInfo[playerid][pBanexp]);
 	INI_Int("BanPerm",BanInfo[playerid][pBanPerm]);
    INI_String("BanPlayer", BanInfo[playerid][pBanIPP], 20);
    INI_String("BanAdmin", BanInfo[playerid][pBanAdmin], 20);
    INI_String("Reason",BanInfo[playerid][pBanres],100);
    return 1;
}
forward LoadIP_data(playerid,name[],value[]);
public LoadIP_data(playerid,name[],value[])
{
	INI_String("IP",pp,50);
 	return 1;
}
stock UserBanPath(playerid)
{
	new string[128],playername[MAX_PLAYER_NAME];
 	GetPlayerName(playerid,playername,sizeof(playername));
  	format(string,sizeof(string),BANPATH,playername);
   	return string;
}
stock VehicleIsCar(Vehicle)
{
	switch(GetVehicleModel(Vehicle))
	{
	    case 480: return 1;
	    case 533: return 1;
	    case 439: return 1;
	    case 555: return 1;
	    case 536: return 1;
	    case 575: return 1;
	    case 534: return 1;
	    case 567: return 1;
	    case 535: return 1;
	    case 566: return 1;
	    case 576: return 1;
	    case 412: return 1;
	    case 445: return 1;
	    case 504: return 1;
	    case 401: return 1;
	    case 518: return 1;
	    case 527: return 1;
	    case 542: return 1;
	    case 507: return 1;
	    case 562: return 1;
	    case 585: return 1;
	    case 419: return 1;
	    case 526: return 1;
	    case 604: return 1;
	    case 466: return 1;
	    case 492: return 1;
	    case 474: return 1;
	    case 546: return 1;
	    case 517: return 1;
	    case 410: return 1;
	    case 551: return 1;
	    case 516: return 1;
	    case 467: return 1;
	    case 426: return 1;
	    case 436: return 1;
	    case 547: return 1;
	    case 405: return 1;
	    case 580: return 1;
	    case 560: return 1;
	    case 550: return 1;
	    case 549: return 1;
	    case 540: return 1;
	    case 491: return 1;
	    case 529: return 1;
	    case 421: return 1;
	    case 602: return 1;
	    case 429: return 1;
	    case 496: return 1;
	    case 402: return 1;
	    case 541: return 1;
	    case 415: return 1;
	    case 589: return 1;
	    case 587: return 1;
	    case 565: return 1;
	    case 494: return 1;
	    case 502: return 1;
	    case 503: return 1;
	    case 411: return 1;
	    case 559: return 1;
	    case 603: return 1;
	    case 475: return 1;
	    case 506: return 1;
	    case 451: return 1;
	    case 558: return 1;
	    case 477: return 1;
	    case 418: return 1;
	    case 404: return 1;
	    case 479: return 1;
	    case 458: return 1;
	    case 561: return 1;
	}
	return 0;
}

Float:PlayerTheoreticAngle(Player)
{
	GetVehiclePos(GetPlayerVehicleID(Player),X,Y,Z);
	new Float:NewX;
	if(X > PlayerPositionX[Player]) NewX = X - PlayerPositionX[Player];
	if(X < PlayerPositionX[Player]) NewX = PlayerPositionX[Player] - X;
	new Float:NewY;
	if(Y > PlayerPositionY[Player]) NewY = Y - PlayerPositionY[Player];
	if(Y < PlayerPositionY[Player]) NewY = PlayerPositionY[Player] - Y;
	new Float:Sinus;
	new Float:Cosinus;
	Cosinus = floatsqroot(floatpower(floatabs(floatsub(X,PlayerPositionX[Player])),2) + floatpower(floatabs(floatsub(Y,PlayerPositionY[Player])),2));
	new Float:TheoreticAngle;
	if(PlayerPositionX[Player] > X && PlayerPositionY[Player] > Y)
	{
	    Sinus = asin(NewX / Cosinus);
	    TheoreticAngle = floatsub(floatsub(floatadd(Sinus,90),floatmul(Sinus,2)),-90.0);
	}
	if(PlayerPositionX[Player] > X && PlayerPositionY[Player] < Y)
	{
	    Sinus = asin(NewX / Cosinus);
	    TheoreticAngle = floatsub(floatadd(Sinus,180),180.0);
	}
	if(PlayerPositionX[Player] < X && PlayerPositionY[Player] < Y)
	{
	    Sinus = acos(NewY / Cosinus);
	    TheoreticAngle = floatsub(floatadd(Sinus,360),floatmul(Sinus,2));
	}
	if(PlayerPositionX[Player] < X && PlayerPositionY[Player] > Y)
	{
	    Sinus = asin(NewX / Cosinus);
	    TheoreticAngle = floatadd(Sinus,180);
	}
	if(TheoreticAngle == 0.0) GetVehicleZAngle(GetPlayerVehicleID(Player),TheoreticAngle);
	return TheoreticAngle;
}

stock VehicleSpeed(Vehicle)
{
	GetVehicleVelocity(Vehicle,X,Y,Z);
	new Float:Speed;
    Speed = floatsqroot(floatpower(floatabs(X),2.0) + floatpower(floatabs(Y),2.0) + floatpower(floatabs(Z),2.0)) * 200.0;
	return floatround(Speed);
}
stock UserIPPath(playerid)
{
	new string[128],ip[50];
 	GetPlayerIp(playerid,ip,sizeof(ip));
 	format(string,sizeof(string),IPPATH,ip);
  	return string;
}
stock Showinfo(playerid,targetname[])
{
	new path[150],ss[500];
 	format(path,sizeof(path),"Bans/%s.ini",targetname);
    INI_ParseFile(path, "LoadBanUser_%s", .bExtra = true, .extra = playerid);
    if(BanInfo[playerid][pBanPerm]==1)
    format(ss,sizeof(ss),"{00FFFF}Banning Admin:\t\t{ff0000}%s\n{00FFFF}Ban Reason:\t\t{ff0000}%s\n{00FFFF}Ban Type:\t\t{ff0000}Permanent.\n\n{FFFF00}Click on Remove Ban button to un-ban the player.",BanInfo[playerid][pBanAdmin],BanInfo[playerid][pBanres]);
    else
    {
    	new d,m,y,h,mi,s;
    	TimestampToDate(BanInfo[playerid][pBanexp],y,m,d,h,mi,s,GMT_H,GMT_M);
        format(ss,sizeof(ss),"{00FFFF}Banning Admin:\t\t{ff0000}%s\n{00FFFF}Ban Reason:\t\t{ff0000}%s\n{00FFFF}Expire Time:\t\t{ff0000}%i-%i\n{00FFFF}Expire Date:\t\t{ff0000}%i-%i-%i\n\n{FFFF00}Time is according to %i GMT\nDate Format: dd-mm-yyyy\nClick on Remove Ban button to un-ban the player.",BanInfo[playerid][pBanAdmin],BanInfo[playerid][pBanres],h,mi,d,m,y,GMT_H);
    }
    format(revseen[playerid],MAX_PLAYER_NAME,"%s",targetname);
    ShowPlayerDialog(playerid, 113,  DIALOG_STYLE_MSGBOX,targetname,ss, "Remove Ban", "Cancel");
    return 1;
}
stock fdeleteline(filename[], line[])
{
	new temp[256];
	new File:fhandle = fopen(filename,io_read);
	if(fexist(filename))
	{
      	if(strfind(temp,line,true)==-1)
 		{
 		    fread(fhandle,temp,sizeof(temp),false);
	 		return 0;
 		}
	}
	else
	{
 		fclose(fhandle);
   		fremove(filename);
   		for(new i=0;i<strlen(temp);i++)
   		{
   			new templine[256];
   			strmid(templine,temp,i,i+strlen(line));
   			if(strcmp(templine,line,true))
   			{
   				strdel(temp,i,i+strlen(line));
	   			fcreate(filename);
	 			fhandle = fopen(filename,io_write);
	   			fwrite(fhandle,temp);
	   			fclose(fhandle);
			}
		}
   	}
    return 0;
}

new RandomMessages[][] =
{
    "~w~new on server? use ~y~/help~w~ to get started.",
    "~w~use ~y~/cmds ~w~to see server commands",
    "~w~see any hackers on server? use ~y~/report~w~.",
   	"~w~use ~y~/teles~w~ to see server teleports.",
	"~w~try ~y~your luck on /hay."

};

public loadaccount_user(playerid, name[], value[])
{
    INI_String("Password", pInfo[playerid][Pass],129);
    INI_Int("AdminLevel",pInfo[playerid][Admin]);
    INI_Int("VIPLevel",pInfo[playerid][VIPlevel]);
    INI_Int("Money",pInfo[playerid][Money]); 
    INI_Int("Scores",pInfo[playerid][Scores]);
    INI_Int("Kills",pInfo[playerid][Kills]);
    INI_Int("Deaths",pInfo[playerid][Deaths]);
    INI_Int("Colour",pInfo[playerid][pColor]);
    INI_Int("Skin",pInfo[playerid][pSkin]);
    return 1;
}

public OnGameModeExit()
{
    KillTimer(xReactionTimer);
	TextDrawDestroy(Textdraw0);
	TextDrawDestroy(Textdraw2);
	
	TextDrawDestroy(ServerTextDrawOne);
	TextDrawDestroy(ServerTextDrawTwo);
	for(new Player; Player < GetMaxPlayers(); Player++)
	{
	    TextDrawDestroy(ServerTextDrawThree[Player]);
	    TextDrawDestroy(ServerTextDrawFour[Player]);
	    TextDrawDestroy(ServerTextDrawFive[Player]);
	}
	KillTimer(ServerTimerOne);
	KillTimer(ServerTimerTwo);
	return 1;
}


public OnPlayerPickUpPickup(playerid, pickupid)
{
	for(new pID= 0; pID < sizeof(pcarmenu); pID++)//To give same things to all pickups
	{
		if(pickupid == pcarmenu[pID])
		{
            ShowPlayerDialog(playerid, carmenu, DIALOG_STYLE_LIST, "vDR: Vehicle","{FFFF00}•{FFFFFF} Bikes\n{FFFF00}•{FFFFFF} Cars 1 [A-E]\n{FFFF00}•{FFFFFF} Cars 2 [F-P]\n{FFFF00}•{FFFFFF} Cars 3 [P-S]\n{FFFF00}•{FFFFFF} Cars 4 [S-Z]\n{FFFF00}•{FFFFFF} Helicopters\n{FFFF00}•{FFFFFF} Planes\n{FFFF00}•{FFFFFF} Boats\n{FFFF00}•{FFFFFF} Trains\n{FFFF00}•{FFFFFF} Trailers\n{FFFF00}•{FFFFFF} RC Vehicles + Vortex", "Select", "Cancel");
		}
		if(pickupid == teleportmenu[pID])
		{
		    ShowPlayerDialog(playerid, TELE_DIALOG, DIALOG_STYLE_LIST, "Teles", "{FFFF00}•{FFFFFF} Los Santos\n{FFFF00}•{FFFFFF} San Fierro\n{FFFF00}•{FFFFFF} Las Venturas", "Select", "Cancel"); // Munculin DIalog
		}
	}
    return 1;
}

public RespawnVehicles()
{
    new bool:vehicleused[MAX_VEHICLES];
    for (new i=0; i < MAX_PLAYERS; i++)
	{
        if(IsPlayerConnected(i) && IsPlayerInAnyVehicle(i))
		{
            vehicleused[GetPlayerVehicleID(i)] = true;
        }
    }
    for (new i=1; i < MAX_VEHICLES; i++)
	{
        if(!vehicleused[i])
		{
            SetVehicleToRespawn(i);
        }
    }
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	TextDrawHideForPlayer(playerid, Login0);
	TextDrawHideForPlayer(playerid,HAYTD[playerid]);
    JoinedHay[playerid] = 0;
	TextDrawHideForPlayer(playerid, Login1);
	TextDrawHideForPlayer(playerid, Login2);
	TextDrawHideForPlayer(playerid, Login3);
	TextDrawHideForPlayer(playerid, Login4);
	TextDrawHideForPlayer(playerid, Login5);
	GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~r~Vision~w~ Drifting", 3000, 3);
    SetPlayerAttachedObject( playerid, 0, 18693, 5, 0.034589, -0.022944, -1.644727, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000 ); // Flame99 - api di tangan
    SetPlayerAttachedObject( playerid, 0, 18693, 6, 0.034589, -0.022944, -1.644727, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000 ); // Flame99 - api di tangan
    SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, -1452.5599, 1575.0573, 1057.6705);
	SetPlayerFacingAngle(playerid, 125.1428);
	SetPlayerInterior(playerid, 14);
	SetPlayerVirtualWorld(playerid, 0);
	if(cameradone[playerid] == 1)
	{
	    cameradone[playerid] = 0;
	    SetCameraBehindPlayer(playerid);
		InterpolateCameraPos(playerid, -1469.116455, 1588.834960, 1066.509643, -1458.172973, 1569.264404, 1058.822387, 3000);
		InterpolateCameraLookAt(playerid, -1464.773803, 1591.308349, 1066.661987, -1454.510864, 1572.658447, 1058.559570, 3000);
	}
	SetPlayerSpecialAction(playerid, 5);
    TextDrawShowForPlayer(playerid, vd);
    TextDrawShowForPlayer(playerid, vd1);
    TextDrawShowForPlayer(playerid, vd2);
 	TextDrawShowForPlayer(playerid, Textdraw0);
    TextDrawShowForPlayer(playerid, Textdraw2);
	return 1;
}

public OnPlayerConnect(playerid)
{
	SetPlayerMapIcon(playerid, 0, 382.9828, -2079.0854, 7.8359, 25, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 1, 1129.3685, -1457.6368, 15.7969, 25, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 2, 1447.9894, -2287.4590, 13.5469, 25, 0, MAPICON_LOCAL);
	WhatLevel[playerid] = 0;
    JoinedHay[playerid] = 0;
	TextDrawHideForPlayer(playerid,HAYTD[playerid]);
    cForced[playerid] = 0;
	new rand = random(sizeof(playerColors));
	SetPlayerColor(playerid, playerColors[rand]);
	cameradone[playerid] = 1;
   	if(fexist(UserBanPath(playerid)))
	{
 		INI_ParseFile(UserBanPath(playerid), "LoadBanUser_%s", .bExtra = true, .extra = playerid);
   		if(BanInfo[playerid][pBanPerm]==1)
     	{
     	    new str[520],sho[520];
 	    	strcat(sho, "{FF0000}you are Permanently Banned from server!\n\n");
			format(str, sizeof(str), "{FF0000}Name:{FFFF00} %s\n", GetName(playerid));
			strcat(sho, str, sizeof(sho));
			format(str, sizeof(str), "{FF0000}Administrator:{FFFF00} %s\n", BanInfo[playerid][pBanAdmin]);
			strcat(sho, str, sizeof(sho));
			format(str, sizeof(str), "{FF0000}Reason:{FFFF00} %s\n\n", BanInfo[playerid][pBanres]);
			strcat(sho, str, sizeof(sho));
			strcat(sho, "{FF0000}if this is a wrongfully banned you can make ban appeals at our website");
			ShowPlayerDialog(playerid, 9999, DIALOG_STYLE_MSGBOX, "{FF0000}You Are Banned", sho, "Close", "");
			SetTimerEx("DelayBan",1200,0,"i", playerid);
      	}
       	else
        {
        	if(gettime() > BanInfo[playerid][pBanexp])
          	{
		  		fremove(UserBanPath(playerid));
              	fremove(UserIPPath(playerid));
              	SendClientMessage(playerid, COLOR_RED, "[vDR]: {B0B0B0}You are Unbanned from server");
          	}
          	else
          	{
      	    	new str[520],sho[520], d, m, y, h, mi, s;
      	    	TimestampToDate(BanInfo[playerid][pBanexp],y,m,d,h,mi,s,GMT_H,GMT_M);
 	    		strcat(sho, "{FF0000}you are Banned from server!\n\n");
				format(str, sizeof(str), "{FF0000}Name:{FFFF00} %s\n", GetName(playerid));
				strcat(sho, str, sizeof(sho));
				format(str, sizeof(str), "{FF0000}Administrator:{FFFF00} %s\n", BanInfo[playerid][pBanAdmin]);
				strcat(sho, str, sizeof(sho));
				format(str, sizeof(str), "{FF0000}Unbanned Date:{FFFF00} %i-%i\n", h, mi);
				strcat(sho, str, sizeof(sho));
				format(str, sizeof(str), "{FF0000}Reason:{FFFF00} %s\n\n", BanInfo[playerid][pBanres]);
				strcat(sho, str, sizeof(sho));
				strcat(sho, "{FF0000}if this is a wrongfully banned you can make ban appeals at our website");
				ShowPlayerDialog(playerid, 9999, DIALOG_STYLE_MSGBOX, "{FF0000}You Are Banned", sho, "Close", "");
				SetTimerEx("DelayBan",1000,0,"i", playerid);
           	}
		}
	}
	else if(fexist(UserIPPath(playerid)))
 	{
  		INI_ParseFile(UserIPPath(playerid), "LoadIPUser_%s", .bExtra = true, .extra = playerid);
    	if(BanInfo[playerid][pBanPerm]==1)
     	{
     		new str[520],sho[520];
    		strcat(sho, "{FF0000}This IP is permanently Banned\n\n");
			format(str, sizeof(str), "{FF0000}Originally Banned Name:{FFFF00} %s\n", BanInfo[playerid][pBanIPP]);
			strcat(sho, str, sizeof(sho));
			format(str, sizeof(str), "{FF0000}Administrator:{FFFF00} %s\n", BanInfo[playerid][pBanAdmin]);
			strcat(sho, str, sizeof(sho));
			format(str, sizeof(str), "{FF0000}Reason:{FFFF00} %s\n\n", BanInfo[playerid][pBanres]);
			strcat(sho, str, sizeof(sho));
			strcat(sho, "{FF0000}if this is a wrongfully banned you can make ban appeals at our website");
			ShowPlayerDialog(playerid, 9999, DIALOG_STYLE_MSGBOX, "{FF0000}You Are Banned", sho, "Close", "");
			SetTimerEx("DelayBan",1000,0,"i", playerid);
    	}
     	else
	 	{
   			if(gettime() > BanInfo[playerid][pBanexp])
          	{
	  			new pat[100];
      			fremove(UserIPPath(playerid));
              	format(pat,sizeof(pat),"Bans/%s.ini",BanInfo[playerid][pBanIPP]);
              	fremove(pat);
              	SendClientMessage(playerid,-1,"{00cc00}This IP was banned but as now the expire time has passed this IP has been unbanned.");
          	}
          	else
          	{

     	    	new str[520],sho[520], d, m, y, h, mi, s;
      	    	TimestampToDate(BanInfo[playerid][pBanexp],y,m,d,h,mi,s,GMT_H,GMT_M);
 	    		strcat(sho, "{FF0000}This IP has been Banned from server!\n\n");
				format(str, sizeof(str), "{FF0000}Originally Banned Name:{FFFF00} %s\n", BanInfo[playerid][pBanIPP]);
				strcat(sho, str, sizeof(sho));
				format(str, sizeof(str), "{FF0000}Administrator:{FFFF00} %s\n", BanInfo[playerid][pBanAdmin]);
				strcat(sho, str, sizeof(sho));
				format(str, sizeof(str), "{FF0000}Unbanned Date:{FFFF00} %i-%i\n", h, mi);
				strcat(sho, str, sizeof(sho));
				format(str, sizeof(str), "{FF0000}Reason:{FFFF00} %s\n\n", BanInfo[playerid][pBanres]);
				strcat(sho, str, sizeof(sho));
				strcat(sho, "{FF0000}if this is a wrongfully banned you can make ban appeals at our website");
				ShowPlayerDialog(playerid, 9999, DIALOG_STYLE_MSGBOX, "{FF0000}You Are Banned", sho, "Close", "");
				SetTimerEx("DelayBan",1000,0,"i", playerid);
			}
		}
  	}
	superman[playerid] = 0;
    PlayAudioStreamForPlayer(playerid, "http://xsfserver.com/music/RememberTheName.mp3");
	god[playerid] = 0;
	afk[playerid] = 0;
	minigun[playerid] = 0;
	onede[playerid] = 0;
	PlayerPlaySound(playerid, 1132, 0.0, 0.0, 0.0);
	TextDrawShowForPlayer(playerid, Login0);
	TextDrawShowForPlayer(playerid, Login1);
	TextDrawShowForPlayer(playerid, Login2);
	TextDrawShowForPlayer(playerid, Login3);
	TextDrawShowForPlayer(playerid, Login4);
	TextDrawShowForPlayer(playerid, Login5);
	RemoveBuildingForPlayer(playerid, 4828, 1474.4141, -2286.7969, 26.3594, 0.25);
	RemoveBuildingForPlayer(playerid, 4942, 1474.4141, -2286.7969, 26.3594, 0.25);
	RemoveBuildingForPlayer(playerid, 4985, 1394.9453, -2286.1563, 17.5391, 0.25);
	
	TextDrawHideForPlayer(playerid,ServerTextDrawOne);
	TextDrawHideForPlayer(playerid,ServerTextDrawTwo);
    TextDrawHideForPlayer(playerid,ServerTextDrawThree[playerid]);
  	TextDrawHideForPlayer(playerid,ServerTextDrawFour[playerid]);
  	TextDrawHideForPlayer(playerid,ServerTextDrawFive[playerid]);
   	TextDrawSetString(ServerTextDrawThree[playerid]," ");
   	TextDrawSetString(ServerTextDrawFour[playerid]," ");
   	TextDrawSetString(ServerTextDrawFive[playerid]," ");
   	PlayerUseDriftCounter[playerid] = 1;
	PlayerMoney[playerid] = 0;
	PlayerScore[playerid] = 0;
	PlayerCombo[playerid] = 1;
	PlayerPositionX[playerid] = 0.0;
	PlayerPositionY[playerid] = 0.0;
	PlayerPositionZ[playerid] = 0.0;
	KillTimer(PlayerTimerOne[playerid]);

	speedo[playerid] = TextDrawCreate(539.000000, 356.000000, " ");
	TextDrawBackgroundColor(speedo[playerid], 255);
	TextDrawFont(speedo[playerid], 2);
	TextDrawLetterSize(speedo[playerid], 0.530000, 2.200000);
	TextDrawColor(speedo[playerid], -1);
	TextDrawSetOutline(speedo[playerid], 1);
	TextDrawSetProportional(speedo[playerid], 1);

	box[playerid] = TextDrawCreate(534.000000, 359.000000, "_");
	TextDrawBackgroundColor(box[playerid], 255);
	TextDrawFont(box[playerid], 2);
	TextDrawLetterSize(box[playerid], 0.570000, 1.900000);
	TextDrawColor(box[playerid], -1);
	TextDrawSetOutline(box[playerid], 1);
	TextDrawSetProportional(box[playerid], 1);
	TextDrawUseBox(box[playerid], 1);
	TextDrawBoxColor(box[playerid], 80);
	TextDrawTextSize(box[playerid], 664.000000, 0.000000);
	
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
	    {
	        if(i != playerid)
	        {
				format(strg, sizeof(strg), "* {15D4ED}Player {FFFFFF}%s(%d) {15D4ED}has joined server.", GetName(playerid), playerid);
				SendClientMessage(i, COLOR_WHITE, strg);
			}
		}
	}
	SendClientMessage(playerid, COLOR_WHITE, " ");
	SendClientMessage(playerid, COLOR_WHITE, " ");
	SendClientMessage(playerid, COLOR_WHITE, " ");
	SendClientMessage(playerid, COLOR_WHITE, " ");
	SendClientMessage(playerid, COLOR_WHITE, "");
	SendClientMessage(playerid, COLOR_WHITE, "Welcome To {FF0000}Vision {FFFFFF}Drifting");
	SendClientMessage(playerid, COLOR_WHITE, "for commands use {FF0000}/cmds");
	SendClientMessage(playerid, COLOR_WHITE, "for teleports use {FF0000}/teles");
	SendClientMessage(playerid, COLOR_WHITE, "to get started about our server at {FF0000}/help");
	SendClientMessage(playerid, COLOR_WHITE, "");

 	SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);

	TextDrawHideForPlayer(playerid, textstring);

    new name[MAX_PLAYER_NAME]; 
    GetPlayerName(playerid,name,sizeof(name)); 
    if(BanInfo[playerid][pBanPerm]== 0)
    {
    	if(fexist(Path(playerid)))
    	{
        	new str[256], sho[256];
	    	strcat(sho, "{FFFFFF}Welcome to {FF0000}Vision {FFFFFF}Drifting\n\n");
			format(str, sizeof(str), "{FFFF00}Account:	{FFFFFF}%s\n\n", GetName(playerid));
			strcat(sho, str, sizeof(sho));
			strcat(sho, "{FFFFFF}Please enter your password below:");
		
			ShowPlayerDialog(playerid,dlogin,DIALOG_STYLE_INPUT,"Login",sho, "Login", "Quit");
        	INI_ParseFile(Path(playerid),"loadaccount_%s", .bExtra = true, .extra = playerid); //Will load user's data using INI_Parsefile.
    	}
		else
    	{
    		new str[128], sho[128];
    		if(BanInfo[playerid][pBanPerm]==1) return 0;
	    	strcat(sho, "{FFFFFF}Welcome to {FF0000}Vision {FFFFFF}Drifting\n\n");
			format(str, sizeof(str), "{FFFF00}Account:	{FFFFFF}%s\n\n", GetName(playerid));
			strcat(sho, str, sizeof(sho));
			strcat(sho, "{FFFFFF}Register your Account by enter your password below:");
		
        	ShowPlayerDialog(playerid,dregister,DIALOG_STYLE_INPUT,"Register","Welcome! This account is not registered.\nEnter your own password to create a new account.","Register","Quit");
			return 1;
		}
  	}
	return 1;
}

public speedometer(playerid)
{
    GetVehicleVelocity(GetPlayerVehicleID(playerid), svx[playerid], svy[playerid], svz[playerid]); // This Saves Our Velocitys To Our Varibles
    s1[playerid] = floatsqroot(((svx[playerid]*svx[playerid])+(svy[playerid]*svy[playerid]))+(svz[playerid]*svz[playerid]))*100; // This Is Our Forumula ( I Don't Know How It Works )
    s2[playerid] = floatround(s1[playerid],floatround_round); // This Rounds Our Output To The Nearest Whole Number
    format(s3[playerid],256,"%i ~y~MPH", s2[playerid]); // This Format Our Text Into What We See
    TextDrawSetString(speedo[playerid], s3[playerid]); // This Changes The Value Of Our Textdraw To What We Formatted
	TextDrawShowForPlayer(playerid, box[playerid]);
	return 1;
}

public RandomMessage()
{
	TextDrawSetString(Textdraw2, RandomMessages[random(sizeof(RandomMessages))]);
	return 1;
}

public settime(playerid)
{
	new string[256],year,month,day,hours,minutes,seconds;
 	getdate(year, month, day), gettime(hours, minutes, seconds);
  	format(string, sizeof string, "%d/%s%d/%s%d", day, ((month < 10) ? ("0") : ("")), month, (year < 10) ? ("0") : (""), year);
   	TextDrawSetString(Date, string);
    format(string, sizeof string, "%s%d:%s%d:%s%d", (hours < 10) ? ("0") : (""), hours, (minutes < 10) ? ("0") : (""), minutes, (seconds < 10) ? ("0") : (""), seconds);
    TextDrawSetString(Time, string);
}

public OnPlayerDisconnect(playerid, reason)
{
	RemovePlayerMapIcon(playerid, 0), RemovePlayerMapIcon(playerid, 1), RemovePlayerMapIcon(playerid, 2);
	TextDrawHideForPlayer(playerid,HAYTD[playerid]);
	god[playerid] = 0;
	minigun[playerid] = 0;
	onede[playerid] = 0;
	superman[playerid] = 0;
	cameradone[playerid] = 0;
	DestroyDynamic3DTextLabel(serverowner[playerid]);
    TextDrawHideForPlayer(playerid, textstring);
	new INI:file = INI_Open(Path(playerid)); 
  	INI_SetTag(file,"Player's Data");
 	INI_WriteInt(file,"AdminLevel",pInfo[playerid][Admin]); 
	INI_WriteInt(file,"VIPLevel",pInfo[playerid][VIPlevel]);
	INI_WriteInt(file,"Money",GetPlayerMoney(playerid));
	INI_WriteInt(file,"Scores",GetPlayerScore(playerid));
	INI_WriteInt(file,"Kills",pInfo[playerid][Kills]);
	INI_WriteInt(file,"Deaths",pInfo[playerid][Deaths]);
	INI_WriteInt(file,"Colour",GetPlayerColor(playerid));
	INI_WriteInt(file,"Skin",pInfo[playerid][pSkin]);
	TextDrawHideForPlayer(playerid,ServerTextDrawOne);
	TextDrawHideForPlayer(playerid,ServerTextDrawTwo);
    TextDrawHideForPlayer(playerid,ServerTextDrawThree[playerid]);
  	TextDrawHideForPlayer(playerid,ServerTextDrawFour[playerid]);
  	TextDrawHideForPlayer(playerid,ServerTextDrawFive[playerid]);
   	TextDrawSetString(ServerTextDrawThree[playerid]," ");
   	TextDrawSetString(ServerTextDrawFour[playerid]," ");
   	TextDrawSetString(ServerTextDrawFive[playerid]," ");
   	PlayerUseDriftCounter[playerid] = 1;
	PlayerMoney[playerid] = 0;
	PlayerScore[playerid] = 0;
	PlayerCombo[playerid] = 1;
	PlayerPositionX[playerid] = 0.0;
	PlayerPositionY[playerid] = 0.0;
	PlayerPositionZ[playerid] = 0.0;
	KillTimer(PlayerTimerOne[playerid]);
	INI_Close(file);
    afk[playerid] = 0;
	TextDrawHideForPlayer(playerid, Textdraw0);
    TextDrawHideForPlayer(playerid, Textdraw2);
    TextDrawHideForPlayer(playerid, vd);
    TextDrawHideForPlayer(playerid, vd1);
    TextDrawHideForPlayer(playerid, vd2);
    TextDrawHideForPlayer(playerid, godbox);
    TextDrawHideForPlayer(playerid, god1);
   	TextDrawHideForPlayer(playerid, speedo[playerid]);
	TextDrawHideForPlayer(playerid, box[playerid]);
    TextDrawHideForPlayer(playerid, TeleportText);
    TextDrawHideForPlayer(playerid, Time), TextDrawHideForPlayer(playerid, Date);
	switch(reason)
	{
	    case 0: format(strg, sizeof(strg), "* {15D4ED}Player{FFFFFF} %s(%d) {15D4ED}has left Vision Drifting [Timed Out]", GetName(playerid), playerid);
		case 1: format(strg, sizeof(strg), "* {15D4ED}Player{FFFFFF} %s(%d) {15D4ED}has left Vision Drifting [Leaving]", GetName(playerid), playerid);
		case 2: format(strg, sizeof(strg), "* {15D4ED}Player{FFFFFF} %s(%d) {15D4ED}has left Vision Drifting [Kicked/Banned]", GetName(playerid), playerid);
	}
	
	if(IsBeingSpeced[playerid] == 1)//If the player being spectated, disconnects, then turn off the spec mode for the spectator.
    {
        foreach(Player,i)
        {
            if(spectatorid[i] == playerid)
            {
                TogglePlayerSpectating(i,false);// This justifies what's above, if it's not off then you'll be either spectating your connect screen, or somewhere in blueberry (I don't know why)
            }
        }
    }
	return 1;
}

public OnPlayerSpawn(playerid)
{
    TextDrawShowForPlayer(playerid, speedo[playerid]); // This Shows The User The Textdraw ;
	JoinedHay[playerid] = 0;
  	SetPlayerWorldBounds(playerid, 20000.0000, -20000.0000, 20000.0000, -20000.0000);
  	TextDrawHideForPlayer(playerid,HAYTD[playerid]);
    TextDrawHideForPlayer(playerid, godbox);
    TextDrawHideForPlayer(playerid, god1);
	GangZoneShowForAll(gangzone0, COLOR_LBLUE);
	GangZoneShowForAll(gangzone1, COLOR_LBLUE);
	GangZoneShowForAll(gangzone2, COLOR_LBLUE);
	cameradone[playerid] = 0;
	if(pInfo[playerid][pSkin] >= 0)
	{
	    SetPlayerSkin(playerid, pInfo[playerid][pSkin]);
	}
	if(IsSpecing[playerid] == 1)
    {
        SetPlayerPos(playerid,SpecX[playerid],SpecY[playerid],SpecZ[playerid]);// Remember earlier we stored the positions in these variables, now we're gonna get them from the variables.
        SetPlayerInterior(playerid,Inter[playerid]);//Setting the player's interior to when they typed '/spec'
        SetPlayerVirtualWorld(playerid,vWorld[playerid]);//Setting the player's virtual world to when they typed '/spec'
        IsSpecing[playerid] = 0;//Just saying you're free to use '/spec' again YAY :D
        IsBeingSpeced[spectatorid[playerid]] = 0;//Just saying that the player who was being spectated, is not free from your stalking >:D
    }
	if(minigun[playerid] == 1)
	{
		new Random = random(sizeof(MinigunSpawns));
		SetPlayerPos(playerid, MinigunSpawns[Random][0], MinigunSpawns[Random][1], MinigunSpawns[Random][2]);
    	SetPlayerFacingAngle(playerid, MinigunSpawns[Random][3]);
    	SetPlayerVirtualWorld(playerid, 2);
    	SetPVarInt(playerid, "minigun", 1);
		GivePlayerWeapon(playerid, 38, 99999);
		SetPlayerHealth(playerid, 100);
		return 0;
	}
	if(onede[playerid] == 1)
	{
		new Random = random(sizeof(OnedeSpawns));
		SetPlayerPos(playerid, OnedeSpawns[Random][0], OnedeSpawns[Random][1], OnedeSpawns[Random][2]);
    	SetPlayerVirtualWorld(playerid, 2);
    	SetPVarInt(playerid, "onede", 1);
		GivePlayerWeapon(playerid, 24, 99999);
		SetPlayerInterior(playerid, 3);
		SetPlayerHealth(playerid, 20);
		return 0;
	}
	StopAudioStreamForPlayer(playerid);
	god[playerid] = 0;
	if(pInfo[playerid][Admin] == 5)
	{
		serverowner[playerid] = CreateDynamic3DTextLabel("{87A3AE}HeadAdmin", -1, 0.0, 0.0, -0.9, 20, playerid, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid, 100);
	}
    afk[playerid] = 0;
    minigun[playerid] = 0;
	onede[playerid] = 0;
	new Random = random(sizeof(RandomSpawns));
	SetPlayerPos(playerid, RandomSpawns[Random][0], RandomSpawns[Random][1], RandomSpawns[Random][2]);
    SetPlayerFacingAngle(playerid, RandomSpawns[Random][3]);
    
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    TextDrawShowForPlayer(playerid, Textdraw0);
    TextDrawShowForPlayer(playerid, Textdraw2);
    TextDrawShowForPlayer(playerid, Time), TextDrawShowForPlayer(playerid, Date);
    SetPlayerHealth(playerid, 999999);
    GivePlayerWeapon(playerid, 43, 99999);
    
	return 1;
}
CMD:hydra(playerid, params[])
{
    if(minigun[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
	if(onede[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
    if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You are not In AFK mode can't use any commands");
    if(GetPVarInt(playerid, "InsideHouse")) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You can't use commands when in the house");
	if(pInfo[playerid][Admin] > 1)
	{
    	CreateVehicleEx(playerid, 520, X,Y,Z+1, Angle, random(126), random(126), -1);
    	SendClientMessage(playerid, COLOR_YELLOW, "Hydra Spawned");
	}
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
	return 1;
}

CMD:hay(playerid,cmdtext[])
{
	if (JoinedHay[playerid] == 0)
	{
		JoinedHay[playerid] = 1;
		SetPlayerWorldBounds(playerid, 116.7788, -70.06725, 105.1009, -116.7788);
	 	TimeInHay[playerid] = GetTickCount();
		SetPlayerPos(playerid, 0, 6.5, 3.2);
		SetPlayerFacingAngle( playerid, 135 );
		SetPlayerVirtualWorld(playerid, 0);
		ResetPlayerWeapons(playerid);
		return 1;
	}
	if(JoinedHay[playerid] == 1)
	{
	    JoinedHay[playerid] = 0;
	    SetPlayerWorldBounds(playerid, 20000.0000, -20000.0000, 20000.0000, -20000.0000);
	    TextDrawHideForPlayer(playerid,HAYTD[playerid]);
	    SpawnPlayer(playerid);
		return 1;
	}
	return 0;
}

CMD:spec(playerid, params[])
{
    new id;// This will hold the ID of the player you are going to be spectating.
    if(pInfo[playerid][Admin] < 1) return SendClientMessage(playerid, COLOR_PINK,"Error: You can't use this command!");
    if(sscanf(params,"u", id))return SendClientMessage(playerid, Grey, "Uzyj: /spec [id]");// Now this is where we use sscanf to check if the params were filled, if not we'll ask you to fill them
    if(id == playerid)return SendClientMessage(playerid,Grey,"Nie mozesz podgladac samego siebie.");// Just making sure.
    if(id == INVALID_PLAYER_ID)return SendClientMessage(playerid, Grey, "Nie ma gracza o podanym ID!");// This is to ensure that you don't fill the param with an invalid player id.
    if(IsSpecing[playerid] == 1)return SendClientMessage(playerid,Grey,"Juz kogos podgladasz, uzyj najpierw komendy /specoff.");// This will make you not automatically spec someone else by mistake.
    GetPlayerPos(playerid,SpecX[playerid],SpecY[playerid],SpecZ[playerid]);// This is getting and saving the player's position in a variable so they'll respawn at the same place they typed '/spec'
    Inter[playerid] = GetPlayerInterior(playerid);// Getting and saving the interior.
    vWorld[playerid] = GetPlayerVirtualWorld(playerid);//Getting and saving the virtual world.
    TogglePlayerSpectating(playerid, true);// Now before we use any of the 3 functions listed above, we need to use this one. It turns the spectating mode on.
    if(IsPlayerInAnyVehicle(id))//Checking if the player is in a vehicle.
    {
        if(GetPlayerInterior(id) > 0)//If the player's interior is more than 0 (the default) then.....
        {
            SetPlayerInterior(playerid,GetPlayerInterior(id));//.....set the spectator's interior to that of the player being spectated.
        }
        if(GetPlayerVirtualWorld(id) > 0)//If the player's virtual world is more than 0 (the default) then.....
        {
            SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(id));//.....set the spectator's virtual world to that of the player being spectated.
        }
        PlayerSpectateVehicle(playerid,GetPlayerVehicleID(id));// Now remember we checked if the player is in a vehicle, well if they're in a vehicle then we'll spec the vehicle.
    }
    else// If they're not in a vehicle, then we'll spec the player.
    {
        if(GetPlayerInterior(id) > 0)
        {
            SetPlayerInterior(playerid,GetPlayerInterior(id));
        }
        if(GetPlayerVirtualWorld(id) > 0)
        {
            SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(id));
        }
        PlayerSpectatePlayer(playerid,id);// Letting the spectator spec the person and not a vehicle.
    }
    GetPlayerName(id, Name, sizeof(Name));//Getting the name of the player being spectated.
    IsSpecing[playerid] = 1;// Just saying that the spectator has begun to spectate someone.
    IsBeingSpeced[id] = 1;// Just saying that a player is being spectated (You'll see where this comes in)
    spectatorid[playerid] = id;// Saving the spectator's id into this variable.
    return 1;// Returning 1 - saying that the command has been sent.
}

CMD:specoff(playerid, params[])
{
    if(pInfo[playerid][Admin] < 1) return SendClientMessage(playerid, COLOR_PINK,"Error: You can't use this command!");
    if(IsSpecing[playerid] == 0)return SendClientMessage(playerid,Grey,"Nikogo nie podgladasz.");
    TogglePlayerSpectating(playerid, 0);//Toggling spectate mode, off. Note: Once this is called, the player will be spawned, there we'll need to reset their positions, virtual world and interior to where they typed '/spec'
    return 1;
}
CMD:report(playerid, params[])
{
    new pName[MAX_PLAYER_NAME], aName[MAX_PLAYER_NAME], str[128], reason, iD;
    if (sscanf(params, "dz", iD, reason)) return SendClientMessage(playerid, 0xAA3333AA, "Usage: /report [id] [reason]");
    if (iD == INVALID_PLAYER_ID) return SendClientMessage(playerid, 0xAA3333AA, "Invalid ID.");
    if (playerid == iD) return SendClientMessage(playerid, 0xAA3333AA, "You can't report yourself.");
    GetPlayerName(playerid, pName, sizeof(pName));
    GetPlayerName(iD, aName, sizeof(aName));
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i))
        {
            new zName[MAX_PLAYER_NAME], pFile[256];
            GetPlayerName(i, zName, sizeof(zName));
            format(pFile, sizeof(pFile), "Users\%s.ini", zName);
            if(pInfo[playerid][Admin] > 1)
            {
                format(str, sizeof(str), "%s(%d) has reported %s(%d) for: %s", pName, playerid, aName, iD, reason);
                SendClientMessage(i, 0xFFFFFFFF, str);
            }
        }
    }
    return 1;
}
CMD:hunter(playerid, params[])
{
    if(minigun[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
	if(onede[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
    if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You are not In AFK mode can't use any commands");
    if(GetPVarInt(playerid, "InsideHouse")) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You can't use commands when in the house");
	if(pInfo[playerid][Admin] > 1)
	{
	    CreateVehicleEx(playerid, 425, X,Y,Z+1, Angle, random(126), random(126), -1);
	    SendClientMessage(playerid, COLOR_YELLOW, "Hunter Spawned");
    }
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
	return 1;
}
CMD:rhino(playerid, params[])
{
    if(minigun[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
	if(onede[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
    if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You are not In AFK mode can't use any commands");
    if(GetPVarInt(playerid, "InsideHouse")) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You can't use commands when in the house");
	if(pInfo[playerid][Admin] > 1)
	{
		CreateVehicleEx(playerid, 432, X,Y,Z+1, Angle, random(126), random(126), -1);
		SendClientMessage(playerid, COLOR_YELLOW, "Hunter Spawned");
	}
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
	return 1;
}
CMD:armour(playerid, params[])
{
    if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You are not In AFK mode can't use any commands");
	if(onede[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
    if(GetPVarInt(playerid, "InsideHouse")) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You can't use commands when in the house");
	if(pInfo[playerid][Admin] > 1) { SetPlayerArmour(playerid, 100);}
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
	return 1;
}

CMD:acmds(playerid, params[])
{
	new str[256];
	if(pInfo[playerid][Admin] > 1)
	{
		strcat(str, "/setcolor /ban /renoveban /removeban /banperm /banm /showbaninfo\n");
		strcat(str, "/givecash /akill /check /kick /respawn /get /goto\n");
		ShowPlayerDialog(playerid, 231, DIALOG_STYLE_MSGBOX, "Acmds", str, "close", "");
	}
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
	return 1;
}
CMD:stats(playerid, params[])
{
	new string[520], sho[520], lvl;
	format(string, sizeof(string), "%s {FFFFFF}status:\n\n", GetName(playerid));
	strcat(sho, string, sizeof(sho));
	strcat(sho, "{FF0000}Player Status:\n");
	format(string, sizeof(string), "{15D4ED}>> Admin Level:{FFFF00} %d\n", pInfo[playerid][Admin]);
	strcat(sho, string, sizeof(sho));
	format(string, sizeof(string), "{15D4ED}>> VIP Level:{FFFF00} %d\n\n", pInfo[playerid][VIPlevel]);
	strcat(sho, string, sizeof(sho));
	strcat(sho, "{FF0000}Player Information:\n");
	format(string, sizeof(string), "{15D4ED}>> Money: {00FF00}${FFFF00}%d\n", GetPlayerMoney(playerid));
	strcat(sho, string, sizeof(sho));
	format(string, sizeof(string), "{15D4ED}>> Score:{FFFF00} %d\n", GetPlayerScore(playerid));
	strcat(sho, string, sizeof(sho));
	format(string, sizeof(string), "{15D4ED}>> Skins:{FFFF00} %d\n\n", pInfo[playerid][pSkin]);
	strcat(sho, string, sizeof(sho));
	strcat(sho, "{FF0000}Other Information:\n");
	format(string, sizeof(string), "{15D4ED}>> Kills:{FFFF00} %d\n", pInfo[playerid][Kills]);
	strcat(sho, string, sizeof(sho));
	format(string, sizeof(string), "{15D4ED}>> Deaths:{FFFF00} %d\n", pInfo[playerid][Deaths]);
	strcat(sho, string, sizeof(sho));
	ShowPlayerDialog(playerid, 66, DIALOG_STYLE_MSGBOX, "Players Information", sho, "Close", "");
	switch(lvl)
	{
 		case 0: AdminRank = "Player";
		case 1: AdminRank = "{00FF00}Moderator";
		case 2: AdminRank = "{FF00FF}Supporter";
		case 3: AdminRank = "{0000FF}Administrator";
		case 4: AdminRank = "{CCFF00}Vice HeadAdmin";
		case 5: AdminRank = "{FF0000}HeadAdmin";
	}
	return 1;
}

CMD:rgb(playerid,params[]) // Set ur own color
{
	if(cForced[playerid] == 0)
	{
		static R, G, B;
		if (sscanf(params, "iii", R,G,B)) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFF00}/rgb <0-255> <0-255> <0-255>");
		SendClientMessage(playerid,(R * 16777216) + (G * 65536) + (B*256), "This is your new Color");
		SetPlayerColor(playerid, (R * 16777216) + (G * 65536) + (B*256));
	}
	else return SendClientMessage(playerid, 0xff0000aa, "{B0B0B0}* This command has been disabled for u");
    return 1;
}
CMD:color(playerid, params[])
{
	ShowPlayerDialog(playerid, 552, DIALOG_STYLE_LIST, "Select Colour", "{FF0000}Red\n{00FF00}Green\n{0000FF}Blue\n{15D4ED}Light Blue\n{B0B0B0}Grey\n{CCFFEE}Orange", "select", "cancel");
	SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {15D4ED}You can also set color using {FFFF00}/rgb <0-255> <0-255> <0-255>");
	return 1;
}

CMD:setcolor(playerid,params[]) // Set another player's color
{

	if(pInfo[playerid][Admin] > 1)
	{
		static ID, R, G, B, name[MAX_PLAYER_NAME], string[128];
		if (sscanf(params, "uiii", ID, R,G,B)) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFF00}/setcolor <playerid/name> <0-255> <0-255> <0-255>");
		GetPlayerName(playerid, name, sizeof(name));
		format(string, sizeof(string), "this is  your new color, set by %s", name);
		SendClientMessage(ID,(R * 16777216) + (G * 65536) + (B*256), string);
		GetPlayerName(ID, name, sizeof(name));
		format(string, sizeof(string), "this is the new color, u gave to %s, use /unforce to let him change their color again.", name);
		SendClientMessage(playerid,(R * 16777216) + (G * 65536) + (B*256), string);

		cForced[ID] = 1; //This sets that the player cannot just use /color again after his color has been set
		SetPlayerColor(ID, (R * 16777216) + (G * 65536) + (B*256));
	}
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
    return 1;
}

CMD:unforce(playerid,params[])
{

	if(pInfo[playerid][Admin] > 1)
	{
	    static ID, name[MAX_PLAYER_NAME], string[128];
	    if(!IsPlayerAdmin(playerid)) return 1;
	    if(sscanf(params, "u", ID)) return SendClientMessage(playerid, 0xff0000aa, "*vDR {B0B0B0}» {FFFF00}/unforce <playerid/name>");
	    if(cForced[ID] != 1) return SendClientMessage(playerid, 0xff0000aa, "* This player is already unforced!");
		GetPlayerName(playerid, name, sizeof(name));
		format(string, sizeof(string), "%s has unforced u and u can now use /color again", name);
		SendClientMessage(ID, 0x00ff00aa, string);
		GetPlayerName(ID, name, sizeof(name));
		format(string, sizeof(string), "You have unforced %s, and he's now free to use /color again", name);
		SendClientMessage(playerid,0x00ff00aa, string);
		cForced[ID] = 0;
	}
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
	return 1;
}

CMD:camera(playerid, params[])
{

	if(minigun[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
    if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You are not In AFK mode can't use any commands");
	GivePlayerWeapon(playerid, 43, 99999);
	SendClientMessage(playerid, COLOR_GREEN, "[INFO]: {FFFFFF}Camera has been given");
	PlayerPlaySound(playerid, 1138, 0.0, 0.0, 0.0);
	return 1;
}

CMD:ban(playerid,parmas[])
{

	if(pInfo[playerid][Admin] > 1)
	{
    	new tid,du,res[128],ppp[50],str[520],sho[520], playa;
    	if(sscanf(parmas, "uis[128]", tid, du, res)) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} /Ban [playerid] [Duration(In Days)] [reason]");
    	if(!IsPlayerConnected(tid))return SendClientMessage(playerid, COLOR_RED,"{ff6666}The Player you requested is not connected.");
		format(String, sizeof(String),"~r~Ban~n~~w~Player: %s~n~Admin: %s~n~~y~~h~%s ~n~Days: %s",PlayerName(playa),PlayerName(playerid),res,du); 
        Kara(String);
    	new adminname[MAX_PLAYER_NAME],targetn[MAX_PLAYER_NAME];
     	GetPlayerName(playerid,adminname,sizeof(adminname));
     	new exp=gettime()+(60*60*24*du);
     	GetPlayerIp(tid,ppp,sizeof(ppp));
     	new INI:File = INI_Open(UserBanPath(tid));
     	INI_SetTag(File,"data");
     	INI_WriteInt(File,"Banexp",exp);
     	INI_WriteInt(File,"BanPerm",0);
     	INI_WriteString(File,"BanAdmin",adminname);
     	INI_WriteString(File,"Reason",res);
     	INI_WriteString(File,"IP",ppp);
     	INI_Close(File);
     	GetPlayerName(tid,targetn,sizeof(targetn));
     	new INI:iFile = INI_Open(UserIPPath(tid));
     	INI_SetTag(iFile,"data");
     	INI_WriteInt(iFile,"Banexp",exp);
     	INI_WriteInt(iFile,"BanPerm",0);
     	INI_WriteString(iFile,"BanPlayer",targetn);
     	INI_WriteString(iFile,"BanAdmin",adminname);
     	INI_WriteString(iFile,"Reason",res);
     	INI_Close(iFile);
     	new File:logg=fopen("BannedPlayers.txt",io_append);
      	fwrite(logg, targetn);
        fwrite(logg,"\n");
        fclose(logg);
        
   	    strcat(sho, "{FF0000}vDR:Banned!\n\n");
		format(str, sizeof(str), "{FF0000}Name:{FFFF00} %s\n", GetName(tid));
		strcat(sho, str, sizeof(sho));
		format(str, sizeof(str), "{FF0000}Administrator:{FFFF00} %s\n", adminname);
		strcat(sho, str, sizeof(sho));
		format(str, sizeof(str), "{FF0000}Ban Days:{FFFF00} %s\n", du);
		strcat(sho, str, sizeof(sho));
		format(str, sizeof(str), "{FF0000}Reason:{FFFF00} %s\n\n", res);
		strcat(sho, str, sizeof(sho));
		strcat(sho, "{FF0000}if this is a wrongfully banned you can make ban appeals at our website");
		ShowPlayerDialog(tid, 9999, DIALOG_STYLE_MSGBOX, "{FF0000}You Are Banned", sho, "Close", "");
		SetTimerEx("DelayBan",1200,0,"i", tid);
  		format(str, sizeof(str), "{FFFF00}- AS - {FF0000}%s(%d) has been Banned by Administrator %s(%d) {A0A0A0}[Reason: %s]", GetName(tid), tid, GetName(playerid), playerid, res);
	    SendClientMessageToAll(COLOR_RED, str);
    }
	else SendClientMessage(playerid,-1,"{ff0000}You are not authorized to use this command.");
    return 1;
}
/*===================================================================================================*/
CMD:removeban(playerid,parmas[])
{

	if(pInfo[playerid][Admin] >= 3)
	{
	    new rename[MAX_PLAYER_NAME],pat[MAX_PLAYER_NAME+10],pati[MAX_PLAYER_NAME+10],ppf[100],adname[MAX_PLAYER_NAME];
	    if(sscanf(parmas,"s",rename) || isnull(parmas))return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} /removeban [playername]");
	    format(pat,sizeof(pat),"Bans/%s.ini",rename);
	    if(!fexist(pat))
	    {
	        format(ppf,sizeof(ppf),"The user cannot be unbanned because there is user named as %s banned.",rename);
	        SendClientMessage(playerid,-1,ppf);
	        return 1;
	    }
	    INI_ParseFile(pat, "LoadIP_%s", .bExtra = true, .extra = playerid);
	    format(pati,sizeof(pat),"IP/%s.ini",pp);
	    fremove(pati);
	    format(pat,sizeof(pat),"Bans/%s.ini",rename);
	    fremove(pat);
	    format(ppf,sizeof(ppf),"The player %s has been un-banned.",rename);
	    SendClientMessage(playerid,0x00FF00FF,ppf);
	    GetPlayerName(playerid,adname,sizeof(adname));
	    format(pat,sizeof(pat),"%s has been unbanned by %s",rename,adname);
	    new File:log=fopen("unban_log.txt",io_append);
	    fwrite(log, pat);
	    fwrite(log,"\r\n");
	    fclose(log);
	    fdeleteline("BannedPlayers.txt", rename);
 	}
  	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
    return 1;
}
/*====================================================================================================*/
CMD:banperm(playerid,parmas[])
{

	if(pInfo[playerid][Admin] > 1)
	{
	    new tid,res[90],ppp[50],playa;
	    if(sscanf(parmas,"us",tid,res) || isnull(parmas))return SendClientMessage(playerid,-1,"vDR {B0B0B0}»{FFFF00} /banperm [playerid] [Reason]");
	    if(!IsPlayerConnected(playa)||playa==playerid) return SendClientMessage(playerid, 0xBABABAFF, "Wrong ID");
        format(String, sizeof(String),"~r~Ban Perm~n~~w~Player: %s~n~Admin: %s~n~~y~~h~%s",PlayerName(playa),PlayerName(playerid),res); 
        Kara(String);
	    new adminname[MAX_PLAYER_NAME];
	    GetPlayerName(playerid,adminname,sizeof(adminname));
	    GetPlayerIp(tid,ppp,sizeof(ppp));
	    new INI:File = INI_Open(UserBanPath(tid));
	    INI_SetTag(File,"data");
	    INI_WriteInt(File,"Banexp",0);
	    INI_WriteInt(File,"BanPerm",1);
	    INI_WriteString(File,"BanAdmin",adminname);
	    INI_WriteString(File,"Reason",res);
	    INI_WriteString(File,"IP",ppp);
	    INI_Close(File);
	    new targetn[MAX_PLAYER_NAME];
	    GetPlayerName(tid,targetn,sizeof(targetn));
	    new INI:iFile = INI_Open(UserIPPath(tid));
	    INI_SetTag(iFile,"data");
	    INI_WriteInt(iFile,"Banexp",0);
	    INI_WriteInt(iFile,"BanPerm",1);
	    INI_WriteString(iFile,"BanPlayer",targetn);
	    INI_WriteString(iFile,"BanAdmin",adminname);
	    INI_WriteString(iFile,"Reason",res);
	    INI_Close(iFile);

		new str[520],sho[520];
		strcat(sho, "{FF0000}vDR:Banned!\n\n");
		format(str, sizeof(str), "{FF0000}Name:{FFFF00} %s\n", GetName(tid));
		strcat(sho, str, sizeof(sho));
		format(str, sizeof(str), "{FF0000}Administrator:{FFFF00} %s\n", adminname);
		strcat(sho, str, sizeof(sho));
		format(str, sizeof(str), "{FF0000}Reason:{FFFF00} %s\n\n", res);
		strcat(sho, str, sizeof(sho));
		strcat(sho, "{FF0000}if this is a wrongfully banned you can make ban appeals at our website");
		ShowPlayerDialog(tid, 9999, DIALOG_STYLE_MSGBOX, "{FF0000}You Are Banned", sho, "Close", "");
		SetTimerEx("DelayBan",1200,0,"i", tid);
		format(str, sizeof(str), "{FFFF00}- AS - {FF0000}%s(%d) has been Banned by Administrator %s(%d) {A0A0A0}[Reason: %s]", GetName(tid), tid, GetName(playerid), playerid, res);
	 	SendClientMessageToAll(COLOR_RED, str);

	    new File:logg=fopen("BannedPlayers.txt",io_append);
	    fwrite(logg, targetn);
	    fwrite(logg,"\n");
	    fclose(logg);
	}
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
    return 1;
}
/*=======================================================================================================*/
CMD:banm(playerid,parmas[])
{

    if(IsPlayerAdmin(playerid))
	{
    	new tid,h,m,res[150],ppp[50],playa;
    	if(sscanf(parmas,"uiis",tid,h,m,res) || isnull(parmas))return SendClientMessage(playerid, COLOR_RED,"vDR {B0B0B0}»{FFFF00} /ban(minutes) [playerid] [Hours] [Minutes] [Reason]");
    	if(!IsPlayerConnected(tid))return SendClientMessage(playerid,COLOR_RED,"The Player you requested is not connected.");
		format(String, sizeof(String),"~r~Time Ban~n~~w~Player: %s~n~Admin: %s~n~~y~~h~%s",PlayerName(playa),PlayerName(playerid),res); 
        Kara(String);
    	new adminname[MAX_PLAYER_NAME],targetn[MAX_PLAYER_NAME];
     	GetPlayerName(playerid,adminname,sizeof(adminname));
     	new exp=gettime()+(60*m)+(60*60*h);
     	GetPlayerIp(tid,ppp,sizeof(ppp));
     	new INI:File = INI_Open(UserBanPath(tid));
     	INI_SetTag(File,"data");
     	INI_WriteInt(File,"Banexp",exp);
     	INI_WriteInt(File,"BanPerm",0);
     	INI_WriteString(File,"BanAdmin",adminname);
     	INI_WriteString(File,"Reason",res);
     	INI_WriteString(File,"IP",ppp);
     	INI_Close(File);
     	GetPlayerName(tid,targetn,sizeof(targetn));
     	new INI:iFile = INI_Open(UserIPPath(tid));
     	INI_SetTag(iFile,"data");
     	INI_WriteInt(iFile,"Banexp",exp);
     	INI_WriteInt(iFile,"BanPerm",0);
     	INI_WriteString(iFile,"BanPlayer",targetn);
     	INI_WriteString(iFile,"BanAdmin",adminname);
     	INI_WriteString(iFile,"Reason",res);
     	INI_Close(iFile);
     	
   		new str[520],sho[520];
		strcat(sho, "{FF0000}vDR:Banned!\n\n");
		format(str, sizeof(str), "{FF0000}Name:{FFFF00} %s\n", GetName(tid));
		strcat(sho, str, sizeof(sho));
		format(str, sizeof(str), "{FF0000}Administrator:{FFFF00} %s\n", adminname);
		strcat(sho, str, sizeof(sho));
		format(str, sizeof(str), "{FF0000}Ban Hours:{FFFF00} %i Hours, %i Minutes", h,m);
		strcat(sho, str, sizeof(sho));
		format(str, sizeof(str), "{FF0000}Reason:{FFFF00} %s\n\n", res);
		strcat(sho, str, sizeof(sho));
		strcat(sho, "{FF0000}if this is a wrongfully banned you can make ban appeals at our website");
		ShowPlayerDialog(tid, 9999, DIALOG_STYLE_MSGBOX, "{FF0000}You Are Banned", sho, "Close", "");
		SetTimerEx("DelayBan",1200,0,"i", tid);
     	
     	new File:logg=fopen("BannedPlayers.txt",io_append);
      	fwrite(logg, targetn);
        fwrite(logg,"\n");
        fclose(logg);
		format(str, sizeof(str), "{FFFF00}- AS - {FF0000}%s(%d) has been Banned by Administrator %s(%d) {A0A0A0}[Reason: %s]", GetName(tid), tid, GetName(playerid), playerid, res);
 		SendClientMessageToAll(COLOR_RED, str);
    }
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
    return 1;
}
/*=======================================================================================================*/
CMD:log(playerid,parmas[])
{

    if(IsPlayerAdmin(playerid))
	{
		new read[500],ss[1008],op[1000];
		format(op,sizeof(op),"");
		new File:log=fopen("unban_log.txt",io_read);
		while(fread(log,read))
		{
			strcat(read,"\n",500);
			strcat(op,read,1000);
		}
		fclose(log);
		format(ss,sizeof(ss),"{9ACD32}%s",op);
		ShowPlayerDialog(playerid, 110, DIALOG_STYLE_MSGBOX, "{00BFFF}Showing Un-Ban Log",ss, "Cool", "");
	}
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
	return 1;
}
/*=========================================================================================================*/
CMD:showbans(playerid,parmas[])
{

    if(IsPlayerAdmin(playerid))
	{
		new read[200],ss[1008],op[1000],bool:NextDialog=false;
		format(op,sizeof(op),"");
		new File:log=fopen("BannedPlayers.txt",io_read);
		while(fread(log,read))
		{
			strcat(read,"\n",200);
			strcat(op,read,1000);
			ln[playerid]++;
			if(ln[playerid]==110)//this specifies the maximum no. of bans that are to be shown in 1 dialog box
			{
				NextDialog=true;
				break;
			}
		}
		fclose(log);
		if(strlen(op)<=3)return SendClientMessage(playerid,-1,"{ff0000}No players currently banned.");
		format(ss,sizeof(ss),"{9ACD32}%s",op);
		if(NextDialog==false)ShowPlayerDialog(playerid, 110,  DIALOG_STYLE_LIST, "{00FFFF}Showing Currently Banned Players",ss, "Select", "Cancel");
		else ShowPlayerDialog(playerid, 111,  DIALOG_STYLE_LIST, "{00FFFF}Showing Currently Banned Players",ss, "Select", "Next Page");
	}
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
	return 1;
}
/*================================================================================================================*/
CMD:showbaninfo(playerid,parmas[])
{

	if(IsPlayerAdmin(playerid))
	{
		new tid[MAX_PLAYER_NAME];
		if(sscanf(parmas,"s",tid))return SendClientMessage(playerid,-1,"vDR {B0B0B0}»{FFFF00} /showbaninfo [PlayerName]\nNOTE:The PlayerName should be exact name of player.");
		new path[150];
		format(path,sizeof(path),"Bans/%s.ini",tid);
		if(!fexist(path))return SendClientMessage(playerid,-1,"vDR {B0B0B0}» The Players that you requested is nothing in Ban Database /showbans to view currently banned players.");
		Showinfo(playerid,tid);
	}
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
	return 1;
}
CMD:superman(playerid, params[])
{
	new str[80];

	if(GetPVarInt(playerid, "InsideHouse")) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You can't use commands when in the house");
	if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You are in AFK mode, Can't use any Commands");
	if(onede[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
	if(minigun[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You already in minigun DM, type /leave to leave DM");
	if(superman[playerid] == 0)
	{
    	superman[playerid] = 1;
    	SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFF00}Your superman Jump is ON");
		format(str, sizeof(str), "~w~Superman jump is ~g~ENABLE");
		TextDrawSetString(textstring, str);
		TextDrawShowForPlayer(playerid, textstring);
		SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
		PlayerPlaySound(playerid, 1138, 0.0, 0.0, 0.0);
	}
	else
	{
		superman[playerid] = 0;
		SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFF00}Your superman Jump is OFF");
		format(str, sizeof(str), "~w~Superman jump is ~r~DISABLE");
		TextDrawSetString(textstring, str);
		TextDrawShowForPlayer(playerid, textstring);
		SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
		PlayerPlaySound(playerid, 1137, 0.0, 0.0, 0.0);
	}
    return 1;
}
CMD:leave(playerid, params[])
{

	if(minigun[playerid] == 1)
	{
		ResetPlayerWeapons(playerid);
		SetPlayerHealth(playerid, 100);
		SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You are leaving Minigun Deathmatch");
		SpawnPlayer(playerid);
		minigun[playerid] = 0;
		DeletePVar(playerid, "minigun");
		SetPlayerVirtualWorld(playerid, 0);
	}
	if(onede[playerid] == 1)
	{
		ResetPlayerWeapons(playerid);
		SetPlayerHealth(playerid, 100);
		SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You are leaving Onede Deathmatch");
		SpawnPlayer(playerid);
		onede[playerid] = 0;
		DeletePVar(playerid, "onede");
		SetPlayerVirtualWorld(playerid, 0);
	}
	else return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You are not in any DM");
	return 1;
}

CMD:onede(playerid, params[])
{
    new str[120];

	if(GetPVarInt(playerid, "InsideHouse")) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You can't use commands when in the house");
	if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You are in AFK mode, Can't use any Commands");
	if(onede[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You already in onede DM, type /leave to leave DM");
	onede[playerid] = 1;
	superman[playerid] = 0;
	god[playerid] = 0;
	new Random = random(sizeof(OnedeSpawns));
	SetPlayerPos(playerid, OnedeSpawns[Random][0], OnedeSpawns[Random][1], OnedeSpawns[Random][2]);
	SetPlayerFacingAngle(playerid, OnedeSpawns[Random][2]);
 	SetPlayerVirtualWorld(playerid, 2);
	SetPlayerHealth(playerid, 20);
	SetPlayerArmour(playerid, 1);
	ResetPlayerWeapons(playerid);
 	SetPlayerInterior(playerid, 3);
	SetPVarInt(playerid, "onede", 1);
	GivePlayerWeapon(playerid, 24, 99999);
	format(strg, sizeof(strg), "[DEATHMATCH] {%06x}%s {15D4ED}has joined Onede Deathmatch (/onede)", (GetPlayerColor(playerid) >>> 8), GetName(playerid));
	format(str, sizeof(str), "~w~To leave type /leave ~y~%s~w~");
	TextDrawSetString(textstring, str);
	TextDrawShowForPlayer(playerid, textstring);
	SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
	SendClientMessage(playerid, COLOR_RED, strg);
	format(MessageStrl3, 170, MessageStrl2); // move the line 2 text to line 1
	format(MessageStrl2, 170, MessageStr); // move the line 3 text to line 2
	TextDrawHideForPlayer(playerid, god1);
	TextDrawHideForPlayer(playerid, godbox);
	format(MessageStr,sizeof MessageStr,"~r~[DM] ~w~%s(%d) has joined /onede.", GetName(playerid), playerid); //formatting line 3 text
	new STR[510]; //creating a new string to merge the 3 strings into a one 3 lines string
	format(STR, sizeof(STR), "%s~n~%s~n~%s", MessageStrl3, MessageStrl2, MessageStr); //formatting the newly created string
	TextDrawSetString(TeleportText, STR); //showing it on the screen
	TextDrawShowForAll(TeleportText);
	return 1;
}


CMD:mini(playerid, params[])
{
    new str[120];

	if(GetPVarInt(playerid, "InsideHouse")) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You can't use commands when in the house");
	if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You are in AFK mode, Can't use any Commands");
	if(minigun[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You already in minigun DM, type /leave to leave DM");
	minigun[playerid] = 1;
	superman[playerid] = 0;
	god[playerid] = 0;
	new Random = random(sizeof(MinigunSpawns));
	SetPlayerPos(playerid, MinigunSpawns[Random][0], MinigunSpawns[Random][1], MinigunSpawns[Random][2]);
 	SetPlayerFacingAngle(playerid, MinigunSpawns[Random][3]);
 	SetPlayerVirtualWorld(playerid, 2);
	ResetPlayerWeapons(playerid);
 	SetPlayerInterior(playerid, 0);
	SetPVarInt(playerid, "minigun", 1);
	GivePlayerWeapon(playerid, 38, 99999);
	format(strg, sizeof(strg), "[DEATHMATCH] {%06x}%s {15D4ED}has joined Minigun Deathmatch (/mini)", (GetPlayerColor(playerid) >>> 8), GetName(playerid));
	format(str, sizeof(str), "~w~To leave type /leave ~y~%s~w~");
	TextDrawSetString(textstring, str);
	TextDrawShowForPlayer(playerid, textstring);
	SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
	SendClientMessage(playerid, COLOR_RED, strg);
	SetPlayerHealth(playerid, 100);
	format(MessageStrl3, 170, MessageStrl2); // move the line 2 text to line 1
	format(MessageStrl2, 170, MessageStr); // move the line 3 text to line 2
	TextDrawHideForPlayer(playerid, god1);
	TextDrawHideForPlayer(playerid, godbox);
	format(MessageStr,sizeof MessageStr,"~r~[DM] ~w~%s(%d) has joined /mini.", GetName(playerid), playerid); //formatting line 3 text
	new STR[510]; //creating a new string to merge the 3 strings into a one 3 lines string
	format(STR, sizeof(STR), "%s~n~%s~n~%s", MessageStrl3, MessageStrl2, MessageStr); //formatting the newly created string
	TextDrawSetString(TeleportText, STR); //showing it on the screen
	TextDrawShowForAll(TeleportText);
	return 1;
}

CMD:forcereaction(playerid, params[])
{
	if(pInfo[playerid][Admin] > 1)
	{
        xReactionTest();
	}
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
	return 1;
}
CMD:setlevel(playerid, params[])
{
	new str[420], id, lvl, sho[420];
	if(pInfo[playerid][Admin] == 5 || IsPlayerAdmin(playerid))
	{
 		if(sscanf(params, "ui", id, lvl)) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} /setlevel [playerid] [0 - 5]");
   		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} Player not connected!");
	    if(lvl < 0 || lvl > 5) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} Invalid Level!");
		if(lvl == pInfo[id][Admin]) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} That player is already in that level!");
		if(pInfo[id][Admin] > lvl) GameTextForPlayer(id, "~r~Demoted", 3000, 3);
  		if(pInfo[id][Admin] < lvl) GameTextForPlayer(id, "~g~Promoted", 3000, 3);
   		switch(lvl)
    	{
	    	    case 0: AdminRank = "Player";
		    	case 1: AdminRank = "Moderator";
		    	case 2: AdminRank = "Administrator";
		    	case 3: AdminRank = "Administrator";
		    	case 4: AdminRank = "Vice HeadAdmin";
		    	case 5: AdminRank = "HeadAdmin";
    	}
		pInfo[id][Admin] = lvl;
		format(str, sizeof(str), "[INFO]: {FFFFFF}You make %s(%d) as Admin Rank %s | Lvl: %i", GetName(id), id, AdminRank, lvl);
		SendClientMessage(playerid, COLOR_GREEN, str);
		strcat(sho, "{FFFFFF}You got Messages From HeadAdmin:\n\n");
		format(str, sizeof(str), "{15D4ED}Administrator Rank:{FFFF00} %s\n", AdminRank);
		strcat(sho, str, sizeof(sho));
		format(str, sizeof(str), "{15D4ED}Administrator Level:{FFFF00} %i\n", lvl);
		strcat(sho, str, sizeof(sho));
		format(str, sizeof(str), "{15D4ED}Promoted By Admin:{FFFF00} %s\n", GetName(playerid));
		strcat(sho, str, sizeof(sho));
		ShowPlayerDialog(id, 428, DIALOG_STYLE_MSGBOX, "Administrator", sho, "Close", "");
	}
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
	return 1;
}
			
			
CMD:god(playerid, params[])
{
    new str[80];

    if(minigun[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You are in DM can't use commands");
	if(onede[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You are in DM can't use commands");
	if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You are in AFK mode, Can't use any Commands");
 	if(god[playerid] == 0)
  	{
  	    if(pInfo[playerid][Admin] == 1) return SetPlayerArmour(playerid, 100);
	  	god[playerid] = 1;
	  	SetPlayerHealth(playerid, 9999999);
		SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}Your god mode is ON");
		format(str, sizeof(str), "~w~Your god mode is ~g~ENABLE");
		TextDrawSetString(textstring, str);
		TextDrawShowForPlayer(playerid, textstring);
		SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
		PlayerPlaySound(playerid, 1138, 0.0, 0.0, 0.0);
		TextDrawShowForPlayer(playerid, godbox);
		TextDrawShowForPlayer(playerid, god1);
		ResetPlayerWeapons(playerid);
	}
	else
	{
	 	god[playerid] = 0;
	  	SetPlayerHealth(playerid, 100);
	   	SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}Your god mode is OFF");
		format(str, sizeof(str), "~w~Your god mode is ~r~DISABLE");
		TextDrawSetString(textstring, str);
		TextDrawShowForPlayer(playerid, textstring);
		SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
		PlayerPlaySound(playerid, 1137, 0.0, 0.0, 0.0);
		TextDrawHideForPlayer(playerid, godbox);
		TextDrawHideForPlayer(playerid, god1);
  		GivePlayerWeapon(playerid, 5, 1);
    	GivePlayerWeapon(playerid, 24, 99999);
    	GivePlayerWeapon(playerid, 27, 99999);
    	GivePlayerWeapon(playerid, 32, 99999);
    	GivePlayerWeapon(playerid, 31, 99999);
	}
	return 1;
}
CMD:spawn(playerid, params[])
{
    new str[120], id;
	if(IsPlayerInAnyVehicle(playerid)) return RemovePlayerFromVehicle(id);
	if(pInfo[playerid][Admin] > 1)
	{
	    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} /spawn [id]");
	    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} Player not connected!");
		if(afk[playerid] == 1) return afk[playerid] = 0;
		format(str, sizeof(str), "[INFO]: {FFFFFF}Administrator %s has spawned you", GetName(playerid));
		SendClientMessage(playerid, COLOR_GREEN, str);
		DeletePVar(playerid, "InsideHouse");
		SpawnPlayer(id);
	}
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
	return 1;
}

CMD:carmenu(playerid, params[])
{

    if(minigun[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
	if(onede[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
	if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You are in AFK mode, Can't use any Commands");
	if(GetPVarInt(playerid, "InsideHouse")) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You can't spawn cars when in the house");
	ShowPlayerDialog(playerid, carmenu, DIALOG_STYLE_LIST, "vDR: Vehicle","{FFFF00}•{FFFFFF} Bikes\n{FFFF00}•{FFFFFF} Cars 1 [A-E]\n{FFFF00}•{FFFFFF} Cars 2 [F-P]\n{FFFF00}•{FFFFFF} Cars 3 [P-S]\n{FFFF00}•{FFFFFF} Cars 4 [S-Z]\n{FFFF00}•{FFFFFF} Helicopters\n{FFFF00}•{FFFFFF} Planes\n{FFFF00}•{FFFFFF} Boats\n{FFFF00}•{FFFFFF} Trains\n{FFFF00}•{FFFFFF} Trailers\n{FFFF00}•{FFFFFF} RC Vehicles + Vortex", "Select", "Cancel");
	return 1;
}

CMD:v(playerid, params[]) return cmd_carmenu(playerid, params);
CMD:t(playerid, params[]) return cmd_teles(playerid, params);

CMD:givecash(playerid, params[])
{
	new str[128], money, id;
	if(pInfo[playerid][Admin] > 1)
	{
		if(sscanf(params, "ui", id, money)) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} /givecash [playerid] [amount]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} Player not connected!");
		GivePlayerMoney(id, money);
		format(str, sizeof(str), "[INFO]: {FFFFFF}Administrator %s has given you $%d Money", GetName(playerid), money);
		SendClientMessage(id, COLOR_GREEN, str);
		format(str, sizeof(str), "~g~you recived $%d money from admin %s", money, GetName(playerid));
		TextDrawSetString(textstring, str);
		TextDrawShowForPlayer(playerid, textstring);
		SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
	}
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
	return 1;
}

CMD:cmds(playerid, params[])
{
	new str[520];

	strcat(str, "/skin{FFFFFF} - To change your skin\n");
	strcat(str, "/teles{FFFFFF} - to see teleports menu\n");
	strcat(str, "/rules{FFFFFF} - to see server rules\n");
	strcat(str, "/mytime{FFFFFF} - change your times\n");
 	strcat(str, "/pm{FFFFFF} - Send Private Message\n");
  	strcat(str, "/afk{FFFFFF} - Away From Keyboards\n");
   	strcat(str, "/credits{FFFFFF} - to see importan players\n");
	strcat(str, "/help{FFFFFF} - To get started\n");
	strcat(str, "/kill{FFFFFF} - Kill yourself\n");
	strcat(str, "/o{FFFFFF} - Attach Object to your skins\n");
	strcat(str, "/minigames{FFFFFF} - Play Minigun DM Minigames\n");
	strcat(str, "/camera{FFFFFF} - Give a Camera");
    ShowPlayerDialog(playerid, 142, DIALOG_STYLE_MSGBOX, "{FFFFFF}Commands", str, "close", "");
	return 1;
}

CMD:minigames(playerid, params[])
{
	new str[520];

	strcat(str, "/onede{FFFFFF} - Play Deagle DM Minigame\n");
	strcat(str, "/mini{FFFFFF} - Play Minigun DM Minigame\n");
	strcat(str, "/hay{FFFFFF} - Climbing On The Hay\n");
    ShowPlayerDialog(playerid, 142, DIALOG_STYLE_MSGBOX, "{FFFFFF}Commands", str, "close", "");
	return 1;
}

CMD:help(playerid, params[])
{
	new str[240];

	strcat(str, "{FFFF00}• {FFFFFF}Players Commands\n");
	strcat(str, "{FFFF00}• {FFFFFF}Vehicle Commands\n");
    strcat(str, "{FFFF00}• {FFFFFF}House Commands\n");
    strcat(str, "{FFFF00}• {FFFFFF}Teleport Menu\n");
    strcat(str, "{B0B0B0}(?) What i can do in this server?\n");
    ShowPlayerDialog(playerid, 234, DIALOG_STYLE_LIST, "{FF0000}Vision {FFFFFF}Drifting", str, "select", "Close");
    return 1;
}

CMD:akill(playerid, params[])
{
    new str[128], reason[32], id;
	if(pInfo[playerid][Admin] > 1)
	{
	    if(afk[playerid] == 1) return afk[playerid] = 0;
		if(sscanf(params, "us[128]", id, reason)) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} /akill [playerid] [reason]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} Player not connected!");
	    format(str, sizeof(str), "{FFFF00}- AS - {FF0000}%s(%d) has been killed by Administrator %s(%d) {A0A0A0}[Reason: %s]", GetName(id), id, GetName(playerid), playerid, reason);
	    SendClientMessageToAll(COLOR_RED, str);
	    SetPlayerHealth(id, 0);
	}
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
	return 1;
}

CMD:skin(playerid, params[])
{
	new skin;

	if(minigun[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
	if(onede[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
	if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You are in AFK mode, Can't use any Commands");
	if(sscanf(params, "i", skin)) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} /skin <0 - 299>");
	if(skin < 0 || skin > 299) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} Invalid SkinID! < 0 - 299 >");
	SetPlayerSkin(playerid, skin);
	pInfo[playerid][pSkin] = skin;
	format(strg, sizeof(strg), "[INFO] {FFFFFF}Your skin has been changed to Skin ID: %i", skin);
	SendClientMessage(playerid, COLOR_GREEN, strg);
	format(strg, sizeof(strg), "~w~Your skin has been change to skin ID ~y~%i~w~.", skin);
	TextDrawSetString(textstring, strg);
	TextDrawShowForPlayer(playerid, textstring);
	SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
   	return 1;
}

CMD:check(playerid, params[])
{
	new string[240], sho[240], id;
	if(pInfo[playerid][Admin] > 1)
	{
	    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} /check [id]");
	    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} Player not connected!");
		format(string, sizeof(string), "{FFFFFF}Player Name: %s\n", GetName(id));
		strcat(sho, string, sizeof(sho));
		format(string, sizeof(string), "{FFFFFF}Player Money: {00FF00}${FFFFFF}%d\n", GetPlayerMoney(id));
		strcat(sho, string, sizeof(sho));
		format(string, sizeof(string), "{FFFFFF}Player Score: %d\n", GetPlayerScore(playerid));
		strcat(sho, string, sizeof(sho));
		format(string, sizeof(string), "{FFFFFF}Player Weapons: %d", GetPlayerWeapon(id));
		strcat(sho, string, sizeof(sho));
		ShowPlayerDialog(playerid, 23, DIALOG_STYLE_MSGBOX, "Players Information", sho, "Close", "");
	}
	else return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You are not authorized to use this commands");
	return 1;
}
CMD:abrakadabra(playerid, params[])
{
	SendClientMessage(playerid, -1, "hahaha you know the secret commands eh");
	return 1;
}

CMD:kick(playerid, params[])
{
    new str[520], id, reason[32], sho[520],playa;
	if(pInfo[playerid][Admin] > 1)
	{
 		if(sscanf(params, "us[128]", id, reason)) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} /kick [playerid] [reason]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} Player not connected!");
		format(String, sizeof(String),"~r~Kick~n~~w~Player: %s~n~Admin: %s~n~~y~~h~%s",PlayerName(playa),PlayerName(playerid),reason); 
        Kara(String);
	    format(str, sizeof(str), "{FFFF00}- AS - {FF0000}%s(%d) has been kicked by Administrator %s(%d) {A0A0A0}[Reason: %s]", GetName(id), id, GetName(playerid), playerid, reason);
	    SendClientMessageToAll(COLOR_RED, str);
	    strcat(sho, "{FF0000}you have been kicked from server!\n\n");
		format(str, sizeof(str), "{FF0000}Name:{FFFF00} %s\n", GetName(id));
		strcat(sho, str, sizeof(sho));
		format(str, sizeof(str), "{FF0000}Administrator:{FFFF00} %s\n", GetName(playerid));
		strcat(sho, str, sizeof(sho));
		format(str, sizeof(str), "{FF0000}Reason:{FFFF00} %s\n\n", reason);
		strcat(sho, str, sizeof(sho));
		strcat(sho, "{FF0000}Be sure you follow the rules yet");
		ShowPlayerDialog(id, 9999, DIALOG_STYLE_MSGBOX, "{FF0000}You have been Kicked", sho, "Close", "");
		SetTimerEx("DelayKick",1200,0,"i", id);
	}
	else return SendClientMessage(playerid, 0xFFFFFFFF, CANT);
	return 1;
}

CMD:freeze(playerid,params[])
{
    if(pInfo[playerid][Admin] > 1)
    {
        new id;
        if(sscanf(params,"u",id)) return SendClientMessage(playerid,0xFF0000AA,"USAGE: /freeze [playerid]");
        if(!IsPlayerConnected(id)) return SendClientMessage(playerid,0xFF0000AA,"ERROR: Invalid playerid");
        TogglePlayerControllable(id,0);
        SendClientMessage(playerid,0xFF0000AA,"( ! ) You are frozen by an Admin ! ");
    }
    return 1;
}  

CMD:unfreeze(playerid,params[])
{
    if(pInfo[playerid][Admin] > 1)
    {
        new id;
        if(sscanf(params,"u",id)) return SendClientMessage(playerid,0xFF0000AA,"USAGE: /freeze [playerid]");
        if(!IsPlayerConnected(id)) return SendClientMessage(playerid,0xFF0000AA,"ERROR: Invalid playerid");
        TogglePlayerControllable(id,1);
        SendClientMessage(playerid,0xFF0000AA,"( ! ) You are unfreezed by an Admin ! ");
    }
    return 1;
}  

CMD:respawn(playerid, params[])
{
	if(pInfo[playerid][Admin] > 1)
	{
	    new str[126];
		RespawnVehicles();
		format(str, sizeof(str), "* {15D4ED}Administrator {FFFFFF}%s {15D4ED}Respawn all vehicles", GetName(playerid));
	    SendClientMessageToAll(COLOR_RED, str);
	}
	else return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You not authorized to use this commands");
	return 1;
}

CMD:teles(playerid, params[])
{

    if(minigun[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
	if(onede[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
    if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You are not In AFK mode can't use any commands");
    if(GetPVarInt(playerid, "InsideHouse")) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You can't use commands when in the house");
   	ShowPlayerDialog(playerid, TELE_DIALOG, DIALOG_STYLE_LIST, "Teles", "{FFFF00}•{FFFFFF} Los Santos\n{FFFF00}•{FFFFFF} San Fierro\n{FFFF00}•{FFFFFF} Las Venturas", "Select", "Cancel"); // Munculin DIalog
    return 1;
}

CMD:countdown(playerid,params[])
{

	if(pInfo[playerid][Admin] >= 2 || pInfo[playerid][VIPlevel] >= 1)
	{
	    if(minigun[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
		if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You are not In AFK mode can't use any commands");
 		if(count == 0)
	   	{
	   	    new str[126];
	        SetTimer("Counting",1000,false);
	        format(str, sizeof(str), "* {15D4ED}Administrator {FFFFFF}%s {15D4ED}has started Countdown", GetName(playerid));
	        SendClientMessageToAll(COLOR_RED, str);
	        count = 1;
	    }
		else
		{
        	SendClientMessage(playerid, 0xFF0000FF,"Countdown already started!");
 		}
	}
	else return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You are not authorized to use this commands");
   	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(newkeys & KEY_JUMP)
	{
		if(superman[playerid] == 1)
		{
			new Float:SuperJump[3];
			GetPlayerVelocity(playerid, SuperJump[0], SuperJump[1], SuperJump[2]);
			SetPlayerVelocity(playerid, SuperJump[0], SuperJump[1], SuperJump[2]+5);
		}
	}
	if (IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
 	{
		if (newkeys & KEY_CROUCH)
        {
        	new Float:vx,Float:vy,Float:vz;
        	GetVehicleVelocity(GetPlayerVehicleID(playerid),vx,vy,vz);
        	SetVehicleVelocity(GetPlayerVehicleID(playerid), vx * 1.5, vy *1.5, vz * 1.5);
        }
   	    if (newkeys & KEY_SUBMISSION)
	    {
     		new currentveh;
        	new Float:angle;
        	new str[80];
        	currentveh = GetPlayerVehicleID(playerid);
        	GetVehicleZAngle(currentveh, angle);
        	SetVehicleZAngle(currentveh, angle);
        	RepairVehicle(GetPlayerVehicleID(playerid));
			SetVehicleHealth(GetPlayerVehicleID(playerid), 1000.0);
			format(str, sizeof(str), "~w~Your vehicle has been flipped");
			TextDrawSetString(textstring, str);
			TextDrawShowForPlayer(playerid, textstring);
			SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
		}
	}
    return 1;
}

forward ban(playerid);
public ban(playerid)
{
    Ban(playerid);
	return 1;
}

forward kick(playerid);
public kick(playerid)
{
    Kick(playerid);
	return 1;
}

forward HideTextdraw(playerid);

public HideTextdraw(playerid)
{
	TextDrawHideForPlayer(playerid, carname);
	TextDrawHideForPlayer(playerid, textstring);
}

public Counting(playerid)
{
	count = 1;
 	GameTextForAll("~y~3",1000,6);
    PlayerPlaySound(playerid, 1056,0,0,0);
   	SetTimer("Counting2",1000,false);
    return 1;
}
public Counting2(playerid)
{
	count = 1;
 	GameTextForAll("~g~2",1000,6);
    PlayerPlaySound(playerid, 1056,0,0,0);
    SetTimer("Counting1",1000,false);
   	return 1;
}
public Counting1(playerid)
{
	count = 1;
	GameTextForAll("~b~1",1000,6);
    PlayerPlaySound(playerid, 1056,0,0,0);
    SetTimer("CountingGO",1000,false);
    return 1;
}
public CountingGO(playerid)
{
	count = 0;
    PlayerPlaySound(playerid, 1057,0,0,0);
    GameTextForAll("~r~GO!!!",1000,6);
    return 1;
}

CMD:rules(playerid, params[])
{
	new str[520];

	if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You are not In AFK mode can't use any commands");
	strcat(str, "{FF0000}Vision Drifting Rules:\n\n");
	strcat(str, "{FFFFFF}- Do not shout hackers name on main chat, /report!\n");
	strcat(str, "{FFFFFF}- Do not Advertise other server in the server, You will get banned by the Anti-Cheat\n");
	strcat(str, "{FFFFFF}- Stop asking for promotion or for being admin/vip\n");
	strcat(str, "{FFFFFF}- Do not spam on the chat or in the PM!\n");
	strcat(str, "{FFFFFF}- Hacks/Cheats is not allowed else, Banned or Warn or Kick!\n");
	strcat(str, "{FFFFFF}- Using Mods is allowed, But abusing it will cause you banned or warn or kick!\n\n");
	strcat(str, "{FFFF00}> FOLLOW THE RULES ELSE MIGHT GET PUNISHMENT FROM ADMINISTRATOR OR VIPS");
	ShowPlayerDialog(playerid, 2, DIALOG_STYLE_MSGBOX, "vDR Rules", str, ".: OK :.", "");
	return 1;
}

CMD:get(playerid, params[])
{
	new str[128], id;

	if(minigun[id] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}That Player are in DM");
	if(onede[id] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}That Player are in DM");
	if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You are not In AFK mode can't use any commands");
	if(pInfo[playerid][Admin] > 1)
	{
		if(sscanf(params, "u", id)) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} /get [playerid]");
	    if(id == playerid) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You cannot get yourself");
	    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} Player not connected!");
        if(afk[id] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} That player are in AFK");
        DeletePVar(playerid, "InsideHouse");
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		SetPlayerInterior(id, GetPlayerInterior(playerid));
		SetPlayerVirtualWorld(id, GetPlayerVirtualWorld(playerid));
		if(GetPlayerState(id) == 2)
		{
   			new VehicleID = GetPlayerVehicleID(id);
			SetVehiclePos(VehicleID, x+3, y, z);
			LinkVehicleToInterior(VehicleID, GetPlayerInterior(playerid));
			SetVehicleVirtualWorld(GetPlayerVehicleID(id), GetPlayerVirtualWorld(playerid));
		}
		else SetPlayerPos(id, x+2, y, z);
		format(str, sizeof(str), "[INFO]: {FFFFFF}You've been teleported to Administrator %s(%d) position", GetName(playerid), playerid);
		SendClientMessage(id, COLOR_GREEN, str);
		format(str, sizeof(str), "[INFO]:{FFFFFF} You have teleport %s(%d) to your position", GetName(id), id);
		SendClientMessage(playerid, COLOR_GREEN, str);
	}
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
	return 1;
}

CMD:goto(playerid, params[])
{
	new str[128], id;
	if(minigun[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
	if(onede[id] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}That Player are in DM");
	if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You are not In AFK mode can't use any commands");
 	if(pInfo[playerid][Admin] > 1)
	{
		if(sscanf(params, "u", id)) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} /goto [playerid]");
	    if(id == playerid) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You cannot goto yourself");
	    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} Player not connected!");
    	new Float:x, Float:y, Float:z;
		GetPlayerPos(id, x, y, z);
		format(str, sizeof(str), "[INFO]:{FFFFFF} You have teleported to %s(%d) position!", GetName(id), id);
		SendClientMessage(playerid, COLOR_GREEN, str);
		format(str, sizeof(str), "[INFO]:{FFFFFF} Administrator %s(%d) has teleport to your position!", GetName(playerid), playerid);
		SendClientMessage(id, COLOR_GREEN, str);
		SetPlayerInterior(playerid, GetPlayerInterior(id));
		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(id));
		if(GetPlayerState(playerid) == 2)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), x+3, y, z);
			LinkVehicleToInterior(GetPlayerVehicleID(playerid), GetPlayerInterior(id));
			SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), GetPlayerVirtualWorld(id));
		}
		else SetPlayerPos(playerid, x+2, y, z);
	}
	else return SendClientMessage(playerid, COLOR_GREEN, CANT);
	return 1;
}

CMD:mytime(playerid, params[])
{
	new time, str[128];

	if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You are not In AFK mode can't use any commands");
	if(sscanf(params, "i", time)) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} /time [0 - 23]");
	if(time < 0 || time > 23) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} Invalid Time [0 - 23]");
	format(strg, sizeof(strg), "[INFO]:{FFFFFF} You changed your time to{FFFF00} ''%02d:00''", time);
	SendClientMessage(playerid, COLOR_WHITE, strg);
	SetPlayerTime(playerid, time, 0);
	format(str, sizeof(str), "~w~You have been set your time to ~y~%d~w~.", time);
	TextDrawSetString(textstring, str);
	TextDrawShowForPlayer(playerid, textstring);
	SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
	return 1;
}

CMD:pm(playerid, params[])
{
	new id, str[120];

	if(sscanf(params, "us[128]", id, params)) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} /pm <id> <message>");
	if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}That player are not connected");
	format(strg, sizeof(strg), "* {15D4ED}PM sent to{FFFFFF} %s(%d):{15D4ED} %s", GetName(id), id, params);
	SendClientMessage(playerid, COLOR_RED, strg);
	PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
	format(strg, sizeof(strg), "* {15D4ED}PM From {FFFFFF}%s(%d):{15D4ED} %s", GetName(playerid), playerid, params);
	SendClientMessage(id, COLOR_RED, strg);
	PlayerPlaySound(id, 1085, 0.0, 0.0, 0.0);
	
	format(str, sizeof(str), "~w~You have a new Private Message From ~y~%s~w~.", GetName(playerid));
	TextDrawSetString(textstring, str);
	TextDrawShowForPlayer(id, textstring);
	SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
	
	format(str, sizeof(str), "~w~Your Private Message Sent to ~y~%s~w~.", GetName(id));
	TextDrawSetString(textstring, str);
	TextDrawShowForPlayer(playerid, textstring);
	SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
	return 1;
}

CMD:tune(playerid, params[])
{
	if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You are not In AFK mode can't use any commands");
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		CarmodDialog(playerid);
		return 1;
	}
	else SendClientMessage(playerid, COLOR_WHITE, "[INFO]:{15D4ED} You must be in a vehicle to open this dialog!");
	return 1;
}

CMD:afk(playerid, params[])
{
    new str[120];
    if(minigun[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
	if(onede[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFFFF}You can't use commands while in DM");
	if(afk[playerid] == 0)
	{
	    if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_WHITE, "[INFO]: {15D4ED}You can't AFK in any cars");
	    SetPlayerHealth(playerid, 999999);
		TogglePlayerControllable(playerid, 0);
		format(str, sizeof(str), "[AFK]: {15D4ED}Players {FFFFFF}%s {15D4ED}is now away from keyboard.", GetName(playerid));
		SendClientMessageToAll(COLOR_WHITE, str);
		SetPVarInt(playerid, "afk", 1);
		afk[playerid] = 1;
		format(str, sizeof(str), "~w~You are in ~b~AFK Mode~w~. Type /afk again to Back");
		TextDrawSetString(textstring, str);
		TextDrawShowForPlayer(playerid, textstring);
		PlayerPlaySound(playerid, 1185, 0.0, 0.0, 0.0);
	}
	else
	{
 		SetPlayerHealth(playerid, 100);
		TogglePlayerControllable(playerid, 1);
		format(str, sizeof(str), "[AFK]: {15D4ED}Players {FFFFFF}%s {15D4ED}is now back.", GetName(playerid));
		SendClientMessageToAll(COLOR_WHITE, str);
		DeletePVar(playerid, "afk");
		afk[playerid] = 0;
		TextDrawHideForPlayer(playerid, textstring);
		PlayerPlaySound(playerid, 1186, 0.0, 0.0, 0.0);
	}
	return 1;
}

CMD:credits(playerid, params[])
{
	new str[520];
	if(afk[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}»{FFFF00} You are not In AFK mode can't use any commands");
	strcat(str, "{FFFFFF}Server Developer: {FFFF00}swredder\n");
	strcat(str, "{FFFFFF}Server Mappers: {FFFF00}Dawidoskyy\n");
	strcat(str, "{FFFFFF}Continued: {FFFF00}Dawidoskyy\n");
	strcat(str, "{FFFFFF}Hard Script: {FFFF00}Dawidoskyy\n");
	ShowPlayerDialog(playerid, 55, DIALOG_STYLE_MSGBOX, "Vision Drifting", str, ".: OK :.", "");
	return 1;
}
	
public OnPlayerDeath(playerid, killerid, reason)
{
	god[playerid] = 0;
    SendDeathMessage(killerid, playerid, reason); // Sends Death Message to evryone in server.
	TextDrawHideForPlayer(playerid,HAYTD[playerid]);
    JoinedHay[playerid] = 0;
	pInfo[killerid][Kills]++;
	format(strg, sizeof(strg), "~w~Wonderful!. you got ~g~$2000~w~ and ~y~+1~w~Scores");
	TextDrawSetString(textstring, strg);
	TextDrawShowForPlayer(killerid, textstring);
	GivePlayerMoney(killerid, 2000);
	SetPlayerScore(killerid, GetPlayerScore(killerid) + 1);
	SetTimerEx("HideTextdraw", 3000, false, "i", killerid);
	TextDrawHideForPlayer(playerid, godbox);
	TextDrawHideForPlayer(playerid, god1);
	GameTextForPlayer(playerid, "Clucky Clucky Fucked", 3000, 3);
    pInfo[playerid][Deaths]++;
	
	if(IsBeingSpeced[playerid] == 1)//If the player being spectated, dies, then turn off the spec mode for the spectator.
    {
        foreach(Player,i)
        {
            if(spectatorid[i] == playerid)
            {
                TogglePlayerSpectating(i,false);// This justifies what's above, if it's not off then you'll be either spectating your connect screen, or somewhere in blueberry (I don't know why)
            }
        }
    }
	return 1;
}

public OnVehicleDeath(vehicleid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)//This is called when a player's interior is changed.
{
    if(IsBeingSpeced[playerid] == 1)//If the player being spectated, changes an interior, then update the interior and virtualword for the spectator.
    {
        foreach(Player,i)
        {
            if(spectatorid[i] == playerid)
            {
                SetPlayerInterior(i,GetPlayerInterior(playerid));
                SetPlayerVirtualWorld(i,GetPlayerVirtualWorld(playerid));
            }
        }
    }
    return 1;
}

// This callback gets called when the player changes state
public OnPlayerStateChange(playerid,newstate,oldstate)
{
	TextDrawHideForPlayer(playerid, box[playerid]);
	KillTimer(stimer[playerid]); // This Stops Our Timer For When You Get Out Of Your Vehicle Your Speed Doesn't Keep Going
	TextDrawSetString(speedo[playerid], " "); // This Sets Our Textdraw To Blank And Freezes Because We Stop The Timer ^
	if(newstate == 2) stimer[playerid] = SetTimerEx("speedometer", 255, true, "i", playerid); // This Starts The Timer When The Player Changes His/Her State To Being The Driver
	
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)// If the player's state changes to a vehicle state we'll have to spec the vehicle.
    {
        if(IsBeingSpeced[playerid] == 1)//If the player being spectated, enters a vehicle, then let the spectator spectate the vehicle.
        {
            foreach(Player,i)
            {
                if(spectatorid[i] == playerid)
                {
                    PlayerSpectateVehicle(i, GetPlayerVehicleID(playerid));// Letting the spectator, spectate the vehicle of the player being spectated (I hope you understand this xD)
                }
            }
        }
    }
	if(newstate == PLAYER_STATE_ONFOOT)
    {
        if(IsBeingSpeced[playerid] == 1)//If the player being spectated, exists a vehicle, then let the spectator spectate the player.
        {
            foreach(Player,i)
            {
                if(spectatorid[i] == playerid)
                {
                    PlayerSpectatePlayer(i, playerid);// Letting the spectator, spectate the player who exited the vehicle.
                }
            }
        }
    }
    return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	new string[128];
	format(string, sizeof(string), "%s", GetVehicleName(vehicleid));
	TextDrawSetString(carname, string);
	TextDrawShowForPlayer(playerid, carname);
	SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
 	return 1;
}
public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
    new textString[120], pName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pName, sizeof(pName));
    format(textString, sizeof(textString), "{%06x}%s {BABABA}(%d): {FFFFFF}%s", (GetPlayerColor(playerid) >>> 8), pName, playerid, text);
    SendClientMessageToAll(-1, textString);
    SetPlayerChatBubble(playerid, text, COLOR_WHITE, 50.0, 1000*10);
   	switch(xTestBusy)
 	{
  		case true:
  		{
  			if(!strcmp(xChars, text, false))
     		{
       			new string[128];
          		format(string, sizeof(string), "{E65555}[REACTION]{%06x} %s(%d) {15D4ED}has won the reaction test for phrase {FFFF00}'%s'",(GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid, xChars);
          		SendClientMessageToAll(GREEN, string);
   				format(string, sizeof(string), "~w~Win reaction test! you got ~g~$%d~w~ and ~y~%d~w~ Score", xCash, xScore);
				TextDrawSetString(textstring, string);
				TextDrawShowForPlayer(playerid, textstring);
				SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
          		GivePlayerMoney(playerid, xCash);
          		SetPlayerScore(playerid, GetPlayerScore(playerid) + xScore);
          		xReactionTimer = SetTimer("xReactionTest", TIME, 1);
          		xTestBusy = false;
            }
       	}
	}
	return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
        new str[520];
		if(dialogid == dregister)
		{
		    if(!response) return Kick(playerid);
			if(response) 
			{
				if(!strlen(inputtext))
				{
			   		ShowPlayerDialog(playerid,dregister,DIALOG_STYLE_INPUT,"Register","Welcome! This account is not registered.\nEnter your own password to create a new account.\nPlease enter the password!","Register","Quit");
					return 1;
				}
				new hashpass[129];
	            WP_Hash(hashpass,sizeof(hashpass),inputtext);
	            new INI:file = INI_Open(Path(playerid));
	            INI_SetTag(file,"Player's Data");
				INI_WriteString(file,"Password",hashpass);
	            INI_WriteInt(file,"AdminLevel",0); 
				INI_WriteInt(file,"VIPLevel",0);
				INI_WriteInt(file,"Money",0);
				INI_WriteInt(file,"Scores",0);
				INI_WriteInt(file,"Kills",0);
				INI_WriteInt(file,"Deaths",0);
				INI_Close(file);
				pInfo[playerid][pSkin] = -1;
				format(str, sizeof(str), "~w~Welcome to vDR, ~r~%s", GetName(playerid));
				TextDrawSetString(textstring, str);
				TextDrawShowForPlayer(playerid, textstring);
				SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
				SendClientMessage(playerid,-1,"You have been successfully registered");
				strcat(str, "{FF0000}Vision Drifting Rules:\n\n");
				strcat(str, "{FFFFFF}- Do not shout hackers name on main chat, /report!\n");
				strcat(str, "{FFFFFF}- Do not Advertise other server in the server, You will get banned by the Anti-Cheat\n");
				strcat(str, "{FFFFFF}- Stop asking for promotion or for being admin/vip\n");
				strcat(str, "{FFFFFF}- Do not spam on the chat or in the PM!\n");
				strcat(str, "{FFFFFF}- Hacks/Cheats is not allowed else, Banned or Warn or Kick!\n");
				strcat(str, "{FFFFFF}- Using Mods is allowed, But abusing it will cause you banned or warn or kick!\n\n");
				strcat(str, "{FFFF00}> FOLLOW THE RULES ELSE MIGHT GET PUNISHMENT FROM ADMINISTRATOR OR VIPS");
				ShowPlayerDialog(playerid, 2, DIALOG_STYLE_MSGBOX, "Vision Drifting Rules", str, ".: OK :.", "");
				return 1;
			}
		}
		if(dialogid == dlogin) 
		{
		    if(!response) return Kick(playerid); 
			if(response)
			{
				new hashpass[129]; 
				WP_Hash(hashpass,sizeof(hashpass),inputtext); 
				if(!strcmp(hashpass, pInfo[playerid][Pass], false)) 
				{
	                INI_ParseFile(Path(playerid),"loadaccount_%s",.bExtra = true, .extra = playerid);
					SetPlayerScore(playerid,pInfo[playerid][Scores]);
					GivePlayerMoney(playerid,pInfo[playerid][Money]);
                    SetPlayerColor(playerid, pInfo[playerid][pColor]);
    				format(strg, sizeof(strg), "{FF0000}*** {87CEFA}Welcome back {FFFFFF}%s{87CEFA}, you have sucessfully logged in!", GetName(playerid));
				    SendClientMessage(playerid, COLOR_RED, strg);
					strcat(str, "{FF0000}Vision Drifting Rules:\n\n");
					strcat(str, "{FFFFFF}- Do not shout hackers name on main chat, /report!\n");
					strcat(str, "{FFFFFF}- Do not Advertise other server in the server, You will get banned by the Anti-Cheat\n");
					strcat(str, "{FFFFFF}- Stop asking for promotion or for being admin/vip\n");
					strcat(str, "{FFFFFF}- Do not spam on the chat or in the PM!\n");
					strcat(str, "{FFFFFF}- Hacks/Cheats is not allowed else, Banned or Warn or Kick!\n");
					strcat(str, "{FFFFFF}- Using Mods is allowed, But abusing it will cause you banned or warn or kick!\n\n");
					strcat(str, "{FFFF00}> FOLLOW THE RULES ELSE MIGHT GET PUNISHMENT FROM ADMINISTRATOR OR VIPS");
					ShowPlayerDialog(playerid, 2, DIALOG_STYLE_MSGBOX, "Vision Drifting Rules", str, ".: OK :.", "");
					format(str, sizeof(str), "~w~Welcome Back, ~r~%s~w~.", GetName(playerid));
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 6000, false, "i", playerid);
				}
				else
				{
					new id;
					format(str, sizeof(str), "{FF0000}Name:{FFFFFF} %s\n", GetName(playerid));
					strcat(str, "{FF0000}Reason:{FFFFFF} Failed To Login\n\n");
					strcat(str, "{FFFFFF}if you forget your password you can contact Administrator");
					ShowPlayerDialog(id, 9999, DIALOG_STYLE_MSGBOX, "{FF0000}You have been Kicked", str, "Close", "");
					SetTimerEx("DelayKick",1200,0,"i", id);
	                return 1;
				}
			}
		}
		if(dialogid == TELE_DIALOG)
  		{
   			if(response)
     		{
				if(listitem == 0) 
   				{
      				ShowPlayerDialog(playerid, TELE_DIALOG+1, DIALOG_STYLE_LIST, "{FF0000}Los Santos", "{FF0000}Los Santos Airport \nSanta Marina \nGrove Street \nCity Hall \nPolice Station \nBank \nOcean Docks \nCrazybob's House \nJefferson Motel \nBack", "Select", "Cancel");
         		}
          		if(listitem == 1) 
           		{
            		ShowPlayerDialog(playerid, TELE_DIALOG+2, DIALOG_STYLE_LIST, "{00FF00}San Fierro", "{00FF00}San Fierro Airport \nCity Hall \nBank \nOcean Flats \nMissionary Hill \nJizzys Pleasure Dome \nPolice Station  \nBack", "Select", "Cancel");
            	}
           		if(listitem == 2) 
            	{
          			ShowPlayerDialog(playerid, TELE_DIALOG+3, DIALOG_STYLE_LIST, "{0000FF}Las Venturas", "{0000FF}Las Venturas Airport \nArea69 \nCity Hall \nPolice Station \nCaligulas Casino \nStarfish Casino \nBank \nPrickle Pine \nBandit Stadium \nLast Dime Motelf\nBack", "Select", "Cancel");
            	}
        	}
		}
        if(dialogid == TELE_DIALOG+1)
        {
        	if(response)
         	{
          		if(listitem == 0)
            	{
           			SetPlayerInterior(playerid, 0);
              		SetPlayerPos(playerid, 1934.8811,-2305.5283,13.5469);
              		PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
      				format(str, sizeof(str), "~y~Welcome to ~w~Los santos Airport");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to {FF0000}Los Santos Airport.");
                }
               	if(listitem == 1)
                {
                 	SetPlayerInterior(playerid, 0);
                  	SetPlayerPos(playerid, 433.1179,-1796.5649,5.5469);
                  	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
 					format(str, sizeof(str), "~y~Welcome to ~w~Santa Marina Beach");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                   	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to Santa Marina Beach.");
       			}
          		if(listitem == 2)
            	{
             		SetPlayerInterior(playerid, 0);
               		SetPlayerPos(playerid, 2499.8733,-1667.6309,13.3512);
               		PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
               		format(str, sizeof(str), "~y~Welcome to ~w~Groove street");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                 	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to Grove Street.");
             	}
              	if(listitem == 3)
               	{
                	SetPlayerInterior(playerid, 0);
                 	SetPlayerPos(playerid, 1461.0043,-1019.4626,24.6975);
                 	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
                	format(str, sizeof(str), "~y~Welcome to ~w~Los santos City Hall");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                  	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to {FF0000}Los Santos City Hall.");
                }
                if(listitem == 4)
                {
                	SetPlayerPos(playerid, 1544.8700,-1675.8081,13.5593);
                 	SetPlayerFacingAngle(playerid, 90);
                 	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
 					format(str, sizeof(str), "~y~Welcome to ~w~Los Santos Police Department");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                  	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to {FF0000}Los Santos Police Department.");
                }
               	if(listitem == 5)
               	{
                	SetPlayerInterior(playerid, 0);
                 	SetPlayerPos(playerid, 595.1895,-1243.1205,18.0844);
                 	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
 					format(str, sizeof(str), "~y~Welcome to ~w~Los santos Bank");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                  	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to {FF0000}Los Santos Bank.");
               	}
                if(listitem == 6) 
                {
                	SetPlayerInterior(playerid, 0);
                 	SetPlayerPos(playerid, 2791.1782,-2534.6309,13.6303);
                 	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
 					format(str, sizeof(str), "~y~Welcome to ~w~Ocean Docks");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                  	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to Ocean Docks.");
                }
                if(listitem == 7)
                {
                	SetPlayerInterior(playerid, 0);
                	SetPlayerPos(playerid, 1255.2925,-778.2413,92.0302);
                	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
 					format(str, sizeof(str), "~y~Welcome to ~w~Crazybob's House");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to Crazybob's House.");
                }
                if(listitem == 8)
                {
                	SetPlayerInterior(playerid, 0);
                 	SetPlayerPos(playerid, 2229.0200,-1159.8000,25.7981);
                 	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
 					format(str, sizeof(str), "~y~Welcome to ~w~Jefferson Motel");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                  	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to Jefferson Motel.");
                }
                if(listitem == 9)
                {
                	ShowPlayerDialog(playerid, TELE_DIALOG, DIALOG_STYLE_LIST, "Teleport Categories", "{FF0000}Los Santos\n{00FF00}San Fierro\n{0000FF}Las Venturas", "Select", "Cancel");
                }
			}
        }
        if(dialogid == TELE_DIALOG+2)
        {
        	if(response)
         	{
          		if(listitem == 0)
            	{
             		SetPlayerInterior(playerid, 0);
               		SetPlayerPos(playerid, -1315.9419,-223.8595,14.1484);
               		PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
      				format(str, sizeof(str), "~y~Welcome to ~w~San Fierro Airport");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                 	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to {00FF00}San Fierro Airport.");
             	}
              	if(listitem == 1) 
               	{
                	SetPlayerInterior(playerid, 0);
                 	SetPlayerPos(playerid, -2672.6116,1268.4943,55.9456);
                 	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
 					format(str, sizeof(str), "~y~Welcome to ~w~San Fierro City Hall");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                  	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to {00FF00}San Fierro City Hall.");
                }
                if(listitem == 2) 
                {
                	SetPlayerInterior(playerid, 0);
                 	SetPlayerPos(playerid, -2050.6089,459.3649,35.1719);
                 	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
 					format(str, sizeof(str), "~y~Welcome to ~w~San Fierro Bank");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                  	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to {00FF00}San Fierro Bank.");
                }
                if(listitem == 3) 
                {
                	SetPlayerInterior(playerid, 0);
                	SetPlayerPos(playerid, -2670.1101,-4.9832,6.1328);
                	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
 					format(str, sizeof(str), "~y~Welcome to ~w~Ocean Flats");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to Ocean Flats.");
                }
                if(listitem == 4) 
                {
                	SetPlayerInterior(playerid, 0);
                	SetPlayerPos(playerid, -2515.6768,-611.6651,132.5625);
                	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
 					format(str, sizeof(str), "~y~Welcome to ~w~Missionnary Hill");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to Missionary Hill.");
                }
                if(listitem == 5) 
                {
                	SetPlayerInterior(playerid, 0);
                	SetPlayerPos(playerid, -2621.0244,1403.7534,7.0938);
                	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
 					format(str, sizeof(str), "~y~Welcome to ~w~Jizzy's Pleasure Dome");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to Jizzy's Pleasure Dome.");
                }
                if(listitem == 6) 
                {
                	SetPlayerInterior(playerid, 0);
                	SetPlayerPos(playerid, -1608.1376,718.9722,12.4356);
                	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
 					format(str, sizeof(str), "~y~Welcome to ~w~San Fierro Police Department");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to {00FF00}San Fierro Police Station.");
                }
                if(listitem == 7) 
                {
                	ShowPlayerDialog(playerid, TELE_DIALOG, DIALOG_STYLE_LIST, "Teleport Categories", "{FF0000}Los Santos\n{00FF00}San Fierro\n{0000FF}Las Venturas", "Select", "Cancel");
                }
			}
        }
        if(dialogid == TELE_DIALOG+3) 
        {
        	if(response)
         	{
          		if(listitem == 0)
          		{
            		SetPlayerInterior(playerid, 0);
            		SetPlayerPos(playerid, 1487.9703,1736.9537,10.8125);
            		PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
      				format(str, sizeof(str), "~y~Welcome to ~w~Las Venturas Airport");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
            		SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to {0000FF}Las Venturas Airport.");
          		}
            	if(listitem == 1)
             	{
              		SetPlayerPos(playerid, 129.3000, 1920.3000, 20.0);
              		PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
 					format(str, sizeof(str), "~y~Welcome to ~w~Area 69");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
  		          	GameTextForPlayer(playerid,"~W~Welcome to ~G~Area 69~W~!",1000,0);
		            SetPlayerInterior(playerid,0);
              	}
               	if(listitem == 2)
                {
                	SetPlayerPos(playerid, 2421.7185,1121.9866,10.8125);
   		          	SetPlayerFacingAngle(playerid, 90);
   		          	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
 					format(str, sizeof(str), "~y~Welcome to ~w~Las Venturas City Hall");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to {0000FF}Las Venturas City Hall.");
                }
                if(listitem == 3)
                {
                	SetPlayerInterior(playerid, 0);
                	SetPlayerPos(playerid, 2287.2561,2426.2576,10.8203);
                	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
					format(str, sizeof(str), "~y~Welcome to ~w~Las Venturas Police Department");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to {0000FF}Las Venturas Police Station.");
                }
                if(listitem == 4)
                {
                	SetPlayerPos(playerid, 2187.8350,1678.5358,11.1094);
                	SetPlayerFacingAngle(playerid, 90);
                	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
  					format(str, sizeof(str), "~y~Welcome to ~w~Caligulas Casino");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to Caligulas Casino.");
                }
                if(listitem == 5) 
                {
                	SetPlayerInterior(playerid, 0);
                	SetPlayerPos(playerid, 2227.3596,1894.3228,10.6719);
                	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
 					format(str, sizeof(str), "~y~Welcome to ~w~Starfish Casino");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to Starfish Casino.");
                }
                if(listitem == 6)
                {
                	SetPlayerInterior(playerid, 0);
                	SetPlayerPos(playerid, 2463.6680,2240.7524,10.8203);
                	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
 					format(str, sizeof(str), "~y~Welcome to ~w~Las Venturas Bank");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to {0000FF}Las Venturas Bank.");
                }
                if(listitem == 7) 
                {
                	SetPlayerInterior(playerid, 0);
                	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
                	SetPlayerPos(playerid, 1434.6989,2654.4026,11.3926);
 					format(str, sizeof(str), "~y~Welcome to ~w~Prickle Pine");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to Prickle Pine.");
                }
                if(listitem == 8) 
                {
                	SetPlayerInterior(playerid, 0);
                	SetPlayerPos(playerid, 1493.2443,2238.1526,11.0291);
                	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
 					format(str, sizeof(str), "~y~Welcome to ~w~Bandit Stadium");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to Bandit Stadium.");
                }
                if(listitem == 9) 
                {
                	SetPlayerInterior(playerid, 0);
                	PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0);
                	SetPlayerPos(playerid, 1929.0522,707.8507,10.8203);
  					format(str, sizeof(str), "~y~Welcome to ~w~Last Dime Hotel");
					TextDrawSetString(textstring, str);
					TextDrawShowForPlayer(playerid, textstring);
					SetTimerEx("HideTextdraw", 3000, false, "i", playerid);
                	SendClientMessage(playerid, COLOR_GREEN, "[INFO] {FFFFFF}You have been teleported to Last Dime Motel.");
                }
                if(listitem == 10) 
                {
              		ShowPlayerDialog(playerid, TELE_DIALOG, DIALOG_STYLE_LIST, "Teleport Categories", "{FF0000}Los Santos\n{00FF00}San Fierro\n{0000FF}Las Venturas", "Select", "Cancel");
                }
			}
	}
    new vehid = GetPlayerVehicleID(playerid);
    new vehmd = GetVehicleModel(GetPlayerVehicleID(playerid));
    if(dialogid == 1111 && response)
	{
		switch(listitem)
		{
			case 0: AddVehicleComponent(vehid,1010),CarmodDialog(playerid), PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
			case 1: ShowPlayerDialog(playerid,1112,DIALOG_STYLE_LIST,"Choose primary color:","White\nBlack\nOrange\nLight Blue\nDark Blue\nPurple\nRed\nDark Red\nGrey","Ok","Cancle");
			case 2: ShowPlayerDialog(playerid,1113,DIALOG_STYLE_LIST,"Choose a wheel:","Shadow\nMega\nRimshine\nWires\nClassic\nTwist\nCutter\nSwitch\nGrove\nImport\nDollar\nTrance\nAtomic\nAhab\nVirtual\nAcces\n{FF0000}Back","Ok","Cancle");
			case 3: AddVehicleComponent(vehid, 1086), PlayerPlaySound(playerid,1133,0.0,0.0,0.0),CarmodDialog(playerid);
			case 4: AddVehicleComponent(vehid, 1087), PlayerPlaySound(playerid,1133,0.0,0.0,0.0),CarmodDialog(playerid);
			case 5:
			{
				if(vehmd == 562 || vehmd == 565 || vehmd == 559 || vehmd == 561 || vehmd == 560 || vehmd == 558)
				{
					ShowPlayerDialog(playerid,1114,DIALOG_STYLE_LIST,"Choose one","Paintjob\nAlien\nX-Flow\n{FF0000}Back","Select","Cancel");
				}
				else if(vehmd == 576 || vehmd == 575 || vehmd == 535)
				{
					ShowPlayerDialog(playerid,1001,DIALOG_STYLE_LIST,"Choose one","Paintjob\nChrome\nSlamin\n{FF0000}Back","Select","Cancel");
    			}
				else if(vehmd == 567 || vehmd == 536)
				{
                    ShowPlayerDialog(playerid,1002,DIALOG_STYLE_LIST,"Choose one","Paintjob\nChrome\nSlamin\nHardtop Roof\nSofttop Roof\n{FF0000}Back","Select","Cancel");
				}
				else if(vehmd == 534)
				{
                    ShowPlayerDialog(playerid,1003,DIALOG_STYLE_LIST,"Choose one","Paintjob\nChrome\nSlamin\nFlame Sideskirt \nArches Sideskirt Roof\n{FF0000}Back","Select","Cancel");
				}
				else if(vehmd == 496 || vehmd == 505 || vehmd == 516 || vehmd == 517 || vehmd == 518 || vehmd == 527 || vehmd == 529 || vehmd == 540 || vehmd == 546 || vehmd == 547 || vehmd == 549 || vehmd == 550 || vehmd == 551 || vehmd == 580 || vehmd == 585 || vehmd == 587 || vehmd == 589 || vehmd == 600 || vehmd == 603 || vehmd == 401 || vehmd == 410 || vehmd == 415 || vehmd == 418 || vehmd == 420 || vehmd == 436 || vehmd == 439 || vehmd == 458 || vehmd == 489 || vehmd == 491 || vehmd == 492)
				{
					RegularCarDialog(playerid);
				}
				else
				{
					SendClientMessage(playerid, COLOR_RED,"Your car cannot be tuned!");
				}
			}
		}
	}
	if(dialogid == 1112 && response)
	{
		new color1, color2;
		GetVehicleColor(vehid,color1,color2);
	    new Carray[] = {1,0,6,2,79,149,151,3,34};
	    ChangeVehicleColor(vehid,Carray[listitem],color2);
	    return ShowPlayerDialog(playerid,1116,DIALOG_STYLE_LIST,"Choose second color:","White\nBlack\nOrange\nLight Blue\nDark Blue\nPurple\nRed\nDark Red\nGrey","Ok","Cancle");
	}

	if(dialogid == 1116 && response)
	{
 		new color1, color2;
		GetVehicleColor(vehid,color1,color2);
	    new Carray[] = {1,0,6,2,79,149,151,3,34};
        ChangeVehicleColor(vehid,color1,Carray[listitem]);
        return CarmodDialog(playerid);
	}
	if(dialogid == 1113 && response)
	{
	    if(listitem == 16) return CarmodDialog(playerid);
		new Warray[] = {1073,1074,1075,1076,1077,1078,1079,1080,1081,1082,1083,1084,1085,1096,1097,1098};
		AddVehicleComponent(vehid,Warray[listitem]);
		return CarmodDialog(playerid);
	}
	if(dialogid == 1114 && response)
	{
	    switch(listitem)
	    {
			case 0: ShowPlayerDialog(playerid,1115,DIALOG_STYLE_LIST,"Choose one:","Paintjob 1\nPaintjob 2\nPaintjob 3","Ok","Cancel");
			case 1:
			{
                if(vehmd == 560)//Sultan
	    		{
					AddVehicleComponent(vehid, 1026);
					AddVehicleComponent(vehid, 1027);
					AddVehicleComponent(vehid, 1028);
					AddVehicleComponent(vehid, 1032);
					AddVehicleComponent(vehid, 1138);
					AddVehicleComponent(vehid, 1141);
					AddVehicleComponent(vehid, 1169);
				}
				if(vehmd == 562)//Elegy
				{
					AddVehicleComponent(vehid, 1036);
					AddVehicleComponent(vehid, 1040);
					AddVehicleComponent(vehid, 1034);
					AddVehicleComponent(vehid, 1038);
					AddVehicleComponent(vehid, 1147);
					AddVehicleComponent(vehid, 1171);
					AddVehicleComponent(vehid, 1149);
				}
				if(vehmd == 565)//Flash
				{
					AddVehicleComponent(vehid, 1047);
					AddVehicleComponent(vehid, 1051);
					AddVehicleComponent(vehid, 1046);
					AddVehicleComponent(vehid, 1054);
					AddVehicleComponent(vehid, 1049);
					AddVehicleComponent(vehid, 1150);
					AddVehicleComponent(vehid, 1153);
				}
				if(vehmd == 559)//Jester
				{
					AddVehicleComponent(vehid, 1069);
					AddVehicleComponent(vehid, 1071);
					AddVehicleComponent(vehid, 1065);
					AddVehicleComponent(vehid, 1067);
					AddVehicleComponent(vehid, 1162);
					AddVehicleComponent(vehid, 1159);
					AddVehicleComponent(vehid, 1160);
				}
				if(vehmd == 561)//Stratum
				{
					AddVehicleComponent(vehid, 1056);
					AddVehicleComponent(vehid, 1062);
					AddVehicleComponent(vehid, 1064);
					AddVehicleComponent(vehid, 1055);
					AddVehicleComponent(vehid, 1058);
					AddVehicleComponent(vehid, 1154);
					AddVehicleComponent(vehid, 1155);
				}
				if(vehmd == 558)//Uranus
				{
					AddVehicleComponent(vehid, 1090);
					AddVehicleComponent(vehid, 1094);
					AddVehicleComponent(vehid, 1092);
					AddVehicleComponent(vehid, 1088);
					AddVehicleComponent(vehid, 1164);
					AddVehicleComponent(vehid, 1168);
					AddVehicleComponent(vehid, 1166);
				}
			}
			case 2:
			{
				if(vehmd == 560)//Sultan
				{
					AddVehicleComponent(vehid, 1031);
					AddVehicleComponent(vehid, 1030);
					AddVehicleComponent(vehid, 1029);
					AddVehicleComponent(vehid, 1033);
					AddVehicleComponent(vehid, 1139);
					AddVehicleComponent(vehid, 1140);
					AddVehicleComponent(vehid, 1170);
				}
				if(vehmd == 562)//Elegy
				{
					AddVehicleComponent(vehid, 1041);
					AddVehicleComponent(vehid, 1039);
					AddVehicleComponent(vehid, 1037);
					AddVehicleComponent(vehid, 1035);
					AddVehicleComponent(vehid, 1146);
					AddVehicleComponent(vehid, 1148);
					AddVehicleComponent(vehid, 1172);
				}
				if(vehmd == 565)//Flash
				{
					AddVehicleComponent(vehid, 1048);
					AddVehicleComponent(vehid, 1045);
					AddVehicleComponent(vehid, 1053);
					AddVehicleComponent(vehid, 1050);
					AddVehicleComponent(vehid, 1152);
					AddVehicleComponent(vehid, 1151);
					AddVehicleComponent(vehid, 1052);
				}
				if(vehmd == 559) //Jester
				{
					AddVehicleComponent(vehid, 1070);
					AddVehicleComponent(vehid, 1072);
					AddVehicleComponent(vehid, 1066);
					AddVehicleComponent(vehid, 1068);
					AddVehicleComponent(vehid, 1158);
					AddVehicleComponent(vehid, 1161);
					AddVehicleComponent(vehid, 1173);
				}
				if(vehmd == 561)//Stratum
				{
					AddVehicleComponent(vehid, 1057);
					AddVehicleComponent(vehid, 1063);
					AddVehicleComponent(vehid, 1059);
					AddVehicleComponent(vehid, 1061);
					AddVehicleComponent(vehid, 1060);
					AddVehicleComponent(vehid, 1154);
					AddVehicleComponent(vehid, 1157);
				}
				if(vehmd == 558) //Uranus
				{
					AddVehicleComponent(vehid, 1093);
					AddVehicleComponent(vehid, 1095);
					AddVehicleComponent(vehid, 1089);
					AddVehicleComponent(vehid, 1091);
					AddVehicleComponent(vehid, 1163);
					AddVehicleComponent(vehid, 1167);
					AddVehicleComponent(vehid, 1165);
				}
			}
			case 3: CarmodDialog(playerid);
		}
	}
	if(dialogid == 1001 && response)
	{
		switch(listitem)
		{
			case 0: ShowPlayerDialog(playerid,1115,DIALOG_STYLE_LIST,"Choose one:","Paintjob 1\nPaintjob 2\nPaintjob 3","Ok","Cancel");
			case 1:
			{
                if(vehmd == 576)//Tornado
				{
                    AddVehicleComponent(vehid, 1134);
                    AddVehicleComponent(vehid, 1136);
                    AddVehicleComponent(vehid, 1137);
                    AddVehicleComponent(vehid, 1191);
                    AddVehicleComponent(vehid, 1192);
				}
				if(vehmd == 575)//Broadway
				{
                    AddVehicleComponent(vehid, 1042);
                    AddVehicleComponent(vehid, 1044);
                    AddVehicleComponent(vehid, 1099);
                    AddVehicleComponent(vehid, 1174);
                    AddVehicleComponent(vehid, 1176);
				}
				if(vehmd == 535)//Slamvan
				{
                    AddVehicleComponent(vehid, 1109);
                    AddVehicleComponent(vehid, 1113);
                    AddVehicleComponent(vehid, 1115);
                    AddVehicleComponent(vehid, 1117);
                    AddVehicleComponent(vehid, 1118);
                    AddVehicleComponent(vehid, 1120);
				}
			}
			case 2:
			{
                if(vehmd == 576)//Tornado
				{
                    AddVehicleComponent(vehid, 1135);
                    AddVehicleComponent(vehid, 1190);
                    AddVehicleComponent(vehid, 1193);
				}
				if(vehmd == 575)//Broadway
				{
                    AddVehicleComponent(vehid, 1177);
                    AddVehicleComponent(vehid, 1175);
                    AddVehicleComponent(vehid, 1143);
				}
				if(vehmd == 535)//Slamvan
				{
                    AddVehicleComponent(vehid, 1110);
                    AddVehicleComponent(vehid, 1114);
                    AddVehicleComponent(vehid, 1116);
                    AddVehicleComponent(vehid, 1119);
                    AddVehicleComponent(vehid, 1121);
				}
			}
			case 3: CarmodDialog(playerid);
		}
	}
	if(dialogid  == 1002)
	{
		switch(listitem)
		{
			case 0: ShowPlayerDialog(playerid,1115,DIALOG_STYLE_LIST,"Choose one:","Paintjob 1\nPaintjob 2\nPaintjob 3","Ok","Cancel");
			case 1:
			{
			    if(vehmd == 567)//Savanna
			    {
                	AddVehicleComponent(vehid, 1129);
                	AddVehicleComponent(vehid, 1133);
                	AddVehicleComponent(vehid, 1102);
                	AddVehicleComponent(vehid, 1187);
                	AddVehicleComponent(vehid, 1189);
                }
                if(vehmd == 536)//Blade
                {
                    AddVehicleComponent(vehid, 1104);
                    AddVehicleComponent(vehid, 1107);
                    AddVehicleComponent(vehid, 1108);
                    AddVehicleComponent(vehid, 1182);
                    AddVehicleComponent(vehid, 1184);
				}
			}
			case 2:
			{
			    if(vehmd == 567)//Savanna
			    {
                	AddVehicleComponent(vehid, 1188);
                	AddVehicleComponent(vehid, 1186);
                	AddVehicleComponent(vehid, 1132);
                }
                if(vehmd == 536)//Blade
                {
                    AddVehicleComponent(vehid, 1105);
                    AddVehicleComponent(vehid, 1183);
                    AddVehicleComponent(vehid, 1181);
				}
			}
			case 3:
			{
				if(vehmd == 567)//Savanna
				{
					AddVehicleComponent(vehid, 1130);
				}
				if(vehmd == 536)//Blade
                {
                    AddVehicleComponent(vehid, 1128);
				}
			}
			case 4:
			{
				if(vehmd == 567)//Savanna
				{
    				 AddVehicleComponent(vehid, 1131);
				}
				if(vehmd == 536)//Blade
                {
                    AddVehicleComponent(vehid, 1103);
				}
			}
			case 5: CarmodDialog(playerid);
		}
	}
	if(dialogid  == 1003)//Remington
	{
		switch(listitem)
		{
		    case 0:ShowPlayerDialog(playerid,1115,DIALOG_STYLE_LIST,"Choose one:","Paintjob 1\nPaintjob 2\nPaintjob 3","Ok","Cancel");
		    case 1:
		    {
				AddVehicleComponent(vehid, 1100);
				AddVehicleComponent(vehid, 1122);
				AddVehicleComponent(vehid, 1123);
				AddVehicleComponent(vehid, 1125);
				AddVehicleComponent(vehid, 1126);
				AddVehicleComponent(vehid, 1179);
            	AddVehicleComponent(vehid, 1180);
			}
			case 2:
			{
                AddVehicleComponent(vehid, 1185);
				AddVehicleComponent(vehid, 1178);
				AddVehicleComponent(vehid, 1127);
			}
			case 3: AddVehicleComponent(vehid, 1122),AddVehicleComponent(vehid, 1101);
			case 4: AddVehicleComponent(vehid, 1106),AddVehicleComponent(vehid, 1124);
			case 5: CarmodDialog(playerid);
		}
	}
	if(dialogid == 1004 && response)//regular cars
	{
	    switch(listitem)
	    {
			case 0:
			{
				ShowPlayerDialog(playerid,1010,DIALOG_STYLE_LIST,"Spoiler","Pro\nWin\nDrag\nAlpha\nChamp\nRace\nWorx\nFury\n{FF0000}Back","Select","Cancel");
			}
			case 1:
			{
			    if(vehmd == 585 || vehmd == 603 || vehmd == 439 || vehmd == 458 || vehmd == 418 || vehmd == 527 || vehmd == 580)
			    {
					AddVehicleComponent(vehid, 1006);
					return RegularCarDialog(playerid);
				}
				else if(vehmd == 439 || vehmd == 458 || vehmd == 491 || vehmd == 517 ||vehmd == 547)
			    {ShowPlayerDialog(playerid,1040,DIALOG_STYLE_LIST,"Vents","Oval\nSquare\n{FF0000}Back","Select","Cancel");}
                else if(vehmd == 415)
                {
					AddVehicleComponent(vehid, 1007);
					AddVehicleComponent(vehid, 1071);
					return RegularCarDialog(playerid);
				}
                else ShowPlayerDialog(playerid,1020,DIALOG_STYLE_LIST,"Hood","Champ\nFury\nRace\nWorx\n{FF0000}Back","Select","Cancel");
			}
			case 2:
			{
			    if(vehmd == 549 || vehmd == 585 || vehmd == 603)
				{ShowPlayerDialog(playerid,1040,DIALOG_STYLE_LIST,"Vents","Oval\nSquare\n{FF0000}Back","Select","Cancel");}
				else if(vehmd == 410 || vehmd == 436 || vehmd == 439 || vehmd == 458 || vehmd == 516 || vehmd == 491 || vehmd == 517 || vehmd == 418 || vehmd == 527 || vehmd == 580)
				{
                    AddVehicleComponent(vehid, 1007);
					AddVehicleComponent(vehid, 1071);
					return RegularCarDialog(playerid);
				}
				else if(vehmd == 415 || vehmd == 547 || vehmd == 420 || vehmd == 587)
				{CarmodDialog(playerid);}
				else
				{
					AddVehicleComponent(vehid, 1006);
					return RegularCarDialog(playerid);
				}

			}
			case 3:
			{
			    if(vehmd == 549 || vehmd == 585 || vehmd == 603 || vehmd == 551 || vehmd == 492 || vehmd == 529)
			    {
					AddVehicleComponent(vehid, 1007);
					AddVehicleComponent(vehid, 1071);
					return RegularCarDialog(playerid);
				}
				else if(vehmd == 410 || vehmd == 436 || vehmd == 439 || vehmd == 458 || vehmd == 489 || vehmd == 505)
				{ShowPlayerDialog(playerid,1060,DIALOG_STYLE_LIST,"Lights","Round Fog\nSquare Fog\n{FF0000}Back","Select","Cancel");}
				else if(vehmd == 418 || vehmd == 527 || vehmd == 580 || vehmd == 491 || vehmd == 517 || vehmd == 516)
				{CarmodDialog(playerid);}
				else{ShowPlayerDialog(playerid,1040,DIALOG_STYLE_LIST,"Vents","Oval\nSquare\n{FF0000}Back","Select","Cancel");}
			}
			case 4:
			{
			    if(vehmd == 549 || vehmd == 550 || vehmd == 585 || vehmd == 603)
			    {ShowPlayerDialog(playerid,1060,DIALOG_STYLE_LIST,"Lights","Round Fog\nSquare Fog\n{FF0000}Back","Select","Cancel");}
			    else if(vehmd == 489 || vehmd == 505 || vehmd == 551 || vehmd == 492 || vehmd == 529 || vehmd == 439 || vehmd == 458 || vehmd == 410 || vehmd == 436)
			    {CarmodDialog(playerid);}
			    else
			    {
					AddVehicleComponent(vehid, 1007);
					AddVehicleComponent(vehid, 1071);
					return RegularCarDialog(playerid);
				}
			}
			case 5:
			{
				if(vehmd == 585 || vehmd == 603 || vehmd == 550 || vehmd == 549)
				{CarmodDialog(playerid);}
				else{ShowPlayerDialog(playerid,1060,DIALOG_STYLE_LIST,"Lights","Round Fog\nSquare Fog\n{FF0000}Back","Select","Cancel");}
			}
			case 6: CarmodDialog(playerid);
		}
	}
	if(dialogid == 1010 && response)
	{
		if(listitem == 8) return RegularCarDialog(playerid);
		new Xarray[] = {1000,1001,1002,1003,1014,1015,1016,1023};
		AddVehicleComponent(vehid, Xarray[listitem]);
		return RegularCarDialog(playerid);
	}
	if(dialogid == 1020 && response)
	{
		if(listitem == 4) return RegularCarDialog(playerid);
		new Xarray[] = {1004,1005,1011,1012};
		AddVehicleComponent(vehid, Xarray[listitem]);
		return RegularCarDialog(playerid);
	}
	if(dialogid == 1040 && response)
	{
	    switch(listitem)
	    {
			case 0:
			{
				AddVehicleComponent(vehid, 1142);
				AddVehicleComponent(vehid, 1143);
				return RegularCarDialog(playerid);
			}
			case 1:
			{
				AddVehicleComponent(vehid, 1144);
				AddVehicleComponent(vehid, 1145);
				return RegularCarDialog(playerid);
			}
			case 2: RegularCarDialog(playerid);
		}
	}
 	if(dialogid==110 && response)
  	{
		Showinfo(playerid,inputtext);
  		ln[playerid]=0;
    }
    if(dialogid==111)
    {
    	if(response)Showinfo(playerid,inputtext);
    	else
     	{
      		new read[200],ss[1008],op[1000];
          	format(op,sizeof(op),"");
          	new File:log=fopen("BannedPlayers.txt",io_read);
          	fseek(log,ln[playerid],seek_start);
          	while(fread(log,read))
          	{
          		strcat(read,"\n",200);
          		strcat(op,read,1000);
          	}
          	fclose(log);
          	format(ss,sizeof(ss),"{9ACD32}%s",op);
          	ShowPlayerDialog(playerid, 112,  DIALOG_STYLE_LIST, "{00FFFF}Showing Currently Banned Players[Page 2]",ss, "Select", "Cancel");
          	ln[playerid]=0;
        }
	}
 	if(dialogid==112 && response)Showinfo(playerid,inputtext);
  	if(dialogid==113 && response)
   	{
    	new pat[MAX_PLAYER_NAME+10],pati[MAX_PLAYER_NAME+10],ppf[100],adname[MAX_PLAYER_NAME];
     	format(pat,sizeof(pat),"Bans/%s.ini",revseen[playerid]);
      	INI_ParseFile(pat, "LoadIP_%s", .bExtra = true, .extra = playerid);
       	format(pati,sizeof(pat),"IP/%s.ini",pp);
       	fremove(pati);
        format(pat,sizeof(pat),"Bans/%s.ini",revseen[playerid]);
        fremove(pat);
        format(ppf,sizeof(ppf),"The player %s has been un-banned.",revseen[playerid]);
        SendClientMessage(playerid,0x00FF00FF,ppf);
        GetPlayerName(playerid,adname,sizeof(adname));
        format(pat,sizeof(pat),"%s has been unbanned by %s",revseen[playerid],adname);
        new File:log=fopen("unban_log.txt",io_append);
        fwrite(log, pat);
        fwrite(log,"\r\n");
        fclose(log);
        fdeleteline("BannedPlayers.txt", revseen[playerid]);
	}
	if(dialogid == 1060 && response)
	{
		if(listitem == 2) return RegularCarDialog(playerid);
		new Xarray[] = {1013,1024};
		AddVehicleComponent(vehid, Xarray[listitem]);
		return RegularCarDialog(playerid);
	}
	if(dialogid == 1115 && response)
	{
		new Parray[] = {0,1,2};
		ChangeVehiclePaintjob(vehid, Parray[listitem]);
		return CarmodDialog(playerid);
	}
	if(dialogid == 234)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
		        case 0:
		        {
					new strng[520];
					strcat(strng, "/skin{FFFFFF} - To change your skin\n");
					strcat(strng, "/teles{FFFFFF} - to see teleports menu\n");
					strcat(strng, "/rules{FFFFFF} - to see server rules\n");
					strcat(strng, "/mytime{FFFFFF} - change your times\n");
				 	strcat(strng, "/pm{FFFFFF} - Send Private Message\n");
				  	strcat(strng, "/afk{FFFFFF} - Away From Keyboards\n");
				   	strcat(strng, "/credits{FFFFFF} - to see importan players\n");
					strcat(strng, "/help{FFFFFF} - To get started\n");
					strcat(strng, "/kill{FFFFFF} - Kill yourself\n");
					strcat(strng, "/o{FFFFFF} - Attach Object to your skins\n");
					strcat(strng, "/mini{FFFFFF} - Play Minigun DM Minigames\n");
					strcat(strng, "/onede{FFFFFF} - Play Deagle DM Minigames\n");
					strcat(strng, "/camera{FFFFFF} - Give a Camera");
	                ShowPlayerDialog(playerid, 142, DIALOG_STYLE_MSGBOX, "{FFFFFF}Commands", strng, "close", "");
				}
				case 1:
				{
					strcat(str, "{FFFFFF}/tune -> To tuning you cars");
	                ShowPlayerDialog(playerid, 143, DIALOG_STYLE_MSGBOX, "{FFFFFF}Vehicle", str, "close", "");
				}
				case 2:
				{
					strcat(str, "{FFFFFF}/housemenu -> to acces your house menu\n");
					strcat(str, "{FFFFFF}/buyhouse -> to bought a house (must near icon house)\n");
					strcat(str, "{FFFFFF}/enter -> to enter house (must near icon house)");
	                ShowPlayerDialog(playerid, 143, DIALOG_STYLE_MSGBOX, "{FFFFFF}House", str, "close", "");
				}
				case 3:
				{
				    ShowPlayerDialog(playerid, TELE_DIALOG, DIALOG_STYLE_LIST, "Teles", "{FF0000}Los Santos\n{00FF00}San Fierro\n{0000FF}Las Venturas", "Select", "Cancel");
				}
				case 4:
				{
					strcat(str, "{FFFFFF}Drifting: You can drifting around the server to recive money\n");
					strcat(str, "House: You can have a house around the server by buying them\n");
					strcat(str, "Vehicle Owner: You can have your Private cars by buying house first\n");
					strcat(str, "Toys: You can attach your character with toys by using /o\n\n");
					strcat(str, "{FFFF00}We hope you Enjoy the server by not using any illegal hacking items! Have Fun Playing\n");
					ShowPlayerDialog(playerid, 144, DIALOG_STYLE_MSGBOX, "{FFFFFF}House", str, "close", "");
				}
			}
		}
	}
	if(dialogid == carmenu) // == Car menu dialog id
	{
        if(response) // If they clicked 'Select' or double-clicked a List
        {
 			if(listitem == 0)
 			{
 				ShowModelSelectionMenu(playerid, bikeslist, "Bikes");
 				return 1;
			}
		 	if(listitem == 1)
			{
				ShowModelSelectionMenu(playerid, car1, "Cars A-E");
				return 1;
			}
		 	if(listitem == 2)
			{
			    ShowModelSelectionMenu(playerid, car2, "Cars F-P");
			    return 1;
			}
		 	if(listitem == 3)
			{
			    ShowModelSelectionMenu(playerid, car3, "Cars P-S");
			    return 1;
			}
		 	if(listitem == 4)
			{
			    ShowModelSelectionMenu(playerid, car4, "Cars S-Z");
			    return 1;
			}
			if(listitem == 5)
			{
				ShowModelSelectionMenu(playerid, helicopter, "Helicopter");
				return 1;
			}
			if(listitem == 6)
			{
				ShowModelSelectionMenu(playerid, planes, "Planes");
				return 1;
			}
			if(listitem == 7)
			{
			    ShowModelSelectionMenu(playerid, boat, "Boats");
			    return 1;
			}
			if(listitem == 8)
			{
			    ShowModelSelectionMenu(playerid, trains, "Trains");
			    return 1;
			}
			if(listitem == 9)
			{
			    ShowModelSelectionMenu(playerid, trailers, "Trailers");
			    return 1;
			}
			if(listitem == 10)
			{
			    ShowModelSelectionMenu(playerid, rcveh, "RC Vehicles + Vortex");
			    return 1;
			}
		}
		else SendClientMessage(playerid, 0xFF40FF, "Canceled Cars selection");
	}
	if(dialogid == 552)
	{
	    if(response)
	    {
	        if(listitem == 0)
	        {
	            SetPlayerColor(playerid, COLOR_RED);
	            SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFF00}You have been set your color to {FF0000}Red");
			}
			if(listitem == 1)
			{
			    SetPlayerColor(playerid, COLOR_GREEN);
			    SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFF00}You have been set your color to {00FF00}Green");
			}
			if(listitem == 2)
			{
				SetPlayerColor(playerid, COLOR_BLUE);
			    SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFF00}You have been set your color to {0000FF}Blue");
			}
			if(listitem == 3)
			{
			    SetPlayerColor(playerid, COLOR_LBLUE);
			    SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFF00}You have been set your color to {15DE4D}Light Blue");
			}
			if(listitem == 4)
			{
			    SetPlayerColor(playerid, COLOR_GREY);
                SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFF00}You have been set your color to {FAFAFA}Grey");
			}
			if(listitem == 5)
			{
			    SetPlayerColor(playerid, COLOR_ORANGE);
			    SendClientMessage(playerid, COLOR_RED, "vDR {B0B0B0}» {FFFF00}You have been set your color to {FF9933}Orange");
			}
		}
	}
	return 1;
}

public OnPlayerModelSelection(playerid, response, listid, modelid)
{
	if(listid == bikeslist)
	{
	    if(response)
	    {
	    	CreateVehicleEx(playerid,modelid, X,Y,Z+1, Angle, random(126), random(126), -1);
	    }
	    else SendClientMessage(playerid, 0xFF0000FF, "Canceled Bikes selection");
    	return 1;
	}
	if(listid == car1)
	{
	    if(response)
	    {
	    	CreateVehicleEx(playerid,modelid, X,Y,Z+1, Angle, random(126), random(126), -1);
	    }
	    else SendClientMessage(playerid, 0xFF0000FF, "Canceled Cars selection");
    	return 1;
	}
	if(listid == car2)
	{
	    if(response)
	    {
	    	CreateVehicleEx(playerid,modelid, X,Y,Z+1, Angle, random(126), random(126), -1);
	    }
	    else SendClientMessage(playerid, 0xFF0000FF, "Canceled Cars selection");
    	return 1;
	}
	if(listid == car3)
	{
	    if(response)
	    {
	    	CreateVehicleEx(playerid,modelid, X,Y,Z+1, Angle, random(126), random(126), -1);
	    }
	    else SendClientMessage(playerid, 0xFF0000FF, "Canceled Cars selection");
    	return 1;
	}
	if(listid == car4)
	{
	    if(response)
	    {
	    	CreateVehicleEx(playerid,modelid, X,Y,Z+1, Angle, random(126), random(126), -1);
	    }
	    else SendClientMessage(playerid, 0xFF0000FF, "Canceled Cars selection");
    	return 1;
	}
	if(listid == helicopter)
	{
	    if(response)
	    {
	    	CreateVehicleEx(playerid,modelid, X,Y,Z+1, Angle, random(126), random(126), -1);
	    }
	    else SendClientMessage(playerid, 0xFF0000FF, "Canceled Helicopter selection");
    	return 1;
	}
	if(listid == planes)
	{
	    if(response)
	    {
	    	CreateVehicleEx(playerid,modelid, X,Y,Z+1, Angle, random(126), random(126), -1);
	    }
	    else SendClientMessage(playerid, 0xFF0000FF, "Canceled Planes selection");
    	return 1;
	}
    if(listid == boat)
	{
	    if(response)
	    {
	    	CreateVehicleEx(playerid,modelid, X,Y,Z+1, Angle, random(126), random(126), -1);
	    }
	    else SendClientMessage(playerid, 0xFF0000FF, "Canceled Boats selection");
    	return 1;
	}
	if(listid == trains)
	{
	    if(response)
	    {
	    	CreateVehicleEx(playerid,modelid, X,Y,Z+1, Angle, random(126), random(126), -1);
	    }
	    else SendClientMessage(playerid, 0xFF0000FF, "Canceled Trains selection");
    	return 1;
	}
	if(listid == trailers)
	{
	    if(response)
	    {
	    	CreateVehicleEx(playerid,modelid, X,Y,Z+1, Angle, random(126), random(126), -1);
	    }
	    else SendClientMessage(playerid, 0xFF0000FF, "Canceled Trailers selection");
    	return 1;
	}
	if(listid == rcveh)
	{
	    if(response)
	    {
	    	CreateVehicleEx(playerid,modelid, X,Y,Z+1, Angle, random(126), random(126), -1);
	    }
	    else SendClientMessage(playerid, 0xFF0000FF, "Canceled Cars selection");
	}
	return 1;
}

stock Path(playerid) //Will create a new stock so we can easily use it later to load/save user's data in user's path
{
    new str[128],name[MAX_PLAYER_NAME];
    GetPlayerName(playerid,name,sizeof(name));
    format(str,sizeof(str),UserPath,name);
    return str;
}

stock PlayerName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof name);
	return name;
}

RegularCarDialog(playerid)
{
    new vehmd = GetVehicleModel(GetPlayerVehicleID(playerid));
 	new string[128];
	if(vehmd == 401 || vehmd == 496 || vehmd == 518 || vehmd == 540 || vehmd == 546 || vehmd == 589)
	{string = "Spoiler\nHood\nRoof\nVents\nSideskirt\nLights\n{FF0000}Back";}
	else if(vehmd == 549)
	{string = "Spoiler\nHood\nVents\nSideskirt\nLights\n{FF0000}Back";}
	else if(vehmd == 550)
	{string = "Spoiler\nHood\nRoof\nVents\nLights\n{FF0000}Back";}
	else if(vehmd == 585 || vehmd == 603)
	{string = "Spoiler\nRoof\nVents\nSideskirt\nLights\n{FF0000}Back";}
	else if(vehmd == 410 || vehmd == 436)
	{string = "Spoiler\nRoof\nSideskirt\nLights\n{FF0000}Back";}
	else if(vehmd == 439 || vehmd == 458)
	{string = "Spoiler\nVents\nSideskirt\nLights\n{FF0000}Back";}
	else if(vehmd == 551 || vehmd == 492 || vehmd == 529)
	{string = "Spoiler\nHood\nRoof\nSideskirt\n{FF0000}Back";}
	else if(vehmd == 489 || vehmd == 505)
	{string = "Spoiler\nHood\nRoof\nLights\n{FF0000}Back";}
	else if(vehmd == 516)
	{string = "Spoiler\nHood\nSideskirt\n{FF0000}Back";}
	else if(vehmd == 491 || vehmd == 517)
	{string = "Spoiler\nVents\nSideskirt\n{FF0000}Back";}
	else if(vehmd == 418 || vehmd == 527 || vehmd == 580)
	{string = "Spoiler\nRoof\nSideskirt\n{FF0000}Back";}
	else if(vehmd == 420 || vehmd == 587)
	{string = "Spoiler\nHood\n{FF0000}Back";}
	else if(vehmd == 547)
	{string = "Spoiler\nVents\n{FF0000}Back";}
	else if(vehmd == 415)
	{string = "Spoiler\nSideskirt\n{FF0000}Back";}
    ShowPlayerDialog(playerid,1004,DIALOG_STYLE_LIST,"Choose one",string,"Select","Cancel");
    return 1;
}

CarmodDialog(playerid)
{
	ShowPlayerDialog(playerid,1111,DIALOG_STYLE_LIST,"Select things to put in your car","Nitro\nCar Color\nWheels\nStereo\nHydraulics\nCar Components","Select","Cancel");
	return 1;
}

GetName(playerid)
{
	new pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, 24);
	return pName;
}

IsValidSkin(skinid)
{
	#define   MAX_BAD_SKINS 1
	new badSkins[MAX_BAD_SKINS] =
	{ 74 };
	if (skinid < 0 || skinid > 299) return false;
	for (new i = 0; i < MAX_BAD_SKINS; i++) { if (skinid == badSkins[i]) return false; }
	#undef MAX_BAD_SKINS
	return 1;
}

stock IsNumeric(string[])
{
	for(new i = 0; i < strlen(string); i++) if(string[i] > '9' || string[i] < '0') return false;
 	return true;
}

stock IsVehicleOccupied(vehicleid)
{
  	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(GetPlayerState(i) == PLAYER_STATE_DRIVER || GetPlayerState(i) == PLAYER_STATE_PASSENGER)
		{
			if(GetPlayerVehicleID(i) == vehicleid)
			{
				return 1;
			}
		}
	}
	return 0;
}
//==============================================================================
stock CreateVehicleEx(playerid, modelid, Float:posX, Float:posY, Float:posZ, Float:angle, Colour1, Colour2, respawn_delay)
{
	new world = GetPlayerVirtualWorld(playerid);
	new interior = GetPlayerInterior(playerid);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		DestroyVehicle(GetPlayerVehicleID(playerid));
		GetPlayerPos(playerid, posX, posY, posZ);
		GetPlayerFacingAngle(playerid, angle);
		CurrentSpawnedVehicle[playerid] = CreateVehicle(modelid, posX, posY, posZ, angle, Colour1, Colour2, respawn_delay);
        LinkVehicleToInterior(CurrentSpawnedVehicle[playerid], interior);
		SetVehicleVirtualWorld(CurrentSpawnedVehicle[playerid], world);
		SetVehicleZAngle(CurrentSpawnedVehicle[playerid], angle);
		PutPlayerInVehicle(playerid, CurrentSpawnedVehicle[playerid], 0);
		SetPlayerInterior(playerid, interior);
	}
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	{
	    if(IsVehicleOccupied(CurrentSpawnedVehicle[playerid])) {} else DestroyVehicle(CurrentSpawnedVehicle[playerid]);
		GetPlayerPos(playerid, posX, posY, posZ);
		GetPlayerFacingAngle(playerid, angle);
		CurrentSpawnedVehicle[playerid] = CreateVehicle(modelid, posX, posY, posZ, angle, Colour1, Colour2, respawn_delay);
		LinkVehicleToInterior(CurrentSpawnedVehicle[playerid], interior);
		SetVehicleVirtualWorld(CurrentSpawnedVehicle[playerid], world);
		SetVehicleZAngle(CurrentSpawnedVehicle[playerid], angle);
		PutPlayerInVehicle(playerid, CurrentSpawnedVehicle[playerid], 0);
		SetPlayerInterior(playerid, interior);
	}
	return 1;
}

function xReactionProgress()
{
	switch(xTestBusy)
 	{
  		case true:
    	{
     		new string[128];
       		format(string, sizeof(string), "{FF0000}ReactionTest :: {15D4ED}Noone won the reaction test. reaction will start in {00FF00}%d minutes", (TIME/60000));
         	SendClientMessageToAll(PURPLE, string);
          	xReactionTimer = SetTimer("xReactionTest", TIME, 1);
     	}
	}
 	return 1;
}

function xReactionTest()
{
	new xLength = (random(8) + 2), string[128];
 	xCash = (random(1000) + 2000);
  	xScore = (random(2)+1);
  	format(xChars, sizeof(xChars), "");
  	Loop(x, xLength) format(xChars, sizeof(xChars), "%s%s", xChars, xCharacters[random(sizeof(xCharacters))][0]);
  	format(string, sizeof(string), "{FF0000}ReactionTest :: {15D4ED}The first one to type '{FFFF00}%s{15D4ED}' wins %d score and {00FF00}$%d", xChars, xScore, xCash);
  	SendClientMessageToAll(PURPLE, string);
  	KillTimer(xReactionTimer);
  	xTestBusy = true;
  	SetTimer("xReactionProgress", 30000, 0);
  	return 1;
}

forward DelayBan(playerid);
public DelayBan(playerid)
{
	Kick(playerid);
}

forward DelayKick(playerid);
public DelayKick(playerid)
{
Kick(playerid);
}
stock GetVehicleName(vehicleid)
{
	new str[80];
	format(str,sizeof(str),"%s",VehicleNames[GetVehicleModel(vehicleid) - 400]);
	return str;
}
forward KickPlayer(playerid);
public KickPlayer(playerid)
{
	Kick(playerid);
 	return 1;
}
forward SendMessage();
public SendMessage()
{
	SendClientMessageToAll(0x9EC73DAA, AutoMessage[random(sizeof(AutoMessage))]);
   	return 1;
}

Kara(text[])
{
if(Karau)
{
TextDrawHideForAll(Kary);
KillTimer(NapisTimer);
}
Karau=true;
TextDrawSetString(Kary,text);
TextDrawShowForAll(Kary);
NapisTimer=SetTimer("NapisWylacz",20000,false);
return 1;
} 

RestartEveryThing ()
{
	new xq, yq, zq;
	new Number;

	Speed_xy = 2000 / (HAY_Z + 1);
	Speed_z = 1500 / (HAY_Z + 1);
	for (new i=0 ; i<MAX_PLAYERS ; i++)
	{
	    if (IsPlayerConnected (i))
	    {
	    	WhatLevel[i] = 0;
	    }
	}
	for (xq=0 ; xq<HAY_X ; xq++)
	{
		for (yq=0 ; yq<HAY_Y ; yq++)
		{
			for (zq=0 ; zq<HAY_Z ; zq++)
			{
				Matrix[xq][yq][zq] = 0;
			}
		}
	}
	for (Number=0 ; Number<HAY_B ; Number++)
	{
		do
		{
			xq = random (HAY_X);
			yq = random (HAY_Y);
			zq = random (HAY_Z);
  		}
		while (Matrix[xq][yq][zq] != 0);
		Matrix[xq][yq][zq] = 1;
		Hays[Number] = CreateObject (ID_HAY_OBJECT, xq*(-4), yq*(-4), (zq+1)*3, 0.0, 0.0, random (2)*180,50);
	}
	Center_x = (HAY_X + 1) * -2;
	Center_y = (HAY_Y + 1) * -2;
	CreateObject (ID_HAY_OBJECT, Center_x, Center_y, HAY_Z*3 + 3, 0, 0, 0,50);
	SetTimer ("TimerMove", 100, 0);
	SetTimer ("TDScore", 1000, 1);
}

CheckWeapons(playerid)
{
    new weaponid = GetPlayerWeapon(playerid);

    if(weaponid >= 1 && weaponid <= 15)
    {
        if(weaponid == Weapons[playerid][Melee])
        {
        return 1;
        }
            else
            {
            SendClientMessage(playerid,ORANGE2,"[AC]: You has been banned by server, reason: Weapon Hack(Mele)");
			GameTextForPlayer(playerid, "~g~ban", 8000, 4);
		    SetTimerEx("ban", 300, false, "i", playerid);
			printf("[AC] %s Has banned by server, reason: Weapon Hack(Mele).", PlayerName(playerid));
			new text[50];
	        format(String, sizeof(String),"~r~Ban~n~~w~Player: %s~n~Admin: System~n~~y~~h~Weapon Hack",PlayerName(playerid),text);
            Kara(String);
			for (new i=0;i<MAX_PLAYERS;i++)
            {
                if (IsPlayerConnected(i))
                {
                    if(IsPlayerAdmin(playerid))
                    {
			            format(String, sizeof(String),"[AC]: %s Has banned by server, reason: Weapon Hack(Mele)",PlayerName(playerid));
                        SendClientMessage(i, COLOR_AC, String);
                    }
                }
            }
            }
    }

    if( weaponid >= 16 && weaponid <= 18 || weaponid == 39 ) 
    {
        if(weaponid == Weapons[playerid][Thrown])
        {
        return 1;
        }
            else
            {
            SendClientMessage(playerid,ORANGE2,"[AC]: You has been banned by server, reason: Weapon Hack(Granades)");
			GameTextForPlayer(playerid, "~g~ban", 8000, 4);
		    SetTimerEx("ban", 300, false, "i", playerid);
			printf("[AC] %s Has banned by server, reason: Weapon Hack(Granades)", PlayerName(playerid));
			new text[50];
	        format(String, sizeof(String),"~r~Ban~n~~w~Player: %s~n~Admin: System~n~~y~~h~Weapon Hack",PlayerName(playerid),text);
            Kara(String);
			for (new i=0;i<MAX_PLAYERS;i++)
            {
                if (IsPlayerConnected(i))
                {
                    if(IsPlayerAdmin(playerid))
                    {
			            format(String, sizeof(String),"[AC]: %s Has banned by server, reason: Weapon Hack(Granades)",PlayerName(playerid));
                        SendClientMessage(i, COLOR_AC, String);
                    }
                }
            }
            }
    }
    if( weaponid >= 22 && weaponid <= 24 ) 
    {
        if(weaponid == Weapons[playerid][Pistols])
        {
        return 1;
        }
        else
        {
            SendClientMessage(playerid,ORANGE2,"[AC]: You has been banned by server, reason: Weapon Hack(Pistols)");
			GameTextForPlayer(playerid, "~g~ban", 8000, 4);
		    SetTimerEx("ban", 300, false, "i", playerid);
			printf("[AC] %s Has banned by server, reason: Weapon Hack(Pistols).", PlayerName(playerid));
			new text[50];
	        format(String, sizeof(String),"~r~Ban~n~~w~Player: %s~n~Admin: System~n~~y~~h~Weapon Hack",PlayerName(playerid),text);
            Kara(String);
			for (new i=0;i<MAX_PLAYERS;i++)
            {
                if (IsPlayerConnected(i))
                {
                    if(IsPlayerAdmin(playerid))
                    {
			            format(String, sizeof(String),"[AC]: %s Has banned by server, reason: Weapon Hack(Pistols)",PlayerName(playerid));
                        SendClientMessage(i, COLOR_AC, String);
                    }
                }
            }
        }
    }

    if( weaponid >= 25 && weaponid <= 27 ) 
    {
        if(weaponid == Weapons[playerid][Shotguns])
        {
        return 1;
        }
            else
            {
            SendClientMessage(playerid,ORANGE2,"[AC]: You has been banned by server, reason: Weapon Hack(Shotguns)");
			GameTextForPlayer(playerid, "~g~ban", 8000, 4);
		    SetTimerEx("ban", 300, false, "i", playerid);
			printf("[AC] %s Has banned by server, reason: Weapon Hack(Shotguns).", PlayerName(playerid));
			new text[50];
	        format(String, sizeof(String),"~r~Ban~n~~w~Player: %s~n~Admin: System~n~~y~~h~Weapon Hack",PlayerName(playerid),text);
            Kara(String);
			for (new i=0;i<MAX_PLAYERS;i++)
            {
                if (IsPlayerConnected(i))
                {
                    if(IsPlayerAdmin(playerid))
                    {
			            format(String, sizeof(String),"[AC]: %s Has banned by server, reason: Weapon Hack(Shotguns)",PlayerName(playerid));
                        SendClientMessage(i, COLOR_AC, String);
                    }
                }
            }
            }
    }
    if( weaponid == 28 || weaponid == 29 || weaponid == 32 ) 
    {
        if(weaponid == Weapons[playerid][SubMachine])
        {
        return 1;
        }
            else
            {
            SendClientMessage(playerid,ORANGE2,"[AC]: You has been banned by server, reason: Weapon Hack(Machine Guns)");
			GameTextForPlayer(playerid, "~g~ban", 8000, 4);
		    SetTimerEx("ban", 300, false, "i", playerid);
			printf("[AC] %s Has banned by server, reason: Weapon Hack(Machine Guns).", PlayerName(playerid));
			new text[50];
	        format(String, sizeof(String),"~r~Ban~n~~w~Player: %s~n~Admin: System~n~~y~~h~Weapon Hack",PlayerName(playerid),text);
            Kara(String);
			for (new i=0;i<MAX_PLAYERS;i++)
            {
                if (IsPlayerConnected(i))
                {
                    if(IsPlayerAdmin(playerid))
                    {
			            format(String, sizeof(String),"[AC]: %s Has banned by server, reason: Weapon Hack(Machine Guns)",PlayerName(playerid));
                        SendClientMessage(i, COLOR_AC, String);
                    }
                }
            }
            }
    }

    if( weaponid == 30 || weaponid == 31 )
    {
        if(weaponid == Weapons[playerid][Assault])
        {
        return 1;
        }
            else
            {
            SendClientMessage(playerid,ORANGE2,"[AC]: You has been banned by server, reason: Weapon Hack(Assasult Guns)");
			GameTextForPlayer(playerid, "~g~ban", 8000, 4);
		    SetTimerEx("ban", 300, false, "i", playerid);
			printf("[AC] %s Has banned by server, reason: Weapon Hack(Assasult Guns).", PlayerName(playerid));
			new text[50];
	        format(String, sizeof(String),"~r~Ban~n~~w~Player: %s~n~Admin: System~n~~y~~h~Weapon Hack",PlayerName(playerid),text);
            Kara(String);
			for (new i=0;i<MAX_PLAYERS;i++)
            {
                if (IsPlayerConnected(i))
                {
                    if(IsPlayerAdmin(playerid))
                    {
			            format(String, sizeof(String),"[AC]: %s Has banned by server, reason: Weapon Hack(Assasult Guns)",PlayerName(playerid));
                        SendClientMessage(i, COLOR_AC, String);
                    }
                }
            }
            }
    }

    if( weaponid == 33 || weaponid == 34 )
    {
        if(weaponid == Weapons[playerid][Rifles])
        {
        return 1;
        }
            else
            {
            SendClientMessage(playerid,ORANGE2,"[AC]: You has been banned by server, reason: Weapon Hack(Snipers)");
			GameTextForPlayer(playerid, "~g~ban", 8000, 4);
		    SetTimerEx("ban", 300, false, "i", playerid);
			printf("[AC] %s Has banned by server, reason: Weapon Hack(Snipers).", PlayerName(playerid));
			new text[50];
	        format(String, sizeof(String),"~r~Ban~n~~w~Player: %s~n~Admin: System~n~~y~~h~Weapon Hack",PlayerName(playerid),text);
            Kara(String);
			for (new i=0;i<MAX_PLAYERS;i++)
            {
                if (IsPlayerConnected(i))
                {
                    if(IsPlayerAdmin(playerid))
                    {
			            format(String, sizeof(String),"[AC]: %s Has banned by server, reason: Weapon Hack(Snipers)",PlayerName(playerid));
                        SendClientMessage(i, COLOR_AC, String);
                    }
                }
            }
            }
    }
    if( weaponid >= 35 && weaponid <= 38 ) 
    {
        if(weaponid == Weapons[playerid][Heavy])
        {
        return 1;
        }
            else
            {
            SendClientMessage(playerid,ORANGE2,"[AC]: You has been banned by server, reason: Weapon Hack(Heavy)");
			GameTextForPlayer(playerid, "~g~ban", 8000, 4);
		    SetTimerEx("ban", 300, false, "i", playerid);
			printf("[AC] %s Has banned by server, reason: Weapon Hack(Heavy).", PlayerName(playerid));
			new text[50];
	        format(String, sizeof(String),"~r~Ban~n~~w~Player: %s~n~Admin: System~n~~y~~h~Weapon Hack",PlayerName(playerid),text);
            Kara(String);
			for (new i=0;i<MAX_PLAYERS;i++)
            {
                if (IsPlayerConnected(i))
                {
                    if(IsPlayerAdmin(playerid))
                    {
			            format(String, sizeof(String),"[AC]: %s Has banned by server, reason: Weapon Hack(Heavy)",PlayerName(playerid));
                        SendClientMessage(i, COLOR_AC, String);
                    }
                }
            }
            }
    }
    else { return 1; }
    
    return 1;
}

ServerWeapon(playerid, weaponid, ammo)
{
if(weaponid >= 1 && weaponid <= 15)
    {
    Weapons[playerid][Melee] = weaponid;
    GivePlayerWeapon(playerid, weaponid, ammo);
    return 1;
    }

        if( weaponid >= 16 && weaponid <= 18 || weaponid == 39 ) // Checking Thrown
    {
    Weapons[playerid][Thrown] = weaponid;
    GivePlayerWeapon(playerid, weaponid, ammo);
    return 1;
    }
    if( weaponid >= 22 && weaponid <= 24 ) // Checking Pistols
    {
    Weapons[playerid][Pistols] = weaponid;
    GivePlayerWeapon(playerid, weaponid, ammo);
    return 1;
    }

    if( weaponid >= 25 && weaponid <= 27 ) // Checking Shotguns
    {
    Weapons[playerid][Shotguns] = weaponid;
    GivePlayerWeapon(playerid, weaponid, ammo);
    return 1;
    }
    if( weaponid == 28 || weaponid == 29 || weaponid == 32 ) // Checking Sub Machine Guns
    {
    Weapons[playerid][SubMachine] = weaponid;
    GivePlayerWeapon(playerid, weaponid, ammo);
    return 1;
    }

    if( weaponid == 30 || weaponid == 31 ) // Checking Assault
    {
    Weapons[playerid][Assault] = weaponid;
    GivePlayerWeapon(playerid, weaponid, ammo);
    return 1;
    }

    if( weaponid == 33 || weaponid == 34 ) // Checking Rifles
    {
    Weapons[playerid][Rifles] = weaponid;
    GivePlayerWeapon(playerid, weaponid, ammo);
    return 1;
    }
    if( weaponid >= 35 && weaponid <= 38 ) // Checking Heavy
    {
    Weapons[playerid][Heavy] = weaponid;
    GivePlayerWeapon(playerid, weaponid, ammo);
    return 1;
    }
return 1;
}
