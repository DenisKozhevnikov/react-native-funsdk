import React, {
  forwardRef,
  useEffect,
  useImperativeHandle,
  useRef,
  useState,
} from 'react';
import { StyleSheet, TouchableOpacity } from 'react-native';
import { Monitor, STREAM_TYPE } from 'react-native-funsdk';
import { monitorsList } from '..';

type Props = {
  devId: string;
  channelId: number;
  isActive: boolean;
  onPress: () => void;
};

export const MonitorView = forwardRef<
  {
    monRef: React.RefObject<Monitor>;
  },
  Props
>(({ devId, channelId, isActive, onPress }, ref) => {
  const monRef = useRef<Monitor>(null);

  useImperativeHandle(ref, () => ({
    monRef,
  }));

  useEffect(() => {
    monitorsList.set(channelId, monRef);
  }, [channelId]);

  useEffect(() => {
    monRef.current?.playVideo();
  }, []);

  // useEffect(() => {
  //   monRef.current?.stopVideo();
  //   monRef.current?.playVideo();
  // }, [isActive]);

  const [width, setWidth] = useState(200);
  const [height, setHeight] = useState((200 / 16) * 9);

  useEffect(() => {
    setTimeout(() => {
      setWidth(300);
      setHeight((300 / 16) * 9);
    }, 3000);
  }, []);
  // console.log('devId: ', devId);
  return (
    <TouchableOpacity
      onPress={onPress}
      // onPress={() => setActiveChannel(0)}
      style={{
        padding: 5,
        backgroundColor: isActive ? 'red' : 'transparent',
        width,
        height,
        // backgroundColor: activeChannel === 0 ? 'red' : 'transparent',
      }}
    >
      <Monitor
        devId={devId}
        channelId={channelId}
        streamType={STREAM_TYPE.EXTRA}
        style={styles.monitor}
        ref={monRef}
        // onLayout={(event) => console.log('event: ', event.nativeEvent)}
        onStartInit={() => console.log(`START INIT ${channelId} CAMERA`)}
        onMediaPlayState={(obj) => console.log('onMediaPlayState: ', obj)}
        onShowRateAndTime={(obj) => console.log('onShowRateAndTime: ', obj)}
        onVideoBufferEnd={(obj) => console.log('onVideoBufferEnd: ', obj)}
        onGetInfo={(obj) => console.log(obj)}
        onFailed={(obj) => console.log('onFailed: ', obj)}
        onCapture={(obj) => console.log('onCapture: ', obj)}
        onDebugState={(obj) => console.log('onDebugState: ', obj)}
      />
    </TouchableOpacity>
  );
});

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'pink',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
    padding: 20,
  },
  monitor: {
    width: '100%',
    aspectRatio: 16 / 9,
    backgroundColor: 'yellow',
  },
  button: {
    // width: 100,
    // height: 50,
    margin: 10,
    padding: 10,
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'green',
  },
  buttonText: {
    color: 'white',
  },
  view: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
  },
});
