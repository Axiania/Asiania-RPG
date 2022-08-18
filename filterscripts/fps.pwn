#define FILTERSCRIPT
#include <a_samp>
#include <Pawn.CMD>
#include <callbacks>
#include <sscanf2>
CMD:fps(playerid, params[])
{
	new target;
	if(sscanf(params,"u",target)) return SendClientMessage(playerid, 0x28DEF7AA, "Correct usage: /fps [ID]");
 	if(!IsPlayerConnected(target)) return SendClientMessage(playerid, 0xE77685AA, "There is no player with this id.");
 	new name[24];
 	GetPlayerName(target, name, 24);
 	new szString[128];
 	format(szString, sizeof(szString), "%s >> FPS: %d >> Packetloss: %.2f", name, GetPlayerFPS(target), NetStats_PacketLossPercent(target));
    SendClientMessage(playerid, 0x28DEF7AA, szString);
	return 1;
}
