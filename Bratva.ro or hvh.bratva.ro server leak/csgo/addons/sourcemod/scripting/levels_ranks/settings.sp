int		g_iAdminFlag,
		g_iTypeStatistics,
		g_iMinimumPlayers,
		g_iEloStartCount,
		g_iDaysDeleteFromBase,
		g_iGiveCalibration,
		g_iGiveKill,
		g_iGiveDeath,
		g_iGiveHeadShot,
		g_iGiveAssist,
		g_iGiveSuicide,
		g_iRoundWin,
		g_iRoundLose,
		g_iRoundMVP,
		g_iBombPlanted,
		g_iBombDefused,
		g_iBombDropped,
		g_iBombPickup,
		g_iHostageKilled,
		g_iHostageRescued,
		g_iVIPGroupCount,
		g_iVIPGroupRanks[64],
		g_iShowExp[20],
		g_iBonus[11];
bool		g_bSpawnMessage = false,
		g_bRankMessage = false,
		g_bUsualMessage = false,
		g_bFakeRank = false,
		g_bInventory = false,
		g_bSoundLVL = false,
		g_bOverLays = false;
char		g_sMainMenuStr[32][16],
		g_sVIPGroup[64][128],
		g_sOverlayUp[256],
		g_sOverlayDown[256],
		g_sSoundUp[256],
		g_sSoundDown[256],
		g_sShowRank[20][192];

public void SetSettings()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/levels_ranks/settings.ini");
	KeyValues hLR_Settings = new KeyValues("LR_Settings");

	if(!hLR_Settings.ImportFromFile(sPath) || !hLR_Settings.GotoFirstSubKey())
	{
		SetFailState("[%s Core] (%s) is not found", PLUGIN_NAME, sPath);
	}

	hLR_Settings.Rewind();

	if(hLR_Settings.JumpToKey("MainSettings"))
	{
		char sBuffer[256];
		hLR_Settings.GetString("lr_call_menu", sBuffer, sizeof(sBuffer), "!lvl"); ExplodeString(sBuffer, ";", g_sMainMenuStr, 32, 16);
		hLR_Settings.GetString("lr_flag_adminmenu", sBuffer, sizeof(sBuffer), "z"); g_iAdminFlag = ReadFlagString(sBuffer);

		g_iTypeStatistics = hLR_Settings.GetNum("lr_type_statistics", 0);
		g_iEloStartCount = hLR_Settings.GetNum("lr_startcount", 1000);
		g_iMinimumPlayers = hLR_Settings.GetNum("lr_minplayers_count", 4);

		switch(g_iTypeStatistics)
		{
			case 1:
			{
				if(g_iEloStartCount < 1000)
				{
					g_iEloStartCount = 1000;
				}
			}

			case 2:
			{
				int iCount;
				Call_StartForward(g_hForward_OnLevelCheckSynhc);
				Call_PushCellRef(iCount);
				Call_Finish();
				
				if(iCount > 1)
				{
					SetFailState("[%s Core] More than one synchronization modules", PLUGIN_NAME);
				}
			}
		}

		if(g_iMinimumPlayers < 2 || g_iMinimumPlayers > 8)
		{
			g_iMinimumPlayers = 4;
		}

		g_bSoundLVL = view_as<bool>(hLR_Settings.GetNum("lr_sound", 1));
		hLR_Settings.GetString("lr_sound_lvlup", g_sSoundUp, sizeof(g_sSoundUp), "levels_ranks/levelup.mp3");
		hLR_Settings.GetString("lr_sound_lvldown", g_sSoundDown, sizeof(g_sSoundDown), "levels_ranks/leveldown.mp3");

		g_bOverLays = view_as<bool>(hLR_Settings.GetNum("lr_overlay", 1));
		hLR_Settings.GetString("lr_overlay_lvlup", g_sOverlayUp, sizeof(g_sOverlayUp), "lvl_overlays/lvl_up");
		hLR_Settings.GetString("lr_overlay_lvldown", g_sOverlayDown, sizeof(g_sOverlayDown), "lvl_overlays/lvl_down");

		g_bFakeRank = view_as<bool>(hLR_Settings.GetNum("lr_show_fakerank", 0));
		g_bInventory = view_as<bool>(hLR_Settings.GetNum("lr_show_inventory", 0));
		g_bUsualMessage = view_as<bool>(hLR_Settings.GetNum("lr_show_usualmessage", 1));
		g_bSpawnMessage = view_as<bool>(hLR_Settings.GetNum("lr_show_spawnmessage", 1));
		g_bRankMessage = view_as<bool>(hLR_Settings.GetNum("lr_show_rankmessage", 1));
		g_iDaysDeleteFromBase = hLR_Settings.GetNum("lr_cleaner_db", 30);
	}
	else SetFailState("[%s Core] Section MainSettings is not found (%s)", PLUGIN_NAME, sPath);

	delete hLR_Settings;
	SetSettingsType();
}

