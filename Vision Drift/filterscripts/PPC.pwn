// Make sure you don't get warnings about tabsize
#pragma tabsize 0

// Include default files
#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <streamer>



// ******************************************************************************************************************************
// Settings that can be changed
// ******************************************************************************************************************************

// When this is set to "true", you spawn at the first house in your list of owned houses
// When set to "false", you spawn normally
new bool:SpawnAtHouse = false;

// Set timer-delay for exiting houses (this timer freezes a player when he exits a house, this allows the game to load the environment
// before the player starts to fall, also the player's vehicles assigned to the house he exits from, are respawned by this timer)
new ExitHouseTimer = 1000;

// This allows you to toggle the red houses on the map (bought houses appear on the map as red house icons when this is set to "true")
// Setting this to "false" doesn't show a bought house on the map
new bool:ShowBoughtHouses = false;

// Setting this to "true" will load all vehicles assigned to houses when the filterscript loads
// Setting this to "false" will load the vehicles assigned to a house when the house-owner logs in (they'll also disappear when he logs out)
// Recommended setting for popular servers (with alot of players): "false"
// In popular servers, the amount of cars could go over the samp-limit (2000), bugging everything when all cars stay loaded
// even when the owner of the vehicle is offline
new bool:LoadCarsDuringFSInit = false;

// Setting this to "true" will set all houses to have insurance by default
// Seting this to "false" required players to buy insurance for their vehicles from within the house
// If players don't have insurance, their vehicle will be gone forever if it's destroyed
// If players have insurance, they will get their vehicle back when it's destroyed
new bool:AutomaticInsurance = true;

// Default max number of players is set to 500, re-define it to 50
#undef MAX_PLAYERS
#define MAX_PLAYERS 50

// Define housing parameters
#define MAX_HOUSES					2000 // Defines the maximum number of houses that can be created
#define MAX_HOUSESPERPLAYER			20 // Defines the maximum number of houses that any player can own (useable values: 1 to 20)
#define HouseUpgradePercent         100 // Defines the percentage for upgrading a house (house of 10m can be upgraded for 5m when set to 50)
#define ParkRange                   150.0 // Defines the range for parking the vehicle around the house to which it belongs (default = 150m)

// Define path to house-files
#define HouseFile "PPC_Housing/House%i.ini"

// Define Dialogs
#define DialogHouseMenu             5001
#define DialogUpgradeHouse          5002
#define DialogGoHome                5003
#define DialogHouseNameChange       5004
#define DialogSellHouse             5005
#define DialogBuyCarClass           5006
#define DialogBuyCar                5007
#define DialogSellCar               5008
#define DialogBuyInsurance          5009
#define DialogGetCarSelectHouse     5010
#define DialogGetCarSelectCar       5011

// Define vehicle-classes
#define VClassBike          1
#define VClassBoat          2
#define VClassConvertible   3
#define VClassHelicopter    4
#define VClassIndustrial    5
#define VClassLowRider      6
#define VClassOffRoad       7
#define VClassPlane         8
#define VClassPublic        9
#define VClassRCVehicle     10
#define VClassSaloons       11
#define VClassSportCar      12
#define VClassStationCar    13
#define VClassTrailer       14
#define VClassUnique        15

#define COLOR_GREEN 0x33AA33AA

// ******************************************************************************************************************************
// Enums and the array-setups that use them
// ******************************************************************************************************************************

// Setup a custom type that holds all data for houses
enum THouseData
{
	PickupID, // Holds the pickup-id that is linked to this house
	Text3D:DoorText, // Holds the reference to the 3DText above the house's pickup
	MapIconID, // Holds the ID of the mapicon for the house

	bool:Owned, // Holds true if the house is owned by somebody
	Owner[24], // Holds the name of the owner of the house

	HouseName[100], // Holds the name of the house (this will be displayed above the pickup near the house when it's owned)
	Float:HouseX, // Holds the X-coordinate of the pickup for the house
	Float:HouseY, // Holds the Y-coordinate of the pickup for the house
	Float:HouseZ, // Holds the Z-coordinate of the pickup for the house
	HouseLevel, // Holds the level of upgrades the house has, and defines which interior to use when you enter the house
	HouseMaxLevel, // Holds the maximum level this house can be upgraded to
	HousePrice, // Holds the price for buying the house, the same price applies when upgrading a house per level (multiplied by HouseUpgradePercent/100)
	bool:HouseOpened, // Holds true if the house is open to the public (anyone can enter), false means: only the owner can enter it
	bool:Insurance, // Holds "true" if the house has an insurance for the vehicles belonging to this house
	VehicleIDs[10], // Holds the vehicle-id's of the vehicles linked to this house (max 10 vehicles per house)

	bool:StaticHouse, // Holds "true" if the house is static (cannot be upgraded and has a fixed interior)
	CarSlots // Holds the amount of carslots available
}
// Holds the data for all houses
new AHouseData[MAX_HOUSES][THouseData];



// Setup a custom type to hold all data about a vehicle
enum TVehicleData
{
	BelongsToHouse, // Holds the HouseID to which this vehicle belongs

	bool:Owned, // Holds true if the vehicle is owned by somebody
	Owner[24], // Holds the name of the owner of the vehicle

	Model, // Holds the vehicle-model of this vehicle
	PaintJob, // Holds the ID of the paintjob applied to the vehicle
	Components[14], // Holds all Component-ID's for all components on the vehicle
	Color1, // Holds the primary color for this vehicle
	Color2, // Holds the secundairy color for this vehicle

	Float:SpawnX, // Holds the X-coordinate of the parking spot for this vehicle
	Float:SpawnY, // Holds the Y-coordinate of the parking spot for this vehicle
	Float:SpawnZ, // Holds the Z-coordinate of the parking spot for this vehicle
	Float:SpawnRot // Holds the rotation of the parking spot for this vehicle
}
// Setup an array which holds all data for every vehicle, max 2000 vehicles (server limit)
new AVehicleData[2000][TVehicleData];



// Setup all the fields required for the player data (Speedometer TextDraw, current job, ...)
enum TPlayerData
{
	Houses[20], // Holds the HouseID's of the houses that the player owns (index of the AHouseData array), maximum 20 houses per player
    CurrentHouse, // Holds the HouseID to track in which house the player currently is (used when accessing the housemenu)
	DialogBuyVClass,
	DialogGetCarHouseID
}
// Create an array to hold the playerdata for every player
new APlayerData[MAX_PLAYERS][TPlayerData];



// Setup a custom type that holds all data about a house-interior (selected when entering a house, based on the house-level)
enum THouseInterior
{
	InteriorName[50], // Holds the name of the interior
	InteriorID, // Holds the interior-id
	Float:IntX, // Holds the X-coordinate of the spawn-location where you enter the house
	Float:IntY, // Holds the Y-coordinate of the spawn-location where you enter the house
	Float:IntZ // Holds the Z-coordinate of the spawn-location where you enter the house
}
// Holds the data for all interiors for houses (each house-level has it's own interior)
new AHouseInteriors[][THouseInterior] =
{
	{"Dummy", 				0, 		0.0, 		0.0, 		0.0}, // Dummy interior (Level 0), as the house-level starts at 1
	{"Small motel room", 	10, 	2262.83, 	-1137.71, 	1050.63}, // Level 1
	{"Small house", 		2, 		2467.36, 	-1698.38, 	1013.51}, // Level 2
	{"Small house 2", 		1, 		223.00, 	1289.26, 	1082.20}, // Level 3
	{"Medium house", 		10, 	2260.76, 	-1210.45, 	1049.02}, // Level 4
	{"Medium house 2",		8, 		2365.42, 	-1131.85, 	1050.88}, // Level 5
	{"Duplex house",		12, 	2324.33, 	-1144.79, 	1050.71}, // Level 6
	{"Big house", 			15, 	295.14, 	1474.47, 	1080.52}, // Level 7
	{"Big duplex house", 	3, 		235.50, 	1189.17, 	1080.34}, // Level 8
	{"Huge house", 			7, 		225.63, 	1022.48, 	1084.07}, // Level 9
	{"Mansion", 			5, 		1262.0366,	-785.1067,	1091.9063} // Level 10
};



// Setup a custom type that holds all data about a buyable vehicle
enum TBuyableVehicle
{
	CarName[50], // Holds the name of the vehicle
	VehicleClass, // Holds the ID of the vehicleclass
	CarModel, // Holds the model-ID of the vehicle
	Price // Holds the price for the vehicle (renting it will be 10% of this price)
}
new ABuyableVehicles[][TBuyableVehicle] =
{
	{"Admiral", VClassSaloons, 445, 50000},
	{"Alpha", VClassSportCar, 602, 50000},
	{"Ambulance", VClassPublic, 416, 50000},
	{"Andromada", VClassPlane, 592, 50000},
	{"Article Trailer", VClassTrailer, 591, 50000},
//	{"AT400", VClassPlane, 577, 50000},
	{"Baggage", VClassUnique, 485, 50000},
	{"Baggage Trailer A", VClassTrailer, 606, 50000},
	{"Baggage Trailer B", VClassTrailer, 607, 50000},
	{"Bandito", VClassOffRoad, 568, 50000},
	{"Banshee", VClassSportCar, 429, 50000},
	{"Barracks", VClassPublic, 433, 50000},
	{"Beagle", VClassPlane, 511, 50000},
	{"Benson", VClassIndustrial, 499, 50000},
	{"Berkley's RC Van", VClassIndustrial, 459, 50000},
	{"BF Injection", VClassOffRoad, 424, 50000},
	{"BF-400", VClassBike, 581, 50000},
	{"Bike", VClassBike, 509, 50000},
	{"Blade", VClassLowRider, 536, 50000},
	{"Blista Compact", VClassSportCar, 496, 50000},
	{"Bloodring Banger", VClassSaloons, 504, 50000},
	{"BMX", VClassBike, 481, 50000},
	{"Bobcat", VClassIndustrial, 422, 50000},
	{"Boxville 1", VClassIndustrial, 498, 50000},
	{"Boxville 2", VClassIndustrial, 609, 50000},
	{"Bravura", VClassSaloons, 401, 50000},
	{"Broadway", VClassLowRider, 575, 50000},
//	{"Brownstreak (train)", VClassUnique, 538, 50000},
	{"Buccaneer", VClassSaloons, 518, 50000},
	{"Buffalo", VClassSportCar, 402, 50000},
	{"Bullet", VClassSportCar, 541, 50000},
	{"Burrito", VClassIndustrial, 482, 50000},
	{"Bus", VClassPublic, 431, 50000},
	{"Cabbie", VClassPublic, 438, 50000},
	{"Caddy", VClassUnique, 457, 50000},
	{"Cadrona", VClassSaloons, 527, 50000},
	{"Camper", VClassUnique, 483, 50000},
	{"Cargo Trailer", VClassTrailer, 435, 50000},
	{"Cargobob", VClassHelicopter, 548, 50000},
	{"Cement Truck", VClassIndustrial, 524, 50000},
	{"Cheetah", VClassSportCar, 415, 50000},
	{"Clover", VClassSaloons, 542, 50000},
	{"Club", VClassSportCar, 589, 50000},
	{"Coach", VClassPublic, 437, 50000},
	{"Coastguard", VClassBoat, 472, 50000},
	{"Combine Harvester", VClassUnique, 532, 50000},
	{"Comet", VClassConvertible, 480, 50000},
	{"Cropduster", VClassPlane, 512, 50000},
	{"DFT-30", VClassIndustrial, 578, 50000},
	{"Dinghy", VClassBoat, 473, 50000},
	{"Dodo", VClassPlane, 593, 50000},
	{"Dozer", VClassUnique, 486, 50000},
	{"Dumper", VClassUnique, 406, 50000},
	{"Dune", VClassOffRoad, 573, 50000},
	{"Elegant", VClassSaloons, 507, 50000},
	{"Elegy", VClassSaloons, 562, 50000},
	{"Emperor", VClassSaloons, 585, 50000},
	{"Enforcer", VClassPublic, 427, 50000},
	{"Esperanto", VClassSaloons, 419, 50000},
	{"Euros", VClassSportCar, 587, 50000},
	{"Faggio", VClassBike, 462, 50000},
	{"Farm Trailer", VClassTrailer, 610, 50000},
	{"FBI Rancher", VClassPublic, 490, 50000},
	{"FBI Truck", VClassPublic, 528, 50000},
	{"FCR-900", VClassBike, 521, 50000},
	{"Feltzer", VClassConvertible, 533, 50000},
	{"Firetruck", VClassPublic, 407, 50000},
	{"Firetruck LA", VClassPublic, 544, 50000},
	{"Flash", VClassSportCar, 565, 50000},
	{"Flatbed", VClassIndustrial, 455, 50000},
	{"Fluids Trailer", VClassTrailer, 584, 50000},
	{"Forklift", VClassUnique, 530, 50000},
	{"Fortune", VClassSaloons, 526, 50000},
	{"Freeway", VClassBike, 463, 50000},
//	{"Freight (train)", VClassUnique, 537, 50000},
//	{"Freight Box Trailer (train)", VClassTrailer, 590, 50000},
//	{"Freight Flat Trailer (train)", VClassTrailer, 569, 50000},
	{"Glendale", VClassSaloons, 466, 50000},
	{"Glendale Shit", VClassSaloons, 604, 50000},
	{"Greenwood", VClassSaloons, 492, 50000},
	{"Hermes", VClassSaloons, 474, 50000},
	{"Hotdog", VClassUnique, 588, 50000},
	{"Hotknife", VClassUnique, 434, 50000},
	{"Hotring Racer 1", VClassSportCar, 494, 50000},
	{"Hotring Racer 2", VClassSportCar, 502, 50000},
	{"Hotring Racer 3", VClassSportCar, 503, 50000},
	{"HPV1000", VClassPublic, 523, 50000},
	{"Hunter", VClassHelicopter, 425, 50000},
	{"Huntley", VClassOffRoad, 579, 50000},
	{"Hustler", VClassUnique, 545, 50000},
	{"Hydra", VClassPlane, 520, 50000},
	{"Infernus", VClassSportCar, 411, 50000},
	{"Intruder", VClassSaloons, 546, 50000},
	{"Jester", VClassSportCar, 559, 50000},
	{"Jetmax", VClassBoat, 493, 50000},
	{"Journey", VClassUnique, 508, 50000},
	{"Kart", VClassUnique, 571, 50000},
	{"Landstalker", VClassOffRoad, 400, 50000},
	{"Launch", VClassBoat, 595, 50000},
	{"Leviathan", VClassHelicopter, 417, 50000},
	{"Linerunner", VClassIndustrial, 403, 50000},
	{"Majestic", VClassSaloons, 517, 50000},
	{"Manana", VClassSaloons, 410, 50000},
	{"Marquis", VClassBoat, 484, 50000},
	{"Maverick", VClassHelicopter, 487, 50000},
	{"Merit", VClassSaloons, 551, 50000},
	{"Mesa", VClassOffRoad, 500, 50000},
	{"Monster", VClassOffRoad, 444, 50000},
	{"Monster A", VClassOffRoad, 556, 50000},
	{"Monster B", VClassOffRoad, 557, 50000},
	{"Moonbeam", VClassStationCar, 418, 50000},
	{"Mountain Bike", VClassBike, 510, 50000},
	{"Mower", VClassUnique, 572, 50000},
	{"Mr Whoopee", VClassUnique, 423, 50000},
	{"Mule", VClassIndustrial, 414, 50000},
	{"Nebula", VClassSaloons, 516, 50000},
	{"Nevada", VClassPlane, 553, 50000},
	{"Newsvan", VClassIndustrial, 582, 50000},
	{"NRG-500", VClassBike, 522, 50000},
	{"Oceanic", VClassSaloons, 467, 50000},
	{"Ore Trailer", VClassTrailer, 450, 50000},
	{"Packer", VClassIndustrial, 443, 50000},
	{"Patriot", VClassOffRoad, 470, 50000},
	{"PCJ-600", VClassBike, 461, 50000},
	{"Perenniel", VClassStationCar, 404, 50000},
	{"Phoenix", VClassSportCar, 603, 50000},
	{"Picador", VClassIndustrial, 600, 50000},
	{"Pizzaboy", VClassBike, 448, 50000},
	{"Police Car (LSPD)", VClassPublic, 596, 50000},
	{"Police Car (LVPD)", VClassPublic, 598, 50000},
	{"Police Car (SFPD)", VClassPublic, 597, 50000},
	{"Police Maverick", VClassHelicopter, 497, 50000},
	{"Police Ranger", VClassPublic, 599, 50000},
	{"Pony", VClassIndustrial, 413, 50000},
	{"Predator", VClassBoat, 430, 50000},
	{"Premier", VClassSaloons, 426, 50000},
	{"Previon", VClassSaloons, 436, 50000},
	{"Primo", VClassSaloons, 547, 50000},
	{"Quad", VClassBike, 471, 50000},
	{"Raindance", VClassHelicopter, 563, 50000},
	{"Rancher 1", VClassOffRoad, 489, 50000},
	{"Rancher 2", VClassOffRoad, 505, 50000},
//	{"RC Bandit", VClassRCVehicle, 441, 50000},
//	{"RC Baron", VClassRCVehicle, 464, 50000},
//	{"RC Cam", VClassRCVehicle, 594, 50000},
//	{"RC Goblin", VClassRCVehicle, 501, 50000},
//	{"RC Raider", VClassRCVehicle, 465, 50000},
//	{"RC Tiger", VClassRCVehicle, 564, 50000},
	{"Reefer", VClassBoat, 453, 50000},
	{"Regina", VClassStationCar, 479, 50000},
	{"Remington", VClassLowRider, 534, 50000},
	{"Rhino", VClassPublic, 432, 50000},
	{"Roadtrain", VClassIndustrial, 515, 50000},
	{"Romero", VClassUnique, 442, 50000},
	{"Rumpo", VClassIndustrial, 440, 50000},
	{"Rustler", VClassPlane, 476, 50000},
	{"Sabre", VClassSportCar, 475, 50000},
	{"Sadler", VClassIndustrial, 543, 50000},
	{"Sadler Shit", VClassIndustrial, 605, 50000},
	{"SAN News Maverick", VClassHelicopter, 488, 50000},
	{"Sanchez", VClassBike, 468, 50000},
	{"Sandking", VClassOffRoad, 495, 50000},
	{"Savanna", VClassLowRider, 567, 50000},
	{"Seasparrow", VClassHelicopter, 447, 50000},
	{"Securicar", VClassUnique, 428, 50000},
	{"Sentinel", VClassSaloons, 405, 50000},
	{"Shamal", VClassPlane, 519, 50000},
	{"Skimmer", VClassPlane, 460, 50000},
	{"Slamvan", VClassLowRider, 535, 50000},
	{"Solair", VClassStationCar, 458, 50000},
	{"Sparrow", VClassHelicopter, 469, 50000},
	{"Speeder", VClassBoat, 452, 50000},
	{"Squallo", VClassBoat, 446, 50000},
	{"Stafford", VClassSaloons, 580, 50000},
	{"Stallion", VClassConvertible, 439, 50000},
	{"Stratum", VClassStationCar, 561, 50000},
//	{"Streak Trailer (train)", VClassTrailer, 570, 50000},
	{"Stretch", VClassUnique, 409, 50000},
	{"Stuntplane", VClassPlane, 513, 50000},
	{"Sultan", VClassSaloons, 560, 50000},
	{"Sunrise", VClassSaloons, 550, 50000},
	{"Super GT", VClassSportCar, 506, 50000},
	{"S.W.A.T.", VClassPublic, 601, 50000},
	{"Sweeper", VClassUnique, 574, 50000},
	{"Tahoma", VClassLowRider, 566, 50000},
	{"Tampa", VClassSaloons, 549, 50000},
	{"Tanker", VClassIndustrial, 514, 50000},
	{"Taxi", VClassPublic, 420, 50000},
	{"Tornado", VClassLowRider, 576, 50000},
	{"Towtruck", VClassUnique, 525, 50000},
	{"Tractor", VClassIndustrial, 531, 50000},
//	{"Tram", VClassUnique, 449, 50000},
	{"Trashmaster", VClassIndustrial, 408, 50000},
	{"Tropic", VClassBoat, 454, 50000},
	{"Tug", VClassUnique, 583, 50000},
	{"Tug Stairs Trailer", VClassTrailer, 608, 50000},
	{"Turismo", VClassSportCar, 451, 50000},
	{"Uranus", VClassSportCar, 558, 50000},
	{"Utility Trailer", VClassTrailer, 611, 50000},
	{"Utility Van", VClassIndustrial, 552, 50000},
	{"Vincent", VClassSaloons, 540, 50000},
	{"Virgo", VClassSaloons, 491, 50000},
	{"Voodoo", VClassLowRider, 412, 50000},
	{"Vortex", VClassUnique, 539, 50000},
	{"Walton", VClassIndustrial, 478, 50000},
	{"Washington", VClassSaloons, 421, 50000},
	{"Wayfarer", VClassBike, 586, 50000},
	{"Willard", VClassSaloons, 529, 50000},
	{"Windsor", VClassConvertible, 555, 50000},
    {"Yankee", VClassIndustrial, 456, 50000},
	{"Yosemite", VClassIndustrial, 554, 50000},
	{"ZR-350", VClassSportCar, 477, 50000}
};



