forward OnGroupInventoryLoad( groupid );
public OnGroupInventoryLoad( groupid ) {

	new rows, fields;
	cache_get_data( rows, fields, _dbConnector );

	if( !rows ) {

		new query[ 128 ];

		format( query, sizeof( query ),
			"INSERT INTO `group_inv` (groupid) VALUES('%d')", org_info[groupid][oID] );

		mysql_pquery( _dbConnector, query, "", "" );
	}
	else {

		new textic[ 64 ];
		for( new i = 0; i < MAX_INVENTORY; i++ ) {
		
			format( textic, sizeof( textic ), "inv_slot_model_%d", i+1 );
			gInventoryInfo[ groupid ][ i ][ invModel ] = cache_get_field_content_int(0, textic );
			format( textic, sizeof( textic ), "inv_slot_quantity_%d", i+1 ); 
			gInventoryInfo[ groupid ][ i ][ invQuantity ] = cache_get_field_content_int(0, textic );
			format( textic, sizeof( textic ), "inv_slot_color_%d", i+1 );
			gInventoryInfo[ groupid ][ i ][ invColor ] = cache_get_field_content_int(0, textic );
			format( textic, sizeof( textic ), "inv_slot_robbed_%d", i+1 );
			gInventoryInfo[ groupid ][ i ][ invRobbed ] = cache_get_field_content_int(0, textic );
			
			if( gInventoryInfo[ groupid ][ i ][ invModel ] != 0 && gInventoryInfo[ groupid ][ i ][ invQuantity ] != 0 ) {
				gInventoryInfo[ groupid ][ i ][ invExists ] = true;
				
				if( gInventoryInfo[ groupid ][ i ][ invModel ] >= 321 && gInventoryInfo[ groupid ][ i ][ invModel ] <= 372 && gInventoryInfo[ groupid ][ i ][ invModel ] != 365 ) {
				
					for( new z = 0; z < 47; z++ ) {
					
						if( WeaponInfos[ z ][ wModel ] == gInventoryInfo[ groupid ][ i ][ invModel ] ) {
						
							strmid( gInventoryInfo[ groupid ][ i ][ invItem ], WeaponInfos[ z ][ wName ], 0, strlen( WeaponInfos[ z ][ wName ] ), 32 );
							break;
						}
					}
				}
				else {
				
					for( new j = 0; j < MAX_ITEMS; j++ ) {
						if( gInventoryInfo[ groupid ][ i ][ invModel ] == inv_obj_inf[ j ][ i_o_i_model ] ) {
							strmid( gInventoryInfo[ groupid ][ i ][ invItem ], inv_obj_inf[ j ][ i_o_i_name ], 0, strlen( inv_obj_inf[ j ][ i_o_i_name ] ), 32 );
							break;
						}
					}
				}
			}
		}
	}
	return (true);
}
stock sql_ginventory_update_quantity( groupid, itemid ) {

	new q[ 256 ];
	mysql_format( _dbConnector, q, sizeof(q), "UPDATE `group_inv` SET `inv_slot_quantity_%d` = '%d' WHERE `groupid` = '%d'", (itemid+1), gInventoryInfo[ groupid ][ itemid ][ invQuantity ], org_info[groupid][oID] );
	mysql_tquery( _dbConnector, q, "", "");

	return true;
}
stock sql_ginventory_update_robbed( groupid, itemid ) {

	new q[ 256 ];
	mysql_format( _dbConnector, q, sizeof(q), "UPDATE `group_inv` SET `inv_slot_robbed_%d` = '%d' WHERE `groupid` = '%d'", (itemid+1), gInventoryInfo[ groupid ][ itemid ][ invRobbed ], org_info[groupid][oID] );
	mysql_tquery( _dbConnector, q, "", "");

	return true;
}
stock sql_ginventory_update_mq( groupid, itemid ) { 

	new q[ 256 ];
	mysql_format( _dbConnector, q, sizeof(q), "UPDATE `group_inv` SET `inv_slot_model_%d` = '%d', `inv_slot_quantity_%d` = '%d', `inv_slot_color_%d` = '%d' WHERE `groupid` = '%d'",
		(itemid+1),
		gInventoryInfo[ groupid ][ itemid ][ invModel ],
		(itemid+1),
		gInventoryInfo[ groupid ][ itemid ][ invQuantity ],
		(itemid+1),
		gInventoryInfo[ groupid ][ itemid ][ invColor ],
		org_info[groupid][oID] );
		
	mysql_pquery( _dbConnector, q, "", "");

	return true;
}

