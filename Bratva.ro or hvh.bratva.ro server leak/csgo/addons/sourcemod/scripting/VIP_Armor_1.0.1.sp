//------------------------------------------------------------------------------
// GPL LISENCE (short)
//------------------------------------------------------------------------------
/*
 * Copyright (c) 2014 R1KO

 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 * ChangeLog:
		1.0.0 -	Релиз
		1.0.1 -	Теперь бронь выдается со шлемом
*/
#pragma semicolon 1

#include <sourcemod>
#include <sdktools_functions>
#include <vip_core>

public Plugin:myinfo =
{
	name = "[VIP] Armor",
	author = "R1KO (skype: vova.andrienko1)",
	version = "1.0.1"
};

#define VIP_ARMOR				"Armor"

new m_ArmorValue,
	m_bHasHelmet;

public VIP_OnVIPLoaded()
{
	VIP_RegisterFeature(VIP_ARMOR, STRING);

	VIP_HookClientSpawn(OnPlayerSpawn);
}

public OnPluginStart()
{
	m_ArmorValue	 = FindSendPropOffs("CCSPlayer", "m_ArmorValue");
	m_bHasHelmet = FindSendPropOffs("CCSPlayer", "m_bHasHelmet");
}

public OnPlayerSpawn(iClient, iTeam, bool:bIsVIP)
{
	if(bIsVIP && VIP_IsClientFeatureUse(iClient, VIP_ARMOR))
	{
		decl String:sArmor[16], iArmor;
		VIP_GetClientFeatureString(iClient, VIP_ARMOR, sArmor, sizeof(sArmor));
		if(sArmor[0] == '+')
		{
			iArmor = StringToInt(sArmor[1])+GetEntData(iClient, m_ArmorValue);
		}
		else
		{
			StringToIntEx(sArmor, iArmor);
		}

		SetEntData(iClient, m_ArmorValue, iArmor);
		SetEntData(iClient, m_bHasHelmet, 1);
	}
}