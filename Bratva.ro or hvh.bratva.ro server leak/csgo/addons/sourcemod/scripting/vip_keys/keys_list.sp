public Action:KeysList_CMD(iClient, args)
{
	SQL_TQuery(g_hDatabase, SQL_Callback_KeysList, "SELECT `key`, `group`, `time` FROM `vip_keys`;", iClient == 0 ? 0:GetClientUserId(iClient));

	return Plugin_Handled;
}

public SQL_Callback_KeysList(Handle:hOwner, Handle:hQuery, const String:sError[], any:UserID)
{
	if (hQuery == INVALID_HANDLE || sError[0])
	{
		LogError("SQL_Callback_KeysList: %s", sError);
		return;
	}

	decl iClient;
	if(UserID > 0)
	{
		iClient = GetClientOfUserId(UserID);
		if(iClient == 0)
		{
			return;
		}
	}
	else
	{
		iClient = UserID;
	}

	if(SQL_GetRowCount(hQuery) > 0)
	{
		ReplyToCommand(iClient, "%t", "KEY_LIST_TITLE");
		decl String:sKey[MAX_KEY_LENGTH], String:sGroup[MAX_GROUP_LENGTH], iCount;
		iCount = 0;
		while(SQL_FetchRow(hQuery))
		{
			SQL_FetchString(hQuery, 0, sKey, sizeof(sKey));
			SQL_FetchString(hQuery, 1, sGroup, sizeof(sGroup));
			ReplyToCommand(iClient, "%i. %s\t%s\t%i", ++iCount, sKey, sGroup, SQL_FetchInt(hQuery, 2));
		}
	}
	else
	{
		ReplyToCommand(iClient, "[VIP] %t", "KEY_LIST_NO_KEYS");
	}
}

public Action:KeysDump_CMD(iClient, args)
{
	SQL_TQuery(g_hDatabase, SQL_Callback_KeysDump, "SELECT `key`, `group`, `time` FROM `vip_keys`;", iClient == 0 ? 0:GetClientUserId(iClient));

	return Plugin_Handled;
}

public SQL_Callback_KeysDump(Handle:hOwner, Handle:hQuery, const String:sError[], any:UserID)
{
	if (hQuery == INVALID_HANDLE || sError[0])
	{
		LogError("SQL_Callback_KeysDump: %s", sError);
		return;
	}

	decl iClient;
	if(UserID > 0)
	{
		iClient = GetClientOfUserId(UserID);
		if(iClient == 0)
		{
			iClient = -1;
		}
	}
	else
	{
		iClient = UserID;
	}

	if(SQL_GetRowCount(hQuery) > 0)
	{
		if(iClient != -1)
		{
			ReplyToCommand(iClient, "%t", "KEY_LIST_TITLE");
		}
		new Handle:hFile = OpenFile("addons/sourcemod/logs/VIP_KEYS/vip_keys_dump.txt", "w+");
		if(hFile != INVALID_HANDLE)
		{
			decl String:sKey[MAX_KEY_LENGTH], String:sGroup[MAX_GROUP_LENGTH], iTime, iCount;
			iCount = 0;
			while(SQL_FetchRow(hQuery))
			{
				SQL_FetchString(hQuery, 0, sKey, sizeof(sKey));
				SQL_FetchString(hQuery, 1, sGroup, sizeof(sGroup));
				iTime = SQL_FetchInt(hQuery, 2);
				if(iClient != -1)
				{	
					ReplyToCommand(iClient, "%i. %s\t%s\t%i", ++iCount, sKey, sGroup, iTime);
				}
				WriteFileLine(hFile, "%s\t%s\t%i", sKey, sGroup, iTime);
			}
			CloseHandle(hFile);
		}
	}
	else
	{
		if(iClient != -1)
		{
			ReplyToCommand(iClient, "[VIP] %t", "KEY_LIST_NO_KEYS");
		}
	}
}