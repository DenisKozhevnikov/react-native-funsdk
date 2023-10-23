import React, { useRef } from 'react';
import { StyleSheet, View, Text } from 'react-native';
import {
  funSDKInit,
  getUserId,
  getUserName,
  loginByAccount,
  // logout,
  // registerByNotBind,
  getDeviceList,
  addDevice,
  RecordPlayer,
  updateAllDevStateFromServer,
  getDetailDeviceList,
  loginDeviceWithCredential,
  SearcResultRecordFile,
  RecordPlayerRef,
  // hasLogin,
} from 'react-native-funsdk';
import { RecordList } from './list';
import { RecordButtons } from './buttons';
import {
  DEVICE_ID,
  DEVICE_LOGIN,
  DEVICE_PASSWORD,
  USER_NAME,
  USER_PASSWORD,
} from '../topsecretdata';

export const RecordPage = () => {
  const playerRef = useRef<RecordPlayerRef>(null);
  const [isInit, setIsInit] = React.useState(false);

  const [recordList, setRecordList] = React.useState<
    SearcResultRecordFile[] | null
  >(null);

  React.useEffect(() => {
    if (isInit) {
      return;
    }
    funSDKInit();
    const someFuncs = async () => {
      try {
        // const res = await loginByAccount({
        //   username: '',
        //   password: '',
        // });
        console.log('start somefunc');
        const res = await loginByAccount({
          username: USER_NAME,
          password: USER_PASSWORD,
        });
        // const res = await registerByNotBind({
        //   username: '',
        //   password: '',
        // });
        console.log('res somefunc: ', res);
        await someInfos();
      } catch (error) {
        console.log('error in someFuncs: ', error);
      }
    };
    const someInfos = async () => {
      try {
        const userId = await getUserId();
        const userName = await getUserName();
        const deviceList = await getDeviceList();
        console.log('res someinfos: ', userId, userName, deviceList);
        await addDeviceTest();
        const updatedStatus = await updateAllDevStateFromServer();
        console.log('updatedStatus: ', updatedStatus);
        const detailedList = await getDetailDeviceList();
        console.log('detailedList: ', detailedList);

        const loginstatus = await loginDeviceWithCredential({
          deviceId: DEVICE_ID,
          deviceLogin: DEVICE_LOGIN,
          devicePassword: DEVICE_PASSWORD,
        });
        console.log('loginstatus: ', loginstatus);
        setIsInit(true);
      } catch (error) {
        console.log('error: ', error);
      }
    };
    const addDeviceTest = async () => {
      try {
        const addedDevice = await addDevice({
          deviceId: DEVICE_ID,
          username: DEVICE_LOGIN,
          password: DEVICE_PASSWORD,
          deviceType: 'no need',
          deviceName: 'supername',
        });
        console.log('addedDevice: ', addedDevice);
        const deviceList = await getDeviceList();
        console.log('deviceList: ', deviceList);
      } catch (error) {
        console.log('error on add device: ', error);
      }
    };
    setTimeout(() => {
      someFuncs();
    }, 2000);
  }, [isInit]);

  if (!isInit) {
    return null;
  }

  return (
    <View style={styles.container}>
      <RecordPlayer
        ref={playerRef}
        style={styles.monitor}
        devId={DEVICE_ID}
        onMediaPlayState={(ev) => console.log('onMediaPlayState: ', ev)}
        onShowRateAndTime={(ev) => console.log('onShowRateAndTime: ', ev)}
        onVideoBufferEnd={(ev) => console.log('onVideoBufferEnd: ', ev)}
        onSearchRecordByFilesResult={(ev) => {
          // console.log(ev);
          if (ev?.list) {
            setRecordList(ev?.list);
          }
        }}
        onFailed={(obj) => console.log('onFailed: ', obj)}
        onStartInit={() => console.log('onStartInit: ')}
        onDebugState={(obj) => console.log('DEBUG STATE: ', obj)}
      />
      <RecordButtons playerRef={playerRef.current} />
      <Text>list of recordlist</Text>
      <RecordList recordList={recordList} playerRef={playerRef.current} />
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
    // height: 200,
    aspectRatio: 16 / 9,
    // backgroundColor: 'yellow',
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
