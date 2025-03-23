// await getDevConfig({
//   deviceId,
//   name: 'NetWork.NetDHCP',
//   channel: -1,
//   timeout: 10000,
//   nOutBufLen: 0,
// })
// {
//   "Name": "NetWork.NetDHCP",
//   "Ret": 100,
//   "NetWork.NetDHCP": [
//     {
//       "Enable": true,
//       "Interface": "eth0"
//     },
//     {
//       "Enable": false,
//       "Interface": "eth1"
//     },
//     {
//       "Enable": false,
//       "Interface": "eth2"
//     },
//     {
//       "Enable": false,
//       "Interface": "eth3"
//     },
//     {
//       "Enable": false,
//       "Interface": "bond0"
//     },
//     null,
//     null,
//     null,
//     null,
//     null,
//     null
//   ],
//   "SessionID": "0x00000022"
// }

export type NetDHCPEntry = {
  Enable: boolean;
  Interface: string;
} | null;

export type NetWorkNetDHCPRootObject = {
  'Name': 'NetWork.NetDHCP';
  'Ret': number;
  'NetWork.NetDHCP': NetDHCPEntry[];
  'SessionID': string;
};
