// await getDevConfig({
//   deviceId,
//   name: 'NetUse.DigitalAbility',
//   channel: CHANNEL,
//   timeout: 10000,
//   nOutBufLen: 0,
// });

// {
//   "Name": "NetUse.DigitalAbility.[1]",
//   "NetUse.DigitalAbility.[1]": {
//     "videoFormat": 0,
//     "ability": {
//       "EncodeInfo": [
//         {
//           "CompressionMask": "0x00000000",
//           "HaveAudio": false,
//           "Enable": false,
//           "StreamType": "MainStream",
//           "ResolutionMask": "0x00000000"
//         },
//         {
//           "CompressionMask": "0x01C4FD84",
//           "HaveAudio": false,
//           "Enable": false,
//           "StreamType": "JPEGStream",
//           "ResolutionMask": "0x00000000"
//         },
//         {
//           "CompressionMask": "0x00000000",
//           "HaveAudio": true,
//           "Enable": false,
//           "StreamType": "MainStream",
//           "ResolutionMask": "0x01BC1668"
//         },
//         {
//           "CompressionMask": "0x00000000",
//           "HaveAudio": true,
//           "Enable": false,
//           "StreamType": "JPEGStream",
//           "ResolutionMask": "0x00000000"
//         },
//         {
//           "CompressionMask": "0x766D8468",
//           "HaveAudio": true,
//           "Enable": false,
//           "StreamType": "JPEGStream",
//           "ResolutionMask": "0x01C8FDA8"
//         }
//       ],
//       "ChannelMaxSetSync": 0,
//       "ImageSizePerChannel": [
//         "0x00124800"
//       ],
//       "Compression": "0x00000180",
//       "MaxBitrate": 49152,
//       "MaxEncodePower": 82944000,
//       "MaxEncodePowerPerChannel": [
//         "0x04F1A000"
//       ],
//       "ExImageSizePerChannel": [
//         "0x00124800"
//       ],
//       "CombEncodeInfo": [
//         {
//           "CompressionMask": "0x00000000",
//           "HaveAudio": false,
//           "Enable": false,
//           "StreamType": "MainStream",
//           "ResolutionMask": "0x00000000"
//         },
//         {
//           "CompressionMask": "0x01D87E60",
//           "HaveAudio": false,
//           "Enable": false,
//           "StreamType": "JPEGStream",
//           "ResolutionMask": "0x00000000"
//         },
//         {
//           "CompressionMask": "0x00000012",
//           "HaveAudio": false,
//           "Enable": false,
//           "StreamType": "MainStream",
//           "ResolutionMask": "0x01C50580"
//         },
//         {
//           "CompressionMask": "0x00000000",
//           "HaveAudio": true,
//           "Enable": false,
//           "StreamType": "JPEGStream",
//           "ResolutionMask": "0x00000050"
//         },
//         {
//           "CompressionMask": "0x01C50584",
//           "HaveAudio": false,
//           "Enable": false,
//           "StreamType": "JPEGStream",
//           "ResolutionMask": "0x00000000"
//         }
//       ],
//       "ExImageSizePerChannelEx": [
//         [
//           "0x00000000",
//           "0x00000000",
//           "0x00000000",
//           "0x00000000",
//           "0x00000000",
//           "0x00000000",
//           "0x00000000",
//           "0x00000000",
//           "0x00000000",
//           "0x00000000",
//           "0x00000000",
//           "0x0000004B",
//           "0x00000000",
//           "0x00000000",
//           "0x0000004B",
//           "0x00000000",
//           "0x00000000",
//           "0x0000004B",
//           "0x00000000",
//           "0x00000000",
//           "0x0000004B",
//           "0x00000000",
//           "0x00000000",
//           "0x00000000",
//           "0x00000000",
//           "0x00000000",
//           "0x00000000",
//           "0x00000000",
//           "0x00000000",
//           "0x00000000",
//           "0x00000000",
//           "0x00000000"
//         ]
//       ]
//     },
//     "nCapture": 1,
//     "enable": true,
//     "IFrameRange": {
//       "sub_min": 1,
//       "sub_max": 12,
//       "main_min": 1,
//       "main_max": 12
//     },
//     "nAudio": 1
//   },
//   "Ret": 100,
//   "SessionID": "0x53"
// }

export type DigitalAbilityKey = `NetUse.DigitalAbility.[${number}]`;

export type DigitalAbilityEncodeInfo = {
  CompressionMask: string;
  HaveAudio: boolean;
  Enable: boolean;
  StreamType: 'MainStream' | 'JPEGStream';
  ResolutionMask: string;
};

export type DigitalAbilityAbility = {
  EncodeInfo: DigitalAbilityEncodeInfo[];
  ChannelMaxSetSync: number;
  ImageSizePerChannel: string[];
  Compression: string;
  MaxBitrate: number;
  MaxEncodePower: number;
  MaxEncodePowerPerChannel: string[];
  ExImageSizePerChannel: string[];
  CombEncodeInfo: DigitalAbilityEncodeInfo[];
  ExImageSizePerChannelEx: string[][];
};

export type DigitalAbilityIFrameRange = {
  sub_min: number;
  sub_max: number;
  main_min: number;
  main_max: number;
};

export interface DigitalAbility {
  videoFormat: number;
  ability: DigitalAbilityAbility;
  nCapture: number;
  enable: boolean;
  IFrameRange: DigitalAbilityIFrameRange;
  nAudio: number;
}

export interface DigitalAbilityRootObject {
  Name: DigitalAbilityKey;
  Ret: number;
  SessionID: string;
  [key: DigitalAbilityKey]: DigitalAbility;
}

export interface EncodeCapabilityRootObject {
  Name: 'EncodeCapability';
  Ret: number;
  SessionID: string;
  EncodeCapability: DigitalAbilityAbility;
}
