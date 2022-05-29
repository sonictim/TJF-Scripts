# pragma once

#include "TJF.h"
#include "razoredits.h"

#define ChunkSize 1000000

void TJF_TestFunction() {
	ClearConsole();
	msg("Running Test Function");

	MediaTrack* track = GetSelectedTrack(0,0);
	char str[ChunkSize];
	//char* result = str;
	GetTrackStateChunk(track, str, ChunkSize, false);
	//msg(str);
	std::vector<RazorEdit> RE;
	GetRazorEdits(RE);
	msg(RE[0].start);
	msg(RE[0].end);
	msg(RE[0].items.size());

	//TrackEnvelope* env = GetTakeEnvelopeByName(GetActiveTake(GetSelectedMediaItem(0,0)), "Volume");
	//msg(env);

}


void TJF_ReverseFadesWithItem() {
		PreventUIRefresh(1);
		Undo_BeginBlock();


      	int itemcount = CountSelectedMediaItems(0);
      	if (!itemcount) return;
		for (int i = 0; i < itemcount; i++) {
			MediaItem* item = GetSelectedMediaItem(0,i);
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



void TJF_HideTrackEnvelopes() {
	for (int i = 0; i < CountTracks(0); i++) {
		MediaTrack* track = GetTrack(0,i);

		for (int i = 0; i < CountTrackEnvelopes(track); i++) {
			TrackEnvelope* env = GetTrackEnvelope(track, i);
			char strNeedBig[ChunkSize];
			char* result = strNeedBig;
			GetEnvelopeStateChunk(env, strNeedBig, ChunkSize, false );
			result = strstr(strNeedBig, "VIS ");
			result += 4;
			*result = 48;
			SetEnvelopeStateChunk(env, strNeedBig, true);
		}
	}
}

void TJF_HideTrackEnvelopes(MediaTrack* track) {
		for (int i = 0; i < CountTrackEnvelopes(track); i++) {
			TrackEnvelope* env = GetTrackEnvelope(track, i);
			char strNeedBig[ChunkSize];
			char* result = strNeedBig;
			GetEnvelopeStateChunk(env, strNeedBig, ChunkSize, false );
			result = strstr(strNeedBig, "VIS ");
			result += 4;
			*result = 48;
			SetEnvelopeStateChunk(env, strNeedBig, true);
		}

}

void TJF_HideTrackEnvelopes(std::vector<MediaTrack*> tracks) {
		for (auto track : tracks) {
			
			for (int i = 0; i < CountTrackEnvelopes(track); i++) {
				TrackEnvelope* env = GetTrackEnvelope(track, i);
				char strNeedBig[ChunkSize];
				char* result = strNeedBig;
				GetEnvelopeStateChunk(env, strNeedBig, ChunkSize, false );
				result = strstr(strNeedBig, "VIS ");
				result += 4;
				*result = 48;
				SetEnvelopeStateChunk(env, strNeedBig, true);
			}
		}
}


void TJF_HideAllEnvelopes() {
	for (int i = 0; i < CountTracks(0); i++) {
		MediaTrack* track = GetTrack(0,i);
		char str[ChunkSize];
		char* result = str;
		GetTrackStateChunk(track, str, ChunkSize, false);

		while ((result = std::strstr(result, "VIS ")) != nullptr) {
			result +=4;
			*result = 48;
		} 
		SetTrackStateChunk(track, str, true);
	}
}

void TJF_HideTakeEnvelopes() {  // Hides all take envelopes for all items
	for (int i = 0; i < CountMediaItems(0); i++) {
		MediaItem* item = GetMediaItem(0,i);
		char str[ChunkSize];
		char* result = str;
		GetItemStateChunk(item, str, ChunkSize, false);

		while ((result = std::strstr(result, "VIS ")) != nullptr) {
			result +=4;
			*result = 48;
		} 
		SetItemStateChunk(item, str, true);
	}
}

void TJF_HideTakeEnvelopes(MediaItem* item) {  // Hides take envelopes for just the item submitted
		char str[ChunkSize];
		char* result = str;
		GetItemStateChunk(item, str, ChunkSize, false);

		while ((result = std::strstr(result, "VIS ")) != nullptr) {
			result +=4;
			*result = 48;
		} 
		SetItemStateChunk(item, str, true);
}

void TJF_HideTakeEnvelopes(std::vector<MediaItem*> items) {  // Hides take envelopes for just the item submitted
	for (auto item : items) {
		char str[ChunkSize];
		char* result = str;
		GetItemStateChunk(item, str, ChunkSize, false);

		while ((result = std::strstr(result, "VIS ")) != nullptr) {
			result +=4;
			*result = 48;
		} 
		SetItemStateChunk(item, str, true);
	}
}


bool GetEnvelopeVis(TrackEnvelope* envelope) {
	char str[ChunkSize];
	char* result = str;
	GetEnvelopeStateChunk(envelope, str, ChunkSize, false);
	result = strstr(str, "VIS ");
	result += 4;
	if (*result == 49) return true;
	return false;
}
/*
void SetEnvelopeVis(TrackEnvelope* envelope, bool vis) {
	char str[ChunkSize];
	char* result = str;
	GetEnvelopeStateChunk(envelope, str, ChunkSize, false);
	result = strstr(str, "VIS ");
	result += 4;
	if (vis) *result = 49;
	else *result = 48;
	SetEnvelopeStateChunk(envelope, str, false);
}
*/

void SetEnvelopeVis(TrackEnvelope* envelope, bool vis) {
	char str[ChunkSize];
	char* result = str;
	GetEnvelopeStateChunk(envelope, str, ChunkSize, false);
	result = strstr(str, "VIS ");
	result += 4;
	*result = 48 + vis;
	SetEnvelopeStateChunk(envelope, str, false);
}


bool IsTakeEnvVisible(const char* name) {   // name is envelope to check ("Volume", "Pan", or "Pitch")
	for (int i = 0; i < CountSelectedMediaItems(0); i++) {
		TrackEnvelope* env = GetTakeEnvelopeByName(GetActiveTake(GetSelectedMediaItem(0,i)), name);
		if (env && GetEnvelopeVis(env)) return true;
	}
	return false;
}

bool IsTrackEnvVisible(const char* name) {   // name is envelope to check ("Volume", "Pan", or "Pitch")
	for (int i = 0; i < CountSelectedTracks(0); i++) {
		TrackEnvelope* env = GetTrackEnvelopeByName(GetSelectedTrack(0,i), name);
		if (env && GetEnvelopeVis(env)) return true;
	}
	return false;
}


void ToggleTakeEnvelope(const char* name) {

	char visible = IsTakeEnvVisible(name) + 48 ;
	for (int i = 0; i < CountSelectedMediaItems(0); i++) {
			MediaItem* item = GetSelectedMediaItem(0,i);
			TJF_HideTakeEnvelopes(item);
			TrackEnvelope* env = GetTakeEnvelopeByName(GetActiveTake(GetSelectedMediaItem(0,0)), "Volume");

			char str[ChunkSize];
			char* result = str;
			GetEnvelopeStateChunk(env, str, ChunkSize, false);
}	}


/*

function ToggleTakeEnvelope(kind) -- Toggles the take envelope visibility Volume, Pan, or Pitch

      local visible = not AnyTakeEnvVisible(kind)     --decide if we should show or hide the envelope
      if visible then visible = "1" else visible = "0" end
      
      for i=1, #items do

            local _,  str = reaper.GetItemStateChunk( items[i], "", false )
                      str = string.gsub(str, "\nVIS %d", "\nVIS 0")  -- hide all envelopes for item
                      
            local     VolEnv = string.match(str, "<VOLENV.->")      --find the volume envelope
            
            if not    VolEnv 
            then      VolEnv = CreateNewEnv("<VOLENV")
                      
            end

            VolEnv = string.gsub(VolEnv, "\nVIS %d", "\nVIS "..visible)  -- adjust visibility per toggle we set earlier

            str =  str:match('(<ITEM.*)>.-$')
            str =  str .. VolEnv
            

            reaper.SetItemStateChunk(items[i], str, false)  -- write chunk
           
      end--for
      
      if #items == 1 then 
          reaper.SetCursorContext( 2, reaper.GetTakeEnvelopeByName(reaper.GetActiveTake(items[1]), "Volume" )) -- selects envelope
          --reaper.Main_OnCommand(40332,0) -- Envelope:  Select all points
      end
      
end--ToggleTakeEnvelope(param)
*/

 
void LastTouchedFXTrack(int& tracknum, int& fxnum, int& paramnum) {
	MediaTrack* track = GetTrack(0, tracknum-1);

	double minvalOut, maxvalOut;
	static double val;
	double fxvalue = TrackFX_GetParam(track, fxnum, paramnum, &minvalOut, &maxvalOut);
	if (val == fxvalue) return;
	val = fxvalue;

	TrackEnvelope* envelope = GetFXEnvelope( track, fxnum, paramnum, true );
	TJF_HideTrackEnvelopes(track);
	SetEnvelopeVis(envelope, true);
	SetCursorContext( 2, envelope );
	int numpoints = CountEnvelopePoints(envelope);
	if (numpoints > 1) return;
	if (!numpoints) InsertEnvelopePointEx(envelope, -1, 0, val, 0, 0, 1, 0);
	
	double timeOut, valueOut, tensionOut;
	int shapeOut;
	bool  selectedOut;
	GetEnvelopePoint(envelope, 0, double* timeOut, double* valueOut, int* shapeOut, double* tensionOut, bool* selectedOut );
	SetEnvelopePoint (envelope, 0, )

	bool SetEnvelopePoint(TrackEnvelope* envelope, int ptidx, double* timeInOptional, double* valueInOptional, int* shapeInOptional, double* tensionInOptional, bool* selectedInOptional, bool* noSortInOptional )
	



}





 void TJF_DisplayLastTouchedEnvelope() {

	 static int tracknum, fxnum, paramnum;
	 if (GetLastTouchedFX(&tracknum, &fxnum, &paramnum )) {
		//if (tracknum == tracknumberOut && fxnum == fxnumberOut && paramnum == paramnumberOut) return;	 
		if (tracknum >> 16) msg("TAKE");
		else LastTouchedFXTrack(tracknum, fxnum, paramnum);


	 }
 }


// function TrackFXLastTouched(tracknumber, fxnumber, paramnumber)
//               local track = reaper.CSurf_TrackFromID(tracknumber, false)
//               local fxvalue, minval, maxval = reaper.TrackFX_GetParam( track, fxnumber, paramnumber )
//               local _, speakers = reaper.TrackFX_GetNamedConfigParm( track, fxnumber, "NUMSPEAKERS" )              
              
//               if fxvalue ~= oldvalue then
             
//                     envelope = reaper.GetFXEnvelope( track, fxnumber, paramnumber, true )
//                     if envelope ~= nil then
//                             for i=0,  reaper.CountTrackEnvelopes( track ) - 1 do
                            
//                                   local env = reaper.GetTrackEnvelope( track, i )
//                                   local _, name = reaper.GetEnvelopeName( env )
//                                   local _, trackname = reaper.GetTrackName(track)
//                                   if env~=envelope  
//                                   then 
//                                         if (name == "Trim Volume" and reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH" ) == 1 and trackname ~= "PIX" ) or ReaSurround2(env, envelope, speakers)
//                                         then
//                                             SetEnvelopeVis(env, true)
//                                         else
//                                             SetEnvelopeVis(env, false)
//                                         end
//                                   else SetEnvelopeVis(env, true)
//                                         if  reaper.CountEnvelopePoints( envelope ) < 2 then
//                                                     if reaper.CountEnvelopePoints(envelope) < 1  
//                                                     then  reaper.InsertEnvelopePointEx( envelope, -1, 0, fxvalue, 0, 0, 1, 0 )
//                                                     end
                                                    
//                                                     local  retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint( envelope, 0 )
//                                                     reaper.SetEnvelopePoint( envelope, 0, time, fxvalue, shape, tension, selected, false )
//                                         end--if
                                  
                                  
                                  
                                  
//                                   end--if

                                  
//                             end--for
//                         reaper.SetCursorContext( 2, envelope ) -- selects envelope
//                         --reaper.Main_OnCommand(40332,0) -- Envelope:  Select all points
//                     end--if

//                     oldvalue = fxvalue
//                     reaper.TrackList_AdjustWindows(false)
                    
//               end--if
              

// end--TrackFXLastTouched


