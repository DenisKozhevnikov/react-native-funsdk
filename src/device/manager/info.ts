import { NativeModules } from 'react-native';
import type { DeviceIdParams, DeviceManagerPromiseSuccessType } from './types';

const funsdk = NativeModules.FunSDKDevStatusModule;

type IsDeviceFunctionSupportParams = {
  deviceId: string;
  functionName: string;
  functionCommandStr: string;
};

export function isDeviceFunctionSupport(
  params: IsDeviceFunctionSupportParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.isDeviceFunctionSupport(params);
}

export function getDeviceModel(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getDeviceModel(params);
}

export function getSoftWareVersion(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getSoftWareVersion(params);
}

export function getBuildTime(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getBuildTime(params);
}

export function getHardWare(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getHardWare(params);
}

export function getDigChannel(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getDigChannel(params);
}

export function getExtraChannel(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getExtraChannel(params);
}

export function getVideoInChannel(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getVideoInChannel(params);
}

export function getTalkInChannel(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getTalkInChannel(params);
}

export function getAlarmInChannel(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getAlarmInChannel(params);
}

export function getAlarmOutChannel(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getAlarmOutChannel(params);
}

export function getCombineSwitch(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getCombineSwitch(params);
}

export function getVideoOutChannel(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getVideoOutChannel(params);
}

export function getAudioInChannel(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getAudioInChannel(params);
}

export function getTalkOutChannel(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getTalkOutChannel(params);
}

export function getUpdataTime(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getUpdataTime(params);
}

export function getEncryptVersion(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getEncryptVersion(params);
}

export function getDeviceRunTime(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getDeviceRunTime(params);
}

export function getHardWareVersion(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getHardWareVersion(params);
}

export function getMcuVersion(
  params: DeviceIdParams
): Promise<DeviceManagerPromiseSuccessType> {
  return funsdk.getMcuVersion(params);
}