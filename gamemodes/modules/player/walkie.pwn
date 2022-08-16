//================================================================================
enum e_walkie_data
{
    e_walkie_freq,
    e_walkie_rank,
    e_walkie_mute,
    e_walkie_type,
    e_walkie_group,
    e_walkie_toggle
}
new gPlayerWalkieTalkie[MAX_PLAYERS][MAX_WALKIE_SLOTS][e_walkie_data];

#define         WT_TYPE_PERSONAL                0
#define         WT_TYPE_GROUP                   1
//================================================================================

stock bool:IsPlayerInWalkie(playerid, freq)
{
    for(new i = 0; i < MAX_WALKIE_SLOTS; i++)
    {
        if(gPlayerWalkieTalkie[playerid][i][e_walkie_freq] > 0) //validation, better safe than sorry
        {
            if(gPlayerWalkieTalkie[playerid][i][e_walkie_freq] == freq)
                return true;
        }
    }
    return false;
}
stock GetPlayerWalkieRank(playerid, freq)
{
    for(new i = 0; i < MAX_WALKIE_SLOTS; i++)
    {
        if(gPlayerWalkieTalkie[playerid][i][e_walkie_freq] > 0) //validation, better safe than sorry
        {
            if(gPlayerWalkieTalkie[playerid][i][e_walkie_freq] == freq)
                return gPlayerWalkieTalkie[playerid][i][e_walkie_rank];
        }
    }
    return 0;
}
stock GetPlayerWalkieSlot(playerid, freq)
{
    for(new i = 0; i < MAX_WALKIE_SLOTS; i++)
    {
        if(gPlayerWalkieTalkie[playerid][i][e_walkie_freq] > 0) //validation, better safe than sorry
        {
            if(gPlayerWalkieTalkie[playerid][i][e_walkie_freq] == freq)
                return i;
        }
    }
    return 0;
}

stock ResetPlayerWalkies(playerid)
{
    for(new i = 0; i < MAX_WALKIE_SLOTS; i++)
    {
        gPlayerWalkieTalkie[playerid][i][e_walkie_freq] = -1;
        gPlayerWalkieTalkie[playerid][i][e_walkie_rank] = -1;
        gPlayerWalkieTalkie[playerid][i][e_walkie_mute] = 0;
        gPlayerWalkieTalkie[playerid][i][e_walkie_toggle] = 1;
        gPlayerWalkieTalkie[playerid][i][e_walkie_group] = 0;
        gPlayerWalkieTalkie[playerid][i][e_walkie_type] = 0;
    }
    return 1;
}

WalkieMessage( color, freq, const string[] ) {
    foreach(new i : Player) 
    {
        for(new slot = 0; slot < MAX_WALKIE_SLOTS; slot++)
        {
            if(gPlayerWalkieTalkie[i][slot][e_walkie_freq] == freq)
            {
                new str[250];
                format(str, sizeof(str), "*** [%d | %d] ", slot+1, freq);
                strcat(str, string);
                SCM( i, color, str );
                break;
            }
        }
    }
    format( globalstring, sizeof( globalstring ), "[WT] %d | %s", freq, string );
    LogSave( "Ostalo/LogWT.log", globalstring );
}

WalkieChat( freq, const string[] ) {
    foreach(new i : Player) 
    {
        for(new slot = 0; slot < MAX_WALKIE_SLOTS; slot++)
        {
            if(gPlayerWalkieTalkie[i][slot][e_walkie_freq] == freq)
            {
                new str[250];
                format(str, sizeof(str), "*** [%d | %d] ", slot+1, freq);
                strcat(str, string);

                SCM( i, gPlayerData[ i ][ E_PLAYER_WT_COLOR ][slot], str );
                break;
            }
        }
    }
    format( globalstring, sizeof( globalstring ), "[WT] %d | %s", freq, string );
    LogSave( "Ostalo/LogWT.log", globalstring );
}

