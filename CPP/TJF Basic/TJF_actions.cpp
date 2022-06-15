# pragma once

#include "TJF.h"
#include "razoredits.cpp"
#include "envelopes.cpp"




void TJF_TestFunction() {
	ClearConsole();
	msg("Running Test Function");
	
	Item i(GetSelectedMediaItem(0,0));
	i.end += 10;


	// auto track = GetSelectedTrack(0,0);
	// auto env = GetTrackEnvelopeByName(track, "Volume");
	// SetEnvelopeVis(env, true);

	// {
	// 	EnvelopePoint e;
	// 	e.value = 0;
	// }

	// MediaTrack* track = GetSelectedTrack(0,0);
	// char str[ChunkSize];
	// //char* result = str;
	// GetTrackStateChunk(track, str, ChunkSize, false);
	// //msg(str);
	// std::vector<RazorEdit> RE;
	// GetRazorEdits(RE);
	// msg(RE[0].start);
	// msg(RE[0].end);
	// msg(RE[0].items.size());

	//TrackEnvelope* env = GetTakeEnvelopeByName(GetActiveTake(GetSelectedMediaItem(0,0)), "Volume");
	//msg(env);

}


// void ReverseItem(MediaItem* &item) {

// 	for (int i=0; i <CountTakes(item); i++) {
// 		MediaItem_Take* take = GetTake(item, 0);
// 		bool section;
// 		double startTime;
// 		double length;
// 		double fade;
// 		bool reverse;

// 		if (GetMediaSourceProperties(take, &section, &startTime, &length, &fade, &reverse ))
// 			SetMediaSourceProperties(MediaItem_Take* take, section, startTime, length, fade, !reverse );
// 	}
// }



void SwapItemFades(MediaItem* &item) {
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


void TJF_ReverseFadesWithItem() {
		Undo_BeginBlock();
      	int itemcount = CountSelectedMediaItems(0);
      	if (!itemcount) return;
		for (int i = 0; i < itemcount; i++) {
			MediaItem* item = GetSelectedMediaItem(0,i);
			SwapItemFades(item);
		}

		Main_OnCommand(41051, 0); // Item: Toggle Reverse Takes      
      	UpdateArrange();
		Undo_EndBlock("Reverse Fades with Item", 0);
}

void ReversePosition(MediaItem* &item, double &startTime, double &endTime) {
	double pos = GetMediaItemInfo_Value(item, "D_POSITION");
	if (pos < startTime || pos > endTime) return;
	double len = GetMediaItemInfo_Value(item, "D_LENGTH");
	pos = endTime - len - pos + startTime;
	SetMediaItemInfo_Value(item,"D_POSITION", pos);
}


void TJF_Reverse() {
	double startTime, endTime;
	GetSet_LoopTimeRange2(0, false, false, &startTime, &endTime, false);
	if (startTime!=endTime) {
		msg("item selection");
		Main_OnCommand(40061,0);  //Split Items at Time Selection
		for (int i = 0; i < CountSelectedMediaItems(0); i++) {
			MediaItem* item = GetSelectedMediaItem(0,i);
			ReversePosition(item, startTime, endTime);
			SwapItemFades(item);
		}
		Main_OnCommand(41051,0); //Reverse Takes
		return;
	}
	
	std::vector<RazorEdit> RazorEdits;
	GetRazorEdits(RazorEdits);
	if (RazorEdits.size()) {
		for (auto &RE : RazorEdits) {
			for (auto &item : RE.items) {
				auto newItem = SplitMediaItem(item, RE.start);
				if (newItem == NULL) {
					SplitMediaItem(item, RE.end);
					ReversePosition(item, RE.start, RE.end);
					SwapItemFades(item);
				}
				else {
					SplitMediaItem(newItem, RE.end);
					ReversePosition(newItem, RE.start, RE.end);
					SwapItemFades(newItem);
				}
			}



		}
		Main_OnCommand(41051,0);
		return;
	}
	TJF_ReverseFadesWithItem();
}













void TJF_LinkPlayAndEditCursor() {
	PreventUIRefresh(1);
	//if (GetPlayState()) 
		Main_OnCommand(40434, 0);	
	//double pos = GetPlayPosition();
	//SetEditCurPos(pos, false, false );
	PreventUIRefresh(-1);
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

void TJF_SaveAllDirtyProjects() {
	PreventUIRefresh(1);
	ReaProject* curProj = EnumProjects(-1, NULL, 0);
	int i = 0;
	ReaProject* proj = EnumProjects(i, NULL, 0);

	while (proj) {
		if (IsProjectDirty(proj)) Main_SaveProject(proj, false);
		i++;
		proj = EnumProjects(i, NULL, 0);
	}
	SelectProjectInstance(curProj);
	PreventUIRefresh(-1);
}

void TJF_LinkEditAndMouseCursor() {
	int x, y;
	MediaTrack* track;
	char info[64];

	GetMousePosition(&x, &y);

	//track = GetThingFromPoint(x, y, info, 64);

	//if (!strcmp(info, "arrange")) 
	Main_OnCommand(40513, 0); //Move Edit Cursor to Mouse Position
}
