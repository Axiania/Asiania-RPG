#include <a_samp>

/*
													FONCTION :
	native CreateVehicleEx(model, Float:x, Float:y, Float:z, Float:rot, color1, color2, respawn_delay, addsirene = 0, plate[] = "",virtualworld = -1, lock = 0);
	native GenerateNumberPlate(plate[], size, dest[]);
	native GetVehicleCarDoor(vehicleid, door);
	native SetVehicleCarDoor(vehicleid, door, bool:status);
	native GetVehicleCarWindows(vehicleid, win);
	native SetVehicleCarWindows(vehicleid, door, bool:status);
	
													CALLBACK :
	public OnVehicleUpdate(vehicleid)
	public OnVehicleCreated(vehicleid)
	public UpdateVehicleCarDoors(vehicleid, door, status)
	public UpdateVehicleCarWindows(vehicleid, win, status)
*/

enum {
	VEH_DRIVER = 1,
	VEH_PASSENGERS,
	VEH_BACK_LEFT,
	VEH_BACK_RIGHT,
	VEH_UP,
	VEH_DOWN,
	VEH_ALL
}
new
	VS_VEH_TIMER[MAX_VEHICLES];
#if defined OnVehicleUpdate
	stock InitVehicleUpdate(vehicleid)
	{
		VS_VEH_TIMER[vehicleid] = SetTimerEx("OnVehicleUpdate", 50, true, "i", vehicleid);
		return VS_VEH_TIMER[vehicleid];
	}
#endif
	
