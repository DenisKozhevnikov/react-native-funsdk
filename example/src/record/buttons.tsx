import React from 'react';
import {
  StyleSheet,
  Text,
  TouchableOpacity,
  // ScrollView,
  View,
} from 'react-native';
import {
  RecordPlayerRef,
  getChannelCount,
  getChannelInfo,
} from 'react-native-funsdk';
import { DEVICE_ID } from '../topsecretdata';

const Button = ({ onPress, text }: { onPress: () => void; text: string }) => {
  return (
    <TouchableOpacity onPress={onPress} style={styles.button}>
      <Text style={styles.buttonText}>{text}</Text>
    </TouchableOpacity>
  );
};

export const RecordButtons = ({
  playerRef,
}: {
  playerRef: RecordPlayerRef | null;
}) => {
  const loadChannelsInfo = async () => {
    try {
      const info = await getChannelInfo({ deviceId: DEVICE_ID });
      console.log('channels info is: ', info);
    } catch (error) {
      console.log('loadChannelsInfo error: ', error);
    }
  };

  const loadChannelsCount = async () => {
    try {
      const count = await getChannelCount({ deviceId: DEVICE_ID });
      console.log('channels count is: ', count);
    } catch (error) {
      console.log('loadChannelCount error: ', error);
    }
  };

  const searchRecordByFile = () => {
    const hour = 60 * 60 * 1000;
    const day = hour * 24;

    const date = new Date();
    const timestamp = date.getTime();
    const timezoneOffset = date.getTimezoneOffset();
    const correctedTimestamp = timestamp + timezoneOffset * 1000 * 60;

    const start = correctedTimestamp - 10 * day;
    const end = correctedTimestamp - 9 * day;

    playerRef?.searchRecordByFile(start, end);
  };

  const openVoice = () => {
    playerRef?.openVoice();
  };

  const closeVoice = () => {
    playerRef?.closeVoice();
  };

  const pause = () => {
    playerRef?.pausePlay();
  };

  const rePlay = () => {
    playerRef?.rePlay();
  };

  const testFunc = () => {
    // playerRef.;
  };
  // const updateSpeed = (speed: number) => {
  //   playerRef?.setPlaySpeed(speed);
  // };

  return (
    // <ScrollView
    //   style={{
    //     backgroundColor: '#EFEFEF',
    //     flex: 1,
    //   }}
    // >
    <View style={styles.view}>
      <Button text="loadChannelsCount" onPress={() => loadChannelsCount()} />
      <Button text="loadChannelsInfo" onPress={() => loadChannelsInfo()} />
      <Button text="searchRecordByFile" onPress={() => searchRecordByFile()} />
      <Button text="openVoice" onPress={() => openVoice()} />
      <Button text="closeVoice" onPress={() => closeVoice()} />
      <Button text="testmethods" onPress={() => testFunc()} />
      <Button text="pause" onPress={() => pause()} />
      <Button text="rePlay" onPress={() => rePlay()} />
      {/* <Button text="slow" onPress={() => updateSpeed(-3)} />
      <Button text="normal" onPress={() => updateSpeed(0)} />
      <Button text="fast" onPress={() => updateSpeed(3)} /> */}
    </View>
    // </ScrollView>
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
    backgroundColor: '#EFEFEF',
  },
});