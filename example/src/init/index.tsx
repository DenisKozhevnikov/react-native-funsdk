import {
  funSDKInit,
  getUserId,
  getUserName,
  loginByAccount,
  // logout,
  // registerByNotBind,
  getDeviceList,
  addDevice,
  updateAllDevStateFromServer,
  getDetailDeviceList,
  loginDeviceWithCredential,
  // hasLogin,
} from 'react-native-funsdk';
import {
  DEVICE_ID,
  DEVICE_LOGIN,
  DEVICE_PASSWORD,
  PORT,
  PWD,
  PWD_TYPE,
  SERVER_ADDR,
  USER_NAME,
  USER_PASSWORD,
} from '../topsecret';
import React from 'react';

export const useInit = () => {
  const [isInit, setIsInit] = React.useState(false);
  const [statusText, setStatusText] = React.useState<null | {
    text: string;
    value?: any;
  }>(null);

  const handleSetStatus = (text: string, value?: any) => {
    setStatusText({
      text,
      value,
    });
  };

  React.useEffect(() => {
    if (isInit) {
      return;
    }

    funSDKInit({
      customPwdType: PWD_TYPE,
      customPwd: PWD,
      customServerAddr: SERVER_ADDR,
      customPort: PORT,
    });
    const someFuncs = async () => {
      try {
        // const res = await loginByAccount({
        //   username: '',
        //   password: '',
        // });
        console.log('start somefunc');
        handleSetStatus('start somefunc');
        const res = await loginByAccount({
          username: USER_NAME,
          password: USER_PASSWORD,
        });
        // const res = await registerByNotBind({
        //   username: '',
        //   password: '',
        // });
        console.log('res somefunc: ', res);
        handleSetStatus('res somefunc: ', res);
        await someInfos();
      } catch (error) {
        console.log('error in someFuncs: ', error);
        handleSetStatus('error in someFuncs: ', error);
      }
    };
    const someInfos = async () => {
      try {
        const userId = await getUserId();
        const userName = await getUserName();
        const deviceList = await getDeviceList();
        console.log('res someinfos: ', userId, userName, deviceList);
        handleSetStatus('res someinfos: ', { userId, userName, deviceList });
        await addDeviceTest();
        const updatedStatus = await updateAllDevStateFromServer();
        console.log('updatedStatus: ', updatedStatus);
        handleSetStatus('updatedStatus: ', updatedStatus);
        const detailedList = await getDetailDeviceList();
        console.log('detailedList: ', detailedList);
        handleSetStatus('detailedList: ', detailedList);

        const loginstatus = await loginDeviceWithCredential({
          deviceId: DEVICE_ID,
          deviceLogin: DEVICE_LOGIN,
          devicePassword: DEVICE_PASSWORD,
        });
        console.log('loginstatus: ', loginstatus);
        handleSetStatus('loginstatus: ', loginstatus);
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

  return { isInit, statusText };
};
