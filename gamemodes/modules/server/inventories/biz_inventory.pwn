forward OnBusinessInventoryLoad( bizid );
public OnBusinessInventoryLoad( bizid ) {

	new rows, fields;
	cache_get_data( rows, fields, _dbConnector );

	if( !rows ) {

		new query[ 128 ];

		format( query, sizeof( query ),
			"INSERT INTO `biz_items` (biz_id) VALUES('%d')", gBusinessData[ bizid ][ E_BUSINESS_DB_ID ] );

		mysql_pquery( _dbConnector, query, "", "" );
	}
	else {

		new textic[ 64 ];
		for( new i = 0; i < MAX_INVENTORY; i++ ) {
		
			format( textic, sizeof( textic ), "inv_slot_model_%d", i+1 );
			gBusinessItems[ bizid ][ i ][ invModel ] = cache_get_field_content_int(0, textic );
			format( textic, sizeof( textic ), "inv_slot_quantity_%d", i+1 ); 
			gBusinessItems[ bizid ][ i ][ invQuantity ] = cache_get_field_content_int(0, textic );
			format( textic, sizeof( textic ), "inv_slot_price_%d", i+1 );
			gBusinessItems[ bizid ][ i ][ invPrice ] = cache_get_field_content_int(0, textic );
			
			if( gBusinessItems[ bizid ][ i ][ invModel ] != 0 ) {
				gBusinessItems[ bizid ][ i ][ invExists ] = true;
				
				if( gBusinessItems[ bizid ][ i ][ invModel ] >= 321 && gBusinessItems[ bizid ][ i ][ invModel ] <= 372 && gBusinessItems[ bizid ][ i ][ invModel ] != 365 ) {
				
					for( new z = 0; z < 47; z++ ) {
					
						if( WeaponInfos[ z ][ wModel ] == gBusinessItems[ bizid ][ i ][ invModel ] ) {
						
							strmid( gBusinessItems[ bizid ][ i ][ invItem ], WeaponInfos[ z ][ wName ], 0, strlen( WeaponInfos[ z ][ wName ] ), 32 );
							break;
						}
					}
				}
				else {
				
					for( new j = 0; j < MAX_BIZ_ITEMS; j++ ) {
						if( gBusinessItems[ bizid ][ i ][ invModel ] == biz_item_info[ j ][ biz_item_model ] ) {
							strmid( gBusinessItems[ bizid ][ i ][ invItem ], biz_item_info[ j ][ biz_item_name ], 0, strlen( biz_item_info[ j ][ biz_item_name ] ), 32 );
							break;
						}
					}
				}
			}
		}
	}
	return (true);
}
stock biz_inventory_update_quantity( bizid, itemid ) {

	new q[ 256 ];
	mysql_format( _dbConnector, q, sizeof(q), "UPDATE `biz_items` SET `inv_slot_quantity_%d` = '%d' WHERE `biz_id` = '%d'", (itemid+1), gBusinessItems[ bizid ][ itemid ][ invQuantity ], gBusinessData[ bizid ][ E_BUSINESS_DB_ID ] );
	mysql_tquery( _dbConnector, q, "", "");

	return true;
}
stock biz_inventory_update_price( bizid, itemid ) {

	new q[ 256 ];
	mysql_format( _dbConnector, q, sizeof(q), "UPDATE `biz_items` SET `inv_slot_price_%d` = '%d' WHERE `biz_id` = '%d'", (itemid+1), gBusinessItems[ bizid ][ itemid ][ invPrice ], gBusinessData[ bizid ][ E_BUSINESS_DB_ID ] );
	mysql_tquery( _dbConnector, q, "", "");

	return true;
}
stock biz_inventory_update_mq( bizid, itemid ) { 

	new q[ 256 ];
	mysql_format( _dbConnector, q, sizeof(q), "UPDATE `biz_items` SET `inv_slot_model_%d` = '%d', `inv_slot_quantity_%d` = '%d', `inv_slot_price_%d` = '%d' WHERE `biz_id` = '%d'",
		(itemid+1),
		gBusinessItems[ bizid ][ itemid ][ invModel ],
		(itemid+1),
		gBusinessItems[ bizid ][ itemid ][ invQuantity ],
		(itemid+1),
		gBusinessItems[ bizid ][ itemid ][ invPrice ],
		gBusinessData[ bizid ][ E_BUSINESS_DB_ID ] );
		
	mysql_pquery( _dbConnector, q, "", "");

	return true;
}
stock ResetBusinessInventory(bizid)
{
	for( new x = 0; x < MAX_INVENTORY; x++ ) {
		gBusinessItems[ bizid ][ x ][ invExists ] = false;
		gBusinessItems[ bizid ][ x ][ invModel ] = gBusinessItems[ bizid ][ x ][ invQuantity ] = 0;
		strmid( gBusinessItems[ bizid ][ x ][ invItem ], "None", 0, strlen( "None" ), 32 );
		gBusinessItems[ bizid ][ x ][ invColor ] = -1;
		gBusinessItems[ bizid ][ x ][ invPrice ] = 0;
	}
	return 1;
}
stock AddBizItem( bizid, item[], model, quantity = 1 ) {
	new itemid = Biz_GetItemID( bizid, item );
	if(itemid == -1){
		item[0] = toupper(item[0]);
		itemid = Biz_GetFreeID( bizid );
		if( itemid != -1 ) {
			gBusinessItems[ bizid ][ itemid ][ invExists ] = true;
			gBusinessItems[ bizid ][ itemid ][ invModel ] = model;
			gBusinessItems[ bizid ][ itemid ][ invQuantity ] = quantity;
			strmid( gBusinessItems[ bizid ][ itemid ][ invItem ], item, 0, strlen( item ), 32 );
			biz_inventory_update_mq( bizid, itemid );
		}
	}
	else
	{
		gBusinessItems[ bizid ][ itemid ][ invQuantity ] += quantity;
	}
	biz_inventory_update_quantity( bizid, itemid );
	return 1;
}
stock Biz_GetItemID( bizid, item[] )
{
	for( new i = 0; i < MAX_INVENTORY; i++ ) {
		if( !gBusinessItems[ bizid ][ i ][ invExists ] )
			continue;

		if( !strcmp( gBusinessItems[ bizid ][ i ][ invItem ], item , true) ) return i;
	}
	return -1;
}
stock Biz_GetItemModel( bizid, item[] )
{
	for( new i = 0; i < MAX_INVENTORY; i++ ) {
		if( !gBusinessItems[ bizid ][ i ][ invExists ] )
			continue;

		if( !strcmp( gBusinessItems[ bizid ][ i ][ invItem ], item, true ) ) return gBusinessItems[ bizid ][ i ][ invModel ];
	}
	return -1;
}

