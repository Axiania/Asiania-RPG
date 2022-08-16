#define MAX_CAR_SLOTS   10
//================================================================================
enum E_PLAYER_CAR
{
    E_PLAYER_CAR_DB_ID,
    E_PLAYER_CAR_ID,
    E_PLAYER_CAR_TYPE,
    E_PLAYER_CAR_STATUS
}
new gPlayerCars[MAX_PLAYERS][MAX_CAR_SLOTS][E_PLAYER_CAR];

#define CAR_STATUS_NONE 0
#define CAR_STATUS_SPAWNED 1
#define CAR_STATUS_DESPAWNED 2

#define CAR_TYPE_NONE 0
#define CAR_TYPE_PERSONAL 1
#define CAR_TYPE_RENT 2
//================================================================================

forward ResetPlayerCarsData(playerid);
public ResetPlayerCarsData(playerid)
{
    for(new i = 0; i < MAX_CAR_SLOTS; i++)
    {
        gPlayerCars[playerid][i][E_PLAYER_CAR_DB_ID] = 0;
        gPlayerCars[playerid][i][E_PLAYER_CAR_ID] = 0;
        gPlayerCars[playerid][i][E_PLAYER_CAR_TYPE] = CAR_TYPE_NONE;
        gPlayerCars[playerid][i][E_PLAYER_CAR_STATUS] = CAR_STATUS_NONE;
    }
    return 1;
}

forward LoadPlayerVehicles(playerid);
public LoadPlayerVehicle(playerid)
{
    new query[300];
    mysql_format( _dbConnector, query, sizeof(query), "SELECT `veh_id` FROM `vehicles` WHERE `owner_sqlID` = %d AND `vspawned` = 1 LIMIT 15", gPlayerData[ playerid ][ E_PLAYER_ID ] );
    mysql_pquery( _dbConnector, query, "CheckPlayerVehicles", "i", playerid );
    return 1;
}

forward CheckPlayerVehicles( playerid );
public CheckPlayerVehicles( playerid ) {

    new rows, fields;
    cache_get_data( rows, fields, _dbConnector );

    if( rows )
    {
        for( new i = 0; i < MAX_CAR_SLOTS; i ++ ) 
        {
            gPlayerCars[playerid][i][E_PLAYER_CAR_DB_ID] = cache_get_field_content_int( i, "veh_id" );
            if(GetVehicleID(gPlayerCars[playerid][i][E_PLAYER_CAR_DB_ID]) != -1) continue;
            new query[150];
            mysql_format( _dbConnector, query, sizeof( query ), "SELECT * FROM `vehicles` WHERE `veh_id` = '%d' LIMIT 1", pveh[ i ] );
            mysql_pquery( _dbConnector, query, "ucitajIzgubljeno3", "i", playerid );
        }
    }
    return true;
}