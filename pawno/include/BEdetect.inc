/*
¦¯¯_ ¦¦¦¦   ¦¦¦ ¦¯¯¦ ¦¯¯_ ¦¯¯¦ ¦¯¯¦ ¦¯¯¦ ¦¯¯_ ¦¯¯¦ ¦¯_¯¦ 
¦¯¯_ ¦__¦   ¦¯_ ¦__¦ ¦¦¦¦ ¦__¦ ¦__¯ ¦__¦ ¦¦¦¦ ¦__¦ ¦¦¯¦¦ 
¯¯¯¦ ___¦   ¯¦¯ ¯¦¦¯ ¯¯¯¦ ¯¦¦¯ ¯¦¯¯ ¯¦¦¯ ¯¯¯¦ ¯¦¦¯ ¯¦¦¦¯ 

*/
forward OnBlueEclipseDetected(playerid);

BlueEclipseCheck(playerid) 
{
	SetTimerEx("be_HackCheck", 2000, false, "i", playerid);
	TogglePlayerControllable(playerid, false);
	
	return 1;
}

forward be_HackCheck(playerid);
public be_HackCheck(playerid)
{
	if( GetPlayerCameraMode(playerid) == 7 )
	{
		CallLocalFunction("OnBlueEclipseDetected", "i", playerid);
	}
	
	TogglePlayerControllable(playerid, true);
}