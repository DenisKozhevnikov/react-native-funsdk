import { NativeModules } from 'react-native';

const funsdk = NativeModules.FunSDKDevSnConnectModule;

export type AddDeviceParams = {
  deviceId: string;
  username: string;
  password: string;
  deviceName: string;
  deviceType: string;
};

/*
 * deviceId: string;
 * username: string;
 * password: string;
 * deviceType: string;
 */
export function addDevice(params: AddDeviceParams): Promise<any> {
  return funsdk.addDev(params);
}

export type DeleteDeviceParams = {
  deviceId: string;
};

export function deleteDevice(params: DeleteDeviceParams): Promise<any> {
  return funsdk.deleteDev(params);
}
