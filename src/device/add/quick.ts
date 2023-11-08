import { NativeEventEmitter, NativeModules } from 'react-native';

const funsdk = NativeModules.FunSDKDevQuickConnectModule;

export type StartSetWiFiParams = {
  passwordWifi: string;
};

/*
 * passwordWifi: string;
 */
export function startSetWiFi(params: StartSetWiFiParams): void {
  return funsdk.startSetWiFi(params);
}

export function stopSetWiFi(): Promise<boolean> {
  return funsdk.stopSetWiFi();
}

export enum WiFiListenersEnum {
  ON_SET_WIFI = 'onSetWiFi',
}

export const wifiEventModule = funsdk;
export const wifiEventEmitter = new NativeEventEmitter(wifiEventModule);

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
