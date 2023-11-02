/**
 * @ Includes This Header Once
 */
#if defined _hattrick_csgo_included
	#endinput
#endif

/**
 * @ Marks The Header As Included
 */
#define _hattrick_csgo_included

#pragma ctrlchar '\\'
#pragma tabsize 0
#pragma semicolon 1
#pragma dynamic 65536

/**
 * @ Base Header Files
 */
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
// #include <clientprefs>
// #include <geoip>
// #include <regex>
#include <adminmenu>

/**
 * @ New Style
 */
// #pragma newdecls required

// #include <GeoResolver>

/**
 * @ Private Call
 */
#define hCSGO_PrivateCall stock

/**
 * @ Input/ Output Variable
 */
#define _hCSGO_In_Out_ /* Input/ Output */

/**
 * @ Input Variable
 */
#define _hCSGO_In_ /* Input */

/**
 * @ Output Variable
 */
#define _hCSGO_Out_ /* Output */

/**
 * @ All Menu Keys
 */
#define hCSGO_MKeysAll (1 << 0 | \
						1 << 1 | \
						1 << 2 | \
						1 << 3 | \
						1 << 4 | \
						1 << 5 | \
						1 << 6 | \
						1 << 7 | \
						1 << 8 | \
						1 << 9)

/**
 * @ Minutes In Hour
 */
#define hCSGO_MinInHr 60

/**
 * @ Gets Current Round Index Based On Teams Score
 */
hCSGO_PrivateCall int hCSGO_GetCurRoundId()
{
	return GetTeamScore(CS_TEAM_T) + \
			GetTeamScore(CS_TEAM_CT);
}

/**
 * @ Returns Absolute Int
 */
hCSGO_PrivateCall int hCSGO_AbsInt(_hCSGO_In_ int Value = 0)
{
	return Value >= 0 ? Value : -Value;
}

/**
 * @ Escapes String Fast
 */
hCSGO_PrivateCall int hCSGO_FastEscapeString(_hCSGO_In_ Handle pConnection, _hCSGO_In_Out_ char[] Buffer, _hCSGO_In_ int Size)
{
	static char m_Escaped[PLATFORM_MAX_PATH * 4];
	SQL_EscapeString(pConnection, Buffer, m_Escaped, sizeof(m_Escaped));

	return FormatEx(Buffer, Size, m_Escaped);
}

/**
 * @ Makes String HTML Safe
 */
hCSGO_PrivateCall int hCSGO_MakeHtmlSafe(_hCSGO_In_Out_ char[] Buffer, _hCSGO_In_ int Size)
{
	ReplaceString(Buffer, Size, "<", "(");
	ReplaceString(Buffer, Size, ">", ")");

	return strlen(Buffer);
}

/**
 * @ Counts Specified Char In A String
 */
hCSGO_PrivateCall int hCSGO_CountChar(_hCSGO_In_ char[] Buffer, _hCSGO_In_ int Char)
{
	static int m_Count, m_Iterator;

	m_Count = 0;
	m_Iterator = 0;

	for (; m_Iterator < strlen(Buffer); m_Iterator++)
	{
		if (Buffer[m_Iterator] == Char)
			m_Count++;
	}

	return m_Count;
}

/**
 * @ Finds First Occurrence Of Specified Char From Right
 */
hCSGO_PrivateCall int hCSGO_FindFirstCharRight(_hCSGO_In_ char[] Buffer, _hCSGO_In_ int Char)
{
	static int m_Iterator;

	m_Iterator = strlen(Buffer) - 1;

	for (; m_Iterator >= 0; m_Iterator--)
	{
		if (Buffer[m_Iterator] == Char)
			return m_Iterator;
	}

	return -1;
}

/**
 * @ Finds First Occurrence Of Specified Char From Left
 */