// Setup an array that holds all prices for vehicle-components
new AVehicleModPrices[] =
{
	400, // ID 1000, Spoiler Pro								Certain Transfender cars
	550, // ID 1001, Spoiler Win								Certain Transfender cars
	200, // ID 1002, Spoiler Drag								Certain Transfender cars
	250, // ID 1003, Spoiler Alpha								Certain Transfender cars
	100, // ID 1004, Hood Champ Scoop							Certain Transfender cars
	150, // ID 1005, Hood Fury Scoop							Certain Transfender cars
	80, // ID 1006, Roof Roof Scoop								Certain Transfender cars
	500, // ID 1007, Sideskirt Right Sideskirt					Certain Transfender cars
	500, // ID 1008, Nitro 5 times								Most cars, Most planes and Most Helicopters
	200, // ID 1009, Nitro 2 times								Most cars, Most planes and Most Helicopters
	1000, // ID 1010, Nitro 10 times                 			Most cars, Most planes and Most Helicopters
	220, // ID 1011, Hood Race Scoop                			Certain Transfender cars
	250, // ID 1012, Hood Worx Scoop                			Certain Transfender cars
	100, // ID 1013, Lamps Round Fog                			Certain Transfender cars
	400, // ID 1014, Spoiler Champ                  			Certain Transfender cars
	500, // ID 1015, Spoiler Race                   			Certain Transfender cars
	200, // ID 1016, Spoiler Worx                   			Certain Transfender cars
	500, // ID 1017, Sideskirt Left Sideskirt       			Certain Transfender cars
	350, // ID 1018, Exhaust Upswept                			Most cars
	300, // ID 1019, Exhaust Twin                   			Most cars
	250, // ID 1020, Exhaust Large                  			Most cars
	200, // ID 1021, Exhaust Medium								Most cars
	150, // ID 1022, Exhaust Small								Most cars
	350, // ID 1023, Spoiler Fury                   			Certain Transfender cars
	50, // ID 1024, Lamps Square Fog							Certain Transfender cars
	1000, // ID 1025, Wheels Offroad							Certain Transfender cars
	480, // ID 1026, Sideskirt Right Alien Sideskirt			Sultan
	480, // ID 1027, Sideskirt Left Alien Sideskirt				Sultan
	770, // ID 1028, Exhaust Alien                      		Sultan
	680, // ID 1029, Exhaust X-Flow								Sultan
	370, // ID 1030, Sideskirt Left X-Flow Sideskirt    		Sultan
	370, // ID 1031, Sideskirt Right X-Flow Sideskirt   		Sultan
	170, // ID 1032, Roof Alien Roof Vent						Sultan
	120, // ID 1033, Roof X-Flow Roof Vent              		Sultan
	790, // ID 1034, Exhaust Alien								Elegy
	150, // ID 1035, Roof X-Flow Roof Vent						Elegy
	500, // ID 1036, SideSkirt Right Alien Sideskirt    		Elegy
	690, // ID 1037, Exhaust X-Flow								Elegy
	190, // ID 1038, Roof Alien Roof Vent						Elegy
	390, // ID 1039, SideSkirt Right X-Flow Sideskirt   		Elegy
	500, // ID 1040, SideSkirt Left Alien Sideskirt				Elegy
	390, // ID 1041, SideSkirt Right X-Flow Sideskirt   		Elegy
	1000, // ID 1042, SideSkirt Right Chrome Sideskirt			Broadway
	500, // ID 1043, Exhaust Slamin                     		Broadway
	500, // ID 1044, Exhaust Chrome								Broadway
	510, // ID 1045, Exhaust X-Flow								Flash
	710, // ID 1046, Exhaust Alien								Flash
	670, // ID 1047, SideSkirt Right Alien Sideskirt    		Flash
	530, // ID 1048, SideSkirt Right X-Flow Sideskirt			Flash
	810, // ID 1049, Spoiler Alien								Flash
	620, // ID 1050, Spoiler X-Flow                     		Flash
	670, // ID 1051, SideSkirt Left Alien Sideskirt     		Flash
	530, // ID 1052, SideSkirt Left X-Flow Sideskirt			Flash
	130, // ID 1053, Roof X-Flow								Flash
	210, // ID 1054, Roof Alien									Flash
	230, // ID 1055, Roof Alien									Stratum
	520, // ID 1056, Sideskirt Right Alien Sideskirt			Stratum
	430, // ID 1057, Sideskirt Right X-Flow Sideskirt			Stratum
	620, // ID 1058, Spoiler Alien								Stratum
	720, // ID 1059, Exhaust X-Flow								Stratum
	530, // ID 1060, Spoiler X-Flow								Stratum
	180, // ID 1061, Roof X-Flow								Stratum
	520, // ID 1062, Sideskirt Left Alien Sideskirt				Stratum
	430, // ID 1063, Sideskirt Left X-Flow Sideskirt			Stratum
	830, // ID 1064, Exhaust Alien								Stratum
	850, // ID 1065, Exhaust Alien								Jester
	750, // ID 1066, Exhaust X-Flow								Jester
	250, // ID 1067, Roof Alien									Jester
	200, // ID 1068, Roof X-Flow								Jester
	550, // ID 1069, Sideskirt Right Alien Sideskirt			Jester
	450, // ID 1070, Sideskirt Right X-Flow Sideskirt			Jester
	550, // ID 1071, Sideskirt Left Alien Sideskirt				Jester
	450, // ID 1072, Sideskirt Left X-Flow Sideskirt			Jester
	1100, // ID 1073, Wheels Shadow								Most cars
	1030, // ID 1074, Wheels Mega								Most cars
	980, // ID 1075, Wheels Rimshine							Most cars
	1560, // ID 1076, Wheels Wires								Most cars
	1620, // ID 1077, Wheels Classic							Most cars
	1200, // ID 1078, Wheels Twist								Most cars
	1030, // ID 1079, Wheels Cutter								Most cars
	900, // ID 1080, Wheels Switch								Most cars
	1230, // ID 1081, Wheels Grove								Most cars
	820, // ID 1082, Wheels Import								Most cars
	1560, // ID 1083, Wheels Dollar								Most cars
	1350, // ID 1084, Wheels Trance								Most cars
	770, // ID 1085, Wheels Atomic								Most cars
	100, // ID 1086, Stereo Stereo								Most cars
	1500, // ID 1087, Hydraulics Hydraulics						Most cars
	150, // ID 1088, Roof Alien									Uranus
	650, // ID 1089, Exhaust X-Flow								Uranus
	450, // ID 1090, Sideskirt Right Alien Sideskirt			Uranus
	100, // ID 1091, Roof X-Flow								Uranus
	750, // ID 1092, Exhaust Alien								Uranus
	350, // ID 1093, Sideskirt Right X-Flow Sideskirt			Uranus
	450, // ID 1094, Sideskirt Left Alien Sideskirt				Uranus
	350, // ID 1095, Sideskirt Right X-Flow Sideskirt			Uranus
	1000, // ID 1096, Wheels Ahab								Most cars
	620, // ID 1097, Wheels Virtual								Most cars
	1140, // ID 1098, Wheels Access								Most cars
	1000, // ID 1099, Sideskirt Left Chrome Sideskirt			Broadway
	940, // ID 1100, Bullbar Chrome Grill						Remington
	780, // ID 1101, Sideskirt Left `Chrome Flames` Sideskirt	Remington
	830, // ID 1102, Sideskirt Left `Chrome Strip` Sideskirt	Savanna
	3250, // ID 1103, Roof Convertible							Blade
	1610, // ID 1104, Exhaust Chrome							Blade
	1540, // ID 1105, Exhaust Slamin							Blade
	780, // ID 1106, Sideskirt Right `Chrome Arches`			Remington
	780, // ID 1107, Sideskirt Left `Chrome Strip` Sideskirt	Blade
	780, // ID 1108, Sideskirt Right `Chrome Strip` Sideskirt	Blade
	1610, // ID 1109, Rear Bullbars Chrome						Slamvan
	1540, // ID 1110, Rear Bullbars Slamin						Slamvan
	55, // ID 1111, Front Sign? Little Sign?					Slamvan         ???
	55, // ID 1112, Front Sign? Little Sign?					Slamvan         ???
	3340, // ID 1113, Exhaust Chrome							Slamvan
	3250, // ID 1114, Exhaust Slamin							Slamvan
	2130, // ID 1115, Front Bullbars Chrome						Slamvan
	2050, // ID 1116, Front Bullbars Slamin						Slamvan
	2040, // ID 1117, Front Bumper Chrome						Slamvan
	780, // ID 1118, Sideskirt Right `Chrome Trim` Sideskirt	Slamvan
	940, // ID 1119, Sideskirt Right `Wheelcovers` Sideskirt	Slamvan
	780, // ID 1120, Sideskirt Left `Chrome Trim` Sideskirt		Slamvan
	940, // ID 1121, Sideskirt Left `Wheelcovers` Sideskirt		Slamvan
	780, // ID 1122, Sideskirt Right `Chrome Flames` Sideskirt	Remington
	860, // ID 1123, Bullbars Bullbar Chrome Bars				Remington
	780, // ID 1124, Sideskirt Left `Chrome Arches` Sideskirt	Remington
	1120, // ID 1125, Bullbars Bullbar Chrome Lights			Remington
	3340, // ID 1126, Exhaust Chrome Exhaust					Remington
	3250, // ID 1127, Exhaust Slamin Exhaust					Remington
	3340, // ID 1128, Roof Vinyl Hardtop						Blade
	1650, // ID 1129, Exhaust Chrome							Savanna
	3380, // ID 1130, Roof Hardtop								Savanna
	3290, // ID 1131, Roof Softtop								Savanna
	1590, // ID 1132, Exhaust Slamin							Savanna
	830, // ID 1133, Sideskirt Right `Chrome Strip` Sideskirt	Savanna
	800, // ID 1134, SideSkirt Right `Chrome Strip` Sideskirt	Tornado
	1500, // ID 1135, Exhaust Slamin							Tornado
	1000, // ID 1136, Exhaust Chrome							Tornado
	800, // ID 1137, Sideskirt Left `Chrome Strip` Sideskirt	Tornado
	580, // ID 1138, Spoiler Alien								Sultan
	470, // ID 1139, Spoiler X-Flow								Sultan
	870, // ID 1140, Rear Bumper X-Flow							Sultan
	980, // ID 1141, Rear Bumper Alien							Sultan
	150, // ID 1142, Vents Left Oval Vents						Certain Transfender Cars
	150, // ID 1143, Vents Right Oval Vents						Certain Transfender Cars
	100, // ID 1144, Vents Left Square Vents					Certain Transfender Cars
	100, // ID 1145, Vents Right Square Vents					Certain Transfender Cars
	490, // ID 1146, Spoiler X-Flow								Elegy
	600, // ID 1147, Spoiler Alien								Elegy
	890, // ID 1148, Rear Bumper X-Flow							Elegy
	1000, // ID 1149, Rear Bumper Alien							Elegy
	1090, // ID 1150, Rear Bumper Alien							Flash
	840, // ID 1151, Rear Bumper X-Flow							Flash
	910, // ID 1152, Front Bumper X-Flow						Flash
	1200, // ID 1153, Front Bumper Alien						Flash
	1030, // ID 1154, Rear Bumper Alien							Stratum
	1030, // ID 1155, Front Bumper Alien						Stratum
	920, // ID 1156, Rear Bumper X-Flow							Stratum
	930, // ID 1157, Front Bumper X-Flow						Stratum
	550, // ID 1158, Spoiler X-Flow								Jester
	1050, // ID 1159, Rear Bumper Alien							Jester
	1050, // ID 1160, Front Bumper Alien						Jester
	950, // ID 1161, Rear Bumper X-Flow							Jester
	650, // ID 1162, Spoiler Alien								Jester
	450, // ID 1163, Spoiler X-Flow								Uranus
	550, // ID 1164, Spoiler Alien								Uranus
	850, // ID 1165, Front Bumper X-Flow						Uranus
	950, // ID 1166, Front Bumper Alien							Uranus
	850, // ID 1167, Rear Bumper X-Flow							Uranus
	950, // ID 1168, Rear Bumper Alien							Uranus
	970, // ID 1169, Front Bumper Alien							Sultan
	880, // ID 1170, Front Bumper X-Flow						Sultan
	990, // ID 1171, Front Bumper Alien							Elegy
	900, // ID 1172, Front Bumper X-Flow						Elegy
	950, // ID 1173, Front Bumper X-Flow						Jester
	1000, // ID 1174, Front Bumper Chrome						Broadway
	900, // ID 1175, Front Bumper Slamin						Broadway
	1000, // ID 1176, Rear Bumper Chrome						Broadway
	900, // ID 1177, Rear Bumper Slamin							Broadway
	2050, // ID 1178, Rear Bumper Slamin						Remington
	2150, // ID 1179, Front Bumper Chrome						Remington
	2130, // ID 1180, Rear Bumper Chrome						Remington
	2050, // ID 1181, Front Bumper Slamin						Blade
	2130, // ID 1182, Front Bumper Chrome						Blade
	2040, // ID 1183, Rear Bumper Slamin						Blade
	2150, // ID 1184, Rear Bumper Chrome						Blade
	2040, // ID 1185, Front Bumper Slamin						Remington
	2095, // ID 1186, Rear Bumper Slamin						Savanna
	2175, // ID 1187, Rear Bumper Chrome						Savanna
	2080, // ID 1188, Front Bumper Slamin						Savanna
	2200, // ID 1189, Front Bumper Chrome						Savanna
	1200, // ID 1190, Front Bumper Slamin						Tornado
	1040, // ID 1191, Front Bumper Chrome						Tornado
	940, // ID 1192, Rear Bumper Chrome							Tornado
	1100, // ID 1193 Rear Bumper Slamin							Tornado
};



// These variables are used when starting the script and debugging purposes
new TotalHouses;



// ******************************************************************************************************************************
// Callbacks
// ******************************************************************************************************************************

// The main function (used only once when the server loads)
main()
{
}

// This callback gets called when the server initializes the filterscript
public OnFilterScriptInit()
{
	// Loop through all houses and try to load them (HouseID 0 isn't used)
	for (new HouseID = 1; HouseID < MAX_HOUSES; HouseID++)
	{
	    // Try to load the house-file
		HouseFile_Load(HouseID);

		// Load housecars too if chosen to do so
		if (LoadCarsDuringFSInit == true)
		    HouseFile_LoadCars(HouseID);
	}

	// Add some icons to the map (modding garages), they will only appear when the player discovers them
	CreateDynamicMapIcon(1039, -1032, 32, 27, 0, 0, 0, -1, 150.0); // Transfender, Los Santos
	CreateDynamicMapIcon(-1936, 235, 34, 27, 0, 0, 0, -1, 150.0); // Transfender, San Fierro
	CreateDynamicMapIcon(2385, 1034, 11, 27, 0, 0, 0, -1, 150.0); // Transfender, Las Venturas
	CreateDynamicMapIcon(2646, -2025, 14, 27, 0, 0, 0, -1, 150.0); // Loco Low Co, Los Santos
	CreateDynamicMapIcon(-2712, 218, 4, 27, 0, 0, 0, -1, 150.0); // Wheel Arch Angels, San Fierro

	// Print information about the filterscript on the server-console
    printf("----------------------------------------");
    printf("PPC Housing filterscript initialized");
    printf("Houses loaded: %i", TotalHouses);
    printf("----------------------------------------");

    return 1;
}

// This callback gets called when a player connects to the server
public OnPlayerConnect(playerid)
{
	// Setup local variables
	new HouseID, HouseSlot, Name[24];

	// Get the player's name
	GetPlayerName(playerid, Name, sizeof(Name));

	// Loop through all houses to find the ones which belong to this player
	for (HouseID = 1; HouseID < MAX_HOUSES; HouseID++)
	{
		// Check if the house exists
		if (IsValidDynamicPickup(AHouseData[HouseID][PickupID]))
		{
		    // Check if the house is owned
		    if (AHouseData[HouseID][Owned] == true)
		    {
		        // Check if the player is the owner of the house
				if (strcmp(AHouseData[HouseID][Owner], Name, false) == 0)
				{
					// Add the HouseID to the player's account for faster reference later on
					APlayerData[playerid][Houses][HouseSlot] = HouseID;

					// Load housecars if they weren't loaded at FilterscriptInit
					if (LoadCarsDuringFSInit == false)
					    HouseFile_LoadCars(HouseID);

					// Select the next HouseSlot
					HouseSlot++;
				}
		    }
		}
	}

	return 1;
}

