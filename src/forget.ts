import { NativeModules } from 'react-native';

const funsdk = NativeModules.FunSDKForgetModule;

export type ForgetCheckPwdParams = {
  password: string;
};

/*
 * password: string;
 */
export function forgetCheckPwd(params: ForgetCheckPwdParams): Promise<any> {
  return funsdk.checkPwd(params);
}

export type RequestSendEmailCodeForResetPWParams = {
  email: string;
};

/*
 * email: string;
 */
export function requestSendEmailCodeForResetPW(
  params: RequestSendEmailCodeForResetPWParams
): Promise<any> {
  return funsdk.requestSendEmailCodeForResetPW(params);
}

export type RequestSendPhoneMsgForResetPWParams = {
  phoneNumber: string;
};

/*
 * phoneNumber: string;
 */
export function requestSendPhoneMsgForResetPW(
  params: RequestSendPhoneMsgForResetPWParams
): Promise<any> {
  return funsdk.requestSendPhoneMsgForResetPW(params);
}

export type RequestVerifyEmailCodeParams = {
  email: string;
  verifyCode: string;
};

/*
 * email: string;
 * verifyCode: string;
 */
export function requestVerifyEmailCode(
  params: RequestVerifyEmailCodeParams
): Promise<any> {
  return funsdk.requestVerifyEmailCode(params);
}

export type RequestVerifyPhoneCodeParams = {
  phoneNumber: string;
  verifyCode: string;
};

/*
 * phoneNumber: string;
 * verifyCode: string;
 */
export function requestVerifyPhoneCode(
  params: RequestVerifyEmailCodeParams
): Promise<any> {
  return funsdk.requestVerifyPhoneCode(params);
}

export type RequestResetPasswByEmailParams = {
  phoneNumber: string;
  verifyCode: string;
};

/*
 * phoneNumber: string;
 * verifyCode: string;
 */
export function requestResetPasswByEmail(
  params: RequestResetPasswByEmailParams
): Promise<any> {
  return funsdk.requestResetPasswByEmail(params);
}

export type RequestResetPasswByPhoneParams = {
  phoneNumber: string;
  newPassword: string;
};

/*
 * phoneNumber: string;
 * newPassword: string;
 */
export function requestResetPasswByPhone(
  params: RequestResetPasswByEmailParams
): Promise<any> {
  return funsdk.requestResetPasswByPhone(params);
}
