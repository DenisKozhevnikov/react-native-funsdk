import React from 'react';
import {
  Alert,
  Platform,
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
  downloadSingleFileByTime,
  SearchDate,
  // startSetWiFi,
} from 'react-native-funsdk';
import { DEVICE_ID } from '../topsecret';
import ReactNativeBlobUtil from 'react-native-blob-util';
import { createFolderIfNotExist, getFilesInFolder } from '../live/ImageSaver';
import { askPermissionStorage } from '../utils/permisiion';

const searchDateToString = (date: SearchDate) => {
  return `${date.day}.${date.month}.${date.year}-${date.hour}:${date.minute}:${date.second}`;
};

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
  playerRef: React.RefObject<RecordPlayerRef>;
  setTimeline: React.Dispatch<React.SetStateAction<number[] | null>>;
  setRecordList: React.Dispatch<
    React.SetStateAction<SearchDeviceFilesByDateItemResponse[] | null>
  >;
}) => {
  React.useEffect(() => {
    console.log('[RecordButtons] mount');
    return () => console.log('[RecordButtons] unmount');
  }, []);

  React.useEffect(() => {
    console.log(
      '[RecordButtons] playerRef.current exists:',
      !!playerRef?.current
    );
  }, [playerRef]);
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
          year: 2025,
          // Отсчет от 1
          // Если нужен ноябрь, то это 10 месяц + 1 = 11
          month: 8, // January = 1, February = 2, and so on.
          day: 21,
          hour: 0,
          minute: 0,
          second: 0,
        },
        end: {
          year: 2025,
          month: 8,
          day: 22,
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
          year: 2025,
          // Отсчет от 1
          // Если нужен ноябрь, то это 10 месяц + 1 = 11
          month: 8,
          day: 21,
          hour: 0,
          minute: 0,
          second: 0,
        },
        end: {
          year: 2025,
          month: 8,
          day: 22,
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

  const loadFileByTime = async () => {
    try {
      let folder: string;

      if (Platform.OS === 'ios') {
        folder = ReactNativeBlobUtil.fs.dirs.LibraryDir;
      } else {
        folder = ReactNativeBlobUtil.fs.dirs.MovieDir;
      }

      const path = `${folder}/video/${DEVICE_ID}`;

      await createFolderIfNotExist(path);

      const filesInFolder = await getFilesInFolder(path);
      console.log('getFilesInFolder res: ', filesInFolder);

      if (Platform.OS === 'android') {
        const permissionAccess = await askPermissionStorage();
        // const permissionReadAccess = await askPermissionReadStorage();
        if (!permissionAccess) {
          Alert.alert('Отсутсвует разрешение на сохранение файлов');
          return;
        }
      }

      const startTime = {
        year: 2025,
        month: 8,
        day: 21,
        hour: 10,
        minute: 10,
        second: 10,
      };

      const endTime = {
        year: 2025,
        month: 8,
        day: 22,
        hour: 10,
        minute: 11,
        second: 10,
      };

      const pathWithFileName = `${path}/${searchDateToString(
        startTime
      )}-${searchDateToString(endTime)}.mp4`;
      console.log('pathWithFileName: ', pathWithFileName);

      const isExists = await ReactNativeBlobUtil.fs.exists(pathWithFileName);

      if (isExists) {
        Alert.alert('takoi fail uzhe est');
        return;
      }

      const res = await downloadSingleFileByTime({
        deviceId: DEVICE_ID,
        deviceChannel: 0,
        startTime,
        endTime,
        mSaveImageDir: pathWithFileName,
      });

      console.log('loadFileByTime res: ', res);

      const filesInFolderAfterLoading = await getFilesInFolder(path);
      console.log('filesInFolderAfterLoading res: ', filesInFolderAfterLoading);

      const pathWithFileNameStat = await ReactNativeBlobUtil.fs.stat(
        pathWithFileName
      );
      console.log('pathWithFileNameStat res: ', pathWithFileNameStat);
    } catch (error) {
      console.log('loadFileByTime error: ', error);
    }
  };

  const getFilesStat = async () => {
    try {
      let folder: string;

      if (Platform.OS === 'ios') {
        folder = ReactNativeBlobUtil.fs.dirs.LibraryDir;
      } else {
        folder = ReactNativeBlobUtil.fs.dirs.MovieDir;
      }

      const path = `${folder}/video/${DEVICE_ID}`;

      const filesInFolder = await getFilesInFolder(path);
      console.log('filesInFolder res: ', filesInFolder);

      const stat = await ReactNativeBlobUtil.fs.lstat(path);

      console.log('stat: ', JSON.stringify(stat, null, 2));

      const pathWithFileName = `${path}/${searchDateToString({
        year: 2025,
        month: 8,
        day: 21,
        hour: 10,
        minute: 10,
        second: 10,
      })}.mp4`;
      console.log('pathWithFileName: ', pathWithFileName);

      const isExists = await ReactNativeBlobUtil.fs.exists(pathWithFileName);

      console.log('isExists: ', isExists);
    } catch (error) {
      console.log('getFilesStat error: ', error);
    }
  };

  const deleteEveryInFolder = async () => {
    try {
      let folder: string;

      if (Platform.OS === 'ios') {
        folder = ReactNativeBlobUtil.fs.dirs.LibraryDir;
      } else {
        folder = ReactNativeBlobUtil.fs.dirs.MovieDir;
      }

      const path = `${folder}/video/${DEVICE_ID}`;

      await ReactNativeBlobUtil.fs.unlink(path);
      console.log('removed');
    } catch (error) {
      console.log('deleteEveryInFolder: ', deleteEveryInFolder);
    }
  };

  const seekToTime = async (addTime: number, absTime: number) => {
    playerRef.current?.seekToTime(addTime, absTime);
  };

  const openVoice = () => {
    playerRef.current?.openVoice();
  };

  const closeVoice = () => {
    playerRef.current?.closeVoice();
  };

  const pause = () => {
    playerRef.current?.pausePlay();
  };

  const rePlay = () => {
    playerRef.current?.rePlay();
  };

  const stopPlay = () => {
    playerRef.current?.stopPlay();
  };

  const init = () => {
    console.log(
      '[RecordButtons] init pressed, playerRef.current exists:',
      !!playerRef?.current
    );
    playerRef.current?.init();
  };

  const speedNormal = () => {
    console.log('[RecordButtons] setPlaySpeed 0');
    playerRef.current?.setPlaySpeed(0);
  };

  const speedPlus2 = () => {
    console.log('[RecordButtons] setPlaySpeed 2');
    playerRef.current?.setPlaySpeed(2);
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
        <Button
          text="rePlay"
          onPress={() => {
            console.log('[RecordButtons] rePlay');
            rePlay();
          }}
        />
        <Button text="stopPlay" onPress={() => stopPlay()} />
        <Button text="speedNormal" onPress={() => speedNormal()} />
        <Button text="speedPlus2" onPress={() => speedPlus2()} />
        <Button text="loadFileByTime" onPress={() => loadFileByTime()} />
        <Button text="getFilesStat" onPress={() => getFilesStat()} />
        <Button
          text="deleteEveryInFolder"
          onPress={() => deleteEveryInFolder()}
        />
        <Button text="seekToTime +15" onPress={() => seekToTime(15, 0)} />
        <Button text="seekToTime -15" onPress={() => seekToTime(-15, 0)} />
        <Button text="seekToTime abs 120" onPress={() => seekToTime(1000, 0)} />
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
