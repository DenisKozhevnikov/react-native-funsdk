// await getDevConfig({
//   deviceId,
//   name: 'NetWork.NetDNS',
//   channel: -1,
//   timeout: 10000,
//   nOutBufLen: 0,
// })
// {
//   "Name": "NetWork.NetDNS",
//   "NetWork.NetDNS": {
//     "SpareAddress": "0x0500A8C0",
//     "Address": "0x0300A8C0"
//   },
//   "Ret": 100,
//   "SessionID": "0x00000022"
// }

export type TNetWorkNetDNS = {
  SpareAddress: string;
  Address: string;
};

export type TNetWorkNetDNSRootObject = {
  'Name': 'NetWork.NetDNS';
  'NetWork.NetDNS': TNetWorkNetDNS;
  'Ret': number;
  'SessionID': string;
};
