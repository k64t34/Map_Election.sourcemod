//->опять  артефакт меню голосования
//->PrintToChat(client,"Map %s is not nominated",part1); сделать развернутое объяснение отказа
//->Добавить счетчик доступных карт к номинации для каждого игрока
//->Не работает PrintToChatAll("%t","Current Map Stays");	// rtv "Голосование состоялось! Текущая карта продолжается! "
// Translation menu https://forums.alliedmods.net/showthread.php?t=281220&highlight=translation
#define DEBUG  1
#define INFO 1
#define SMLOG 1
#define DEBUG_LOG 1
#define DEBUG_PLAYER "K64t"

#define PLUGIN_NAME  "Map_Elections"
#define PLUGIN_VERSION "0.4.3" //Item Shift

#define MENU_ITEM_LEN 64
#define MENU_ITEMS_COUNT 7
#define MENU_ITEMS_SHIFT 2
#define MENU_ITEMS_MARK "√"
#define SND_VOTE_START	"k64t\\votestart.mp3"
#define SND_VOTE_FINISH	"k64t\\votefinish.mp3"
#define MAX_KEY_WORDS 7

#include <k64t>

#define MENU_TITLE "VoteMenuTitle"
#define ITEM_DO_NOT_CHANGE "Dont Change"

//Constvar
char cPLUGIN_NAME[]=PLUGIN_NAME;
char snd_votestart[]	={SND_VOTE_START}; //Sound vote start
char snd_votefinish[]	={SND_VOTE_FINISH};//Sound vote finish
//char PopularMenuItems[][MENU_ITEM_LEN]={"de_dust","de_dust2","de_inferno","de_piranesi","cs_office","de_aztec","de_cbble","de_chateau","de_nuke","de_tides","de_train"};
// CVar
Handle mp_freezetime= INVALID_HANDLE; 
int cvar_mp_freezetime;
Handle sv_alltalk= INVALID_HANDLE;
int cvar_sv_alltalk;
Handle cvar_sm_vote_delay= INVALID_HANDLE; //Delay between votes
int g_vote_delay; //Delay between votes
Handle cvar_sm_mapvote_voteduration= INVALID_HANDLE; //Duration voting in seconds
float g_vote_time=15.0;//time to vote
Handle cvar_sm_rtv_minplayers= INVALID_HANDLE;	//Number of players required before vote will be enabled.
int g_min_players_demand=2; //Minimal demands for voting start 
Handle cvar_key_words= INVALID_HANDLE;
int key_word_cnt=MAX_KEY_WORDS;
char key_word[MAX_KEY_WORDS][MENU_ITEM_LEN];
Handle g_version;
// Global Var
bool g_elect=false; //been requested a vote
bool g_voting=false; //there is a voting;
int g_vote_countdown; //countdown voting process
Menu vMenu;//Handle menu= INVALID_HANDLE;//VotingMenu
Menu g_MapMenu = null;//Menu select map
char part1[32]; //tmp var
//char part2[32]; //tmp var
Handle g_MapList = null;
int g_mapFileSerial = -1;
char item_select_mark[]={MENU_ITEMS_MARK}; //Mark selected item
//Handle VoteTimer=INVALID_HANDLE;
char MenuItems[MENU_ITEMS_COUNT][MENU_ITEM_LEN];//VotingItems
int PlayerVote[MAX_PLAYERS];    // For which item voted player.-1 = no vote.
int ItemVote[MENU_ITEMS_COUNT]; // Counter. How many votes for the item
char Title[MENU_ITEM_LEN]; // Title of voting menu
int CandidateCount;             //Count of candidate item to votemenu
int g_item_shift=MENU_ITEMS_SHIFT;
//int g_item_count=MENU_ITEMS_COUNT;
//int VoteMax;
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
if(mp_freezetime==INVALID_HANDLE)
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
cvar_key_words = FindConVar("sm_votemap_keywords");
if ( cvar_key_words == INVALID_HANDLE )
    {
	CreateConVar("sm_votemap_keywords","votemap;карту","Key words for demand map vote. Delimiter is ;");
	cvar_key_words = FindConVar("sm_votemap_keywords");
    }
	
g_version = CreateConVar("mapelection_version", 
	PLUGIN_VERSION, 
	"MapElection version", 
	FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_REPLICATED);
SetConVarString(g_version,PLUGIN_VERSION);

