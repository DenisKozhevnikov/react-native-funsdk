// await getDevConfig({
//   deviceId,
//   name: 'SupportExtRecord',
//   channel: 0,
//   timeout: 10000,
//   nOutBufLen: 0,
// });
// {
//   "Name": "SupportExtRecord.[2900]",
//   "Ret": 100,
//   "SupportExtRecord.[2900]": {
//     "AbilityPram": "0x00000000"
//   },
//   "SessionID": "0x00000010"
// }

export type SupportExtRecordKey = `SupportExtRecord.[${number}]`;

export interface SupportExtRecord {
  // 0x00000000
  // 0. Поддерживает только основной поток.
  // 1. Поддерживает только потоки вспомогательного кода.
  // 2. Поддерживаются как основной, так и вспомогательный потоки кода.
  AbilityPram: string;
}

export interface SupportExtRecordRootObject {
  Name: SupportExtRecordKey;
  Ret: number;
  SessionID: string;
  [key: SupportExtRecordKey]: SupportExtRecord;
}
