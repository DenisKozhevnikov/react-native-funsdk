#pragma once
#import <FunSDK/JObject.h>

#define JK_AudioConfigOutput "fVideo.Volume"
class AudioConfigOutput : public JObject
{
public:
	JStrObj		AudioMode;
	JIntObj		LeftVolume;
	JIntObj		RightVolume;

public:
    AudioConfigOutput(JObject *pParent = NULL, const char *szName = JK_AudioConfigOutput):
    JObject(pParent,szName),
	AudioMode(this, "AudioMode"),
	LeftVolume(this, "LeftVolume"),
	RightVolume(this, "RightVolume"){
	};

    ~AudioConfigOutput(void){};
};
