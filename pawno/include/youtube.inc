/*
Credits:
 
YoutubeInMP3 - API - http://youtubeinmp3.com/api/
Westie - strlib: explode() - http://forum.sa-mp.com/showthread.php?t=85697
Michael@Belgium - [MV]_Youtube
 
native PlayYoutubeVideoForPlayer(playerid,url[])
native StopYoutubeVideoForPlayer(playerid)
native ContainsYoutubeURL(string[])
native IsYouTubeVideoPlaying()
native GetLengthOfVideo()
native GetVideoTitle()
native GetVideoLink()
 
Update 1.1:
- Fixed where server crashes when you have a youtube link with more GET params
 
Update 1.2:
- Added callback OnYoutubeVideoFinished(playerid)
 
Update 2.0
- Added stock ContainsYoutubeURL, IsYouTubeVideoPlaying, GetLengthOfVideo, GetVideoTitle and GetVideoLink
- Improved code
 
*/
 
#include <a_http>
 
new bool:g_playing = false, g_title[256], g_duration = 0, g_link[64];
 
forward OnYoutubeVideoFinished(playerid);
forward SongFinished(playerid);
 
stock PlayYoutubeVideoForPlayer(playerid,url[])
{
        if(strfind(url,"&") != -1) strmid(url,url,0,strfind(url,"&"),128);
        format(g_link,sizeof(g_link),"%s",url);
        format(url,128,"youtubeinmp3.com/fetch/?api=advanced&video=%s",g_link);
        HTTP(playerid, HTTP_GET, url, "", "OnYoutubeResponse");
}
 
stock StopYoutubeVideoForPlayer(playerid)       return StopAudioStreamForPlayer(playerid);
stock ContainsYoutubeURL(string[])                      return (strfind(string,"youtube") != 1 && strfind(string,"watch?v=") != 1);
 
stock IsYouTubeVideoPlaying()   return g_playing;
stock GetLengthOfVideo()                return g_duration;
stock GetVideoTitle()                   return g_title;
stock GetVideoLink()                    return g_link;
 
forward OnYoutubeResponse(playerid, response_code, data[]);
public OnYoutubeResponse(playerid, response_code, data[])
{
        if(response_code == 200)
        {
                new content[3][256],stream[256],string[256];
                new hours,minutes,seconds,tmp_seconds[8];
 
                explode(content,data,"<br />");
                strmid(tmp_seconds,content[1],8,strlen(content[1]));
                strmid(stream,content[2],6,strlen(content[2]));
 
                g_duration = strval(tmp_seconds);
                g_title = content[0];
 
                formatSeconds(g_duration,hours,minutes,seconds);
               
                format(string,sizeof(string),"{0049FF}[Now playing] {00c9ff}%s (Duration: %02d:%02d:%02d)",GetVideoTitle(),hours,minutes,seconds);
                SendClientMessage(playerid,-1,string);
 
                PlayAudioStreamForPlayer(playerid,stream);
                g_playing = true;
               
                SetTimerEx("SongFinished",(g_duration+5)*1000,false,"i",playerid);
        }
        else
        {
                new error[128];
                format(error,sizeof(error),"{0049FF}[ERROR] {00c9ff}An error has occured: %s (%d)",GetError(response_code),response_code);
                SendClientMessage(playerid,0xFF0000FF,error);
        }
}
 
public SongFinished(playerid)
{
    g_playing = false;
        CallLocalFunction("OnYoutubeVideoFinished","i",playerid);
}
 
stock GetError(val)
{
        new error[32];
        switch(val)
        {
                case 1: error = "Bad host";
                case 2: error = "No socket";
                case 3: error = "Can't connect";
                case 4: error = "Can't write";
                case 5: error = "Content too big";
                case 6: error = "Malformed response";
                case 300..308: error = "Redirection";
                case 400..499: error = "Client error";
                case 500..599: error = "Server error";
        }
        return error;
}
 
stock formatSeconds(seconds, &hours_left, &minutes_left, &seconds_left)
{
    hours_left = seconds/60/60;
    minutes_left = (seconds - hours_left*60*60)/60;
    seconds_left = (seconds - hours_left*60*60 - minutes_left*60);
}
 
stock explode(aExplode[][], const sSource[], const sDelimiter[] = " ", iVertices = sizeof aExplode, iLength = sizeof aExplode[])
{
        new
                iNode,
                iPointer,
                iPrevious = -1,
                iDelimiter = strlen(sDelimiter);
 
        while(iNode < iVertices)
        {
                iPointer = strfind(sSource, sDelimiter, false, iPointer);
 
                if(iPointer == -1)
                {
                        strmid(aExplode[iNode], sSource, iPrevious, strlen(sSource), iLength);
                        break;
                }
                else
                {
                        strmid(aExplode[iNode], sSource, iPrevious, iPointer, iLength);
                }
 
                iPrevious = (iPointer += iDelimiter);
                ++iNode;
        }
 
        return iPrevious;
}