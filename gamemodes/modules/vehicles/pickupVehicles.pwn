// Module for Vehicles Pickup - Take Vehicle on THE PICKUP
// Skripter: Unknown
// Work Begin 20:02 17/04/2020
// Work End 00:25 18/04/2020


//=====================[ DEFINES & Player Variables ]===============

#define PERM_ADMIN    1
#define PERM_HELPER   2
#define PERM_VIP      3
#define PERM_PROMOTER 4


#define MAX_VEHICLE_PICKUPS  200

enum vehPickupData {
	piSQLID,
	Text3D:piLabel,
	piPickup,
	piPickupID,
	Float:piPickup_Pos_X,
	Float:piPickup_Pos_Y,
	Float:piPickup_Pos_Z,
	piVeh_Model,
	Float:piVeh_Pos_X,
	Float:piVeh_Pos_Y,
	Float:piVeh_Pos_Z,
	Float:piVeh_Pos_A,
	piVeh_Color_1,
	piVeh_Color_2,
	piVeh_Usage,
	piVeh_Permission
};

new VehiclePickupInfo[ MAX_VEHICLE_PICKUPS ][ vehPickupData ];

// --Player Variables-- //

new createPickupVehicle[ MAX_PLAYERS ],
	editPickupVehicle[ MAX_PLAYERS ],
	PickupedVehicle[ MAX_PLAYERS ],
	pickupedTimer[ MAX_PLAYERS ],
	bool:pickupedVehicleEnter[ MAX_PLAYERS ],
	counterVehicleTimer[ MAX_PLAYERS ];


//-- Usages --//

enum {
	USAGE_VEHICLE_JOB = 1 ,
	USAGE_VEHICLE_ADMIN,
	USAGE_VEHICLE_VIP,
	USAGE_VEHICLE_PROMOTER,
	USAGE_VEHICLE_HELPER
};

//=====================[ FORWARDS ]================================

forward LoadPickupVehicles( );
forward SavePickupVehicle( id );
forward mSQL_CreateVehiclePickup( playerid,  createID );
forward OnVehiclePickupCreated( playerid, id );



//=====================[ Functions ]===============================

getUsageString( vehicleid ) {
	new usage[ 40 ];
	switch( gVehicleData[ vehicleid ][ E_VEHICLE_TYPE ] ) {
		case e_VEHICLE_TYPE_ADMIN: {
			format(usage , sizeof( usage ), "Admin");
		}
		case e_VEHICLE_TYPE_HELPER: {
			format(usage , sizeof( usage ), "Helper");
		}
		case e_VEHICLE_TYPE_VIP: {
			format(usage , sizeof( usage ), "VIP");
		}
		case e_VEHICLE_TYPE_SPECIAL: {
			format(usage , sizeof( usage ), "Promoter");
		}
	}
	return usage;
}

GetUsageForVehicleStaff( vehicleid ) {
	new usage = -1;
	switch( gVehicleData[ vehicleid ][ E_VEHICLE_TYPE ] ) {
		case e_VEHICLE_TYPE_ADMIN: {
			usage = e_VEHICLE_TYPE_ADMIN; 
		}
		case e_VEHICLE_TYPE_HELPER: {
			usage = e_VEHICLE_TYPE_HELPER; 
		}
		case e_VEHICLE_TYPE_VIP: {
			usage = e_VEHICLE_TYPE_VIP; 
		}
		case e_VEHICLE_TYPE_SPECIAL: {
			usage = e_VEHICLE_TYPE_SPECIAL; 
		}
	}
	return usage;
}




GetNearestPickupVehicle(playerid ) {
	new id = -1;
	for( new b = 1; b < MAX_VEHICLE_PICKUPS; b++ ) {
		if( VehiclePickupInfo[ b ][ piSQLID ] != 0 && VehiclePickupInfo[ b ][ piSQLID ] != -1 ) {
			if(IsPlayerInRangeOfPoint(playerid, 3.0, VehiclePickupInfo[ b ][ piPickup_Pos_X ], VehiclePickupInfo[ b ][ piPickup_Pos_Y ], VehiclePickupInfo[ b ][ piPickup_Pos_Z ])) {
				id = b;
				break;
			}
		}
	}
	return id;
}

RefreshLabelAndP( thisID ) {
	if( IsValidDynamicPickup( VehiclePickupInfo[ thisID ][ piPickup] ) )
		DestroyDynamicPickup( VehiclePickupInfo[ thisID ][ piPickup] );

	if( IsValidDynamic3DTextLabel( VehiclePickupInfo[ thisID ][ piLabel] ) ) 
        DestroyDynamic3DTextLabel( VehiclePickupInfo[ thisID ][ piLabel ] );
    VehiclePickupInfo[ thisID ][ piLabel ]  = Text3D:-1;
   //new string[ 200 ]; 
    switch( VehiclePickupInfo[ thisID ][ piVeh_Usage ] ) {
		case USAGE_VEHICLE_JOB: {
			//format(string, sizeof(string), ""col_server"[Vehicle - Job]\n"col_white"Job: "col_server"%s\n"col_white"To take a vehicle, type \n"col_server"[ /jobveh or /jv ]", getJobName( VehiclePickupInfo[ thisID ][ piVeh_Permission ] ) );
			//VehiclePickupInfo[ thisID ][ piLabel ] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
			VehiclePickupInfo[ thisID ][ piPickup ] = CreateDynamicPickup( VehiclePickupInfo[ thisID ][ piPickupID ], 1, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 0, 0);
		}
		case USAGE_VEHICLE_ADMIN: {
			//format(string, sizeof(string), ""col_server"[Vehicle - Admin]\n"col_white"To take a vehicle, type \n"col_server"[ /takeveh or /tv ]" );
    		//VehiclePickupInfo[ thisID ][ piLabel ] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
			VehiclePickupInfo[ thisID ][ piPickup ] = CreateDynamicPickup( VehiclePickupInfo[ thisID ][ piPickupID ], 1, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 0, 0);
		}
		case USAGE_VEHICLE_HELPER: {
			//format(string, sizeof(string), ""col_server"[Vehicle - Helperr]\n"col_white"To take a vehicle, type \n"col_server"[ /takeveh or /tv ]" );
    		//VehiclePickupInfo[ thisID ][ piLabel ] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
			VehiclePickupInfo[ thisID ][ piPickup ] = CreateDynamicPickup( VehiclePickupInfo[ thisID ][ piPickupID ], 1, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 0, 0);
		}
		case USAGE_VEHICLE_VIP: {
			//format(string, sizeof(string), ""col_server"[Vehicle - Vip]\n"col_white"To take a vehicle, type \n"col_server"[ /takeveh or /tv ]" );
    		//VehiclePickupInfo[ thisID ][ piLabel ] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
			VehiclePickupInfo[ thisID ][ piPickup ] = CreateDynamicPickup( VehiclePickupInfo[ thisID ][ piPickupID ], 1, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 0, 0);
		}
		case USAGE_VEHICLE_PROMOTER: {
			//format(string, sizeof(string), ""col_server"[Vehicle - Promoter]\n"col_white"To take a vehicle, type \n"col_server"[ /takeveh or /tv ]" );
    		//VehiclePickupInfo[ thisID ][ piLabel ] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
			VehiclePickupInfo[ thisID ][ piPickup ] = CreateDynamicPickup( VehiclePickupInfo[ thisID ][ piPickupID ], 1, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 0, 0);
		}
	}



}


