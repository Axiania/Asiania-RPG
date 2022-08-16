/*
        OnPlayerAirbreak(playerid);
 
        This include is one of the only accurate airbreak detecting
        methods developed in SA-MP.
 
        I do not guarantee positive results with this include.
        There could be many false flags.
 
        Created by Emmet on Wednesday, November 6, 2013.
*/
 
#if !defined MAX_FLAGGED_DETECTIONS
        #define MAX_FLAGGED_DETECTIONS 3
#endif
 
#if !defined ONFOOT_DISTANCE
        #define ONFOOT_DISTANCE 75.0
#endif
 
#if !defined VEHICLE_DISTANCE
        #define VEHICLE_DISTANCE 50.0
#endif
 
static
        // Last known coordinates of the player.
        Float:s_AirbreakLastCoords[MAX_PLAYERS][3],
       
        // Timestamp containing the next time to check for airbreak.
        s_AirbreakUpdateTick[MAX_PLAYERS],
       
        // Timestamp containing the last detection.
        s_AirbreakLastDetection[MAX_PLAYERS],
       
        // Number of detections in the last 60 seconds.
        s_AirbreakDetects[MAX_PLAYERS]
;
 
forward OnPlayerAirbreak(playerid);
 
static ab_IsVehicleMoving(vehicleid)
{
        new
            Float:x,
            Float:y,
            Float:z;
           
        GetVehicleVelocity(vehicleid, x, y, z);
 
        if (floatabs(x) <= 0.001 && floatabs(y) <= 0.001 && floatabs(z) <= 0.005)
            return 0;
           
        return 1;
}
 
public OnFilterScriptInit()
{
        for (new i = 0; i < MAX_PLAYERS; i ++)
        {
                if (IsPlayerConnected(i) && GetPlayerState(i) == PLAYER_STATE_ONFOOT)
                {
                        s_AirbreakUpdateTick[i] = gettime() + 3;
                }
        }
 
        #if defined AB_OnFilterScriptInit
            return AB_OnFilterScriptInit();
        #else
            return 1;
        #endif
}
 
public OnPlayerConnect(playerid)
{
    s_AirbreakDetects[playerid] = 0;
    s_AirbreakLastDetection[playerid] = 0;
    s_AirbreakUpdateTick[playerid] = gettime();
 
        #if defined AB_OnPlayerConnect
            return AB_OnPlayerConnect(playerid);
        #else
            return 1;
        #endif
}
 
public OnPlayerSpawn(playerid)
{
    s_AirbreakUpdateTick[playerid] = gettime() + 3;
 
        #if defined AB_OnPlayerSpawn
            return AB_OnPlayerSpawn(playerid);
        #else
            return 1;
        #endif
}
 
public OnPlayerDeath(playerid, killerid, reason)
{
    s_AirbreakUpdateTick[playerid] = gettime() + 3;
 
        #if defined AB_OnPlayerDeath
            return AB_OnPlayerDeath(playerid, killerid, reason);
        #else
            return 1;
        #endif
}
 
public OnPlayerUpdate(playerid)
{
        if (!IsPlayerNPC(playerid) && GetPlayerSurfingVehicleID(playerid) == INVALID_VEHICLE_ID)
        {
                if (gettime() > s_AirbreakUpdateTick[playerid])
                {
                    new
                        Float:x,
                        Float:y,
                        Float:z,
                        Float:distance;
               
                        if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
                        {
                                GetPlayerPos(playerid, x, y, z);
 
                            if (floatabs((s_AirbreakLastCoords[playerid][2] - z)) < 1.0)
                            {
                                        distance = GetPlayerDistanceFromPoint(playerid, s_AirbreakLastCoords[playerid][0], s_AirbreakLastCoords[playerid][1], s_AirbreakLastCoords[playerid][2]);
 
                                        if ((floatabs(distance) >= ONFOOT_DISTANCE) && (floatabs(s_AirbreakLastCoords[playerid][1] - y) >= 50.0 || floatabs(s_AirbreakLastCoords[playerid][0] - x) >= 50.0))
                                        {
                                            if ((++ s_AirbreakDetects[playerid]) >= MAX_FLAGGED_DETECTIONS && (gettime() - s_AirbreakLastDetection[playerid]) < 60)
                                            {
                                                        CallLocalFunction("OnPlayerAirbreak", "d", playerid);
                                                }
                                                s_AirbreakLastDetection[playerid] = gettime();
                                        }
                            }
                        }
                        else if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
                        {
                            new
                                        vehicleid = GetPlayerVehicleID(playerid);
                               
                                GetVehiclePos(vehicleid, x, y, z);
 
                            if (!ab_IsVehicleMoving(vehicleid))
                            {
                                        distance = GetVehicleDistanceFromPoint(vehicleid, s_AirbreakLastCoords[playerid][0], s_AirbreakLastCoords[playerid][1], s_AirbreakLastCoords[playerid][2]);
 
                                        if ((floatabs(distance) >= VEHICLE_DISTANCE) && (floatabs(s_AirbreakLastCoords[playerid][1] - y) >= 40.0 || floatabs(s_AirbreakLastCoords[playerid][0] - x) >= 40.0))
                                        {
                                            if ((++ s_AirbreakDetects[playerid]) >= MAX_FLAGGED_DETECTIONS && (gettime() - s_AirbreakLastDetection[playerid]) < 60)
                                            {
                                                        CallLocalFunction("OnPlayerAirbreak", "d", playerid);
                                                }
                                                s_AirbreakLastDetection[playerid] = gettime();
                                        }
                            }
                        }
                       
                        s_AirbreakUpdateTick[playerid] = gettime();
 
                        if (IsPlayerInAnyVehicle(playerid))
                        {
                            GetVehiclePos(GetPlayerVehicleID(playerid), s_AirbreakLastCoords[playerid][0], s_AirbreakLastCoords[playerid][1], s_AirbreakLastCoords[playerid][2]);
                        }
                        else
                        {
                        GetPlayerPos(playerid, s_AirbreakLastCoords[playerid][0], s_AirbreakLastCoords[playerid][1], s_AirbreakLastCoords[playerid][2]);
                        }
                }
        }
        #if defined AB_OnPlayerUpdate
            return AB_OnPlayerUpdate(playerid);
        #else
            return 1;
        #endif
}
 
