#include <YSI_Coding\y_hooks>
//============================================CRATES=================================================
enum
{
	e_CRATE_TYPE_NONE,
	e_CRATE_TYPE_FABRICS,
	e_CRATE_TYPE_METALS,
	e_CRATE_TYPE_MATS,
	e_CRATE_TYPE_COKE
}

enum E_CRATE_DEPOT {
	E_CRATE_DEPOT_NAME[48],
	E_CRATE_DEPOT_TYPE,
	E_CRATE_DEPOT_AMOUNT,
	Text3D:E_CRATE_DEPOT_3D,
	E_CRATE_DEPOT_PRICE,
	Float:E_CRATE_DEPOT_X,
	Float:E_CRATE_DEPOT_Y,
	Float:E_CRATE_DEPOT_Z,
}
new gCratesDepot[][E_CRATE_DEPOT] = {
	{ "Fabric Crates", e_CRATE_TYPE_FABRICS, 500, Text3D:-1, 600, 638.8908, 851.9096, -42.9609},
	{ "Metal Crates", e_CRATE_TYPE_METALS, 500, Text3D:-1, 300, 2823.2893, -2465.7300, 12.0962},
	{ "Material Crates", e_CRATE_TYPE_MATS, 500, Text3D:-1, 100, -738.4017,-130.8114,59.8809},
	{ "Cocaine Crates", e_CRATE_TYPE_COKE, 500, Text3D:-1, 200, -2160.3679,654.5424,52.3672}
};
//=======================================DROPPED CRATES=========================================
#define 	MAX_CRATE_DROPS 				500

enum E_CRATE_DROP {

	E_CRATE_DROP_TYPE,
	E_CRATE_DROP_OBJECT,
	Text3D:E_CRATE_DROP_TEXT,
	Float:E_CRATE_DROP_X,
	Float:E_CRATE_DROP_Y,
	Float:E_CRATE_DROP_Z
};
new gDroppedCrates[MAX_CRATE_DROPS][E_CRATE_DROP];
new Iterator:i_Crates<MAX_CRATE_DROPS>;
//==============================================================================================
hook OnGameModeInit()
{
	LoadCrateDepots();
	Iter_Init(i_Crates);
	for(new i = 0; i < MAX_CRATE_DROPS; i++)
	{
		gDroppedCrates[i][E_CRATE_DROP_TYPE] = 0;
		if (IsValidDynamicObject(gDroppedCrates[i][E_CRATE_DROP_OBJECT]))
			DestroyDynamicObject(gDroppedCrates[i][E_CRATE_DROP_OBJECT]);
		gDroppedCrates[i][E_CRATE_DROP_OBJECT] = -1;
		if (IsValidDynamic3DTextLabel(gDroppedCrates[i][E_CRATE_DROP_TEXT]))
			DestroyDynamic3DTextLabel(gDroppedCrates[i][E_CRATE_DROP_TEXT]);
		gDroppedCrates[i][E_CRATE_DROP_TEXT] = Text3D:-1;
	}
	return 1;
}

GetCrateName(type)
{
	new szString[24] = "None";
	switch(type)
	{
		case e_CRATE_TYPE_FABRICS: szString = "Fabrics";
		case e_CRATE_TYPE_METALS: szString = "Metals";
		case e_CRATE_TYPE_MATS: szString = "Materials";
		case e_CRATE_TYPE_COKE: szString = "Cocaine";
	}
	return szString;
}

