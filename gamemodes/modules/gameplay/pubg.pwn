#include <YSI_Coding\y_hooks>
#include <GZ_ShapesALS>
#define MAX_LOOT 900
#define PUBG_VW 20000
enum LootData
{
	ObjID,
	ObjType,
	Text3D:ObjIDLabel,
    Float:SpawnX,
    Float:SpawnY,
    Float:SpawnZ
}
new bool:PUBGLaunched, bool:PUBGOpen, PUBGMap;
new Float:PUBGCircleFloat[3];
new Float:MeterPlier;
new Iterator:PUBGIterator<MAX_LOOT>, Iterator:PUBGEvent<MAX_PLAYERS>;
new PUBGLootObj[MAX_LOOT][LootData];
new PUBGCircle, PUBGLaunchTime;
new PUBGcloseTimer;

#define 	LOOT_ARMOUR		373
#define 	LOOT_MEDKIT		11736
#define 	LOOT_SNIPER		358
#define 	LOOT_DEAGLE		348
#define 	LOOT_SHOTGUN	349
#define 	LOOT_MP5		353
#define 	LOOT_M4			356
#define 	LOOT_RIFLE		357
#define 	LOOT_GRENADE	342
#define 	LOOT_MOLOTOV	344
#define 	LOOT_SILENCED   347


new Text:PUBGKillTD;
new Text:PubgSafeZoneTD;
new Text:PUBGStaticTD;
new Text:PUBGAliveTD;
new PUBGKillExpiry;

hook OnGameModeInit()
{
	PUBGKillExpiry = 0;

	PUBGKillTD = TextDrawCreate(317.000000, 294.000000, "~r~~h~Christofski ~w~ was killed by ~b~~h~Seif_Tounes[GE]");
	TextDrawAlignment(PUBGKillTD, 2);
	TextDrawBackgroundColor(PUBGKillTD, 255);
	TextDrawFont(PUBGKillTD, 1);
	TextDrawLetterSize(PUBGKillTD, 0.230000, 1.100000);
	TextDrawColor(PUBGKillTD, -1);
	TextDrawSetOutline(PUBGKillTD, 0);
	TextDrawSetProportional(PUBGKillTD, 1);
	TextDrawSetShadow(PUBGKillTD, 1);
	TextDrawSetSelectable(PUBGKillTD, 0);

	PubgSafeZoneTD = TextDrawCreate(315.000000, 320.000000, "Restricting play area in 1 minute");
	TextDrawAlignment(PubgSafeZoneTD, 2);
	TextDrawBackgroundColor(PubgSafeZoneTD, 20);
	TextDrawFont(PubgSafeZoneTD, 1);
	TextDrawLetterSize(PubgSafeZoneTD, 0.230000, 1.100000);
	TextDrawColor(PubgSafeZoneTD, -34572289);
	TextDrawSetOutline(PubgSafeZoneTD, 1);
	TextDrawSetProportional(PubgSafeZoneTD, 1);

	PUBGStaticTD = TextDrawCreate(616.000000, 7.000000, "ALIVE");
	TextDrawAlignment(PUBGStaticTD, 2);
	TextDrawBackgroundColor(PUBGStaticTD, 255);
	TextDrawFont(PUBGStaticTD, 2);
	TextDrawLetterSize(PUBGStaticTD, 0.359999, 2.000000);
	TextDrawColor(PUBGStaticTD, 168430200);
	TextDrawSetOutline(PUBGStaticTD, 0);
	TextDrawSetProportional(PUBGStaticTD, 1);
	TextDrawSetShadow(PUBGStaticTD, 0);
	TextDrawUseBox(PUBGStaticTD, 1);
	TextDrawBoxColor(PUBGStaticTD, -206);
	TextDrawTextSize(PUBGStaticTD, 550.000000, 46.000000);

	PUBGAliveTD = TextDrawCreate(579.299987, 7.000000, "1");
	TextDrawAlignment(PUBGAliveTD, 2);
	TextDrawBackgroundColor(PUBGAliveTD, 255);
	TextDrawFont(PUBGAliveTD, 2);
	TextDrawLetterSize(PUBGAliveTD, 0.359999, 2.000000);
	TextDrawColor(PUBGAliveTD, -1);
	TextDrawSetOutline(PUBGAliveTD, 0);
	TextDrawSetProportional(PUBGAliveTD, 1);
	TextDrawSetShadow(PUBGAliveTD, 1);
	TextDrawUseBox(PUBGAliveTD, 1);
	TextDrawBoxColor(PUBGAliveTD, 84215366);
	TextDrawTextSize(PUBGAliveTD, 550.000000, 22.000000);

	return 1;
}

