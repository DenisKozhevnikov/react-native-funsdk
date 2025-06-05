import { NativeModules } from 'react-native';

const funsdk = NativeModules.FunSDKDevLanConnectModule;

export type SearchDeviceType = {
  devId: string;
  deviceName: string;
  deviceIp: string;
  port: string;
  deviceType: string;
};

export type SearchDeviceParams = {
  timeout?: number;
};

export function searchDevice(
  params?: SearchDeviceParams
): Promise<SearchDeviceType[]> {
  return funsdk.searchDevice({
    timeout: 10000,
    ...params,
  });
}