OnDialogResponsePV(playerid, dialogid, response, listitem, inputtext[]) {
	if( dialogid == dialog_VEHTYPE ) {
		if( !response ) return true;
		if( response ) {
			switch( listitem ) {
				case 0: {
					SPD( playerid, dialog_VEHTYPE_JOB, DSI, D_INFO_TEXT, "Enter the desired car id, job id, color id1, color id2.", FirstButton, SecondButton_2 );
				}
				case 1: {
					SPD( playerid, dialog_VEHTYPE_ADMIN, DSI, D_INFO_TEXT, "Enter the desired car id, color id1, color id2.", FirstButton, SecondButton_2 );
				}
				case 2: {
					SPD( playerid, dialog_VEHTYPE_HELPER, DSI, D_INFO_TEXT, "Enter the desired car id, color id1, color id2.", FirstButton, SecondButton_2 );
				}
				case 3: {
					SPD( playerid, dialog_VEHTYPE_VIP, DSI, D_INFO_TEXT, "Enter the desired car id, color id1, color id2.", FirstButton, SecondButton_2 );
				}
				case 4: {
					SPD( playerid, dialog_VEHTYPE_PROMOTER, DSI, D_INFO_TEXT, "Enter the desired car id, color id1, color id2.", FirstButton, SecondButton_2 );
				}
			}
		}
	}
	else if( dialogid == dialog_VEHTYPECHANGE ) {
		if( !response ) return true;
		if( response ) {
			switch( listitem ) {
				case 0: {
					new id ;
					id = GetNearestPickupVehicle( playerid );
					if( id == -1 ) return SendErrorMessage( playerid, "You are not near a vehicle pickup");
					new infoDialog[ 300 ];
					format( infoDialog, sizeof( infoDialog) \
						, ""col_white"1 - Vehicle type of "col_server"job\n\
						"col_white"2 - Vehicle type of "col_server"admin\n\
						"col_white"3 - Vehicle type of "col_server"helper\n\
						"col_white"4 - Vehicle type of "col_server"vip\n\
						"col_white"5 - Vehicle type of "col_server"promoter\n");
					SPD( playerid, dialog_VEH_USAGE_CHANGE, DSL, D_INFO_TEXT, infoDialog, FirstButton, SecondButton);
					editPickupVehicle[ playerid ] = id;
				}
				case 1: {
					new id ;
					id = GetNearestPickupVehicle( playerid );
					if( id == -1 ) return SendErrorMessage( playerid, "You are not near a vehicle pickup");
					new infoDialog[ 100 ];
					format( infoDialog, sizeof( infoDialog) \
						, ""col_white"Enter the job id for which you want to edit "col_server"vehicle pickup");
					SPD( playerid, dialog_VEH_JOBCHANGE, DSI, D_INFO_TEXT, infoDialog, FirstButton, SecondButton);
					editPickupVehicle[ playerid ] = id;
				}
				case 2: {
					new id ;
					id = GetNearestPickupVehicle( playerid );
					if( id == -1 ) return SendErrorMessage( playerid, "You are not near a vehicle pickup");
					new infoDialog[ 100 ];
					format( infoDialog, sizeof( infoDialog) \
						, ""col_white"Enter vehicle id for "col_server"vehicle pickup");
					SPD( playerid, dialog_VEH_MODELCHANGE, DSI, D_INFO_TEXT, infoDialog, FirstButton, SecondButton);
					editPickupVehicle[ playerid ] = id;
				}
			}
		}
	}
	else if( dialogid == dialog_VEH_MODELCHANGE ) {
		if( !response ) {
			editPickupVehicle[ playerid ] = -1;
			return true;
		}
		if( response ) {
			new id = editPickupVehicle[ playerid ];
			new idVehicle;
			if( sscanf( inputtext , "i", idVehicle )) {
				new infoDialog[ 100 ];
				format( infoDialog, sizeof( infoDialog) \
					, ""col_white"Enter vehicle id for "col_server"vehicle pickup");
				return SPD( playerid, dialog_VEH_MODELCHANGE, DSL, D_INFO_TEXT, infoDialog, FirstButton, SecondButton);
			}
			if( idVehicle < 400 || idVehicle > 611 ) {
				new infoDialog[ 100 ];
				format( infoDialog, sizeof( infoDialog) \
					, ""col_white"Enter vehicle id for "col_server"vehicle pickup");
				return SPD( playerid, dialog_VEH_MODELCHANGE, DSL, D_INFO_TEXT, infoDialog, FirstButton, SecondButton);
			} 

			VehiclePickupInfo[ id ][ piVeh_Model ] = idVehicle; 

			new query[ 192 ];
			mysql_format( _dbConnector, query, sizeof(query), "UPDATE `pickup_vehicles` SET `vehicle_id` = '%d' WHERE `id` = '%d'",
				VehiclePickupInfo[ id ][ piVeh_Model ],
				VehiclePickupInfo[ id ][ piSQLID ] );
			mysql_pquery( _dbConnector, query, "", "" );
			SendInfoMessage( playerid, "You have successfully modified the pickup vehicle model!");
			
			RefreshLabelAndP( id );
			editPickupVehicle[ playerid ] = -1;
		}
	}
	else if( dialogid == dialog_VEH_JOBCHANGE ) {
		if( !response ) {
			editPickupVehicle[ playerid ] = -1;
			return true;
		}
		if( response ) {
			new id = editPickupVehicle[ playerid ];
			if( VehiclePickupInfo[ id ][ piVeh_Usage ] != USAGE_VEHICLE_JOB ) {
				editPickupVehicle[ playerid ] = -1;
				return SendErrorMessage( playerid, "This vehicle is not the job type!");
			} 
			new idPosla;
			if( sscanf( inputtext , "i", idPosla )) {
				new infoDialog[ 100 ];
				format( infoDialog, sizeof( infoDialog) \
					, ""col_white"Enter the job id for which you want to edit "col_server"vehicle pickup");
				return SPD( playerid, dialog_VEH_JOBCHANGE, DSL, D_INFO_TEXT, infoDialog, FirstButton, SecondButton);
			}
			if( idPosla < 1 || idPosla > MAX_JOBS ) {
				editPickupVehicle[ playerid ] = -1;
				return SendErrorMessage( playerid, "Wrong job id!" );
			}

			VehiclePickupInfo[ id ][ piVeh_Permission ] = idPosla;
			VehiclePickupInfo[ id ][ piPickupID ] = 19134;

			new query[ 192 ];
			mysql_format( _dbConnector, query, sizeof(query), "UPDATE `pickup_vehicles` SET `vehicle_usage` = '%d',`vehicle_perm` = '%d',`pickup_id` = '%d' WHERE `id` = '%d'",
				VehiclePickupInfo[ id ][ piVeh_Usage ],
				VehiclePickupInfo[ id ][ piVeh_Permission ],
				VehiclePickupInfo[ id ][ piPickupID ],
				VehiclePickupInfo[ id ][ piSQLID ] );
			mysql_pquery( _dbConnector, query, "", "" );
			SendInfoMessage(playerid, "You changed vehicle pickup for job %s", getJobName( idPosla ));
			RefreshLabelAndP( id );
			editPickupVehicle[ playerid ] = -1;
		}
	}
	else if( dialogid == dialog_VEH_USAGE_CHANGE ) {
		if( !response ) {
			editPickupVehicle[ playerid ] = -1;
			return true;
		}
		if( response ) {
			switch( listitem ) {
				case 0 : {
					new id = editPickupVehicle[ playerid ];
					if( VehiclePickupInfo[ id ][ piVeh_Usage ] == USAGE_VEHICLE_JOB ) {
						editPickupVehicle[ playerid ] = -1;
						return SendErrorMessage( playerid, "This vehicle is being used already!");
					} 
					VehiclePickupInfo[ id ][ piVeh_Usage ] = USAGE_VEHICLE_JOB;
					VehiclePickupInfo[ id ][ piVeh_Permission ] = 0;
					VehiclePickupInfo[ id ][ piPickupID ] = 19134;

					new query[ 192 ];
					mysql_format( _dbConnector, query, sizeof(query), "UPDATE `pickup_vehicles` SET `vehicle_usage` = '%d',`vehicle_perm` = '%d',`pickup_id` = '%d' WHERE `id` = '%d'",
						VehiclePickupInfo[ id ][ piVeh_Usage ],
						VehiclePickupInfo[ id ][ piVeh_Permission ],
						VehiclePickupInfo[ id ][ piPickupID ],
						VehiclePickupInfo[ id ][ piSQLID ] );

				 	mysql_pquery( _dbConnector, query, "", "");
				 	SendInfoMessage( playerid, "You have changed the pickup vehicle type to a pickup truck for this job!");
				 	SendInfoMessage(playerid, "Job id 0 is set to change it automatically go /server> edit> Vehicle Pickup");
				 	RefreshLabelAndP( id );
					editPickupVehicle[ playerid ] = -1;
				}
				case 1 : {
					new id = editPickupVehicle[ playerid ];
					if( VehiclePickupInfo[ id ][ piVeh_Usage ] == USAGE_VEHICLE_ADMIN ) {
						editPickupVehicle[ playerid ] = -1;
						return SendErrorMessage( playerid, "This type is currently for admins!");
					} 
					VehiclePickupInfo[ id ][ piVeh_Usage ] = USAGE_VEHICLE_ADMIN;
					VehiclePickupInfo[ id ][ piVeh_Permission ] = PERM_ADMIN;
					VehiclePickupInfo[ id ][ piPickupID ] = 1080;

					new query[ 192 ];
					mysql_format( _dbConnector, query, sizeof(query), "UPDATE `pickup_vehicles` SET `vehicle_usage` = '%d',`vehicle_perm` = '%d',`pickup_id` = '%d' WHERE `id` = '%d'",
						VehiclePickupInfo[ id ][ piVeh_Usage ],
						VehiclePickupInfo[ id ][ piVeh_Permission ],
						VehiclePickupInfo[ id ][ piPickupID ],
						VehiclePickupInfo[ id ][ piSQLID ] );

				 	mysql_pquery( _dbConnector, query, "", "");
				 	SendInfoMessage( playerid, "You have changed the pickup vehicle type for admins!");
				 	RefreshLabelAndP( id );
					editPickupVehicle[ playerid ] = -1;
				}
				case 2 : {
					new id = editPickupVehicle[ playerid ];
					if( VehiclePickupInfo[ id ][ piVeh_Usage ] == USAGE_VEHICLE_HELPER ) {
						editPickupVehicle[ playerid ] = -1;
						return SendErrorMessage( playerid, "This type is currently for helpers!");
					} 
					VehiclePickupInfo[ id ][ piVeh_Usage ] = USAGE_VEHICLE_HELPER;
					VehiclePickupInfo[ id ][ piVeh_Permission ] = PERM_HELPER;
					VehiclePickupInfo[ id ][ piPickupID ] = 1079;

					new query[ 192 ];
					mysql_format( _dbConnector, query, sizeof(query), "UPDATE `pickup_vehicles` SET `vehicle_usage` = '%d',`vehicle_perm` = '%d',`pickup_id` = '%d' WHERE `id` = '%d'",
						VehiclePickupInfo[ id ][ piVeh_Usage ],
						VehiclePickupInfo[ id ][ piVeh_Permission ],
						VehiclePickupInfo[ id ][ piPickupID ],
						VehiclePickupInfo[ id ][ piSQLID ] );

				 	mysql_pquery( _dbConnector, query, "", "");
				 	SendInfoMessage( playerid, "You have changed the pickup vehicle type for helpers!");
				 	RefreshLabelAndP( id );
					editPickupVehicle[ playerid ] = -1;
				}
				case 3 : {
					new id = editPickupVehicle[ playerid ];
					if( VehiclePickupInfo[ id ][ piVeh_Usage ] == USAGE_VEHICLE_VIP ) {
						editPickupVehicle[ playerid ] = -1;
						return SendErrorMessage( playerid, "This type is currently for vips!");
					} 
					VehiclePickupInfo[ id ][ piVeh_Usage ] = USAGE_VEHICLE_VIP;
					VehiclePickupInfo[ id ][ piVeh_Permission ] = PERM_VIP;
					VehiclePickupInfo[ id ][ piPickupID ] = 1078;

					new query[ 192 ];
					mysql_format( _dbConnector, query, sizeof(query), "UPDATE `pickup_vehicles` SET `vehicle_usage` = '%d',`vehicle_perm` = '%d',`pickup_id` = '%d' WHERE `id` = '%d'",
						VehiclePickupInfo[ id ][ piVeh_Usage ],
						VehiclePickupInfo[ id ][ piVeh_Permission ],
						VehiclePickupInfo[ id ][ piPickupID ],
						VehiclePickupInfo[ id ][ piSQLID ] );

				 	mysql_pquery( _dbConnector, query, "", "");
				 	SendInfoMessage( playerid, "You have changed the pickup vehicle type for vips!");
				 	RefreshLabelAndP( id );
					editPickupVehicle[ playerid ] = -1;
				}
				case 4 : {
					new id = editPickupVehicle[ playerid ];
					if( VehiclePickupInfo[ id ][ piVeh_Usage ] == USAGE_VEHICLE_PROMOTER ) {
						editPickupVehicle[ playerid ] = -1;
						return SendErrorMessage( playerid, "This type is currently for promoters!");
					} 
					VehiclePickupInfo[ id ][ piVeh_Usage ] = USAGE_VEHICLE_PROMOTER;
					VehiclePickupInfo[ id ][ piVeh_Permission ] = PERM_PROMOTER;
					VehiclePickupInfo[ id ][ piPickupID ] = 1077;

					new query[ 192 ];
					mysql_format( _dbConnector, query, sizeof(query), "UPDATE `pickup_vehicles` SET `vehicle_usage` = '%d',`vehicle_perm` = '%d',`pickup_id` = '%d' WHERE `id` = '%d'",
						VehiclePickupInfo[ id ][ piVeh_Usage ],
						VehiclePickupInfo[ id ][ piVeh_Permission ],
						VehiclePickupInfo[ id ][ piPickupID ],
						VehiclePickupInfo[ id ][ piSQLID ] );

				 	mysql_pquery( _dbConnector, query, "", "");
				 	SendInfoMessage( playerid, "You have changed the pickup vehicle type for promoters!");
				 	RefreshLabelAndP( id );
					editPickupVehicle[ playerid ] = -1;
				}
			}
		}
	} 
	else if( dialogid == dialog_VEHTYPE_JOB  ) {
	    if( response ) {
	        if( ServerInfo[ BrojKreiranihVozila ] > MaxBrojKreiranih ) return SCM( playerid, ANTICHEAT, "[ANTICHEAT]"col_white" It is currently impossible to create a vehicle, the vehicle limit on the server has been reached.");
		    new idauta, posao, Float:PozX, Float:PozY, Float:PozZ, boja1, boja2;
		    GetPlayerPos( playerid, PozX, PozY, PozZ );
		    if(carspawntimer == 1)
		    {
				SendClientMessageEx( playerid, ANTICHEAT, "[ANTICHEAT] "col_white"Someone spawn/parked a vehicle in front of you. Try after 3 seconds. (Anticrash)");
				return 1;
		    }

		    new id = -1;
		    for( new counter = 1; counter < MAX_VEHICLE_PICKUPS; counter++ ) {
		    	if( VehiclePickupInfo[ counter ][ piSQLID ] == 0 ) {
		    		id = counter;
		    		break;
		    	}
		    }
		    if( id == -1) return SendErrorMessage( playerid, "There is no more room for pickups!");


		    if( sscanf( inputtext, "iiii", idauta, posao, boja1, boja2 ) ) return SPD( playerid, dialog_VEHTYPE_JOB, DSI, D_INFO_TEXT, "Enter the desired car id, job id, color id1, color id2.", FirstButton, SecondButton_2 );
			if( idauta < 400 || idauta > 611 ) return SPD( playerid, dialog_VEHTYPE_JOB, DSI, D_INFO_TEXT, "Enter the desired car id, job id, color id1, color id2.", FirstButton, SecondButton_2 );
	        if( posao < 1 || posao > MAX_JOBS ) return SendErrorMessage( playerid, "Wrong job id!" );
            if( boja1 < 0 || boja1 > 255 ) return SendErrorMessage( playerid, "The first color cannot be less than 0 or more than 255.");
    		if( boja2 < 0 || boja2 > 255 ) return SendErrorMessage( playerid, "The second color cannot be less than 0 or more than 255.");


    		VehiclePickupInfo[ id ][ piSQLID ] = -1;
    		VehiclePickupInfo[ id ][ piVeh_Model ] = idauta;
    		VehiclePickupInfo[ id ][ piVeh_Color_1 ] = boja1;
    		VehiclePickupInfo[ id ][ piVeh_Color_2 ] = boja2;
    		VehiclePickupInfo[ id ][ piVeh_Usage ] = USAGE_VEHICLE_JOB;
    		VehiclePickupInfo[ id ][ piVeh_Permission ] = posao;
    		VehiclePickupInfo[ id ][ piPickupID ] = 19134;
    		VehiclePickupInfo[ id ][ piPickup_Pos_X ] = PozX;
    		VehiclePickupInfo[ id ][ piPickup_Pos_Y ] = PozY;
    		VehiclePickupInfo[ id ][ piPickup_Pos_Z ] = PozZ;

    		new string[ 250 ]; 
			format(string, sizeof(string), ""col_server"[Job Vehicle]\n"col_white"Job: "col_server"%s\n"col_white"CMD: "col_server"/jobveh or /jv", getJobName( posao ) );
    		VehiclePickupInfo[ id] [ piLabel ] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, VehiclePickupInfo[ id ][ piPickup_Pos_X ], VehiclePickupInfo[ id ][ piPickup_Pos_Y ], VehiclePickupInfo[ id ][ piPickup_Pos_Z ], 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
			VehiclePickupInfo[ id ][ piPickup ] = CreateDynamicPickup( VehiclePickupInfo[ id ][ piPickupID ], 1, VehiclePickupInfo[ id ][ piPickup_Pos_X ], VehiclePickupInfo[ id ][ piPickup_Pos_Y ], VehiclePickupInfo[ id ][ piPickup_Pos_Z ], 0, 0);

			SendInfoMessage( playerid, "Now create a vehicle and save the position with the command /savevehpos ");
			createPickupVehicle[ playerid ] = id;	                
		}		
	}
	else if( dialogid == dialog_VEHTYPE_ADMIN  ) {
	    if( response ) {
	        if( ServerInfo[ BrojKreiranihVozila ] > MaxBrojKreiranih ) return SCM( playerid, ANTICHEAT, "[ANTICHEAT]"col_white" It is currently impossible to create a vehicle, the vehicle limit on the server has been reached.");
		    new idauta, Float:PozX, Float:PozY, Float:PozZ, boja1, boja2;
		    GetPlayerPos( playerid, PozX, PozY, PozZ );
		    if(carspawntimer == 1)
		    {
				SendClientMessageEx( playerid, ANTICHEAT, "[ANTICHEAT] "col_white"Someone spawn/parked a vehicle in front of you. Try after 3 seconds. (Anticrash)");
				return 1;
		    }

		    new id = -1;
		    for( new counter = 1; counter < MAX_VEHICLE_PICKUPS; counter++ ) {
		    	if( VehiclePickupInfo[ counter ][ piSQLID ] == 0 ) {
		    		id = counter;
		    		break;
		    	}
		    }
		    if( id == -1) return SendErrorMessage( playerid, "There is no more room for pickups!");


		    if( sscanf( inputtext, "iii", idauta, boja1, boja2 ) ) return SPD( playerid, dialog_VEHTYPE_JOB, DSI, D_INFO_TEXT, "Enter the desired car id, color id1, color id2.", FirstButton, SecondButton_2 );
			if( idauta < 400 || idauta > 611 ) return SPD( playerid, dialog_VEHTYPE_JOB, DSI, D_INFO_TEXT, "Enter the desired car id, color id1, color id2.", FirstButton, SecondButton_2 );
	        if( boja1 < 0 || boja1 > 255 ) return SendErrorMessage( playerid, "The first color cannot be less than 0 or more than 255.");
    		if( boja2 < 0 || boja2 > 255 ) return SendErrorMessage( playerid, "The second color cannot be less than 0 or more than 255.");


    		VehiclePickupInfo[ id ][ piSQLID ] = -1;
    		VehiclePickupInfo[ id ][ piVeh_Model ] = idauta;
    		VehiclePickupInfo[ id ][ piVeh_Color_1 ] = boja1;
    		VehiclePickupInfo[ id ][ piVeh_Color_2 ] = boja2;
    		VehiclePickupInfo[ id ][ piVeh_Usage ] = USAGE_VEHICLE_ADMIN;
    		VehiclePickupInfo[ id ][ piVeh_Permission ] = PERM_ADMIN;
    		VehiclePickupInfo[ id ][ piPickupID ] = 1080;
    		VehiclePickupInfo[ id ][ piPickup_Pos_X ] = PozX;
    		VehiclePickupInfo[ id ][ piPickup_Pos_Y ] = PozY;
    		VehiclePickupInfo[ id ][ piPickup_Pos_Z ] = PozZ;

    		new string[ 250 ]; 
			format(string, sizeof(string), ""col_server"[Vehicle - Admin]\n"col_white"To take a vehicle, type \n"col_server"[ /takeveh or /tv ]" );
    		VehiclePickupInfo[ id] [ piLabel ] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, VehiclePickupInfo[ id ][ piPickup_Pos_X ], VehiclePickupInfo[ id ][ piPickup_Pos_Y ], VehiclePickupInfo[ id ][ piPickup_Pos_Z ], 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
			VehiclePickupInfo[ id ][ piPickup ] = CreateDynamicPickup( VehiclePickupInfo[ id ][ piPickupID ], 1, VehiclePickupInfo[ id ][ piPickup_Pos_X ], VehiclePickupInfo[ id ][ piPickup_Pos_Y ], VehiclePickupInfo[ id ][ piPickup_Pos_Z ], 0, 0);

			SendInfoMessage( playerid, "Now create a vehicle and save the position with the command /savevehpos ");
			createPickupVehicle[ playerid ] = id;	                
		}		
	}
	else if( dialogid == dialog_VEHTYPE_HELPER  ) {
	    if( response ) {
	        if( ServerInfo[ BrojKreiranihVozila ] > MaxBrojKreiranih ) return SCM( playerid, ANTICHEAT, "[ANTICHEAT]"col_white" It is currently impossible to create a vehicle, the vehicle limit on the server has been reached.");
		    new idauta, Float:PozX, Float:PozY, Float:PozZ, boja1, boja2;
		    GetPlayerPos( playerid, PozX, PozY, PozZ );
		    if(carspawntimer == 1)
		    {
				SendClientMessageEx( playerid, ANTICHEAT, "[ANTICHEAT] "col_white"Someone spawn/parked a vehicle in front of you. Try after 3 seconds. (Anticrash)");
				return 1;
		    }

		    new id = -1;
		    for( new counter = 1; counter < MAX_VEHICLE_PICKUPS; counter++ ) {
		    	if( VehiclePickupInfo[ counter ][ piSQLID ] == 0 ) {
		    		id = counter;
		    		break;
		    	}
		    }
		    if( id == -1) return SendErrorMessage( playerid, "There is no more room for pickups!");


		    if( sscanf( inputtext, "iii", idauta, boja1, boja2 ) ) return SPD( playerid, dialog_VEHTYPE_JOB, DSI, D_INFO_TEXT, "Enter the desired car id, color id1, color id2.", FirstButton, SecondButton_2 );
			if( idauta < 400 || idauta > 611 ) return SPD( playerid, dialog_VEHTYPE_JOB, DSI, D_INFO_TEXT, "Enter the desired car id, color id1, color id2.", FirstButton, SecondButton_2 );
	        if( boja1 < 0 || boja1 > 255 ) return SendErrorMessage( playerid, "The first color cannot be less than 0 or more than 255.");
    		if( boja2 < 0 || boja2 > 255 ) return SendErrorMessage( playerid, "The second color cannot be less than 0 or more than 255.");


    		VehiclePickupInfo[ id ][ piSQLID ] = -1;
    		VehiclePickupInfo[ id ][ piVeh_Model ] = idauta;
    		VehiclePickupInfo[ id ][ piVeh_Color_1 ] = boja1;
    		VehiclePickupInfo[ id ][ piVeh_Color_2 ] = boja2;
    		VehiclePickupInfo[ id ][ piVeh_Usage ] = USAGE_VEHICLE_HELPER;
    		VehiclePickupInfo[ id ][ piVeh_Permission ] = PERM_HELPER;
    		VehiclePickupInfo[ id ][ piPickupID ] = 1079;
    		VehiclePickupInfo[ id ][ piPickup_Pos_X ] = PozX;
    		VehiclePickupInfo[ id ][ piPickup_Pos_Y ] = PozY;
    		VehiclePickupInfo[ id ][ piPickup_Pos_Z ] = PozZ;

    		new string[ 250 ]; 
			format(string, sizeof(string), ""col_server"[Vehicle - Helper]\n"col_white"To take a vehicle, type \n"col_server"[ /takeveh or /tv ]" );
    		VehiclePickupInfo[ id] [ piLabel ] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, VehiclePickupInfo[ id ][ piPickup_Pos_X ], VehiclePickupInfo[ id ][ piPickup_Pos_Y ], VehiclePickupInfo[ id ][ piPickup_Pos_Z ], 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
			VehiclePickupInfo[ id ][ piPickup ] = CreateDynamicPickup( VehiclePickupInfo[ id ][ piPickupID ], 1, VehiclePickupInfo[ id ][ piPickup_Pos_X ], VehiclePickupInfo[ id ][ piPickup_Pos_Y ], VehiclePickupInfo[ id ][ piPickup_Pos_Z ], 0, 0);

			SendInfoMessage( playerid, "Now create a vehicle(/veh) and save the position with the command /savevehpos ");
			createPickupVehicle[ playerid ] = id;	                
		}		
	}
	else if( dialogid == dialog_VEHTYPE_VIP  ) {
	    if( response ) {
	        if( ServerInfo[ BrojKreiranihVozila ] > MaxBrojKreiranih ) return SCM( playerid, ANTICHEAT, "[ANTICHEAT]"col_white" It is currently impossible to create a vehicle, the vehicle limit on the server has been reached.");
		    new idauta, Float:PozX, Float:PozY, Float:PozZ, boja1, boja2;
		    GetPlayerPos( playerid, PozX, PozY, PozZ );
		    if(carspawntimer == 1)
		    {
				SendClientMessageEx( playerid, ANTICHEAT, "[ANTICHEAT] "col_white"Someone spawn/parked a vehicle in front of you. Try after 3 seconds. (Anticrash)");
				return 1;
		    }

		    new id = -1;
		    for( new counter = 1; counter < MAX_VEHICLE_PICKUPS; counter++ ) {
		    	if( VehiclePickupInfo[ counter ][ piSQLID ] == 0 ) {
		    		id = counter;
		    		break;
		    	}
		    }
		    if( id == -1) return SendErrorMessage( playerid, "There is no more room for pickups!");


		    if( sscanf( inputtext, "iii", idauta, boja1, boja2 ) ) return SPD( playerid, dialog_VEHTYPE_JOB, DSI, D_INFO_TEXT, "Enter the desired car id, color id1, color id2.", FirstButton, SecondButton_2 );
			if( idauta < 400 || idauta > 611 ) return SPD( playerid, dialog_VEHTYPE_JOB, DSI, D_INFO_TEXT, "Enter the desired car id, color id1, color id2.", FirstButton, SecondButton_2 );
	        if( boja1 < 0 || boja1 > 255 ) return SendErrorMessage( playerid, "The first color cannot be less than 0 or more than 255.");
    		if( boja2 < 0 || boja2 > 255 ) return SendErrorMessage( playerid, "The second color cannot be less than 0 or more than 255.");


    		VehiclePickupInfo[ id ][ piSQLID ] = -1;
    		VehiclePickupInfo[ id ][ piVeh_Model ] = idauta;
    		VehiclePickupInfo[ id ][ piVeh_Color_1 ] = boja1;
    		VehiclePickupInfo[ id ][ piVeh_Color_2 ] = boja2;
    		VehiclePickupInfo[ id ][ piVeh_Usage ] = USAGE_VEHICLE_VIP;
    		VehiclePickupInfo[ id ][ piVeh_Permission ] = PERM_VIP;
    		VehiclePickupInfo[ id ][ piPickupID ] = 1078;
    		VehiclePickupInfo[ id ][ piPickup_Pos_X ] = PozX;
    		VehiclePickupInfo[ id ][ piPickup_Pos_Y ] = PozY;
    		VehiclePickupInfo[ id ][ piPickup_Pos_Z ] = PozZ;

    		new string[ 250 ]; 
			format(string, sizeof(string), ""col_server"[Vozilo - Vip]\n"col_white"To take a vehicle, type \n"col_server"[ /takeveh or /tv ]" );
    		VehiclePickupInfo[ id] [ piLabel ] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, VehiclePickupInfo[ id ][ piPickup_Pos_X ], VehiclePickupInfo[ id ][ piPickup_Pos_Y ], VehiclePickupInfo[ id ][ piPickup_Pos_Z ], 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
			VehiclePickupInfo[ id ][ piPickup ] = CreateDynamicPickup( VehiclePickupInfo[ id ][ piPickupID ], 1, VehiclePickupInfo[ id ][ piPickup_Pos_X ], VehiclePickupInfo[ id ][ piPickup_Pos_Y ], VehiclePickupInfo[ id ][ piPickup_Pos_Z ], 0, 0);

			SendInfoMessage( playerid, "Now create a vehicle and save the position with the command /savevehpos ");
			createPickupVehicle[ playerid ] = id;	                
		}		
	}
	else if( dialogid == dialog_VEHTYPE_PROMOTER  ) {
	    if( response ) {
	        if( ServerInfo[ BrojKreiranihVozila ] > MaxBrojKreiranih ) return SCM( playerid, ANTICHEAT, "[ANTICHEAT]"col_white" It is currently impossible to create a vehicle, the vehicle limit on the server has been reached.");
		    new idauta, Float:PozX, Float:PozY, Float:PozZ, boja1, boja2;
		    GetPlayerPos( playerid, PozX, PozY, PozZ );
		    if(carspawntimer == 1)
		    {
				SendClientMessageEx( playerid, ANTICHEAT, "[ANTICHEAT] "col_white"Someone spawned/parked a vehicle in front of you. Try after 3 seconds. (Anticrash)");
				return 1;
		    }

		    new id = -1;
		    for( new counter = 1; counter < MAX_VEHICLE_PICKUPS; counter++ ) {
		    	if( VehiclePickupInfo[ counter ][ piSQLID ] == 0 ) {
		    		id = counter;
		    		break;
		    	}
		    }
		    if( id == -1) return SendErrorMessage( playerid, "There is no more room for pickups!");


		    if( sscanf( inputtext, "iii", idauta, boja1, boja2 ) ) return SPD( playerid, dialog_VEHTYPE_JOB, DSI, D_INFO_TEXT, "Enter the desired car id, color id1, color id2.", FirstButton, SecondButton_2 );
			if( idauta < 400 || idauta > 611 ) return SPD( playerid, dialog_VEHTYPE_JOB, DSI, D_INFO_TEXT, "Enter the desired car id, color id1, color id2.", FirstButton, SecondButton_2 );
	        if( boja1 < 0 || boja1 > 255 ) return SendErrorMessage( playerid, "The first color cannot be less than 0 or more than 255.");
    		if( boja2 < 0 || boja2 > 255 ) return SendErrorMessage( playerid, "The second color cannot be less than 0 or more than 255.");


    		VehiclePickupInfo[ id ][ piSQLID ] = -1;
    		VehiclePickupInfo[ id ][ piVeh_Model ] = idauta;
    		VehiclePickupInfo[ id ][ piVeh_Color_1 ] = boja1;
    		VehiclePickupInfo[ id ][ piVeh_Color_2 ] = boja2;
    		VehiclePickupInfo[ id ][ piVeh_Usage ] = USAGE_VEHICLE_PROMOTER;
    		VehiclePickupInfo[ id ][ piVeh_Permission ] = PERM_PROMOTER;
    		VehiclePickupInfo[ id ][ piPickupID ] = 1077;
    		VehiclePickupInfo[ id ][ piPickup_Pos_X ] = PozX;
    		VehiclePickupInfo[ id ][ piPickup_Pos_Y ] = PozY;
    		VehiclePickupInfo[ id ][ piPickup_Pos_Z ] = PozZ;

    		new string[ 250 ]; 
			format(string, sizeof(string), ""col_server"[Vehicle - Promoters]\n"col_white"To take a vehicle, type \n"col_server"[ /takeveh or /tv ]" );
    		VehiclePickupInfo[ id] [ piLabel ] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, VehiclePickupInfo[ id ][ piPickup_Pos_X ], VehiclePickupInfo[ id ][ piPickup_Pos_Y ], VehiclePickupInfo[ id ][ piPickup_Pos_Z ], 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
			VehiclePickupInfo[ id ][ piPickup ] = CreateDynamicPickup( VehiclePickupInfo[ id ][ piPickupID ], 1, VehiclePickupInfo[ id ][ piPickup_Pos_X ], VehiclePickupInfo[ id ][ piPickup_Pos_Y ], VehiclePickupInfo[ id ][ piPickup_Pos_Z ], 0, 0);

			SendInfoMessage( playerid, "Now create a vehicle and save the position with the command /savevehpos ");
			createPickupVehicle[ playerid ] = id;	                
		}		
	}
	return true;
}

