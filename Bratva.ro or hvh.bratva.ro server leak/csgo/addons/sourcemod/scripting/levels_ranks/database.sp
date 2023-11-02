int			g_iPlayerCount,
			g_iPlayerPlace[MAXPLAYERS+1];
bool			g_bInitialized[MAXPLAYERS+1];
char			g_sSQL_CreateTable_SQLITE[] = "CREATE TABLE IF NOT EXISTS lvl_base (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, value INTEGER NOT NULL default 0, steam varchar(32) NOT NULL default '', name varchar(128) NOT NULL default '', rank INTEGER NOT NULL default 0, kills INTEGER NOT NULL default 0, deaths INTEGER NOT NULL default 0, shoots INTEGER NOT NULL default 0, hits INTEGER NOT NULL default 0, headshots INTEGER NOT NULL default 0, assists INTEGER NOT NULL default 0, vip INTEGER NOT NULL default 0, lastconnect INTEGER NOT NULL default 0);",
			g_sSQL_CreateTable_MYSQL[] = "CREATE TABLE IF NOT EXISTS lvl_base (id int(12) NOT NULL AUTO_INCREMENT, value int(12) NOT NULL default 0, steam varchar(32) NOT NULL default '', name varchar(128) NOT NULL default '', rank int(12) NOT NULL default 0, kills int(12) NOT NULL default 0, deaths int(12) NOT NULL default 0, shoots int(12) NOT NULL default 0, hits int(12) NOT NULL default 0, headshots int(12) NOT NULL default 0, assists int(12) NOT NULL default 0, vip int(12) NOT NULL default 0, lastconnect int(12) NOT NULL default 0, PRIMARY KEY (id)) CHARSET=utf8 COLLATE utf8_general_ci",
			g_sSQL_CreatePlayer[] = "INSERT INTO lvl_base (value, steam, name, lastconnect) VALUES (%d, '%s', '%s', %d);",
			g_sSQL_LoadPlayer[] = "SELECT value, rank, kills, deaths, shoots, hits, headshots, assists, vip FROM lvl_base WHERE steam = '%s';",
			g_sSQL_SavePlayer[] = "UPDATE lvl_base SET value = %d, name = '%s', rank = %d, kills = %d, deaths = %d, shoots = %d, hits = %d, headshots = %d, assists = %d, vip = %d, lastconnect = %d WHERE steam = '%s';",
			g_sSQL_RankPlayer[] = "SELECT value, steam FROM lvl_base ORDER BY value DESC;",
			g_sSQL_PurgeDB[] = "DELETE FROM lvl_base WHERE lastconnect < %d;",
			g_sSQL_GetCount[] = "SELECT * FROM lvl_base;",
			g_sSQL_CallTOP[] = "SELECT name, value FROM lvl_base ORDER BY value DESC LIMIT %i, 10;",
			g_sSQL_ResetFull[] = "DELETE FROM lvl_base;",
			g_sName[MAXPLAYERS+1][MAX_NAME_LENGTH],
			g_sSteamID[MAXPLAYERS+1][32];
Database	g_hDatabase = null;

void Connect_Database()
{
	char sIdent[16], sError[256];
	g_hDatabase = SQL_Connect("levels_ranks", false, sError, 256);
	if(g_hDatabase == null)
	{
		g_hDatabase = SQLite_UseDatabase("lr_base", sError, 256);
		if(g_hDatabase == null)
		{
			SetFailState("[%s Core] Could not connect to the database (%s)", PLUGIN_NAME, sError);
		}
	}

	DBDriver hDatabaseDriver = g_hDatabase.Driver;
	hDatabaseDriver.GetIdentifier(sIdent, sizeof(sIdent));

	SQL_LockDatabase(g_hDatabase);
	switch(sIdent[0])
	{
		case 's': if(!SQL_FastQuery(g_hDatabase, g_sSQL_CreateTable_SQLITE)) SetFailState("[%s Core] Connect_Database - could not create table in SQLite", PLUGIN_NAME);
		case 'm': if(!SQL_FastQuery(g_hDatabase, g_sSQL_CreateTable_MYSQL)) SetFailState("[%s Core] Connect_Database - could not create table in MySQL", PLUGIN_NAME);
		default: SetFailState("[%s Core] Connect_Database - type database is invalid", PLUGIN_NAME);
	}
	SQL_UnlockDatabase(g_hDatabase);

	g_hDatabase.SetCharset("utf8");
	g_iPlayerCount = GetCount_Players();
}

