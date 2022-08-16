#include <a_samp>

#if defined _setgravity_included
  #endinput
#endif
#define _setgravity_included

static bool:moving[MAX_PLAYERS char];
static falltime[MAX_PLAYERS];
static Float:velZ[MAX_PLAYERS];
static Float:gravity[MAX_PLAYERS];
static bool:setgravity[MAX_PLAYERS char];

gravitacijaOPC(playerid)
{
    moving{playerid} = false;
    velZ{playerid} = 0.0;
    gravity[playerid] = 0.0;
    setgravity{playerid} = false;
}

gravitacijaUpdate(playerid)
{
    if(setgravity{playerid} && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
    {
        new Float:x, Float:y, Float:z;
        GetPlayerVelocity(playerid, x, y, z);
        new anim = GetPlayerAnimationIndex(playerid);
        if(anim == 1130 || anim == 1132 || anim == 1195)
        {
            if(!moving{playerid} || z == 0.0)
            {
                velZ[playerid] = z;
                moving{playerid} = true;
                falltime[playerid] = GetTickCount();
            }
            new time = GetTickCount()-falltime[playerid];
            z = (gravity[playerid]*time)/1000.0;
            if(z > 1.17) z = 1.17;
            SetPlayerVelocity(playerid, x, y, velZ[playerid]-z);
        }else{
            moving{playerid} = false;
        }
    }
}

stock SetPlayerGravity(playerid, Float:newgravity)
{
    setgravity{playerid} = true;
    gravity[playerid] = newgravity*50.0;
    moving{playerid} = false;
}

stock ResetPlayerGravity(playerid)
{
    setgravity{playerid} = false;
    gravity[playerid] = 0.0;
    moving{playerid} = false;
}