CMD:ch( playerid, params[] ) {
    if( !Inventory_HasItem( playerid, "Walkie Talkie" ) ) return SendErrorMessage(playerid, "You don't have a walkie talkie in your inventory.");
    new item[32], number, slot;
    if( sscanf( params, "s[32]i", item, slot )) {
        SCM( playerid, SVETLOPLAVA, "___________________________________________________________________");
        SendUsageMessage( playerid, "/ch [ option ] [slot]");
        SCM( playerid, BELA, "[option] join, register, unregister, members, ban, unban, level, leave, kick, lock, unlock");
        SCM( playerid, SVETLOPLAVA, "___________________________________________________________________");
        return 1;
    }
    if( strcmp( item, "join", true ) == 0) {
        if( sscanf( params, "s[32]ii ", item,slot,number )) return SendUsageMessage( playerid, "/ch [ join ] [slot] [frequency]");
        if(number == 911 && !IsACop(playerid)) return SendErrorMessage(playerid, "Only law enforcement agencies can join the specified walkie talkie channel.");
        if(slot > MAX_WALKIE_SLOTS || slot <1) return SendErrorMessage(playerid, "Invalid slot number (1 to %d).", MAX_WALKIE_SLOTS);
        if(number < 1) return SendErrorMessage(playerid, "Walkie talkie frequency can't be lower than 1.");
        if(IsPlayerInWalkie(playerid, number)) return SendErrorMessage(playerid, "You are already part of that channel.");

        new query[ 128 ]; 
        mysql_format( _dbConnector, query, sizeof(query), "SELECT `banned` FROM `wtmembers` WHERE `playersqlid` = '%d' AND `freq` = '%d'", gPlayerData[playerid][E_PLAYER_ID], number );
        mysql_pquery( _dbConnector, query, "IsWTBanned", "iii",playerid, number, slot-1);

        return 1;
    }
    else if( strcmp( item, "register",true) == 0) 
    {
        new prefix[12];
        if( sscanf( params, "s[32]iS()[12]", item, slot, prefix )) return SendUsageMessage( playerid, "/ch [ register ] [slot]");
        if(slot > MAX_WALKIE_SLOTS || slot <1) return SendErrorMessage(playerid, "Invalid slot number (1 to %d).", MAX_WALKIE_SLOTS);
        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] == -1) return SendErrorMessage(playerid, "You don't have a walkie talkie frequency set in that slot.");

        if(!isnull(prefix))
        {
            new OrgID = getOrgIDByPrefix(prefix);
            if (OrgID == -1) return SendErrorMessage(playerid, "No group exists by that tag.");
            if (!IsPlayerInGroup(playerid, OrgID)) return SendErrorMessage(playerid, "You are not part of the specified group.");
            if(org_info[OrgID][oFrequency] != 0) return SendErrorMessage(playerid, "Your group already owns a walkie talkie frequency (%d).", org_info[OrgID][oFrequency]);
            if (GetPlayerGroupRank(OrgID, playerid) != 100) return SendErrorMessage(playerid, "You must be rank 100 to set register a walkie talkie for your group.");
            new query[ 128 ]; 
            mysql_format( _dbConnector, query, sizeof(query), "SELECT * FROM `walkies` WHERE `freq` = '%d'", gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
            mysql_pquery( _dbConnector, query, "CheckWalkieTalkieGroup", "iiii", playerid, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], slot-1, OrgID);
            return 1;
        }
        if(gPlayerData[playerid][E_PLAYER_OWNED_FREQ] > 0) return SendErrorMessage(playerid, "You already own a walkie talkie channel");
        new query[ 128 ]; 
        mysql_format( _dbConnector, query, sizeof(query), "SELECT * FROM `walkies` WHERE `freq` = '%d'", gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
        mysql_pquery( _dbConnector, query, "CheckWalkieTalkie", "iii", playerid, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], slot-1);

        return 1;
    }
    else if( strcmp( item, "unregister",true) == 0) 
    {
        if(gPlayerData[playerid][E_PLAYER_OWNED_FREQ] < 1) return SendErrorMessage(playerid, "You dont' own a walkie talkie frequency");
        if(slot > MAX_WALKIE_SLOTS || slot <1) return SendErrorMessage(playerid, "Invalid slot number (1 to %d).", MAX_WALKIE_SLOTS);

        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] == -1) return SendErrorMessage(playerid, "You don't have a walkie talkie frequency set in that slot.");
        new query[ 128 ]; 
        mysql_format( _dbConnector, query, sizeof(query), "SELECT * FROM `walkies` WHERE `freq` = '%d'", gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
        mysql_pquery( _dbConnector, query, "CheckWTOwner", "iii", playerid, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], slot-1);

        return 1;
    }
    else if( strcmp( item, "members",true) == 0) {
        if(slot > MAX_WALKIE_SLOTS || slot <1) return SendErrorMessage(playerid, "Invalid slot number (1 to %d).", MAX_WALKIE_SLOTS);
        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] == -1) return SendErrorMessage(playerid, "You don't have a walkie talkie frequency set in that slot.");

        strdel( DialogStrgEx, 0, sizeof( DialogStrgEx ) );
        strcat(DialogStrgEx, "Name\tLevel\n");
        foreach(new i : Player) 
        {
            for(new x = 0; x < MAX_WALKIE_SLOTS; x++)
            {
                if(gPlayerWalkieTalkie[i][x][e_walkie_freq] == gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq])
                {
                    format( DialogStrgEx, sizeof( DialogStrgEx ), "%s\n%s\t%s", DialogStrgEx, PlayerName(i), GetWalkieRank(gPlayerWalkieTalkie[i][x][e_walkie_rank]) );
                }
            }
        }
        SPD(playerid, DIALOG_UNUSED, DIALOG_STYLE_TABLIST_HEADERS, "Members", DialogStrgEx, "Close","");
        strdel( DialogStrgEx, 0, sizeof( DialogStrgEx ) );
        return 1;
    }

    else if( strcmp( item, "leave",true) == 0) {
        if( sscanf( params, "s[32]i ", item, slot )) return SendUsageMessage( playerid, "/ch leave [slot]");
        if(slot > MAX_WALKIE_SLOTS || slot <1) return SendErrorMessage(playerid, "Invalid slot number (1 to %d).", MAX_WALKIE_SLOTS);
        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] == -1) return SendErrorMessage(playerid, "You don't have a walkie talkie frequency set in that slot.");

        format( globalstring, sizeof( globalstring ), "%s has left the channel.", PlayerName( playerid ));
        WalkieMessage(0x479267AA, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], globalstring);
        new q[ 256 ];
        mysql_format( _dbConnector, q, sizeof(q), "UPDATE `wtmembers` SET `current` = '0' WHERE `playersqlid` = '%d' and `freq` = '%d'", gPlayerData[ playerid ][ E_PLAYER_ID ], gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
        mysql_tquery( _dbConnector, q, "", "");

        gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] = -1;
        gPlayerWalkieTalkie[playerid][slot-1][e_walkie_rank] = -1;
        gPlayerWalkieTalkie[playerid][slot-1][e_walkie_group] = 0;
        gPlayerWalkieTalkie[playerid][slot-1][e_walkie_type] = 0;

        return 1;
    }
    else if( strcmp( item, "ban",true) == 0) {
        new id;
        if( sscanf( params, "s[32]ii ", item,slot,id )) return SendUsageMessage( playerid, "/ch [ ban ] [slot] [ID of player]");
        if(slot > MAX_WALKIE_SLOTS || slot <1) return SendErrorMessage(playerid, "Invalid slot number (1 to %d).", MAX_WALKIE_SLOTS);
        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] == -1) return SendErrorMessage(playerid, "You don't have a walkie talkie frequency set in that slot.");
        
        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_type] == WT_TYPE_PERSONAL)
        {
            if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_rank] < 3) return SendErrorMessage(playerid, "You don't have permissions to ban players.");

            if(!IsPlayerConnected(id)) return SendErrorMessage(playerid, "There is no-one online with that ID.");
            if(!IsPlayerInWalkie(id, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq])) return SendErrorMessage(playerid, "Specified player is not in the walkie talkie.");
            if(GetPlayerWalkieRank(id,  gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq]) >= gPlayerWalkieTalkie[playerid][slot-1][e_walkie_rank]) return SendErrorMessage(playerid, "Specified player has equal or higher rank than you.");

            format( globalstring, sizeof( globalstring ), "%s has banned %s from the channel.", PlayerName( playerid ), PlayerName(id) );
            WalkieMessage(0x479267AA, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], globalstring);
            new wslot = GetPlayerWalkieSlot(id, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq]);
            gPlayerWalkieTalkie[id][wslot][e_walkie_freq] = -1;
            gPlayerWalkieTalkie[id][wslot][e_walkie_rank] = -1;
            gPlayerWalkieTalkie[id][wslot][e_walkie_group] = 0;
            gPlayerWalkieTalkie[id][wslot][e_walkie_type] = 0;
            new q[ 256 ];
            mysql_format( _dbConnector, q, sizeof(q), "UPDATE `wtmembers` SET `banned` = '1', `current` = '0' WHERE `playersqlid` = '%d' and `freq` = '%d'", gPlayerData[ id ][ E_PLAYER_ID ], gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
            mysql_tquery( _dbConnector, q, "", "");

        }
        else
        {
            new orgid = gPlayerWalkieTalkie[playerid][slot-1][e_walkie_group];
            if(orgid < 1) return SendErrorMessage(playerid, "You don't have permission to ban players from walkie talkie.");
            if( !IsPlayerInGroup(playerid, orgid) ) return SendErrorMessage(playerid, "You are not part of the group that owns this walkie talkie.");
            if(!HasPermission(GetPlayerGroupRank(orgid,playerid), orgid, GROUP_WT_BAN)) return SendErrorMessage(playerid, "You don't have permission to ban walkie talkie players.");

            if(!IsPlayerConnected(id)) return SendErrorMessage(playerid, "There is no-one online with that ID.");
            if(!IsPlayerInWalkie(id, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq])) return SendErrorMessage(playerid, "Specified player is not in the walkie talkie.");
            if(GetPlayerGroupRank(orgid,playerid) < GetPlayerGroupRank(orgid,id)) return SendErrorMessage(playerid, "You can't do that on your seniors.");
            if(GetPlayerGroupRank(orgid,playerid) == GetPlayerGroupRank(orgid,id)) return SendErrorMessage(playerid, "You can't do that on players with same rank as you.");

            format( globalstring, sizeof( globalstring ), "%s has banned %s from the channel.", PlayerName( playerid ), PlayerName(id) );
            WalkieMessage(0x479267AA, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], globalstring);
            new wslot = GetPlayerWalkieSlot(id, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq]);
            gPlayerWalkieTalkie[id][wslot][e_walkie_freq] = -1;
            gPlayerWalkieTalkie[id][wslot][e_walkie_rank] = -1;
            gPlayerWalkieTalkie[id][wslot][e_walkie_group] = 0;
            gPlayerWalkieTalkie[id][wslot][e_walkie_type] = 0;
            new q[ 256 ];
            mysql_format( _dbConnector, q, sizeof(q), "UPDATE `wtmembers` SET `banned` = '1', `current` = '0' WHERE `playersqlid` = '%d' and `freq` = '%d'", gPlayerData[ id ][ E_PLAYER_ID ], gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
            mysql_tquery( _dbConnector, q, "", "");

        }
        return 1;
    }
    else if( strcmp( item, "kick",true) == 0) {
        new id;
        if( sscanf( params, "s[32]ii ", item,slot,id )) return SendUsageMessage( playerid, "/ch kick [slot] [ID of player]");
        if(slot > MAX_WALKIE_SLOTS || slot <1) return SendErrorMessage(playerid, "Invalid slot number (1 to %d).", MAX_WALKIE_SLOTS);
        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] == -1) return SendErrorMessage(playerid, "You don't have a walkie talkie frequency set in that slot.");
        
        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_type] == WT_TYPE_PERSONAL)
        {
            if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_rank] < 2) return SendErrorMessage(playerid, "You don't have permissions to kick players.");
            if(!IsPlayerConnected(id)) return SendErrorMessage(playerid, "There is no-one online with that ID.");
            if(!IsPlayerInWalkie(id, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq])) return SendErrorMessage(playerid, "Specified player is not in the walkie talkie.");
            if(GetPlayerWalkieRank(id,  gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq]) >= gPlayerWalkieTalkie[playerid][slot-1][e_walkie_rank]) return SendErrorMessage(playerid, "Specified player has equal or higher rank than you.");

            format( globalstring, sizeof( globalstring ), "%s has kicked %s from the channel.", PlayerName( playerid ), PlayerName(id) );
            WalkieMessage(0x479267AA, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], globalstring);
            new wslot = GetPlayerWalkieSlot(id, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq]);
            gPlayerWalkieTalkie[id][wslot][e_walkie_freq] = -1;
            gPlayerWalkieTalkie[id][wslot][e_walkie_rank] = -1;
            gPlayerWalkieTalkie[id][wslot][e_walkie_group] = 0;
            gPlayerWalkieTalkie[id][wslot][e_walkie_type] = 0;

            new q[ 256 ];
            mysql_format( _dbConnector, q, sizeof(q), "UPDATE `wtmembers` SET `current` = '0' WHERE `playersqlid` = '%d' and `freq` = '%d'", gPlayerData[ id ][ E_PLAYER_ID ], gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
            mysql_tquery( _dbConnector, q, "", "");
        }
        else
        {
            new orgid = gPlayerWalkieTalkie[playerid][slot-1][e_walkie_group];
            if(orgid < 1) return SendErrorMessage(playerid, "You don't have permission to kick players from walkie talkie.");
            if( !IsPlayerInGroup(playerid, orgid) ) return SendErrorMessage(playerid, "You are not part of the group that owns this walkie talkie.");
            if(!HasPermission(GetPlayerGroupRank(orgid,playerid), orgid, GROUP_WT_KICK)) return SendErrorMessage(playerid, "You don't have permission to kick walkie talkie players.");

            if(!IsPlayerConnected(id)) return SendErrorMessage(playerid, "There is no-one online with that ID.");
            if(!IsPlayerInWalkie(id, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq])) return SendErrorMessage(playerid, "Specified player is not in the walkie talkie.");
            if(GetPlayerGroupRank(orgid,playerid) < GetPlayerGroupRank(orgid,id)) return SendErrorMessage(playerid, "You can't do that on your seniors.");
            if(GetPlayerGroupRank(orgid,playerid) == GetPlayerGroupRank(orgid,id)) return SendErrorMessage(playerid, "You can't do that on players with same rank as you.");


            format( globalstring, sizeof( globalstring ), "%s has kicked %s from the channel.", PlayerName( playerid ), PlayerName(id) );
            WalkieMessage(0x479267AA, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], globalstring);
            new wslot = GetPlayerWalkieSlot(id, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq]);
            gPlayerWalkieTalkie[id][wslot][e_walkie_freq] = -1;
            gPlayerWalkieTalkie[id][wslot][e_walkie_rank] = -1;
            gPlayerWalkieTalkie[id][wslot][e_walkie_group] = 0;
            gPlayerWalkieTalkie[id][wslot][e_walkie_type] = 0;
            new q[ 256 ];
            mysql_format( _dbConnector, q, sizeof(q), "UPDATE `wtmembers` SET `current` = '0' WHERE `playersqlid` = '%d' and `freq` = '%d'", gPlayerData[ id ][ E_PLAYER_ID ], gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
            mysql_tquery( _dbConnector, q, "", "");
        }

        return 1;
    }

    else if( strcmp( item, "unban",true) == 0) {
        new id;
        if( sscanf( params, "s[32]ii ", item,slot,id )) return SendUsageMessage( playerid, "/ch [ ban ] [slot] [ID of player]");
        if(slot > MAX_WALKIE_SLOTS || slot <1) return SendErrorMessage(playerid, "Invalid slot number (1 to %d).", MAX_WALKIE_SLOTS);
        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] == -1) return SendErrorMessage(playerid, "You don't have a walkie talkie frequency set in that slot.");
        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_type] == WT_TYPE_PERSONAL)
        {
            if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_rank] < 3) return SendErrorMessage(playerid, "You don't have permissions to unban players.");

            if(!IsPlayerConnected(id)) return SendErrorMessage(playerid, "There is no-one online with that ID.");

            new query[256];
            mysql_format( _dbConnector, query, sizeof(query), "SELECT `banned` FROM `wtmembers` WHERE `playersqlid` = '%d' AND `freq` = '%d'", gPlayerData[id][E_PLAYER_ID], gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
            mysql_pquery( _dbConnector, query, "WTUnbanCheck", "iii", playerid, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], id);
        }
        else
        {
            new orgid = gPlayerWalkieTalkie[playerid][slot-1][e_walkie_group];
            if(orgid < 1) return SendErrorMessage(playerid, "You don't have permission to unban players from walkie talkie.");
            if( !IsPlayerInGroup(playerid, orgid) ) return SendErrorMessage(playerid, "You are not part of the group that owns this walkie talkie.");
            if(!HasPermission(GetPlayerGroupRank(orgid,playerid), orgid, GROUP_WT_BAN)) return SendErrorMessage(playerid, "You don't have permission to unban walkie talkie players.");

            new query[256];
            mysql_format( _dbConnector, query, sizeof(query), "SELECT `banned` FROM `wtmembers` WHERE `playersqlid` = '%d' AND `freq` = '%d'", gPlayerData[id][E_PLAYER_ID], gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
            mysql_pquery( _dbConnector, query, "WTUnbanCheck", "iii", playerid, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], id);
        }
        return 1;
    }
    else if( strcmp( item, "level",true) == 0) {
        new id, level;
        if( sscanf( params, "s[32]iii ", item,slot,id, level )) return SendUsageMessage( playerid, "/ch [ level ] [slot] [ID of player] [level 0-3]");
        if(level < 0 || level > 3) return SendErrorMessage(playerid, "Invalid level specified.");

        if(slot > MAX_WALKIE_SLOTS || slot <1) return SendErrorMessage(playerid, "Invalid slot number (1 to %d).", MAX_WALKIE_SLOTS);
        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] == -1) return SendErrorMessage(playerid, "You don't have a walkie talkie frequency set in that slot.");
        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_type] != WT_TYPE_PERSONAL) return SendErrorMessage(playerid, "You cannot manage levels of group owned walkie talkies.");
        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_rank] < 3) return SendErrorMessage(playerid, "You don't have permissions to set level of players.");

        if(!IsPlayerConnected(id)) return SendErrorMessage(playerid, "There is no-one online with that ID.");
        if(!IsPlayerInWalkie(id, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq])) return SendErrorMessage(playerid, "Specified player is not in the walkie talkie.");
        if(GetPlayerWalkieRank(id,  gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq]) >= gPlayerWalkieTalkie[playerid][slot-1][e_walkie_rank]) return SendErrorMessage(playerid, "Specified player has equal or higher rank than you.");
        if(GetPlayerWalkieRank(id,  gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq]) >= level) return SendErrorMessage(playerid, "Player's walkie talkie level is already equal to or higher than the specified level.");

        new wslot = GetPlayerWalkieSlot(id, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq]);
        gPlayerWalkieTalkie[id][wslot][e_walkie_rank] = level;
        format( globalstring, sizeof( globalstring ), "%s has set %s as %s.", PlayerName( playerid ), PlayerName(id), GetWalkieRank(level) );
        WalkieMessage(0x479267AA, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], globalstring);
        new q[ 256 ];
        mysql_format( _dbConnector, q, sizeof(q), "UPDATE `wtmembers` SET `playerank` = '%d' WHERE `playersqlid` = '%d' and `freq` = '%d'", level, gPlayerData[ id ][ E_PLAYER_ID ], gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
        mysql_tquery( _dbConnector, q, "", "");

        return 1;
    }
    else if( strcmp( item, "lock",true) == 0) {
        if(slot > MAX_WALKIE_SLOTS || slot <1) return SendErrorMessage(playerid, "Invalid slot number (1 to %d).", MAX_WALKIE_SLOTS);
        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] == -1) return SendErrorMessage(playerid, "You don't have a walkie talkie frequency set in that slot.");
        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_type] == WT_TYPE_PERSONAL)
        {
            if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_rank] < 3) return SendErrorMessage(playerid, "You don't have permissions to lock walkie talkie.");

            new query[128];
            mysql_format( _dbConnector, query, sizeof(query), "SELECT `lockstatus` FROM `walkies` WHERE `freq` = '%d'" , gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
            mysql_tquery( _dbConnector, query, "LockWalkieTalkie", "ii", playerid, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq]);
        }
        else
        {
            new orgid = gPlayerWalkieTalkie[playerid][slot-1][e_walkie_group];
            if(orgid < 1) return SendErrorMessage(playerid, "You don't have permission to lock this walkie talkie.");
            if( !IsPlayerInGroup(playerid, orgid) ) return SendErrorMessage(playerid, "You are not part of the group that owns this walkie talkie.");
            if(!HasPermission(GetPlayerGroupRank(orgid,playerid), orgid, GROUP_WT_LOCK)) return SendErrorMessage(playerid, "You don't have permission to lock walkie talkie.");
            new query[128];
            mysql_format( _dbConnector, query, sizeof(query), "SELECT `lockstatus` FROM `walkies` WHERE `freq` = '%d'" , gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
            mysql_tquery( _dbConnector, query, "LockWalkieTalkie", "ii", playerid, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq]);
        }
        return 1;
    }
    else if( strcmp( item, "unlock",true) == 0) {
        if(slot > MAX_WALKIE_SLOTS || slot <1) return SendErrorMessage(playerid, "Invalid slot number (1 to %d).", MAX_WALKIE_SLOTS);
        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] == -1) return SendErrorMessage(playerid, "You don't have a walkie talkie frequency set in that slot.");
        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_type] == WT_TYPE_PERSONAL)
        {
            if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_rank] < 3) return SendErrorMessage(playerid, "You don't have permissions to unlock walkie talkie.");

            new query[128];
            mysql_format( _dbConnector, query, sizeof(query), "SELECT `lockstatus` FROM `walkies` WHERE `freq` = '%d' LIMIT 1" , gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
            mysql_pquery( _dbConnector, query, "UnlockWalkieTalkie", "ii", playerid, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq]);
        }
        else
        {
            new orgid = gPlayerWalkieTalkie[playerid][slot-1][e_walkie_group];
            if(orgid < 1) return SendErrorMessage(playerid, "You don't have permission to unlock this walkie talkie.");
            if( !IsPlayerInGroup(playerid, orgid) ) return SendErrorMessage(playerid, "You are not part of the group that owns this walkie talkie.");
            if(!HasPermission(GetPlayerGroupRank(orgid,playerid), orgid, GROUP_WT_LOCK)) return SendErrorMessage(playerid, "You don't have permission to lock walkie talkie.");
            new query[128];
            mysql_format( _dbConnector, query, sizeof(query), "SELECT `lockstatus` FROM `walkies` WHERE `freq` = '%d' LIMIT 1" , gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
            mysql_pquery( _dbConnector, query, "UnlockWalkieTalkie", "ii", playerid, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq]);
        }
        return 1;
    }
    else {
    
        SCM( playerid, SVETLOPLAVA, "___________________________________________________________________");
        SendUsageMessage( playerid, "/ch [ option ] [slot]");
        SCM( playerid, BELA, "[option] join, register, unregister, members, ban, unban, level, leave, kick, lock, unlock");
        SCM( playerid, SVETLOPLAVA, "___________________________________________________________________");
    }
    return 1;
}
stock GetWalkieRank(level)
{
    new rankname[30] = "None";
    if(level == 0) rankname = "Guest";
    else if(level == 1) rankname = "Member";
    else if(level == 2) rankname = "Moderator";
    else if(level == 3) rankname = "Admin";
    else if(level == 4) rankname = "Owner";
    return rankname;
}

