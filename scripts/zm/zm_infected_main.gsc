#include scripts/zm/infected/hud;
#include scripts/zm/infected/player_zombies;

main()
{
	replaceFunc( maps/mp/zombies/_zm_turned::turn_to_zombie, scripts/zm/infected/player_zombies::turn_to_zombie_override );
	init_custom_zombie_properties();
	level thread on_player_connect();
}

on_player_connect()
{
	level endon( "end_game" );
	while ( true )
	{
		level waittill( "connected", player );
		player thread health_bar_hud();
	}
}