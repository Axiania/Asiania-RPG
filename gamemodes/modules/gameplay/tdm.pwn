#include <YSI_Coding\y_hooks>
#define TDM_VW 40
#define TD_COUNTER_TDM		26
#define MAX_TDMS     		(100)
#define TDM_NEXT_ROUND_TIME	(420) // 8 minutes

enum TDMINFO
{
	T_ID,
	T_NAME[24],
	T_INT,
	T_WEATHER[2],
	T_FREEZE,
	T_STATUS,
	T_TIME,
	T_TIMETIMER,
	T_OBJECTIVE,
	T_COUNTER[2],
	T_PLAYERS,
	T_TeamPLAYERS[2],
	T_NEXTTDM_TIMER
	
};

new TDMI[TDMINFO],
	TDM_WEP[13][2],
	Float:TDM_SP[2][10][4],
	Text:TD_TDM[16],
	
	TDM_Names[MAX_TDMS][24],
	TOTAL_TDM;
	
forward TDMCounterBack();

new TDM_TeamColors[] =
{
	0xE87973FF,
	0x81A6EFFF
};
new TDM_TeamSkins[] =
{
	230,
	202
};

hook OnGameModeInit()
{
	LoadTDMNames("TDM/tdms.sfr");

	if(isnull(TDM_Names[ TDMI[T_ID] ])) TDMI[T_ID] = 0;
	if(!LoadTDM( TDM_Names[ TDMI[T_ID] ] ))
	{
		TDMI[T_ID] = 0;
		LoadTDM(TDM_Names[ TDMI[T_ID] ]);
	}
	TextDrawSetString(TD_TDM[15], "_");
	TDMI[T_PLAYERS] = 0;
	TDMI[T_TIME] = TDM_NEXT_ROUND_TIME;
	KillTimer(TDMI[T_TIMETIMER]);
	TDMI[T_TIMETIMER] = SetTimer("TDMCounterBack", 1000, true);

	//TD_TDM  
	TD_TDM[0] = TextDrawCreate(613.000488, 402.375091, "5:00");
	TextDrawLetterSize(TD_TDM[0], 0.284999, 1.280626);
	TextDrawAlignment(TD_TDM[0], 3);
	TextDrawColor(TD_TDM[0], -116);
	TextDrawSetShadow(TD_TDM[0], 0);
	TextDrawSetOutline(TD_TDM[0], 0);
	TextDrawBackgroundColor(TD_TDM[0], 255);
	TextDrawFont(TD_TDM[0], 1);
	TextDrawSetProportional(TD_TDM[0], 1);
	TextDrawSetShadow(TD_TDM[0], 0);

	TD_TDM[1] = TextDrawCreate(581.700622, 403.974700, "TIME");
	TextDrawLetterSize(TD_TDM[1], 0.205000, 1.000626);
	TextDrawAlignment(TD_TDM[1], 3);
	TextDrawColor(TD_TDM[1], -116);
	TextDrawSetShadow(TD_TDM[1], 0);
	TextDrawSetOutline(TD_TDM[1], 0);
	TextDrawBackgroundColor(TD_TDM[1], 255);
	TextDrawFont(TD_TDM[1], 1);
	TextDrawSetProportional(TD_TDM[1], 1);
	TextDrawSetShadow(TD_TDM[1], 0);

	TD_TDM[2] = TextDrawCreate(537.500000, 403.062500, "_");
	TextDrawLetterSize(TD_TDM[2], 0.390500, 1.315626);
	TextDrawTextSize(TD_TDM[2], 614.000000, 0.000000);
	TextDrawAlignment(TD_TDM[2], 1);
	TextDrawColor(TD_TDM[2], -1);
	TextDrawUseBox(TD_TDM[2], 1);
	TextDrawBoxColor(TD_TDM[2], 90);
	TextDrawSetShadow(TD_TDM[2], 0);
	TextDrawSetOutline(TD_TDM[2], 0);
	TextDrawBackgroundColor(TD_TDM[2], 255);
	TextDrawFont(TD_TDM[2], 1);
	TextDrawSetProportional(TD_TDM[2], 1);
	TextDrawSetShadow(TD_TDM[2], 0);
	
	TD_TDM[3] = TextDrawCreate(613.000488, (402.375091)-34.0, "0");
	TextDrawLetterSize(TD_TDM[3], 0.284999, 1.280626);
	TextDrawAlignment(TD_TDM[3], 3);
	TextDrawColor(TD_TDM[3], -116);
	TextDrawSetShadow(TD_TDM[3], 0);
	TextDrawSetOutline(TD_TDM[3], 0);
	TextDrawBackgroundColor(TD_TDM[3], 255);
	TextDrawFont(TD_TDM[3], 1);
	TextDrawSetProportional(TD_TDM[3], 1);
	TextDrawSetShadow(TD_TDM[3], 0);

	TD_TDM[4] = TextDrawCreate(581.700622, (403.974700)-34.0, "RED TEAM");
	TextDrawLetterSize(TD_TDM[4], 0.205000, 1.000626);
	TextDrawAlignment(TD_TDM[4], 3);
	TextDrawColor(TD_TDM[4], 0xE87973AA); // -116
	TextDrawSetShadow(TD_TDM[4], 0);
	TextDrawSetOutline(TD_TDM[4], 0);
	TextDrawBackgroundColor(TD_TDM[4], 255);
	TextDrawFont(TD_TDM[4], 1);
	TextDrawSetProportional(TD_TDM[4], 1);
	TextDrawSetShadow(TD_TDM[4], 0);

	TD_TDM[5] = TextDrawCreate(537.500000, (403.062500)-34.0, "_");
	TextDrawLetterSize(TD_TDM[5], 0.390500, 1.315626);
	TextDrawTextSize(TD_TDM[5], 614.000000, 0.000000);
	TextDrawAlignment(TD_TDM[5], 1);
	TextDrawColor(TD_TDM[5], -1);
	TextDrawUseBox(TD_TDM[5], 1);
	TextDrawBoxColor(TD_TDM[5], 90);
	TextDrawSetShadow(TD_TDM[5], 0);
	TextDrawSetOutline(TD_TDM[5], 0);
	TextDrawBackgroundColor(TD_TDM[5], 255);
	TextDrawFont(TD_TDM[5], 1);
	TextDrawSetProportional(TD_TDM[5], 1);
	TextDrawSetShadow(TD_TDM[5], 0);
	
	TD_TDM[6] = TextDrawCreate(613.000488, (402.375091)-51.0, "0");
	TextDrawLetterSize(TD_TDM[6], 0.284999, 1.280626);
	TextDrawAlignment(TD_TDM[6], 3);
	TextDrawColor(TD_TDM[6], -116);
	TextDrawSetShadow(TD_TDM[6], 0);
	TextDrawSetOutline(TD_TDM[6], 0);
	TextDrawBackgroundColor(TD_TDM[6], 255);
	TextDrawFont(TD_TDM[6], 1);
	TextDrawSetProportional(TD_TDM[6], 1);
	TextDrawSetShadow(TD_TDM[6], 0);

	TD_TDM[7] = TextDrawCreate(581.700622, (403.974700)-51.0, "OBJECTIVE");
	TextDrawLetterSize(TD_TDM[7], 0.205000, 1.000626);
	TextDrawAlignment(TD_TDM[7], 3);
	TextDrawColor(TD_TDM[7], -116);
	TextDrawSetShadow(TD_TDM[7], 0);
	TextDrawSetOutline(TD_TDM[7], 0);
	TextDrawBackgroundColor(TD_TDM[7], 255);
	TextDrawFont(TD_TDM[7], 1);
	TextDrawSetProportional(TD_TDM[7], 1);
	TextDrawSetShadow(TD_TDM[7], 0);

	TD_TDM[8] = TextDrawCreate(537.500000, (403.062500)-51.0, "_");
	TextDrawLetterSize(TD_TDM[8], 0.390500, 1.315626);
	TextDrawTextSize(TD_TDM[8], 614.000000, 0.000000);
	TextDrawAlignment(TD_TDM[8], 1);
	TextDrawColor(TD_TDM[8], -1);
	TextDrawUseBox(TD_TDM[8], 1);
	TextDrawBoxColor(TD_TDM[8], 90);
	TextDrawSetShadow(TD_TDM[8], 0);
	TextDrawSetOutline(TD_TDM[8], 0);
	TextDrawBackgroundColor(TD_TDM[8], 255);
	TextDrawFont(TD_TDM[8], 1);
	TextDrawSetProportional(TD_TDM[8], 1);
	TextDrawSetShadow(TD_TDM[8], 0);
	
	TD_TDM[9] = TextDrawCreate(613.000488, (402.375091)-68.0, "0");
	TextDrawLetterSize(TD_TDM[9], 0.284999, 1.280626);
	TextDrawAlignment(TD_TDM[9], 3);
	TextDrawColor(TD_TDM[9], -116);
	TextDrawSetShadow(TD_TDM[9], 0);
	TextDrawSetOutline(TD_TDM[9], 0);
	TextDrawBackgroundColor(TD_TDM[9], 255);
	TextDrawFont(TD_TDM[9], 1);
	TextDrawSetProportional(TD_TDM[9], 1);
	TextDrawSetShadow(TD_TDM[9], 0);

	TD_TDM[10] = TextDrawCreate(581.700622, (403.974700)-68.0, "Players");
	TextDrawLetterSize(TD_TDM[10], 0.205000, 1.000626);
	TextDrawAlignment(TD_TDM[10], 3);
	TextDrawColor(TD_TDM[10], -116);
	TextDrawSetShadow(TD_TDM[10], 0);
	TextDrawSetOutline(TD_TDM[10], 0);
	TextDrawBackgroundColor(TD_TDM[10], 255);
	TextDrawFont(TD_TDM[10], 1);
	TextDrawSetProportional(TD_TDM[10], 1);
	TextDrawSetShadow(TD_TDM[10], 0);

	TD_TDM[11] = TextDrawCreate(537.500000, (403.062500)-68.0, "_");
	TextDrawLetterSize(TD_TDM[11], 0.390500, 1.315626);
	TextDrawTextSize(TD_TDM[11], 614.000000, 0.000000);
	TextDrawAlignment(TD_TDM[11], 1);
	TextDrawColor(TD_TDM[11], -1);
	TextDrawUseBox(TD_TDM[11], 1);
	TextDrawBoxColor(TD_TDM[11], 90);
	TextDrawSetShadow(TD_TDM[11], 0);
	TextDrawSetOutline(TD_TDM[11], 0);
	TextDrawBackgroundColor(TD_TDM[11], 255);
	TextDrawFont(TD_TDM[11], 1);
	TextDrawSetProportional(TD_TDM[11], 1);
	TextDrawSetShadow(TD_TDM[11], 0);
	
	TD_TDM[12] = TextDrawCreate(613.000488, (402.375091)-17.0, "0");
	TextDrawLetterSize(TD_TDM[12], 0.284999, 1.280626);
	TextDrawAlignment(TD_TDM[12], 3);
	TextDrawColor(TD_TDM[12], -116);
	TextDrawSetShadow(TD_TDM[12], 0);
	TextDrawSetOutline(TD_TDM[12], 0);
	TextDrawBackgroundColor(TD_TDM[12], 255);
	TextDrawFont(TD_TDM[12], 1);
	TextDrawSetProportional(TD_TDM[12], 1);
	TextDrawSetShadow(TD_TDM[12], 0);

	TD_TDM[13] = TextDrawCreate(581.700622, (403.974700)-17.0, "BLUE TEAM");
	TextDrawLetterSize(TD_TDM[13], 0.205000, 1.000626);
	TextDrawAlignment(TD_TDM[13], 3);
	TextDrawColor(TD_TDM[13], 0x81A6EFAA);
	TextDrawSetShadow(TD_TDM[13], 0);
	TextDrawSetOutline(TD_TDM[13], 0);
	TextDrawBackgroundColor(TD_TDM[13], 255);
	TextDrawFont(TD_TDM[13], 1);
	TextDrawSetProportional(TD_TDM[13], 1);
	TextDrawSetShadow(TD_TDM[13], 0);

	TD_TDM[14] = TextDrawCreate(537.500000, (403.062500)-17.0, "_");
	TextDrawLetterSize(TD_TDM[14], 0.390500, 1.315626);
	TextDrawTextSize(TD_TDM[14], 614.000000, 0.000000);
	TextDrawAlignment(TD_TDM[14], 1);
	TextDrawColor(TD_TDM[14], -1);
	TextDrawUseBox(TD_TDM[14], 1);
	TextDrawBoxColor(TD_TDM[14], 90);
	TextDrawSetShadow(TD_TDM[14], 0);
	TextDrawSetOutline(TD_TDM[14], 0);
	TextDrawBackgroundColor(TD_TDM[14], 255);
	TextDrawFont(TD_TDM[14], 1);
	TextDrawSetProportional(TD_TDM[14], 1);
	TextDrawSetShadow(TD_TDM[14], 0);
	
	TD_TDM[15] = TextDrawCreate(320.000000, 190.000000, "_");
	TextDrawLetterSize(TD_TDM[15], 0.840333, 3.304888);
	TextDrawAlignment(TD_TDM[15], 2);
	TextDrawColor(TD_TDM[15], -4652801);
	TextDrawSetShadow(TD_TDM[15], 0);
	TextDrawSetOutline(TD_TDM[15], 1);
	TextDrawBackgroundColor(TD_TDM[15], 255);
	TextDrawFont(TD_TDM[15], 3);
	TextDrawSetProportional(TD_TDM[15], 1);
	TextDrawSetShadow(TD_TDM[15], 0);
	return 1;
}

