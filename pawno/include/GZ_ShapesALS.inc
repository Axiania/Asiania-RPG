#if defined _gz_shapes_included
	#endinput
#endif
#define _gz_shapes_included


// ================================== [DEFINITIONS] ================================== //
#if !defined MAX_GZ_SHAPES
	#define MAX_GZ_SHAPES				10
#endif

#if !defined INVALID_GZ_SHAPE_ID
	#define INVALID_GZ_SHAPE_ID			-1
#endif

#if !defined MAP_SIZE_LIMIT
	#define MAP_SIZE_LIMIT				3000.0			// Useful for setting limits for the EMPTY_CIRCLE shape.
#endif


// ================================== [VARIABLES] ================================== //
static bool:gzs_gInit;
static bool:gzs_gExit;

enum GZ_SHAPE_TYPES
{
	CIRCLE,
	EMPTY_CIRCLE,
	CIRCUMFERENCE
}

enum gzs_data
{
	Float:gzs_x,
	Float:gzs_y,
	Float:gzs_radius,
	gzs_Elements[MAX_GANG_ZONES],
	bool:gzs_Exists
}
static gzs_gInfo[MAX_GZ_SHAPES][gzs_data];

static gzs_gGangZonesUsed;


// ================================== [HOOKED CALLBACKS] ================================== //
public OnFilterScriptInit()
{
    if(!gzs_gInit)
    {
    	gzs_gInit = true;
    	gzs_gGangZonesUsed = 0;

      	for(new x = 0; x < MAX_GZ_SHAPES; x++)
      	{
      		for(new y = 0; y < MAX_GANG_ZONES; y++)
      		{
      			gzs_gInfo[x][gzs_Elements][y] = INVALID_GANG_ZONE;
      		}
      	}
    }

    #if defined gzs_OnFilterScriptInit
         return gzs_OnFilterScriptInit();
    #else
   	 	return 1;
	#endif
}
#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit gzs_OnFilterScriptInit
#if defined gzs_OnFilterScriptInit
	forward gzs_OnFilterScriptInit();
#endif

public OnFilterScriptExit()
{
    if(!gzs_gExit)
    {
    	gzs_gExit = true;
    	GZ_ShapeDestroyAll();
    }

    #if defined gzs_OnFilterScriptExit
         return gzs_OnFilterScriptExit();
    #else
   	 	return 1;
	#endif
}
#if defined _ALS_OnFilterScriptExit
	#undef OnFilterScriptExit
#else
	#define _ALS_OnFilterScriptExit
#endif
#define OnFilterScriptExit gzs_OnFilterScriptExit
#if defined gzs_OnFilterScriptExit
	forward gzs_OnFilterScriptExit();
#endif

