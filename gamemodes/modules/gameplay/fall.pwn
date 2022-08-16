#include <YSI_Coding\y_hooks>
enum
{
	PD_NORMAL,
	PD_DEAD,
	PD_SPECTATE
};
#define	NO_WINNER			(-1)

//==================================FALL SYSTEM================================
#define	MAX_FALLS			(50)
#define	MAX_FALL_OBJECTS	(500)
#define FALL_VW				992
enum
{
	FALL_CLOSED,
	FALL_RUNNING,
	FALL_WAIT
};

enum FINFO
{
	F_PLAYERS,
	F_RUNNINGPLAYERS,
	F_WINNER,
	F_STATUS,
	
	F_ID,
	//F_OBJECTS,
	F_NAME[24],
	F_WEATHER,
	F_HOUR,
	Float:F_DEAD_CAM[6],
	Float:F_ZPOS,
	
	F_TICKCOUNT,
	F_COUNTDOWN_COUNTER,
	F_COUNTDOWN_TIMER,
	F_NEXTFSTATUS_TIMER,
	F_TIMEOUT_COUNTER,
	F_TIMEOUT_TIMER,
	F_MAX_PRIZE
	
};

new FI[FINFO], FALL_OBJECTID[MAX_FALL_OBJECTS], FALL_SMOKE_OBJECTID[MAX_FALL_OBJECTS],/* FALL_OBJECT_VALID[MAX_FALL_OBJECTS],*/ Text:TD_FALL[9], Text:TD_FallMessage,
	TOTAL_FALLS, FALL_FILENAMES[MAX_FALLS][24], Iterator:FALL_OBJECTS<MAX_FALL_OBJECTS>;
	
forward NextFallStatus();
forward FallCountdown();
forward FallTimeOutCountdown();