int GetCount_Players()
{
	DBResultSet hDatabaseResults = SQL_Query(g_hDatabase, g_sSQL_GetCount);
	if(hDatabaseResults == null)
	{
		LogError("[%s Core] GetCount_Players - error while working with data", PLUGIN_NAME);
		return 0;
	}

	int iRows = hDatabaseResults.RowCount;
	delete hDatabaseResults;
	return iRows;
}

void CreateDataPlayer(int iClient)
{
	if(!g_hDatabase)
	{
		SetFailState("[%s Core] CreateDataPlayer - database is invalid", PLUGIN_NAME);
	}

	if(iClient && IsClientInGame(iClient) && !IsFakeClient(iClient))
	{
		char sQuery[512], sSaveName[MAX_NAME_LENGTH * 2 + 1];
		g_hDatabase.Escape(g_sName[iClient], sSaveName, sizeof(sSaveName));
		switch(g_iTypeStatistics)
		{
			case 1: g_iClientData[iClient][0] = g_iEloStartCount;
			default: g_iClientData[iClient][0] = 0;
		}

		FormatEx(sQuery, sizeof(sQuery), g_sSQL_CreatePlayer, g_iClientData[iClient][0], g_sSteamID[iClient], sSaveName, GetTime());
		g_hDatabase.Query(SQL_CreateDataPlayer, sQuery, iClient);
	}
}

public void SQL_CreateDataPlayer(Database hDatabase, DBResultSet hDatabaseResults, const char[] sError, any iClient)
{
	if(hDatabaseResults == null)
	{
		LogError("[%s Core] SQL_CreateDataPlayer - error while working with data (%s)", PLUGIN_NAME, sError);
		return;
	}

	GetClientName(iClient, g_sName[iClient], MAX_NAME_LENGTH);
	g_iPlayerCount++;
	g_bInitialized[iClient] = true;
	g_iClientData[iClient][1] = 0;
	g_iClientData[iClient][2] = 0;
	g_iClientData[iClient][3] = 0;
	g_iClientData[iClient][4] = 0;
	g_iClientData[iClient][5] = 0;
	g_iClientData[iClient][6] = 0;
	g_iClientData[iClient][7] = 0;
	g_iClientData[iClient][8] = 0;
	CheckRank(iClient);
}

void LoadDataPlayer(int iClient)
{
	if(!g_hDatabase)
	{
		SetFailState("[%s Core] LoadDataPlayer - database is invalid", PLUGIN_NAME);
	}

	if(iClient && IsClientInGame(iClient) && !IsFakeClient(iClient))
	{
		char sQuery[512];
		GetClientAuthId(iClient, AuthId_Steam2, g_sSteamID[iClient], 32);
		GetClientName(iClient, g_sName[iClient], MAX_NAME_LENGTH);
		FormatEx(sQuery, sizeof(sQuery), g_sSQL_LoadPlayer, g_sSteamID[iClient]);
		g_hDatabase.Query(SQL_LoadDataPlayer, sQuery, iClient);
	}
}

public void SQL_LoadDataPlayer(Database hDatabase, DBResultSet hDatabaseResults, const char[] sError, any iClient)
{
	if(hDatabaseResults == null)
	{
		LogError("[%s Core] SQL_LoadDataPlayer - error while working with data (%s)", PLUGIN_NAME, sError);
		return;
	}
	
	if(hDatabaseResults.HasResults && hDatabaseResults.FetchRow())
	{
		for(int i = 0; i < 9; i++)
		{
			g_iClientData[iClient][i] = hDatabaseResults.FetchInt(i);
		}
		g_bInitialized[iClient] = true;
		RankDataPlayer(iClient);
		CheckRank(iClient);
	}
	else CreateDataPlayer(iClient);
}

