#pragma once

#include <vector>


struct RazorEdit {
	MediaTrack* track;
	int areaStart;
	int areaEnd;
	char* GUID;
	bool isEnvelope;
	std::vector<MediaItem*> items;		
};


std::vector<RE> GetRazorEdits() {
		

}





bool isRazorEdit() {
		for (int i=0; i < reaper.CountTracks(0); i++) {
			if (GetSetMediaTrackInfo_String(GetTrack(0, i), "P_RAXOREDITS_EXT", char* string, false ))
				return true;		
		}
		return false;
}

