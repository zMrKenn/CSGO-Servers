#pragma semicolon 1
#pragma tabsize 0
#define DEBUG

#define PREFIX " \x04[Crash-System]\x01"
#define MENUPREFIX "[Crash Menu]"
#include <sourcemod>
#include <sdktools>
#include <store>
#include <multicolors>

#pragma newdecls required

ConVar g_cvMinAmount;
ConVar g_cvMaxAmount;
ConVar g_cvMaxMultiply;
ConVar g_cvChanceToLose;
ConVar g_cvChanceToSmallMultiply;
ConVar g_cvChanceToMediumMultiply;
ConVar g_cvChanceToHighMultiply;
ConVar g_cvMaxSmall;
ConVar g_cvMaxMedium;
ConVar g_cvFastTimer;
ConVar g_cvFasterTimer;
float StartMultiply[MAXPLAYERS + 1];
float rand[MAXPLAYERS + 1];
bool IsPlaying[MAXPLAYERS + 1];
int g_iManualAmount[MAXPLAYERS + 1] = 0;
bool g_bTypingAmount[MAXPLAYERS + 1] = false;
Handle CrashTimer[MAXPLAYERS + 1] = null;
int ClientChance[MAXPLAYERS + 1];
int g_Chances[100];
bool IsCfgValid = true;
public Plugin myinfo = 
{
	name = "Crash System - Zephyrus Store",
	author = "SheriF",
	description = "Gamble your Credits in the Crash System using Zephyrus Store credits",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	g_cvMinAmount = CreateConVar("sm_crash_min_amount", "50", "The minimum amount of Credits to use the Crash System.");
	g_cvMaxAmount = CreateConVar("sm_crash_max_amount", "500", "The maximum amount of Credits to use the Crash System.");
	g_cvMaxMultiply = CreateConVar("sm_max_multiply", "100.0", "The maximum multiplication of credits available in the Crash System.");
	g_cvMaxSmall = CreateConVar("sm_max_small", "2.00", "The maximum multiplication of credits when the chances are small.");
	g_cvMaxMedium = CreateConVar("sm_max_medium", "5.00", "The maximum multiplication of credits when the chances are medium.");
	g_cvChanceToLose = CreateConVar("sm_chance_to_lose", "10", "The percentages to get multiplication of 0 (lose no matter what).");
	g_cvChanceToSmallMultiply = CreateConVar("sm_chance_to_small", "70", "The percentages to get a small multiplication (between 1.01 to sm_max_small value).");
	g_cvChanceToMediumMultiply = CreateConVar("sm_chance_to_medium", "19", "The percentages to get a medium multiplication (between sm_max_small to sm_max_medium values).");
	g_cvChanceToHighMultiply = CreateConVar("sm_chance_to_high", "1", "The percentages to get a high multiplication (between sm_max_medium value to the maximum multiplication of credits available).");
	g_cvFastTimer = CreateConVar("sm_fast_timer", "3.50", "The amount of multiplication when the timer starts to get faster (double speed).");
	g_cvFasterTimer = CreateConVar("sm_faster_timer", "10.00", "The amount of multiplication when the timer starts to get even faster (triple speed).");
	RegConsoleCmd("sm_crash", crash);
	AutoExecConfig(true, "store_crash");
}
public void OnConfigsExecuted()
{
	if((g_cvChanceToLose.IntValue+g_cvChanceToSmallMultiply.IntValue+g_cvChanceToMediumMultiply.IntValue+g_cvChanceToHighMultiply.IntValue)!=100
	|| g_cvMaxSmall.FloatValue<=1.00 || g_cvMinAmount.IntValue<0 || g_cvChanceToLose.IntValue<0 
	|| g_cvChanceToSmallMultiply.IntValue<0 || g_cvChanceToMediumMultiply.IntValue<0 || g_cvChanceToHighMultiply.IntValue<0 
	|| g_cvMaxMedium.FloatValue<=1.00 || g_cvFastTimer.FloatValue<=1.00 || g_cvFasterTimer.FloatValue<=1.00 
	|| g_cvMaxSmall.FloatValue>=g_cvMaxMedium.FloatValue || g_cvMaxSmall.FloatValue>=g_cvMaxMultiply.FloatValue 
	|| g_cvMaxMedium.FloatValue>=g_cvMaxMultiply.FloatValue || g_cvFastTimer.FloatValue>=g_cvMaxMultiply.FloatValue 
	|| g_cvFasterTimer.FloatValue>=g_cvMaxMultiply.FloatValue || g_cvFasterTimer.FloatValue<=g_cvFastTimer.FloatValue)
		IsCfgValid = false;
}
public Action crash(int client,int args)
{
	if(!IsCfgValid)
		return Plugin_Stop;
	if(IsClientInGame(client)&&!IsFakeClient(client))
		ShowMainMenu(client);
return Plugin_Continue;
}
void ShowMainMenu(int client)
{
	Menu CrashMenu = new Menu(menuHandler_CrashMenu);
	CrashMenu.SetTitle("%s", MENUPREFIX);
	char szItem1[64];
	Format(szItem1, sizeof(szItem1), "Current Amount : %i\n[Press to Change]", g_iManualAmount[client]);
	CrashMenu.AddItem("", szItem1);
	CrashMenu.AddItem("", "Start!");
	CrashMenu.ExitButton = true;
	CrashMenu.Display(client, MENU_TIME_FOREVER);
}
void ShowPlayAgainMenu(int client)
{
	Menu CrashMenu = new Menu(menuHandler_CrashMenu2);
	CrashMenu.SetTitle("%s\nDo you want to play again?", MENUPREFIX);
	CrashMenu.AddItem("Yes", "Yes");
	CrashMenu.AddItem("No", "No");
	CrashMenu.ExitButton = false;
	CrashMenu.Display(client, MENU_TIME_FOREVER);
}
public int menuHandler_CrashMenu2(Menu menu, MenuAction action, int client, int itemNUM)
{
	if (action == MenuAction_Select)
	{
		switch (itemNUM)
		{
			case 0:
			ShowMainMenu(client);
			case 1:
			delete menu;
		}
	}
}