LoadTDMNames(mapname[])
{
	new File:Handler = fopen(mapname, io_read);
	if(!Handler) return 0;
	TOTAL_TDM = 0;
	new Object_String[512];
	while(fread(Handler, Object_String))
	{
		StripNewLine(Object_String);
		format(TDM_Names[TOTAL_TDM], 24, "%s", Object_String);
		TOTAL_TDM ++;
	}

	fclose(Handler);
	return 1;
}

LoadTDM(mapname[])
{
	new File:Handler = fopen(mapname, io_read);
	if(!Handler) return 0;
	
	new tmp[TDMINFO],	tmp_WEP[13][2], slot,	Float:tmp_SP[4], team, count_tm[2];
	tmp = TDMI;
	new Object_String[512];
	while(fread(Handler, Object_String))
	{
		StripNewLine(Object_String);
		if(!sscanf(Object_String, "p<,>s[24]ddddd", tmp[T_NAME], tmp[T_WEATHER][0], tmp[T_WEATHER][1], tmp[T_INT], tmp[T_FREEZE], tmp[T_OBJECTIVE])) TDMI = tmp;
		if(!sscanf(Object_String, "p<,>dd", tmp_WEP[slot][0], tmp_WEP[slot][1])) TDM_WEP = tmp_WEP, slot ++;
		if(!sscanf(Object_String, "p<,>dffff", team, tmp_SP[0], tmp_SP[1], tmp_SP[2], tmp_SP[3])) TDM_SP[team][count_tm[team] ++] = tmp_SP;
	}
	fclose(Handler);
	
	//TDMI[T_STATUS] = TDM_RUNNING;
	return 1;
}