//=====================[ Commands ]================================

CMD:savevehpos( playerid ) {
	if( gPlayerData[ playerid ][ E_PLAYER_ADMIN_LEVEL ] < 7 ) return SendErrorMessage( playerid, "You are not authorized to use this command! ");
	if( !IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) != PLAYER_STATE_DRIVER ) return SendErrorMessage( playerid, "You are not in the vehicle or you are not in the driver's seat");
	if( createPickupVehicle[ playerid ] == -1 ) return SendErrorMessage( playerid, "You are not in the process of creating a vehicle ");
	new vehicleID = GetPlayerVehicleID(playerid), id = createPickupVehicle[ playerid ];
	if( AdminVozilo[ playerid ] != vehicleID ) return SendErrorMessage( playerid, "You must create an admin vehicle to complete the process." );
	new Float:posX, Float:posY, Float:posZ, Float:posA;
	GetVehiclePos(vehicleID, posX, posY, posZ); 
	GetVehicleZAngle(vehicleID, posA);
	VehiclePickupInfo[ id ][ piVeh_Pos_X ] = posX;
    VehiclePickupInfo[ id ][ piVeh_Pos_Y ] = posY;
    VehiclePickupInfo[ id ][ piVeh_Pos_Z ] = posZ;
    VehiclePickupInfo[ id ][ piVeh_Pos_A ] = posA;
    mSQL_CreateVehiclePickup( playerid, id );

    ResetVehicle( vehicleID );
    KGEyes_DestroyVehicle( vehicleID, 11 );
    AdminVozilo[ playerid ] = -1;

	SendInfoMessage( playerid, "You have successfully saved the position and completed the creation." );
 	return true;
}
CMD:takeveh( playerid ) {
	new id = GetNearestPickupVehicle( playerid ); 
	if( id == -1 ) return SendErrorMessage( playerid, "You are not close to vehicle spawn pickup");
	if( VehiclePickupInfo[ id ][ piVeh_Usage ] == USAGE_VEHICLE_JOB ) return SendErrorMessage( playerid, "Only job vehicles can be taken from here");
	else {
		switch( VehiclePickupInfo[ id ][ piVeh_Usage ] ) {
			case USAGE_VEHICLE_ADMIN: {
				if( VehiclePickupInfo[ id ][ piVeh_Permission ] == PERM_ADMIN ) {
					if(gPlayerData[ playerid ][ E_PLAYER_ADMIN_LEVEL ] < 1 ) 
						return SendErrorMessage( playerid, "You are not authorized to take an administrative vehicle");
					if( PickupedVehicle[ playerid ] != -1 ) {
						VehicleObjectCheck( PickupedVehicle[ playerid ] );
						gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_TYPE ] = 0;
						gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_JOB ] = 0;
						ResetVehicle( PickupedVehicle[ playerid ] );
						KGEyes_DestroyVehicle( PickupedVehicle[ playerid ], 11 );
						PickupedVehicle[ playerid ] = -1;
						pickupedTimer[ playerid ] = -1;
						pickupedVehicleEnter[ playerid ] = false;
					}
					PickupedVehicle[ playerid ] = KGEyes_CreateVehicle(VehiclePickupInfo[ id ][ piVeh_Model ], VehiclePickupInfo[id][piVeh_Pos_X], VehiclePickupInfo[id][piVeh_Pos_Y], VehiclePickupInfo[id][piVeh_Pos_Z], VehiclePickupInfo[id][piVeh_Pos_A], VehiclePickupInfo[ id ][ piVeh_Color_1], VehiclePickupInfo[ id ][ piVeh_Color_2], -1 );
					LinkVehicleToInterior( PickupedVehicle[ playerid ], GetPlayerInterior( playerid ) );
					SetVehicleVirtualWorld( PickupedVehicle[ playerid ], GetPlayerVirtualWorld( playerid ) );
					ResetVehicle( PickupedVehicle[ playerid ] );
					ResetVehicleStatistics( PickupedVehicle[ playerid ] );

					gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_TYPE ] = e_VEHICLE_TYPE_ADMIN;
					gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_JOB ] = 0;
					new engine, lights, alarm, doors, bonnet, boot, objective;

					GetVehicleParamsEx( PickupedVehicle[ playerid ], engine, lights, alarm, doors, bonnet, boot, objective );
					SetVehicleParamsEx( PickupedVehicle[ playerid ], 0, 0, alarm, 0, 0, 0, objective );
					SendInfoMessage(playerid, "You have created an administrative vehicle, type /rveh to return it.");
					pickupedTimer[ playerid ] = 2;
					pickupedVehicleEnter[ playerid ] = false;
				}
			}
			case USAGE_VEHICLE_HELPER: {
				if( VehiclePickupInfo[ id ][ piVeh_Permission ] == PERM_HELPER ) {
					if(gPlayerData[ playerid ][ E_PLAYER_ADMIN_LEVEL ] < 1 && gPlayerData[ playerid ][ E_PLAYER_HELPER ] < 1 ) 
						return SendErrorMessage( playerid, "You are not authorized to take a helper vehicle");
					if( PickupedVehicle[ playerid ] != -1 ) {
						VehicleObjectCheck( PickupedVehicle[ playerid ] );
						gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_TYPE ] = 0;
						gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_JOB ] = 0;
						ResetVehicle( PickupedVehicle[ playerid ] );
						KGEyes_DestroyVehicle( PickupedVehicle[ playerid ], 11 );
						PickupedVehicle[ playerid ] = -1;
						pickupedTimer[ playerid ] = -1;
						pickupedVehicleEnter[ playerid ] = false;
					}
					PickupedVehicle[ playerid ] = KGEyes_CreateVehicle(VehiclePickupInfo[ id ][ piVeh_Model ], VehiclePickupInfo[id][piVeh_Pos_X], VehiclePickupInfo[id][piVeh_Pos_Y], VehiclePickupInfo[id][piVeh_Pos_Z], VehiclePickupInfo[id][piVeh_Pos_A], VehiclePickupInfo[ id ][ piVeh_Color_1], VehiclePickupInfo[ id ][ piVeh_Color_2], -1 );
					LinkVehicleToInterior( PickupedVehicle[ playerid ], GetPlayerInterior( playerid ) );
					SetVehicleVirtualWorld( PickupedVehicle[ playerid ], GetPlayerVirtualWorld( playerid ) );
					ResetVehicle( PickupedVehicle[ playerid ] );
					ResetVehicleStatistics( PickupedVehicle[ playerid ] );
					gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_TYPE ] = e_VEHICLE_TYPE_HELPER;
					gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_JOB ] = 0;
					new engine, lights, alarm, doors, bonnet, boot, objective;

					GetVehicleParamsEx( PickupedVehicle[ playerid ], engine, lights, alarm, doors, bonnet, boot, objective );
					SetVehicleParamsEx( PickupedVehicle[ playerid ], 0, 0, alarm, 0, 0, 0, objective );
					SendInfoMessage(playerid, "You have created a helper vehicle, type /rveh to return it.");
					//SendInfoMessage( playerid, "To return it, type: "col_server"/rveh ");
					pickupedTimer[ playerid ] = 2;
					pickupedVehicleEnter[ playerid ] = false;
					//SendInfoMessage( playerid, "If you do not enter the vehicle within 2 minutes, it will automatically be destroyed");
				}
			}
			case USAGE_VEHICLE_VIP: {
				if( VehiclePickupInfo[ id ][ piVeh_Permission ] == PERM_VIP ) {
					if( gPlayerData[ playerid ][ E_PLAYER_ADMIN_LEVEL ] < 6 && gPlayerData[ playerid ][ E_PLAYER_VIP_LEVEL ] < 1 ) 
						return SendErrorMessage( playerid, "You are not authorized to take a VIP vehicle");
					if( PickupedVehicle[ playerid ] != -1 ) {
						VehicleObjectCheck( PickupedVehicle[ playerid ] );
						gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_TYPE ] = 0;
						gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_JOB ] = 0;
						ResetVehicle( PickupedVehicle[ playerid ] );
						KGEyes_DestroyVehicle( PickupedVehicle[ playerid ], 11 );
						PickupedVehicle[ playerid ] = -1;
						pickupedTimer[ playerid ] = -1;
						pickupedVehicleEnter[ playerid ] = false;
					}
					PickupedVehicle[ playerid ] = KGEyes_CreateVehicle(VehiclePickupInfo[ id ][ piVeh_Model ], VehiclePickupInfo[id][piVeh_Pos_X], VehiclePickupInfo[id][piVeh_Pos_Y], VehiclePickupInfo[id][piVeh_Pos_Z], VehiclePickupInfo[id][piVeh_Pos_A], VehiclePickupInfo[ id ][ piVeh_Color_1], VehiclePickupInfo[ id ][ piVeh_Color_2], -1 );
					LinkVehicleToInterior( PickupedVehicle[ playerid ], GetPlayerInterior( playerid ) );
					SetVehicleVirtualWorld( PickupedVehicle[ playerid ], GetPlayerVirtualWorld( playerid ) );
					ResetVehicle( PickupedVehicle[ playerid ] );
					ResetVehicleStatistics( PickupedVehicle[ playerid ] );

					gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_TYPE ] = e_VEHICLE_TYPE_VIP;
					gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_JOB ] = 0;
					new engine, lights, alarm, doors, bonnet, boot, objective;

					GetVehicleParamsEx( PickupedVehicle[ playerid ], engine, lights, alarm, doors, bonnet, boot, objective );
					SetVehicleParamsEx( PickupedVehicle[ playerid ], 0, 0, alarm, 0, 0, 0, objective );
					SendInfoMessage(playerid, "You have created a VIP vehicle, type /rveh to return it.");
					//SendInfoMessage( playerid, "To return it, type: "col_server"/rveh ");
					pickupedTimer[ playerid ] = 2;
					pickupedVehicleEnter[ playerid ] = false;
					//SendInfoMessage( playerid, "If you do not enter the vehicle within 2 minutes, it will automatically be destroyed");
				}
			}
			case USAGE_VEHICLE_PROMOTER: {
				if( VehiclePickupInfo[ id ][ piVeh_Permission ] == PERM_PROMOTER ) {
					if(gPlayerData[ playerid ][ E_PLAYER_ADMIN_LEVEL ] < 6 && gPlayerData[ playerid ][ E_PLAYER_SPECIAL_LEVEL ] < 1 ) 
						return SendErrorMessage( playerid, "You are not authorized to take a promoter vehicle");
					if( PickupedVehicle[ playerid ] != -1 ) {
						VehicleObjectCheck( PickupedVehicle[ playerid ] );
						gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_TYPE ] = 0; 
						gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_JOB ] = 0;
						ResetVehicle( PickupedVehicle[ playerid ] );
						KGEyes_DestroyVehicle( PickupedVehicle[ playerid ], 11 );
						PickupedVehicle[ playerid ] = -1;
						pickupedTimer[ playerid ] = -1;
						pickupedVehicleEnter[ playerid ] = false;
					}
					PickupedVehicle[ playerid ] = KGEyes_CreateVehicle(VehiclePickupInfo[ id ][ piVeh_Model ], VehiclePickupInfo[id][piVeh_Pos_X], VehiclePickupInfo[id][piVeh_Pos_Y], VehiclePickupInfo[id][piVeh_Pos_Z], VehiclePickupInfo[id][piVeh_Pos_A], VehiclePickupInfo[ id ][ piVeh_Color_1], VehiclePickupInfo[ id ][ piVeh_Color_2], -1 );
					LinkVehicleToInterior( PickupedVehicle[ playerid ], GetPlayerInterior( playerid ) );
					SetVehicleVirtualWorld( PickupedVehicle[ playerid ], GetPlayerVirtualWorld( playerid ) );
					ResetVehicle( PickupedVehicle[ playerid ] );
					ResetVehicleStatistics( PickupedVehicle[ playerid ] );
					gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_TYPE ] = e_VEHICLE_TYPE_SPECIAL; 
					gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_JOB ] = 0;
					new engine, lights, alarm, doors, bonnet, boot, objective;

					GetVehicleParamsEx( PickupedVehicle[ playerid ], engine, lights, alarm, doors, bonnet, boot, objective );
					SetVehicleParamsEx( PickupedVehicle[ playerid ], 0, 0, alarm, 0, 0, 0, objective );
					SendInfoMessage(playerid, "You have created a promoter vehicle, type /rveh to return it.");
					//SendInfoMessage( playerid, "To return it, type: "col_server"/rveh ");
					pickupedTimer[ playerid ] = 2;
					pickupedVehicleEnter[ playerid ] = false;
					//SendInfoMessage( playerid, "If you do not enter the vehicle within 2 minutes, it will automatically be destroyed");
				}
			}
		}
	}
	return true;
}
alias:takeveh("tv");

