import { NativeModules } from 'react-native';

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

export function getDetailDeviceList(): Promise<any> {
  return funsdk.getDetailDeviceList();
}

export function updateAllDevStateFromServer(): Promise<any> {
  return funsdk.updateAllDevStateFromServer();
}
