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
  customPwdType: CUSTOM_PWD_TYPE | number; // 0
  customPwd: string;
  customServerAddr: string;
  customPort: number;
  // iOS
  APPUUID?: string;
  APPKEY?: string;
  APPSECRET?: string;
  MOVECARD?: number;
};

// export function funSDKInit(params: FunSDKInitParams): Promise<any> {
export function funSDKInit(params: FunSDKInitParams): Promise<any> {
  return funsdk.init(params);
}

export type FunSDKReInitParams = {
  appUuid: string; // APP_UUID from open platform (https://oppf.xmcsrv.com)
  appKey: string; // APP_KEY from open platform
  appSecret: string; // APP_SECRET from open platform
  appMovedCard: number; // APP_MOVECARD from open platform (usually 2)
  // Optional custom P2P server configuration
  customPwdType?: CUSTOM_PWD_TYPE | number;
  customPwd?: string;
  customServerAddr?: string;
  customPort?: number;
};

/**
 * Re-initialize FunSDK with custom open platform credentials
 * 重新初始化SDK - 使用开放平台申请的AppKey、AppSecret等参数
 *
 * Register at: https://oppf.xmcsrv.com/#/docs?md=readGuide
 * 1. Create Android app in console
 * 2. Get AppKey, AppSecret, AppUuid, MovedCard after approval
 * 3. Call this method to re-initialize SDK with your credentials
 *
 * @param params - Open platform credentials
 * @example
 * ```typescript
 * import { funSDKReInitByUser } from 'react-native-funsdk';
 *
 * funSDKReInitByUser({
 *   appUuid: 'your-app-uuid',
 *   appKey: 'your-app-key',
 *   appSecret: 'your-app-secret',
 *   appMovedCard: 2
 * });
 * ```
 */
export function funSDKReInitByUser(params: FunSDKReInitParams): void {
  funsdk.reInitByUser(params);
}

export type FunSDKSysSetServerIPPortParams = {
  serverKey:
    | 'APP_SERVER'
    | 'STATUS_P2P_SERVER'
    | 'STATUS_DSS_SERVER'
    | 'STATUS_RPS_SERVER'
    | 'STATUS_IDR_SERVER'
    | 'HLS_DSS_SERVER'
    | 'CONFIG_SERVER'
    | 'UPGRADE_SERVER'
    | 'CAPS_SERVER'
    | string;
  serverIpOrDomain: string;
  serverPort: number;
};

/**
 * Use after initialization
 * 
 * server keys: 'APP_SERVER'
    , 'STATUS_P2P_SERVER'
    , 'STATUS_DSS_SERVER'
    , 'STATUS_RPS_SERVER'
    , 'STATUS_IDR_SERVER'
    , 'HLS_DSS_SERVER'
    , 'CONFIG_SERVER'
    , 'UPGRADE_SERVER'
    , 'CAPS_SERVER'
 */
// export function funSDKSysSetServerIPPort(
//   params: FunSDKSysSetServerIPPortParams
// ) {
//   funsdk.SysSetServerIPPort(params);
// }
