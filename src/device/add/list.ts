import { NativeModules } from 'react-native';
import type { DEVICE } from 'src/types';

const funsdk = NativeModules.FunSDKDevListConnectModule;

export function getDeviceList(): Promise<any> {
  return funsdk.getDevList();
}

export type GetDeviceStateParams = {
  deviceId: string;
};

// OFF_LINE：0  offline
// ON_LINE：1 online
// SLEEP：2 Sleeping (low-power devices)
// WAKE_UP：3 Waking up (low power device)
// WAKE：4  Woke up (low power device)
// SLEEP_UNWAKE：5  Unwakeable during sleep (low power device)
// PREPARE_SLEEP：6 Preparing for Sleep (low power device)
/*
 * deviceId: string;
 */
export function getDeviceState(params: GetDeviceStateParams): Promise<any> {
  return funsdk.getDevState(params);
}

export type DetailDeviceType = {
  devId: string;
  devIp: string;
  devIpPort: string;
  devName: string;
  devPort: number;
  devState: number;
  devType: DEVICE.TYPE;
};

export function getDetailDeviceList(): Promise<DetailDeviceType[]> {
  return funsdk.getDetailDeviceList();
}

export function updateAllDevStateFromServer(): Promise<any> {
  return funsdk.updateAllDevStateFromServer();
}
