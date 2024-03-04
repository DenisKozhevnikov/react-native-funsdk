import { NativeModules } from 'react-native';
import type {
  DeviceIdParams,
  DeviceManagerPromiseSuccessType,
  EFUN_ATTR,
} from './types';

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

// public static final int CONNECT_TYPE_P2P = 0;
// public static final int CONNECT_TYPE_TRANSMIT = 1;
// public static final int CONNECT_TYPE_IP = 2;
// public static final int CONNECT_TYPE_RPS = 5;
// public static final int CONNECT_TYPE_RTS_P2P = 6;
// public static final int CONNECT_TYPE_RTS = 7;
// 0:p2p连接，1转发模式 2:IP地址直连
export enum networkMode {
  P2P,
  FORWARDING,
  IP,
  RPS = 5,
  RTS_P2P,
  RTS,
}

export function getNetworkMode(
  params: DeviceIdParams
): Promise<{ value: networkMode }> {
  return funsdk.getNetworkMode(params);
}

export function getAccessToken(): Promise<string> {
  return funsdk.getAccessToken();
}

export type SecretPromiseSuccessType = {
  timeMillis: string;
  secret: string;
  uuid: string;
  appKey: string;
  appSecret: string;
  movedCard: number;
};

export function getSecret(): Promise<SecretPromiseSuccessType> {
  return funsdk.getSecret();
}

export function getFunStrAttr(params: {
  FunStrAttr: EFUN_ATTR;
}): Promise<string> {
  return funsdk.getFunStrAttr(params);
}

export function devGetLocalUserName(params: DeviceIdParams): Promise<string> {
  return funsdk.devGetLocalUserName(params);
}

export function getDevType(params: DeviceIdParams): Promise<number> {
  return funsdk.getDevType(params);
}

export function devGetLocalEncToken(params: DeviceIdParams): Promise<string> {
  return funsdk.devGetLocalEncToken(params);
}
