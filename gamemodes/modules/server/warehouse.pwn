#define MAX_WAREHOUSE 10

enum E_WAREHOUSE {

	E_WAREHOUSE_DB_ID,
	whsqlID,
	Float:whEntPos[ 3 ],
	Float:whExitPos[ 3 ],
	whPrice,
	whOrgOwnerSqlID,
	whOrgOwner,
	whInt,
	whVW,
	whfabrics,
	whmetals,
	whgunparts,
	whPickup,
	whDarea,
	Text3D:whLabel
};
new warehouse[MAX_WAREHOUSE][E_WAREHOUSE];


forward OnWarehouseCreated( dl );
public OnWarehouseCreated( dl ){

	warehouse[ dl ][ whsqlID ] = cache_insert_id();
	warehouse_Refresh( dl );
	
	return true;
}

warehouse_Refresh( wh ) {
	if( wh != -1 ) {
		if( warehouse[ wh ][ whsqlID ] > 0 ) {

			if( IsValidDynamic3DTextLabel( warehouse[ wh ][ whLabel ] ) )
				DestroyDynamic3DTextLabel( warehouse[ wh ][ whLabel ] );

			if( IsValidDynamicPickup( warehouse[ wh ][ whPickup ] ) )
				DestroyDynamicPickup( warehouse[ wh ][ whPickup ] );

			warehouse[ wh ][ whDarea ] = CreateDynamicCircle(warehouse[ wh ][ whEntPos ][ 0 ], warehouse[ wh ][ whEntPos ][ 1 ], 2);
			new string[ 256 ];
			if( warehouse[ wh ][ whOrgOwner ] != -1 ) {

				warehouse[ wh ][ whPickup ] = CreateDynamicPickup( 19523, 1, warehouse[ wh ][ whEntPos ][ 0 ], warehouse[ wh ][ whEntPos ][ 1 ], warehouse[ wh ][ whEntPos ][ 2 ], 0, 0 );
				format( string, sizeof( string ), ""col_white"Owner: "col_server"%s\n"col_white"Fabrics: "col_server"%d"col_white"\nMetals: "col_server"%d"col_white"\nGunparts: "col_server"%d", org_info[warehouse[ wh ][ whOrgOwner ]][oName], warehouse[wh][whfabrics],warehouse[wh][whmetals],warehouse[wh][whgunparts] );
				warehouse[ wh ][ whLabel ] = CreateDynamic3DTextLabel( string, BELA, warehouse[ wh ][ whEntPos ][ 0 ], warehouse[ wh ][ whEntPos ][ 1 ], warehouse[ wh ][ whEntPos ][ 2 ], 8.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0 );
			}
			else {

				warehouse[ wh ][ whPickup ] = CreateDynamicPickup( 19523, 1, warehouse[ wh ][ whEntPos ][ 0 ], warehouse[ wh ][ whEntPos ][ 1 ], warehouse[ wh ][ whEntPos ][ 2 ], 0, 0 );
				format( string, sizeof( string ), ""col_white"Owner: "col_server"Unowned"col_white"\nPrice: "col_server"%d"col_white"\nCommand: "col_server"/buywarehouse",  warehouse[wh][whPrice] );
				warehouse[ wh ][ whLabel ] = CreateDynamic3DTextLabel( string, BELA, warehouse[ wh ][ whEntPos ][ 0 ], warehouse[ wh ][ whEntPos ][ 1 ], warehouse[ wh ][ whEntPos ][ 2 ], 8.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0 );
			}

		}
	}
}
