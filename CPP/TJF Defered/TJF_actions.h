# pragma once

#include <vector>
#include "reaper_plugin_functions.h"

void TJF_HELLO() {
    ShowConsoleMsg("Hello World!\n");
    MB("Hello World!", "TITLE BAR", 0 );
}

void TJF_GOODBYE() {
    ShowConsoleMsg("Goodbye World!\n");
    MB("Goodbye World!", "TITLE BAR", 0 );
}


void LinkPlayAndEditCursor() {
	if (GetPlayState()) Main_OnCommand(40434, 0);	
}



void TJF_ReverseFadesWithItem() {
		PreventUIRefresh(1);
		Undo_BeginBlock();


      	int itemcount = CountSelectedMediaItems(0);
      	if (!itemcount) return;
		for (int i = 0; i < itemcount; i++) {
			auto item = GetSelectedMediaItem(0,i);
			double temp = GetMediaItemInfo_Value(item, "D_FADEINLEN");
            SetMediaItemInfo_Value(item,"D_FADEINLEN", GetMediaItemInfo_Value(item, "D_FADEOUTLEN") );
        	SetMediaItemInfo_Value(item,"D_FADEOUTLEN", temp);

            temp = GetMediaItemInfo_Value(item, "D_FADEINDIR");
            SetMediaItemInfo_Value(item,"D_FADEINDIR", GetMediaItemInfo_Value(item, "D_FADEOUTDIR") );
            SetMediaItemInfo_Value(item,"D_FADEOUTDIR", temp);

            temp = GetMediaItemInfo_Value(item, "D_FADEINLEN_AUTO");
            SetMediaItemInfo_Value(item,"D_FADEINLEN_AUTO", GetMediaItemInfo_Value(item, "D_FADEOUTLEN_AUTO") );
            SetMediaItemInfo_Value(item,"D_FADEOUTLEN_AUTO", temp);

            temp = GetMediaItemInfo_Value(item, "C_FADEINSHAPE");
        	SetMediaItemInfo_Value(item,"C_FADEINSHAPE", GetMediaItemInfo_Value(item, "C_FADEOUTSHAPE") );
            SetMediaItemInfo_Value(item,"C_FADEOUTSHAPE", temp);
		}


      	Main_OnCommand(41051, 0);  // Reverse Takes
      
      	UpdateArrange();
		Undo_EndBlock("Reverse Fades with Item", 0);
		PreventUIRefresh(-1);
}


