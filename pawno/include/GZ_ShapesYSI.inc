#if defined _gz_shapes_included
	#endinput
#endif
#define _gz_shapes_included

#include <YSI\y_utils>
#include <YSI\y_iterate>
#include <YSI\y_hooks>

#if !defined MAX_GZ_SHAPES
	#define MAX_GZ_SHAPES					10
#endif

#if !defined INVALID_GZ_SHAPE_ID
	#define INVALID_GZ_SHAPE_ID				-1
#endif

#if !defined MAP_SIZE_LIMIT
	#define MAP_SIZE_LIMIT					3000.0 // Useful to set limits for the EMPTY_CIRCLE shape.
#endif

enum GZ_SHAPE_TYPES
{
	CIRCLE,
	EMPTY_CIRCLE,
	CIRCUMFERENCE
}

static Iterator:gzs_Shapes<MAX_GZ_SHAPES>;
static Iterator:gzs_ShapeElements[MAX_GZ_SHAPES]<MAX_GANG_ZONES>;
static Iterator:gzs_GangZonesUsed<MAX_GANG_ZONES>;

hook OnScriptInit()
{
	Iter_Init(gzs_ShapeElements);
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnScriptExit()
{
	GZ_ShapeDestroyAll();
	return Y_HOOKS_CONTINUE_RETURN_1;
}

stock gzs_GangZoneCreate(Float:minx, Float:miny, Float:maxx, Float:maxy)
{
	new zone = GangZoneCreate(minx, miny, maxx, maxy);

	if(zone != -1)
	{
		Iter_Add(gzs_GangZonesUsed, zone);
	}
	return zone;
}
#if defined _ALS_GangZoneCreate
    #undef GangZoneCreate
#else
    #define _ALS_GangZoneCreate
#endif
#define GangZoneCreate gzs_GangZoneCreate

stock gzs_GangZoneDestroy(zone)
{
	if(IS_IN_RANGE(zone, 0, MAX_GANG_ZONES))
	{
		if(Iter_Contains(gzs_GangZonesUsed, zone))
		{
			Iter_Remove(gzs_GangZonesUsed, zone);
		}
	}
	return GangZoneDestroy(zone);
}
#if defined _ALS_GangZoneDestroy
    #undef GangZoneDestroy
#else
    #define _ALS_GangZoneDestroy
#endif
#define GangZoneDestroy gzs_GangZoneDestroy

stock GetGangZonesAvailable()
{
	return (MAX_GANG_ZONES - Iter_Count(gzs_GangZonesUsed));
}

stock GZ_ShapeCreate(GZ_SHAPE_TYPES:type, Float:x, Float:y, Float:radius, squares = -1, Float:square_size = 5.0, Float:min_ang = 0.0, Float:max_ang = 360.0)
{
	new free_squares = GetGangZonesAvailable();

	if(free_squares <= 1)
	{
		print("** [GZ Shapes] The shape couldn't be created, gang zones limit reached.");
		return INVALID_GZ_SHAPE_ID;
	}

	new idx = Iter_Free(gzs_Shapes);

	if(idx == INVALID_ITERATOR_SLOT)
	{
		print("** [GZ_Shapes] The shape couldn't be created, MAX_GZ_SHAPES has been reached.");
		return INVALID_GZ_SHAPE_ID; 
	}

	new Float:angle = floatabs(max_ang - min_ang);

	/*
		What is "reference"?
		512 are the gang zones I've used for a 750m radius circumference.
		512/750 is a ratio. The result of multiplying that ratio by the new
		radius will be the amount of gang zones required for the new shape.
	*/
	new Float:reference = radius * (512.0/750.0);

	/*
		What is "auto_squares"?
		"reference" is the amount of squares required for a 360º circumference.
		The gang zones amount used for a shape must be set according to the angle
		provided by the user, which is "angle".
	*/
	new auto_squares = floatround(reference * (angle/360.0));

	if(squares == -1)
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

	new gangzone_id;
	new Float:temp_x;
	new Float:next_x;
	new Float:temp_y;
	new Float:temp_diff;
	new Float:next_diff;
	new Float:diff = angle / float(squares);

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
					gangzone_id =  GangZoneCreate((x + next_x), y, (x + temp_x), (y + temp_y));
				}
				else
				{
					gangzone_id =  GangZoneCreate((x + temp_x), (y + temp_y), (x + next_x), y);
				}

				Iter_Add(gzs_ShapeElements[idx], gangzone_id);
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

				next_x = radius * floatcos(next_diff, degrees);

				if(0.0 <= temp_diff <= 90.0)
				{
					if(j == 0)
					{
						temp_y = 0.0;
						temp_x = (MAP_SIZE_LIMIT - x);
					}

					gangzone_id =  GangZoneCreate((x + next_x), (y + temp_y), (x + temp_x), MAP_SIZE_LIMIT);
				}
				else if(90.0 < temp_diff < 180.0)
				{
					if(next_diff >= 180.0)
					{
						next_x = - (MAP_SIZE_LIMIT + x);
						temp_y = 0.0;

						second_quadrant = true;
					}

					gangzone_id =  GangZoneCreate((x + next_x), (y + temp_y), (x + temp_x), MAP_SIZE_LIMIT);
				}
				else if(180.0 <= temp_diff <= 270.0)
				{
					if(second_quadrant)
					{
						second_quadrant = false;

						temp_x = - (MAP_SIZE_LIMIT + x);
						temp_y = 0.0;

					}

					gangzone_id =  GangZoneCreate((x + temp_x), -MAP_SIZE_LIMIT, (x + next_x), (y + temp_y));
				}
				else if(270 < temp_diff <= 360.0)
				{
					if((squares - j) <= 1)
					{
						next_x = (MAP_SIZE_LIMIT - x);
						temp_y = 0.0;
					}

					gangzone_id =  GangZoneCreate((x + temp_x), -MAP_SIZE_LIMIT, (x + next_x), (y + temp_y));
				}

				Iter_Add(gzs_ShapeElements[idx], gangzone_id);
			}
		}
		case CIRCUMFERENCE:
		{
			for(new j = 0; j < squares; j++)
			{
				temp_diff = min_ang + (diff * float(j));

				temp_x = radius * floatcos(temp_diff, degrees);
				temp_y = radius * floatsin(temp_diff, degrees);

				gangzone_id = GangZoneCreate((x + temp_x) - square_size, (y + temp_y) - square_size, (x + temp_x) + square_size, (y + temp_y) + square_size);

				Iter_Add(gzs_ShapeElements[idx], gangzone_id);
			}
		}
		default:
		{
			printf("** [GZ Shapes] The shape couldn't be created, the shape type isn't correct.");
			return INVALID_GZ_SHAPE_ID;
		}
	}

	/*
		printf(
			"** [GZ Shapes Debug] The shape %d has been created (%d gang zones used). %d/%d gang zones available.",
			idx,
			squares,
			GetGangZonesAvailable(),
			MAX_GANG_ZONES
		);
	*/

	Iter_Add(gzs_Shapes, idx);

	return idx;
}