hCSGO_PrivateCall int hCSGO_FindFirstCharLeft(_hCSGO_In_ char[] Buffer, _hCSGO_In_ int Char)
{
	static int m_Iterator;

	m_Iterator = 0;

	for (; m_Iterator < strlen(Buffer); m_Iterator++)
	{
		if (Buffer[m_Iterator] == Char)
			return m_Iterator;
	}

	return -1;
}

/**
 * @ Gets Char Position By Occurrence Number
 */
hCSGO_PrivateCall int hCSGO_GetCharPosByOccNo(_hCSGO_In_ char[] Buffer, _hCSGO_In_ int Char, \
												_hCSGO_In_ int Number)
{
	static int m_Iterator;
	static int m_Occurrences;

	m_Iterator = 0;
	m_Occurrences = 0;

	for (; m_Iterator < strlen(Buffer); m_Iterator++)
	{
		if (Buffer[m_Iterator] == Char)
		{
			if (++m_Occurrences == Number)
			{
				return m_Iterator;
			}
		}
	}

	return -1;
}

/**
 * @ Removes Workshop Data From Map Name
 */
hCSGO_PrivateCall int hCSGO_RemoveWorkshop(_hCSGO_In_Out_ char[] Map, _hCSGO_In_ int Size, \
											_hCSGO_In_ bool appendBSP = false)
{
	static int m_Length, m_Char;
	static bool m_bStripped;

	m_Length = strlen(Map);

	if (m_Length == 0)
		return m_Length;

	if (appendBSP && StrContains(Map, ".bsp", false) != -1)
		appendBSP = false;

	m_bStripped = false;

	if (StrContains(Map, "/") != -1)
	{
		m_Char = hCSGO_FindFirstCharRight(Map, '/');

		if (m_Char != -1)
		{
			m_Length = !appendBSP ? Format(Map, Size, Map[m_Char + 1]) : Format(Map, Size, "%s.bsp", Map[m_Char + 1]);

			m_bStripped = true;
		}
	}

	else if (StrContains(Map, "\\") != -1)
	{
		m_Char = hCSGO_FindFirstCharRight(Map, '\\');

		if (m_Char != -1)
		{
			m_Length = !appendBSP ? Format(Map, Size, Map[m_Char + 1]) : Format(Map, Size, "%s.bsp", Map[m_Char + 1]);

			m_bStripped = true;
		}
	}

	if (!m_bStripped && appendBSP)
		m_Length = Format(Map, Size, "%s.bsp", Map);

	return m_Length;
}

/**
 * @ Fix File Line Removing Redundant Spaces And Tabs
 */
hCSGO_PrivateCall int hCSGO_FixFileLine(_hCSGO_In_Out_ char[] FileLine, _hCSGO_In_ int Size, \
										_hCSGO_In_ int Times = 32)
{
	static int m_Iterator;

	for (m_Iterator = 0; m_Iterator < Times; m_Iterator++)
		ReplaceString(FileLine, Size, "\t", " ");

	for (m_Iterator = 0; m_Iterator < Times; m_Iterator++)
		ReplaceString(FileLine, Size, "  ", " ");

	return strlen(FileLine);
}

/**
 * @ Lowers String
 */
hCSGO_PrivateCall int hCSGO_ToLower(_hCSGO_In_Out_ char[] Input = "")
{
	static int m_Iterator;

	m_Iterator = 0;

	for (; m_Iterator < strlen(Input); m_Iterator++)
		Input[m_Iterator] = CharToLower(Input[m_Iterator]);

	return m_Iterator;
}

/**
 * @ Uppers String
 */
hCSGO_PrivateCall int hCSGO_ToUpper(_hCSGO_In_Out_ char[] Input = "")
{
	static int m_Iterator;

	m_Iterator = 0;

	for (; m_Iterator < strlen(Input); m_Iterator++)
		Input[m_Iterator] = CharToUpper(Input[m_Iterator]);

	return m_Iterator;
}

/**
 * @ Gets Time String By Minutes
 */
