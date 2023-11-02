public Action:DelKey_CMD(iClient, args)
{
	if(args != 1)
	{
		ReplyToCommand(iClient, "[VIP] %t", "DEL_KEY_ERROR_USAGE");
		return Plugin_Handled;
	}
	
	decl String:sKey[MAX_KEY_LENGTH];
	GetCmdArg(1, sKey, sizeof(sKey));
	if(FindStringInArray(g_hKeysArray, sKey) == -1)
	{
		ReplyToCommand(iClient, "[VIP] %t", "ERROR_KEY_NOT_EXISTS");
		return Plugin_Handled;
	}
	
	DeleteKey(sKey, iClient);

	return Plugin_Handled;
}

public Action:ClearKeys_CMD(iClient, args)
{
	SQL_TQuery(g_hDatabase, SQL_Callback_DropTable, "DROP TABLE `vip_keys`;", iClient == 0 ? 0:GetClientUserId(iClient));

	return Plugin_Handled;
}

public SQL_Callback_DropTable(Handle:hOwner, Handle:hQuery, const String:sError[], any:UserID)
{
	if (hQuery == INVALID_HANDLE || sError[0])
	{
		LogError("SQL_Callback_DropTable: %s", sError);
		return;
	}

	ClearArray(g_hKeysArray);

	CreateTables();
	
	decl iClient;
	if(UserID > 0)
	{
		iClient = GetClientOfUserId(UserID);
		if(iClient == 0)
		{
			return;
		}
	}

	ReplyToCommand(iClient, "[VIP] %t", "ALL_KEYS_DELETED_SUCCESSFULLY");
}

DeleteKey(const String:sKey[], iOwner = -1)
{
	
	decl String:sQuery[256], Handle:hPack;
	FormatEx(sQuery, sizeof(sQuery), "DELETE FROM `vip_keys` WHERE `key` = '%s';", sKey);
	hPack = CreateDataPack();
	WritePackString(hPack, sKey);
	if(iOwner > 0)
	{
		WritePackCell(hPack, GetClientUserId(iOwner));
	}
	else
	{
		WritePackCell(hPack, iOwner);
	}

	SQL_TQuery(g_hDatabase, SQL_Callback_DelKey, sQuery, hPack);
}

public SQL_Callback_DelKey(Handle:hOwner, Handle:hQuery, const String:sError[], any:hPack)
{
	if (hQuery == INVALID_HANDLE || sError[0])
	{
		LogError("SQL_Callback_DelKey: %s", sError);
		CloseHandle(hPack);
		return;
	}

	if(SQL_GetAffectedRows(hOwner))
	{
		ResetPack(hPack);
		decl String:sKey[MAX_KEY_LENGTH], iClient;
		ReadPackString(hPack, sKey, sizeof(sKey));

		iClient = FindStringInArray(g_hKeysArray, sKey);
		if(iClient != -1)
		{
			RemoveFromArray(g_hKeysArray, iClient);
		}

		iClient = ReadPackCell(hPack);

		if(iClient > 0)
		{
			iClient = GetClientOfUserId(iClient);
			if(iClient == 0)
			{
				iClient = -1;
			}
		}

		if(iClient != -1)
		{
			ReplyToCommand(iClient, "[VIP] %t", "KEY_DELETED_SUCCESSFULLY", sKey);
		}
	}

	CloseHandle(hPack);
}