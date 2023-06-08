import { NativeModules } from 'react-native';

const funsdk = NativeModules.FunSDKDevListConnectModule;

export function getDeviceList(): Promise<any> {
  return funsdk.getDevList();
}

export type GetDeviceStateParams = {
  deviceId: string;
};

/*
 * deviceId: string;
 */
export function getDeviceState(params: GetDeviceStateParams): Promise<any> {
  return funsdk.getDevState(params);
}