CMD:jobveh( playerid ) {
	new id = GetNearestPickupVehicle( playerid ); 
	if( id == -1 ) return SendErrorMessage( playerid, "You are not close to job vehicle spawn point.");
	if( VehiclePickupInfo[ id ][ piVeh_Usage ] != USAGE_VEHICLE_JOB ) return SendErrorMessage( playerid, "You are not close to job vehicle spawn point.");
	if( VehiclePickupInfo[ id ][ piVeh_Permission ] != gPlayerData[ playerid ][ E_PLAYER_JOB ] ) return SendErrorMessage( playerid, "You don't have this job!");
	/*new jobID = gPlayerData[ playerid ][ E_PLAYER_JOB ] - 1;
	if( jobsInfos[ jobID ][ jUniformPos ] != 0 || jobsInfos[ jobID ][ jUniformSkin_Male ] != 0 ){
		if( !UzeoOpremu[ playerid ] ) return SendErrorMessage( playerid, "To take a job vehicle, you need to put on job uniform");
	}*/
	
	if( PickupedVehicle[ playerid ] != -1 ) 
		return SendErrorMessage(playerid, "You have already taken the job vehicle, return it with command /returnjobveh or /rjv !");
	

	PickupedVehicle[ playerid ] = KGEyes_CreateVehicle(VehiclePickupInfo[ id ][ piVeh_Model ], VehiclePickupInfo[id][piVeh_Pos_X], VehiclePickupInfo[id][piVeh_Pos_Y], VehiclePickupInfo[id][piVeh_Pos_Z], VehiclePickupInfo[id][piVeh_Pos_A], VehiclePickupInfo[ id ][ piVeh_Color_1], VehiclePickupInfo[ id ][ piVeh_Color_2], -1 );
	LinkVehicleToInterior( PickupedVehicle[ playerid ], GetPlayerInterior( playerid ) );
	SetVehicleVirtualWorld( PickupedVehicle[ playerid ], GetPlayerVirtualWorld( playerid ) );
	ResetVehicle( PickupedVehicle[ playerid ] );
	ResetVehicleStatistics( PickupedVehicle[ playerid ] );
	gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_TYPE ] = e_VEHICLE_TYPE_JOB;
	gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_JOB ] = gPlayerData[ playerid ][ E_PLAYER_JOB ];
	new engine, lights, alarm, doors, bonnet, boot, objective;

	GetVehicleParamsEx( PickupedVehicle[ playerid ], engine, lights, alarm, doors, bonnet, boot, objective );
	SetVehicleParamsEx( PickupedVehicle[ playerid ], 0, 0, alarm, 0, 0, 0, objective );
	pickupedTimer[ playerid ] = 2;
	pickupedVehicleEnter[ playerid ] = false;
	SendInfoMessage( playerid, "You spawned %s job vehicle, type /rjv to return it.", getJobName( gPlayerData[ playerid ][ E_PLAYER_JOB ] ));
	return true;
}

