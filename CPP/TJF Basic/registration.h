# pragma once

#include "reaper_plugin_functions.h"
#include <unordered_map>

struct ActionData 
{
	void (*action)();
  	int ID;
    int state;
  	bool defer;
};


std::unordered_map<int, ActionData> ActionMap;

#include "TJF_actions.cpp"

static void Register(void (*func)(), const char* id, const char* desc, int state, bool def) 
{
  custom_action_register_t action { 0, id, desc };
  int actionId = plugin_register("custom_action", &action);
  ActionMap[actionId] = ActionData{ func, actionId, state, def} ;
  if (def && state) plugin_register("timer", reinterpret_cast<void *>(func));
}

static void Register(void (*func)(), const char* id, const char* desc, int state) 
{
  custom_action_register_t action { 0, id, desc };
  int actionId = plugin_register("custom_action", &action);
  ActionMap[actionId] = ActionData{ func, actionId, state, false} ;
}

static void Register(void (*func)(), const char* id, const char* desc) 
{
  custom_action_register_t action { 0, id, desc };
  int actionId = plugin_register("custom_action", &action);
  ActionMap[actionId] = ActionData{ func, actionId, -1, false} ;
}

static bool defer = true;

void RegisterNewActions() 
{
	  Register(TJF_HELLO, "TJF_CPP_HELLOWORLD", "TJF C++ Hello World");
  	Register(TJF_ReverseFadesWithItem, "TJF_CPP_REVERSE01", "TJF C++ Reverse Fades with Item");
  	Register(TJF_LinkPlayAndEditCursor, "TJF_CPP_LINKPLAYEDIT", "TJF C++ Link Play and Edit Cursor", 0, defer);
    Register(TJF_EditInsertionFollowsPlayback, "TJF_CPP_EDITINSERTION", "TJF C++ Edit Insertion Follows Playback", 1, defer);
  	Register(TJF_ToggleMoveMode, "TJF_CPP_MOVEMODE", "TJF C++ Toggle Move Mode", 0);
    Register(TJF_LinkRazorEditToFolders, "TJF_CPP_LINKRAZOR2FOLDER", "TJF C++ Link Razor Edits to Folders", 1, defer);
    Register(TJF_LinkTrackandEditSelection, "TJF_CPP_LINKTRACKEDIT", "TJF C++ Link Track and Edit Selection", 1, defer);
    Register(TJF_SaveAllDirtyProjects, "TJF_CPP_SAVEALLDIRTY", "TJF C++ Save All Open Dirty Projects");
    Register(TJF_HideAllEnvelopes, "TJF_CPP_HIDEENVELOPES", "TJF C++ Hide All Envelopes");
    Register(TJF_HideTrackEnvelopes, "TJF_CPP_HIDETRACKENVELOPES", "TJF C++ Hide All Track Envelopes");
    Register(TJF_HideTakeEnvelopes, "TJF_CPP_HIDETAKEENVELOPES", "TJF C++ Hide All Take Envelopes");
    Register(TJF_TrackChunkTest, "TJF_CPP_TRACKCHUNKTEST", "TJF C++ Track Chunk Test");

} 

/*
void MenuHook(const char* menuidstr, HMENU menu, int flag)
{
    if (strcmp(menuidstr, "Main extensions") || flag != 0)
        return;

    if (!menu) {
        menu = CreatePopupMenu();
    }

    int pos = GetMenuItemCount(menu);

    MENUITEMINFO mii;
    mii.cbSize = sizeof(mii);
    mii.fMask = MIIM_TYPE | MIIM_ID;
    mii.fType = MFT_STRING;
    // menu name
    mii.dwTypeData = (char*)"TJF Link Track and Edit Selection";
    // menu command
    mii.wID = NamedCommandLookup("_TJF_CPP_LINKTRACKEDIT");
    // insert as next menu item
    InsertMenuItem(menu, pos++, true, &mii);
    return;
}

*/






void RegisterNewMenus()
{
    //plugin_register("hookcustommenu", (void*)MenuHook);
    //AddExtensionsMainMenu();
    AddCustomizableMenu("TJF", "TJF Options", NULL, true);
}