stock ReloadPUBGLoot()
{
	foreach(new i : PUBGIterator)
	{
		if(IsValidDynamicObject(PUBGLootObj[i][ObjID]))
			DestroyDynamicObject(PUBGLootObj[i][ObjID]);

		if(IsValidDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]))
			DestroyDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]);

        PUBGLootObj[i][ObjID] = -1;
        PUBGLootObj[i][ObjIDLabel] = Text3D:-1;
	}
	Iter_Clear(PUBGIterator);
    mysql_pquery( _dbConnector,"SELECT `x`, `y`, `z` FROM `pubgpickups`", "ReLoadEventLootCoords", "");

	return 1;
}
forward ReLoadEventLootCoords();
public ReLoadEventLootCoords()
{
	new cc;
	new fields;
	cache_get_data( cc, fields, _dbConnector );

	new Float:xx,Float:yy,Float:zz, type, tag[36], total = 0;
	for(new i =0; i < cc; i++)
	{
		total++;
		xx = cache_get_field_content_float( i, "x" );
		PUBGLootObj[i][SpawnX] = xx;
		yy = cache_get_field_content_float( i, "y" );
		PUBGLootObj[i][SpawnY] = yy;
		zz = cache_get_field_content_float( i, "z" );
		PUBGLootObj[i][SpawnZ] = zz;
		Iter_Add(PUBGIterator, i);
		switch(random(100))
		{
		    case 0..4: 		{ type = LOOT_ARMOUR; 		tag = "Armour"; 				}
		    case 5..8: 		{ type = LOOT_MEDKIT; 		tag = "Medkit"; 				}
		    case 9..17: 	{ type = LOOT_SNIPER; 		tag = "Sniper"; 				}
		    case 18..30: 	{ type = LOOT_DEAGLE; 		tag = "Deagle"; 				}
		    case 31..50: 	{ type = LOOT_SHOTGUN; 		tag = "Shotgun";			 	}
		    case 51..70: 	{ type = LOOT_MP5;     	 	tag = "MP5"; 					}
		    case 71..80: 	{ type = LOOT_M4;    		tag = "M16A4"; 					}
		    case 81..88: 	{ type = LOOT_RIFLE; 		tag = "KAR98K"; 				}
		    case 89..92: 	{ type = LOOT_GRENADE; 		tag = "Grenade"; 				}
		    case 93..96: 	{ type = LOOT_MOLOTOV; 		tag = "Molotov"; 				}
		    case 97..99: 	{ type = LOOT_SILENCED; 	tag = "Pistol w/ Suppressor"; 	}
		}
		strcat(tag, "\n\nF to pickup");
		PUBGLootObj[i][ObjType] = type;

		if(IsValidDynamicObject(PUBGLootObj[i][ObjID]))
			DestroyDynamicObject(PUBGLootObj[i][ObjID]);

		if(IsValidDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]))
			DestroyDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]);

	    PUBGLootObj[i][ObjID] = CreateDynamicObject(type, xx, yy, zz, 0, 0, 0, PUBG_VW, 0, -1, 100.0, 100.0);
        PUBGLootObj[i][ObjIDLabel] = CreateDynamic3DTextLabel(tag, 0xFFFF00AA, xx, yy, zz-0.1, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, PUBG_VW, -1,-1, 20.0 );
	}
	return 1;
}
forward LoadEventLootCoords();
public LoadEventLootCoords()
{
	new cc;
	new fields;
	cache_get_data( cc, fields, _dbConnector );

	new Float:xx,Float:yy,Float:zz, type, tag[36], total = 0;
	for(new i =0; i < cc; i++)
	{
		total++;
		xx = cache_get_field_content_float( i, "x" );
		PUBGLootObj[i][SpawnX] = xx;
		yy = cache_get_field_content_float( i, "y" );
		PUBGLootObj[i][SpawnY] = yy;
		zz = cache_get_field_content_float( i, "z" );
		PUBGLootObj[i][SpawnZ] = zz;
		Iter_Add(PUBGIterator, i);
		switch(random(100))
		{
		    case 0..4: 		{ type = LOOT_ARMOUR; 		tag = "Armour"; 				}
		    case 5..8: 		{ type = LOOT_MEDKIT; 		tag = "Medkit"; 				}
		    case 9..17: 	{ type = LOOT_SNIPER; 		tag = "Sniper"; 				}
		    case 18..30: 	{ type = LOOT_DEAGLE; 		tag = "Deagle"; 				}
		    case 31..50: 	{ type = LOOT_SHOTGUN; 		tag = "Shotgun";			 	}
		    case 51..70: 	{ type = LOOT_MP5;     	 	tag = "MP5"; 					}
		    case 71..80: 	{ type = LOOT_M4;    		tag = "M16A4"; 					}
		    case 81..88: 	{ type = LOOT_RIFLE; 		tag = "KAR98K"; 				}
		    case 89..92: 	{ type = LOOT_GRENADE; 		tag = "Grenade"; 				}
		    case 93..96: 	{ type = LOOT_MOLOTOV; 		tag = "Molotov"; 				}
		    case 97..99: 	{ type = LOOT_SILENCED; 	tag = "Pistol w/ Suppressor"; 	}
		}
		strcat(tag, "\n\nF to pickup");
		PUBGLootObj[i][ObjType] = type;

		if(IsValidDynamicObject(PUBGLootObj[i][ObjID]))
			DestroyDynamicObject(PUBGLootObj[i][ObjID]);

		if(IsValidDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]))
			DestroyDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]);

	    PUBGLootObj[i][ObjID] = CreateDynamicObject(type, xx, yy, zz, 0, 0, 0, PUBG_VW, 0, -1, 100.0, 100.0);
        PUBGLootObj[i][ObjIDLabel] = CreateDynamic3DTextLabel(tag, 0xFFFF00AA, xx, yy, zz-0.1, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, PUBG_VW, -1,-1, 20.0 );
	}
	printf( "[LOADED] %d pubg weapons", total );

	mysql_pquery( _dbConnector, "SELECT * FROM `drug_labs`", "OnDrugLabsLoad" );
	return 1;
}

stock SpreadGas(Float:meters) return SetTimerEx("SpreadGasT", 500, 0, "f", meters);

