/*
 *
 *      	"fuckCleo.inc" - #1 Anti-cleo mod include
 *      		Created/Debugged most by Lorenc_
 *
 *      Thanks to:
 *			Cessil, Infamous and [FeK]Drakins, JernejL
 *
*/

/* ** Stop Duplicating Code! ** */
#if defined _fcleo_included
	#endinput
#endif
#define _fcleo_included

/* ** Includes ** */
#include 							< a_samp >

/* ** Configuration ** */
#define FC_FILE_VERSION				"0.3.5" // Added the FC_

#define CLEO_FAKEKILL				( 1 )
#define CLEO_CARWARP				( 2 )
#define CLEO_PLAYERBUGGER			( 3 ) // This number will never be called from OnPlayerCleoDetected
#define CLEO_CARSWING				( 4 )
#define CLEO_CAR_PARTICLE_SPAM		( 5 )

/* ** Variables ** */
enum E_CLEO_DATA
{
	E_FK_LASTDEATH,					E_FK_DEATHSPAM,
	E_CW_TIME,						E_CW_VEHID,
	Float: E_PB_X,					Float: E_PB_Y,				Float: E_PB_Z,
	E_CPS_SPAMCOUNT,				E_CPS_TICK
};

static stock
	g_cleoData						[ MAX_PLAYERS ] [ E_CLEO_DATA ],

	bool: FC_OPU,
	bool: FC_OPD,
	bool: FC_OPSC,
	bool: FC_OVDSU,
	bool: FC_OPDC
;

/* ** Forwards ** */
forward OnPlayerCleoDetected		( playerid, cleoid );
forward fc_RepairVehicle			( vehicleid );

public fc_RepairVehicle( vehicleid )
{
	#if defined _FOREACH_LOCAL_VERSION // I guess this is always defined in foreach.inc
		foreach (new playerid : Player)
		{
			if( GetPlayerVehicleID( playerid ) == vehicleid )  {
				g_cleoData[ playerid ] [ E_CPS_SPAMCOUNT ] 	= 0;
				g_cleoData[ playerid ] [ E_CPS_TICK ] 		= 0;
			}
		}
	#else
		for( new playerid; playerid < MAX_PLAYERS; playerid++ )
		{
			if( IsPlayerConnected( playerid ) )
			{
				if( GetPlayerVehicleID( playerid ) == vehicleid )  {
					g_cleoData[ playerid ] [ E_CPS_SPAMCOUNT ] 	= 0;
					g_cleoData[ playerid ] [ E_CPS_TICK ] 		= 0;
				}
			}
		}
	#endif
	return RepairVehicle( vehicleid );
}
#define RepairVehicle fc_RepairVehicle

public OnVehicleDamageStatusUpdate( vehicleid, playerid )
{
	static fc_tires, fc_lights;
    GetVehicleDamageStatus( vehicleid, fc_lights, fc_tires, fc_lights, fc_tires );
	if( GetPlayerState( playerid ) == PLAYER_STATE_DRIVER )
	{
	    if( fc_lights || fc_tires )
	        return 1;

		new time = GetTickCount( );
		switch( time - g_cleoData[ playerid ] [ E_CPS_TICK ] )
		{
			case 0 .. 500:
			{
				g_cleoData[ playerid ] [ E_CPS_SPAMCOUNT ] ++;
				if( g_cleoData[ playerid ] [ E_CPS_SPAMCOUNT ] >= 10 )
				{
					CallLocalFunction( "OnPlayerCleoDetected", "dd", playerid, CLEO_CAR_PARTICLE_SPAM );
					return 1;
				}
			}
			default: g_cleoData[ playerid ] [ E_CPS_SPAMCOUNT ] = 0;
		}
		g_cleoData[ playerid ] [ E_CPS_TICK ] = time;
	}
	return ( FC_OVDSU ) ? CallLocalFunction( "FC_OnVehicleDamageStatusUpdate", "dd", vehicleid, playerid ) : 1;
}

#if defined _ALS_OnVehicleDamageStatusUpd
	#undef OnVehicleDamageStatusUpdate
#else
	#define _ALS_OnVehicleDamageStatusUpd
#endif
#define OnVehicleDamageStatusUpdate FC_OnVehicleDamageStatusUpdate
forward FC_OnVehicleDamageStatusUpdate( vehicleid, playerid );

public OnPlayerStateChange( playerid, newstate, oldstate )
{
    if( newstate == PLAYER_STATE_DRIVER )
    {
        if( GetPlayerVehicleID( playerid ) != g_cleoData[ playerid ] [ E_CW_VEHID ] )
        {
            if( g_cleoData[ playerid ] [ E_CW_TIME ] > gettime( ) )
            {
				CallLocalFunction( "OnPlayerCleoDetected", "dd", playerid, CLEO_CARWARP );
                return 1;
            }
            g_cleoData[ playerid ] [ E_CW_TIME ] = gettime( ) + 1;
			g_cleoData[ playerid ] [ E_CW_VEHID ] = GetPlayerVehicleID( playerid );
        }
    }
	return ( FC_OPSC ) ? CallLocalFunction( "FC_OnPlayerStateChange", "ddd", playerid, newstate, oldstate ) : 1;
}

#if defined _ALS_OnPlayerStateChange
	#undef OnPlayerStateChange
#else
	#define _ALS_OnPlayerStateChange
#endif
#define OnPlayerStateChange FC_OnPlayerStateChange
forward FC_OnPlayerStateChange( playerid, newstate, oldstate );

