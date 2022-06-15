// Bare-bone REAPER extension
//
// 1. Grab reaper_plugin.h from https://github.com/justinfrankel/reaper-sdk/raw/main/sdk/reaper_plugin.h
// 2. Grab reaper_plugin_functions.h by running the REAPER action "[developer] Write C++ API functions header"
// 3. Grab WDL: git clone https://github.com/justinfrankel/WDL.git
// 4. Build then copy or link the binary file into <REAPER resource directory>/UserPlugins
//
// Linux
// =====
//
// c++ -fPIC -O2 -std=c++14 -IWDL/WDL -shared main.cpp -o reaper_barebone.so
//
// macOS
// =====
//
// c++ -fPIC -O2 -std=c++14 -IWDL/WDL -dynamiclib TJF_main.cpp -o /Users/tfarrell/Library/Application\ Support/REAPER/UserPlugins/reaper_TJF.dylib
//
// Windows
// =======
//
// (Use the VS Command Prompt matching your REAPER architecture, eg. x64 to use the 64-bit compiler)
// cl /nologo /O2 /Z7 /Zo /DUNICODE main.cpp /link /DEBUG /OPT:REF /PDBALTPATH:%_PDB% /DLL /OUT:reaper_barebone.dll

#define REAPERAPI_IMPLEMENT
#include "reaper_plugin_functions.h"
#include "registration.h"



int ToggleActionCallback(int command)
{
    if (ActionMap.find(command) == ActionMap.end()) return -1; //make sure it exists in map
    return ActionMap[command].state;
}



static bool commandHook(KbdSectionInfo *sec, const int command,
  const int val, const int valhw, const int relmode, HWND hwnd)
{
  (void)sec; (void)val; (void)valhw; (void)relmode; (void)hwnd; // unused

	if(ActionMap.find(command) == ActionMap.end()) return false;
	
	if (ActionMap[command].state > -1) {
        ActionMap[command].state = !ActionMap[command].state;        
        if (ActionMap[command].state)  SetExtState("TJF", ActionMap[command].name, "on", true);
        else SetExtState("TJF", ActionMap[command].name, "off", true);
  }
  
	if (ActionMap[command].defer) {
			if (ActionMap[command].state) plugin_register("timer", reinterpret_cast<void *>(ActionMap[command].action));
			else plugin_register("-timer", reinterpret_cast<void *>(ActionMap[command].action));	
	}
	else { 
        PreventUIRefresh(1);
        ActionMap[command].action();
        PreventUIRefresh(-1);
       }
	
	return true;
}


//PLUGIN ENTRY POINT aka "MAIN"
extern "C" REAPER_PLUGIN_DLL_EXPORT int REAPER_PLUGIN_ENTRYPOINT(
  REAPER_PLUGIN_HINSTANCE instance, reaper_plugin_info_t *rec)
{
  if(!rec)
    return 0; // cleanup here
  else if(rec->caller_version != REAPER_PLUGIN_VERSION)
    return 0;

  REAPERAPI_LoadAPI(rec->GetFunc);

  plugin_register("hookcommand2", reinterpret_cast<void *>(&commandHook));
  plugin_register("toggleaction", (void*)ToggleActionCallback);

  RegisterNewActions();
  //RegisterNewMenus();
  
  
  return 1;
}



