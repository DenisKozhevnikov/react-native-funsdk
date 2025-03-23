// await getDevCmdGeneral({
//   deviceId,
//   cmdReq: 1042,
//   cmd: 'NetWork.PMS',
//   isBinary: 0,
//   timeout: 5000,
//   param: null,
//   inParamLen: 0,
//   cmdRes: -1,
// }

// {
//   "NetWork.PMS": {
//     "PushInterval": 10,
//     "Enable": true,
//     "Port": 80,
//     "BoxID": "",
//     "ServName": "push.umeye.cn"
//   },
//   "SessionID": "0x0000001B",
//   "Name": "NetWork.PMS",
//   "Ret": 100
// }

export interface NetworkPMS {
  PushInterval: number;
  Enable: boolean;
  Port: number;
  BoxID: string;
  ServName: string;
}

export interface NetworkPMSRootObject {
  'Name': 'NetWork.PMS';
  'Ret': number;
  'SessionID': string;
  'NetWork.PMS': NetworkPMS;
}
