#include <a_samp>

#define KORREKTUR_VEK 0
#define SHOT_MS 200

#if defined Holding
#else
	    #define Holding(%0) \
		((newkeys & (%0)) == (%0))
#endif

#if defined PRESSED
#else
	#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#endif

forward OnEmptyVehicleDamage(vehicleid,playerid,exems);

new playerblock[MAX_PLAYERS];
new playershottick[MAX_PLAYERS];

stock GetVehicleSize(modelID, &Float: size_X, &Float: size_Y, &Float: size_Z)
{
	static const
		Float: sizeData[212][3] =
		{
			{ 2.32, 5.11, 1.63 }, { 2.56, 5.82, 1.71 }, { 2.41, 5.80, 1.52 }, { 3.15, 9.22, 4.17 },
			{ 2.20, 5.80, 1.84 }, { 2.34, 6.00, 1.49 }, { 5.26, 11.59, 4.42 }, { 2.84, 8.96, 2.70 },
			{ 3.11, 10.68, 3.91 }, { 2.36, 8.18, 1.52 }, { 2.25, 5.01, 1.79 }, { 2.39, 5.78, 1.37 },
			{ 2.45, 7.30, 1.38 }, { 2.27, 5.88, 2.23 }, { 2.51, 7.07, 4.59 }, { 2.31, 5.51, 1.13 },
			{ 2.73, 8.01, 3.40 }, { 5.44, 23.27, 6.61 }, { 2.56, 5.67, 2.14 }, { 2.40, 6.21, 1.40 },
			{ 2.41, 5.90, 1.76 }, { 2.25, 6.38, 1.37 }, { 2.26, 5.38, 1.54 }, { 2.31, 4.84, 4.90 },
			{ 2.46, 3.85, 1.77 }, { 5.15, 18.62, 5.19 }, { 2.41, 5.90, 1.76 }, { 2.64, 8.19, 3.23 },
			{ 2.73, 6.28, 3.48 }, { 2.21, 5.17, 1.27 }, { 4.76, 16.89, 5.92 }, { 3.00, 12.21, 4.42 },
			{ 4.30, 9.17, 3.88 }, { 3.40, 10.00, 4.86 }, { 2.28, 4.57, 1.72 }, { 3.16, 13.52, 4.76 },
			{ 2.27, 5.51, 1.72 }, { 3.03, 11.76, 4.01 }, { 2.41, 5.82, 1.72 }, { 2.22, 5.28, 1.47 },
			{ 2.30, 5.55, 2.75 }, { 0.87, 1.40, 1.01 }, { 2.60, 6.67, 1.75 }, { 4.15, 20.04, 4.42 },
			{ 3.66, 6.01, 3.28 }, { 2.29, 5.86, 1.75 }, { 4.76, 17.02, 4.30 }, { 2.42, 14.80, 3.15 },
			{ 0.70, 2.19, 1.62 }, { 3.02, 9.02, 4.98 }, { 3.06, 13.51, 3.72 }, { 2.31, 5.46, 1.22 },
			{ 3.60, 14.56, 3.28 }, { 5.13, 13.77, 9.28 }, { 6.61, 19.04, 13.84 }, { 3.31, 9.69, 3.63 },
			{ 3.23, 9.52, 4.98 }, { 1.83, 2.60, 2.72 }, { 2.41, 6.13, 1.47 }, { 2.29, 5.71, 2.23 },
			{ 10.85, 13.55, 4.44 }, { 0.69, 2.46, 1.67 }, { 0.70, 2.19, 1.62 }, { 0.69, 2.42, 1.34 },
			{ 1.58, 1.54, 1.14 }, { 0.87, 1.40, 1.01 }, { 2.52, 6.17, 1.64 }, { 2.52, 6.36, 1.66 },
			{ 0.70, 2.23, 1.41 }, { 2.42, 14.80, 3.15 }, { 2.66, 5.48, 2.09 }, { 1.41, 2.00, 1.71 },
			{ 2.67, 9.34, 4.86 }, { 2.90, 5.40, 2.22 }, { 2.43, 6.03, 1.69 }, { 2.45, 5.78, 1.48 },
			{ 11.02, 11.28, 3.28 }, { 2.67, 5.92, 1.39 }, { 2.45, 5.57, 1.74 }, { 2.25, 6.15, 1.99 },
			{ 2.26, 5.26, 1.41 }, { 0.70, 1.87, 1.32 }, { 2.33, 5.69, 1.87 }, { 2.04, 6.19, 2.10 },
			{ 5.34, 26.20, 7.15 }, { 1.97, 4.07, 1.44 }, { 4.34, 7.84, 4.44 }, { 2.32, 15.03, 4.67 },
			{ 2.32, 12.60, 4.65 }, { 2.53, 5.69, 2.14 }, { 2.92, 6.92, 2.14 }, { 2.30, 6.32, 1.28 },
			{ 2.34, 6.17, 1.78 }, { 4.76, 17.82, 3.84 }, { 2.25, 6.48, 1.50 }, { 2.77, 5.44, 1.99 },
			{ 2.27, 4.75, 1.78 }, { 2.32, 15.03, 4.65 }, { 2.90, 6.59, 4.28 }, { 2.64, 7.19, 3.75 },
			{ 2.28, 5.01, 1.85 }, { 0.87, 1.40, 1.01 }, { 2.34, 5.96, 1.51 }, { 2.21, 6.13, 1.62 },
			{ 2.52, 6.03, 1.64 }, { 2.53, 5.69, 2.14 }, { 2.25, 5.21, 1.16 }, { 2.56, 6.59, 1.62 },
			{ 2.96, 8.05, 3.33 }, { 0.70, 1.89, 1.32 }, { 0.72, 1.74, 1.12 }, { 21.21, 21.19, 5.05 },
			{ 11.15, 6.15, 2.99 }, { 8.69, 9.00, 2.23 }, { 3.19, 10.06, 3.05 }, { 3.54, 9.94, 3.42 },
			{ 2.59, 6.23, 1.71 }, { 2.52, 6.32, 1.64 }, { 2.43, 6.00, 1.57 }, { 20.30, 19.29, 6.94 },
			{ 8.75, 14.31, 2.16 }, { 0.69, 2.46, 1.67 }, { 0.69, 2.46, 1.67 }, { 0.69, 2.47, 1.67 },
			{ 3.58, 8.84, 3.64 }, { 3.04, 6.46, 3.28 }, { 2.20, 5.40, 1.25 }, { 2.43, 5.71, 1.74 },
			{ 2.54, 5.55, 2.14 }, { 2.38, 5.63, 1.86 }, { 1.58, 4.23, 2.68 }, { 1.96, 3.70, 1.66 },
			{ 8.61, 11.39, 4.17 }, { 2.38, 5.42, 1.49 }, { 2.18, 6.26, 1.15 }, { 2.67, 5.48, 1.58 },
			{ 2.46, 6.42, 1.29 }, { 3.32, 18.43, 5.19 }, { 3.26, 16.59, 4.94 }, { 2.50, 3.86, 2.55 },
			{ 2.58, 6.07, 1.50 }, { 2.26, 4.94, 1.24 }, { 2.48, 6.40, 1.70 }, { 2.38, 5.73, 1.86 },
			{ 2.80, 12.85, 3.89 }, { 2.19, 4.80, 1.69 }, { 2.56, 5.86, 1.66 }, { 2.49, 5.84, 1.76 },
			{ 4.17, 24.42, 4.90 }, { 2.40, 5.53, 1.42 }, { 2.53, 5.88, 1.53 }, { 2.66, 6.71, 1.76 },
			{ 2.65, 6.71, 3.55 }, { 28.73, 23.48, 7.38 }, { 2.68, 6.17, 2.08 }, { 2.00, 5.13, 1.41 },
			{ 3.66, 6.36, 3.28 }, { 3.66, 6.26, 3.28 }, { 2.23, 5.25, 1.75 }, { 2.27, 5.48, 1.39 },
			{ 2.31, 5.40, 1.62 }, { 2.50, 5.80, 1.78 }, { 2.25, 5.30, 1.50 }, { 3.39, 18.62, 4.71 },
			{ 0.87, 1.40, 1.01 }, { 2.02, 4.82, 1.50 }, { 2.50, 6.46, 1.65 }, { 2.71, 6.63, 1.58 },
			{ 2.71, 4.61, 1.41 }, { 3.25, 18.43, 5.03 }, { 3.47, 21.06, 5.19 }, { 1.57, 2.32, 1.58 },
			{ 1.65, 2.34, 2.01 }, { 2.93, 7.38, 3.16 }, { 1.62, 3.84, 2.50 }, { 2.49, 5.82, 1.92 },
			{ 2.42, 6.36, 1.85 }, { 62.49, 61.43, 34.95 }, { 3.15, 11.78, 2.77 }, { 2.47, 6.21, 2.55 },
			{ 2.66, 5.76, 2.24 }, { 0.69, 2.46, 1.67 }, { 2.44, 7.21, 3.19 }, { 1.66, 3.66, 3.21 },
			{ 3.54, 15.90, 3.40 }, { 2.44, 6.53, 2.05 }, { 0.69, 2.79, 1.96 }, { 2.60, 5.76, 1.45 },
			{ 3.07, 8.61, 7.53 }, { 2.25, 5.09, 2.11 }, { 3.44, 18.39, 5.03 }, { 3.18, 13.63, 4.65 },
			{ 44.45, 57.56, 18.43 }, { 12.59, 13.55, 3.56 }, { 0.50, 0.92, 0.30 }, { 2.84, 13.47, 2.21 },
			{ 2.41, 5.90, 1.76 }, { 2.41, 5.90, 1.76 }, { 2.41, 5.78, 1.76 }, { 2.92, 6.15, 2.14 },
			{ 2.40, 6.05, 1.55 }, { 3.07, 6.96, 3.82 }, { 2.31, 5.53, 1.28 }, { 2.64, 6.07, 1.42 },
			{ 2.52, 6.17, 1.64 }, { 2.38, 5.73, 1.86 }, { 2.93, 3.38, 1.97 }, { 3.01, 3.25, 1.60 },
			{ 1.45, 4.65, 6.36 }, { 2.90, 6.59, 4.21 }, { 2.48, 1.42, 1.62 }, { 2.13, 3.16, 1.83 }
		}
	;
	if(400 <= modelID <= 611)
	{
		size_X = sizeData[modelID - 400][0];
		size_Y = sizeData[modelID - 400][1];
		size_Z = sizeData[modelID - 400][2];       
		return 1;
	}
	return 0;
}

