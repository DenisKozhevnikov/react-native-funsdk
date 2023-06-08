import { NativeModules } from 'react-native';

const funsdk = NativeModules.FunSDKModifyModule;

export type CheckPwdParams = {
  password: string;
};

export function checkPwd(params: CheckPwdParams): Promise<any> {
  return funsdk.checkPwd(params);
}

export type ChangePwdParams = {
  username: string;
  currentPassword: string;
  newPassword: string;
};

export function changePwd(params: ChangePwdParams): Promise<any> {
  return funsdk.modifyPwd(params);
}