forward SpreadGasT(Float:meters);
public SpreadGasT(Float:meters)
{
	if(!PUBGLaunched) return 1;
 	PUBGCircleFloat[2] -= MeterPlier;
	new Float:x = PUBGCircleFloat[0], Float:y = PUBGCircleFloat[1], Float:r = PUBGCircleFloat[2];
	GZ_ShapeDestroy(PUBGCircle);
	PUBGCircle = GZ_ShapeCreate(CIRCLE, x, y, r);
	GZ_ShapeShowForAll(PUBGCircle, 0x00FF0084);
	meters -= MeterPlier;
	if(meters < 1.0) return 1;
	else return SetTimerEx("SpreadGasT", 500, 0, "f", meters);
}
forward POTimer();
public POTimer()
{
	if(PUBGOpen)
	{
	    new str[4]; format(str, sizeof str, "%d", Iter_Count(PUBGEvent));
		TextDrawSetString(PUBGAliveTD, str);
		foreach(new i: PUBGEvent) TextDrawShowForPlayer(i, PUBGAliveTD);
		SetTimer("POTimer", 1000, 0);
	}
	return 1;
}
Float:GetPointDistanceToPoint(Float:x1,Float:y1,Float:x2,Float:y2)
{
  new Float:x, Float:y;
  x = x1-x2;
  y = y1-y2;
  return floatsqroot(x*x+y*y);
}
Float:frandom(Float:max, Float:min = 0.0, dp = 4)
{
	new
		// Get the multiplication for storing fractional parts.
		Float:mul = floatpower(10.0, dp),
		// Get the max and min as integers, with extra dp.
		imin = floatround(min * mul),
		imax = floatround(max * mul);
	// Get a random int between two bounds and convert it to a float.
	return float(random(imax - imin) + imin) / mul;
}
forward PLTimer();
public PLTimer()
{
	if(PUBGLaunched)
	{
	    new str[4]; format(str, sizeof str, "%d", Iter_Count(PUBGEvent));
		TextDrawSetString(PUBGAliveTD, str);
	    if(PUBGKillExpiry > 0)
	    {
	        foreach(new i : PUBGEvent) TextDrawShowForPlayer(i,PUBGKillTD);
			PUBGKillExpiry --;
		} else TextDrawHideForAll(PUBGKillTD);
		new Float:rr, Float:xx, Float:yy;
		rr = PUBGCircleFloat[2], xx = PUBGCircleFloat[0], yy = PUBGCircleFloat[1];
		if(++PUBGLaunchTime > 5)
		{
			for(new i = 0; i < MAX_PLAYERS; i++)
			{
			    if(IsPlayerConnected(i))
			    {
					if(Iter_Contains(PUBGEvent, i))
					{
				    	new Float:x, Float:y, Float:z;
					    GetPlayerPos(i,x,y,z);
					    if( rr < GetPointDistanceToPoint(x,y,xx,yy) )
						{
							GameTextForPlayer(i,"~r~You are out of the safe zone!~n~-1 HP (Gas intoxication)",1000,5);
							new Float:hp; GetPlayerHealth(i, hp);
							SetPlayerHealth(i, hp-1.00);
							GetPlayerHealth(i, hp);
							if(hp <= 2) 
							{
								new msg[100];
								format(msg, 100, "~r~~h~%s ~w~ died of intoxication.", PlayerName(i));
								TextDrawSetString(PUBGKillTD, msg);
								PUBGKillExpiry = 5;
								ResetAllWeapons( i );
								SpawnPlayer( i );
								TextDrawHideForPlayer(i, PubgSafeZoneTD);
								TextDrawHideForPlayer(i, PUBGAliveTD);
								TextDrawHideForPlayer(i, PUBGStaticTD);
							}
							PlayerPlaySound(i, 1134, 0, 0, 0);
						}
					}
				}
			}
		}
		switch(PUBGLaunchTime)
		{
		    case 60:
		    {
		        TextDrawSetString(PubgSafeZoneTD, "Restricting play area in 1 minute");
                foreach(new i: PUBGEvent) TextDrawShowForPlayer(i, PubgSafeZoneTD);
		    }
		    case 65: foreach(new i: PUBGEvent) TextDrawHideForPlayer(i, PubgSafeZoneTD);
		    case 110:
		    {
		        TextDrawSetString(PubgSafeZoneTD, "Restricting play area in 10 seconds");
                foreach(new i: PUBGEvent) TextDrawShowForPlayer(i, PubgSafeZoneTD);
		    }
		    case 115: foreach(new i: PUBGEvent) TextDrawHideForPlayer(i, PubgSafeZoneTD);
		    case 120:
		    {
		        MeterPlier = 1.25;
		        TextDrawSetString(PubgSafeZoneTD, "Toxic Gas is spreading");
		        SpreadGas(100.00);
                foreach(new i: PUBGEvent) TextDrawShowForPlayer(i, PubgSafeZoneTD);
		    }
		    case 125: foreach(new i: PUBGEvent) TextDrawHideForPlayer(i, PubgSafeZoneTD);
		    case 130:
		    {
		        TextDrawSetString(PubgSafeZoneTD, "Restricting play area in 4 minutes");
                foreach(new i: PUBGEvent) TextDrawShowForPlayer(i, PubgSafeZoneTD);
		    }
		    case 135: foreach(new i: PUBGEvent) TextDrawHideForPlayer(i, PubgSafeZoneTD);
		    case 190:
		    {
		        TextDrawSetString(PubgSafeZoneTD, "Restricting play area in 3 minutes");
                foreach(new i: PUBGEvent) TextDrawShowForPlayer(i, PubgSafeZoneTD);
		    }
		    case 195: foreach(new i: PUBGEvent) TextDrawHideForPlayer(i, PubgSafeZoneTD);
		    case 250:
		    {
		        TextDrawSetString(PubgSafeZoneTD, "Restricting play area in 2 minutes");
                foreach(new i: PUBGEvent) TextDrawShowForPlayer(i, PubgSafeZoneTD);
		    }
		    case 255: foreach(new i: PUBGEvent) TextDrawHideForPlayer(i, PubgSafeZoneTD);
		    case 310:
		    {
		        TextDrawSetString(PubgSafeZoneTD, "Restricting play area in 1 minute");
                foreach(new i: PUBGEvent) TextDrawShowForPlayer(i, PubgSafeZoneTD);
		    }
		    case 315: foreach(new i: PUBGEvent) TextDrawHideForPlayer(i, PubgSafeZoneTD);
		    case 360:
		    {
		        TextDrawSetString(PubgSafeZoneTD, "Restricting play area in 10 seconds");
                foreach(new i: PUBGEvent) TextDrawShowForPlayer(i, PubgSafeZoneTD);
		    }
		    case 365: foreach(new i: PUBGEvent) TextDrawHideForPlayer(i, PubgSafeZoneTD);
		    case 370:
		    {
		        MeterPlier = 2.5;
		        TextDrawSetString(PubgSafeZoneTD, "Toxic Gas is spreading");
		        SpreadGas(100.00);
                foreach(new i: PUBGEvent) TextDrawShowForPlayer(i, PubgSafeZoneTD);
		    }
		    case 375: foreach(new i: PUBGEvent) TextDrawHideForPlayer(i, PubgSafeZoneTD);
		    case 380:
		    {
		        TextDrawSetString(PubgSafeZoneTD, "Restricting play area in 5 minutes");
                foreach(new i: PUBGEvent) TextDrawShowForPlayer(i, PubgSafeZoneTD);
		    }
		    case 385: foreach(new i: PUBGEvent) TextDrawHideForPlayer(i, PubgSafeZoneTD);
		    case 440:
		    {
		        TextDrawSetString(PubgSafeZoneTD, "Restricting play area in 4 minutes");
                foreach(new i: PUBGEvent) TextDrawShowForPlayer(i, PubgSafeZoneTD);
		    }
		    case 445: foreach(new i: PUBGEvent) TextDrawHideForPlayer(i, PubgSafeZoneTD);
		    case 500:
		    {
		        TextDrawSetString(PubgSafeZoneTD, "Restricting play area in 3 minutes");
                foreach(new i: PUBGEvent) TextDrawShowForPlayer(i, PubgSafeZoneTD);
		    }
		    case 505: foreach(new i: PUBGEvent) TextDrawHideForPlayer(i, PubgSafeZoneTD);
		    case 560:
		    {
		        TextDrawSetString(PubgSafeZoneTD, "Restricting play area in 2 minutes");
                foreach(new i: PUBGEvent) TextDrawShowForPlayer(i, PubgSafeZoneTD);
		    }
		  	case 565: foreach(new i: PUBGEvent) TextDrawHideForPlayer(i, PubgSafeZoneTD);
		    case 620:
			{
		        TextDrawSetString(PubgSafeZoneTD, "Restricting play area in 1 minute");
                foreach(new i: PUBGEvent) TextDrawShowForPlayer(i, PubgSafeZoneTD);
		    }
		    case 625: foreach(new i: PUBGEvent) TextDrawHideForPlayer(i, PubgSafeZoneTD);
		    case 670:
		    {
		        TextDrawSetString(PubgSafeZoneTD, "Restricting play area in 10 seconds");
                foreach(new i: PUBGEvent) TextDrawShowForPlayer(i, PubgSafeZoneTD);
		    }
		    case 675: foreach(new i: PUBGEvent) TextDrawHideForPlayer(i, PubgSafeZoneTD);
		    case 680:
		    {
		        MeterPlier = 3.75;
		        TextDrawSetString(PubgSafeZoneTD, "Toxic Gas is spreading");
		        SpreadGas(200.00);
                foreach(new i: PUBGEvent) TextDrawShowForPlayer(i, PubgSafeZoneTD);
		    }
		    case 685: foreach(new i: PUBGEvent) TextDrawHideForPlayer(i, PubgSafeZoneTD);
		}
		SetTimer("PLTimer", 1000, 0);
	}
	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(PUBGLaunched)
	{
     	if(Iter_Contains(PUBGEvent, playerid))
		{
		    new Float:xxx,Float:yyy,Float:zz;
		    GetPlayerPos(playerid,xxx,yyy,zz);
	        new weapons[13][2];
			for(new i=2;i<13;i++)
			{
				GetPlayerWeaponData(playerid, i, weapons[i][0], weapons[i][1]);
				new weap = weapons[i][0];
				if(!(weap == 34 || weap == 24 || weap == 25 || weap == 29 || weap == 31 || weap == 33 || weap == 16 || weap == 18 || weap == 23)) continue;
			    if(weapons[i][1] > 0)
			    {
					new tag[86], type;
					new b = Iter_Free(PUBGIterator);
					Iter_Add(PUBGIterator, b);
					new Float:xx =  xxx + frandom(2.0, -2.0, 2), Float:yy =  yyy + frandom(2.0, -2.0, 2);
					PUBGLootObj[b][SpawnX] = xx;
					PUBGLootObj[b][SpawnY] = yy;
					PUBGLootObj[b][SpawnZ] = zz;
					format(tag, sizeof tag, "%f %f %f", xx,yy,zz);
					SCM(playerid, -1,tag);

	    			new kk = weapons[i][0];
					switch(kk)
					{
					    case 34: 	{ type = LOOT_SNIPER; 		tag = "Sniper"; 				}
					    case 24: 	{ type = LOOT_DEAGLE; 		tag = "Deagle"; 				}
					    case 25: 	{ type = LOOT_SHOTGUN; 		tag = "Shotgun";			 	}
					    case 29: 	{ type = LOOT_MP5;     	 	tag = "MP5"; 					}
					    case 31: 	{ type = LOOT_M4;    		tag = "M16A4"; 					}
					    case 33: 	{ type = LOOT_RIFLE; 		tag = "KAR98K"; 				}
					    case 16: 	{ type = LOOT_GRENADE; 		tag = "Grenade"; 				}
					    case 18: 	{ type = LOOT_MOLOTOV; 		tag = "Molotov"; 				}
					    case 23: 	{ type = LOOT_SILENCED; 	tag = "Pistol w/ Suppressor"; 	}
					}
					strcat(tag, "\n\nF to pickup");
					PUBGLootObj[b][ObjType] = type;

					if(IsValidDynamicObject(PUBGLootObj[b][ObjID]))
						DestroyDynamicObject(PUBGLootObj[b][ObjID]);

					if(IsValidDynamic3DTextLabel(PUBGLootObj[b][ObjIDLabel]))
						DestroyDynamic3DTextLabel(PUBGLootObj[b][ObjIDLabel]);

			        PUBGLootObj[b][ObjID] = CreateDynamicObject(type, xx, yy, zz, 0, 0, 0, PUBG_VW, 0, -1, 100.0, 100.0);
			        PUBGLootObj[b][ObjIDLabel] = CreateDynamic3DTextLabel(tag, 0xFFFF00AA, xx, yy, zz-0.1, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, PUBG_VW, -1,-1, 20.0 );
				}
			}
			/*
			new i = playerid;
			Iter_SafeRemove(PUBGEvent, playerid, i);
			TextDrawHideForPlayer(playerid, PubgSafeZoneTD);
			if(Iter_Count(PUBGEvent) == 1)
			{
			    new to[150];
			    new k = Iter_Random(PUBGEvent);
				format(to, 24, PlayerName(k));
			    format(to,100,"{FF0000}[PUBG] %s, Winner Winner Chicken Dinner!",to);
			  	TextDrawHideForPlayer(k, PUBGAliveTD);
			  	TextDrawHideForPlayer(k, PUBGStaticTD);
				SendClientMessageToAll(-1,to);
			    Iter_Clear(PUBGEvent);
			    PUBGLaunched = false;
			    TextDrawHideForPlayer(k, PubgSafeZoneTD);
			    ReloadPUBGLoot();
			    SpawnPlayer(k);
			}*/
  		}
	}
	else if(Iter_Contains(PUBGEvent, playerid)) Iter_SafeRemove(PUBGEvent, playerid, playerid);
	return 1;
}

