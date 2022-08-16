#include <YSI_Coding\y_hooks>
//------------------------------------------------------------------------------
forward OnWeaponSlotInserted(playerid, slot);

//------------------------------------------------------------------------------
#define     MAX_WEAPON_SLOTS    5
enum E_WEAPON_SLOT
{
    E_WEAPON_SLOT_DB,
    E_WEAPON_SLOT_TYPE,
    E_WEAPON_SLOT_CREATED,
    E_WEAPON_SLOT_STATUS,
    E_WEAPON_SLOT_NAME[64],
    E_WEAPON_SLOT_WEAPON[5],
    E_WEAPON_SLOT_AMMO[5]
}
new gWeaponSlots[MAX_PLAYERS][MAX_WEAPON_SLOTS][E_WEAPON_SLOT];
new gWeaponSlotList[MAX_PLAYERS][MAX_WEAPON_SLOTS];
//------------------------------------------------------------------------------
GetPlayerWeaponSlots(playerid)
{
    new count = 0;
    for(new i = 0; i < MAX_WEAPON_SLOTS; i++)
    {
        if(gWeaponSlots[playerid][i][E_WEAPON_SLOT_CREATED] == 1)
            count++;
    }
    return count;
}
ResetPlayerWeaponSlots(playerid)
{
    for(new i = 0; i < MAX_WEAPON_SLOTS; i++)
    {
        gWeaponSlots[playerid][i][E_WEAPON_SLOT_CREATED] = 0;
        gWeaponSlots[playerid][i][E_WEAPON_SLOT_DB] = 0; 
        gWeaponSlots[playerid][i][E_WEAPON_SLOT_TYPE] = 0; 
        gWeaponSlots[playerid][i][E_WEAPON_SLOT_STATUS] = 0; 
        gWeaponSlots[playerid][i][E_WEAPON_SLOT_NAME][0] = '\0';
        for(new p = 0; p < 5; p++)
        {
            gWeaponSlots[playerid][i][E_WEAPON_SLOT_WEAPON][p] = 0;
            gWeaponSlots[playerid][i][E_WEAPON_SLOT_AMMO][p] = 0;
        }
         
    }
    return 1;
}
GetActiveWeaponSlot(playerid)
{
    for(new i = 0; i < MAX_WEAPON_SLOTS; i++)
    {
        if(gWeaponSlots[playerid][i][E_WEAPON_SLOT_CREATED] == 1 && gWeaponSlots[playerid][i][E_WEAPON_SLOT_STATUS] == 1)
            return i;
    }
    return -1;
}
//------------------------------------------------------------------------------
AddWeaponSlot(playerid, name[])
{
    for(new i = 0; i < MAX_WEAPON_SLOTS; i++)
    {
        if(gWeaponSlots[playerid][i][E_WEAPON_SLOT_CREATED] == 0)
        {
            gWeaponSlots[playerid][i][E_WEAPON_SLOT_CREATED] = 1;
            gWeaponSlots[playerid][i][E_WEAPON_SLOT_STATUS] = 0;
            gWeaponSlots[playerid][i][E_WEAPON_SLOT_TYPE] = 0;
            strmid( gWeaponSlots[playerid][i][E_WEAPON_SLOT_NAME], name, 0, strlen( name ), 64);

            new query[256];
            mysql_format( _dbConnector, query, sizeof( query ), "INSERT INTO `weapon_slots` ( name, user_id ) VALUES( '%e', '%d')", name, gPlayerData[ playerid ][ E_PLAYER_ID ] );
            mysql_tquery( _dbConnector, query, "OnWeaponSlotInserted", "ii", playerid, i );
            break;
        }
    }
    return 1;
}
UpdateWeaponSlotName(playerid, slot, name[])
{
    if(gWeaponSlots[playerid][slot][E_WEAPON_SLOT_CREATED] == 1)
    {
        strmid( gWeaponSlots[playerid][slot][E_WEAPON_SLOT_NAME], name, 0, strlen( name ), 64);

        new query[256];
        mysql_format( _dbConnector, query, sizeof( query ), "UPDATE `weapon_slots` SET `name` = '%e' WHERE `id` = '%d'", name,  gWeaponSlots[playerid][slot][E_WEAPON_SLOT_DB]);
        mysql_tquery( _dbConnector, query, "", "" );
    }
    return 1;
}
DeleteWeaponSlot(playerid, slot)
{
    if(gWeaponSlots[playerid][slot][E_WEAPON_SLOT_CREATED] == 1)
    {
        gWeaponSlots[playerid][slot][E_WEAPON_SLOT_CREATED] = 0;
        gWeaponSlots[playerid][slot][E_WEAPON_SLOT_STATUS] = 0;
        gWeaponSlots[playerid][slot][E_WEAPON_SLOT_TYPE] = 0;
        strmid( gWeaponSlots[playerid][slot][E_WEAPON_SLOT_NAME], "", 0, strlen( "" ), 64);

        new query[256];
        mysql_format( _dbConnector, query, sizeof( query ), "DELETE FROM `weapon_slots` WHERE `id` = '%d'", gWeaponSlots[playerid][slot][E_WEAPON_SLOT_DB]);
        mysql_tquery( _dbConnector, query, "", "" );
    }
    return 1;
}
ResetWeaponSlot(playerid, slot)
{
    for(new w = 0; w < 5; w++)
    {
        gWeaponSlots[playerid][slot][E_WEAPON_SLOT_WEAPON][w] = 0;
        gWeaponSlots[playerid][slot][E_WEAPON_SLOT_AMMO][w] = 0;
    } 
    return 1;
}
SavePlayerWeaponSlot(playerid, slot)
{
    new wd[ 2 ][ 13 ];
    for( new i; i < 13; i++ ) GetPlayerWeaponData( playerid, i, wd[ 0 ][ i ], wd[ 1 ][ i ] );
    for( new i; i < 13; i++ ) 
    {
        for(new w = 0; w < 5; w++)
        {
            if( gWeaponSlots[playerid][slot][E_WEAPON_SLOT_WEAPON][w] == wd[ 0 ][ i ] && wd[ 1 ][ i ] > 0) 
                gWeaponSlots[playerid][slot][E_WEAPON_SLOT_AMMO][w] = antiCheatCS[ playerid ][ Ammo ][ GetWeaponSlot(wd[ 0 ][ i ]) ];
        }
    }
    new query[512];
    mysql_format(_dbConnector, query, sizeof(query),
    "UPDATE `weapon_slots` SET `weapon_0`=%d, `weapon_1`=%d, `weapon_2`=%d, `weapon_3`=%d, `weapon_4`=%d,\
    `ammo_0`=%d, `ammo_1`=%d, `ammo_2`=%d, `ammo_3`=%d, `ammo_4`=%d, `status`=%d WHERE `id`=%d",
    gWeaponSlots[playerid][slot][E_WEAPON_SLOT_WEAPON][0], gWeaponSlots[playerid][slot][E_WEAPON_SLOT_WEAPON][1], gWeaponSlots[playerid][slot][E_WEAPON_SLOT_WEAPON][2],
    gWeaponSlots[playerid][slot][E_WEAPON_SLOT_WEAPON][3], gWeaponSlots[playerid][slot][E_WEAPON_SLOT_WEAPON][4], gWeaponSlots[playerid][slot][E_WEAPON_SLOT_AMMO][0],
    gWeaponSlots[playerid][slot][E_WEAPON_SLOT_AMMO][1], gWeaponSlots[playerid][slot][E_WEAPON_SLOT_AMMO][2], gWeaponSlots[playerid][slot][E_WEAPON_SLOT_AMMO][3], 
    gWeaponSlots[playerid][slot][E_WEAPON_SLOT_AMMO][4], gWeaponSlots[playerid][slot][E_WEAPON_SLOT_STATUS], gWeaponSlots[playerid][slot][E_WEAPON_SLOT_DB]);
    mysql_tquery(_dbConnector, query);
}
forward LoadPlayerWeaponSlots(playerid);
public LoadPlayerWeaponSlots(playerid)
{
    new rows, fields, loaded = 0;
    cache_get_data( rows, fields, _dbConnector );

    if( rows ) {
        for(new i = 0; i < rows; i++)
        {
            if(i == MAX_WEAPON_SLOTS)
            {
                break;
            }

            gWeaponSlots[playerid][i][E_WEAPON_SLOT_DB] = cache_get_field_content_int(i, "id");
            gWeaponSlots[playerid][i][E_WEAPON_SLOT_STATUS] = cache_get_field_content_int(i, "status");
            gWeaponSlots[playerid][i][E_WEAPON_SLOT_TYPE] = cache_get_field_content_int(i, "type");
            gWeaponSlots[playerid][i][E_WEAPON_SLOT_CREATED] = 1;
            cache_get_field_content( i, "name", gWeaponSlots[playerid][i][E_WEAPON_SLOT_NAME], _dbConnector, 64 );

            for(new p = 0; p < 5; p++)
            {
                new column[32];
                format(column, sizeof(column), "weapon_%d", p);
                gWeaponSlots[playerid][i][E_WEAPON_SLOT_WEAPON][p] = cache_get_field_content_int( i, column );
                format(column, sizeof(column), "ammo_%d", p);
                gWeaponSlots[playerid][i][E_WEAPON_SLOT_AMMO][p] = cache_get_field_content_int( i, column );
            }
            if(gWeaponSlots[playerid][i][E_WEAPON_SLOT_STATUS] == 1 && loaded == 0)
            {
                loaded = 1;
                for(new w = 0; w < 5; w++)
                {
                    if(gWeaponSlots[playerid][i][E_WEAPON_SLOT_WEAPON][w] > 0 && IsValidWeapon(gWeaponSlots[playerid][i][E_WEAPON_SLOT_WEAPON][w]) && gWeaponSlots[playerid][i][E_WEAPON_SLOT_AMMO][w] > 0)
                        GiveWeaponToPlayer(playerid, gWeaponSlots[playerid][i][E_WEAPON_SLOT_WEAPON][w], gWeaponSlots[playerid][i][E_WEAPON_SLOT_AMMO][w]);
                }
            }
        }
    
    }
    return (true);
}
forward OnWeaponSlotInserted( playerid, slot );
public OnWeaponSlotInserted( playerid, slot ){

    gWeaponSlots[playerid][slot][E_WEAPON_SLOT_DB] = cache_insert_id();
    return true;
}
//------------------------------------------------------------------------------

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if( dialogid == DIALOG_WEAPONS ) {
        if( !response ) return true;
        else
        {
            if(listitem == 0)
            {
                if(GetPlayerWeaponSlots(playerid) >= MAX_WEAPON_SLOTS) 
                {
                    SendErrorMessage(playerid, "You have created maximum number of weapon slots.");
                    ShowDialog(playerid, DIALOG_WEAPONS);
                    return 1;
                }
                SPD( playerid, DIALOG_WEAPONS_SLOTNAME, DSI, "New Slot", "{FFFFFF}Enter the name you want to set on the slot:", "Enter", "Back" );
            }
            else
            {
                SetPVarInt(playerid, "SelectedWeaponSlot", gWeaponSlotList[playerid][listitem]);
                ShowDialog(playerid, DIALOG_WEAPONS_SLOTEDIT);
            }
        }
    }
    if( dialogid == DIALOG_WEAPONS_SLOTNAME )
    {
        if( !response )
        {
            ShowDialog(playerid, DIALOG_WEAPONS);
            return 1;
        }
        if( response ) {
            new slot_name[64];
            if( sscanf( inputtext, "s[64]", slot_name) ) return SPD( playerid, DIALOG_WEAPONS_SLOTNAME, DSI, "New Slot", "{FFFFFF}Enter the name you want to set on the slot:", "Enter", "Back" );
            if(GetPlayerWeaponSlots(playerid) >= MAX_WEAPON_SLOTS) return ShowDialog(playerid, DIALOG_WEAPONS);

            AddWeaponSlot(playerid, slot_name);
            SendInfoMessage(playerid, "You successfully created a new weapon slot with name %s.", slot_name);
            ShowDialog(playerid, DIALOG_WEAPONS);
            return 1;
        }
    }
    if( dialogid == DIALOG_WEAPONS_SLOTEDIT )
    {
        if( !response )
        {
            ShowDialog(playerid, DIALOG_WEAPONS);
            return 1;
        }
        if( response ) {
            new slot = GetPVarInt(playerid, "SelectedWeaponSlot");
            switch( listitem )
            {
                case 0:
                {
                    if(gWeaponSlots[playerid][slot][E_WEAPON_SLOT_STATUS] == 0) 
                    {
                        if(GetActiveWeaponSlot(playerid) != -1)
                        {
                            SendErrorMessage(playerid, "You have another weapon slot activated.");
                            return ShowDialog(playerid, DIALOG_WEAPONS);
                        }
                        gWeaponSlots[playerid][slot][E_WEAPON_SLOT_STATUS] = 1; 
                        for(new w = 0; w < 5; w++)
                        {
                            if(gWeaponSlots[playerid][slot][E_WEAPON_SLOT_WEAPON][w] > 0 && IsValidWeapon(gWeaponSlots[playerid][slot][E_WEAPON_SLOT_WEAPON][w]) && gWeaponSlots[playerid][slot][E_WEAPON_SLOT_AMMO][w] > 0)
                                GiveWeaponToPlayer(playerid, gWeaponSlots[playerid][slot][E_WEAPON_SLOT_WEAPON][w], gWeaponSlots[playerid][slot][E_WEAPON_SLOT_AMMO][w]);
                        }
                    }
                    else if(gWeaponSlots[playerid][slot][E_WEAPON_SLOT_STATUS] == 1)
                    {
                        gWeaponSlots[playerid][slot][E_WEAPON_SLOT_STATUS] = 0;
                        SavePlayerWeaponSlot(playerid, slot);
                        ResetAllWeapons(playerid);
                        
                    }
                    ShowDialog(playerid, DIALOG_WEAPONS_SLOTEDIT);
                }
                case 1:
                {
                    new string[158];
                    format(string, sizeof(string), "{FFFFFF}Enter the new name for the slot.\n\n{FFFFFF}Current Name: {1AD630}%s", gWeaponSlots[playerid][slot][E_WEAPON_SLOT_NAME]);
                    SPD( playerid, DIALOG_WEAPONS_SLOTEDITNAME, DSI, "Edit Slot Name", string, "Enter", "Back" );
                }
                case 2:
                {
                    strdel( DialogStrgEx, 0, sizeof( DialogStrgEx ) );
                    format( globalstring, sizeof( globalstring ),""col_white"Are you sure you want to delete slot "col_server"%s?", gWeaponSlots[playerid][slot][E_WEAPON_SLOT_NAME] );
                    strcat( DialogStrgEx, globalstring );

                    ShowPlayerDialog( playerid, DIALOG_WEAPONS_SLOTDELETE, DSMSG, "Slot Delete", DialogStrgEx, "Delete", "Back" );
                }
            }
            return 1;
        }
    }
    if( dialogid == DIALOG_WEAPONS_SLOTDELETE )
    {
        if( !response )
        {
            ShowDialog(playerid, DIALOG_WEAPONS_SLOTEDIT);
            return 1;
        }
        else
        {
            new slot = GetPVarInt(playerid, "SelectedWeaponSlot");
            SendInfoMessage(playerid, "You deleted slot %s.", gWeaponSlots[playerid][slot][E_WEAPON_SLOT_NAME]);
            if(gWeaponSlots[playerid][slot][E_WEAPON_SLOT_STATUS] == 1)
                ResetAllWeapons(playerid);
            DeleteWeaponSlot(playerid, slot);
            ShowDialog(playerid, DIALOG_WEAPONS);
            return 1;
        }
    }
    if( dialogid == DIALOG_WEAPONS_SLOTEDITNAME )
    {
        if( !response )
        {
            ShowDialog(playerid, DIALOG_WEAPONS_SLOTEDIT);
            return 1;
        }
        if( response ) {
            new slot_name[64];
            new slot = GetPVarInt(playerid, "SelectedWeaponSlot");
            if( sscanf( inputtext, "s[64]", slot_name) )
            {
                new string[158];
                format(string, sizeof(string), "{FFFFFF}Enter the new name for the slot.\n\n{FFFFFF}Current Name: {1AD630}%s", gWeaponSlots[playerid][slot][E_WEAPON_SLOT_NAME]);
                SPD( playerid, DIALOG_WEAPONS_SLOTEDITNAME, DSI, "Edit Slot Name", string, "Enter", "Back" );
            }
            SendGreenMessage(playerid, "You have changed the slot name.");
            UpdateWeaponSlotName(playerid, slot, slot_name);
            ShowDialog(playerid, DIALOG_WEAPONS);
            return 1;
        }
 
    }
    return 1;
} 

CMD:weapons(playerid)
{
    if( IsPlayerInAnyVehicle( playerid ) ) return SendErrorMessage( playerid, "You can't while you're in the vehicle." );
    ShowDialog(playerid, DIALOG_WEAPONS);
    return 1;
}