forward IsWTBanned( playerid, freq, slot );
public IsWTBanned( playerid, freq, slot) {

    new rows, fields;
    cache_get_data( rows, fields, _dbConnector );

    if( !rows ) {
        new query[ 128 ]; 
        mysql_format( _dbConnector, query, sizeof(query), "SELECT lockstatus, wt_type, wt_group FROM `walkies` WHERE `freq` = '%d'", freq );
        mysql_tquery( _dbConnector, query, "CheckWTLock", "iii",playerid, freq, slot);

    }
    else {
        new banned = cache_get_field_content_int( 0, "banned" );
        if (banned) return SendErrorMessage(playerid, "You are banned from the specified walkie talkie frequency.");

        new query[ 128 ]; 
        mysql_format( _dbConnector, query, sizeof(query), "SELECT lockstatus, wt_type, wt_group FROM `walkies` WHERE `freq` = '%d'", freq );
        mysql_tquery( _dbConnector, query, "CheckWTLock", "iii",playerid, freq, slot);
    }
    return (true);
}
forward CheckWTLock( playerid, freq, slot);
public CheckWTLock( playerid, freq, slot) {

    new rows, fields;
    new query[ 256 ];
    cache_get_data( rows, fields, _dbConnector );

    if( !rows ) {

        if(gPlayerWalkieTalkie[playerid][slot][e_walkie_freq] > 0)
        {
            format( globalstring, sizeof( globalstring ), "%s has left the channel.", PlayerName( playerid ) );
            WalkieMessage(0x479267AA, gPlayerWalkieTalkie[playerid][slot][e_walkie_freq], globalstring);

            mysql_format( _dbConnector, query, sizeof(query), "UPDATE `wtmembers` SET `current` = '0' WHERE `playersqlid` = '%d' and `freq` = '%d'", gPlayerData[ playerid ][ E_PLAYER_ID ], gPlayerWalkieTalkie[playerid][slot][e_walkie_freq] );
            mysql_tquery( _dbConnector, query, "", "");
        }
        gPlayerWalkieTalkie[playerid][slot][e_walkie_freq] = freq;
        gPlayerWalkieTalkie[playerid][slot][e_walkie_type] = 0;
        gPlayerWalkieTalkie[playerid][slot][e_walkie_group] = 0;

        format( globalstring, sizeof( globalstring ), "%s has joined the channel.", PlayerName( playerid ) );
        WalkieMessage(0x479267AA, gPlayerWalkieTalkie[playerid][slot][e_walkie_freq], globalstring);

        mysql_format( _dbConnector, query, sizeof(query), "SELECT `playerank` FROM `wtmembers` WHERE `playersqlid` = '%d' AND `freq` = '%d'",
        gPlayerData[playerid][E_PLAYER_ID], freq );
        mysql_pquery( _dbConnector, query, "InsertWalkie", "iii",playerid, freq, slot);

    }
    else {
        new status = cache_get_field_content_int( 0, "lockstatus" );
        new wt_type = cache_get_field_content_int( 0, "wt_type" );
        new wt_group = cache_get_field_content_int( 0, "wt_group" );
        if(wt_type == WT_TYPE_PERSONAL)
        {
            if(status == 0)
            {
                if(gPlayerWalkieTalkie[playerid][slot][e_walkie_freq] > 0)
                {
                    format( globalstring, sizeof( globalstring ), "%s has left the channel.", PlayerName( playerid ) );
                    WalkieMessage(0x479267AA, gPlayerWalkieTalkie[playerid][slot][e_walkie_freq], globalstring);

                    mysql_format( _dbConnector, query, sizeof(query), "UPDATE `wtmembers` SET `current` = '0' WHERE `playersqlid` = '%d' and `freq` = '%d'", gPlayerData[ playerid ][ E_PLAYER_ID ], gPlayerWalkieTalkie[playerid][slot][e_walkie_freq] );
                    mysql_tquery( _dbConnector, query, "", "");
                }
                gPlayerWalkieTalkie[playerid][slot][e_walkie_freq] = freq;
                gPlayerWalkieTalkie[playerid][slot][e_walkie_type] = 0;
                gPlayerWalkieTalkie[playerid][slot][e_walkie_group] = 0;

                format( globalstring, sizeof( globalstring ), "%s has joined the channel.", PlayerName( playerid ) );
                WalkieMessage(0x479267AA, gPlayerWalkieTalkie[playerid][slot][e_walkie_freq], globalstring);
                mysql_format( _dbConnector, query, sizeof(query), "SELECT `playerank` FROM `wtmembers` WHERE `playersqlid` = '%d' AND `freq` = '%d'",
                gPlayerData[playerid][E_PLAYER_ID], freq );
                mysql_pquery( _dbConnector, query, "InsertWalkie", "iii",playerid, freq, slot);

            }
            else
            {
                mysql_format( _dbConnector, query, sizeof(query), "SELECT `playerank` FROM `wtmembers` WHERE `playersqlid` = '%d' AND `freq` = '%d'",
                gPlayerData[playerid][E_PLAYER_ID], freq );
                mysql_pquery( _dbConnector, query, "InsertWalkie3", "iii",playerid, freq, slot);
            }
        }
        else
        {
            new org_id = -1;
            if( wt_group > 0 ) {
                for( new id = 1; id < MAX_ORG; id++)  {
                    if( wt_group == org_info[ id ][ oID ] ) {
                        org_id = id;
                        break;
                    }
                }
            }
            if(org_id == -1 || !IsPlayerInGroup(playerid, org_id)) return SendErrorMessage(playerid, "You are not part of the group that owns this frequency.");

            if(gPlayerWalkieTalkie[playerid][slot][e_walkie_freq] > 0)
            {
                format( globalstring, sizeof( globalstring ), "%s has left the channel.", PlayerName( playerid ) );
                WalkieMessage(0x479267AA, gPlayerWalkieTalkie[playerid][slot][e_walkie_freq], globalstring);

                mysql_format( _dbConnector, query, sizeof(query), "UPDATE `wtmembers` SET `current` = '0' WHERE `playersqlid` = '%d' and `freq` = '%d'", gPlayerData[ playerid ][ E_PLAYER_ID ], gPlayerWalkieTalkie[playerid][slot][e_walkie_freq] );
                mysql_tquery( _dbConnector, query, "", "");
            }
            gPlayerWalkieTalkie[playerid][slot][e_walkie_freq] = freq;
            gPlayerWalkieTalkie[playerid][slot][e_walkie_type] = 1;
            gPlayerWalkieTalkie[playerid][slot][e_walkie_group] = org_id;

            format( globalstring, sizeof( globalstring ), "%s has joined the channel.", PlayerName( playerid ) );
            WalkieMessage(0x479267AA, gPlayerWalkieTalkie[playerid][slot][e_walkie_freq], globalstring);
            mysql_format( _dbConnector, query, sizeof(query), "SELECT `playerank` FROM `wtmembers` WHERE `playersqlid` = '%d' AND `freq` = '%d'",
            gPlayerData[playerid][E_PLAYER_ID], freq );
            mysql_pquery( _dbConnector, query, "InsertWalkie", "iii",playerid, freq, slot);
        }
    }
    return (true);
}
forward CheckWTOwner( playerid, freq, slot );
public CheckWTOwner( playerid, freq, slot) {

    new rows, fields;
    cache_get_data( rows, fields, _dbConnector );

    if( !rows ) {
        SendErrorMessage(playerid, "Specified walkie talkie channel is not registered.");
    }
    else {
        new owner = cache_get_field_content_int( 0, "owner" );
        new wt_type = cache_get_field_content_int( 0, "wt_type" );
        new wt_group = cache_get_field_content_int( 0, "wt_group" );
        if(wt_type == 0)
        {
            if(owner != gPlayerData[playerid][E_PLAYER_ID]) return SendErrorMessage(playerid, "You don't own this frequency.");

            new query[ 128 ];
            mysql_format( _dbConnector, query, sizeof( query ), "DELETE FROM `walkies` WHERE `freq` = '%d'",  freq);
            mysql_pquery( _dbConnector, query, "", "" );
            format( globalstring, sizeof( globalstring ), "%s has unregistered the channel.", PlayerName( playerid ) );
            WalkieMessage(0x479267AA, freq, globalstring);
            gPlayerData[ playerid ][E_PLAYER_OWNED_FREQ] = -1;
            gPlayerWalkieTalkie[playerid][slot][e_walkie_rank] = 0;
            sql_user_update_integer( playerid, "ownedwt", gPlayerData[ playerid ][ E_PLAYER_OWNED_FREQ ] );
            mysql_format( _dbConnector, query, sizeof( query ), "UPDATE `wtmembers` SET `playerank` = '0' WHERE `freq` = '%d'",  freq);
            mysql_pquery( _dbConnector, query, "", "" );
            return 1;
        }
        else
        {
            if(wt_group > 0)
            {
                for( new id = 1; id < MAX_ORG; id++)  {
                    if( freq == org_info[ id ][ oFrequency ] ) {
                        org_info[ id ][ oFrequency ] = 0;
                        sql_organization_update_integer( id, "frequency", org_info[id][oFrequency] );
                        break;
                    }
                }
            }

            new query[ 128 ];
            mysql_format( _dbConnector, query, sizeof( query ), "DELETE FROM `walkies` WHERE `freq` = '%d'",  freq);
            mysql_pquery( _dbConnector, query, "", "" );
            format( globalstring, sizeof( globalstring ), "%s has unregistered the channel.", PlayerName( playerid ) );
            WalkieMessage(0x479267AA, freq, globalstring);

            foreach(new i : Player)
            {
                for(new w = 0; w < MAX_WALKIE_SLOTS; w++)
                {
                    if(gPlayerWalkieTalkie[i][w][e_walkie_freq] > 0) //validation, better safe than sorry
                    {
                        if(gPlayerWalkieTalkie[i][w][e_walkie_freq] == freq)
                        {
                             gPlayerWalkieTalkie[i][w][e_walkie_group] = 0;
                             gPlayerWalkieTalkie[i][w][e_walkie_type] = 0;
                        }
                    }
                }
            }
        }
    }
    return (true);
}
forward CheckWalkieTalkieGroup( playerid, freq, slot, group );
public CheckWalkieTalkieGroup( playerid, freq, slot, group) {

    new rows, fields;
    cache_get_data( rows, fields, _dbConnector );

    if( !rows ) {
        new query[256]; 
        mysql_format( _dbConnector, query, sizeof( query ), "INSERT INTO `walkies` ( wt_type, wt_group, freq) VALUES( '%d', '%d', '%d' )", 1, org_info[group][oID], freq  );
        mysql_pquery( _dbConnector, query, "", "" );
        format( globalstring, sizeof( globalstring ), "%s has registered the channel for %s.", PlayerName( playerid ), org_info[group][oName] );
        WalkieMessage(0x479267AA, freq, globalstring);
        
        org_info[group][oFrequency] = freq;
        sql_organization_update_integer( group, "frequency", org_info[group][oFrequency] );

        foreach(new i : Player)
        {
            for(new w = 0; w < MAX_WALKIE_SLOTS; w++)
            {
                if(gPlayerWalkieTalkie[i][w][e_walkie_freq] > 0) //validation, better safe than sorry
                {
                    if(gPlayerWalkieTalkie[i][w][e_walkie_freq] == freq)
                    {
                         gPlayerWalkieTalkie[i][w][e_walkie_group] = group;
                    }
                }
            }
        }

        mysql_format( _dbConnector, query, sizeof(query), "SELECT `playerank` FROM `wtmembers` WHERE `playersqlid` = '%d' AND `freq` = '%d'", gPlayerData[playerid][E_PLAYER_ID], freq );
        mysql_pquery( _dbConnector, query, "InsertWalkie2", "iii", playerid, freq, slot);
    }
    else {
        SendErrorMessage(playerid, "Specified walkie talkie frequency is already registered.");
        return 1;
    }
    return (true);
}
forward CheckWalkieTalkie( playerid, freq, slot );
public CheckWalkieTalkie( playerid, freq, slot) {

    new rows, fields;
    cache_get_data( rows, fields, _dbConnector );

    if( !rows ) {
        new query[256]; 
        mysql_format( _dbConnector, query, sizeof( query ), "INSERT INTO `walkies` ( owner, freq) VALUES( '%d', '%d' )",gPlayerData[playerid][E_PLAYER_ID], freq  );
        mysql_pquery( _dbConnector, query, "", "" );
        format( globalstring, sizeof( globalstring ), "%s has registered the channel.", PlayerName( playerid ) );
        WalkieMessage(0x479267AA, freq, globalstring);
        gPlayerWalkieTalkie[playerid][slot][e_walkie_rank] = 4;
        gPlayerData[ playerid ][E_PLAYER_OWNED_FREQ] = freq;
        sql_user_update_integer( playerid, "ownedwt", gPlayerData[ playerid ][ E_PLAYER_OWNED_FREQ ] );

        mysql_format( _dbConnector, query, sizeof(query), "SELECT `playerank` FROM `wtmembers` WHERE `playersqlid` = '%d' AND `freq` = '%d'",
        gPlayerData[playerid][E_PLAYER_ID], freq );
        mysql_pquery( _dbConnector, query, "InsertWalkie2", "iii", playerid, freq, slot);
    }
    else {
        SendErrorMessage(playerid, "Specified walkie talkie frequency is already registered.");
        return 1;
    }
    return (true);
}
forward InsertWalkie( playerid, freq, slot );
public InsertWalkie( playerid, freq, slot) {

    new rows, fields;
    cache_get_data( rows, fields, _dbConnector );

    if( !rows ) {
        gPlayerWalkieTalkie[playerid][slot][e_walkie_rank] = 0;
        new query[256]; 
        mysql_format( _dbConnector, query, sizeof( query ), "INSERT INTO `wtmembers` ( playersqlid, freq, current) VALUES( '%d', '%d', '%d' )",gPlayerData[playerid][E_PLAYER_ID], freq, 1 );
        mysql_pquery( _dbConnector, query, "");
    }
    else {
        gPlayerWalkieTalkie[playerid][slot][e_walkie_rank] = cache_get_field_content_int( 0, "playerank" );
        new query[256];
        mysql_format( _dbConnector, query, sizeof(query), "UPDATE `wtmembers` SET `current` = '1' WHERE `playersqlid` = '%d' and `freq` = '%d'", gPlayerData[ playerid ][ E_PLAYER_ID ], freq);
        mysql_tquery( _dbConnector, query, "", "");
    }
    return (true);
}
forward InsertWalkie2( playerid, freq, slot );
public InsertWalkie2( playerid, freq, slot) {

    new rows, fields;
    cache_get_data( rows, fields, _dbConnector );
    new query[256]; 
    if( !rows ) {
        mysql_format( _dbConnector, query, sizeof( query ), "INSERT INTO `wtmembers` ( playersqlid, freq, playerank, current) VALUES( '%d', '%d', '%d', '%d')", gPlayerData[playerid][E_PLAYER_ID], freq, 4, 1 );
        mysql_pquery( _dbConnector, query, "");

    }
    else {
        mysql_format( _dbConnector, query, sizeof(query), "UPDATE `wtmembers` SET `playerank` = '4' WHERE `playersqlid` = '%d' AND `freq` = '%d' LIMIT 1",
            gPlayerData[ playerid ][ E_PLAYER_ID ], freq );
        mysql_pquery( _dbConnector, query, "");

    }
    return (true);
}
forward InsertWalkie3( playerid, freq, slot );
public InsertWalkie3( playerid, freq, slot) {

    new rows, fields;
    cache_get_data( rows, fields, _dbConnector );
    if( !rows ) {
        SendErrorMessage(playerid, "Specified walkie talkie frequency is locked.");
    }
    else {

        new rank = cache_get_field_content_int( 0, "playerank" );
        if (rank < 1) return SendErrorMessage(playerid, "Specified walkie talkie frequency is locked.");
        
        if(gPlayerWalkieTalkie[playerid][slot][e_walkie_freq] > 0)
        {
            format( globalstring, sizeof( globalstring ), "%s has left the channel.", PlayerName( playerid ) );
            WalkieMessage(0x479267AA, gPlayerWalkieTalkie[playerid][slot][e_walkie_freq], globalstring);

            new query[256];
            mysql_format( _dbConnector, query, sizeof(query), "UPDATE `wtmembers` SET `current` = '0' WHERE `playersqlid` = '%d' and `freq` = '%d'", gPlayerData[ playerid ][ E_PLAYER_ID ], gPlayerWalkieTalkie[playerid][slot][e_walkie_freq] );
            mysql_tquery( _dbConnector, query, "", "");
        }
        gPlayerWalkieTalkie[playerid][slot][e_walkie_freq] = freq;
        gPlayerWalkieTalkie[playerid][slot][e_walkie_type] = 0;
        gPlayerWalkieTalkie[playerid][slot][e_walkie_group] = 0;
        
        format( globalstring, sizeof( globalstring ), "%s has joined the channel.", PlayerName( playerid ) );
        WalkieMessage(0x479267AA, gPlayerWalkieTalkie[playerid][slot][e_walkie_freq], globalstring);

        new query[256];
        mysql_format( _dbConnector, query, sizeof(query), "SELECT `playerank` FROM `wtmembers` WHERE `playersqlid` = '%d' AND `freq` = '%d'",
        gPlayerData[playerid][E_PLAYER_ID], freq );
        mysql_pquery( _dbConnector, query, "InsertWalkie", "iii",playerid, freq, slot);

    }
    return (true);
}

