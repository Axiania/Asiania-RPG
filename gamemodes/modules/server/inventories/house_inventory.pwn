forward OnHouseInventoryLoad( houseid );
public OnHouseInventoryLoad( houseid ) {

	new rows, fields;
	cache_get_data( rows, fields, _dbConnector );

	if( !rows ) {

		new query[ 128 ];

		format( query, sizeof( query ),
			"INSERT INTO `house_inv` (house_id) VALUES('%d')", gPropertyInfo[ houseid ][ ibaseID ] );

		mysql_pquery( _dbConnector, query, "", "" );
	}
	else {

		new textic[ 64 ];
		for( new i = 0; i < MAX_INVENTORY; i++ ) {
		
			format( textic, sizeof( textic ), "inv_slot_model_%d", i+1 );
			hinventoryInfo[ houseid ][ i ][ invModel ] = cache_get_field_content_int(0, textic );
			format( textic, sizeof( textic ), "inv_slot_quantity_%d", i+1 ); 
			hinventoryInfo[ houseid ][ i ][ invQuantity ] = cache_get_field_content_int(0, textic );
			format( textic, sizeof( textic ), "inv_slot_color_%d", i+1 );
			hinventoryInfo[ houseid ][ i ][ invColor ] = cache_get_field_content_int(0, textic );
			format( textic, sizeof( textic ), "inv_slot_robbed_%d", i+1 );
			hinventoryInfo[ houseid ][ i ][ invRobbed ] = cache_get_field_content_int(0, textic );
			
			if( hinventoryInfo[ houseid ][ i ][ invModel ] != 0 && hinventoryInfo[ houseid ][ i ][ invQuantity ] != 0 ) {
				hinventoryInfo[ houseid ][ i ][ invExists ] = true;
				
				if( hinventoryInfo[ houseid ][ i ][ invModel ] >= 321 && hinventoryInfo[ houseid ][ i ][ invModel ] <= 372 && hinventoryInfo[ houseid ][ i ][ invModel ] != 365 ) {
				
					for( new z = 0; z < 47; z++ ) {
					
						if( WeaponInfos[ z ][ wModel ] == hinventoryInfo[ houseid ][ i ][ invModel ] ) {
						
							strmid( hinventoryInfo[ houseid ][ i ][ invItem ], WeaponInfos[ z ][ wName ], 0, strlen( WeaponInfos[ z ][ wName ] ), 32 );
							break;
						}
					}
				}
				else {
				
					for( new j = 0; j < MAX_ITEMS; j++ ) {
						if( hinventoryInfo[ houseid ][ i ][ invModel ] == inv_obj_inf[ j ][ i_o_i_model ] ) {
							strmid( hinventoryInfo[ houseid ][ i ][ invItem ], inv_obj_inf[ j ][ i_o_i_name ], 0, strlen( inv_obj_inf[ j ][ i_o_i_name ] ), 32 );
							break;
						}
					}
				}
			}
		}
	}
	return (true);
}
stock sql_hinventory_update_quantity( houseid, itemid ) {

	new q[ 256 ];
	mysql_format( _dbConnector, q, sizeof(q), "UPDATE `house_inv` SET `inv_slot_quantity_%d` = '%d' WHERE `house_id` = '%d'", (itemid+1), hinventoryInfo[ houseid ][ itemid ][ invQuantity ], gPropertyInfo [houseid ][ ibaseID ] );
	mysql_tquery( _dbConnector, q, "", "");

	return true;
}
stock sql_hinventory_update_robbed( houseid, itemid ) {

	new q[ 256 ];
	mysql_format( _dbConnector, q, sizeof(q), "UPDATE `house_inv` SET `inv_slot_robbed_%d` = '%d' WHERE `house_id` = '%d'", (itemid+1), hinventoryInfo[ houseid ][ itemid ][ invRobbed ], gPropertyInfo [houseid ][ ibaseID ] );
	mysql_tquery( _dbConnector, q, "", "");

	return true;
}
stock sql_hinventory_update_mq( houseid, itemid ) { 

	new q[ 256 ];
	mysql_format( _dbConnector, q, sizeof(q), "UPDATE `house_inv` SET `inv_slot_model_%d` = '%d', `inv_slot_quantity_%d` = '%d', `inv_slot_color_%d` = '%d' WHERE `house_id` = '%d'",
		(itemid+1),
		hinventoryInfo[ houseid ][ itemid ][ invModel ],
		(itemid+1),
		hinventoryInfo[ houseid ][ itemid ][ invQuantity ],
		(itemid+1),
		hinventoryInfo[ houseid ][ itemid ][ invColor ],
		gPropertyInfo [houseid ][ ibaseID ] );
		
	mysql_pquery( _dbConnector, q, "", "");

	return true;
}