stock GZ_ShapeDestroy(shapeid)
{
	if(!Iter_Contains(gzs_Shapes, shapeid))
	{
		return 0;
	}

	foreach(new x : gzs_ShapeElements[shapeid])
	{
		GangZoneDestroy(x);
	}

	Iter_Clear(gzs_ShapeElements[shapeid]);
	Iter_Remove(gzs_Shapes, shapeid);
	return 1;
}

stock GZ_ShapeDestroyAll()
{
	foreach(new x : gzs_Shapes)
	{
		foreach(new y : gzs_ShapeElements[x])
		{
			GangZoneDestroy(y);
		}
		Iter_Clear(gzs_ShapeElements[x]);
	}
	Iter_Clear(gzs_Shapes);
}

stock GZ_ShapeShowForPlayer(playerid, shapeid, color)
{
	if(!VALID_PLAYERID(playerid))
	{
		return 0;
	}

	if(!Iter_Contains(gzs_Shapes, shapeid))
	{
		return 0;
	}

	foreach(new x : gzs_ShapeElements[shapeid])
	{
		GangZoneShowForPlayer(playerid, x, color);
	}
	return 1;
}

stock GZ_ShapeHideForPlayer(playerid, shapeid)
{
	if(!VALID_PLAYERID(playerid))
	{
		return 0;
	}

	if(!Iter_Contains(gzs_Shapes, shapeid))
	{
		return 0;
	}

	foreach(new x : gzs_ShapeElements[shapeid])
	{
		GangZoneHideForPlayer(playerid, x);
	}
	return 1;
}

stock GZ_ShapeFlashForPlayer(playerid, shapeid, flashcolor)
{
	if(!VALID_PLAYERID(playerid))
	{
		return 0;
	}

	if(!Iter_Contains(gzs_Shapes, shapeid))
	{
		return 0;
	}

	foreach(new x : gzs_ShapeElements[shapeid])
	{
		GangZoneFlashForPlayer(playerid, x, flashcolor);
	}
	return 1;
}

stock GZ_ShapeStopFlashForPlayer(playerid, shapeid)
{
	if(!VALID_PLAYERID(playerid))
	{
		return 0;
	}

	if(!Iter_Contains(gzs_Shapes, shapeid))
	{
		return 0;
	}

	foreach(new x : gzs_ShapeElements[shapeid])
	{
		GangZoneStopFlashForPlayer(playerid, x);
	}
	return 1;
}

stock GZ_ShapeShowForAll(shapeid, color)
{
	if(!Iter_Contains(gzs_Shapes, shapeid))
	{
		return 0;
	}

	foreach(new x : gzs_ShapeElements[shapeid])
	{
		GangZoneShowForAll(x, color);
	}
	return 1;
}

stock GZ_ShapeHideForAll(shapeid)
{
	if(!Iter_Contains(gzs_Shapes, shapeid))
	{
		return 0;
	}

	foreach(new x : gzs_ShapeElements[shapeid])
	{
		GangZoneHideForAll(x);
	}
	return 1;
}

stock GZ_ShapeFlashForAll(shapeid, flashcolor)
{
	if(!Iter_Contains(gzs_Shapes, shapeid))
	{
		return 0;
	}

	foreach(new x : gzs_ShapeElements[shapeid])
	{
		GangZoneFlashForAll(x, flashcolor);
	}
	return 1;
}

stock GZ_ShapeStopFlashForAll(shapeid)
{
	if(!Iter_Contains(gzs_Shapes, shapeid))
	{
		return 0;
	}

	foreach(new x : gzs_ShapeElements[shapeid])
	{
		GangZoneStopFlashForAll(x, flashcolor);
	}
	return 1;
}
