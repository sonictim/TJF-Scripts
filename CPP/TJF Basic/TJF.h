#pragma once

#include <iostream>


void msg(const char* c) {
    ShowConsoleMsg(c);
    ShowConsoleMsg("\n");
}

void msg(std::string s) {
    const char* c = s.c_str();
    ShowConsoleMsg(c);
    ShowConsoleMsg("\n");
}


template <typename T>
void msg(T x) {
    std::string tmp = std::to_string(x);
    const char* c = tmp.c_str();
    ShowConsoleMsg(c);
    ShowConsoleMsg("\n");
}


//  TEMPLATES FOR GET / SET MEDIA ITEM/TAKE/TRACK properties (alternative to GetMediaItemInfo_Value)
//	usage:  double item_length=get_property<double>(item,"D_LENGTH");

template<typename T>
T GetProperty(MediaItem* item,const char* propname,T defval=T())
{
    static_assert(!std::is_pointer<T>::value,"do not use this function with pointer properties");
    void* temp=GetSetMediaItemInfo(item,propname,nullptr);
    if (temp==nullptr)
        return defval;
    return *(T*)temp;
}

template<typename T>
void SetProperty(MediaItem* item, const char* propname,T value)
{
    GetSetMediaItemInfo(item,propname,&value);
}



template<typename T>
T GetProperty(MediaItem_Take* take,const char* propname,T defval=T())
{
    static_assert(!std::is_pointer<T>::value,"do not use this function with pointer properties");
    void* temp=GetSetMediaItemTakeInfo(take,propname,nullptr);
    if (temp==nullptr)
        return defval;
    return *(T*)temp;
}

template<typename T>
void SetProperty(MediaItem_Take* take, const char* propname,T value)
{
    GetSetMediaItemTakeInfo(take,propname,&value);
}



template<typename T>
T GetProperty(MediaTrack* track,const char* propname,T defval=T())
{
    static_assert(!std::is_pointer<T>::value,"do not use this function with pointer properties");
    void* temp=GetSetMediaTrackInfo(track,propname,nullptr);
    if (temp==nullptr)
        return defval;
    return *(T*)temp;
}

template<typename T>
void SetProperty(MediaTrack* track, const char* propname,T value)
{
    GetSetMediaTrackInfo(track,propname,&value);
}

/////EXAMPLE FUNCTION WITH DIFFERNT TYPES OF CALLS
/*
void TJF_ReverseFadesWithItem() { // This shows how to use GetSetMediaItemInfo with casting... tougher, but interested
		PreventUIRefresh(1);
		Undo_BeginBlock();


      	int itemcount = CountSelectedMediaItems(0);
      	if (!itemcount) return;
		for (int i = 0; i < itemcount; i++) {
			auto item = GetSelectedMediaItem(0,i);
			
			double* inPtr = (double*)GetSetMediaItemInfo(item, "D_FADEINLEN", NULL);
			double* outPtr = (double*)GetSetMediaItemInfo(item, "D_FADEOUTLEN", NULL);
			GetSetMediaItemInfo(item, "D_FADEINLEN", outPtr);
			GetSetMediaItemInfo(item, "D_FADEOUTLEN", inPtr);

			double temp = GetProperty<double>(item, "D_FADEINDIR");
            SetProperty(item,"D_FADEINDIR", GetProperty<double>(item, "D_FADEOUTDIR") );
            SetProperty(item,"D_FADEOUTDIR", temp);

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

*/