public void SetSettingsType()
{
	char sBuffer[64], sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/levels_ranks/settings_stats.ini");
	KeyValues hLR_Settings = new KeyValues("LR_Settings");

	if(!hLR_Settings.ImportFromFile(sPath) || !hLR_Settings.GotoFirstSubKey())
	{
		SetFailState("[%s Core] (%s) is not found", PLUGIN_NAME, sPath);
	}

	hLR_Settings.Rewind();

	switch(g_iTypeStatistics)
	{
		case 0:
		{
			if(hLR_Settings.JumpToKey("Exp_Stats"))
			{
				g_iGiveKill = hLR_Settings.GetNum("lr_kill", 10);
				g_iGiveDeath = hLR_Settings.GetNum("lr_death", 10);
				g_iGiveHeadShot = hLR_Settings.GetNum("lr_headshot", 2);
				g_iGiveAssist = hLR_Settings.GetNum("lr_assist", 2);
				g_iGiveSuicide = hLR_Settings.GetNum("lr_suicide", 12);
				g_iRoundWin = hLR_Settings.GetNum("lr_winround", 6);
				g_iRoundLose = hLR_Settings.GetNum("lr_loseround", 6);
				g_iRoundMVP = hLR_Settings.GetNum("lr_mvpround", 8);
				g_iBombPlanted = hLR_Settings.GetNum("lr_bombplanted", 6);
				g_iBombDefused = hLR_Settings.GetNum("lr_bombdefused", 6);
				g_iBombDropped = hLR_Settings.GetNum("lr_bombdropped", 4);
				g_iBombPickup = hLR_Settings.GetNum("lr_bombpickup", 4);
				g_iHostageKilled = hLR_Settings.GetNum("lr_hostagekilled", 8);
				g_iHostageRescued = hLR_Settings.GetNum("lr_hostagerescued", 6);
				
				for(int i = 0; i <= 10; i++)
				{
					FormatEx(sBuffer, sizeof(sBuffer), "lr_bonus_%i", i + 1);
					g_iBonus[i] = hLR_Settings.GetNum(sBuffer, i + 5);
				}
			}
			else SetFailState("[%s Core] Section Exp_Stats is not found (%s)", PLUGIN_NAME, sPath);
		}

		case 1:
		{
			if(hLR_Settings.JumpToKey("Elo_Stats"))
			{
				g_iGiveCalibration = hLR_Settings.GetNum("lr_calibration", 20);
				g_iGiveHeadShot = hLR_Settings.GetNum("lr_headshot", 1);
				g_iGiveAssist = hLR_Settings.GetNum("lr_assist", 1);
				g_iGiveSuicide = hLR_Settings.GetNum("lr_suicide", 1);
				g_iRoundWin = hLR_Settings.GetNum("lr_winround", 2);
				g_iRoundLose = hLR_Settings.GetNum("lr_loseround", 2);
				g_iRoundMVP = hLR_Settings.GetNum("lr_mvpround", 1);
				g_iBombPlanted = hLR_Settings.GetNum("lr_bombplanted", 10);
				g_iBombDefused = hLR_Settings.GetNum("lr_bombdefused", 10);
				g_iBombDropped = hLR_Settings.GetNum("lr_bombdropped", 2);
				g_iBombPickup = hLR_Settings.GetNum("lr_bombpickup", 2);
				g_iHostageKilled = hLR_Settings.GetNum("lr_hostagekilled", 15);
				g_iHostageRescued = hLR_Settings.GetNum("lr_hostagerescued", 5);
				
				for(int i = 0; i <= 10; i++)
				{
					FormatEx(sBuffer, sizeof(sBuffer), "lr_bonus_%i", i + 1);
					g_iBonus[i] = hLR_Settings.GetNum(sBuffer, i + 1);
				}
			}
			else SetFailState("[%s Core] Section Elo_Stats is not found (%s)", PLUGIN_NAME, sPath);
		}
	}

	delete hLR_Settings;
	SetSettingsRank();
}