stock GetPlayerLookingPos(playerid,Float:radius,&Float:x,&Float:y,&Float:z)
{
	if(IsPlayerConnected(playerid))
	{
		new
			Float:fPX, Float:fPY, Float:fPZ,
			Float:fVX, Float:fVY, Float:fVZ,
			Float:tmpz;

		GetPlayerPos(playerid, fPX, fPY, fPZ);
		GetPlayerCameraFrontVector(playerid, fVX, fVY, fVZ);
		
		if(GetPlayerSpecialAction(playerid) != 1) fPZ += 0.7;
		tmpz = fVZ*0.5;
		fVZ = tmpz;

		x = fPX + ((radius)*fVX);
		y = fPY + ((radius)*fVY);
		z = fPZ + ((radius)*fVZ);
	}
	return 1;
}

stock VehicleToPoint(Float:radi, vehicleid, Float:x, Float:y, Float:z)
{
	new Float:oldposx, Float:oldposy, Float:oldposz;
	new Float:tempposx, Float:tempposy, Float:tempposz;
	GetVehiclePos(vehicleid, oldposx, oldposy, oldposz);
	tempposx = (oldposx -x);
	tempposy = (oldposy -y);
	tempposz = (oldposz -z);
	if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
	{
		return 1;
	}
	return 0;
}

