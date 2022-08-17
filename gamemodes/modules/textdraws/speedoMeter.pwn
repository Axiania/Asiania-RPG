//Replica of Valrise's speedometer


//=====================[ DEFINES & Player Variables]=================================

new PlayerText:pSpeedometar[MAX_PLAYERS][12];

new bool: showedSpeedometer[ MAX_PLAYERS ];

new const Float:TopSpeed[212] = {
	157.0, 147.0, 186.0, 110.0, 133.0, 164.0, 110.0, 148.0, 100.0, 158.0, 129.0, 221.0, 168.0, 110.0, 105.0, 192.0, 154.0, 270.0, 115.0, 149.0,
	145.0, 154.0, 140.0, 99.0,  135.0, 270.0, 173.0, 165.0, 157.0, 201.0, 190.0, 130.0, 94.0,  110.0, 167.0, 0.0,   149.0, 158.0, 142.0, 168.0,
	136.0, 145.0, 139.0, 126.0, 110.0, 164.0, 270.0, 270.0, 111.0, 0.0,   0.0,   193.0, 270.0, 60.0,  135.0, 157.0, 106.0, 95.0,  157.0, 136.0,
	270.0, 160.0, 111.0, 142.0, 145.0, 145.0, 147.0, 140.0, 144.0, 270.0, 157.0, 110.0, 190.0, 190.0, 149.0, 173.0, 270.0, 186.0, 117.0, 140.0,
	184.0, 73.0,  156.0, 122.0, 190.0, 99.0,  64.0,  270.0, 270.0, 139.0, 157.0, 149.0, 140.0, 270.0, 214.0, 176.0, 162.0, 270.0, 108.0, 123.0,
	140.0, 145.0, 216.0, 216.0, 173.0, 140.0, 179.0, 166.0, 108.0, 79.0,  101.0, 270.0,	270.0, 270.0, 120.0, 142.0, 157.0, 157.0, 164.0, 270.0, 
	270.0, 160.0, 176.0, 151.0, 130.0, 160.0, 158.0, 149.0, 176.0, 149.0, 60.0,  70.0,  110.0, 167.0, 168.0, 158.0, 173.0, 0.0,   0.0,   270.0,
	149.0, 203.0, 164.0, 151.0, 150.0, 147.0, 149.0, 142.0, 270.0, 153.0, 145.0, 157.0, 121.0, 270.0, 144.0, 158.0, 113.0, 113.0, 156.0, 178.0,
	169.0, 154.0, 178.0, 270.0, 145.0, 165.0, 160.0, 173.0, 146.0, 0.0,   0.0,   93.0,  60.0,  110.0, 60.0,  158.0, 158.0, 270.0, 130.0, 158.0,
	153.0, 151.0, 136.0, 85.0,  0.0,   153.0, 142.0, 165.0, 108.0, 162.0, 0.0,   0.0,   270.0, 270.0, 130.0, 190.0, 175.0, 175.0, 175.0, 158.0,
	151.0, 110.0, 169.0, 171.0, 148.0, 152.0, 0.0,   0.0,   0.0,   108.0, 0.0,   0.0
};
#define GetVehicleModelTopSpeed(%0)				TopSpeed[((%0)-400)]
#define GetVehicleTopSpeed(%0)					GetVehicleModelTopSpeed(GetVehicleModel(%0))
//=====================[ Functions ]===============================


