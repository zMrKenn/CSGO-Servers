#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <vip_core>
#include <clientprefs>

public Plugin:myinfo = 
{
	name = "[VIP] Grenades (CS:GO)",
	author = "R1KO",
	version = "1.0.0 dev"
};

#define VIP_GRENADES		"Grenades"

#define MAX	5

new const String:g_sGrens[][] =
{
	"weapon_hegrenade",
	"weapon_flashbang",
	"weapon_smokegrenade",
	"weapon_molotov",
	"weapon_decoy"
};

public OnPluginStart() 
{
	HookEventEx("hegrenade_detonate",		Event_GrenDetonate);
	HookEventEx("flashbang_detonate",		Event_GrenDetonate);
	HookEventEx("smokegrenade_detonate",		Event_GrenDetonate);
	HookEventEx("molotov_detonate",			Event_GrenDetonate);
	HookEventEx("decoy_detonate",			Event_GrenDetonate);
}

public VIP_OnVIPLoaded()
{
	VIP_RegisterFeature(VIP_GRENADES, STRING, _, OnToggleItem);

	VIP_HookClientSpawn(OnPlayerSpawn);
}

public VIP_OnVIPClientLoaded(iClient)
{
	if(VIP_IsClientFeatureUse(iClient, VIP_GRENADES))
	{
		GetClientGrens(iClient);
	}
}

GetClientGrens(iClient)
{
	decl String:sBuffer[64], String:sParts[MAX][3], iParts;
	VIP_GetClientFeatureString(iClient, VIP_GRENADES, sBuffer, sizeof(sBuffer));
	if((iParts = ExplodeString(sBuffer, ";", sParts, sizeof(sParts), sizeof(sParts[]))) <= MAX)
	{
		decl i, Handle:hTrie;
		hTrie = VIP_GetVIPClientTrie(iClient);
		for(i = 0; i < iParts; ++i) SetTrieValue(hTrie, g_sGrens[i], StringToInt(sParts[i]));
	}
}
public Action:OnToggleItem(iClient, const String:sFeatureName[], VIP_ToggleState:OldStatus, &VIP_ToggleState:NewStatus)
{
	if(NewStatus == ENABLED)
	{
		GetClientGrens(iClient);
	}
	else
	{
		decl i, Handle:hTrie;
		hTrie = VIP_GetVIPClientTrie(iClient);
		for(i = 0; i < MAX; ++i)
		{
			RemoveFromTrie(hTrie, g_sGrens[i]);
		}
	}
	return Plugin_Continue;
}

public OnPlayerSpawn(iClient, iTeam, bool:bIsVIP)
{
	if(bIsVIP && VIP_IsClientFeatureUse(iClient, VIP_GRENADES))
	{
		decl i, Handle:hTrie, iCount;
		hTrie = VIP_GetVIPClientTrie(iClient);
		for(i = 0; i < MAX; ++i)
		{
			if(GetTrieValue(hTrie, g_sGrens[i], iCount) && iCount > 0)
			{
				SetTrieValue(hTrie, g_sGrens[i][7], iCount-1);
				
				if(GetEntProp(iClient, Prop_Send, "m_iAmmo", i+14) < 1)
				{
					GivePlayerItem(iClient, g_sGrens[i]);
				}
			}
		}
	}
}

public Event_GrenDetonate(Handle:hEvent, const String:sEvName[], bool:bSilent)
{
	new iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (iClient && IsPlayerAlive(iClient) && VIP_IsClientVIP(iClient) && VIP_IsClientFeatureUse(iClient, VIP_GRENADES))
	{
		decl i, iCount, Handle:hTrie;
		switch(sEvName[0])
		{
			case 'h': i = 0;
			case 'f': i = 1;
			case 's': i = 2;
			case 'm': i = 3;
			case 'd': i = 4;
		}
		
		hTrie = VIP_GetVIPClientTrie(iClient);
		if(GetTrieValue(hTrie, g_sGrens[i][7], iCount) && iCount > 0 && GetEntProp(iClient, Prop_Send, "m_iAmmo", i+14) < 1)
		{
			SetTrieValue(hTrie, g_sGrens[i][7], iCount-1);
			GivePlayerItem(iClient, g_sGrens[i]);
		}
	}
}