forward LoadCrateDepots();
public LoadCrateDepots()
{
	for(new i = 0; i < sizeof(gCratesDepot); i++)
	{
		new szString[150];
		format( szString, sizeof( szString ), ""col_zenolo"Crates\n"col_zenolo"Type: "col_white"%s\n"col_zenolo"Price: "col_white"$%d\n"col_zenolo"Amount: "col_white"%d/500", gCratesDepot[ i ][ E_CRATE_DEPOT_NAME ], gCratesDepot[ i ][ E_CRATE_DEPOT_PRICE ], gCratesDepot[i][E_CRATE_DEPOT_AMOUNT]);
		gCratesDepot[ i ][ E_CRATE_DEPOT_3D ] = CreateDynamic3DTextLabel( szString, 0xFFFFFFFF, gCratesDepot[ i ][ E_CRATE_DEPOT_X ], gCratesDepot[ i ][ E_CRATE_DEPOT_Y ], gCratesDepot[ i ][ E_CRATE_DEPOT_Z ], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1 );
	}
	return 1;
}

forward RestockCrates();
public RestockCrates()
{
	for(new i = 0; i < sizeof(gCratesDepot); i++)
	{
		gCratesDepot[i][E_CRATE_DEPOT_AMOUNT] = 500;
	}
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if( PRESSED( KEY_YES ) && !IsPlayerInAnyVehicle(playerid) && gPlayerData[playerid][E_PLAYER_CRATE] == e_CRATE_TYPE_NONE)
	{
		new found = 0;
		for (new i = 0; i < sizeof(gCratesDepot); i++)
		{
			if(IsPlayerInRangeOfPoint(playerid, 3, gCratesDepot[i][E_CRATE_DEPOT_X], gCratesDepot[i][E_CRATE_DEPOT_Y], gCratesDepot[i][E_CRATE_DEPOT_Z]))
			{
				if (gCratesDepot[i][E_CRATE_DEPOT_TYPE] == e_CRATE_TYPE_MATS && gPlayerData[ playerid ][ E_PLAYER_JOB ] != JOB_MAT_SMUGGLER) return SendErrorMessage(playerid, "You are not on material smuggler job.");
				if (gCratesDepot[i][E_CRATE_DEPOT_TYPE] == e_CRATE_TYPE_COKE && gPlayerData[ playerid ][ E_PLAYER_JOB ] != JOB_COKE_SMUGGLER) return SendErrorMessage(playerid, "You are not on cocaine smuggler job.");
				if (gCratesDepot[i][E_CRATE_DEPOT_AMOUNT] < 1) return SendErrorMessage(playerid, "There are no more crates left here.");
				if (gPlayerData[playerid][E_PLAYER_CRATE] != e_CRATE_TYPE_NONE) return SendErrorMessage(playerid, "You are already carrying a crate.");
				if (gPlayerData[ playerid ][ E_PLAYER_MONEY ] < gCratesDepot[i][E_CRATE_DEPOT_PRICE]) return SendErrorMessage(playerid, "You don't have enough money.");
				new group = GetODTurfOwner();
				if (group > 0)
				{
					org_info[ group ][ oSafeMoney ] += gCratesDepot[i][E_CRATE_DEPOT_PRICE]/2;
					sql_organization_update_integer(group, "safe_money", org_info[ group ][ oSafeMoney ] );
				}
				gPlayerData[playerid][E_PLAYER_CRATE] = gCratesDepot[i][E_CRATE_DEPOT_TYPE];
				SetPlayerSpecialAction( playerid, SPECIAL_ACTION_CARRY);
				SetPlayerAttachedObject( playerid, OBJECT_SLOT_BADGE, 3052, 1, 0.15, 0.4, 0.0, 0.0, 90.0, 0.0, 1.0, 1.0, 1.0 );
				LastTaken[playerid] = GetTickCount();
				GivePlayerMoneyEx( playerid, -gCratesDepot[i][E_CRATE_DEPOT_PRICE]);
				gCratesDepot[i][E_CRATE_DEPOT_AMOUNT]--;
				new szString[150];
				format( szString, sizeof( szString ), ""col_zenolo"Crates\n"col_zenolo"Type: "col_white"%s\n"col_zenolo"Price: "col_white"$%d\n"col_zenolo"Amount: "col_white"%d/500", gCratesDepot[ i ][ E_CRATE_DEPOT_NAME ], gCratesDepot[ i ][ E_CRATE_DEPOT_PRICE ], gCratesDepot[i][E_CRATE_DEPOT_AMOUNT]);
				UpdateDynamic3DTextLabelText(gCratesDepot[ i ][ E_CRATE_DEPOT_3D ], 0xFFFFFFFF, szString);
				found = 1;
			}
		}
		if(!found)
		{
			new id = ITER_NONE;
			foreach(new i : i_Crates)
			{
				if (IsPlayerInRangeOfPoint(playerid, 3, gDroppedCrates[i][E_CRATE_DROP_X], gDroppedCrates[i][E_CRATE_DROP_Y], gDroppedCrates[i][E_CRATE_DROP_Z]))
				{
					gPlayerData[playerid][E_PLAYER_CRATE] = gDroppedCrates[i][E_CRATE_DROP_TYPE];
					SetPlayerSpecialAction( playerid, SPECIAL_ACTION_CARRY);
					SetPlayerAttachedObject( playerid, OBJECT_SLOT_BADGE, 3052, 1, 0.15, 0.4, 0.0, 0.0, 90.0, 0.0, 1.0, 1.0, 1.0 );
					LastTaken[playerid] = GetTickCount();

					gDroppedCrates[i][E_CRATE_DROP_TYPE] = 0;
					if (IsValidDynamicObject(gDroppedCrates[i][E_CRATE_DROP_OBJECT]))
						DestroyDynamicObject(gDroppedCrates[i][E_CRATE_DROP_OBJECT]);
					gDroppedCrates[i][E_CRATE_DROP_OBJECT] = -1;
					if (IsValidDynamic3DTextLabel(gDroppedCrates[i][E_CRATE_DROP_TEXT]))
						DestroyDynamic3DTextLabel(gDroppedCrates[i][E_CRATE_DROP_TEXT]);
					gDroppedCrates[i][E_CRATE_DROP_TEXT] = Text3D:-1;
					id = i; //removing the id from iterator in foreach usually crashes the server, Iter_SafeRemove can be used too
					break;
				}
			}
			if (id != ITER_NONE)
			{
				Iter_Remove(i_Crates, id);
			}
		}
	}

	//LOADING IN TRUCK
	if( PRESSED( KEY_YES ) && !IsPlayerInAnyVehicle(playerid) && gPlayerData[playerid][E_PLAYER_CRATE] != e_CRATE_TYPE_NONE)
	{
		if ((GetTickCount() - LastTaken[playerid]) < 1500) return 0;
		new vehicleid = 0;
		foreach(new i : Vehicle) {
			new Float:X, Float:Y, Float:Z;
			GetVehiclePos(i, X, Y, Z);
			if( IsPlayerInRangeOfPoint( playerid, 5.0, X, Y, Z) && GetVehicleVirtualWorld(i) == GetPlayerVirtualWorld(playerid)) {
				vehicleid = i;
				break;
			}
			else
				continue;
		}
		if (vehicleid == 0)
		{
			if(gPlayerData[playerid][E_PLAYER_CRATE] != e_CRATE_TYPE_MATS && gPlayerData[playerid][E_PLAYER_CRATE] != e_CRATE_TYPE_COKE) return 0;
			new group = GetNearestOrganization( playerid );
			new OrgID = GetPlayerIllegalOrg(playerid);
			if(OrgID == -1) return 0;
			if(group == -1) return 0;
			if(group != OrgID) return 0;
			if(gPlayerData[playerid][E_PLAYER_CRATE] == e_CRATE_TYPE_MATS)
			{
				SendClientMessageEx( playerid, 0x95b4a2FF, "[Mats] You delivered 25 materials to the group. You received 25 mats as bonus.");
				
				PlayerInventoryAdd( playerid, "Material", 18633, 25 );
				GroupInventory_Add( group, "Material", 18633, 25 );
				gPlayerData[playerid][E_PLAYER_CRATE] = e_CRATE_TYPE_NONE;
				SetPlayerSpecialAction(playerid, 0);
				RemovePlayerAttachedObject( playerid, OBJECT_SLOT_BADGE );
				format( globalstring, sizeof( globalstring ), "%s puts a material crate in the HQ.", PlayerMaskedName( playerid ) );
				RangeMessage(20.0 , playerid, globalstring );
				return 1;
			}
			else if(gPlayerData[playerid][E_PLAYER_CRATE] == e_CRATE_TYPE_COKE)
			{

				gPlayerData[ playerid ][ E_PLAYER_COCAINE_SKILL ]++;
				sql_user_update_integer( playerid, "drug_skill", gPlayerData[playerid][E_PLAYER_COCAINE_SKILL] );

				if(gPlayerData[ playerid ][ E_PLAYER_COCAINE_SKILL ] <= 50)
				{
					PlayerInventoryAdd( playerid, "Cocaine(P)", 1575, 5 );
				
					SendGreenMessage( playerid, "You received 10g of Cocaine(P) and half of it went to group storage!" );

					GroupInventory_Add( group, "Cocaine(P)", 1575, 5 );
				}
				else if(gPlayerData[ playerid ][ E_PLAYER_COCAINE_SKILL ] > 50 && gPlayerData[ playerid ][ E_PLAYER_COCAINE_SKILL ] <= 100)
				{
					PlayerInventoryAdd( playerid, "Cocaine(N)", 1580, 5 );
				
					SendGreenMessage( playerid, "You received 10g of Cocaine(N) and half of it went to group storage!" );

					GroupInventory_Add( group, "Cocaine(N)", 1580, 5 );
				}
				else if(gPlayerData[ playerid ][ E_PLAYER_COCAINE_SKILL ] > 100 && gPlayerData[ playerid ][ E_PLAYER_COCAINE_SKILL ] <= 200)
				{
					PlayerInventoryAdd( playerid, "Cocaine(G)", 1578, 5 );
				
					SendGreenMessage( playerid, "You received 10g of Cocaine(G) and half of it went to group storage!" );

					GroupInventory_Add( group, "Cocaine(G)", 1578, 5 );
				}
				else if(gPlayerData[ playerid ][ E_PLAYER_COCAINE_SKILL ] > 200 )
				{
					PlayerInventoryAdd( playerid, "Cocaine(E)", 1579, 5 );
				
					SendGreenMessage( playerid, "You received 10g of Cocaine(E) and half of it went to group storage!" );

					GroupInventory_Add( group, "Cocaine(E)", 1579, 5 );
				}

				gPlayerData[playerid][E_PLAYER_CRATE] = e_CRATE_TYPE_NONE;
				SetPlayerSpecialAction(playerid, 0);
				RemovePlayerAttachedObject( playerid, OBJECT_SLOT_BADGE );
				format( globalstring, sizeof( globalstring ), "%s puts a cocaine crate in the HQ.", PlayerMaskedName( playerid ) );
				RangeMessage(20.0 , playerid, globalstring );
				return 1;
			}
			else return 0;

		}
		new Float:vehPos[ 3 ];
		getPosBehindVehicle( vehicleid, vehPos[ 0 ], vehPos[ 1 ], vehPos[ 2 ], 0.0 );
		if (!IsPlayerInRangeOfPoint(playerid, 3, vehPos[ 0 ], vehPos[ 1 ], vehPos[ 2 ])) return 0;
		if (!IsTruckingVehicle( vehicleid)) return SendErrorMessage( playerid, "This vehicle can't be used for trucking." );
		if (gVehicleData[vehicleid][E_VEHICLE_CRATE_TYPE] != gPlayerData[playerid][E_PLAYER_CRATE] && gVehicleData[vehicleid][E_VEHICLE_CRATE_TYPE] != 0) return SendErrorMessage( playerid, "There can be only one type of crate in the truck at a time." );
		if (gVehicleData[vehicleid][E_VEHICLE_CRATES] >= GetTruckWeight(vehicleid)) return SendErrorMessage( playerid, "There are already maximum boxes in this truck." );
		
		RemovePlayerAttachedObject(playerid, OBJECT_SLOT_BADGE);
		SetPlayerSpecialAction(playerid, 0);

		gVehicleData[vehicleid][E_VEHICLE_CRATE_TYPE] = gPlayerData[playerid][E_PLAYER_CRATE];
		gVehicleData[vehicleid][E_VEHICLE_CRATES] += 5;
		gPlayerData[playerid][E_PLAYER_CRATE] = e_CRATE_TYPE_NONE;

		if (gVehicleData[vehicleid][E_VEHICLE_CRATES] == 5)
		{
			if (IsValidDynamic3DTextLabel(gVehicleData[vehicleid][E_VEHICLE_TEXT]))
				DestroyDynamic3DTextLabel(gVehicleData[vehicleid][E_VEHICLE_TEXT]);
			new szString[64];
			format( szString, sizeof( szString ), ""col_zenolo"%s: "col_white"%d", GetCrateName(gVehicleData[vehicleid][E_VEHICLE_CRATE_TYPE]), gVehicleData[vehicleid][E_VEHICLE_CRATES]);
			gVehicleData[vehicleid][E_VEHICLE_TEXT] = CreateDynamic3DTextLabel(szString, 0xFFFFFFC8, 0, 0, 0, 13, INVALID_PLAYER_ID, vehicleid, 0, -1, -1, -1, 30.0, -1, 1);
		}
		else
		{
			new szString[64];
			format( szString, sizeof( szString ), ""col_zenolo"%s: "col_white"%d", GetCrateName(gVehicleData[vehicleid][E_VEHICLE_CRATE_TYPE]), gVehicleData[vehicleid][E_VEHICLE_CRATES]);
			UpdateDynamic3DTextLabelText(gVehicleData[vehicleid][E_VEHICLE_TEXT], -1, szString);
		}

		LastTaken[playerid] = GetTickCount();//for use in unloading
		format( globalstring, sizeof( globalstring ), "%s loads a crate into the truck", PlayerMaskedName( playerid ) );
		RangeMessage(20.0 , playerid, globalstring );
	}

//UNLOADING FROM TRUCK
	if( PRESSED( KEY_YES ) && !IsPlayerInAnyVehicle(playerid) && gPlayerData[playerid][E_PLAYER_CRATE] == e_CRATE_TYPE_NONE)
	{
		if ((GetTickCount() - LastTaken[playerid]) < 2000) return 0; //to stop unloading and loading at same time
		new vehicleid = 0;
		foreach(new i : Vehicle) {
			new Float:X, Float:Y, Float:Z;
			GetVehiclePos(i, X, Y, Z);
			if( IsPlayerInRangeOfPoint( playerid, 5.0, X, Y, Z) && GetVehicleVirtualWorld(i) == GetPlayerVirtualWorld(playerid)) {
				vehicleid = i;
				break;
			}
			else
				continue;
		}
		if (vehicleid == 0) return 0; //SendErrorMessage( playerid, "You are not close to a truck.");
		new Float:vehPos[ 3 ];
		getPosBehindVehicle( vehicleid, vehPos[ 0 ], vehPos[ 1 ], vehPos[ 2 ], 0.0 );
		if (!IsPlayerInRangeOfPoint(playerid, 3, vehPos[ 0 ], vehPos[ 1 ], vehPos[ 2 ])) return 0; //SendErrorMessage( playerid, "You have to be next to the trunk." );
		if (!IsTruckingVehicle( vehicleid)) return SendErrorMessage( playerid, "This vehicle can't be used for trucking." );
		if (gVehicleData[vehicleid][E_VEHICLE_CRATE_TYPE] == e_CRATE_TYPE_NONE) return SendErrorMessage( playerid, "There are no crates in the truck." );
		if (gVehicleData[vehicleid][E_VEHICLE_CRATES] < 5) return SendErrorMessage( playerid, "There are no crates in the truck." );
		
		gPlayerData[playerid][E_PLAYER_CRATE] = gVehicleData[vehicleid][E_VEHICLE_CRATE_TYPE];
		SetPlayerSpecialAction( playerid, SPECIAL_ACTION_CARRY);
		SetPlayerAttachedObject( playerid, OBJECT_SLOT_BADGE, 3052, 1, 0.15, 0.4, 0.0, 0.0, 90.0, 0.0, 1.0, 1.0, 1.0 );
		
		gVehicleData[vehicleid][E_VEHICLE_CRATES] -= 5;

		if (gVehicleData[vehicleid][E_VEHICLE_CRATES] < 5)
		{
			if (IsValidDynamic3DTextLabel(gVehicleData[vehicleid][E_VEHICLE_TEXT]))
				DestroyDynamic3DTextLabel(gVehicleData[vehicleid][E_VEHICLE_TEXT]);
			gVehicleData[vehicleid][E_VEHICLE_TEXT] = Text3D:-1;
			gVehicleData[vehicleid][E_VEHICLE_CRATE_TYPE] = e_CRATE_TYPE_NONE;
		}
		else
		{
			if (IsValidDynamic3DTextLabel(gVehicleData[vehicleid][E_VEHICLE_TEXT]))
			{
				new szString[64];
				format( szString, sizeof( szString ), ""col_zenolo"%s: "col_white"%d", GetCrateName(gVehicleData[vehicleid][E_VEHICLE_CRATE_TYPE]), gVehicleData[vehicleid][E_VEHICLE_CRATES]);
				UpdateDynamic3DTextLabelText(gVehicleData[vehicleid][E_VEHICLE_TEXT], -1, szString);
			}
		}
		LastTaken[playerid] = GetTickCount();
		format( globalstring, sizeof( globalstring ), "%s unloads a crate from the truck.", PlayerMaskedName( playerid ) );
		RangeMessage(20.0 , playerid, globalstring );
	}
	return 1;
}