SpeedoTDControl( playerid, bool:show ) {
	if( show ) {

		pSpeedometar[playerid][10] = CreatePlayerTextDraw(playerid, 485.000000, 362.000000, "SpeedBox");
		PlayerTextDrawLetterSize(playerid, pSpeedometar[playerid][10], 0.310000, 6.999999);
		PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][10], 625.000000, 90.000000);
		PlayerTextDrawAlignment(playerid, pSpeedometar[playerid][10], 0);
		PlayerTextDrawColor(playerid, pSpeedometar[playerid][10], 0x00000000);
		PlayerTextDrawUseBox(playerid, pSpeedometar[playerid][10], 1);
		PlayerTextDrawBoxColor(playerid, pSpeedometar[playerid][10], 0x00000080);
		PlayerTextDrawSetShadow(playerid, pSpeedometar[playerid][10], 2);
		PlayerTextDrawSetOutline(playerid, pSpeedometar[playerid][10], 1);
		PlayerTextDrawBackgroundColor(playerid, pSpeedometar[playerid][10], 0x00000000);
		PlayerTextDrawFont(playerid, pSpeedometar[playerid][10], 2);
		PlayerTextDrawSetProportional(playerid, pSpeedometar[playerid][10], 1);
		PlayerTextDrawSetSelectable(playerid, pSpeedometar[playerid][10], 0);

		pSpeedometar[playerid][9] = CreatePlayerTextDraw(playerid, 535.000000, 393.000000, "SpeedBoxMovable");
		PlayerTextDrawLetterSize(playerid, pSpeedometar[playerid][9], 0.310000, 0.000000);
		PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][9], 532.000000, 60.000000);
		PlayerTextDrawAlignment(playerid, pSpeedometar[playerid][9], 0);
		PlayerTextDrawColor(playerid, pSpeedometar[playerid][9], 0x00000000);
		PlayerTextDrawUseBox(playerid, pSpeedometar[playerid][9], 1);
		PlayerTextDrawBoxColor(playerid, pSpeedometar[playerid][9], gPlayerData[ playerid ][ E_PLAYER_SPEEDO_COLOR ]);
		PlayerTextDrawSetShadow(playerid, pSpeedometar[playerid][9], 2);
		PlayerTextDrawSetOutline(playerid, pSpeedometar[playerid][9], 1);
		PlayerTextDrawBackgroundColor(playerid, pSpeedometar[playerid][9], 0x00000000);
		PlayerTextDrawFont(playerid, pSpeedometar[playerid][9], 2);
		PlayerTextDrawSetProportional(playerid, pSpeedometar[playerid][9], 1);
		PlayerTextDrawSetSelectable(playerid, pSpeedometar[playerid][9], 0);

		pSpeedometar[playerid][8] = CreatePlayerTextDraw(playerid, 535.000000, 399.000000, "FuelBox");
		PlayerTextDrawLetterSize(playerid, pSpeedometar[playerid][8], 0.310000, 0.899999);
		PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][8], 625.000000, 90.000000);
		PlayerTextDrawAlignment(playerid, pSpeedometar[playerid][8], 0);
		PlayerTextDrawColor(playerid, pSpeedometar[playerid][8], 0x00000000);
		PlayerTextDrawUseBox(playerid, pSpeedometar[playerid][8], 1);
		PlayerTextDrawBoxColor(playerid, pSpeedometar[playerid][8], 0x00000080);
		PlayerTextDrawSetShadow(playerid, pSpeedometar[playerid][8], 2);
		PlayerTextDrawSetOutline(playerid, pSpeedometar[playerid][8], 1);
		PlayerTextDrawBackgroundColor(playerid, pSpeedometar[playerid][8], 0x00000000);
		PlayerTextDrawFont(playerid, pSpeedometar[playerid][8], 2);
		PlayerTextDrawSetProportional(playerid, pSpeedometar[playerid][8], 1);
		PlayerTextDrawSetSelectable(playerid, pSpeedometar[playerid][8], 0);

		pSpeedometar[playerid][7] = CreatePlayerTextDraw(playerid, 535.000000, 399.000000, "FuelBoxMovable");
		PlayerTextDrawLetterSize(playerid, pSpeedometar[playerid][7], 0.310000, 0.899999);
		PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][7], 532.497131, 60.000000);
		PlayerTextDrawAlignment(playerid, pSpeedometar[playerid][7], 0);
		PlayerTextDrawColor(playerid, pSpeedometar[playerid][7], 0x00000000);
		PlayerTextDrawUseBox(playerid, pSpeedometar[playerid][7], 1);
		PlayerTextDrawBoxColor(playerid, pSpeedometar[playerid][7], gPlayerData[ playerid ][ E_PLAYER_SPEEDO_COLOR ]);
		PlayerTextDrawSetShadow(playerid, pSpeedometar[playerid][7], 2);
		PlayerTextDrawSetOutline(playerid, pSpeedometar[playerid][7], 1);
		PlayerTextDrawBackgroundColor(playerid, pSpeedometar[playerid][7], 0x00000000);
		PlayerTextDrawFont(playerid, pSpeedometar[playerid][7], 2);
		PlayerTextDrawSetProportional(playerid, pSpeedometar[playerid][7], 1);
		PlayerTextDrawSetSelectable(playerid, pSpeedometar[playerid][7], 0);

		pSpeedometar[playerid][6] = CreatePlayerTextDraw(playerid, 535.000000, 413.000000, "BatteryBox");
		PlayerTextDrawLetterSize(playerid, pSpeedometar[playerid][6], 0.310000, 0.899999);
		PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][6], 625.000000, 90.000000);
		PlayerTextDrawAlignment(playerid, pSpeedometar[playerid][6], 0);
		PlayerTextDrawColor(playerid, pSpeedometar[playerid][6], 0x00000000);
		PlayerTextDrawUseBox(playerid, pSpeedometar[playerid][6], 1);
		PlayerTextDrawBoxColor(playerid, pSpeedometar[playerid][6], 0x00000080);
		PlayerTextDrawSetShadow(playerid, pSpeedometar[playerid][6], 2);
		PlayerTextDrawSetOutline(playerid, pSpeedometar[playerid][6], 1);
		PlayerTextDrawBackgroundColor(playerid, pSpeedometar[playerid][6], 0x00000000);
		PlayerTextDrawFont(playerid, pSpeedometar[playerid][6], 2);
		PlayerTextDrawSetProportional(playerid, pSpeedometar[playerid][6], 1);
		PlayerTextDrawSetSelectable(playerid, pSpeedometar[playerid][6], 0);

		pSpeedometar[playerid][5] = CreatePlayerTextDraw(playerid, 535.000000, 413.000000, "BatteryBoxMovable");
		PlayerTextDrawLetterSize(playerid, pSpeedometar[playerid][5], 0.310000, 0.899999);
		PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][5], 532.565002, 60.000000);
		PlayerTextDrawAlignment(playerid, pSpeedometar[playerid][5], 0);
		PlayerTextDrawColor(playerid, pSpeedometar[playerid][5], 0x00000000);
		PlayerTextDrawUseBox(playerid, pSpeedometar[playerid][5], 1);
		PlayerTextDrawBoxColor(playerid, pSpeedometar[playerid][5], gPlayerData[ playerid ][ E_PLAYER_SPEEDO_COLOR ]);
		PlayerTextDrawSetShadow(playerid, pSpeedometar[playerid][5], 2);
		PlayerTextDrawSetOutline(playerid, pSpeedometar[playerid][5], 1);
		PlayerTextDrawBackgroundColor(playerid, pSpeedometar[playerid][5], 0x00000000);
		PlayerTextDrawFont(playerid, pSpeedometar[playerid][5], 2);
		PlayerTextDrawSetProportional(playerid, pSpeedometar[playerid][5], 1);
		PlayerTextDrawSetSelectable(playerid, pSpeedometar[playerid][5], 0);

		pSpeedometar[playerid][3] = CreatePlayerTextDraw(playerid, 484.000000, 368.000000, "Preview");
		PlayerTextDrawLetterSize(playerid, pSpeedometar[playerid][3], 0.360000, 0.099999);
		PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][3], 50.000000, 50.000000);
		PlayerTextDrawAlignment(playerid, pSpeedometar[playerid][3], 2);
		PlayerTextDrawColor(playerid, pSpeedometar[playerid][3], 0xFFFFFFFF);
		PlayerTextDrawUseBox(playerid, pSpeedometar[playerid][3], 1);
		PlayerTextDrawBoxColor(playerid, pSpeedometar[playerid][3], 0x000000FF);
		PlayerTextDrawSetShadow(playerid, pSpeedometar[playerid][3], 2);
		PlayerTextDrawSetOutline(playerid, pSpeedometar[playerid][3], 1);
		PlayerTextDrawBackgroundColor(playerid, pSpeedometar[playerid][3], 0x00000000);
		PlayerTextDrawFont(playerid, pSpeedometar[playerid][3], 5);
		PlayerTextDrawSetProportional(playerid, pSpeedometar[playerid][3], 1);
		PlayerTextDrawSetSelectable(playerid, pSpeedometar[playerid][3], 0);
		PlayerTextDrawSetPreviewModel(playerid, pSpeedometar[playerid][3], 480);
		PlayerTextDrawSetPreviewRot(playerid, pSpeedometar[playerid][3], -16.000000, 0.000000, -55.000000, 1.000000);
		PlayerTextDrawSetPreviewVehCol(playerid, pSpeedometar[playerid][3], 126, 126);

		pSpeedometar[playerid][2] = CreatePlayerTextDraw(playerid, 485.000000, 362.000000, "SpeedBox");
		PlayerTextDrawLetterSize(playerid, pSpeedometar[playerid][2], 0.310000, 6.999999);
		PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][2], 532.000000, 90.000000);
		PlayerTextDrawAlignment(playerid, pSpeedometar[playerid][2], 0);
		PlayerTextDrawColor(playerid, pSpeedometar[playerid][2], 0x00000000);
		PlayerTextDrawUseBox(playerid, pSpeedometar[playerid][2], 1);
		PlayerTextDrawBoxColor(playerid, pSpeedometar[playerid][2], 0x00000020);
		PlayerTextDrawSetShadow(playerid, pSpeedometar[playerid][2], 2);
		PlayerTextDrawSetOutline(playerid, pSpeedometar[playerid][2], 1);
		PlayerTextDrawBackgroundColor(playerid, pSpeedometar[playerid][2], 0x00000000);
		PlayerTextDrawFont(playerid, pSpeedometar[playerid][2], 2);
		PlayerTextDrawSetProportional(playerid, pSpeedometar[playerid][2], 1);
		PlayerTextDrawSetSelectable(playerid, pSpeedometar[playerid][2], 0);

		pSpeedometar[playerid][1] = CreatePlayerTextDraw(playerid, 580.000000, 380.000000, "~g~~h~ENG ~w~LCK ~w~SBLT ~g~~h~LIG");
		PlayerTextDrawLetterSize(playerid, pSpeedometar[playerid][1], 0.150000, 1.100000);
		PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][1], 1280.000000, 1280.000000);
		PlayerTextDrawAlignment(playerid, pSpeedometar[playerid][1], 2);
		PlayerTextDrawColor(playerid, pSpeedometar[playerid][1], 0xFFFFFFFF);
		PlayerTextDrawUseBox(playerid, pSpeedometar[playerid][1], 0);
		PlayerTextDrawBoxColor(playerid, pSpeedometar[playerid][1], 0x80808080);
		PlayerTextDrawSetShadow(playerid, pSpeedometar[playerid][1], 2);
		PlayerTextDrawSetOutline(playerid, pSpeedometar[playerid][1], 1);
		PlayerTextDrawBackgroundColor(playerid, pSpeedometar[playerid][1], 0x00000080);
		PlayerTextDrawFont(playerid, pSpeedometar[playerid][1], 2);
		PlayerTextDrawSetProportional(playerid, pSpeedometar[playerid][1], 1);
		PlayerTextDrawSetSelectable(playerid, pSpeedometar[playerid][1], 0);

		pSpeedometar[playerid][0] = CreatePlayerTextDraw(playerid, 535.000000, 399.000000, "FUEL: 21.4l");
		PlayerTextDrawLetterSize(playerid, pSpeedometar[playerid][0], 0.150000, 1.000000);
		PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][0], 1280.000000, 1280.000000);
		PlayerTextDrawAlignment(playerid, pSpeedometar[playerid][0], 0);
		PlayerTextDrawColor(playerid, pSpeedometar[playerid][0], 0xFFFFFFFF);
		PlayerTextDrawUseBox(playerid, pSpeedometar[playerid][0], 0);
		PlayerTextDrawBoxColor(playerid, pSpeedometar[playerid][0], 0x80808080);
		PlayerTextDrawSetShadow(playerid, pSpeedometar[playerid][0], 2);
		PlayerTextDrawSetOutline(playerid, pSpeedometar[playerid][0], 1);
		PlayerTextDrawBackgroundColor(playerid, pSpeedometar[playerid][0], 0x00000080);
		PlayerTextDrawFont(playerid, pSpeedometar[playerid][0], 2);
		PlayerTextDrawSetProportional(playerid, pSpeedometar[playerid][0], 1);
		PlayerTextDrawSetSelectable(playerid, pSpeedometar[playerid][0], 0);

		pSpeedometar[playerid][4] = CreatePlayerTextDraw(playerid, 535.000000, 413.000000, "HEALTH: 99.5%");
		PlayerTextDrawLetterSize(playerid, pSpeedometar[playerid][4], 0.150000, 1.000000);
		PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][4], 1280.000000, 1280.000000);
		PlayerTextDrawAlignment(playerid, pSpeedometar[playerid][4], 0);
		PlayerTextDrawColor(playerid, pSpeedometar[playerid][4], 0xFFFFFFFF);
		PlayerTextDrawUseBox(playerid, pSpeedometar[playerid][4], 0);
		PlayerTextDrawBoxColor(playerid, pSpeedometar[playerid][4], 0x80808080);
		PlayerTextDrawSetShadow(playerid, pSpeedometar[playerid][4], 2);
		PlayerTextDrawSetOutline(playerid, pSpeedometar[playerid][4], 1);
		PlayerTextDrawBackgroundColor(playerid, pSpeedometar[playerid][4], 0x00000080);
		PlayerTextDrawFont(playerid, pSpeedometar[playerid][4], 2);
		PlayerTextDrawSetProportional(playerid, pSpeedometar[playerid][4], 1);
		PlayerTextDrawSetSelectable(playerid, pSpeedometar[playerid][4], 0);

		pSpeedometar[playerid][11] = CreatePlayerTextDraw(playerid, 580.000000, 362.000000, "0 kmh");
		PlayerTextDrawLetterSize(playerid, pSpeedometar[playerid][11], 0.310000, 1.800000);
		PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][11], 1280.000000, 1280.000000);
		PlayerTextDrawAlignment(playerid, pSpeedometar[playerid][11], 2);
		PlayerTextDrawColor(playerid, pSpeedometar[playerid][11], 0xFFFFFFFF);
		PlayerTextDrawUseBox(playerid, pSpeedometar[playerid][11], 0);
		PlayerTextDrawBoxColor(playerid, pSpeedometar[playerid][11], 0x80808080);
		PlayerTextDrawSetShadow(playerid, pSpeedometar[playerid][11], 2);
		PlayerTextDrawSetOutline(playerid, pSpeedometar[playerid][11], 1);
		PlayerTextDrawBackgroundColor(playerid, pSpeedometar[playerid][11], 0x00000080);
		PlayerTextDrawFont(playerid, pSpeedometar[playerid][11], 2);
		PlayerTextDrawSetProportional(playerid, pSpeedometar[playerid][11], 1);
		PlayerTextDrawSetSelectable(playerid, pSpeedometar[playerid][11], 0);

		for( new index = 0; index < 12; index++) {
			PlayerTextDrawShow(playerid, pSpeedometar[ playerid ][ index ] ); 
		}
		showedSpeedometer[ playerid ] = true;
	}
	else {
		for( new index = 0; index < 12; index++) {
			PlayerTextDrawHide(playerid, pSpeedometar[ playerid ][ index ] ); 
			PlayerTextDrawDestroy(playerid, pSpeedometar[ playerid ][ index ] );
			pSpeedometar[ playerid ][ index ] = PlayerText: INVALID_TEXT_DRAW; 
		}
		showedSpeedometer[ playerid ] = false;
	}
	return true;
} 

