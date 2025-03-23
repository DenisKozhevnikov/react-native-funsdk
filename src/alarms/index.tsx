import { NativeModules, Platform } from 'react-native';
import type { AlarmType } from '../types/alarm';
import type { DeviceManagerPromiseSuccessType } from '../../src/device';
import type { SearchDate } from '../types/common';

const funsdk = NativeModules.FunSDKDevAlarmModule;

// Android
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

// iOS
export type SearchAlarmMsgByTimeParams = {
  deviceId: string;
  deviceChannel: number;
  alarmType: number;
  startTime: number; // example - 1699680774000
  endTime: number; // example - 1699680774000
};

export type AlarmInfo = {
  // iOS
  ID: string;
  picSize: number;
  AlarmInfo: {
    Status: string | null;
    StartTime: string | null;
    MsgStatus: string;
    Channel: string;
    Event: AlarmType;
    DevName: string;
    Pic: string;
    PicInfo?: {
      ObjSize: number;
      ObjName: string;
      StorageBucket: string;
    };
  };

  // Android
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

// Android
/**
 * Searches alarm messages based on the provided parameters.
 *
 * @param {SearchAlarmMsgParams} params - The parameters for searching alarm messages.
 * @return {Promise<AlarmInfo[]>} A promise that resolves to an array of alarm information.
 */
export function searchAlarmMsg(
  params: SearchAlarmMsgParams
): Promise<AlarmInfo[]> {
  if (Platform.OS === 'android') {
    return funsdk.searchAlarmMsg({ ...params, searchDays: 1 });
  } else {
    throw new Error('searchAlarmMsgByTime for Android only');
  }
}

// iOS
export function searchAlarmMsgByTime(
  params: SearchAlarmMsgByTimeParams
  // TODO: update
): Promise<AlarmInfo[]> {
  if (Platform.OS === 'ios') {
    return funsdk.searchAlarmMsgByTime(params);
  } else {
    throw new Error('searchAlarmMsgByTime for iOS only');
  }
}

export type DeleteAlarmInfoParams = {
  deviceId: string;
  deleteType: 'MSG' | 'VIDEO';
  // max size - 60
  alarmInfos: {
    id: string;
  }[];
};

export type DeleteOneAlarmInfoParams = {
  deviceId: string;
  deleteType: 'MSG' | 'VIDEO';
  // max size - 60
  alarmID: string;
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

  if (Platform.OS !== 'android') {
    if (params.alarmInfos.length > 1) {
      throw new Error('delete only 1 item in iOS');
    }
    // throw new Error('deleteAlarmInfo for Android only');
    return funsdk.deleteOneAlarmInfo({
      deviceId: params.deviceId,
      deleteType: params.deleteType,
      alarmID: params.alarmInfos?.[0]?.id,
    });
  }
  return funsdk.deleteAlarmInfo(params);
}

export function deleteOneAlarmInfo(
  params: DeleteOneAlarmInfoParams
  // TODO: update
): Promise<DeleteAlarmInfoResponse> {
  if (Platform.OS !== 'ios') {
    throw new Error('deleteOneAlarmInfo for iOS only');
  }

  return funsdk.deleteOneAlarmInfo(params);
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

export type LinkAlarmParams = {
  deviceId: string;
  deviceLogin: string;
  devicePassword: string;
  deviceName?: string;
};

export function linkAlarm(params: LinkAlarmParams): Promise<any> {
  return funsdk.linkAlarm(params);
}

export type LinkDevGeneralParams = {
  deviceId: string;
  deviceName: string;
  voice: string;
  devUserName: string;
  devUserPwd: string;
  appToken: string;
  appType: string;
};

export function linkDevGeneral(params: LinkDevGeneralParams): Promise<any> {
  return funsdk.linkDevGeneral(params);
}

export type LinkDevsBatchParams = {
  deviceIds: string;
  devName: string;
  voice: string;
  devUserName: string;
  devUserPwd: string;
  appToken: string;
  appType: string;
};

export function linkDevsBatch(params: LinkDevsBatchParams): Promise<any> {
  return funsdk.linkDevsBatch(params);
}

export type DevAlarmSubscribeParams = {
  deviceId: string;
  deviceName: string;
  rules: string;
  voice: string;
  appToken: string;
  appType: string;
};

export function devAlarmSubscribe(
  params: DevAlarmSubscribeParams
): Promise<any> {
  return funsdk.devAlarmSubscribe(params);
}

export type DevAlarmSubscribeBatchParams = {
  deviceIds: string;
  deviceName: string;
  rules: string;
  voice: string;
  appToken: string;
  appType: string;
};

export function devAlarmSubscribeBatch(
  params: DevAlarmSubscribeBatchParams
): Promise<any> {
  return funsdk.devAlarmSubscribeBatch(params);
}

export type UnlinkAlarmParams = {
  deviceId: string;
};

export function unlinkAlarm(params: UnlinkAlarmParams): Promise<any> {
  return funsdk.unlinkAlarm(params);
}

export type UnlinkDevGeneralParams = {
  deviceId: string;
  appToken: string;
  flag?: number; // 0 ??
};

export function unlinkDevGeneral(params: UnlinkDevGeneralParams): Promise<any> {
  return funsdk.unlinkDevGeneral({
    flag: 0,
    ...params,
  });
}

export type UnlinkAllAccountsOfDevParams = {
  deviceId: string;
};

export function unlinkAllAccountsOfDev(
  params: UnlinkAllAccountsOfDevParams
): Promise<any> {
  return funsdk.unlinkAllAccountsOfDev(params);
}

export type UnlinkDevsBatchParams = {
  deviceId: string;
  appToken: string;
  flag: number;
};

export function unlinkDevsBatch(params: UnlinkDevsBatchParams): Promise<any> {
  return funsdk.unlinkDevsBatch(params);
}

export type UnlinkDevAbnormalParams = {
  deviceId: string;
  appToken: string;
  flag: number;
};

export function unlinkDevAbnormal(
  params: UnlinkDevAbnormalParams
): Promise<any> {
  return funsdk.unlinkDevAbnormal(params);
}

export type GetDevAlarmSubStatusByTypeParams = {
  deviceIds: string;
  appToken: string;
};

export function getDevAlarmSubStatusByType(
  params: GetDevAlarmSubStatusByTypeParams
): Promise<any> {
  return funsdk.getDevAlarmSubStatusByType(params);
}

export type GetDevAlarmSubStatusByTokenParams = {
  deviceId: string;
  appTokens: string;
};

export function getDevAlarmSubStatusByToken(
  params: GetDevAlarmSubStatusByTokenParams
): Promise<any> {
  return funsdk.getDevAlarmSubStatusByToken(params);
}

export type SearchAlarmPicParams = {
  deviceId: string;
  fileName: string;
  uId: string; // alarm id?
  res: string; // max 31 character, example - _176x144.jpeg
};

export function searchAlarmPic(params: SearchAlarmPicParams): Promise<any> {
  return funsdk.searchAlarmPic(params);
}

export type DownloadAlarmImageParams = {
  deviceId: string;
  path: string;
  picInfoJSONstring: string; // информация об изображении в json строке
  width?: number;
  height?: number;
};

export function downloadAlarmImage(
  params: DownloadAlarmImageParams
): Promise<any> {
  return funsdk.downloadAlarmImage({
    width: 0,
    height: 0,
    ...params,
  });
}

export function stopDownloadAlarmImages(): Promise<any> {
  return funsdk.stopDownloadAlarmImages({});
}

export type SearchAlarmByMothParams = {
  deviceId: string;
  deviceChannel: number;
  streamType?: string; // ""
  date: SearchDate;
};

export function searchAlarmByMoth(params: SearchAlarmPicParams): Promise<any> {
  return funsdk.searchAlarmByMoth({
    streamType: '',
    ...params,
  });
}

export type SearchAlarmLastTimeByTypeParams = {
  deviceId: string;
  deviceChannel: number;
  streamType?: string; // ""
  alarmType?: string; // ""
};

export function searchAlarmLastTimeByType(
  params: SearchAlarmLastTimeByTypeParams
): Promise<any> {
  return funsdk.searchAlarmLastTimeByType({
    streamType: '',
    alarmType: '',
    ...params,
  });
}

export enum ESortType {
  E_SORT_TYPE_ORDER,
  E_SORT_TYPE_REVERSE_ORDER,
}

export type QueryDevsStatusHistoryRecordParams = {
  deviceId: string;
  startTime: number;
  endTime: number;
  queryCount: number; // max 500
  sortType: ESortType;
};

export function queryDevsStatusHistoryRecord(
  params: QueryDevsStatusHistoryRecordParams
): Promise<any> {
  return funsdk.queryDevsStatusHistoryRecord(params);
}

export type AlarmLinkByUserIDParams = {
  userId: string;
  voice?: string;
  appToken: string;
  appType: string;
};

export function alarmLinkByUserID(
  params: AlarmLinkByUserIDParams
): Promise<any> {
  return funsdk.alarmLinkByUserID({
    voice: '',
    ...params,
  });
}

export type AlarmUnLinkByUserIDParams = {
  userId: string;
  appToken: string;
  clearFlag?: number; // 1 - удаляет все подписки, appToken не требуется
};

export function alarmUnLinkByUserID(
  params: AlarmUnLinkByUserIDParams
): Promise<any> {
  return funsdk.alarmUnLinkByUserID({
    clearFlag: 0,
    ...params,
  });
}

export type SetAlarmMsgReadFlagParams = {
  deviceId: string;
  alarmIds: string; // строки из id разделенных знаком ";"
};

export function setAlarmMsgReadFlag(
  params: SetAlarmMsgReadFlagParams
): Promise<any> {
  return funsdk.setAlarmMsgReadFlag(params);
}

export type BatchDevAlarmMsgQueryParams = {
  deviceIds: string; // строки из id разделенных знаком ";"
  deviceChannel: number; // - 1 = все каналы
  startTime: number;
  endTime: number;
  maxNumber: number;
  pageIndex: number;
  alarmType?: string | null;
};

export function batchDevAlarmMsgQuery(
  params: BatchDevAlarmMsgQueryParams
): Promise<any> {
  return funsdk.batchDevAlarmMsgQuery({
    alarmType: null,
    ...params,
  });
}

export type DevAlarmMsgQueryParams = {
  deviceId: string;
  startTime: number;
  endTime: number;
  deviceChannel: number;
  pageNum: number;
  pageSize: number;
  alarmType?: string;
};

export function devAlarmMsgQuery(params: DevAlarmMsgQueryParams): Promise<any> {
  return funsdk.devAlarmMsgQuery({
    alarmType: '',
    ...params,
  });
}

export enum EMSGLANGUAGE {
  ELG_AUTO = 0,
  ELG_ENGLISH = 1,
  ELG_CHINESE = 2,
  ELG_JAPANESE = 3,
}

export enum EAPPTYPE {
  EXMFamily = 1,
  EFamilyCenter = 2,
  EXMEye = 3, // ProductionType = 3 ??
  EFamily_BaiAn = 4,
  DevelopmentType = 200,
}

export type InitAlarmServerParams = {
  username: string;
  password: string;
  token: string;
  language?: EMSGLANGUAGE;
  pushType?: EAPPTYPE;
  szAppType?: string; // XXXXXX Third party subscription alarm URL
};

export function initAlarmServer(params: InitAlarmServerParams): Promise<any> {
  return funsdk.initAlarmServer({
    language: EMSGLANGUAGE.ELG_ENGLISH,
    pushType: EAPPTYPE.DevelopmentType,
    ...params,
  });
}

export type InitAlarmServerV2Params = {
  username: string;
  password: string;
  userId: string;
  token: string;
  language?: EMSGLANGUAGE;
  pushType?: EAPPTYPE;
  szAppType?: string; // XXXXXX Third party subscription alarm URL
};

export function initAlarmServerV2(
  params: InitAlarmServerV2Params
): Promise<any> {
  return funsdk.initAlarmServerV2({
    language: EMSGLANGUAGE.ELG_ENGLISH,
    pushType: EAPPTYPE.DevelopmentType,
    ...params,
  });
}

export type GetAlarmStateParams = {
  deviceId: string;
};

export type GetAlarmStateResult = DeviceManagerPromiseSuccessType & {
  value: {
    'Name': 'NetWork.PMS';
    'NetWork.PMS': {
      BoxID: string;
      Enable: boolean;
      Port: number;
      PushInterval: number;
      ServName: string;
    };
    'Ret': number;
    'SessionID': string;
  };
};

export function getAlarmState(
  params: GetAlarmStateParams
): Promise<GetAlarmStateResult> {
  return funsdk.getAlarmState(params);
}

export type SetAlarmStateParams = {
  deviceId: string;
  isAlertEnabled: boolean;
};

export type SetAlarmStateResult = DeviceManagerPromiseSuccessType & {
  value: {
    Name: 'NetWork.PMS';
    Ret: number;
    SessionID: string;
  };
};

export function setAlarmState(
  params: SetAlarmStateParams
): Promise<SetAlarmStateResult> {
  return funsdk.setAlarmState(params);
}
