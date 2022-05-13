# pragma once


#include "TJF.h"
#include "razoredits.h"



void TJF_HELLO() {
    ShowConsoleMsg("Hello World!\n");
    MB("Hello World!", "TITLE BAR", 0 );
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

void TJF_LinkPlayAndEditCursor() {
	//if (GetPlayState()) 
		Main_OnCommand(40434, 0);	
	//double pos = GetPlayPosition();
	//SetEditCurPos(pos, false, false )
}

void TJF_EditInsertionFollowsPlayback() {
	static int state = GetPlayState();
	if (state == GetPlayState()) return;
	state = GetPlayState();
	
	double pos = GetPlayPosition();
	SetEditCurPos(pos, false, false );
}



void TJF_ToggleMoveMode() {
	int command = NamedCommandLookup("_TJF_CPP_MOVEMODE");
	int rectify = GetToggleCommandState(42307); // check rectify
	
	if (ActionMap[command].state == 1) {
		Main_OnCommand(40569,0); //enable locking
  		Main_OnCommand(40595,0); // set item edges lock
  		Main_OnCommand(40598,0); //set item fades lock
  		Main_OnCommand(41852,0); //set item stretch markers lock
  		Main_OnCommand(41849,0); //set item envelope
  		Main_OnCommand(40572,0); //set time selection to UNlock
  		//Main_OnCommand(40571,0); //set time selection to lock  
  		if (!rectify) Main_OnCommand(42307,0); //rectify peaks    
  		Main_OnCommand(40578,0); //Locking: Clear left/right item locking mode
  		Main_OnCommand(40581,0); //Locking: Clear up/down item locking mode
  		return;
	}
  	Main_OnCommand(40570,0); // disable locking
  	if (rectify) Main_OnCommand(42307,0); //rectify peaks
	//Main_OnCommand(39013,0); --Set default mouse modifier action for "Media item left drag" to "Move item ignoring time selection" (factory default)

}









