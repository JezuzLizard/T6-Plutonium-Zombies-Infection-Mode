#include maps/mp/gametypes_zm/_spawnlogic;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/_visionset_mgr;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_turned;

turn_to_zombie_override() //checked changed to match cerberus output
{
	if ( self.sessionstate == "playing" && is_true( self.is_zombie ) && !is_true( self.laststand ) )
	{
		return;
	}
	if ( is_true( self.is_in_process_of_zombify ) )
	{
		return;
	}
	while ( is_true( self.is_in_process_of_humanify ) )
	{
		wait 0.1;
	}
	if ( !flag( "pregame" ) )
	{
		self playsoundtoplayer( "evt_spawn", self );
		playsoundatposition( "evt_disappear_3d", self.origin );
		if ( !self.is_zombie )
		{
			playsoundatposition( "vox_plr_" + randomintrange( 0, 4 ) + "_exert_death_high_" + randomintrange( 0, 4 ), self.origin );
		}
	}
	self._can_score = 1;
	self setclientfield( "player_has_eyes", 0 );
	self ghost();
	self turned_disable_player_weapons();
	self notify( "clear_red_flashing_overlay" );
	self notify( "zombify" );
	self.is_in_process_of_zombify = 1;
	self.team = level.zombie_team;
	self.pers[ "team" ] = level.zombie_team;
	self.sessionteam = level.zombie_team;
	wait_network_frame();
	self maps/mp/gametypes_zm/_zm_gametype::onspawnplayer();
	self freezecontrols( 1 );
	self.is_zombie = 1;
	self setburn( 0 );
	if ( is_true( self.turned_visionset ) )
	{
		maps/mp/_visionset_mgr::vsmgr_deactivate( "visionset", "zm_turned", self );
		wait_network_frame();
		wait_network_frame();
		if ( !isDefined( self ) )
		{
			return;
		}
	}
	maps/mp/_visionset_mgr::vsmgr_activate( "visionset", "zm_turned", self );
	self.turned_visionset = 1;
	self setclientfieldtoplayer( "turned_ir", 1 );
	self maps/mp/zombies/_zm_audio::setexertvoice( 1 );
	self.laststand = undefined;
	wait_network_frame();
	if ( !isDefined( self ) )
	{
		return;
	}
	self enableweapons();
	self show();
	playsoundatposition( "evt_appear_3d", self.origin );
	playsoundatposition( "zmb_zombie_spawn", self.origin );
	self thread delay_turning_on_eyes();
	self thread turned_player_buttons();
	self setperk( "specialty_noname" );
	self setperk( "specialty_unlimitedsprint" );
	self setperk( "specialty_fallheight" );
	self turned_give_melee_weapon();
	self.animname = "zombie";
	self disableoffhandweapons();
	self allowstand( 1 );
	self allowprone( 1 );
	self allowcrouch( 1 );
	self allowads( 0 );
	self allowjump( 1 );
	self disableweaponcycling();
	self assign_zombie_type();
	self setmovespeedscale( self calculate_zombie_speed() );
	self setsprintduration( 4 );
	self setsprintcooldown( 0 );
	self stopshellshock();
	self.maxhealth = calculate_zombie_health();
	self.health = self.maxhealth;
	self.meleedamage = 20;
	self detachall();
	if ( isDefined( level.custom_zombie_player_loadout ) )
	{
		self [[ level.custom_zombie_player_loadout ]]();
	}
	else
	{
		self setmodel( "c_zom_player_zombie_fb" );
		self.voice = "american";
		self.skeleton = "base";
		self setviewmodel( "c_zom_zombie_viewhands" );
	}
	self.shock_onpain = 0;
	self disableinvulnerability();
	if ( isDefined( level.player_movement_suppressed ) )
	{
		self freezecontrols( level.player_movement_suppressed );
	}
	else if ( isDefined( self.hostmigrationcontrolsfrozen ) && !self.hostmigrationcontrolsfrozen )
	{
		self freezecontrols( 0 );
	}
	self.is_in_process_of_zombify = 0;
}

