// Module For Textdraws - Notifications
// Skripter: Lanmi
// Textdraws: Marshal Newton - NWN

//=====================[ DEFINES & Player Variables]==================================



new PlayerText:NotificationsTD[MAX_PLAYERS][6];
new bool: showedNotifications[ MAX_PLAYERS ];


//=====================[ FUNCTIONS ]==================================================


NotificationsTDControl( playerid, bool:show, notifStr[ ] = "", infoNotifStr[ ] = "") {
	if( show && showedNotifications[ playerid ] == false) {
		NotificationsTD[playerid][0] = CreatePlayerTextDraw(playerid, 498.847198, 104.649925, "box");
		PlayerTextDrawLetterSize(playerid, NotificationsTD[playerid][0], 0.000000, 4.352941);
		PlayerTextDrawTextSize(playerid, NotificationsTD[playerid][0], 605.598632, 0.000000);
		PlayerTextDrawAlignment(playerid, NotificationsTD[playerid][0], 1);
		PlayerTextDrawColor(playerid, NotificationsTD[playerid][0], -1);
		PlayerTextDrawUseBox(playerid, NotificationsTD[playerid][0], 1);
		PlayerTextDrawBoxColor(playerid, NotificationsTD[playerid][0], 336860415);
		PlayerTextDrawSetShadow(playerid, NotificationsTD[playerid][0], 0);
		PlayerTextDrawBackgroundColor(playerid, NotificationsTD[playerid][0], 255);
		PlayerTextDrawFont(playerid, NotificationsTD[playerid][0], 1);
		PlayerTextDrawSetProportional(playerid, NotificationsTD[playerid][0], 1);

		NotificationsTD[playerid][1] = CreatePlayerTextDraw(playerid, 494.905822, 110.883460, "particle:lamp_shad_64");
		PlayerTextDrawTextSize(playerid, NotificationsTD[playerid][1], 119.000000, 35.000000);
		PlayerTextDrawAlignment(playerid, NotificationsTD[playerid][1], 1);
		PlayerTextDrawColor(playerid, NotificationsTD[playerid][1], 761825480);
		PlayerTextDrawSetShadow(playerid, NotificationsTD[playerid][1], 0);
		PlayerTextDrawBackgroundColor(playerid, NotificationsTD[playerid][1], 255);
		PlayerTextDrawFont(playerid, NotificationsTD[playerid][1], 4);
		PlayerTextDrawSetProportional(playerid, NotificationsTD[playerid][1], 0);

		NotificationsTD[playerid][2] = CreatePlayerTextDraw(playerid, 498.847320, 112.233253, "box");
		PlayerTextDrawLetterSize(playerid, NotificationsTD[playerid][2], 0.000000, 3.176470);
		PlayerTextDrawTextSize(playerid, NotificationsTD[playerid][2], 601.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, NotificationsTD[playerid][2], 1);
		PlayerTextDrawColor(playerid, NotificationsTD[playerid][2], -1);
		PlayerTextDrawUseBox(playerid, NotificationsTD[playerid][2], 1);
		PlayerTextDrawBoxColor(playerid, NotificationsTD[playerid][2], 336860415);
		PlayerTextDrawSetShadow(playerid, NotificationsTD[playerid][2], 0);
		PlayerTextDrawBackgroundColor(playerid, NotificationsTD[playerid][2], 255);
		PlayerTextDrawFont(playerid, NotificationsTD[playerid][2], 1);
		PlayerTextDrawSetProportional(playerid, NotificationsTD[playerid][2], 1);

		NotificationsTD[playerid][3] = CreatePlayerTextDraw(playerid, 501.329711, 107.383247, "box");
		PlayerTextDrawLetterSize(playerid, NotificationsTD[playerid][3], 0.000000, 0.258823);
		PlayerTextDrawTextSize(playerid, NotificationsTD[playerid][3], 562.500000, 0.000000);
		PlayerTextDrawAlignment(playerid, NotificationsTD[playerid][3], 1);
		PlayerTextDrawColor(playerid, NotificationsTD[playerid][3], 761825535);
		PlayerTextDrawUseBox(playerid, NotificationsTD[playerid][3], 1);
		PlayerTextDrawBoxColor(playerid, NotificationsTD[playerid][3], 761825535);
		PlayerTextDrawSetShadow(playerid, NotificationsTD[playerid][3], 0);
		PlayerTextDrawBackgroundColor(playerid, NotificationsTD[playerid][3], 255);
		PlayerTextDrawFont(playerid, NotificationsTD[playerid][3], 1);
		PlayerTextDrawSetProportional(playerid, NotificationsTD[playerid][3], 1);

		NotificationsTD[playerid][4] = CreatePlayerTextDraw(playerid, 504.923583, 104.399978, "");
		PlayerTextDrawLetterSize(playerid, NotificationsTD[playerid][4], 0.181176, 0.911665);
		PlayerTextDrawAlignment(playerid, NotificationsTD[playerid][4], 1);
		PlayerTextDrawColor(playerid, NotificationsTD[playerid][4], 336860415);
		PlayerTextDrawSetShadow(playerid, NotificationsTD[playerid][4], 0);
		PlayerTextDrawBackgroundColor(playerid, NotificationsTD[playerid][4], 255);
		PlayerTextDrawFont(playerid, NotificationsTD[playerid][4], 1);
		PlayerTextDrawSetProportional(playerid, NotificationsTD[playerid][4], 1);

		NotificationsTD[playerid][5] = CreatePlayerTextDraw(playerid, 507.664642, 120.766693, "");
		PlayerTextDrawLetterSize(playerid, NotificationsTD[playerid][5], 0.141645, 0.800831);
		PlayerTextDrawTextSize(playerid, NotificationsTD[playerid][5], 1.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, NotificationsTD[playerid][5], 1);
		PlayerTextDrawColor(playerid, NotificationsTD[playerid][5], -1);
		PlayerTextDrawSetShadow(playerid, NotificationsTD[playerid][5], 0);
		PlayerTextDrawBackgroundColor(playerid, NotificationsTD[playerid][5], 255);
		PlayerTextDrawFont(playerid, NotificationsTD[playerid][5], 1);
		PlayerTextDrawSetProportional(playerid, NotificationsTD[playerid][5], 1);

		for( new index = 0; index < 6; index++) {
			PlayerTextDrawShow(playerid, NotificationsTD[ playerid ][ index ]);
		}
		showedNotifications[ playerid ] = true;

		PlayerTextDrawSetString(playerid, NotificationsTD[ playerid ][ 4 ], notifStr);
		PlayerTextDrawSetString(playerid, NotificationsTD[ playerid ][ 5 ], infoNotifStr);
	} 
	else if( show == false) {
		for( new index = 0; index < 6; index++) {
			PlayerTextDrawHide(playerid, NotificationsTD[ playerid ][ index ]);
			PlayerTextDrawDestroy(playerid, NotificationsTD[ playerid ][ index ]);
			NotificationsTD[ playerid ][ index ] = PlayerText: INVALID_TEXT_DRAW;
		}
		showedNotifications[ playerid ] = false;
	} 
	else {
		PlayerTextDrawSetString(playerid, NotificationsTD[ playerid ][ 4 ], notifStr);
		PlayerTextDrawSetString(playerid, NotificationsTD[ playerid ][ 5 ], infoNotifStr);
	}
}


