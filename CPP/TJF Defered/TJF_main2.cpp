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
// c++ -fPIC -O2 -std=c++14 -IWDL/WDL -dynamiclib TJF_main2.cpp -o reaper_TJFdefered.dylib
//
// Windows
// =======
//
// (Use the VS Command Prompt matching your REAPER architecture, eg. x64 to use the 64-bit compiler)
// cl /nologo /O2 /Z7 /Zo /DUNICODE main.cpp /link /DEBUG /OPT:REF /DLL /OUT:reaper_hello_world.dll

#define REAPERAPI_IMPLEMENT
#include "reaper_plugin_functions.h"
#include <unordered_map>


struct Actions {
	void (*function)();
  	int id;
  	bool defer;
  	bool state;
};



std::unordered_map<int, Actions> Action;



void Register(void (*func)(), const char* command, const char* description) {
		custom_action_register_t action { 0, command, description };
  		int id = plugin_register("custom_action", &action);
  		Action[command] = { func, id, false, false} ;
}


void Register(void (*func)(), const char* command, const char* description, bool defer, bool state) {
		custom_action_register_t action { 0, command, description };
  		int id = plugin_register("custom_action", &action);
  		Action[command] = Actions{ func, id, defer, state} ;
}









int ToggleActionCallback(int command)
{
    if (Action.find(command) == Action.end()) return -1;
    if (Action[command].state) return 1;
    return 0;
}



static bool commandHook(KbdSectionInfo *sec, const int command,
  const int val, const int valhw, const int relmode, HWND hwnd)
{
  (void)sec; (void)val; (void)valhw; (void)relmode; (void)hwnd; // unused

	if(Action.find(command) == Action.end()) return false;
  
	//if (Action[command].defer) {
			//Action[command].state = !Action[command].state;
	//		ShowConsoleMsg("DEFERED\n");
			
			//if (Action[command].state) plugin_register("timer", reinterpret_cast<void *>(&Action[command].function));
			//else plugin_register("-timer", reinterpret_cast<void *>(&Action[command].function));	
	//}
	else Action[command].function();
	
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



//SAMPLE FUNCTION THEN REGISTRY

static void HelloWorld() {
		ShowConsoleMsg("Hello World\n"); 
}

Register(HelloWorld, "TJF_CPP_HELLO", "TJF C++: Hello World" );


static void LinkPlayAndEditCursor()
{
	if (GetPlayState()) Main_OnCommand(40434, 0);	
}

Register(LinkPlayAndEditCursor, "TJF_CPP_LINK01","TJF C++ Link Play and Edit Cursor", true, false);