// This callback gets called when a player disconnects from the server
public OnPlayerDisconnect(playerid, reason)
{
	// Setup local variables
	new HouseSlot;

	// Loop through all Houses the player owns
	for (HouseSlot = 0; HouseSlot < MAX_HOUSESPERPLAYER; HouseSlot++)
	{
		// Check if the player has a house in this houseslot
		if (APlayerData[playerid][Houses][HouseSlot] != 0)
		{
		    // Save the housefile
			HouseFile_Save(APlayerData[playerid][Houses][HouseSlot]);

			// Unload housecars if they were loaded when the owner logged in
			if (LoadCarsDuringFSInit == false)
			{
			    // Unload all vehicles assigned to this house
				House_RemoveVehicles(APlayerData[playerid][Houses][HouseSlot]);
			}

		    // Clear the HouseID stored in this houseslot
			APlayerData[playerid][Houses][HouseSlot] = 0;
		}
	}

	// Clear all data for this player
	APlayerData[playerid][CurrentHouse] = 0;
	APlayerData[playerid][DialogBuyVClass] = 0;
	APlayerData[playerid][DialogGetCarHouseID] = 0;

	return 1;
}

// This callback gets called when a player interacts with a dialog
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	// Select the proper dialog to process
	switch (dialogid)
	{
		case DialogHouseMenu: Dialog_HouseMenu(playerid, response, listitem); // Process the main housemenu
		case DialogUpgradeHouse: Dialog_UpgradeHouse(playerid, response, listitem); // Process the house-upgrade menu
		case DialogGoHome: Dialog_GoHome(playerid, response, listitem); // Port to one of your houses
		case DialogHouseNameChange: Dialog_ChangeHouseName(playerid, response, inputtext); // Change the name of your house
		case DialogSellHouse: Dialog_SellHouse(playerid, response); // Sell the house
		case DialogBuyCarClass: Dialog_BuyCarClass(playerid, response, listitem); // The player chose a vehicleclass from where he can buy a vehicle
		case DialogBuyCar: Dialog_BuyCar(playerid, response, listitem); // The player chose a vehicle from the list of vehicles from the vehicleclass he chose before
		case DialogSellCar: Dialog_SellCar(playerid, response, listitem);
		case DialogBuyInsurance: Dialog_BuyInsurance(playerid, response);
		case DialogGetCarSelectHouse: Dialog_GetCarSelectHouse(playerid, response, listitem);
		case DialogGetCarSelectCar: Dialog_GetCarSelectCar(playerid, response, listitem);
	}

    return 0;
}

// This callback gets called when a player spawns somewhere
public OnPlayerSpawn(playerid)
{
	// Setup local variables
	new HouseID;

	// Reset the HouseID where the player is located
	APlayerData[playerid][CurrentHouse] = 0;

	// If SpawnAtHouse is set to "true", re-position the player at the first house in his list of owned houses
	if (SpawnAtHouse == true)
	{
		// Get the first HouseID in your list of owned houses
		HouseID = APlayerData[playerid][Houses][0];
		// Check if the player has a house in this first slot
		if (HouseID != 0)
		{
			// Re-position the player at the house's coordinates
			SetPlayerPos(playerid, AHouseData[HouseID][HouseX], AHouseData[HouseID][HouseY], AHouseData[HouseID][HouseZ]);
		}
	}

	return 1;
}

// This callback gets called whenever a player dies
public OnPlayerDeath(playerid, killerid, reason)
{
	// Reset the HouseID where the player is located
	APlayerData[playerid][CurrentHouse] = 0;

	return 1;
}

// This callback gets called when the player is selecting a class (but hasn't clicked "Spawn" yet)
public OnPlayerRequestClass(playerid, classid)
{
	// Reset the HouseID where the player is located
	APlayerData[playerid][CurrentHouse] = 0;

	return 1;
}

// This callback is called when the player attempts to spawn via class-selection
public OnPlayerRequestSpawn(playerid)
{
	// Reset the HouseID where the player is located
	APlayerData[playerid][CurrentHouse] = 0;

    return 1;
}

// This callback gets called when a vehicle respawns at it's spawn-location (where it was created)
public OnVehicleSpawn(vehicleid)
{
	// Only use this for house-vehicles
	if (AVehicleData[vehicleid][Owned] == true)
	{
		// Re-apply the paintjob (if any was applied)
		if (AVehicleData[vehicleid][PaintJob] != 0)
		{
		    // Re-apply the paintjob
			ChangeVehiclePaintjob(vehicleid, AVehicleData[vehicleid][PaintJob] - 1);
		}

		// Also update the car-color
		ChangeVehicleColor(vehicleid, AVehicleData[vehicleid][Color1], AVehicleData[vehicleid][Color2]);

		// Re-add all components that were installed (if they were there)
		for (new i; i < 14; i++)
		{
			// Remove all mods from the vehicle (all added mods applied by hackers will hopefully be removed this way when the vehicle respawns)
	        RemoveVehicleComponent(vehicleid, GetVehicleComponentInSlot(vehicleid, i));

		    // Check if the componentslot has a valid component-id
			if (AVehicleData[vehicleid][Components][i] != 0)
		        AddVehicleComponent(vehicleid, AVehicleData[vehicleid][Components][i]); // Add the component to the vehicle
		}
	}

    return 1;
}

// This callback is called when the vehicle leaves a mod shop
public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	// Only use this for house-vehicles
	if (AVehicleData[vehicleid][Owned] == true)
	{
		// Let the player pay $150 for changing the color (if they have been changed)
		if ((AVehicleData[vehicleid][Color1] != color1) || (AVehicleData[vehicleid][Color2] != color2))
			INT_GivePlayerMoney(playerid, -150);

		// Save the colors
		AVehicleData[vehicleid][Color1] = color1;
		AVehicleData[vehicleid][Color2] = color2;

		// If the primary color is black, remove the paintjob
		if (color1 == 0)
			AVehicleData[vehicleid][PaintJob] = 0;
	}

	return 1;
}

// This callback gets called whenever a player mods his vehicle
public OnVehicleMod(playerid, vehicleid, componentid)
{
	// Only use this for house-vehicles
	if (AVehicleData[vehicleid][Owned] == true)
	{
		// When the player changes a component of his vehicle, reduce the price of the component from the player's money
		INT_GivePlayerMoney(playerid, -AVehicleModPrices[componentid - 1000]);

		// Store the component in the AVehicleData array
		AVehicleData[vehicleid][Components][GetVehicleComponentType(componentid)] = componentid;
	}

	return 1;
}

// This callback gets called whenever a player VIEWS at a paintjob in a mod garage (viewing automatically applies it)
public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	// Only use this for house-vehicles
	if (AVehicleData[vehicleid][Owned] == true)
	{
		// Store the paintjobid for the vehicle (add 1 to the value, otherwise checking for an applied paintjob is difficult)
	    AVehicleData[vehicleid][PaintJob] = paintjobid + 1;
	}

	return 1;
}

// This callback gets called whenever a vehicle enters the water or is destroyed (explodes)
public OnVehicleDeath(vehicleid)
{
	// Setup local variables
	new HouseID, CarSlot;

	// Only use this for house-vehicles
	if (AVehicleData[vehicleid][Owned] == true)
	{
		// Get the houseid to which this vehicle belongs
		HouseID = AVehicleData[vehicleid][BelongsToHouse];

		// If automatic insurance has been turned off, check if the vehicle's house has insurance for the vehicle
		if (AutomaticInsurance == false)
		{
			// Check if this vehicle belongs to a house
			if (HouseID != 0)
			{
				// If the house doesn't have insurance for it's vehicles
				if (AHouseData[HouseID][Insurance] == false)
				{
					// Find the CarSlot where this vehicle is stored
					for (CarSlot = 0; CarSlot < 10; CarSlot++)
					{
						// Check if the vehicle is stored in this carslot
						if (AHouseData[HouseID][VehicleIDs][CarSlot] == vehicleid)
						    break; // Stop searching, because CarSlot now hold the carslot of the vehicle where it's stored
					}

				    // Delete the vehicle, clear the data and remove it from the house it belongs to
					Vehicle_Delete(vehicleid, HouseID, CarSlot);

				    // Save the house (and linked vehicles)
				    HouseFile_Save(HouseID);
				}
			}
		}
	}

	return 1;
}

// This callback gets called when the player changes state
public OnPlayerStateChange(playerid,newstate,oldstate)
{
	// Setup local variables
	new vid, Name[24], Msg[128], engine, lights, alarm, doors, bonnet, boot, objective;

	// Check if the player became the driver of a vehicle
	if (newstate == PLAYER_STATE_DRIVER)
	{
		// Get the ID of the player's vehicle
		vid = GetPlayerVehicleID(playerid);
		// Get the player's name
		GetPlayerName(playerid, Name, sizeof(Name));

		// Check if the vehicle is owned
		if (AVehicleData[vid][Owned] == true)
		{
			// Check if the vehicle is owned by somebody else (strcmp will not be 0)
			if (strcmp(AVehicleData[vid][Owner], Name, false) != 0)
			{
				// Force the player out of the vehicle
				RemovePlayerFromVehicle(playerid);
				// Turn off the lights and engine
				GetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);
				SetVehicleParamsEx(vid, 0, 0, alarm, doors, bonnet, boot, objective);
				// Let the player know he cannot use somebody else's vehicle
				format(Msg, 128, "{00FFFF}[INFO]: {FFFFFF}You cannot use this vehicle, it's owned by \"{FFFF00}%s{FF0000}\"", AVehicleData[vid][Owner]);
				SendClientMessage(playerid, 0xFFFFFFFF, Msg);
			}
		}
	}

	return 1;
}



// ******************************************************************************************************************************
// Commands
// ******************************************************************************************************************************

