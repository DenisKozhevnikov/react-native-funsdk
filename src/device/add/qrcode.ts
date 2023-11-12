import { NativeEventEmitter, NativeModules } from 'react-native';

const funsdk = NativeModules.FunSDKDevQRCodeConnectModule;

export type StartSetByQRCodeParams = {
  passwordWifi: string;
  isDevDeleteFromOthersUsers: boolean;
};

/**
 * passwordWifi: string;
 * isDevDeleteFromOthersUsers: boolean;
 */
export function startSetByQRCode(params: StartSetByQRCodeParams): void {
  return funsdk.startSetByQRCode(params);
}

export function stopSetByQRCode(): Promise<boolean> {
  return funsdk.stopSetByQRCode();
}

export enum QRCodeListenersEnum {
  ON_SET_WIFI = 'onSetWiFi',
  ON_ADD_DEVICE_STATUS = 'onAddDeviceStatus',
}

export type OnAddQRDeviceStatusType = {
  status: string | 'error' | 'start' | 'error-wifi';
  errorId: number | null;
  msgId: number | null;
  base64Image?: string;
};

export const qrCodeEventModule = funsdk;
export const qrCodeEventEmitter = new NativeEventEmitter(qrCodeEventModule);

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
