void MakeHooks_CS()
{
	HookEventEx("weapon_fire", LRHooks);
	HookEventEx("player_death", LRHooks);
	HookEventEx("player_hurt", LRHooks);
	HookEventEx("round_mvp", LRHooks);
	HookEventEx("round_end", LRHooks);
	HookEventEx("round_start", LRHooks);
	HookEventEx("bomb_planted", LRHooks);
	HookEventEx("bomb_defused", LRHooks);
	HookEventEx("bomb_dropped", LRHooks);
	HookEventEx("bomb_pickup", LRHooks);
	HookEventEx("hostage_killed", LRHooks);
	HookEventEx("hostage_rescued", LRHooks);
}

void MakeHooks_TF2()
{
	HookEventEx("arena_round_start", LRHooks_TF2);
	HookEventEx("arena_win_panel", LRHooks_TF2);
	HookEventEx("teamplay_round_start", LRHooks_TF2);
	HookEventEx("teamplay_win_panel", LRHooks_TF2);
	HookEventEx("player_death", LRHooks_TF2);
}

public void LRHooks(Handle hEvent, char[] sEvName, bool bDontBroadcast)
{
	switch(sEvName[0])
	{
		case 'w':
		{
			int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
			if(g_bInitialized[iClient] && IsClientInGame(iClient))
			{
				char sWeaponName[64];
				GetEventString(hEvent, "weapon", sWeaponName, sizeof(sWeaponName));
				if(!StrEqual(sWeaponName, "hegrenade") || !StrEqual(sWeaponName, "flashbang") || !StrEqual(sWeaponName, "smokegrenade") || !StrEqual(sWeaponName, "molotov") || !StrEqual(sWeaponName, "incgrenade") || !StrEqual(sWeaponName, "decoy"))
				{
					g_iClientData[iClient][4]++;
				}
			}
		}

		case 'p':
		{
			switch(sEvName[7])
			{
				case 'h':
				{
					int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
					int iAttacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));

					if(iClient && iAttacker && iAttacker != iClient && g_bInitialized[iClient] && g_bInitialized[iAttacker] && IsClientInGame(iClient) && IsClientInGame(iAttacker))
					{
						if(GetEventInt(hEvent, "hitgroup"))
						{
							g_iClientData[iAttacker][5]++;
						}
					}
				}

				case 'd':
				{
					int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
					int iAttacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));
					bool headshot = GetEventBool(hEvent, "headshot");

					if(!iAttacker || !iClient)
						return;

					if(IsFakeClient(iClient) || IsFakeClient(iAttacker))
						return;

					if(iAttacker == iClient)
					{
						Hook_MakeChatMessage(iClient, -g_iGiveSuicide, g_iGiveSuicide, "Suicide");
					}
					else
					{
						if(g_iTypeStatistics != 1)
						{
							Hook_MakeChatMessage(iAttacker, g_iGiveKill, g_iGiveKill, "Kill");
							Hook_MakeChatMessage(iClient, -g_iGiveDeath, g_iGiveDeath, "MyDeath");
						}
						else
						{
							int iRankAttacker = g_iClientData[iAttacker][0];
							int iRankVictim = g_iClientData[iClient][0];

							if(iRankAttacker == 0) iRankAttacker = 1;
							if(iRankVictim == 0) iRankVictim = 1;

							int iExpCoeff = RoundToNearest((float(iRankVictim) / float(iRankAttacker)) * 5.00);

							if(iExpCoeff < 0) iExpCoeff = iExpCoeff * -1;
							if(iExpCoeff < 2) iExpCoeff = 2;

							if((g_iClientData[iAttacker][2] > 9) || (g_iClientData[iAttacker][3] > 9)) Hook_MakeChatMessage(iAttacker, iExpCoeff, iExpCoeff, "Kill");
							else Hook_MakeChatMessage(iAttacker, g_iGiveCalibration, g_iGiveCalibration, "CalibrationPlus");

							if((g_iClientData[iClient][2] > 9) || (g_iClientData[iClient][3] > 9)) Hook_MakeChatMessage(iClient, -iExpCoeff, iExpCoeff, "MyDeath");
							else Hook_MakeChatMessage(iClient, -g_iGiveCalibration, g_iGiveCalibration, "CalibrationMinus");
						}

						if(headshot && g_bInitialized[iAttacker])
						{
							g_iClientData[iAttacker][6]++;
							Hook_MakeChatMessage(iAttacker, g_iGiveHeadShot, g_iGiveHeadShot, "HeadShotKill");
						}

						if(g_iEngineGame == EngineGameCSGO)
						{
							int iAssister = GetClientOfUserId(GetEventInt(hEvent, "assister"));
							if(iAssister && g_bInitialized[iAssister])
							{
								g_iClientData[iAssister][7]++;
								Hook_MakeChatMessage(iAssister, g_iGiveAssist, g_iGiveAssist, "AssisterKill");
							}
						}

						if(g_bInitialized[iAttacker])
						{
							g_iClientData[iAttacker][2]++;
							g_iKillstreak[iAttacker]++;
						}
					}

					if(g_bInitialized[iClient])
					{
						g_iClientData[iClient][3]++;
					}

					SetExpStreakKills(iClient);
				}
			}
		}

		case 'r':
		{
			switch(sEvName[6])
			{
				case 'e': 
				{
					int iTeam, checkteam;
					for(int iClient = 1; iClient <= MaxClients; iClient++)
					{
						if(IsClientInGame(iClient))
						{
							SetExpStreakKills(iClient);
							if((checkteam = GetEventInt(hEvent, "winner")) > 1)
							{
								if((iTeam = GetClientTeam(iClient)) > 1)
								{
									if(iTeam == checkteam)
									{
										Hook_MakeChatMessage(iClient, g_iRoundWin, g_iRoundWin, "RoundWin");
									}
									else Hook_MakeChatMessage(iClient, -g_iRoundLose, g_iRoundLose, "RoundLose");
								}
							}
						}
					}

					SavePlayer_EndRound();
				}

				case 'm':
				{
					int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
					Hook_MakeChatMessage(iClient, g_iRoundMVP, g_iRoundMVP, "RoundMVP");
				}

				case 's':
				{
					g_iCountPlayers = 0;

					for(int i = 1; i <= MaxClients; i++)
					{
						if(g_bInitialized[i] && IsClientInGame(i))
						{
							g_iCountPlayers++;
							RankDataPlayer(i);
						}
					}

					if(g_bSpawnMessage && g_iCountPlayers < g_iMinimumPlayers && g_iTypeStatistics != 2)
					{
						for(int i = 1; i <= MaxClients; i++)
						{
							if(IsClientInGame(i))
							{
								LR_PrintToChat(i, "%t", "RoundStartCheckCount", g_iCountPlayers, g_iMinimumPlayers);
							}
						}
					}

					if(g_bSpawnMessage)
					{
						for(int i = 1; i <= MaxClients; i++)
						{
							if(IsClientInGame(i))
							{
								LR_PrintToChat(i, "%t", "RoundStartMessageRanks", g_sMainMenuStr[0]);
							}
						}
					}
				}
			}
		}

		case 'b':
		{
			int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
			switch(sEvName[6])
			{
				case 'l': g_bHaveBomb[iClient] = false, Hook_MakeChatMessage(iClient, g_iBombPlanted, g_iBombPlanted, "BombPlanted");
				case 'e': Hook_MakeChatMessage(iClient, g_iBombDefused, g_iBombDefused, "BombDefused");
				case 'r': if(g_bHaveBomb[iClient]) {g_bHaveBomb[iClient] = false; Hook_MakeChatMessage(iClient, -g_iBombDropped, g_iBombDropped, "BombDropped");}
				case 'i': if(!g_bHaveBomb[iClient]) {g_bHaveBomb[iClient] = true; Hook_MakeChatMessage(iClient, g_iBombPickup, g_iBombPickup, "BombPickup");}
			}
		}

		case 'h':
		{
			int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
			switch(sEvName[8])
			{
				case 'k': Hook_MakeChatMessage(iClient, -g_iHostageKilled, g_iHostageKilled, "HostageKilled");
				case 'r': Hook_MakeChatMessage(iClient, g_iHostageRescued, g_iHostageRescued, "HostageRescued");
			}
		}
	}
}

