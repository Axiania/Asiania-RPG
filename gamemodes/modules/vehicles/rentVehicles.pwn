// Module For Rent Vehicles
// Skripter: Unknown
// Work Begin 20:10 11/04/2020

//=====================[ DEFINES & Player Variables]===============

#define MAX_VRENT  80
#define MAX_RENTMODELS 10


enum vRentSystem
{
	vrSQLID,
	//
	Float:vrLiP_Pos_X,
	Float:vrLiP_Pos_Y,
	Float:vrLiP_Pos_Z,
	Float:vrSpawn_Pos_X,
	Float:vrSpawn_Pos_Y,
	Float:vrSpawn_Pos_Z,
	Float:vrSpawn_Pos_A,
	vrVehModel,
	vrModel[ MAX_RENTMODELS ],
	vrPrice[ MAX_RENTMODELS ],
	vrType,
	//
	Text3D:VoziloRentLabel,
	VoziloRentPickup
}
new gRentStation[MAX_VRENT][vRentSystem];

//new PlayerText:RentTD[MAX_PLAYERS][2];


new CreateRentID[ MAX_PLAYERS ],
	choosedRentID[ MAX_PLAYERS],
	//rentTimer[ MAX_PLAYERS ],
	bool: showedRent[ MAX_PLAYERS ],
	choosedRentEditID[ MAX_PLAYERS];

new DBListRent[ MAX_PLAYERS ][ MAX_RENTMODELS];


//=====================[ FORWARDS ]================================

//forward KrajRenta( playerid, vehicleid);
forward mSQL_CreateVehicleRent( playerid,  createID );
forward OnRentCreated( playerid,  createID );
forward OnRentsLoad();
forward OnRentsListModels( playerid );
forward OnRentChangeModel( playerid, modelID );
forward OnRentRemoveModel( playerid );
forward OnRentsListPrice( playerid );
forward OnRentChangePrice( playerid, inputPrice );
//=====================[ Functions ]===============================

bool:IsVehicleMotorRent(model)
{
	switch( model )
	{
		case 448, 461, 462, 463, 468, 471, 521, 522, 523, 586, 581: return true;
	}
	return false;
}

bool:IsVehicleAutoRent(model)
{
	switch( model )
	{
		case 400, 401, 402, 404, 405, 409, 410, 411, 412, 415, 419, 420, 421, 422,
	    426, 429, 434, 436, 438, 439, 442, 445, 451, 458, 466, 467, 470, 474, 475,
		477, 478, 479, 480, 489, 490, 491, 492, 494, 495, 496, 500, 502, 503, 504,
		505, 506, 507, 516, 517, 518, 525, 526, 527, 528, 529, 533, 534, 535, 536,
		540, 541, 542, 543, 545, 546, 547, 549, 550, 551, 552, 554, 555, 558, 559,
		560, 561, 562, 565, 566, 567, 568, 575, 576, 579, 580, 585, 587, 589, 596,
		597, 598, 599, 600, 602, 603, 604, 605, 444, 457, 483, 485, 530, 531, 539,
		556, 557, 574, 424, 583, 572: return true;
	}
	return false;
}

GetNearestRentVehicle(playerid)
{
	for(new b = 0; b < MAX_VRENT; b++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 2.0, gRentStation[b][vrLiP_Pos_X], gRentStation[b][vrLiP_Pos_Y], gRentStation[b][vrLiP_Pos_Z])) return b;
	}
	return -1;
}

GetNearestRentVehicleAdmin(playerid) // Veci Range :D
{
	for(new b = 0; b < MAX_VRENT; b++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 20.0, gRentStation[b][vrLiP_Pos_X], gRentStation[b][vrLiP_Pos_Y], gRentStation[b][vrLiP_Pos_Z])) return b;
	}
	return -1;
}

RefreshRentPandL( id ) {

	if( id != -1 ) {
		new string[ 200 ];

		if(IsValidDynamic3DTextLabel(gRentStation[id][VoziloRentLabel]))
			DestroyDynamic3DTextLabel(gRentStation[id][VoziloRentLabel]);

		if(IsValidDynamicPickup(gRentStation[id][VoziloRentPickup]))
			DestroyDynamicPickup(gRentStation[id][VoziloRentPickup]);
		

		format(string, sizeof(string), "{02E102}Vehicle Rent Station: "col_white"%d\n"col_white"\nTo rent a vehicle, type\n/rentveh", id);
		gRentStation[id][VoziloRentLabel] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, gRentStation[id][vrLiP_Pos_X], gRentStation[id][vrLiP_Pos_Y], gRentStation[id][vrLiP_Pos_Z], 8.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
		gRentStation[id][VoziloRentPickup] = CreateDynamicPickup(19134, 1, gRentStation[id][vrLiP_Pos_X], gRentStation[id][vrLiP_Pos_Y], gRentStation[id][vrLiP_Pos_Z], 0, 0);
	}
}

GetPriceOfRentWithID( tempID , modelid ){
	new price = -1;
	for(new j = 0; j < MAX_RENTMODELS; j++ ) {
		if( gRentStation[ tempID ][ vrModel ][j] == modelid ) {
			price = gRentStation[ tempID ][ vrPrice ][j];
			break;
		} 
	}
	return price;
}
GetRentTypeWithModel(modelid)
{
	new id = -1;
	for(new b = 0; b < MAX_VRENT; b++)
	{
		if(gRentStation[ b ][ vrSQLID ] != 0) {
			for(new j = 0; j < MAX_RENTMODELS; j++ ) {
				if( gRentStation[ b ][ vrModel ][j] == modelid ) {
					id = b;
					break;
				} 
			}
		}
	}
	return id;
}

SaveRentEdit( playerid, rentID) {
	new query[1200]; 
	mysql_format( _dbConnector, query, sizeof(query), "UPDATE `rents` SET `vr_model_0` = '%d'\
		, `vr_model_1` = '%d'\
		, `vr_model_2` = '%d'\
		, `vr_model_3` = '%d'\
		, `vr_model_4` = '%d'\
		, `vr_model_5` = '%d'\
		, `vr_model_6` = '%d'\
		, `vr_model_7` = '%d'\
		, `vr_model_8` = '%d'\
		, `vr_model_9` = '%d'\
		, `vr_price_0` = '%d'\
		, `vr_price_1` = '%d'\
		, `vr_price_2` = '%d'\
		, `vr_price_3` = '%d'\
		, `vr_price_4` = '%d'\
		, `vr_price_5` = '%d'\
		, `vr_price_6` = '%d'\
		, `vr_price_7` = '%d'\
		, `vr_price_8` = '%d'\
		, `vr_price_9` = '%d' WHERE `vrSQLID` = '%d'"\
		, gRentStation[ rentID ][ vrModel ][0]\
		, gRentStation[ rentID ][ vrModel ][1]\
		, gRentStation[ rentID ][ vrModel ][2]\
		, gRentStation[ rentID ][ vrModel ][3]\
		, gRentStation[ rentID ][ vrModel ][4]\
		, gRentStation[ rentID ][ vrModel ][5]\
		, gRentStation[ rentID ][ vrModel ][6]\
		, gRentStation[ rentID ][ vrModel ][7]\
		, gRentStation[ rentID ][ vrModel ][8]\
		, gRentStation[ rentID ][ vrModel ][9]\
		, gRentStation[ rentID ][ vrPrice ][0]\
		, gRentStation[ rentID ][ vrPrice ][1]\
		, gRentStation[ rentID ][ vrPrice ][2]\
		, gRentStation[ rentID ][ vrPrice ][3]\
		, gRentStation[ rentID ][ vrPrice ][4]\
		, gRentStation[ rentID ][ vrPrice ][5]\
		, gRentStation[ rentID ][ vrPrice ][6]\
		, gRentStation[ rentID ][ vrPrice ][7]\
		, gRentStation[ rentID ][ vrPrice ][8]\
		, gRentStation[ rentID ][ vrPrice ][9]\
		, gRentStation[ rentID ][ vrSQLID ] );
	mysql_pquery( _dbConnector, query, "", "");
	choosedRentEditID[playerid] = -1;
}


//--Main Functions - For Mode --//

