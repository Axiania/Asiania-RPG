/*
	SA-MP FloodControl Include
	Copyright © 2012 RyDeR`, JernejL
*/

#if !defined MAX_JOIN_LOGS
	#define MAX_JOIN_LOGS (30)
#endif

#if !defined MAX_THRESHOLD
	#define MAX_THRESHOLD (8000) // The amount of time in which all joins are valid and counted
#endif

enum e_JoinLog {
	e_iIP,
	e_iTimeStamp
};

static stock
	g_eaJoinLog[MAX_JOIN_LOGS][e_JoinLog]
;

public OnPlayerConnect(playerid) {
	static
		s_iJoinSeq,
		s_szIP[16]
	;
	GetPlayerIp(playerid, s_szIP, sizeof(s_szIP));
	
	g_eaJoinLog[s_iJoinSeq][e_iIP] = s_szIP[0] = IpToInt(s_szIP);
	g_eaJoinLog[s_iJoinSeq][e_iTimeStamp] = GetTickCount();
	
	s_iJoinSeq = ++s_iJoinSeq % MAX_JOIN_LOGS;
	
	s_szIP[1] = s_szIP[2] = 0;
	
	for(new i = 0; i < (MAX_JOIN_LOGS - 1); ++i) {
		if(g_eaJoinLog[i][e_iIP] != s_szIP[0]) {
			continue;
		}
		s_szIP[3] = GetTickCount();

		if(floatround(floatabs(s_szIP[3] - g_eaJoinLog[i][e_iTimeStamp])) < MAX_THRESHOLD) {
			if(floatround(floatabs(s_szIP[3] - g_eaJoinLog[i + 1][e_iTimeStamp])) < MAX_THRESHOLD) {
				s_szIP[2] += floatround(floatabs(g_eaJoinLog[i][e_iTimeStamp] - g_eaJoinLog[i + 1][e_iTimeStamp]));
				s_szIP[1] += 1;
			}
		}
	}
	// Eventually initialize and call if exists
	static
		bool: s_bInit,
		
		s_iHasOPFC = -1,
		s_iHasOPC = -1
	;
	if(!s_bInit) {
		s_iHasOPFC = funcidx("OnPlayerFloodControl");
		s_iHasOPC = funcidx("FC_OnPlayerConnect");

		s_bInit = !s_bInit;
	}
	if(s_bInit) {
		if(s_iHasOPFC != -1) {
			CallRemoteFunction("OnPlayerFloodControl", "iii", playerid, s_szIP[1], s_szIP[2]);
		}
		if(s_iHasOPC != -1) {
			return CallLocalFunction("FC_OnPlayerConnect", "i", playerid);
		}
	}
	return 1;
}

#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect FC_OnPlayerConnect

static stock IpToInt(const s_szIP[]) {
	new
		aiBytes[1],
		iPos = 0
	;
	aiBytes{0} = strval(s_szIP[iPos]);
	while(iPos < 15 && s_szIP[iPos++] != '.') {}
	aiBytes{1} = strval(s_szIP[iPos]);
	while(iPos < 15 && s_szIP[iPos++] != '.') {}
	aiBytes{2} = strval(s_szIP[iPos]);
	while(iPos < 15 && s_szIP[iPos++] != '.') {}
	aiBytes{3} = strval(s_szIP[iPos]);
	
	return aiBytes[0];
}

forward OnPlayerConnect(playerid);
forward OnPlayerFloodControl(playerid, iCount, iTimeSpan);