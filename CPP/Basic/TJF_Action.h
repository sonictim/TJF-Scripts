#pragma once

#include <unordered_map>


struct TJFAction {
	void (*function)();
	int ID = 0;
	bool state = false, defer = false;



	TJFAction(char* CODE, char* DESCRIPTION, void (*func)()) {
		custom_action_register_t action = {0, CODE, DESCRIPTION, NULL};
		ID = plugin_register("custom_action", &action);
		function = func;

	}
}