hook OnPlayerDeath(playerid, killerid, reason)
{
	if(PUBGLaunched)
	{
	    if(Iter_Contains(PUBGEvent, playerid))
		{
		    TextDrawHideForPlayer(playerid, PUBGAliveTD);
		  	TextDrawHideForPlayer(playerid, PUBGStaticTD);
			new Float:xxx,Float:yyy,Float:zz, killername[25], msg[100];
            if(killerid != INVALID_PLAYER_ID)
			{
				format(killername, 24, PlayerName(killerid));
				format(msg, 100, "~r~~h~%s ~w~ was killed by ~b~~h~%s", PlayerName(playerid), killername);
			}
			else format(msg, 100, "~r~~h~%s ~w~ was knocked out", PlayerName(playerid));
			TextDrawSetString(PUBGKillTD, msg);
			PUBGKillExpiry = 5;
		    GetPlayerPos(playerid,xxx,yyy,zz);
	        new weapons[13][2];
			for(new i=2;i<13;i++)
			{
				GetPlayerWeaponData(playerid, i, weapons[i][0], weapons[i][1]);
				new weap = weapons[i][0];
				if(!(weap == 34 || weap == 24 || weap == 25 || weap == 29 || weap == 31 || weap == 33 || weap == 16 || weap == 18 || weap == 23)) continue;
			    if(weapons[i][1] > 0)
			    {
					new tag[86], type;
					new b = Iter_Free(PUBGIterator);
					Iter_Add(PUBGIterator, b);
					new Float:xx =  xxx + frandom(2.0, -2.0, 2), Float:yy =  yyy + frandom(2.0, -2.0, 2);
					PUBGLootObj[b][SpawnX] = xx;
					PUBGLootObj[b][SpawnY] = yy;
					PUBGLootObj[b][SpawnZ] = zz;
	    			new kk = weapons[i][0];
					switch(kk)
					{
					    case 34: 	{ type = LOOT_SNIPER; 		tag = "Sniper"; 				}
					    case 24: 	{ type = LOOT_DEAGLE; 		tag = "Deagle"; 				}
					    case 25: 	{ type = LOOT_SHOTGUN; 		tag = "Shotgun";			 	}
					    case 29: 	{ type = LOOT_MP5;     	 	tag = "MP5"; 					}
					    case 31: 	{ type = LOOT_M4;    		tag = "M16A4"; 					}
					    case 33: 	{ type = LOOT_RIFLE; 		tag = "KAR98K"; 				}
					    case 16: 	{ type = LOOT_GRENADE; 		tag = "Grenade"; 				}
					    case 18: 	{ type = LOOT_MOLOTOV; 		tag = "Molotov"; 				}
					    case 23: 	{ type = LOOT_SILENCED; 	tag = "Pistol w/ Suppressor"; 	}
					}
					strcat(tag, "\n\nF to pickup");
					PUBGLootObj[b][ObjType] = type;

					if(IsValidDynamicObject(PUBGLootObj[b][ObjID]))
						DestroyDynamicObject(PUBGLootObj[b][ObjID]);

					if(IsValidDynamic3DTextLabel(PUBGLootObj[b][ObjIDLabel]))
						DestroyDynamic3DTextLabel(PUBGLootObj[b][ObjIDLabel]);

			        PUBGLootObj[b][ObjID] = CreateDynamicObject(type, xx, yy, zz, 0, 0, 0, PUBG_VW, 0, -1, 100.0, 100.0);
			        PUBGLootObj[b][ObjIDLabel] = CreateDynamic3DTextLabel(tag, 0xFFFF00AA, xx, yy, zz-0.1, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, PUBG_VW, -1,-1, 20.0 );
				}
			}
			/*
			new i = playerid;
			Iter_SafeRemove(PUBGEvent, playerid, i);
			TextDrawHideForPlayer(playerid, PubgSafeZoneTD);
			SpawnPlayer(playerid);
			if(Iter_Count(PUBGEvent) == 1)
			{
			    new to[128];
			    new k = Iter_Random(PUBGEvent);
				format(to, 24, PlayerName(k));
			    format(to,128,"{FF0000}[PUBG] %s Winner Winner Chicken Dinner! Earned 200XP, 100 Score & $100k as a reward.",to);
			  	TextDrawHideForPlayer(k, PUBGAliveTD);
			  	TextDrawHideForPlayer(k, PUBGStaticTD);
				SendClientMessageToAll(-1,to);
			    Iter_Clear(PUBGEvent);
			    ReloadPUBGLoot();
			    PUBGLaunched = false;
			    SetPlayerHealth(k, 0);
			    TextDrawHideForPlayer(k, PubgSafeZoneTD);
			}*/
		}
	}
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(inPUBG[playerid] == 1)
	{
		if(PRESSED(KEY_SECONDARY_ATTACK))
		{
			foreach(new i:PUBGIterator)
		    {
				new Float:xx,Float:yy,Float:zz;
				xx = PUBGLootObj[i][SpawnX]; yy = PUBGLootObj[i][SpawnY]; zz = PUBGLootObj[i][SpawnZ];
				if(IsPlayerInRangeOfPoint(playerid, 0.9, xx, yy, zz) && GetPlayerVirtualWorld(playerid) == PUBG_VW)
				{
				    switch(PUBGLootObj[i][ObjType])
				    {
				        case LOOT_ARMOUR:
				        {
				            new Float:Arm;
							GetPlayerArmour(playerid, Arm);
							if(Arm>10) { SendErrorMessage(playerid, "You already have some armour."); continue;}
						    SetPlayerArmour(playerid, 100.00);

						    if(IsValidDynamicObject(PUBGLootObj[i][ObjID]))
								DestroyDynamicObject(PUBGLootObj[i][ObjID]);

							if(IsValidDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]))
								DestroyDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]);

							PUBGLootObj[i][ObjID] = -1;
							PUBGLootObj[i][ObjIDLabel] = Text3D:-1;

							Iter_SafeRemove(PUBGIterator, i, i);
							ApplyAnimation(playerid,"CARRY","liftup05",4.1,0,0,0,0,500, 1);
						    break;
				        }
				        case LOOT_MEDKIT:
				        {
				            new Float:HP;
							GetPlayerHealth(playerid, HP);
							if(HP> 99.00) { SendErrorMessage(playerid, "You already have full HP."); continue;}
							SetPlayerHealth(playerid, 100.00);

						    if(IsValidDynamicObject(PUBGLootObj[i][ObjID]))
								DestroyDynamicObject(PUBGLootObj[i][ObjID]);

							if(IsValidDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]))
								DestroyDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]);

							PUBGLootObj[i][ObjID] = -1;
							PUBGLootObj[i][ObjIDLabel] = Text3D:-1;
							Iter_SafeRemove(PUBGIterator, i, i);
							ApplyAnimation(playerid,"CARRY","liftup05",4.1,0,0,0,0,500, 1);
							break;
				        }
				        case LOOT_SNIPER:
				        {
							GiveWeaponToPlayer(playerid, 34, random(80)+1);

						    if(IsValidDynamicObject(PUBGLootObj[i][ObjID]))
								DestroyDynamicObject(PUBGLootObj[i][ObjID]);

							if(IsValidDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]))
								DestroyDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]);

							PUBGLootObj[i][ObjID] = -1;
							PUBGLootObj[i][ObjIDLabel] = Text3D:-1;

							Iter_SafeRemove(PUBGIterator, i, i);
							ApplyAnimation(playerid,"CARRY","liftup05",4.1,0,0,0,0,500, 1);
							break;
				        }
				        case LOOT_DEAGLE:
				        {
							GiveWeaponToPlayer(playerid, 24, random(80)+1);
						    if(IsValidDynamicObject(PUBGLootObj[i][ObjID]))
								DestroyDynamicObject(PUBGLootObj[i][ObjID]);

							if(IsValidDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]))
								DestroyDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]);

							PUBGLootObj[i][ObjID] = -1;
							PUBGLootObj[i][ObjIDLabel] = Text3D:-1;
							Iter_SafeRemove(PUBGIterator, i, i);
							ApplyAnimation(playerid,"CARRY","liftup05",4.1,0,0,0,0,500, 1);
							break;
				        }
				        case LOOT_SHOTGUN:
				        {
							GiveWeaponToPlayer(playerid, 25, random(80)+1);

						    if(IsValidDynamicObject(PUBGLootObj[i][ObjID]))
								DestroyDynamicObject(PUBGLootObj[i][ObjID]);

							if(IsValidDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]))
								DestroyDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]);

							PUBGLootObj[i][ObjID] = -1;
							PUBGLootObj[i][ObjIDLabel] = Text3D:-1;

							Iter_SafeRemove(PUBGIterator, i, i);
							ApplyAnimation(playerid,"CARRY","liftup05",4.1,0,0,0,0,500, 1);
							break;
				        }
				        case LOOT_MP5:
				        {
							GiveWeaponToPlayer(playerid, 29, random(200)+1);
						    if(IsValidDynamicObject(PUBGLootObj[i][ObjID]))
								DestroyDynamicObject(PUBGLootObj[i][ObjID]);

							if(IsValidDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]))
								DestroyDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]);

							PUBGLootObj[i][ObjID] = -1;
							PUBGLootObj[i][ObjIDLabel] = Text3D:-1;
							Iter_SafeRemove(PUBGIterator, i, i);
							ApplyAnimation(playerid,"CARRY","liftup05",4.1,0,0,0,0,500, 1);
							break;
				        }
				        case LOOT_M4:
				        {
							GiveWeaponToPlayer(playerid, 31, random(100)+1);
						    if(IsValidDynamicObject(PUBGLootObj[i][ObjID]))
								DestroyDynamicObject(PUBGLootObj[i][ObjID]);

							if(IsValidDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]))
								DestroyDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]);

							PUBGLootObj[i][ObjID] = -1;
							PUBGLootObj[i][ObjIDLabel] = Text3D:-1;
							Iter_SafeRemove(PUBGIterator, i, i);
							ApplyAnimation(playerid,"CARRY","liftup05",4.1,0,0,0,0,500, 1);
							break;
				        }
				        case LOOT_RIFLE:
				        {
							GiveWeaponToPlayer(playerid, 33, random(100)+1);
						    if(IsValidDynamicObject(PUBGLootObj[i][ObjID]))
								DestroyDynamicObject(PUBGLootObj[i][ObjID]);

							if(IsValidDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]))
								DestroyDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]);

							PUBGLootObj[i][ObjID] = -1;
							PUBGLootObj[i][ObjIDLabel] = Text3D:-1;
							Iter_SafeRemove(PUBGIterator, i, i);
							ApplyAnimation(playerid,"CARRY","liftup05",4.1,0,0,0,0,500, 1);
							break;
				        }
				        case LOOT_GRENADE:
				        {
							GiveWeaponToPlayer(playerid, 16, random(6)+1);
						    if(IsValidDynamicObject(PUBGLootObj[i][ObjID]))
								DestroyDynamicObject(PUBGLootObj[i][ObjID]);

							if(IsValidDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]))
								DestroyDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]);

							PUBGLootObj[i][ObjID] = -1;
							PUBGLootObj[i][ObjIDLabel] = Text3D:-1;
							Iter_SafeRemove(PUBGIterator, i, i);
							ApplyAnimation(playerid,"CARRY","liftup05",4.1,0,0,0,0,500, 1);
							break;
				        }
				        case LOOT_MOLOTOV:
				        {
							GiveWeaponToPlayer(playerid, 18, random(6)+1);
						    if(IsValidDynamicObject(PUBGLootObj[i][ObjID]))
								DestroyDynamicObject(PUBGLootObj[i][ObjID]);

							if(IsValidDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]))
								DestroyDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]);

							PUBGLootObj[i][ObjID] = -1;
							PUBGLootObj[i][ObjIDLabel] = Text3D:-1;
							Iter_SafeRemove(PUBGIterator, i, i);
							ApplyAnimation(playerid,"CARRY","liftup05",4.1,0,0,0,0,500, 1);
							break;
				        }
				        case LOOT_SILENCED:
				        {
							GiveWeaponToPlayer(playerid, 23, random(150)+1);
						    if(IsValidDynamicObject(PUBGLootObj[i][ObjID]))
								DestroyDynamicObject(PUBGLootObj[i][ObjID]);

							if(IsValidDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]))
								DestroyDynamic3DTextLabel(PUBGLootObj[i][ObjIDLabel]);

							PUBGLootObj[i][ObjID] = -1;
							PUBGLootObj[i][ObjIDLabel] = Text3D:-1;
							Iter_SafeRemove(PUBGIterator, i, i);
							ApplyAnimation(playerid,"CARRY","liftup05",4.1,0,0,0,0,500, 1);
							break;
				        }
				    }
				}
		    }
		}
	}
	return 1;
}