hook OnGameModeInit()
{
	LoadFallNames("FALL/falls.sfr");

	//FALL
	TD_FALL[2] = TextDrawCreate(537.500000, 403.062500, "_");
	TextDrawLetterSize(TD_FALL[2], 0.390500, 1.315626);
	TextDrawTextSize(TD_FALL[2], 614.000000, 0.000000);
	TextDrawAlignment(TD_FALL[2], 1);
	TextDrawColor(TD_FALL[2], -1);
	TextDrawUseBox(TD_FALL[2], 1);
	TextDrawBoxColor(TD_FALL[2], 90);
	TextDrawSetShadow(TD_FALL[2], 0);
	TextDrawSetOutline(TD_FALL[2], 0);
	TextDrawBackgroundColor(TD_FALL[2], 255);
	TextDrawFont(TD_FALL[2], 1);
	TextDrawSetProportional(TD_FALL[2], 1);
	TextDrawSetShadow(TD_FALL[2], 0);
	
	TD_FALL[0] = TextDrawCreate(613.000488, 402.375091, "5:00");
	TextDrawLetterSize(TD_FALL[0], 0.284999, 1.280626);
	TextDrawAlignment(TD_FALL[0], 3);
	TextDrawColor(TD_FALL[0], -116);
	TextDrawSetShadow(TD_FALL[0], 0);
	TextDrawSetOutline(TD_FALL[0], 0);
	TextDrawBackgroundColor(TD_FALL[0], 255);
	TextDrawFont(TD_FALL[0], 1);
	TextDrawSetProportional(TD_FALL[0], 1);
	TextDrawSetShadow(TD_FALL[0], 0);

	TD_FALL[1] = TextDrawCreate(581.700622, 403.974700, "TIME");
	TextDrawLetterSize(TD_FALL[1], 0.205000, 1.000626);
	TextDrawAlignment(TD_FALL[1], 3);
	TextDrawColor(TD_FALL[1], -116);
	TextDrawSetShadow(TD_FALL[1], 0);
	TextDrawSetOutline(TD_FALL[1], 0);
	TextDrawBackgroundColor(TD_FALL[1], 255);
	TextDrawFont(TD_FALL[1], 1);
	TextDrawSetProportional(TD_FALL[1], 1);
	TextDrawSetShadow(TD_FALL[1], 0);

	TD_FALL[5] = TextDrawCreate(537.500000, (403.062500)-17.0, "_");
	TextDrawLetterSize(TD_FALL[5], 0.390500, 1.315626);
	TextDrawTextSize(TD_FALL[5], 614.000000, 0.000000);
	TextDrawAlignment(TD_FALL[5], 1);
	TextDrawColor(TD_FALL[5], -1);
	TextDrawUseBox(TD_FALL[5], 1);
	TextDrawBoxColor(TD_FALL[5], 90);
	TextDrawSetShadow(TD_FALL[5], 0);
	TextDrawSetOutline(TD_FALL[5], 0);
	TextDrawBackgroundColor(TD_FALL[5], 255);
	TextDrawFont(TD_FALL[5], 1);
	TextDrawSetProportional(TD_FALL[5], 1);
	TextDrawSetShadow(TD_FALL[5], 0);
	
	TD_FALL[3] = TextDrawCreate(613.000488, (402.375091)-17.0, "0");
	TextDrawLetterSize(TD_FALL[3], 0.284999, 1.280626);
	TextDrawAlignment(TD_FALL[3], 3);
	TextDrawColor(TD_FALL[3], -116);
	TextDrawSetShadow(TD_FALL[3], 0);
	TextDrawSetOutline(TD_FALL[3], 0);
	TextDrawBackgroundColor(TD_FALL[3], 255);
	TextDrawFont(TD_FALL[3], 1);
	TextDrawSetProportional(TD_FALL[3], 1);
	TextDrawSetShadow(TD_FALL[3], 0);

	TD_FALL[4] = TextDrawCreate(581.700622, (403.974700)-17.0, "ACTIVES");
	TextDrawLetterSize(TD_FALL[4], 0.205000, 1.000626);
	TextDrawAlignment(TD_FALL[4], 3);
	TextDrawColor(TD_FALL[4], -116);
	TextDrawSetShadow(TD_FALL[4], 0);
	TextDrawSetOutline(TD_FALL[4], 0);
	TextDrawBackgroundColor(TD_FALL[4], 255);
	TextDrawFont(TD_FALL[4], 1);
	TextDrawSetProportional(TD_FALL[4], 1);
	TextDrawSetShadow(TD_FALL[4], 0);

	TD_FALL[8] = TextDrawCreate(537.500000, (403.062500)-34.0, "_");
	TextDrawLetterSize(TD_FALL[8], 0.390500, 1.315626);
	TextDrawTextSize(TD_FALL[8], 614.000000, 0.000000);
	TextDrawAlignment(TD_FALL[8], 1);
	TextDrawColor(TD_FALL[8], -1);
	TextDrawUseBox(TD_FALL[8], 1);
	TextDrawBoxColor(TD_FALL[8], 90);
	TextDrawSetShadow(TD_FALL[8], 0);
	TextDrawSetOutline(TD_FALL[8], 0);
	TextDrawBackgroundColor(TD_FALL[8], 255);
	TextDrawFont(TD_FALL[8], 1);
	TextDrawSetProportional(TD_FALL[8], 1);
	TextDrawSetShadow(TD_FALL[8], 0);
	
	TD_FALL[6] = TextDrawCreate(613.000488, (402.375091)-34.0, "0");
	TextDrawLetterSize(TD_FALL[6], 0.284999, 1.280626);
	TextDrawAlignment(TD_FALL[6], 3);
	TextDrawColor(TD_FALL[6], -116);
	TextDrawSetShadow(TD_FALL[6], 0);
	TextDrawSetOutline(TD_FALL[6], 0);
	TextDrawBackgroundColor(TD_FALL[6], 255);
	TextDrawFont(TD_FALL[6], 1);
	TextDrawSetProportional(TD_FALL[6], 1);
	TextDrawSetShadow(TD_FALL[6], 0);

	TD_FALL[7] = TextDrawCreate(581.700622, (403.974700)-34.0, "Player");
	TextDrawLetterSize(TD_FALL[7], 0.205000, 1.000626);
	TextDrawAlignment(TD_FALL[7], 3);
	TextDrawColor(TD_FALL[7], -116);
	TextDrawSetShadow(TD_FALL[7], 0);
	TextDrawSetOutline(TD_FALL[7], 0);
	TextDrawBackgroundColor(TD_FALL[7], 255);
	TextDrawFont(TD_FALL[7], 1);
	TextDrawSetProportional(TD_FALL[7], 1);
	TextDrawSetShadow(TD_FALL[7], 0);
	
	TD_FallMessage = TextDrawCreate(320.000000, 320.000000, "_");
	TextDrawLetterSize(TD_FallMessage, 0.281332, 1.077334);
	TextDrawAlignment(TD_FallMessage, 2);
	TextDrawColor(TD_FallMessage, -1);
	TextDrawSetShadow(TD_FallMessage, 0);
	TextDrawSetOutline(TD_FallMessage, 1);
	TextDrawFont(TD_FallMessage, 3);
	TextDrawSetProportional(TD_FallMessage, 1);
	TextDrawSetShadow(TD_FallMessage, 0);
	return 1;
}

