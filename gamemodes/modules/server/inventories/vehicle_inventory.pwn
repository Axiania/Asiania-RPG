forward OnVehicleInventoryLoad( vehicleid );
public OnVehicleInventoryLoad( vehicleid ) {

	new rows, fields;
	cache_get_data( rows, fields, _dbConnector );

	if( !rows ) {

		new query[ 128 ];

		format( query, sizeof( query ),
			"INSERT INTO `vehicleinv` (vehicle_id) VALUES('%d')", gVehicleData[ vehicleid ][ E_VEHICLE_DB_ID ] );

		mysql_pquery( _dbConnector, query, "", "" );
	}
	else {

		new textic[ 64 ];
		for( new i = 0; i < MAX_INVENTORY; i++ ) {
		
			format( textic, sizeof( textic ), "inv_slot_model_%d", i+1 );
			vinventoryInfo[ vehicleid ][ i ][ invModel ] = cache_get_field_content_int(0, textic );
			format( textic, sizeof( textic ), "inv_slot_quantity_%d", i+1 ); 
			vinventoryInfo[ vehicleid ][ i ][ invQuantity ] = cache_get_field_content_int(0, textic );
			format( textic, sizeof( textic ), "inv_slot_color_%d", i+1 );
			vinventoryInfo[ vehicleid ][ i ][ invColor ] = cache_get_field_content_int(0, textic );
			format( textic, sizeof( textic ), "inv_slot_robbed_%d", i+1 );
			vinventoryInfo[ vehicleid ][ i ][ invRobbed ] = cache_get_field_content_int(0, textic );
			
			if( vinventoryInfo[ vehicleid ][ i ][ invModel ] != 0 && vinventoryInfo[ vehicleid ][ i ][ invQuantity ] != 0 ) {
				vinventoryInfo[ vehicleid ][ i ][ invExists ] = true;
				
				if( vinventoryInfo[ vehicleid ][ i ][ invModel ] >= 321 && vinventoryInfo[ vehicleid ][ i ][ invModel ] <= 372 && vinventoryInfo[ vehicleid ][ i ][ invModel ] != 365 ) {
				
					for( new z = 0; z < 47; z++ ) {
					
						if( WeaponInfos[ z ][ wModel ] == vinventoryInfo[ vehicleid ][ i ][ invModel ] ) {
						
							strmid( vinventoryInfo[ vehicleid ][ i ][ invItem ], WeaponInfos[ z ][ wName ], 0, strlen( WeaponInfos[ z ][ wName ] ), 32 );
							break;
						}
					}
				}
				else {
				
					for( new j = 0; j < MAX_ITEMS; j++ ) {
						if( vinventoryInfo[ vehicleid ][ i ][ invModel ] == inv_obj_inf[ j ][ i_o_i_model ] ) {
							strmid( vinventoryInfo[ vehicleid ][ i ][ invItem ], inv_obj_inf[ j ][ i_o_i_name ], 0, strlen( inv_obj_inf[ j ][ i_o_i_name ] ), 32 );
							break;
						}
					}
				}
			}
		}
	}
	return (true);
}
stock sql_vinventory_update_quantity( vehicleid, itemid ) {

	new q[ 256 ];
	mysql_format( _dbConnector, q, sizeof(q), "UPDATE `vehicleinv` SET `inv_slot_quantity_%d` = '%d' WHERE `vehicle_id` = '%d'", (itemid+1), vinventoryInfo[ vehicleid ][ itemid ][ invQuantity ], gVehicleData[ vehicleid ][ E_VEHICLE_DB_ID ] );
	mysql_tquery( _dbConnector, q, "", "");

	return true;
}
stock sql_vinventory_update_robbed( vehicleid, itemid ) {

	new q[ 256 ];
	mysql_format( _dbConnector, q, sizeof(q), "UPDATE `vehicleinv` SET `inv_slot_robbed_%d` = '%d' WHERE `vehicle_id` = '%d'", (itemid+1), vinventoryInfo[ vehicleid ][ itemid ][ invRobbed ], gVehicleData[ vehicleid ][ E_VEHICLE_DB_ID ] );
	mysql_tquery( _dbConnector, q, "", "");

	return true;
}
stock sql_vinventory_update_mq( vehicleid, itemid ) { 

	new q[ 256 ];
	mysql_format( _dbConnector, q, sizeof(q), "UPDATE `vehicleinv` SET `inv_slot_model_%d` = '%d', `inv_slot_quantity_%d` = '%d', `inv_slot_color_%d` = '%d' WHERE `vehicle_id` = '%d'",
		(itemid+1),
		vinventoryInfo[ vehicleid ][ itemid ][ invModel ],
		(itemid+1),
		vinventoryInfo[ vehicleid ][ itemid ][ invQuantity ],
		(itemid+1),
		vinventoryInfo[ vehicleid ][ itemid ][ invColor ],
		gVehicleData[ vehicleid ][ E_VEHICLE_DB_ID ] );
		
	mysql_pquery( _dbConnector, q, "", "");

	return true;
}

