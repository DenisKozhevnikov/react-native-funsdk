import { NativeModules } from 'react-native';

const funsdk = NativeModules.FunSDKDeviceImageModule;

export type DownloadSingleImageParams = {
  deviceId: string;
  deviceChannel: number;
  mSaveImageDir: string;
  imgSizes: {
    imgHeight: number; // 90
    imgWidth: number; // 160
  };
  timestamp: string;
  seq: number;
};

export type DownloadSingleImageResponse = {
  isSuccess: boolean;
  imagePath: string;
  mediaType: number;
  seq: number;
};

export const downloadSingleImage = (
  params: DownloadSingleImageParams
): Promise<DownloadSingleImageResponse> => {
  return funsdk.downloadSingleImage(params);
};