alias:jobveh("jv");

CMD:returnjobveh( playerid ) {
	if( PickupedVehicle[ playerid ] != -1 && gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_TYPE ] == e_VEHICLE_TYPE_JOB) {
		VehicleObjectCheck( PickupedVehicle[ playerid ] );
		gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_TYPE ] = 0;
		gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_JOB ] = 0;
		ResetVehicle( PickupedVehicle[ playerid ] );
		KGEyes_DestroyVehicle( PickupedVehicle[ playerid ], 11 );
		PickupedVehicle[ playerid ] = -1;
		pickupedTimer[ playerid ] = -1;
		pickupedVehicleEnter[ playerid ] = false;
		SendInfoMessage( playerid, "You have returned your job vehicle");
	}
	else return SendErrorMessage( playerid, "You have not taken a job vehicle!");
	return true;
}

alias:returnjobveh("rjv");

CMD:rveh( playerid ) {
	if( PickupedVehicle[ playerid ] != -1 && GetUsageForVehicleStaff( PickupedVehicle[ playerid ] ) != -1 ) {
		VehicleObjectCheck( PickupedVehicle[ playerid ] );
		gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_TYPE ] = 0;
		gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_JOB ] = 0;
		ResetVehicle( PickupedVehicle[ playerid ] );
		KGEyes_DestroyVehicle( PickupedVehicle[ playerid ], 11 );
		PickupedVehicle[ playerid ] = -1;
		SendInfoMessage( playerid, "You returned your vehicle");
		pickupedTimer[ playerid ] = -1;
		pickupedVehicleEnter[ playerid ] = false;
	}
	else return SendErrorMessage( playerid, "You did not take a vehicle!");
	return true;
}

