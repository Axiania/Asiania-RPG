/****************************************************************************************************
 *                                                                                                  *
 *                                       Route Random Points                                        *
 *                                                                                                  *
 * Copyright © 2019 Abyss Morgan. All rights reserved.                                              *
 * Contributors: Gamer_Z, NaS                                                                       *
 *                                                                                                  *
 * Website:  adm.ct8.pl                                                                             *
 * Download: adm.ct8.pl/r/download                                                                  *
 *                                                                                                  *
 * Plugins: None                                                                                    *
 * Modules: None                                                                                    *
 * Attributes: None                                                                                 *
 * Data Base: /scriptfiles/route_rand.bin                                                           *
 *                                                                                                  *
 * File Version: 1.0.0                                                                              *
 *                                                                                                  *
 * Functions:                                                                                       *
 * GetRandomRoutePoint(const file_name[],&Float:x,&Float:y,&Float:z,max_points=MAX_ROUTE_RANDOM);   *
 * Route_DumpTempData(const input[],const output[]); //file generator (you don't need this :D)      *
 *                                                                                                  *
 ****************************************************************************************************/

#if defined _route_rand
	#endinput
#endif
#define _route_rand

#if !defined MAX_ROUTE_RANDOM
	#define MAX_ROUTE_RANDOM				(27608)
#endif

#define INVALID_ROUTE_ID					(-1)

//BitFunctions.inc
#define RR_ExtractValue(%0,%1,%2,%3,%4)		((%1) = (((%0) & 0xFF000000) >>> 24),(%2) = (((%0) & 0x00FF0000) >>> 16),(%3) = (((%0) & 0x0000FF00) >>> 8),(%4) = ((%0) & 0x000000FF))
#define RR_ExtractFloat(%0,%1,%2,%3,%4)		((%1) = (((_:%0) & 0xFF000000) >>> 24),(%2) = (((_:%0) & 0x00FF0000) >>> 16),(%3) = (((_:%0) & 0x0000FF00) >>> 8),(%4) = ((_:%0) & 0x000000FF))

#define RR_MergeValue(%0,%1,%2,%3,%4)		((%0) = (((%1) << 24) | ((%2) << 16) | ((%3) << 8) | (%4)))
#define RR_MergeFloat(%0,%1,%2,%3,%4)		((%0) = Float:(((%1) << 24) | ((%2) << 16) | ((%3) << 8) | (%4)))

stock GetRandomRoutePoint(const file_name[],&Float:x,&Float:y,&Float:z,max_points=MAX_ROUTE_RANDOM){
	if(!fexist(file_name)) return INVALID_ROUTE_ID;
	new File:inpf = fopen(file_name,io_read);
	if(!inpf) return INVALID_ROUTE_ID;
	new routeid = random(max_points);
	fseek(inpf,routeid*12,seek_start);
	RR_MergeFloat(x,fgetchar(inpf,0,false),fgetchar(inpf,0,false),fgetchar(inpf,0,false),fgetchar(inpf,0,false));
	RR_MergeFloat(y,fgetchar(inpf,0,false),fgetchar(inpf,0,false),fgetchar(inpf,0,false),fgetchar(inpf,0,false));
	RR_MergeFloat(z,fgetchar(inpf,0,false),fgetchar(inpf,0,false),fgetchar(inpf,0,false),fgetchar(inpf,0,false));
	fclose(inpf);
	return routeid;
}

//file generator (you don't need this :D)
stock Route_DumpTempData(const input[],const output[]){
	if(fexist(output)) fremove(output);
	new File:inpf = fopen(input,io_read),
		File:outf = fopen(output,io_write),
		line[256];
	
	if(!outf) return 0;
	if(!inpf) return 0;
	
	new int1, int2, int3, int4,
		Float:x,Float:y,Float:z;
	
	while(fread(inpf,line)){
		if(!sscanf(line,"fff",x,y,z)){
			RR_ExtractFloat(x,int1,int2,int3,int4);
			fputchar(outf,int1,false), fputchar(outf,int2,false), fputchar(outf,int3,false), fputchar(outf,int4,false);
			
			RR_ExtractFloat(y,int1,int2,int3,int4);
			fputchar(outf,int1,false), fputchar(outf,int2,false), fputchar(outf,int3,false), fputchar(outf,int4,false);
			
			RR_ExtractFloat(z,int1,int2,int3,int4);
			fputchar(outf,int1,false), fputchar(outf,int2,false), fputchar(outf,int3,false), fputchar(outf,int4,false);
		}
	}
	fclose(inpf);
	fclose(outf);
	return 1;
}

//EOF