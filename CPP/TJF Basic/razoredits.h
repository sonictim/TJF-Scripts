#pragma once

#include <vector>
#include "TJF.h"

struct RazorEdit {
	MediaTrack* track;
	int areaStart;
	int areaEnd;
	char* GUID;
	bool isEnvelope;
	std::vector<MediaItem*> items;		
};


void GetRazorEditTracks(std::vector<MediaTrack*>& v) {
        v.clear();
        for (int i=0; i < CountTracks(0); i++) {
                MediaTrack* track = GetTrack(0,i);
                std::string str = (char*)GetSetMediaTrackInfo(track, "P_RAZOREDITS_EXT", NULL);
                if (str.size()) v.push_back(track);
        }
}


static void CopyRazorEdit(MediaTrack* source, MediaTrack* dest) {
    char* str = (char*)GetSetMediaTrackInfo(source, "P_RAZOREDITS_EXT", NULL);
    GetSetMediaTrackInfo(dest, "P_RAZOREDITS", (void*)str);
}

static void CopyRazorEdit(MediaTrack* source, std::vector<MediaTrack*> &dest) {
    char* str = (char*)GetSetMediaTrackInfo(source, "P_RAZOREDITS_EXT", NULL);
    for (auto &x : dest) GetSetMediaTrackInfo(x, "P_RAZOREDITS_EXT", (void*)str);
}


//Link Razor Edits to Folders::::::::::::;

static MediaTrack* GetParent(MediaTrack* track) {
    //if (GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH") == 1) return track;
    if (GetTrackDepth(track) > 0) return GetParentTrack(track);
    return track;
} 


static void GetChildren(MediaTrack*& parent, std::vector<MediaTrack*>& children) {
        int parentDepth = GetTrackDepth(parent);
        int ParentNumber = GetMediaTrackInfo_Value(parent, "IP_TRACKNUMBER");

        for (int i = ParentNumber; i < CountTracks(0); i++) {
                MediaTrack* track = GetTrack(0,i);
                int depth = GetTrackDepth(track);
                if (depth <= parentDepth) break;
                children.push_back(track);
        }
}

void TJF_LinkRazorEditToFolders() {
    //THESE MAKE IT HAPPEN LESS
        /*static int change =  GetProjectStateChangeCount(0);
        if (change == GetProjectStateChangeCount(0)) return;
        change = GetProjectStateChangeCount(0);
        
        if (Undo_CanUndo2(0) == NULL) return;
        std::string str = Undo_CanUndo2(0);
        for (auto &c : str) c = tolower(c);
        if (str.find("folder") == std::string::npos && str.find("razor") == std::string::npos) return;
        */

    //PreventUIRefresh(1);
        int check = GetToggleCommandState(1156); // check if grouping is enabled
        for (int i=0; i < CountTracks(0); i++) {
                MediaTrack* track = GetTrack(0,i);
                std::string str = (char*)GetSetMediaTrackInfo(track, "P_RAZOREDITS_EXT", NULL);
                if (str.size()) {
                    MediaTrack* parent = track;
                    if (check) parent = GetParent(track);
                    std::vector<MediaTrack*> children;
                    GetChildren(parent, children);
                    CopyRazorEdit(track, children);
                }
        }
    //PreventUIRefresh(-1);
}



