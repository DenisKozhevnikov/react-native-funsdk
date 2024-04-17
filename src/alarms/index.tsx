import { NativeModules } from 'react-native';
import type { AlarmType } from '../types/alarm';

const funsdk = NativeModules.FunSDKDevAlarmModule;

export type SearchAlarmMsgParams = {
  deviceId: string;
  deviceChannel: number;
  alarmType: number;
  searchTime: number; // example - 1699680774000
  searchDays: number; // 1 - 1 день
  imgSizes: {
    imgHeight: number; // example - 90
    imgWidth: number; // example - 160
  };
};

export type AlarmInfo = {
  alarmRing: string | null;
  channel: number;
  devName: string | null;
  event: AlarmType | null;
  extInfo: string | null;
  id: string;
  isHavePic: boolean;
  linkCenter: {
    msgType: string | null;
    msg: string | null;
    subSn: string | null;
    modelType: number | null;
  } | null;
  pic: string | null;
  picError: number;
  picsize: number;
  pushMsg: string | null;
  serialNumber: string | null;
  startTime: string | null;
  status: string | null;
  videoInfo: boolean;
};
// Максимум за 1 день?

/**
 * Searches alarm messages based on the provided parameters.
 *
 * @param {SearchAlarmMsgParams} params - The parameters for searching alarm messages.
 * @return {Promise<AlarmInfo[]>} A promise that resolves to an array of alarm information.
 */
export function searchAlarmMsg(
  params: SearchAlarmMsgParams
): Promise<AlarmInfo[]> {
  return funsdk.searchAlarmMsg(params);
}

export type DeleteAlarmInfoParams = {
  deviceId: string;
  deleteType: 'MSG' | 'VIDEO';
  // max size - 60
  alarmInfos: {
    id: string;
  }[];
};

export type DeleteAlarmInfoResponse = {
  isSuccess: boolean;
  // в AlarmInfo только id, остальные поля null
  alarmInfos: AlarmInfo[];
};

/**
 * Deletes alarm information.
 *
 * @param {DeleteAlarmInfoParams} params - The parameters for deleting alarm information.
 * @param {string} params.deviceId - The ID of the device.
 * @param {'MSG' | 'VIDEO'} params.deleteType - The type of deletion ('MSG' or 'VIDEO').
 * @param {Array<{id: string}>} params.alarmInfos - The array of alarm information IDs to delete.
 * @throws {Error} Throws an error if the length of alarmInfos is more than 60.
 * @return {Promise<DeleteAlarmInfoResponse>} A promise that resolves to the response containing the success status and the deleted alarm information.
 */
export function deleteAlarmInfo(
  params: DeleteAlarmInfoParams
): Promise<DeleteAlarmInfoResponse> {
  if (params.alarmInfos.length > 60) {
    throw new Error("alarmInfos length can't be more than 60");
  }
  return funsdk.deleteAlarmInfo(params);
}

/**
 * Deletes all alarm messages based on the provided parameters, excluding the alarmInfos field.
 *
 * @param {Omit<DeleteAlarmInfoParams, 'alarmInfos'>} params - The parameters for deleting alarm information, excluding the alarmInfos field.
 * @return {Promise<Omit<DeleteAlarmInfoResponse, 'alarmInfos'>>} A promise that resolves to the response containing the success status and the deleted alarm information, excluding the alarmInfos field.
 */
export function deleteAllAlarmMsg(
  params: Omit<DeleteAlarmInfoParams, 'alarmInfos'>
): Promise<Omit<DeleteAlarmInfoResponse, 'alarmInfos'>> {
  return funsdk.deleteAllAlarmMsg(params);
}
