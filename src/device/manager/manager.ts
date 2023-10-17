import { NativeModules } from 'react-native';

const funsdk = NativeModules.FunSDKDevStatusModule;

export type DeviceManagerPromiseSuccessType = {
  s: string;
  i: number;
};

export type DeviceIdParams = {
  deviceId: string;
};

export type DeviceCredentialParams = {
  deviceId: string;
  deviceLogin: string;
  devicePassword: string;
};

export function loginDevice(
  params: DeviceCredentialParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.loginDevice(params);
}

export function loginDeviceWithCredential(
  params: DeviceCredentialParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.loginDeviceWithCredential(params);
}

// export function loginDeviceByLowPower(
//   params: DeviceCredentialParams
// ): Promise<DeviceManagerPromiseSuccessType> {
//   return funsdk.loginDeviceByLowPower(params);
// }

// export function loginDeviceByLowPowerWithCredential(
//   params: DeviceCredentialParams
// ): Promise<DeviceManagerPromiseSuccessType> {
//   return funsdk.loginDeviceByLowPowerWithCredential(params);
// }

// export function wakeUpAndSendCtrl(
//   params: DeviceCredentialParams
// ): Promise<DeviceManagerPromiseSuccessType> {
//   return funsdk.loginDeviceByLowPowerWithCredential(params);
// }

export function logoutDevice(params: DeviceIdParams): Promise<true> {
  return funsdk.logoutDevice(params);
}

export function getChannelInfo(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getChannelInfo(params);
}

export function getChannelCount(params: DeviceIdParams): Promise<number> {
  return funsdk.getChannelCount(params);
}

// export function setLocalDeviceUserPassword(
//   params: DeviceCredentialParams
// ): Promise<'success'> {
//   return funsdk.getChannelCount(params);
// }

export type LocalLoginInfoParams = DeviceCredentialParams & {
  token: string;
};

// export function setLocalLoginInfo(
//   params: LocalLoginInfoParams
// ): Promise<'success'> {
//   return funsdk.setLocalLoginInfo(params);
// }

export type ModifyDevicePasswordParams = DeviceCredentialParams & {
  deviceNewPassword: string;
};

export function modifyDevicePassword(
  params: ModifyDevicePasswordParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.modifyDevicePassword(params);
}

export type ModifyDeviceNameParams = DeviceIdParams & {
  deviceName: string;
};

export function modifyDeviceName(
  params: ModifyDevicePasswordParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.modifyDevicePassword(params);
}

export type DevicePTZControlParams = {
  deviceId: string;
  command: number;
  bStop: boolean;
  deviceChannel: number;
};

export function devicePTZcontrol(
  params: DevicePTZControlParams
): Promise<boolean> {
  return funsdk.devicePTZControl(params);
}

export function resetDeviceConfig(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.resetDeviceConfig(params);
}

export function rebootDevice(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.rebootDevice(params);
}

export type CaptureFromDeviceAndSaveToDeviceParams = {
  deviceId: string;
  deviceChannel: number;
};

export function captureFromDeviceAndSaveToDevice(
  params: CaptureFromDeviceAndSaveToDeviceParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.captureFromDeviceAndSaveToDevice(params);
}