CMD:pubgstart(playerid, params[])
{
	if( gPlayerData[ playerid ][ E_PLAYER_ADMIN_LEVEL ] < 4) return SendErrorMessage( playerid, "You do not have permission to use this command." );
	if( EventInfo[ eID ] != 0 || EventInfo[ ec_Started ] > 0 || EventInfo[ edr_Started ] > 0 || deaglePokrenut > 0) return SendErrorMessage( playerid, "An event is already running, use /endevent." );
	if(PUBGOpen || PUBGLaunched) return SendErrorMessage(playerid, "PUBG event has already started. Use /endpubg to end it.");

	new mapp;
	if(sscanf(params,"d",mapp)) return SendUsageMessage(playerid,"/pubgstart ( 1 - San Fierro, 2 - Bone County, 3 - Las Venturas, 4 - Red County)");

	if(mapp == 1)
	{
		PUBGOpen = true;
		SetTimer("POTimer", 1000, 0);
		PUBGLaunched = false;
		SCMA( -1, ""col_zenolo"San Fierro PUBG | Event has begun, you have 60 seconds to join [/pubg]." );
		PUBGcloseTimer = SetTimer("ClosePUBG", 60*1000, 0);
		GZ_ShapeDestroy(PUBGCircle);
		PUBGMap = mapp;
		PUBGCircleFloat[0] = -2259.0444;
		PUBGCircleFloat[1] = 568.2881;
		PUBGCircleFloat[2] = 500.00;
		PUBGCircle = GZ_ShapeCreate(CIRCLE, -2259.0444, 568.2881, 500.00);
		GZ_ShapeShowForAll(PUBGCircle, 0x00FF0084);
	}
	else if(mapp == 2)
	{
		PUBGOpen = true;
		SetTimer("POTimer", 1000, 0);
		PUBGLaunched = false;
		SCMA( -1, ""col_zenolo"Bone County PUBG | Event has begun, you have 60 seconds to join [/pubg]." );
		PUBGcloseTimer = SetTimer("ClosePUBG", 60*1000, 0);
		GZ_ShapeDestroy(PUBGCircle);
		PUBGMap = mapp;
		PUBGCircleFloat[0] = -149.3887;
		PUBGCircleFloat[1] = 1925.7269;
		PUBGCircleFloat[2] = 500.00;
		PUBGCircle = GZ_ShapeCreate(CIRCLE, -149.3887, 1925.7269, 500.00);
		GZ_ShapeShowForAll(PUBGCircle, 0x00FF0084);
	}
	else if(mapp == 3)
	{
		PUBGOpen = true;
		SetTimer("POTimer", 1000, 0);
		PUBGLaunched = false;
		SCMA( -1, ""col_zenolo"Las Venturas PUBG | Event has begun, you have 60 seconds to join [/pubg]." );
		PUBGcloseTimer = SetTimer("ClosePUBG", 60*1000, 0);
		GZ_ShapeDestroy(PUBGCircle);
		PUBGMap = mapp;
		PUBGCircleFloat[0] = 2104.7358;
		PUBGCircleFloat[1] = 1785.3613;
		PUBGCircleFloat[2] = 500.00;
		PUBGCircle = GZ_ShapeCreate(CIRCLE, 2104.7358, 1785.3613, 500.00);
		GZ_ShapeShowForAll(PUBGCircle, 0x00FF0084);
	}
	else if(mapp == 4)
	{
		PUBGOpen = true;
		SetTimer("POTimer", 1000, 0);
		PUBGLaunched = false;
		SCMA( -1, ""col_zenolo"Red County PUBG | Event has begun, you have 60 seconds to join [/pubg]." );
		PUBGcloseTimer = SetTimer("ClosePUBG", 60*1000, 0);
		GZ_ShapeDestroy(PUBGCircle);
		PUBGMap = mapp;
		PUBGCircleFloat[0] = 848.6768;
		PUBGCircleFloat[1] = -215.2424;
		PUBGCircleFloat[2] = 500.00;
		PUBGCircle = GZ_ShapeCreate(CIRCLE, 848.6768, -215.2424, 500.00);
		GZ_ShapeShowForAll(PUBGCircle, 0x00FF0084);
	}
	else SendErrorMessage(playerid, "Invalid map number selected.");
	return 1;
}