stock sql_hinventory_remove_item( houseid, itemid ) {

	new q[ 256 ];
	mysql_format( _dbConnector, q, sizeof(q), "UPDATE `house_inv` SET `inv_slot_model_%d` = '0', `inv_slot_quantity_%d` = '0' WHERE `house_id` = '%d'",
		(itemid+1),
		(itemid+1),
		gPropertyInfo [houseid ][ ibaseID ] );

	mysql_tquery( _dbConnector, q, "", "");

	return true;
}
stock ResetHouseInventory(houseid)
{
	for( new x = 0; x < MAX_INVENTORY; x++ ) {
		hinventoryInfo[ houseid ][ x ][ invExists ] = false;
		hinventoryInfo[ houseid ][ x ][ invModel ] = hinventoryInfo[ houseid ][ x ][ invQuantity ] = 0;
		strmid( hinventoryInfo[ houseid ][ x ][ invItem ], "None", 0, strlen( "None" ), 32 );
		hinventoryInfo[ houseid ][ x ][ invColor ] = -1;
	}
	return 1;
}
stock ResetGroupInventory(OrgID)
{
	for( new x = 0; x < MAX_INVENTORY; x++ ) {
		gInventoryInfo[ OrgID ][ x ][ invExists ] = false;
		gInventoryInfo[ OrgID ][ x ][ invModel ] = gInventoryInfo[ OrgID ][ x ][ invQuantity ] = 0;
		strmid( gInventoryInfo[ OrgID ][ x ][ invItem ], "None", 0, strlen( "None" ), 32 );
		gInventoryInfo[ OrgID ][ x ][ invColor ] = -1;
	}
	return 1;
}
stock HouseInventory_Add( houseid, item[], model, quantity = 1 ) {
	new itemid = HouseInventory_GetItemID( houseid, item );
	if(itemid == -1){
		item[0] = toupper(item[0]);
		itemid = HouseInventory_GetFreeID( houseid );
		if( itemid != -1 ) {
			hinventoryInfo[ houseid ][ itemid ][ invExists ] = true;
			hinventoryInfo[ houseid ][ itemid ][ invModel ] = model;
			hinventoryInfo[ houseid ][ itemid ][ invQuantity ] = quantity;
			strmid( hinventoryInfo[ houseid ][ itemid ][ invItem ], item, 0, strlen( item ), 32 );
			sql_hinventory_update_mq( houseid, itemid );
		}
	}
	else
	{
		hinventoryInfo[ houseid ][ itemid ][ invQuantity ] += quantity;
	}
	sql_hinventory_update_quantity( houseid, itemid );
	return 1;
}
stock HouseInventory_GetItemID( houseid, item[] )
{
	for( new i = 0; i < MAX_INVENTORY; i++ ) {
		if( !hinventoryInfo[ houseid ][ i ][ invExists ] )
			continue;

		if( !strcmp( hinventoryInfo[ houseid ][ i ][ invItem ], item , true) ) return i;
	}
	return -1;
}
stock HouseInventory_GetItemModel( houseid, item[] )
{
	for( new i = 0; i < MAX_INVENTORY; i++ ) {
		if( !hinventoryInfo[ houseid ][ i ][ invExists ] )
			continue;

		if( !strcmp( hinventoryInfo[ houseid ][ i ][ invItem ], item, true ) ) return hinventoryInfo[ houseid ][ i ][ invModel ];
	}
	return -1;
}

stock HouseInventory_GetFreeID( houseid ) {
	if( HouseInventory_Items( houseid ) >= 100 )
		return -1;

	for( new i = 0; i < MAX_INVENTORY; i++ ) {
		if( !hinventoryInfo[ houseid ][ i ][ invExists ] )
			return i;
	}
	return -1;
}

stock HouseInventory_Items( houseid ) {
	new count;

	for( new i = 0; i != MAX_INVENTORY; i++ ) if( hinventoryInfo[ houseid ][ i ][ invExists ] ) {
		count++;
	}
	return count;
}

stock HouseInventory_Count( houseid, item[] ) {
	new itemid = HouseInventory_GetItemID( houseid, item );

	if( itemid != -1 )
		return hinventoryInfo[ houseid ][ itemid ][ invQuantity ];

	return false;
}