// Lets the player add new houses (a house that can be upgraded and where the houselevel determines the amount of carslots)
COMMAND:createhouse(playerid, params[])
{
    if(GetPVarInt(playerid, "minigun")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are in Minigun DM can't use any commands");
    if(GetPVarInt(playerid, "afk")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are In AFK mode can't use any commands");
	// If a player hasn't logged in properly, he cannot use this command
	if (INT_IsPlayerLoggedIn(playerid) == 0) return 0;
	// If the player has an insufficient admin-level (he needs level 5 or RCON admin), exit the command
	// returning "SERVER: Unknown command" to the player
	if (INT_CheckPlayerAdminLevel(playerid, 5) == 0) return 0;

	// Setup local variables
	new HPrice, MaxLevel, HouseID;

	// Check if the player isn't inside a vehicle (the admin-player must be on foot to use this command)
	if (GetPlayerVehicleSeat(playerid) == -1)
	{
		if (sscanf(params, "ii", HPrice, MaxLevel)) SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}/createhouse <price> <maxlevel (1-10)>");
		else
		{
			// Check if the player entered a proper maxlevel
			if ((MaxLevel >= 1) && (MaxLevel <= 10))
			{
				// Find the first free HouseID
				for (HouseID = 1; HouseID < MAX_HOUSES; HouseID++)
					if (!IsValidDynamicPickup(AHouseData[HouseID][PickupID])) // Check if an empty house-index has been found (PickupID is 0)
					    break; // Stop searching, the first free HouseID has been found now

			    // Check if the house-limit hasn't been reached yet
			    // This would seem to double-check the pickup-id, but in case there was no free houseslot found (HouseID points
				// to the last index, the last index would hold a house, so be sure to not overwrite it
				if (!IsValidDynamicPickup(AHouseData[HouseID][PickupID]))
				{
				    // Setup some local variables
					new Float:x, Float:y, Float:z, Msg[128];
					// Get the player's position
					GetPlayerPos(playerid, x, y, z);
					// Set some default data
					AHouseData[HouseID][Owned] = false;
					AHouseData[HouseID][Owner] = 0;
					AHouseData[HouseID][HouseX] = x;
					AHouseData[HouseID][HouseY] = y;
					AHouseData[HouseID][HouseZ] = z;
					AHouseData[HouseID][HouseLevel] = 1;
					AHouseData[HouseID][HouseMaxLevel] = MaxLevel;
					AHouseData[HouseID][HousePrice] = HPrice;
					AHouseData[HouseID][HouseOpened] = false;
					AHouseData[HouseID][Insurance] = false;
					AHouseData[HouseID][StaticHouse] = false;
					AHouseData[HouseID][CarSlots] = 1; // This must be equal to the house-level for a normal house

					// Add the pickup and 3DText at the location of the house-entrance (where the player is standing when he creates the house)
					House_UpdateEntrance(HouseID);

					// Save the house
					HouseFile_Save(HouseID);

					// Inform the player that he created a new house
					format(Msg, 128, "{00FF00}[INFO]: {FFFFFF}You've succesfully created a house with ID: {FFFF00}%i", HouseID);
					SendClientMessage(playerid, 0xFFFFFFFF, Msg);
				}
				else
				    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}The maximum amount of houses has been reached");
			}
			else
			    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You have to use a max-level from 1 to 10");
		}
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You must be on foot to create a house");

	// Let the server know that this was a valid command
	return 1;
}

// Lets the player add new houses (a house that cannot be upgraded, has a fixed interior and a fixed amount of carslots)
COMMAND:createstatichouse(playerid, params[])
{
    if(GetPVarInt(playerid, "minigun")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are in Minigun DM can't use any commands");
    if(GetPVarInt(playerid, "afk")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are not In AFK mode can't use any commands");
	// Setup local variables
	new HPrice, Carslots, HouseID, Interior;

	// If a player hasn't logged in properly, he cannot use this command
	if (INT_IsPlayerLoggedIn(playerid) == 0) return 0;
	// If the player has an insufficient admin-level (he needs level 5 or RCON admin), exit the command
	// returning "SERVER: Unknown command" to the player
	if (INT_CheckPlayerAdminLevel(playerid, 5) == 0) return 0;

	// Check if the player isn't inside a vehicle (the admin-player must be on foot to use this command)
	if (GetPlayerVehicleSeat(playerid) == -1)
	{
		if (sscanf(params, "iii", HPrice, Carslots, Interior)) SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}/createstatichouse <price> <Carslots (1-10)> <Interior (1-10)>");
		else
		{
			// Check if the player entered a proper amount of Carslots
			if ((Carslots >= 1) && (Carslots <= 10))
			{
				// Check if the player entered a valid interior
				if ((Interior >= 1) && (Interior <= 10))
				{
					// Find the first free HouseID
					for (HouseID = 1; HouseID < MAX_HOUSES; HouseID++)
						if (!IsValidDynamicPickup(AHouseData[HouseID][PickupID])) // Check if an empty house-index has been found (PickupID is 0)
						    break; // Stop searching, the first free HouseID has been found now

				    // Check if the house-limit hasn't been reached yet
				    // This would seem to double-check the pickup-id, but in case there was no free houseslot found (HouseID points
					// to the last index, the last index would hold a house, so be sure to not overwrite it
					if (!IsValidDynamicPickup(AHouseData[HouseID][PickupID]))
					{
					    // Setup some local variables
						new Float:x, Float:y, Float:z, Msg[128];
						// Get the player's position
						GetPlayerPos(playerid, x, y, z);
						// Set some default data
						AHouseData[HouseID][Owned] = false;
						AHouseData[HouseID][HouseX] = x;
						AHouseData[HouseID][HouseY] = y;
						AHouseData[HouseID][HouseZ] = z;
						AHouseData[HouseID][HouseLevel] = Interior; // The house-level indicates the static interior
						AHouseData[HouseID][HouseMaxLevel] = Interior;
						AHouseData[HouseID][HousePrice] = HPrice;
						AHouseData[HouseID][HouseOpened] = false;
						AHouseData[HouseID][Insurance] = false;
						AHouseData[HouseID][StaticHouse] = true;
						AHouseData[HouseID][CarSlots] = Carslots;

						// Add the pickup and 3DText at the location of the house-entrance (where the player is standing when he creates the house)
						House_UpdateEntrance(HouseID);

						// Save the house
						HouseFile_Save(HouseID);

						// Inform the player that he created a new house
						format(Msg, 128, "{00FF00}[INFO]: {FFFFFF}You've succesfully created a static house with ID: {FFFF00}%i", HouseID);
						SendClientMessage(playerid, 0xFFFFFFFF, Msg);
					}
					else
					    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}The maximum amount of houses has been reached");
				}
				else
				    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You have to use an interior-id from 1 to 10");
			}
			else
			    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You have to use a max amount of carslots from 1 to 10");
		}
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You must be on foot to create a house");

	// Let the server know that this was a valid command
	return 1;
}

// This command lets the player delete a house
COMMAND:delhouse(playerid, params[])
{
    if(GetPVarInt(playerid, "minigun")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are in Minigun DM can't use any commands");
	// If a player hasn't logged in properly, he cannot use this command
	if (INT_IsPlayerLoggedIn(playerid) == 0) return 0;
	// If the player has an insufficient admin-level (he needs level 5 or RCON admin), exit the command
	// returning "SERVER: Unknown command" to the player
	if (INT_CheckPlayerAdminLevel(playerid, 5) == 0) return 0;

	// Setup local variables
	new file[100], Msg[128], Name[24];

	// Check if the player isn't inside a vehicle (the admin-player must be on foot to use this command)
	if (GetPlayerVehicleSeat(playerid) == -1)
	{
		// Loop through all houses
		for (new HouseID = 1; HouseID < MAX_HOUSES; HouseID++)
		{
			// Check if the house exists
			if (IsValidDynamicPickup(AHouseData[HouseID][PickupID]))
			{
				// Check if the player is in range of the house-pickup
				if (IsPlayerInRangeOfPoint(playerid, 2.5, AHouseData[HouseID][HouseX], AHouseData[HouseID][HouseY], AHouseData[HouseID][HouseZ]))
				{
					// Get the name of the owner (if the house is owned)
					if (AHouseData[HouseID][Owned] == true)
					{
						// Loop through all players to find the owner (if he's online)
						for (new pid; pid < MAX_PLAYERS; pid++)
						{
							// Check if this player is online
						    if (INT_IsPlayerLoggedIn(playerid) == 1)
						    {
						        // Get that player's name
						        GetPlayerName(pid, Name, sizeof(Name));
						        // Compare if this player has the same name as the owner of the house
								if (strcmp(AHouseData[HouseID][Owner], Name, false) == 0)
								{
									// Inform the player that his house is being deleted
									format(Msg, 128, "{00FF00}[INFO]: {FFFFFF}Your house {FFFF00}%s{FFFFFF} is being deleted", AHouseData[HouseID][HouseName]);
									SendClientMessage(pid, 0xFFFFFFFF, Msg);

									// Also remove the HouseID from his list of houses
									for (new HouseSlot; HouseSlot < MAX_HOUSESPERPLAYER; HouseSlot++)
									    // Check if the house is stored in this houseslot
									    if (APlayerData[pid][Houses][HouseSlot] == HouseID)
									        // If the house is stored in this slot, clear the slot
									        APlayerData[pid][Houses][HouseSlot] = 0;

									// Stop this For-loop, as the owner was already found and informed
									break;
								}
						    }
						}
					}

					// First remove all vehicles from the house
					House_RemoveVehicles(HouseID);

					// Clear all data of the house
					AHouseData[HouseID][Owned] = false;
					AHouseData[HouseID][Owner] = 0;
					AHouseData[HouseID][HouseName] = 0;
					AHouseData[HouseID][Insurance] = false;
					AHouseData[HouseID][HouseX] = 0.0;
					AHouseData[HouseID][HouseY] = 0.0;
					AHouseData[HouseID][HouseZ] = 0.0;
					AHouseData[HouseID][HouseLevel] = 0;
					AHouseData[HouseID][HouseMaxLevel] = 0;
					AHouseData[HouseID][HousePrice] = 0;
					AHouseData[HouseID][HouseOpened] = false;
					AHouseData[HouseID][StaticHouse] = false;
					AHouseData[HouseID][CarSlots] = 0;
					// Destroy the mapicon, 3DText and pickup for the house
					DestroyDynamicPickup(AHouseData[HouseID][PickupID]);
					DestroyDynamicMapIcon(AHouseData[HouseID][MapIconID]);
					DestroyDynamic3DTextLabel(AHouseData[HouseID][DoorText]);
					AHouseData[HouseID][PickupID] = 0;
					AHouseData[HouseID][MapIconID] = 0;

					// Delete the house-file
					format(file, sizeof(file), HouseFile, HouseID); // Construct the complete filename for this house-file
					if (fexist(file)) // Make sure the file exists
						fremove(file); // Delete the file

					// Also let the player know he deleted the house
					format(Msg, 128, "{00FF00}[INFO]: {FFFFFF}You have deleted the house with ID: {FFFF00}%i", HouseID);
					SendClientMessage(playerid, 0xFFFFFFFF, Msg);

					// Exit the function
					return 1;
				}
			}
		}

		// There was no house in range, so let the player know about it
		SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}No house in range to delete");
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You must be on foot to delete a house");

	// Let the server know that this was a valid command
	return 1;
}

// This command lets the player buy a house when he's standing in range of a house that isn't owned yet
COMMAND:buyhouse(playerid, params[])
{
    if(GetPVarInt(playerid, "minigun")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are in Minigun DM can't use any commands");
    if(GetPVarInt(playerid, "afk")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are not In AFK mode can't use any commands");
	// Setup local variables
	new Msg[128];

	// If a player hasn't logged in properly, he cannot use this command
	if (INT_IsPlayerLoggedIn(playerid) == 0) return 0;

	// Check if the player isn't inside a vehicle (the player must be on foot to use this command)
	if (GetPlayerVehicleSeat(playerid) == -1)
	{
		// Check if the player is near a house-pickup
		for (new HouseID = 1; HouseID < MAX_HOUSES; HouseID++)
		{
			// Check if the house exists
			if (IsValidDynamicPickup(AHouseData[HouseID][PickupID]))
			{
				// Check if the player is in range of the house-pickup
				if (IsPlayerInRangeOfPoint(playerid, 2.5, AHouseData[HouseID][HouseX], AHouseData[HouseID][HouseY], AHouseData[HouseID][HouseZ]))
				{
				    // Check if the house isn't owned yet
				    if (AHouseData[HouseID][Owned] == false)
				    {
				        // Check if the player can afford this house
				        if (INT_GetPlayerMoney(playerid) >= AHouseData[HouseID][HousePrice])
				            House_SetOwner(playerid, HouseID); // Give ownership of the house to the player (if he has a spare houseslot)
				        else
				            SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You cannot afford this house"); // The player cannot afford this house
				    }
				    else
				    {
				        // Let the player know that this house is already owned by a player
						format(Msg, 128, "{00FF00}[INFO]: {FFFFFF}This house is already owned by {FFFF00}%s", AHouseData[HouseID][Owner]);
						SendClientMessage(playerid, 0xFFFFFFFF, Msg);
				    }

					// The player was in range of a house-pickup, so stop searching for the other house pickups
				    return 1;
				}
			}
		}

		// All houses have been processed, but the player wasn't in range of any house-pickup, let him know about it
		SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}To buy a house, you have to be near a house-pickup");
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You can't buy a house when you're inside a vehicle");

	// Let the server know that this was a valid command
	return 1;
}

// This command lets the player enter the house/business if he's the owner
COMMAND:enter(playerid, params[])
{
    if(GetPVarInt(playerid, "minigun")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are in Minigun DM can't use any commands");
    if(GetPVarInt(playerid, "afk")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are not In AFK mode can't use any commands");
	// Setup local variables
	new HouseID, IntID;

	// If a player hasn't logged in properly, he cannot use this command
	if (INT_IsPlayerLoggedIn(playerid) == 0) return 0;

	// Check if the player isn't inside a vehicle (the player must be on foot to use this command)
	if (GetPlayerVehicleSeat(playerid) == -1)
	{
		// Loop through all houses
		for (HouseID = 1; HouseID < MAX_HOUSES; HouseID++)
		{
			// Check if the house exists
			if (IsValidDynamicPickup(AHouseData[HouseID][PickupID]))
			{
				// Check if the player is in range of the house-pickup
				if (IsPlayerInRangeOfPoint(playerid, 2.5, AHouseData[HouseID][HouseX], AHouseData[HouseID][HouseY], AHouseData[HouseID][HouseZ]))
				{
					// Check if the house is closed to the public
					if (AHouseData[HouseID][HouseOpened] == false)
					{
						// The house isn't open to the public, so keep anyone out who isn't the owner of the house
						if (House_PlayerIsOwner(playerid, HouseID) == 0)
						{
						    // Let the player know that this house isn't open to the public and he can't enter it
							SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}This house isn't open to the public, you can't enter it");
						    return 1;
						}
					}

					// The house is open to the public, or the player trying to enter is the owner, so let the player inside the house

					// Get the interior to put the player in
					IntID = AHouseData[HouseID][HouseLevel]; // Get the level of the house
                    SetPVarInt(playerid, "InsideHouse", 1);
					// Set the worldid so other players cannot see him anymore (but allow all players in the same house to see eachother)
					SetPlayerVirtualWorld(playerid, 5000 + HouseID);
					// Set the player inside the interior of the house
					SetPlayerInterior(playerid, AHouseInteriors[IntID][InteriorID]);
					// Set the position of the player at the spawn-location of the house's interior
					SetPlayerPos(playerid, AHouseInteriors[IntID][IntX], AHouseInteriors[IntID][IntY], AHouseInteriors[IntID][IntZ]);
					// Also set a tracking-variable to enable /housemenu to track in which house the player is
					APlayerData[playerid][CurrentHouse] = HouseID;
					// Also let the player know he can use /housemenu to upgrade/exit his house
					SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}Use /housemenu to change options for your house");

					// Exit the function
					return 1;
				}
			}
		}
	}

	// If no house was in range, allow other script to use this command too (business-script for example)
	return 0;
}

// This command opens a menu when you're inside your house to allow to access the options of your house
COMMAND:housemenu(playerid, params[])
{
    if(GetPVarInt(playerid, "minigun")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are in Minigun DM can't use any commands");
    if(GetPVarInt(playerid, "afk")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are not In AFK mode can't use any commands");
	// Setup local variables
	new OptionsList[200], DialogTitle[200], HouseID;

	// If a player hasn't logged in properly, he cannot use this command
	if (INT_IsPlayerLoggedIn(playerid) == 0) return 0;

	// Get the HouseID where the player has entered
	HouseID = APlayerData[playerid][CurrentHouse];

	// Check if the player is inside a house
	if (HouseID != 0)
	{
		format(DialogTitle, sizeof(DialogTitle), "Select option for %s", AHouseData[HouseID][HouseName]);

		// Create 2 different option-lists, based on StaticHouse
		if (AHouseData[HouseID][StaticHouse] == true)
		{
			// Create the dialog for a static house (has the same options as a normal house, except for upgrading the house)
			format(OptionsList, sizeof(OptionsList), "%sChange house-name\n", OptionsList);
			format(OptionsList, sizeof(OptionsList), "%sBuy house-car\n", OptionsList);
			format(OptionsList, sizeof(OptionsList), "%sBuy house-car insurance\n", OptionsList);
			format(OptionsList, sizeof(OptionsList), "%sSell house-car\n", OptionsList);
			format(OptionsList, sizeof(OptionsList), "%sSell house\n", OptionsList);
			format(OptionsList, sizeof(OptionsList), "%sOpen house to the public\n", OptionsList);
			format(OptionsList, sizeof(OptionsList), "%sClose house to the public\n", OptionsList);
			format(OptionsList, sizeof(OptionsList), "%sExit house\n", OptionsList);
		}
		else
		{
			// Create the dialog for a normal house
			format(OptionsList, sizeof(OptionsList), "%sChange house-name\n", OptionsList);
			format(OptionsList, sizeof(OptionsList), "%sUpgrade house\n", OptionsList);
			format(OptionsList, sizeof(OptionsList), "%sBuy house-car\n", OptionsList);
			format(OptionsList, sizeof(OptionsList), "%sBuy house-car insurance\n", OptionsList);
			format(OptionsList, sizeof(OptionsList), "%sSell house-car\n", OptionsList);
			format(OptionsList, sizeof(OptionsList), "%sSell house\n", OptionsList);
			format(OptionsList, sizeof(OptionsList), "%sOpen house to the public\n", OptionsList);
			format(OptionsList, sizeof(OptionsList), "%sClose house to the public\n", OptionsList);
			format(OptionsList, sizeof(OptionsList), "%sExit house\n", OptionsList);
		}
		// Show the housemenu
		ShowPlayerDialog(playerid, DialogHouseMenu, DIALOG_STYLE_LIST, DialogTitle, OptionsList, "Select", "Cancel");
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You're not inside a house");
	// Let the server know that this was a valid command
	return 1;
}

// This command teleports you to your selected house
COMMAND:gohome(playerid, params[])
{
    if(GetPVarInt(playerid, "minigun")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are in Minigun DM can't use any commands");
    if(GetPVarInt(playerid, "afk")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are not In AFK mode can't use any commands");
	// Setup local variables
	new HouseList[1000], HouseID;

	// If a player hasn't logged in properly, he cannot use this command
	if (INT_IsPlayerLoggedIn(playerid) == 0) return 0;

	// Check if the player isn't jailed
	if (INT_IsPlayerJailed(playerid) == 0)
	{
		// Check if the player isn't inside a vehicle (the player must be on foot to use this command)
		if (GetPlayerVehicleSeat(playerid) == -1)
		{
			// Ask to which house the player wants to port
			for (new HouseSlot; HouseSlot < MAX_HOUSESPERPLAYER; HouseSlot++)
			{
			    // Get the HouseID in this slot
			    HouseID = APlayerData[playerid][Houses][HouseSlot];

				// Check if this houseindex is occupied
				if (HouseID != 0)
					format(HouseList, 1000, "%s{00FF00}%s{FFFFFF}\n", HouseList, AHouseData[HouseID][HouseName]);
				else
					format(HouseList, 1000, "%s{FFFFFF}%s{FFFFFF}\n", HouseList, "Empty house-slot");
			}
			ShowPlayerDialog(playerid, DialogGoHome, DIALOG_STYLE_LIST, "Choose the house to go to:", HouseList, "Select", "Cancel");
		}
		else
			SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You must be on foot to port to your house");
	}
	else
		SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You cannot use /gohome when you're in jail");

	// Let the server know that this was a valid command
	return 1;
}

// This command allows you to port a vehicle from your house to your location
COMMAND:getcar(playerid, params[])
{
    if(GetPVarInt(playerid, "minigun")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are in Minigun DM can't use any commands");
    if(GetPVarInt(playerid, "afk")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are not In AFK mode can't use any commands");
	// Setup local variables
	new HouseList[1000], HouseID;

	// If a player hasn't logged in properly, he cannot use this command
	if (INT_IsPlayerLoggedIn(playerid) == 0) return 0;

	// Check if the player isn't inside a vehicle (the player must be on foot to use this command)
	if (GetPlayerVehicleSeat(playerid) == -1)
	{
		// Ask to which house the player wants to port
		for (new HouseSlot; HouseSlot < MAX_HOUSESPERPLAYER; HouseSlot++)
		{
		    // Get the HouseID in this slot
		    HouseID = APlayerData[playerid][Houses][HouseSlot];

			// Check if this houseindex is occupied
			if (HouseID != 0)
				format(HouseList, 1000, "%s{00FF00}%s{FFFFFF}\n", HouseList, AHouseData[HouseID][HouseName]);
			else
				format(HouseList, 1000, "%s{FFFFFF}%s{FFFFFF}\n", HouseList, "Empty house-slot");
		}
		ShowPlayerDialog(playerid, DialogGetCarSelectHouse, DIALOG_STYLE_LIST, "Choose the house to get a car from:", HouseList, "Select", "Cancel");
	}
	else
		SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You need to be on foot to port a vehicle to your location");

	// Let the server know that this was a valid command
	return 1;
}

// This command checks if the player is inside a vehicle that he owns and if he's in range of the house where the vehicle is assigned to
COMMAND:park(playerid, params[])
{
    if(GetPVarInt(playerid, "minigun")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are in Minigun DM can't use any commands");
    if(GetPVarInt(playerid, "afk")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are not In AFK mode can't use any commands");
	// Setup local variables
	new Float:x, Float:y, Float:z, Float:rot, vid, HouseID, Msg[128];
	new engine,lights,alarm,doors,bonnet,boot,objective;

	// If a player hasn't logged in properly, he cannot use this command
	if (INT_IsPlayerLoggedIn(playerid) == 0) return 0;

	// Check if the player is inside a vehicle (he must be the driver)
	if (GetPlayerVehicleSeat(playerid) == 0)
	{
		// Get the vehicle-id
		vid = GetPlayerVehicleID(playerid);
		// Get the HouseID to which this vehicle belongs
		HouseID = AVehicleData[vid][BelongsToHouse];

		// Check if this vehicle belongs to a house (if not, the vehicle cannot be parked, as it's not a house-vehicle)
		if (HouseID != 0)
		{
			// Check if the vehicle is in range of the house-entrance (you cannot park a vehicle further away from your house than 150m)
			if (IsPlayerInRangeOfPoint(playerid, ParkRange, AHouseData[HouseID][HouseX], AHouseData[HouseID][HouseY], AHouseData[HouseID][HouseZ]))
			{
				// Get the player's position and angle
				GetVehiclePos(vid, x, y, z);
				GetVehicleZAngle(vid, rot);
				// Save those values for the vehicle
				AVehicleData[vid][SpawnX] = x;
				AVehicleData[vid][SpawnY] = y;
				AVehicleData[vid][SpawnZ] = z;
				AVehicleData[vid][SpawnRot] = rot;

				// Loop through all carslots of this house to find the vehicle-id
				for (new CarSlot; CarSlot < 10; CarSlot++)
				{
					// Check if this carslot holds the same vehicle-id
				    if (AHouseData[HouseID][VehicleIDs][CarSlot] == vid)
				    {
	                    House_ReplaceVehicle(HouseID, CarSlot); // Re-create the vehicle at the same spot the player wants to park his vehicle
	                    PutPlayerInVehicle(playerid, AHouseData[HouseID][VehicleIDs][CarSlot], 0);
						// Turn on the engine and lights
						GetVehicleParamsEx(AHouseData[HouseID][VehicleIDs][CarSlot], engine, lights, alarm, doors, bonnet, boot, objective);
						SetVehicleParamsEx(AHouseData[HouseID][VehicleIDs][CarSlot], 1, 1, alarm, doors, bonnet, boot, objective);
	                    break; // Stop the for-loop
					}
				}

				// Let the player know he parked his vehicle
				SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You've parked your vehicle");

				// Save the housefile
				HouseFile_Save(HouseID);
			}
			else
			{
			    format(Msg, 128, "{00FF00}[INFO]: {FFFFFF}You need to be within %im of your house to park this vehicle", ParkRange);
			    SendClientMessage(playerid, 0xFFFFFFFF, Msg);
			}
		}
		else
		    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You cannot park a vehicle that's not owned by you");
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You must be driving a vehicle you own to park it");

	// Let the server know that this was a valid command
	return 1;
}

// This command lets the player evict a house (this clears the ownership of the house so it can be bought again by other players)
COMMAND:evict(playerid, params[])
{
    if(GetPVarInt(playerid, "minigun")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are in Minigun DM can't use any commands");
    if(GetPVarInt(playerid, "afk")) return SendClientMessage(playerid, COLOR_GREEN, "[INFO]:{FFFFFF} You are not In AFK mode can't use any commands");
	// If a player hasn't logged in properly, he cannot use this command
	if (INT_IsPlayerLoggedIn(playerid) == 0) return 0;
	// If the player has an insufficient admin-level (he needs level 5 or RCON admin), exit the command
	// returning "SERVER: Unknown command" to the player
	if (INT_CheckPlayerAdminLevel(playerid, 5) == 0) return 0;

	// Setup local variables
	new Msg[128], Name[24];

	// Check if the player isn't inside a vehicle (the admin-player must be on foot to use this command)
	if (GetPlayerVehicleSeat(playerid) == -1)
	{
		// Loop through all houses
		for (new HouseID = 1; HouseID < MAX_HOUSES; HouseID++)
		{
			// Check if the house exists
			if (IsValidDynamicPickup(AHouseData[HouseID][PickupID]))
			{
				// Check if the player is in range of the house-pickup
				if (IsPlayerInRangeOfPoint(playerid, 2.5, AHouseData[HouseID][HouseX], AHouseData[HouseID][HouseY], AHouseData[HouseID][HouseZ]))
				{
					// Get the name of the owner (if the house is owned)
					if (AHouseData[HouseID][Owned] == true)
					{
						// Loop through all players to find the owner (if he's online)
						for (new pid; pid < MAX_PLAYERS; pid++)
						{
							// Check if this player is online
						    if (INT_IsPlayerLoggedIn(playerid) == 1)
						    {
						        // Get that player's name
						        GetPlayerName(pid, Name, sizeof(Name));
						        // Compare if this player has the same name as the owner of the house
								if (strcmp(AHouseData[HouseID][Owner], Name, false) == 0)
								{
									// Inform the player that his house is being deleted
									format(Msg, 128, "{00FF00}[INFO]: {FFFFFF}You lost your house %s, as it was evicted", AHouseData[HouseID][HouseName]);
									SendClientMessage(pid, 0xFFFFFFFF, Msg);

									// Also remove the HouseID from his list of houses
									for (new HouseSlot; HouseSlot < MAX_HOUSESPERPLAYER; HouseSlot++)
									    // Check if the house is stored in this houseslot
									    if (APlayerData[pid][Houses][HouseSlot] == HouseID)
									        // If the house is stored in this slot, clear the slot
									        APlayerData[pid][Houses][HouseSlot] = 0;

									// Stop this For-loop, as the owner was already found and informed
									break;
								}
						    }
						}
					}

					// First remove all vehicles from the house
					House_RemoveVehicles(HouseID);

					// Clear the ownership of the house
					AHouseData[HouseID][Owned] = false;
					AHouseData[HouseID][Owner] = 0;

					// Update the entrance of the house so other players know it's available for purchase again
					House_UpdateEntrance(HouseID);
					// Save the house
					HouseFile_Save(HouseID);

					// Also let the player know he evicted the house
					format(Msg, 128, "{00FF00}[INFO]: {FFFFFF}You have evicted the house with ID: {FFFF00}%i", HouseID);
					SendClientMessage(playerid, 0xFFFFFFFF, Msg);

					// Exit the function
					return 1;
				}
			}
		}

		// There was no house in range, so let the player know about it
		SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}No house in range to delete");
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You must be on foot to delete a house");

	// Let the server know that this was a valid command
	return 1;
}



// ******************************************************************************************************************************
// Dialog-responses
// ******************************************************************************************************************************

// This function processes the housemenu dialog
Dialog_HouseMenu(playerid, response, listitem)
{
	// Just close the dialog if the player clicked "Cancel"
	if(!response) return 1;

	// Setup local variables
	new UpgradeList[2000], HouseID, DialogTitle[200], Counter, UpgradePrice, Msg[128], CarSlot, VehicleClassList[1000], VehicleList[500];
    new MsgInsurance[128], BuyableCarIndex, bool:HouseHasCars = false;

	// Get the HouseID of the house where the player is
	HouseID = APlayerData[playerid][CurrentHouse];

	// Skip listitem 1 if this house is a static house (listitem 1 = buy house-car => item 2, ...)
	if (AHouseData[HouseID][StaticHouse] == true)
	{
		// If listitem is 1 or higher, increase the listitem by 1, skipping the "upgrade house" option
		// but still keep the "change housename" option (listitem 0)
		if (listitem >= 1)
		    listitem++;
	}

	// Select an option based on the selection in the list
	switch(listitem)
	{
	    case 0: // Change house name
	    {
			// Only the house-owner can use this option
			if (House_PlayerIsOwner(playerid, HouseID) == 1)
			{
		        format(DialogTitle, 200, "Old house-name: %s", AHouseData[HouseID][HouseName]);
				ShowPlayerDialog(playerid, DialogHouseNameChange, DIALOG_STYLE_INPUT, DialogTitle, "Give a new name to your house", "Select", "Cancel");
			}
			else
			    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}Only the house-owner can use this option");
	    }
	    case 1: // Upgrade the house
	    {
			// Only the house-owner can use this option
			if (House_PlayerIsOwner(playerid, HouseID) == 1)
			{
		        // Check if it's possible to upgrade further
				if (AHouseData[HouseID][HouseLevel] < AHouseData[HouseID][HouseMaxLevel])
				{
					// Add only the upgrades above the current house-level to the upgradelist
					for (new i = AHouseData[HouseID][HouseLevel] + 1; i <= AHouseData[HouseID][HouseMaxLevel]; i++)
					{
					    Counter++; // Add 1 to the counter each time an upgrade is added to the upgradelist
					    UpgradePrice = ((AHouseData[HouseID][HousePrice] * Counter) / 100) * HouseUpgradePercent;
					    // Add the upgrade-info in green if the player can afford it, and in red if he cannot afford it
						if (INT_GetPlayerMoney(playerid) >= UpgradePrice)
							format(UpgradeList, 2000, "%s{00FF00}%s (level %i)\t\t$%i\n", UpgradeList, AHouseInteriors[i][InteriorName], i, UpgradePrice);
						else
							format(UpgradeList, 2000, "%s{FF0000}%s (level %i)\t\t$%i\n", UpgradeList, AHouseInteriors[i][InteriorName], i, UpgradePrice);
					}

			        // Show another dialog to let the player select which upgrade he wants for his house
					ShowPlayerDialog(playerid, DialogUpgradeHouse, DIALOG_STYLE_LIST, "Select upgrade:", UpgradeList, "Select", "Cancel");
				}
				else
				    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}Your house has reached the maximum level, you cannot upgrade it further");
			}
			else
			    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}Only the house-owner can use this option");
	    }
		case 2: // Buy house-car
		{
			// Only the house-owner can use this option
			if (House_PlayerIsOwner(playerid, HouseID) == 1)
			{
			    // Find a free carslot
			    CarSlot = House_GetFreeCarSlot(HouseID);
			    // Check if the carslot is valid
			    if (CarSlot != -1)
			    {
				    // Let the player choose a vehicle-class
					format(VehicleClassList, 1000, "%s{00FF00}%s{FFFFFF}\n", VehicleClassList, "Bikes");
					format(VehicleClassList, 1000, "%s{40FF00}%s{FFFFFF}\n", VehicleClassList, "Boats");
					format(VehicleClassList, 1000, "%s{80FF00}%s{FFFFFF}\n", VehicleClassList, "Convertibles");
					format(VehicleClassList, 1000, "%s{B0FF00}%s{FFFFFF}\n", VehicleClassList, "Helicopters");
					format(VehicleClassList, 1000, "%s{FFFF00}%s{FFFFFF}\n", VehicleClassList, "Industrial vehicles");
					format(VehicleClassList, 1000, "%s{B0FF40}%s{FFFFFF}\n", VehicleClassList, "Low-riders");
					format(VehicleClassList, 1000, "%s{80FF80}%s{FFFFFF}\n", VehicleClassList, "Off-Road vehicles");
					format(VehicleClassList, 1000, "%s{40FFB0}%s{FFFFFF}\n", VehicleClassList, "Planes");
					format(VehicleClassList, 1000, "%s{00FFFF}%s{FFFFFF}\n", VehicleClassList, "Public Service vehicles");
					format(VehicleClassList, 1000, "%s{00B0FF}%s{FFFFFF}\n", VehicleClassList, "RC vehicles");
					format(VehicleClassList, 1000, "%s{0080FF}%s{FFFFFF}\n", VehicleClassList, "Saloon vehicles");
					format(VehicleClassList, 1000, "%s{0040FF}%s{FFFFFF}\n", VehicleClassList, "Sport vehicles");
					format(VehicleClassList, 1000, "%s{0000FF}%s{FFFFFF}\n", VehicleClassList, "Station wagons");
					format(VehicleClassList, 1000, "%s{4000FF}%s{FFFFFF}\n", VehicleClassList, "Trailers");
					format(VehicleClassList, 1000, "%s{8000FF}%s{FFFFFF}\n", VehicleClassList, "Unique vehicles");
					// Ask which vehicle class the player wants to see to buy a vehicle
					ShowPlayerDialog(playerid, DialogBuyCarClass, DIALOG_STYLE_LIST, "Select vehicle class:", VehicleClassList, "Select", "Cancel");
			    }
			    else
			        SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}This house has the maximum amount of house-cars already");
			}
			else
			    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}Only the house-owner can use this option");
		}
		case 3: // Buy house-car insurance
		{
			// Only the house-owner can use this option
			if (House_PlayerIsOwner(playerid, HouseID) == 1)
			{
			    // Check if this house doesn't have insurance yet
			    if (AHouseData[HouseID][Insurance] == false)
			    {
			        // Check if the player can afford the insurance
			        if (INT_GetPlayerMoney(playerid) >= (AHouseData[HouseID][HousePrice] / 10))
			        {
					    // Construct the message for the dialog, this includes the price for the insurance
					    format(MsgInsurance, 128, "{00FF00}[INFO]: {FFFFFF}Are you sure you want to buy an insurance for your house's vehicles for $%i?", AHouseData[HouseID][HousePrice] / 10);
						// Ask the player if the wants to buy an insurance for this house's vehicles
						if (AutomaticInsurance == true)
							ShowPlayerDialog(playerid, DialogBuyInsurance, DIALOG_STYLE_MSGBOX, "The admin enabled insurance for everyone. Buy insurance anyway?", MsgInsurance, "Yes", "No");
						else
							ShowPlayerDialog(playerid, DialogBuyInsurance, DIALOG_STYLE_MSGBOX, "Buy insurance?", MsgInsurance, "Yes", "No");
					}
					else
					    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You cannot afford the vehicle-insurance");
				}
				else
				    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}This house already has an insurance for it's vehicles");
			}
			else
			    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}Only the house-owner can use this option");
		}
		case 4: // Sell house-car
		{
			// Only the house-owner can use this option
			if (House_PlayerIsOwner(playerid, HouseID) == 1)
			{
				// Check if the house has any cars assigned to it
				for (CarSlot = 0; CarSlot < AHouseData[HouseID][CarSlots]; CarSlot++)
				    if (AHouseData[HouseID][VehicleIDs][CarSlot] != 0)
				        HouseHasCars = true;

				// Check if the house has any cars assigned to it
				if (HouseHasCars == true)
				{
					// Add all vehicles to the list
					for (CarSlot = 0; CarSlot < AHouseData[HouseID][CarSlots]; CarSlot++)
					{
						if (AHouseData[HouseID][VehicleIDs][CarSlot] != 0)
						{
						    // Get the index where the first vehicle is found in the ABuyableVehicles array
						    BuyableCarIndex = VehicleBuyable_GetIndex(GetVehicleModel(AHouseData[HouseID][VehicleIDs][CarSlot]));
						    // Add the name of the vehicle to the list
						    format(VehicleList, 500, "%s{00FF00}%s: $%i{FFFFFF}\n", VehicleList, ABuyableVehicles[BuyableCarIndex][CarName], ABuyableVehicles[BuyableCarIndex][Price] / 2);
						}
						else
							format(VehicleList, 500, "%s{FFFFFF}Empty car-slot{FFFFFF}\n", VehicleList);
					}

					// Ask which vehicle class the player wants to see to buy a vehicle
					ShowPlayerDialog(playerid, DialogSellCar, DIALOG_STYLE_LIST, "Select vehicle to sell:", VehicleList, "Select", "Cancel");
				}
				else
				    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}This house has no vehicles assigned to it");
			}
			else
			    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}Only the house-owner can use this option");
		}
		case 5: // Sell house
		{
			// Only the house-owner can use this option
			if (House_PlayerIsOwner(playerid, HouseID) == 1)
			{
				// Check if the house has any cars assigned to it
				for (CarSlot = 0; CarSlot < AHouseData[HouseID][CarSlots]; CarSlot++)
				    if (AHouseData[HouseID][VehicleIDs][CarSlot] != 0)
				        HouseHasCars = true;

				// Check if all house-cars have been sold (all slots are empty)
				if (HouseHasCars == false)
				{
				    format(Msg, 128, "Are you sure you want to sell your house for $%i?", House_CalcSellPrice(HouseID));
					ShowPlayerDialog(playerid, DialogSellHouse, DIALOG_STYLE_MSGBOX, "Are you sure?", Msg, "Yes", "No");
				}
				else
				    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You can't sell a house which still has house-cars assigned to it");
			}
			else
			    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}Only the house-owner can use this option");
		}
	    case 6: // Open the house to the public (everyone can enter it)
	    {
			// Only the house-owner can use this option
			if (House_PlayerIsOwner(playerid, HouseID) == 1)
			{
			    // Open the house to the public
				AHouseData[HouseID][HouseOpened] = true;
				// Let the player know he opened the house to the public
				SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You've opened the house to the public, anyone can enter it");
			}
			else
			    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}}Only the house-owner can use this option");
	    }
	    case 7: // Close the house to the public (only the owner can enter it)
	    {
			// Only the house-owner can use this option
			if (House_PlayerIsOwner(playerid, HouseID) == 1)
			{
			    // Close the house to the public
				AHouseData[HouseID][HouseOpened] = false;
				// Let the player know he closed the house to the public
				SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You've closed the house to the public, only you can enter it");
			}
			else
			    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}Only the house-owner can use this option");
	    }
	    case 8: // Exit the house
	    {
			House_Exit(playerid, HouseID);
	    }
	}

	return 1;
}

// This function processes the house-upgrade menu
Dialog_UpgradeHouse(playerid, response, listitem)
{
	// Just close the dialog if the player clicked "Cancel"
	if(!response) return 1;

	// Setup local variables
	new Msg[128], HouseID, hLevel, Payment;

	// Get the HouseID of the house where the player is
	HouseID = APlayerData[playerid][CurrentHouse];
	// Calculate the new house-level based on the selection in the list (the first entry is 1 level higher than the current house-level)
	hLevel = listitem + 1 + AHouseData[HouseID][HouseLevel];
	// Calculate the price for upgrading
	Payment = ((AHouseData[HouseID][HousePrice] * (listitem + 1)) / 100) * HouseUpgradePercent;

	// Check if the player can afford it
	if (INT_GetPlayerMoney(playerid) >= Payment)
	{
		// Upgrade the house
		AHouseData[HouseID][HouseLevel] = hLevel;
		// Also set the amount of carslots equal to the house-level
		AHouseData[HouseID][CarSlots] = hLevel;

		// Also re-position all players who are in your house (including yourself), otherwise they stay in the same interior
		for (new OtherPlayer; OtherPlayer < MAX_PLAYERS; OtherPlayer++)
		{
			// Check if the other player is in the house too
			if (APlayerData[OtherPlayer][CurrentHouse] == HouseID)
			{
				// Set the worldid so other players cannot see him anymore (but allow all players in the same house to see eachother)
				SetPlayerVirtualWorld(OtherPlayer, 5000 + HouseID);
				// Set the player inside the new interior of the house
				SetPlayerInterior(OtherPlayer, AHouseInteriors[hLevel][InteriorID]);
				// Set the position of the player at the spawn-location of the house's interior
				SetPlayerPos(OtherPlayer, AHouseInteriors[hLevel][IntX], AHouseInteriors[hLevel][IntY], AHouseInteriors[hLevel][IntZ]);
			}
		}

		// Let the player pay for the upgrade
		INT_GivePlayerMoney(playerid, -Payment);
		format(Msg, 128, "{00FF00}[INFO]: {FFFFFF}You've upgraded your house to level %i for $%i", AHouseData[HouseID][HouseLevel], Payment);
		SendClientMessage(playerid, 0xFFFFFFFF, Msg);

		// Also update the 3DText at the entrance of the house
		House_UpdateEntrance(HouseID);

		// Save the house-file
		HouseFile_Save(HouseID);
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You cannot afford this upgrade");

	return 1;
}

// Check which house the player chose, and port him to it
Dialog_GoHome(playerid, response, listitem)
{
	// Just close the dialog if the player clicked "Cancel"
	if(!response) return 1;

	// Setup local variables
	new HouseIndex, HouseID;

	// The listitem directly indicates the house-index
	HouseIndex = listitem;
	// Get the HouseID
	HouseID = APlayerData[playerid][Houses][HouseIndex];

	// Check if this is a valid house (HouseID != 0)
	if (HouseID != 0)
	{
		// Get the coordinates of the house's entrance
		SetPlayerPos(playerid, AHouseData[HouseID][HouseX], AHouseData[HouseID][HouseY], AHouseData[HouseID][HouseZ]);
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You don't have a house in this house-slot");

	return 1;
}

// Let the player change the name of his house
Dialog_ChangeHouseName(playerid, response, inputtext[])
{
	// Just close the dialog if the player clicked "Cancel" or if the player didn't input any text
	if ((!response) || (strlen(inputtext) == 0)) return 1;

	// Change the name of the house
	format(AHouseData[APlayerData[playerid][CurrentHouse]][HouseName], 100, inputtext);
	// Also update the 3DText at the entrance of the house
	House_UpdateEntrance(APlayerData[playerid][CurrentHouse]);
	// Let the player know that the name of his house has been changed
	SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You've changed the name of your house");

	// Save the house-file
	HouseFile_Save(APlayerData[playerid][CurrentHouse]);

	return 1;
}

// Choose a vehicle class from which to buy a vehicle
Dialog_BuyCarClass(playerid, response, listitem)
{
	// Just close the dialog if the player clicked "Cancel"
	if(!response) return 1;

	// Setup local variables
	new CarList[1000], DialogTitle[128];

	// Set the player's chosen vehicle-class based on the listitem he chose (add 1 as the vehicleclass starts at 1)
	APlayerData[playerid][DialogBuyVClass] = listitem + 1;

	// Add all vehicles of the same class to the list
	for (new i; i < sizeof(ABuyableVehicles); i++)
	{
		// Check if the vehicle in the list has the same class as requested
		if (ABuyableVehicles[i][VehicleClass] == APlayerData[playerid][DialogBuyVClass])
		{
			// Add the carname to the list and it's price
			format(CarList, 1000, "%s%s%s ($%i)", CarList, "\n", ABuyableVehicles[i][CarName], ABuyableVehicles[i][Price]); // Add the name of the next car to the list on the next line
		}
	}

	// Check if the list is empty
	if (strlen(CarList) == 0)
	{
		// Send the player a message that all vehicles have been disabled of the chosen class (no vehicles in the array of this class)
		SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}This is an empty list, the administrator may have disabled all vehicles of this class");
		// Exit the function (don't ask to choose a vehicle)
		return 1;
	}

	// Set a title for the dialog based on the requested vehicleclass
	switch (APlayerData[playerid][DialogBuyVClass])
	{
		case VClassBike: format(DialogTitle, 128, "Buy a bike:");
		case VClassBoat: format(DialogTitle, 128, "Buy a boat:");
		case VClassConvertible: format(DialogTitle, 128, "Buy a convertible:");
		case VClassHelicopter: format(DialogTitle, 128, "Buy a helicopter:");
		case VClassIndustrial: format(DialogTitle, 128, "Buy a industrial vehicle:");
		case VClassLowRider: format(DialogTitle, 128, "Buy a low-rider:");
		case VClassOffRoad: format(DialogTitle, 128, "Buy an off-road vehicle:");
		case VClassPlane: format(DialogTitle, 128, "Buy a plane:");
		case VClassPublic: format(DialogTitle, 128, "Buy a public service vehicle:");
		case VClassRCVehicle: format(DialogTitle, 128, "Buy a RC vehicle:");
		case VClassSaloons: format(DialogTitle, 128, "Buy a saloon vehicle:");
		case VClassSportCar: format(DialogTitle, 128, "Buy a sport vehicle:");
		case VClassStationCar: format(DialogTitle, 128, "Buy a stationwagon:");
		case VClassTrailer: format(DialogTitle, 128, "Buy a trailer:");
		case VClassUnique: format(DialogTitle, 128, "Buy a unique vehicle:");
	}

	// Ask which car the player wants to have by showing the dialog
	ShowPlayerDialog(playerid, DialogBuyCar, DIALOG_STYLE_LIST, DialogTitle, CarList, "Select", "Cancel");

	return 1;
}

// Buy a vehicle and assign it to the house
Dialog_BuyCar(playerid, response, listitem)
{
	// Just close the dialog if the player clicked "Cancel"
	if(!response) return 1;

	// Setup local variables
	new Counter, Msg[128], cComponents[14], vid;

	// Get the HouseID
	new HouseID = APlayerData[playerid][CurrentHouse];

	// Loop through the entire list of buyable vehicles
	for (new i; i < sizeof(ABuyableVehicles); i++)
	{
		// Check if the vehicle in the list has the same class as requested
		if (ABuyableVehicles[i][VehicleClass] == APlayerData[playerid][DialogBuyVClass])
		{
		    // Check if this is the vehicle that the player chose
		    if (Counter == listitem)
			{
			    // Check if the player has enough money to afford buying this vehicle
			    if (INT_GetPlayerMoney(playerid) >= (ABuyableVehicles[i][Price]))
			    {
					// Add the vehicle to the house (this sets ownership and other data that's needed)
					// The vehicles are by default created inside the hangar of KACC Military Fuels instead of near the EasterBoard Farm
					vid = House_AddVehicle(HouseID, ABuyableVehicles[i][CarModel], 0, cComponents, 2585.0, 2829.0, 10.9, 0.0, random(126), random(126));
					// Also set the vehicle's fuel to maximum (when the PPC_Speedometer script is used)
					INT_SetVehicleFuel(vid, -1);

					// Let the player pay for buying the vehicle
					INT_GivePlayerMoney(playerid, -ABuyableVehicles[i][Price]);
					// Let the player know he bought a vehicle
					format(Msg, 128, "{00FF00}[INFO]: {FFFFFF}You have bought a %s for $%i", ABuyableVehicles[i][CarName], ABuyableVehicles[i][Price]);
					SendClientMessage(playerid, 0xFFFFFFFF, Msg);
					// Let the player know he can go outside and use /getcar and /park to park his vehicle
					SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}Now get outside and use /getcar to spawn it, then use /park to park it near your house");

					// Save the house-file
					HouseFile_Save(HouseID);
				}
				else // The player has not enough money to buy this vehicle
				    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You can't afford to buy this vehicle");

				// Stop looking for the vehicle, as it's found and given to the player already
				return 1;
			}
		    else // The player chose another vehicle from the same class, keep looking for another one
		        Counter++;
		}
	}

	return 1;
}

// Buy insurance for the house's vehicles
Dialog_BuyInsurance(playerid, response)
{
	// Just close the dialog if the player clicked "No"
	if(!response) return 1;

	// Setup local variables
	new Msg[128];

	// Get the HouseID where the player is right now
	new HouseID = APlayerData[playerid][CurrentHouse];

	// Buy an insurance for this house's vehicles (insurance costs 10% of the house's baseprice)
	AHouseData[HouseID][Insurance] = true;
	INT_GivePlayerMoney(playerid, -(AHouseData[HouseID][HousePrice] / 10));

	// Let the player know he has bought a vehicle-insurance for this house
	format(Msg, 128, "{00FF00}[INFO]: {FFFFFF}You've bought a vehicle-insurance for all vehicles in this house for {FFFF00}$%i", AHouseData[HouseID][HousePrice] / 10);
	SendClientMessage(playerid, 0xFFFFFFFF, Msg);

	// Save the house-file
	HouseFile_Save(HouseID);

	return 1;
}

// Sell the house
Dialog_SellHouse(playerid, response)
{
	// Just close the dialog if the player clicked "Cancel"
	if(!response) return 1;

	// Get the HouseID where the player is right now
	new HouseID = APlayerData[playerid][CurrentHouse];

	// All players must exit the house
	for (new OtherPlayer; OtherPlayer < MAX_PLAYERS; OtherPlayer++)
	{
		// If this player is inside the house
		if (APlayerData[OtherPlayer][CurrentHouse] == HouseID)
		{
			// Let the player exit the house
			House_Exit(OtherPlayer, HouseID);
		}
	}

	// Refund the player 50% of the worth of the house
	INT_GivePlayerMoney(playerid, House_CalcSellPrice(HouseID));
	SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You've sold your house");

	// Clear the owner of the house
	AHouseData[HouseID][Owned] = false;
	AHouseData[HouseID][Owner] = 0;
	// Clear the house-name and house-level
	AHouseData[HouseID][HouseName] = 0;
	if (AHouseData[HouseID][StaticHouse] == false)
	{
        AHouseData[HouseID][HouseLevel] = 1;
	    AHouseData[HouseID][CarSlots] = 1;
	}
	AHouseData[HouseID][Insurance] = false;
	AHouseData[HouseID][HouseOpened] = false;

	// Clear the house-id from the player
	for (new HouseSlot; HouseSlot < MAX_HOUSESPERPLAYER; HouseSlot++)
	{
		// If the house-slot if found where the house was added to the player
		if (APlayerData[playerid][Houses][HouseSlot] == HouseID)
		{
		    // Clear the house-id
		    APlayerData[playerid][Houses][HouseSlot] = 0;
		    // Stop searching
		    break;
		}
	}

	// Update the 3DText near the house's entrance to show other players that it's for sale again
	House_UpdateEntrance(HouseID);

	// Save the sold house, otherwise the old ownership-data is still there
	HouseFile_Save(HouseID);

	return 1;
}

// Sell the selected car
Dialog_SellCar(playerid, response, listitem)
{
	// Just close the dialog if the player clicked "Cancel"
	if(!response) return 1;

	// Setup local variables
	new HouseID = APlayerData[playerid][CurrentHouse];
	new vid = AHouseData[HouseID][VehicleIDs][listitem];
	new CarSlot = listitem;

	// Check if there is a vehicle stored in this carslot
	if (vid != 0)
	{
		new BuyableCarIndex = VehicleBuyable_GetIndex(GetVehicleModel(vid));
		new Msg[128];

		// Destroy the vehicle and remove it from the house
		Vehicle_Delete(vid, HouseID, CarSlot);

		// Refund the player with 50% of the vehicle's buying price
		INT_GivePlayerMoney(playerid, (ABuyableVehicles[BuyableCarIndex][Price] / 2));
		// Let the player know about it
		format(Msg, 128, "{00FF00}[INFO]: {FFFFFF}You've sold your %s for $%i", ABuyableVehicles[BuyableCarIndex][CarName], ABuyableVehicles[BuyableCarIndex][Price] / 2);
		SendClientMessage(playerid, 0xFFFFFFFF, Msg);

		// Save the house-file
		HouseFile_Save(HouseID);
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}No vehicle exists in this vehicle-slot");

	return 1;
}

// This dialog processes the selected house from which to get a vehicle using /getcar
Dialog_GetCarSelectHouse(playerid, response, listitem)
{
	// Just close the dialog if the player clicked "Cancel"
	if(!response) return 1;

	// Get the houseid based on the chosen listitem
	new HouseID = APlayerData[playerid][Houses][listitem];

	// Check if it was a valid house
	if (HouseID != 0)
	{
		// Setup local variables
	    new BuyableCarIndex, VehicleList[500], bool:HouseHasCars = false, CarSlot;

		// Store the HouseID, otherwise the next dialog won't be able to get a car from the chosen house
		APlayerData[playerid][DialogGetCarHouseID] = HouseID;

		// Check if the house has any cars assigned to it
		for (CarSlot = 0; CarSlot < AHouseData[HouseID][CarSlots]; CarSlot++)
			if (AHouseData[HouseID][VehicleIDs][CarSlot] != 0)
			    HouseHasCars = true;

		// Check if the house has any cars assigned to it
		if (HouseHasCars == true)
		{
			// Add all vehicles to the list
			for (CarSlot = 0; CarSlot < AHouseData[HouseID][CarSlots]; CarSlot++)
			{
				// Check if the carslot has a vehicle in it
				if (AHouseData[HouseID][VehicleIDs][CarSlot] != 0)
				{
				    // Get the index where the first vehicle is found in the ABuyableVehicles array
				    BuyableCarIndex = VehicleBuyable_GetIndex(GetVehicleModel(AHouseData[HouseID][VehicleIDs][CarSlot]));
				    // Add the name of the vehicle to the list
				    format(VehicleList, 500, "%s{00FF00}%s\n", VehicleList, ABuyableVehicles[BuyableCarIndex][CarName]);
				}
				else
					format(VehicleList, 500, "%s{FFFFFF}Empty car-slot{FFFFFF}\n", VehicleList);
			}

			// Ask which vehicle the player wants to teleport to his location
			ShowPlayerDialog(playerid, DialogGetCarSelectCar, DIALOG_STYLE_LIST, "Select vehicle to port to your location:", VehicleList, "Select", "Cancel");
		}
		else
		    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}This house has no vehicles assigned to it");
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You don't have a house in this house-slot");

	return 1;
}

// This dialog processes the chosen car and spawns it at the player's location
Dialog_GetCarSelectCar(playerid, response, listitem)
{
	// Just close the dialog if the player clicked "Cancel"
	if(!response) return 1;

	// Get the HouseID from which to get the car
	new HouseID = APlayerData[playerid][DialogGetCarHouseID];

	// Get the vehicleid from the chosen listitem
	new vid = AHouseData[HouseID][VehicleIDs][listitem];

	// Check if it was a valid vehicleid
	if (vid != 0)
	{
		// Setup local variables
		new Float:x, Float:y, Float:z, Float:Angle;
		// Get the player's position
		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, Angle);
		// Port the vehicle to the player
		SetVehiclePos(vid, x, y, z);
		// Put the player inside the vehicle and rotate the vehicle to face where the player was facing
		PutPlayerInVehicle(playerid, vid, 0);
		SetVehicleZAngle(vid, Angle);
		// Turn on the engine and lights
		new engine,lights,alarm,doors,bonnet,boot,objective;
		GetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);
		SetVehicleParamsEx(vid, 1, 1, alarm, doors, bonnet, boot, objective);
		// Let the player know he should park the vehicle
		SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You've spawned your vehicle, now use /park to park it near your house");
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}No vehicle exists in this vehicle-slot");

	return 1;
}



// ******************************************************************************************************************************
// File functions
// ******************************************************************************************************************************

// This function will load the house's datafile (used when the server is started to load all houses)
// It only reads the data about the house, vehicle-data is skipped
HouseFile_Load(HouseID)
{
	// Setup local variables
	new file[100], File:HFile, LineFromFile[100], ParameterName[50], ParameterValue[50];

    // Construct the complete filename for this house-file
	format(file, sizeof(file), HouseFile, HouseID);

	// Check if the HouseFile exists
	if (fexist(file))
	{
	    // Open the housefile for reading
		HFile = fopen(file, io_read);
        // Read the first line of the file
		fread(HFile, LineFromFile);

		// Keep reading until the end of the file is found (no more data)
		// An empty line between data-segments still has the NewLine characters (\r\n) so it's not completely empty
		// Reading past the last line will read a completely empty line, therefore indicating the end of the file
		while (strlen(LineFromFile) > 0)
		{
			StripNewLine(LineFromFile); // Strip any newline characters from the LineFromFile
			sscanf(LineFromFile, "s[50]s[50]", ParameterName, ParameterValue); // Extract parametername and parametervalue

			// Check if there is anything in the LineFromFile (skipping empty lines)
			if (strlen(LineFromFile) > 0)
			{
				// Store the proper value in the proper place
				if (strcmp(ParameterName, "Owned", false) == 0) // If the parametername is correct ("Owned")
				{
				    if (strcmp(ParameterValue, "Yes", false) == 0) // If the value "Yes" was read
						AHouseData[HouseID][Owned] = true; // House is owned
					else
						AHouseData[HouseID][Owned] = false; // House is not owned
				}
				if (strcmp(ParameterName, "Owner", false) == 0) // If the parametername is correct ("Owner")
					// Store the Owner (Owner will hold "1" if there is no owner (empty string), done by "sscanf" I guess)
					// But this doesn't matter, as the owner will never be displayed when the house is not owned by someone
				    format(AHouseData[HouseID][Owner], 24, ParameterValue);

				if (strcmp(ParameterName, "HouseName", false) == 0) // If the parametername is correct ("HouseName")
				    format(AHouseData[HouseID][HouseName], 24, ParameterValue); // Store the HouseName
				if (strcmp(ParameterName, "HouseX", false) == 0) // If the parametername is correct ("HouseX")
					AHouseData[HouseID][HouseX] = floatstr(ParameterValue); // Store the HouseX
				if (strcmp(ParameterName, "HouseY", false) == 0) // If the parametername is correct ("HouseY")
					AHouseData[HouseID][HouseY] = floatstr(ParameterValue); // Store the HouseY
				if (strcmp(ParameterName, "HouseZ", false) == 0) // If the parametername is correct ("HouseZ")
					AHouseData[HouseID][HouseZ] = floatstr(ParameterValue); // Store the HouseZ
				if (strcmp(ParameterName, "HouseLevel", false) == 0) // If the parametername is correct ("HouseLevel")
					AHouseData[HouseID][HouseLevel] = strval(ParameterValue); // Store the HouseLevel
				if (strcmp(ParameterName, "HouseMaxLevel", false) == 0) // If the parametername is correct ("HouseMaxLevel")
					AHouseData[HouseID][HouseMaxLevel] = strval(ParameterValue); // Store the HouseMaxLevel
				if (strcmp(ParameterName, "HousePrice", false) == 0) // If the parametername is correct ("HousePrice")
					AHouseData[HouseID][HousePrice] = strval(ParameterValue); // Store the HousePrice
				if (strcmp(ParameterName, "HouseOpened", false) == 0) // If the parametername is correct ("HouseOpened")
				{
				    if (strcmp(ParameterValue, "Yes", false) == 0) // If the value "Yes" was read
						AHouseData[HouseID][HouseOpened] = true; // House is open to the public (anyone can enter)
					else
						AHouseData[HouseID][HouseOpened] = false; // House is closed to the public, only house-owner can enter
				}
				if (strcmp(ParameterName, "Insurance", false) == 0) // If the parametername is correct ("Insurance")
				{
				    if (strcmp(ParameterValue, "Yes", false) == 0) // If the value "Yes" was read
						AHouseData[HouseID][Insurance] = true; // House has insurance for it's vehicles
					else
						AHouseData[HouseID][Insurance] = false; // House doesn't have insurance
				}

				if (strcmp(ParameterName, "StaticHouse", false) == 0) // If the parametername is correct ("StaticHouse")
				{
				    if (strcmp(ParameterValue, "Yes", false) == 0) // If the value "Yes" was read
						AHouseData[HouseID][StaticHouse] = true; // House is static (not upgradable, fixed interior and carslots)
					else
						AHouseData[HouseID][StaticHouse] = false; // House isn't static (upgradable, interior and carslots based on HouseLevel)
				}
				if (strcmp(ParameterName, "CarSlots", false) == 0) // If the parametername is correct ("CarSlots")
					AHouseData[HouseID][CarSlots] = strval(ParameterValue); // Store the CarSlots
			}

            // Read the next line of the file
			fread(HFile, LineFromFile);
		}

        // Close the file
		fclose(HFile);

		// Add a pickup and 3DText for this house
		House_UpdateEntrance(HouseID);
		// Count the amount of houses that are loaded
	    TotalHouses++;

        // Return if the file was read correctly
		return 1;
	}
	else
	    return 0; // Return 0 if the file couldn't be read (doesn't exist)
}

// This function will load the house's datafile (used when the server is started to load all houses)
// It only reads the data about the vehicles, house-data is skipped
HouseFile_LoadCars(HouseID)
{
	// Setup local variables
	new file[100], File:HFile, LineFromFile[100], ParameterName[50], ParameterValue[50];
	new vid, cModel, cPaint, cComponents[14], Float:cx, Float:cy, Float:cz, Float:crot, Col1, Col2, cFuel;

    // Construct the complete filename for this house-file
	format(file, sizeof(file), HouseFile, HouseID);

	// Check if the HouseFile exists
	if (fexist(file))
	{
	    // Open the housefile for reading
		HFile = fopen(file, io_read);
        // Read the first line of the file
		fread(HFile, LineFromFile);

		// Keep reading until the end of the file is found (no more data)
		// An empty line between data-segments still has the NewLine characters (\r\n) so it's not completely empty
		// Reading past the last line will read a completely empty line, therefore indicating the end of the file
		while (strlen(LineFromFile) > 0)
		{
			StripNewLine(LineFromFile); // Strip any newline characters from the LineFromFile
			sscanf(LineFromFile, "s[50]s[50]", ParameterName, ParameterValue); // Extract parametername and parametervalue

			// Check if there is anything in the LineFromFile (skipping empty lines)
			if (strlen(LineFromFile) > 0)
			{
				if (strcmp(ParameterName, "[Vehicle]", false) == 0) // If the parametername is correct ("[Vehicle]")
				{
				    // Clear all data to start a new vehicle
				    for (new i; i < 14; i++)
				        cComponents[i] = 0;
				}
				if (strcmp(ParameterName, "VehicleModel", false) == 0) // If the parametername is correct ("VehicleModel")
					cModel = strval(ParameterValue); // Store the VehicleModel
				if (strcmp(ParameterName, "VehiclePaintJob", false) == 0) // If the parametername is correct ("VehiclePaintJob")
					cPaint = strval(ParameterValue); // Store the VehiclePaintJob
				if (strcmp(ParameterName, "VehicleSpoiler", false) == 0) // If the parametername is correct ("VehicleSpoiler")
					cComponents[0] = strval(ParameterValue); // Store the VehicleSpoiler
				if (strcmp(ParameterName, "VehicleHood", false) == 0) // If the parametername is correct ("VehicleHood")
					cComponents[1] = strval(ParameterValue); // Store the VehicleHood
				if (strcmp(ParameterName, "VehicleRoof", false) == 0) // If the parametername is correct ("VehicleRoof")
					cComponents[2] = strval(ParameterValue); // Store the VehicleRoof
				if (strcmp(ParameterName, "VehicleSideSkirt", false) == 0) // If the parametername is correct ("VehicleSideSkirt")
					cComponents[3] = strval(ParameterValue); // Store the VehicleSideSkirt
				if (strcmp(ParameterName, "VehicleLamps", false) == 0) // If the parametername is correct ("VehicleLamps")
					cComponents[4] = strval(ParameterValue); // Store the VehicleLamps
				if (strcmp(ParameterName, "VehicleNitro", false) == 0) // If the parametername is correct ("VehicleNitro")
					cComponents[5] = strval(ParameterValue); // Store the VehicleNitro
				if (strcmp(ParameterName, "VehicleExhaust", false) == 0) // If the parametername is correct ("VehicleExhaust")
					cComponents[6] = strval(ParameterValue); // Store the VehicleExhaust
				if (strcmp(ParameterName, "VehicleWheels", false) == 0) // If the parametername is correct ("VehicleWheels")
					cComponents[7] = strval(ParameterValue); // Store the VehicleWheels
				if (strcmp(ParameterName, "VehicleStereo", false) == 0) // If the parametername is correct ("VehicleStereo")
					cComponents[8] = strval(ParameterValue); // Store the VehicleStereo
				if (strcmp(ParameterName, "VehicleHydraulics", false) == 0) // If the parametername is correct ("VehicleHydraulics")
					cComponents[9] = strval(ParameterValue); // Store the VehicleHydraulics
				if (strcmp(ParameterName, "VehicleFrontBumper", false) == 0) // If the parametername is correct ("VehicleFrontBumper")
					cComponents[10] = strval(ParameterValue); // Store the VehicleFrontBumper
				if (strcmp(ParameterName, "VehicleRearBumper", false) == 0) // If the parametername is correct ("VehicleRearBumper")
					cComponents[11] = strval(ParameterValue); // Store the VehicleRearBumper
				if (strcmp(ParameterName, "VehicleVentRight", false) == 0) // If the parametername is correct ("VehicleVentRight")
					cComponents[12] = strval(ParameterValue); // Store the VehicleVentRight
				if (strcmp(ParameterName, "VehicleVentLeft", false) == 0) // If the parametername is correct ("VehicleVentLeft")
					cComponents[13] = strval(ParameterValue); // Store the VehicleVentLeft

				if (strcmp(ParameterName, "Color1", false) == 0) // If the parametername is correct ("Color1")
					Col1 = strval(ParameterValue); // Store the Color1
				if (strcmp(ParameterName, "Color2", false) == 0) // If the parametername is correct ("Color2")
					Col2 = strval(ParameterValue); // Store the Color2

				if (strcmp(ParameterName, "VehicleX", false) == 0) // If the parametername is correct ("VehicleX")
					cx = floatstr(ParameterValue); // Store the VehicleX
				if (strcmp(ParameterName, "VehicleY", false) == 0) // If the parametername is correct ("VehicleY")
					cy = floatstr(ParameterValue); // Store the VehicleY
				if (strcmp(ParameterName, "VehicleZ", false) == 0) // If the parametername is correct ("VehicleZ")
					cz = floatstr(ParameterValue); // Store the VehicleZ
				if (strcmp(ParameterName, "VehicleAngle", false) == 0) // If the parametername is correct ("VehicleAngle")
					crot = floatstr(ParameterValue); // Store the VehicleAngle

				if (strcmp(ParameterName, "Fuel", false) == 0) // If the parametername is correct ("Fuel")
					cFuel = strval(ParameterValue); // Store the Fuel

				if (strcmp(ParameterName, "[/Vehicle]", false) == 0) // If the parametername is correct ("[/Vehicle]")
				{
					// Set both colors to 1 if they are 0 AND if there is a paintjob applied
					if ((Col1 == 0) && (cPaint != 0))
					    Col1 = 1;
					if ((Col2 == 0) && (cPaint != 0))
					    Col2 = 1;

					// The "[/Vehicle]" is found, this means that all data about this vehicle is now stored in the variables
					// Now add the vehicle to the house and set it's data
					vid = House_AddVehicle(HouseID, cModel, cPaint, cComponents, cx, cy, cz, crot, Col1, Col2);

					// Also set the vehicle's fuel
					INT_SetVehicleFuel(vid, cFuel);
				}
			}

            // Read the next line of the file
			fread(HFile, LineFromFile);
		}

        // Close the file
		fclose(HFile);

        // Return if the file was read correctly
		return 1;
	}
	else
	    return 0; // Return 0 if the file couldn't be read (doesn't exist)
}

// This function will save the given house
HouseFile_Save(HouseID)
{
	new file[100], File:HFile, LineForFile[100], vid;

    // Construct the complete filename for this house
	format(file, sizeof(file), HouseFile, HouseID);

    // Open the housefile for writing
	HFile = fopen(file, io_write);

	if (AHouseData[HouseID][Owned] == true) // Check if the house is owned
		format(LineForFile, 100, "Owned Yes\r\n"); // Construct the line: "Owned Yes"
	else
		format(LineForFile, 100, "Owned No\r\n"); // Construct the line: "Owned No"
	fwrite(HFile, LineForFile); // And save it to the file

	format(LineForFile, 100, "Owner %s\r\n", AHouseData[HouseID][Owner]); // Construct the line: "Owner "
	fwrite(HFile, LineForFile); // And save it to the file

	format(LineForFile, 100, "HouseName %s\r\n", AHouseData[HouseID][HouseName]); // Construct the line: "HouseName "
	fwrite(HFile, LineForFile); // And save it to the file
	format(LineForFile, 100, "HouseX %f\r\n", AHouseData[HouseID][HouseX]); // Construct the line: "HouseX "
	fwrite(HFile, LineForFile); // And save it to the file
	format(LineForFile, 100, "HouseY %f\r\n", AHouseData[HouseID][HouseY]); // Construct the line: "HouseY "
	fwrite(HFile, LineForFile); // And save it to the file
	format(LineForFile, 100, "HouseZ %f\r\n", AHouseData[HouseID][HouseZ]); // Construct the line: "HouseZ "
	fwrite(HFile, LineForFile); // And save it to the file
	format(LineForFile, 100, "HouseLevel %i\r\n", AHouseData[HouseID][HouseLevel]); // Construct the line: "HouseLevel "
	fwrite(HFile, LineForFile); // And save it to the file
	format(LineForFile, 100, "HouseMaxLevel %i\r\n", AHouseData[HouseID][HouseMaxLevel]); // Construct the line: "HouseMaxLevel "
	fwrite(HFile, LineForFile); // And save it to the file
	format(LineForFile, 100, "HousePrice %i\r\n", AHouseData[HouseID][HousePrice]); // Construct the line: "HousePrice "
	fwrite(HFile, LineForFile); // And save it to the file

	if (AHouseData[HouseID][HouseOpened] == true) // Check if the house is open to the public
		format(LineForFile, 100, "HouseOpened Yes\r\n"); // Construct the line: "HouseOpened Yes"
	else
		format(LineForFile, 100, "HouseOpened No\r\n"); // Construct the line: "HouseOpened No"
	fwrite(HFile, LineForFile); // And save it to the file

	if (AHouseData[HouseID][Insurance] == true) // Check if the house has insurance for it's vehicles
		format(LineForFile, 100, "Insurance Yes\r\n"); // Construct the line: "Insurance Yes"
	else
		format(LineForFile, 100, "Insurance No\r\n"); // Construct the line: "Insurance No"
	fwrite(HFile, LineForFile); // And save it to the file

	if (AHouseData[HouseID][StaticHouse] == true) // Check if the house is a static house
		format(LineForFile, 100, "StaticHouse Yes\r\n"); // Construct the line: "StaticHouse Yes"
	else
		format(LineForFile, 100, "StaticHouse No\r\n"); // Construct the line: "StaticHouse No"
	fwrite(HFile, LineForFile); // And save it to the file

	format(LineForFile, 100, "CarSlots %i\r\n", AHouseData[HouseID][CarSlots]); // Construct the line: "CarSlots "
	fwrite(HFile, LineForFile); // And save it to the file
	fwrite(HFile, "\r\n"); // Add an empty line, just for readability


	// Save the vehicle-data for every vehicle added to the house
	for (new CarSlot; CarSlot < AHouseData[HouseID][CarSlots]; CarSlot++)
	{
	    // If a valid vehicle-id has been found
		if (AHouseData[HouseID][VehicleIDs][CarSlot] != 0)
		{
			// Get the vehicle id
			vid = AHouseData[HouseID][VehicleIDs][CarSlot];

		    format(LineForFile, 100, "[Vehicle]\r\n"); // Construct the line: "[Vehicle]"
			fwrite(HFile, LineForFile); // And save it to the file

		    format(LineForFile, 100, "VehicleModel %i\r\n", AVehicleData[vid][Model]); // Construct the line: "VehicleModel "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "VehiclePaintJob %i\r\n", AVehicleData[vid][PaintJob]); // Construct the line: "VehiclePaintJob "
			fwrite(HFile, LineForFile); // And save it to the file

		    format(LineForFile, 100, "VehicleSpoiler %i\r\n", AVehicleData[vid][Components][0]); // Construct the line: "VehicleSpoiler "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "VehicleHood %i\r\n", AVehicleData[vid][Components][1]); // Construct the line: "VehicleHood "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "VehicleRoof %i\r\n", AVehicleData[vid][Components][2]); // Construct the line: "VehicleRoof "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "VehicleSideSkirt %i\r\n", AVehicleData[vid][Components][3]); // Construct the line: "VehicleSideSkirt "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "VehicleLamps %i\r\n", AVehicleData[vid][Components][4]); // Construct the line: "VehicleLamps "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "VehicleNitro %i\r\n", AVehicleData[vid][Components][5]); // Construct the line: "VehicleNitro "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "VehicleExhaust %i\r\n", AVehicleData[vid][Components][6]); // Construct the line: "VehicleSpoiler "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "VehicleWheels %i\r\n", AVehicleData[vid][Components][7]); // Construct the line: "VehicleWheels "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "VehicleStereo %i\r\n", AVehicleData[vid][Components][8]); // Construct the line: "VehicleStereo "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "VehicleHydraulics %i\r\n", AVehicleData[vid][Components][9]); // Construct the line: "VehicleHydraulics "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "VehicleFrontBumper %i\r\n", AVehicleData[vid][Components][10]); // Construct the line: "VehicleFrontBumper "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "VehicleRearBumper %i\r\n", AVehicleData[vid][Components][11]); // Construct the line: "VehicleRearBumper "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "VehicleVentRight %i\r\n", AVehicleData[vid][Components][12]); // Construct the line: "VehicleVentRight "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "VehicleVentLeft %i\r\n", AVehicleData[vid][Components][13]); // Construct the line: "VehicleVentLeft "
			fwrite(HFile, LineForFile); // And save it to the file

		    format(LineForFile, 100, "Color1 %i\r\n", AVehicleData[vid][Color1]); // Construct the line: "Color1 "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "Color2 %i\r\n", AVehicleData[vid][Color2]); // Construct the line: "Color2 "
			fwrite(HFile, LineForFile); // And save it to the file

		    format(LineForFile, 100, "VehicleX %f\r\n", AVehicleData[vid][SpawnX]); // Construct the line: "VehicleVentLeft "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "VehicleY %f\r\n", AVehicleData[vid][SpawnY]); // Construct the line: "VehicleVentLeft "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "VehicleZ %f\r\n", AVehicleData[vid][SpawnZ]); // Construct the line: "VehicleVentLeft "
			fwrite(HFile, LineForFile); // And save it to the file
		    format(LineForFile, 100, "VehicleAngle %f\r\n", AVehicleData[vid][SpawnRot]); // Construct the line: "VehicleVentLeft "
			fwrite(HFile, LineForFile); // And save it to the file

		    format(LineForFile, 100, "Fuel %i\r\n", INT_GetVehicleFuel(vid)); // Construct the line: "Fuel "
			fwrite(HFile, LineForFile); // And save it to the file

		    format(LineForFile, 100, "[/Vehicle]\r\n"); // Construct the line: "[/Vehicle]"
			fwrite(HFile, LineForFile); // And save it to the file
			fwrite(HFile, "\r\n"); // Add an empty line, just for readability
		}
	}

	fclose(HFile); // Close the file

	return 1;
}



// ******************************************************************************************************************************
// Housing functions
// ******************************************************************************************************************************

// This function updates (destroys and re-creates) the pickup, map-icon and 3DText label near the house's entrance
House_UpdateEntrance(HouseID)
{
	// Setup local variables
	new Msg[320], Float:x, Float:y, Float:z;

	// Get the coordinates of the house's pickup (usually near the door)
	x = AHouseData[HouseID][HouseX];
	y = AHouseData[HouseID][HouseY];
	z = AHouseData[HouseID][HouseZ];

	// Destroy the pickup, map-icon and 3DText near the house's entrance (if they exist)
	if (IsValidDynamicPickup(AHouseData[HouseID][PickupID]))
		DestroyDynamicPickup(AHouseData[HouseID][PickupID]);
	if (IsValidDynamicMapIcon(AHouseData[HouseID][MapIconID]))
		DestroyDynamicMapIcon(AHouseData[HouseID][MapIconID]);
	if (IsValidDynamic3DTextLabel(AHouseData[HouseID][DoorText]))
		DestroyDynamic3DTextLabel(AHouseData[HouseID][DoorText]);

	// Add a new pickup at the house's location (usually near the door), green = free, blue = owned
	if (AHouseData[HouseID][Owned] == true)
	{
		// Create a blue house-pickup (house is owned)
 		AHouseData[HouseID][PickupID] = CreateDynamicPickup(1272, 1, x, y, z, 0);
		// Create the 3DText that appears above the house-pickup (displays the housename and the name of the owner)
		if (AHouseData[HouseID][StaticHouse] == true)
			format(Msg, 320, "{15D4ED}House Name:{FFFFFF} %s\n{15D4ED}House Owner:{FFFFFF} %s\n{15D4ED}House Value:{FFFFFF} $%i\n{15D4ED}Carslots:{FFFFFF} %i\n{15D4ED}Size:{FFFFFF} %i\n{15D4ED}House ID: {FFCC99}%d", AHouseData[HouseID][HouseName], AHouseData[HouseID][Owner], AHouseData[HouseID][HousePrice], AHouseData[HouseID][CarSlots], AHouseData[HouseID][HouseLevel], HouseID);
		else
			format(Msg, 320, "{15D4ED}House Name:{FFFFFF} %s\n{15D4ED}House Owner:{FFFFFF} %s\n{15D4ED}House Value:{FFFFFF} $%i\n{15D4ED}House level:{FFFFFF} %i\n{15D4ED}House ID: {FFCC99}%d", AHouseData[HouseID][HouseName], AHouseData[HouseID][Owner], AHouseData[HouseID][HousePrice], AHouseData[HouseID][HouseLevel], HouseID);
		AHouseData[HouseID][DoorText] = CreateDynamic3DTextLabel(Msg, 0x008080FF, x, y, z + 1.0, 50.0);
		// Add a streamed icon to the map (red house), type = 32, color = 0, world = 0, interior = 0, playerid = -1, drawdist = 150.0
		if (ShowBoughtHouses == true)
			AHouseData[HouseID][MapIconID] = CreateDynamicMapIcon(x, y, z, 32, 0, 0, 0, -1, 150.0);
	}
	else
	{
        // Create a green house-pickup (house is free)
		AHouseData[HouseID][PickupID] = CreateDynamicPickup(1273, 1, x, y, z, 0);
		// Create the 3DText that appears above the house-pickup (displays the price of the house)
		if (AHouseData[HouseID][StaticHouse] == true)
			format(Msg, 320, "{15D4ED}House Name: {FFFFFF}House For Sale!\n{15D4ED}House Owner: {FFFFFF}No Owner\n{15D4ED}House Value:{FFFFFF} $%i\n{15D4ED}Carslots:{FFFFFF} %i\n{15D4ED}Size:{FFFFFF} %i\n{FFCC99}/buyhouse", AHouseData[HouseID][HousePrice], AHouseData[HouseID][CarSlots], AHouseData[HouseID][HouseLevel]);
		else
			format(Msg, 320, "{15D4ED}House Name: {FFFFFF}House For Sale!\n{15D4ED}House Owner: {FFFFFF}No Owner\n{15D4ED}House Value:{FFFFFF} $%i\n{15D4ED}Max level:{FFFFFF} %i\n{FFCC99}/buyhouse", AHouseData[HouseID][HousePrice], AHouseData[HouseID][HouseMaxLevel]);
		AHouseData[HouseID][DoorText] = CreateDynamic3DTextLabel(Msg, 0x008080FF, x, y, z + 1.0, 50.0);
		// Add a streamed icon to the map (green house), type = 31, color = 0, world = 0, interior = 0, playerid = -1, drawdist = 150.0
		AHouseData[HouseID][MapIconID] = CreateDynamicMapIcon(x, y, z, 31, 0, 0, 0, -1, 150.0);
	}
}

// This function is used to spawn back at the entrance of your house
House_Exit(playerid, HouseID)
{
    DeletePVar(playerid, "InsideHouse");
	// Set the player in the normal world again
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);
	// Set the position of the player at the entrance of his house
	SetPlayerPos(playerid, AHouseData[HouseID][HouseX], AHouseData[HouseID][HouseY], AHouseData[HouseID][HouseZ]);
	// Also clear the tracking-variable to track in which house the player is
	APlayerData[playerid][CurrentHouse] = 0;

	// Check if there is a timer-value set for exiting the house (this timer freezes the player while the environment is being loaded)
	if (ExitHouseTimer > 0)
	{
		// Don't allow the player to fall
	    TogglePlayerControllable(playerid, 0);
		// Let the player know he's frozen for 5 seconds
		GameTextForPlayer(playerid, "Waiting for the environment to load", ExitHouseTimer, 4);
		// Start a timer that will allow the player to fall again when the environment has loaded
		SetTimerEx("House_ExitTimer", ExitHouseTimer, false, "ii", playerid, HouseID);
	}

	return 1;
}

