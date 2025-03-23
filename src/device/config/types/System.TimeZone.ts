export type SystemTimeZoneKey = 'System.TimeZone';

export interface SystemTimeZone {
  FirstUserTimeZone: number;
  timeMin: number;
}

export interface SystemTimeZoneRootObject {
  'Name': 'System.TimeZone';
  'Ret': number;
  'SessionID': string;
  'System.TimeZone': SystemTimeZone;
}