hCSGO_PrivateCall int hCSGO_GetTimeStringMinutes(_hCSGO_In_ int Minutes, _hCSGO_Out_ char[] Output, _hCSGO_In_ int Size)
{
	static int m_Hours, m_Minutes;

	m_Hours = 0;
	m_Minutes = hCSGO_AbsInt(Minutes);

	if (m_Minutes == 0)
		return FormatEx(Output, Size, "0 m");

	while (m_Minutes >= hCSGO_MinInHr)
	{
		m_Hours++;

		m_Minutes -= hCSGO_MinInHr;
	}

	if (m_Hours > 0)
	{
		if (m_Minutes > 0)
			return FormatEx(Output, Size, "%d h %d m", m_Hours, m_Minutes);

		return FormatEx(Output, Size, "%d h", m_Hours);
	}

	return FormatEx(Output, Size, "%d m", m_Minutes);
}

/**
 * @ Counts How Many Players In A Team Own A Specific Weapon
 */
hCSGO_PrivateCall int hCSGO_CountPlayersWeapon(_hCSGO_In_ int Team, \
												_hCSGO_In_ char[] Weapon, \
												_hCSGO_In_ bool bPartialMatch = true)
{
	static int m_Id, m_WeaponA, m_WeaponB, m_Count;
	static char m_ClassA[MAX_NAME_LENGTH], m_ClassB[MAX_NAME_LENGTH];
	static bool m_bSkip;

	m_Count = 0;

	for (m_Id = 1; m_Id <= MaxClients; m_Id++)
	{
		if (IsClientInGame(m_Id) && IsPlayerAlive(m_Id) && GetClientTeam(m_Id) == Team)
		{
			m_bSkip = false;

			m_WeaponA = INVALID_ENT_REFERENCE;
			m_WeaponA = GetEntPropEnt(m_Id, Prop_Send, "m_hActiveWeapon");

			if (m_WeaponA != INVALID_ENT_REFERENCE)
			{
				if (GetEdictClassname(m_WeaponA, m_ClassA, sizeof(m_ClassA)))
				{
					if (bPartialMatch)
					{
						if (StrContains(m_ClassA, Weapon, false) != -1)
						{
							m_bSkip = true;

							m_Count++;
						}
					}

					else
					{
						if (strcmp(m_ClassA, Weapon, false) == 0)
						{
							m_bSkip = true;

							m_Count++;
						}
					}
				}
			}

			if (!m_bSkip)
			{
				m_WeaponB = INVALID_ENT_REFERENCE;
				m_WeaponB = GetPlayerWeaponSlot(m_Id, CS_SLOT_PRIMARY);

				if (m_WeaponB != INVALID_ENT_REFERENCE)
				{
					if (GetEdictClassname(m_WeaponB, m_ClassB, sizeof(m_ClassB)))
					{
						if (bPartialMatch)
						{
							if (StrContains(m_ClassB, Weapon, false) != -1)
							{
								m_Count++;
							}
						}

						else
						{
							if (strcmp(m_ClassB, Weapon, false) == 0)
							{
								m_Count++;
							}
						}
					}
				}
			}
		}
	}

	return m_Count;
}

/**
 * @ Pures Client Chat Command
 */
hCSGO_PrivateCall int hCSGO_PureChatCommand(_hCSGO_In_ char[] Input, _hCSGO_Out_ char[] Output, _hCSGO_In_ int Size)
{
	static int m_Iterator, m_Length;

	m_Iterator = 0;
	m_Length = 0;

	Output[0] = EOS;

	for (; m_Iterator < strlen(Input); m_Iterator++)
	{
		if (Input[m_Iterator] == '!' || Input[m_Iterator] == '/' || \
			IsCharAlpha(Input[m_Iterator]) || IsCharNumeric(Input[m_Iterator]))
		{
			m_Length = Format(Output, Size, "%s%c", Output, Input[m_Iterator]);
		}
	}

	return m_Length;
}

/**
 * @ Clamps Int Value
 */