update_speedo_int( playerid, type[], value) {
	new carid = GetPlayerVehicleID(playerid);
	if(carid > 0)
	{
		new engine, lights, alarm, doors, bonnet, boot, objective;
		GetVehicleParamsEx( carid, engine, lights, alarm, doors, bonnet, boot, objective );

		new valueStr[ 48 ];

		format( valueStr , sizeof( valueStr ), "%sENG %sLCK %sSBLT %sLIG", (engine == 0 ? ("~w~") : ("~g~~h~")), (doors == 0 ? ("~w~") : ("~g~~h~")), (Pojas[playerid] == false ? ("~w~") : ("~g~~h~")), (lights == 0 ? ("~w~") : ("~g~~h~")) );

		PlayerTextDrawSetString(playerid, pSpeedometar[ playerid ][ 1 ], valueStr); 
	}

	if(strcmp(type, "kmh", true) == 0) {
		new valueStr[ 15 ];
		format( valueStr , sizeof( valueStr ), "%d kmh", value );
		PlayerTextDrawSetString(playerid, pSpeedometar[ playerid ][ 11 ], valueStr); 
		if(carid > 0 && value >= 0)
		{
			new Float:top_speed = GetVehicleTopSpeed(carid);
			new Float:addX;
			addX = 92 * value / top_speed;
			if(value >= top_speed)
			{
				PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][9], 624.000000, 60.000000);
				PlayerTextDrawShow(playerid, pSpeedometar[ playerid ][ 9 ] ); 
			}
			else
			{
				PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][9], 532+addX, 60.000000);
				PlayerTextDrawShow(playerid, pSpeedometar[ playerid ][ 9 ] ); 
			}
		}
	}
	else if(strcmp(type, "fuel", true) == 0) { 
		new tempString[ 30 ];
		format( tempString, sizeof( tempString), "FUEL: %dL", value);
		PlayerTextDrawSetString(playerid, pSpeedometar[ playerid ][ 0 ], tempString); 
		if( value >= 0)
		{
			new Float:addX;
			addX = 92 * value / 100;
			if(value >= 100)
			{
				PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][7], 624.000000, 60.000000);
				PlayerTextDrawShow(playerid, pSpeedometar[ playerid ][ 7 ] ); 
			}
			else
			{
				PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][7], 532+addX, 60.000000);
				PlayerTextDrawShow(playerid, pSpeedometar[ playerid ][ 7 ] ); 
			}
		}
	}
	else if(strcmp(type, "modelVehicle", true) == 0) {
		PlayerTextDrawHide(playerid, pSpeedometar[playerid][3] );
		PlayerTextDrawSetPreviewModel(playerid, pSpeedometar[playerid][3], value);
		new col1, col2;
		GetVehicleColor( carid, col1, col2 );
		PlayerTextDrawSetPreviewVehCol(playerid, pSpeedometar[playerid][3], col1, col2);
		PlayerTextDrawShow(playerid, pSpeedometar[playerid][3] );
	}  
	else if(strcmp(type, "damage", true) == 0) {
		new valueStr[ 15 ];
		format( valueStr , sizeof( valueStr ), "HEALTH: %d", value );
		PlayerTextDrawSetString(playerid, pSpeedometar[ playerid ][ 4 ], valueStr);

		if(carid > 0 && value >= 0)
		{
			new Float:max_health = 1000.0;
			if( gVehicleData[ carid ][ E_VEHICLE_ARMOUR ] != 0 )
			{
				switch( gVehicleData[ carid ][ E_VEHICLE_ARMOUR ] ) {
					case 2000: max_health = 2000.0;
					case 3000: max_health = 3000.0;
					case 4000: max_health = 4000.0;
					case 5000: max_health = 5000.0;
					case 10000: max_health = 10000.0;
				}
			}
			new Float:addX;
			addX = 92 * value / max_health;
			if(value >= max_health)
			{
				PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][5], 624.000000, 60.000000);
				PlayerTextDrawShow(playerid, pSpeedometar[ playerid ][ 5 ] ); 
			}
			else
			{
				PlayerTextDrawTextSize(playerid, pSpeedometar[playerid][5], 532+addX, 60.000000);
				PlayerTextDrawShow(playerid, pSpeedometar[ playerid ][ 5 ] ); 
			}

		}
	}
}

//=====================[ ALS ]=====================================
public OnPlayerConnect( playerid)
{
	showedSpeedometer[ playerid ] = false;
	#if defined 	als_td_spdmt_OnPlayerConnect
		return 	als_td_spdmt_OnPlayerConnect( playerid );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect als_td_spdmt_OnPlayerConnect
#if defined 	als_td_spdmt_OnPlayerConnect
	forward 	als_td_spdmt_OnPlayerConnect( playerid );
#endif

public OnPlayerDisconnect(playerid, reason)
{

	if( showedSpeedometer[ playerid ] ) 
		SpeedoTDControl( playerid, false);

	#if defined 	als_td_spdmt_OnPlayerDisconnect
		return 	als_td_spdmt_OnPlayerDisconnect( playerid, reason );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif

#define OnPlayerDisconnect als_td_spdmt_OnPlayerDisconnect
#if defined 	als_td_spdmt_OnPlayerDisconnect
	forward 	als_td_spdmt_OnPlayerDisconnect( playerid, reason );
#endif