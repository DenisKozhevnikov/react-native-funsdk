// const res = await getDevConfig({
//   deviceId,
//   name: 'Detect.MotionDetect',
//   channel: 0,
//   timeout: 10000,
//   nOutBufLen: 0,
// });

// {
//   "Name": "Detect.MotionDetect.[0]",
//   "Ret": 100,
//   "Detect.MotionDetect.[0]": {
//     "EventHandler": {
//       "VoiceTipInterval": 0,
//       "MatrixEnable": false,
//       "AlarmLedMode": 0,
//       "AlarmInfo": "",
//       "MessageEnable": true,
//       "MultimediaMsgEnable": false,
//       "PtzEnable": false,
//       "MatrixMask": "0x00000000",
//       "AlarmOutEnable": false,
//       "FTPEnable": false,
//       "MsgtoNetEnable": false,
//       "CheckDiskInterval": 60,
//       "VoiceEnable": false,
//       "TourMask": "0x00000000",
//       "AlarmOutLatch": 10,
//       "SnapShotMask": "0x00000001",
//       "AlarmOutMask": "0x00000000",
//       "RecordMask": "0x00000001",
//       "EventLatch": 2,
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
//     },
//     "Enable": true,
//     "Region": [
//       "0x003FFFFF",
//       "0x003FFFFF",
//       "0x003FFFFF",
//       "0x003FFFFF",
//       "0x003FFFFF",
//       "0x003FFFFF",
//       "0x003FFFFF",
//       "0x003FFFFF",
//       "0x003FFFFF",
//       "0x003FFFFF",
//       "0x003FFFFF",
//       "0x003FFFFF",
//       "0x003FFFFF",
//       "0x003FFFFF",
//       "0x003FFFFF",
//       "0x00000000",
//       "0x00000000",
//       "0x00000000",
//       "0x00000000",
//       "0x00000000",
//       "0x00000000",
//       "0x00000000",
//       "0x00000000",
//       "0x00000000",
//       "0x00000000",
//       "0x00000000",
//       "0x00000000",
//       "0x00000000",
//       "0x00000000",
//       "0x00000000",
//       "0x00000000",
//       "0x00000000"
//     ],
//     "Level": 6
//   },
//   "SessionID": "0x0000000B"
// }

export type MotionDetectKey = `Detect.MotionDetect.[${number}]`;

export interface MotionDetectEventHandler {
  VoiceTipInterval: number;
  MatrixEnable: boolean;
  AlarmLedMode: number;
  AlarmInfo: string;
  MessageEnable: boolean;
  MultimediaMsgEnable: boolean;
  PtzEnable: boolean;
  MatrixMask: string;
  AlarmOutEnable: boolean;
  FTPEnable: boolean;
  MsgtoNetEnable: boolean;
  CheckDiskInterval: number;
  VoiceEnable: boolean;
  TourMask: string;
  AlarmOutLatch: number;
  SnapShotMask: string;
  AlarmOutMask: string;
  RecordMask: string;
  EventLatch: number;
  BeepEnable: boolean;
  PtzLink: [string, number][];
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

export interface MotionDetect {
  EventHandler: MotionDetectEventHandler;
  Enable: boolean;
  Region: string[];
  Level: number;
}

export interface MotionDetectRootObject {
  Name: MotionDetectKey;
  Ret: number;
  SessionID: string;
  [key: MotionDetectKey]: MotionDetect;
}
