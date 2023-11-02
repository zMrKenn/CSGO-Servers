#pragma semicolon 1
#include <sourcemod>
#include <vip_core>

public Plugin:myinfo = 
{
	name = "[VIP] Time VIP",
	author = "R1KO",
	version = "1.0.0"
};

new String:g_sGroup[64];
new String:g_sStartTime[64];
new String:g_sEndTime[64];
new bool:g_bGive;

public OnPluginStart()
{
	new Handle:hCvar = CreateConVar("sm_vip_time_group", "vip", "Группа VIP-статуса");
	HookConVarChange(hCvar, OnGroupChange);
	GetConVarString(hCvar, g_sGroup, sizeof(g_sGroup));

	hCvar = CreateConVar("sm_vip_time_start", "00:00", "Начало времени");
	HookConVarChange(hCvar, OnStartTimeChange);
	GetConVarString(hCvar, g_sStartTime, sizeof(g_sStartTime));

	hCvar = CreateConVar("sm_vip_time_end", "05:00", "Конец времени");
	HookConVarChange(hCvar, OnEndTimeChange);
	GetConVarString(hCvar, g_sEndTime, sizeof(g_sEndTime));

	AutoExecConfig(true, "time_vip", "vip");
}

public OnGroupChange(Handle:hCvar, const String:sOldValue[], const String:sNewValue[])			strcopy(g_sGroup, sizeof(g_sGroup), sNewValue);
public OnStartTimeChange(Handle:hCvar, const String:sOldValue[], const String:sNewValue[])		strcopy(g_sStartTime, sizeof(g_sStartTime), sNewValue);
public OnEndTimeChange(Handle:hCvar, const String:sOldValue[], const String:sNewValue[])			strcopy(g_sEndTime, sizeof(g_sEndTime), sNewValue);

public OnMapStart() 
{
	g_bGive = false;
	
	Timer_CheckTime(INVALID_HANDLE);

	CreateTimer(60.0, Timer_CheckTime, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

#define HOURS		0
#define MINUTES	1

public Action:Timer_CheckTime(Handle:hTimer)
{
	decl String:sTime[64], iCurrentTime[2], iStartTime[2], iEndTime[2];
	FormatTime(sTime, sizeof(sTime), "%H:%M");
	GetIntDate(sTime, iCurrentTime);

	strcopy(sTime, sizeof(sTime), g_sStartTime);
	GetIntDate(sTime, iStartTime);

	strcopy(sTime, sizeof(sTime), g_sEndTime);
	GetIntDate(sTime, iEndTime);

	g_bGive = false;

	if(iCurrentTime[HOURS] == iStartTime[HOURS])
	{
		if(iCurrentTime[MINUTES] > iStartTime[MINUTES])
		{
			g_bGive = true;
			return Plugin_Continue;
		}
	}

	if(iCurrentTime[HOURS] > iStartTime[HOURS])
	{
		if(iCurrentTime[HOURS] < iEndTime[HOURS])
		{
			g_bGive = true;
			return Plugin_Continue;
		}
		else if(iCurrentTime[HOURS] == iEndTime[HOURS])
		{
			if(iCurrentTime[MINUTES] < iStartTime[MINUTES])
			{
				g_bGive = true;
				return Plugin_Continue;
			}
		}
	}

	return Plugin_Continue;
}

GetIntDate(String:sTime[], iDate[2])
{
	iDate[1] = StringToInt(sTime[3]);
	sTime[2] = 0;
	iDate[0] = StringToInt(sTime);
}

public OnClientPutInServer(iClient)
{
	if (g_bGive && !IsFakeClient(iClient)) 
	{
		CreateTimer(4.0, Timer_Delay, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:Timer_Delay(Handle:hTimer, any:UserID)
{
	new iClient = GetClientOfUserId(UserID);
	if(iClient && VIP_IsClientVIP(iClient) == false)
	{
		VIP_SetClientVIP(iClient, 0, AUTH_STEAM, g_sGroup, false);
	}
}