forward House_ExitTimer(playerid, HouseID);
public House_ExitTimer(playerid, HouseID)
{
	// Allow the player to move again (environment should have been loaded now)
    TogglePlayerControllable(playerid, 1);

	// Respawn the player's vehicles near the house (only the vehicles that belong to this house)
	for (new CarSlot; CarSlot < AHouseData[HouseID][CarSlots]; CarSlot++)
		if (AHouseData[HouseID][VehicleIDs][CarSlot] != 0)
		    SetVehicleToRespawn(AHouseData[HouseID][VehicleIDs][CarSlot]);

	return 1;
}

// This function sets ownership to the given player (if he has a free houseslot)
House_SetOwner(playerid, HouseID)
{
	// Setup local variables
	new FreeHouseSlot, Name[24], Msg[128];

	// Get the first free house-slot from this player
	FreeHouseSlot = Player_GetFreeHouseSlot(playerid);

	// Check if the player has a free house-slot
	if (FreeHouseSlot != -1)
	{
		// Get the player's name
		GetPlayerName(playerid, Name, sizeof(Name));

		// Store the house-id for the player
		APlayerData[playerid][Houses][FreeHouseSlot] = HouseID;
		// Let the player pay for the house
		INT_GivePlayerMoney(playerid, -AHouseData[HouseID][HousePrice]);

		// Set the house as owned
		AHouseData[HouseID][Owned] = true;
		// Store the owner-name for the house
		format(AHouseData[HouseID][Owner], 24, Name);
		// Set the level and amount of carslots to 1 for a normal house (keep existing data for a static house)
		if (AHouseData[HouseID][StaticHouse] == false)
		{
			AHouseData[HouseID][HouseLevel] = 1;
			AHouseData[HouseID][CarSlots] = 1;
		}
		// Set the default house-name ("'s house")
		format(AHouseData[HouseID][HouseName], 100, "%s's house", Name);

		// Also, update the pickup and map-icon for this house
		House_UpdateEntrance(HouseID);

		// Save the house-file
		HouseFile_Save(HouseID);

		// Let the player know he bought the house
		format(Msg, 128, "{00FF00}[INFO]: {FFFFFF}You've bought the house for {FFFF00}$%i", AHouseData[HouseID][HousePrice]);
		SendClientMessage(playerid, 0xFFFFFFFF, Msg);
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}[INFO]: {FFFFFF}You already own the maximum amount of allowed houses per player");

	return 1;
}

