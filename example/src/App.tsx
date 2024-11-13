import * as React from 'react';

import {
  Button,
  Dimensions,
  ScrollView,
  //   StyleSheet,
  //   View,
  //   Text,
  TouchableOpacity,
} from 'react-native';
// import RNFetchBlob from 'rn-fetch-blob';

import { RecordPage } from './record';
import { MonitorPage } from './live';
// import { WIFIDevice } from './wifi';
// import { useInit } from './init';
import {
  SafeAreaView,
  // ScrollView,
  Text,
} from 'react-native';
import { useInit } from './init';
import { Alarms } from './alarms';
import { DeviceList } from './list';

// import funsdk from 'react-native-funsdk';
// import { Share } from './share';
// import { QRCodeDevice } from './qrcode';
// import { PushInitLink } from './push';

// Временно используется для тестирования ios
// По мере добавления в библиотеку методов из ios будет дополняться
export default function App() {
  const [currScreen, setCurrScreen] = React.useState<
    'DeviceList' | 'MonitorPage' | 'Alarms' | 'RecordPage'
  >('DeviceList');
  const { isInit, isAuth, statusText, reinit, logoutsdk } = useInit();
  const [showInit, setShowInit] = React.useState(true);

  return (
    <SafeAreaView style={{ flex: 1 }}>
      {/* <Text>some random text2 {String(isInit)}</Text> */}
      <ScrollView
        // pointerEvents="none"
        // contentContainerStyle={{ height: 50 }}
        style={{
          position: 'absolute',
          top: 20,
          left: 0,
          right: 0,
          opacity: 0.7,
          backgroundColor: '#ffffff',
          zIndex: 11111,
        }}
      >
        {showInit && (
          <ScrollView
            style={{ maxHeight: Dimensions.get('window').height / 2 }}
          >
            <Text>isInit: {isInit.toString()}</Text>
            <Text>text: {statusText?.text}</Text>
            <Text>value: {JSON.stringify(statusText?.value)}</Text>
            <ScrollView horizontal>
              <Button
                title="Device List"
                onPress={() => setCurrScreen('DeviceList')}
              />
              <Button
                title="MonitorPage"
                onPress={() => setCurrScreen('MonitorPage')}
              />
              <Button title="Alarms" onPress={() => setCurrScreen('Alarms')} />
              <Button
                title="RecordPage"
                onPress={() => setCurrScreen('RecordPage')}
              />
            </ScrollView>
          </ScrollView>
        )}
        <TouchableOpacity
          style={{ backgroundColor: 'red', height: 30 }}
          onPress={() => setShowInit((prev) => !prev)}
        >
          <Text>show/hide</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={{
            backgroundColor: 'red',
            height: 50,
            borderWidth: 2,
            borderColor: 'yellow',
          }}
          onPress={() => reinit()}
        >
          <Text>re init</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={{
            backgroundColor: 'red',
            height: 50,
            borderWidth: 2,
            borderColor: 'yellow',
          }}
          onPress={() => logoutsdk()}
        >
          <Text>logoutsdk</Text>
        </TouchableOpacity>
      </ScrollView>
      {isAuth && (
        <>
          {currScreen === 'DeviceList' && <DeviceList />}
          {currScreen === 'MonitorPage' && <MonitorPage isAuth={true} />}
          {currScreen === 'Alarms' && <Alarms />}
          {currScreen === 'RecordPage' && <RecordPage />}
        </>
      )}
    </SafeAreaView>
  );
}

// android
// export default function App() {
//   const { isInit, statusText } = useInit();
//   const [showInit, setShowInit] = React.useState(true);
//   // const path = `file://${RNFetchBlob.fs.dirs.PictureDir}`;

//   return (
//     <>
//       {/* <RecordPage /> */}
//       <MonitorPage isInit={isInit} />
//       {/* <WIFIDevice /> */}
//       {/* <QRCodeDevice /> */}
//       {/* <PushInitLink /> */}
//       {/* <Share /> */}
// <ScrollView
//   // pointerEvents="none"
//   // contentContainerStyle={{ height: 50 }}
//   style={{
//     position: 'absolute',
//     top: 0,
//     left: 0,
//     right: 0,
//     opacity: 1,
//     backgroundColor: '#ffffff',
//   }}
// >
//   {showInit && (
//     <>
//       <Text>isInit: {isInit.toString()}</Text>
//       <Text>text: {statusText?.text}</Text>
//       <Text>value: {JSON.stringify(statusText?.value)}</Text>
//     </>
//   )}
//   <TouchableOpacity
//     style={{ backgroundColor: 'red' }}
//     onPress={() => setShowInit((prev) => !prev)}
//   >
//     <Text>show/hide</Text>
//   </TouchableOpacity>
// </ScrollView>
//     </>
//   );
// }
