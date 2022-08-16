#include <YSI_Coding\y_hooks>
#define MAX_PLAYER_ATTACHED_ITEMS	10
//------------------------------------------------------------------------------

forward OnLoadPlayerAttachments(playerid);
forward OnInsertAttachmentOnDatabase(playerid, index);

//------------------------------------------------------------------------------

new gPlayerTickCount[MAX_PLAYERS];
new gIsDialogVisible[MAX_PLAYERS];
new gChosenWeapon[MAX_PLAYERS];
new gHidenAttachment[MAX_PLAYERS];
//------------------------------------------------------------------------------

enum
{
    LIST_GLASSES,
    LIST_HATS,
	LIST_BANDANA,
	LIST_CAP,
	LIST_HELMETS,
	LIST_MASKS,
    LIST_FUN
}

new attachments_category[][] =
{
    "Glasses",
    "Hats",
	"Bandana",
	"Caps",
	"Helmets",
	"Masks"
};

new attachments_data[][][] =
{
    /*
		price, model, category, name
	*/

	// Glasses
    {50,	19006, 	LIST_GLASSES,	"Red Common Glasses"},
    {50,	19007, 	LIST_GLASSES,	"Yellow Common Glasses"},
    {50,	19008, 	LIST_GLASSES,	"Green Common Glasses"},
    {50,	19009, 	LIST_GLASSES,	"Blue Common Glasses"},
    {50,	19010, 	LIST_GLASSES,	"Purple Common Glasses"},
    {150,	19011,	LIST_GLASSES,	"Psychedelic"},
    {75,	19012,	LIST_GLASSES,	"Black Common Glasses"},
    {100,	19013, 	LIST_GLASSES,	"Black Custom"},
    {150,	19014, 	LIST_GLASSES,	"Chess"},
    {200,	19015, 	LIST_GLASSES,	"Black Transparent"},
    {250,	19016, 	LIST_GLASSES,	"Lightning-X"},
    {300,	19017, 	LIST_GLASSES,	"Yellow"},
    {300,	19018, 	LIST_GLASSES,	"Orange"},
    {300,	19019, 	LIST_GLASSES,	"Red"},
    {300,	19020, 	LIST_GLASSES,	"Blue"},
    {300,	19021, 	LIST_GLASSES,	"Green"},
    {600,	19022, 	LIST_GLASSES,	"Black Air"},
    {500,	19023, 	LIST_GLASSES,	"Blue Air"},
    {500,	19024, 	LIST_GLASSES,	"Purple Air"},
    {500,	19025, 	LIST_GLASSES,	"Lilas Air"},
    {500,	19026, 	LIST_GLASSES,	"Rose Air"},
    {500,	19027, 	LIST_GLASSES,	"Orange Air"},
    {500,	19028, 	LIST_GLASSES,	"Yellow Air"},
    {500,	19029, 	LIST_GLASSES,	"Green Air"},
    {400,	19030, 	LIST_GLASSES,	"Brown Modern"},
    {400,	19031, 	LIST_GLASSES,	"Yellow Modern"},
    {400,	19032, 	LIST_GLASSES,	"Red Modern"},
    {800,	19033, 	LIST_GLASSES,	"Black Glasses"},
    {650,	19034, 	LIST_GLASSES,	"Black Glasses"},
    {1200,	19035, 	LIST_GLASSES,	"Blue Custom"},
    {2000,	19138, 	LIST_GLASSES,	"Black Modern Glasses"},
    {2000,	19139, 	LIST_GLASSES,	"Red Modern Glasses"},
    {2000,	19140, 	LIST_GLASSES,	"Blue Modern Glasses"},
	// Hats
	{400,	18947, 	LIST_HATS,		"Hat Black"},
    {400,	18948, 	LIST_HATS,		"Hat Blue"},
    {400,	18949, 	LIST_HATS,		"Hat Green"},
    {400,	18950, 	LIST_HATS,		"Hat Red"},
    {400,	18951, 	LIST_HATS,		"Hat Yellow"},
    {350,	18967, 	LIST_HATS,		"Hat Black 2"},
    {350,	18969, 	LIST_HATS,		"Hat Orange"},
    {500,	18968, 	LIST_HATS,		"Hat Grey and Blue"},

	// Bandanas
	{120,	18891,	LIST_BANDANA,	"Bandana 1"},
	{120,	18892,	LIST_BANDANA,	"Bandana 2"},
	{100,	18893,	LIST_BANDANA,	"Bandana 3"},
	{100,	18894,	LIST_BANDANA,	"Bandana 4"},
	{500,	18895,	LIST_BANDANA,	"Bandana 5"},
	{450,	18896,	LIST_BANDANA,	"Bandana 6"},
	{300,	18897,	LIST_BANDANA,	"Bandana 7"},
	{300,	18898,	LIST_BANDANA,	"Bandana 8"},
	{300,	18899,	LIST_BANDANA,	"Bandana 9"},
	{300,	18900,	LIST_BANDANA,	"Bandana 10"},
	{400,	18901,	LIST_BANDANA,	"Bandana 11"},
	{300,	18902,	LIST_BANDANA,	"Bandana 12"},
	{200,	18903,	LIST_BANDANA,	"Bandana 13"},
	{350,	18904,	LIST_BANDANA,	"Bandana 14"},
	{300,	18905,	LIST_BANDANA,	"Bandana 15"},
	{250,	18906,	LIST_BANDANA,	"Bandana 16"},
	{250,	18907,	LIST_BANDANA,	"Bandana 17"},
	{250,	18908,	LIST_BANDANA,	"Bandana 18"},
	{250,	18909,	LIST_BANDANA,	"Bandana 19"},
	{500,	18910,	LIST_BANDANA,	"Bandana 20"},

	// Caps
	{500,	18939,	LIST_CAP,		"Cap 1"},
	{150,	18940,	LIST_CAP,		"Cap 2"},
	{150,	18942,	LIST_CAP,		"Cap 3"},
	{250,	18943,	LIST_CAP,		"Cap 4"},
	{500,	18926,	LIST_CAP,		"Cap 5"},
	{450,	18927,	LIST_CAP,		"Cap 6"},
	{300,	18928,	LIST_CAP,		"Cap 7"},
	{300,	18929,	LIST_CAP,		"Cap 8"},
	{300,	18930,	LIST_CAP,		"Cap 9"},
	{300,	18932,	LIST_CAP,		"Cap 10"},
	{300,	18933,	LIST_CAP,		"Cap 11"},
	{200,	18934,	LIST_CAP,		"Cap 12"},
	{200,	18935,	LIST_CAP,		"Cap 13"},
	{200,	19093,	LIST_CAP,		"Cap 14"},
	{200,	19160,	LIST_CAP,		"Cap 15"},
	{1000,	19161,	LIST_CAP,		"Cap 16"},
	{1000,	19162,	LIST_CAP,		"Cap 17"},

    {200,   18973,  LIST_CAP,       "Cap 18"},
    {200,   19553,  LIST_CAP,       "Cap 19"},
    {200,   19421,  LIST_CAP,       "Headphone 1"},
    {1000,  19422,  LIST_CAP,       "Headphone 2"},
    {1000,  19423,  LIST_CAP,       "Headphone 3"},
    {200,   19424,  LIST_CAP,       "Headphone 4"},
    {200,   18928,  LIST_CAP,       "Cap 20"},
    {1000,  18929,  LIST_CAP,       "Cap 21"},
    {1000,  18930,  LIST_CAP,       "Cap 22"},
    {200,   18931,  LIST_CAP,       "Cap 23"},
    {1000,  18932,  LIST_CAP,       "Cap 24"},
    {1000,  18933,  LIST_CAP,       "Cap 25"},
    {200,   18903,  LIST_CAP,       "Bandana 21"},
    {1000,  18909,  LIST_CAP,       "Bandana 22"},

	// Helmets
	{600,	18645,	LIST_HELMETS,	"Helmet"},
	{1200,	18976,	LIST_HELMETS,	"Helmet Motocross"},
	{800,	18977,	LIST_HELMETS,	"Helmet Red"},
	{1000,	18978,	LIST_HELMETS,	"Helmet Beow"},
	{800,	18979,	LIST_HELMETS,	"Helmet Pink"},
	{3500,	19200,	LIST_HELMETS,	"Helmet Police"},

	// Masks
	{1200,	18911,	LIST_MASKS,		"Mask 1"},
	{600,	18912,	LIST_MASKS,		"Mask 2"},
	{300,	18913,	LIST_MASKS,		"Mask 3"},
	{600,	18914,	LIST_MASKS,		"Mask 4"},
	{300,	18915,	LIST_MASKS,		"Mask 5"},
	{300,	18916,	LIST_MASKS,		"Mask 6"},
	{1200,	18917,	LIST_MASKS,		"Mask 7"},
	{300,	18918,	LIST_MASKS,		"Mask 8"},
	{300,	18919,	LIST_MASKS,		"Mask 9"},
	{300,	18920,	LIST_MASKS,		"Mask 10"},
	{1200,	19036,	LIST_MASKS,		"Mask 11"},
	{600,	19037,	LIST_MASKS,		"Mask 12"},
	{600,	19038,	LIST_MASKS,		"Mask 13"},
	{800,	18974,	LIST_MASKS,		"Mask 14"},
	{600,	19163,	LIST_MASKS,		"Mask 15"},
    {600,   11704,  LIST_MASKS,     "Mask 16"},
    {1000,  19515,  LIST_CAP,       "Armour"},
    {1000,  19517,  LIST_CAP,       "Hair 1"},
    {1000,  19516,  LIST_CAP,       "Hair 2"},
    {1000,  19518,  LIST_CAP,       "Hair 3"},
    {1000,  19519,  LIST_CAP,       "Hair 4"},
    {1000,  19274,  LIST_CAP,       "Hair 5"},
    {1000,  19077,  LIST_CAP,       "Hair 6"},
    {1000,  18975,  LIST_CAP,       "Hair 7"},
    {1000,  18640,  LIST_CAP,       "Hair 8"},
    {1000,  19314,  LIST_CAP,       "Horn"},
    {1000,  348,    LIST_CAP,       "Desert Eagle"},
    {1000,  349,    LIST_CAP,       "Shotgun"},
    {1000,  353,    LIST_CAP,       "SMG"},
    {1000,  355,    LIST_CAP,       "AK47"},
    {1000,  356,    LIST_CAP,       "M4"},
    {1000,  358,    LIST_CAP,       "Sniper Rifle"},
    {1000,  363,    LIST_CAP,       "Satchel Charge"},
    //===================POLICE============================
    {1000,  19161,    LIST_CAP,       "Police Cap"},
    {1000,  19141,    LIST_CAP,       "Police Cap 2"},
    {1000,  19099,    LIST_CAP,       "Police Cap 3"},
    {1000,  19100,    LIST_CAP,       "Police Cap 4"},
    {1000,  19521,    LIST_CAP,       "Police Cap 5"},
    {1000,  19139,    LIST_CAP,       "Police Glasses"},
    {1000,  19140,    LIST_CAP,       "Police Glasses 2"},
    {1000,  18637,    LIST_CAP,       "Police Shield"},
    {1000,  19142,    LIST_CAP,       "Police Armour"},
    {1000,  19777,    LIST_CAP,       "FBI Badge"},
    {1000,  19590,  LIST_CAP,       "Sword"},
    {1000,  19773,  LIST_CAP,       "Holster"},
    {1000,  19801,  LIST_CAP,       "Black Mask"},
    {1000,  19085,  LIST_CAP,       "Black EyePatch"},
    {1000,  18953,  LIST_CAP,       "Hat 1"},
    {1000,  18954,  LIST_CAP,       "Hat 2"},
    {1000,  19555,  LIST_CAP,       "Glove Right"},
    {1000,  19556,  LIST_CAP,       "Glove Left"},
    {1000,  19102,  LIST_CAP,       "Army Hat 1"},
    {1000,  19103,  LIST_CAP,       "Army Hat 2"},
    {1000,  19104,  LIST_CAP,       "Army Hat 3"},
    {1000,  19105,  LIST_CAP,       "Army Hat 4"},
    {1000,  19106,  LIST_CAP,       "Army Hat 5"},
    {1000,  19107,  LIST_CAP,       "Army Hat 6"},
    {1000,  18921,  LIST_CAP,       "Hat 3"},
    {1000,  19488,  LIST_CAP,       "Hat 4"},
    {1000,  19064,  LIST_CAP,       "Christmas Cap"},
    {1000,  19065,  LIST_CAP,       "Christmas Cap 2"},
    {1000,  19095,  LIST_CAP,       "Hat 5"},
    {1000,  19096,  LIST_CAP,       "Hat 6"},
    {1000,  19097,  LIST_CAP,       "Hat 7"},
    {1000,  19098,  LIST_CAP,       "Hat 8"},
    {1000,  18922,  LIST_CAP,       "Beret 1"},
    {1000,  18923,  LIST_CAP,       "Beret 2"},
    {1000,  18924,  LIST_CAP,       "Beret 3"},
    {1000,  18925,  LIST_CAP,       "Beret 4"},
    {1000,  19942,  LIST_CAP,       "Radio"},
    {1000,  19559,  LIST_CAP,       "Hiking Bag"},
    {1000,  11745,  LIST_CAP,       "Bag 1"},
    {1000,  2919,  LIST_CAP,       "Bag 2"},
    {1000,  3026,  LIST_CAP,       "Bag 3"},
    {1000, 371,  LIST_CAP,       "Parachute"},
    {1000,  19472,  LIST_CAP,       "Gas Mask"}

};

