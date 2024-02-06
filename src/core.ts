import { NativeModules } from 'react-native';

const funsdk = NativeModules.FunSDKCoreModule;

export enum CUSTOM_PWD_TYPE {
  E_PWD_GENERAL, // Default, universal encryption (MD5 encryption)
  E_PWD_QUNGUANG, // is a special case before compatibility. Prefix is "QunGuang_". Prefix is added before encryption
  E_PWD_PREFIX_BEFORE_ENCRYPT, // Prefix is added before encryption
  E_PWD_PREFIX_BACK_ENCRYPT, // Add the prefix after encryption
  E_PWD_GIGA, // giga is a special case before compatibility. After encryption, prefix is added. json parameter szEncType is passed to the device: "GIGA" (other default values are "MD5").
  E_PWD_CUSTOM_MAX,
}

export type FunSDKInitParams = {
  customPwdType?: CUSTOM_PWD_TYPE | number; // 0
  customPwd?: string;
  customServerAddr?: string;
  customPort?: number;
};

// export function funSDKInit(params: FunSDKInitParams): Promise<any> {
export function funSDKInit(params: FunSDKInitParams = {}): Promise<any> {
  return funsdk.init(params);
}