update_notification( playerid, notifStr[ ] = "", infoNotifStr[ ] = "") {
	printf("notifStr : %s", notifStr);
	printf("notifStr : %s", infoNotifStr);
	PlayerTextDrawSetString(playerid, NotificationsTD[ playerid ][ 4 ], notifStr);
	PlayerTextDrawSetString(playerid, NotificationsTD[ playerid ][ 5 ], infoNotifStr);
}
//=====================[ ALS ]========================================================

public OnPlayerConnect( playerid)
{
	showedNotifications[ playerid ] = false;
	#if defined 	als_td_nt_OnPlayerConnect
		return 	als_td_nt_OnPlayerConnect( playerid );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect als_td_nt_OnPlayerConnect
#if defined 	als_td_nt_OnPlayerConnect
	forward 	als_td_nt_OnPlayerConnect( playerid );
#endif

public OnPlayerDisconnect(playerid, reason)
{

	if( showedNotifications[ playerid ] ) 
		NotificationsTDControl( playerid, false);

	#if defined 	als_td_nt_OnPlayerDisconnect
		return 	als_td_nt_OnPlayerDisconnect( playerid, reason );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif

#define OnPlayerDisconnect als_td_nt_OnPlayerDisconnect
#if defined 	als_td_nt_OnPlayerDisconnect
	forward 	als_td_nt_OnPlayerDisconnect( playerid, reason );
#endif
