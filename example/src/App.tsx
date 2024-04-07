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

import {
  funSDKInit,
  // getUserId,
  // getUserName,
  // loginByAccount,
  // // logout,
  // registerByNotBind,
  // getDeviceList,
  // addDevice,
  // Monitor,
  // RecordPlayer,
  // updateAllDevStateFromServer,
  // getDetailDeviceList,
  // loginDeviceWithCredential,
  // SearcResultRecordFile,
  // // hasLogin,
} from 'react-native-funsdk';
// import { RecordPage } from './record';
// import { MonitorPage } from './live';
// import { WIFIDevice } from './wifi';
// import { useInit } from './init';
import {
  Button,
  SafeAreaView,
  // ScrollView,
  Text,
  // TouchableOpacity,
} from 'react-native';

// import funsdk from 'react-native-funsdk';
// import { Share } from './share';
// import { QRCodeDevice } from './qrcode';
// import { PushInitLink } from './push';

// Временно используется для тестирования ios
// По мере добавления в библиотеку методов из ios будет дополняться
export default function App() {
  return (
    <SafeAreaView>
      <Text>some random text2</Text>
      <Button
        title="titul"
        onPress={
          // () => console.log('dasdas: ', someMethod())
          () => {
            funSDKInit((id) => console.log('some id: ', id));
          }
          // () => console.log('dasdas: ')
          // createCalendarEvent('aba', 'kaba', (num) =>
          //   console.log('num is: ', num)
          // )
        }
      />
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
//       <ScrollView
//         // pointerEvents="none"
//         // contentContainerStyle={{ height: 50 }}
//         style={{
//           position: 'absolute',
//           top: 0,
//           left: 0,
//           right: 0,
//           opacity: 1,
//           backgroundColor: '#ffffff',
//         }}
//       >
//         {showInit && (
//           <>
//             <Text>isInit: {isInit.toString()}</Text>
//             <Text>text: {statusText?.text}</Text>
//             <Text>value: {JSON.stringify(statusText?.value)}</Text>
//           </>
//         )}
//         <TouchableOpacity
//           style={{ backgroundColor: 'red' }}
//           onPress={() => setShowInit((prev) => !prev)}
//         >
//           <Text>show/hide</Text>
//         </TouchableOpacity>
//       </ScrollView>
//     </>
//   );
// }