stock sql_ginventory_remove_item( groupid, itemid ) {

	new q[ 256 ];
	mysql_format( _dbConnector, q, sizeof(q), "UPDATE `group_inv` SET `inv_slot_model_%d` = '0', `inv_slot_quantity_%d` = '0' WHERE `groupid` = '%d'",
		(itemid+1),
		(itemid+1),
		org_info[groupid][oID] );

	mysql_tquery( _dbConnector, q, "", "");

	return true;
}
stock GroupInventory_Add( groupid, item[], model, quantity = 1 ) {
	new itemid = GroupInventory_GetItemID( groupid, item );
	if(itemid == -1){
		item[0] = toupper(item[0]);
		itemid = GroupInventory_GetFreeID( groupid );
		if( itemid != -1 ) {
			gInventoryInfo[ groupid ][ itemid ][ invExists ] = true;
			gInventoryInfo[ groupid ][ itemid ][ invModel ] = model;
			gInventoryInfo[ groupid ][ itemid ][ invQuantity ] = quantity;
			strmid( gInventoryInfo[ groupid ][ itemid ][ invItem ], item, 0, strlen( item ), 32 );
			sql_ginventory_update_mq( groupid, itemid );
		}
	}
	else
	{
		gInventoryInfo[ groupid ][ itemid ][ invQuantity ] += quantity;
	}
	sql_ginventory_update_quantity( groupid, itemid );
	return 1;
}
stock GroupInventory_GetItemID( groupid, item[] )
{
	for( new i = 0; i < MAX_INVENTORY; i++ ) {
		if( !gInventoryInfo[ groupid ][ i ][ invExists ] )
			continue;

		if( !strcmp( gInventoryInfo[ groupid ][ i ][ invItem ], item , true) ) return i;
	}
	return -1;
}
stock GroupInventory_GetItemModel( groupid, item[] )
{
	for( new i = 0; i < MAX_INVENTORY; i++ ) {
		if( !gInventoryInfo[ groupid ][ i ][ invExists ] )
			continue;

		if( !strcmp( gInventoryInfo[ groupid ][ i ][ invItem ], item, true ) ) return gInventoryInfo[ groupid ][ i ][ invModel ];
	}
	return -1;
}

stock GroupInventory_GetFreeID( groupid ) {
	if( GroupInventory_Items( groupid ) >= 100 )
		return -1;

	for( new i = 0; i < MAX_INVENTORY; i++ ) {
		if( !gInventoryInfo[ groupid ][ i ][ invExists ] )
			return i;
	}
	return -1;
}

stock GroupInventory_Items( groupid ) {
	new count;

	for( new i = 0; i != MAX_INVENTORY; i++ ) if( gInventoryInfo[ groupid ][ i ][ invExists ] ) {
		count++;
	}
	return count;
}

stock GroupInventory_Count( groupid, item[] ) {
	new itemid = GroupInventory_GetItemID( groupid, item );

	if( itemid != -1 )
		return gInventoryInfo[ groupid ][ itemid ][ invQuantity ];

	return false;
}

stock GroupInventory_HasItem( groupid, item[] ) {
	return ( GroupInventory_GetItemID( groupid, item ) != -1 );
}

stock GroupInventory_SetQuantity( groupid, item[], quantity ) {
	new
		itemid = GroupInventory_GetItemID( groupid, item ),
		string[ 128 ];

	if( itemid != -1 ) {
		gInventoryInfo[ groupid ][ itemid ][ invQuantity ] = quantity;
		
		sql_ginventory_update_quantity( groupid, itemid );
	}
	return true;
}

stock GroupInventory_Remove( groupid, item[], quantity = 1 ) {
	new
		itemid = GroupInventory_GetItemID( groupid, item );

	if( itemid != -1 ) {
	
		if( gInventoryInfo[ groupid ][ itemid ][ invQuantity ] > (quantity-1) ) {
			gInventoryInfo[ groupid ][ itemid ][ invQuantity ] -= quantity;
		}
		else return false;
		
		if( quantity == -1 || gInventoryInfo[ groupid ][ itemid ][ invQuantity ] < 1 ) {
			gInventoryInfo[ groupid ][ itemid ][ invExists ] = false;
			gInventoryInfo[ groupid ][ itemid ][ invModel ] = 0;
			gInventoryInfo[ groupid ][ itemid ][ invQuantity ] = 0;
			strmid( gInventoryInfo[ groupid ][ itemid ][ invItem ], "None", 0, strlen( "None" ), 32 );
			gInventoryInfo[ groupid ][ itemid ][ invColor ] = -1;

			sql_ginventory_remove_item( groupid, itemid );
		}
		else if( quantity != -1 && gInventoryInfo[ groupid ][ itemid ][ invQuantity ] > 0 ) { 
			
			sql_ginventory_update_quantity( groupid, itemid );
		}
		return true;
	}
	return false;
}

stock GroupInventory_Remove_2( groupid, itemid, quantity = 1 ) {

	if( itemid != -1 ) {
	
		if( gInventoryInfo[ groupid ][ itemid ][ invQuantity ] > 0 ) {
			gInventoryInfo[ groupid ][ itemid ][ invQuantity ] -= quantity;
		}
		else return false;

		if( quantity == -1 || gInventoryInfo[ groupid ][ itemid ][ invQuantity ] < 1 ) {
			gInventoryInfo[ groupid ][ itemid ][ invExists ] = false;
			gInventoryInfo[ groupid ][ itemid ][ invModel ] = 0;
			gInventoryInfo[ groupid ][ itemid ][ invQuantity ] = 0;
			strmid( gInventoryInfo[ groupid ][ itemid ][ invItem ], "None", 0, strlen( "None" ), 32 );
			gInventoryInfo[ groupid ][ itemid ][ invColor ] = -1;
			sql_ginventory_remove_item( groupid, itemid );
		}
		else if( quantity != -1 && gInventoryInfo[ groupid ][ itemid ][ invQuantity ] > 0 ) {

			sql_ginventory_update_quantity( groupid, itemid );
		}
		return true;
	}
	return false;
}


stock GroupInventory_Set( groupid, item[], model, amount ) {
	new itemid = GroupInventory_GetItemID( groupid, item );

	if( itemid == -1 && amount > 0 )
		GroupInventory_Add( groupid, item, model, amount );

	else if( amount > 0 && itemid != -1 )
		GroupInventory_SetQuantity( groupid, item, amount );

	else if( amount < 1 && itemid != -1 )
		GroupInventory_Remove( groupid, item, -1 );

	return true;
}
