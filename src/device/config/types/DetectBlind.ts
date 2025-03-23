// await getDevConfig({
//   deviceId,
//   name: 'Detect.BlindDetect',
//   channel: 0,
//   timeout: 10000,
//   nOutBufLen: 0,
// });

// {
//   "Name": "Detect.BlindDetect.[0]",
//   "Detect.BlindDetect.[0]": {
//     "Level": 3,
//     "Enable": false,
//     "EventHandler": {
//       "VoiceTipInterval": 0,
//       "MatrixEnable": false,
//       "MessageEnable": true,
//       "MultimediaMsgEnable": false,
//       "AlarmOutMask": "0x00000000",
//       "PtzEnable": false,
//       "MatrixMask": "0x00000000",
//       "AlarmOutEnable": false,
//       "FTPEnable": false,
//       "MsgtoNetEnable": false,
//       "CheckDiskInterval": 60,
//       "EventLatch": 1,
//       "RecordMask": "0x00000001",
//       "VoiceEnable": false,
//       "TourMask": "0x00000000",
//       "AlarmOutLatch": 10,
//       "SnapShotMask": "0x00000001",
//       "BeepEnable": false,
//       "PtzLink": [
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ],
//         [
//           "None",
//           0
//         ]
//       ],
//       "AlarmInfo": "",
//       "MailEnable": false,
//       "VoiceType": 24,
//       "SaveSerEnable": true,
//       "RecordEnable": true,
//       "TipEnable": false,
//       "TimeSection": [
//         [
//           "1 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00"
//         ],
//         [
//           "1 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00"
//         ],
//         [
//           "1 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00"
//         ],
//         [
//           "1 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00"
//         ],
//         [
//           "1 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00"
//         ],
//         [
//           "1 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00"
//         ],
//         [
//           "1 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00",
//           "0 00:00:00-24:00:00"
//         ]
//       ],
//       "TourEnable": false,
//       "SnapEnable": true,
//       "ShowInfoMask": "0x00000000",
//       "LogEnable": false,
//       "RecordLatch": 10,
//       "ShortMsgEnable": false,
//       "ShowInfo": false
//     }
//   },
//   "Ret": 100,
//   "SessionID": "0x00000013"
// }
export type BlindDetectKey = `Detect.BlindDetect.[${number}]`;

export interface BlindDetectEventHandler {
  VoiceTipInterval: number;
  MatrixEnable: boolean;
  MessageEnable: boolean;
  MultimediaMsgEnable: boolean;
  AlarmOutMask: string;
  PtzEnable: boolean;
  MatrixMask: string;
  AlarmOutEnable: boolean;
  FTPEnable: boolean;
  MsgtoNetEnable: boolean;
  CheckDiskInterval: number;
  EventLatch: number;
  RecordMask: string;
  VoiceEnable: boolean;
  TourMask: string;
  AlarmOutLatch: number;
  SnapShotMask: string;
  BeepEnable: boolean;
  PtzLink: [string, number][];
  AlarmInfo: string;
  MailEnable: boolean;
  VoiceType: number;
  SaveSerEnable: boolean;
  RecordEnable: boolean;
  TipEnable: boolean;
  TimeSection: string[][];
  TourEnable: boolean;
  SnapEnable: boolean;
  ShowInfoMask: string;
  LogEnable: boolean;
  RecordLatch: number;
  ShortMsgEnable: boolean;
  ShowInfo: boolean;
}

export interface BlindDetect {
  EventHandler: BlindDetectEventHandler;
  Enable: boolean;
  Level: number;
}

export interface BlindDetectRootObject {
  Name: BlindDetectKey;
  Ret: number;
  SessionID: string;
  [key: BlindDetectKey]: BlindDetect;
}