stock AB_SetPlayerPos(playerid, Float:x, Float:y, Float:z)
{
        s_AirbreakUpdateTick[playerid] = gettime() + 3;
       
        s_AirbreakLastCoords[playerid][0] = x;
        s_AirbreakLastCoords[playerid][1] = y;
        s_AirbreakLastCoords[playerid][2] = z;
       
        return SetPlayerPos(playerid, x, y, z);
}
 
stock AB_SetVehiclePos(vehicleid, Float:x, Float:y, Float:z)
{
        for (new i = 0; i < MAX_PLAYERS; i ++)
        {
            if (GetPlayerState(i) == PLAYER_STATE_DRIVER && IsPlayerInVehicle(i, vehicleid))
            {
                        s_AirbreakUpdateTick[i] = gettime() + 3;
 
                        s_AirbreakLastCoords[i][0] = x;
                        s_AirbreakLastCoords[i][1] = y;
                        s_AirbreakLastCoords[i][2] = z;
 
                        break;
                }
        }
        return SetVehiclePos(vehicleid, x, y, z);
}
 
stock AB_PutPlayerInVehicle(playerid, vehicleid, seatid)
{
    s_AirbreakUpdateTick[playerid] = gettime() + 3;
 
        return PutPlayerInVehicle(playerid, vehicleid, seatid);
}
 
stock AB_SetPlayerPosFindZ(playerid, Float:x, Float:y, Float:z)
{
    s_AirbreakUpdateTick[playerid] = gettime() + 3;
 
        s_AirbreakLastCoords[playerid][0] = x;
        s_AirbreakLastCoords[playerid][1] = y;
        s_AirbreakLastCoords[playerid][2] = z;
 
        return SetPlayerPosFindZ(playerid, x, y, z);
}
 
#if defined _ALS_OnPlayerConnect
        #undef OnPlayerConnect
#else
        #define _ALS_OnPlayerConnect
#endif
 
#if defined _ALS_OnPlayerSpawn
        #undef OnPlayerSpawn
 #else
        #define _ALS_OnPlayerSpawn
#endif
 
#if defined _ALS_OnPlayerDeath
        #undef OnPlayerDeath
#else
        #define _ALS_OnPlayerDeath
#endif
 
#if defined _ALS_OnPlayerUpdate
        #undef OnPlayerUpdate
#else
        #define _ALS_OnPlayerUpdate
#endif
 
#if defined _ALS_OnFilterScriptInit
        #undef OnFilterScriptInit
#else
        #define _ALS_OnFilterScriptInit
#endif
 
#if defined _ALS_SetPlayerPos
        #undef SetPlayerPos
#else
        #define _ALS_SetPlayerPos
#endif
 
#if defined _ALS_SetVehiclePos
        #undef SetVehiclePos
#else
        #define _ALS_SetVehiclePos
#endif
 
#if defined _ALS_SetPlayerPosFindZ
        #undef SetPlayerPosFindZ
#else
        #define _ALS_SetPlayerPosFindZ
#endif
 
#if defined _ALS_PutPlayerInVehicle
        #undef PutPlayerInVehicle
#else
        #define _ALS_PutPlayerInVehicle
#endif
 
#define OnPlayerConnect         AB_OnPlayerConnect
#define OnPlayerSpawn           AB_OnPlayerSpawn
#define OnPlayerDeath           AB_OnPlayerDeath
#define OnPlayerUpdate          AB_OnPlayerUpdate
#define OnFilterScriptInit  AB_OnFilterScriptInit
 
#define SetPlayerPos        AB_SetPlayerPos
#define SetVehiclePos       AB_SetVehiclePos
#define SetPlayerPosFindZ   AB_SetPlayerPosFindZ
#define PutPlayerInVehicle  AB_PutPlayerInVehicle
 
#if defined AB_OnFilterScriptInit
        forward AB_OnFilterScriptInit();
#endif
 
#if defined AB_OnPlayerConnect
        forward AB_OnPlayerConnect(playerid);
#endif
 
#if defined AB_OnPlayerSpawn
        forward AB_OnPlayerSpawn(playerid);
#endif
 
#if defined AB_OnPlayerUpdate
        forward AB_OnPlayerUpdate(playerid);
#endif
 
#if defined AB_OnPlayerDeath
        forward AB_OnPlayerDeath(playerid, killerid, reason);
#endif