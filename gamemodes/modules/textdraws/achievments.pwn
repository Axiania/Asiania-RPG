// Module For Textdraws - Achievment
// Skripter: Lanmi
// Textdraws: Marshal Newton - NWN




//=====================[ DEFINES & Player Variables]=================================

new PlayerText:AchievmentsTD[MAX_PLAYERS][6];
new bool: showedAchievments[ MAX_PLAYERS ];

//=====================[ FUNCTIONS ]==================================================

AchievmentTDControl( playerid, bool:show, nameAchStr[] = "") {

	if( show ) {
		AchievmentsTD[playerid][0] = CreatePlayerTextDraw(playerid, 501.000000, 149.000000, "box");
		PlayerTextDrawLetterSize(playerid, AchievmentsTD[playerid][0], 0.000000, 3.176470);
		PlayerTextDrawTextSize(playerid, AchievmentsTD[playerid][0], 603.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, AchievmentsTD[playerid][0], 1);
		PlayerTextDrawColor(playerid, AchievmentsTD[playerid][0], -1);
		PlayerTextDrawUseBox(playerid, AchievmentsTD[playerid][0], 1);
		PlayerTextDrawBoxColor(playerid, AchievmentsTD[playerid][0], 336860415);
		PlayerTextDrawSetShadow(playerid, AchievmentsTD[playerid][0], 0);
		PlayerTextDrawBackgroundColor(playerid, AchievmentsTD[playerid][0], 255);
		PlayerTextDrawFont(playerid, AchievmentsTD[playerid][0], 1);
		PlayerTextDrawSetProportional(playerid, AchievmentsTD[playerid][0], 1);

		AchievmentsTD[playerid][1] = CreatePlayerTextDraw(playerid, 499.000000, 154.000000, "particle:lamp_shad_64");
		PlayerTextDrawTextSize(playerid, AchievmentsTD[playerid][1], 114.000000, -7.000000);
		PlayerTextDrawAlignment(playerid, AchievmentsTD[playerid][1], 1);
		PlayerTextDrawColor(playerid, AchievmentsTD[playerid][1], 761825480);
		PlayerTextDrawSetShadow(playerid, AchievmentsTD[playerid][1], 0);
		PlayerTextDrawBackgroundColor(playerid, AchievmentsTD[playerid][1], 255);
		PlayerTextDrawFont(playerid, AchievmentsTD[playerid][1], 4);
		PlayerTextDrawSetProportional(playerid, AchievmentsTD[playerid][1], 0);

		AchievmentsTD[playerid][2] = CreatePlayerTextDraw(playerid, 518.235107, 152.083328, "ACHIEVEMENT_UNLOCKED!");
		PlayerTextDrawLetterSize(playerid, AchievmentsTD[playerid][2], 0.132235, 0.689998);
		PlayerTextDrawAlignment(playerid, AchievmentsTD[playerid][2], 1);
		PlayerTextDrawColor(playerid, AchievmentsTD[playerid][2], -1);
		PlayerTextDrawSetShadow(playerid, AchievmentsTD[playerid][2], 0);
		PlayerTextDrawBackgroundColor(playerid, AchievmentsTD[playerid][2], 255);
		PlayerTextDrawFont(playerid, AchievmentsTD[playerid][2], 1);
		PlayerTextDrawSetProportional(playerid, AchievmentsTD[playerid][2], 1);

		AchievmentsTD[playerid][3] = CreatePlayerTextDraw(playerid, 497.882720, 145.016723, "ld_beat:chit");
		PlayerTextDrawTextSize(playerid, AchievmentsTD[playerid][3], 19.000000, 22.000000);
		PlayerTextDrawAlignment(playerid, AchievmentsTD[playerid][3], 1);
		PlayerTextDrawColor(playerid, AchievmentsTD[playerid][3], 761825535);
		PlayerTextDrawSetShadow(playerid, AchievmentsTD[playerid][3], 0);
		PlayerTextDrawBackgroundColor(playerid, AchievmentsTD[playerid][3], 255);
		PlayerTextDrawFont(playerid, AchievmentsTD[playerid][3], 4);
		PlayerTextDrawSetProportional(playerid, AchievmentsTD[playerid][3], 0);

		AchievmentsTD[playerid][4] = CreatePlayerTextDraw(playerid, 500.823608, 148.583389, "]");
		PlayerTextDrawLetterSize(playerid, AchievmentsTD[playerid][4], 0.400000, 1.600000);
		PlayerTextDrawAlignment(playerid, AchievmentsTD[playerid][4], 1);
		PlayerTextDrawColor(playerid, AchievmentsTD[playerid][4], 336860415);
		PlayerTextDrawSetShadow(playerid, AchievmentsTD[playerid][4], 0);
		PlayerTextDrawBackgroundColor(playerid, AchievmentsTD[playerid][4], 255);
		PlayerTextDrawFont(playerid, AchievmentsTD[playerid][4], 2);
		PlayerTextDrawSetProportional(playerid, AchievmentsTD[playerid][4], 1);

		AchievmentsTD[playerid][5] = CreatePlayerTextDraw(playerid, 550.235046, 169.583297, "");
		PlayerTextDrawLetterSize(playerid, AchievmentsTD[playerid][5], 0.132235, 0.689998);
		PlayerTextDrawAlignment(playerid, AchievmentsTD[playerid][5], 2);
		PlayerTextDrawColor(playerid, AchievmentsTD[playerid][5], -1);
		PlayerTextDrawSetShadow(playerid, AchievmentsTD[playerid][5], 0);
		PlayerTextDrawBackgroundColor(playerid, AchievmentsTD[playerid][5], 255);
		PlayerTextDrawFont(playerid, AchievmentsTD[playerid][5], 1);
		PlayerTextDrawSetProportional(playerid, AchievmentsTD[playerid][5], 1);

		for( new index = 0; index < 6; index++) {
			PlayerTextDrawShow(playerid, AchievmentsTD[ playerid ][ index ]);
		}

		PlayerTextDrawSetString(playerid, AchievmentsTD[ playerid ][ 5 ], nameAchStr);
		showedAchievments[ playerid ] = true;
	}
	else {
		for( new index = 0; index < 6; index++) {
			PlayerTextDrawHide(playerid, AchievmentsTD[ playerid ][ index ]);
			PlayerTextDrawDestroy(playerid, AchievmentsTD[ playerid ][ index ]);
			AchievmentsTD[ playerid ][ index ] = PlayerText: INVALID_TEXT_DRAW;
		}
		showedAchievments[ playerid ] = false;
	}
	

}


