import * as React from 'react';

import {
  StyleSheet,
  View,
  Text,
  TouchableOpacity,
  ScrollView,
} from 'react-native';
import RNFetchBlob from 'rn-fetch-blob';

import {
  funSDKInit,
  getUserId,
  getUserName,
  loginByAccount,
  logout,
  registerByNotBind,
  getDeviceList,
  addDevice,
  Monitor,
  hasLogin,
} from 'react-native-funsdk';

// export default function App() {
//   const [isLogin, setIsLogin] = React.useState<string>('');

//   React.useEffect(() => {
//     const checkIsLogin = async () => {
//       try {
//         const isLogin = await hasLogin();
//         setIsLogin(String(isLogin));
//         console.log('checkIsLogin: ', isLogin);
//       } catch (error) {
//         console.log('checkIsLogin error: ', error);
//       }
//     };

//     checkIsLogin();
//   }, []);

//   return (
//     <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
//       <Text>{isLogin}</Text>
//     </View>
//   );
// }

export default function App() {
  const [showMonitor, setShowMonitor] = React.useState(false);
  const [result] = React.useState<number | undefined>(0);
  const [isInit, setIsInit] = React.useState(false);
  const monitorRef = React.useRef<Monitor>(null);

  React.useEffect(() => {
    funSDKInit();

    const someFuncs = async () => {
      try {
        // const res = await loginByAccount({
        //   username: 'username',
        //   password: 'password',
        // });
        // const res = await registerByNotBind({
        //   username: 'username',
        //   password: 'password',
        // });
        // console.log('res: ', res);
        await someInfos();
      } catch (error) {
        console.log('error: ', error);
      }
    };

    const someInfos = async () => {
      try {
        const userId = await getUserId();
        const userName = await getUserName();
        const deviceList = await getDeviceList();

        console.log('res: ', userId, userName, deviceList);

        // await addDeviceTest();
        setIsInit(true);
      } catch (error) {
        console.log('error: ', error);
      }
    };

    // const addDeviceTest = async () => {
    //   try {
    //     const addedDevice = await addDevice({
    //       deviceId: '',
    //       username: '',
    //       password: '',
    //       deviceType: 'no need',
    //     });

    //     console.log('addedDevice: ', addedDevice);

    //     const deviceList = await getDeviceList();
    //     console.log('deviceList: ', deviceList);
    //   } catch (error) {
    //     console.log('error: ', error);
    //   }
    // };

    setTimeout(() => {
      someFuncs();
    }, 2000);
  }, []);

  const path = `file://${RNFetchBlob.fs.dirs.PictureDir}`;

  if (!isInit) {
    return null;
  }

  return (
    <View style={styles.container}>
      {showMonitor && (
        <Monitor
          devId=""
          style={styles.monitor}
          ref={monitorRef}
          onLayout={(event) => console.log('event: ', event.nativeEvent)}
        />
      )}
      <ScrollView style={{ flex: 1 }}>
        <View style={styles.view}>
          <TouchableOpacity
            onPress={() => setShowMonitor((prev) => !prev)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>toggle player</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.flipVideo()}
            style={styles.button}
          >
            <Text style={styles.buttonText}>flip video</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.playVideo()}
            style={styles.button}
          >
            <Text style={styles.buttonText}>playVideo</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.pauseVideo()}
            style={styles.button}
          >
            <Text style={styles.buttonText}>pauseVideo</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.replayVideo()}
            style={styles.button}
          >
            <Text style={styles.buttonText}>replayVideo</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.stopVideo()}
            style={styles.button}
          >
            <Text style={styles.buttonText}>stopVideo</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.destroyVideo()}
            style={styles.button}
          >
            <Text style={styles.buttonText}>destroyVideo</Text>
          </TouchableOpacity>
          <TouchableOpacity
            // disabled
            onPress={() => monitorRef.current?.captureImage(path)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>captureImage</Text>
          </TouchableOpacity>
          <TouchableOpacity
            disabled
            onPress={() => monitorRef.current?.startVideoRecord('')}
            style={styles.button}
          >
            <Text style={styles.buttonText}>startVideoRecord</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.stopVideoRecord()}
            style={styles.button}
          >
            <Text style={styles.buttonText}>stopVideoRecord</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.openVoice()}
            style={styles.button}
          >
            <Text style={styles.buttonText}>openVoice</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.closeVoice()}
            style={styles.button}
          >
            <Text style={styles.buttonText}>closeVoice</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.setSpeakerType(0)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>setSpeakerType 0</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.setSpeakerType(1)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>setSpeakerType 1</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.setSpeakerType(2)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>setSpeakerType 2</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.startSingleIntercomAndSpeak()}
            style={styles.button}
          >
            <Text style={styles.buttonText}>startSingleIntercomAndSpeak</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.stopSingleIntercomAndSpeak()}
            style={styles.button}
          >
            <Text style={styles.buttonText}>stopSingleIntercomAndSpeak</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.startDoubleIntercom()}
            style={styles.button}
          >
            <Text style={styles.buttonText}>startDoubleIntercom</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.stopDoubleIntercom()}
            style={styles.button}
          >
            <Text style={styles.buttonText}>stopDoubleIntercom</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.swtichStream()}
            style={styles.button}
          >
            <Text style={styles.buttonText}>swtichStream</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.setVideoFullScreen(true)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>setVideoFullScreen true</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.setVideoFullScreen(false)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>setVideoFullScreen false</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => monitorRef.current?.capturePicFromDevAndSave()}
            style={styles.button}
          >
            <Text style={styles.buttonText}>capturePicFromDevAndSave</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
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
    backgroundColor: 'gray',
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
  },
});
