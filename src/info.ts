import { NativeModules } from 'react-native';

const funsdk = NativeModules.FunSDKInfoModule;

export function logout(): Promise<undefined> {
  return funsdk.logout({});
}

// export function getUserId(): Promise<any> {
//   return funsdk.getUserId();
// }

// export function getUserName(): Promise<any> {
//   return funsdk.getUserName();
// }

// export function getEmail(): Promise<any> {
//   return funsdk.getEmail();
// }

// export function getPhoneNo(): Promise<any> {
//   return funsdk.getPhoneNo();
// }

// export function hasLogin(): Promise<boolean> {
//   return funsdk.hasLogin();
// }