/*
void GetSelectedTracks(std::vector<MediaTrack*>& v) {
    v.clear();
    for (int i=0; i < CountTracks(0); i++) {
        MediaTrack* track = GetTrack(0,i);
        if (IsTrackSelected(track)) v.push_back(track);
    }
}


void GetFirstRazorEditString(std::string& s) {
        for (int i=0; i < CountTracks(0); i++) {
            MediaTrack* track = GetTrack(0,i);
            s = (const char*)GetSetMediaTrackInfo(track, "P_RAZOREDITS_EXT", NULL);
            if (s.size()) return;
        }
}

MediaTrack* GetFirstRazorEditTrack() {
        MediaTrack* track;
        for (int i=0; i < CountTracks(0); i++) {
            track = GetTrack(0,i);
            std::string s = (const char*)GetSetMediaTrackInfo(track, "P_RAZOREDITS_EXT", NULL);
            if (s.size()) return track;
        }
        return track;
}
*/
void TJF_LinkTrackandEditSelection() {
    
    
    static std::vector<MediaTrack*> tracks;
    std::vector<MediaTrack*> curTracks;
    GetSelectedTracks(curTracks);




    if (tracks != curTracks && current.size()) {

        tracks = curTracks;
                msg("GO");

        char* str = (char*)GetSetMediaTrackInfo(current[0], "P_RAZOREDITS_EXT", NULL);
        for (int i=0; i < CountTracks(0); i++) {
            MediaTrack* track = GetTrack(0,i);
            if (IsTrackSelected(track)) GetSetMediaTrackInfo(track, "P_RAZOREDITS", (void*)str);
            else GetSetMediaTrackInfo(track, "P_RAZOREDITS", (void*)"");
        }
        return;
    }
    

    static std::vector<MediaTrack*> REtracks;
    std::vector<MediaTrack*> currentRE;
    GetRazorEditTracks(currentRE);

    if (REtracks != currentRE) {
        REtracks = currentRE;
        if (REtracks.size())  {
            for (int i=0; i < CountTracks(0); i++) {
                MediaTrack* track = GetTrack(0,i);
                std::string str = (const char*)GetSetMediaTrackInfo(track, "P_RAZOREDITS_EXT", NULL);
                SetTrackSelected(track, str.size());
            }
            Main_OnCommand(40914, 0); // Track: Set first selected track as last touched track
            return;
        }
    }

    static std::vector<MediaItem*> items;
    std::vector<MediaItem*> currentItems;
    for (int i=0; i < CountSelectedMediaItems(0); i++)  currentItems.push_back(GetSelectedMediaItem(0,i));

    static MediaTrack* firstItemTrack = GetMediaItem_Track(GetSelectedMediaItem(0,0));
    MediaTrack* currentFIT = GetMediaItem_Track(GetSelectedMediaItem(0,0)); 

    
    if (items != currentItems || firstItemTrack != currentFIT) {
        items = currentItems;
        firstItemTrack = currentFIT;

        for (int i=0; i < CountTracks(0); i++) SetTrackSelected(GetTrack(0,i), false); //unselect all tracks
        if (items.size()) for (int i=0; i < items.size(); i++) SetTrackSelected(GetMediaItem_Track(items[i]), true); //select tracks with selected items
        Main_OnCommand(40914, 0); // Track: Set first selected track as last touched track
        return;
    }
}






/*
std::vector<RazorEdit> GetRazorEdits() 
{
    std::vector<RazorEdit> areaMap;
    for (int i = 0; i < CountTracks(); i++) {

    }
        auto track = GetTrack(0, i)


        std::string area = (const char*)GetSetMediaTrackInfo(track, "P_RAZOREDITS", NULL);
        if (area != "") {
            //PARSE STRING
            local str = {}
            for j in string.gmatch(area, "%S+") do
                table.insert(str, j)
            }
        
            //FILL AREA DATA
            local j = 1
            while j <= #str do
                //area data
                local areaStart = tonumber(str[j])
                local areaEnd = tonumber(str[j+1])
                local GUID = str[j+2]
                local isEnvelope = GUID ~= '""'
    
                //get item data
                local items = {}
                if not isEnvelope then
                    local itemCount = reaper.CountTrackMediaItems(track)
                    for k = 0, itemCount - 1 do 
                        local item = reaper.GetTrackMediaItem(track, k)
                        local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
                        local length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
                        local itemEndPos = pos+length
    
                        //check if item is in area bounds
                        if (itemEndPos > areaStart and itemEndPos <= areaEnd) or
                            (pos >= areaStart and pos < areaEnd) or
                            (pos <= areaStart and itemEndPos >= areaEnd) then
                                table.insert(items,item)
                        end
                    end
                end
    
                local areaData = {
                    areaStart = areaStart,
                    areaEnd = areaEnd,
                    track = track,
                    items = items,
                    isEnvelope = isEnvelope,
                    GUID = GUID
                }
    
                 table.insert(areaMap, areaData)
    
                j = j + 3
            end
        end
    }
    
    return areaMap
end

	

}



bool isRazorEdit() {
		for (int i=0; i < reaper.CountTracks(0); i++) {
			if (GetSetMediaTrackInfo_String(GetTrack(0, i), "P_RAXOREDITS_EXT", char* string, false ))
				return true;		
		}
		return false;
}

*/