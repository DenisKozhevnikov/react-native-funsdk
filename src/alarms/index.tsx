import { NativeModules, Platform } from 'react-native';
import type { AlarmType } from '../types/alarm';
import type { DeviceManagerPromiseSuccessType } from '../../src/device';

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

export type UnlinkAlarmParams = {
  deviceId: string;
};

export function unlinkAlarm(params: UnlinkAlarmParams): Promise<any> {
  return funsdk.unlinkAlarm(params);
}

export enum EMSGLANGUAGE {
  ELG_AUTO = 0,
  ELG_ENGLISH = 1,
  ELG_CHINESE = 2,
  ELG_JAPANESE = 3,
}

export enum ALARM_PUSH_TYPE {
  DevelopmentType = 200,
  ProductionType = 3,
}

export type InitAlarmServerParams = {
  username: string;
  password: string;
  token: string;
  language?: EMSGLANGUAGE;
  pushType?: ALARM_PUSH_TYPE;
  pushThirdServerURL?: string;
};

export function initAlarmServer(params: InitAlarmServerParams): Promise<any> {
  return funsdk.initAlarmServer({
    language: EMSGLANGUAGE.ELG_ENGLISH,
    pushType: ALARM_PUSH_TYPE.DevelopmentType,
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