public OnPlayerDeath( playerid, killerid, reason )
{
	new time = gettime( );
	switch( time - g_cleoData[ playerid ] [ E_FK_LASTDEATH ] )
	{
		case 0 .. 3:
		{
			g_cleoData[ playerid ] [ E_FK_DEATHSPAM ] ++;
			if( g_cleoData[ playerid ] [ E_FK_DEATHSPAM ] >= 3 )
			{
				CallLocalFunction( "OnPlayerCleoDetected", "dd", playerid, CLEO_FAKEKILL );
				return 1;
			}
		}
		default: g_cleoData[ playerid ] [ E_FK_DEATHSPAM ] = 0;
	}
	g_cleoData[ playerid ] [ E_FK_LASTDEATH ] = time;
	return ( FC_OPD ) ? CallLocalFunction( "FC_OnPlayerDeath", "ddd", playerid, killerid, reason ) : 1;
}

#if defined _ALS_OnPlayerDeath
	#undef OnPlayerDeath
#else
	#define _ALS_OnPlayerDeath
#endif
#define OnPlayerDeath FC_OnPlayerDeath
forward FC_OnPlayerDeath( playerid, killerid, reason );

public OnPlayerUpdate( playerid )
{
	static
		Float: sX, 	Float: sY, 	Float: sZ,
		Float: vX,	Float: vY, 	Float: vZ
	;

	if( IsPlayerInAnyVehicle( playerid ) && GetPlayerState( playerid ) == PLAYER_STATE_DRIVER )
	{
		GetPlayerPos( playerid, sX, sY, sZ );
  		GetVehicleVelocity( GetPlayerVehicleID( playerid ), vX, vY, vZ );
		if( ( vX > 3.0 || vY > 3.0 || vZ > 3.0 || vX < -3.0 || vY < -3.0 || vZ < -3.0 ) && ( vX != sX && vY != sY && vZ != sZ ) )
		{
			CallLocalFunction( "OnPlayerCleoDetected", "dd", playerid, CLEO_CARSWING );
		}
	}
	return ( FC_OPU ) ? CallLocalFunction( "FC_OnPlayerUpdate", "d", playerid ) : 1;
}

#if defined _ALS_OnPlayerUpdate
	#undef OnPlayerUpdate
#else
	#define _ALS_OnPlayerUpdate
#endif
#define OnPlayerUpdate FC_OnPlayerUpdate
forward FC_OnPlayerUpdate( playerid );

public OnPlayerDisconnect(playerid, reason)
{
	// Pointless reseting, but just incase!
	g_cleoData[ playerid ] [ E_FK_LASTDEATH ] = 0;
	g_cleoData[ playerid ] [ E_FK_DEATHSPAM ] = 0;
	g_cleoData[ playerid ] [ E_CW_TIME ] = 0;
	g_cleoData[ playerid ] [ E_CW_VEHID ] = INVALID_VEHICLE_ID;
	g_cleoData[ playerid ] [ E_PB_X ] = -1;
	g_cleoData[ playerid ] [ E_PB_Y ] = -1;
	g_cleoData[ playerid ] [ E_PB_Z ] = -1;
	g_cleoData[ playerid ] [ E_CPS_SPAMCOUNT ] = 0;
	g_cleoData[ playerid ] [ E_CPS_TICK ] = 0;
	return ( FC_OPDC ) ? CallLocalFunction( "FC_OnPlayerDisconnect", "dd", playerid, reason ) : 1;
}

#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect FC_OnPlayerDisconnect
forward FC_OnPlayerDisconnect( playerid, reason );

#if !defined FILTERSCRIPT
	public OnGameModeInit()
	{
		FC_OPU = ( funcidx( "FC_OnPlayerUpdate" ) != -1 );
		FC_OPD = ( funcidx( "FC_OnPlayerDeath" ) != -1 );
		FC_OPSC = ( funcidx( "FC_OnPlayerStateChange" ) != -1 );
		FC_OPDC = ( funcidx( "FC_OnPlayerDisconnect" ) != -1 );
		FC_OVDSU = ( funcidx( "FC_OnVehicleDamageStatusUpdate" ) != -1 );
		return ( funcidx( "FC_OnGameModeInit" ) != -1 ) ? CallLocalFunction( "FC_OnGameModeInit", "" ) : 1;
	}
	#if defined _ALS_OnGameModeInit
		#undef OnGameModeInit
	#else
		#define _ALS_OnGameModeInit
	#endif
	#define OnGameModeInit FC_OnGameModeInit
	forward FC_OnGameModeInit();
#else
	public OnFilterScriptInit()
	{
		FC_OPU = ( funcidx( "FC_OnPlayerUpdate" ) != -1 );
		FC_OPD = ( funcidx( "FC_OnPlayerDeath" ) != -1 );
		FC_OPSC = ( funcidx( "FC_OnPlayerStateChange" ) != -1 );
		FC_OPDC = ( funcidx( "FC_OnPlayerDisconnect" ) != -1 );
		FC_OVDSU = ( funcidx( "FC_OnVehicleDamageStatusUpdate" ) != -1 );
		return ( funcidx( "FC_OnFilterScriptInit" ) != -1 ) ? CallLocalFunction( "FC_OnFilterScriptInit", "" ) : 1;
	}
	#if defined _ALS_OnFilterScriptInit
		#undef OnFilterScriptInit
	#else
		#define _ALS_OnFilterScriptInit
	#endif
	#define OnFilterScriptInit FC_OnFilterScriptInit
	forward FC_OnFilterScriptInit();
#endif