stock Biz_GetFreeID( bizid ) {
	if( Biz_Items( bizid ) >= 100 )
		return -1;

	for( new i = 0; i < MAX_INVENTORY; i++ ) {
		if( !gBusinessItems[ bizid ][ i ][ invExists ] )
			return i;
	}
	return -1;
}

stock Biz_Items( bizid ) {
	new count;

	for( new i = 0; i != MAX_INVENTORY; i++ ) if( gBusinessItems[ bizid ][ i ][ invExists ] ) {
		count++;
	}
	return count;
}

stock BizItems_Count( bizid, item[] ) {
	new itemid = Biz_GetItemID( bizid, item );

	if( itemid != -1 )
		return gBusinessItems[ bizid ][ itemid ][ invQuantity ];

	return false;
}

stock Biz_HasItem( bizid, item[] ) {
	return ( Biz_GetItemID( bizid, item ) != -1 );
}

stock SetBizItem( bizid, item[], model, quantity = 1 ) {
	new itemid = Biz_GetItemID( bizid, item );
	if(itemid == -1){
		item[0] = toupper(item[0]);
		itemid = Biz_GetFreeID( bizid );
		if( itemid != -1 ) {
			gBusinessItems[ bizid ][ itemid ][ invExists ] = true;
			gBusinessItems[ bizid ][ itemid ][ invModel ] = model;
			gBusinessItems[ bizid ][ itemid ][ invQuantity ] = quantity;
			strmid( gBusinessItems[ bizid ][ itemid ][ invItem ], item, 0, strlen( item ), 32 );
			biz_inventory_update_mq( bizid, itemid );
		}
	}
	else
	{
		gBusinessItems[ bizid ][ itemid ][ invQuantity ] = quantity;
	}
	biz_inventory_update_quantity( bizid, itemid );
	return 1;
}

stock BizItem_Remove( bizid, item[], quantity = 1 ) {
	new
		itemid = Biz_GetItemID( bizid, item );

	if( itemid != -1 ) {
	
		if( gBusinessItems[ bizid ][ itemid ][ invQuantity ] > (quantity-1) ) {
			gBusinessItems[ bizid ][ itemid ][ invQuantity ] -= quantity;
		}
		else return false;
		
		if( quantity == -1 || gBusinessItems[ bizid ][ itemid ][ invQuantity ] < 1 ) {
			gBusinessItems[ bizid ][ itemid ][ invQuantity ] = 0;
			biz_inventory_update_quantity( bizid, itemid );
			//biz_inventory_remove_item( bizid, itemid );
		}
		else if( quantity != -1 && gBusinessItems[ bizid ][ itemid ][ invQuantity ] > 0 ) { 
			
			biz_inventory_update_quantity( bizid, itemid );
		}
		return true;
	}
	return false;
}



stock BizItem_Set( bizid, item[], model, amount ) {
	new itemid = Biz_GetItemID( bizid, item );

	if( itemid == -1 && amount > 0 )
		AddBizItem( bizid, item, model, amount );

	else if( amount > 0 && itemid != -1 )
		Biz_SetQuantity( bizid, item, amount );

	else if( amount < 1 && itemid != -1 )
		BizItem_Remove( bizid, item, -1 );

	return true;
}