stock IsPlayerLookingAtVehicle(playerid,vehicleid)
{
	if(IsPlayerConnected(playerid) && GetVehicleModel(vehicleid))
	{
		new Float:SizeX,Float:SizeY,Float:SizeZ,Float:VehX,Float:VehY,Float:VehZ,Float:PlyDis,Float:PlyX,Float:PlyY,Float:PlyZ;
		GetVehiclePos(vehicleid,VehX,VehY,VehZ);
		PlyDis = GetPlayerDistanceFromPoint(playerid,VehX,VehY,VehZ);
		GetPlayerLookingPos(playerid,PlyDis,PlyX,PlyY,PlyZ);
		GetVehicleSize(GetVehicleModel(vehicleid),SizeX,SizeY,SizeZ);
		if(VehicleToPoint(SizeY,vehicleid,PlyX,PlyY,PlyZ))
		{
			return 1;
		}
	}
	return 0;
}

public OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z)
{
	new testtick = GetTickCount();
	CallLocalFunction("VB_OnUnoccupiedVehicleUpdate", "iiiffffff", vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z);
	if(GetPlayerWeapon(playerid) == 5)
	{
		new newkeys,plylr,plyup;
		GetPlayerKeys(playerid,newkeys,plyup,plylr);
		if(Holding(KEY_FIRE) || (GetTickCount()-playershottick[playerid]) <= SHOT_MS)
		{
			if(GetPlayerWeapon(playerid) == 5)
			{
				new Float:SizeX,Float:SizeY,Float:SizeZ,Float:VehX,Float:VehY,Float:VehZ;
				GetVehicleSize(GetVehicleModel(vehicleid),SizeX,SizeY,SizeZ);
				GetVehiclePos(vehicleid,VehX,VehY,VehZ);
				if(IsPlayerInRangeOfPoint(playerid,SizeY,VehX,VehY,VehZ))
				{
					new animidx = GetPlayerAnimationIndex(playerid);
					if(	animidx == 17 || animidx == 18 || animidx == 19 )
					{	
						if(playerblock[playerid] == 0) playerblock[playerid] = 1;
						else return 1;
					}
					else
					{
						playerblock[playerid] = 0;
						return 1;
					}
				}
				else return 1;
			}
			CallRemoteFunction("OnEmptyVehicleDamage","iii",vehicleid,playerid,(GetTickCount()-testtick));
		}
		else if(playerblock[playerid] == 1) playerblock[playerid] = 0;
	}
	return 1;
}
forward VB_OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z);
#if defined _ALS_OnUnoccupiedVehicleUpdate
	#undef OnUnoccupiedVehicleUpdate
#else
	#define _ALS_OnUnoccupiedVehicleUpdate
#endif
#define OnUnoccupiedVehicleUpdate VB_OnUnoccupiedVehicleUpdate

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(PRESSED(KEY_FIRE)) playershottick[playerid] = GetTickCount();
	return CallLocalFunction("VB_OnPlayerKeyStateChange", "iii", playerid, newkeys, oldkeys);
}
forward VB_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange VB_OnPlayerKeyStateChange