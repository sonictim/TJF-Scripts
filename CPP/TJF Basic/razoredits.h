#pragma once

#include <vector>
#include "TJF.h"


struct RazorEdit {
	MediaTrack* track;
	double start;
	double end;
	const char* GUID;
    double top;
    double bottom;
	bool isEnvelope;
    //const char* envName;
	std::vector<MediaItem*> items;		
};


void GetTrackItemsInRange(MediaTrack* track, double start, double end, std::vector<MediaItem*>& items) {
    for (int j=0; j < CountTrackMediaItems(track); j++) {
                    auto item = GetTrackMediaItem(track, j);
                    auto iStart = GetMediaItemInfo_Value(item, "D_POSITION");
                    auto iEnd = iStart + GetMediaItemInfo_Value(item, "D_LENGTH");
                    
                    if  ((iEnd > start && iEnd <= end) || (iStart >= start && iStart < end) || (iStart <= start && iEnd >= end)) items.push_back(item);
    }



}

void GetRazorEdits(std::vector<RazorEdit>& RazorEdits) 
{
    RazorEdits.clear();
    for (int i = 0; i < CountTracks(0); i++) {
        auto track = GetTrack(0, i);
        char* area = (char*)GetSetMediaTrackInfo(track, "P_RAZOREDITS_EXT", NULL);
        if (!strlen(area)) continue;
        RazorEdit RE;
        RE.track = track;
        char* p;
        p=strtok(area, " ,");
        while (p!=NULL) {
            char* ptr;
            RE.start = strtod(p, &ptr);
            p = strtok(NULL, " ,");
            RE.end = strtod(p, &ptr);
            p = strtok(NULL, " ,");
            RE.GUID = p;
            RE.isEnvelope = strlen(p) > 2;
            p = strtok(NULL, " ,");
            RE.top = strtod(p, &ptr);
            p = strtok(NULL, " ,");
            RE.bottom = strtod(p, &ptr);
            std::vector<MediaItem*> items;
            if (!RE.isEnvelope) GetTrackItemsInRange(track, RE.start, RE.end, items);
            RE.items = items;
            RazorEdits.push_back(RE);
            p = strtok(NULL, " ,");

        }

    }
}




/*
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


*/

void GetRazorEditTracks(std::vector<MediaTrack*>& v) {
        v.clear();
        for (int i=0; i < CountTracks(0); i++) {
                MediaTrack* track = GetTrack(0,i);
                const char* str = (const char*)GetSetMediaTrackInfo(track, "P_RAZOREDITS_EXT", NULL);
                if (strlen(str)) v.push_back(track);
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

static void CopyRazorEdit(const char* str, std::vector<MediaTrack*> &dest) {
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

    PreventUIRefresh(1);
        int check = GetToggleCommandState(1156); // check if grouping is enabled
        for (int i=0; i < CountTracks(0); i++) {
                MediaTrack* track = GetTrack(0,i);
                const char* str = (const char*)GetSetMediaTrackInfo(track, "P_RAZOREDITS_EXT", NULL);
                if (strlen(str)) {
                    MediaTrack* parent = track;
                    if (check) parent = GetParent(track);
                    std::vector<MediaTrack*> children;
                    GetChildren(parent, children);
                    CopyRazorEdit(track, children);
                }
        }
    PreventUIRefresh(-1);
}







void TJF_LinkTrackandEditSelection() {

    
    static std::vector<MediaTrack*> REtracks;    
    std::vector<MediaTrack*> currentRE;
    GetRazorEditTracks(currentRE);

    static std::vector<MediaItem*> items;
    std::vector<MediaItem*> currentItems;
    for (int i=0; i < CountSelectedMediaItems(0); i++)  currentItems.push_back(GetSelectedMediaItem(0,i));

    static MediaTrack* firstItemTrack = GetMediaItem_Track(GetSelectedMediaItem(0,0));
    MediaTrack* currentFIT = GetMediaItem_Track(GetSelectedMediaItem(0,0));

    std::vector<MediaTrack*> curSelTracks;
    GetSelectedTracks(curSelTracks);   
    


    if (REtracks != currentRE) {
            for (int i=0; i < CountTracks(0); i++) {
                MediaTrack* track = GetTrack(0,i);
                const char* str = (const char*)GetSetMediaTrackInfo(track, "P_RAZOREDITS_EXT", NULL);
                SetTrackSelected(track, strlen(str));
            }

    }

    else if (curSelTracks != currentRE && currentRE.size() && curSelTracks.size()) {

        const char* str = (const char*)GetSetMediaTrackInfo(currentRE[0], "P_RAZOREDITS_EXT", NULL);
        CopyRazorEdit(str, curSelTracks);
        for (int i=0; i < CountTracks(0); i++)  if (!IsTrackSelected(GetTrack(0,i)))  GetSetMediaTrackInfo(GetTrack(0,i), "P_RAZOREDITS_EXT", (void*)"");

        REtracks = curSelTracks;
        return;

    }

    else if (!REtracks.size() && (items != currentItems || firstItemTrack != currentFIT)) {
        for (int i=0; i < CountTracks(0); i++) SetTrackSelected(GetTrack(0,i), false); //unselect all tracks
        if (currentItems.size()) for (int i=0; i < currentItems.size(); i++) SetTrackSelected(GetMediaItem_Track(currentItems[i]), true); //select tracks with selected items
    }

    SetFirstSelectedTrack();
    REtracks = currentRE;
    items = currentItems;
    firstItemTrack = currentFIT;


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