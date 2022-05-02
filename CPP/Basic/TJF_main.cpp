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
// c++ -fPIC -O2 -std=c++14 -IWDL/WDL -dynamiclib TJF_main.cpp -o reaper_TJF.dylib
//
// Windows
// =======
//
// (Use the VS Command Prompt matching your REAPER architecture, eg. x64 to use the 64-bit compiler)
// cl /nologo /O2 /Z7 /Zo /DUNICODE main.cpp /link /DEBUG /OPT:REF /PDBALTPATH:%_PDB% /DLL /OUT:reaper_barebone.dll

#define REAPERAPI_IMPLEMENT
#include "reaper_plugin_functions.h"

#include <unordered_map>


struct TJFAction {
  int ID;
  void (*function)();
  bool state;
  bool defer;

};

static std::unordered_map<int, TJFAction> ActionList;



void TJFRegisterAction(void (*func)(), const char* ID, const char* Desc, bool defer, bool state) {

  custom_action_register_t action { 0, ID, Desc };
  int actionId = plugin_register("custom_action", &action);
  // if (defer) {
  //    plugin_register("toggleaction", (void*)ToggleActionCallback);
  // }

  ActionList[actionId] = TJFAction{ actionId, func, defer, state} ;
}

void TJFFunction() {
    ShowConsoleMsg("Hello World!\n");
    MB("Hello World!", "TITLE BAR", 0 );
}





static bool commandHook(KbdSectionInfo *sec, const int command,
  const int val, const int valhw, const int relmode, HWND hwnd)
{
  (void)sec; (void)val; (void)valhw; (void)relmode; (void)hwnd; // unused

  if(ActionList.find(command) != ActionList.end()) {
   if (ActionList[command].defer) {
        // flip state on/off
        ActionList[command].state = !ActionList[command].state;

        if (ActionList[command].state) {
            // "reaper.defer(main)"
            plugin_register("timer", (void*)&ActionList[command].function);
        }
        else {
            // "reaper.atexit(shutdown)"
            plugin_register("-timer", (void*)&ActionList[command].function);
            // shutdown stuff
        }
    }
    else {
        // call main function once
        ActionList[command].function();
    }

    return true;}
  

  return false;
}

// returns current toggle on/off state,
/* see reaper_plugin.h
int ToggleActionCallback(int command)
{
    if (ActionList.find(command) == ActionList.end()) {
        return -1;
    }
    else if (ActionList[command].state) {
        return 1;
    }
    return 0;
}
*/

extern "C" REAPER_PLUGIN_DLL_EXPORT int REAPER_PLUGIN_ENTRYPOINT(
  REAPER_PLUGIN_HINSTANCE instance, reaper_plugin_info_t *rec)
{
  if(!rec)
    return 0; // cleanup here
  else if(rec->caller_version != REAPER_PLUGIN_VERSION)
    return 0;

  REAPERAPI_LoadAPI(rec->GetFunc);

  plugin_register("hookcommand2", reinterpret_cast<void *>(&commandHook));
  //plugin_register("toggleaction", (void*)ToggleActionCallback);

  TJFRegisterAction(&TJFFunction, "TJF_CPP_HELLOWORLD", "TJF C++ Hello World", false, false);

  return 1;
}