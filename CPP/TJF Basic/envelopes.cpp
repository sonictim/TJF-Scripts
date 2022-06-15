#pragma once

#include <vector>
#include "TJF.h"
#include "reaper_plugin_functions.h"

struct EnvelopePoint {
	TrackEnvelope* envelope;
    int autoIndex;
	int index;
	double time;
	double value;
	int shape;
	double tension;
	bool selected;
	bool noSort;

    	EnvelopePoint()  // Gets First Point of Selected Envelope
            : envelope(GetSelectedEnvelope(0)), autoIndex(-1), index(0), time(0), value(0), shape(0), tension(0), selected(true), noSort(false)
        {
            // if (!CountEnvelopePointsEx(envelope, autoIndex)) InsertEnvelopePointEx(envelope, autoIndex, time, value, shape, tension, selected, &noSort);  
            //else 
			GetEnvelopePointEx(envelope, autoIndex, index, &time, &value, &shape, &tension, &selected );
    	}

	    EnvelopePoint(TrackEnvelope* e)   // Gets First Envelope Point of Specified Envelope
            : envelope(e), autoIndex(-1), index(0), time(0), value(0), shape(0), tension(0), selected(true), noSort(false)
        {
            //if (!CountEnvelopePointsEx(envelope, autoIndex)) InsertEnvelopePointEx(envelope, autoIndex, time, value, shape, tension, selected, &noSort);  
            // else 
			GetEnvelopePointEx(envelope, autoIndex, index, &time, &value, &shape, &tension, &selected );
	    }	

	    EnvelopePoint(int i)   // Gets Specified Envelope Point of Selected Envelope
            : envelope(GetSelectedEnvelope(0)), autoIndex(-1), index(i), time(0), value(0), shape(0), tension(0), selected(true), noSort(false)
        {
            //if (!CountEnvelopePointsEx(envelope, autoIndex)) InsertEnvelopePointEx(envelope, autoIndex, time, value, shape, tension, selected, &noSort);  
            // else 
			GetEnvelopePointEx(envelope, autoIndex, index, &time, &value, &shape, &tension, &selected );
	    }	

	    EnvelopePoint(TrackEnvelope* e, int i) // Gets Specified Point Index of Specified Envelope
            : envelope(e), autoIndex(-1), index(i), time(0), value(0), shape(0), tension(0), selected(true), noSort(false)
        {
            // if (!CountEnvelopePointsEx(envelope, autoIndex)) InsertEnvelopePointEx(envelope, autoIndex, time, value, shape, tension, selected, &noSort);  
            // else 
			GetEnvelopePointEx(envelope, autoIndex, index, &time, &value, &shape, &tension, &selected );
	    }	

	    EnvelopePoint(TrackEnvelope* e, int i, int j)  // Get Specified Index of Specified Envelope of Specified Automation Item
            : envelope(e), autoIndex(i), index(j), time(0), value(0), shape(0), tension(0), selected(true), noSort(false)
        {
            // if (!CountEnvelopePointsEx(envelope, autoIndex)) InsertEnvelopePointEx(envelope, autoIndex, time, value, shape, tension, selected, &noSort);  
            // else 
			GetEnvelopePointEx(envelope, autoIndex, index, &time, &value, &shape, &tension, &selected );
	    }	

        // EnvelopePoint(TrackEnvelope* e, int i, double t, double v)
        //     : envelope(e), autoIndex(i), index(0), time(t), value(v), shape(0), tension(0), selected(true), noSort(false)
        // {
        //     if (!CountEnvelopePointsEx(envelope, autoIndex)) InsertEnvelopePointEx(envelope, autoIndex, time, value, shape, tension, selected, &noSort);  
        //     else GetEnvelopePointEx(envelope, autoIndex, index, &time, &value, &shape, &tension, &selected );
	    // }	








		//InsertEnvelopePointEx(envelope, -1, curpos, val, 0, 0, 1, 0);



	    ~EnvelopePoint() 
        {
	        SetEnvelopePointEx(envelope, autoIndex, index, &time, &value, &shape, &tension, &selected, &noSort);	
	    }
};