public TDMCounterBack()
{
	TDMI[T_TIME] -= 1;
	if(TDMI[T_TIME] < 0)
	{
		if(TDMI[T_COUNTER][0] > TDMI[T_COUNTER][1])
		{
			TextDrawSetString(TD_TDM[15], "~r~RED_Team_Won");
		}
		else if(TDMI[T_COUNTER][1] > TDMI[T_COUNTER][0])
		{
			TextDrawSetString(TD_TDM[15], "~b~BLUE_Team_Won");
		}
		else if(TDMI[T_COUNTER][0] == TDMI[T_COUNTER][1])
		{
			TextDrawSetString(TD_TDM[15], "~g~TIED");
		}
		KillTimer(TDMI[T_TIMETIMER]);
		TDMI[T_TIME] = 0;
		KillTimer(TDMI[T_NEXTTDM_TIMER]);
		TDMI[T_NEXTTDM_TIMER] = SetTimer("NextTDM", 3000, false);
	}
	TextDrawSetString(TD_TDM[0], TimeConvert(TDMI[T_TIME]));
	new str[10];
	format(str, 10, "%d", TDMI[T_COUNTER][0]); TextDrawSetString(TD_TDM[3], str);
	format(str, 10, "%d", TDMI[T_OBJECTIVE]); TextDrawSetString(TD_TDM[6], str);
	format(str, 10, "%d", TDMI[T_PLAYERS]); TextDrawSetString(TD_TDM[9], str);
	format(str, 10, "%d", TDMI[T_COUNTER][1]); TextDrawSetString(TD_TDM[12], str);
	return 1;
}