//FALL SYSTEM
LoadFallNames(mapname[])
{
	
	new File:Handler = fopen(mapname, io_read);
	if(!Handler) return 0;
	TOTAL_FALLS = 0;
	new File_String[512];
	for(new i = 0; i != MAX_FALLS; i++) FALL_FILENAMES[i] = "";
	while(fread(Handler, File_String))
	{
		if(TOTAL_FALLS < MAX_FALLS)
		{
			StripNewLine(File_String);
			format(FALL_FILENAMES[TOTAL_FALLS], 24, "%s", File_String);
			TOTAL_FALLS ++;
		}	
	}
	fclose(Handler);
	return 1;
}

LoadFall(fallid)
{
	for(new i = 0; i != MAX_FALL_OBJECTS; i++)
	{
		if(IsValidDynamicObject(FALL_OBJECTID[i]))
		{
			DestroyDynamicObject(FALL_OBJECTID[i]);
			FALL_OBJECTID[i] = -1;
		}
		if(IsValidObject(FALL_SMOKE_OBJECTID[i]))
		{
			DestroyObject(FALL_SMOKE_OBJECTID[i]);
			FALL_SMOKE_OBJECTID[i] = INVALID_OBJECT_ID;
		}
	}
	new File:Handler = fopen(FALL_FILENAMES[fallid], io_read);
	if(!Handler) return 0;
	Iter_Clear(FALL_OBJECTS);
	new Line, Count, modelid, Float:pos[6];
	new File_String[512];
	while(fread(Handler, File_String))
	{
		StripNewLine(File_String);
		switch(Line)
		{
			case 0: if(sscanf(File_String, "p<,>s[24]ddf", FI[F_NAME], FI[F_HOUR], FI[F_WEATHER], FI[F_ZPOS])) return 0;
			case 1: if(sscanf(File_String, "p<,>ffffff", FI[F_DEAD_CAM][0], FI[F_DEAD_CAM][1], FI[F_DEAD_CAM][2], FI[F_DEAD_CAM][3], FI[F_DEAD_CAM][4], FI[F_DEAD_CAM][5])) return 0;
			default:
			{
				if(sscanf(File_String, "p<,>dffffff", modelid, pos[0], pos[1], pos[2], pos[3], pos[4], pos[5])) return 0;
				FALL_OBJECTID[Count]  = CreateDynamicObjectEx(modelid, pos[0], pos[1], pos[2], pos[3], pos[4], pos[5], 1000.0, 1000.0, {FALL_VW});
				Iter_Add(FALL_OBJECTS, Count);
				Count ++;
			}
		}	
		Line ++;
	}
	fclose(Handler);
	FI[F_RUNNINGPLAYERS] = 0;
	FI[F_WINNER] = NO_WINNER;
	FI[F_TICKCOUNT] = 0;
	FI[F_COUNTDOWN_COUNTER] = 11; //10 seconds
	KillTimer(FI[F_NEXTFSTATUS_TIMER]);
	KillTimer(FI[F_COUNTDOWN_TIMER]);
	KillTimer(FI[F_TIMEOUT_TIMER]);
	return 1;
}