forward WTUnbanCheck( playerid, freq, id );
public WTUnbanCheck( playerid, freq, id) {

    new rows, fields;
    cache_get_data( rows, fields, _dbConnector );
    if( !rows ) {
        SendErrorMessage(playerid, "Specified player is not banned.");
    }
    else {
        new banned = cache_get_field_content_int( 0, "banned" );
        if (!banned) return SendErrorMessage(playerid, "The player is not banned.");
        format( globalstring, sizeof( globalstring ), "%s has unbanned %s from the channel.", PlayerName( playerid ), PlayerName(id) );
        WalkieMessage(0x479267AA, freq, globalstring);
        new q[ 256 ];
        mysql_format( _dbConnector, q, sizeof(q), "UPDATE `wtmembers` SET `banned` = '0' WHERE `playersqlid` = '%d' and `freq` = '%d'",gPlayerData[ id ][ E_PLAYER_ID ], freq );
        mysql_tquery( _dbConnector, q, "", "");
    }
    return (true);
}
forward LockWalkieTalkie( playerid, freq );
public LockWalkieTalkie( playerid, freq) {

    new rows, fields;
    cache_get_data( rows, fields, _dbConnector );
    if( !rows ) {
        SendErrorMessage(playerid, "You don't have permission to do this.");
    }
    else {
        new locked = cache_get_field_content_int( 0, "lockstatus" );
        if(locked) return SendErrorMessage(playerid, "Channel is already locked.");
        new q[ 128 ];
        mysql_format( _dbConnector, q, sizeof(q), "UPDATE `walkies` SET `lockstatus` = '1' WHERE `freq` = '%d' LIMIT 1", freq );
        mysql_pquery( _dbConnector, q, "", "");
        format( globalstring, sizeof( globalstring ), "%s has locked the channel.", PlayerName( playerid ) );
        WalkieMessage(0x479267AA, freq, globalstring);
    }
    return (true);
}
forward UnlockWalkieTalkie( playerid,freq );
public UnlockWalkieTalkie( playerid,freq) {

    new rows, fields;
    cache_get_data( rows, fields, _dbConnector );
    if( !rows ) {
        SendErrorMessage(playerid, "You don't have permission to do this.");
    }
    else {
        new locked = cache_get_field_content_int( 0, "lockstatus" );
        if(!locked) return SendErrorMessage(playerid, "Channel is already unlocked.");
        new q[ 128 ];
        mysql_format( _dbConnector, q, sizeof(q), "UPDATE `walkies` SET `lockstatus` = '0' WHERE `freq` = '%d' LIMIT 1", freq );
        mysql_pquery( _dbConnector, q, "", "");
        format( globalstring, sizeof( globalstring ), "%s has unlocked the channel.", PlayerName( playerid ) );
        WalkieMessage(0x479267AA, freq, globalstring);
    }
    return (true);
}
CMD:wt( playerid, params[] ) {
    if( !Inventory_HasItem( playerid, "Walkie Talkie" ) ) return SendErrorMessage(playerid, "You don't have a walkie talkie in your inventory.");
    if(GetPlayerSpecialAction( playerid ) == SPECIAL_ACTION_CUFFED) return SendErrorMessage(playerid, "You cannot use this command right now.");
    if( IgracZavezan[ playerid ] ==  true || PlayerCuffed[ playerid ] == 2) return SendErrorMessage(playerid, "You cannot use this command right now while cuff/tied.");
    if(dsys_info[ playerid ][ ds_b_w ] == true) return SendErrorMessage(playerid, "You cannot use this command right now.");
    if( gPlayerData[ playerid ][ E_PLAYER_JAIL_TYPE ] != 0 ) return SendErrorMessage( playerid, "You cannot use this command while in jail." );
    if( gPlayerData[ playerid ][ E_PLAYER_MUTE_TIME ] > gettime() ) return SendErrorMessage( playerid, "You are muted.");
    if( PlayerCuffed[ playerid ] >= 1 ) return SendErrorMessage( playerid, "You can't use the command when you're cuffed or tapped.");
    if( gPlayerData[ playerid ][ E_PLAYER_JAIL_TYPE ] >= 1 ) return SendErrorMessage( playerid, "You cannot write while in prison.");
    new slot, text[250];
    if( sscanf( params, "is[250]", slot, text )) return SendUsageMessage( playerid, "/wt [slot] [text]");
    if(slot > MAX_WALKIE_SLOTS || slot <1) return SendErrorMessage(playerid, "Invalid slot number (1 to %d).", MAX_WALKIE_SLOTS);
    if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] == -1) return SendErrorMessage(playerid, "You have no walkie talkie freq set in specified slot.");
    if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_type] == WT_TYPE_PERSONAL)
    {
        format( globalstring, sizeof( globalstring ), "%s: %s", PlayerName( playerid ), text );
        WalkieChat(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], globalstring);
        format( globalstring, sizeof( globalstring ), "%s (walkie-talkie): %s", PlayerMaskedName( playerid ), text);
        RadiusMessageWT( 20.0, playerid, globalstring, 0, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
    }
    else
    {
        new orgid = gPlayerWalkieTalkie[playerid][slot-1][e_walkie_group];
        if(orgid > 0 && GetGroupType(orgid) == ORG_TIP_PD) 
        {
            if(strcmp(gPlayerData[playerid][E_PLAYER_CALLSIGN], "") )
            {
                format( globalstring, sizeof( globalstring ), "%s [%s]: %s", PlayerName( playerid ), gPlayerData[playerid][E_PLAYER_CALLSIGN], text );
                WalkieChat(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], globalstring);
                format( globalstring, sizeof( globalstring ), "%s (walkie-talkie): %s", PlayerMaskedName( playerid ), text);
                RadiusMessageWT( 20.0, playerid, globalstring, 0, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
            }
            else
            {
                format( globalstring, sizeof( globalstring ), "%s: %s", PlayerName( playerid ), text );
                WalkieChat(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], globalstring);
                format( globalstring, sizeof( globalstring ), "%s (walkie-talkie): %s", PlayerMaskedName( playerid ), text);
                RadiusMessageWT( 20.0, playerid, globalstring, 0, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
            }
        }
        else
        {
            format( globalstring, sizeof( globalstring ), "%s: %s", PlayerName( playerid ), text );
            WalkieChat(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], globalstring);
            format( globalstring, sizeof( globalstring ), "%s (walkie-talkie): %s.", PlayerMaskedName( playerid ), text);
            RadiusMessageWT( 20.0, playerid, globalstring, 0, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
        }
    }
    return 1;
}
CMD:wtlow( playerid, params[] ) {
    if( !Inventory_HasItem( playerid, "Walkie Talkie" ) ) return SendErrorMessage(playerid, "You don't have a walkie talkie in your inventory.");
    if(GetPlayerSpecialAction( playerid ) == SPECIAL_ACTION_CUFFED) return SendErrorMessage(playerid, "You cannot use this command right now.");
    if( IgracZavezan[ playerid ] ==  true || PlayerCuffed[ playerid ] == 2) return SendErrorMessage(playerid, "You cannot use this command right now while cuff/tied.");
    if(dsys_info[ playerid ][ ds_b_w ] == true) return SendErrorMessage(playerid, "You cannot use this command right now.");
    if( gPlayerData[ playerid ][ E_PLAYER_JAIL_TYPE ] != 0 ) return SendErrorMessage( playerid, "You cannot use this command while in jail." );
    if( gPlayerData[ playerid ][ E_PLAYER_MUTE_TIME ] > gettime() ) return SendErrorMessage( playerid, "You are muted.");
    if( PlayerCuffed[ playerid ] >= 1 ) return SendErrorMessage( playerid, "You can't use the command when you're cuffed or tapped.");
    if( gPlayerData[ playerid ][ E_PLAYER_JAIL_TYPE ] >= 1 ) return SendErrorMessage( playerid, "You cannot write while in prison.");
    new slot, text[250];
    if( sscanf( params, "is[250]", slot, text )) return SendUsageMessage( playerid, "/wtlow [slot] [text]");
    if(slot > MAX_WALKIE_SLOTS || slot <1) return SendErrorMessage(playerid, "Invalid slot number (1 to %d).", MAX_WALKIE_SLOTS);
    if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] == -1) return SendErrorMessage(playerid, "You have no walkie talkie freq set in specified slot.");
    if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_type] == WT_TYPE_PERSONAL)
    {
        format( globalstring, sizeof( globalstring ), "%s: %s", PlayerName( playerid ), text );
        WalkieChat(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], globalstring);
        format( globalstring, sizeof( globalstring ), "%s (walkie-talkie): %s", PlayerMaskedName( playerid ), text);
        RadiusMessageWT( 10.0, playerid, globalstring, 0, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
    }
    else
    {
        new orgid = gPlayerWalkieTalkie[playerid][slot-1][e_walkie_group];
        if(orgid > 0) 
        {
            if(GetGroupType(orgid) != ORG_TIP_PD)
            {
                if(strcmp(gPlayerData[playerid][E_PLAYER_CALLSIGN], "") )
                {
                    format( globalstring, sizeof( globalstring ), "%s [%s]: %s", PlayerName( playerid ), gPlayerData[playerid][E_PLAYER_CALLSIGN], text );
                    WalkieChat(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], globalstring);
                    format( globalstring, sizeof( globalstring ), "%s (walkie-talkie): %s", PlayerMaskedName( playerid ), text);
                    RadiusMessageWT( 10.0, playerid, globalstring, 0, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
                }
                else
                {
                    format( globalstring, sizeof( globalstring ), "%s: %s", PlayerName( playerid ), text );
                    WalkieChat(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], globalstring);
                    format( globalstring, sizeof( globalstring ), "%s (walkie-talkie): %s", PlayerMaskedName( playerid ), text);
                    RadiusMessageWT( 10.0, playerid, globalstring, 0, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
                }
            }
        }
        else
        {
            format( globalstring, sizeof( globalstring ), "%s: %s", PlayerName( playerid ), text );
            WalkieChat(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], globalstring);
            format( globalstring, sizeof( globalstring ), "%s (walkie-talkie): %s", PlayerMaskedName( playerid ), text);
            RadiusMessageWT( 10.0, playerid, globalstring, 0, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
        }
    }
    return 1;
}
CMD:wtpanic( playerid, params[] ) {
    if( !Inventory_HasItem( playerid, "Walkie Talkie" ) ) return SendErrorMessage(playerid, "You don't have a walkie talkie in your inventory.");
    if(dsys_info[ playerid ][ ds_b_w ] == true) return SendErrorMessage(playerid, "You cannot use this command right now.");
    if( gPlayerData[ playerid ][ E_PLAYER_JAIL_TYPE ] != 0 ) return SendErrorMessage( playerid, "You cannot use this command while in jail." );
    if( gPlayerData[ playerid ][ E_PLAYER_MUTE_TIME ] > gettime() ) return SendErrorMessage( playerid, "You are muted.");
    if( PlayerCuffed[ playerid ] >= 1 ) return SendErrorMessage( playerid, "You can't use the command when you're cuffed or tapped.");
    if((GetTickCount() - lastpanic[playerid]) < 60000) return SendErrorMessage(playerid, "You can press panic button once every 60 seconds.");
    new slot;
    if( sscanf( params, "i", slot )) return SendUsageMessage( playerid, "/wtpanic [slot]");
    if(slot > MAX_WALKIE_SLOTS || slot <1) return SendErrorMessage(playerid, "Invalid slot number (1 to %d).", MAX_WALKIE_SLOTS);
    if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] == -1) return SendErrorMessage(playerid, "You have no walkie talkie freq set in specified slot.");

    format( globalstring, sizeof( globalstring ), "%s has pressed the panic button at %s.", PlayerName( playerid ), GetPlayerLocation( playerid ) );
    WalkieMessage(0x479267AA, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], globalstring);

    lastpanic[playerid] = GetTickCount();
    format( globalstring, sizeof( globalstring ), "* %s pressed panic button on their walkie talkie.", PlayerMaskedName( playerid ) );
    RangeMessage( 20.0, playerid, globalstring );
    return 1;
}
CMD:wtalert( playerid, params[] ) {
    if( !Inventory_HasItem( playerid, "Walkie Talkie" ) ) return SendErrorMessage(playerid, "You don't have a walkie talkie in your inventory.");
    if( IgracZavezan[ playerid ] ==  true || PlayerCuffed[ playerid ] == 2) return SendErrorMessage(playerid, "You cannot use this command right now while cuff/tied.");
    if(dsys_info[ playerid ][ ds_b_w ] == true) return SendErrorMessage(playerid, "You cannot use this command right now.");
    if( gPlayerData[ playerid ][ E_PLAYER_JAIL_TYPE ] != 0 ) return SendErrorMessage( playerid, "You cannot use this command while in jail." );
    if( gPlayerData[ playerid ][ E_PLAYER_MUTE_TIME ] > gettime() ) return SendErrorMessage( playerid, "You are muted.");
    if( PlayerCuffed[ playerid ] >= 1 ) return SendErrorMessage( playerid, "You can't use the command when you're cuffed or tapped.");
    if( gPlayerData[ playerid ][ E_PLAYER_JAIL_TYPE ] >= 1 ) return SendErrorMessage( playerid, "You cannot write while in prison.");
    new slot, text[250];
    if( sscanf( params, "is[250]", slot, text )) return SendUsageMessage( playerid, "/wtalert [slot] [text]");

    if(slot > MAX_WALKIE_SLOTS || slot <1) return SendErrorMessage(playerid, "Invalid slot number (1 to %d).", MAX_WALKIE_SLOTS);
    if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] == -1) return SendErrorMessage(playerid, "You don't have a walkie talkie frequency set in that slot.");
    if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_type] == WT_TYPE_PERSONAL)
    {
        if(gPlayerWalkieTalkie[playerid][slot-1][e_walkie_rank] < 3) return SendErrorMessage(playerid, "You don't have permissions to make WT alerts.");

        format( globalstring, sizeof( globalstring ), "%s: {F11417}%s", PlayerName( playerid ), text );
        WalkieMessage(walkie, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], globalstring);
        format( globalstring, sizeof( globalstring ), "%s (walkie-talkie): %s.", PlayerMaskedName( playerid ), text);
        RadiusMessageWT( 20.0, playerid, globalstring, 0, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
    }
    else
    {
        new orgid = gPlayerWalkieTalkie[playerid][slot-1][e_walkie_group];
        if(orgid < 1) return SendErrorMessage(playerid, "You don't have group permission to make alerts.");
        if( !IsPlayerInGroup(playerid, orgid) ) return SendErrorMessage(playerid, "You are not part of the group that owns this walkie talkie.");
        if(!HasPermission(GetPlayerGroupRank(orgid,playerid), orgid, GROUP_WT_ALERT)) return SendErrorMessage(playerid, "You don't have group permission to make alerts.");
        format( globalstring, sizeof( globalstring ), "%s: {F11417}%s", PlayerName( playerid ), text );
        WalkieMessage(walkie, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq], globalstring);
        format( globalstring, sizeof( globalstring ), "%s (walkie-talkie): %s.", PlayerMaskedName( playerid ), text);
        RadiusMessageWT( 20.0, playerid, globalstring, 0, gPlayerWalkieTalkie[playerid][slot-1][e_walkie_freq] );
    }
    return 1;
}