hCSGO_PrivateCall int hCSGO_ClampInt(_hCSGO_In_ int Val, _hCSGO_In_ int Min, _hCSGO_In_ int Max)
{
	if (Val < Min)
		return Min;

	if (Val > Max)
		return Max;

	return Val;
}

/**
 * @ Clamps Float Value
 */
hCSGO_PrivateCall float hCSGO_ClampFloat(_hCSGO_In_ float Val, _hCSGO_In_ float Min, _hCSGO_In_ float Max)
{
	if (Val < Min)
		return Min;

	if (Val > Max)
		return Max;

	return Val;
}

/**
 * @ Gets Players Count Per Team
 */
hCSGO_PrivateCall int hCSGO_CountTeam(_hCSGO_In_ int Team = CS_TEAM_NONE, _hCSGO_In_ bool bOnlyAlive = false)
{
	static int m_Player, m_Count;

	m_Player = 1;
	m_Count = 0;

	for (; m_Player <= MaxClients; m_Player++)
	{
		if (!IsClientInGame(m_Player) || GetClientTeam(m_Player) != Team)
			continue;

		if (bOnlyAlive && !IsPlayerAlive(m_Player))
			continue;

		m_Count++;
	}

	return m_Count;
}

/**
 * @ Gets One Player From Team
 */
hCSGO_PrivateCall int hCSGO_GetOnePlayerTeam(_hCSGO_In_ int Team = CS_TEAM_NONE, _hCSGO_In_ bool bOnlyAlive = false)
{
	static int m_Player, playersTable[MAXPLAYERS], playersSize;

	for (m_Player = 1, playersSize = 0; m_Player <= MaxClients; m_Player++)
	{
		if (!IsClientInGame(m_Player) || GetClientTeam(m_Player) != Team)
			continue;

		if (bOnlyAlive && !IsPlayerAlive(m_Player))
			continue;

		playersTable[playersSize++] = m_Player;
	}

	playersTable[playersSize] = 0;

	if (playersSize == 0)
		return INVALID_ENT_REFERENCE;

	return playersTable[GetRandomInt(0, playersSize - 1)];
}

/**
 * @ Checks Whether Certain Client Is Any Kind Of Admin
 */
hCSGO_PrivateCall bool hCSGO_IsClientAdmin(_hCSGO_In_ int Id)
{
	static int m_Flags;

	m_Flags = GetUserFlagBits(Id);

	if (m_Flags & ADMFLAG_RESERVATION || m_Flags & ADMFLAG_CHAT || m_Flags & ADMFLAG_KICK || m_Flags & ADMFLAG_ROOT)
		return true;

	return false;
}

/**
 * @ Extracts Pure ID from the Steam ID
 */
hCSGO_PrivateCall int hCSGO_ExtractSteamID(_hCSGO_In_ char[] Input, _hCSGO_Out_ char[] Output, _hCSGO_In_ int Size)
{
	static char m_Patterns[][] =
	{
		"STEAM_0:0:", "STEAM_0:1:",
		"STEAM_1:0:", "STEAM_1:1:"
	};

	static int m_Iterator, m_Length;

	m_Iterator = 0;
	m_Length = FormatEx(Output, Size, Input);

	for (; m_Iterator < sizeof(m_Patterns); m_Iterator++)
		m_Length = ReplaceString(Output, Size, m_Patterns[m_Iterator], "", false);

	return m_Length;
}

/**
 * @ Adds Commas
 */
