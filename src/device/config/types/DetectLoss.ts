// await getDevConfig({
//   deviceId,
//   name: 'Detect.LossDetect',
//   channel: 0,
//   timeout: 10000,
//   nOutBufLen: 0,
// })
// {
//   "Detect.LossDetect.[0]": {
//     "Enable": true,
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
//       "RecordMask": "0x00000000",
//       "VoiceEnable": false,
//       "TourMask": "0x00000000",
//       "AlarmOutLatch": 10,
//       "SnapShotMask": "0x00000000",
//       "BeepEnable": true,
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
//   "Name": "Detect.LossDetect.[0]",
//   "Ret": 100,
//   "SessionID": "0x00000016"
// }
export type LossDetectKey = `Detect.LossDetect.[${number}]`;

export interface DetectLossEventHandler {
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

export interface DetectLossDetect {
  EventHandler: DetectLossEventHandler;
  Enable: boolean;
}

export interface LossDetectRootObject {
  Name: LossDetectKey;
  Ret: number;
  SessionID: string;
  [key: LossDetectKey]: DetectLossDetect;
}