public void SetSettingsRank()
{
	char sPath[PLATFORM_MAX_PATH];

	if(g_iTypeStatistics == 2)
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "configs/levels_ranks/settings_ranks_synhc.ini");
		KeyValues hLR_Settings = new KeyValues("LR_Settings");

		if(!hLR_Settings.ImportFromFile(sPath) || !hLR_Settings.GotoFirstSubKey())
		{
			SetFailState("[%s Core] (%s) is not found", PLUGIN_NAME, sPath);
		}

		hLR_Settings.Rewind();

		if(hLR_Settings.JumpToKey("Ranks"))
		{
			int iRanksCount = 0;
			hLR_Settings.GotoFirstSubKey();

			do
			{
				switch(g_iEngineGame)
				{
					case EngineGameCSGO, EngineGameCSS: hLR_Settings.GetString("name_cs", g_sShowRank[iRanksCount], sizeof(g_sShowRank[]));
					case EngineGameTF2: hLR_Settings.GetString("name_tf2", g_sShowRank[iRanksCount], sizeof(g_sShowRank[]));
				}

				if(iRanksCount > 1)
				{
					g_iShowExp[iRanksCount] = hLR_Settings.GetNum("value", 0);
				}
				iRanksCount++;
			}
			while(hLR_Settings.GotoNextKey());
		}
		else SetFailState("[%s Core] Section Ranks is not found (%s)", PLUGIN_NAME, sPath);
		delete hLR_Settings;
	}
	else
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "configs/levels_ranks/settings_ranks.ini");
		KeyValues hLR_Settings = new KeyValues("LR_Settings");

		if(!hLR_Settings.ImportFromFile(sPath) || !hLR_Settings.GotoFirstSubKey())
		{
			SetFailState("[%s Core] (%s) is not found", PLUGIN_NAME, sPath);
		}

		hLR_Settings.Rewind();

		if(hLR_Settings.JumpToKey("Ranks"))
		{
			int iRanksCount = 0;
			hLR_Settings.GotoFirstSubKey();

			do
			{
				switch(g_iEngineGame)
				{
					case EngineGameCSGO, EngineGameCSS: hLR_Settings.GetString("name_cs", g_sShowRank[iRanksCount], sizeof(g_sShowRank[]));
					case EngineGameTF2: hLR_Settings.GetString("name_tf2", g_sShowRank[iRanksCount], sizeof(g_sShowRank[]));
				}

				if(iRanksCount > 1)
				{
					switch(g_iTypeStatistics)
					{
						case 0: g_iShowExp[iRanksCount] = hLR_Settings.GetNum("value_0", 0);
						case 1: g_iShowExp[iRanksCount] = hLR_Settings.GetNum("value_1", 0);
					}
				}
				iRanksCount++;
			}
			while(hLR_Settings.GotoNextKey());
		}
		else SetFailState("[%s Core] Section Ranks is not found (%s)", PLUGIN_NAME, sPath);
		delete hLR_Settings;
	}

	switch(g_iEngineGame)
	{
		case EngineGameCSGO, EngineGameCSS: MakeHooks_CS();
		case EngineGameTF2: MakeHooks_TF2();
	}

	Connect_Database();
}

public void SetSettingsVIPGroups()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/levels_ranks/settings_vip.ini");
	KeyValues hLR_Settings = new KeyValues("LR_Settings");

	if(!hLR_Settings.ImportFromFile(sPath) || !hLR_Settings.GotoFirstSubKey())
	{
		SetFailState("[%s Core] (%s) is not found", PLUGIN_NAME, sPath);
	}

	hLR_Settings.Rewind();

	if(hLR_Settings.JumpToKey("VIPGroups"))
	{
		hLR_Settings.GotoFirstSubKey();
		g_iVIPGroupCount = 0;

		do
		{
			hLR_Settings.GetSectionName(g_sVIPGroup[g_iVIPGroupCount], sizeof(g_sVIPGroup[]));
			g_iVIPGroupRanks[g_iVIPGroupCount] = hLR_Settings.GetNum("viprank", 1);
			g_iVIPGroupCount++;
		}
		while(hLR_Settings.GotoNextKey() && g_iVIPGroupCount < 64);
	}
	else SetFailState("[%s Core] Section VIPGroups is not found (%s)", PLUGIN_NAME, sPath);
	delete hLR_Settings;
}