forward NextTDM();
public NextTDM()
{
	for(new i = 0; i < 13; i++)
	{
		TDM_WEP[i][0] = 0;
		TDM_WEP[i][1] = 0;
	}
	
	TDMI[T_COUNTER][0] = 0;
	TDMI[T_COUNTER][1] = 0;
	
	TDMI[T_ID] ++;
	if(isnull(TDM_Names[ TDMI[T_ID] ])) TDMI[T_ID] = 0;
	if(!LoadTDM( TDM_Names[ TDMI[T_ID] ] ))
	{
		TDMI[T_ID] = 0;
		LoadTDM(TDM_Names[ TDMI[T_ID] ]);
	}
	
	TextDrawSetString(TD_TDM[15], "_");
	foreach(new i : Player) 
	{
		if(tdm_player_info[ i ][ tdm_Team ] == -1) continue;

		new index = random(sizeof(TDM_SP[]));
		SetPlayerArmour(i, 100.0);
		SetPlayerHealth(i,100.0);
		KGEyes_SetPlayerPos(i, TDM_SP[tdm_player_info[ i ][ tdm_Team ]][index][0], TDM_SP[tdm_player_info[ i ][ tdm_Team ]][index][1], TDM_SP[tdm_player_info[ i ][ tdm_Team ]][index][2]);
		SetPlayerFacingAngle(i, TDM_SP[tdm_player_info[ i ][ tdm_Team ]][index][3]);
		SetCameraBehindPlayer(i);
		ResetAllWeapons(i);
		SetPlayerVirtualWorld(i, TDM_VW);
		SetPlayerInterior(i, TDMI[T_INT]);
		GameTextForPlayer(i, TDMI[T_NAME], 3000, 6);
		if(TDMI[T_FREEZE]) LoadObjects( i );
		for (new d = 0; d <= 12; d++) GiveWeaponToPlayer(i, TDM_WEP[d][0], TDM_WEP[d][1], 1);
		
	}
	
	TDMI[T_TIME] = TDM_NEXT_ROUND_TIME;
	KillTimer(TDMI[T_TIMETIMER]);
	TDMI[T_TIMETIMER] = SetTimer("TDMCounterBack", 1000, true);
	return 1;
}