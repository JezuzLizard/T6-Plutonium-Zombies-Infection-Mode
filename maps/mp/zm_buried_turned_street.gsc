//checked includes changed to match cerberus output
#include maps/mp/gametypes_zm/zcleansed;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/_visionset_mgr;
#include character/c_zom_zombie_buried_saloongirl_mp;
#include maps/mp/zm_buried_gamemodes;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

precache() //checked matches cerberus output
{
	precachemodel( "zm_collision_buried_street_turned" );
	precachemodel( "p6_zm_bu_buildable_bench_tarp" );
	character/c_zom_zombie_buried_saloongirl_mp::precache();
	precachemodel( "c_zom_buried_zombie_sgirl_viewhands" );
	maps/mp/_visionset_mgr::vsmgr_register_info( "overlay", "zm_transit_burn", 1, 21, 15, 1, maps/mp/_visionset_mgr::vsmgr_duration_lerp_thread_per_player, 0 );
}

main() //checked matches cerberus output
{
	flag_init( "sloth_blocker_towneast" );
	level.custom_zombie_player_loadout = ::custom_zombie_player_loadout;
	getspawnpoints();
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "street" );
	street_treasure_chest_init();
	generatebuildabletarps();
	//deletechalktriggers();
	//deleteslothbarricade( "candystore_alley" );
	deleteslothbarricades( 0 );
	//deletebuyabledebris( 1 );
	powerswitchstate( 1 );
	level.cleansed_loadout = getgametypesetting( "cleansedLoadout" );
	if ( level.cleansed_loadout )
	{
		level.humanify_custom_loadout = maps/mp/gametypes_zm/zcleansed::gunprogressionthink;
		level.cleansed_zombie_round = 5;
	}
	else
	{
		level.humanify_custom_loadout = maps/mp/gametypes_zm/zcleansed::shotgunloadout;
		level.cleansed_zombie_round = 2;
	}
	spawnmapcollision( "zm_collision_buried_street_turned" );
	flag_wait( "initial_blackscreen_passed" );
	flag_wait( "start_zombie_round_logic" );
	flag_set( "power_on" );
	clientnotify( "pwr" );
}

custom_zombie_player_loadout() //checked matches cerberus output
{
	self character/c_zom_zombie_buried_saloongirl_mp::main();
	self setviewmodel( "c_zom_buried_zombie_sgirl_viewhands" );
}

getspawnpoints() //checked matches cerberus output
{
	level._turned_zombie_spawners = getentarray( "game_mode_spawners", "targetname" );
	level._turned_zombie_spawnpoints = getstructarray( "street_turned_zombie_spawn", "targetname" );
	level._turned_zombie_respawnpoints = getstructarray( "street_turned_player_respawns", "targetname" );
	level._turned_powerup_spawnpoints = getstructarray( "street_turned_powerups", "targetname" );
}

onendgame() //checked matches cerberus output
{
}

street_treasure_chest_init() //checked matches cerberus output
{
	start_chest = getstruct( "start_chest", "script_noteworthy" );
	court_chest = getstruct( "courtroom_chest1", "script_noteworthy" );
	tunnel_chest = getstruct( "tunnels_chest1", "script_noteworthy" );
	jail_chest = getstruct( "jail_chest1", "script_noteworthy" );
	gun_chest = getstruct( "gunshop_chest", "script_noteworthy" );
	setdvar( "disableLookAtEntityLogic", 1 );
	level.chests = [];
	level.chests[ level.chests.size ] = start_chest;
	level.chests[ level.chests.size ] = court_chest;
	level.chests[ level.chests.size ] = tunnel_chest;
	level.chests[ level.chests.size ] = jail_chest;
	level.chests[ level.chests.size ] = gun_chest;
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( "start_chest" );
}