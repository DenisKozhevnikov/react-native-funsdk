// await getDevConfig({
//   deviceId,
//   name: 'NetWork.NetCommon',
//   channel: -1,
//   timeout: 10000,
//   nOutBufLen: 0,
// })
// {
//   "Name": "NetWork.NetCommon",
//   "NetWork.NetCommon": {
//     "UDPPort": 34568,
//     "TransferPlan": "AutoAdapt",
//     "MonMode": "TCP",
//     "MaxBps": 0,
//     "HostIP": "0xCB00A8C0",
//     "Submask": "0x00FFFFFF",
//     "UseHSDownLoad": false,
//     "TCPMaxConn": 10,
//     "SSLPort": 8443,
//     "GateWay": "0xD400A8C0",
//     "MAC": "00:12:43:53:dc:71",
//     "TCPPort": 34590,
//     "HttpPort": 90,
//     "HostName": "LocalHost"
//   },
//   "Ret": 100,
//   "SessionID": "0x00000026"
// }

export type TNetWorkNetCommon = {
  UDPPort: number;
  TransferPlan: string;
  MonMode: string;
  MaxBps: number;
  HostIP: string;
  Submask: string;
  UseHSDownLoad: boolean;
  TCPMaxConn: number;
  SSLPort: number;
  GateWay: string;
  MAC: string;
  TCPPort: number;
  HttpPort: number;
  HostName: string;
};

export type TNetWorkNetCommonRootObject = {
  'Name': 'NetWork.NetCommon';
  'NetWork.NetCommon': TNetWorkNetCommon;
  'Ret': number;
  'SessionID': string;
};