//------------------------------------------------------------------------------
#define     MAX_ATTACH_SLOTS    5
enum e_slot_data
{
    e_slot_db,
    e_slot_created,
    e_slot_status,
    e_slot_name[64],
    e_slot_type
}
new gAttachmentSlot[MAX_PLAYERS][MAX_ATTACH_SLOTS][e_slot_data];
new gClothingSlotList[MAX_PLAYERS][MAX_ATTACH_SLOTS+1];

enum e_attachment_data
{
    e_attachment_db,
    e_attachment_slot,
    e_attachment_index,
    e_attachment_model,
    e_attachment_bone,
    e_attachment_toggle,
    Float:e_attachment_x,
    Float:e_attachment_y,
    Float:e_attachment_z,

    Float:e_attachment_rx,
    Float:e_attachment_ry,
    Float:e_attachment_rz,

    Float:e_attachment_sx,
    Float:e_attachment_sy,
    Float:e_attachment_sz,

    e_attachment_col_1,
    e_attachment_col_2
}
new gPlayerAttachmentData[MAX_PLAYERS][MAX_PLAYER_ATTACHED_ITEMS][e_attachment_data];
new bool:gPlayerAlreadySpawned[MAX_PLAYERS];
new bool:gIsPlayerEditing[MAX_PLAYERS];
new gPlayerSelectedIndex[MAX_PLAYERS];
new gPlayerSelectedCategory[MAX_PLAYERS];
new gPlayerSelectedSlot[MAX_PLAYERS];
//------------------------------------------------------------------------------
GetPlayerClothingSlots(playerid)
{
    new count = 0;
    for(new i = 0; i < MAX_ATTACH_SLOTS; i++)
    {
        if(gAttachmentSlot[playerid][i][e_slot_created] == 1)
            count++;
    }
    return count;
}
GetPlayerActivatedSlot(playerid)
{
    for(new i = 0; i < MAX_ATTACH_SLOTS; i++)
    {
        if(gAttachmentSlot[playerid][i][e_slot_created] == 1 && gAttachmentSlot[playerid][i][e_slot_status] == 1)
            return i;
    }
    return -1;
}
//------------------------------------------------------------------------------
AddClothingSlot(playerid, name[])
{
    for(new i = 0; i < MAX_ATTACH_SLOTS; i++)
    {
        if(gAttachmentSlot[playerid][i][e_slot_created] == 0)
        {
            gAttachmentSlot[playerid][i][e_slot_created] = 1;
            gAttachmentSlot[playerid][i][e_slot_status] = 0;
            gAttachmentSlot[playerid][i][e_slot_type] = 0;
            strmid( gAttachmentSlot[playerid][i][e_slot_name], name, 0, strlen( name ), 64);

            new query[256];
            mysql_format( _dbConnector, query, sizeof( query ), "INSERT INTO `attach_slots` ( name, user_id ) VALUES( '%e', '%d')", name, gPlayerData[ playerid ][ E_PLAYER_ID ] );
            mysql_tquery( _dbConnector, query, "OnClothingSlotCreated", "ii", playerid, i );
            break;
        }
    }
    return 1;
}
UpdateSlotName(playerid, slot, name[])
{
    if(gAttachmentSlot[playerid][slot][e_slot_created] == 1)
    {
        strmid( gAttachmentSlot[playerid][slot][e_slot_name], name, 0, strlen( name ), 64);

        new query[256];
        mysql_format( _dbConnector, query, sizeof( query ), "UPDATE `attach_slots` SET `name` = '%e' WHERE `id` = '%d'", name,  gAttachmentSlot[playerid][slot][e_slot_db]);
        mysql_tquery( _dbConnector, query, "", "" );
    }
    return 1;
}
DeleteSlot(playerid, slot)
{
    if(gAttachmentSlot[playerid][slot][e_slot_created] == 1)
    {
        gAttachmentSlot[playerid][slot][e_slot_created] = 0;
        gAttachmentSlot[playerid][slot][e_slot_status] = 0;
        gAttachmentSlot[playerid][slot][e_slot_type] = 0;
        strmid( gAttachmentSlot[playerid][slot][e_slot_name], "", 0, strlen( "" ), 64);

        new query[256];
        mysql_format( _dbConnector, query, sizeof( query ), "DELETE FROM `attach_slots` WHERE `id` = '%d'", gAttachmentSlot[playerid][slot][e_slot_db]);
        mysql_tquery( _dbConnector, query, "", "" );

        mysql_format( _dbConnector, query, sizeof( query ), "DELETE FROM `attachments` WHERE `user_id` = '%d' AND `slot_id` = '%d'", gPlayerData[playerid][E_PLAYER_ID], gAttachmentSlot[playerid][slot][e_slot_db]);
        mysql_tquery( _dbConnector, query, "", "" );
    }
    return 1;
}
forward OnClothingSlotCreated( playerid, slot );
public OnClothingSlotCreated( playerid, slot ){

    gAttachmentSlot[playerid][slot][e_slot_db] = cache_insert_id();
    return true;
}
//------------------------------------------------------------------------------
ResetPlayerAttachments(playerid)
{
    for (new i = 0; i < MAX_PLAYER_ATTACHED_ITEMS; i++)
    {
        gPlayerAttachmentData[playerid][i][e_attachment_db] = 0;
        gPlayerAttachmentData[playerid][i][e_attachment_model] = 0;
        RemovePlayerAttachedObject(playerid, gPlayerAttachmentData[playerid][i][e_attachment_index]);
    }
}
stock TogglePlayerAttachments(playerid, toggle)
{
    for (new i = 0; i < MAX_PLAYER_ATTACHED_ITEMS; i++)
    {
        TogglePlayerItem(playerid, i, toggle);
    }
}
//------------------------------------------------------------------------------

