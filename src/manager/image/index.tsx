import { NativeModules } from 'react-native';
import type { SearchDate } from '../search';

const funsdk = NativeModules.FunSDKDeviceImageModule;

export type DownloadSingleImageParams = {
  deviceId: string;
  deviceChannel: number;
  mSaveImageDir: string;
  imgSizes: {
    imgHeight: number; // 90
    imgWidth: number; // 160
  };
  time: SearchDate;
  seq: number;
};

export type DownloadSingleImageResponse = {
  isSuccess: boolean;
  imagePath: string;
  // нет на iOS
  mediaType?: number;
  seq: number;
};

export const downloadSingleImage = (
  params: DownloadSingleImageParams
): Promise<DownloadSingleImageResponse> => {
  return funsdk.downloadSingleImage(params);
};

export type DownloadSingleFileParams = {
  deviceId: string;
  deviceChannel: number;
  mSaveImageDir: string;
  startTime: SearchDate;
  endTime: SearchDate;
  fileName: string;
};

export type DownloadSingleFileResponse = {
  isSuccess: boolean;
  filePath: string;
  seq: number;
};

export const downloadSingleFile = (
  params: DownloadSingleFileParams
): Promise<DownloadSingleFileResponse> => {
  return funsdk.downloadSingleFile(params);
};
