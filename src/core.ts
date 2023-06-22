import { NativeModules } from 'react-native';

const funsdk = NativeModules.FunSDKCoreModule;

export type FunSDKInitParams = {
  uuid: string;
  key: string;
  secret: string;
  movedCard: number;
};

export function funSDKInit(params: FunSDKInitParams): Promise<any> {
  return funsdk.init(params);
}