public NextFallStatus()
{
	switch(FI[F_STATUS])
	{
		case FALL_CLOSED:
		{
			if(!LoadFall(FI[F_ID]))
			{
				FI[F_ID] = 0;
				LoadFall(FI[F_ID]);
			}
			
			new str[64]; format(str, 64, "~y~awaiting_players");
			TextDrawSetString(TD_FallMessage, str);
			
			FI[F_STATUS] = FALL_WAIT;
			FI[F_COUNTDOWN_COUNTER] = 11;
			KillTimer(FI[F_COUNTDOWN_TIMER]);
			FI[F_COUNTDOWN_TIMER] = SetTimer("FallCountdown", 900, true);
			UpdatePlayersFallStatus();
		}
		case FALL_WAIT:
		{
			TextDrawSetString(TD_FallMessage, "~r~~h~try_~p~not_to~y~fall_~g~~h~;)");
			SetTimer("HideFallMessage", 2000, false);
			FI[F_COUNTDOWN_COUNTER] = 11;
			FI[F_MAX_PRIZE] = 750*FI[F_PLAYERS];
			FI[F_RUNNINGPLAYERS] = FI[F_PLAYERS];
			FI[F_TIMEOUT_COUNTER] = 180;
			KillTimer(FI[F_TIMEOUT_TIMER]);
			FI[F_TIMEOUT_TIMER] = SetTimer("FallTimeOutCountdown", 1000, true);
			FI[F_TICKCOUNT] = gettime();
			FI[F_STATUS] = FALL_RUNNING;
			SetTimer("FallObject", 3000, false);
			UpdatePlayersFallStatus();
		}
		case FALL_RUNNING:
		{
			FI[F_ID] += 1;
			if(!LoadFall(FI[F_ID]))
			{
				FI[F_ID] = 0;
				LoadFall(FI[F_ID]);
			}
			
			TextDrawHideForAll(TD_FALL[0]);
			TextDrawHideForAll(TD_FALL[1]);
			TextDrawHideForAll(TD_FALL[2]);
			TextDrawHideForAll(TD_FALL[3]);
			TextDrawHideForAll(TD_FALL[4]);
			TextDrawHideForAll(TD_FALL[5]);
			TextDrawHideForAll(TD_FALL[6]);
			TextDrawHideForAll(TD_FALL[7]);
			TextDrawHideForAll(TD_FALL[8]);
			KillTimer(FI[F_TIMEOUT_TIMER]);
			
			FI[F_STATUS] = FALL_WAIT;
			FI[F_COUNTDOWN_COUNTER] = 11;
			KillTimer(FI[F_COUNTDOWN_TIMER]);
			FI[F_COUNTDOWN_TIMER] = SetTimer("FallCountdown", 900, true);
			UpdatePlayersFallStatus();
		}
	}
	return 1;
}


forward FallObject();
public FallObject()
{
	if(FI[F_STATUS] != FALL_RUNNING) return 1;
	if(FI[F_WINNER] != NO_WINNER) return 1;
	if(Iter_Count(FALL_OBJECTS) <= 0) return FI[F_TIMEOUT_COUNTER] = 3;
	
	new r = Iter_Random(FALL_OBJECTS);
	new Float:p[3]; GetDynamicObjectPos(FALL_OBJECTID[r], p[0], p[1], p[2]);
	MoveDynamicObject(FALL_OBJECTID[r], p[0], p[1], p[2] - 5.0, 0.5);
	Iter_Remove(FALL_OBJECTS, r);
	SetTimerEx("SpeedUp", 1000, false, "dfff", r, p[0], p[1], p[2]);

	SetTimer("FallObject", minrand(500, 3000), false);
	return 1;
}