void SaveDataPlayer_OnMapEnd()
{
	if(!g_hDatabase)
	{
		SetFailState("[%s Core] SaveDataPlayer_OnMapEnd - database is invalid", PLUGIN_NAME);
	}

	char sQuery[512], sSaveName[MAX_NAME_LENGTH * 2 + 1];
	Transaction hQuery = new Transaction();

	for(int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if(g_bInitialized[iClient] && IsClientInGame(iClient))
		{
			g_hDatabase.Escape(g_sName[iClient], sSaveName, sizeof(sSaveName));
			FormatEx(sQuery, 512, g_sSQL_SavePlayer, g_iClientData[iClient][0], sSaveName, g_iClientData[iClient][1], g_iClientData[iClient][2], g_iClientData[iClient][3], g_iClientData[iClient][4], g_iClientData[iClient][5], g_iClientData[iClient][6], g_iClientData[iClient][7], g_iClientData[iClient][8], GetTime(), g_sSteamID[iClient]);
			hQuery.AddQuery(sQuery);
		}
	}

	g_hDatabase.Execute(hQuery, _, Transaction_ErrorCallback, _, DBPrio_High);
}

void SaveDataPlayer(int iClient)
{
	if(!g_hDatabase)
	{
		SetFailState("[%s Core] SaveDataPlayer - database is invalid", PLUGIN_NAME);
	}

	if(g_bInitialized[iClient] && IsClientInGame(iClient))
	{
		char	sQuery[512], sSaveName[MAX_NAME_LENGTH * 2 + 1];
		g_hDatabase.Escape(g_sName[iClient], sSaveName, sizeof(sSaveName));
		FormatEx(sQuery, 512, g_sSQL_SavePlayer, g_iClientData[iClient][0], sSaveName, g_iClientData[iClient][1], g_iClientData[iClient][2], g_iClientData[iClient][3], g_iClientData[iClient][4], g_iClientData[iClient][5], g_iClientData[iClient][6], g_iClientData[iClient][7], g_iClientData[iClient][8], GetTime(), g_sSteamID[iClient]);
		g_hDatabase.Query(SQL_SaveDataPlayer, sQuery, iClient, DBPrio_High);
	}
}

public void SQL_SaveDataPlayer(Database db, DBResultSet dbRs, const char[] sError, any iClient)
{
	if(dbRs == null)
	{
		LogError("[%s Core] SQL_SaveDataPlayer - error while working with data (%s)", PLUGIN_NAME, sError);
		return;
	}
}

void RankDataPlayer(int iClient)
{
	if(!g_hDatabase)
	{
		SetFailState("[%s Core] RankDataPlayer - database is invalid", PLUGIN_NAME);
	}

	char sQuery[512];
	FormatEx(sQuery, 512, g_sSQL_RankPlayer, g_iClientData[iClient][0]);
	g_hDatabase.Query(SQL_RankDataPlayer, sQuery, iClient);
}

public void SQL_RankDataPlayer(Database db, DBResultSet dbRs, const char[] sError, any iClient)
{
	if(dbRs == null)
	{
		LogError("[%s Core] SQL_RankDataPlayer - error while working with data (%s)", PLUGIN_NAME, sError);
		return;
	}
	
	int i;
	char sSteam[32];
	while(dbRs.HasResults && dbRs.FetchRow())
	{
		i++;
		dbRs.FetchString(1, sSteam, sizeof(sSteam));
		if(StrEqual(sSteam, g_sSteamID[iClient], false))
		{
			g_iPlayerPlace[iClient] = i;
			break;
		}
	}
}

void PurgeDatabase()
{
	char sQuery[256];
	if(g_iDaysDeleteFromBase > 0)
	{
		FormatEx(sQuery, 256, g_sSQL_PurgeDB, GetTime() - (g_iDaysDeleteFromBase * 86400));
		g_hDatabase.Query(SQL_PurgeDatabase, sQuery);
	}
}

public void SQL_PurgeDatabase(Database db, DBResultSet dbRs, const char[] sError, any iClient)
{
	if(dbRs == null)
	{
		LogError("[%s Core] SQL_PurgeDatabase - error while working with data (%s)", PLUGIN_NAME, sError);
		return;
	}
}

void ResetStats()
{
	if(!g_hDatabase)
	{
		LogError("[%s Core] ResetStats - database is invalid", PLUGIN_NAME);
		return;
	}

	SQL_FastQuery(g_hDatabase, g_sSQL_ResetFull);
	for(int i = 1; i <= MaxClients; i++)
	{
		if(g_bInitialized[i])
		{
			g_bInitialized[i] = false;
			CreateDataPlayer(i);
		}
	}
	g_iPlayerCount = GetCount_Players();
}

public void Transaction_ErrorCallback(Database db, any data, int numQueries, const char[] sError, int failIndex, any[] queryData)
{
	LogError("[%s Core] Save EndRound - EndMap - error while working with data (%s)", PLUGIN_NAME, sError);
	return;
}