stock sql_vinventory_remove_item( vehicleid, itemid ) {

	new q[ 256 ];
	mysql_format( _dbConnector, q, sizeof(q), "UPDATE `vehicleinv` SET `inv_slot_model_%d` = '0', `inv_slot_quantity_%d` = '0' WHERE `vehicle_id` = '%d'",
		(itemid+1),
		(itemid+1),
		gVehicleData[ vehicleid ][ E_VEHICLE_DB_ID ] );

	mysql_tquery( _dbConnector, q, "", "");

	return true;
}
stock VehicleInventory_Add( vehicleid, item[], model, quantity = 1 ) {
	new itemid = VehicleInventory_GetItemID( vehicleid, item );
	if(itemid == -1){
		item[0] = toupper(item[0]);
		itemid = VehicleInventory_GetFreeID( vehicleid );
		if( itemid != -1 ) {
			vinventoryInfo[ vehicleid ][ itemid ][ invExists ] = true;
			vinventoryInfo[ vehicleid ][ itemid ][ invModel ] = model;
			vinventoryInfo[ vehicleid ][ itemid ][ invQuantity ] = quantity;
			strmid( vinventoryInfo[ vehicleid ][ itemid ][ invItem ], item, 0, strlen( item ), 32 );
			sql_vinventory_update_mq( vehicleid, itemid );
		}
	}
	else
	{
		vinventoryInfo[ vehicleid ][ itemid ][ invQuantity ] += quantity;
	}
	sql_vinventory_update_quantity( vehicleid, itemid );
	return 1;
}
stock VehicleInventory_GetItemID( vehicleid, item[] )
{
	for( new i = 0; i < MAX_INVENTORY; i++ ) {
		if( !vinventoryInfo[ vehicleid ][ i ][ invExists ] )
			continue;

		if( !strcmp( vinventoryInfo[ vehicleid ][ i ][ invItem ], item , true) ) return i;
	}
	return -1;
}
stock VehicleInventory_GetItemModel( vehicleid, item[] )
{
	for( new i = 0; i < MAX_INVENTORY; i++ ) {
		if( !vinventoryInfo[ vehicleid ][ i ][ invExists ] )
			continue;

		if( !strcmp( vinventoryInfo[ vehicleid ][ i ][ invItem ], item, true ) ) return vinventoryInfo[ vehicleid ][ i ][ invModel ];
	}
	return -1;
}

stock VehicleInventory_GetFreeID( vehicleid ) {
	if( VehicleInventory_Items( vehicleid ) >= 100 )
		return -1;

	for( new i = 0; i < MAX_INVENTORY; i++ ) {
		if( !vinventoryInfo[ vehicleid ][ i ][ invExists ] )
			return i;
	}
	return -1;
}

stock ClearVehicleInventory(id)
{
	for( new i = 0; i < MAX_INVENTORY; i++ ) {
				
		if( vinventoryInfo[ id ][ i ][ invExists ] ) {
		
			vinventoryInfo[ id ][ i ][ invExists ] = false;
			vinventoryInfo[ id ][ i ][ invModel ] = 0;
			vinventoryInfo[ id ][ i ][ invQuantity ] = 0;
			strmid( vinventoryInfo[ id ][ i ][ invItem ], "None", 0, strlen( "None" ), 32 );
		}
	}
	return 1;
}
stock VehicleInventory_Items( vehicleid ) {
	new count;

	for( new i = 0; i != MAX_INVENTORY; i++ ) if( vinventoryInfo[ vehicleid ][ i ][ invExists ] ) {
		count++;
	}
	return count;
}

stock VehicleInventory_Count( vehicleid, item[] ) {
	new itemid = VehicleInventory_GetItemID( vehicleid, item );

	if( itemid != -1 )
		return vinventoryInfo[ vehicleid ][ itemid ][ invQuantity ];

	return false;
}