forward SpeedUp(index, Float:X, Float:Y, Float:Z);
public SpeedUp(index, Float:X, Float:Y, Float:Z)
{
	if(FI[F_STATUS] != FALL_RUNNING) return 1;
	if(FI[F_WINNER] != NO_WINNER) return 1;
	MoveDynamicObject(FALL_OBJECTID[index], X, Y, Z - 5.0, 5.0);
	SetTimerEx("DestroyFallObject", 500, false, "dd", index, 0);
	return 1;
}

forward DestroyFallObject(index, step);
public DestroyFallObject(index, step)
{
	if(FI[F_STATUS] != FALL_RUNNING) return 1;
	if(!step)
	{
		new Float:p[3]; GetDynamicObjectPos(FALL_OBJECTID[index], p[0], p[1], p[2]); 
		DestroyDynamicObject(FALL_OBJECTID[index]);
		FALL_OBJECTID[index] = -1;
		FALL_SMOKE_OBJECTID[index] = CreateObject(18680, p[0], p[1], p[2], 0.0, 0.0, 0.0);
		SetTimerEx("DestroyFallObject", 100, false, "dd", index, 1);
	}
	else
	{
		DestroyObject(FALL_SMOKE_OBJECTID[index]);
		FALL_SMOKE_OBJECTID[index] = INVALID_OBJECT_ID;
	}
	return 1;
}

public FallTimeOutCountdown()
{
	if(FI[F_STATUS] != FALL_RUNNING) KillTimer(FI[F_TIMEOUT_TIMER]);
	
	FI[F_TIMEOUT_COUNTER] --;
	if(FI[F_TIMEOUT_COUNTER] < 0)
	{
		KillTimer(FI[F_TIMEOUT_TIMER]);
		if(FI[F_WINNER] == NO_WINNER)
		{
			for(new playerid = 0, j = GetPlayerPoolSize(); playerid <= j; playerid++) 
			{
				if(IsPlayerConnected(playerid))
				{
					if(inFall[playerid])
					{
						PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
						
						new str[256]; format(str, 256, "_~n~_~n~_~n~~y~NO_FALL_FINALIZED_~n~~g~~h~time:~p~_%s_minutes~n~~r~~h~time is over", TimeConvert(gettime() - FI[F_TICKCOUNT]));
						GameTextForPlayer(playerid, str, 5000, 6);

						FI[F_RUNNINGPLAYERS] = 0;
					}
				}
			}
			KillTimer(FI[F_NEXTFSTATUS_TIMER]);
			FI[F_NEXTFSTATUS_TIMER] = SetTimer("NextFallStatus", 5000, false);
			return 1;
		}
		return 1;
	}
	
	TextDrawSetString(TD_FALL[0], TimeConvert(FI[F_TIMEOUT_COUNTER]));
	new str[10]; 
	format(str, 10, "%d", FI[F_RUNNINGPLAYERS]); TextDrawSetString(TD_FALL[3], str);
	format(str, 10, "%d", FI[F_PLAYERS]); TextDrawSetString(TD_FALL[6], str);
	return 1;
}

forward HideFallMessage();
public HideFallMessage()
{
	return TextDrawSetString(TD_FallMessage, "_");
}

