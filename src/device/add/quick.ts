import { NativeEventEmitter, NativeModules } from 'react-native';

const funsdk = NativeModules.FunSDKDevQuickConnectModule;

export type StartSetWiFiParams = {
  // ssidWifi обязательно для iOS, в Android используется текущий
  ssidWifi: string;
  passwordWifi: string;
  isDevDeleteFromOthersUsers: boolean;
};

/**
 * passwordWifi: string;
 * isDevDeleteFromOthersUsers: boolean;
 */
export function startSetWiFi(params: StartSetWiFiParams): void {
  return funsdk.startSetWiFi(params);
}

export function stopSetWiFi(): Promise<boolean> {
  return funsdk.stopSetWiFi();
}

export enum WiFiListenersEnum {
  ON_SET_WIFI = 'onSetWiFi',
  ON_ADD_DEVICE_STATUS = 'onAddDeviceStatus',
}

export type OnAddDeviceStatusType = {
  status: string | 'error' | 'start' | 'error-wifi' | 'success';
  errorId: number | null;
  msgId: number | null;
  deviceData: {
    devId: string;
    devName: string;
    devUserName: string;
    devPassword: string;
    devIp: string;
    devPort: number;
    devType: number;
    devState: number;
    string: string;
    pid: string;
    mac: string;
    devToken: string;
    cloudCryNum: string;
  } | null;
};

export const wifiEventModule = funsdk;
export const wifiEventEmitter = new NativeEventEmitter(funsdk);

// listener example
// useEffect(() => {
//   const wifiEventEmitter = new NativeEventEmitter(wifiEventModule);
//   let eventListener = wifiEventEmitter.addListener(
//     WiFiListenersEnum.ON_SET_WIFI,
//     (event) => {
//       console.log('event: ', event); // "someValue"
//     }
//   );

//   // Removes the listener once unmounted
//   return () => {
//     eventListener.remove();
//   };
// }, []);
