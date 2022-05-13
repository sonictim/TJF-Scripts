// This extension adds an action named "ReaImGui C++ example"
//
// Prerequisites
// =============
//
// 1. Grab reaper_plugin.h from https://github.com/justinfrankel/reaper-sdk/raw/main/sdk/reaper_plugin.h
// 2. Grab reaper_plugin_functions.h by running the REAPER action "[developer] Write C++ API functions header"
// 3. Grab reaper_imgui_functions.h from https://github.com/cfillion/reaimgui/releases
// 4. Grab WDL: git clone https://github.com/justinfrankel/WDL.git
// 5. Build then copy or link the binary file into <REAPER resource directory>/UserPlugins
//
// Linux
// =====
//
// c++ -fPIC -O2 -std=c++14 -IWDL/WDL -shared hello_world.cpp -o reaper_hello_world.so
//
// macOS
// =====
//
// c++ -fPIC -O2 -std=c++14 -IWDL/WDL -dynamiclib TJF_main.cpp -o reaper_TJFdefered.dylib
//
// Windows
// =======
//
// (Use the VS Command Prompt matching your REAPER architecture, eg. x64 to use the 64-bit compiler)
// cl /nologo /O2 /Z7 /Zo /DUNICODE main.cpp /link /DEBUG /OPT:REF /DLL /OUT:reaper_hello_world.dll

#define REAPERAPI_IMPLEMENT
#include "reaper_plugin_functions.h"

static int g_actionId;
static bool state = false;


static void loop()
{
	if (GetPlayState()) Main_OnCommand(40434, 0);	
}

int ToggleActionCallback(int command)
{
    if (command != g_actionId) {
        return -1;
    }
    else if (state) {
        return 1;
    }
    return 0;
}

static bool commandHook(KbdSectionInfo *sec, const int command,
  const int val, const int valhw, const int relmode, HWND hwnd)
{
  (void)sec; (void)val; (void)valhw; (void)relmode; (void)hwnd; // unused

	if (command != g_actionId) return false;
  
    state = !state;
    
    if (state) plugin_register("timer", reinterpret_cast<void *>(&loop));
    else plugin_register("-timer", reinterpret_cast<void *>(&loop));

    return true;
}

extern "C" REAPER_PLUGIN_DLL_EXPORT int REAPER_PLUGIN_ENTRYPOINT(
  REAPER_PLUGIN_HINSTANCE instance, reaper_plugin_info_t *rec)
{
  if(!rec)
    return 0; // cleanup here
  else if(rec->caller_version != REAPER_PLUGIN_VERSION)
    return 0;

  REAPERAPI_LoadAPI(rec->GetFunc);

  custom_action_register_t action { 0, "TJF_CPP_DEFER", "TJF C++ Deferred Test"};
  g_actionId = plugin_register("custom_action", &action);

  plugin_register("hookcommand2", reinterpret_cast<void *>(&commandHook));
  plugin_register("toggleaction", reinterpret_cast<void *>(&ToggleActionCallback));

  return 1;
}