stock CreateVehicleEx(model, Float:x, Float:y, Float:z, Float:rot, color1, color2, respawn_delay, addsirene = 0, plate[] = "",virtualworld = -1, lock = 0)
{
	new
		vehicleid = CreateVehicle(model, x, y, z, rot, color1, color2, respawn_delay, addsirene);
	SetVehicleVirtualWorld(vehicleid, virtualworld);
	
	if(lock != 0)
		SetVehicleCarDoor(vehicleid, lock, 0);
		
	if(strlen(plate) != 0) {SetVehicleNumberPlate(vehicleid, plate); SetVehicleToRespawn(vehicleid);}
		
	#if defined OnVehicleCreated	
		OnVehicleCreated(vehicleid);
	#endif
	return vehicleid;
}
stock GenerateNumberPlate(plate[], size, dest[])
{
	for(new i, rand, str[2];i < size;i++)
	{
		if(plate[i] == 'i')
		{
			rand = random(10);
			valstr(str, rand);
			dest[i] = str[0];
		}
		else if(plate[i] == 's')
		{
			rand = random(26);
			
			switch(rand)
			{
				case 0: str[0] = 'A';
				case 1: str[0] = 'B';
				case 2: str[0] = 'C';
				case 3: str[0] = 'D';
				case 4: str[0] = 'E';
				case 5: str[0] = 'F';
				case 6: str[0] = 'G';
				case 7: str[0] = 'H';
				case 8: str[0] = 'I';
				case 9: str[0] = 'J';
				case 10: str[0] = 'K';
				case 11: str[0] = 'L';
				case 12: str[0] = 'M';
				case 13: str[0] = 'N';
				case 14: str[0] = 'O';
				case 15: str[0] = 'P';
				case 16: str[0] = 'Q';
				case 17: str[0] = 'R';
				case 18: str[0] = 'S';
				case 19: str[0] = 'T';
				case 20: str[0] = 'U';
				case 21: str[0] = 'V';
				case 22: str[0] = 'W';
				case 23: str[0] = 'X';
				case 24: str[0] = 'Y';
				case 25: str[0] = 'Z';
			}
			dest[i] = str[0];
		}
		else
		{
			dest[i] = plate[i];
		}
	}
	
	return 0;
}
stock GetVehicleCarDoor(vehicleid, door)
{
	new
		status[4];
		
	GetVehicleParamsCarDoors(vehicleid, status[0], status[1], status[2], status[3]);
	
	switch(door)
	{
		case VEH_DRIVER: return status[0];
		case VEH_PASSENGERS: return status[1];
		case VEH_BACK_LEFT: return status[2];
		case VEH_BACK_RIGHT: return status[3];
		default: return print("Impossible d'éfféctuer cette action.");
	}
	return 0;
}
stock SetVehicleCarDoor(vehicleid, door, bool:status)
{
	new
		nextstate[4];
	
	GetVehicleParamsCarDoors(vehicleid, nextstate[0], nextstate[1], nextstate[2], nextstate[3]);
	
	switch(door)
	{
		case VEH_DRIVER: SetVehicleParamsCarDoors(vehicleid, status, nextstate[1], nextstate[2], nextstate[3]);
		case VEH_PASSENGERS: SetVehicleParamsCarDoors(vehicleid, nextstate[0], status, nextstate[2], nextstate[3]);
		case VEH_BACK_LEFT: SetVehicleParamsCarDoors(vehicleid, nextstate[0], nextstate[1], status, nextstate[3]);
		case VEH_BACK_RIGHT: SetVehicleParamsCarDoors(vehicleid, nextstate[0], nextstate[1], nextstate[2], status);
		case VEH_UP: SetVehicleParamsCarDoors(vehicleid, status, status, nextstate[2], nextstate[3]);
		case VEH_DOWN: SetVehicleParamsCarDoors(vehicleid, nextstate[0], nextstate[1], status, status);
		case VEH_ALL: SetVehicleParamsCarDoors(vehicleid, status, status, status, status);
		default: print("Impossible d'éfectuer cette action.");
	}
	
	#if defined UpdateVehicleCarDoors
		UpdateVehicleCarDoors(vehicleid, door, status);
	#endif
	
	return 0;
}
stock GetVehicleCarWindows(vehicleid, win)
{
	new
		status[4];
		
	GetVehicleParamsCarWindows(vehicleid, status[0], status[1], status[2], status[3]);
	
	switch(win)
	{
		case VEH_DRIVER: return status[0];
		case VEH_PASSENGERS: return status[1];
		case VEH_BACK_LEFT: return status[2];
		case VEH_BACK_RIGHT: return status[3];
		default: return print("Impossible d'éfféctuer cette action.");
	}
	return 0;
}
stock SetVehicleCarWindows(vehicleid, win, bool:status)
{
	new
		nextstate[4];
	
	GetVehicleParamsCarWindows(vehicleid, nextstate[0], nextstate[1], nextstate[2], nextstate[3]);
	
	switch(win)
	{
		case VEH_DRIVER: SetVehicleParamsCarWindows(vehicleid, status, nextstate[1], nextstate[2], nextstate[3]);
		case VEH_PASSENGERS: SetVehicleParamsCarWindows(vehicleid, nextstate[0], status, nextstate[2], nextstate[3]);
		case VEH_BACK_LEFT: SetVehicleParamsCarWindows(vehicleid, nextstate[0], nextstate[1], status, nextstate[3]);
		case VEH_BACK_RIGHT: SetVehicleParamsCarWindows(vehicleid, nextstate[0], nextstate[1], nextstate[2], status);
		case VEH_UP: SetVehicleParamsCarWindows(vehicleid, status, status, nextstate[2], nextstate[3]);
		case VEH_DOWN: SetVehicleParamsCarWindows(vehicleid, nextstate[0], nextstate[1], status, status);
		case VEH_ALL: SetVehicleParamsCarWindows(vehicleid, status, status, status, status);
		default: print("Impossible d'éfectuer cette action.");
	}
	
	#if defined UpdateVehicleCarWindows
		UpdateVehicleCarWindows(vehicleid, win, status);
	#endif
	
	return 0;
}
#if defined OnVehicleCreated
	forward OnVehicleCreated(vehicleid);
#endif
#if defined UpdateVehicleCarDoors
	forward UpdateVehicleCarDoors(vehicleid, door, status);
#endif
#if defined OnVehicleUpdate
	forward OnVehicleUpdate(vehicleid);
#endif
#if defined UpdateVehicleCarWindows
	forward UpdateVehicleCarWindows(vehicleid, win, status);
#endif 