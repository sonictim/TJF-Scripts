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
}
