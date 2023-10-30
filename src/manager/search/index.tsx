import { NativeModules } from 'react-native';
import { FILE_TYPE, STREAM_TYPE } from '../../types/stream';

const funsdk = NativeModules.FunSDKDeviceSearchByTime;

export type SearchTimeinfoParams = {
  deviceId: string;
  time: number;
  deviceChannel: number;
  fileType?: FILE_TYPE;
  streamType?: STREAM_TYPE;
  seq?: number;
};

export type SearchTimeinfoResponse = {
  charList: number[];
  minutesStatusList: number[];
  charsCount: number;
  minutesCount: number;
} | null;

export const searchTimeinfo = (
  params: SearchTimeinfoParams
): Promise<SearchTimeinfoResponse> => {
  const defaultParams: Required<SearchTimeinfoParams> = {
    fileType: FILE_TYPE.SDK_RECORD_ALL,
    streamType: STREAM_TYPE.MAIN,
    seq: 0,
    ...params,
  };

  return funsdk.searchTimeinfo(defaultParams);
};
