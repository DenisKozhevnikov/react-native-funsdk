import { NativeModules } from 'react-native';

const funsdk = NativeModules.FunSDKPushMessageModule;

export const InitGoogleFunSDKPush = (params: {
  token: string;
  deviceId: string;
  type: number;
}) => {
  funsdk.initGoogleFunSDKPush(params);
};

export const LoadTestPushData = () => {
  // funsdk.getManager();
};

export const openPush = () => {
  // funsdk.openPush();
};

export const closePush = () => {
  // funsdk.closePush();
};

export const isPushOpen = () => {
  // funsdk.isPushOpen();
};
