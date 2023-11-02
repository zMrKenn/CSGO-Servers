#pragma semicolon 1
#include <csgocolors>
#include <store>
#pragma newdecls required

int ScrollTimes[MAXPLAYERS + 1];
int WinNumber[MAXPLAYERS + 1];
int betAmount[MAXPLAYERS + 1];
bool isSpinning[MAXPLAYERS + 1] = false;


ConVar g_Cvar_NormalItems;

char g_sNormalItems[64];
#define PLUGIN_NAME "Roleta Casino by Goncalo"
#define PLUGIN_AUTHOR "Goncalo"
#define PLUGIN_DESCRIPTION "Zephyrus Store Roulette"
#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_TAG "{pink}[GodGeneration Roleta]{green}"

public Plugin myinfo =
{
    name        =    PLUGIN_NAME,
    author        =    PLUGIN_AUTHOR,
    description    =    PLUGIN_DESCRIPTION,
    version        =    PLUGIN_VERSION,
    url            =    "https://steamcommunity.com/groups/GodGenerationCM"
};

public void OnPluginStart()
{	
	g_Cvar_NormalItems = CreateConVar("goncalo_roulette_normal_items", "50,100,250,500", "Lists all the menu items for normal player roulette. Separate each item with a comma. Only integers allowed");
	RegConsoleCmd("sm_roleta", CommandRoulette);
	RegConsoleCmd("sm_roulette", CommandRoulette);
	LoadTranslations("goncalo_roulette.phrases");
	AutoExecConfig(true, "goncalo_roulette");
}

public void OnClientPostAdminCheck(int client)
{
	isSpinning[client] = false;
}

public Action CommandRoulette(int client, int args)
{
	if (client > 0 && args < 1)
	{		
		CreateRouletteMenu(client).Display(client, 10);	
	}
	return Plugin_Handled;
}

Menu CreateRouletteMenu(int client)
{
	Menu menu = new Menu(RouletteMenuHandler);
	char buffer[128];
	Format(buffer, sizeof(buffer), "%T", "ChooseType", client);
	menu.SetTitle(buffer);	
	menu.AddItem("vermelho", "Vermelho");
	menu.AddItem("preto", "Preto");
	menu.AddItem("verde", "Verde");
	return menu;
}

public int RouletteMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char option[32];
				menu.GetItem(selection, option, sizeof(option));
				if (StrEqual(option, "vermelho"))
				{
					CreateVermelhoRouletteMenu(client).Display(client, MENU_TIME_FOREVER);
				}
				if (StrEqual(option, "preto"))
				{
					CreatePretoRouletteMenu(client).Display(client, MENU_TIME_FOREVER);
				}
				if (StrEqual(option, "verde"))
				{
					CreateVerdeRouletteMenu(client).Display(client, MENU_TIME_FOREVER);
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}


Menu CreateVermelhoRouletteMenu(int client)
{
	Menu menu = new Menu(CreditsChosenMenuHandlerVermelho);
	char buffer[128];
	Format(buffer, sizeof(buffer), "%T", "ChooseCredits", client, Store_GetClientCredits(client));
	menu.SetTitle(buffer);	
	GetConVarString(g_Cvar_NormalItems, g_sNormalItems, sizeof(g_sNormalItems));
	char sItems[18][16];
	ExplodeString(g_sNormalItems, ",", sItems, sizeof(sItems), sizeof(sItems[]));
	for (int i = 0; i < sizeof(sItems); i++) {
		if (!StrEqual(sItems[i], "")) {
			menu.AddItem(sItems[i], sItems[i], Store_GetClientCredits(client) >= StringToInt(sItems[i]) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);	
		}
	}
	menu.ExitBackButton = true;
	return menu;
}


Menu CreatePretoRouletteMenu(int client)
{
	Menu menu = new Menu(CreditsChosenMenuHandlerPreto);
	char buffer[128];		
	Format(buffer, sizeof(buffer), "%T", "ChooseCredits", client, Store_GetClientCredits(client));
	menu.SetTitle(buffer);	
	GetConVarString(g_Cvar_NormalItems, g_sNormalItems, sizeof(g_sNormalItems));
	char sItems[18][16];
	ExplodeString(g_sNormalItems, ",", sItems, sizeof(sItems), sizeof(sItems[]));
	for (int i = 0; i < sizeof(sItems); i++) {
		if (!StrEqual(sItems[i], "")) {
			menu.AddItem(sItems[i], sItems[i], Store_GetClientCredits(client) >= StringToInt(sItems[i]) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);	
		}
	}
	menu.ExitBackButton = true;
	return menu;
}

Menu CreateVerdeRouletteMenu(int client)
{
	int numero;
	Menu menu = new Menu(CreditsChosenMenuHandlerVerde);
	char buffer[128];		
	Format(buffer, sizeof(buffer), "%T", "ChooseCredits", client, Store_GetClientCredits(client));
	menu.SetTitle(buffer);	
	GetConVarString(g_Cvar_NormalItems, g_sNormalItems, sizeof(g_sNormalItems));
	char sItems[18][16];
	ExplodeString(g_sNormalItems, ",", sItems, sizeof(sItems), sizeof(sItems[]));
	numero == 14;
	for (int i = 0; i < sizeof(sItems); i++) {
		if (!StrEqual(sItems[i], "")) {
			menu.AddItem(sItems[i], sItems[i], Store_GetClientCredits(client) >= StringToInt(sItems[i]) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);	
		}
	}
	menu.ExitBackButton = true;
	return menu;
}

