import React, { useEffect, useState } from 'react';
import {
  Alert,
  FlatList,
  Image,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import {
  downloadSingleImage,
  type RecordPlayerRef,
  type SearcResultRecordFile,
} from 'react-native-funsdk';
import { DEVICE_ID } from '../topsecret';
import {
  createFolderIfNotExist,
  // getListOfFiles
} from '../utils/folder';
import ReactNativeBlobUtil from 'react-native-blob-util';
import {
  // askPermissionReadStorage,
  askPermissionStorage,
} from '../utils/permisiion';

const RecordItem = ({
  fileInfo,
  index,
  playerRef,
}: {
  fileInfo: SearcResultRecordFile;
  index: number;
  playerRef: RecordPlayerRef | null;
}) => {
  const [thumbLink, setThumbLink] = useState<string | null>(null);

  useEffect(() => {
    if (thumbLink) {
      return;
    }

    const handleLoadThumb = async () => {
      try {
        let folder = ReactNativeBlobUtil.fs.dirs.PictureDir;
        const res = await createFolderIfNotExist(folder, DEVICE_ID);
        if (!res) {
          Alert.alert(
            'Невозможно создать директорию для сохранения изображений'
          );
          return;
        }
        const permissionAccess = await askPermissionStorage();

        // const permissionReadAccess = await askPermissionReadStorage();

        if (!permissionAccess) {
          Alert.alert('Отсутсвует разрешение на сохранение файлов');
          return;
        }
        console.log('fileInfo.startTimeOfYear: ', fileInfo.startTimeOfYear);
        const downloadInfo = await downloadSingleImage({
          deviceId: DEVICE_ID,
          deviceChannel: fileInfo.channel,
          imgSizes: {
            imgHeight: 90,
            imgWidth: 160,
          },
          timestamp: fileInfo.startTimeOfYear,
          mSaveImageDir: `${folder}/${DEVICE_ID}`,
          seq: index,
        });

        setThumbLink(downloadInfo.imagePath);
      } catch (error) {
        console.log('handleLoadThumb error: ', error);
      }
    };

    handleLoadThumb();
  }, [fileInfo.channel, fileInfo.startTimeOfYear, index, thumbLink]);

  return (
    <View
      style={{
        paddingHorizontal: 8,
        marginVertical: 12,
      }}
      // key={item.filename}
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
          {/* <Text>filename: {fileInfo.filename}</Text> */}
          {/* <Text>filesize: {fileInfo.filesize}</Text> */}
          <Text>startDate: {fileInfo.startTimeOfYear}</Text>
          {/* <Text>endTimeLong: {fileInfo.endTimeLong}</Text> */}
          {/* <Text>streamType: {fileInfo.streamType}</Text> */}
        </View>
      </View>
      <View style={{ flexDirection: 'row' }}>
        <TouchableOpacity
          style={{ backgroundColor: 'green', margin: 2 }}
          onPress={() => playerRef?.startPlayRecord(index)}
        >
          <Text>start play record</Text>
        </TouchableOpacity>
        {/* <TouchableOpacity
          style={{ backgroundColor: 'green', margin: 2 }}
          // onPress={() => console.log('item: ', item)}
          onPress={handleLoadThumb}
        >
          <Text>load thumb image</Text>
        </TouchableOpacity> */}
      </View>
    </View>
  );
};

export const RecordList = ({
  recordList,
  playerRef,
}: {
  recordList: SearcResultRecordFile[] | null;
  playerRef: RecordPlayerRef | null;
}) => {
  // useEffect(() => {
  //   const loadList = async () => {
  //     let folder = ReactNativeBlobUtil.fs.dirs.PictureDir;
  //     const files = await getListOfFiles(folder);
  //     console.log('files: ', files);
  //   };

  //   loadList();
  // }, []);
  return (
    <FlatList
      style={{ flex: 1 }}
      data={recordList}
      renderItem={({ item, index }) => (
        <RecordItem
          key={DEVICE_ID + item.startTimeOfYear + item.channel}
          fileInfo={item}
          index={index}
          playerRef={playerRef}
        />
      )}
    />
  );
};
