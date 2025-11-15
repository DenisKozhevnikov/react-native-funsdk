import React from 'react';
import {
  addDevice,
  funSDKInit,
  getDetailDeviceList,
  loginByAccount,
  loginDeviceWithCredential,
  updateAllDevStateFromServer,
  logout,
  registerByNotBind,
  updateAreaCode,
} from 'react-native-funsdk';
import {
  APPKEY,
  APPSECRET,
  APPUUID,
  DEVICE_ID,
  DEVICE_LOGIN,
  DEVICE_PASSWORD,
  MOVECARD,
  PORT,
  PWD,
  PWD_TYPE,
  SERVER_ADDR,
} from '../topsecret';
import { Platform } from 'react-native';

type Credentials = {
  username: string;
  password: string;
};

const delay = (ms: number) => {
  return new Promise((resolve) => setTimeout(resolve, ms));
};

export const useInit = () => {
  const [isInit, setIsInit] = React.useState(false);
  const [isAuth, setIsAuth] = React.useState(false);
  const [statusText, setStatusText] = React.useState<null | {
    text: string;
    value?: any;
  }>(null);

  const setStatus = (text: string, value?: any) => {
    setStatusText({
      text,
      value,
    });
  };

  const logoutsdk = async () => {
    try {
      const res = await logout();
      setIsAuth(false);
      console.log('logoutsdk res: ', res);
    } catch (error) {
      console.log('logoutsdk error: ', logoutsdk);
    }
  };

  const reinit = async (credentials: Credentials) => {
    try {
      initSDK();
      updateAreaCode();
      await delay(1000);
      console.log('start somefunc');
      setStatus('start somefunc');
      someFuncs(credentials);
    } catch (error) {
      console.log('error in someFuncs: ', error);
      setStatus('error in someFuncs: ', (error as Error)?.message);
    }
  };

  const someFuncs = async (credentials: Credentials) => {
    const { username, password } = credentials;

    try {
      console.log('start somefunc');
      setStatus('start somefunc');
      const res = await loginByAccount({
        username,
        password,
      });
      console.log('res somefunc: ', res);
      setStatus('res somefunc: ', res);
      setIsAuth(true);
      await someInfos();
    } catch (error) {
      console.log('error in someFuncs: ', error);
      setStatus('error in someFuncs: ', (error as Error)?.message);

      // Пользователь не зареган?
      if ((error as Error)?.message.includes('-604025')) {
        const res = await registerByNotBind({
          username,
          password,
        }).then(() => {
          console.log('res registerByNotBind: ', res);
          setStatus('res registerByNotBind: ', res);
          someFuncs(credentials);
        });
      }
    }
  };
  const someInfos = async () => {
    try {
      await delay(100);

      await addDeviceTest();
      const updatedStatus = await updateAllDevStateFromServer();
      console.log('updatedStatus: ', updatedStatus);
      setStatus('updatedStatus: ', updatedStatus);

      await delay(100);
      const detailedList = await getDetailDeviceList();
      console.log('detailedList: ', JSON.stringify(detailedList, null, 2));
      setStatus('detailedList: ', detailedList);

      await delay(100);
      const loginstatus = await loginDeviceWithCredential({
        deviceId: DEVICE_ID,
        deviceLogin: DEVICE_LOGIN,
        devicePassword: DEVICE_PASSWORD,
      });

      console.log('loginstatus: ', loginstatus);
      setStatus('loginstatus: ', loginstatus);
    } catch (error) {
      console.log('error someInfos: ', error);
      setStatus('error in someFuncs: ', (error as Error)?.message);
    } finally {
      setIsInit(true);
    }
  };
  const addDeviceTest = async () => {
    try {
      const addedDevice = await addDevice({
        deviceId: DEVICE_ID,
        username: DEVICE_LOGIN,
        password: DEVICE_PASSWORD,
        // deviceType: 'no need',
        deviceName: 'supername2',
      });
      console.log('addedDevice: ', addedDevice);
      // const deviceList = await getDeviceList();
      // console.log('deviceList: ', deviceList);
    } catch (error) {
      console.log('error on add device: ', error);
    }
  };

  const initSDK = async () => {
    // funSDKInit({});
    if (Platform.OS === 'ios') {
      await funSDKInit({
        customPwdType: PWD_TYPE,
        customPwd: PWD,
        customServerAddr: SERVER_ADDR,
        customPort: PORT,
        APPUUID,
        APPKEY,
        APPSECRET,
        MOVECARD,
        // TODO: удалить then
      });

      console.log('funsdkinit success');
    }

    if (Platform.OS === 'android') {
      funSDKInit({
        customPwdType: PWD_TYPE,
        customPwd: PWD,
        customServerAddr: SERVER_ADDR,
        customPort: PORT,
        APPUUID,
        APPKEY,
        APPSECRET,
      });
      // setIsInit(true);
    }

    setIsInit(true);
  };

  // React.useEffect(() => {
  //   if (isInit) {
  //     return;
  //   }

  //   initSDK();
  //   // setTimeout(() => {
  //   //   someFuncs();
  //   // }, 3000);
  // }, [isInit]);

  return { isInit, isAuth, statusText, reinit, logoutsdk };
};
