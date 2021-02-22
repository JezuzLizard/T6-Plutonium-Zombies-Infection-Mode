//checked includes changed to match cerberus output
#include maps/mp/gametypes_zm/_spawnlogic;
#include maps/mp/animscripts/traverse/shared;
#include maps/mp/animscripts/utility;
#include maps/mp/zombies/_load;
#include maps/mp/_demo;
#include maps/mp/_global_fx;
#include maps/mp/_createfx;
#include maps/mp/_art;
#include maps/mp/_serverfaceanim_mp;
#include maps/mp/_fxanim;
#include maps/mp/_music;
#include maps/mp/_busing;
#include maps/mp/_audio;
#include maps/mp/_interactive_objects;
#include maps/mp/_script_gen;
#include maps/mp/_utility;
#include common_scripts/utility;

main( bscriptgened, bcsvgened, bsgenabled ) //checked partially changed to match cerberus output
{
	if ( !isDefined( level.script_gen_dump_reasons ) )
	{
		level.script_gen_dump_reasons = [];
	}
	if ( !isDefined( bsgenabled ) )
	{
		level.script_gen_dump_reasons[ level.script_gen_dump_reasons.size ] = "First run";
	}
	if ( !isDefined( bcsvgened ) )
	{
		bcsvgened = 0;
	}
	level.bcsvgened = bcsvgened;
	if ( !isDefined( bscriptgened ) )
	{
		bscriptgened = 0;
	}
	else
	{
		bscriptgened = 1;
	}
	level.bscriptgened = bscriptgened;
	level._loadstarted = 1;
	struct_class_init();
	if ( getDvar( "cg_usingClientScripts" ) != "" ) //changed at own discretion
	{
		level.clientscripts = getDvar( "cg_usingClientScripts" );
	}
	
	level._client_exploders = [];
	level._client_exploder_ids = [];
	if ( !isDefined( level.flag ) )
	{
		level.flag = [];
		level.flags_lock = [];
	}
	if ( !isDefined( level.timeofday ) )
	{
		level.timeofday = "day";
	}
	flag_init( "scriptgen_done" );
	level.script_gen_dump_reasons = [];
	if ( !isDefined( level.script_gen_dump ) )
	{
		level.script_gen_dump = [];
		level.script_gen_dump_reasons[ 0 ] = "First run";
	}
	if ( !isDefined( level.script_gen_dump2 ) )
	{
		level.script_gen_dump2 = [];
	}
	if ( isDefined( level.createfxent ) && isDefined( level.script ) )
	{
		script_gen_dump_addline( "maps\\mp\\createfx\\" + level.script + "_fx::main();", level.script + "_fx" );
	}
	if ( isDefined( level.script_gen_dump_preload ) )
	{
		for ( i = 0; i < level.script_gen_dump_preload.size; i++ )
		{
			script_gen_dump_addline( level.script_gen_dump_preload[ i ].string, level.script_gen_dump_preload[ i ].signature );
		}
	}
	if ( getDvar( "scr_RequiredMapAspectratio" ) == "" )
	{
		setdvar( "scr_RequiredMapAspectratio", "1" );
	}
	setdvar( "r_waterFogTest", 0 );
	precacherumble( "reload_small" );
	precacherumble( "reload_medium" );
	precacherumble( "reload_large" );
	precacherumble( "reload_clipin" );
	precacherumble( "reload_clipout" );
	precacherumble( "reload_rechamber" );
	precacherumble( "pullout_small" );
	precacherumble( "buzz_high" );
	precacherumble( "riotshield_impact" );
	registerclientsys( "levelNotify" );
	level.aitriggerspawnflags = getaitriggerflags();
	level.vehicletriggerspawnflags = getvehicletriggerflags();
	level.physicstracemaskphysics = 1;
	level.physicstracemaskvehicle = 2;
	level.physicstracemaskwater = 4;
	level.physicstracemaskclip = 8;
	level.physicstracecontentsvehicleclip = 16;
	if ( getDvar( "createfx" ) != "" )
	{
		level.createfx_enabled = getDvar( "createfx" );
	}
	level thread start_intro_screen_zm();
	thread maps/mp/_interactive_objects::init();
	maps/mp/_audio::init();
	thread maps/mp/_busing::businit();
	thread maps/mp/_music::music_init();
	thread maps/mp/_fxanim::init();
	thread maps/mp/_serverfaceanim_mp::init();
	if ( level.createfx_enabled )
	{
		setinitialplayersconnected();
	}
	visionsetnight( "default_night" );
	setup_traversals();
	maps/mp/_art::main();
	setupexploders();
	parse_structs();
	thread footsteps();
	/*
/#
	level thread level_notify_listener();
	level thread client_notify_listener();
#/
	*/
	thread maps/mp/_createfx::fx_init();
	if ( level.createfx_enabled )
	{
		calculate_map_center();
		maps/mp/_createfx::createfx();
	}
	if ( getDvar( "r_reflectionProbeGenerate" ) == "1" )
	{
		maps/mp/_global_fx::main();
		level waittill( "eternity" );
	}
	thread maps/mp/_global_fx::main();
	maps/mp/_demo::init();
	for ( p = 0; p < 6; p++ )
	{
		switch( p )
		{
			case 0:
				triggertype = "trigger_multiple";
				break;
			case 1:
				triggertype = "trigger_once";
				break;
			case 2:
				triggertype = "trigger_use";
				break;
			case 3:
				triggertype = "trigger_radius";
				break;
			case 4:
				triggertype = "trigger_lookat";
				break;
			default:
			/*
/#
				assert( p == 5 );
#/
			*/
				triggertype = "trigger_damage";
				break;
		}
		triggers = getentarray( triggertype, "classname" );
		for ( i = 0; i < triggers.size; i++ )
		{
			if ( isDefined( triggers[ i ].script_prefab_exploder ) )
			{
				triggers[ i ].script_exploder = triggers[ i ].script_prefab_exploder;
			}
			if ( isDefined( triggers[ i ].script_exploder ) )
			{
				level thread maps/mp/zombies/_load::exploder_load( triggers[ i ] );
			}
		}
	}
	if ( getDvar( "g_gametype" ) == "zcleansed" )
	{ 
		register_perk_locations_zcleansed();
	}
}