stock HouseInventory_HasItem( houseid, item[] ) {
	return ( HouseInventory_GetItemID( houseid, item ) != -1 );
}

stock HouseInventory_SetQuantity( houseid, item[], quantity ) {
	new
		itemid = HouseInventory_GetItemID( houseid, item ),
		string[ 128 ];

	if( itemid != -1 ) {
		hinventoryInfo[ houseid ][ itemid ][ invQuantity ] = quantity;
		
		sql_hinventory_update_quantity( houseid, itemid );
	}
	return true;
}

stock HouseInventory_Remove( houseid, item[], quantity = 1 ) {
	new
		itemid = HouseInventory_GetItemID( houseid, item );

	if( itemid != -1 ) {
	
		if( hinventoryInfo[ houseid ][ itemid ][ invQuantity ] > (quantity-1) ) {
			hinventoryInfo[ houseid ][ itemid ][ invQuantity ] -= quantity;
		}
		else return false;
		
		if( quantity == -1 || hinventoryInfo[ houseid ][ itemid ][ invQuantity ] < 1 ) {
			hinventoryInfo[ houseid ][ itemid ][ invExists ] = false;
			hinventoryInfo[ houseid ][ itemid ][ invModel ] = 0;
			hinventoryInfo[ houseid ][ itemid ][ invQuantity ] = 0;
			strmid( hinventoryInfo[ houseid ][ itemid ][ invItem ], "None", 0, strlen( "None" ), 32 );
			hinventoryInfo[ houseid ][ itemid ][ invColor ] = -1;

			sql_hinventory_remove_item( houseid, itemid );
		}
		else if( quantity != -1 && hinventoryInfo[ houseid ][ itemid ][ invQuantity ] > 0 ) { 
			
			sql_hinventory_update_quantity( houseid, itemid );
		}
		return true;
	}
	return false;
}

stock HouseInventory_Remove_2( houseid, itemid, quantity = 1 ) {

	if( itemid != -1 ) {
	
		if( hinventoryInfo[ houseid ][ itemid ][ invQuantity ] > 0 ) {
			hinventoryInfo[ houseid ][ itemid ][ invQuantity ] -= quantity;
		}
		else return false;

		if( quantity == -1 || hinventoryInfo[ houseid ][ itemid ][ invQuantity ] < 1 ) {
			hinventoryInfo[ houseid ][ itemid ][ invExists ] = false;
			hinventoryInfo[ houseid ][ itemid ][ invModel ] = 0;
			hinventoryInfo[ houseid ][ itemid ][ invQuantity ] = 0;
			strmid( hinventoryInfo[ houseid ][ itemid ][ invItem ], "None", 0, strlen( "None" ), 32 );
			hinventoryInfo[ houseid ][ itemid ][ invColor ] = -1;
			sql_hinventory_remove_item( houseid, itemid );
		}
		else if( quantity != -1 && hinventoryInfo[ houseid ][ itemid ][ invQuantity ] > 0 ) {

			sql_hinventory_update_quantity( houseid, itemid );
		}
		return true;
	}
	return false;
}


stock HouseInventory_Set( houseid, item[], model, amount ) {
	new itemid = HouseInventory_GetItemID( houseid, item );

	if( itemid == -1 && amount > 0 )
		HouseInventory_Add( houseid, item, model, amount );

	else if( amount > 0 && itemid != -1 )
		HouseInventory_SetQuantity( houseid, item, amount );

	else if( amount < 1 && itemid != -1 )
		HouseInventory_Remove( houseid, item, -1 );

	return true;
}

