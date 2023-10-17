import React from 'react';
import { FlatList, Text, TouchableOpacity } from 'react-native';
import type {
  RecordPlayerRef,
  SearcResultRecordFile,
} from 'react-native-funsdk';

export const RecordList = ({
  recordList,
  playerRef,
}: {
  recordList: SearcResultRecordFile[] | null;
  playerRef: RecordPlayerRef | null;
}) => {
  return (
    <FlatList
      style={{ flex: 2 }}
      data={recordList}
      renderItem={({ item, index }) => (
        <TouchableOpacity
          style={{
            paddingHorizontal: 8,
            marginVertical: 12,
          }}
          onPress={() => playerRef?.startPlayRecord(index)}
          // key={item.filename}
        >
          <Text>channel: {item.channel}</Text>
          <Text>filename: {item.filename}</Text>
          <Text>filesize: {item.filesize}</Text>
          <Text>startDate: {item.startDate}</Text>
          <Text>endTimeLong: {item.endTimeLong}</Text>
          <Text>streamType: {item.streamType}</Text>
        </TouchableOpacity>
      )}
    />
  );
};