CMD:endpubg(playerid)
{
	if( gPlayerData[ playerid ][ E_PLAYER_ADMIN_LEVEL ] < 4) return SendErrorMessage( playerid, "You do not have permission to use this command." );
	if(!PUBGOpen && !PUBGLaunched) return SendErrorMessage(playerid, "PUBG event is not running.");
	KillTimer(PUBGcloseTimer);
	PUBGLaunched = false;
	PUBGOpen = false;
	PUBGLaunchTime = 0;
	foreach(new k : PUBGEvent)
	{
		ResetAllWeapons(k);
		TextDrawHideForPlayer(k, PubgSafeZoneTD);
		KGEyes_SetSpawnInfo( k );
		inPUBG[ k ] = 0;
		SpawnPlayer(k);
		SendInfoMessage(k, "Management has ended PUBG event.");
		//Iter_SafeRemove(PUBGEvent, k, k);
		TextDrawHideForPlayer(k, PUBGAliveTD);
		TextDrawHideForPlayer(k, PUBGStaticTD);
	}
	GZ_ShapeDestroy(PUBGCircle);
	TextDrawHideForAll(PUBGKillTD);
	Iter_Clear(PUBGEvent);
	ReloadPUBGLoot();
	SendInfoMessage(playerid, "You have ended PUBG event.");
	return 1;
}
CMD:addpubg(playerid, params[])
{
	if( gPlayerData[ playerid ][ E_PLAYER_ADMIN_LEVEL ] < 3 ) return -1;
	if(!PUBGLaunched && PUBGOpen) return SendErrorMessage(playerid, "PUBG mode registration is still open. Tell them to /pubg instead.");
	new playa;
	if( sscanf( params, "u", playa ) ) {
		SendUsageMessage( playerid, "/addpubg [ ID/Name ]");
		return 1;
	}
	if(!IsPlayerConnected(playa)) return SendErrorMessage(playerid, "There's no one online with that ID.");
	if(Iter_Contains(PUBGEvent, playa)) return SendErrorMessage(playerid, "Specified player is already in the event.");
	if( NaDmEventu[ playa ] == true ) return SendErrorMessage( playerid, "Specified player is at CS: DM." );
	if( tdm_player_info[ playa ][ tdm_Team ] != -1 ) return SendErrorMessage( playerid, "Specified player is at TDM event." );
	if( NaUtrci[ playa ] ) return SendErrorMessage( playerid, "Specified player is at the race." );
	if( naDeagle[ playa ] != 0 ) return SendErrorMessage( playerid, "Specified player is at an event." );
	if( WARPInfo[ playa ][ WARIgrac ] != -1 ) return SendErrorMessage( playerid, "Specified player is at war." );
	if( GetPlayerState( playa ) != PLAYER_STATE_ONFOOT ) return SendErrorMessage( playerid, "Specified player must be on his feet!" );
	if( IsPlayerFalling( playa ) ) return SendErrorMessage( playerid, "You cannot add them to pubg while they are falling." );
	if( gPlayerData[ playa ][ E_PLAYER_JAIL_TYPE ] != 0 ) return SendErrorMessage( playerid, "You can't add them to PUBG while they're in jail." );
	if( GetPlayerInterior( playa ) > 0 ) return SendErrorMessage(playerid, "Specified player is in an interior.");
	if(GetPlayerVirtualWorld(playa) > 0) return SendErrorMessage(playerid, "Specified player is not in virtual world ID 0.");
	if( PlayerInvited[ playa ] > 0 ) return SendErrorMessage( playerid, "Specified player is at an event." );
	if( PlayerCP[ playa ] > 0 ) return SendErrorMessage( playerid, "Specified player is at an event." );
	if( PlayerCuffed[ playa ] > 0 ) return SendErrorMessage( playerid, "Specified player is cuffed." );
	if( IgracZavezan[ playa ] == true ) return SendErrorMessage( playerid, "Specified player is tied up." );
	if( PlayerCP[ playa ] > 0 && PlayerInvited[ playa ] != 0 ) return SendErrorMessage( playerid, "Specified player is at event." );
	if(gPlayerData[playa][E_PLAYER_DUTY] != E_DUTY_NONE) return SendErrorMessage( playerid, "Specified player is on faction duty.");
	if( IsSuspected(playa) ) return SendErrorMessage( playerid, "Specified player is suspected." );

	SavePlayerWeapons(playa);
	GetPlayerPos( playa, PozicijaWAR[ playa ][ 0 ], PozicijaWAR[ playa ][ 1 ],  PozicijaWAR[ playa ][ 2 ] );
	GetPlayerArmour(playa, gPlayerData[playa][E_PLAYER_ARMOUR]);
	GetPlayerHealth(playa,gPlayerData[playa][E_PLAYER_HEALTH]);
	ResetAllWeapons( playa );

	SetPlayerVirtualWorld(playa, PUBG_VW);
	ResetAllWeapons(playa);
	SetPlayerHealth(playa, 100.00);
	SendGreenMessage(playa, "You have been added to PUBG event by %s!", PlayerName(playerid));
	TextDrawShowForPlayer(playa, PUBGAliveTD);
	TextDrawShowForPlayer(playa, PUBGStaticTD);
	Iter_Add(PUBGEvent, playa);
	inPUBG[playa] = 1;

	for(new i=0; i<4; i++) PlayerTextDrawHide(playa, valrisetd[playa][i]);
	TextDrawHideForPlayer(playa, timetd);

	GameTextForPlayer(playa,"~r~Go!",3000,5);
    PlayerPlaySound(playa, 15805, 0,0,0);
    SetPlayerArmour(playa, 0.0);
	GiveWeaponToPlayer(playa, 46,1);
    new Float:xx = frandom(50.0, -50.0, 2), Float:yy = frandom(50.0, -50.0, 2), Float:zz = frandom(15.0, -15.0, 2);
    switch(PUBGMap)
	{
		case 1: KGEyes_SetPlayerPos(playa, -2259.0444+xx, 568.2881+yy, 779.9348+zz);
		case 2: KGEyes_SetPlayerPos(playa, -149.3887+xx,1925.7269+yy,779.9348+zz);
		case 3: KGEyes_SetPlayerPos(playa, 2104.7358+xx,1785.3613+yy,779.9348+zz);
		case 4: KGEyes_SetPlayerPos(playa, 848.6768+xx,-215.2424+yy,779.9348+zz);
	}
    SetPlayerInterior(playa, 0);
	ApplyAnimation(playa,"PARACHUTE","FALL_skyDive",0.0,0,0,0,0,0);

	GZ_ShapeShowForPlayer(playa, PUBGCircle, 0x00FF0084);

	SendInfoMessage(playerid, "You succesfully added %s to PUBG event.", PlayerName(playa));
	return 1;
}
CMD:pubg(playerid)
{
	if(Iter_Contains(PUBGEvent, playerid)) return SendErrorMessage(playerid, "You have already joined PUBG Event.");
	if(!PUBGOpen) return SendErrorMessage(playerid, "No PUBG event running or the event is locked.");
	if( NaDmEventu[ playerid ] == true ) return SendErrorMessage( playerid, "You can't while you're at CS: DM." );
	if( tdm_player_info[ playerid ][ tdm_Team ] != -1 ) return SendErrorMessage( playerid, "You can't do this while you're at a TDM event." );
	if( NaUtrci[ playerid ] ) return SendErrorMessage( playerid, "You can't while you're at the race." );
	if( naDeagle[ playerid ] != 0 ) return SendErrorMessage( playerid, "You can't while you're at an event." );
	if( WARPInfo[ playerid ][ WARIgrac ] != -1 ) return SendErrorMessage( playerid, "You can't do this while you're at war." );
	if( GetPlayerState( playerid ) != PLAYER_STATE_ONFOOT ) return SendErrorMessage( playerid, "You have to be on your feet!" );
	if( IsPlayerFalling( playerid ) ) return SendErrorMessage( playerid, "You cannot use this command while falling." );
	if( gPlayerData[ playerid ][ E_PLAYER_JAIL_TYPE ] != 0 ) return SendErrorMessage( playerid, "You can't join PUBG while you're in jail." );
	if( GetPlayerInterior( playerid ) > 0 ) return SendErrorMessage(playerid, "You can't use this command in the interior.");
	if(GetPlayerVirtualWorld(playerid) > 0) return SendErrorMessage(playerid, "You can't use this command in the interior.");
	if( PlayerInvited[ playerid ] > 0 ) return SendErrorMessage( playerid, "You cannot use this command while at an event." );
	if( PlayerCP[ playerid ] > 0 ) return SendErrorMessage( playerid, "You cannot use this command while at an event." );
	if( !PlayerFreezed[ playerid ] ) return SendErrorMessage(playerid, "You're frozen, you can't use this command.");
	if( PlayerCuffed[ playerid ] > 0 ) return SendErrorMessage( playerid, "You can't while you're tazed or cuffed." );
	if( IgracZavezan[ playerid ] == true ) return SendErrorMessage( playerid, "You can't while you're tied up." );
	if( PlayerCP[ playerid ] > 0 && PlayerInvited[ playerid ] != 0 ) return SendErrorMessage( playerid, "You are already at an event." );
	if( gPlayerData[playerid][E_PLAYER_DUTY] != E_DUTY_NONE) return SendErrorMessage( playerid, "You can't go to an event while you're on duty.");
	if( IsSuspected(playerid) ) return SendErrorMessage( playerid, "You cannot do this while you are suspected." );

	SavePlayerWeapons(playerid);
	GetPlayerPos( playerid, PozicijaWAR[ playerid ][ 0 ], PozicijaWAR[ playerid ][ 1 ],  PozicijaWAR[ playerid ][ 2 ] );
	GetPlayerArmour(playerid, gPlayerData[playerid][E_PLAYER_ARMOUR]);
	GetPlayerHealth(playerid,gPlayerData[playerid][E_PLAYER_HEALTH]);
	ResetAllWeapons( playerid );

	SetPlayerInterior(playerid, 1);
	KGEyes_SetPlayerPos(playerid, 1.808619,32.384357,1199.593750);
	SetPlayerVirtualWorld(playerid, PUBG_VW);
	ResetAllWeapons(playerid);
	SetPlayerArmour(playerid, 0.0);
	SetPlayerHealth(playerid, 100.00);
	SendGreenMessage(playerid, "You have joined PUBG event. Wait for it to start!");
	TextDrawShowForPlayer(playerid, PUBGAliveTD);
	TextDrawShowForPlayer(playerid, PUBGStaticTD);
	Iter_Add(PUBGEvent, playerid);
	inPUBG[playerid] = 1;

	for(new i=0; i<4; i++) PlayerTextDrawHide(playerid, valrisetd[playerid][i]);
	TextDrawHideForPlayer(playerid, timetd);
	return 1;
}
CMD:saveloot(playerid)
{
	if( gPlayerData[ playerid ][ E_PLAYER_ADMIN_LEVEL ] < 4) return SendErrorMessage( playerid, "You do not have permission to use this command." );
	if(Iter_Count(PUBGIterator) == MAX_LOOT) return SendErrorMessage(playerid, "Maximum number of loot is already set.");
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

	new query[ 256 ];
	mysql_format( _dbConnector, query, sizeof( query ), "INSERT INTO `pubgpickups` ( x, y, z ) VALUES( '%f', '%f', '%f')", x, y, z );
	mysql_pquery( _dbConnector, query, "", "" );
	SendInfoMessage(playerid, "Loot point saved at your current position.");
	return 1;
}
CMD:reloadloot(playerid)
{
	if( gPlayerData[ playerid ][ E_PLAYER_ADMIN_LEVEL ] < 4) return -1;
	ReloadPUBGLoot();
	SendInfoMessage(playerid, "You reloaded PUBG loot.");
	return 1;

}
forward ClosePUBG();
public ClosePUBG()
{
	PUBGOpen = false;
	PUBGLaunchTime = 0;
	PUBGLaunched = true;
	SetTimer("PLTimer", 1000, 0);
	foreach(new i:PUBGEvent)
	{
	    GameTextForPlayer(i,"~r~Go!",3000,5);
	    PlayerPlaySound(i, 15805, 0,0,0);
	    ResetAllWeapons(i);
	    SetPlayerArmour(i, 0.0);
		GiveWeaponToPlayer(i, 46,1);
	    new Float:xx = frandom(50.0, -50.0, 2), Float:yy = frandom(50.0, -50.0, 2), Float:zz = frandom(15.0, -15.0, 2);
	    switch(PUBGMap)
		{
			case 1: KGEyes_SetPlayerPos(i, -2259.0444+xx, 568.2881+yy, 779.9348+zz);
			case 2: KGEyes_SetPlayerPos(i, -149.3887+xx,1925.7269+yy,779.9348+zz);
			case 3: KGEyes_SetPlayerPos(i, 2104.7358+xx,1785.3613+yy,779.9348+zz);
			case 4: KGEyes_SetPlayerPos(i, 848.6768+xx,-215.2424+yy,779.9348+zz);
		}
	    SetPlayerInterior(i, 0);
		ApplyAnimation(i,"PARACHUTE","FALL_skyDive",0.0,0,0,0,0,0);
	}
	return 1;
}
CMD:pubgers(playerid, params[])
{
	strdel( DialogStrgEx, 0, sizeof( DialogStrgEx ) );
	new count = 0;
	foreach(new i : Player)
	{
		if(inPUBG[i] == 1)
		{
			format( globalstring, sizeof( globalstring ), "%s\n", PlayerName(i) );
			strcat( DialogStrgEx, globalstring );
			count++;
		}
	}
	if(count == 0) return SendErrorMessage(playerid, "There's no one in pubg event.");
	ShowPlayerDialog( playerid, 0, DSL, "PUBG players", DialogStrgEx, "Close", "" );
	strdel( DialogStrgEx, 0, sizeof( DialogStrgEx ) );
	return 1;
}