//alias:returnveh("rveh");

//=====================[ Stocks]===================================

/*
checkEmptyPickupVehicle( playerid ) {
	if( PickupedVehicle[ playerid ] != -1 && pickupedVehicleEnter[ playerid ] == false ) {
		if( !IsPlayerInVehicle(playerid, PickupedVehicle[ playerid ] )) {
			counterVehicleTimer[ playerid ] ++;
			if( counterVehicleTimer[ playerid ] >= pickupedTimer[ playerid] ) {
				if( pickupedTimer[ playerid ] == 2 || pickupedTimer[ playerid ] == 5) {
					SendInfoMessage( playerid, "Your job vehicle was destroyed as it stayed empty for long!");
				}
				SendInfoMessage( playerid, "You have returned your job vehicle");
				VehicleObjectCheck( PickupedVehicle[ playerid ] );
				gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_TYPE ] = 0;
				gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_JOB ] = 0;
				ResetVehicle( PickupedVehicle[ playerid ] );
				KGEyes_DestroyVehicle( PickupedVehicle[ playerid ], 11 );
				PickupedVehicle[ playerid ] = -1;
				pickupedTimer[ playerid ] = -1;
				pickupedVehicleEnter[ playerid ] = false;
			}
		}
	}
}*/


//=====================[ Publics ]=================================

