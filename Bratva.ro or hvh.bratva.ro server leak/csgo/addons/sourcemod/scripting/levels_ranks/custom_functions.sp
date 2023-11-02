public int SteamWorks_SteamServersConnected()
{
	int iIp[4];
	if(SteamWorks_GetPublicIP(iIp) && iIp[0] && iIp[1] && iIp[2] && iIp[3])
	{
		char szBuffer[256];
		Handle hRequest = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, "http://stats.scriptplugs.info/add_server.php");
		if(!hRequest)
			return;

		FormatEx(szBuffer, sizeof(szBuffer), "key=%s&ip=%d.%d.%d.%d:%d&version=%s", API_KEY, iIp[0], iIp[1], iIp[2], iIp[3], FindConVar("hostport").IntValue, PLUGIN_VERSION);
		if(!SteamWorks_SetHTTPRequestRawPostBody(hRequest, "application/x-www-form-urlencoded", szBuffer, sizeof(szBuffer)) || !SteamWorks_SetHTTPCallbacks(hRequest, _) || !SteamWorks_SendHTTPRequest(hRequest))
		{
			delete hRequest;
			return;
		}
	}
}

void Hook_MakeChatMessage(int iClient, int iValue, int iValueShow, char[] sTitlePhrase)
{
	if(iValue != 0 && g_iTypeStatistics != 2 && g_iCountPlayers >= g_iMinimumPlayers && g_bInitialized[iClient] && IsClientInGame(iClient))
	{
		SetExpEvent(iClient, iValue);
		if(g_bUsualMessage)
		{
			SetGlobalTransTarget(iClient);
			LR_PrintToChat(iClient, "%t", sTitlePhrase, g_iClientData[iClient][0], iValueShow);
		}
	}
}

int SetExpEvent(int iClient, int iAmount)
{
	g_iClientData[iClient][0] += iAmount;
	if(g_iTypeStatistics == 0 && g_iClientData[iClient][0] < 0)
	{
		g_iClientData[iClient][0] = 0;
	}

	CheckRank(iClient);
	return g_iClientData[iClient][0];
}

bool IsClientVip(int iClient)
{
	if((g_iClientData[iClient][8] == -1) || (g_iClientData[iClient][8] > GetTime()))
	{
		return true;
	}

	g_iClientData[iClient][8] = 0;
	return false;
}

void LR_PrecacheSound()
{
	char sBuffer[256];
	switch(g_iEngineGame)
	{
		case EngineGameCSGO:
		{
			int iStringTable = FindStringTable("soundprecache");
			FormatEx(sBuffer, sizeof(sBuffer), "*%s", g_sSoundUp); AddToStringTable(iStringTable, sBuffer);
			FormatEx(sBuffer, sizeof(sBuffer), "*%s", g_sSoundDown); AddToStringTable(iStringTable, sBuffer);
		}

		case EngineGameCSS, EngineGameTF2:
		{
			FormatEx(sBuffer, sizeof(sBuffer), "%s", g_sSoundUp); PrecacheSound(sBuffer);
			FormatEx(sBuffer, sizeof(sBuffer), "%s", g_sSoundDown); PrecacheSound(sBuffer);
		}
	}
}

void LR_EmitSound(int iClient, char[] sPath)
{
	if(g_bSoundLVL)
	{
		char sBuffer[256];
		switch(g_iEngineGame)
		{
			case EngineGameCSGO: FormatEx(sBuffer, sizeof(sBuffer), "*%s", sPath);
			case EngineGameCSS, EngineGameTF2: strcopy(sBuffer, sizeof(sBuffer), sPath);
		}
		EmitSoundToClient(iClient, sBuffer, SOUND_FROM_PLAYER, SNDCHAN_LR_RANK);
	}
}

void LR_ShowOverlay(int iClient, char[] sPath)
{
	if(g_bOverLays)
	{
		ClientCommand(iClient, "r_screenoverlay %s", sPath);
		CreateTimer(3.0, DeleteOverlay, GetClientUserId(iClient));
	}
}

void LR_CallRankForward(int iClient, int iNewLevel, bool bUp)
{
	Call_StartForward(g_hForward_OnLevelChanged);
	Call_PushCell(iClient);
	Call_PushCell(iNewLevel);
	Call_PushCell(bUp);
	Call_Finish();
}

public Action DeleteOverlay(Handle hTimer, any iUserid)
{
	int iClient = GetClientOfUserId(iUserid);
	if(iClient && IsClientInGame(iClient))
	{
		ClientCommand(iClient, "r_screenoverlay off");
	}
}