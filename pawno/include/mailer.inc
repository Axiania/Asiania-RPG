#include <a_samp>
#include <a_http>

#if ( !defined MAILER_MAX_MAIL_SIZE )
	#define MAILER_MAX_MAIL_SIZE  (1024)
#endif

#if ( !defined MAILER_URL )
	#error Please define MAILER_URL before including the mailer include.
#endif

stock SendMail( const szReceiver[ ], const szSenderMail[ ], const szSenderName[ ], const szSubject[ ], const szMessage[ ] )
{
	new
		szBuffer[ MAILER_MAX_MAIL_SIZE ] = "t=",
		iPos    = strlen( szBuffer ),
		iLength = strlen( szReceiver )
	;
	
	memcpy( szBuffer, szReceiver, iPos * 4, ( iLength + 1 ) * 4 );
	
	StringURLEncode( szBuffer[ iPos ], 1024 - iPos );
	
	strcat( szBuffer, "&f=" );
	
	iPos    = strlen( szBuffer );
	iLength = strlen( szSenderName );
	
	memcpy( szBuffer, szSenderName, iPos * 4, ( iLength + 1 ) * 4 );
	
	StringURLEncode( szBuffer[ iPos ], 1024 - iPos );
	
	strcat( szBuffer, "&n=" );
	
	iPos    = strlen( szBuffer );
	iLength = strlen( szSenderMail );
	
	memcpy( szBuffer, szSenderMail, iPos * 4, ( iLength + 1 ) * 4 );
	
	StringURLEncode( szBuffer[ iPos ], 1024 - iPos );
	
	strcat( szBuffer, "&s=" );
	
	iPos    = strlen( szBuffer );
	iLength = strlen( szSubject );
	
	memcpy( szBuffer, szSubject, iPos * 4, ( iLength + 1 ) * 4 );
	
	StringURLEncode( szBuffer[ iPos ], 1024 - iPos );
	
	strcat( szBuffer, "&m=" );
	
	iPos    = strlen( szBuffer );
	iLength = strlen( szMessage );
	
	memcpy( szBuffer, szMessage, iPos * 4, ( iLength + 1 ) * 4 );
	
	StringURLEncode( szBuffer[ iPos ], 1024 - iPos );
	
	HTTP( 0xD00D, HTTP_POST, MAILER_URL, szBuffer, "OnMailScriptResponse" );
}

forward OnMailScriptResponse( iIndex, iResponseCode, const szData[ ] );
public  OnMailScriptResponse( iIndex, iResponseCode, const szData[ ] )
{
	if ( szData[ 0 ] )
		printf( "Mailer script says: %s", szData );
}

stock StringURLEncode( szString[ ], iSize = sizeof( szString ) )
{
	for ( new i = 0, l = strlen( szString ); i < l; i++ )
	{
		switch ( szString[ i ] )
		{
			case '!', '(', ')', '\'', '*',
			     '0' .. '9',
			     'A' .. 'Z',
			     'a' .. 'z':
			{
				continue;
			}
			
			case ' ':
			{
				szString[ i ] = '+';
				
				continue;
			}
		}
		
		new
			s_szHex[ 8 ]
		;
		
		if ( i + 3 >= iSize )
		{
			szString[ i ] = EOS;
			
			break;
		}
		
		if ( l + 3 >= iSize )
			szString[ iSize - 3 ] = EOS;
		
		format( s_szHex, sizeof( s_szHex ), "%02h", szString[ i ] );
		
		szString[ i ] = '%';
		
		strins( szString, s_szHex, i + 1, iSize );
		
		l += 2;
		i += 2;
		
		if ( l > iSize - 1 )
			l = iSize - 1;
	}
}