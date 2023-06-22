// import { NativeModules, Platform } from 'react-native';

// const LINKING_ERROR =
//   `The package 'react-native-funsdk' doesn't seem to be linked. Make sure: \n\n` +
//   Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
//   '- You rebuilt the app after installing the package\n' +
//   '- You are not using Expo Go\n';

// const Funsdk = NativeModules.Funsdk
//   ? NativeModules.Funsdk
//   : new Proxy(
//       {},
//       {
//         get() {
//           throw new Error(LINKING_ERROR);
//         },
//       }
//     );

// export function multiply(a: number, b: number): Promise<number> {
//   return Funsdk.multiply(a, b);
// }

export * from './core';
export * from './register';
export * from './forget';
export * from './info';
export * from './login';
export * from './modify';
export * from './device/add';

// views
export * from './monitor';
