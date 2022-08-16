#include <YSI\y_hooks>

hook OnGameModeInit()
{
	return 1;
}

hook OnGameModeExit()
{
	return 1;
}

hook OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

hook OnPlayerConnect(playerid)
{
	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

hook OnPlayerSpawn(playerid)
{
	return 1;
}

hook OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

hook OnVehicleSpawn(vehicleid)
{
	return 1;
}

hook OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

hook OnPlayerText(playerid, text[])
{
	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

hook OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

hook OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

hook OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

hook OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

hook OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

hook OnRconCommand(cmd[])
{
	return 1;
}

hook OnPlayerRequestSpawn(playerid)
{
	return 1;
}

hook OnObjectMoved(objectid)
{
	return 1;
}

hook OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

hook OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

hook OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

hook OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

hook OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

hook OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

hook OnPlayerExitedMenu(playerid)
{
	return 1;
}

hook OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

hook OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

hook OnPlayerUpdate(playerid)
{
	return 1;
}

hook OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

hook OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

hook OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

hook OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

hook OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