// This function adds a vehicle to the house (if possible)
House_AddVehicle(HouseID, cModel, cPaint, cComponents[], Float:cx, Float:cy, Float:cz, Float:crot, Col1, Col2)
{
	// Setup local variables
	new vid, CarSlot;

	// Get a free carslot from the house
	CarSlot = House_GetFreeCarSlot(HouseID);

	// Check if there is a free carslot
	if (CarSlot != -1)
	{
		// Create a new vehicle and get the vehicle-id
		vid = CreateVehicle(cModel, cx, cy, cz, crot, Col1, Col2, 600);
		// Store the vehicle-id in the house's free carslot
		AHouseData[HouseID][VehicleIDs][CarSlot] = vid;

		// Save the model of the vehicle
		AVehicleData[vid][Model] = cModel;
		// Save the paintjob of the vehicle and apply it
		AVehicleData[vid][PaintJob] = cPaint;
		if (cPaint != 0)
			ChangeVehiclePaintjob(vid, cPaint - 1);

		// Also update the car-color
		ChangeVehicleColor(vid, Col1, Col2);
		// Save the colors of the vehicle
		AVehicleData[vid][Color1] = Col1;
		AVehicleData[vid][Color2] = Col2;

		// Save the components of the vehicle and apply them
		for (new i; i < 14; i++)
		{
			AVehicleData[vid][Components][i] = cComponents[i];
		    // Check if the componentslot has a valid component-id
			if (AVehicleData[vid][Components][i] != 0)
		        AddVehicleComponent(vid, AVehicleData[vid][Components][i]); // Add the component to the vehicle
		}

		// Save the spawn-data of the vehicle
        AVehicleData[vid][SpawnX] = cx;
        AVehicleData[vid][SpawnY] = cy;
        AVehicleData[vid][SpawnZ] = cz;
        AVehicleData[vid][SpawnRot] = crot;
		// Also set the owner
		AVehicleData[vid][Owned] = true;
		format(AVehicleData[vid][Owner], 24, AHouseData[HouseID][Owner]);
		// Save the HouseID for the vehicle
		AVehicleData[vid][BelongsToHouse] = HouseID;
	}
	else // No free carslot was found, return 0
		return 0;

	// Exit the function and return the vehicle-id
	return vid;
}

