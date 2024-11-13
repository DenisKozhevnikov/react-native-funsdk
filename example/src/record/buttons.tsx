import React from 'react';
import {
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  // ScrollView,
  View,
} from 'react-native';
import {
  FILE_TYPE,
  searchDeviceFilesByDate,
  SearchDeviceFilesByDateItemResponse,
  RecordPlayerRef,
  // getChannelCount,
  // getChannelInfo,
  searchTimeinfo,
  // startSetWiFi,
} from 'react-native-funsdk';
import { DEVICE_ID } from '../topsecret';

const Button = ({ onPress, text }: { onPress: () => void; text: string }) => {
  return (
    <TouchableOpacity onPress={onPress} style={styles.button}>
      <Text style={styles.buttonText}>{text}</Text>
    </TouchableOpacity>
  );
};

export const RecordButtons = ({
  playerRef,
  setTimeline,
  setRecordList,
}: {
  playerRef: RecordPlayerRef | null;
  setTimeline: React.Dispatch<React.SetStateAction<number[] | null>>;
  setRecordList: React.Dispatch<
    React.SetStateAction<SearchDeviceFilesByDateItemResponse[] | null>
  >;
}) => {
  const searchRecordTimeInfo = async () => {
    try {
      // 27.10.23
      // const start = 1698364800000;
      // const start = 1698364800000;
      // const start = 1699680774000;
      // 1000 - 1 мс
      // 60 - 1 минута
      // 60 - 1 час
      // 24 - 1 сутки
      // 2 - 2 дня
      // const start = Date.now() - 1000 * 60 * 60 * 24 * 1;
      // const start = Date.now();

      const result = await searchTimeinfo({
        deviceId: DEVICE_ID,
        deviceChannel: 0,
        start: {
          year: 2024,
          // Отсчет от 1
          // Если нужен ноябрь, то это 10 месяц + 1 = 11
          month: 1, // January = 1, February = 2, and so on.
          day: 9,
          hour: 0,
          minute: 0,
          second: 0,
        },
        end: {
          year: 2024,
          month: 11,
          day: 11,
          hour: 23,
          minute: 59,
          second: 59,
        },
        timeout: 10000,
      });
      // const result2 = await searchTimeinfo({
      //   deviceId: DEVICE_ID,
      //   startTime: start - 10000,
      //   endTime: start,
      //   deviceChannel: 0,
      //   fileType: 0,
      //   streamType: 0,
      //   seq: 0,
      // });
      if (result?.minutesStatusList) {
        setTimeline(result?.minutesStatusList);
      }

      console.log('searchRecordTimeInfo result: ', result);
      // console.log('searchRecordTimeInfo result2: ', result2);
    } catch (error) {
      console.log('searchRecordTimeInfo error: ', error);
    }
  };

  const searchRecordFiles = async () => {
    try {
      const result = await searchDeviceFilesByDate({
        deviceChannel: 0,
        deviceId: DEVICE_ID,
        maxFileCount: 10000,
        // fileType: FILE_TYPE.SDK_RECORD_ALL,
        fileType: FILE_TYPE.SDK_RECORD_ALL,
        start: {
          year: 2024,
          // Отсчет от 1
          // Если нужен ноябрь, то это 10 месяц + 1 = 11
          month: 11,
          day: 13,
          hour: 0,
          minute: 0,
          second: 0,
        },
        end: {
          year: 2024,
          month: 11,
          day: 20,
          hour: 23,
          minute: 59,
          second: 59,
        },
        timeout: 10000,
      });

      setRecordList(result);
      console.log(
        'searchRecordFiles result: ',
        JSON.stringify(result, null, 2)
      );
    } catch (error) {
      console.log('searchRecordFiles error: ', error);
    }
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

  const stopPlay = () => {
    playerRef?.stopPlay();
  };

  const init = () => {
    console.log('playerRef: ', playerRef);
    playerRef?.init();
  };

  const speedNormal = () => {
    playerRef?.setPlaySpeed(0);
  };

  const speedPlus2 = () => {
    playerRef?.setPlaySpeed(2);
  };

  // const plus10sec = () => {
  //   playerRef.se
  // }

  return (
    <ScrollView
      style={{
        backgroundColor: '#EFEFEF',
        height: 100,
      }}
    >
      <View style={styles.view}>
        <Button
          text="searchRecordTimeInfo"
          onPress={() => searchRecordTimeInfo()}
        />
        <Button text="searchRecordFiles" onPress={() => searchRecordFiles()} />
        <Button text="init" onPress={() => init()} />
        <Button text="openVoice" onPress={() => openVoice()} />
        <Button text="closeVoice" onPress={() => closeVoice()} />
        <Button text="pause" onPress={() => pause()} />
        <Button text="rePlay" onPress={() => rePlay()} />
        <Button text="stopPlay" onPress={() => stopPlay()} />
        <Button text="speedNormal" onPress={() => speedNormal()} />
        <Button text="speedPlus2" onPress={() => speedPlus2()} />
      </View>
    </ScrollView>
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
