#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

health_bar_hud()
{
	level endon( "end_game" );
	self endon("disconnect");
	
	health_bar = self createprimaryprogressbar();
	health_bar.hidewheninmenu = 1;
	health_bar.bar.hidewheninmenu = 1;
	health_bar.barframe.hidewheninmenu = 1;
	health_bar_text = self createprimaryprogressbartext();
	if (level.script == "zm_buried")
	{
		health_bar setpoint("CENTER", "BOTTOM", -335, -95);
		health_bar_text setpoint("CENTER", "BOTTOM", -410, -95);
	}
	else if (level.script == "zm_tomb")
	{
		health_bar setpoint("CENTER", "BOTTOM", -335, -100);
		health_bar_text setpoint("CENTER", "BOTTOM", -410, -100);
	}
	else
	{
		health_bar setpoint("CENTER", "BOTTOM", -335, -70);
		health_bar_text setpoint("CENTER", "BOTTOM", -410, -70);
	}
	health_bar_text.hidewheninmenu = 1;
	health_bar thread cleanup_health_bar_on_end_game();
	health_bar_text thread cleanup_health_bar_on_end_game();
	
	while ( true )
	{
		if ( isDefined( self.e_afterlife_corpse ) || self.sessionstate == "spectator" || self.sessionstate == "intermission" )
		{
			if (health_bar.alpha != 0)
			{
				health_bar.alpha = 0;
				health_bar.bar.alpha = 0;
				health_bar.barframe.alpha = 0;
				health_bar_text.alpha = 0;
			}
			wait 0.05;
			continue;
		}
		if ( health_bar.alpha != 0.8 )
		{
			health_bar fadeOverTime( 0.25 );
			health_bar.alpha = 0.8;
			health_bar.bar fadeOverTime( 0.25 );
			health_bar.bar.alpha = 0.8;
			health_bar.barframe fadeOverTime( 0.25 );
			health_bar.barframe.alpha = 0.8;
			health_bar_text fadeOverTime( 0.25 );
			health_bar_text.alpha = 0.8;
			wait 0.25;
		}
		health_bar updatebar( self.health / self.maxhealth );
		health_bar_text setvalue( self.health );
		wait 0.05;
	}
}

cleanup_health_bar_on_end_game()
{
	level waittill( "end_game" );
	if ( isDefined( self ) )
	{
		self destroyelem();
	}
}