hCSGO_PrivateCall int hCSGO_AddCommas(_hCSGO_In_ int Number, _hCSGO_Out_ char[] Output, _hCSGO_In_ int Size)
{
	static char m_Buffer[MAX_NAME_LENGTH];
	static int m_outPos, m_noPos, m_noLen;

	m_outPos = 0;
	m_noPos = 0;

	if (Number < 0)
	{
		Output[m_outPos++] = '-';

		Number = hCSGO_AbsInt(Number);
	}

	if ((m_noLen = IntToString(Number, m_Buffer, sizeof(m_Buffer))) <= 3)
		m_outPos = strcopy(Output[m_outPos], Size, m_Buffer);

	else
	{
		while (m_noPos < m_noLen)
		{
			Output[m_outPos++] = m_Buffer[m_noPos++];

			if (m_noLen - m_noPos != 0 && (m_noLen - m_noPos) % 3 == 0)
				Output[m_outPos++] = ',';
		}

		Output[m_outPos] = EOS;
	}

	return m_outPos;
}

/**
 * @ Clears Line By Removing The Left/ Right Quotes And Trimming Left/ Right White Spaces A Number Of Times
 */
hCSGO_PrivateCall int hCSGO_ClearLine(_hCSGO_In_Out_ char[] Line, _hCSGO_In_ int Times = 4)
{
	static int m_Iterator, m_Length;

	m_Iterator = 0;
	m_Length = strlen(Line);

	for (; m_Iterator < Times; m_Iterator++)
	{
		StripQuotes(Line);
		m_Length = TrimString(Line);
	}

	return m_Length;
}

/**
 * @ Gets [Client/ Admin/ Server] Name Safe
 */
hCSGO_PrivateCall bool hCSGO_GetName(_hCSGO_In_ int Id, _hCSGO_Out_ char[] Output, _hCSGO_In_ int Size)
{
	static Handle pConVar = INVALID_HANDLE;

	if (Id >= 1 && Id <= MaxClients)
		return GetClientName(Id, Output, Size);

	if (pConVar == INVALID_HANDLE)
		pConVar = FindConVar("hostname");

	if (pConVar != INVALID_HANDLE)
	{
		GetConVarString(pConVar, Output, Size);

		return true;
	}

	Output[0] = EOS;

	return false;
}

/**
 * @ Quietly Sets Console Variable Int
 */
hCSGO_PrivateCall bool hCSGO_QuietSetConVarInt(_hCSGO_In_ Handle pConVar, _hCSGO_In_ int Value)
{
	static int m_oldFlags, m_newFlags;
	static bool m_bChanged;

	m_bChanged = false;
	m_oldFlags = GetConVarFlags(pConVar);

	if (m_oldFlags & FCVAR_NOTIFY)
	{
		m_newFlags = m_oldFlags;
		m_newFlags &= ~FCVAR_NOTIFY;

		SetConVarFlags(pConVar, m_newFlags);

		m_bChanged = true;
	}

	SetConVarInt(pConVar, Value);

	if (m_bChanged)
		SetConVarFlags(pConVar, m_oldFlags);

	return m_bChanged;
}

/**
 * @ Quietly Sets Console Variable String
 */
hCSGO_PrivateCall bool hCSGO_QuietSetConVarString(_hCSGO_In_ Handle pConVar, _hCSGO_In_ char[] Value)
{
	static int m_oldFlags, m_newFlags;
	static bool m_bChanged;

	m_bChanged = false;
	m_oldFlags = GetConVarFlags(pConVar);

	if (m_oldFlags & FCVAR_NOTIFY)
	{
		m_newFlags = m_oldFlags;
		m_newFlags &= ~FCVAR_NOTIFY;

		SetConVarFlags(pConVar, m_newFlags);

		m_bChanged = true;
	}

	SetConVarString(pConVar, Value);

	if (m_bChanged)
		SetConVarFlags(pConVar, m_oldFlags);

	return m_bChanged;
}

/**
 * @ Quietly Sets Console Variable Float
 */
hCSGO_PrivateCall bool hCSGO_QuietSetConVarFloat(_hCSGO_In_ Handle pConVar, _hCSGO_In_ float Value)
{
	static int m_oldFlags, m_newFlags;
	static bool m_bChanged;

	m_bChanged = false;
	m_oldFlags = GetConVarFlags(pConVar);

	if (m_oldFlags & FCVAR_NOTIFY)
	{
		m_newFlags = m_oldFlags;
		m_newFlags &= ~FCVAR_NOTIFY;

		SetConVarFlags(pConVar, m_newFlags);

		m_bChanged = true;
	}

	SetConVarFloat(pConVar, Value);

	if (m_bChanged)
		SetConVarFlags(pConVar, m_oldFlags);

	return m_bChanged;
}

