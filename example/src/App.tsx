import * as React from 'react';

// import {
//   StyleSheet,
//   View,
//   Text,
//   TouchableOpacity,
//   ScrollView,
//   FlatList,
// } from 'react-native';
// import RNFetchBlob from 'rn-fetch-blob';

// import {
//   funSDKInit,
//   getUserId,
//   getUserName,
//   loginByAccount,
//   // logout,
//   registerByNotBind,
//   getDeviceList,
//   addDevice,
//   Monitor,
//   RecordPlayer,
//   updateAllDevStateFromServer,
//   getDetailDeviceList,
//   loginDeviceWithCredential,
//   SearcResultRecordFile,
//   // hasLogin,
// } from 'react-native-funsdk';
import { RecordPage } from './record';
import { MonitorPage } from './live';

export default function App() {
  // const path = `file://${RNFetchBlob.fs.dirs.PictureDir}`;

  return (
    <>
      <RecordPage />
      {/* <MonitorPage /> */}
    </>
  );
}
