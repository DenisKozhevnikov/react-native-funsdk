/* eslint-disable react-native/no-inline-styles */
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
import { WIFIDevice, WIFIDeviceSearch } from './wifi';
// import { useInit } from './init';
import {
  SafeAreaView,
  // ScrollView,
  Text,
} from 'react-native';
import { useInit } from './init';
import { Alarms } from './alarms';
import { DeviceList } from './list';
import {
  USER_NAME,
  USER_NAME2,
  USER_PASSWORD,
  USER_PASSWORD2,
} from './topsecret';
import { SearchLanDevices } from './lan';

// import funsdk from 'react-native-funsdk';
// import { Share } from './share';
// import { QRCodeDevice } from './qrcode';
// import { PushInitLink } from './push';

const Btn = ({ onPress, text }: { onPress: () => void; text: string }) => {
  return (
    <TouchableOpacity
      style={{
        backgroundColor: 'red',
        height: 40,
        borderWidth: 2,
        borderColor: 'yellow',
      }}
      onPress={onPress}
    >
      <Text>{text}</Text>
    </TouchableOpacity>
  );
};

// Временно используется для тестирования ios
// По мере добавления в библиотеку методов из ios будет дополняться
export default function App() {
  const [currScreen, setCurrScreen] = React.useState<
    | 'DeviceList'
    | 'MonitorPage'
    | 'Alarms'
    | 'RecordPage'
    | 'WIFIDevice'
    | 'SearchLanDevices'
    | 'WIFIDevice2'
  >('DeviceList');
  const { isInit, statusText, reinit, logoutsdk } = useInit();
  const [showInit, setShowInit] = React.useState(true);

  return (
    <SafeAreaView style={{ flex: 1 }}>
      {/* <Text>some random text2 {String(isInit)}</Text> */}
      <ScrollView
        bounces={false}
        scrollEnabled={false}
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
        <TouchableOpacity
          style={{ backgroundColor: 'red', height: 40 }}
          onPress={() => setShowInit((prev) => !prev)}
        >
          <Text>toggle</Text>
        </TouchableOpacity>
        {showInit && (
          <ScrollView
            bounces={false}
            style={{ maxHeight: Dimensions.get('window').height / 1.2 }}
          >
            <Text>isInit: {isInit.toString()}</Text>
            <Text>text: {statusText?.text}</Text>
            <Text>value: {JSON.stringify(statusText?.value, null, 2)}</Text>
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
              <Button
                title="WIFIDevice"
                onPress={() => setCurrScreen('WIFIDevice')}
              />
              <Button
                title="WIFIDevice2"
                onPress={() => setCurrScreen('WIFIDevice2')}
              />
              <Button
                title="SearchLanDevices"
                onPress={() => setCurrScreen('SearchLanDevices')}
              />
            </ScrollView>
            <>
              <Btn
                onPress={() =>
                  reinit({ username: USER_NAME, password: USER_PASSWORD })
                }
                text="re init by user1"
              />
              <Btn
                onPress={() =>
                  reinit({ username: USER_NAME2, password: USER_PASSWORD2 })
                }
                text="re init by user2"
              />
              <Btn onPress={() => logoutsdk()} text="logoutsdk" />
            </>
          </ScrollView>
        )}
      </ScrollView>
      <>
        {currScreen === 'DeviceList' && <DeviceList />}
        {currScreen === 'MonitorPage' && <MonitorPage isAuth={true} />}
        {currScreen === 'Alarms' && <Alarms />}
        {currScreen === 'RecordPage' && <RecordPage />}
        {currScreen === 'WIFIDevice' && <WIFIDevice />}
        {currScreen === 'WIFIDevice2' && <WIFIDeviceSearch />}
        {currScreen === 'SearchLanDevices' && <SearchLanDevices />}
      </>
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