/**
 * @ Returns True If Called In Warmup Period
 */
hCSGO_PrivateCall bool hCSGO_IsWarmup()
{
	return GameRules_GetProp("m_bWarmupPeriod") ? true : false;
}

/**
 * @ Gets Option From File Int
 */
hCSGO_PrivateCall int hCSGO_GetOptFromFileInt(_hCSGO_In_ char[] fileName, \
												_hCSGO_In_ char[] keyName, \
												_hCSGO_In_ bool bUseSMPath = true)
{
	static Handle m_pFile;
	static char m_Buffer[PLATFORM_MAX_PATH * 4];
	static int m_Iterator, m_Length;

	if (bUseSMPath)
		BuildPath(Path_SM, m_Buffer, sizeof(m_Buffer), fileName);

	else
		FormatEx(m_Buffer, sizeof(m_Buffer), fileName);

	m_pFile = OpenFile(m_Buffer, "rt");

	if (m_pFile != INVALID_HANDLE)
	{
		while (!IsEndOfFile(m_pFile) && ReadFileLine(m_pFile, m_Buffer, sizeof(m_Buffer)))
		{
			TrimString(m_Buffer);

			if (strlen(m_Buffer) < 1 || \
				m_Buffer[0] == ';' || \
				m_Buffer[0] == '#' || \
				(m_Buffer[0] == '/' && m_Buffer[1] == '/'))
			{
				continue;
			}

			hCSGO_FixFileLine(m_Buffer, sizeof(m_Buffer));

			if (strlen(m_Buffer) < 1)
				continue;

			ReplaceString(m_Buffer, sizeof(m_Buffer), "\"", "");

			if (strlen(m_Buffer) < 1 || strncmp(m_Buffer, keyName, strlen(keyName), false) != 0)
				continue;

			m_Length = strlen(m_Buffer);

			for (m_Iterator = 0; m_Iterator < m_Length; m_Iterator++)
			{
				if (m_Iterator != m_Length - 1 && \
					m_Buffer[m_Iterator] == ' ' && \
					IsCharNumeric(m_Buffer[m_Iterator + 1]))
				{
					CloseHandle(m_pFile);

					return StringToInt(m_Buffer[m_Iterator + 1]);
				}
			}
		}

		CloseHandle(m_pFile);
	}

	return 0;
}

/**
 * @ Gets Option From File Char
 */
hCSGO_PrivateCall int hCSGO_GetOptFromFileChar(_hCSGO_In_ char[] fileName, \
												_hCSGO_In_ char[] keyName, \
												_hCSGO_Out_ char[] Output, \
												_hCSGO_In_ int maxSize, \
												_hCSGO_In_ bool bUseSMPath = true)
{
	static Handle m_pFile;
	static char m_Buffer[PLATFORM_MAX_PATH * 4];
	static int m_Iterator, m_Length;

	if (bUseSMPath)
		BuildPath(Path_SM, m_Buffer, sizeof(m_Buffer), fileName);

	else
		FormatEx(m_Buffer, sizeof(m_Buffer), fileName);

	m_pFile = OpenFile(m_Buffer, "rt");

	if (m_pFile != INVALID_HANDLE)
	{
		while (!IsEndOfFile(m_pFile) && ReadFileLine(m_pFile, m_Buffer, sizeof(m_Buffer)))
		{
			TrimString(m_Buffer);

			if (strlen(m_Buffer) < 1 || \
				m_Buffer[0] == ';' || \
				m_Buffer[0] == '#' || \
				(m_Buffer[0] == '/' && m_Buffer[1] == '/'))
			{
				continue;
			}

			hCSGO_FixFileLine(m_Buffer, sizeof(m_Buffer));

			if (strlen(m_Buffer) < 1)
				continue;

			ReplaceString(m_Buffer, sizeof(m_Buffer), "\"", "");

			if (strlen(m_Buffer) < 1 || strncmp(m_Buffer, keyName, strlen(keyName), false) != 0)
				continue;

			m_Length = strlen(m_Buffer);

			for (m_Iterator = 0; m_Iterator < m_Length; m_Iterator++)
			{
				if (m_Iterator != m_Length - 1 && \
					(m_Buffer[m_Iterator] == ' ' || m_Buffer[m_Iterator] == '\t'))
				{
					CloseHandle(m_pFile);

					return FormatEx(Output, maxSize, m_Buffer[m_Iterator + 1]);
				}
			}
		}

		CloseHandle(m_pFile);
	}

	return FormatEx(Output, maxSize, "");
}

