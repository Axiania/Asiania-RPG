
forward MyHttpResponse(playerid, response_code, data[]);
hook OnPlayerConnect(playerid)
{
	new ip[16], string[256];
	GetPlayerIp(playerid, ip, sizeof ip);
	format(string, sizeof string, "www.ip-api.com/json/%s?fields=proxy,hosting", ip);
	HTTP(playerid, HTTP_GET, string, "", "MyHttpResponse");
    return 1;
}
public MyHttpResponse(playerid, response_code, data[])
{
	new ip[16];
	GetPlayerIp(playerid, ip, sizeof ip);
	if(strcmp(ip, "127.0.0.1", true) == 0)
	{
//		format(string, 256, "[LOCALHOST] %s(%d) has joined the server.", name, playerid);
//	    SendClientMessageToAll( 0x09F7DFC8, string);
        return 1;
    }
    if(strfind(data, "true", true) != -1)
    {
		new query2[156];
		mysql_format( _dbConnector, query2, sizeof(query2), "SELECT * FROM `vpnlist` WHERE `p_name` = '%e' LIMIT 1", PlayerName(playerid) );
		mysql_tquery( _dbConnector, query2, "CheckVPN", "i", playerid );
   	    return 1;
	}
	return 1;
}
forward CheckVPN( playerid );
public CheckVPN( playerid ) {

	new rows, fields;
	cache_get_data( rows, fields, _dbConnector );

	if( !rows ) {
		if(ServerInfo[ VpnKick ] == 1)
		{
			SendClientMessage( playerid, REDCOLOR, "You have been kicked for using a VPN.");
			SendClientMessage(playerid, REDCOLOR, "You can get yourself added to VPN list at https://discord.gg/GSk4uKwjxG" );
			SendClientMessage(playerid, REDCOLOR, "You can copy the given discord link from chatlogs folder in your documents directory." );
			SetTimerEx( "KickIgraca", 150, false, "d", playerid );
			new adstring[256];
		    format(adstring, sizeof(adstring), "{FF0000}[VPN] {E4CA78}%s (%d) has been kicked for using a VPN.", PlayerName(playerid), playerid);
		    AdminMessage(-1, adstring);
			return 1;
		}
	}
	return (true);
}