void CreateNewEnvChunk(char* &chunkname) {

	strcat(chunkname, "\nEGUID ");

	GUID g;
	genGuid(&g);
	char guid[64];
	guidToString(&g, guid);

	strcat(chunkname, guid);


	const char* envChunk = "\n\
	ACT 1 -1\n\
	VIS 1 1 1\n\
	LANEHEIGHT 0 0\n\
	ARM 0\n\
	DEFSHAPE 0 -1 -1\n\
	VOLTYPE 1\n\
	PT 0 1 0\n\
	>\n";
	strcat(chunkname, envChunk);
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
void TJF_HideAllTakeEnvelopes() {  // Hides all take envelopes for all items
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
void TJF_HideAllTrackEnvelopes() {
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

void HideEnvelopes(MediaItem* item) {  // Hides take envelopes for just the item submitted
		char str[ChunkSize];
		char* result = str;
		GetItemStateChunk(item, str, ChunkSize, false);

		while ((result = std::strstr(result, "VIS ")) != nullptr) {
			result +=4;
			*result = 48;
		} 
		SetItemStateChunk(item, str, true);
}
void HideEnvelopes(std::vector<MediaItem*> &items) {  // Hides take envelopes for just the item submitted
	for (MediaItem* item : items) {
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
void HideEnvelopes(MediaTrack* track) {
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
void HideEnvelopes(std::vector<MediaTrack*> tracks) {
		for (MediaTrack* track : tracks) {
			
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

bool GetEnvelopeVis(TrackEnvelope* envelope) {
	char str[ChunkSize];
	char* result = str;
	GetEnvelopeStateChunk(envelope, str, ChunkSize, false);
	result = strstr(str, "VIS ");
	result += 4;
	if (*result == 49) return true;
	return false;
}
void SetEnvelopeVis(TrackEnvelope* envelope, bool vis) {
	char str[ChunkSize];
	char* result = str;
	GetEnvelopeStateChunk(envelope, str, ChunkSize, false);
	result = strstr(str, "VIS ");
	result += 4;
	*result = 48 + vis;
	SetEnvelopeStateChunk(envelope, str, false);
}

bool IsAnyTakeEnvVisible(const char* name) {   // name is envelope to check ("Volume", "Pan", or "Pitch")
	for (int i = 0; i < CountSelectedMediaItems(0); i++) {
		TrackEnvelope* env = GetTakeEnvelopeByName(GetActiveTake(GetSelectedMediaItem(0,i)), name);
		if (env && GetEnvelopeVis(env)) return true;
	}
	return false;
}
bool IsAnyTrackEnvVisible(const char* name) {   // name is envelope to check ("Volume", "Pan", or "Pitch")
	for (int i = 0; i < CountSelectedTracks(0); i++) {
		TrackEnvelope* env = GetTrackEnvelopeByName(GetSelectedTrack(0,i), name);
		if (env && GetEnvelopeVis(env)) return true;
	}
	return false;
}

void AddTakeEnvelope(const char* &name) {
	if (!strcmp(name, "Volume")) Main_OnCommand(40693,0);  //toggle Take Volume
	else if (!strcmp(name, "Pan")) Main_OnCommand(40694,0);
	else if (!strcmp(name, "Pitch")) Main_OnCommand(41612,0);

}
void AddTrackEnvelope(const char* &name) {
	if (!strcmp(name, "Volume")) Main_OnCommand(40406,0);  //Selecct Take Volume
	else if (!strcmp(name, "Volume (Pre-FX)")) Main_OnCommand(40408,0);
	else if (!strcmp(name, "Pan")) Main_OnCommand(40407,0);
	else if (!strcmp(name, "Pan (Pre-FX)")) Main_OnCommand(40409,0);

}

void ToggleEnvelopes(std::vector<MediaItem*> &items, const char* name) {

	bool visible = false;
	TrackEnvelope* env;

	for (auto &item : items) {
		env = GetTakeEnvelopeByName(GetActiveTake(item), name);
		if (env) {
			SetMediaItemSelected(item, false);
			if (!visible && GetEnvelopeVis(env)) visible = true;
		}
	}

	if (CountSelectedMediaItems(0)) AddTakeEnvelope(name);

	for (auto &item : items) {
			SetMediaItemSelected(item, true);					
			HideEnvelopes(item);
			env = GetTakeEnvelopeByName(GetActiveTake(item), name);
			if (env) SetEnvelopeVis(env, !visible);
	}

	if (items.size() == 1) SetCursorContext( 2, env); // selects envelope

}
void ToggleEnvelopes(std::vector<MediaTrack*> &tracks, const char* name) {

	bool visible = false;
	TrackEnvelope* env;

	for (auto &track : tracks) {
		env = GetTrackEnvelopeByName(track, name);
		if (env) {
			SetTrackSelected(track, false);
			if (!visible && GetEnvelopeVis(env)) visible = true;
		}
	}

	if (CountSelectedTracks(0)) AddTrackEnvelope(name);

	for (auto &track : tracks) {
			SetTrackSelected(track, true);					
			HideEnvelopes(track);
			env = GetTrackEnvelopeByName(track, name);
			if (env) SetEnvelopeVis(env, !visible);
	}

}

void TJF_ToggleVolumeEnvelopes() {
	std::vector<MediaItem *> items;
	GetSelected(items);
	if (items.size()) {ToggleEnvelopes(items, "Volume"); return;}

	std::vector<MediaTrack *> tracks;
	GetSelected(tracks);
	if (tracks.size()) {ToggleEnvelopes(tracks, "Volume"); return;}
}
void TJF_ToggleVolumeEnvelopes2() {
	std::vector<MediaItem *> items;
	GetSelected(items);
	if (items.size()) {ToggleEnvelopes(items, "Volume"); return;}

	std::vector<MediaTrack *> tracks;
	GetSelected(tracks);
	if (tracks.size()) {ToggleEnvelopes(tracks, "Volume (Pre-FX)"); return;}
}
void TJF_TogglePanEnvelopes() {
	std::vector<MediaItem *> items;
	GetSelected(items);
	if (items.size()) {ToggleEnvelopes(items, "Pan"); return;}

	std::vector<MediaTrack *> tracks;
	GetSelected(tracks);
	if (tracks.size()) {ToggleEnvelopes(tracks, "Pan"); return;}
}
void TJF_TogglePanEnvelopes2() {
	std::vector<MediaItem *> items;
	GetSelected(items);
	if (items.size()) {ToggleEnvelopes(items, "Pan"); return;}

	std::vector<MediaTrack *> tracks;
	GetSelected(tracks);
	if (tracks.size()) {ToggleEnvelopes(tracks, "Pan (Pre-FX)"); return;}
}
void TJF_ToggleMuteEnvelopes() {
	std::vector<MediaItem *> items;
	GetSelected(items);
	if (items.size()) {ToggleEnvelopes(items, "Mute"); return;}

	std::vector<MediaTrack *> tracks;
	GetSelected(tracks);
	if (tracks.size()) {ToggleEnvelopes(tracks, "Mute"); return;}
}
void TJF_TogglePitchEnvelopes() {
	std::vector<MediaItem *> items;
	GetSelected(items);
	if (items.size()) {ToggleEnvelopes(items, "Pitch"); return;}
}


void ShowAndUpdateLastTouchedFXTrack(int& tracknum, int& fxnum, int& paramnum) {
	MediaTrack* track = GetTrack(0, tracknum-1);
	double minvalOut, maxvalOut;
	static double val;
	double fxvalue = TrackFX_GetParam(track, fxnum, paramnum, &minvalOut, &maxvalOut);
	if (val == fxvalue) return;
	val = fxvalue;
	static double curpos = GetCursorPosition();
	double cp = GetCursorPosition();
	if (cp != curpos) {
		curpos = cp;
		return;
	}

	TrackEnvelope* envelope = GetFXEnvelope( track, fxnum, paramnum, true );
	static int numpoints = CountEnvelopePoints(envelope);
	int np = CountEnvelopePoints(envelope);
	if (np != numpoints) {
		numpoints = np;
		return;
	}

	HideEnvelopes(track);
	SetEnvelopeVis(envelope, true);
	SetCursorContext( 2, envelope );

	if (numpoints > 1) {
		DeleteEnvelopePointRangeEx(envelope, -1, curpos - .005, curpos + .005 );
		InsertEnvelopePointEx(envelope, -1, curpos, val, 0, 0, 1, 0);
		return;
	}

    EnvelopePoint e(envelope);
    e.value = val;

}
void ShowAndUpdateLastTouchedFXTake(int& tracknum, int& fxnum, int& paramnum) {
	MediaTrack* track = CSurf_TrackFromID((tracknum & 0xFFFF), false);
    int takenumber = (fxnum >> 16);
    fxnum = (fxnum & 0xFFFF);
	int item_index = (tracknum >> 16)-1;
    MediaItem* item = GetTrackMediaItem(track, item_index);
	double itemStart = GetMediaItemInfo_Value(item, "D_POSITION");
	double itemEnd = itemStart + GetMediaItemInfo_Value(item, "D_LENGTH");

    MediaItem_Take* take = GetTake(item, takenumber);

	double minvalOut, maxvalOut;
	static double val;
	double fxvalue = TakeFX_GetParam(take, fxnum, paramnum, &minvalOut, &maxvalOut);
	if (val == fxvalue) return;
	val = fxvalue;

	static double curpos = GetCursorPosition();
	double cp = GetCursorPosition();
	if (cp != curpos) {
		curpos = cp;
		return;
	}

	TrackEnvelope* envelope = TakeFX_GetEnvelope( take, fxnum, paramnum, true );

	static int numpoints = CountEnvelopePoints(envelope);
	int np = CountEnvelopePoints(envelope);
	if (np != numpoints) {
		numpoints = np;
		return;
	}

	HideEnvelopes(item);
	SetEnvelopeVis(envelope, true);
	SetCursorContext( 2, envelope );

	if (numpoints > 1) {
	 	if (curpos > itemStart && curpos < itemEnd) {
			DeleteEnvelopePointRangeEx(envelope, -1, curpos - itemStart - .005, curpos - itemStart + .005 );
			InsertEnvelopePointEx(envelope, -1, curpos - itemStart, val, 0, 0, 1, 0);
		 }
		return;
	}

	if (!numpoints) InsertEnvelopePointEx(envelope, -1, 0, val, 0, 0, 1, 0);   
    EnvelopePoint e(envelope, 0);
    e.value = val;
}
void TJF_AutoDisplayLastTouchedEnvelope() {

	 static int tracknum, fxnum, paramnum;
	 if (GetLastTouchedFX(&tracknum, &fxnum, &paramnum )) {
		if (tracknum >> 16) ShowAndUpdateLastTouchedFXTake(tracknum, fxnum, paramnum);
		else ShowAndUpdateLastTouchedFXTrack(tracknum, fxnum, paramnum);
	 }
}


void ToggleLastTouchedFXTake(int& tracknum, int& fxnum, int& paramnum) {
	MediaTrack* track = CSurf_TrackFromID((tracknum & 0xFFFF), false);
    int takenumber = (fxnum >> 16);
    fxnum = (fxnum & 0xFFFF);
	int item_index = (tracknum >> 16)-1;
    MediaItem* item = GetTrackMediaItem(track, item_index);
    MediaItem_Take* take = GetTake(item, takenumber);

	bool vis = true;
	TrackEnvelope* envelope = TakeFX_GetEnvelope( take, fxnum, paramnum, false );
	if (envelope) vis = !GetEnvelopeVis(envelope);
	else envelope = TakeFX_GetEnvelope( take, fxnum, paramnum, true );
	HideEnvelopes(item);
	SetEnvelopeVis(envelope, true);
	if (!vis) SetCursorContext( 2, envelope );
}
void ToggleLastTouchedFXTrack(int& tracknum, int& fxnum, int& paramnum) {
	MediaTrack* track = GetTrack(0, tracknum-1);
	bool vis = true;
	TrackEnvelope* envelope = GetFXEnvelope( track, fxnum, paramnum, false );
	if (envelope) vis = !GetEnvelopeVis(envelope);
	else envelope = GetFXEnvelope( track, fxnum, paramnum, true);
	HideEnvelopes(track);
	SetEnvelopeVis(envelope, vis);
	if (vis) SetCursorContext( 2, envelope );
}
void TJF_ToggleLastTouchedFXEnvelope() {

	 static int tracknum, fxnum, paramnum;
	 if (GetLastTouchedFX(&tracknum, &fxnum, &paramnum )) {
		if (tracknum >> 16) ToggleLastTouchedFXTake(tracknum, fxnum, paramnum);
		else ToggleLastTouchedFXTrack(tracknum, fxnum, paramnum);
	 }
 }



void GetItemsInRange(MediaTrack* &track, double &areaStart, double &areaEnd, std::vector<MediaItem*> &items) {
	for (int j = 0; j < CountTrackMediaItems(track); j++) {
		Item i(GetTrackMediaItem(track, j));
		if (i.end < areaStart or  i.start > areaEnd) continue;
		items.push_back(i.item);
	}


}