ResetPlayerAttachment(playerid, slotid)
{
    gPlayerAttachmentData[playerid][slotid][e_attachment_db] = 0;
    gPlayerAttachmentData[playerid][slotid][e_attachment_model] = 0;
    RemovePlayerAttachedObject(playerid, gPlayerAttachmentData[playerid][slotid][e_attachment_index]);
}
TogglePlayerItem(playerid, slotid, toggle)
{
    if(toggle==0)
    {
        RemovePlayerAttachedObject(playerid, gPlayerAttachmentData[playerid][slotid][e_attachment_index]);
        gPlayerAttachmentData[playerid][slotid][e_attachment_toggle] = 0;
    }
    else
    {

        new index = gPlayerAttachmentData[playerid][slotid][e_attachment_index];
        new modelid = gPlayerAttachmentData[playerid][slotid][e_attachment_model];
        new bone = gPlayerAttachmentData[playerid][slotid][e_attachment_bone];

        new Float:x = gPlayerAttachmentData[playerid][slotid][e_attachment_x];
        new Float:y = gPlayerAttachmentData[playerid][slotid][e_attachment_y];
        new Float:z = gPlayerAttachmentData[playerid][slotid][e_attachment_z];

        new Float:rx = gPlayerAttachmentData[playerid][slotid][e_attachment_rx];
        new Float:ry = gPlayerAttachmentData[playerid][slotid][e_attachment_ry];
        new Float:rz = gPlayerAttachmentData[playerid][slotid][e_attachment_rz];

        new Float:sx = gPlayerAttachmentData[playerid][slotid][e_attachment_sx];
        new Float:sy = gPlayerAttachmentData[playerid][slotid][e_attachment_sy];
        new Float:sz = gPlayerAttachmentData[playerid][slotid][e_attachment_sz];
        
		if(!isJobItem(playerid, modelid))
		{
        	SetPlayerAttachedObject(playerid, index, modelid, bone, x, y, z, rx, ry, rz, sx, sy, sz);
        	gPlayerAttachmentData[playerid][slotid][e_attachment_toggle] = 1;
        }
            
    }
}

//------------------------------------------------------------------------------

SavePlayerAttachments(playerid)
{
    new query[512];
    for (new i = 0; i < MAX_PLAYER_ATTACHED_ITEMS; i++)
    {
        if(gPlayerAttachmentData[playerid][i][e_attachment_db] == 0)
            continue;

    	mysql_format(_dbConnector, query, sizeof(query),
        "UPDATE `attachments` SET `Index`=%d, `Model`=%d, `Bone`=%d,\
        `X`=%f, `Y`=%f, `Z`=%f,\
        `RX`=%f, `RY`=%f, `RZ`=%f,\
        `SX`=%f, `SY`=%f, `SZ`=%f, `toggle`=%d \
        WHERE `ID`=%d",
    	gPlayerAttachmentData[playerid][i][e_attachment_index], gPlayerAttachmentData[playerid][i][e_attachment_model], gPlayerAttachmentData[playerid][i][e_attachment_bone],
        gPlayerAttachmentData[playerid][i][e_attachment_x], gPlayerAttachmentData[playerid][i][e_attachment_y], gPlayerAttachmentData[playerid][i][e_attachment_z],
        gPlayerAttachmentData[playerid][i][e_attachment_rx], gPlayerAttachmentData[playerid][i][e_attachment_ry], gPlayerAttachmentData[playerid][i][e_attachment_rz],
        gPlayerAttachmentData[playerid][i][e_attachment_sx], gPlayerAttachmentData[playerid][i][e_attachment_sy], gPlayerAttachmentData[playerid][i][e_attachment_sz], gPlayerAttachmentData[playerid][i][e_attachment_toggle],
        gPlayerAttachmentData[playerid][i][e_attachment_db]);
    	mysql_tquery(_dbConnector, query);
    }
}

//------------------------------------------------------------------------------

DeletePlayerAttachment(playerid, slotid)
{
	if(!gPlayerAttachmentData[playerid][slotid][e_attachment_db])
		return 1;

    if(gHidenAttachment[playerid] == slotid) gHidenAttachment[playerid] = -1;

	new query[100];
	mysql_format(_dbConnector, query, sizeof(query), "DELETE FROM `attachments` WHERE `ID` = %d", gPlayerAttachmentData[playerid][slotid][e_attachment_db]);
	mysql_tquery(_dbConnector, query);
    ResetPlayerAttachment(playerid, slotid);
	return 1;
}
TogglePlayerAttachment(playerid, slotid, toggle)
{
    if(!gPlayerAttachmentData[playerid][slotid][e_attachment_db])
        return 1;
    
    TogglePlayerItem(playerid, slotid, toggle);
    return 1;
}