public FallCountdown()
{
	if(FI[F_STATUS] == FALL_CLOSED) return KillTimer(FI[F_COUNTDOWN_TIMER]);
	if(FI[F_PLAYERS] == 0)
	{
		KillTimer(FI[F_COUNTDOWN_TIMER]);
		CloseFall();
		return 1;
	}
	if(FI[F_PLAYERS] <= 1)
	{
		FI[F_COUNTDOWN_COUNTER] = 11;
		new str[64]; format(str, 64, "~y~awaiting_players");
		TextDrawSetString(TD_FallMessage, str);
		return 1;
	}
	FI[F_COUNTDOWN_COUNTER] --;
	new str[145]; format(str, 145, "~p~%d_players~n~~y~%d_seconds_to_start", FI[F_PLAYERS], FI[F_COUNTDOWN_COUNTER]);
	TextDrawSetString(TD_FallMessage, str);
	if(FI[F_COUNTDOWN_COUNTER] != 0) TextDrawSetString(TD_FallMessage, str);
	
	if(FI[F_COUNTDOWN_COUNTER] <= 0)
	{
		KillTimer(FI[F_COUNTDOWN_TIMER]);
		if(FI[F_PLAYERS] == 0)
		{
			CloseFall();
			return 1;
		}
		else if(FI[F_PLAYERS] == 1)
		{
			format(str, 64, "~y~awaiting_players");
			TextDrawSetString(TD_FallMessage, str);
			FI[F_COUNTDOWN_COUNTER] = 11;
			KillTimer(FI[F_COUNTDOWN_TIMER]);
			FI[F_COUNTDOWN_TIMER] = SetTimer("FallCountdown", 900, true);
		}
		else NextFallStatus();
	}
	return 1;
}

CloseFall()
{
	for(new i = 0; i != MAX_FALL_OBJECTS; i++)
	{
		if(IsValidDynamicObject(FALL_OBJECTID[i]))
		{
			DestroyDynamicObject(FALL_OBJECTID[i]);
			FALL_OBJECTID[i] = -1;
		}
		if(IsValidObject(FALL_SMOKE_OBJECTID[i]))
		{
			DestroyObject(FALL_SMOKE_OBJECTID[i]);
			FALL_SMOKE_OBJECTID[i] = INVALID_OBJECT_ID;
		}
	}
	Iter_Clear(FALL_OBJECTS);
	KillTimer(FI[F_TIMEOUT_TIMER]);
	KillTimer(FI[F_COUNTDOWN_TIMER]);
	KillTimer(FI[F_NEXTFSTATUS_TIMER]);
	FI[F_STATUS] = FALL_CLOSED;
	FI[F_PLAYERS] = 0;
	FI[F_RUNNINGPLAYERS] = 0;
	FI[F_WINNER] = NO_WINNER;
	//FI[F_ID] = 0;
	format(FI[F_NAME], 24, "");
	FI[F_WEATHER] = 0;
	FI[F_HOUR] = 0;
	FI[F_ZPOS] = 0.0;
	FI[F_TICKCOUNT] = 0;
	FI[F_COUNTDOWN_COUNTER] = 0;
	FI[F_TIMEOUT_COUNTER] = 0;
	FI[F_MAX_PRIZE] = 0;
	TextDrawSetString(TD_FallMessage, "_");
	return 1;
}

UpdatePlayersFallStatus()
{

	switch(FI[F_STATUS])
	{
		case FALL_WAIT:
		{
			for(new players = 0, j = GetPlayerPoolSize(); players <= j; players++) 
			{
				if(IsPlayerConnected(players))
				{
					if(inFall[players])
					{
						if(GetPlayerState(players) == PLAYER_STATE_SPECTATING) TogglePlayerSpectating(players, false);
						gPlayerData[players][E_PLAYER_FALL_STATUS] = PD_NORMAL;
						
						SetPlayerVirtualWorld(players, FALL_VW);
						TogglePlayerControllable(players, false);
						
						
						new r = Iter_Random(FALL_OBJECTS), Float:p[3];
						GetDynamicObjectPos(FALL_OBJECTID[r], p[0], p[1], p[2]);
						KGEyes_SetPlayerPos(players, p[0], p[1], p[2] + 3.0);
						//SetSpawnInfo(players, GetPlayerTeam(players), GetPlayerSkin(players), p[0], p[1], p[2] + 1.5, 0.0, 0, 0, 0, 0, 0,0);
						SetCameraBehindPlayer(players);
					}
				}
			}
		}
		case FALL_RUNNING:
		{
			for(new players = 0, j = GetPlayerPoolSize(); players <= j; players++) 
			{
				if(IsPlayerConnected(players))
				{
					if(inFall[players])
					{
						gPlayerData[players][E_PLAYER_FALL_STATUS] = PD_NORMAL;
						TogglePlayerControllable(players, true);
						PlayerPlaySound(players, 3200, 0.0, 0.0, 0.0);
						
						TextDrawShowForPlayer(players, TD_FALL[0]);
						TextDrawShowForPlayer(players, TD_FALL[1]);
						TextDrawShowForPlayer(players, TD_FALL[2]);
						TextDrawShowForPlayer(players, TD_FALL[3]);
						TextDrawShowForPlayer(players, TD_FALL[4]);
						TextDrawShowForPlayer(players, TD_FALL[5]);
						TextDrawShowForPlayer(players, TD_FALL[6]);
						TextDrawShowForPlayer(players, TD_FALL[7]);
						TextDrawShowForPlayer(players, TD_FALL[8]);
					}
				}
			}
		}
	}
	return 1;
}

