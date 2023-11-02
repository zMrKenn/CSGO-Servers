
CreateCvars()
{
	CreateConVar("sm_vip_core_version", VIP_VERSION, "VIP-CORE VERSION", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_CHEAT|FCVAR_DONTRECORD);

	decl Handle:hCvar;

	hCvar = CreateConVar("sm_vip_admin_flag", "z", "The administrator's flag required to have access to the management of VIP players.");
	HookConVarChange(hCvar, OnAdminFlagChange);
	g_CVAR_iAdminFlag = UTIL_GetConVarAdminFlag(hCvar);

	g_CVAR_hVIPMenu_CMD = CreateConVar("sm_vip_menu_commands", "vip;sm_vip;sm_vipmenu", "Commands for calling the VIP menu");

	hCvar = CreateConVar("sm_vip_server_id", "0", "Server ID when using MySQL database", _, true, 0.0);
	HookConVarChange(hCvar, OnServerIDChange);
	g_CVAR_iServerID = GetConVarInt(hCvar);
	
	hCvar = CreateConVar("sm_vip_info_show_mode", "1", "Where to output information from information files (0 - Chat, 1 - Menu, 2 - MOTD window)", _, true, 0.0, true, 2.0);
	HookConVarChange(hCvar, OnInfoShowModeChange);
	g_CVAR_iInfoShowMode = GetConVarInt(hCvar);
	
	hCvar = CreateConVar("sm_vip_auto_open_menu", "0", "Automatically open the VIP-menu at the entrance (0 - Disabled, 1 - Enabled)", _, true, 0.0, true, 1.0);
	HookConVarChange(hCvar, OnAutoOpenMenuChange);
	g_CVAR_bAutoOpenMenu = GetConVarBool(hCvar);

	hCvar = CreateConVar("sm_vip_time_mode", "0", "Time format (0 - Seconds, 1 - Minutes, 2 - Hours, 3 - Days)", _, true, 0.0, true, 3.0);
	HookConVarChange(hCvar, OnTimeModeChange);
	g_CVAR_iTimeMode = GetConVarInt(hCvar);

	hCvar = CreateConVar("sm_vip_delete_expired", "0", "Delete VIP-players who have expired (-1 - Do not delete, 0 - Delete immediately,> 0 - Number of days after which to delete)", _, true, -1.0);
	HookConVarChange(hCvar, OnDeleteExpiredChange);
	g_CVAR_iDeleteExpired = GetConVarInt(hCvar);

	hCvar = CreateConVar("sm_vip_update_name", "1", "Update the names of VIP players in the database at the login (0 - Disabled, 1 - Enabled)", _, true, 0.0, true, 1.0);
	HookConVarChange(hCvar, OnUpdateNameChange);
	g_CVAR_bUpdateName = GetConVarBool(hCvar);

	hCvar = CreateConVar("sm_vip_spawn_delay", "1.0", "Delay before installing privileges when the player rebounds", _, true, 0.1);
	HookConVarChange(hCvar, OnSpawnDelayChange);
	g_CVAR_fSpawnDelay = GetConVarFloat(hCvar);

	hCvar = CreateConVar("sm_vip_kick_not_authorized", "0", "Drop players who have VIP status from the server, but do not enter a password (0 - Disabled, 1 - Enabled)", _, true, 0.0, true, 1.0);
	HookConVarChange(hCvar, OnKickNotAuthorizedChange);
	g_CVAR_bKickNotAuthorized = GetConVarBool(hCvar);

	hCvar = CreateConVar("sm_vip_hide_no_access_items", "0", "The mode of displaying inaccessible functions in the menu vip (0 - Make items inactive, 1 - Hide items)", _, true, 0.0, true, 1.0);
	HookConVarChange(hCvar, OnHideNoAccessItemsChange);
	g_CVAR_bHideNoAccessItems = GetConVarBool(hCvar);
	
	hCvar = CreateConVar("sm_vip_logs_enable", "1", "Whether to log logs / VIP_Logs.log (0 - Disabled, 1 - Enabled)", _, true, 0.0, true, 1.0);
	HookConVarChange(hCvar, OnLogsEnableChange);
	g_CVAR_bLogsEnable = GetConVarBool(hCvar);

	AutoExecConfig(true, "VIP_Core", "vip");
}

public OnAdminFlagChange(Handle:hCvar, const String:oldValue[], const String:newValue[])
{
	g_CVAR_iAdminFlag = UTIL_GetConVarAdminFlag(hCvar);
	
	if(VIPAdminMenuObject != INVALID_TOPMENUOBJECT && g_hTopMenu != INVALID_HANDLE)
	{
		RemoveFromTopMenu(g_hTopMenu, VIPAdminMenuObject);
		VIPAdminMenuObject = INVALID_TOPMENUOBJECT;
	}

	AddItemsToTopMenu();
}

public OnServerIDChange(Handle:hCvar, const String:oldValue[], const String:newValue[])					g_CVAR_iServerID = GetConVarInt(hCvar);
public OnInfoShowModeChange(Handle:hCvar, const String:oldValue[], const String:newValue[])				g_CVAR_iInfoShowMode = GetConVarInt(hCvar);
public OnAutoOpenMenuChange(Handle:hCvar, const String:oldValue[], const String:newValue[])				g_CVAR_bAutoOpenMenu = GetConVarBool(hCvar);
public OnTimeModeChange(Handle:hCvar, const String:oldValue[], const String:newValue[])					g_CVAR_iTimeMode = GetConVarInt(hCvar);
public OnDeleteExpiredChange(Handle:hCvar, const String:oldValue[], const String:newValue[])			g_CVAR_iDeleteExpired = GetConVarInt(hCvar);
public OnUpdateNameChange(Handle:hCvar, const String:oldValue[], const String:newValue[])				g_CVAR_bUpdateName = GetConVarBool(hCvar);
public OnSpawnDelayChange(Handle:hCvar, const String:oldValue[], const String:newValue[])				g_CVAR_fSpawnDelay = GetConVarFloat(hCvar);
public OnKickNotAuthorizedChange(Handle:hCvar, const String:oldValue[], const String:newValue[])		g_CVAR_bKickNotAuthorized = GetConVarBool(hCvar);
public OnHideNoAccessItemsChange(Handle:hCvar, const String:oldValue[], const String:newValue[])		g_CVAR_bHideNoAccessItems = GetConVarBool(hCvar);
public OnLogsEnableChange(Handle:hCvar, const String:oldValue[], const String:newValue[])				g_CVAR_bLogsEnable = GetConVarBool(hCvar);
