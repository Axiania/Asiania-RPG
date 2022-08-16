//=================================[ Defines ]====================================

#define host
 
#if defined host
	#define MYSQL_WRITE_LOG LOG_ERROR
    #define MYSQL_HOST "localhost"
    #define MYSQL_USER "root"
    #define MYSQL_PASS ""
    #define MYSQL_DB "magic"
#endif

#if defined host_test
//	#define MYSQL_WRITE_LOG LOG_ALL
    #define MYSQL_HOST "localhost"
    #define MYSQL_USER "root"
    #define MYSQL_PASS "2020meanwhilesmr434"
    #define MYSQL_DB "testmeanwhile"
#endif

#if defined kucni
//	#define MYSQL_WRITE_LOG LOG_ERROR
    #define MYSQL_HOST "127.0.0.1"
    #define MYSQL_USER "server_5059"
    #define MYSQL_PASS "e3pnl81w97"
    #define MYSQL_DB "server_5059_asian"
#endif


new _dbConnector, sql_str[ 128 ];

//=================================[ Stocks ]====================================

stock Mysql_Connect() {

	_dbConnector = mysql_connect( dini_Get("Mysql.ini", "Host"), dini_Get("Mysql.ini", "User"), dini_Get("Mysql.ini", "Database"), dini_Get("Mysql.ini", "Password"), 3306, true );
	if( mysql_errno( _dbConnector ) != 0 ){
		return printf("Connection failed %s@%s -> %s", dini_Get("Mysql.ini", "User"), dini_Get("Mysql.ini", "Host"), dini_Get("Mysql.ini", "Database"));
	} else {

		printf("Connection successful %s@%s -> %s", dini_Get("Mysql.ini", "User"), dini_Get("Mysql.ini", "Host"), dini_Get("Mysql.ini", "Database"));
		mysql_pquery( _dbConnector, "UPDATE `users` SET `isonline` = 0 WHERE `user_id` > 0" );
		return true;
	}
}


//=================================[ ALS ]====================================

public OnGameModeInit( )
{
	if(!dini_Exists("Mysql.ini"))
	{
		dini_Set("Mysql.ini", "Host", "localhost");
		dini_Set("Mysql.ini", "User", "root");
		dini_Set("Mysql.ini", "Password", "");
		dini_Set("Mysql.ini", "Database", "magic");
	}
	Mysql_Connect();
	mysql_log(MYSQL_WRITE_LOG);
	#if defined 	als_mysql_OnGameModeInit
		return 	als_mysql_OnGameModeInit( );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif

#define OnGameModeInit 	als_mysql_OnGameModeInit
#if defined 	als_mysql_OnGameModeInit
	forward 	als_mysql_OnGameModeInit( );
#endif

public OnGameModeExit( )
{
	mysql_close(_dbConnector);
	#if defined 	als_mysql_OnGameModeExit
		return 	als_mysql_OnGameModeExit( );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeExit
	#undef OnGameModeExit
#else
	#define _ALS_OnGameModeExit
#endif

#define OnGameModeExit 	als_mysql_OnGameModeExit
#if defined 	als_mysql_OnGameModeExit
	forward 	als_mysql_OnGameModeExit( );
#endif


//=================================[ END OF MODULE ]====================================	
