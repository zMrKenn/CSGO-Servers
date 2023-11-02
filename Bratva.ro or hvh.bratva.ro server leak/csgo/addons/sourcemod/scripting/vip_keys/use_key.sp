public Action:UseKey_CMD(iClient, args)
{
	if (iClient)
	{
		if(VIP_IsClientVIP(iClient) == false)
		{
			if(g_CVAR_iAttempts && g_bIsBlocked[iClient])
			{
				if(g_iAttempts[iClient] > GetTime())
				{
					VIP_PrintToChatClient(iClient, "[VIP] %t", "USE_KEY_ERROR_BLOCKED");
					return Plugin_Handled;
					
				}
				else
				{
					UnBlockClient(iClient);
				}
			}
			
			if(args != 1)
			{
				VIP_PrintToChatClient(iClient, "[VIP] %t", "USE_KEY_ERROR_USAGE");
				return Plugin_Handled;
			}

			decl String:sKey[MAX_KEY_LENGTH];
			GetCmdArg(1, sKey, sizeof(sKey));
			
			if(FindStringInArray(g_hKeysArray, sKey) == -1)
			{
				if(g_CVAR_iAttempts)
				{
					if(++g_iAttempts[iClient] >= g_CVAR_iAttempts)
					{
						BlockClient(iClient);
						VIP_PrintToChatClient(iClient, "[VIP] %t", "USE_KEY_ERROR_BLOCKED");
					}
					else
					{
						VIP_PrintToChatClient(iClient, "[VIP] %t", "USE_KEY_ERROR_INCORRECT_KEY_LEFT", g_CVAR_iAttempts-g_iAttempts[iClient]);
					}
				}
				else
				{
					VIP_PrintToChatClient(iClient, "%t", "ERROR_KEY_NOT_EXIST");
				}
				return Plugin_Handled;
			}

			decl String:sQuery[256];
			FormatEx(sQuery, sizeof(sQuery), "SELECT `key`, `group`, `time`, `created`, `lifetime` FROM `vip_keys` WHERE `key` = '%s';", sKey);
			SQL_TQuery(g_hDatabase, SQL_Callback_UseKey, sQuery, GetClientUserId(iClient));
		}
		else
		{
			VIP_PrintToChatClient(iClient, "%t", "USE_KEY_ERROR_VIP_ALREADY");
		}
	}
	return Plugin_Handled;
}

public SQL_Callback_UseKey(Handle:hOwner, Handle:hQuery, const String:sError[], any:UserID)
{
	if (hQuery == INVALID_HANDLE || sError[0])
	{
		LogError("SQL_Callback_UseKey: %s", sError);
		return;
	}

	new iClient = GetClientOfUserId(UserID);
	if (iClient)
	{
		if(SQL_FetchRow(hQuery))
		{
			decl String:sKey[MAX_KEY_LENGTH], iLifeTime;
			SQL_FetchString(hQuery, 0, sKey, sizeof(sKey));
			iLifeTime = SQL_FetchInt(hQuery, 4);
			if(iLifeTime)
			{
				if(GetTime() > SQL_FetchInt(hQuery, 3)+iLifeTime)
				{
					DeleteKey(sKey);
					VIP_PrintToChatClient(iClient, "%t", "ERROR_KEY_NOT_EXIST");
					return;
				}
			}
			
			decl String:sGroup[MAX_GROUP_LENGTH], iTime;
			SQL_FetchString(hQuery, 1, sGroup, sizeof(sGroup));
			iTime = SQL_FetchInt(hQuery, 2);
			
			if(VIP_SetClientVIP(iClient, iTime, AUTH_STEAM, sGroup, true))
			{
				DeleteKey(sKey);
				VIP_PrintToChatClient(iClient, "%t", "USE_KEY_SUCCESSFULLY");
			}
		}
		else
		{
			VIP_PrintToChatClient(iClient, "%t", "USE_KEY_ERROR_HAS_OCCURRED");
		}
	}
}