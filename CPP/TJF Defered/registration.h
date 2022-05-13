# pragma once

#include "reaper_plugin_functions.h"
#include <unordered_map>
#include "TJF_actions.h"


struct TJFAction {
	void (*action)();
  	int ID;
  	bool defer;
  	bool state;
};

static std::unordered_map<int, TJFAction> ActionList;



void TJFRegisterAction(void (*func)(), const char* ID, const char* Desc, bool defer, bool state) {

  custom_action_register_t action { 0, ID, Desc };
  int actionId = plugin_register("custom_action", &action);
  // if (defer) {
  //    plugin_register("toggleaction", (void*)ToggleActionCallback);
  // }

  ActionList[actionId] = TJFAction{ func, actionId, defer, state} ;
}


void Registration() {
	TJFRegisterAction(TJF_HELLO, "TJF_CPP_HELLOWORLD", "TJF C++ Hello World", false, false);
  	TJFRegisterAction(TJF_GOODBYE, "TJF_CPP_GOODBYEWORLD", "TJF C++ Goodbye World", false, false);
  	TJFRegisterAction(TJF_ReverseFadesWithItem, "TJF_CPP_REVERSE01", "TJF C++ Reverse Fades with Item", false, false);
	TJFRegisterAction(TJF_LinkPlayback, "TJF_CPP_LINKPLAYBACK", "TJF C++ Link Play and Edit Cursor", true, false);

}