hook OnPlayerEnterDynArea(playerid, STREAMER_TAG_AREA areaid)
{
	new whid = GetNearestWareHouse( playerid );
	if (whid !=-1 && warehouse[whid][whOrgOwner] != -1)
	{
		if (areaid == warehouse[whid][whDarea] && GetPlayerState( playerid ) == PLAYER_STATE_ONFOOT) 
		{

			if (gPlayerData[playerid][E_PLAYER_CRATE] == e_CRATE_TYPE_FABRICS || gPlayerData[playerid][E_PLAYER_CRATE] == e_CRATE_TYPE_METALS)
			{

				if (gPlayerData[playerid][E_PLAYER_CRATE] == e_CRATE_TYPE_FABRICS)
				{
					warehouse[whid][whfabrics]+=5;
				}
				else if (gPlayerData[playerid][E_PLAYER_CRATE] == e_CRATE_TYPE_METALS)
				{
					warehouse[whid][whmetals]+=5;
				}

				gPlayerData[playerid][E_PLAYER_CRATE] = e_CRATE_TYPE_NONE;
				SetPlayerSpecialAction(playerid, 0);
				RemovePlayerAttachedObject( playerid, OBJECT_SLOT_BADGE );
				format( globalstring, sizeof( globalstring ), "%s puts a crate in the warehouse.", PlayerMaskedName( playerid ) );
				RangeMessage(20.0 , playerid, globalstring );

				if (warehouse[whid][whmetals] == warehouse[whid][whfabrics])
				{
					warehouse[whid][whgunparts] = warehouse[whid][whgunparts] + warehouse[whid][whmetals];
					warehouse[whid][whfabrics]=	0;
					warehouse[whid][whmetals]= 0;	
				}
				new szString[ 256 ];
				format( szString, sizeof( szString ), ""col_white"Fabrics: "col_server"%d"col_white"\nMetals: "col_server"%d"col_white"\nGunparts: "col_server"%d",  warehouse[whid][whfabrics],warehouse[whid][whmetals],warehouse[whid][whgunparts] );
				UpdateDynamic3DTextLabelText(warehouse[whid][whLabel], -1, szString);

			}
		}
	}
	return 1;
}

