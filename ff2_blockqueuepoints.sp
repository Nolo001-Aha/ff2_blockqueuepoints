#define PLUGIN_NAME           "[FF2] Queue Points Disabler"
#define PLUGIN_AUTHOR         "Nolo001" //Meet the most lazy coder ever (TM)
#define PLUGIN_DESCRIPTION    "Prevents targeted clients from receiving queue points ever again, muahahaha"
#define PLUGIN_VERSION        "1.0" //how much boilerplate and ugly code can I fit into one release
#define PLUGIN_URL            ""

#include <sourcemod>
#include <freak_fortress_2>
#include <clientprefs> //why the FUCK is this not automatically imported with <sourcemod>
#pragma semicolon 1

Handle c00ki3; //c00kieZ, 0w0 gimme


public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

public void OnPluginStart()
{
	PrintToServer("[FF2] Queue Points Disabler initializing...");
	c00ki3 = RegClientCookie("ff2_block_queue_points", "Block client queue points?", CookieAccess_Protected);
	RegConsoleCmd("ff2_togglepoints", Command_BlockFF2PointsCallback, "Block target queue points");
	
	LoadTranslations("freak_fortress_2.phrases"); //idgaf what file the proper response is in, so Ill just shove in all translations at once
	LoadTranslations("freak_fortress_2_prefs.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("core.phrases");
}

public Action FF2_OnAddQueuePoints(int add_points[MAXPLAYERS+1])
{
	for(int client = 1; client<=MAXPLAYERS+1; client++)
	{
		if(!IsValidClient(client))
			continue;
		
		char buffer[4];
		GetClientCookie(client, c00ki3, buffer, sizeof(buffer)); //steal the cookie
		if(StrEqual(buffer, "1", false))
		{
			add_points[client] = 0;
			FPrintToChat(client, "Staff disabled your queue points, so you're not getting any. Too bad!"); // Too bad! (TM Valve Software)
		}	
	}
	return Plugin_Changed;
}


public Action Command_BlockFF2PointsCallback(int client, int args)
{
	if(args != 1)
	{
		FReplyToCommand(client, "Usage: ff2_togglepoints <target>");
		return Plugin_Handled;
	}
	char pattern[32];
	GetCmdArg(1, pattern, sizeof(pattern));
	static char targetName[MAX_TARGET_LENGTH];
	int targets[MAXPLAYERS], matches;
	bool targetNounIsMultiLanguage;

	if((matches=ProcessTargetString(pattern, client, targets, sizeof(targets), 0, targetName, sizeof(targetName), targetNounIsMultiLanguage)) < 1)
	{
		ReplyToTargetError(client, matches);
		return Plugin_Handled;
	}

	if(matches > 1)
	{
		for(int target; target<matches; target++)
		{
			if(!IsValidClient(target))
				continue;

			char buffer[4];
			GetClientCookie(target, c00ki3, buffer, sizeof(buffer));
			if(StrEqual(buffer, "1", false))
			{
				SetClientCookie(target, c00ki3, "0");
				ReplyToCommand(client, "Enabled points for target %N", target);
			}
			else
			{
				SetClientCookie(target, c00ki3, "1");	
				ReplyToCommand(client, "Disabled points for target %N", target);
				FF2_SetQueuePoints(target, 0);
			}

		}
	}
	else
	{
			char buffer[4];
			GetClientCookie(targets[0], c00ki3, buffer, sizeof(buffer));
			if(StrEqual(buffer, "1", false))
			{
				SetClientCookie(targets[0], c00ki3, "0");
				ReplyToCommand(client, "Enabled points for target %N", targets[0]);
			}
			else
			{
				SetClientCookie(targets[0], c00ki3, "1");	
				ReplyToCommand(client, "Disabled points for target %N", targets[0]);
				FF2_SetQueuePoints(targets[0], 0);
			}
	}
	return Plugin_Handled;
}

stock bool IsValidClient(int client, bool replaycheck=true, bool onlyrealclients=true) //stock that checks if the client is valid(not bot, connected, in game, authorized etc)
{
	if(client<=0 || client>MaxClients)
	{
		return false;
	}

	if(!IsClientInGame(client))
	{
		return false;
	}

	if(GetEntProp(client, Prop_Send, "m_bIsCoaching"))
	{
		return false;
	}

	if(replaycheck)
	{
		if(IsClientSourceTV(client) || IsClientReplay(client))
		{
			return false;
		}
	}
	
	if(onlyrealclients)
	{
		if(IsFakeClient(client))
			return false;
	}
	
	return true;
}	