CMD:store(playerid, params[])
{
	if (inPUBG[ playerid ] != 0) return SendErrorMessage(playerid, "You cannot while you are at event.");
	if (dsys_info[ playerid ][ ds_b_w ]==true) return SendErrorMessage(playerid, "You cannot use this command right now.");
	if (inProperty[playerid] != -1)
	{
		new houseid = inProperty[ playerid ];
		if( houseid == -1 ) 
		{
			SendErrorMessage( playerid, "You are not in any property." );
			return 1;
		}
		if (GetPlayerVirtualWorld(playerid) != gPropertyInfo[houseid][iVW]) return SendErrorMessage( playerid, "You are not in any property." );
		if (gPropertyInfo [houseid ][ iOwnerbaseID ] == gPlayerData[playerid][E_PLAYER_ID]) {}
		else if (gPlayerData[playerid][E_PLAYER_PROPERTY_KEY_1] == gPropertyInfo[houseid][ibaseID]  ) { }
		else if (gPlayerData[playerid][E_PLAYER_PROPERTY_KEY_2] == gPropertyInfo[houseid][ibaseID]  ) { }
		else if (gPlayerData[playerid][E_PLAYER_PROPERTY_KEY_3] == gPropertyInfo[houseid][ibaseID]  ) { }
		else if (gPlayerData[playerid][E_PLAYER_PROPERTY_KEY_4] == gPropertyInfo[houseid][ibaseID]  ) { }
		else if (gPlayerData[playerid][E_PLAYER_PROPERTY_KEY_5] == gPropertyInfo[houseid][ibaseID]  ) { }
		else return SendErrorMessage( playerid, "You cannot use this command in property because it is not yours or you don't have keys to it." );

		new amount, item[32];
		if( sscanf(params, "is[32]", amount, item) ) {
			SendUsageMessage( playerid, "/store [amount] [item]");
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
			    if( ForbiddenWeap( playerid ) ) return SendErrorMessage( playerid, "Specified weapon is forbidden." );
			    if(IsPlayerOnLawDuty(playerid)) return SendErrorMessage(playerid, "You cannot store weapons while on duty.");
			    gunid=z;
			    if(GetPlayerWeapon(playerid) != gunid) return SendErrorMessage(playerid, "You don't have specified weapon in your hand.");
			    if(!IsValidServerWeapon( playerid, gunid )) return SendErrorMessage(playerid, "You don't have a valid server weapon in hand.");
			    if(!IsStoreableWeapon(playerid, gunid)) return SendErrorMessage(playerid, "Weapons received from counter strike cannot be stored.");

			    if( gunid == 41 ) return SendErrorMessage( playerid, "You cannot store that." );
				if( gunid >= 36 && gunid <= 40 ) {
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
				HouseInventory_Add(houseid, WeaponInfos[ gunid ][ wName ], WeaponInfos[ gunid ][ wModel ], amount );
				format(globalstring, sizeof(globalstring), "You stored %s (%d) in your property.",  WeaponInfos[ gunid ][ wName ], amount);
				SCM(playerid,sales2, globalstring);

				format(globalstring, sizeof(globalstring), "%s stored %s (%d) in property %d.", PlayerName(playerid),  WeaponInfos[ gunid ][ wName ], amount, houseid);
				LogSave( "Ostalo/PropertyStore.log", globalstring );
				return 1;
			}
		}
		if( !Inventory_HasItem( playerid, item ) ) return SendErrorMessage( playerid, "You don't have specified item in your inventory!");
		if(amount < 0) return SendErrorMessage(playerid, "Invalid amount specified.");
		if(amount == 0) amount = Inventory_Count( playerid, item );
		if( ( Inventory_Count( playerid, item ) ) < amount ) return SendErrorMessage( playerid, "You don't that much of specified item in your inventory!" );
		new model = GetItemModel( item );
		HouseInventory_Add( houseid, item, model, amount );
		format(globalstring, sizeof(globalstring), "You stored %s (%d) in your property.", item, amount);
		SCM(playerid,sales2, globalstring);

		format(globalstring, sizeof(globalstring), "%s stored %s (%d) in property %d.", PlayerName(playerid),  item, amount, houseid);
		LogSave( "Ostalo/PropertyStore.log", globalstring );
		Inventory_Remove(playerid, item, amount);
	}
	else if( IsPlayerInGroup(playerid, inOrgInt[ playerid ]))
	{
		new hid = inOrgInt[ playerid ];
		if(hid < 1) return SendErrorMessage(playerid, "You are not in a group HQ.");
		if(GetPlayerVirtualWorld(playerid) != org_info[ hid ][ oVw ]) return SendErrorMessage(playerid, "You are not in a group HQ.");
		if(!HasPermission(GetPlayerGroupRank(hid,playerid), hid, GROUP_STORE_PERM)) return SendErrorMessage(playerid, "You don't have permission to access group storage.");
		new amount, item[32];
		if( sscanf(params, "is[32]", amount, item) ) {
			SendUsageMessage( playerid, "/store [amount] [item]");
			return 1;
		}
		item[0] = toupper(item[0]);
		new gunid = -1;
		for( new z = 0; z < 47; z++ ) {
			if( strfind( WeaponInfos[ z ][ wName ], item, true ) != -1 ) {
				if( WARPInfo[ playerid ][ WARIgrac ] != -1 ) return SendErrorMessage( playerid, "You cannot do that while at war." );
				if( naDeagle[ playerid ] > 0 ) return SendErrorMessage( playerid, "You cannot do that while at deagle event." );
			   	if( tdm_player_info[ playerid ][ tdm_Team ] != -1) return SendErrorMessage( playerid, "You cannot do that in TDM event." );
			    if( NaDmEventu[ playerid ] == true || inDerby[playerid] || inFall[playerid]) return SendErrorMessage( playerid, "You cannot do that in games." );
				if( IsPlayerInAnyVehicle( playerid ) ) return SendErrorMessage( playerid, "You cannot do that while in a vehicle." );
			    if( ForbiddenWeap( playerid ) ) return SendErrorMessage( playerid, "Specified weapon is forbidden." );
			    if(IsPlayerOnLawDuty(playerid)) return SendErrorMessage(playerid, "You cannot store weapons while on duty.");
			    gunid=z;
			    if(GetPlayerWeapon(playerid) != gunid) return SendErrorMessage(playerid, "You don't have specified weapon in your hand.");
			    if(!IsValidServerWeapon( playerid, gunid )) return SendErrorMessage(playerid, "You don't have a valid server weapon in hand.");
			    if(!IsStoreableWeapon(playerid, gunid)) return SendErrorMessage(playerid, "Weapons received from counter strike cannot be stored.");
			    if( gunid == 41 ) return SendErrorMessage( playerid, "You cannot store that." );
				if( gunid >= 36 && gunid <= 40 ) {
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
				GroupInventory_Add(hid, WeaponInfos[ gunid ][ wName ], WeaponInfos[ gunid ][ wModel ], amount );
				format(globalstring, sizeof(globalstring), "You stored %s (%d) in group storage.",  WeaponInfos[ gunid ][ wName ], amount);
				SCM(playerid,sales2, globalstring);


				format(globalstring, sizeof(globalstring), "%s stored %s (%d) in %s.", PlayerName(playerid),  WeaponInfos[ gunid ][ wName ], amount, org_info[ hid ][ oName ]);
				LogSave( "Ostalo/GroupStore.log", globalstring );
				return 1;
			}
		}
		if( !Inventory_HasItem( playerid, item ) ) return SendErrorMessage( playerid, "You don't have specified item in your inventory!");
		if(amount < 0) return SendErrorMessage(playerid, "Invalid amount specified.");
		if(amount == 0) amount = Inventory_Count( playerid, item );
		if( ( Inventory_Count( playerid, item ) ) < amount ) return SendErrorMessage( playerid, "You don't that much of specified item in your inventory!" );
		new model = GetItemModel( item );
		GroupInventory_Add( hid, item, model, amount );
		format(globalstring, sizeof(globalstring), "You stored %s (%d) in your group storage.", item, amount);
		SCM(playerid,sales2, globalstring);
		Inventory_Remove(playerid, item, amount);

		format(globalstring, sizeof(globalstring), "%s stored %s (%d) in %s.", PlayerName(playerid),  item, amount, org_info[ hid ][ oName ]);
		LogSave( "Ostalo/GroupStore.log", globalstring );

	}
	else SendErrorMessage(playerid, "You are not inside your property or group HQ.");
	return 1;
}
CMD:load(playerid, params[])
{
	if(inPUBG[ playerid ] != 0) return SendErrorMessage(playerid, "You cannot while you are at event.");
	if(dsys_info[ playerid ][ ds_b_w ]==true) return SendErrorMessage(playerid, "You cannot use this command right now.");
	if(inProperty[playerid] != -1)
	{
		new houseid = inProperty[ playerid ];
		if( houseid == -1 ) {
			SendErrorMessage( playerid, "You are not in any property." );
			return 1;
		}
		if(GetPlayerVirtualWorld(playerid) != gPropertyInfo [houseid ][ iVW ]) return SendErrorMessage( playerid, "You are not in any property." );
		new amount, item[32];
		if(gPropertyInfo [houseid ][ iOwnerbaseID ] == gPlayerData[playerid][E_PLAYER_ID]) {}
		else if( gPlayerData[ playerid ][ E_PLAYER_PROPERTY_KEY_1 ] == gPropertyInfo [houseid ][ ibaseID ]  ) { }
		else if( gPlayerData[ playerid ][ E_PLAYER_PROPERTY_KEY_2 ] == gPropertyInfo [houseid ][ ibaseID ]  ) { }
		else if( gPlayerData[ playerid ][ E_PLAYER_PROPERTY_KEY_3 ] == gPropertyInfo [houseid ][ ibaseID ]  ) { }
		else if( gPlayerData[ playerid ][ E_PLAYER_PROPERTY_KEY_4 ] == gPropertyInfo [houseid ][ ibaseID ]  ) { }
		else if( gPlayerData[ playerid ][ E_PLAYER_PROPERTY_KEY_5 ] == gPropertyInfo [houseid ][ ibaseID ]  ) { }
		else 
		{
			if(gPropertyInfo [houseid ][ iLockUpgrade ] == 1) return SendErrorMessage(playerid, "This property has reinforced safe that cannot be robbed.");
			if( sscanf(params, "s[32]", item) ) {
				SendUsageMessage( playerid, "/load [item]");
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
				    if( !HouseInventory_HasItem( houseid, WeaponInfos[ z ][ wName ] ) ) return SendErrorMessage( playerid, "There's no such item in the storage!");
				    new itemid = HouseInventory_GetItemID( houseid, item );
					if(HouseInventory_Count( houseid, WeaponInfos[ z ][ wName ] ) < 3) return SendErrorMessage(playerid, "There's too little of the item.");
					if(hinventoryInfo[ houseid ][ itemid ][ invRobbed ] > gettime()) return SendErrorMessage(playerid, "This item was recently robbed from the house.");
					amount = HouseInventory_Count( houseid, WeaponInfos[ z ][ wName ] )/3;
					amount = floatround(amount, floatround_floor);

					GiveWeaponToPlayer(playerid, gunid, amount);
					HouseInventory_Remove(houseid, WeaponInfos[ z ][ wName ], amount);
					format(globalstring, sizeof(globalstring), "You robbed %s (%d) from the property.",  WeaponInfos[ gunid ][ wName ], amount);
					SCM(playerid,sales2, globalstring);

					hinventoryInfo[ houseid ][ itemid ][ invRobbed ]= 1200 + gettime();
					sql_hinventory_update_robbed( houseid, itemid );
					format(globalstring, sizeof(globalstring), "%s robbed %s (%d) from property %d.", PlayerName(playerid),  WeaponInfos[ gunid ][ wName ], amount, houseid);
					LogSave( "Ostalo/PropertyLoad.log", globalstring );
					return 1;
				}
			}
			if( !HouseInventory_HasItem( houseid, item ) ) return SendErrorMessage( playerid, "There's no such item in the storage!");
			new itemid = HouseInventory_GetItemID( houseid, item );
			if(hinventoryInfo[ houseid ][ itemid ][ invRobbed ] > gettime()) return SendErrorMessage(playerid, "This item was recently robbed from the house.");
			if(HouseInventory_Count( houseid, item ) < 3) return SendErrorMessage(playerid, "There's too little of the item.");
			amount = HouseInventory_Count( houseid, item )/3;
			amount = floatround(amount, floatround_floor);

			new model = GetItemModel( item );
			PlayerInventoryAdd( playerid, item, model, amount );
			format(globalstring, sizeof(globalstring), "You robbed %s (%d) from the property.", item, amount);
			SCM(playerid,sales2, globalstring);
			HouseInventory_Remove(houseid, item, amount);

			hinventoryInfo[ houseid ][ itemid ][ invRobbed ]= 1200 + gettime();
			sql_hinventory_update_robbed( houseid, itemid );
			format(globalstring, sizeof(globalstring), "%s robbed %s (%d) from property %d.", PlayerName(playerid),  item, amount, houseid);
			LogSave( "Ostalo/PropertyLoad.log", globalstring );
			return 1;
		}

		if( sscanf(params, "is[32]", amount, item) ) {
			SendUsageMessage( playerid, "/load [amount] [item]");
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
			    if( !HouseInventory_HasItem( houseid, WeaponInfos[ z ][ wName ] ) ) return SendErrorMessage( playerid, "There's no such item in the storage!");
			    if(amount < 0) return SendErrorMessage(playerid, "Invalid amount specified.");
			    if(amount == 0) amount = HouseInventory_Count( houseid, WeaponInfos[ z ][ wName ] );
				if( ( HouseInventory_Count( houseid, WeaponInfos[ z ][ wName ] ) ) < amount ) return SendErrorMessage( playerid, "Specified amount exceed the amount in the house storage!" );
				GiveWeaponToPlayer(playerid, gunid, amount);
				HouseInventory_Remove(houseid, WeaponInfos[ z ][ wName ], amount);
				format(globalstring, sizeof(globalstring), "You took %s (%d) from your property.",  WeaponInfos[ gunid ][ wName ], amount);
				SCM(playerid,sales2, globalstring);

				format(globalstring, sizeof(globalstring), "%s loaded %s (%d) from property %d.", PlayerName(playerid),  WeaponInfos[ gunid ][ wName ], amount, houseid);
				LogSave( "Ostalo/PropertyLoad.log", globalstring );
				return 1;
			}
		}
		if( !HouseInventory_HasItem( houseid, item ) ) return SendErrorMessage( playerid, "There's no such item in the storage!");
		if(amount < 0) return SendErrorMessage(playerid, "Invalid amount specified.");
		if(amount == 0) amount = HouseInventory_Count( houseid, item );
		if( ( HouseInventory_Count( houseid, item ) ) < amount ) return SendErrorMessage( playerid, "Specified amount exceed the amount in the house storage!" );
		new model = GetItemModel( item );
		PlayerInventoryAdd( playerid, item, model, amount );
		format(globalstring, sizeof(globalstring), "You took %s (%d) from your property.", item, amount);
		SCM(playerid,sales2, globalstring);
		HouseInventory_Remove(houseid, item, amount);

		format(globalstring, sizeof(globalstring), "%s loaded %s (%d) from property %d.", PlayerName(playerid),  item, amount, houseid);
		LogSave( "Ostalo/PropertyLoad.log", globalstring );
	}
	else if( IsPlayerInGroup(playerid, inOrgInt[ playerid ]) )
	{
		new hid = inOrgInt[ playerid ];
		if(hid < 1) return SendErrorMessage(playerid, "You are not in a group HQ.");
		if(GetPlayerVirtualWorld(playerid) != org_info[ hid ][ oVw ]) return SendErrorMessage(playerid, "You are not in a group HQ.");
		if(!HasPermission(GetPlayerGroupRank(hid,playerid), hid, GROUP_STORE_PERM)) return SendErrorMessage(playerid, "You don't have permission to access group storage.");
		new amount, item[32];
		if( sscanf(params, "is[32]", amount, item) ) {
			SendUsageMessage( playerid, "/load [amount] [item]");
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
			    if( !GroupInventory_HasItem( hid, WeaponInfos[ z ][ wName ] ) ) return SendErrorMessage( playerid, "There's no such item in the storage!");
			    if(amount < 0) return SendErrorMessage(playerid, "Invalid amount specified.");
			    if(amount == 0) amount =  GroupInventory_Count( hid, WeaponInfos[ z ][ wName ] );
				if( ( GroupInventory_Count( hid, WeaponInfos[ z ][ wName ] ) ) < amount ) return SendErrorMessage( playerid, "Specified amount exceed the amount in the house storage!" );
				GiveWeaponToPlayer(playerid, gunid, amount);
				GroupInventory_Remove(hid, WeaponInfos[ z ][ wName ], amount);
				format(globalstring, sizeof(globalstring), "You took %s (%d) from the group storage.",  WeaponInfos[ gunid ][ wName ], amount);
				SCM(playerid,sales2, globalstring);

				format(globalstring, sizeof(globalstring), "%s loaded %s (%d) from %s.", PlayerName(playerid),  WeaponInfos[ gunid ][ wName ], amount, org_info[ hid ][ oName ]);
				LogSave( "Ostalo/GroupLoad.log", globalstring );
				return 1;
			}
		}
		if( !GroupInventory_HasItem( hid, item ) ) return SendErrorMessage( playerid, "There's no such item in the storage!");
		if(amount < 0) return SendErrorMessage(playerid, "Invalid amount specified.");
		if(amount == 0) amount = GroupInventory_Count( hid, item );
		if( ( GroupInventory_Count( hid, item ) ) < amount ) return SendErrorMessage( playerid, "Specified amount exceed the amount in the house storage!" );
		new model = GetItemModel( item );
		PlayerInventoryAdd( playerid, item, model, amount );
		format(globalstring, sizeof(globalstring), "You took %s (%d) from the group storage.", item, amount);
		SCM(playerid,sales2, globalstring);
		GroupInventory_Remove(hid, item, amount);

		format(globalstring, sizeof(globalstring), "%s loaded %s (%d) from %s.", PlayerName(playerid),  item, amount, org_info[ hid ][ oName ]);
		LogSave( "Ostalo/GroupLoad.log", globalstring );
	}
	else SendErrorMessage(playerid, "You are not inside your property or group HQ.");

	return 1;
}
CMD:storage(playerid, params[])
{
	if(inPUBG[ playerid ] != 0) return SendErrorMessage(playerid, "You cannot while you are at event.");
	if(inProperty[playerid] != -1)
	{
		new houseid = inProperty[ playerid ];
		if( houseid == -1 ) {
			SendErrorMessage( playerid, "You are not in any property." );
			return 1;
		}
		if(GetPlayerVirtualWorld(playerid) != gPropertyInfo [houseid ][ iVW ]) return SendErrorMessage( playerid, "You are not in any property." );
		if(gPropertyInfo [houseid ][ iOwnerbaseID ] == gPlayerData[playerid][E_PLAYER_ID]) {}
		else if( gPlayerData[ playerid ][ E_PLAYER_PROPERTY_KEY_1 ] == gPropertyInfo [houseid ][ ibaseID ]  ) { }
		else if( gPlayerData[ playerid ][ E_PLAYER_PROPERTY_KEY_2 ] == gPropertyInfo [houseid ][ ibaseID ]  ) { }
		else if( gPlayerData[ playerid ][ E_PLAYER_PROPERTY_KEY_3 ] == gPropertyInfo [houseid ][ ibaseID ]  ) { }
		else if( gPlayerData[ playerid ][ E_PLAYER_PROPERTY_KEY_4 ] == gPropertyInfo [houseid ][ ibaseID ]  ) { }
		else if( gPlayerData[ playerid ][ E_PLAYER_PROPERTY_KEY_5 ] == gPropertyInfo [houseid ][ ibaseID ]  ) { }
		else
		{
			if(gPropertyInfo [houseid ][ iLockUpgrade ] == 1) return SendErrorMessage(playerid, "This property has reinforced safe. You cannot view it's storage.");
			new str[3000] = "Item\tQuantity";
			new count=0;
			for( new i = 0; i != MAX_INVENTORY; i++ ) 
			{
				if( hinventoryInfo[ houseid ][ i ][ invExists ] ) 
				{
					format(str, sizeof(str) , "%s\n%s\t%d\n", str, hinventoryInfo[ houseid ][ i ][ invItem ], hinventoryInfo[ houseid ][ i ][ invQuantity ]);
					count++;
				}
			}
			if(count == 0) return SendErrorMessage(playerid, "There's nothing in the storage.");
			new header[32];
			format(header, 32, "Inventory {FCCA11}(%d/100)", count);
			SPD(playerid, dialog_NEWINV, DIALOG_STYLE_TABLIST_HEADERS, header, str, "Close","");
			return 1;
		}

		new str[3000] = "Item\tQuantity";
		new count=0;
		for( new i = 0; i != MAX_INVENTORY; i++ ) 
		{
			if( hinventoryInfo[ houseid ][ i ][ invExists ] ) 
			{
				format(str, sizeof(str) , "%s\n%s\t%d\n", str, hinventoryInfo[ houseid ][ i ][ invItem ], hinventoryInfo[ houseid ][ i ][ invQuantity ]);
				count++;
			}
		}
		if(count == 0) return SendErrorMessage(playerid, "There's nothing in the storage.");
		new header[32];
		format(header, 32, "Inventory {FCCA11}(%d/100)", count);
		SPD(playerid, dialog_NEWINV, DIALOG_STYLE_TABLIST_HEADERS, header, str, "Close","");
	}
	else if( IsPlayerInGroup(playerid, inOrgInt[ playerid ]) )
	{
		new houseid = inOrgInt[ playerid ];
		if(houseid < 1) return SendErrorMessage(playerid, "You are not in a group HQ.");
		if(GetPlayerVirtualWorld(playerid) != org_info[ houseid ][ oVw ]) return SendErrorMessage(playerid, "You are not in a group HQ.");
		new str[3000] = "Item\tQuantity";
		new count = 0;
		for( new i = 0; i != MAX_INVENTORY; i++ ) 
		{
			if( gInventoryInfo[ houseid ][ i ][ invExists ] ) 
			{
				format(str, sizeof(str) , "%s\n%s\t%d\n", str, gInventoryInfo[ houseid ][ i ][ invItem ], gInventoryInfo[ houseid ][ i ][ invQuantity ]);
				count++;
			}
		}
		if(count == 0) return SendErrorMessage(playerid, "There's nothing in the storage.");
		new header[32];
		format(header, 32, "Inventory {FCCA11}(%d/100)", count);
		SPD(playerid, dialog_NEWINV, DIALOG_STYLE_TABLIST_HEADERS, header, str, "Close","");
	}
	else SendErrorMessage(playerid, "You are not inside your property or group HQ.");
	return 1;
}