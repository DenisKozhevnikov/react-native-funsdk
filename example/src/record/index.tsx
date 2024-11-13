import React, { useRef, useState } from 'react';
import { StyleSheet, View, Text, ScrollView } from 'react-native';
import {
  RecordPlayer,
  RecordPlayerRef,
  SearchDeviceFilesByDateItemResponse,
} from 'react-native-funsdk';
import { RecordList } from './list';
import { RecordButtons } from './buttons';
import { DEVICE_ID } from '../topsecret';
// import { useInit } from '../init';

export const RecordPage = () => {
  // return null;
  const playerRef = useRef<RecordPlayerRef>(null);

  const [recordList, setRecordList] = React.useState<
    SearchDeviceFilesByDateItemResponse[] | null
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

  return (
    <View style={styles.container}>
      <RecordPlayer
        ref={playerRef}
        style={styles.monitor}
        devId={DEVICE_ID}
        channelId={0}
        onMediaPlayState={(ev) => console.log('onMediaPlayState: ', ev)}
        onShowRateAndTime={(ev) => console.log('onShowRateAndTime: ', ev)}
        onVideoBufferEnd={(ev) => console.log('onVideoBufferEnd: ', ev)}
        // onSearchRecordByFilesResult={(ev) => {
        //   console.log('onSearchRecordByFilesResult ', ev?.list?.length);
        //   if (ev?.list) {
        //     setRecordList(ev?.list);
        //   }
        // }}
        onFailed={(obj) => console.log('onFailed: ', obj)}
        onStartInit={(obj) => console.log('onStartInit: ', obj)}
        onDebugState={(obj) => console.log('DEBUG STATE: ', obj)}
      />
      <ScrollView horizontal style={styles.timelineScrollview}>
        {timeline?.map((minute, index) => {
          return (
            <View
              key={index}
              style={[
                styles.timelineMinute,
                {
                  backgroundColor: getColorByStatus(minute),
                },
              ]}
            />
          );
        })}
      </ScrollView>
      <RecordButtons
        playerRef={playerRef.current}
        setTimeline={setTimeline}
        setRecordList={setRecordList}
      />
      <Text>list of recordlist</Text>
      <RecordList recordList={recordList} playerRef={playerRef.current} />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: 130,
    paddingHorizontal: 8,
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
  timelineMinute: {
    width: 1,
    height: '100%',
  },
  timelineScrollview: {
    flexGrow: 0,
    flexShrink: 0,
    // padding: 10,
    height: 40,
    backgroundColor: 'red',
  },
});