OnDialogResponseRent(playerid, dialogid, response, listitem, inputtext[]) {
	if( dialogid == dialog_TYPESRENT) {
		if( !response ) return true;
		if( response ) {
			new tip, infoDialog[ 670 ];

			if( sscanf( inputtext, "i", tip)) {
				format( infoDialog, sizeof( infoDialog),"\
					"col_server"1 "col_white"- Only "col_server"cars!\n\
					"col_server"2 "col_white"- Only "col_server"bikes!\n\
					"col_server"3 "col_white"- Both "col_server"cars and bikes "col_white"( "col_crvena"Cars and Bikes Both "col_white")!!!\n");
				return SPD( playerid, dialog_TYPESRENT, DSI, D_INFO_TEXT, infoDialog, FirstButton, SecondButton_2 );
			}
			if( tip < 1 || tip > 3) {
				format( infoDialog, sizeof( infoDialog),"\
					"col_server"1 "col_white"- Only "col_server"cars!\n\
					"col_server"2 "col_white"- Only "col_server"bikes!\n\
					"col_server"3 "col_white"- Both "col_server"cars and bikes "col_white"( "col_crvena"Cars and Bikes Both "col_white")!!!\n");
				return SPD( playerid, dialog_TYPESRENT, DSI, D_INFO_TEXT, infoDialog, FirstButton, SecondButton_2 );
			}
			gRentStation[ CreateRentID[playerid ]][ vrType ] = tip;
			switch( tip ) {
				case 1: {
					format( infoDialog, sizeof( infoDialog) , "\
						"col_white"You have selected rent type: "col_server"Cars!\n\
						"col_white"Enter the number of different types of cars "col_server"(models) "col_white"that will be found in this type of "col_crvena"vehicle rent\n\
						"col_crvena"You cannot have less than 2 models and more than 10!");
				}
				case 2: {
					format( infoDialog, sizeof( infoDialog) , "\
						"col_white"You have selected rent type: "col_server"Bikes!\n\
						"col_white"Enter the number of different types of bikes "col_server"(models) "col_white"that will be found in this type of "col_crvena"vehicle rent\n\
						"col_crvena"You cannot have less than 2 models and more than 10!");
				}
				case 3: {
					format( infoDialog, sizeof( infoDialog) , "\
						"col_white"You have selected rent type: "col_server"Cars and Bikes!\n\
						"col_white"Enter the number of different types of cars and bikes "col_server"(models) "col_white"that will be found in this type of "col_crvena"vehicle rent\n\
						"col_crvena"You cannot have less than 2 models and more than 10!");
				}
			}
			SPD( playerid, dialog_RENTMAXMODEL, DSI, D_INFO_TEXT, infoDialog, FirstButton, SecondButton_2 );
		 }
	}
	else if( dialogid == dialog_RENTMAXMODEL ) {
		if(!response ) return 1;
		if( response ) {
			new broj, id = CreateRentID[ playerid ], infoDialog[670];
			if( choosedRentEditID[ playerid ] != -1)
				id = choosedRentEditID[ playerid ];

            if( sscanf( inputtext, "i", broj ) ) {
            	switch( gRentStation[ id ][ vrType ] ) {
            		case 1: {
            			format( infoDialog, sizeof( infoDialog) , "\
            				"col_white"You have selected rent type: "col_server"Cars!\n\
            				"col_white"Enter the number of different types of cars "col_server"(models) "col_white"that will be found in this type of "col_crvena"vehicle rent\n\
            				"col_crvena"You cannot have less than 2 models and more than 10!");
            		}
            		case 2: {
            			format( infoDialog, sizeof( infoDialog) , "\
            				"col_white"You have selected rent type: "col_server"Bikes!\n\
            				"col_white"Enter the number of different types of bikes "col_server"(models) "col_white"that will be found in this type of "col_crvena"vehicle rent\n\
            				"col_crvena"You cannot have less than 2 models and more than 10!");
            		}
            		case 3: {
            			format( infoDialog, sizeof( infoDialog) , "\
            				"col_white"You have selected rent type: "col_server"Cars and Bikes!\n\
            				"col_white"Enter the number of different types of cars and bikes "col_server"(models) "col_white"that will be found in this type of "col_crvena"vehicle rent\n\
            				"col_crvena"You cannot have less than 2 models and more than 10!");
            		}
            	}
            	return SPD( playerid, dialog_RENTMAXMODEL, DSI, D_INFO_TEXT, infoDialog, FirstButton, SecondButton_2 );
            } 
           	if( broj < 2 || broj > 10 ) {
           		switch( gRentStation[ id ][ vrType ] ) {
            		case 1: {
            			format( infoDialog, sizeof( infoDialog) , "\
            				"col_white"You have selected rent type: "col_server"Cars!\n\
            				"col_white"Enter the number of different types of cars "col_server"(models) "col_white"that will be found in this type of "col_crvena"vehicle rent\n\
            				"col_crvena"You cannot have less than 2 models and more than 10!");
            		}
            		case 2: {
            			format( infoDialog, sizeof( infoDialog) , "\
            				"col_white"You have selected rent type: "col_server"Bikes!\n\
            				"col_white"Enter the number of different types of bikes "col_server"(models) "col_white"that will be found in this type of "col_crvena"vehicle rent\n\
            				"col_crvena"You cannot have less than 2 models and more than 10!");
            		}
            		case 3: {
            			format( infoDialog, sizeof( infoDialog) , "\
            				"col_white"You have selected rent type: "col_server"Cars and Bikes!\n\
            				"col_white"Enter the number of different types of cars and bikes "col_server"(models) "col_white"that will be found in this type of "col_crvena"vehicle rent\n\
            				"col_crvena"You cannot have less than 2 models and more than 10!");
            		}
            	}
            	return SPD( playerid, dialog_RENTMAXMODEL, DSI, D_INFO_TEXT, infoDialog, FirstButton, SecondButton_2 );
           	} 
			gRentStation[ id ][ vrVehModel ] = broj;
			if( choosedRentEditID [ playerid ] != -1) {
				for(new b = 0; b < MAX_RENTMODELS; b++) {
					gRentStation[ id ][ vrModel ][ b ] = 0;
					gRentStation[ id ][ vrPrice ][ b ] = 0;
				}
			}
			SendClientMessageEx( playerid, BELA, "You chose "col_server"%d types of models.", broj );
			
			switch( broj ) {
				case 2: {
					if( gRentStation[ id ][ vrType ] == 1) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the two vehicle models that will be in the rental selection.\nExample: 401 402", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the two vehicle models that will be in the rental selection.\nExample: 448, 461", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 3) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the two vehicle models that will be in the rental selection.\nExample: 401, 461", FirstButton, SecondButton_2 );
					}
				}
				case 3: {
					if( gRentStation[ id ][ vrType ] == 1) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 3 vehicle models that will be in the rental selection.\nExample: 401 402 404", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 3 vehicle models that will be in the rental selection.\nExample: 448 461 462", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 3) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 3 vehicle models that will be in the rental selection.\nExample: 401 461 451", FirstButton, SecondButton_2 );
					}
				}
				case 4: {
					if( gRentStation[ id ][ vrType ] == 1) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 4 vehicle models that will be in the rental selection.\nExample: 401 402 404 405", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 4 vehicle models that will be in the rental selection.\nExample: 448 461 462 463", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 3) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 4 vehicle models that will be in the rental selection.\nExample: 401 461 451 463", FirstButton, SecondButton_2 );
					}
				}
				case 5: {
					if( gRentStation[ id ][ vrType ] == 1) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 5 vehicle models that will be in the rental selection.\nExample: 401 402 404 405 409", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 5 vehicle models that will be in the rental selection.\nExample: 448 461 462 463 468", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 3) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 5 vehicle models that will be in the rental selection.\nExample: 401 461 451 463 410", FirstButton, SecondButton_2 );
					}
				}
				case 6: {
					if( gRentStation[ id ][ vrType ] == 1) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 6 vehicle models that will be in the rental selection.\nExample: 401 402 404 405 409 410", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 6 vehicle models that will be in the rental selection.\nExample: 448 461 462 463 468 471 ", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 3) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 6 vehicle models that will be in the rental selection.\nExample: 401 461 451 463 410 521", FirstButton, SecondButton_2 );
					}
				}
				case 7: {
					if( gRentStation[ id ][ vrType ] == 1) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 7 vehicle models that will be in the rental selection.\nExample: 401 402 404 405 409 410 411 ", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 7 vehicle models that will be in the rental selection.\nExample: 448 461 462 463 468 471 521 ", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 3) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 7 vehicle models that will be in the rental selection.\nExample: 401 461 451 463 410 521 560", FirstButton, SecondButton_2 );
					}
				}
				case 8: {
					if( gRentStation[ id ][ vrType ] == 1) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 8 vehicle models that will be in the rental selection.\nExample: 401 402 404 405 409 410 411 412", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 8 vehicle models that will be in the rental selection.\nExample: 448 461 462 463 468 471 521 522", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 3) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 8 vehicle models that will be in the rental selection.\nExample: 401 461 451 463 410 521 560 522", FirstButton, SecondButton_2 );
					}
				}
				case 9: {
					if( gRentStation[ id ][ vrType ] == 1) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 9 vehicle models that will be in the rental selection.\nExample: 401 402 404 405 409 410 411 412 415", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 9 vehicle models that will be in the rental selection.\nExample: 448 461 462 463 468 471 521 522 523", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 3) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the 9 vehicle models that will be in the rental selection.\nExample: 401 461 451 463 410 521 560 522 415", FirstButton, SecondButton_2 );
					}
				}
				case 10: {
					if( gRentStation[ id ][ vrType ] == 1) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter 10 vehicle models that will be in the rental selection.\nExample: 401 402 404 405 409 410 411 412 415 419", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter 10 vehicle models that will be in the rental selection.\nExample: 448 461 462 463 468 471 521 522 523 586", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 3) {
						SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter 10 vehicle models that will be in the rental selection.\nExample: 401 461 451 463 410 521 560 522 415 523", FirstButton, SecondButton_2 );
					}
				}
			}
		}
	}
	else if( dialogid == dialog_RENTMODEL ) {
		if( !response ) return true;
		if( response ) {
			new id = CreateRentID[ playerid ];
			if( choosedRentEditID[ playerid ] != -1)
				id = choosedRentEditID[ playerid ];
			if( gRentStation[ id ][ vrVehModel ] == 2 ) {
			    new model[ 2 ];
			    if( sscanf( inputtext, "ii", model[ 0 ], model[ 1 ] ) ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
				for( new i = 0; i < gRentStation[ id ][ vrVehModel ]; i++) {
					if( gRentStation[ id ][ vrType ] == 1) {
						if( IsVehicleMotorRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You have entered a model that belongs to a bike - this is the Rent Type Car!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						if( IsVehicleAutoRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You entered a model that belongs to the car - this is the Rent Type Bike!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					if( model[ i ] < 400 || model[ i ] > 611 ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
				}
				gRentStation[ id ][ vrModel ][ 0 ] = model[ 0 ];
				gRentStation[ id ][ vrModel ][ 1 ] = model[ 1 ];
				switch( gRentStation[ id ][ vrVehModel ] ) {
					case 2: {
						if( gRentStation[ id ][ vrType ] == 1) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the two vehicle models that will be in the rental choice.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 2) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the two vehicle models that will be in the rental choice.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 3) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the two vehicle models that will be in the rental choice.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
					}
				}
			}
			else if( gRentStation[ id ][ vrVehModel ] == 3 ) {
			    new model[ 3 ];
			    if( sscanf( inputtext, "iii", model[ 0 ], model[ 1 ], model[ 2 ] ) ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the three vehicle models that will be rented.", FirstButton, SecondButton_2 );
				for( new i = 0; i < gRentStation[ id ][ vrVehModel ]; i++) {
					if( gRentStation[ id ][ vrType ] == 1) {
						if( IsVehicleMotorRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You have entered a model that belongs to a bike, this is car rent!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						if( IsVehicleAutoRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You entered a model that belongs to the car - this is bike rent booth!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					if( model[ i ] < 400 || model[ i ] > 611 ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the three vehicle models that will be rented.", FirstButton, SecondButton_2 );
				}
				gRentStation[ id ][ vrModel ][ 0 ] = model[ 0 ];
				gRentStation[ id ][ vrModel ][ 1 ] = model[ 1 ];
				gRentStation[ id ][ vrModel ][ 2 ] = model[ 2 ];
				switch( gRentStation[ id ][ vrVehModel ] ) {
					case 3: {
						if( gRentStation[ id ][ vrType ] == 1) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the three vehicle models that will be in the rental choice.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 2) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the three vehicle models that will be in the rental choice.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 3) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the three vehicle models that will be in the rental choice.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
					}
				}
			}
			else if( gRentStation[ id ][ vrVehModel ] == 4 ) {
			    new model[ 4 ];
			    if( sscanf( inputtext, "iiii", model[ 0 ], model[ 1 ], model[ 2 ], model[ 3 ] ) ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Unesite cetri modela vozila koja ce biti u rent-u.", FirstButton, SecondButton_2 );
				for( new i = 0; i < gRentStation[ id ][ vrVehModel ]; i++) {
					if( gRentStation[ id ][ vrType ] == 1) {
						if( IsVehicleMotorRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You have entered a model that belongs to a bike, this is car rent!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						if( IsVehicleAutoRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You entered a model that belongs to the car - this is bike rent booth!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					if( model[ i ] < 400 || model[ i ] > 611 ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Unesite cetri modela vozila koja ce biti u rent-u.", FirstButton, SecondButton_2 );
				}
				gRentStation[ id ][ vrModel ][ 0 ] = model[ 0 ];
				gRentStation[ id ][ vrModel ][ 1 ] = model[ 1 ];
				gRentStation[ id ][ vrModel ][ 2 ] = model[ 2 ];
				gRentStation[ id ][ vrModel ][ 3 ] = model[ 3 ];
				switch( gRentStation[ id ][ vrVehModel ] ) {
					case 4: {
						if( gRentStation[ id ][ vrType ] == 1) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the four vehicle models that will be in the rental selection.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 2) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the four vehicle models that will be in the rental selection.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 3) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the four vehicle models that will be in the rental selection.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
					}
				}
			}
			else if( gRentStation[ id ][ vrVehModel ] == 5 ) {
			    new model[ 5 ];
			    if( sscanf( inputtext, "iiiii", model[ 0 ], model[ 1 ], model[ 2 ], model[ 3 ], model[ 4 ] ) ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the five vehicle models that will be rented..", FirstButton, SecondButton_2 );
				for( new i = 0; i < gRentStation[ id ][ vrVehModel ]; i++) {
					if( gRentStation[ id ][ vrType ] == 1) {
						if( IsVehicleMotorRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You have entered a model that belongs to a bike, this is car rent!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						if( IsVehicleAutoRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You entered a model that belongs to the car - this is bike rent booth!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					if( model[ i ] < 400 || model[ i ] > 611 ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter the five vehicle models that will be rented..", FirstButton, SecondButton_2 );
				}
				gRentStation[ id ][ vrModel ][ 0 ] = model[ 0 ];
				gRentStation[ id ][ vrModel ][ 1 ] = model[ 1 ];
				gRentStation[ id ][ vrModel ][ 2 ] = model[ 2 ];
				gRentStation[ id ][ vrModel ][ 3 ] = model[ 3 ];
				gRentStation[ id ][ vrModel ][ 4 ] = model[ 4 ];
				switch( gRentStation[ id ][ vrVehModel ] ) {
					case 5: {
						if( gRentStation[ id ][ vrType ] == 1) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the five vehicle models that will be in the rental choice.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 2) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the five vehicle models that will be in the rental choice.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 3) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the five vehicle models that will be in the rental choice.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
					}
				}
			}
			else if( gRentStation[ id ][ vrVehModel ] == 6 ) {
			    new model[ 6 ];
			    if( sscanf( inputtext, "iiiiii", model[ 0 ], model[ 1 ], model[ 2 ], model[ 3 ], model[ 4 ],  model[ 5 ] ) ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Unesite sest modela vozila koja ce biti u rent-u.", FirstButton, SecondButton_2 );
				for( new i = 0; i < gRentStation[ id ][ vrVehModel ]; i++) {
					if( gRentStation[ id ][ vrType ] == 1) {
						if( IsVehicleMotorRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You have entered a model that belongs to a bike, this is car rent!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						if( IsVehicleAutoRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You entered a model that belongs to the car - this is bike rent booth!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					if( model[ i ] < 400 || model[ i ] > 611 ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Unesite sest modela vozila koja ce biti u rent-u.", FirstButton, SecondButton_2 );
				}
				gRentStation[ id ][ vrModel ][ 0 ] = model[ 0 ];
				gRentStation[ id ][ vrModel ][ 1 ] = model[ 1 ];
				gRentStation[ id ][ vrModel ][ 2 ] = model[ 2 ];
				gRentStation[ id ][ vrModel ][ 3 ] = model[ 3 ];
				gRentStation[ id ][ vrModel ][ 4 ] = model[ 4 ];
				gRentStation[ id ][ vrModel ][ 5 ] = model[ 5 ];
				switch( gRentStation[ id ][ vrVehModel ] ) {
					case 6: {
						if( gRentStation[ id ][ vrType ] == 1) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for six vehicle models that will be in the rental choice.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 2) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for six vehicle models that will be in the rental choice.\nExample: 250 154 and so on to the number of allowed models! ", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 3) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for six vehicle models that will be in the rental choice.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
					}
				}
			}
			else if( gRentStation[ id ][ vrVehModel ] == 7 ) {
			    new model[ 7 ];
			    if( sscanf( inputtext, "iiiiiii", model[ 0 ], model[ 1 ], model[ 2 ], model[ 3 ], model[ 4 ],  model[ 5 ],  model[ 6 ] ) ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Unesite sedam modela vozila koja ce biti u rent-u.", FirstButton, SecondButton_2 );
				for( new i = 0; i < gRentStation[ id ][ vrVehModel ]; i++) {
					if( gRentStation[ id ][ vrType ] == 1) {
						if( IsVehicleMotorRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You have entered a model that belongs to a bike, this is car rent!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						if( IsVehicleAutoRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You entered a model that belongs to the car - this is bike rent booth!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					if( model[ i ] < 400 || model[ i ] > 611 ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Unesite sedam modela vozila koja ce biti u rent-u.", FirstButton, SecondButton_2 );
				}
				gRentStation[ id ][ vrModel ][ 0 ] = model[ 0 ];
				gRentStation[ id ][ vrModel ][ 1 ] = model[ 1 ];
				gRentStation[ id ][ vrModel ][ 2 ] = model[ 2 ];
				gRentStation[ id ][ vrModel ][ 3 ] = model[ 3 ];
				gRentStation[ id ][ vrModel ][ 4 ] = model[ 4 ];
				gRentStation[ id ][ vrModel ][ 5 ] = model[ 5 ];
				gRentStation[ id ][ vrModel ][ 6 ] = model[ 6 ];
				switch( gRentStation[ id ][ vrVehModel ] ) {
					case 7: {
						if( gRentStation[ id ][ vrType ] == 1) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the seven vehicle models that will be in the rental selection.\nExample: 250 154 and so on to the number of allowed models! ", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 2) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the seven vehicle models that will be in the rental selection.\nExample: 250 154 and so on to the number of allowed models! ", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 3) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the seven vehicle models that will be in the rental selection.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
					}
				}
			}
			else if( gRentStation[ id ][ vrVehModel ] == 8 ) {
			    new model[ 8 ];
			    if( sscanf( inputtext, "iiiiiiii", model[ 0 ], model[ 1 ], model[ 2 ], model[ 3 ], model[ 4 ],  model[ 5 ],  model[ 6 ],  model[ 7 ] ) ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter eight vehicle models to be rented.", FirstButton, SecondButton_2 );
				for( new i = 0; i < gRentStation[ id ][ vrVehModel ]; i++) {
					if( gRentStation[ id ][ vrType ] == 1) {
						if( IsVehicleMotorRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You have entered a model that belongs to a bike, this is car rent!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						if( IsVehicleAutoRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You entered a model that belongs to the car - this is bike rent booth!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					if( model[ i ] < 400 || model[ i ] > 611 ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter eight vehicle models to be rented.", FirstButton, SecondButton_2 );
				}
				gRentStation[ id ][ vrModel ][ 0 ] = model[ 0 ];
				gRentStation[ id ][ vrModel ][ 1 ] = model[ 1 ];
				gRentStation[ id ][ vrModel ][ 2 ] = model[ 2 ];
				gRentStation[ id ][ vrModel ][ 3 ] = model[ 3 ];
				gRentStation[ id ][ vrModel ][ 4 ] = model[ 4 ];
				gRentStation[ id ][ vrModel ][ 5 ] = model[ 5 ];
				gRentStation[ id ][ vrModel ][ 6 ] = model[ 6 ];
				gRentStation[ id ][ vrModel ][ 7 ] = model[ 7 ];
				switch( gRentStation[ id ][ vrVehModel ] ) {
					case 8: {
						if( gRentStation[ id ][ vrType ] == 1) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the eight vehicle models that will be in the rental selection.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 2) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the eight vehicle models that will be in the rental selection.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 3) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the eight vehicle models that will be in the rental selection.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
					}
				}
			}
			else if( gRentStation[ id ][ vrVehModel ] == 9 ) {
			    new model[ 9 ];
			    if( sscanf( inputtext, "iiiiiiiii", model[ 0 ], model[ 1 ], model[ 2 ], model[ 3 ], model[ 4 ],  model[ 5 ],  model[ 6 ],  model[ 7 ],  model[ 8 ] ) ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Unesite devet modela vozila koja ce biti u rent-u.", FirstButton, SecondButton_2 );
				for( new i = 0; i < gRentStation[ id ][ vrVehModel ]; i++) {
					if( gRentStation[ id ][ vrType ] == 1) {
						if( IsVehicleMotorRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You have entered a model that belongs to a bike, this is car rent!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						if( IsVehicleAutoRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You entered a model that belongs to the car - this is bike rent booth!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					if( model[ i ] < 400 || model[ i ] > 611 ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Unesite devet modela vozila koja ce biti u rent-u.", FirstButton, SecondButton_2 );
				}
				gRentStation[ id ][ vrModel ][ 0 ] = model[ 0 ];
				gRentStation[ id ][ vrModel ][ 1 ] = model[ 1 ];
				gRentStation[ id ][ vrModel ][ 2 ] = model[ 2 ];
				gRentStation[ id ][ vrModel ][ 3 ] = model[ 3 ];
				gRentStation[ id ][ vrModel ][ 4 ] = model[ 4 ];
				gRentStation[ id ][ vrModel ][ 5 ] = model[ 5 ];
				gRentStation[ id ][ vrModel ][ 6 ] = model[ 6 ];
				gRentStation[ id ][ vrModel ][ 7 ] = model[ 7 ];
				gRentStation[ id ][ vrModel ][ 8 ] = model[ 8 ];
				switch( gRentStation[ id ][ vrVehModel ] ) {
					case 9: {
						if( gRentStation[ id ][ vrType ] == 1) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the nine vehicle models that will be in the rental selection.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 2) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the nine vehicle models that will be in the rental selection.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 3) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for the nine vehicle models that will be in the rental selection.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
					}
				}
			}
			else if( gRentStation[ id ][ vrVehModel ] == 10 ) {
			    new model[ 10 ];
			    if( sscanf( inputtext, "iiiiiiiiii", model[ 0 ], model[ 1 ], model[ 2 ], model[ 3 ], model[ 4 ],  model[ 5 ],  model[ 6 ],  model[ 7 ],  model[ 8 ],  model[ 9 ] ) ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter ten vehicle models to be rented.", FirstButton, SecondButton_2 );
				for( new i = 0; i < gRentStation[ id ][ vrVehModel ]; i++) {
					if( gRentStation[ id ][ vrType ] == 1) {
						if( IsVehicleMotorRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You have entered a model that belongs to a bike, this is car rent!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					else if( gRentStation[ id ][ vrType ] == 2) {
						if( IsVehicleAutoRent( model[ i ])) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, "You entered a model that belongs to the car - this is bike rent booth!\nEnter the two vehicle models that will be rented.", FirstButton, SecondButton_2 );
					}
					if( model[ i ] < 400 || model[ i ] > 611 ) return SPD( playerid, dialog_RENTMODEL, DSI, D_INFO_TEXT, ""col_white"Enter ten vehicle models to be rented.", FirstButton, SecondButton_2 );
				}
				gRentStation[ id ][ vrModel ][ 0 ] = model[ 0 ];
				gRentStation[ id ][ vrModel ][ 1 ] = model[ 1 ];
				gRentStation[ id ][ vrModel ][ 2 ] = model[ 2 ];
				gRentStation[ id ][ vrModel ][ 3 ] = model[ 3 ];
				gRentStation[ id ][ vrModel ][ 4 ] = model[ 4 ];
				gRentStation[ id ][ vrModel ][ 5 ] = model[ 5 ];
				gRentStation[ id ][ vrModel ][ 6 ] = model[ 6 ];
				gRentStation[ id ][ vrModel ][ 7 ] = model[ 7 ];
				gRentStation[ id ][ vrModel ][ 8 ] = model[ 8 ];
				gRentStation[ id ][ vrModel ][ 9 ] = model[ 9 ];
				switch( gRentStation[ id ][ vrVehModel ] ) {
					case 10: {
						if( gRentStation[ id ][ vrType ] == 1) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for ten vehicle models that will be in the rental choice.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 2) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for ten vehicle models that will be in the rental choice.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
						else if( gRentStation[ id ][ vrType ] == 3) {
							SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for ten vehicle models that will be in the rental choice.\nExample: 250 154 and so on to the number of allowed models!", FirstButton, SecondButton_2 );
						}
					}
				}
			}
		}
	}
	else if( dialogid == dialog_RENTPRICE ) {
		if( !response ) return true;
		if( response ) {
			new id = CreateRentID[ playerid ];

			if( choosedRentEditID[ playerid ] != -1)
				id = choosedRentEditID[ playerid ];

			if( gRentStation[ id ][ vrVehModel ] == 2 ) {
			    new price[ 2 ];
			    if( sscanf( inputtext, "ii", price[ 0 ], price[ 1 ] ) ) return SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for two models of vehicles that will be rented.", FirstButton, SecondButton_2 );
				gRentStation[ id ][ vrPrice ][ 0 ] = price[ 0 ];
				gRentStation[ id ][ vrPrice ][ 1 ] = price[ 1 ];
				SendInfoMessage(playerid, "You have chosen the price of rent a car per "col_server"minute!");
				if( choosedRentEditID[ playerid ] == -1)
					SendInfoMessage(playerid, "Use the '/ veh' command to create a vehicle, then use the '/arentveh' command to mark the position for the rental vehicle.");
				else 
					SaveRentEdit( playerid, id );
			}
			else if( gRentStation[ id ][ vrVehModel ] == 3 ) {
			    new price[ 3 ];
			    if( sscanf( inputtext, "iii", price[ 0 ], price[ 1 ], price[ 2 ] ) ) return SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Unesite cenu po minute za tri modela vozila koja ce biti u rent-u.", FirstButton, SecondButton_2 );
				gRentStation[ id ][ vrPrice ][ 0 ] = price[ 0 ];
				gRentStation[ id ][ vrPrice ][ 1 ] = price[ 1 ];
				gRentStation[ id ][ vrPrice ][ 2 ] = price[ 2 ];
				SendInfoMessage(playerid, "You have chosen the price of rent a car per "col_server"minute!");
				if( choosedRentEditID[ playerid ] == -1)
					SendInfoMessage(playerid, "Use the '/ veh' command to create a vehicle, then use the '/arentveh' command to mark the position for the rental vehicle.");
				else 
					SaveRentEdit( playerid, id );
			}
			else if( gRentStation[ id ][ vrVehModel ] == 4 ) {
			    new price[ 4 ];
			    if( sscanf( inputtext, "iiii", price[ 0 ], price[ 1 ], price[ 2 ], price[ 3 ] ) ) return SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Unesite cenu po minute za cetri modela vozila koja ce biti u rent-u.", FirstButton, SecondButton_2 );
				gRentStation[ id ][ vrPrice ][ 0 ] = price[ 0 ];
				gRentStation[ id ][ vrPrice ][ 1 ] = price[ 1 ];
				gRentStation[ id ][ vrPrice ][ 2 ] = price[ 2 ];
				gRentStation[ id ][ vrPrice ][ 3 ] = price[ 3 ];
				SendInfoMessage(playerid, "You have chosen the price of rent a car per "col_server"minute!");
				if( choosedRentEditID[ playerid ] == -1)
					SendInfoMessage(playerid, "Use the '/ veh' command to create a vehicle, then use the '/arentveh' command to mark the position for the rental vehicle.");
				else 
					SaveRentEdit( playerid, id );
			}
			else if( gRentStation[ id ][ vrVehModel ] == 5 ) {
			    new price[ 5 ];
			    if( sscanf( inputtext, "iiiii", price[ 0 ], price[ 1 ], price[ 2 ], price[ 3 ], price[ 4 ] ) ) return SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Unesite cenu po minute za pet modela vozila koja ce biti u rent-u.", FirstButton, SecondButton_2 );
				gRentStation[ id ][ vrPrice ][ 0 ] = price[ 0 ];
				gRentStation[ id ][ vrPrice ][ 1 ] = price[ 1 ];
				gRentStation[ id ][ vrPrice ][ 2 ] = price[ 2 ];
				gRentStation[ id ][ vrPrice ][ 3 ] = price[ 3 ];
				gRentStation[ id ][ vrPrice ][ 4 ] = price[ 4 ];
				SendInfoMessage(playerid, "You have chosen the price of rent a car per "col_server"minute!");
				if( choosedRentEditID[ playerid ] == -1)
					SendInfoMessage(playerid, "Use the '/ veh' command to create a vehicle, then use the '/arentveh' command to mark the position for the rental vehicle.");
				else 
					SaveRentEdit( playerid, id );
			}
			else if( gRentStation[ id ][ vrVehModel ] == 6 ) {
			    new price[ 6 ];
			    if( sscanf( inputtext, "iiiiii", price[ 0 ], price[ 1 ], price[ 2 ], price[ 3 ], price[ 4 ],  price[ 5 ] ) ) return SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Unesite cenu po minute za sest modela vozila koja ce biti u rent-u.", FirstButton, SecondButton_2 );
				gRentStation[ id ][ vrPrice ][ 0 ] = price[ 0 ];
				gRentStation[ id ][ vrPrice ][ 1 ] = price[ 1 ];
				gRentStation[ id ][ vrPrice ][ 2 ] = price[ 2 ];
				gRentStation[ id ][ vrPrice ][ 3 ] = price[ 3 ];
				gRentStation[ id ][ vrPrice ][ 4 ] = price[ 4 ];
				gRentStation[ id ][ vrPrice ][ 5 ] = price[ 5 ];
				SendInfoMessage(playerid, "You have chosen the price of rent a car per "col_server"minute!");
				if( choosedRentEditID[ playerid ] == -1)
					SendInfoMessage(playerid, "Use the '/ veh' command to create a vehicle, then use the '/arentveh' command to mark the position for the rental vehicle.");
				else 
					SaveRentEdit( playerid, id );
			}
			else if( gRentStation[ id ][ vrVehModel ] == 7 ) {
			    new price[ 7 ];
			    if( sscanf( inputtext, "iiiiiii", price[ 0 ], price[ 1 ], price[ 2 ], price[ 3 ], price[ 4 ],  price[ 5 ],  price[ 6 ] ) ) return SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Unesite cenu po minute za sedam modela vozila koja ce biti u rent-u.", FirstButton, SecondButton_2 );
				gRentStation[ id ][ vrPrice ][ 0 ] = price[ 0 ];
				gRentStation[ id ][ vrPrice ][ 1 ] = price[ 1 ];
				gRentStation[ id ][ vrPrice ][ 2 ] = price[ 2 ];
				gRentStation[ id ][ vrPrice ][ 3 ] = price[ 3 ];
				gRentStation[ id ][ vrPrice ][ 4 ] = price[ 4 ];
				gRentStation[ id ][ vrPrice ][ 5 ] = price[ 5 ];
				gRentStation[ id ][ vrPrice ][ 6 ] = price[ 6 ];
				SendInfoMessage(playerid, "You have chosen the price of rent a car per "col_server"minute!");
				if( choosedRentEditID[ playerid ] == -1)
					SendInfoMessage(playerid, "Use the '/ veh' command to create a vehicle, then use the '/arentveh' command to mark the position for the rental vehicle.");
				else 
					SaveRentEdit( playerid, id );
			}
			else if( gRentStation[ id ][ vrVehModel ] == 8 ) {
			    new price[ 8 ];
			    if( sscanf( inputtext, "iiiiiiii", price[ 0 ], price[ 1 ], price[ 2 ], price[ 3 ], price[ 4 ],  price[ 5 ],  price[ 6 ],  price[ 7 ] ) ) return SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Unesite cenu po minute za osam modela vozila koja ce biti u rent-u.", FirstButton, SecondButton_2 );
				gRentStation[ id ][ vrPrice ][ 0 ] = price[ 0 ];
				gRentStation[ id ][ vrPrice ][ 1 ] = price[ 1 ];
				gRentStation[ id ][ vrPrice ][ 2 ] = price[ 2 ];
				gRentStation[ id ][ vrPrice ][ 3 ] = price[ 3 ];
				gRentStation[ id ][ vrPrice ][ 4 ] = price[ 4 ];
				gRentStation[ id ][ vrPrice ][ 5 ] = price[ 5 ];
				gRentStation[ id ][ vrPrice ][ 6 ] = price[ 6 ];
				gRentStation[ id ][ vrPrice ][ 7 ] = price[ 7 ];
				SendInfoMessage(playerid, "You have chosen the price of rent a car per "col_server"minute!");
				if( choosedRentEditID[ playerid ] == -1)
					SendInfoMessage(playerid, "Use the '/ veh' command to create a vehicle, then use the '/arentveh' command to mark the position for the rental vehicle.");
				else 
					SaveRentEdit( playerid, id );
			}
			else if( gRentStation[ id ][ vrVehModel ] == 9 ) {
			    new price[ 9 ];
			    if( sscanf( inputtext, "iiiiiiiii", price[ 0 ], price[ 1 ], price[ 2 ], price[ 3 ], price[ 4 ],  price[ 5 ],  price[ 6 ],  price[ 7 ],  price[ 8 ] ) ) return SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Unesite cenu po minute za devet modela vozila koja ce biti u rent-u.", FirstButton, SecondButton_2 );
				gRentStation[ id ][ vrPrice ][ 0 ] = price[ 0 ];
				gRentStation[ id ][ vrPrice ][ 1 ] = price[ 1 ];
				gRentStation[ id ][ vrPrice ][ 2 ] = price[ 2 ];
				gRentStation[ id ][ vrPrice ][ 3 ] = price[ 3 ];
				gRentStation[ id ][ vrPrice ][ 4 ] = price[ 4 ];
				gRentStation[ id ][ vrPrice ][ 5 ] = price[ 5 ];
				gRentStation[ id ][ vrPrice ][ 6 ] = price[ 6 ];
				gRentStation[ id ][ vrPrice ][ 7 ] = price[ 7 ];
				gRentStation[ id ][ vrPrice ][ 8 ] = price[ 8 ];
				SendInfoMessage(playerid, "You have chosen the price of rent a car per "col_server"minute!");
				if( choosedRentEditID[ playerid ] == -1)
					SendInfoMessage(playerid, "Use the '/ veh' command to create a vehicle, then use the '/arentveh' command to mark the position for the rental vehicle.");
				else 
					SaveRentEdit( playerid, id );
			}
			else if( gRentStation[ id ][ vrVehModel ] == 10 ) {
			    new price[ 10 ];
			    if( sscanf( inputtext, "iiiiiiiiii", price[ 0 ], price[ 1 ], price[ 2 ], price[ 3 ], price[ 4 ],  price[ 5 ],  price[ 6 ],  price[ 7 ],  price[ 8 ],  price[ 9 ] ) ) return SPD( playerid, dialog_RENTPRICE, DSI, D_INFO_TEXT, ""col_white"Enter the price per minute for ten vehicle models that will be rented.", FirstButton, SecondButton_2 );
				gRentStation[ id ][ vrPrice ][ 0 ] = price[ 0 ];
				gRentStation[ id ][ vrPrice ][ 1 ] = price[ 1 ];
				gRentStation[ id ][ vrPrice ][ 2 ] = price[ 2 ];
				gRentStation[ id ][ vrPrice ][ 3 ] = price[ 3 ];
				gRentStation[ id ][ vrPrice ][ 4 ] = price[ 4 ];
				gRentStation[ id ][ vrPrice ][ 5 ] = price[ 5 ];
				gRentStation[ id ][ vrPrice ][ 6 ] = price[ 6 ];
				gRentStation[ id ][ vrPrice ][ 7 ] = price[ 7 ];
				gRentStation[ id ][ vrPrice ][ 8 ] = price[ 8 ];
				gRentStation[ id ][ vrPrice ][ 9 ] = price[ 9 ];
				SendInfoMessage(playerid, "You have chosen the price of rent a car per "col_server"minute!");
				if( choosedRentEditID[ playerid ] == -1)
					SendInfoMessage(playerid, "Use the '/veh' command to create a vehicle, then use the 'arentveh' command to mark the position for the rental vehicle.");
				else 
					SaveRentEdit( playerid, id );
			}
		}
	}
	else if( dialogid == dialog_RENTEDIT ) {
    	if( ! response ) return true;
    	if( response ) {
    		switch ( listitem ) {
    			case 0: {
    				new rentID = GetNearestRentVehicleAdmin( playerid );
		        	if( rentID == -1 ) return SendErrorMessage( playerid, "You must be next to the rent to whom you want to change position." );

		        	new Float:Pos[ 3 ];
		        	GetPlayerPos( playerid, Pos[ 0 ], Pos[ 1 ], Pos[ 2 ] );

		        	gRentStation[ rentID ][ vrLiP_Pos_X ] = Pos[ 0 ];
					gRentStation[ rentID ][ vrLiP_Pos_Y ] = Pos[ 1 ];
					gRentStation[ rentID ][ vrLiP_Pos_Z ] = Pos[ 2 ];

					RefreshRentPandL( rentID );

					new q[ 192 ];
					mysql_format( _dbConnector, q, sizeof(q), "UPDATE `rents` SET `vrLiP_Pos_X` = '%f',`vrLiP_Pos_Y` = '%f',`vrLiP_Pos_Z` = '%f' WHERE `vrSQLID` = '%d'",
						gRentStation[ rentID ][ vrLiP_Pos_X ],
						gRentStation[ rentID ][ vrLiP_Pos_Y ],
						gRentStation[ rentID ][ vrLiP_Pos_Z ],
						gRentStation[ rentID ][ vrSQLID ] );

				 	mysql_pquery( _dbConnector, q, "", "");

				   	SendInfoMessage( playerid, "You have successfully changed the position - rent SQLID ID:%d.", gRentStation[ rentID ][ vrSQLID ] );

				   	KGEyes_SetPlayerPos( playerid, Pos[ 0 ], Pos[ 1 ], Pos[ 2 ]+5 );
    			}
    			case 1: {
    				new rentID = GetNearestRentVehicleAdmin( playerid );
		        	if( rentID == -1 ) return SendErrorMessage( playerid, "You must be next to the rent to whom you want to change the spawn position." );
		        	if(!IsPlayerInVehicle(playerid, GetPlayerVehicleID(playerid)) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return SendErrorMessage(playerid, "Morate biti u vozilu kao vozac!");
		        	new Float:Pos[ 4 ];
		        	GetVehiclePos(GetPlayerVehicleID(playerid), Pos[ 0 ], Pos[ 1 ], Pos[ 2 ] );
		        	GetVehicleZAngle(GetPlayerVehicleID(playerid), Pos[3]);

		        	gRentStation[ rentID ][ vrSpawn_Pos_X ] = Pos[ 0 ];
					gRentStation[ rentID ][ vrSpawn_Pos_Y ] = Pos[ 1 ];
					gRentStation[ rentID ][ vrSpawn_Pos_Z ] = Pos[ 2 ];
					gRentStation[ rentID ][ vrSpawn_Pos_A ] = Pos[ 3 ];

					new q[ 192 ];
					mysql_format( _dbConnector, q, sizeof(q), "UPDATE `rents` SET `vrSpawn_Pos_X` = '%f',`vrSpawn_Pos_Y` = '%f',`vrSpawn_Pos_Z` = '%f' WHERE `vrSQLID` = '%d'",
						gRentStation[ rentID ][ vrSpawn_Pos_X ],
						gRentStation[ rentID ][ vrSpawn_Pos_Y ],
						gRentStation[ rentID ][ vrSpawn_Pos_Z ],
						gRentStation[ rentID ][ vrSpawn_Pos_A ],
						gRentStation[ rentID ][ vrSQLID ] );

				 	mysql_pquery( _dbConnector, q, "", "");

				   	SendInfoMessage( playerid, "You have successfully changed the spawn position - rent SQLID ID:%d.", gRentStation[ rentID ][ vrSQLID ] );
    			}
    			case 2: {
    				new rentID = GetNearestRentVehicleAdmin( playerid ), infoDialog[1500];
		        	if( rentID == -1 ) return SendErrorMessage( playerid, "You must be next to the rent to whom you want to change the spawn position." );

		        	switch( gRentStation[ rentID ][ vrType] ) {
						case 1: {
							format( infoDialog, sizeof( infoDialog) , "\
								"col_white"You have selected rent type: "col_server"Cars!\n\
								"col_white"Enter the number of different types of cars "col_server"(modela) "col_white"koja ce se nalaziti u ovom tipu "col_crvena"renta vozila\n\
								"col_crvena"Ne mozete manje modela od 2 i vise od 10!");
						}
						case 2: {
							format( infoDialog, sizeof( infoDialog) , "\
								"col_white"You have selected rent type: "col_server"Bikes!\n\
								"col_white"Unesite broj razlicitih vrsti motora "col_server"(modela) "col_white"koja ce se nalaziti u ovom tipu "col_crvena"renta vozila\n\
								"col_crvena"Ne mozete manje modela od 2 i vise od 10!");
						}
						case 3: {
							format( infoDialog, sizeof( infoDialog) , "\
								"col_white"You have selected rent type: "col_server"Car n Bikes!\n\
								"col_white"Enter the number of different types of cars and bikes "col_server"(modela) "col_white"koja ce se nalaziti u ovom tipu "col_crvena"renta vozila\n\
								"col_crvena"Ne mozete manje modela od 2 i vise od 10!");
						}
					}
					choosedRentEditID[ playerid ] = rentID; 
					format( infoDialog, sizeof ( infoDialog ) \
		        		, "The current quantity of models in this RENT is :"col_server"%d\n%s", gRentStation[ rentID ][ vrVehModel ], infoDialog);
					SPD( playerid, dialog_RENTMAXMODEL, DSI, D_INFO_TEXT, infoDialog, FirstButton, SecondButton_2 );
    			}
    			case 3: {
    				new rentID = GetNearestRentVehicleAdmin( playerid );
		        	if( rentID == -1 ) return SendErrorMessage( playerid, "You must be next to the rent to whom you want to change the spawn position." );
    				new query[126];
					mysql_format( _dbConnector, query, sizeof(query), "SELECT * FROM `rents` WHERE `vrSQLID` = '%d'", gRentStation[ rentID ][ vrSQLID] );
					mysql_tquery( _dbConnector, query, "OnRentsListModels", "i", playerid );
    			}
    			case 4: {
    				new rentID = GetNearestRentVehicleAdmin( playerid );
		        	if( rentID == -1 ) return SendErrorMessage( playerid, "You must be next to the rent to whom you want to change the spawn position." );
    				new query[126];
					mysql_format( _dbConnector, query, sizeof(query), "SELECT * FROM `rents` WHERE `vrSQLID` = '%d'", gRentStation[ rentID ][ vrSQLID] );
					mysql_tquery( _dbConnector, query, "OnRentsListPrice", "i", playerid );
    			}
    		}
    	}
    }
    else if( dialogid == dialog_RENTTIME ) {
		if(!response ) {
			choosedRentID[playerid] = -1;
			return true;
		} 
		if( response ) {
			new rentID = GetNearestRentVehicle(playerid);
			if(rentID == -1) return SendErrorMessage(playerid, "You are not close to a vehicle rent place.");
			new gnrv = GetRentTypeWithModel(choosedRentID[playerid]);
			if(gnrv == -1) return SendErrorMessage(playerid, "An error occurred while renting, contact the scripter!");
			new time;
			if( sscanf( inputtext, "i", time)) return SPD( playerid, dialog_RENTTIME, DSI, D_INFO_TEXT, ""col_white"Enter the number of minutes you want to rent a vehicle for\nMinimum: "col_server"1 "col_white"Maximum: "col_server"10080", FirstButton, SecondButton );
			if(time < 1 || time > 10080) return SPD( playerid, dialog_RENTTIME, DSI, D_INFO_TEXT, ""col_white"Enter the number of minutes you want to rent a vehicle for\nMinimum: "col_server"1 "col_white"Maximum: "col_server"10080", FirstButton, SecondButton );
			if(GetPlayerMoney(playerid) < ( GetPriceOfRentWithID( gnrv, choosedRentID[playerid] ) * time ) ) return SendErrorMessage(playerid, "You don't have enough money - $%d.", ( GetPriceOfRentWithID( gnrv, choosedRentID[playerid] ) * time ));

			new cash = GetPriceOfRentWithID( gnrv, choosedRentID[playerid] ) * time;
			GivePlayerMoneyEx(playerid, -cash	);
			BussinesRentMoney( cash/10 );
			if( IsValidDynamicObject( atmKonopac[ playerid ][ 0 ] ) ) DestroyDynamicObject(atmKonopac[ playerid ][ 0 ]);
			if( IsValidDynamicObject( atmKonopac[ playerid ][ 1 ] ) ) DestroyDynamicObject(atmKonopac[ playerid ][ 1 ]);
			if( IsValidDynamicObject( atmKonopac[ playerid ][ 2 ] ) ) DestroyDynamicObject(atmKonopac[ playerid ][ 2 ]);
			atmKonopac[ playerid ][ 0 ] = atmKonopac[ playerid ][ 1 ] = atmKonopac[ playerid ][ 2 ] = -1;
			new vehicleid = sql_create_vehicle( choosedRentID[playerid], e_VEHICLE_TYPE_RENT, -1, -1, gRentStation[rentID][vrSpawn_Pos_X], gRentStation[rentID][vrSpawn_Pos_Y], gRentStation[rentID][vrSpawn_Pos_Z], gRentStation[rentID][vrSpawn_Pos_A], 1, 1, 0, playerid, time*60 + gettime() );
			LinkVehicleToInterior( vehicleid, GetPlayerInterior( playerid ) );
			SetVehicleVirtualWorld( vehicleid, GetPlayerVirtualWorld( playerid ) );
			KGEyes_PutPlayerInVehicle( playerid, vehicleid, 0 );

			new engine, lights, alarm, doors, bonnet, boot, objective;

			GetVehicleParamsEx( vehicleid, engine, lights, alarm, doors, bonnet, boot, objective );
			SetVehicleParamsEx( vehicleid, 1, 0, alarm, 0, 0, 0, objective );
			SetVehiclePlate( vehicleid );
			SendGreenMessage(playerid, "You rented a(n) %s for %d minutes at price of $%d.", GetVehicleNameEx( choosedRentID[playerid] ), time, ( GetPriceOfRentWithID( gnrv, choosedRentID[playerid] ) * time ));
			choosedRentID[playerid] = -1;
			for( new i = 0; i < MAX_RENTMODELS; i++) {
				DBListRent[playerid][i] = 0;
			}
			return true;
		}
	} 
	else if( dialogid == dialog_RENTMODELLIST ) {
		if( !response ) {
			for( new i = 0; i < MAX_RENTMODELS; i++) {
				DBListRent[playerid][i] = 0;
			}
			choosedRentID[playerid] = -1;
			return true;
		}
		if( response )
		{
			new infoDialog[500];
			choosedRentID[playerid ] = DBListRent[playerid][listitem];
			if( choosedRentID[playerid] == -1 ) return SendErrorMessage(playerid, "An error occurred while selecting the model, contact the scripter!");
			format(infoDialog, sizeof( infoDialog )\
				, ""col_white"Change "col_server"Model ID\n\
				"col_white"Remove "col_server"%s "col_white"from the model list!");
			SPD( playerid, dialog_RENTMODELMENU, DSL, D_INFO_TEXT, infoDialog, FirstButton, SecondButton );
			for( new i = 0; i < MAX_RENTMODELS; i++) {
				DBListRent[playerid][i] = 0;
			}
		}
	}
	else if( dialogid == dialog_RENTPRICELIST ) {
		if( !response ) {
			for( new i = 0; i < MAX_RENTMODELS; i++) {
				DBListRent[playerid][i] = 0;
			}
			choosedRentID[playerid] = -1;
			return true;
		}
		if( response )
		{
			new infoDialog[500];
			choosedRentID[playerid ] = DBListRent[playerid][listitem];
			new id = GetRentTypeWithModel( choosedRentID[playerid ] );
			if( choosedRentID[playerid] == -1 ) return SendErrorMessage(playerid, "An error occurred while selecting the model, contact the scripter!");
			format( infoDialog, sizeof(infoDialog)\
				, ""col_white"Current model price "col_server"%s "col_white"for "col_server"$%d\n\
				"col_white"Enter the desired price for this model, the price is calculated per minute", GetPriceOfRentWithID( id, choosedRentID[playerid] ) );
			SPD( playerid, dialog_RENTCHANGEPRICE, DSI, D_INFO_TEXT, infoDialog, FirstButton, SecondButton );
			for( new i = 0; i < MAX_RENTMODELS; i++) {
				DBListRent[playerid][i] = 0;
			}
		}
	}
	else if( dialogid == dialog_RENTCHANGEPRICE ) {
		if( !response ) {
			for( new i = 0; i < MAX_RENTMODELS; i++) {
				DBListRent[playerid][i] = 0;
			}
			choosedRentID[playerid] = -1;
		}
		if( response ) {
			new inputPrice, infoDialog[500]; 
			new id = GetRentTypeWithModel( choosedRentID[ playerid ] );
			if( sscanf( inputtext, "i", inputPrice)) {
				format( infoDialog, sizeof(infoDialog)\
				, ""col_white"Trenutna cena modela "col_server"%s "col_white"iznosi "col_server"$%d\n\
				"col_white"Unesite zeljenu cenu za ovaj model , cena se racuna po minute");
				return SPD( playerid, dialog_RENTCHANGEPRICE, DSI, D_INFO_TEXT, infoDialog, FirstButton, SecondButton );
			}

			if( inputPrice < 10  ) return SendErrorMessage( playerid, "Cena Rent-a ne moze biti manja od 10$!");
			new query[126];
			mysql_format( _dbConnector, query, sizeof(query), "SELECT * FROM `rents` WHERE `vrSQLID` = '%d'", gRentStation[ id ][ vrSQLID] );
			mysql_tquery( _dbConnector, query, "OnRentChangePrice", "ii", playerid, inputPrice );
		}
	}
	else if( dialogid == dialog_RENTMODELMENU ) {
		if( !response ) {
			for( new i = 0; i < MAX_RENTMODELS; i++) {
				DBListRent[playerid][i] = 0;
			}
			choosedRentID[playerid] = -1;
		}
		if( response ) {
			switch( listitem ) {
				case 0 : {
					new id = GetRentTypeWithModel( choosedRentID[ playerid ] ), infoDialog[500];
					if( id == -1 ) return SendErrorMessage( playerid, "Dogodila se greska prilikom Izmene modela - kontaktirajte Scriptera!");
					switch( gRentStation[ id ][ vrType]) {
						case 1: {
							format(infoDialog, sizeof( infoDialog ) , ""col_white"Ovaj "col_server"tip rent-a "col_white" se koristi samo za "col_crvena"AUTA!\n\
								"col_white"Unesite Zeljeni ID Modela koji pripada vozilu vrste "col_server"( AUTO )");
						}
						case 2: {
							format(infoDialog, sizeof( infoDialog ) , ""col_white"Ovaj "col_server"tip rent-a "col_white" se koristi samo za "col_crvena"MOTORE!\n\
								"col_white"Unesite Zeljeni ID Modela koji pripada vozilu vrste "col_server"( MOTOR )");
						}
						case 3: {
							format(infoDialog, sizeof( infoDialog ) , ""col_white"Ovaj "col_server"tip rent-a "col_white" se koristi za "col_crvena"AUTA & MOTORE!\n\
								"col_white"Unesite Zeljeni ID Modela koji pripada vozilu vrste "col_server"( AUTO & MOTOR )");
						}
					}
					SPD( playerid, dialog_RENTCHANGEMODEL, DSI, D_INFO_TEXT, infoDialog, FirstButton, SecondButton );
				}
				case 1: { 
					new id = GetRentTypeWithModel( choosedRentID[ playerid ] );
					if( id == -1 ) return SendErrorMessage( playerid, "Dogodila se greska prilikom brisanja modela - kontaktirajte Scriptera!");
					new query[126];
					mysql_format( _dbConnector, query, sizeof(query), "SELECT * FROM `rents` WHERE `vrSQLID` = '%d'", gRentStation[ id ][ vrSQLID] );
					mysql_tquery( _dbConnector, query, "OnRentRemoveModel", "i", playerid );
				}
			}
		}
	}
	else if( dialogid == dialog_confirmrent ) {
		if( !response ) {
			SendErrorMessage(playerid, "You cancelled vehicle rent extension.");
		}
		if( response ) {
			if(gPlayerData[playerid][E_PLAYER_MONEY] < GetPVarInt(playerid, "RentExtendPrice")) return SendErrorMessage(playerid, "You don't have $%d on you.", GetPVarInt(playerid, "RentExtendPrice"));
			GivePlayerMoneyEx(playerid, -GetPVarInt(playerid, "RentExtendPrice"));
			SendGreenMessage(playerid, "You extended your vehicle's rent time");
		}
	}
	else if( dialogid == dialog_RENTCHANGEMODEL ) {
		if( !response ) {
			for( new i = 0; i < MAX_RENTMODELS; i++) {
				DBListRent[playerid][i] = 0;
			}
			choosedRentID[playerid] = -1;
		}
		if( response ) {
			new inputModel, infoDialog[500]; 
			new id = GetRentTypeWithModel( choosedRentID[ playerid ] );
			if( sscanf( inputtext, "i", inputModel)) {
				switch( gRentStation[ id ][ vrType] ) {
					case 1: {
						format(infoDialog, sizeof( infoDialog ) , ""col_white"Ovaj "col_server"tip rent-a "col_white" se koristi samo za "col_crvena"AUTA!\n\
							"col_white"Unesite Zeljeni ID Modela koji pripada vozilu vrste "col_server"( AUTO )");
					}
					case 2: {
						format(infoDialog, sizeof( infoDialog ) , ""col_white"Ovaj "col_server"tip rent-a "col_white" se koristi samo za "col_crvena"MOTORE!\n\
							"col_white"Unesite Zeljeni ID Modela koji pripada vozilu vrste "col_server"( MOTOR )");
					}
					case 3: {
						format(infoDialog, sizeof( infoDialog ) , ""col_white"Ovaj "col_server"tip rent-a "col_white" se koristi za "col_crvena"AUTA & MOTORE!\n\
							"col_white"Unesite Zeljeni ID Modela koji pripada vozilu vrste "col_server"( AUTO & MOTOR )");
					}
				}
				return SPD( playerid, dialog_RENTCHANGEMODEL, DSI, D_INFO_TEXT, infoDialog, FirstButton, SecondButton );
			}

			if( inputModel < 400 || inputModel > 611 ) return SendErrorMessage( playerid, "ID vozila ne moze biti manji od 400 ili veci od 611!");
			switch( gRentStation[ id ][ vrType] ) {
				case 0: {
					if(IsVehicleMotorRent(inputModel)) {
						SendErrorMessage(playerid, "Ovaj Tip Renta je samo za AUTA, uneli ste id modela koji pripada MOTORU!");
						format(infoDialog, sizeof( infoDialog ) , ""col_white"Ovaj "col_server"tip rent-a "col_white" se koristi samo za "col_crvena"AUTA!\n\
							"col_white"Unesite Zeljeni ID Modela koji pripada vozilu vrste "col_server"( AUTO )");
						return SPD( playerid, dialog_RENTCHANGEMODEL, DSI, D_INFO_TEXT, infoDialog, FirstButton, SecondButton );
					}
				}
				case 1: {
					if(IsVehicleMotorRent(inputModel)) {
						SendErrorMessage(playerid, "Ovaj Tip Renta je samo za Motore, uneli ste id modela koji pripada Autu!");
						format(infoDialog, sizeof( infoDialog ) , ""col_white"Ovaj "col_server"tip rent-a "col_white" se koristi samo za "col_crvena"MOTORE!\n\
							"col_white"Unesite Zeljeni ID Modela koji pripada vozilu vrste "col_server"( MOTOR )");
						return SPD( playerid, dialog_RENTCHANGEMODEL, DSI, D_INFO_TEXT, infoDialog, FirstButton, SecondButton );
					}
				}
			}
			new query[126];
			mysql_format( _dbConnector, query, sizeof(query), "SELECT * FROM `rents` WHERE `vrSQLID` = '%d'", gRentStation[ id ][ vrSQLID] );
			mysql_tquery( _dbConnector, query, "OnRentChangeModel", "ii", playerid, inputModel );
		}
	}
	else if( dialogid == dialog_RENTANJE )
	{
		if( !response ) {
			for( new i = 0; i < MAX_RENTMODELS; i++) {
				DBListRent[playerid][i] = 0;
			}
			choosedRentID[playerid] = -1;
			return true;
		}
		if( response )
		{
			new gnrv = GetRentTypeWithModel(DBListRent[playerid][listitem]);
			if(gnrv == -1) return SendErrorMessage(playerid, "An error occurred while selecting the model, contact the scripter!");
			choosedRentID[playerid ] = DBListRent[playerid][listitem];
			SPD( playerid, dialog_RENTTIME, DSI, D_INFO_TEXT, ""col_white"Enter the number of minutes you want to rent a vehicle for\nMinimum: "col_server"1 "col_white"Maximum: "col_server"10080", FirstButton, SecondButton );
	    }
	}
	return true;
}

//--End_of_main_function_for_mode--//

//=====================[ Commands ]================================
CMD:checkrent( playerid )
{
	if( gPlayerData[ playerid ][ E_PLAYER_ADMIN_LEVEL ] < 4 ) return -1;
	new id = GetNearestRentVehicle( playerid );
	if(id == -1) return SendErrorMessage(playerid, "You are not close to vehicle rent area.");
	SendInfoMessage(playerid, "Server sided ID: %d, Database ID: %d", id, gRentStation[id][vrSQLID]);
	return 1;
}
CMD:rentveh( playerid )
{
	if(dsys_info[ playerid ][ ds_b_w ]==true) return SendErrorMessage(playerid, "You cannot use this command right now.");
	if( NaDmEventu[ playerid ] == true || inDerby[playerid] || inFall[playerid]) return SendErrorMessage( playerid, "You cannot do this in event." );
	if( WARPInfo[ playerid ][ WARIgrac ] != -1 ) return SendErrorMessage( playerid, "You can't while you're in WAR." );
	if( naDeagle[ playerid ] > 0 /*|| inPUBG[playerid] > 0*/) return SendErrorMessage( playerid, "You can't while you're at an event." );
	if( tdm_player_info[ playerid ][ tdm_Team ] != -1 ) return SendErrorMessage( playerid, "You can't do this while you're at a tdm event." );
	new id = GetNearestRentVehicle( playerid );
	if(id == -1) return SendErrorMessage(playerid, "You are not close to vehicle rent area.");
	if(GetTotalRentVehicles(playerid) > 5) return SendErrorMessage(playerid, "You are already renting 6 vehicles.");
	if(IsPlayerInAnyVehicle(playerid)) return SendErrorMessage(playerid, "You have to get out of the vehicle.");

	strdel( DialogStrgEx, 0, sizeof( DialogStrgEx ) );
	format( DialogStrgEx, sizeof( DialogStrgEx ), "Model\tPrice" );

	new counter = 0;
	for( new i = 0; i < MAX_RENTMODELS; i++) {
		if( gRentStation[ id ][ vrModel ][ i ] > 0) {
			format(DialogStrgEx, sizeof( DialogStrgEx ), "%s\n%s\t$%d\n", DialogStrgEx, GetVehicleNameEx( gRentStation[ id ][ vrModel ][ i ] ), gRentStation[ id ][ vrPrice ][ i ] );
			DBListRent[playerid][counter] = gRentStation[ id ][ vrModel ][ i ];
			counter++;
		}
	}
	ShowPlayerDialog(playerid, dialog_RENTANJE, DIALOG_STYLE_TABLIST_HEADERS, "Rent Vehicles", DialogStrgEx, "Rent", "Close");
	strdel( DialogStrgEx, 0, sizeof( DialogStrgEx ) );
	return(true);
}

CMD:arentveh( playerid )
{
    if( gPlayerData[ playerid ][ E_PLAYER_ADMIN_LEVEL ] < 4 ) return SendErrorMessage( playerid, "You do not have permission to use this command.");
	if( !AdminDuty[ playerid ] ) return SendErrorMessage( playerid, "You must be on admin duty!" );
	if( !IsPlayerInAnyVehicle( playerid ) ) return SendErrorMessage( playerid, "You must be in the vehicle!" );
    new /*id = CreateRentID[ playerid ],*/ vehicleid = GetPlayerVehicleID( playerid );
	if( CreateRentID[ playerid ] == -1 ) return SendErrorMessage( playerid, "You did not create any rent." );
    if( AdminVozilo[ playerid ] != vehicleid ) return SendErrorMessage( playerid, "You must create an admin vehicle to complete the process." );
    

	/*GetVehiclePos( vehicleid, gRentStation[ id ][ vrSpawn_Pos_X ], gRentStation[ id ][ vrSpawn_Pos_Y ], gRentStation[ id ][ vrSpawn_Pos_Z ] );
	GetVehicleZAngle( vehicleid, gRentStation[ id ][ vrSpawn_Pos_A ] );*/
	
	new Float:X, Float:Y, Float:Z, Float:angle;
	GetVehiclePos( vehicleid, X, Y, Z );
	GetVehicleZAngle( vehicleid, angle );

    gRentStation[CreateRentID[ playerid ]][vrSpawn_Pos_X] = X;
	gRentStation[CreateRentID[ playerid ]][vrSpawn_Pos_Y] = Y;
	gRentStation[CreateRentID[ playerid ]][vrSpawn_Pos_Z] = Z;
	gRentStation[CreateRentID[ playerid ]][vrSpawn_Pos_A] = angle;

	mSQL_CreateVehicleRent( playerid, CreateRentID[ playerid ]);

	/*new q[ 128 ];
	mysql_format( _dbConnector, q, sizeof q, "UPDATE `rents` SET `vrSpawn_Pos_X` = %f, `vrSpawn_Pos_Y` = %f, `vrSpawn_Pos_Z` = %f, `vrSpawn_Pos_A` = %f WHERE `vrSQLID` = '%d' LIMIT 1", FARMA_ENUM[ id ][ farm_vX ], FARMA_ENUM[ id ][ farm_vY ], FARMA_ENUM[ id ][ farm_vZ ], FARMA_ENUM[ id ][ farm_A ], id );
	mysql_pquery( _dbConnector, q, "", "");*/

    CreateRentID[ playerid ] = -1;
    ResetVehicle( vehicleid );
    KGEyes_DestroyVehicle( vehicleid, 11 );
    AdminVozilo[ playerid ] = -1;

	SendInfoMessage( playerid, "You have successfully saved the position and completed rent veh creation." );
    return true;
}
//=====================[ Stocks]===================================

/*
CMD:extendrent(playerid, params[])
{
	new timex;
	if( sscanf( params, "i", timex)) {
		SendUsageMessage( playerid, "/extendrent [ time in minutes ]");
		return 1;
	}
	if(timex < 1) return SendErrorMessage(playerid, "Time cannot be less than 1 minutes.");
	new price = 200*timex;
	SetPVarInt(playerid, "RentExtend", timex);
	SetPVarInt(playerid, "RentExtendPrice", price);
	new str[ 128 ];
	format( str, sizeof( str ), ""col_server"CONFIRM RENT EXTENSION\n\n"col_server"Minutes to extend: "col_white"%d\n"col_server"Price: "col_white"$%d", timex, price);
	SPD( playerid, dialog_confirmrent, DSMSG, "Rent Confirmation", str, "Extend", "Abort" );
	return 1;
}
*/
//=====================[ Publics ]=================================
public mSQL_CreateVehicleRent( playerid,  createID )
{
	static q[1000];
    mysql_format( _dbConnector, q, sizeof( q ),

		"INSERT INTO `rents` ( `vrLiP_Pos_X`\
		, `vrLiP_Pos_Y`\
		, `vrLiP_Pos_Z`\
		, `vrSpawn_Pos_X`\
		, `vrSpawn_Pos_Y`\
		, `vrSpawn_Pos_Z`\
		, `vrSpawn_Pos_A`\
		, `vrType`\
		, `vr_model_0`\
		, `vr_model_1`\
		, `vr_model_2`\
		, `vr_model_3`\
		, `vr_model_4`\
		, `vr_model_5`\
		, `vr_model_6`\
		, `vr_model_7`\
		, `vr_model_8`\
		, `vr_model_9`\
		, `vr_price_0`\
		, `vr_price_1`\
		, `vr_price_2`\
		, `vr_price_3`\
		, `vr_price_4`\
		, `vr_price_5`\
		, `vr_price_6`\
		, `vr_price_7`\
		, `vr_price_8`\
		, `vr_price_9` ) \
		VALUES( '%f'\
		, '%f'\
		, '%f'\
		, '%f'\
		, '%f'\
		, '%f'\
		, '%f'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d'\
		, '%d' )"\
		, gRentStation[createID][vrLiP_Pos_X]\
		, gRentStation[createID][vrLiP_Pos_Y]\
		, gRentStation[createID][vrLiP_Pos_Z]\
		, gRentStation[createID][vrSpawn_Pos_X]\
		, gRentStation[createID][vrSpawn_Pos_Y]\
		, gRentStation[createID][vrSpawn_Pos_Z]\
		, gRentStation[createID][vrSpawn_Pos_A]\
		, gRentStation[createID][vrType]\
		, gRentStation[ createID ][ vrModel ][0]\
		, gRentStation[ createID ][ vrModel ][1]\
		, gRentStation[ createID ][ vrModel ][2]\
		, gRentStation[ createID ][ vrModel ][3]\
		, gRentStation[ createID ][ vrModel ][4]\
		, gRentStation[ createID ][ vrModel ][5]\
		, gRentStation[ createID ][ vrModel ][6]\
		, gRentStation[ createID ][ vrModel ][7]\
		, gRentStation[ createID ][ vrModel ][8]\
		, gRentStation[ createID ][ vrModel ][9]\
		, gRentStation[ createID ][ vrPrice ][0]\
		, gRentStation[ createID ][ vrPrice ][1]\
		, gRentStation[ createID ][ vrPrice ][2]\
		, gRentStation[ createID ][ vrPrice ][3]\
		, gRentStation[ createID ][ vrPrice ][4]\
		, gRentStation[ createID ][ vrPrice ][5]\
		, gRentStation[ createID ][ vrPrice ][6]\
		, gRentStation[ createID ][ vrPrice ][7]\
		, gRentStation[ createID ][ vrPrice ][8]\
		, gRentStation[ createID ][ vrPrice ][9] );

    mysql_pquery( _dbConnector, q, "OnRentCreated", "ii", playerid,  createID );
	return(true);
}

public OnRentCreated( playerid,  createID )
{
	gRentStation[ createID ][ vrSQLID ] = cache_insert_id();

	new string[180];
	format(string, sizeof(string), "{02E102}Vehicle Rent Station: "col_white"%d\n"col_white"\nTo rent a vehicle, type\n/rentveh", createID);
	gRentStation[createID][VoziloRentLabel] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, gRentStation[createID][vrLiP_Pos_X], gRentStation[createID][vrLiP_Pos_Y], gRentStation[createID][vrLiP_Pos_Z], 8.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
	gRentStation[createID][VoziloRentPickup] = CreateDynamicPickup(19134, 1, gRentStation[createID][vrLiP_Pos_X], gRentStation[createID][vrLiP_Pos_Y], gRentStation[createID][vrLiP_Pos_Z], 0, 0);
	SendInfoMessage(playerid, "You have created a Rent Type: "col_server"%d", gRentStation[ createID ][ vrType ]);
	return(true);
}
// --

public OnRentsLoad()
{
    new rows, fields, thisID, rowsCounter = 1, string[180];
    cache_get_data( rows, fields, _dbConnector );

	if( rows )
	{
		for( new i = 0; i < rows; i ++ )
		{
			thisID = rowsCounter;

			//

            gRentStation[ thisID ][ vrSQLID ] 			= cache_get_field_content_int( i, "vrSQLID" );
            gRentStation[ thisID ][ vrLiP_Pos_X ] 		= cache_get_field_content_float( i, "vrLiP_Pos_X" );
            gRentStation[ thisID ][ vrLiP_Pos_Y ] 		= cache_get_field_content_float( i, "vrLiP_Pos_Y" );
            gRentStation[ thisID ][ vrLiP_Pos_Z ] 		= cache_get_field_content_float( i, "vrLiP_Pos_Z" );
            gRentStation[ thisID ][ vrSpawn_Pos_X ]		= cache_get_field_content_float( i, "vrSpawn_Pos_X" );
            gRentStation[ thisID ][ vrSpawn_Pos_Y ] 		= cache_get_field_content_float( i, "vrSpawn_Pos_Y" );
            gRentStation[ thisID ][ vrSpawn_Pos_Z ] 		= cache_get_field_content_float( i, "vrSpawn_Pos_Z" );
            gRentStation[ thisID ][ vrSpawn_Pos_A ] 		= cache_get_field_content_float( i, "vrSpawn_Pos_A" );

            for(new j = 0; j < MAX_RENTMODELS; j++) {
            	format( string , sizeof( string ), "vr_model_%d", j);
            	gRentStation[ thisID ][ vrModel ][ j ] = cache_get_field_content_int( i, string );
            	format( string , sizeof( string ), "vr_price_%d", j);
            	gRentStation[ thisID ][ vrPrice ][ j ] = cache_get_field_content_int( i, string );

            	if( gRentStation[ thisID ][ vrModel ][ j ] >= 400 && gRentStation[ thisID ][ vrModel ][ j ] <= 611 )
					gRentStation[ thisID ][ vrVehModel ]++;
            }

			format(string, sizeof(string), "{02E102}Vehicle Rent Station: "col_white"%d\n"col_white"\nTo rent a vehicle, type\n/rentveh", thisID);
			gRentStation[thisID][VoziloRentLabel] = CreateDynamic3DTextLabel(string, 0xF5CF5DFF, gRentStation[thisID][vrLiP_Pos_X], gRentStation[thisID][vrLiP_Pos_Y], gRentStation[thisID][vrLiP_Pos_Z], 8.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1);
			gRentStation[thisID][VoziloRentPickup] = CreateDynamicPickup(19134, 1, gRentStation[thisID][vrLiP_Pos_X], gRentStation[thisID][vrLiP_Pos_Y], gRentStation[thisID][vrLiP_Pos_Z], 0, 0);

			//

            rowsCounter++;
		}
	}
	printf("[LOADED] %d vehicle rent booths", rows);
    return(true);
}

public OnRentsListModels( playerid ) {
	new  rows, fields, infoDialog[ 1000], title[20], model[MAX_RENTMODELS], counter = 0;
	cache_get_data( rows , fields, _dbConnector);
	if( !rows ) return SendErrorMessage(playerid, "An error occurred while showing the rent, contact the scripter!");
	else {
		for( new i = 0; i < MAX_RENTMODELS; i++) {
			format(title , sizeof( title ), "vr_model_%d", i);
			model[i] = cache_get_field_content_int(0, title);

			if( model[i] > 0) {
				format(infoDialog, sizeof( infoDialog ), "%s{006622}(%d). "col_white"%s\n", infoDialog, counter+1, GetVehicleNameEx( model[i] ) );
				DBListRent[playerid][counter] = model[i];
				counter++;
			}
		}
		format(infoDialog, sizeof(infoDialog), "Model:\n%s", infoDialog);
		if(counter != 0)
			ShowPlayerDialog(playerid, dialog_RENTMODELLIST, DIALOG_STYLE_TABLIST_HEADERS, "{FFFFFF}Rent Vehicle:", infoDialog, "Confirm", "Abort");
		else {
			return SendErrorMessage(playerid,"There are no models created for this rent!");
		}
	}
	return true;
}


public  OnRentChangeModel( playerid, modelID ) {
	new  rows, fields, tempVar = 0, title[20], id, model[MAX_RENTMODELS];
	cache_get_data( rows , fields, _dbConnector);
	if( !rows ) return SendErrorMessage(playerid, "An error occurred while changing the rental model - mysql, contact the scripter!");
	else {
		id = cache_get_field_content_int(0, "vrSQLID");

		for( new i = 0; i < MAX_VRENT; i++) {
			if( gRentStation[ i ][ vrSQLID] == id ) {
				for( new j = 0; j < MAX_RENTMODELS; j++) {
					format(title , sizeof( title ), "vr_model_%d", j);
					model[j] = cache_get_field_content_int(0, title);
					if( model[j] == choosedRentID[playerid]) {
						gRentStation[i][vrModel][j] = modelID;
						SaveRentEdit( playerid, i);
						tempVar++;
						break; 
					}
				}
			}
		}
		if(tempVar != 0) {
			SendInfoMessage(playerid, "You have successfully replaced the model : "col_server"%s"col_white" with model : "col_server"%s", GetVehicleNameEx( choosedRentID[playerid] ), GetVehicleNameEx( modelID ));
			choosedRentID[ playerid ] = -1;
		}
		else
			SendInfoMessage(playerid, "An error occurred while replacing the model - mysql, contact the scripter");
	}
	return true;
}


public  OnRentRemoveModel( playerid ) {
	new  rows, fields, tempVar = 0, title[20], id, model[MAX_RENTMODELS];
	cache_get_data( rows , fields, _dbConnector);
	if( !rows ) return SendErrorMessage(playerid, "An error occurred while replacing the model - mysql, contact the scripter!");
	else {
		id = cache_get_field_content_int(0, "vrSQLID");

		for( new i = 0; i < MAX_VRENT; i++) {
			if( gRentStation[ i ][ vrSQLID] == id ) {
				for( new j = 0; j < MAX_RENTMODELS; j++) {
					format(title , sizeof( title ), "vr_model_%d", j);
					model[j] = cache_get_field_content_int(0, title);
					if( model[j] == choosedRentID[playerid]) {
						gRentStation[i][vrModel][j] = 0;
						gRentStation[i][vrPrice][j] = 0;
						SaveRentEdit( playerid, i);
						tempVar++;
						break; 
					}
				}
			}
		}
		if(tempVar != 0) {
			SendInfoMessage(playerid, "You have successfully deleted the model : "col_server"%s .", GetVehicleNameEx( choosedRentID[playerid] ));
			choosedRentID[ playerid ] = -1;
		}
		else
			SendInfoMessage(playerid, "An error occurred while deleting the model - mysql, contact the scriptor");
	}
	return true;
}
/*
stock ShowRentTimer(playerid, time)
{
	new txt[56];
	if(time > 600)
		format(txt, sizeof(txt), "~w~Rent left: ~g~%s", rent_time_convert(time - gettime()));
	else if(time < 600 && time > 299)
		format(txt, sizeof(txt), "~w~Rent left: ~y~%s", rent_time_convert(time - gettime()));
	else
		format(txt, sizeof(txt), "~w~Rent left: ~r~%s", rent_time_convert(time - gettime()));
	PlayerTextDrawSetString(playerid, RentTD[playerid][1], txt); 
	PlayerTextDrawShow(playerid, RentTD[playerid][1]);
	PlayerTextDrawShow(playerid, RentTD[playerid][0]);
	KillTimer(rentTimer[playerid]);
	rentTimer[playerid] = SetTimerEx("HideRentTimer", 2000, false, "i", playerid);
	return 1;
}
forward HideRentTimer(playerid);
public HideRentTimer(playerid) {
	PlayerTextDrawHide(playerid, RentTD[playerid][1]);
	PlayerTextDrawHide(playerid, RentTD[playerid][0]);
	return 1;
}
*/
public OnRentsListPrice( playerid ) {
	new  rows, fields, infoDialog[ 1000], title[20], model[MAX_RENTMODELS], price[MAX_RENTMODELS],  counter = 0;
	cache_get_data( rows , fields, _dbConnector);
	if( !rows ) return SendErrorMessage(playerid, "An error occurred while showing the rent, contact the scripter!");
	else {
		for( new i = 0; i < MAX_RENTMODELS; i++) {
			format(title , sizeof( title ), "vr_model_%d", i);
			model[i] = cache_get_field_content_int(0, title);
			format(title , sizeof( title ), "vr_price_%d", i);
			price[i] = cache_get_field_content_int(0, title);

			if( model[i] > 0) {
				format(infoDialog, sizeof( infoDialog ), "%s{006622}(%d). "col_white"%s\t$%d\n", infoDialog, counter+1, GetVehicleNameEx( model[i] ), price[i] );
				DBListRent[playerid][counter] = model[i];
				counter++;
			}
		}
		format(infoDialog, sizeof(infoDialog), "Model:\tPrice:\n%s", infoDialog);
		if(counter != 0)
			ShowPlayerDialog(playerid, dialog_RENTPRICELIST, DIALOG_STYLE_TABLIST_HEADERS, "{FFFFFF}Rent Vehicle:", infoDialog, "Confirm", "Abort");
		else {
			return SendErrorMessage(playerid,"There are no models created for this rent area!");
		}
	}
	return true;
}


public  OnRentChangePrice( playerid, inputPrice ) {
	new  rows, fields, tempVar = 0, title[20], id, model[MAX_RENTMODELS];
	cache_get_data( rows , fields, _dbConnector);
	if( !rows ) return SendErrorMessage(playerid, "An error occurred while changing the rental model - mysql, contact the scriptor!");
	else {
		id = cache_get_field_content_int(0, "vrSQLID");

		for( new i = 0; i < MAX_VRENT; i++) {
			if( gRentStation[ i ][ vrSQLID] == id ) {
				for( new j = 0; j < MAX_RENTMODELS; j++) {
					format(title , sizeof( title ), "vr_model_%d", j);
					model[j] = cache_get_field_content_int(0, title);
					if( model[j] == choosedRentID[playerid]) {
						gRentStation[i][vrPrice][j] = inputPrice;
						SaveRentEdit( playerid, i);
						tempVar++;
						break; 
					}
				}
			}
		}
		if(tempVar != 0) {
			SendInfoMessage(playerid, "You have successfully changed the rental price of the model : "col_server"%s"col_white" new amount : "col_server"%d$", GetVehicleNameEx( choosedRentID[playerid] ), inputPrice);
			choosedRentID[ playerid ] = -1;
		}
		else
			SendInfoMessage(playerid, "An error occurred while changing the rental model - mysql, contact the scriptor");
	}
	return true;
}
//=====================[ ALS ]=====================================
public OnPlayerConnect( playerid)
{
	//KillTimer(rentTimer[ playerid ]);
	CreateRentID[ playerid ] =
	choosedRentID[ playerid ] =
	choosedRentEditID[ playerid ] =
	showedRent[ playerid ] = false;
	for( new i = 0; i < MAX_RENTMODELS; i++) {
		DBListRent[playerid][i] = 0;
	}
	/*RentTD[playerid][0] = CreatePlayerTextDraw(playerid, 225.000000, 372.000000, "_");
	PlayerTextDrawFont(playerid, RentTD[playerid][0], 1);
	PlayerTextDrawLetterSize(playerid, RentTD[playerid][0], 0.683332, 1.300003);
	PlayerTextDrawTextSize(playerid, RentTD[playerid][0], 298.500000, 90.000000);
	PlayerTextDrawSetOutline(playerid, RentTD[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, RentTD[playerid][0], 0);
	PlayerTextDrawAlignment(playerid, RentTD[playerid][0], 2);
	PlayerTextDrawColor(playerid, RentTD[playerid][0], -1);
	PlayerTextDrawBackgroundColor(playerid, RentTD[playerid][0], 255);
	PlayerTextDrawBoxColor(playerid, RentTD[playerid][0], 9109589);
	PlayerTextDrawUseBox(playerid, RentTD[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, RentTD[playerid][0], 1);
	PlayerTextDrawSetSelectable(playerid, RentTD[playerid][0], 0);

	RentTD[playerid][1] = CreatePlayerTextDraw(playerid, 224.000000, 372.000000, "Rent left: 30 minutes");
	PlayerTextDrawFont(playerid, RentTD[playerid][1], 1);
	PlayerTextDrawLetterSize(playerid, RentTD[playerid][1], 0.183332, 1.000000);
	PlayerTextDrawTextSize(playerid, RentTD[playerid][1], 380.000000, 722.000000);
	PlayerTextDrawSetOutline(playerid, RentTD[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, RentTD[playerid][1], 0);
	PlayerTextDrawAlignment(playerid, RentTD[playerid][1], 2);
	PlayerTextDrawColor(playerid, RentTD[playerid][1], -1);
	PlayerTextDrawBackgroundColor(playerid, RentTD[playerid][1], 100);
	PlayerTextDrawBoxColor(playerid, RentTD[playerid][1], 50);
	PlayerTextDrawUseBox(playerid, RentTD[playerid][1], 0);
	PlayerTextDrawSetProportional(playerid, RentTD[playerid][1], 1);
	PlayerTextDrawSetSelectable(playerid, RentTD[playerid][1], 0);*/
	#if defined 	als_rent_OnPlayerConnect
		return 	als_rent_OnPlayerConnect( playerid );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect als_rent_OnPlayerConnect
#if defined 	als_rent_OnPlayerConnect
	forward 	als_rent_OnPlayerConnect( playerid );
#endif

public OnPlayerDisconnect(playerid, reason)
{
	if( CreateRentID[ playerid] != 1) {
		CreateRentID[ playerid ] = -1;
	}
	if( choosedRentID[ playerid ] != -1 ) {
		choosedRentID[ playerid ] = -1;
	}
	if( choosedRentEditID[ playerid ] != -1 ) {
		choosedRentEditID[ playerid ] = -1;
	}
	for( new i = 0; i < MAX_RENTMODELS; i++) {
		if( DBListRent[playerid][i] != 0)
			DBListRent[playerid][i] = 0;
	}

	#if defined 	als_rent_OnPlayerDisconnect
		return 	als_rent_OnPlayerDisconnect( playerid, reason );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif

#define OnPlayerDisconnect als_rent_OnPlayerDisconnect
#if defined 	als_rent_OnPlayerDisconnect
	forward 	als_rent_OnPlayerDisconnect( playerid, reason );
#endif
