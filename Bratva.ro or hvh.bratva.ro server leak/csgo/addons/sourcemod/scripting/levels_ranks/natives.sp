public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("LR_CheckCountPlayers", Native_LR_CheckCountPlayers);
	CreateNative("LR_GetTypeStatistics", Native_LR_GetTypeStatistics);
	CreateNative("LR_GetClientPos", Native_LR_GetClientPos);
	CreateNative("LR_GetClientInfo", Native_LR_GetClientInfo);
	CreateNative("LR_ChangeClientValue", Native_LR_ChangeClientValue);
	CreateNative("LR_SetClientValue", Native_LR_SetClientValue);
	CreateNative("LR_MenuInventory", Native_LR_MenuInventory);
	CreateNative("LR_IsValidGroupVIP", Native_LR_IsValidGroupVIP);
	CreateNative("LR_IsClientVIP", Native_LR_IsClientVIP);
	CreateNative("LR_SetClientVIP", Native_LR_SetClientVIP);
	CreateNative("LR_GetClientInfoVIP", Native_LR_GetClientInfoVIP);
	CreateNative("LR_ChangeClientVIP", Native_LR_ChangeClientVIP);
	CreateNative("LR_DeleteClientVIP", Native_LR_DeleteClientVIP);
	RegPluginLibrary("levelsranks");
}

public int Native_LR_CheckCountPlayers(Handle hPlugin, int iNumParams)
{
	if(g_iCountPlayers >= g_iMinimumPlayers)
		return true;
	return false;
}

public int Native_LR_GetTypeStatistics(Handle hPlugin, int iNumParams)
{
	return g_iTypeStatistics;
}

public int Native_LR_GetClientPos(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if(g_bInitialized[iClient] && IsClientInGame(iClient))
		return g_iPlayerPlace[iClient];
	return 0;
}

public int Native_LR_GetClientInfo(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iStats = GetNativeCell(2);

	if(g_bInitialized[iClient] && IsClientInGame(iClient) && (-1 < iStats < 8))
	{
		return g_iClientData[iClient][iStats];
	}

	return 0;
}

public int Native_LR_ChangeClientValue(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	int iValue = GetNativeCell(2);

	if(g_bInitialized[iClient] && IsClientInGame(iClient))
	{
		return SetExpEvent(iClient, iValue);
	}

	return 0;
}

public int Native_LR_SetClientValue(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	int iValue = GetNativeCell(2);

	if(g_iTypeStatistics == 2 && g_bInitialized[iClient] && IsClientInGame(iClient))
	{
		g_iClientData[iClient][0] = iValue;
		CheckRank(iClient);
		return true;
	}

	return false;
}

public int Native_LR_MenuInventory(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(g_bInitialized[iClient] && IsClientInGame(iClient))
	{
		InventoryMenu(iClient);
	}
}

public int Native_LR_IsValidGroupVIP(Handle hPlugin, int iNumParams)
{
	char sGroup[256];
	GetNativeString(1, sGroup, 256);
	for(int i = 0; i < g_iVIPGroupCount; i++)
	{
		if(StrEqual(sGroup, g_sVIPGroup[i], false))
		{
			return true;
		}
	}

	return false;
}

public int Native_LR_IsClientVIP(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(g_bInitialized[iClient] && IsClientInGame(iClient) && IsClientVip(iClient))
	{
		return true;
	}

	return false;
}

public int Native_LR_SetClientVIP(Handle hPlugin, int iNumParams)
{
	char sGroup[256];
	int iClient = GetNativeCell(1);
	int iTime = GetNativeCell(2);
	GetNativeString(3, sGroup, 256);

	if(g_bInitialized[iClient] && IsClientInGame(iClient))
	{
		for(int i = 0; i < g_iVIPGroupCount; i++)
		{
			if(StrEqual(sGroup, g_sVIPGroup[i], false))
			{
				g_iClientData[iClient][8] = iTime;
				g_iClientData[iClient][9] = i;
				IsClientVip(iClient);
				CheckRank(iClient);
				return true;
			}
		}
	}

	return false;
}

public int Native_LR_GetClientInfoVIP(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(g_bInitialized[iClient] && IsClientInGame(iClient))
	{
		DataPack hDataPack = new DataPack();
		DataPack hPack = view_as<DataPack>(CloneHandle(hDataPack, hPlugin));
		delete hDataPack;

		hPack.WriteCell(g_iClientData[iClient][8]);
		hPack.WriteString(g_sVIPGroup[g_iClientData[iClient][9]]);
		return view_as<int>(hPack);
	}

	return -1;
}

public int Native_LR_ChangeClientVIP(Handle hPlugin, int iNumParams)
{
	char sGroup[256];
	int iClient = GetNativeCell(1);
	GetNativeString(2, sGroup, 256);
	int iTime = GetNativeCell(3);

	if(g_bInitialized[iClient] && IsClientInGame(iClient))
	{
		if(sGroup[0])
		{
			for(int i = 0; i < g_iVIPGroupCount; i++)
			{
				if(StrEqual(sGroup, g_sVIPGroup[i], false))
				{
					g_iClientData[iClient][9] = i;
					break;
				}
			}
		}

		if(iTime > -1)
		{
			if(iTime == 0)
			{
				g_iClientData[iClient][8] = -1;
			}
			else
			{
				g_iClientData[iClient][8] = iTime;
			}
		}

		CheckRank(iClient);
		return true;
	}

	return false;
}

public int Native_LR_DeleteClientVIP(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(g_bInitialized[iClient] && IsClientInGame(iClient))
	{
		g_iClientData[iClient][8] = 0;
		CheckRank(iClient);
		return true;
	}

	return false;
}