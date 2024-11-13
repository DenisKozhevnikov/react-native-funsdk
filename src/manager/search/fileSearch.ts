import { NativeModules } from 'react-native';
import type { FILE_TYPE, STREAM_TYPE } from '../../types/stream';

const funsdk = NativeModules.FunSDKDeviceFileSearch;

export type SearchDate = {
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  second: number;
};

export type SearchDeviceFilesByDateParams = {
  deviceChannel: number;
  deviceId: string;
  maxFileCount?: number;
  fileType: FILE_TYPE;
  fileName?: string;
  streamType?: STREAM_TYPE;
  start: SearchDate;
  end: SearchDate;
  timeout?: number;
};

// пример из funsdkexample с тем что означает в имени файла знак []
// if ([recordInfo.fileName containsString:@"[H]"] || [recordInfo.fileName containsString:@"[R]"]) {
//   //如果选择了普通视频，则将数据源改成 normalFileList
//   [normalFileList addObject:recordInfo];
// }else if ([recordInfo.fileName containsString:@"[A]"] || [recordInfo.fileName containsString:@"[M]"] || [recordInfo.fileName containsString:@"[I]"] || [recordInfo.fileName containsString:@"[s]"]){
//   //如果选择了告警视频，则将数据源改成 alarmFileList
//   [alarmFileList addObject:recordInfo];
// }

export type SearchDeviceFilesByDateItemResponse = {
  size: number;
  channel: number;
  // example - "/idea0/2000-01-01/001/23.00.00-23.10.00[R][@e123][0].h264",
  fileName: string;
  streamType: STREAM_TYPE;
  startTime: SearchDate;
  endTime: SearchDate;
};

export const searchDeviceFilesByDate = (
  params: SearchDeviceFilesByDateParams
): Promise<SearchDeviceFilesByDateItemResponse[]> => {
  const defaultParams = {
    maxFileCount: 10000,
    timeout: 10000,
    ...params,
  };

  return funsdk.searchDeviceFilesByDate(defaultParams);
};