public LoadPickupVehicles( ) {
	new rows, fields, thisID, rowsCounter = 1, string[250];
    cache_get_data( rows, fields, _dbConnector );

	if( rows )
	{
		for( new i = 0; i < rows; i ++ )
		{
			thisID = rowsCounter;
			VehiclePickupInfo[ thisID ][ piSQLID ] = cache_get_field_content_int( i , "id" );
			VehiclePickupInfo[ thisID ][ piPickup_Pos_X ] = cache_get_field_content_float( i  , "pickup_pos_x" );
			VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ] = cache_get_field_content_float( i  , "pickup_pos_y" );
			VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ] = cache_get_field_content_float( i  , "pickup_pos_z" );
			VehiclePickupInfo[ thisID ][ piVeh_Usage ] = cache_get_field_content_int( i , "vehicle_usage" );
			VehiclePickupInfo[ thisID ][ piVeh_Model ] = cache_get_field_content_int( i , "vehicle_id" );
			VehiclePickupInfo[ thisID ][ piVeh_Permission ] = cache_get_field_content_int( i , "vehicle_perm" );
			VehiclePickupInfo[ thisID ][ piVeh_Pos_X ] = cache_get_field_content_float( i  , "vehicle_pos_x" );
			VehiclePickupInfo[ thisID ][ piVeh_Pos_Y ] = cache_get_field_content_float( i  , "vehicle_pos_y" );
			VehiclePickupInfo[ thisID ][ piVeh_Pos_Z ] = cache_get_field_content_float( i  , "vehicle_pos_z" );
			VehiclePickupInfo[ thisID ][ piVeh_Pos_A ] = cache_get_field_content_float( i , "vehicle_pos_a" );	
			VehiclePickupInfo[ thisID ][ piVeh_Color_1 ] = cache_get_field_content_int( i , "vehicle_color1" );
			VehiclePickupInfo[ thisID ][ piVeh_Color_2 ] = cache_get_field_content_int( i , "vehicle_color2" );
			VehiclePickupInfo[ thisID ][ piPickupID ] = cache_get_field_content_int( i, "pickup_id");
 
			switch( VehiclePickupInfo[ thisID ][ piVeh_Usage ] ) {
				case USAGE_VEHICLE_JOB: {
					format(string, sizeof(string), ""col_server"[Job Vehicle]\n"col_white"Job: "col_server"%s\n"col_white"CMD: "col_server"/jobveh or /jv", getJobName( VehiclePickupInfo[ thisID ][ piVeh_Permission ] ) );
    				VehiclePickupInfo[ thisID ][ piLabel ] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
					VehiclePickupInfo[ thisID ][ piPickup ] = CreateDynamicPickup( VehiclePickupInfo[ thisID ][ piPickupID ], 1, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 0, 0);
				}
				case USAGE_VEHICLE_ADMIN: {
					format(string, sizeof(string), ""col_server"[Vehicle - Admin]\n"col_white"To take a vehicle, type \n"col_server"[ /takeveh or /tv ]" );
		    		VehiclePickupInfo[ thisID ][ piLabel ] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
					VehiclePickupInfo[ thisID ][ piPickup ] = CreateDynamicPickup( VehiclePickupInfo[ thisID ][ piPickupID ], 1, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 0, 0);
				}
				case USAGE_VEHICLE_HELPER: {
					format(string, sizeof(string), ""col_server"[Vehicle - Helper]\n"col_white"To take a vehicle, type \n"col_server"[ /takeveh or /tv ]" );
		    		VehiclePickupInfo[ thisID ][ piLabel ] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
					VehiclePickupInfo[ thisID ][ piPickup ] = CreateDynamicPickup( VehiclePickupInfo[ thisID ][ piPickupID ], 1, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 0, 0);
				}
				case USAGE_VEHICLE_VIP: {
					format(string, sizeof(string), ""col_server"[Vehicle - Vip]\n"col_white"To take a vehicle, type \n"col_server"[ /takeveh or /tv ]" );
		    		VehiclePickupInfo[ thisID ][ piLabel ] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
					VehiclePickupInfo[ thisID ][ piPickup ] = CreateDynamicPickup( VehiclePickupInfo[ thisID ][ piPickupID ], 1, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 0, 0);
				}
				case USAGE_VEHICLE_PROMOTER: {
					format(string, sizeof(string), ""col_server"[Vehicle - Promoter]\n"col_white"To take a vehicle, type \n"col_server"[ /takeveh or /tv ]" );
		    		VehiclePickupInfo[ thisID ][ piLabel ] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
					VehiclePickupInfo[ thisID ][ piPickup ] = CreateDynamicPickup( VehiclePickupInfo[ thisID ][ piPickupID ], 1, VehiclePickupInfo[ thisID ][ piPickup_Pos_X ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Y ], VehiclePickupInfo[ thisID ][ piPickup_Pos_Z ], 0, 0);
				}
			}
			rowsCounter++;
		}
	}
	printf("[LOADED] %d pickup vehicles", rowsCounter - 1);
	return ( true );
}