LoadTranslations("common.phrases");
LoadTranslations("nominations.phrases");
LoadTranslations("basevotes.phrases");
LoadTranslations("mapchooser.phrases");
LoadTranslations("rockthevote.phrases");
LoadTranslations("Map_Election.phrases.txt");
HookEvent("round_end",		EventRoundEnd);
//RegConsoleCmd("cem", cmd_Elect_Map,"Call elections map");
RegConsoleCmd("say", 		Command_Say);//https://wiki.alliedmods.net/Talk:Introduction_to_sourcemod_plugins
RegConsoleCmd("say_team",	Command_Say);
//Sound
PrecacheSound(snd_votestart,true);
PrecacheSound(snd_votefinish,true);
char buffer[PLATFORM_MAX_PATH];
Format(buffer, PLATFORM_MAX_PATH, "sound\\%s",snd_votestart);	
AddFileToDownloadsTable(buffer);
Format(buffer, PLATFORM_MAX_PATH, "sound\\%s",snd_votefinish);	
AddFileToDownloadsTable(buffer);

int arraySize = ByteCountToCells(33);
g_MapList = CreateArray(arraySize);

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

char tmpBuf[256];
GetConVarString(cvar_key_words, tmpBuf, sizeof(tmpBuf));
key_word_cnt=ExplodeString(tmpBuf,";",key_word,MAX_KEY_WORDS,MENU_ITEM_LEN);
if(key_word_cnt==0)
	{
	key_word_cnt=1;
	strcopy(key_word[0],MENU_ITEM_LEN,"votemap");	
	}
#if defined DEBUG
g_min_players_demand=1;
g_vote_delay=GetTime()+1;
for (int i=0;i!=sizeof(key_word);i++) DebugPrint("%d %s",i,key_word[i]);
#else
g_min_players_demand=GetConVarInt(cvar_sm_rtv_minplayers);
g_vote_delay=GetTime()+GetConVarInt(cvar_sm_vote_delay);
#endif
for (int i=0;i!=MAX_PLAYERS;i++)PlayerVote[i]=-1;
//Read MapList
if (ReadMapList(g_MapList,g_mapFileSerial,"default",MAPLIST_FLAG_CLEARARRAY)== null)	
	if (g_mapFileSerial == -1)
		SetFailState("Unable to create a valid map list.");	
}
//***********************************************
public Action Command_Say(int client, int args){
//***********************************************
//=> use GetCmdArg
#if defined DEBUG
DebugPrint("Command_Say.Client %d, args %d",client,args);
#endif
//Do not use GetCmdArg. It not response cyrilic 
char argstext[128];
int pos;
GetCmdArgString(argstext, sizeof(argstext)); // argstext=карту de_dust2
StripQuotes(argstext);
pos = BreakString(argstext, part1, sizeof(part1));
int len = pos;
for (int i=0;i!=key_word_cnt;i++)
	if (strcmp(part1, key_word[i], false) == 0)
		{		
		if (pos==-1) part1[0]=0;
		else BreakString(argstext[len], part1, sizeof(part1));
		cmd_Elect_Map(client,part1);
		return Plugin_Stop;
		}
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
BuildMapVoteMenu();
g_voting=true;
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
			//stpcpy(bufftmp);	
			if (!vMenu.Display(i, g_vote_countdown))										
			//if (!vMenu.Display(i, g_vote_time))									
					LogError("DisplayMenu to client %d faild",i);
				
			}		
	}
}	
//***********************************************
int cmd_Elect_Map(int client, char[] map){
//***********************************************
#if defined DEBUG
DebugPrint("cmd_Elect_Map client %d map %s",client,map);
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
		PrintToChat(client,"%t","Vote Delay Seconds",tdif);	//common "Вы не можете начать новое голосование раньше, чем через {1} секунд"
	return Plugin_Handled;
	}

if (strlen(map)==0)
	{
	BuildMapMenu();
	g_MapMenu.SetTitle("%T", "Nominate Title", client);
	g_MapMenu.Display(client, MENU_TIME_FOREVER);	
	}
else
	{
	GetClientName(client, Title, MAX_CLIENT_NAME);		
	PrintToChatAll("%t","Map Election Requested",Title);//"Игрок {1} хочет сменить карту.		
	if (AddMenuMapItem(map))				
		PrintToChatAll("%t","Map Nominated",Title,map);//"Игрок {1} предложил {2} для голосование по смене карты."
	else	
		PrintToChat(client,"Map %s is not nominated",map);			
	if (client!=0)
		{
		if (PlayerVote[client-1]==-1)
			{
			PlayerVote[client-1]++;
			g_min_players_demand--;			
			}
		else
			PrintToChat(client,"%s, %t",Title,"Already Nominated");	//rtv "Вы уже предложили карту."
		}	
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
	}
