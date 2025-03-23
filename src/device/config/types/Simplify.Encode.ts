// await getDevConfig({
//   deviceId,
//   name: 'NetUse.DigitalEncode',
//   channel: 0,
//   timeout: 10000,
//   nOutBufLen: 0,
// });

// {
//   "NetUse.DigitalEncode.[0]": [
//     {
//       "ExtraFormat": {
//         "VideoEnable": true,
//         "AudioEnable": true,
//         "Audio": {
//           "SampleRate": 0,
//           "MaxVolume": 0,
//           "BitRate": 0
//         },
//         "Video": {
//           "BitRateControl": "CBR",
//           "Resolution": "VGA",
//           "BitRate": 332,
//           "GOP": 60,
//           "FPS": 25,
//           "Quality": 2,
//           "Compression": "H.265"
//         }
//       },
//       "MainFormat": {
//         "VideoEnable": true,
//         "AudioEnable": true,
//         "Audio": {
//           "SampleRate": 0,
//           "MaxVolume": 0,
//           "BitRate": 0
//         },
//         "Video": {
//           "BitRateControl": "CBR",
//           "Resolution": "VGA",
//           "BitRate": 332,
//           "GOP": 60,
//           "FPS": 25,
//           "Quality": 2,
//           "Compression": "H.265"
//         }
//       }
//     }
//   ],
//   "Name": "NetUse.DigitalEncode.[0]",
//   "Ret": 100,
//   "SessionID": "0x4b"
// }

export type SimplifyEncodeKey = `Simplify.Encode.[${number}]`;

export type SimplifyEncodeAudioFormat = {
  SampleRate: number;
  MaxVolume: number;
  BitRate: number;
};

export type SimplifyEncodeVideoFormat = {
  BitRateControl: string;
  Resolution: string;
  BitRate: number;
  GOP: number;
  FPS: number;
  Quality: number;
  Compression: string;
};

export type SimplifyEncodeFormat = {
  VideoEnable: boolean;
  AudioEnable: boolean;
  Audio: SimplifyEncodeAudioFormat;
  Video: SimplifyEncodeVideoFormat;
};

export interface SimplifyEncode {
  ExtraFormat: SimplifyEncodeFormat;
  MainFormat: SimplifyEncodeFormat;
}

export interface SimplifyEncodeRootObject {
  Name: SimplifyEncodeKey;
  Ret: number;
  SessionID: string;
  [key: SimplifyEncodeKey]: SimplifyEncode[];
}