stock VehicleInventory_HasItem( vehicleid, item[] ) {
	return ( VehicleInventory_GetItemID( vehicleid, item ) != -1 );
}

stock VehicleInventory_SetQuantity( vehicleid, item[], quantity ) {
	new
		itemid = VehicleInventory_GetItemID( vehicleid, item ),
		string[ 128 ];

	if( itemid != -1 ) {
		vinventoryInfo[ vehicleid ][ itemid ][ invQuantity ] = quantity;
		
		sql_vinventory_update_quantity( vehicleid, itemid );
	}
	return true;
}

stock VehicleInventory_Remove( vehicleid, item[], quantity = 1 ) {
	new
		itemid = VehicleInventory_GetItemID( vehicleid, item );

	if( itemid != -1 ) {
	
		if( vinventoryInfo[ vehicleid ][ itemid ][ invQuantity ] > (quantity-1) ) {
			vinventoryInfo[ vehicleid ][ itemid ][ invQuantity ] -= quantity;
		}
		else return false;
		
		if( quantity == -1 || vinventoryInfo[ vehicleid ][ itemid ][ invQuantity ] < 1 ) {
			vinventoryInfo[ vehicleid ][ itemid ][ invExists ] = false;
			vinventoryInfo[ vehicleid ][ itemid ][ invModel ] = 0;
			vinventoryInfo[ vehicleid ][ itemid ][ invQuantity ] = 0;
			strmid( vinventoryInfo[ vehicleid ][ itemid ][ invItem ], "None", 0, strlen( "None" ), 32 );
			vinventoryInfo[ vehicleid ][ itemid ][ invColor ] = -1;

			sql_vinventory_remove_item( vehicleid, itemid );
		}
		else if( quantity != -1 && vinventoryInfo[ vehicleid ][ itemid ][ invQuantity ] > 0 ) { 
			
			sql_vinventory_update_quantity( vehicleid, itemid );
		}
		return true;
	}
	return false;
}

stock VehicleInventory_Remove_2( vehicleid, itemid, quantity = 1 ) {

	if( itemid != -1 ) {
	
		if( vinventoryInfo[ vehicleid ][ itemid ][ invQuantity ] > 0 ) {
			vinventoryInfo[ vehicleid ][ itemid ][ invQuantity ] -= quantity;
		}
		else return false;

		if( quantity == -1 || vinventoryInfo[ vehicleid ][ itemid ][ invQuantity ] < 1 ) {
			vinventoryInfo[ vehicleid ][ itemid ][ invExists ] = false;
			vinventoryInfo[ vehicleid ][ itemid ][ invModel ] = 0;
			vinventoryInfo[ vehicleid ][ itemid ][ invQuantity ] = 0;
			strmid( vinventoryInfo[ vehicleid ][ itemid ][ invItem ], "None", 0, strlen( "None" ), 32 );
			vinventoryInfo[ vehicleid ][ itemid ][ invColor ] = -1;
			sql_vinventory_remove_item( vehicleid, itemid );
		}
		else if( quantity != -1 && vinventoryInfo[ vehicleid ][ itemid ][ invQuantity ] > 0 ) {

			sql_vinventory_update_quantity( vehicleid, itemid );
		}
		return true;
	}
	return false;
}