UpdatePlayerFallStatus(playerid)
{

	switch(FI[F_STATUS])
	{
		case FALL_WAIT:
		{
			gPlayerData[playerid][E_PLAYER_FALL_STATUS] = PD_NORMAL;

			SetPlayerVirtualWorld(playerid, FALL_VW);
			TogglePlayerControllable(playerid, false);
			
			new r = Iter_Random(FALL_OBJECTS), Float:p[3];
			GetDynamicObjectPos(FALL_OBJECTID[r], p[0], p[1], p[2]);
			KGEyes_SetPlayerPos(playerid, p[0], p[1], p[2] + 3.0);
			//SetSpawnInfo(playerid, GetPlayerTeam(playerid), GetPlayerSkin(playerid), p[0], p[1], p[2] + 1.5, 0.0, 0, 0, 0, 0, 0,0);
			SetCameraBehindPlayer(playerid);
			return 1;
		}
		case FALL_RUNNING:
		{
			SetPlayerVirtualWorld(playerid, FALL_VW);
			gPlayerData[playerid][E_PLAYER_FALL_STATUS] = PD_DEAD;

			TogglePlayerSpectating(playerid, true);
			InterpolateCameraPos(playerid, FI[F_DEAD_CAM][0], FI[F_DEAD_CAM][1], FI[F_DEAD_CAM][2], FI[F_DEAD_CAM][0], FI[F_DEAD_CAM][1], FI[F_DEAD_CAM][2], 500);
			InterpolateCameraLookAt(playerid, FI[F_DEAD_CAM][3], FI[F_DEAD_CAM][4], FI[F_DEAD_CAM][5], FI[F_DEAD_CAM][3], FI[F_DEAD_CAM][4], FI[F_DEAD_CAM][5], 500);
			
			TextDrawShowForPlayer(playerid, TD_FALL[0]);
			TextDrawShowForPlayer(playerid, TD_FALL[1]);
			TextDrawShowForPlayer(playerid, TD_FALL[2]);
			TextDrawShowForPlayer(playerid, TD_FALL[3]);
			TextDrawShowForPlayer(playerid, TD_FALL[4]);
			TextDrawShowForPlayer(playerid, TD_FALL[5]);
			TextDrawShowForPlayer(playerid, TD_FALL[6]);
			TextDrawShowForPlayer(playerid, TD_FALL[7]);
			TextDrawShowForPlayer(playerid, TD_FALL[8]);
		}
	}
	return 1;
}

