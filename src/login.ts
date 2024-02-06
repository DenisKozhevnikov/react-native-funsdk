import { NativeModules } from 'react-native';

const funsdk = NativeModules.FunSDKLoginModule;

export type LoginByAccountParams = {
  username: string;
  password: string;
};

/**
 * username: string;
 * password: string;
 */
export function loginByAccount(params: LoginByAccountParams): Promise<any> {
  return funsdk.loginByAccount(params);
}

export type LoginByLocalParams = {};
/**
 * does not work
 */
export function loginByLocal(params: LoginByLocalParams): Promise<any> {
  return funsdk.loginByAccount(params);
}

export type LoginByAPParams = {};
/**
 * does not work
 */
export function loginByAP(params: LoginByAPParams): Promise<any> {
  return funsdk.loginByAccount(params);
}
