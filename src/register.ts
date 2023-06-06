import { NativeModules } from 'react-native';

const funsdk = NativeModules.FunSDKRegisterModule;

export function registerByNotBind(
  params: RegisterByNotBindParams
): Promise<any> {
  return funsdk.registerByNotBind(params);
}

export type RegisterByNotBindParams = {
  username: string;
  password: string;
};
