// ios
import { NativeModules } from 'react-native';
import type { DeviceManagerPromiseSuccessType } from '../manager';
export * from './types/@index';

const funsdk = NativeModules.FunSDKDevConfigModule;

type DevCmdGeneralParams = {
  deviceId: string;
  cmdReq: number; //1452
  cmd: string; // "OPTimeQuery"
  isBinary: number; // 0, 1430, 4096?
  timeout: number; // 5000
  param: string | null;
  inParamLen: number; // param.length ?
  cmdRes: number; // -1 || 0 ?
};

export function getDevCmdGeneral(params: DevCmdGeneralParams): Promise<any> {
  return funsdk.getDevCmdGeneral(params);
}

export type GetDevConfigParams = {
  deviceId: string;
  name: string; // имя запрашиваемой конфигурации
  nOutBufLen: number; // 0
  channel: number; // -1 === все?
  timeout: number;
};

export function getDevConfig(params: GetDevConfigParams): Promise<any> {
  return funsdk.getDevConfig(params);
}

export type SetDevConfigParams = {
  deviceId: string;
  name: string;
  param: string; // json преобразованный в строку
  channel: number;
  timeout: number;
};

export function setDevConfig(params: SetDevConfigParams): Promise<
  DeviceManagerPromiseSuccessType & {
    value: any;
  }
> {
  return funsdk.setDevConfig(params);
}
