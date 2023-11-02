public Action:AddKey_CMD(iClient, args)
{
	if(args < 3)
	{
		ReplyToCommand(iClient, "[VIP] %t", "ADD_KEY_ERROR_USAGE");
		return Plugin_Handled;
	}
	
	decl String:sKey[MAX_KEY_LENGTH];
	GetCmdArg(1, sKey, sizeof(sKey));
	if(FindStringInArray(g_hKeysArray, sKey) != -1)
	{
		ReplyToCommand(iClient, "[VIP] %t", "ADD_KEY_ERROR_KEY_ALREADY_EXISTS");
		return Plugin_Handled;
	}

	decl String:sGroup[MAX_GROUP_LENGTH], iTime;
	GetCmdArg(3, sGroup, sizeof(sGroup));
	StringToIntEx(sGroup, iTime);
	if(iTime < 0)
	{
		ReplyToCommand(iClient, "[VIP] %t", "ADD_KEY_ERROR_INVALID_TIME");
		return Plugin_Handled;
	}
	
	if(iTime > 0)
	{
		iTime = VIP_TimeToSeconds(iTime);
	}
	
	decl iLifeTime;
	if(args == 4)
	{
		GetCmdArg(4, sGroup, sizeof(sGroup));
		StringToIntEx(sGroup, iLifeTime);
		if(iLifeTime < 0)
		{
			ReplyToCommand(iClient, "[VIP] %t", "ADD_KEY_ERROR_INCORRECT_LIFETIME");
			return Plugin_Handled;
		}
		
		if(iLifeTime > 0)
		{
			iLifeTime = VIP_TimeToSeconds(iLifeTime);
		}
	}
	else
	{
		iLifeTime = 0;
	}

	GetCmdArg(2, sGroup, sizeof(sGroup));
	if(VIP_IsValidVIPGroup(sGroup) == false)
	{
		ReplyToCommand(iClient, "[VIP] %t", "ADD_KEY_ERROR_INCORRECT_GROUP");
		return Plugin_Handled;
	}

	decl String:sQuery[256], Handle:hDataPack;
	FormatEx(sQuery, sizeof(sQuery), "INSERT INTO `vip_keys` (`key`, `group`, `time`, `created`, `lifetime`) VALUES ('%s', '%s', '%i', '%i', '%i');", sKey, sGroup, iTime, GetTime(), iLifeTime);
	hDataPack = CreateDataPack();
	WritePackCell(hDataPack, iClient == 0 ? 0:GetClientUserId(iClient));
	WritePackString(hDataPack, sKey);

	SQL_TQuery(g_hDatabase, SQL_Callback_AddKey, sQuery, hDataPack);

	return Plugin_Handled;
}

