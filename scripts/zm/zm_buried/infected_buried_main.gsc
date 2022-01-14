#include maps/mp/zm_buried_grief_street;
#include maps/mp/zm_buried_turned_street;
#include maps/mp/zm_buried_classic;
#include maps/mp/zm_buried;
#include maps/mp/gametypes_zm/_zm_gametype;

#include scripts/zm/zm_buried/locs/loc_street;

main()
{
	replaceFunc( maps/mp/zm_buried_gamemodes::init, ::init_override );
	ents = getEntArray();
	foreach ( ent in ents )
	{
		if ( isDefined( ent.script_gameobjectname ) && ent.script_gameobjectname == "zclassic zgrief" )
		{
			if ( isDefined( ent.classname ) && ent.classname == "zbarrier_zmcore_MagicBox" )
			{
				ent.script_gameobjectname = "zclassic zgrief zcleansed";
			}
		}
	}
	ents = getEntArray();
	foreach ( ent in ents )
	{
		if ( isDefined( ent.origin ) && ent.origin == ( -651.34, 599.69, 33 ) || isDefined( ent.origin ) && ent.origin == ( -287.82, 594.71, 25.57 ) || isDefined( ent.origin ) && ent.origin == ( -143.82, -60.29, 87.53 ) )
		{
			ent delete();
		}
	}
}

init_override()
{
	add_map_gamemode( "zclassic", maps/mp/zm_buried::zclassic_preinit, undefined, undefined );
	add_map_gamemode( "zcleansed", maps/mp/zm_buried::zcleansed_preinit, undefined, undefined );
	add_map_gamemode( "zgrief", maps/mp/zm_buried::zgrief_preinit, undefined, undefined );
	add_map_location_gamemode( "zclassic", "processing", maps/mp/zm_buried_classic::precache, maps/mp/zm_buried_classic::main );
	add_map_location_gamemode( "zcleansed", "street", scripts/zm/zm_buried/locs/loc_street::precache, scripts/zm/zm_buried/locs/loc_street::main );
	add_map_location_gamemode( "zgrief", "street", maps/mp/zm_buried_grief_street::precache, maps/mp/zm_buried_grief_street::main );

	scripts/zm/_gametype_setup::add_struct_location_gamemode_func( "zcleansed", "street", scripts/zm/zm_buried/locs/loc_street::struct_init );
}