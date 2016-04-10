//-> подавить вывод say map 
//->PrintToChat(client,"Map %s is not nominated",part1); сделать развернутое объяснение отказа
//->Добавить счетчик доступных карт к номинации для каждого игрока
//->Не работает PrintToChatAll("%t","Current Map Stays");	// rtv "Голосование состоялось! Текущая карта продолжается! "
// Translation menu https://forums.alliedmods.net/showthread.php?t=281220&highlight=translation
//#define DEBUG  1
#define INFO 1
#define SMLOG 1
#define DEBUG_LOG 1
#define DEBUG_PLAYER "K64t"

#define PLUGIN_NAME  "Map_Elections"
#define PLUGIN_VERSION "0.2"

#define MENU_ITEM_LEN 64
#define MENU_ITEMS_COUNT 7
#define SND_VOTE_START	"k64t\\votestart.mp3"
#define SND_VOTE_FINISH	"k64t\\votefinish.mp3"

#include <k64t>


#define MENU_TITLE "VoteMenuTitle"
#define ITEM_DO_NOT_CHANGE "Dont Change"

//Constvar
char cPLUGIN_NAME[]=PLUGIN_NAME;
char snd_votestart[]	={SND_VOTE_START}; //Sound vote start
char snd_votefinish[]	={SND_VOTE_FINISH};//Sound vote finish
char PopularMenuItems[][MENU_ITEM_LEN]={"de_dust","de_dust2","de_inferno","de_piranesi","cs_office","de_aztec","de_cbble","de_chateau","de_nuke","de_tides","de_train"};
// ConVar
Handle mp_freezetime= INVALID_HANDLE; 
int cvar_mp_freezetime;
Handle sv_alltalk= INVALID_HANDLE;
int cvar_sv_alltalk;
Handle cvar_sm_vote_delay= INVALID_HANDLE; //Delay between votes
Handle cvar_sm_mapvote_voteduration= INVALID_HANDLE; //Duration voting in seconds
Handle cvar_sm_rtv_minplayers= INVALID_HANDLE;	//Number of players required before vote will be enabled.
// Global Var
bool g_elect=false; //been requested a vote
bool g_voting=false; //there is a voting;
int g_vote_delay; //Delay between votes
float g_vote_time=15.0;//time to vote
int g_vote_countdown; //countdown voting process
int g_min_players_demand=2; //Minimal demands for voting start 
Menu vMenu;//Handle menu= INVALID_HANDLE;//VotingMenu
char part1[32]; //tmp var
char part2[32]; //tmp var
char argstext[128]; //tmp var

char key_word[][MENU_ITEM_LEN]={"карта","карту","map","mapvote"}; //key_word :map карту карта
//char[] key_word = new int[MaxClients]

//Handle VoteTimer=INVALID_HANDLE;
char MenuItems[MENU_ITEMS_COUNT][MENU_ITEM_LEN];//VotingItems
int PlayerVote[MAX_PLAYERS];    // For which item voted player.-1 = no vote.
int ItemVote[MENU_ITEMS_COUNT]; // Counter. How many votes for the item
char Title[MENU_ITEM_LEN]; // Title of voting menu
int CandidateCount;             //Count of candidate item to votemenu
int VoteMax;
// DB
//Handle k64tDB=INVALID_HANDLE;	              
//***********************************************
public Plugin myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Provides map voting and immediately showing the players choice .Players can agree during voting and change their choice to any map.",
	version = PLUGIN_VERSION,
	url = ""};