init_custom_zombie_properties()
{
	level.infected_difficulty = 0;
	level.custom_zombie_properties = [];
	level.custom_zombie_properties[ "start_infected" ] = spawnStruct();
	level.custom_zombie_properties[ "new_infected" ] = spawnStruct();
	stats = getDvar( "infected_start_zombie_stats" ); //base_health:150 health_increase_multiplier:1 health_increase_flat:100 base_speed:0.55 speed_increase_flat:0.025
	if ( stats == "" )
	{
		level.custom_zombie_properties[ "start_infected" ].base_health = 150;
		level.custom_zombie_properties[ "start_infected" ].health_increase_multiplier = 1;
		level.custom_zombie_properties[ "start_infected" ].health_increase_flat = 100;
		level.custom_zombie_properties[ "start_infected" ].base_speed = 0.55;
		level.custom_zombie_properties[ "start_infected" ].speed_increase_flat = 0.025;
	}
	else 
	{
		stat_values = get_stats_from_dvar( stats );
		level.custom_zombie_properties[ "start_infected" ].base_health = stat_values[ 0 ];
		level.custom_zombie_properties[ "start_infected" ].health_increase_multiplier = stat_values[ 1 ];
		level.custom_zombie_properties[ "start_infected" ].health_increase_flat = stat_values[ 2 ];
		level.custom_zombie_properties[ "start_infected" ].base_speed = stat_values[ 3 ];
		level.custom_zombie_properties[ "start_infected" ].speed_increase_flat = stat_values[ 4 ];
	}
	stats = getDvar( "infected_new_zombie_stats" ); //base_health:150 health_increase_multiplier:1 health_increase_flat:100 base_speed:0.55 speed_increase_flat:0.025
	if ( stats == "" )
	{
		level.custom_zombie_properties[ "new_infected" ].base_health = 150;
		level.custom_zombie_properties[ "new_infected" ].health_increase_multiplier = 1;
		level.custom_zombie_properties[ "new_infected" ].health_increase_flat = 100;
		level.custom_zombie_properties[ "new_infected" ].base_speed = 0.55;
		level.custom_zombie_properties[ "new_infected" ].speed_increase_flat = 0.01;
	}
	else 
	{
		stat_values = get_stats_from_dvar( stats );
		level.custom_zombie_properties[ "new_infected" ].base_health = stat_values[ 0 ];
		level.custom_zombie_properties[ "new_infected" ].health_increase_multiplier = stat_values[ 1 ];
		level.custom_zombie_properties[ "new_infected" ].health_increase_flat = stat_values[ 2 ];
		level.custom_zombie_properties[ "new_infected" ].base_speed = stat_values[ 3 ];
		level.custom_zombie_properties[ "new_infected" ].speed_increase_flat = stat_values[ 4 ];
	}
	if ( getDvarIntDefault( "infected_use_special_zombies", 0 ) == 1 )
	{
		level.custom_zombie_properties[ "tank_infected" ] = spawnStruct();
		level.custom_zombie_properties[ "fast_infected" ] = spawnStruct();
	}
	else 
	{
		return;
	}
	stats = getDvar( "infected_tank_zombie_stats" ); //base_health:150 health_increase_multiplier:1 health_increase_flat:100 base_speed:0.55 speed_increase_flat:0.025
	if ( stats == "" )
	{
		level.custom_zombie_properties[ "tank_infected" ].base_health = 300;
		level.custom_zombie_properties[ "tank_infected" ].health_increase_multiplier = 1.05;
		level.custom_zombie_properties[ "tank_infected" ].health_increase_flat = 200;
		level.custom_zombie_properties[ "tank_infected" ].base_speed = 0.45;
		level.custom_zombie_properties[ "tank_infected" ].speed_increase_flat = 0.005;
	}
	else 
	{
		stat_values = get_stats_from_dvar( stats );
		level.custom_zombie_properties[ "tank_infected" ].base_health = stat_values[ 0 ];
		level.custom_zombie_properties[ "tank_infected" ].health_increase_multiplier = stat_values[ 1 ];
		level.custom_zombie_properties[ "tank_infected" ].health_increase_flat = stat_values[ 2 ];
		level.custom_zombie_properties[ "tank_infected" ].base_speed = stat_values[ 3 ];
		level.custom_zombie_properties[ "tank_infected" ].speed_increase_flat = stat_values[ 4 ];
	}
	stats = getDvar( "infected_fast_zombie_stats" ); //base_health:150 health_increase_multiplier:1 health_increase_flat:100 base_speed:0.55 speed_increase_flat:0.025
	if ( stats == "" )
	{
		level.custom_zombie_properties[ "fast_infected" ].base_health = 100;
		level.custom_zombie_properties[ "fast_infected" ].health_increase_multiplier = 1;
		level.custom_zombie_properties[ "fast_infected" ].health_increase_flat = 75;
		level.custom_zombie_properties[ "fast_infected" ].base_speed = 0.7;
		level.custom_zombie_properties[ "fast_infected" ].speed_increase_flat = 0.01;
	}
	else 
	{
		stat_values = get_stats_from_dvar( stats );
		level.custom_zombie_properties[ "fast_infected" ].base_health = stat_values[ 0 ];
		level.custom_zombie_properties[ "fast_infected" ].health_increase_multiplier = stat_values[ 1 ];
		level.custom_zombie_properties[ "fast_infected" ].health_increase_flat = stat_values[ 2 ];
		level.custom_zombie_properties[ "fast_infected" ].base_speed = stat_values[ 3 ];
		level.custom_zombie_properties[ "fast_infected" ].speed_increase_flat = stat_values[ 4 ];
	}
	level.zombie_special_types = [];
	level.zombie_special_types[ 0 ] = "tank_infected";
	level.zombie_special_types[ 1 ] = "fast_infected";
}

get_stats_from_dvar( stats )
{
	stat_tokens = strTok( stats, " " );
	stat_values = [];
	foreach ( token in stat_tokens )
	{
		stat_values[ stat_values.size ] = int( strTok( token, ":" )[ 1 ] );
	}
	return stat_values;
}

assign_zombie_type()
{
	if ( getDvarInt( "infected_use_special_zombies" ) == 1 )
	{
		self.zombie_type = random( level.zombie_special_types );
	}
	if ( !isDefined( self.zombie_type ) )
	{
		self.zombie_type = "new_infected";
	}
}

calculate_zombie_health()
{
 	base_health = level.custom_zombie_properties[ self.zombie_type ].base_health;
	multiplier = level.custom_zombie_properties[ self.zombie_type ].health_increase_multiplier;
	flat_increase = level.custom_zombie_properties[ self.zombie_type ].health_increase_flat;
	new_health = base_health + ( flat_increase * level.infected_difficulty );
	if ( multiplier > 1 )
	{
		for ( i = 0; i < level.infected_difficulty; i++ )
		{
			new_health *= multiplier;
		}
	}
	return new_health;
}

calculate_zombie_speed()
{
	base_speed = level.custom_zombie_properties[ self.zombie_type ].base_speed;
	speed_increase = level.custom_zombie_properties[ self.zombie_type ].speed_increase_flat;
	new_speed = base_speed + ( speed_increase * level.infected_difficulty );
	return new_speed;
}