public Action:GenKeys_CMD(iClient, args)
{
	if(args < 3)
	{
		ReplyToCommand(iClient, "[VIP] %t", "GEN_KEYS_ERROR_USAGE");
		return Plugin_Handled;
	}
	
	decl String:sGroup[MAX_GROUP_LENGTH], iAmount;
	GetCmdArg(1, sGroup, sizeof(sGroup));
	StringToIntEx(sGroup, iAmount);
	if(iAmount < 1 || iAmount > 100)
	{
		ReplyToCommand(iClient, "[VIP] %t", "GEN_KEYS_ERROR_INCORRECT_AMOUNT");
		return Plugin_Handled;
	}

	decl iTime;
	GetCmdArg(3, sGroup, sizeof(sGroup));
	StringToIntEx(sGroup, iTime);
	if(iTime < 0)
	{
		ReplyToCommand(iClient, "[VIP] %t", "ADD_KEY_ERROR_INVALID_TIME");
		return Plugin_Handled;
	}

	if(iTime > 0)
	{
		iTime = VIP_TimeToSeconds(iTime);
	}
	
	decl iLifeTime;
	if(args == 4)
	{
		GetCmdArg(4, sGroup, sizeof(sGroup));
		StringToIntEx(sGroup, iLifeTime);
		if(iLifeTime < 0)
		{
			ReplyToCommand(iClient, "[VIP] %t", "ADD_KEY_ERROR_INCORRECT_LIFETIME");
			return Plugin_Handled;
		}
		
		if(iLifeTime > 0)
		{
			iLifeTime = VIP_TimeToSeconds(iLifeTime);
		}
	}
	else
	{
		iLifeTime = 0;
	}

	GetCmdArg(2, sGroup, sizeof(sGroup));
	if(VIP_IsValidVIPGroup(sGroup) == false)
	{
		ReplyToCommand(iClient, "[VIP] %t", "ADD_KEY_ERROR_INCORRECT_GROUP");
		return Plugin_Handled;
	}
	
	decl String:sQuery[256], String:sKey[MAX_KEY_LENGTH], Handle:hDataPack, UserID, iCurrentTime;
	
	if(iClient)
	{
		UserID = GetClientUserId(iClient);
	}
	else
	{
		UserID = 0;
	}

	iCurrentTime = GetTime();

	while(iAmount > 0)
	{
		iAmount--;

		UTIL_GenerateKey(sKey, sizeof(sKey), g_CVAR_iKeyLength);

		FormatEx(sQuery, sizeof(sQuery), "INSERT INTO `vip_keys` (`key`, `group`, `time`, `created`, `lifetime`) VALUES ('%s', '%s', '%i', '%i', '%i');", sKey, sGroup, iTime, iCurrentTime, iLifeTime);
		hDataPack = CreateDataPack();
		WritePackString(hDataPack, sKey);
		WritePackCell(hDataPack, UserID);

		SQL_TQuery(g_hDatabase, SQL_Callback_AddKey, sQuery, hDataPack);
	}

	return Plugin_Handled;
}

public SQL_Callback_AddKey(Handle:hOwner, Handle:hQuery, const String:sError[], any:hDataPack)
{
	if (hQuery == INVALID_HANDLE || sError[0])
	{
		LogError("SQL_Callback_AddKey: %s", sError);
		CloseHandle(hDataPack);
		return;
	}
	
	if(SQL_GetAffectedRows(hOwner))
	{
		ResetPack(hDataPack);
		decl String:sKey[MAX_KEY_LENGTH], iClient;
		ReadPackString(hDataPack, sKey, sizeof(sKey));

		PushArrayString(g_hKeysArray, sKey);
		
		iClient = ReadPackCell(hDataPack);
		if(iClient)
		{
			iClient = GetClientOfUserId(iClient);
			if(iClient == 0)
			{
				CloseHandle(hDataPack);
				return;
			}
		}

		ReplyToCommand(iClient, "[VIP] %t", "KEY_SUCCESSFULLY_ADDED", sKey);
	}

	CloseHandle(hDataPack);
}

UTIL_GenerateKey(String:sKey[], iMaxLength, iLen)
{
	static const Chars[] =
	{
		'0',
		'1',
		'2',
		'3',
		'4',
		'5',
		'6',
		'7',
		'8',
		'9',
		'q',
		'w',
		'e',
		'r',
		't',
		'y',
		'u',
		'i',
		'o',
		'p',
		'a',
		's',
		'd',
		'f',
		'g',
		'h',
		'j',
		'k',
		'l',
		'z',
		'x',
		'c',
		'v',
		'b',
		'n',
		'm',
		'Q',
		'W',
		'E',
		'R',
		'T',
		'Y',
		'U',
		'I',
		'O',
		'P',
		'A',
		'S',
		'D',
		'F',
		'G',
		'H',
		'J',
		'K',
		'L',
		'Z',
		'X',
		'C',
		'V',
		'B',
		'N',
		'M'
	};

	sKey[0] = '\0';

	decl i, iLength;
	i = 0;
	iLength = sizeof(Chars)-1;
	while (i < iLen && i < iMaxLength)
	{
		sKey[i] = Chars[UTIL_GetRandomInt(0, iLength)];
		++i;
	}

	sKey[iLen] = '\0';
}


// спиздил из smlib
UTIL_GetRandomInt(iMin, iMax)
{
	new iRandom = GetURandomInt();
	
	if (iRandom == 0)
	{
		++iRandom;
	}

	return RoundToCeil(float(iRandom) / (float(2147483647) / float(iMax - iMin + 1))) + iMin - 1;
}