//***********************************************
public void OnPluginStart(){
//***********************************************
#if defined DEBUG
PrintToServer("[%s] OnPluginStart",PLUGIN_NAME);
#endif 

mp_freezetime = FindConVar("mp_freezetime");
	if ( mp_freezetime == INVALID_HANDLE )
    {
        LogError("FATAL: Cannot find mp_freezetime cvar.");
        SetFailState("[%s] %s",cPLUGIN_NAME,"Cannot find mp_freezetime cvar.");
    }
sv_alltalk = FindConVar("sv_alltalk");
    if ( sv_alltalk == INVALID_HANDLE )
    {
        LogError("FATAL: Cannot find sv_alltalk cvar.");
        SetFailState("[%s] %s",cPLUGIN_NAME,"Cannot find sv_alltalk cvar.");
    }
cvar_sm_vote_delay = FindConVar("sm_vote_delay");
    if ( cvar_sm_vote_delay == INVALID_HANDLE )
    {
	CreateConVar("sm_vote_delay","600","Delay between votes",true,true,60);
    cvar_sm_vote_delay = FindConVar("sm_vote_delay");    
    }	
cvar_sm_mapvote_voteduration = FindConVar("sm_mapvote_voteduration");
    if ( cvar_sm_mapvote_voteduration == INVALID_HANDLE )
    {
	CreateConVar("sm_mapvote_voteduration","20","Duration voting in seconds",true,true,60);
    cvar_sm_mapvote_voteduration = FindConVar("sm_mapvote_voteduration");    
    }	
cvar_sm_rtv_minplayers = FindConVar("sm_rtv_minplayers");
    if ( cvar_sm_rtv_minplayers == INVALID_HANDLE )
    {
	CreateConVar("sm_rtv_minplayers","1","Number of players required before RTV will be enabled.",true,true,60);
    cvar_sm_rtv_minplayers = FindConVar("sm_rtv_minplayers");    
    }	
	

LoadTranslations("common.phrases");
LoadTranslations("nominations.phrases");
LoadTranslations("basevotes.phrases");
LoadTranslations("mapchooser.phrases");
LoadTranslations("rockthevote.phrases");
LoadTranslations("Map_Election.phrases.txt");
HookEvent("round_end",		EventRoundEnd);
//RegConsoleCmd("cem", cmd_Elect_Map,"Call elections map");
RegConsoleCmd("say", 		Command_Say);
RegConsoleCmd("say_team",	Command_Say);
//Sound
PrecacheSound(snd_votestart,true);
PrecacheSound(snd_votefinish,true);
char buffer[PLATFORM_MAX_PATH];
Format(buffer, PLATFORM_MAX_PATH, "sound\\%s",snd_votestart);	
AddFileToDownloadsTable(buffer);
Format(buffer, PLATFORM_MAX_PATH, "sound\\%s",snd_votefinish);	
AddFileToDownloadsTable(buffer);

//DB
/*Handle KVdb = INVALID_HANDLE;             
KVdb=CreateKeyValues("k64tdb"); 
KvSetString(KVdb,"driver","sqlite"); 
KvSetString(KVdb,"host","localhost"); 
KvSetString(KVdb,"database","k64t");

char error[255]; 
k64tDB=SQL_ConnectCustom(KVdb,error,sizeof(error),true); */
}
//***********************************************
public void OnMapStart(){
//***********************************************
#if defined DEBUG
PrintToServer("[%s] OnMapStart",PLUGIN_NAME);
#endif 
g_elect=false;
g_voting=false;
CandidateCount=0;
AutoExecConfig(true, "Map_Elections");
g_vote_time= GetConVarFloat(cvar_sm_mapvote_voteduration);
#if defined DEBUG
g_min_players_demand=1;
g_vote_delay=GetTime()+1;
#else
g_min_players_demand=GetConVarInt(cvar_sm_rtv_minplayers);
g_vote_delay=GetTime()+GetConVarInt(cvar_sm_vote_delay);
#endif
for (int i=0;i!=MAX_PLAYERS;i++)PlayerVote[i]=-1;
}
//***********************************************
public Action Command_Say(int client, int args){
//***********************************************
#if defined DEBUG
DebugPrint("Command_Say");
#endif
//-> сделать парсинг для добаления нескольких карт. Пример взять из sm_votempa
GetCmdArgString(argstext, sizeof(argstext));
StripQuotes(argstext);
BreakString(argstext[0], part1, sizeof(part1));
for (int i=0;i!=sizeof(key_word);i++)
	if (strcmp(part1, key_word[i], false) == 0)
		{
		cmd_Elect_Map(client,args);
		return Plugin_Handled;
		}
//mapvote
/*
if (strcmp(part1, "карту", false) == 0)
	{
	cmd_Elect_Map(client,args);
	return Plugin_Handled;
	}
else if (strcmp(part1, "map", false) == 0)
	{
	cmd_Elect_Map(client,args);
	return Plugin_Handled;
	}	
else if (strcmp(part1, "mapvote", false) == 0)
	{
	cmd_Elect_Map(client,args);
	return Plugin_Handled;
	}	
else if (strcmp(part1, "rfhne", false) == 0)
	{
	cmd_Elect_Map(client,args);
	return Plugin_Handled;
	}
else if (strcmp(part1, "карта", false) == 0)
	{
	cmd_Elect_Map(client,args);
	return Plugin_Handled;
	}
*/	
return Plugin_Continue;
}
//***********************************************
public void EventRoundEnd(Handle event, const char[] name,bool dontBroadcast){
//***********************************************
#if defined DEBUG
DebugPrint("round_end");
#endif

if (!g_elect) return;
g_elect=false;
PrecacheSound(snd_votestart,true);
EmitSoundToAll(snd_votestart);
PrintToChatAll("%t","Initiated Vote Map");

g_vote_countdown=RoundToCeil(g_vote_time);
cvar_mp_freezetime=GetConVarInt(mp_freezetime);
SetConVarInt(mp_freezetime, g_vote_countdown);
cvar_sv_alltalk=GetConVarInt(sv_alltalk);
SetConVarInt(sv_alltalk, 1);

//https://forums.alliedmods.net/showthread.php?t=264033
//origin vMenu = CreateMenu(MenuHandler1, MenuAction:MENU_ACTIONS_ALL);
//https://wiki.alliedmods.net/Menu_API_(SourceMod)
//Panel panel = view_as<Panel>param2;
//https://wiki.alliedmods.net/Menu_API_(SourceMod)#Basic_Panel
//menu = CreateMenu(MenuHandler1, MenuAction:MENU_ACTIONS_ALL);

vMenu = new Menu(MenuHandler1,MENU_ACTIONS_ALL);
//vMenu = new Menu(MenuHandler1,MENU_ACTIONS_DEFAULT);

Format(Title,MENU_ITEM_LEN,"%t",MENU_TITLE,g_vote_countdown);
vMenu.SetTitle(Title);
//Make random map list
//\cstrike\cfg\mapcycle_default.txt" - пропустить //
//\cstrike\cfg\mapcyclet.txt" 
//\cstrike\cfg\bigmaps.txt 
//Read from DB
/*if (k64tDB!=INVALID_HANDLE){
	Handle MapQuery=SQL_Query(k64tDB,"select name from map");
	//if (MapQuery!=INVALID_HANDLE)
	//	if (SQL_FetchRow(MapQuery)) 
	//		if(!SQL_IsFieldNull(IPQuery,0))
	//			SQL_FetchString(IPQuery,0,ip,sizeof(ip));
}*/
//Read MapList
Handle g_MapList = INVALID_HANDLE;
int g_MapListSerial = -1;
//(ReadMapList(g_MapList,g_MapListSerial,"default",MAPLIST_FLAG_CLEARARRAY|MAPLIST_FLAG_NO_DEFAULT)==INVALID_HANDLE)
if (ReadMapList(g_MapList,g_MapListSerial,"default",MAPLIST_FLAG_CLEARARRAY)==INVALID_HANDLE)
{	
	#if defined DEBUG
	DebugPrint("ReadMapList failure");
	#endif 
	if (g_MapListSerial == -1)
	{
	#if defined DEBUG
	DebugPrint("Cannot load map cycle");
	#endif 
	}
}	
if (g_MapList!=INVALID_HANDLE)
	{
	#if defined DEBUG
	DebugPrint("Get map cycle");
	#endif 
	/*int mapCount = GetArraySize(g_MapList);
	
	char mapName[32];
	for (int i = 0; i < mapCount; i++)
		{
		GetArrayString(g_MapList, i, mapName, sizeof(mapName));
		LogMessage(mapName);
		}*/

	//-> Сформировать произвольный список карт в массиве PopularMenuItems
		
		if (g_MapList!=INVALID_HANDLE) CloseHandle(g_MapList);
	}
//Read MapList from mapcycle.txt
//if FileExists("mapcycle.txt") 
	
//AddCandidateMaptoMenuItems("de_alivemetal");
//AddMenuMapItem("de_snowball");
//AddMenuMapItem("de_survivor_css");

for (int i=1+CandidateCount;i!=MENU_ITEMS_COUNT;i++)
	{	
	AddRandomMenuMapItem();
	//strcopy(MenuItems[i],MENU_ITEM_LEN,PopularMenuItems[i]);	
	}
g_voting=true;	
VoteMax=0;
for (int i=0;i!=MAX_PLAYERS;i++)	
	PlayerVote[i]=-1;
char ItemShift[MENU_ITEMS_COUNT];
Fill(ItemShift, MENU_ITEMS_COUNT,' ',MENU_ITEMS_COUNT);
Format(Title,MENU_ITEM_LEN,"%t",ITEM_DO_NOT_CHANGE);
strcopy(MenuItems[0],MENU_ITEM_LEN,Title);
vMenu.AddItem("", Title);
for (int i=1;i!=MENU_ITEMS_COUNT;i++)
	{
	ItemVote[i]=0;	
	Format(Title,MENU_ITEM_LEN,"%s%s",ItemShift,MenuItems[i]);
	vMenu.AddItem("", Title);
	//AddMenuItem(vMenu,"",Title);
	}
//SetMenuExitButton(vMenu, false);
vMenu.ExitButton=false;
CreateTimer(g_vote_time+1.0,EndVote);	
ReDisplayMenu();
CreateTimer(1.0,RefreshMenu,_, TIMER_REPEAT);		
}
//*****************************************************************************
public  Action RefreshMenu(Handle Timer,any Parameters){
//*****************************************************************************
if (g_voting)
	{
	g_vote_countdown--;	
	Format(Title,MENU_ITEM_LEN,"%t",MENU_TITLE,g_vote_countdown);
	vMenu.SetTitle(Title);
	if (g_vote_countdown==0)	return Plugin_Stop;
	else 
		{
		ReDisplayMenu();
		return Plugin_Continue;	
		}
	}
else	
	return Plugin_Stop;
}