public void LRHooks_TF2(Handle hEvent, char[] sEvName, bool bDontBroadcast)
{
	switch(sEvName[0])
	{
		case 'p':
		{
			switch(sEvName[7])
			{
				case 'd':
				{
					int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
					int iAttacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));
					int iAssister = GetClientOfUserId(GetEventInt(hEvent, "assister"));

					if(!iAttacker || !iClient)
						return;

					if(IsFakeClient(iClient) || IsFakeClient(iAttacker))
						return;

					if(iAttacker == iClient)
					{
						Hook_MakeChatMessage(iClient, -g_iGiveSuicide, g_iGiveSuicide, "Suicide");
					}
					else
					{
						if(g_iTypeStatistics != 1)
						{
							Hook_MakeChatMessage(iAttacker, g_iGiveKill, g_iGiveKill, "Kill");
							Hook_MakeChatMessage(iClient, -g_iGiveDeath, g_iGiveDeath, "MyDeath");
						}
						else
						{
							int iRankAttacker = g_iClientData[iAttacker][0];
							int iRankVictim = g_iClientData[iClient][0];

							if(iRankAttacker == 0) iRankAttacker = 1;
							if(iRankVictim == 0) iRankVictim = 1;

							int iExpCoeff = RoundToNearest((float(iRankVictim) / float(iRankAttacker)) * 5.00);

							if(iExpCoeff < 0) iExpCoeff = iExpCoeff * -1;
							if(iExpCoeff < 2) iExpCoeff = 2;

							if((g_iClientData[iAttacker][2] > 9) || (g_iClientData[iAttacker][3] > 9)) Hook_MakeChatMessage(iAttacker, iExpCoeff, iExpCoeff, "Kill");
							else Hook_MakeChatMessage(iAttacker, g_iGiveCalibration, g_iGiveCalibration, "Kill");

							if((g_iClientData[iClient][2] > 9) || (g_iClientData[iClient][3] > 9)) Hook_MakeChatMessage(iClient, -iExpCoeff, iExpCoeff, "MyDeath");
							else Hook_MakeChatMessage(iClient, -g_iGiveCalibration, g_iGiveCalibration, "MyDeath");
						}

						if(iAssister && g_bInitialized[iAssister])
						{
							g_iClientData[iAssister][7]++;
							Hook_MakeChatMessage(iAssister, g_iGiveAssist, g_iGiveAssist, "AssisterKill");
						}

						if(g_bInitialized[iAttacker])
						{
							g_iClientData[iAttacker][2]++;
							g_iKillstreak[iAttacker]++;
						}
					}

					if(g_bInitialized[iClient])
					{
						g_iClientData[iClient][3]++;
					}

					SetExpStreakKills(iClient);
				}
			}
		}

		case 'a':
		{
			switch(sEvName[6])
			{
				case 'r': LRHooks_TF2_Round(true, hEvent);
				case 'w': LRHooks_TF2_Round(false, hEvent);
			}
		}

		case 't':
		{
			switch(sEvName[9])
			{
				case 'r': LRHooks_TF2_Round(false, hEvent);
				case 'w': LRHooks_TF2_Round(true, hEvent);
			}
		}
	}
}