// This function is used only when you park a car
House_ReplaceVehicle(HouseID, CarSlot)
{
	// Setup local variables
	new vid, cModel, cPaint, cComponents[14], Float:cx, Float:cy, Float:cz, Float:crot, Col1, Col2, cFuel;

	// Get the data from the already existing vehicle that was parked before
	vid = AHouseData[HouseID][VehicleIDs][CarSlot];
	cModel = AVehicleData[vid][Model];
	cPaint = AVehicleData[vid][PaintJob];
	for (new i; i < 14; i++)
	    cComponents[i] = AVehicleData[vid][Components][i];
	Col1 = AVehicleData[vid][Color1];
	Col2 = AVehicleData[vid][Color2];
	cx = AVehicleData[vid][SpawnX];
	cy = AVehicleData[vid][SpawnY];
	cz = AVehicleData[vid][SpawnZ];
	crot = AVehicleData[vid][SpawnRot];
	cFuel = INT_GetVehicleFuel(vid);

	// Delete the vehicle and clear the data
	Vehicle_Delete(vid, HouseID, CarSlot);

	// Create a new vehicle in the same carslot
	vid = House_AddVehicle(HouseID, cModel, cPaint, cComponents, Float:cx, Float:cy, Float:cz, Float:crot, Col1, Col2);
	// Restore the previous fuel-setting for the new vehicle
	INT_SetVehicleFuel(vid, cFuel);

	// Return the new vehicle-id of the replaced vehicle
	return vid;
}

