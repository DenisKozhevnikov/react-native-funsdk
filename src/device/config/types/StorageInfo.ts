// example

// const res: StorageInfoResponse = await getDevConfig({
//   deviceId,
//   name: 'StorageInfo',
//   channel: -1,
//   timeout: 10000,
//   nOutBufLen: 0,
// });
//
// {
//   "Name": "StorageInfo",
//   "Ret": 100,
//   "SessionID": "0x10",
//   "StorageInfo": [
//     {
//       "PlysicalNo": 0,
//       "Partition": [
//         {
//           "DirverType": 0,
//           "LogicSerialNo": 0,
//           "IsCurrent": true,
//           "RemainSpace": "0x00000000",
//           "OldEndTime": "2025-01-26 21:40:30",
//           "Status": 0,
//           "NewEndTime": "2025-01-26 21:40:30",
//           "NewStartTime": "2024-12-24 10:22:44",
//           "OldStartTime": "2024-12-24 10:38:37",
//           "TotalSpace": "0x00037E48"
//         },
//         {
//           "DirverType": 0,
//           "LogicSerialNo": 0,
//           "IsCurrent": false,
//           "RemainSpace": "0x00000000",
//           "OldEndTime": "0000-00-00 00:00:00",
//           "Status": 0,
//           "NewEndTime": "0000-00-00 00:00:00",
//           "NewStartTime": "0000-00-00 00:00:00",
//           "OldStartTime": "0000-00-00 00:00:00",
//           "TotalSpace": "0x00000000"
//         },
//         {
//           "DirverType": 0,
//           "LogicSerialNo": 0,
//           "IsCurrent": false,
//           "RemainSpace": "0x00000000",
//           "OldEndTime": "0000-00-00 00:00:00",
//           "Status": 0,
//           "NewEndTime": "0000-00-00 00:00:00",
//           "NewStartTime": "0000-00-00 00:00:00",
//           "OldStartTime": "0000-00-00 00:00:00",
//           "TotalSpace": "0x00000000"
//         },
//         {
//           "DirverType": 0,
//           "LogicSerialNo": 0,
//           "IsCurrent": false,
//           "RemainSpace": "0x00000000",
//           "OldEndTime": "0000-00-00 00:00:00",
//           "Status": 0,
//           "NewEndTime": "0000-00-00 00:00:00",
//           "NewStartTime": "0000-00-00 00:00:00",
//           "OldStartTime": "0000-00-00 00:00:00",
//           "TotalSpace": "0x00000000"
//         }
//       ],
//       "ModelNumber": "",
//       "PartNumber": 1,
//       "SerialNumber": ""
//     }
//   ]
// }

export type StorageInfoResponse = {
  Name: string;
  Ret: number;
  SessionID: string;
  StorageInfo: StorageDevice[];
};

export type StorageDevice = {
  PlysicalNo: number;
  Partition: PartitionInfo[];
  ModelNumber: string;
  PartNumber: number;
  SerialNumber: string;
};

export type PartitionInfo = {
  DirverType: number;
  LogicSerialNo: number;
  IsCurrent: boolean;
  RemainSpace: string;
  OldEndTime: string;
  Status: number;
  NewEndTime: string;
  NewStartTime: string;
  OldStartTime: string;
  TotalSpace: string;
};
