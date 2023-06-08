import { NativeModules } from 'react-native';

const funsdk = NativeModules.FunSDKRegisterModule;

export type UserCheckParams = {
  username: string;
};

export function userCheck(params: UserCheckParams): Promise<any> {
  return funsdk.userCheck(params);
}

export type SendEmailCodeParams = {
  email: string;
};

export function sendEmailCode(params: SendEmailCodeParams): Promise<any> {
  return funsdk.emailCode(params);
}

export type SendPhoneCodeParams = {
  username: string;
  phoneNumber: string;
};

export function sendPhoneCode(params: SendPhoneCodeParams): Promise<any> {
  return funsdk.phoneMsg(params);
}

export type RegisterByPhoneParams = {
  username: string;
  password: string;
  verifyCode: string;
  phoneNumber: string;
};

export function registerByPhone(params: RegisterByPhoneParams): Promise<any> {
  return funsdk.registerPhone(params);
}

export type RegisterByEmailParams = {
  username: string;
  password: string;
  email: string;
  verifyCode: string;
};

export function registerByEmail(params: RegisterByEmailParams): Promise<any> {
  return funsdk.registerEmail(params);
}

export type RegisterByNotBindParams = {
  username: string;
  password: string;
};

export function registerByNotBind(
  params: RegisterByNotBindParams
): Promise<any> {
  return funsdk.registerByNotBind(params);
}