PlayerFallDead(playerid)
{
	if(gPlayerData[playerid][E_PLAYER_FALL_STATUS] == PD_DEAD) return 1;
	gPlayerData[playerid][E_PLAYER_FALL_STATUS] = PD_DEAD;
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	
	new str[128]; format(str, 128, "_~n~_~n~_~n~_~n~_~n~~y~YOU FELL_~r~~h~%d/%d~n~~g~~h~time:~p~_%s_minutes", FI[F_RUNNINGPLAYERS], FI[F_PLAYERS], TimeConvert(gettime() - FI[F_TICKCOUNT]));
	GameTextForPlayer(playerid, str, 5000, 6);
	
	FI[F_RUNNINGPLAYERS] -= 1;
	
	if(FI[F_RUNNINGPLAYERS] == 1)
	{
		for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++) 
		{
			if(IsPlayerConnected(i))
			{
				if(inFall[i])
				{
					if(gPlayerData[i][E_PLAYER_FALL_STATUS] == PD_NORMAL)
					{
						ApplyAnimation(i, "CASINO", "manwind", 4.1, 1, 1, 1, 1, 1, 1);
						ApplyAnimation(i, "CASINO", "manwind", 4.1, 1, 1, 1, 1, 1, 1);
						FI[F_WINNER] = i;
						GivePlayerMoneyEx( i, 2000 );
						break;
					}
				}
			}
		}
		format(str, 128, "~g~~h~winner: ~y~%s", PlayerName(FI[F_WINNER]));
		TextDrawSetString(TD_FallMessage, str);
			
		PlayerPlaySound(FI[F_WINNER], 1057, 0.0, 0.0, 0.0);
		
		format(str, 128, "_~n~_~n~_~n~_~n~_~n~~y~winner_~r~~h~%d/%d~n~~g~~h~time:~p~_%s_minutes", FI[F_RUNNINGPLAYERS], FI[F_PLAYERS], TimeConvert(gettime() - FI[F_TICKCOUNT]));
		GameTextForPlayer(FI[F_WINNER], str, 5000, 6);
		KillTimer(FI[F_NEXTFSTATUS_TIMER]);
		FI[F_NEXTFSTATUS_TIMER] = SetTimer("NextFallStatus", 5000, false);
	}
	TogglePlayerSpectating(playerid, true);
	InterpolateCameraPos(playerid, FI[F_DEAD_CAM][0], FI[F_DEAD_CAM][1], FI[F_DEAD_CAM][2], FI[F_DEAD_CAM][0], FI[F_DEAD_CAM][1], FI[F_DEAD_CAM][2], 500);
	InterpolateCameraLookAt(playerid, FI[F_DEAD_CAM][3], FI[F_DEAD_CAM][4], FI[F_DEAD_CAM][5], FI[F_DEAD_CAM][3], FI[F_DEAD_CAM][4], FI[F_DEAD_CAM][5], 500);
	return 1;
}

CheckFall()
{
	if(FI[F_PLAYERS] <= 0 && FI[F_STATUS] != FALL_CLOSED) return CloseFall();
	switch(FI[F_STATUS])
	{
		case FALL_CLOSED: return 1;
		case FALL_RUNNING:
		{
			if(FI[F_RUNNINGPLAYERS] == 1)
			{
				for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++) 
				{
					if(IsPlayerConnected(i))
					{
						if(inFall[i])
						{
							if(gPlayerData[i][E_PLAYER_FALL_STATUS] == PD_NORMAL)
							{
								ApplyAnimation(i, "CASINO", "manwind", 4.1, 1, 1, 1, 1, 1, 1);
								ApplyAnimation(i, "CASINO", "manwind", 4.1, 1, 1, 1, 1, 1, 1);
								FI[F_WINNER] = i;
								GivePlayerMoneyEx( i, 2000 );
								break;
							}
						}
					}
				}
				new str[128];
				format(str, 128, "~g~~h~winner: ~y~%s", PlayerName(FI[F_WINNER]));
				TextDrawSetString(TD_FallMessage, str);
					
				PlayerPlaySound(FI[F_WINNER], 1057, 0.0, 0.0, 0.0);
				
				format(str, 128, "_~n~_~n~_~n~_~n~_~n~~y~winner_~r~~h~%d/%d~n~~g~~h~time:~p~_%s_minutes", FI[F_RUNNINGPLAYERS], FI[F_PLAYERS], TimeConvert(gettime() - FI[F_TICKCOUNT]));
				GameTextForPlayer(FI[F_WINNER], str, 5000, 6);
				
				KillTimer(FI[F_NEXTFSTATUS_TIMER]);
				FI[F_NEXTFSTATUS_TIMER] = SetTimer("NextFallStatus", 5000, false);
			}
			return 1;
		}
	}
	return 1;
}