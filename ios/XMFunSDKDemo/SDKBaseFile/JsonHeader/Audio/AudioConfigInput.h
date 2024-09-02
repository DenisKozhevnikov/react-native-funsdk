#pragma once
#import <FunSDK/JObject.h>

#define JK_AudioConfigInput "fVideo.InVolume"
class AudioConfigInput : public JObject
{
public:
	JStrObj		AudioMode;
	JIntObj		LeftVolume;
	JIntObj		RightVolume;

public:
    AudioConfigInput(JObject *pParent = NULL, const char *szName = JK_AudioConfigInput):
    JObject(pParent,szName),
	AudioMode(this, "AudioMode"),
	LeftVolume(this, "LeftVolume"),
	RightVolume(this, "RightVolume"){
	};

    ~AudioConfigInput(void){};
};
