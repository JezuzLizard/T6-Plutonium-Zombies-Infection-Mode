//checked includes changed to match cerberus output
#include maps/mp/gametypes_zm/zcleansed;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/_visionset_mgr;
#include character/c_zom_zombie_buried_saloongirl_mp;
#include maps/mp/zm_buried_gamemodes;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_unitrigger;

struct_init()
{
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_weapupgrade", "p6_anim_zm_buildable_pap", ( 0, 191.4, 0 ), ( 1205.61, 698.608, -17.68 ) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( 0, 1, 0 ),( -665.13, 1069.13, 9.49 ) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_longersprint", "zombie_vending_marathon", ( 0, 0, 0 ), ( 761.63, 1542.25, 0 ) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_rof", "zombie_vending_doubletap2", ( 0, 180, 0 ), ( 2328, 936.5, 88 ) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_additionalprimaryweapon", "zombie_vending_three_gun", ( 0, 180, 0 ), ( -711, -1249.5, 140.5 ) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_fastreload", "zombie_vending_sleight", ( 0, 90, 0 ), ( -170.5, -328.25, 144 ) );
}

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
	deletechalktriggers();
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
	//spawnmapcollision( "zm_collision_buried_street_turned" );
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

/*
_weapon_spawner( weapon_angles, weapon_coordinates, chalk_fx, weapon_name, weapon_model, target, targetname )
{
	tempmodel = spawn( "script_model", ( 0, 0, 0 ) );
	precachemodel( weapon_model );
	unitrigger_stub = spawnstruct();
	unitrigger_stub.origin = weapon_coordinates;
	unitrigger_stub.angles = weapon_angles;
	tempmodel.origin = weapon_coordinates;
	tempmodel.angles = weapon_angles;
	mins = undefined;
	maxs = undefined;
	absmins = undefined;
	absmaxs = undefined;
	tempmodel setmodel( weapon_model );
	tempmodel useweaponhidetags( weapon_name );
	mins = tempmodel getmins();
	maxs = tempmodel getmaxs();
	absmins = tempmodel getabsmins();
	absmaxs = tempmodel getabsmaxs();
	bounds = absmaxs - absmins;
	unitrigger_stub.script_length = bounds[ 0 ] * 0.25;
	unitrigger_stub.script_width = bounds[ 1 ];
	unitrigger_stub.script_height = bounds[ 2 ];
	unitrigger_stub.origin -= anglesToRight( unitrigger_stub.angles ) * ( unitrigger_stub.script_length * 0.4 );
	unitrigger_stub.target = target;
	unitrigger_stub.targetname = targetname;
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	if ( unitrigger_stub.targetname == "weapon_upgrade" )
	{
		unitrigger_stub.cost = get_weapon_cost( weapon_name );
		if ( !is_true( level.monolingustic_prompt_format ) )
		{
			unitrigger_stub.hint_string = get_weapon_hint( weapon_name );
			unitrigger_stub.hint_parm1 = unitrigger_stub.cost;
		}
		else
		{
			unitrigger_stub.hint_parm1 = get_weapon_display_name( weapon_name );
			if ( !isDefined( unitrigger_stub.hint_parm1 ) || unitrigger_stub.hint_parm1 == "" || unitrigger_stub.hint_parm1 == "none" )
			{
				unitrigger_stub.hint_parm1 = "missing weapon name " + weapon_name;
			}
			unitrigger_stub.hint_parm2 = unitrigger_stub.cost;
			unitrigger_stub.hint_string = &"ZOMBIE_WEAPONCOSTONLY";
		}
	}
	unitrigger_stub.weapon_upgrade = weapon_name;
	unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	unitrigger_stub.require_look_at = 1;
	unitrigger_stub.require_look_from = 0;
	unitrigger_stub.zombie_weapon_upgrade = weapon_name;
	maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	if ( is_melee_weapon( weapon_name ) )
	{
		if ( weapon_name == "tazer_knuckles_zm" && isDefined( level.taser_trig_adjustment ) )
		{
			unitrigger_stub.origin += level.taser_trig_adjustment;
		}
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::melee_weapon_think );
	}
	else if ( weapon_name == "claymore_zm" )
	{
		unitrigger_stub.prompt_and_visibility_func = ::claymore_unitrigger_update_prompt;
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::buy_claymores );
	}
	else
	{
		unitrigger_stub.prompt_and_visibility_func = ::wall_weapon_update_prompt;
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
	}
	tempmodel delete();
    thread playchalkfx( chalk_fx, weapon_coordinates, weapon_angles );
}
*/