public OnGameModeInit()
{
 	if(!gzs_gInit)
    {
    	gzs_gInit = true;
    	gzs_gGangZonesUsed = 0;

      	for(new x = 0; x < MAX_GZ_SHAPES; x++)
      	{
      		for(new y = 0; y < MAX_GANG_ZONES; y++)
      		{
      			gzs_gInfo[x][gzs_Elements][y] = INVALID_GANG_ZONE;
      		}
      	}
    }
    #if defined gzs_OnGameModeInit
         return gzs_OnGameModeInit();
    #else
   	 	return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit gzs_OnGameModeInit
#if defined gzs_OnGameModeInit
	forward gzs_OnGameModeInit();
#endif

public OnGameModeExit()
{
 	if(!gzs_gExit)
    {
    	gzs_gExit = true;
    	GZ_ShapeDestroyAll();
    }

    #if defined gzs_OnGameModeExit
         return gzs_OnGameModeExit();
    #else
   	 	return 1;
	#endif
}
#if defined _ALS_OnGameModeExit
	#undef OnGameModeExit
#else
	#define _ALS_OnGameModeExit
#endif
#define OnGameModeExit gzs_OnGameModeExit
#if defined gzs_OnGameModeExit
	forward gzs_OnGameModeExit();
#endif


// ================================== [NEW FUNCTIONS] ================================== //
stock GZ_ShapeCreate(GZ_SHAPE_TYPES:type, Float:x, Float:y, Float:radius, squares = -1, Float:square_size = 5.0, Float:min_ang = 0.0, Float:max_ang = 360.0)
{
	for(new i = 0; i < MAX_GZ_SHAPES; i++)
	{
		if(gzs_gInfo[i][gzs_Exists])
		{
			continue;
		}

		new auto_squares = floatround((radius * 512.0)/750.0);
		new free_squares = MAX_GANG_ZONES - gzs_gGangZonesUsed;

		if(squares == -1) // Assign the number of gangzones (squares) automatically.
		{
			if(auto_squares <= free_squares)
			{
				squares = auto_squares;
			}
			else
			{
				squares = free_squares;
			}
		}
		else
		{
			if(squares > free_squares)
			{
				squares = free_squares;
			}
		}

		
		if(squares <= 1) // If there is only one gangzone or none available, creating the shape isn't worth.
		{
			printf("** [GZ Shapes] The shape couldn't be created, there aren't enough free gang zones.");
			break;
		}

		new Float:temp_x;
		new Float:next_x;
		new Float:temp_y;
		new Float:temp_diff;
		new Float:next_diff;
		new Float:diff = (max_ang - min_ang) / float(squares);

		switch(type)
		{
			case CIRCLE:
			{
				for(new j = 0; j < squares; j++)
				{
					temp_diff = min_ang + (diff * float(j));

					temp_x = radius * floatcos(temp_diff, degrees);
					temp_y = radius * floatsin(temp_diff, degrees);

					next_x = radius * floatcos((min_ang + (diff * float(j + 1))), degrees);

					if(0.0 <= temp_diff <= 180.0)
					{
						gzs_gInfo[i][gzs_Elements][j] =  GangZoneCreate((x + next_x), y, (x + temp_x), (y + temp_y));
					}
					else
					{
						gzs_gInfo[i][gzs_Elements][j] =  GangZoneCreate((x + temp_x), (y + temp_y), (x + next_x), y);
					}
				}
			}
			case EMPTY_CIRCLE:
			{
				new bool:second_quadrant = false;

				for(new j = 0; j < squares; j++)
				{
					temp_diff = diff * float(j);
					next_diff = diff * float(j + 1);

					temp_x = radius * floatcos(temp_diff, degrees);
					temp_y = radius * floatsin(temp_diff, degrees);

					next_x = radius * floatcos(diff * float(j + 1), degrees);

					if(0.0 <= temp_diff <= 90.0)
					{
						if(j == 0)
						{
							temp_y = 0.0;
							temp_x = (MAP_SIZE_LIMIT - x);
						}

						gzs_gInfo[i][gzs_Elements][j] =  GangZoneCreate((x + next_x), (y + temp_y), (x + temp_x), MAP_SIZE_LIMIT);
					}
					else if(90.0 < temp_diff < 180.0)
					{
						if(next_diff >= 180.0)
						{
							next_x = - (MAP_SIZE_LIMIT + x);
							temp_y = 0.0;

							second_quadrant = true;
						}

						gzs_gInfo[i][gzs_Elements][j] =  GangZoneCreate((x + next_x), (y + temp_y), (x + temp_x), MAP_SIZE_LIMIT);
					}
					else if(180.0 <= temp_diff <= 270.0)
					{
						if(second_quadrant)
						{
							second_quadrant = false;

							temp_x = - (MAP_SIZE_LIMIT + x);
							temp_y = 0.0;

						}

						gzs_gInfo[i][gzs_Elements][j] =  GangZoneCreate((x + temp_x), -MAP_SIZE_LIMIT, (x + next_x), (y + temp_y));
					}
					else if(270 < temp_diff <= 360.0)
					{
						if((squares - j) <= 1)
						{
							next_x = (MAP_SIZE_LIMIT - x);
							temp_y = 0.0;
						}

						gzs_gInfo[i][gzs_Elements][j] =  GangZoneCreate((x + temp_x), -MAP_SIZE_LIMIT, (x + next_x), (y + temp_y));
					}
				}
			}
			case CIRCUMFERENCE:
			{
				for(new j = 0; j < squares; j++)
				{
					temp_diff = min_ang + (diff * float(j));

					temp_x = radius * floatcos(temp_diff, degrees);
					temp_y = radius * floatsin(temp_diff, degrees);

					gzs_gInfo[i][gzs_Elements][j] = GangZoneCreate((x + temp_x) - square_size, (y + temp_y) - square_size, (x + temp_x) + square_size, (y + temp_y) + square_size);
				}
			}
			default:
			{
				printf("** [GZ Shapes] The shape couldn't be created, the shape type isn't correct.");
				break;
			}
		}

		gzs_gGangZonesUsed += squares;
		gzs_gInfo[i][gzs_Exists] = true;

		return i;
	}
	return INVALID_GZ_SHAPE_ID;
}

stock GZ_ShapeDestroy(shapeid)
{
	if(0 <= shapeid < MAX_GZ_SHAPES)
	{
		if(gzs_gInfo[shapeid][gzs_Exists])
		{
			for(new y = 0; y < MAX_GANG_ZONES; y++)
			{
				if(gzs_gInfo[shapeid][gzs_Elements][y] == INVALID_GANG_ZONE)
				{
					continue;
				}

				gzs_gGangZonesUsed--;

				GangZoneDestroy(gzs_gInfo[shapeid][gzs_Elements][y]);
				gzs_gInfo[shapeid][gzs_Elements][y] = INVALID_GANG_ZONE;
			}

			gzs_gInfo[shapeid][gzs_Exists] = false;

			return 1;
		}
	}
	return 0;
}

stock GZ_ShapeShowForPlayer(playerid, shapeid, color)
{
	if(0 <= shapeid < MAX_GZ_SHAPES)
	{
		if(gzs_gInfo[shapeid][gzs_Exists])
		{
			for(new y = 0; y < MAX_GANG_ZONES; y++)
			{
				if(gzs_gInfo[shapeid][gzs_Elements][y] == INVALID_GANG_ZONE)
				{
					continue;
				}

				GangZoneShowForPlayer(playerid, gzs_gInfo[shapeid][gzs_Elements][y], color);
			}

			return 1;
		}
	}
	return 0;
}

stock GZ_ShapeShowForAll(shapeid, color)
{
	if(0 <= shapeid < MAX_GZ_SHAPES)
	{
		if(gzs_gInfo[shapeid][gzs_Exists])
		{
			for(new y = 0; y < MAX_GANG_ZONES; y++)
			{
				if(gzs_gInfo[shapeid][gzs_Elements][y] == INVALID_GANG_ZONE)
				{
					continue;
				}

				GangZoneShowForAll(gzs_gInfo[shapeid][gzs_Elements][y], color);
			}

			return 1;
		}
	}
	return 0;
}

stock GZ_ShapeHideForPlayer(playerid, shapeid)
{
	if(0 <= shapeid < MAX_GZ_SHAPES)
	{
		if(gzs_gInfo[shapeid][gzs_Exists])
		{
			for(new y = 0; y < MAX_GANG_ZONES; y++)
			{
				if(gzs_gInfo[shapeid][gzs_Elements][y] == INVALID_GANG_ZONE)
				{
					continue;
				}

				GangZoneHideForPlayer(playerid, gzs_gInfo[shapeid][gzs_Elements][y]);
			}

			return 1;
		}
	}
	return 0;
}

stock GZ_ShapeHideForAll(shapeid)
{
	if(0 <= shapeid < MAX_GZ_SHAPES)
	{
		if(gzs_gInfo[shapeid][gzs_Exists])
		{
			for(new y = 0; y < MAX_GANG_ZONES; y++)
			{
				if(gzs_gInfo[shapeid][gzs_Elements][y] == INVALID_GANG_ZONE)
				{
					continue;
				}

				GangZoneHideForAll(gzs_gInfo[shapeid][gzs_Elements][y]);
			}

			return 1;
		}
	}
	return 0;
}

stock GZ_ShapeFlashForPlayer(playerid, shapeid, flashcolor)
{
	if(0 <= shapeid < MAX_GZ_SHAPES)
	{
		if(gzs_gInfo[shapeid][gzs_Exists])
		{
			for(new y = 0; y < MAX_GANG_ZONES; y++)
			{
				if(gzs_gInfo[shapeid][gzs_Elements][y] == INVALID_GANG_ZONE)
				{
					continue;
				}

				GangZoneFlashForPlayer(playerid, gzs_gInfo[shapeid][gzs_Elements][y], flashcolor);
			}

			return 1;
		}
	}
	return 0;
}

stock GZ_ShapeFlashForAll(shapeid, flashcolor)
{
	if(0 <= shapeid < MAX_GZ_SHAPES)
	{
		if(gzs_gInfo[shapeid][gzs_Exists])
		{
			for(new y = 0; y < MAX_GANG_ZONES; y++)
			{
				if(gzs_gInfo[shapeid][gzs_Elements][y] == INVALID_GANG_ZONE)
				{
					continue;
				}

				GangZoneFlashForAll(gzs_gInfo[shapeid][gzs_Elements][y], flashcolor);
			}

			return 1;
		}
	}
	return 0;
}

stock GZ_ShapeStopFlashForPlayer(playerid, shapeid)
{
	if(0 <= shapeid < MAX_GZ_SHAPES)
	{
		if(gzs_gInfo[shapeid][gzs_Exists])
		{
			for(new y = 0; y < MAX_GANG_ZONES; y++)
			{
				if(gzs_gInfo[shapeid][gzs_Elements][y] == INVALID_GANG_ZONE)
				{
					continue;
				}

				GangZoneStopFlashForPlayer(playerid, gzs_gInfo[shapeid][gzs_Elements][y]);
			}

			return 1;
		}
	}
	return 0;
}

stock GZ_ShapeStopFlashForAll(shapeid)
{
	if(0 <= shapeid < MAX_GZ_SHAPES)
	{
		if(gzs_gInfo[shapeid][gzs_Exists])
		{
			for(new y = 0; y < MAX_GANG_ZONES; y++)
			{
				if(gzs_gInfo[shapeid][gzs_Elements][y] == INVALID_GANG_ZONE)
				{
					continue;
				}

				GangZoneStopFlashForAll(gzs_gInfo[shapeid][gzs_Elements][y]);
			}

			return 1;
		}
	}
	return 0;
}

stock GZ_ShapeDestroyAll()
{
	for(new x = 0; x < MAX_GZ_SHAPES; x++)
	{
		if(!gzs_gInfo[x][gzs_Exists])
		{
			continue;
		}

		for(new y = 0; y < MAX_GANG_ZONES; y++)
  		{
  			if(gzs_gInfo[x][gzs_Elements][y] == INVALID_GANG_ZONE)
  			{
  				continue;
  			}

  			GangZoneDestroy(gzs_gInfo[x][gzs_Elements][y]);
  		}

  		gzs_gInfo[x][gzs_Exists] = false;
	}
	return 1;
}