return Plugin_Handled;
}

//***********************************************
public int  MenuHandler1(Menu menu, MenuAction action, int param1/*-client*/, int param2/*-menu item*/){
//***********************************************
/* If an option was selected, tell the client about the item. */
if (action == MenuAction_Select)
	{
		#if defined DEBUG		
		char info[32];
		bool found = GetMenuItem(menu, param2, info, sizeof(info));	//LogMessage("MenuAction_Select. param1(client)=%d param2(item)=%d",param1,param2);
		DebugPrint("%d selected item: %d (found? %d info: %s)", param1,param2, found, info);
		//LogMessage("Client %d selected item: %d (found? %d info: %s)",param1, param2, found, info);
		//DebugPrint("MenuAction_Select.Client %d selected item: %d (found? %d info: %s)",param1,param2,found,info);
		#endif
		if ( 1<param1 || param1>MaxClients ) 
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
			PlayerVote[param1-1]=param2-g_item_shift;
			ItemVote[param2-g_item_shift]++;			
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
	}/* If the menu was cancelled, print a message to the server about it. */
#if defined DEBUG
else if (action == MenuAction_Cancel)
	{	
	DebugPrint("MenuAction_Cancel. %d %d",param1,param2);
	}
#endif	
else if (action == MenuAction_DisplayItem)
	{
	#if defined DEBUG	
	DebugPrint("MenuAction_DisplayItem. %d %d",param1,param2);
	#endif
	if (param2<=g_item_shift)return 0;	
	else
		{			
		char ItemShift[MENU_ITEMS_COUNT];
		Fill(ItemShift, MENU_ITEMS_COUNT,' ',MENU_ITEMS_COUNT-ItemVote[param2-g_item_shift]);
		if 	(ItemVote[param2-g_item_shift]==0)
			Format(Title,MENU_ITEM_LEN,"%s%s",ItemShift,MenuItems[param2-g_item_shift]);
		else
			Format(Title,MENU_ITEM_LEN,"%s%s[%d]",ItemShift,MenuItems[param2-g_item_shift],ItemVote[param2-g_item_shift]);
		}
	//if (PlayerVote[param1-1] ==param2)
	//		StrCat(Title, sizeof(Title),item_select_mark);
		
	return RedrawMenuItem(Title);
	}
/* If the menu has ended, destroy it */
#if defined DEBUG
else if (action == MenuAction_End)
	{
	#if defined DEBUG	
	DebugPrint("MenuAction_End ");
	#endif
	//vMenu.RemoveAllItems();//ReDisplayMenu();//delete menu;//CloseHandle(menu);
	}
#endif	
#if defined DEBUG //https://wiki.alliedmods.net/Menus_Step_By_Step_(SourceMod_Scripting)#AddMenuItem
else if (action == MenuAction_DrawItem)
		{
		#if defined DEBUG
		DebugPrint("MenuAction_DrawItem. %d %d",param1,param2);
		#endif
		if (param2<g_item_shift) return ITEMDRAW_NOTEXT | ITEMDRAW_SPACER;		
		}	
#endif	
#if defined DEBUG		
else if (action == MenuAction_Start)
		{
		#if defined DEBUG
		DebugPrint("MenuAction_Start");
		#endif
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
for (int i=g_item_shift;i!=MENU_ITEMS_COUNT;i++)
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
void BuildMapVoteMenu(){
//*****************************************************************************
vMenu = new Menu(MenuHandler1,MENU_ACTIONS_ALL);//warning 240: 'MenuAction:' is an old-style tag operation; use view_as<MenuAction>(expression) instead
//vMenu = view_as<MenuAction>(MenuHandler1);//warning 237: coercing functions to and from primitives is unsupported and will be removed in the future

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
/*BuildMapListForVoteMenu();*/
for (int i=1+CandidateCount;i!=MENU_ITEMS_COUNT;i++)
	AddRandomMenuMapItem();	//strcopy(MenuItems[i],MENU_ITEM_LEN,PopularMenuItems[i]);	

for (int i=0;i!=MAX_PLAYERS;i++)	
	PlayerVote[i]=-1;

for (int i=0;i!=g_item_shift;i++)	
	vMenu.AddItem("", ""/*,ITEMDRAW_IGNORE*//*TEMDRAW_SPACER*/);//https://wiki.alliedmods.net/Menus_Step_By_Step_(SourceMod_Scripting)
char ItemShift[MENU_ITEMS_COUNT];
Fill(ItemShift, MENU_ITEMS_COUNT,' ',MENU_ITEMS_COUNT);
ItemVote[g_item_shift]=0;
Format(Title,MENU_ITEM_LEN,"%t",ITEM_DO_NOT_CHANGE);
strcopy(MenuItems[0],MENU_ITEM_LEN,Title);
vMenu.AddItem("", Title);

#if defined SMLOG
for (int i=0;i!=MENU_ITEMS_COUNT;i++) DebugPrint("%d %s",i,MenuItems[i]);
#endif
for (int i=g_item_shift+1;i!=MENU_ITEMS_COUNT;i++)
	{
	DebugPrint("%d %s",i,MenuItems[i-g_item_shift]);
	ItemVote[i-g_item_shift]=0;
	Format(Title,MENU_ITEM_LEN,"%s%s",ItemShift,MenuItems[i-g_item_shift]);
	vMenu.AddItem("", Title);
	}
vMenu.ExitButton=false;
vMenu.ExitBackButton=false;
}

//***********************************************
// void BuildMapListForVoteMenu(){
//***********************************************
// #if defined DEBUG
// DebugPrint("BuildMapListForVoteMenu");
// #endif 
// if (g_MapListSerial != -1)
	// {
	// int mapCount = GetArraySize(g_MapList);		
	// char mapName[32];
	// for (int i = 0; i < mapCount; i++)
		// {
		// GetArrayString(g_MapList, i, mapName, sizeof(mapName));		
		// #if defined DEBUG
		// DebugPrint(mapName);		
		// #endif
		// }
	// }
// }
//***********************************************
void AddRandomMenuMapItem(){
//***********************************************
/*int SizePopularMenuItems=sizeof(PopularMenuItems)-1;
int IndexPopularMenuItems;
do 	{
	IndexPopularMenuItems=GetRandomInt(0,SizePopularMenuItems);
	}
while (!AddMenuMapItem(PopularMenuItems[IndexPopularMenuItems]));*/
int IndexMenuItems;
int mapCount = GetArraySize(g_MapList)-1;
char mapName[32];
do 	{
	IndexMenuItems=GetRandomInt(0,mapCount);
	GetArrayString(g_MapList, IndexMenuItems, mapName, sizeof(mapName));	
	}
while (!AddMenuMapItem(mapName));
}
//***********************************************
void AddMenuMapItem(char[] Map){
//***********************************************
if (g_voting) return false;
if (!IsMapValid(Map)) return false;
if (CandidateCount+1==MENU_ITEMS_COUNT)return false;
char currentMap[PLATFORM_MAX_PATH];
GetCurrentMap(currentMap, sizeof(currentMap));
if (strcmp(Map, currentMap, false)==0)return false;
String_ToLower(Map, Map, MENU_ITEM_LEN);
if (Array_FindString(MenuItems, CandidateCount+1, Map, false,1)!=-1) return false;
CandidateCount++;
strcopy(MenuItems[CandidateCount],MENU_ITEM_LEN,Map);
return true;
}

//*****************************************************************************
public int Handler_MapSelectMenu(Menu menu, MenuAction action, int param1, int param2){
//*****************************************************************************
switch (action)
	{
		case MenuAction_Select:
		{
		char map[64];
			menu.GetItem(param2, map, sizeof(map));		
			cmd_Elect_Map(param1,map);
		}
	}	
return 0;
}
//*****************************************************************************
void BuildMapMenu(){
//*****************************************************************************	
delete g_MapMenu;
g_MapMenu = new Menu(Handler_MapSelectMenu, MENU_ACTIONS_DEFAULT|MenuAction_DrawItem|MenuAction_DisplayItem);
//char map[PLATFORM_MAX_PATH];
char currentMap[PLATFORM_MAX_PATH];
GetCurrentMap(currentMap, sizeof(currentMap));
if (g_mapFileSerial != -1) 
	{
	int mapCount = GetArraySize(g_MapList)-1;
	char mapName[32];
	for (int i = 0; i != mapCount; i++)
		{
		GetArrayString(g_MapList, i, mapName, sizeof(mapName));		
		g_MapMenu.AddItem(mapName,mapName);
		}
	}
g_MapMenu.ExitButton = true;

}
//*****************************************************************************
//public void OnPluginEnd(){
//*****************************************************************************
//if (k64tDB!=INVALID_HANDLE) SQL_UnlockDatabase(k64tDB); 
//}
//*****************************************************************************
#endinput
//#C:\pro\SourceMod\MySMcompile.exe "$(FULL_CURRENT_PATH)"
===
//-> use mp_round_restart_delay & mp_freezetime
//mp_round_restart_delay 0
//mp_freezetime  0
===
