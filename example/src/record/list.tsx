import React, { useState } from 'react';
import {
  Alert,
  FlatList,
  Platform,
  Image,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import {
  downloadSingleFile,
  downloadSingleFileByTime,
  downloadSingleImage,
  SearchDate,
  type RecordPlayerRef,
  type SearchDeviceFilesByDateItemResponse,
} from 'react-native-funsdk';
import { DEVICE_ID } from '../topsecret';
import ReactNativeBlobUtil from 'react-native-blob-util';
import {
  // askPermissionReadStorage,
  askPermissionStorage,
} from '../utils/permisiion';
import { createFolderIfNotExist, getFilesInFolder } from '../live/ImageSaver';

const searchDateToString = (date: SearchDate) => {
  const base = `${date.day}.${date.month}.${date.year}-${date.hour}:${date.minute}:${date.second}`;
  // Android filesystem does not allow ':' in filenames
  return Platform.OS === 'android' ? base.replace(/:/g, '-') : base;
};

const RecordItem = ({
  fileInfo,
  playerRef,
}: {
  fileInfo: SearchDeviceFilesByDateItemResponse;
  index: number;
  playerRef: React.RefObject<RecordPlayerRef>;
}) => {
  const [thumbLink, setThumbLink] = useState<string | null>(null);
  React.useEffect(() => {
    console.log('[RecordItem] mount', {
      file: fileInfo?.fileName,
      channel: fileInfo?.channel,
    });
    return () => {
      console.log('[RecordItem] unmount', { file: fileInfo?.fileName });
    };
  }, [fileInfo?.fileName, fileInfo?.channel]);

  const handleLoadThumb = async () => {
    try {
      let folder: string;

      if (Platform.OS === 'ios') {
        folder = ReactNativeBlobUtil.fs.dirs.LibraryDir;
      } else {
        folder = ReactNativeBlobUtil.fs.dirs.PictureDir;
      }
      console.log('folder: ', folder);

      const path = `${folder}/thumbs/${DEVICE_ID}`;

      await createFolderIfNotExist(path);

      const res = await getFilesInFolder(path);
      console.log('getFilesInFolder res: ', res);

      if (Platform.OS === 'android') {
        const permissionAccess = await askPermissionStorage();
        // const permissionReadAccess = await askPermissionReadStorage();
        if (!permissionAccess) {
          Alert.alert('Отсутсвует разрешение на сохранение файлов');
          return;
        }
      }

      const pathWithFileName = `${path}/${searchDateToString(
        fileInfo.startTime
      )}.jpg`;
      console.log('pathWithFileName: ', pathWithFileName);

      const downloadInfo = await downloadSingleImage({
        deviceId: DEVICE_ID,
        deviceChannel: fileInfo.channel,
        imgSizes: {
          imgHeight: 90,
          imgWidth: 160,
        },
        mSaveImageDir: pathWithFileName,
        time: fileInfo.startTime,
        seq: 0,
      });
      console.log('[RecordItem] downloadSingleImage result:', downloadInfo);

      const filesInFolderAfterLoading = await getFilesInFolder(path);
      console.log('filesInFolderAfterLoading res: ', filesInFolderAfterLoading);

      const pathWithFileNameStat = await ReactNativeBlobUtil.fs.stat(
        pathWithFileName
      );
      console.log('pathWithFileNameStat res: ', pathWithFileNameStat);

      const imageUri =
        Platform.OS === 'android'
          ? `file://${pathWithFileName}`
          : pathWithFileName;
      Image.getSize(
        imageUri,
        (width, height) => {
          console.log('Image.getSize width height: ', width, height);
        },
        (error: any) => {
          console.log('Image.getSize error: ', error);
        }
      );

      setThumbLink(pathWithFileName);
    } catch (error) {
      console.log('handleLoadThumb error: ', error);
    }
  };

  const handleLoadVideoFile = async () => {
    try {
      let folder: string;

      if (Platform.OS === 'ios') {
        folder = ReactNativeBlobUtil.fs.dirs.LibraryDir;
      } else {
        folder = ReactNativeBlobUtil.fs.dirs.MovieDir;
      }
      console.log('folder: ', folder);

      const path = `${folder}/video/${DEVICE_ID}`;

      await createFolderIfNotExist(path);

      const res = await getFilesInFolder(path);
      console.log('getFilesInFolder res: ', res);

      if (Platform.OS === 'android') {
        const permissionAccess = await askPermissionStorage();
        if (!permissionAccess) {
          Alert.alert('Отсутсвует разрешение на сохранение файлов');
          return;
        }
      }

      const pathWithFileName = `${path}/${searchDateToString(
        fileInfo.startTime
      )}-${searchDateToString(fileInfo.endTime)}.mp4`;
      console.log('pathWithFileName: ', pathWithFileName);

      if (Platform.OS === 'android') {
        const result = await downloadSingleFileByTime({
          deviceId: DEVICE_ID,
          deviceChannel: fileInfo.channel,
          mSaveImageDir: pathWithFileName,
          startTime: fileInfo.startTime,
          endTime: fileInfo.endTime,
        });
        console.log(
          '[RecordItem] downloadSingleFileByTime result (android):',
          result
        );
      } else {
        const result = await downloadSingleFile({
          deviceId: DEVICE_ID,
          deviceChannel: fileInfo.channel,
          mSaveImageDir: pathWithFileName,
          startTime: fileInfo.startTime,
          endTime: fileInfo.endTime,
          fileName: fileInfo.fileName,
        });
        console.log('[RecordItem] downloadSingleFile result:', result);
      }

      const filesInFolderAfterLoading = await getFilesInFolder(path);
      console.log('filesInFolderAfterLoading res: ', filesInFolderAfterLoading);

      const pathWithFileNameStat = await ReactNativeBlobUtil.fs.stat(
        pathWithFileName
      );
      console.log('pathWithFileNameStat res: ', pathWithFileNameStat);
    } catch (error) {
      console.log('handleLoadVideoFile error: ', error);
    }
  };

  return (
    <View
      style={{
        paddingHorizontal: 8,
        marginVertical: 12,
      }}
    >
      <View style={{ flexDirection: 'row', alignItems: 'center' }}>
        {thumbLink && (
          <Image
            source={{ uri: `file://${thumbLink}` }}
            style={{ width: 150, aspectRatio: 16 / 9, marginRight: 4 }}
          />
        )}
        <View>
          <Text>channel: {fileInfo.channel}</Text>
          <Text>filename: {fileInfo.fileName}</Text>
          <Text>filesize: {fileInfo.size}</Text>
          <Text>startDate: {searchDateToString(fileInfo.startTime)}</Text>
          <Text>endDate: {searchDateToString(fileInfo.endTime)}</Text>
          <Text>streamType: {fileInfo.streamType}</Text>
        </View>
      </View>
      <View style={{ flexDirection: 'row' }}>
        <TouchableOpacity
          hitSlop={20}
          style={{ backgroundColor: 'green', margin: 2 }}
          onPress={() => {
            console.log(
              '[RecordItem] start play record, playerRef.current exists:',
              !!playerRef?.current
            );
            playerRef.current?.stopPlay();
            playerRef.current?.startPlayRecordByTime(
              fileInfo.startTime,
              fileInfo.endTime
            );
          }}
        >
          <Text>start play record</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={{ backgroundColor: 'green', margin: 2 }}
          // onPress={() => console.log('item: ', item)}
          onPress={handleLoadThumb}
        >
          <Text>load thumb image</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={{ backgroundColor: 'green', margin: 2 }}
          // onPress={() => console.log('item: ', item)}
          onPress={handleLoadVideoFile}
        >
          <Text>load video file</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

export const RecordList = ({
  recordList,
  playerRef,
}: {
  recordList: SearchDeviceFilesByDateItemResponse[] | null;
  playerRef: React.RefObject<RecordPlayerRef>;
}) => {
  return (
    <FlatList
      style={{ flex: 1 }}
      data={recordList}
      keyExtractor={(item) => item.fileName + item.size}
      renderItem={({ item, index }) => (
        <RecordItem fileInfo={item} index={index} playerRef={playerRef} />
      )}
    />
  );
};