//*****************************************************************************
public void ReDisplayMenu(){
//*****************************************************************************
for(int i = 1; i <= MaxClients; i++) 
	{
	if (IsClientConnected(i))
		if (IsClientInGame(i))			
			if (!IsFakeClient(i))	
			{
			if (!vMenu.Display(i, g_vote_countdown))										
			//if (!vMenu.Display(i, g_vote_time))									
					LogError("DisplayMenu to client %d faild",i);
			}		
	}
}	
//***********************************************
public Action cmd_Elect_Map(int client, int args){
//***********************************************
#if defined DEBUG
DebugPrint("cmd_Elect_Map");
#endif
if (g_voting) return Plugin_Handled;
if (g_elect) return Plugin_Handled;
int tdif=g_vote_delay-GetTime();
if (tdif>0) 
	{	
	PrintToChat(client,"%t","RTV Not Allowed");	//RTV "Голосование по смене карты еще недоступно."	
	if (tdif>60)
		PrintToChat(client,"%t","Vote Delay Minutes",RoundToCeil(tdif/60.0));	//common "Вы не можете начать новое голосование раньше, чем через {1} минут"
	else
		PrintToChat(client,"%t","Vote Delay Seconds",tdif);	
	return Plugin_Handled;
	}
GetClientName(client, Title, MAX_CLIENT_NAME);
GetCmdArgString(argstext, sizeof(argstext));
StripQuotes(argstext);
//-> Если нет аргументов, то выдать пользователю список карт сервера
PrintToChatAll("%t","Map Election Requested",Title);//"Игрок {1} хочет сменить карту.
int len, pos;
while (pos != -1 && CandidateCount!=MENU_ITEMS_COUNT )
	{	
		pos = BreakString(argstext[len], part1, sizeof(part1));
		if (len!=0)
			{
			if (AddMenuMapItem(part1))				
				PrintToChatAll("%t","Map Nominated",Title,part1);//"Игрок {1} предложил {2} для голосование по смене карты."
			else	
				PrintToChat(client,"Map %s is not nominated",part1);
			}
		if (pos != -1)len += pos;
	}	
#if defined DEBUG	
DebugPrint("client=%d g_min_players_demand=%d",client,g_min_players_demand);
#endif
if (client!=0)
	{
	#if defined DEBUG	
	DebugPrint("PlayerVote[%d]=%d",client-1,PlayerVote[client-1]);	
	#endif
	if (PlayerVote[client-1]==-1)
		{
		PlayerVote[client-1]++;
		g_min_players_demand--;
		#if defined DEBUG	
		DebugPrint("PlayerVote[%d]=%d",client-1,PlayerVote[client-1]);	
		#endif		
		}
	else
		PrintToChat(client,"%s, %t",Title,"Already Nominated");	//rtv "Вы уже предложили карту."
	}	
#if defined DEBUG	
DebugPrint("client=%d g_min_players_demand=%d",client,g_min_players_demand);
#endif	
if (g_min_players_demand<=0)		
	{
	g_elect=true;
	PrintToChatAll("%t","Start_Vote_After_Round_End");	//map_election "Голосование начнется сразу после завершения раунда"
	PrintToChatAll("%t:","Nominated");	//nomination "Предложены для голосования"
	for (int i=0;i!=MENU_ITEMS_COUNT;i++)PrintToChatAll("%s",MenuItems[i]);
	}
else
	{
	PrintToChatAll("%t","Number_of_demands",g_min_players_demand); // map_election "Количество заявлений, необходимое для начала голосования - {1}\nКто-нибудь, наберите в чате 'карта'"
	}
	
return Plugin_Handled;
}
//***********************************************
void AddRandomMenuMapItem(){
//***********************************************
int SizePopularMenuItems=sizeof(PopularMenuItems)-1;
int IndexPopularMenuItems;
do 	{
	IndexPopularMenuItems=GetRandomInt(0,SizePopularMenuItems);
	}
while (!AddMenuMapItem(PopularMenuItems[IndexPopularMenuItems]));
}
//***********************************************
void AddMenuMapItem(char[] Map){
//***********************************************
if (g_voting) return false;
if (!IsMapValid(Map)) return false;
if (CandidateCount+1==MENU_ITEMS_COUNT)return false;
String_ToLower(Map, Map, MENU_ITEM_LEN);
if (Array_FindString(MenuItems, CandidateCount+1, Map, false,1)!=-1) return false;
CandidateCount++;
strcopy(MenuItems[CandidateCount],MENU_ITEM_LEN,Map);
return true;
}
//***********************************************
public int  MenuHandler1(Menu menu, MenuAction action, int param1/*-client*/, int param2/*-menu item*/){
//***********************************************
/* If an option was selected, tell the client about the item. */
if (action == MenuAction_Select)
	{
		#if defined DEBUG
		char info[32];
		bool found = GetMenuItem(menu, param2, info, sizeof(info));		
		LogMessage("MenuAction_Select. param1(client)=%d param2(item)=%d",param1,param2);
		PrintToChat(param1, "You selected item: %d (found? %d info: %s)", param2, found, info);
		LogMessage("Client %d selected item: %d (found? %d info: %s)",param1, param2, found, info);
		#endif
		if ( param1<1 || param1>MaxClients ) 
			{
			LogError("MenuHandler param1=%d is out of range. Must be client id",param1);			
			}
		else if (param2<0 || param2>MENU_ITEMS_COUNT)
			{
			LogError("MenuHandler param2=%d is out of range. Must be item id",param1);
			}
		else	
			{
			if ( PlayerVote[param1-1] != -1 )
				{
				ItemVote[PlayerVote[param1-1]]--;
				}
			PlayerVote[param1-1]=param2;
			ItemVote[param2]++;			
			//if (!RemoveMenuItem(menu, param2)) LogMessage("Error in RemoveMenuItem(%d)",param2);			
			//Format(Title,MENU_ITEM_LEN,"%s [%d]",MenuItems[param2],ItemVote[param2]);			
			#if defined DEBUG
			LogMessage("int item for %i is %s ",param2,Title);
			#endif
			//if (param2==MENU_ITEMS_COUNT)
			//	if (!AddMenuItem(menu,""/*Title*/,Title)) LogMessage("Error in AddMenuItem(%d)",param2);				
			//else
			//	if (!InsertMenuItem(menu,param2,""/*strBuf*/,Title)) LogMessage("Error in InsertMenuItem(%d)",param2);
				
			vMenu.Display(param1, g_vote_countdown);
		}
	}
/* If the menu was cancelled, print a message to the server about it. */
#if defined DEBUG
else if (action == MenuAction_Cancel)
	{
	LogMessage("Client %d's menu was cancelled.  Reason: %d", param1, param2);
	}
#endif	
else if (action == MenuAction_DisplayItem)
	{
	#if defined DEBUG
	LogMessage("MenuAction_DisplayItem %d ",param2);
	#endif
	if (param2==0)
		//Format(Title,MENU_ITEM_LEN,"%T",ITEM_DO_NOT_CHANGE);
		return 0;
	else
		{
		char ItemShift[MENU_ITEMS_COUNT];
		Fill(ItemShift, MENU_ITEMS_COUNT,' ',MENU_ITEMS_COUNT-ItemVote[param2]);
		if 	(ItemVote[param2]==0)
			Format(Title,MENU_ITEM_LEN,"%s%s",ItemShift,MenuItems[param2]);
		else
			Format(Title,MENU_ITEM_LEN,"%s%s[%d]",ItemShift,MenuItems[param2],ItemVote[param2]);
		}
	return RedrawMenuItem(Title);
	}
/* If the menu has ended, destroy it */
#if defined DEBUG
else if (action == MenuAction_End)
	{
	#if defined DEBUG
	LogMessage("MenuAction_End ");
	//DebugPrint("MenuAction_End ");
	#endif
	//vMenu.RemoveAllItems();
	//ReDisplayMenu();
	//delete menu;
	//CloseHandle(menu);
	}
#endif	
return 0;	
}
//*****************************************************************************
public  Action EndVote(Handle Timer,any Parameters){
//*********************************************	********************************
#if defined DEBUG
DebugPrint("EndVote");
#endif
g_voting=false;
PrecacheSound(snd_votefinish,true);
EmitSoundToAll(snd_votefinish);
SetConVarInt(mp_freezetime, cvar_mp_freezetime);
SetConVarInt(sv_alltalk, cvar_sv_alltalk);
CandidateCount=0;

if (!vMenu==INVALID_HANDLE) vMenu.RemoveAllItems();
if (!vMenu==INVALID_HANDLE) vMenu.Cancel();
if (!vMenu==INVALID_HANDLE) delete vMenu;
for (int i=0;i!=MAX_PLAYERS;i++)	PlayerVote[i]=-1;
#if defined DEBUG
g_min_players_demand=1;
g_vote_delay=GetTime()+1;
#else
g_min_players_demand=GetConVarInt(cvar_sm_rtv_minplayers);
g_vote_delay=GetTime()+GetConVarInt(cvar_sm_vote_delay);
#endif
int ItemWiner=0;
int y=-1;
PrintToChatAll("===========================\n%t\n---------------------------","Vote_Reault");
for (int i=0;i!=MENU_ITEMS_COUNT;i++)
	{	
	#if defined SMLOG
	LogMessage("ItemVote[%d]=%d",i,ItemVote[i]);
	#endif		
	PrintToChatAll("%d - %s",ItemVote[i],MenuItems[i]);	
	if (ItemVote[i]>y)
		{
		y=ItemVote[i];
		ItemWiner=i;	
		}
	}
PrintToChatAll("---------------------------");	
if (ItemWiner>0)
	{	
	#if defined SMLOG
	LogMessage("ItemWiner=%d %s",ItemWiner,MenuItems[ItemWiner]);
	#endif
	PrintToChatAll("%t - %s","Win_Item",MenuItems[ItemWiner]); //map_election "Победил пункт"
	PrintToChatAll("%t","Changing Maps",MenuItems[ItemWiner]); //rtv "Голосование состоялось! Смена карты на {1}!"
	ForceChangeLevel(MenuItems[ItemWiner], "map vote");	
	}
else
	{
	#if defined SMLOG
	LogMessage("%s","noWin_Item");
	#endif
	PrintToChatAll("%t - %t","Win_Item",ITEM_DO_NOT_CHANGE); //map_election "Победил пункт"
	PrintToChatAll("%t","Current Map Stays");	 // rtv "Голосование состоялось! Текущая карта продолжается! "
	}
}
//*****************************************************************************
public void OnPluginEnd(){
//*****************************************************************************
//if (k64tDB!=INVALID_HANDLE) SQL_UnlockDatabase(k64tDB); 
}
//*****************************************************************************
#endinput
//#C:\pro\SourceMod\MySMcompile.exe "$(FULL_CURRENT_PATH)"
===
//-> use mp_round_restart_delay & mp_freezetime
//mp_round_restart_delay 0
//mp_freezetime  0
===
/* Пример SplitString
 if(SplitString(strMap, "_", strPart, sizeof(strPart)) != -1)
     {
          if(StrEqual(strPart, "bhop"))
          {
               g_nMapType = MAP_BHOP;
          }
     }
*/	 

//Какая функция лучше = ?
//CutWord(argstext," ",1,part1,sizeof(part1));
===