// This function deletes the vehicle and clears all the data
Vehicle_Delete(vid, HouseID, CarSlot)
{
	// Remove the vehicle from the house
	AHouseData[HouseID][VehicleIDs][CarSlot] = 0;

	// Delete the vehicle
	DestroyVehicle(vid);
	// Clear the data
	AVehicleData[vid][Owned] = false;
	AVehicleData[vid][Owner] = 0;
	AVehicleData[vid][Model] = 0;
	AVehicleData[vid][PaintJob] = 0;
	for (new i; i < 14; i++)
	    AVehicleData[vid][Components][i] = 0;
	AVehicleData[vid][Color1] = 0;
	AVehicleData[vid][Color2] = 0;
	AVehicleData[vid][SpawnX] = 0.0;
	AVehicleData[vid][SpawnY] = 0.0;
	AVehicleData[vid][SpawnZ] = 0.0;
	AVehicleData[vid][SpawnRot] = 0.0;
	AVehicleData[vid][BelongsToHouse] = 0;

	// After deleting the vehicle, the vehicle's id has become available, so restore the fuel to maximum for this id
	// Otherwise newly created vehicles that use this id would have an unpredictable fuel-setting
	INT_SetVehicleFuel(vid, -1);
}

// This function is used only when a player logs out (the vehicles are unloaded)
House_RemoveVehicles(HouseID)
{
	// Setup local variables
	new vid;

	// Loop through all carslots of this house
	for (new CarSlot; CarSlot < AHouseData[HouseID][CarSlots]; CarSlot++)
	{
		// Get the vehicle-id
		vid = AHouseData[HouseID][VehicleIDs][CarSlot];

		// Check if there was a vehicle in this carslot
		if (vid != 0)
		{
			// Delete the vehicle and clear the data
			Vehicle_Delete(vid, HouseID, CarSlot);
		}
	}
}

// This function returns the first free house-slot for the given player
Player_GetFreeHouseSlot(playerid)
{
	// Check if the player has room for another house (he hasn't bought the maximum amount of houses per player yet)
	// and get the slot-id
	for (new HouseSlot; HouseSlot < MAX_HOUSESPERPLAYER; HouseSlot++) // Loop through all house-slots of the player
		if (APlayerData[playerid][Houses][HouseSlot] == 0) // Check if this house slot is free
		    return HouseSlot; // Return the free HouseSlot for this player

	// If there were no free house-slots, return "-1"
	return -1;
}

// This function returns "1" if the given player is the owner of the given house
House_PlayerIsOwner(playerid, HouseID)
{
	// Loop through all houses owner by this player
	for (new HouseSlot; HouseSlot < MAX_HOUSESPERPLAYER; HouseSlot++)
	{
		// Check if the player owns the house in any of his house-slots
		if (APlayerData[playerid][Houses][HouseSlot] == HouseID)
		    return 1;
	}

	// If the player doesn't own the house, return 0
	return 0;
}

// This function returns the first free carslot in the given house (or -1 if no free slot is found)
House_GetFreeCarSlot(HouseID)
{
	// Get the maximum number of carslots for this house and make a loop through all carslots for this house
	for (new CarSlot; CarSlot < AHouseData[HouseID][CarSlots]; CarSlot++)
	{
		// Check if the carslot is empty
		if (AHouseData[HouseID][VehicleIDs][CarSlot] == 0)
		    return CarSlot; // Return the carslot-id
	}

	// If no carslots are free, return -1
	return -1;
}

// This function calculates the sell-price for the given house
House_CalcSellPrice(HouseID)
{
	// Setup local variables
	new SellPrice, NumUpgrades, UpgradePrice;

	// Calculate 50% of the original buying price (base-price for selling)
	SellPrice = AHouseData[HouseID][HousePrice] / 2;
	// Calculate the number of upgrades applied to the house
	NumUpgrades = AHouseData[HouseID][HouseLevel] - 1;
	// Also calculate 50% for each upgrade, based on the percentage for upgrading the house
	UpgradePrice = ((AHouseData[HouseID][HousePrice] / 100) * HouseUpgradePercent) * NumUpgrades;

	// Add 50% of the upgrade-price to the sell-price
	SellPrice = SellPrice + UpgradePrice;

	// Return the total sell-price to the calling function
	return SellPrice;
}

// This function searches the ABuyableVehicles array to search for the model and returns the index in the array
VehicleBuyable_GetIndex(vModel)
{
	// Loop through all vehicles in the ABuyableVehicles array
	for (new i; i < sizeof(ABuyableVehicles); i++)
	{
	    // Check if the model of the current vehicle is the same as the given model
		if (ABuyableVehicles[i][CarModel] == vModel)
		    return i; // Return the index of the array where the carmodel was found
	}

	return -1;
}



// ******************************************************************************************************************************
// Support functions
// ******************************************************************************************************************************

// This function is copied from the include-file "dutils.inc"
stock StripNewLine(string[])
{
	new len = strlen(string); // Get the length of the given string

	if (string[0] == 0) return ; // If the given string is empty, exit the function
	if ((string[len - 1] == '\n') || (string[len - 1] == '\r')) // If the string ends with \n or \r
	{
		string[len - 1] = 0; // Replace the \n or \r with a 0 character
		if (string[0]==0) return ; // If the string became empty, exit the function
		if ((string[len - 2] == '\n') || (string[len - 2] == '\r')) // Check again if the string ends with \n or \r
			string[len - 2] = 0; // Replace the \n or \r again with a 0 character
	}
}



// ******************************************************************************************************************************
// Special functions that try to access external public functions to retreive or set data from another script
// ******************************************************************************************************************************

// This function is used to get the player's money
INT_GetPlayerMoney(playerid)
{
	// Setup local variables
	new Money;

	// Try to call the external function to get the player's money (used to get the serversided money for this player)
	Money = CallRemoteFunction("Admin_GetPlayerMoney", "i", playerid);

	// The external function returned "0" (as the player doesn't have any money yet), or the function is not used in another script
	if (Money == 0)
		return GetPlayerMoney(playerid); // Return the normal money of the player
	else
		return Money; // Return the money that was returned by the external function
}

// This function is used to set the player's money
INT_GivePlayerMoney(playerid, Money)
{
	// Setup local variables
	new Success;

	// Try to call the external function to get the player's money (used to get the serversided money for this player)
	Success = CallRemoteFunction("Admin_GivePlayerMoney", "ii", playerid, Money);

	// The external function returned "0" as the function is not used in another script
	if (Success == 0)
		GivePlayerMoney(playerid, Money); // Use the normal money (client-sided money)
}

// This function checks if the admin-level of a player is sufficient
INT_CheckPlayerAdminLevel(playerid, AdminLevel)
{
	// Setup local variables
	new Level;

	// Check if the player is an RCON admin
	if (IsPlayerAdmin(playerid))
	    return 1; // Return 1 to indicate this player has a sufficient admin-level to use a command

	// If the player is not an RCON admin, try to get his admin-level from an external script using a remote function
	Level = CallRemoteFunction("Admin_GetPlayerAdminLevel", "i", playerid);
	// Check if the player has a sufficient admin-level
	if (Level >= AdminLevel)
	    return 1; // Return 1 to indicate this player has a sufficient admin-level
	else
		return 0; // Return 0 to indicate this player has an insufficient admin-level
}

// This function checks if the player has logged in properly by entering his password
INT_IsPlayerLoggedIn(playerid)
{
	// Setup local variables
	new LoggedIn;

	// Try to determine if the player logged in properly by entering his password in another script
	LoggedIn = CallRemoteFunction("Admin_IsPlayerLoggedIn", "i", playerid);

	// Check if the player has logged in properly
	switch (LoggedIn)
	{
		case 0: return 1; // No admin script present that holds the LoggedIn status of a player, so allow a command to be used
		case 1: return 1; // The player logged in properly by entering his password, allow commands to be used
		case -1: return 0; // There is an admin script present, but the player hasn't entered his password yet, so block all commands
							// This prevents executing the commands using F6 during login with an admin-account before entering a password
	}

	// In any other case, block all commands
	return 0;
}

// This function sets the fuel of the given vehicle to the given value (calls the PPC_Speedometer script)
INT_SetVehicleFuel(vehicleid, Fuel)
{
	// Call the remote function in the PPC_Speedometer script to set the given vehicle's fuel
	CallRemoteFunction("Speedo_SetVehicleFuel", "ii", vehicleid, Fuel);
}

// This function tries to get the vehicle's fuel from the PPC_Speedometer script
INT_GetVehicleFuel(vehicleid)
{
	// Call the remote function in the PPC_Speedometer script to get the vehicle's fuel
	return CallRemoteFunction("Speedo_GetVehicleFuel", "i", vehicleid);
}

// This function tries to cetermine if the player is in jail
INT_IsPlayerJailed(playerid)
{
	// Setup local variables
	new Jailed;

	// Try to determine if the player is jailed
	Jailed = CallRemoteFunction("Admin_IsPlayerJailed", "i", playerid);

	// Check if the player is jailed
	switch (Jailed)
	{
		case 0: return 0; // No admin script present, so there is no jail either
		case 1: return 1; // The player is jailed, so return "1"
		case -1: return 0; // There is an admin script present, but the player isn't jailed
	}

	// In any other case, return "0" (player not jailed)
	return 0;
}



// ******************************************************************************************************************************
// External functions to be used from within other filterscripts or gamemode (these aren't called anywhere inside this script)
// These functions can be called from other filterscripts or the gamemode to get data from the housing filterscript
// ******************************************************************************************************************************

// This function returns "1" if the given vehicle is owned by a player (a vehicle belonging to this script, as this script
// only holds owned vehicles
forward Housing_IsVehicleOwned(vehicleid);
public Housing_IsVehicleOwned(vehicleid)
{
	// Check if the vehicle is owned by a player
	if (AVehicleData[vehicleid][Owned] == true)
	    return 1; // The vehicle is owned, return 1
	else
	    return -1; // The vehicle is not owned, return -1
}



// ******************************************************************************************************************************
// Functions that need to be placed in the gamemode or filterscript which holds the playerdata
// Only needed when the server uses server-sided money, otherwise the normal money is used
// ******************************************************************************************************************************

/*
// This function is used to get the player's money
forward Admin_GetPlayerMoney(playerid);
public Admin_GetPlayerMoney(playerid)
{
	return APlayerData[playerid][PlayerMoney];
}

// This function is used to get the player's money
forward Admin_GivePlayerMoney(playerid, Money);
public Admin_GivePlayerMoney(playerid, Money)
{
	// Add the given money to the player's account
	APlayerData[playerid][PlayerMoney] = APlayerData[playerid][PlayerMoney] + Money;

	// Return that the function had success
	return 1;
}

// This function is used to get the player's admin-level
forward Admin_GetPlayerAdminLevel(playerid);
public Admin_GetPlayerAdminLevel(playerid)
{
	return APlayerData[playerid][AdminLevel];
}

// This function is used to determine if the player has logged in (he succesfully entered his password)
forward Admin_IsPlayerLoggedIn(playerid);
public Admin_IsPlayerLoggedIn(playerid)
{
	if (APlayerData[playerid][LoggedIn] == true)
	    return 1; // The player has logged in succesfully
	else
	    return -1; // The player hasn't logged in (yet)
}
// This function is used to determine if a player is jailed
forward Admin_IsPlayerJailed(playerid);
public Admin_IsPlayerJailed(playerid)
{
	// Check if a player has jaimtime left
	if (APlayerData[playerid][PlayerJailed] == true)
	    return 1; // The player is still jailed
	else
	    return -1; // The player is not jailed
}

// This function can be used to get the fuel-status from the given vehicle
forward Speedo_GetVehicleFuel(vehicleid);
public Speedo_GetVehicleFuel(vehicleid)
{
	return AVehicleData[vehicleid][Fuel];
}

// This function can be used to set the fuel-status for the given vehicle
forward Speedo_SetVehicleFuel(vehicleid, fuel);
public Speedo_SetVehicleFuel(vehicleid, fuel)
{
	// If a fuel-value of -1 is used, this will refuel the vehicle to maximum fuel
	if (fuel == -1)
	{
		AVehicleData[vehicleid][Fuel] = MaxFuel; // Set fuel to maximum
		return 1; // Return 1 (this can be used in the other script to check if the function was called successfully)
	}

	// Fuel cannot be negative (other negative values are ignored)
	if (fuel >= 0)
	{
		// Check if the fuel is within normal limits
		if (fuel > MaxFuel)
			AVehicleData[vehicleid][Fuel] = MaxFuel; // If a higher value was given than allowed (higher than MaxFuel), set fuel to maximum
		else
			AVehicleData[vehicleid][Fuel] = fuel; // Set the fuel to the given value
	}
	else
	    return -1; // Return -1 (this can be used in the other script to check if the function was called successfully,
					// but the fuel-value was not acceptable)

	// Return 1 (this can be used in the other script to check if the function was called successfully)
	return 1;
}
*/


