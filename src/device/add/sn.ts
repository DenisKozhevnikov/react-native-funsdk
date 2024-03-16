import { NativeModules } from 'react-native';
import type { DEVICE } from '../../types/index';

const funsdk = NativeModules.FunSDKDevSnConnectModule;

// previous
// export type AddDeviceParams = {
//   deviceId: string;
//   username: string;
//   password: string;
//   deviceName: string;
//   deviceType: string;
// };
export type AddDeviceParams = {
  // SerialNumber / IP / DNS
  deviceId?: string;
  username?: string;
  password?: string;
  deviceName?: string;
  deviceType?: DEVICE.TYPE;
  deviceIp?: string;
  DMZTcpPort?: number;
  deviceIdNum?: number;
};

/**
 * deviceId can be as:
 *
 * SerialNumber / IP / DNS
 *
 *
 * add dev by deviceId:
 *
 *  deviceId: string;
 *  username: string;
 *  password: string;
 *  deviceName: string;
 */
export function addDevice(params: AddDeviceParams): Promise<any> {
  console.log('params: ', params);
  return funsdk.addDev(params);
}

export type DeleteDeviceParams = {
  deviceId: string;
};

/**
 * status number in answer
 */
export function deleteDevice(params: DeleteDeviceParams): Promise<number> {
  return funsdk.deleteDev(params);
}