public void OnClientDisconnect(int client)
{
	if(IsCfgValid)
	{
		StartMultiply[client] = 1.0;
		IsPlaying[client] = false;
		if (CrashTimer[client] != null)
		{
			KillTimer(CrashTimer[client]);
			CrashTimer[client] = null;
		}
	}		
}
public void OnClientPutInServer(int client)
{
	if(IsCfgValid)
	{
		StartMultiply[client] = 1.0;
		IsPlaying[client] = false;
		if (CrashTimer[client] != null)
		{
			KillTimer(CrashTimer[client]);
			CrashTimer[client] = null;
		}
	}	
}

public int menuHandler_CrashMenu(Menu menu, MenuAction action, int client, int itemNUM)
{
	if (action == MenuAction_Select)
	{
		switch (itemNUM)
		{
			case 0:
			{
				g_bTypingAmount[client] = true;
				CPrintToChat(client, "%s Please type an amount of credits in chat",PREFIX);
			}
			case 1:
			{
				if (Store_GetClientCredits(client) < g_iManualAmount[client])
					CPrintToChat(client, "%s You dont have enough credits to use the Crash System",PREFIX);
				else if(g_iManualAmount[client]==0)
					CPrintToChat(client, "%s Minimum amount of Credits is \x10%i", PREFIX, g_cvMinAmount.IntValue);
				else
				{
					Menu CrashMenu1 = new Menu(menuHandler_CrashMenu1);	
					Store_SetClientCredits(client, Store_GetClientCredits(client) - g_iManualAmount[client]);
					for (int i = 0; i < g_cvChanceToLose.IntValue; i++)
						g_Chances[i] = 0;
					for (int i = g_cvChanceToLose.IntValue; i < g_cvChanceToLose.IntValue+g_cvChanceToSmallMultiply.IntValue; i++)
						g_Chances[i] = 1;
					for (int i = g_cvChanceToLose.IntValue+g_cvChanceToSmallMultiply.IntValue; i < g_cvChanceToLose.IntValue+g_cvChanceToSmallMultiply.IntValue+g_cvChanceToMediumMultiply.IntValue; i++)
						g_Chances[i] = 2;
					for (int i = g_cvChanceToLose.IntValue+g_cvChanceToSmallMultiply.IntValue+g_cvChanceToMediumMultiply.IntValue; i < g_cvChanceToLose.IntValue+g_cvChanceToSmallMultiply.IntValue+g_cvChanceToMediumMultiply.IntValue+g_cvChanceToHighMultiply.IntValue; i++)
						g_Chances[i] = 3;
					ClientChance[client] = GetRandomInt(1, 100);
					if (g_Chances[ClientChance[client]]==0)
					{
						rand[client] = 1.0;
						CPrintToChat(client, "%s You \x07lost \x10%d\x01 Credits since the crash was immediately",PREFIX,g_iManualAmount[client]);
						delete menu;
						if (CrashTimer[client] != null)
						{
							KillTimer(CrashTimer[client]);
							CrashTimer[client] = null;
						}
						ShowPlayAgainMenu(client);
					}
					else
					{
						if (g_Chances[ClientChance[client]]==1)
						{
							rand[client] = GetRandomFloat(1.01, g_cvMaxSmall.FloatValue);
						}
						else if (g_Chances[ClientChance[client]]==2)
						{
							rand[client] = GetRandomFloat(g_cvMaxSmall.FloatValue+0.01, g_cvMaxMedium.FloatValue);
						}
						else if (g_Chances[ClientChance[client]]==3)
						{
							rand[client] = GetRandomFloat(g_cvMaxMedium.FloatValue+0.01, g_cvMaxMultiply.FloatValue);
						}
						StartMultiply[client] = 1.0;
						IsPlaying[client] = true;
						CrashTimer[client] = CreateTimer(0.1, CrashGame, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
						CrashMenu1.SetTitle("%s Crash Started!", MENUPREFIX);
						char szItem1[64];
						Format(szItem1, sizeof(szItem1),"Cashout");
        				CrashMenu1.AddItem(szItem1,szItem1);
						CrashMenu1.ExitButton = true;
						CrashMenu1.Display(client, MENU_TIME_FOREVER);
					}
				}
			}
		}
	}
}
public int menuHandler_CrashMenu1 (Menu menu, MenuAction action, int client, int ItemNum)
{
	if (action == MenuAction_Select && StartMultiply[client] != 1.0)
	{
		int CreditsWon = WinCredits(g_iManualAmount[client], StartMultiply[client]);
		Store_SetClientCredits(client, Store_GetClientCredits(client) + CreditsWon);
		CPrintToChat(client, "%s You \x04won \x10%d\x01 Credits",PREFIX,CreditsWon);
		StartMultiply[client] = 1.0;
		IsPlaying[client] = false;
		if (CrashTimer[client] != null)
		{
			KillTimer(CrashTimer[client]);
			CrashTimer[client] = null;
		}	
		delete menu;
		ShowPlayAgainMenu(client);
	}
	else if (StartMultiply[client] == 1.0)
    {
        delete menu;
        IsPlaying[client] = false;
		if (CrashTimer[client] != null)
		{
			KillTimer(CrashTimer[client]);
			CrashTimer[client] = null;
		}
		ShowPlayAgainMenu(client);
    }
}
public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if (g_bTypingAmount[client])
	{
		if (IsNumeric(sArgs))
		{
			int iMinAmount = g_cvMinAmount.IntValue;
			int iMaxAmount = g_cvMaxAmount.IntValue;
			int iAmount = StringToInt(sArgs);
			if (iAmount < iMinAmount)
			{
				CPrintToChat(client, "%s Minimum amount of Credits is \x10%i", PREFIX, iMinAmount);
				return Plugin_Handled;
			}
			else if (iAmount > iMaxAmount)
			{
				CPrintToChat(client, "%s Maximum amount of Credits is \x10%i", PREFIX, iMaxAmount);
				return Plugin_Handled;
			}
			g_iManualAmount[client] = iAmount;
			CPrintToChat(client, "%s You chose \x10%i\x01 Credits to play with", PREFIX, iAmount);
		}
		else
			PrintToChat(client, "%s You can type only numbers..", PREFIX);
		
		ShowMainMenu(client);
		g_bTypingAmount[client] = false;
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
stock bool IsNumeric(const char[] buffer)
{
	int iLen = strlen(buffer);
	for (int i = 0; i < iLen; i++)
	{
		if (!IsCharNumeric(buffer[i]))
			return false;
	}
	return true;
}
public Action CrashGame(Handle timer,int client)
{	
	if(IsPlaying[client])
	{
		if(StartMultiply[client]==g_cvMaxMultiply.FloatValue)
		{
			int CreditsWon = WinCredits(g_iManualAmount[client], StartMultiply[client]);
			Store_SetClientCredits(client, Store_GetClientCredits(client) + CreditsWon);
			CPrintToChat(client, "%s Because you were so brave and didn't cashout you \x04won \x10%d\x01 Credits",PREFIX,CreditsWon);
			if(GetClientMenu(client) != MenuSource_None)
        		CancelClientMenu(client,true);
			StartMultiply[client] = 1.0;
			IsPlaying[client] = false;
			if (CrashTimer[client] != null)
			{
				KillTimer(CrashTimer[client]);
				CrashTimer[client] = null;
			}	
			ShowPlayAgainMenu(client);
		}
		if(StartMultiply[client] >= g_cvFasterTimer.FloatValue)
			StartMultiply[client] += 0.03;
		else if(StartMultiply[client] >= g_cvFastTimer.FloatValue)
			StartMultiply[client] += 0.02;
		else
			StartMultiply[client] += 0.01;
		if(rand[client] <= StartMultiply[client] && rand[client] != 1.0)
		{
			if (CrashTimer[client] != null)
			{
				KillTimer(CrashTimer[client]);
				CrashTimer[client] = null;
			}	
			StartMultiply[client] = 1.0;
			IsPlaying[client] = false;
			CPrintToChat(client, "%s You \x07lost \x10%d\x01 Credits",PREFIX,g_iManualAmount[client]);
			if(GetClientMenu(client) != MenuSource_None)
        		CancelClientMenu(client,true);
			ShowPlayAgainMenu(client);        		
		}
		else
		{
			PrintHintText(client, "<font color='#00FF00' size='20'>Crash IS ON!</font>\n<font color='#FF0000' size='30'>Multiply:</font><font color='#FFFFFF' size='30'> %0.2f</font>", StartMultiply[client]);
		}
	}
}
public int WinCredits(int credits,float winratio)
{
	int WonCredits;
	int round = RoundFloat(100.0*winratio)-1;
	WonCredits = credits * round;
	return WonCredits/100;
}