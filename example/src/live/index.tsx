import React, { useEffect, useRef, useState } from 'react';
import {
  StyleSheet,
  View,
  // Text,
  TouchableOpacity,
  Text,
  ScrollView,
  // FlatList,
} from 'react-native';
import {
  // funSDKInit,
  // getUserId,
  // getUserName,
  // loginByAccount,
  // logout,
  // registerByNotBind,
  // getDeviceList,
  // addDevice,
  // RecordPlayer,
  // updateAllDevStateFromServer,
  // getDetailDeviceList,
  // loginDeviceWithCredential,
  // SearcResultRecordFile,
  Monitor,
  devicePTZcontrol,
  getChannelCount,
  getChannelInfo,
  isDeviceFunctionSupport,
  getDeviceModel,
  getSoftWareVersion,
  getBuildTime,
  EPTZCMD,
  DevicePTZControlParams,
  // hasLogin,
} from 'react-native-funsdk';
import {
  DEVICE_ID,
  // DEVICE_LOGIN,
  // DEVICE_PASSWORD,
  // USER_NAME,
  // USER_PASSWORD,
} from '../topsecret';

const monitorsList = new Map<number, React.RefObject<Monitor>>();

export const MonitorPage = ({ isInit }: { isInit: boolean }) => {
  // const [isInit, setIsInit] = React.useState(false);
  const monitorRef = useRef<Monitor>(null);
  const monitorRef2 = useRef<Monitor>(null);
  const [activeChannel, setActiveChannel] = useState(0);
  const [PTZSpeed, setPTZSpeed] =
    useState<NonNullable<DevicePTZControlParams['speed']>>(4);

  const getMonitor = (channelId: number) => {
    const hasMonitor = monitorsList.has(channelId);
    console.log('hasMonitor: ', hasMonitor);
    if (!hasMonitor) {
      return;
    }

    return monitorsList.get(channelId);
  };

  useEffect(() => {
    monitorsList.set(0, monitorRef);
    monitorsList.set(1, monitorRef2);
  }, []);

  // React.useEffect(() => {
  //   if (isInit) {
  //     return;
  //   }

  //   monitorsList.set(0, monitorRef);
  //   monitorsList.set(1, monitorRef2);

  //   funSDKInit();
  //   const someFuncs = async () => {
  //     try {
  //       // const res = await loginByAccount({
  //       //   username: '',
  //       //   password: '',
  //       // });
  //       console.log('start somefunc');
  //       const res = await loginByAccount({
  //         username: USER_NAME,
  //         password: USER_PASSWORD,
  //       });
  //       // const res = await registerByNotBind({
  //       //   username: '',
  //       //   password: '',
  //       // });
  //       console.log('res somefunc: ', res);
  //       await someInfos();
  //     } catch (error) {
  //       console.log('error in someFuncs: ', error);
  //     }
  //   };
  //   const someInfos = async () => {
  //     try {
  //       const userId = await getUserId();
  //       const userName = await getUserName();
  //       const deviceList = await getDeviceList();
  //       console.log('res someinfos: ', userId, userName, deviceList);
  //       await addDeviceTest();
  //       const updatedStatus = await updateAllDevStateFromServer();
  //       console.log('updatedStatus: ', updatedStatus);
  //       const detailedList = await getDetailDeviceList();
  //       console.log('detailedList: ', detailedList);

  //       // const loginstatus = await loginDeviceWithCredential({
  //       //   deviceId: DEVICE_ID,
  //       //   deviceLogin: DEVICE_LOGIN,
  //       //   devicePassword: DEVICE_PASSWORD,
  //       // });
  //       // console.log('loginstatus: ', loginstatus);
  //       setIsInit(true);
  //     } catch (error) {
  //       console.log('error: ', error);
  //     }
  //   };
  //   const addDeviceTest = async () => {
  //     try {
  //       // const addedDevice = await addDevice({
  //       //   deviceId: DEVICE_ID,
  //       //   username: DEVICE_LOGIN,
  //       //   password: DEVICE_PASSWORD,
  //       //   deviceType: 'no need',
  //       //   deviceName: 'supername',
  //       // });
  //       // console.log('addedDevice: ', addedDevice);
  //       const deviceList = await getDeviceList();
  //       console.log('deviceList: ', deviceList);
  //     } catch (error) {
  //       console.log('error on add device: ', error);
  //     }
  //   };
  //   setTimeout(() => {
  //     someFuncs();
  //   }, 2000);
  // }, [isInit]);

  const [isLogged, setIsLogged] = useState(false);

  const handleDeviceLogin = async () => {
    try {
      // const loginstatus = await loginDeviceWithCredential({
      //   deviceId: DEVICE_ID,
      //   deviceLogin: DEVICE_LOGIN,
      //   devicePassword: DEVICE_PASSWORD,
      // });
      // console.log('loginstatus: ', loginstatus);
      setIsLogged(true);
    } catch (error) {
      console.log('error login: ', error);
      // handleDeviceLogin();
      setIsLogged(true);
    }
  };

  const openVoice = () => {
    getMonitor(activeChannel)?.current?.openVoice();
  };

  const closeVoice = () => {
    getMonitor(activeChannel)?.current?.closeVoice();
  };

  const loadChannelsInfo = async () => {
    try {
      const info = await getChannelInfo({ deviceId: DEVICE_ID });
      console.log('channels info is: ', info);
    } catch (error) {
      console.log('loadChannelsInfo error: ', error);
    }
  };

  const loadChannelsCount = async () => {
    try {
      const count = await getChannelCount({ deviceId: DEVICE_ID });
      console.log('channels count is: ', count);
    } catch (error) {
      console.log('loadChannelCount error: ', error);
    }
  };

  const devicePTZSend = async (command: number, bStop: boolean) => {
    try {
      const count = await devicePTZcontrol({
        deviceId: DEVICE_ID,
        deviceChannel: activeChannel,
        command,
        bStop,
        speed: PTZSpeed,
      });
      console.log('channels count is: ', count);
    } catch (error) {
      console.log('devicePTZSend error: ', error);
    }
  };

  const checkDeviceFunctionSupport = async () => {
    try {
      const result = await isDeviceFunctionSupport({
        deviceId: DEVICE_ID,
        functionName: 'OtherFunction',
        functionCommandStr: 'SupportPTZTour',
      });
      console.log('OtherFunction is: ', result);
    } catch (error) {
      console.log('checkDeviceFunctionSupport error: ', error);
    }
  };

  const loadDeviceModel = async () => {
    try {
      const result = await getDeviceModel({
        deviceId: DEVICE_ID,
      });
      console.log('getDeviceModel is: ', result);
    } catch (error) {
      console.log('getDeviceModel error: ', error);
    }
  };

  const loadSoftWareVersion = async () => {
    try {
      const result = await getSoftWareVersion({
        deviceId: DEVICE_ID,
      });
      console.log('getDeviceModel is: ', result);
    } catch (error) {
      console.log('getDeviceModel error: ', error);
    }
  };

  const loadDeviceInfo = async () => {
    try {
      const result = await getBuildTime({
        deviceId: DEVICE_ID,
      });
      console.log('getBuildTime is: ', result);
    } catch (error) {
      console.log('getDeviceModel error: ', error);
    }
  };

  const startPlay = () => {
    console.log('startPlay');
    console.log('startPlay', getMonitor(activeChannel));
    getMonitor(activeChannel)?.current?.playVideo();
    // monitorRef.current?.playVideo();
    // monitorRef2.current?.playVideo();
  };

  if (!isInit) {
    return null;
  }

  if (!isLogged) {
    return (
      <View style={styles.container}>
        <TouchableOpacity style={styles.button} onPress={handleDeviceLogin}>
          <Text style={styles.buttonText}>device login</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <TouchableOpacity
        onPress={() => setActiveChannel(0)}
        style={{
          padding: 10,
          backgroundColor: activeChannel === 0 ? 'red' : 'transparent',
        }}
      >
        <Monitor
          devId={DEVICE_ID}
          channelId={0}
          style={styles.monitor}
          ref={monitorRef}
          onLayout={(event) => console.log('event: ', event.nativeEvent)}
          onStartInit={() => console.log('START INIT 1 CAMERA')}
          onMediaPlayState={(obj) => console.log('onMediaPlayState: ', obj)}
          onShowRateAndTime={(obj) => console.log('onShowRateAndTime: ', obj)}
          onVideoBufferEnd={(obj) => console.log('onVideoBufferEnd: ', obj)}
          onFailed={(obj) => console.log('onFailed: ', obj)}
          onDebugState={(obj) => console.log('onDebugState: ', obj)}
        />
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => setActiveChannel(1)}
        style={{
          padding: 10,
          backgroundColor: activeChannel === 1 ? 'red' : 'transparent',
        }}
      >
        <Monitor
          devId={DEVICE_ID}
          channelId={1}
          style={styles.monitor}
          ref={monitorRef2}
          onLayout={(event) => console.log('event: ', event.nativeEvent)}
          onStartInit={() => console.log('START INIT 2 CAMERA')}
          onMediaPlayState={(obj) => console.log('onMediaPlayState: ', obj)}
          onShowRateAndTime={(obj) => console.log('onShowRateAndTime: ', obj)}
          onVideoBufferEnd={(obj) => console.log('onVideoBufferEnd: ', obj)}
          onFailed={(obj) => console.log('onFailed: ', obj)}
          onDebugState={(obj) => console.log('onDebugState: ', obj)}
        />
      </TouchableOpacity>
      <ScrollView>
        <TouchableOpacity onPress={startPlay} style={styles.button}>
          <Text style={styles.buttonText}>startPlay</Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={() => {
            getMonitor(activeChannel)?.current?.switchStreamTypeMonitor();
            // if (activeChannel === 0) {
            //   monitorRef.current?.switchStreamTypeMonitor();
            // }

            // if (activeChannel === 1) {
            //   monitorRef2.current?.switchStreamTypeMonitor();
            // }
          }}
          style={styles.button}
        >
          <Text style={styles.buttonText}>swtichStream</Text>
        </TouchableOpacity>
        <Text style={styles.buttonText}>{PTZSpeed}</Text>
        <View style={{ flexDirection: 'row' }}>
          <TouchableOpacity
            onPress={() => setPTZSpeed((prev) => (prev + 1 > 8 ? 8 : prev + 1))}
            style={styles.button}
          >
            <Text style={styles.buttonText}>speed up</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => setPTZSpeed((prev) => (prev - 1 < 1 ? 1 : prev - 1))}
            style={styles.button}
          >
            <Text style={styles.buttonText}>speed down</Text>
          </TouchableOpacity>
        </View>
        <View style={{ flexDirection: 'row' }}>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.TILT_UP, false)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>up</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.TILT_UP, true)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>up stop</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.TILT_DOWN, false)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>down</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.TILT_DOWN, true)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>down stop</Text>
          </TouchableOpacity>
        </View>
        <View style={{ flexDirection: 'row' }}>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.PAN_LEFT, false)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>left start</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.PAN_LEFT, true)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>left stop</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.PAN_RIGHT, false)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>right start</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.PAN_RIGHT, true)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>right stop</Text>
          </TouchableOpacity>
        </View>
        <View style={{ flexDirection: 'row' }}>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.ZOOM_IN, false)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>zoomin</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.ZOOM_IN, true)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>zoomin stop</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.ZOOM_OUT, false)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>zoomout</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.ZOOM_OUT, true)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>zoomout stop</Text>
          </TouchableOpacity>
        </View>
        <View style={{ flexDirection: 'row' }}>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.FOCUS_FAR, true)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>focus far</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.FOCUS_NEAR, true)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>focus near</Text>
          </TouchableOpacity>
        </View>
        <TouchableOpacity onPress={loadChannelsCount} style={styles.button}>
          <Text style={styles.buttonText}>channel count</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={loadChannelsInfo} style={styles.button}>
          <Text style={styles.buttonText}>channel info</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={openVoice} style={styles.button}>
          <Text style={styles.buttonText}>open voice</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={closeVoice} style={styles.button}>
          <Text style={styles.buttonText}>closeVoice</Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={checkDeviceFunctionSupport}
          style={styles.button}
        >
          <Text style={styles.buttonText}>check support func</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={loadDeviceModel} style={styles.button}>
          <Text style={styles.buttonText}>loadDeviceModel</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={loadSoftWareVersion} style={styles.button}>
          <Text style={styles.buttonText}>loadSoftWareVersion</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={loadDeviceInfo} style={styles.button}>
          <Text style={styles.buttonText}>loadDeviceInfo</Text>
        </TouchableOpacity>
      </ScrollView>
    </View>
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
  },
});