CMD:mywt( playerid, params[] ) {

    new count = 0;
    strdel( DialogStrgEx, 0, sizeof( DialogStrgEx ) );
    strcat( DialogStrgEx, "Slot\tChannel\tRank" );
    for(new i = 0; i < MAX_WALKIE_SLOTS; i++)
    {
        if(gPlayerWalkieTalkie[playerid][i][e_walkie_freq] > 0)
        {
            format( DialogStrgEx, sizeof( DialogStrgEx ), "%s\n%d\t%d\t%s", DialogStrgEx, i+1, gPlayerWalkieTalkie[playerid][i][e_walkie_freq], GetWalkieRank(gPlayerWalkieTalkie[playerid][i][e_walkie_rank]) );
            count++;
        }
    }
    if(gPlayerData[playerid][E_PLAYER_OWNED_FREQ] > 0)
    {   
        format( DialogStrgEx, sizeof( DialogStrgEx ), "%s\nOwned Frequency (%d)", DialogStrgEx, gPlayerData[playerid][E_PLAYER_OWNED_FREQ]);
        count++;
    }

    if(count == 0) return SendErrorMessage(playerid, "You are not part of any walkie talkie channel.");
    ShowPlayerDialog( playerid, 0, DIALOG_STYLE_TABLIST_HEADERS, "Your Walkie Talkies", DialogStrgEx, "Close", "" );
    strdel( DialogStrgEx, 0, sizeof( DialogStrgEx ) );
    return 1;
}