//------------------------------------------------------------------------------

GivePlayerAttachments(playerid)
{
    for (new i = 0; i < MAX_PLAYER_ATTACHED_ITEMS; i++)
    {
        if(gPlayerAttachmentData[playerid][i][e_attachment_db] == 0)
            continue;
        if(gPlayerAttachmentData[playerid][i][e_attachment_toggle] == 0)
            continue;

        new index = gPlayerAttachmentData[playerid][i][e_attachment_index];
        new modelid = gPlayerAttachmentData[playerid][i][e_attachment_model];
        new bone = gPlayerAttachmentData[playerid][i][e_attachment_bone];

        new Float:x = gPlayerAttachmentData[playerid][i][e_attachment_x];
        new Float:y = gPlayerAttachmentData[playerid][i][e_attachment_y];
        new Float:z = gPlayerAttachmentData[playerid][i][e_attachment_z];

        new Float:rx = gPlayerAttachmentData[playerid][i][e_attachment_rx];
        new Float:ry = gPlayerAttachmentData[playerid][i][e_attachment_ry];
        new Float:rz = gPlayerAttachmentData[playerid][i][e_attachment_rz];

        new Float:sx = gPlayerAttachmentData[playerid][i][e_attachment_sx];
        new Float:sy = gPlayerAttachmentData[playerid][i][e_attachment_sy];
        new Float:sz = gPlayerAttachmentData[playerid][i][e_attachment_sz];
        if(!isJobItem(playerid, modelid))
        	SetPlayerAttachedObject(playerid, index, modelid, bone, x, y, z, rx, ry, rz, sx, sy, sz);
    }
}

isJobItem(playerid,modelid)
{
    for (new j = 0; j < sizeof(attachments_data); j++)
    {
        if(modelid == attachments_data[j][1][0])
        {
            if (strfind(attachments_data[j][3], "FBI", true) != -1)
            {
                if(GetPlayerFBISlot(playerid) == -1) return 1;
            }
        }
    }
    for (new j = 0; j < sizeof(attachments_data); j++)
    {
        if(modelid == attachments_data[j][1][0])
        {
            if (strfind(attachments_data[j][3], "Police", true) != -1)
            {
                if(!IsACop(playerid)) return 1;
            }
        }
    }
    return 0;
}
stock HideItems(playerid)
{
    for(new i=0; i< MAX_PLAYER_ATTACHED_OBJECTS; i++)
    {
        if(IsPlayerAttachedObjectSlotUsed(playerid, i)) RemovePlayerAttachedObject(playerid, i);
    }
}
//------------------------------------------------------------------------------

LoadPlayerAttachments(playerid, slot)
{
	new query[256];
	mysql_format(_dbConnector, query, sizeof(query), "SELECT * FROM `attachments` WHERE `user_id` = %i AND `slot_id` = %i", gPlayerData[ playerid ][ E_PLAYER_ID ], slot);
	mysql_tquery(_dbConnector, query, "OnLoadPlayerAttachments", "i", playerid);
}
/*
public OnGameModeInit()
{
    dodacilist = LoadModelSelectionMenu("dodaci.txt");
    return 1;
}*/
//------------------------------------------------------------------------------

public OnLoadPlayerAttachments(playerid)
{
	new rows, fields;
	cache_get_data(rows, fields, _dbConnector);
	if(rows)
	{
        for (new i = 0; i < rows; i++)
        {
            if(i == MAX_PLAYER_ATTACHED_ITEMS) break;
            gPlayerAttachmentData[playerid][i][e_attachment_db] = cache_get_field_content_int(i, "ID");

            gPlayerAttachmentData[playerid][i][e_attachment_index] = cache_get_field_content_int(i, "Index");
            gPlayerAttachmentData[playerid][i][e_attachment_model] = cache_get_field_content_int(i, "Model");
            gPlayerAttachmentData[playerid][i][e_attachment_bone] = cache_get_field_content_int(i, "Bone");

            gPlayerAttachmentData[playerid][i][e_attachment_x] = cache_get_field_content_float(i, "X");
            gPlayerAttachmentData[playerid][i][e_attachment_y] = cache_get_field_content_float(i, "Y");
            gPlayerAttachmentData[playerid][i][e_attachment_z] = cache_get_field_content_float(i, "Z");

            gPlayerAttachmentData[playerid][i][e_attachment_rx] = cache_get_field_content_float(i, "RX");
            gPlayerAttachmentData[playerid][i][e_attachment_ry] = cache_get_field_content_float(i, "RY");
            gPlayerAttachmentData[playerid][i][e_attachment_rz] = cache_get_field_content_float(i, "RZ");

            gPlayerAttachmentData[playerid][i][e_attachment_sx] = cache_get_field_content_float(i, "SX");
            gPlayerAttachmentData[playerid][i][e_attachment_sy] = cache_get_field_content_float(i, "SY");
            gPlayerAttachmentData[playerid][i][e_attachment_sz] = cache_get_field_content_float(i, "SZ");

            gPlayerAttachmentData[playerid][i][e_attachment_col_1] = cache_get_field_content_int(i, "Col1");
            gPlayerAttachmentData[playerid][i][e_attachment_col_2] = cache_get_field_content_int(i, "Col2");
            gPlayerAttachmentData[playerid][i][e_attachment_toggle] = cache_get_field_content_int(i, "toggle");
        }
        GivePlayerAttachments(playerid);
	}
    return 1;
}