public mSQL_CreateVehiclePickup( playerid,  createID )
{
	static q[1000];
    mysql_format( _dbConnector, q, sizeof( q ),

		"INSERT INTO `pickup_vehicles` ( `pickup_id`\
		, `pickup_pos_x`\
		, `pickup_pos_y`\
		, `pickup_pos_z`\
		, `vehicle_usage`\
		, `vehicle_id`\
		, `vehicle_color1`\
		, `vehicle_color2`\
		, `vehicle_perm`\
		, `vehicle_pos_x`\
		, `vehicle_pos_y`\
		, `vehicle_pos_z`\
		, `vehicle_pos_a` ) \
		VALUES( '%d'\
		, '%f'\
		, '%f'\
		, '%f'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%f'\
		, '%f'\
		, '%f'\
		, '%f' )"\
		, VehiclePickupInfo[createID][piPickupID]\
		, VehiclePickupInfo[createID][piPickup_Pos_X]\
		, VehiclePickupInfo[createID][piPickup_Pos_Y]\
		, VehiclePickupInfo[createID][piPickup_Pos_Z]\
		, VehiclePickupInfo[createID][piVeh_Usage]\
		, VehiclePickupInfo[createID][piVeh_Model]\
		, VehiclePickupInfo[createID][piVeh_Color_1]\
		, VehiclePickupInfo[createID][piVeh_Color_2]\
		, VehiclePickupInfo[createID][piVeh_Permission]\
		, VehiclePickupInfo[createID][piVeh_Pos_X]\
		, VehiclePickupInfo[createID][piVeh_Pos_Y]\
		, VehiclePickupInfo[createID][piVeh_Pos_Z]\
		, VehiclePickupInfo[createID][piVeh_Pos_A] );

    mysql_pquery( _dbConnector, q, "OnVehiclePickupCreated", "ii", playerid,  createID );
	return(true);
}


public OnVehiclePickupCreated( playerid, id ) {
	VehiclePickupInfo[ id ][ piSQLID ] = cache_insert_id();
	SendInfoMessage(playerid, "You have created a position for pickup vehicle");
	return true;
}
//=====================[ ALS ]=====================================

public OnPlayerConnect( playerid)
{
	createPickupVehicle[ playerid ] = -1;
	editPickupVehicle[ playerid ] = -1;
	PickupedVehicle[ playerid ] = -1;
	pickupedTimer[ playerid ] = -1;
	pickupedVehicleEnter[ playerid ] = false;
	counterVehicleTimer[ playerid ] = 0;
	#if defined 	als_vpickup_OnPlayerConnect
		return 	als_vpickup_OnPlayerConnect( playerid );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect als_vpickup_OnPlayerConnect
#if defined 	als_vpickup_OnPlayerConnect
	forward 	als_vpickup_OnPlayerConnect( playerid );
#endif

public OnPlayerDisconnect(playerid, reason)
{
	if( createPickupVehicle[ playerid ] != -1 )
		createPickupVehicle[ playerid ] = -1;
	if( editPickupVehicle[ playerid ] != -1 ) 
		editPickupVehicle[ playerid ] = -1;
	
	if( PickupedVehicle[ playerid ] != -1 ) {
		VehicleObjectCheck( PickupedVehicle[ playerid ] );
		gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_TYPE ] = 0;
		gVehicleData[ PickupedVehicle[ playerid ] ][ E_VEHICLE_JOB ] = 0;
		ResetVehicle( PickupedVehicle[ playerid ] );
		KGEyes_DestroyVehicle( PickupedVehicle[ playerid ], 11 );
		PickupedVehicle[ playerid ] = -1;
	}

	pickupedTimer[ playerid ] = -1;
	pickupedVehicleEnter[ playerid ] = false;
	counterVehicleTimer[ playerid ] = 0;

	#if defined 	als_vpickup_OnPlayerDisconnect
		return 	als_vpickup_OnPlayerDisconnect( playerid, reason );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif

#define OnPlayerDisconnect als_vpickup_OnPlayerDisconnect
#if defined 	als_vpickup_OnPlayerDisconnect
	forward 	als_vpickup_OnPlayerDisconnect( playerid, reason );
#endif