void LRHooks_TF2_Round(bool bEndRound, Handle hEvent)
{
	if(bEndRound)
	{
		int iTeam, checkteam;
		for(int iClient = 1; iClient <= MaxClients; iClient++)
		{
			if(IsClientInGame(iClient))
			{
				SetExpStreakKills(iClient);
				if((checkteam = GetEventInt(hEvent, "winning_team")) > 1)
				{
					if((iTeam = GetClientTeam(iClient)) > 1)
					{
						if(iTeam == checkteam)
						{
							Hook_MakeChatMessage(iClient, g_iRoundWin, g_iRoundWin, "RoundWin");
						}
						else Hook_MakeChatMessage(iClient, -g_iRoundLose, g_iRoundLose, "RoundLose");
					}
				}
			}
		}
		SavePlayer_EndRound();
	}
	else
	{
		g_iCountPlayers = 0;

		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsFakeClient(i) && g_bInitialized[i])
			{
				g_iCountPlayers++;
				RankDataPlayer(i);
			}
		}

		if(g_bSpawnMessage && g_iCountPlayers < g_iMinimumPlayers && g_iTypeStatistics != 2)
		{
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i))
				{
					LR_PrintToChat(i, "%t", "RoundStartCheckCount", g_iCountPlayers, g_iMinimumPlayers);
				}
			}
		}

		if(g_bSpawnMessage)
		{
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i))
				{
					LR_PrintToChat(i, "%t", "RoundStartMessageRanks", g_sMainMenuStr[0]);
				}
			}
		}
	}
}