forward LoadPlayerClothingSlots(playerid);
public LoadPlayerClothingSlots(playerid)
{
    new rows, fields;
    cache_get_data( rows, fields, _dbConnector );

    if( rows ) {
        for(new i = 0; i < rows; i++)
        {
            if(i == MAX_ATTACH_SLOTS)
            {
                break;
            }

            gAttachmentSlot[playerid][i][e_slot_db] = cache_get_field_content_int(i, "id");
            gAttachmentSlot[playerid][i][e_slot_status] = cache_get_field_content_int(i, "status");
            gAttachmentSlot[playerid][i][e_slot_type] = cache_get_field_content_int(i, "type");
            gAttachmentSlot[playerid][i][e_slot_created] = 1;

            cache_get_field_content( i, "name", gAttachmentSlot[playerid][i][e_slot_name], _dbConnector, 64 );
            //printf("%s: gSQL: %d > gID: %d > gRank: %d", PlayerName(playerid), gPlayerGroups[playerid][i][e_group_sql], gPlayerGroups[playerid][i][e_group_group], gPlayerGroups[playerid][i][e_group_rank]);
        }
    
    }
    return (true);
}
//------------------------------------------------------------------------------
hook OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid))
		return 1;

    if(!gPlayerAlreadySpawned[playerid])
    {
        new slot = GetPlayerActivatedSlot(playerid);
        if(slot != -1)
            LoadPlayerAttachments(playerid, gAttachmentSlot[playerid][slot][e_slot_db]);
        gPlayerAlreadySpawned[playerid] = true;
    }
	else
		GivePlayerAttachments(playerid);
	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	SavePlayerAttachments(playerid);
    ResetPlayerAttachments(playerid);
    for(new i = 0; i < MAX_ATTACH_SLOTS; i++)
    {
        if(gAttachmentSlot[playerid][i][e_slot_created] == 1)
        {
            gAttachmentSlot[playerid][i][e_slot_created] = 0;
        }
    }
    gIsDialogVisible[playerid] = false;
    gIsPlayerEditing[playerid] = false;
	gPlayerAlreadySpawned[playerid] = false;
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerEditAttachedObj(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
    if(gIsPlayerEditing[playerid])
    {
        for (new i = 0; i < MAX_PLAYER_ATTACHED_ITEMS; i++)
        {
            if(index != gPlayerAttachmentData[playerid][i][e_attachment_index])
                continue;

            if(response)
            {
                if(fOffsetX > 1.4)
                {
                    fOffsetX = 1.4;
                    SendErrorMessage(playerid, "Maximum X Offset exeeded, damped to maximum");
                }
                if(fOffsetY > 1.4) {
                    fOffsetY = 1.4;
                    SendErrorMessage(playerid, "Maximum Y Offset exeeded, damped to maximum");
                }
                if(fOffsetZ > 1.4) {
                    fOffsetZ = 1.4;
                    SendErrorMessage(playerid, "Maximum Z Offset exeeded, damped to maximum");
                }
                if(fOffsetX < -1.4) {
                    fOffsetX = -1.4;
                    SendErrorMessage(playerid, "Maximum X Offset exeeded, damped to maximum");
                }
                if(fOffsetY < -1.4) {
                    fOffsetY = -1.4;
                    SendErrorMessage(playerid, "Maximum Y Offset exeeded, damped to maximum");
                }
                if(fOffsetZ < -1.4) {
                    fOffsetZ = -1.4;
                    SendErrorMessage(playerid, "Maximum Z Offset exeeded, damped to maximum");
                }
                if(fScaleX > 1.5) {
                    fScaleX = 1.5;
                    SendErrorMessage(playerid, "Maximum X Scale exeeded, damped to maximum");
                }
                if(fScaleY > 1.5) {
                    fScaleY = 1.5;
                    SendErrorMessage(playerid, "Maximum Y Scale exeeded, damped to maximum");
                }
                if(fScaleZ > 1.5) {
                    fScaleZ = 1.5;
                    SendErrorMessage(playerid, "Maximum Z Scale exeeded, damped to maximum");
                }
                gPlayerAttachmentData[playerid][i][e_attachment_x] = fOffsetX;
                gPlayerAttachmentData[playerid][i][e_attachment_y] = fOffsetY;
                gPlayerAttachmentData[playerid][i][e_attachment_z] = fOffsetZ;

                gPlayerAttachmentData[playerid][i][e_attachment_rx] = fRotX;
                gPlayerAttachmentData[playerid][i][e_attachment_ry] = fRotY;
                gPlayerAttachmentData[playerid][i][e_attachment_rz] = fRotZ;

                gPlayerAttachmentData[playerid][i][e_attachment_sx] = fScaleX;
                gPlayerAttachmentData[playerid][i][e_attachment_sy] = fScaleY;
                gPlayerAttachmentData[playerid][i][e_attachment_sz] = fScaleZ;
                gPlayerAttachmentData[playerid][i][e_attachment_toggle] = 1;
				SetPlayerAttachedObject(playerid, index, modelid, boneid, fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, fScaleX, fScaleY, fScaleZ);
				SendInfoMessage(playerid, "* Choosen item has been saved.");
            }
            else
            {
                new Float:x = gPlayerAttachmentData[playerid][i][e_attachment_x];
                new Float:y = gPlayerAttachmentData[playerid][i][e_attachment_y];
                new Float:z = gPlayerAttachmentData[playerid][i][e_attachment_z];

                new Float:rx = gPlayerAttachmentData[playerid][i][e_attachment_rx];
                new Float:ry = gPlayerAttachmentData[playerid][i][e_attachment_ry];
                new Float:rz = gPlayerAttachmentData[playerid][i][e_attachment_rz];

                new Float:sx = gPlayerAttachmentData[playerid][i][e_attachment_sx];
                new Float:sy = gPlayerAttachmentData[playerid][i][e_attachment_sy];
                new Float:sz = gPlayerAttachmentData[playerid][i][e_attachment_sz];

                SetPlayerAttachedObject(playerid, index, modelid, boneid, x, y, z, rx, ry, rz, sx, sy, sz);
				SendInfoMessage(playerid, "* You have stopped editing the item.");
            }
            break;
        }
        gIsPlayerEditing[playerid] = false;
    }
    return 1;
}
//------------------------------------------------------------------------------

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if( dialogid == DIALOG_ATTACHMENTS ) {
        if( !response ) return true;
        else
        {
            if(listitem == 0)
            {
                if(GetPlayerClothingSlots(playerid) >= MAX_ATTACH_SLOTS) 
                {
                    SendErrorMessage(playerid, "You have created maximum number of clothing slots.");
                    ShowDialog(playerid, DIALOG_ATTACHMENTS);
                    return 1;
                }
                SPD( playerid, DIALOG_ATTACHMENTS_SLOTNAME, DSI, "New Slot", "{FFFFFF}Enter the name you want to set on the slot:", "Enter", "Back" );
            }
            else
            {
                SetPVarInt(playerid, "SelectedClothingSlot", gClothingSlotList[playerid][listitem]);
                ShowDialog(playerid, DIALOG_ATTACHMENTS_SLOTEDIT);
            }
        }
    }
    if( dialogid == DIALOG_ATTACHMENTS_SLOTNAME )
    {
        if( !response )
        {
            ShowDialog(playerid, DIALOG_ATTACHMENTS);
            return 1;
        }
        if( response ) {
            new slot_name[64];
            if( sscanf( inputtext, "s[64]", slot_name) ) return SPD( playerid, DIALOG_ATTACHMENTS_SLOTNAME, DSI, "New Slot", "{FFFFFF}Enter the name you want to set on the slot:", "Enter", "Back" );
            if(GetPlayerClothingSlots(playerid) >= MAX_ATTACH_SLOTS) return ShowDialog(playerid, DIALOG_ATTACHMENTS);

            AddClothingSlot(playerid, slot_name);
            SendInfoMessage(playerid, "You successfully created a new clothing slot with name %s.", slot_name);
            ShowDialog(playerid, DIALOG_ATTACHMENTS);
            return 1;
        }
    }
    if( dialogid == DIALOG_ATTACHMENTS_SLOTEDIT )
    {
        if( !response )
        {
            ShowDialog(playerid, DIALOG_ATTACHMENTS);
            return 1;
        }
        if( response ) {
            new slot = GetPVarInt(playerid, "SelectedClothingSlot");
            switch( listitem )
            {
                case 0:
                {
                    if(gAttachmentSlot[playerid][slot][e_slot_status] == 0) 
                    {
                        if(GetPlayerActivatedSlot(playerid) != -1)
                        {
                            SendErrorMessage(playerid, "You have another clothing slot activated.");
                            return ShowDialog(playerid, DIALOG_ATTACHMENTS);
                        }
                        gAttachmentSlot[playerid][slot][e_slot_status] = 1;
                        new query[256];
                        mysql_format( _dbConnector, query, sizeof( query ), "UPDATE `attach_slots` SET `status` = '1' WHERE `id` = '%d'", gAttachmentSlot[playerid][slot][e_slot_db]);
                        mysql_pquery( _dbConnector, query, "", "" );
                        LoadPlayerAttachments(playerid, gAttachmentSlot[playerid][slot][e_slot_db]);
                    }
                    else if(gAttachmentSlot[playerid][slot][e_slot_status] == 1)
                    {
                        gAttachmentSlot[playerid][slot][e_slot_status] = 0;
                        SavePlayerAttachments(playerid);
                        ResetPlayerAttachments(playerid);
                        new query[256];
                        mysql_format( _dbConnector, query, sizeof( query ), "UPDATE `attach_slots` SET `status` = '0' WHERE `id` = '%d'", gAttachmentSlot[playerid][slot][e_slot_db]);
                        mysql_pquery( _dbConnector, query, "", "" );
                    }
                    ShowDialog(playerid, DIALOG_ATTACHMENTS_SLOTEDIT);
                }
                case 1:
                {
                    if(gAttachmentSlot[playerid][slot][e_slot_status] == 0)
                    {
                        SendErrorMessage(playerid, "You must activate the slot first.");
                        ShowDialog(playerid, DIALOG_ATTACHMENTS_SLOTEDIT);
                        return 1;
                    }
                    SPD( playerid, DIALOG_ATTACHMENTS_MAIN, DSL, "Items", "Buy Item\nEdit Item\nToggle Item\nDelete Item", "Select", "Back" );
                }
                case 2:
                {
                    new string[158];
                    format(string, sizeof(string), "{FFFFFF}Enter the new name for the slot.\n\n{FFFFFF}Current Name: {1AD630}%s", gAttachmentSlot[playerid][slot][e_slot_name]);
                    SPD( playerid, DIALOG_ATTACHMENTS_SLOTEDITNAME, DSI, "Edit Slot Name", string, "Enter", "Back" );
                }
                case 3:
                {
                    strdel( DialogStrgEx, 0, sizeof( DialogStrgEx ) );
                    format( globalstring, sizeof( globalstring ),""col_white"Are you sure you want to delete slot "col_server"%s?", gAttachmentSlot[playerid][slot][e_slot_name] );
                    strcat( DialogStrgEx, globalstring );

                    ShowPlayerDialog( playerid, DIALOG_ATTACHMENTS_SLOTDELETE, DSMSG, "Slot Delete", DialogStrgEx, "Delete", "Back" );
                }
            }
            return 1;
        }
    }
    if( dialogid == DIALOG_ATTACHMENTS_SLOTDELETE )
    {
        if( !response )
        {
            ShowDialog(playerid, DIALOG_ATTACHMENTS_SLOTEDIT);
            return 1;
        }
        else
        {
            new slot = GetPVarInt(playerid, "SelectedClothingSlot");
            SendInfoMessage(playerid, "You deleted slot %s.", gAttachmentSlot[playerid][slot][e_slot_name]);
            if(gAttachmentSlot[playerid][slot][e_slot_status] == 1)
                ResetPlayerAttachments(playerid);
            DeleteSlot(playerid, slot);
            ShowDialog(playerid, DIALOG_ATTACHMENTS);
            return 1;
        }
    }
    if( dialogid == DIALOG_ATTACHMENTS_SLOTEDITNAME )
    {
        if( !response )
        {
            ShowDialog(playerid, DIALOG_ATTACHMENTS_SLOTEDIT);
            return 1;
        }
        if( response ) {
            new slot_name[64];
            new slot = GetPVarInt(playerid, "SelectedClothingSlot");
            if( sscanf( inputtext, "s[64]", slot_name) )
            {
                new string[158];
                format(string, sizeof(string), "{FFFFFF}Enter the new name for the slot.\n\n{FFFFFF}Current Name: {1AD630}%s", gAttachmentSlot[playerid][slot][e_slot_name]);
                SPD( playerid, DIALOG_ATTACHMENTS_SLOTEDITNAME, DSI, "Edit Slot Name", string, "Enter", "Back" );
            }
            SendGreenMessage(playerid, "You have changed the slot name.");
            UpdateSlotName(playerid, slot, slot_name);
            ShowDialog(playerid, DIALOG_ATTACHMENTS);
            return 1;
        }
    }
    if( dialogid == DIALOG_ATTACHMENTS_MAIN ) {
        if( !response ) return ShowDialog(playerid, DIALOG_ATTACHMENTS_SLOTEDIT);
        if( response ) {
            switch( listitem ) {
                case 0: {
                    if( IsPlayerInAnyVehicle( playerid ) ) return SendErrorMessage( playerid, "You can't while you're in the vehicle." );
                    if( PlayerCuffed[ playerid ] > 0 ) return SendErrorMessage( playerid, "You can't do this while cuffed." );
                    if( IgracZavezan[ playerid ] == true ) return SendErrorMessage( playerid, "You can't while you're tied up." );
                    if( KnockedDown[ playerid ] == true ) return SendErrorMessage( playerid, "You cannot use this command while you are knocked out.");

                    ShowModelSelectionMenu( playerid, dodacilist, "SELECT TOY", 0x00000070, 0x19595950, 0xFFFFFFFF);
                }
                case 1: {
                    new items = 0, info[250];
                    for (new i = 0; i < MAX_PLAYER_ATTACHED_ITEMS; i++)
                    {
                        if(gPlayerAttachmentData[playerid][i][e_attachment_db] != 0)
                        {
                            items++;

                            for (new j = 0; j < sizeof(attachments_data); j++)
                            {
                                if(gPlayerAttachmentData[playerid][i][e_attachment_model] == attachments_data[j][1][0])
                                {
                                    if(i > 0) strcat(info, "\n");
                                    strcat(info, attachments_data[j][3]);
                                    break;
                                }
                            }
                        }
                        else
                        {
                            if(i > 0) strcat(info, "\n");
                            strcat(info, "None");
                        }
                    }
                    if(items == 0) return SendErrorMessage(playerid, "You do not have any items.");
                    SPD(playerid, DIALOG_ATTACHMENTS_EDIT, DSL, "Edit items", info, "Edit", "Back");
                }
                case 2: {
                    new items = 0, info[250];
                    for (new i = 0; i < MAX_PLAYER_ATTACHED_ITEMS; i++)
                    {
                        if(gPlayerAttachmentData[playerid][i][e_attachment_db] != 0)
                        {
                            items++;

                            for (new j = 0; j < sizeof(attachments_data); j++)
                            {
                                if(gPlayerAttachmentData[playerid][i][e_attachment_model] == attachments_data[j][1][0])
                                {
                                    if(i > 0) strcat(info, "\n");
                                    strcat(info, attachments_data[j][3]);
                                    break;
                                }
                            }
                        }
                        else
                        {
                            if(i > 0) strcat(info, "\n");
                            strcat(info, "None");
                        }
                    }

                    if(items == 0)
                        return SendErrorMessage(playerid, "You do not have any items.");
                    SPD(playerid, DIALOG_ATTACHMENTS_TOGGLE, DSL, "Toggle Items", info, "Select", "Back");
                }
                case 3: {
                    new items = 0, info[250];
                    for (new i = 0; i < MAX_PLAYER_ATTACHED_ITEMS; i++)
                    {
                        if(gPlayerAttachmentData[playerid][i][e_attachment_db] != 0)
                        {
                            items++;

                            for (new j = 0; j < sizeof(attachments_data); j++)
                            {
                                if(gPlayerAttachmentData[playerid][i][e_attachment_model] == attachments_data[j][1][0])
                                {
                                    if(i > 0) strcat(info, "\n");
                                    strcat(info, attachments_data[j][3]);
                                    break;
                                }
                            }
                        }
                        else
                        {
                            if(i > 0) strcat(info, "\n");
                            strcat(info, "None");
                        }
                    }
                    if(items == 0) return SendErrorMessage(playerid, "You do not have any items.");
                    SPD(playerid, DIALOG_ATTACHMENTS_REMOVE, DSL, "Remove Items", info, "Delete", "Back");
                }
            }
        }
    }

    else if(dialogid == DIALOG_ATTACHMENTS_CATEGORY)
    {
		gPlayerSelectedCategory[playerid] = listitem;
        if(!response)
        {
            return -2;
        }

        new caption[32], buffer[64], info[1024];
        strcat(info, "Name\tPrice");
        for(new i = 0; i < sizeof(attachments_data); i++)
        {
			if(listitem == attachments_data[i][2][0])
			{
				format(buffer, sizeof(buffer), "\n%s\t$%d", attachments_data[i][3], attachments_data[i][0]);
            	strcat(info, buffer);
			}
        }
        format(caption, sizeof(caption), "Items->%s", attachments_category[listitem]);
        SPD(playerid, DIALOG_ATTACHMENTS_CATEGORY + (listitem+1), DIALOG_STYLE_TABLIST_HEADERS, caption, info, "Buy", "Back");

        return -2;
    }
    else if(dialogid == DIALOG_ATTACHMENTS_BONE)
    {
        new i = gPlayerSelectedIndex[playerid];
        gIsPlayerEditing[playerid] = true;
		gPlayerAttachmentData[playerid][i][e_attachment_bone] = (listitem + 1);

        SetPlayerAttachedObject(playerid, i, gPlayerAttachmentData[playerid][i][e_attachment_model], (listitem + 1));
        EditAttachedObject(playerid, i);

        return -2;
    }
    else if(dialogid == DIALOG_ATTACHMENTS_EDITBONE)
    {
        new i = gPlayerSelectedIndex[playerid];
        gIsPlayerEditing[playerid] = true;
        gPlayerAttachmentData[playerid][i][e_attachment_bone] = (listitem + 1);

        new Float:x = gPlayerAttachmentData[playerid][i][e_attachment_x];
        new Float:y = gPlayerAttachmentData[playerid][i][e_attachment_y];
        new Float:z = gPlayerAttachmentData[playerid][i][e_attachment_z];

        new Float:rx = gPlayerAttachmentData[playerid][i][e_attachment_rx];
        new Float:ry = gPlayerAttachmentData[playerid][i][e_attachment_ry];
        new Float:rz = gPlayerAttachmentData[playerid][i][e_attachment_rz];

        new Float:sx = gPlayerAttachmentData[playerid][i][e_attachment_sx];
        new Float:sy = gPlayerAttachmentData[playerid][i][e_attachment_sy];
        new Float:sz = gPlayerAttachmentData[playerid][i][e_attachment_sz];
        SetPlayerAttachedObject(playerid, i, gPlayerAttachmentData[playerid][i][e_attachment_model], (listitem + 1), x, y, z, rx, ry, rz, sx, sy, sz);
        EditAttachedObject(playerid, i);

        return -2;
    }
    else if(dialogid == DIALOG_ATTACHMENTS_REMOVE)
	{
		if(!response)
		{
			return SPD( playerid, DIALOG_ATTACHMENTS_MAIN, DSL, D_INFO_TEXT, "Buy Item\nEdit Item\nToggle Item\nDelete Item", "Select", "Close" );
		}
        if(gPlayerAttachmentData[playerid][listitem][e_attachment_db] == 0) 
        {
            SendErrorMessage(playerid, "You have no item in this slot.");
            new items = 0, info[250];
            for (new i = 0; i < MAX_PLAYER_ATTACHED_ITEMS; i++)
            {
                if(gPlayerAttachmentData[playerid][i][e_attachment_db] != 0)
                {
                    items++;

                    for (new j = 0; j < sizeof(attachments_data); j++)
                    {
                        if(gPlayerAttachmentData[playerid][i][e_attachment_model] == attachments_data[j][1][0])
                        {
                            if(i > 0) strcat(info, "\n");
                            strcat(info, attachments_data[j][3]);
                            break;
                        }
                    }
                }
                else
                {
                    if(i > 0) strcat(info, "\n");
                    strcat(info, "None");
                }
            }
            return SPD(playerid, DIALOG_ATTACHMENTS_REMOVE, DSL, "Remove Items", info, "Delete", "Back");
        }
		SendInfoMessage(playerid, "* You removed the item.");
		DeletePlayerAttachment(playerid, listitem);
	}
    else if(dialogid == DIALOG_ATTACHMENTS_TOGGLE)
    {
        if(!response)
        {
            return SPD( playerid, DIALOG_ATTACHMENTS_MAIN, DSL, D_INFO_TEXT, "Buy Item\nEdit Item\nToggle Item\nDelete Item", "Select", "Abort" );
        }
        if(gPlayerAttachmentData[playerid][listitem][e_attachment_db] == 0)
        { 
            SendErrorMessage(playerid, "You have no item in this slot.");
            new items = 0, info[250];
            for (new i = 0; i < MAX_PLAYER_ATTACHED_ITEMS; i++)
            {
                if(gPlayerAttachmentData[playerid][i][e_attachment_db] != 0)
                {
                    items++;

                    for (new j = 0; j < sizeof(attachments_data); j++)
                    {
                        if(gPlayerAttachmentData[playerid][i][e_attachment_model] == attachments_data[j][1][0])
                        {
                            if(i > 0) strcat(info, "\n");
                            strcat(info, attachments_data[j][3]);
                            break;
                        }
                    }
                }
                else
                {
                    if(i > 0) strcat(info, "\n");
                    strcat(info, "None");
                }
            }
            return SPD(playerid, DIALOG_ATTACHMENTS_TOGGLE, DSL, "Toggle Items", info, "Select", "Back");
        }
        gPlayerSelectedSlot[playerid]=listitem;
        //SPD( playerid, dialog_toggleitem , DSMSG, ""col_white"Toggle", "What do you want to do with this item?", "On", "Off");
        SPD(playerid, dialog_toggleitem, DSL, "Toggle", "{17DA3E}On\n{FF2A2A}Off", "Select", "Back");

    }
    else if(dialogid == dialog_toggleitem)
    {
        if(!response)
        {
            new items = 0, info[250];
            for (new i = 0; i < MAX_PLAYER_ATTACHED_ITEMS; i++)
            {
                if(gPlayerAttachmentData[playerid][i][e_attachment_db] != 0)
                {
                    items++;

                    for (new j = 0; j < sizeof(attachments_data); j++)
                    {
                        if(gPlayerAttachmentData[playerid][i][e_attachment_model] == attachments_data[j][1][0])
                        {
                            if(i > 0) strcat(info, "\n");
                            strcat(info, attachments_data[j][3]);
                            break;
                        }
                    }
                }
                else
                {
                    if(i > 0) strcat(info, "\n");
                    strcat(info, "None");
                }
            }
            return SPD(playerid, DIALOG_ATTACHMENTS_TOGGLE, DSL, "Toggle Items", info, "Select", "Back");
        }
        if(listitem==0)
        {
            SendInfoMessage(playerid, "* You have toggled on the selected item.");
           // TogglePlayerItem(playerid, gPlayerSelectedSlot[playerid], 1);
            TogglePlayerAttachment(playerid, gPlayerSelectedSlot[playerid], 1);
            new items = 0, info[250];
            for (new i = 0; i < MAX_PLAYER_ATTACHED_ITEMS; i++)
            {
                if(gPlayerAttachmentData[playerid][i][e_attachment_db] != 0)
                {
                    items++;

                    for (new j = 0; j < sizeof(attachments_data); j++)
                    {
                        if(gPlayerAttachmentData[playerid][i][e_attachment_model] == attachments_data[j][1][0])
                        {
                            if(i > 0) strcat(info, "\n");
                            strcat(info, attachments_data[j][3]);
                            break;
                        }
                    }
                }
                else
                {
                    if(i > 0) strcat(info, "\n");
                    strcat(info, "None");
                }
            }
            return SPD(playerid, DIALOG_ATTACHMENTS_TOGGLE, DSL, "Toggle Items", info, "Select", "Back");

        }
        else if(listitem==1)
        {
            SendInfoMessage(playerid, "* You have toggled off the selected item.");
            //TogglePlayerItem(playerid, gPlayerSelectedSlot[playerid], 0);
            TogglePlayerAttachment(playerid, gPlayerSelectedSlot[playerid], 0);
            new items = 0, info[250];
            for (new i = 0; i < MAX_PLAYER_ATTACHED_ITEMS; i++)
            {
                if(gPlayerAttachmentData[playerid][i][e_attachment_db] != 0)
                {
                    items++;

                    for (new j = 0; j < sizeof(attachments_data); j++)
                    {
                        if(gPlayerAttachmentData[playerid][i][e_attachment_model] == attachments_data[j][1][0])
                        {
                            if(i > 0) strcat(info, "\n");
                            strcat(info, attachments_data[j][3]);
                            break;
                        }
                    }
                }
                else
                {
                    if(i > 0) strcat(info, "\n");
                    strcat(info, "None");
                }
            }
            return SPD(playerid, DIALOG_ATTACHMENTS_TOGGLE, DSL, "Toggle Items", info, "Select", "Back");
        }

    }
    else if(dialogid == DIALOG_ATTACHMENTS_EDIT)
	{
		if(!response)
		{
			return SPD( playerid, DIALOG_ATTACHMENTS_MAIN, DSL, D_INFO_TEXT, "Buy Item\nEdit Item\nToggle Item\nDelete Item", "Select", "Abort" );
		}
        if(gPlayerAttachmentData[playerid][listitem][e_attachment_db] == 0)
        { 
            SendErrorMessage(playerid, "You have no item in this slot.");
            new items = 0, info[250];
            for (new i = 0; i < MAX_PLAYER_ATTACHED_ITEMS; i++)
            {
                if(gPlayerAttachmentData[playerid][i][e_attachment_db] != 0)
                {
                    items++;

                    for (new j = 0; j < sizeof(attachments_data); j++)
                    {
                        if(gPlayerAttachmentData[playerid][i][e_attachment_model] == attachments_data[j][1][0])
                        {
                            if(i > 0) strcat(info, "\n");
                            strcat(info, attachments_data[j][3]);
                            break;
                        }
                    }
                }
                else
                {
                    if(i > 0) strcat(info, "\n");
                    strcat(info, "None");
                }
            }
            return SPD(playerid, DIALOG_ATTACHMENTS_EDIT, DSL, "Edit items", info, "Edit", "Back");
        }
		gPlayerSelectedIndex[playerid] = listitem;
		SPD(playerid, DIALOG_ATTACHMENTS_EDITBONE, DIALOG_STYLE_TABLIST, "Choose the bone you want to attach the item to",
        "1\tSpine\n2\tHead\n3\tUpper left arm\n4\tRight upper arm\n5\tLeft hand\n6\tRight hand\n7\tLeft thigh\n8\tRight thigh\n9\tLeft foot\n10\tRight foot\n11\tRight calf\n12\tLeft calf\n13\tLower left arm\n14\tLower right arm\n15\tLeft Shoulder\n16\tRight shoulder\n17\tNeck\n18\tJaw",
        "Choose", "");
	}
    else if(dialogid >= (DIALOG_ATTACHMENTS_CATEGORY+1) && dialogid <= (DIALOG_ATTACHMENTS_CATEGORY+sizeof(attachments_category)))
    {
        if(!response)
        {
            new info[128];
            for(new i = 0; i < sizeof(attachments_category); i++)
            {
                if(i > 0) strcat(info, "\n");
                strcat(info, attachments_category[i]);
            }
            SPD(playerid, DIALOG_ATTACHMENTS_CATEGORY, DSL, "Items", info, "Select", "Back");
            return -2;
        }

        new free_index = -1;
        for (new i = 0; i < MAX_PLAYER_ATTACHED_ITEMS; i++)
        {
            if(gPlayerAttachmentData[playerid][i][e_attachment_db] == 0)
            {
                free_index = i;
                break;
            }
        }

		new category = 0, sc = gPlayerSelectedCategory[playerid];
		for (new i = 0; i < sizeof(attachments_data); i++)
		{
			if(attachments_data[i][2][0] == sc)
				break;
			category++;
		}

        if(free_index == -1)
        {
            SendErrorMessage(playerid, "You cannot use more clothing items.");
            return -2;
        }
		/*else if(GetPlayerCash(playerid) < attachments_data[(listitem+category)][0][0])
		{
			SendClientMessage(playerid, -1, "* Você não tem dinheiro suficiente.");
            return -2;
		}*/

		//GivePlayerCash(playerid, -attachments_data[(listitem+category)][0][0]);
        gPlayerAttachmentData[playerid][free_index][e_attachment_model] = attachments_data[(listitem+category)][1][0];
        gPlayerAttachmentData[playerid][free_index][e_attachment_index] = free_index;
        gPlayerSelectedIndex[playerid] = free_index;

        SPD(playerid, DIALOG_ATTACHMENTS_BONE, DIALOG_STYLE_TABLIST, "Choose the bone you want to attach the item to",
        "1\tSpine\n2\tHead\n3\tUpper left arm\n4\tRight upper arm\n5\tLeft hand\n6\tRight hand\n7\tLeft thigh\n8\tRight thigh\n9\tLeft foot\n10\tRight foot\n11\tRight calf\n12\tLeft calf\n13\tLower left arm\n14\tLower right arm\n15\tLeft Shoulder\n16\tRight shoulder\n17\tNeck\n18\tJaw",
        "Choose", "");

		SendInfoMessage(playerid, "* You bought an item!");

        gIsDialogVisible[playerid] = false;
        gPlayerTickCount[playerid] = GetTickCount() + 2500;

		new query[220];
        mysql_format(_dbConnector, query, sizeof(query), "INSERT INTO `attachments` (`user_id`, `Index`, `Model`, `Bone`, `X`, `Y`, `Z`, `RX`, `RY`, `RZ`, `SX`, `SY`, `SZ`, `Col1`, `Col2`) VALUES (%d, %d, %d, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0)", gPlayerData[ playerid ][ E_PLAYER_ID ], free_index, attachments_data[(listitem+category)][1]);
    	mysql_tquery(_dbConnector, query, "OnInsertAttachmentOnDatabase", "ii", playerid, free_index);
        return -2;
    }
    return 1;
}

