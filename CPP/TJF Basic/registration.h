# pragma once

#include "reaper_plugin_functions.h"
#include <unordered_map>

struct ActionData 
{
	void (*action)();
  	int ID;
    int state;
  	bool defer;
    const char* name;
    const char* desc;
};


std::unordered_map<int, ActionData> ActionMap;

#include "TJF_actions.cpp"

static void Register(void (*func)(), const char* id, const char* desc, int state, bool def) 
{
  custom_action_register_t action { 0, id, desc };
  int actionId = plugin_register("custom_action", &action);
  if (HasExtState("TJF", id)) {
      int len = strlen(GetExtState("TJF", id));
      state = len == 2;
  }
  ActionMap[actionId] = ActionData{ func, actionId, state, def, id, desc} ;
  if (def && state) plugin_register("timer", reinterpret_cast<void *>(func));
}

static void Register(void (*func)(), const char* id, const char* desc, int state) 
{
  custom_action_register_t action { 0, id, desc };
  int actionId = plugin_register("custom_action", &action);
  if (HasExtState("TJF", id)) {
      int len = strlen(GetExtState("TJF", id));
      state = len == 2;
  }
  ActionMap[actionId] = ActionData{ func, actionId, state, false, id, desc} ;
}

static void Register(void (*func)(), const char* id, const char* desc) 
{
  custom_action_register_t action { 0, id, desc };
  int actionId = plugin_register("custom_action", &action);
  ActionMap[actionId] = ActionData{ func, actionId, -1, false, id, desc} ;
}

static bool defer = true;

void RegisterNewActions() 
{
    Register(TJF_TestFunction, "TJF_CPP_TEST", "TJF C++ zzzTestFunction");
  	Register(TJF_ReverseFadesWithItem, "TJF_CPP_REVERSE01", "TJF C++ Reverse Fades with Item");
  	Register(TJF_LinkPlayAndEditCursor, "TJF_CPP_LINKPLAYEDIT", "TJF C++ Link Play and Edit Cursor", 0, defer);
    Register(TJF_EditInsertionFollowsPlayback, "TJF_CPP_EDITINSERTION", "TJF C++ Edit Insertion Follows Playback", 1, defer);
  	Register(TJF_ToggleMoveMode, "TJF_CPP_MOVEMODE", "TJF C++ Toggle Move Mode", 0);
    Register(TJF_LinkTrackandEditSelection, "TJF_CPP_LINKTRACKEDIT", "TJF C++ Link Track and Edit Selection", 1, defer);
    Register(TJF_SaveAllDirtyProjects, "TJF_CPP_SAVEALLDIRTY", "TJF C++ Save All Open Dirty Projects");
    Register(TJF_Reverse, "TJF_CPP_REVERSE", "TJF C++ Reverse Time");
    Register(TJF_LinkEditAndMouseCursor, "TJF_CPP_LINKEDITANDMOUSE", "TJF C++ Link Edit and Mouse Cursor", 1, defer);
    
    //RAZOR EDITS
    Register(TJF_LinkRazorEditToFolders, "TJF_CPP_LINKRAZOR2FOLDER", "TJF C++ Link Razor Edits to Folders", 1, defer);
    
    
    //ENVELOPES
    Register(TJF_HideAllEnvelopes, "TJF_CPP_HIDEENVELOPES", "TJF C++ Hide All Envelopes");
    Register(TJF_HideAllTrackEnvelopes, "TJF_CPP_HIDETRACKENVELOPES", "TJF C++ Hide All Track Envelopes");
    Register(TJF_HideAllTakeEnvelopes, "TJF_CPP_HIDETAKEENVELOPES", "TJF C++ Hide All Take Envelopes");
    Register(TJF_AutoDisplayLastTouchedEnvelope, "TJF_CPP_AUTOSHOWLASTTOUCHED", "TJF C++ Auto Display Last Touched FX Envelope", 1, defer);
    Register(TJF_ToggleVolumeEnvelopes, "TJF_CPP_VOLENVTOGGLE", "TJF C++ Toggle Volume Envelopes");
    Register(TJF_ToggleVolumeEnvelopes2, "TJF_CPP_VOLENVTOGGLE2", "TJF C++ Toggle Volume Envelopes (Pre-FX)");
    Register(TJF_TogglePanEnvelopes, "TJF_CPP_PANENVTOGGLE", "TJF C++ Toggle Pan Envelopes");
    Register(TJF_TogglePanEnvelopes2, "TJF_CPP_PANENVTOGGLE2", "TJF C++ Toggle Pan Envelopes (Pre-FX)");
    Register(TJF_TogglePitchEnvelopes, "TJF_CPP_PITCHENVTOGGLE", "TJF C++ Toggle Pitch Envelopes (TakeFX Only)");
    Register(TJF_ToggleMuteEnvelopes, "TJF_CPP_MUTEENVTOGGLE", "TJF C++ Toggle Mute Envelopes");
    Register(TJF_ToggleLastTouchedFXEnvelope, "TJF_CPP_TOGGLELASTTOUCHEDFX", "TJF C++ Toggle Last Touched FX Envelope");

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







void RegisterNewMenus()
{

    AddExtensionsMainMenu();
    AddCustomizableMenu("TJF", "TJF Options", NULL, true);
    plugin_register("hookcustommenu", (void*)MenuHook);
}
*/