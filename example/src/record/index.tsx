import React, { useRef, useState } from 'react';
import { StyleSheet, View, Text, ScrollView } from 'react-native';
import {
  RecordPlayer,
  SearcResultRecordFile,
  RecordPlayerRef,
  // hasLogin,
} from 'react-native-funsdk';
import { RecordList } from './list';
import { RecordButtons } from './buttons';
import { DEVICE_ID } from '../topsecret';
// import { useInit } from '../init';

export const RecordPage = () => {
  const playerRef = useRef<RecordPlayerRef>(null);

  // useInit();

  const [recordList, setRecordList] = React.useState<
    SearcResultRecordFile[] | null
  >(null);

  const [timeline, setTimeline] = useState<number[] | null>(null);

  const getColorByStatus = (status: number) => {
    if (status === 1) {
      return 'blue';
    }
    if (status === 2) {
      return 'yellow';
    }
    if (status === 3) {
      return 'green';
    }
    if (status === 4) {
      return 'pink';
    }
    return 'black';
  };

  console.log(
    'recordList: ',
    recordList?.length,
    recordList?.map((record) => record.startTimeOfYear)
  );

  return (
    <View style={styles.container}>
      <RecordPlayer
        ref={playerRef}
        style={styles.monitor}
        devId={DEVICE_ID}
        channelId={1}
        onMediaPlayState={(ev) => console.log('onMediaPlayState: ', ev)}
        onShowRateAndTime={(ev) => console.log('onShowRateAndTime: ', ev)}
        onVideoBufferEnd={(ev) => console.log('onVideoBufferEnd: ', ev)}
        onSearchRecordByFilesResult={(ev) => {
          console.log('onSearchRecordByFilesResult ', ev?.list?.length);
          if (ev?.list) {
            setRecordList(ev?.list);
          }
        }}
        onFailed={(obj) => console.log('onFailed: ', obj)}
        onStartInit={() => console.log('onStartInit: ')}
        onDebugState={(obj) => console.log('DEBUG STATE: ', obj)}
      />
      <ScrollView
        horizontal
        style={{
          flexGrow: 0,
          flexShrink: 0,
          // padding: 10,
          height: 40,
          backgroundColor: 'red',
        }}
      >
        {timeline?.map((minute, index) => {
          return (
            <View
              key={index}
              style={{
                width: 1,
                height: '100%',
                // backgroundColor: `#${minute}${minute}${minute}${minute}${minute}${minute}`,
                backgroundColor: getColorByStatus(minute),
              }}
            />
          );
        })}
      </ScrollView>
      <RecordButtons playerRef={playerRef.current} setTimeline={setTimeline} />
      <Text>list of recordlist</Text>
      <RecordList recordList={recordList} playerRef={playerRef.current} />
    </View>
  );
};

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
    // height: 200,
    aspectRatio: 16 / 9,
    // backgroundColor: 'yellow',
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