public int CreditsChosenMenuHandlerVermelho(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char option[32];
				menu.GetItem(selection, option, sizeof(option));
								
				int crd = Store_GetClientCredits(client);
				int bet = StringToInt(option);
				if(crd >= bet)
				{
					if (!isSpinning[client])
					{
						Store_SetClientCredits(client, crd - bet);
						betAmount[client] = bet;
						SpinCreditsVermelho(client);
						isSpinning[client] = true;
					}
					else
					{
						CPrintToChat(client, "%s %t", PLUGIN_TAG, "AlreadySpinning");
					}
				} 
				else
				{
					CPrintToChat(client, "%s %t", PLUGIN_TAG,  "NoEnoughCredits", bet - crd);
				}
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
			{
				CreateRouletteMenu(client).Display(client, 10);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public int CreditsChosenMenuHandlerPreto(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char option[32];
				menu.GetItem(selection, option, sizeof(option));
								
				int crd = Store_GetClientCredits(client);
				int bet = StringToInt(option);
				if(crd >= bet)
				{
					if (!isSpinning[client])
					{
						Store_SetClientCredits(client, crd - bet);
						betAmount[client] = bet;
						SpinCreditsPreto(client);
						isSpinning[client] = true;
					}
					else
					{
						CPrintToChat(client, "%s %t", PLUGIN_TAG, "AlreadySpinning");
					}
				} 
				else
				{
					CPrintToChat(client, "%s %t", PLUGIN_TAG,  "NoEnoughCredits", bet - crd);
				}
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
			{
				CreateRouletteMenu(client).Display(client, 10);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public int CreditsChosenMenuHandlerVerde(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char option[32];
				menu.GetItem(selection, option, sizeof(option));
								
				int crd = Store_GetClientCredits(client);
				int bet = StringToInt(option);
				if(crd >= bet)
				{
					if (!isSpinning[client])
					{
						Store_SetClientCredits(client, crd - bet);
						betAmount[client] = bet;
						SpinCreditsVerde(client);
						isSpinning[client] = true;
					}
					else
					{
						CPrintToChat(client, "%s %t", PLUGIN_TAG, "AlreadySpinning");
					}
				} 
				else
				{
					CPrintToChat(client, "%s %t", PLUGIN_TAG,  "NoEnoughCredits", bet - crd);
				}
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
			{
				CreateRouletteMenu(client).Display(client, 10);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public void SpinCreditsVermelho(int client)
{
	int	FakeNumber = GetRandomInt(0,29);
	PrintHintText(client, "<font color='#ff0000'>[Roleta GodGeneration]</font><font color='#00ff00'> Number:</font><font color='#0000ff'> %i", FakeNumber);
	if(ScrollTimes[client] < 20)
	{
		CreateTimer(0.05, TimerNextVermelho, client);
		ScrollTimes[client] += 1;
	} 
	else if(ScrollTimes[client] < 30)
	{
		float AddSomeTime = 0.05 * ScrollTimes[client] / 3;
		CreateTimer(AddSomeTime, TimerNextVermelho, client);
		ScrollTimes[client] += 1;
	}
	else if(ScrollTimes[client] == 30)
	{
		int troll = GetRandomInt(1,2);
		if(troll == 1)
		{
			ScrollTimes[client] += 1;
			CreateTimer(1.5, TimerNextVermelho, client);
		}
		else
		{
			CreateTimer(1.5, TimerFinishingVermelho, client);
			WinNumber[client] = FakeNumber;
			ScrollTimes[client] = 0;
		}
	} 
	else
	{
		CreateTimer(1.5, TimerFinishingVermelho, client);
		WinNumber[client] = FakeNumber;
		ScrollTimes[client] = 0;
	}
}
public void SpinCreditsPreto(int client)
{
	int	FakeNumber = GetRandomInt(0,29);
	PrintHintText(client, "<font color='#ff0000'>[Roleta GodGeneration]</font><font color='#00ff00'> Number:</font><font color='#0000ff'> %i", FakeNumber);
	if(ScrollTimes[client] < 20)
	{
		CreateTimer(0.05, TimerNextPreto, client);
		ScrollTimes[client] += 1;
	} 
	else if(ScrollTimes[client] < 30)
	{
		float AddSomeTime = 0.05 * ScrollTimes[client] / 3;
		CreateTimer(AddSomeTime, TimerNextPreto, client);
		ScrollTimes[client] += 1;
	}
	else if(ScrollTimes[client] == 30)
	{
		int troll = GetRandomInt(1,2);
		if(troll == 1)
		{
			ScrollTimes[client] += 1;
			CreateTimer(1.5, TimerNextPreto, client);
		}
		else
		{
			CreateTimer(1.5, TimerFinishingPreto, client);
			WinNumber[client] = FakeNumber;
			ScrollTimes[client] = 0;
		}
	} 
	else
	{
		CreateTimer(1.5, TimerFinishingPreto, client);
		WinNumber[client] = FakeNumber;
		ScrollTimes[client] = 0;
	}
}
public void SpinCreditsVerde(int client)
{
	int	FakeNumber = GetRandomInt(0,29);
	PrintHintText(client, "<font color='#ff0000'>[Roleta GodGeneration]</font><font color='#00ff00'> Number:</font><font color='#0000ff'> %i", FakeNumber);
	if(ScrollTimes[client] < 20)
	{
		CreateTimer(0.05, TimerNextVerde, client);
		ScrollTimes[client] += 1;
	} 
	else if(ScrollTimes[client] < 30)
	{
		float AddSomeTime = 0.05 * ScrollTimes[client] / 3;
		CreateTimer(AddSomeTime, TimerNextVerde, client);
		ScrollTimes[client] += 1;
	}
	else if(ScrollTimes[client] == 30)
	{
		int troll = GetRandomInt(1,2);
		if(troll == 1)
		{
			ScrollTimes[client] += 1;
			CreateTimer(1.5, TimerNextVerde, client);
		}
		else
		{
			CreateTimer(1.5, TimerFinishingVerde, client);
			WinNumber[client] = FakeNumber;
			ScrollTimes[client] = 0;
		}
	} 
	else
	{
		CreateTimer(1.5, TimerFinishingVerde, client);
		WinNumber[client] = FakeNumber;
		ScrollTimes[client] = 0;
	}
}

public Action TimerFinishingVermelho(Handle timer, any client)
{
	if (IsClientInGame(client))
	{
		isSpinning[client] = false;
		WinCreditsVermelho(client, WinNumber[client], betAmount[client]);
	}
}
public Action TimerFinishingPreto(Handle timer, any client)
{
	if (IsClientInGame(client))
	{
		isSpinning[client] = false;
		WinCreditsPreto(client, WinNumber[client], betAmount[client]);
	}
}
public Action TimerFinishingVerde(Handle timer, any client)
{
	if (IsClientInGame(client))
	{
		isSpinning[client] = false;
		WinCreditsVerde(client, WinNumber[client], betAmount[client]);
	}
}

public void WinCreditsVermelho(int client, int Number, int Bet)
{
	if(IsClientInGame(client))
	{	
		int multiplier;
		if(Number == 0 || Number == 2 || Number == 4 || Number == 6 || Number == 8 || Number == 10 || Number == 12 || Number == 16 || Number == 18 || Number == 20 || Number == 22 || Number == 24 || Number == 26 || Number == 28)
		{
			multiplier = 1;
		}
		else 
		{
			multiplier = -1;
			CPrintToChatAll("%s %t", PLUGIN_TAG, "YouLost", client, Bet);
		}	
		if (multiplier > 0)
		{	
			CPrintToChatAll("%s %t", PLUGIN_TAG, "YouWinVermelho", client, Bet * multiplier, multiplier);
			Store_SetClientCredits(client, Store_GetClientCredits(client) + Bet * (multiplier + 1));
		}
	}
}
public void WinCreditsPreto(int client, int Number, int Bet)
{
	if(IsClientInGame(client))
	{
		int multiplier;
		if(Number == 1 || Number == 3 || Number == 5 || Number == 7 || Number == 9 || Number == 11 || Number == 13 || Number == 15 || Number == 17 || Number == 19 || Number == 21 || Number == 23 || Number == 25 || Number == 27 || Number == 29)
		{
			multiplier = 1;
		}
		else 
		{
			multiplier = -1;
			CPrintToChatAll("%s %t", PLUGIN_TAG, "YouLost", client, Bet);
		}	
		if (multiplier > 0)
		{	
			CPrintToChatAll("%s %t", PLUGIN_TAG, "YouWinPreto", client, Bet * multiplier, multiplier);
			Store_SetClientCredits(client, Store_GetClientCredits(client) + Bet * (multiplier + 1));
		}
	}
}

public void WinCreditsVerde(int client, int Number, int Bet)
{
	if(IsClientInGame(client))
	{	
		int multiplier;
		if(Number == 14)
		{
			multiplier = 14;
		}
		else 
		{
			multiplier = -1;
			CPrintToChatAll("%s %t", PLUGIN_TAG, "YouLost", client, Bet);
		}	
		if (multiplier > 0)
		{	
			CPrintToChatAll("%s %t", PLUGIN_TAG, "YouWinVerde", client, Bet * multiplier, multiplier);
			Store_SetClientCredits(client, Store_GetClientCredits(client) + Bet * (multiplier + 1));
		}
	}
}


public Action TimerNextVermelho(Handle timer, any client)
{
	if (IsClientInGame(client))
	{
		SpinCreditsVermelho(client);
	}
}
public Action TimerNextPreto(Handle timer, any client)
{
	if (IsClientInGame(client))
	{
		SpinCreditsPreto(client);
	}
}
public Action TimerNextVerde(Handle timer, any client)
{
	if (IsClientInGame(client))
	{
		SpinCreditsVerde(client);
	}
}