stock VehicleInventory_Set( vehicleid, item[], model, amount ) {
	new itemid = VehicleInventory_GetItemID( vehicleid, item );

	if( itemid == -1 && amount > 0 )
		VehicleInventory_Add( vehicleid, item, model, amount );

	else if( amount > 0 && itemid != -1 )
		VehicleInventory_SetQuantity( vehicleid, item, amount );

	else if( amount < 1 && itemid != -1 )
		VehicleInventory_Remove( vehicleid, item, -1 );

	return true;
}
CMD:trunk( playerid, params[] ) {
	if(inPUBG[ playerid ] != 0) return SendErrorMessage(playerid, "You cannot while you are at event.");
	if(dsys_info[ playerid ][ ds_b_w ]==true) return SendErrorMessage(playerid, "You cannot use this command right now.");
	if( WARPInfo[ playerid ][ WARIgrac ] != -1 ) return SendErrorMessage( playerid, "You can't do this while you're at war." );
	if( naDeagle[ playerid ] > 0 ) return SendErrorMessage( playerid, "You can't while you're at an event." );
	if( NaDmEventu[ playerid ] == true || inDerby[playerid] || inFall[playerid]) return SendErrorMessage( playerid, "You can't do this while you're at games." );
	if( tdm_player_info[ playerid ][ tdm_Team ] != -1 ) return SendErrorMessage( playerid, "You can't do this while you're at CS:TDM." );

	new vehicleid, found, engine, lights, alarm, doors, bonnet, boot, objective;
	for(new i = GetVehiclePoolSize(); i > 0; i--) {
		new Float:X, Float:Y, Float:Z;
		GetVehiclePos(i, X, Y, Z);
		if( IsPlayerInRangeOfPoint( playerid, 5.0, X, Y, Z) && GetVehicleVirtualWorld(i) == GetPlayerVirtualWorld(playerid)) {
			vehicleid = i;
			found = 1;
			break;
		}
		else
			continue;
	}
	if( found == 0 ) return SendErrorMessage( playerid, "You are not close to the vehicle.");

	new Float:vehPos[ 3 ];
	getPosBehindVehicle( vehicleid, vehPos[ 0 ], vehPos[ 1 ], vehPos[ 2 ], 0.0 );
	if( !IsPlayerInRangeOfPoint( playerid, 2, vehPos[ 0 ], vehPos[ 1 ], vehPos[ 2 ] ) ) return SendErrorMessage( playerid, "You have to be next to the trunk." );
	if(gVehicleData[ vehicleid ][ E_VEHICLE_LOCK_STATUS ] == 1) return SendErrorMessage(playerid, "Vehicle is locked. Unlock the vehicle first to open the trunk.");
	if( IsANoTrunkVehicle( vehicleid ) ) return SendErrorMessage( playerid, "This vehicle does not have a trunk!");
	if( GetPlayerState( playerid ) != PLAYER_STATE_ONFOOT ) return SendErrorMessage( playerid, "You must be on your feet to close / open the trunk.");
	if( IsVehicleBajs( vehicleid ) || IsVehicleMotor( vehicleid ) || IsVehicleBrod( vehicleid ) ) {
		SendErrorMessage( playerid, "This vehicle has no trunk.");
		return 1;
	}
	
	if( gVehicleData[ vehicleid ][ E_VEHICLE_DB_ID ] == 0 ) return SendErrorMessage( playerid, "This vehicle was not created correctly, if you think it is a mistake contact the Admin team." );
	
	GetVehicleParamsEx( vehicleid, engine, lights, alarm, doors, bonnet, boot, objective );
	if( boot == 0 ) {
		SetVehicleParamsEx( vehicleid, engine, lights, alarm, doors, bonnet, 1, objective );
		format( globalstring, sizeof( globalstring ), "* %s opens the trunk of their %s.", PlayerMaskedName( playerid ), GetVehicleNameEx( GetVehicleModel( vehicleid ) ) );
		RangeMessage(20.0 , playerid, globalstring );
	} else {
		SetVehicleParamsEx( vehicleid, engine, lights, alarm, doors, bonnet, 0, objective );
		format( globalstring, sizeof( globalstring ), "* %s closes the trunk of their %s.", PlayerMaskedName( playerid ), GetVehicleNameEx( GetVehicleModel( vehicleid ) ) );
		RangeMessage(20.0 , playerid, globalstring );
	}
	return 1;
}
CMD:trunkstore(playerid, params[])
{
	if(inPUBG[ playerid ] != 0) return SendErrorMessage(playerid, "You cannot while you are at event.");
	if(dsys_info[ playerid ][ ds_b_w ]==true) return SendErrorMessage(playerid, "You cannot use this command right now.");
	if( WARPInfo[ playerid ][ WARIgrac ] != -1 ) return SendErrorMessage( playerid, "You can't do this while you're at war." );
	if( naDeagle[ playerid ] > 0 ) return SendErrorMessage( playerid, "You can't while you're at an event." );
	if( NaDmEventu[ playerid ] == true || inDerby[playerid] || inFall[playerid]) return SendErrorMessage( playerid, "You can't do this while you're at games." );
	if( tdm_player_info[ playerid ][ tdm_Team ] != -1 ) return SendErrorMessage( playerid, "You can't do this while you're at CS:TDM." );

	new vehicleid, found;
	new engine, lights, alarm, doors, bonnet, boot, objective;
	for(new i = GetVehiclePoolSize(); i > 0; i--) {
		new Float:X, Float:Y, Float:Z;
		GetVehiclePos(i, X, Y, Z);
		if( IsPlayerInRangeOfPoint( playerid, 5.0, X, Y, Z) && GetVehicleVirtualWorld(i) == GetPlayerVirtualWorld(playerid)) {
			vehicleid = i;
			found = 1;
			break;
		}
		else
			continue;
	}
	if( found == 0 ) return SendErrorMessage( playerid, "You are not close to the vehicle.");

	new Float:vehPos[ 3 ];
	getPosBehindVehicle( vehicleid, vehPos[ 0 ], vehPos[ 1 ], vehPos[ 2 ], 0.0 );
	if( !IsPlayerInRangeOfPoint( playerid, 2, vehPos[ 0 ], vehPos[ 1 ], vehPos[ 2 ] ) ) return SendErrorMessage( playerid, "You have to be next to the trunk." );

	if( IsANoTrunkVehicle( vehicleid ) ) return SendErrorMessage( playerid, "This vehicle does not have a trunk!");
	if( GetPlayerState( playerid ) != PLAYER_STATE_ONFOOT ) return SendErrorMessage( playerid, "You must be on your feet to close / open the trunk.");
	if( IsVehicleBajs( vehicleid ) || IsVehicleMotor( vehicleid ) || IsVehicleBrod( vehicleid ) ) {
		SendErrorMessage( playerid, "This vehicle has no trunk.");
		return 1;
	}
	GetVehicleParamsEx( vehicleid, engine, lights, alarm, doors, bonnet, boot, objective );
	if( boot == 0 ) return SendErrorMessage(playerid, "Vehicle's trunk is closed.");
	if( gVehicleData[ vehicleid ][ E_VEHICLE_DB_ID ] == 0 ) return SendErrorMessage( playerid, "This vehicle was not created correctly, if you think it is a mistake contact the Admin team." );

	new amount, item[32];
	if( sscanf(params, "is[32]", amount, item) ) {
		SendUsageMessage( playerid, "/trunkstore [amount] [item]");
		return 1;
	}
	item[0] = toupper(item[0]);
	new gunid = -1;
	for( new z = 0; z < 47; z++ ) {
		if( strfind( WeaponInfos[ z ][ wName ], item, true ) != -1 ) {
			if( WARPInfo[ playerid ][ WARIgrac ] != -1 ) return SendErrorMessage( playerid, "You cannot do that while at war." );
			if( naDeagle[ playerid ] > 0 ) return SendErrorMessage( playerid, "You cannot do that while at deagle event." );
		   	if( tdm_player_info[ playerid ][ tdm_Team ] != -1 ) return SendErrorMessage( playerid, "You cannot do that in CS:TDM." );
		    if( NaDmEventu[ playerid ] == true || inDerby[playerid] || inFall[playerid]) return SendErrorMessage( playerid, "You cannot do that in games." );
			if( IsPlayerInAnyVehicle( playerid ) ) return SendErrorMessage( playerid, "You cannot do that while in a vehicle." );
		    if( ForbiddenWeap( playerid ) ) return SendErrorMessage( playerid, "Specified weapon is forbidden." );
		    if(IsPlayerOnLawDuty(playerid)) return SendErrorMessage(playerid, "You cannot store weapons while on duty.");
		    gunid=z;
		    if(GetPlayerWeapon(playerid) != gunid) return SendErrorMessage(playerid, "You don't have specified weapon in your hand.");
		    if( gunid == 41 ) return SendErrorMessage( playerid, "You cannot store that." );
		    if(!IsValidServerWeapon( playerid, gunid )) return SendErrorMessage(playerid, "You don't have a valid server weapon in hand.");
		 	if(!IsStoreableWeapon(playerid, gunid)) return SendErrorMessage(playerid, "Weapons received from counter strike cannot be stored.");

			if( gunid >= 35 && gunid <= 40 ) {
			    SendErrorMessage( playerid, "You cannot store %s.", WeaponInfos[ gunid ][ wName ] );
			    return 1;
			}

			if( gunid < 1 ) {
			    SendErrorMessage( playerid, "You don't have a weapon in your hand." );
			    return 1;
			}
			if(amount < 0) return SendErrorMessage(playerid, "Invalid amount specified.");
			if(amount == 0) amount = AC_GetPlayerAmmo(playerid);
			new checkammo = AC_GetPlayerAmmo(playerid);
			if(checkammo < amount) return SendErrorMessage(playerid, "You don't have that much ammo for your weapon.");
			//RemovePlayerWeapon( playerid, GetWeapon( playerid ));
			//GiveWeaponToPlayer(playerid, gunid, checkammo-amount);
			if(checkammo == amount)
				RemovePlayerWeapon( playerid, GetWeapon( playerid ) );
			else
				SetWeaponAmmo( playerid, gunid, checkammo-amount );
			VehicleInventory_Add(vehicleid, WeaponInfos[ gunid ][ wName ], WeaponInfos[ gunid ][ wModel ], amount );
			format(globalstring, sizeof(globalstring), "You stored %s (%d) in your vehicles trunk.",  WeaponInfos[ gunid ][ wName ], amount);
			SCM(playerid,sales2, globalstring);


			format( globalstring, sizeof( globalstring ), "* %s stores weapons in the trunk of %s.", PlayerMaskedName( playerid ), GetVehicleNameEx( GetVehicleModel( vehicleid ) ) );
			RangeMessage( 15.0, playerid, globalstring );

			format(globalstring, sizeof(globalstring), "%s stored %s (%d) in %s (%d).", PlayerName(playerid),  WeaponInfos[ gunid ][ wName ], amount, GetVehicleNameEx( GetVehicleModel( vehicleid )), gVehicleData[vehicleid][ E_VEHICLE_DB_ID ]);
			LogSave( "Ostalo/VehicleStore.log", globalstring );
			return 1;
		}
	}
	if( !Inventory_HasItem( playerid, item ) ) return SendErrorMessage( playerid, "You don't have specified item in your inventory!");
	if(amount < 0) return SendErrorMessage(playerid, "Invalid amount specified.");
	if(amount == 0) amount = Inventory_Count( playerid, item );
	if( ( Inventory_Count( playerid, item ) ) < amount ) return SendErrorMessage( playerid, "You don't that much of specified item in your inventory!" );
	new model = GetItemModel( item );
	VehicleInventory_Add( vehicleid, item, model, amount );
	format(globalstring, sizeof(globalstring), "You stored %s (%d) in vehicle's trunk.", item, amount);
	SCM(playerid,sales2, globalstring);
	Inventory_Remove(playerid, item, amount);
	format( globalstring, sizeof( globalstring ), "* %s stored something in the trunk of %s.", PlayerMaskedName( playerid ), GetVehicleNameEx( GetVehicleModel( vehicleid ) ) );
	RangeMessage(20.0 , playerid, globalstring );

	format(globalstring, sizeof(globalstring), "%s stored %s (%d) in %s (%d).", PlayerName(playerid),  item, amount, GetVehicleNameEx( GetVehicleModel( vehicleid )), gVehicleData[vehicleid][ E_VEHICLE_DB_ID ]);
	LogSave( "Ostalo/VehicleStore.log", globalstring );
	return 1;
}
CMD:trunkload(playerid, params[])
{
	if(inPUBG[ playerid ] != 0) return SendErrorMessage(playerid, "You cannot while you are at event.");
	if(dsys_info[ playerid ][ ds_b_w ]==true) return SendErrorMessage(playerid, "You cannot use this command right now.");
	if( WARPInfo[ playerid ][ WARIgrac ] != -1 ) return SendErrorMessage( playerid, "You can't do this while you're at war." );
	if( naDeagle[ playerid ] > 0 ) return SendErrorMessage( playerid, "You can't while you're at an event." );
	if( NaDmEventu[ playerid ] == true || inDerby[playerid] || inFall[playerid]) return SendErrorMessage( playerid, "You can't do this while you're at games." );
	if( tdm_player_info[ playerid ][ tdm_Team ] != -1 ) return SendErrorMessage( playerid, "You can't do this while you're at a tdm event." );

	new vehicleid, found;
	for(new i = GetVehiclePoolSize(); i > 0; i--) {
		new Float:X, Float:Y, Float:Z;
		GetVehiclePos(i, X, Y, Z);
		if( IsPlayerInRangeOfPoint( playerid, 5.0, X, Y, Z) && GetVehicleVirtualWorld(i) == GetPlayerVirtualWorld(playerid)) {
			vehicleid = i;
			found = 1;
			break;
		}
		else
			continue;
	}
	if( found == 0 ) return SendErrorMessage( playerid, "You are not close to the vehicle.");

	new Float:vehPos[ 3 ];
	getPosBehindVehicle( vehicleid, vehPos[ 0 ], vehPos[ 1 ], vehPos[ 2 ], 0.0 );
	if( !IsPlayerInRangeOfPoint( playerid, 2, vehPos[ 0 ], vehPos[ 1 ], vehPos[ 2 ] ) ) return SendErrorMessage( playerid, "You have to be next to the trunk." );

	if( IsANoTrunkVehicle( vehicleid ) ) return SendErrorMessage( playerid, "This vehicle does not have a trunk!");
	if( GetPlayerState( playerid ) != PLAYER_STATE_ONFOOT ) return SendErrorMessage( playerid, "You must be on your feet to close / open the trunk.");
	if( IsVehicleBajs( vehicleid ) || IsVehicleMotor( vehicleid ) || IsVehicleBrod( vehicleid ) ) {
		SendErrorMessage( playerid, "This vehicle has no trunk.");
		return 1;
	}
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx( vehicleid, engine, lights, alarm, doors, bonnet, boot, objective );
	if( boot == 0 ) return SendErrorMessage(playerid, "Vehicle's trunk is closed.");
	if( gVehicleData[ vehicleid ][ E_VEHICLE_DB_ID ] == 0 ) return SendErrorMessage( playerid, "This vehicle was not created correctly, if you think it is a mistake contact the Admin team." );

	new amount, item[32];
	if( sscanf(params, "is[32]", amount, item) ) {
		SendUsageMessage( playerid, "/trunkload [amount] [item]");
		return 1;
	}
	item[0] = toupper(item[0]);
	new gunid = -1;
	for( new z = 0; z < 47; z++ ) {
		if( strfind( WeaponInfos[ z ][ wName ], item, true ) != -1 ) {
			if( WARPInfo[ playerid ][ WARIgrac ] != -1 ) return SendErrorMessage( playerid, "You cannot do that while at war." );
			if( naDeagle[ playerid ] > 0 ) return SendErrorMessage( playerid, "You cannot do that while at deagle event." );
		   	if( tdm_player_info[ playerid ][ tdm_Team ] != -1 ) return SendErrorMessage( playerid, "You cannot do that in TDM event." );
		    if( NaDmEventu[ playerid ] == true || inDerby[playerid] || inFall[playerid]) return SendErrorMessage( playerid, "You cannot do that in games." );
			if( IsPlayerInAnyVehicle( playerid ) ) return SendErrorMessage( playerid, "You cannot do that while in a vehicle." );
		    gunid=z;
		    if( !VehicleInventory_HasItem( vehicleid, WeaponInfos[ z ][ wName ] ) ) return SendErrorMessage( playerid, "There's no such item in the storage!");
		    if(amount < 0) return SendErrorMessage(playerid, "Invalid amount specified.");
		    if(amount == 0) amount = VehicleInventory_Count( vehicleid, WeaponInfos[ z ][ wName ] );
			if( ( VehicleInventory_Count( vehicleid, WeaponInfos[ z ][ wName ] ) ) < amount ) return SendErrorMessage( playerid, "Specified amount exceed the amount in the house storage!" );
			GiveWeaponToPlayer(playerid, gunid, amount);
			VehicleInventory_Remove(vehicleid, WeaponInfos[ z ][ wName ], amount);
			format(globalstring, sizeof(globalstring), "You took %s (%d) from vehicle's trunk.",  WeaponInfos[ gunid ][ wName ], amount);
			SCM(playerid,sales2, globalstring);

			format( globalstring, sizeof( globalstring ), "* %s takes a(n) %s from the trunk of %s.", PlayerMaskedName( playerid ), WeaponInfos[ gunid ][ wName ], GetVehicleNameEx( GetVehicleModel( vehicleid ) ) );
			RangeMessage( 15.0, playerid, globalstring );

			format(globalstring, sizeof(globalstring), "%s loaded %s (%d) from %s (%d).", PlayerName(playerid),  WeaponInfos[ gunid ][ wName ], amount, GetVehicleNameEx( GetVehicleModel( vehicleid )), gVehicleData[vehicleid][ E_VEHICLE_DB_ID ]);
			LogSave( "Ostalo/VehicleLoad.log", globalstring );
			return 1;
		}
	}
	if( !VehicleInventory_HasItem( vehicleid, item ) ) return SendErrorMessage( playerid, "There's no such item in the trunk!");
	if(amount < 0) return SendErrorMessage(playerid, "Invalid amount specified.");
	if(amount == 0) amount = VehicleInventory_Count( vehicleid, item );
	if( ( VehicleInventory_Count( vehicleid, item ) ) < amount ) return SendErrorMessage( playerid, "Specified amount exceed the amount in the trunk!" );
	new model = GetItemModel( item );
	PlayerInventoryAdd( playerid, item, model, amount );
	format(globalstring, sizeof(globalstring), "You took %s (%d) from vehicle's trunk.", item, amount);
	SCM(playerid,sales2, globalstring);
	VehicleInventory_Remove(vehicleid, item, amount);
	format( globalstring, sizeof( globalstring ), "* %s took something from the trunk of %s.", PlayerMaskedName( playerid ), GetVehicleNameEx( GetVehicleModel( vehicleid ) ) );
	RangeMessage(20.0 , playerid, globalstring );

	format(globalstring, sizeof(globalstring), "%s loaded %s (%d) from %s (%d).", PlayerName(playerid),  item, amount, GetVehicleNameEx( GetVehicleModel( vehicleid )), gVehicleData[vehicleid][ E_VEHICLE_DB_ID ]);
	LogSave( "Ostalo/VehicleLoad.log", globalstring );
	return 1;
}
CMD:trunkitems(playerid, params[])
{
	if(inPUBG[ playerid ] != 0) return SendErrorMessage(playerid, "You cannot while you are at event.");
	if( WARPInfo[ playerid ][ WARIgrac ] != -1 ) return SendErrorMessage( playerid, "You can't do this while you're at war." );
	if( naDeagle[ playerid ] > 0 ) return SendErrorMessage( playerid, "You can't while you're at an event." );
	if( NaDmEventu[ playerid ] == true || inDerby[playerid] || inFall[playerid]) return SendErrorMessage( playerid, "You can't do this while you're at games." );
	if( tdm_player_info[ playerid ][ tdm_Team ] != -1 ) return SendErrorMessage( playerid, "You can't do this while you are at CS:TDM." );

	new vehicleid, found;
	for(new i = GetVehiclePoolSize(); i > 0; i--) {
		new Float:X, Float:Y, Float:Z;
		GetVehiclePos(i, X, Y, Z);
		if( IsPlayerInRangeOfPoint( playerid, 5.0, X, Y, Z) && GetVehicleVirtualWorld(i) == GetPlayerVirtualWorld(playerid)) {
			vehicleid = i;
			found = 1;
			break;
		}
		else
			continue;
	}
	if( found == 0 ) return SendErrorMessage( playerid, "You are not close to the vehicle.");

	new Float:vehPos[ 3 ];
	getPosBehindVehicle( vehicleid, vehPos[ 0 ], vehPos[ 1 ], vehPos[ 2 ], 0.0 );
	if( !IsPlayerInRangeOfPoint( playerid, 2, vehPos[ 0 ], vehPos[ 1 ], vehPos[ 2 ] ) ) return SendErrorMessage( playerid, "You have to be next to the trunk." );
	if( IsANoTrunkVehicle( vehicleid ) ) return SendErrorMessage( playerid, "This vehicle does not have a trunk!");
	if( GetPlayerState( playerid ) != PLAYER_STATE_ONFOOT ) return SendErrorMessage( playerid, "You must be on your feet to close / open the trunk.");
	if( IsVehicleBajs( vehicleid ) || IsVehicleMotor( vehicleid ) || IsVehicleBrod( vehicleid ) ) {
		SendErrorMessage( playerid, "This vehicle has no trunk.");
		return 1;
	}
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx( vehicleid, engine, lights, alarm, doors, bonnet, boot, objective );
	if( boot == 0 ) return SendErrorMessage(playerid, "Vehicle's trunk is closed.");
	if( gVehicleData[ vehicleid ][ E_VEHICLE_DB_ID ] == 0 ) return SendErrorMessage( playerid, "This vehicle was not created correctly, if you think it is a mistake contact the Admin team." );

	new str[3000] = "Item\tQuantity";
	new count = 0;
	for( new i = 0; i != MAX_INVENTORY; i++ ) 
	{
		if( vinventoryInfo[ vehicleid ][ i ][ invExists ] ) 
		{
			format(str, sizeof(str) , "%s\n%s\t%d\n", str, vinventoryInfo[ vehicleid ][ i ][ invItem ], vinventoryInfo[ vehicleid ][ i ][ invQuantity ]);
			count++;
		}
	}
	if(count == 0) return SendErrorMessage(playerid, "There's nothing in the storage.");
	new header[32];
	format(header, 32, "Items {FCCA11}(%d/100)", count);
	SPD(playerid, dialog_NEWINV, DIALOG_STYLE_TABLIST_HEADERS, header, str, "Close","");
	return 1;
}