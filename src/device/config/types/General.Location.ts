// await getDevConfig({
//           deviceId,
//           name: 'General.Location',
//           channel: -1,
//           timeout: 10000,
//           nOutBufLen: 0,
//         });
//
// {
//   "General.Location": {
//     "WorkDay": 62,
//     "VideoFormat": "PAL",
//     "DateFormat": "DDMMYY",
//     "DSTStart": {
//       "Day": 1,
//       "Minute": 1,
//       "Year": 2025,
//       "Week": 0,
//       "Hour": 1,
//       "Month": 5
//     },
//     "Language": "Russian",
//     "DSTRule": "Off",
//     "DateSeparator": "-",
//     "IranCalendar": 0,
//     "TimeFormat": "24",
//     "DSTEnd": {
//       "Day": 1,
//       "Minute": 1,
//       "Year": 2025,
//       "Week": 0,
//       "Hour": 1,
//       "Month": 10
//     }
//   },
//   "Ret": 100,
//   "Name": "General.Location",
//   "SessionID": "0x00000003"
// }

export type GeneralLocationKey = `Simplify.Encode.[${number}]`;

export type DSTTimeFormat = {
  Day: number;
  Minute: number;
  Year: number;
  Week: number;
  Hour: number;
  Month: number;
};

export interface GeneralLocation {
  WorkDay: number;
  VideoFormat: 'PAL' | 'NSTC';
  DateFormat: string;
  DSTStart: DSTTimeFormat;
  Language: string;
  DSTRule: 'On' | 'Off';
  DateSeparator: string;
  IranCalendar: number;
  TimeFormat: string;
  DSTEnd: DSTTimeFormat;
}

export interface GeneralLocationRootObject {
  Name: GeneralLocationKey;
  Ret: number;
  SessionID: string;
  [key: GeneralLocationKey]: GeneralLocation;
}
