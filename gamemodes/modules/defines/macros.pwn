#define SetDynamicObjectModel(%1,%2)			Streamer::SetIntData(STREAMER_TYPE_OBJECT,(%1),E_STREAMER_MODEL_ID,(%2))
#define GetDynamicObjectModel(%1)				Streamer::GetIntData(STREAMER_TYPE_OBJECT,(%1),E_STREAMER_MODEL_ID)
#define SetDynamicObjectVW(%1,%2)				Streamer::SetIntData(STREAMER_TYPE_OBJECT,(%1),E_STREAMER_WORLD_ID,(%2))
#define GetDynamicObjectVW(%1)					Streamer::GetIntData(STREAMER_TYPE_OBJECT,(%1),E_STREAMER_WORLD_ID)
#define GetDynamic3DTextVW(%1)					Streamer::GetIntData(STREAMER_TYPE_3D_TEXT_LABEL,(%1),E_STREAMER_WORLD_ID)
#define SetDynamic3DTextVW(%1,%2)				Streamer::SetIntData(STREAMER_TYPE_3D_TEXT_LABEL,(%1),E_STREAMER_WORLD_ID,(%2))
#define GetDynamic3DTextPos(%0,%1,%2,%3)		Streamer::GetItemPos(STREAMER_TYPE_3D_TEXT_LABEL,(%0),(%1),(%2),(%3))
#define SetDynamic3DTextPos(%0,%1,%2,%3)		Streamer::SetItemPos(STREAMER_TYPE_3D_TEXT_LABEL,(%0),(%1),(%2),(%3))
#define SetDynamicActorModel(%1,%2)				Streamer::SetIntData(STREAMER_TYPE_ACTOR,(%1),E_STREAMER_MODEL_ID,(%2))
#define RandomEx(%0,%1) (random(%1 - %0 + 1) + %0)

#define SendErrorMessage(%0,%1) SendClientMessageEx(%0, ERROR, %1) 

#define SendJobMessage(%0,%1) SendClientMessageEx(%0, JOBMSG, %1) 

#define SendInfoMessage(%0,%1) SendClientMessageEx(%0, INFO, %1)

#define SendYellowMessage(%0,%1) SendClientMessageEx(%0, 0xE4DF99FF, %1)
	
#define SendGreenMessage(%0,%1) SendClientMessageEx(%0, 0x00CD7AFF, %1)

#define SendUsageMessage(%0,%1) SendClientMessageEx(%0, ERROR, "Correct usage: "%1)

#define PROPERTY_OFFSET(%0) \
			((((%0) * ((%0) << 1)) << 2) + 65536)

#define UpdatePVarInt(%0,%1,%2)     SetPVarInt(%0, %1, GetPVarInt(%0, %1) + %2)
#define ClearChat(%0,%1)  for( new n=0; n<%1; n++) SendClientMessage(%0, -1, " ")

#define HOLDING(%0) 							((newkeys & (%0)) == (%0))
#if !defined PRESSED
	#define PRESSED(%0) 						(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#endif

#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

#define gettimeEx(%0,%1,%2) gettime(%0,%1,%2); %0 -= 0
#define Min(%0) %0*60	
#define Sec(%0) %0		
#define IsValidWeapon(%0) (%0>=1 && %0<=18 || %0>=21 && %0<=46)