level_notify_listener() //checked matches cerberus output
{
	while ( 1 )
	{
		val = getDvar( "level_notify" );
		if ( val != "" )
		{
			level notify( val );
			setdvar( "level_notify", "" );
		}
		wait 0.2;
	}
}

client_notify_listener() //checked matches cerberus output
{
	while ( 1 )
	{
		val = getDvar( "client_notify" );
		if ( val != "" )
		{
			clientnotify( val );
			setdvar( "client_notify", "" );
		}
		wait 0.2;
	}
}

footsteps() //checked matches cerberus output
{
	if ( is_true( level.fx_exclude_footsteps ) )
	{
		return;
	}
	maps/mp/animscripts/utility::setfootstepeffect( "asphalt", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "brick", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "carpet", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "cloth", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "concrete", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "dirt", loadfx( "bio/player/fx_footstep_sand" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "foliage", loadfx( "bio/player/fx_footstep_sand" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "gravel", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "grass", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "metal", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "mud", loadfx( "bio/player/fx_footstep_mud" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "paper", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "plaster", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "rock", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "sand", loadfx( "bio/player/fx_footstep_sand" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "water", loadfx( "bio/player/fx_footstep_water" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "wood", loadfx( "bio/player/fx_footstep_dust" ) );
}

parse_structs() //checked matches cerberus output
{
	for ( i = 0; i < level.struct.size; i++ )
	{
		if ( isDefined( level.struct[ i ].targetname ) )
		{
			if ( level.struct[ i ].targetname == "flak_fire_fx" )
			{
				level._effect[ "flak20_fire_fx" ] = loadfx( "weapon/tracer/fx_tracer_flak_single_noExp" );
				level._effect[ "flak38_fire_fx" ] = loadfx( "weapon/tracer/fx_tracer_quad_20mm_Flak38_noExp" );
				level._effect[ "flak_cloudflash_night" ] = loadfx( "weapon/flak/fx_flak_cloudflash_night" );
				level._effect[ "flak_burst_single" ] = loadfx( "weapon/flak/fx_flak_single_day_dist" );
			}
			if ( level.struct[ i ].targetname == "fake_fire_fx" )
			{
				level._effect[ "distant_muzzleflash" ] = loadfx( "weapon/muzzleflashes/heavy" );
			}
			if ( level.struct[ i ].targetname == "spotlight_fx" )
			{
				level._effect[ "spotlight_beam" ] = loadfx( "env/light/fx_ray_spotlight_md" );
			}
		}
	}
}

exploder_load( trigger ) //checked matches cerberus output
{
	level endon( "killexplodertridgers" + trigger.script_exploder );
	trigger waittill( "trigger" );
	if ( isDefined( trigger.script_chance ) && randomfloat( 1 ) > trigger.script_chance )
	{
		if ( isDefined( trigger.script_delay ) )
		{
			wait trigger.script_delay;
		}
		else
		{
			wait 4;
		}
		level thread exploder_load( trigger );
		return;
	}
	maps/mp/_utility::exploder( trigger.script_exploder );
	level notify( "killexplodertridgers" + trigger.script_exploder );
}

setupexploders() //checked partially changed to match cerberus output
{
	ents = getentarray( "script_brushmodel", "classname" );
	smodels = getentarray( "script_model", "classname" );
	for ( i = 0; i < smodels.size; i++ )
	{
		ents[ ents.size ] = smodels[ i ];
	}
	i = 0;
	while ( i < ents.size )
	{
		if ( isDefined( ents[ i ].script_prefab_exploder ) )
		{
			ents[ i ].script_exploder = ents[ i ].script_prefab_exploder;
		}
		if ( isDefined( ents[ i ].script_exploder ) )
		{
			if ( ents[ i ].model == "fx" || !isDefined( ents[ i ].targetname ) && ents[ i ].targetname != "exploderchunk" )
			{
				ents[ i ] hide();
				i++;
				continue;
			}
			if ( isDefined( ents[ i ].targetname ) && ents[ i ].targetname == "exploder" )
			{
				ents[ i ] hide();
				ents[ i ] notsolid();
				i++;
				continue;
			}
			if ( isDefined( ents[ i ].targetname ) && ents[ i ].targetname == "exploderchunk" )
			{
				ents[ i ] hide();
				ents[ i ] notsolid();
			}
		}
		i++;
	}
	script_exploders = [];
	potentialexploders = getentarray( "script_brushmodel", "classname" );
	for ( i = 0; i < potentialexploders.size; i++ )
	{
		if ( isDefined( potentialexploders[ i ].script_prefab_exploder ) )
		{
			potentialexploders[ i ].script_exploder = potentialexploders[ i ].script_prefab_exploder;
		}
		if ( isDefined( potentialexploders[ i ].script_exploder ) )
		{
			script_exploders[ script_exploders.size ] = potentialexploders[ i ];
		}
	}
	potentialexploders = getentarray( "script_model", "classname" );
	for ( i = 0; i < potentialexploders.size; i++ )
	{
		if ( isDefined( potentialexploders[ i ].script_prefab_exploder ) )
		{
			potentialexploders[ i ].script_exploder = potentialexploders[ i ].script_prefab_exploder;
		}
		if ( isDefined( potentialexploders[ i ].script_exploder ) )
		{
			script_exploders[ script_exploders.size ] = potentialexploders[ i ];
		}
	}
	potentialexploders = getentarray( "item_health", "classname" );
	for ( i = 0; i < potentialexploders.size; i++ )
	{
		if ( isDefined( potentialexploders[ i ].script_prefab_exploder ) )
		{
			potentialexploders[ i ].script_exploder = potentialexploders[ i ].script_prefab_exploder;
		}
		if ( isDefined( potentialexploders[ i ].script_exploder ) )
		{
			script_exploders[ script_exploders.size ] = potentialexploders[ i ];
		}
	}
	if ( !isDefined( level.createfxent ) )
	{
		level.createfxent = [];
	}
	acceptabletargetnames = [];
	acceptabletargetnames[ "exploderchunk visible" ] = 1;
	acceptabletargetnames[ "exploderchunk" ] = 1;
	acceptabletargetnames[ "exploder" ] = 1;
	for ( i = 0; i < script_exploders.size; i++ )
	{
		exploder = script_exploders[ i ];
		ent = createexploder( exploder.script_fxid );
		ent.v = [];
		ent.v[ "origin" ] = exploder.origin;
		ent.v[ "angles" ] = exploder.angles;
		ent.v[ "delay" ] = exploder.script_delay;
		ent.v[ "firefx" ] = exploder.script_firefx;
		ent.v[ "firefxdelay" ] = exploder.script_firefxdelay;
		ent.v[ "firefxsound" ] = exploder.script_firefxsound;
		ent.v[ "firefxtimeout" ] = exploder.script_firefxtimeout;
		ent.v[ "earthquake" ] = exploder.script_earthquake;
		ent.v[ "damage" ] = exploder.script_damage;
		ent.v[ "damage_radius" ] = exploder.script_radius;
		ent.v[ "soundalias" ] = exploder.script_soundalias;
		ent.v[ "repeat" ] = exploder.script_repeat;
		ent.v[ "delay_min" ] = exploder.script_delay_min;
		ent.v[ "delay_max" ] = exploder.script_delay_max;
		ent.v[ "target" ] = exploder.target;
		ent.v[ "ender" ] = exploder.script_ender;
		ent.v[ "type" ] = "exploder";
		if ( !isDefined( exploder.script_fxid ) )
		{
			ent.v[ "fxid" ] = "No FX";
		}
		else
		{
			ent.v[ "fxid" ] = exploder.script_fxid;
		}
		ent.v[ "exploder" ] = exploder.script_exploder;
		/*
/#
		assert( isDefined( exploder.script_exploder ), "Exploder at origin " + exploder.origin + " has no script_exploder" );
#/
		*/
		if ( !isDefined( ent.v[ "delay" ] ) )
		{
			ent.v[ "delay" ] = 0;
		}
		if ( isDefined( exploder.target ) )
		{
			org = getent( ent.v[ "target" ], "targetname" ).origin;
			ent.v[ "angles" ] = vectorToAngles( org - ent.v[ "origin" ] );
		}
		if ( exploder.classname == "script_brushmodel" || isDefined( exploder.model ) )
		{
			ent.model = exploder;
			ent.model.disconnect_paths = exploder.script_disconnectpaths;
		}
		if ( isDefined( exploder.targetname ) && isDefined( acceptabletargetnames[ exploder.targetname ] ) )
		{
			ent.v[ "exploder_type" ] = exploder.targetname;
		}
		else
		{
			ent.v[ "exploder_type" ] = "normal";
		}
		ent maps/mp/_createfx::post_entity_creation_function();
	}
	level.createfxexploders = [];
	i = 0;
	while ( i < level.createfxent.size )
	{
		ent = level.createfxent[ i ];
		if ( ent.v[ "type" ] != "exploder" )
		{
			i++;
			continue;
		}
		ent.v[ "exploder_id" ] = getexploderid( ent );
		if ( !isDefined( level.createfxexploders[ ent.v[ "exploder" ] ] ) )
		{
			level.createfxexploders[ ent.v[ "exploder" ] ] = [];
		}
		level.createfxexploders[ ent.v[ "exploder" ] ][ level.createfxexploders[ ent.v[ "exploder" ] ].size ] = ent;
		i++;
	}
}

setup_traversals() //checked changed to match cerberus output
{
	potential_traverse_nodes = getallnodes();
	for ( i = 0; i < potential_traverse_nodes.size; i++ )
	{
		node = potential_traverse_nodes[ i ];
		if ( node.type == "Begin" )
		{
			node maps/mp/animscripts/traverse/shared::init_traverse();
		}
	}
}

calculate_map_center() //checked matches cerberus output
{
	if ( !isDefined( level.mapcenter ) )
	{
		level.nodesmins = ( 0, 0, 0 );
		level.nodesmaxs = ( 0, 0, 0 );
		level.mapcenter = maps/mp/gametypes_zm/_spawnlogic::findboxcenter( level.nodesmins, level.nodesmaxs );
		/*
/#
		println( "map center: ", level.mapcenter );
#/
		*/
		setmapcenter( level.mapcenter );
	}
}

start_intro_screen_zm() //checked changed to match cerberus output
{
	if ( level.createfx_enabled )
	{
		return;
	}
	if ( !isDefined( level.introscreen ) )
	{
		level.introscreen = newhudelem();
		level.introscreen.x = 0;
		level.introscreen.y = 0;
		level.introscreen.horzalign = "fullscreen";
		level.introscreen.vertalign = "fullscreen";
		level.introscreen.foreground = 0;
		level.introscreen setshader( "black", 640, 480 );
		level.introscreen.immunetodemogamehudsettings = 1;
		level.introscreen.immunetodemofreecamera = 1;
		wait 0.05;
	}
	level.introscreen.alpha = 1;
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] freezecontrols( 1 );
	}
	wait 1;
}

register_perk_locations_zcleansed()
{
	register_zcleansed_perk( "specialty_weapupgrade", "p6_anim_zm_buildable_pap", ( 0, 191.4, 0 ), ( 1205.61, 698.608, -17.68 ) );
	register_zcleansed_perk( "specialty_armorvest", "zombie_vending_jugg", ( 0, 1, 0 ),( -665.13, 1069.13, 9.49 ) );
	register_zcleansed_perk( "specialty_longersprint", "zombie_vending_marathon", ( 0, 0, 0 ), ( 761.63, 1542.25, 0 ) );
	register_zcleansed_perk( "specialty_rof", "zombie_vending_doubletap2", ( 0, 180, 0 ), ( 2328, 936.5, 88 ) );
	register_zcleansed_perk( "specialty_additionalprimaryweapon", "zombie_vending_three_gun", ( 0, 180, 0 ), ( -711, -1249.5, 140.5 ) );
	register_zcleansed_perk( "specialty_fastreload", "zombie_vending_sleight", ( 0, 90, 0 ), ( -170.5, -328.25, 144 ) );
}

register_zcleansed_perk( perk_name, perk_model, perk_angles, perk_coordinates )
{
	perk_struct = spawnStruct();
	perk_struct.script_noteworthy = perk_name;
	perk_struct.model = perk_model;
	perk_struct.angles = perk_angles;
	perk_struct.origin = perk_coordinates;
	perk_struct.script_string = _get_perk_script_string_for_location( getDvar( "ui_zm_mapstartlocation" ), getDvar( "g_gametype") );
	perk_struct.targetname = "zm_perk_machine";
	struct_size = level.struct_class_names[ "targetname" ][ "zm_perk_machine" ].size;
	level.struct_class_names[ "targetname" ][ "zm_perk_machine" ][ struct_size ] = perk_struct;
}

_get_perk_script_string_for_location( location, gametype )
{ 
	string = gametype + "_" + "perks" + "_" + location;
	return string;
}
