//Mobile include by Jekmant

/*
    ATTENTION! Include require "Pawn.RakNet" plugin version "1.4.1" or higher!

    Functions:
    bool:IsPlayerMobile(playerid) - check player platform type. Returns "true" if founded mobile platform
    bool:IsPlayerHaveAutoaim(playerid) - check player autoaiming. Returns "true" if autoaming enabled
*/

#if defined _mobile_included
	#endinput
#endif
#define _mobile_included

#tryinclude <a_samp>
#include <Pawn.RakNet>

#define MIN_PACKET_SIZE     3
#define MOBILE_AUTH_KEY     "ED40ED0E8089CC44C08EE9580F4C8C44EE8EE990"
const ID_CUSTOM_SYNC = 221;
const RPC_INIT_MOBILE = 0x10;

enum pMobileInfo
{
    bool:isMobile,
    bool:isHaveAutoaim
}
new PlayerMobileInfo[MAX_PLAYERS][pMobileInfo];

public OnPlayerConnect(playerid)
{
    new gpciStr[64];
	gpci(playerid, gpciStr, sizeof(gpciStr));
    if(!strcmp(gpciStr, MOBILE_AUTH_KEY)) // system for older version, will be deprecated
		PlayerMobileInfo[playerid][isMobile] = true;
	else
		PlayerMobileInfo[playerid][isMobile] = false;

    #if defined mob_OnPlayerConnect
		return mob_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect mob_OnPlayerConnect
#if defined mob_OnPlayerConnect
	forward mob_OnPlayerConnect(playerid);
#endif

public OnPlayerDisconnect(playerid, reason)
{
    PlayerMobileInfo[playerid][isMobile] = false;
    PlayerMobileInfo[playerid][isHaveAutoaim] = false;

    #if defined mob_OnPlayerDisconnect
		return mob_OnPlayerDisconnect(playerid, reason);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect mob_OnPlayerDisconnect
#if defined mob_OnPlayerDisconnect
	forward mob_OnPlayerDisconnect(playerid, reason);
#endif

IRawPacket:ID_CUSTOM_SYNC(playerid, BitStream:bs)
{
	new bytes, rpcid;
	BS_GetNumberOfBytesUsed(bs, bytes);
	if(bytes < MIN_PACKET_SIZE) return 0;

	BS_ReadValue(bs, 
		PR_IGNORE_BITS, 8,
		PR_UINT8, rpcid);

	if(rpcid == RPC_INIT_MOBILE)
	{
		new autoaim;
		BS_ReadValue(bs, PR_UINT8, autoaim);

        PlayerMobileInfo[playerid][isMobile] = true; // system for newer version
		PlayerMobileInfo[playerid][isHaveAutoaim] = bool:autoaim;
	}
	return 1;
}

stock bool:IsPlayerMobile(playerid)
{
    return PlayerMobileInfo[playerid][isMobile];
}

stock bool:IsPlayerHaveAutoaim(playerid)
{
    return PlayerMobileInfo[playerid][isHaveAutoaim];
}