#include <YSI_Coding\y_hooks>
#define MAX_DM_SP   		(10)
#define MAX_DMS     		(100)
#define DM_NEXT_ROUND_TIME	(600) // 3 
#define DM_VW	60
new
	Text:TD_DM,
	DM_ID,
	DM_TIME,
	DM_TIMETIMER,
	DM_INT,
	DM_FREEZE,
	TOTAL_PLAYERS_DM,
	DM_WEP[13][2],
	DM_Name[24],
	Float:DM_SP[MAX_DM_SP][4],
	DM_Names[MAX_DMS][24],
	DM_TWEATHER[2],
	Total_DM,
	ChosenWorld[ MAX_PLAYERS ];

hook OnGameModeInit()
{
	LoadDMNames("DM/dms.sfr");

	if(isnull(DM_Names[DM_ID])) DM_ID = 0;
	if(!LoadDM(DM_Names[DM_ID]))
	{
		DM_ID = 0;
		LoadDM(DM_Names[DM_ID]);
	}
	TOTAL_PLAYERS_DM = 0;
	DM_TIME = DM_NEXT_ROUND_TIME;
	KillTimer(DM_TIMETIMER);
	DM_TIMETIMER = SetTimer("DMCounterBack", 1000, true);

	//TD_DM
	TD_DM = TextDrawCreate(605.000000, 395.000000, "Players: 100 ~n~Time: 10:50");
	TextDrawFont(TD_DM, 2);
	TextDrawLetterSize(TD_DM, 0.183333, 1.000000);
	TextDrawTextSize(TD_DM, 400.000000, 592.000000);
	TextDrawSetOutline(TD_DM, 1);
	TextDrawSetShadow(TD_DM, 0);
	TextDrawAlignment(TD_DM, 2);
	TextDrawColor(TD_DM, -1);
	TextDrawBackgroundColor(TD_DM, 255);
	TextDrawBoxColor(TD_DM, 50);
	TextDrawUseBox(TD_DM, 0);
	TextDrawSetProportional(TD_DM, 1);
	TextDrawSetSelectable(TD_DM, 0);
	return 1;
}

//=========================================================
LoadDMNames(mapname[])
{
	new File:Handler = fopen(mapname, io_read);
	if(!Handler) return 0;
	Total_DM = 0;
	new Object_String[512];
	while(fread(Handler, Object_String))
	{
		StripNewLine(Object_String);
		format(DM_Names[Total_DM], 24, "%s", Object_String);
		Total_DM ++;
	}

	fclose(Handler);
	return 1;
}
LoadDM(mapname[])
{
	new File:Handler = fopen(mapname, io_read);
	if(!Handler) return 0;
	new Line, slot, sslot, tmp_WEP[13][2], Float:tmp_SP[10][4];
	new Object_String[512];
	while(fread(Handler, Object_String))
	{
		StripNewLine(Object_String);
		if(Line == 0) if(sscanf(Object_String, "p<,>s[24]dddd", DM_Name, DM_TWEATHER[0], DM_TWEATHER[1], DM_INT, DM_FREEZE)) return 0;
		if(Line > 0)  
		{
			if(!sscanf(Object_String, "p<,>dd", tmp_WEP[slot][0], tmp_WEP[slot][1])) DM_WEP = tmp_WEP, slot ++;
			if(!sscanf(Object_String, "p<,>ffff", tmp_SP[sslot][0], tmp_SP[sslot][1], tmp_SP[sslot][2], tmp_SP[sslot][3])) DM_SP = tmp_SP, sslot ++;
		}
		Line ++;
	}
	fclose(Handler);
	return 1;
}

forward DMCounterBack();
public DMCounterBack()
{
	DM_TIME -= 1;
	if(DM_TIME < 0)
	{
		KillTimer(DM_TIMETIMER);
		NextDM();
	}
	new str[30];
	format(str, 30, "Players: %d~n~Time: %s", TOTAL_PLAYERS_DM, TimeConvert(DM_TIME));
	TextDrawSetString(TD_DM, str);
	return 1;
}

NextDM()
{
	for(new i = 0; i < 13; i++)
	{
		DM_WEP[i][0] = 0;
		DM_WEP[i][1] = 0;
	}
	//KillTimer(DM_TIMETIMER);
	
	DM_ID ++;
	if(isnull(DM_Names[DM_ID])) DM_ID = 0;
	if(!LoadDM(DM_Names[DM_ID]))
	{
		DM_ID = 0;
		LoadDM(DM_Names[DM_ID]);
	}
	
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++) 
	{
		if(!NaDmEventu[ i ]) continue;
		ResetPlayerWeapons(i);
		if(ChosenWorld[i] == 0) SetPlayerVirtualWorld(i, DM_VW);
		else SetPlayerVirtualWorld(i, ChosenWorld[i]);
		SetPlayerArmour(i, 100.0);
		SetPlayerHealth(i,100.0);

		SetPlayerInterior(i, DM_INT);
		new index = random(sizeof(DM_SP));
		KGEyes_SetPlayerPos(i, DM_SP[index][0], DM_SP[index][1], DM_SP[index][2]);
		SetPlayerFacingAngle(i, DM_SP[index][3]);
		SetPlayerColor(i, 0xFFFFFFFF);
		SetCameraBehindPlayer(i);
		GameTextForPlayer(i, DM_Name, 3000, 6);
		if(DM_FREEZE) LoadObjects( i );
		for (new a = 0; a <= 12; a++) GiveWeaponToPlayer(i, DM_WEP[a][0], DM_WEP[a][1]);
	}
	
	DM_TIME = DM_NEXT_ROUND_TIME;
	KillTimer(DM_TIMETIMER);
	DM_TIMETIMER = SetTimer("DMCounterBack", 1000, true);
	return 1;
}