hook OnPlayerModelSelection( playerid, response, listid, modelid) {
    if(!response) gIsPlayerEditing[playerid] = false;
    if( listid == dodacilist ) {
    
        if( response ) {
            new free_index = -1;
            for (new i = 0; i < MAX_PLAYER_ATTACHED_ITEMS; i++)
            {
                if(gPlayerAttachmentData[playerid][i][e_attachment_db] == 0)
                {
                    free_index = i;
                    break;
                }
            }
			if(isJobItem(playerid,modelid)) return SendErrorMessage(playerid, "You are not allowed to use this item.");
            new category = 0, sc = gPlayerSelectedCategory[playerid];
            for (new i = 0; i < sizeof(attachments_data); i++)
            {
                if(attachments_data[i][2][0] == sc)
                    break;
                category++;
            }

            if(free_index == -1)
            {
                SendInfoMessage(playerid, "* You cannot use more clothing items.");
                return -2;
            }
            //GivePlayerCash(playerid, -attachments_data[(listitem+category)][0][0]);

            gPlayerAttachmentData[playerid][free_index][e_attachment_model] = modelid;
            gPlayerAttachmentData[playerid][free_index][e_attachment_index] = free_index;
            gPlayerSelectedIndex[playerid] = free_index;

            SPD(playerid, DIALOG_ATTACHMENTS_BONE, DIALOG_STYLE_TABLIST, "Choose the bone you want to attach the item to",
            "1\tSpine\n2\tHead\n3\tUpper left arm\n4\tRight upper arm\n5\tLeft hand\n6\tRight hand\n7\tLeft thigh\n8\tRight thigh\n9\tLeft foot\n10\tRight foot\n11\tRight calf\n12\tLeft calf\n13\tLower left arm\n14\tLower right arm\n15\tLeft Shoulder\n16\tRight shoulder\n17\tNeck\n18\tJaw",
            "Choose", "");

            SendInfoMessage(playerid, "* You bought an item!");

            gIsDialogVisible[playerid] = false;
            gPlayerTickCount[playerid] = GetTickCount() + 2500;

            new slot = GetPVarInt(playerid, "SelectedClothingSlot");
            new query[256];
            mysql_format(_dbConnector, query, sizeof(query), "INSERT INTO `attachments` (`user_id`, `Index`, `Model`, `Bone`, `X`, `Y`, `Z`, `RX`, `RY`, `RZ`, `SX`, `SY`, `SZ`, `Col1`, `Col2`, `slot_id`) VALUES (%d, %d, %d, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, %d)", gPlayerData[ playerid ][ E_PLAYER_ID ], free_index, modelid,  gAttachmentSlot[playerid][slot][e_slot_db]);
            mysql_tquery(_dbConnector, query, "OnInsertAttachmentOnDatabase", "ii", playerid, free_index);
        }
    }
    return 1;
}
//------------------------------------------------------------------------------

public OnInsertAttachmentOnDatabase(playerid, index)
{
    gPlayerAttachmentData[playerid][index][e_attachment_db] = cache_insert_id();
    return 1;
}

CMD:clothing(playerid)
{
    if( IsPlayerInAnyVehicle( playerid ) ) return SendErrorMessage( playerid, "You can't while you're in the vehicle." );
    ShowDialog(playerid, DIALOG_ATTACHMENTS);
    return 1;
}
