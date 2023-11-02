#include <sourcemod>
#include <sendproxy>

#pragma semicolon 1
#pragma newdecls required

#define IsValidClient(%0) 				(1 <= %0 <= MaxClients && IsClientInGame(%0) && !IsFakeClient(%0) && !IsClientSourceTV(%0) && !IsClientReplay(%0))
#define PLUGIN_VERSION "2.7"

int user_flag;

ConVar AdminESPflag = null;
ConVar AdminESPglow = null;

ConVar sv_competitive_official_5v5;
ConVar mp_weapons_glow_on_ground;

public Plugin myinfo = {
	name        = "CS:GO Esl Admin ESP (mmcs.pro)",
	author      = "SAZONISCHE",
	description = "ESP/WH for Admins",
	version     = PLUGIN_VERSION,
	url         = "https://mmcs.pro/"
};

public void OnPluginStart() {
	if(GetEngineVersion() != Engine_CSGO)
		SetFailState("This plugin works only on CS:GO. Disabling plugin...");

	if(GetConVarInt(FindConVar("sv_parallel_packentities")) == 1)
		SetFailState("Please set convar sv_parallel_packentities to 0. Disabling plugin...");

	CreateConVar("sm_esl_adminesp_version", PLUGIN_VERSION, "Version of CS:GO Esl Admin ESP", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	AdminESPflag = CreateConVar("sm_esl_adminesp_flag", "d", "Admin flag, blank=any flag", FCVAR_NOTIFY);
	AdminESPglow = CreateConVar("sm_esl_adminesp_weapons_glow_on_ground", "1", "Enable glow weapons on ground", 0, true, 0.0, true, 1.0);
	AdminESPflag.AddChangeHook(OnCvarChanged);

	sv_competitive_official_5v5 = FindConVar("sv_competitive_official_5v5");
	mp_weapons_glow_on_ground = FindConVar("mp_weapons_glow_on_ground");

	AutoExecConfig(true, "esl_admin_esp");
	
	HookEvent("player_death", ReloadEvent);
	HookEvent("player_team", ReloadEvent);
	HookEvent("player_spawn", ReloadEvent);
}

public void OnClientPostAdminCheck(int client) {
	if (IsValidClient(client)) {
		int bits = GetUserFlagBits(client);
		SendConVarValue(client, sv_competitive_official_5v5, (bits & (user_flag|ADMFLAG_ROOT)) ? "1" : "0");
		if (bits & (user_flag|ADMFLAG_ROOT)) {
			if (AdminESPglow.BoolValue && !IsPlayerAlive(client))
				SetGlow(client, true);
		}
	}
}

public void OnClientDisconnect(int client) {
	if (!IsFakeClient(client)) 
		SetEspHook(client, false);
}

public void OnMapStart() {
	char m_BaseFlags[32];
	GetConVarString(AdminESPflag, m_BaseFlags, sizeof(m_BaseFlags));
	user_flag = ReadFlagString(m_BaseFlags);
}

public void OnCvarChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	if (convar == AdminESPflag) {
		user_flag = ReadFlagString(newValue);
		for (int client = 1; client <= MaxClients; client++)
			OnClientPostAdminCheck(client);
	}
}

public Action ReloadEvent(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsValidClient(client)) {
		int bits = GetUserFlagBits(client);
		switch (name[7]) {
			case 'd':{
				if(bits & (user_flag|ADMFLAG_ROOT)) {
					SetEspHook(client, true);
					if (AdminESPglow.BoolValue)
						SetGlow(client, true);
				}
			}
			case 't':{
				int team = event.GetInt("team");
				if (team >= 2 && IsPlayerAlive(client)) {
					SetEspHook(client, false);
					if (AdminESPglow.BoolValue)
						SetGlow(client, false);
				} else if (team <= 1 && (bits & (user_flag|ADMFLAG_ROOT))) {
					SetEspHook(client, false);
					if (AdminESPglow.BoolValue)
						SetGlow(client, true);
				} else if (bits & (user_flag|ADMFLAG_ROOT)) {
					SetEspHook(client, true);
					if (AdminESPglow.BoolValue)
						SetGlow(client, true);
				}
			}
			case 's':{
				if (IsPlayerAlive(client)) {
					SetEspHook(client, false);
					if (AdminESPglow.BoolValue && (bits & (user_flag|ADMFLAG_ROOT)))
						SetGlow(client, false);
				}
			}
		}
	}
	return Plugin_Continue;
}

public bool SetEspHook(int client, bool value) {
	if (value) {
		if (!SendProxy_IsHooked(client, "m_iTeamNum"))
			SendProxy_Hook(client, "m_iTeamNum", Prop_Int, Set_Esp);
	} else {
		if (SendProxy_IsHooked(client, "m_iTeamNum"))
			SendProxy_Unhook(client, "m_iTeamNum", Set_Esp);
	}
}

public bool SetGlow(int client, bool value) {
	SendConVarValue(client, mp_weapons_glow_on_ground, value ? "1" : "0");
}

public Action Set_Esp(int entity, const char[] PropName, int &iValue, int element) {
	if (iValue) {
		iValue = 1;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
