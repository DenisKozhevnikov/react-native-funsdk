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

// Параметры для поиска устройств
export interface QuickSearchDeviceParams {
  ssidWifi: string;
  passwordWifi: string;
}

// Данные найденного устройства
export interface FoundDeviceData {
  devId: string; // deviceMac
  devType: number; // deviceType
  devName: string; // deviceName
  devUserName: string; // loginName
  devPassword: string; // loginPassword
  withRandomPassword: boolean;
  randomUserData?: {
    userName: string;
    password: string;
    random: boolean;
  };
}

// Параметры для добавления устройства
export interface AddFoundDeviceParams {
  deviceMac: string;
  deviceName?: string;
  loginName?: string;
  loginPassword?: string;
  deviceType?: number;
}

// Результат добавления устройства
export interface AddFoundDeviceResult {
  success: boolean;
  deviceMac: string;
  deviceName: string;
  message: string;
}
/**
 * Поиск устройств через WiFi конфигурацию
 * @param params Параметры для поиска устройств
 */
export function startQuickDeviceSearch(params: QuickSearchDeviceParams): void {
  return funsdk.startDeviceSearch(params);
}

/**
 * Добавление найденного устройства
 * @param deviceInfo Данные устройства для добавления
 * @returns Promise с результатом добавления
 */
export function addFoundDevice(
  deviceInfo: AddFoundDeviceParams
): Promise<AddFoundDeviceResult> {
  return funsdk.addFoundDevice(deviceInfo);
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