CMD:dropcrate(playerid)
{
	if(gPlayerData[playerid][E_PLAYER_CRATE] != e_CRATE_TYPE_NONE)
	{
		for (new i = 0; i < sizeof(gCratesDepot); i++)
		{
			if(IsPlayerInRangeOfPoint(playerid, 4, gCratesDepot[i][E_CRATE_DEPOT_X], gCratesDepot[i][E_CRATE_DEPOT_Y], gCratesDepot[i][E_CRATE_DEPOT_Z]))
			{
				return SendErrorMessage(playerid, "You cannot drop a crate close to the crate depot. Move away a little.");
			}
		}
		RemovePlayerAttachedObject( playerid, OBJECT_SLOT_BADGE );
		SetPlayerSpecialAction(playerid, 0);
		new
			i = Iter_Free(i_Crates);

		if (i != ITER_NONE)
		{
			gDroppedCrates[i][E_CRATE_DROP_TYPE] = gPlayerData[playerid][E_PLAYER_CRATE];

			GetXYInFrontOfPlayer(playerid, gDroppedCrates[i][E_CRATE_DROP_X], gDroppedCrates[i][E_CRATE_DROP_Y], 1.0);
			new 
				Float:x, Float:y;
			GetPlayerPos(playerid, x, y, gDroppedCrates[i][E_CRATE_DROP_Z]);
			if (IsValidDynamicObject(gDroppedCrates[i][E_CRATE_DROP_OBJECT]))
				DestroyDynamicObject(gDroppedCrates[i][E_CRATE_DROP_OBJECT]);
			gDroppedCrates[i][E_CRATE_DROP_OBJECT] = CreateDynamicObject( 3052, gDroppedCrates[i][E_CRATE_DROP_X], gDroppedCrates[i][E_CRATE_DROP_Y], gDroppedCrates[i][E_CRATE_DROP_Z]-0.9, 0.0, 0.0, 0.0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), -1, 50.0, 50.0);
			if (IsValidDynamic3DTextLabel(gDroppedCrates[i][E_CRATE_DROP_TEXT]))
				DestroyDynamic3DTextLabel(gDroppedCrates[i][E_CRATE_DROP_TEXT]);
			new szLabel[100];
			format(szLabel, sizeof(szLabel), ""col_white"Crate\n"col_white"Type: "col_zenolo"%s\n"col_white"Press ~k~~CONVERSATION_YES~ to pickup", GetCrateName(gDroppedCrates[i][E_CRATE_DROP_TYPE]));
			gDroppedCrates[i][E_CRATE_DROP_TEXT] = CreateDynamic3DTextLabel(szLabel, 0xFFFFFFFF, gDroppedCrates[i][E_CRATE_DROP_X], gDroppedCrates[i][E_CRATE_DROP_Y], gDroppedCrates[i][E_CRATE_DROP_Z]-0.8, 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), -1, 20.0 );
			Iter_Add(i_Crates, i);
			Streamer_Update(playerid);
		}
		gPlayerData[playerid][E_PLAYER_CRATE] = e_CRATE_TYPE_NONE;
		SendInfoMessage(playerid, "You dropped the crate.");
	}
	else SendErrorMessage(playerid, "You are not carrying a crate.");
	return 1;
}