postaviMedalju( medalja[], playerid, kolicina )
{
	new tekst[ 50 ];
	format( tekst, sizeof tekst, "%s~n~(%d)", medalja, kolicina );
	AchievmentTDControl( playerid, true, tekst);
	if( kolicina == 1 ) postaviSmaragde( playerid, 3 );
	else if( kolicina == 100 ) postaviSmaragde( playerid, 6 );
	else if( kolicina == 1000 ) postaviSmaragde( playerid, 9 );
	else if( kolicina == 10000 ) postaviSmaragde( playerid, 12 );
	else postaviSmaragde( playerid, 3 );
	gPlayerData[ playerid ][ E_PLAYER_RESPECT ] ++;
	sql_user_update_integer( playerid, "exp", gPlayerData[ playerid ][ E_PLAYER_RESPECT ] );
	SetTimerEx( "skloniATD", 5000, false, "i", playerid );
	return 1;
}

forward skloniATD( playerid );
public skloniATD( playerid )
{
	AchievmentTDControl( playerid, false);
	return 1;
}

//=====================[ ALS ]=====================================
public OnPlayerConnect( playerid)
{
	showedAchievments[ playerid ] = false;
	#if defined 	als_td_ach_OnPlayerConnect
		return 	als_td_ach_OnPlayerConnect( playerid );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect als_td_ach_OnPlayerConnect
#if defined 	als_td_ach_OnPlayerConnect
	forward 	als_td_ach_OnPlayerConnect( playerid );
#endif

public OnPlayerDisconnect(playerid, reason)
{

	if( showedAchievments[ playerid ] ) 
		AchievmentTDControl( playerid, false);

	#if defined 	als_td_ach_OnPlayerDisconnect
		return 	als_td_ach_OnPlayerDisconnect( playerid, reason );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif

#define OnPlayerDisconnect als_td_ach_OnPlayerDisconnect
#if defined 	als_td_ach_OnPlayerDisconnect
	forward 	als_td_ach_OnPlayerDisconnect( playerid, reason );
#endif