/**
 * @ Checks Whether Key Exists In File
 */
hCSGO_PrivateCall bool hCSGO_KeyExists(_hCSGO_In_ char[] fileName, \
												_hCSGO_In_ char[] keyName, \
												_hCSGO_In_ bool bUseSMPath = true)
{
	static Handle m_pFile;
	static char m_Buffer[PLATFORM_MAX_PATH];

	if (bUseSMPath)
		BuildPath(Path_SM, m_Buffer, sizeof(m_Buffer), fileName);

	else
		FormatEx(m_Buffer, sizeof(m_Buffer), fileName);

	m_pFile = OpenFile(m_Buffer, "rt");

	if (m_pFile != INVALID_HANDLE)
	{
		while (!IsEndOfFile(m_pFile) && ReadFileLine(m_pFile, m_Buffer, sizeof(m_Buffer)))
		{
			TrimString(m_Buffer);

			if (strlen(m_Buffer) < 1 || \
				m_Buffer[0] == ';' || \
				m_Buffer[0] == '#' || \
				(m_Buffer[0] == '/' && m_Buffer[1] == '/'))
			{
				continue;
			}

			hCSGO_FixFileLine(m_Buffer, sizeof(m_Buffer));

			if (strlen(m_Buffer) < 1)
				continue;

			ReplaceString(m_Buffer, sizeof(m_Buffer), "\"", "");

			if (strlen(m_Buffer) < 1 || StrContains(m_Buffer, keyName, false) == -1)
				continue;

			CloseHandle(m_pFile);

			return true;
		}

		CloseHandle(m_pFile);
	}

	return false;
}

/**
 * @ Plays Sound To Client
 */
hCSGO_PrivateCall void hCSGO_PlaySound(_hCSGO_In_ int Client, _hCSGO_In_ char[] Sound, \
											_hCSGO_In_ int Channel = SNDCHAN_AUTO, \
												_hCSGO_In_ float Volume = SNDVOL_NORMAL)
{
	EmitSoundToClient(Client, Sound, _, Channel, _, _, Volume);
}

/**
 * @ Plays Ambient Sound To Client
 */
hCSGO_PrivateCall void hCSGO_PlayAmbientSound(_hCSGO_In_ int Client, _hCSGO_In_ char[] Sound, \
												_hCSGO_In_ float Volume = SNDVOL_NORMAL, \
													_hCSGO_In_ int Level = SNDLEVEL_NORMAL, \
														_hCSGO_In_ bool bFromWorld = true)
{
	static float pOrigin[3];
	
	if (Client >= 1 && Client <= MaxClients)
		GetClientEyePosition(Client, pOrigin);
	
	else
		GetEntPropVector(Client, Prop_Data, "m_vecAbsOrigin", pOrigin);
	
	EmitAmbientSound(Sound,
						pOrigin,
							bFromWorld ? SOUND_FROM_WORLD : Client,
								Level,
									SND_NOFLAGS,
										Volume);
}