void SetExpStreakKills(int iClient)
{
	if(g_iKillstreak[iClient] > 1)
	{
		switch(g_iKillstreak[iClient])
		{
			case 2: Hook_MakeChatMessage(iClient, g_iBonus[0], g_iBonus[0], "DoubleKill");
			case 3: Hook_MakeChatMessage(iClient, g_iBonus[1], g_iBonus[1], "TripleKill");
			case 4: Hook_MakeChatMessage(iClient, g_iBonus[2], g_iBonus[2], "Domination");
			case 5: Hook_MakeChatMessage(iClient, g_iBonus[3], g_iBonus[3], "Rampage");
			case 6: Hook_MakeChatMessage(iClient, g_iBonus[4], g_iBonus[4], "MegaKill");
			case 7: Hook_MakeChatMessage(iClient, g_iBonus[5], g_iBonus[5], "Ownage");
			case 8: Hook_MakeChatMessage(iClient, g_iBonus[6], g_iBonus[6], "UltraKill");
			case 9: Hook_MakeChatMessage(iClient, g_iBonus[7], g_iBonus[7], "KillingSpree");
			case 10: Hook_MakeChatMessage(iClient, g_iBonus[8], g_iBonus[8], "MonsterKill");
			case 11: Hook_MakeChatMessage(iClient, g_iBonus[9], g_iBonus[9], "Unstoppable");
			default: Hook_MakeChatMessage(iClient, g_iBonus[10], g_iBonus[10], "GodLike");
		}
	}
	g_iKillstreak[iClient] = 0;
}

void SavePlayer_EndRound()
{
	char sQuery[512], sSaveName[MAX_NAME_LENGTH * 2 + 1];
	Transaction hQuery = new Transaction();
	for(int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if(iClient && IsClientInGame(iClient) && !IsFakeClient(iClient) && g_bInitialized[iClient])
		{
			g_hDatabase.Escape(g_sName[iClient], sSaveName, sizeof(sSaveName));
			FormatEx(sQuery, sizeof(sQuery), g_sSQL_SavePlayer, g_iClientData[iClient][0], sSaveName, g_iClientData[iClient][1], g_iClientData[iClient][2], g_iClientData[iClient][3], g_iClientData[iClient][4], g_iClientData[iClient][5], g_iClientData[iClient][6], g_iClientData[iClient][7], g_iClientData[iClient][8], GetTime(), g_sSteamID[iClient]);
			hQuery.AddQuery(sQuery);
		}
	}
	
	g_hDatabase.Execute(hQuery, _, Transaction_ErrorCallback, _, DBPrio_High);
}