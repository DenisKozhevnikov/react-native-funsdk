export enum EPTZCMD {
  TILT_UP = 0, // on
  TILT_DOWN = 1, // down
  PAN_LEFT = 2, // Left
  PAN_RIGHT = 3, // Right
  PAN_LEFTTOP = 4, // Upper left
  PAN_LEFTDOWN = 5, // Lower left
  PAN_RIGTHTOP = 6, // Top right
  PAN_RIGTHDOWN = 7, // Lower right
  ZOOM_OUT = 8, // The number of times smaller
  ZOOM_IN = 9, // Double the size
  FOCUS_FAR = 10, // Focus back
  FOCUS_NEAR = 11, // Focus forward
  IRIS_OPEN = 12, // The aperture is enlarged
  IRIS_CLOSE = 13, // The aperture decreases by 13
  EXTPTZ_OPERATION_ALARM = 14, ///< Alarm function
  EXTPTZ_LAMP_ON = 15, ///< Lights on
  EXTPTZ_LAMP_OFF = 16, // The lights are off
  EXTPTZ_POINT_SET_CONTROL = 17, // Set the preset point
  EXTPTZ_POINT_DEL_CONTROL = 18, // Clear preset points
  EXTPTZ_POINT_MOVE_CONTROL = 19, // Go to the preset point
  EXTPTZ_STARTPANCRUISE = 20, // Start horizontal rotation
  EXTPTZ_STOPPANCRUISE = 21, // Stop horizontal rotation
  EXTPTZ_SETLEFTBORDER = 22, // Set the left boundary
  EXTPTZ_SETRIGHTBORDER = 23, // Set the right boundary
  EXTPTZ_STARTLINESCAN = 24, // Automatic scanning starts
  EXTPTZ_CLOSELINESCAN = 25, // Automatic scanning starts and stops
  EXTPTZ_ADDTOLOOP = 26, // Add preset points to cruise p1 preset points for cruise line p2
  EXTPTZ_DELFROMLOOP = 27, // Delete preset point p1 on cruise line p2
  EXTPTZ_POINT_LOOP_CONTROL = 28, // Start cruising
  EXTPTZ_POINT_STOP_LOOP_CONTROL = 29, // Stop cruising
  EXTPTZ_CLOSELOOP = 30, // Clear the cruise p1 cruise line
  EXTPTZ_FASTGOTO = 31, // Fast positioning
  EXTPTZ_AUXIOPEN = 32, // Auxiliary switch, off in the subcommand
  EXTPTZ_OPERATION_MENU = 33, // Ball machine menu operation, including on, off, OK, etc
  EXTPTZ_REVERSECOMM = 34, // Lens flip
  EXTPTZ_OPERATION_RESET = 35, ///< Head reset
  EXTPTZ_TOTAL = 36,
}

export type DeviceManagerPromiseSuccessType = {
  s: string;
  i: number;
};

export type DeviceIdParams = {
  deviceId: string;
};

export type DeviceCredentialParams = {
  deviceId: string;
  deviceLogin: string;
  devicePassword: string;
};

export enum EFUN_ATTR {
  APP_PATH = 1,
  DOC_PATH = 2,
  CONFIG_PATH = 2,
  UPDATE_FILE_PATH = 3,
  SAVE_LOGIN_USER_INFO = 4,
  AUTO_DL_UPGRADE = 5,
  FUN_MSG_HANDLE = 6,
  SET_NET_TYPE = 7,
  GET_IP_FROM_SN = 8,
  TEMP_FILES_PATH = 9,
  USER_PWD_DB = 10,
  LOGIN_ENC_TYPE = 11,
  LOGIN_USER_ID = 12,
  CLEAR_SDK_CACHE_DATA = 13,
  DSS_STREAM_ENC_SYN_DEV = 14,
  CDATACENTER_LANGUAGE = 15,
  LOGIN_SUP_RSA_ENC = 16,
  JUDEGE_RPSVIDEO_ABILITY = 17,
  LOGIN_AES_ENC_RESULT = 18,
  FACE_CHECK_OCX = 19,
  GET_ALL_DECODER_FRAME_BITS_PS = 20,
  LOGIN_RPS_STATE_ALLOW = 21,
  SUP_RPS_VIDEO_DEFAULT = 22,
  SET_DSS_REAL_PLAY_FLUENCY = 23,
  SET_CLOUD_UPGRADE_CHECK_URL = 24,
  CLOUD_UPGRADE_DOWNLOAD_URL = 25,
  SET_RPS_DATA_ENCRYPT_ENABLE = 26,
  SET_HTTP_PROTOCOL_USER_AGENT = 27,
  SET_MULTI_VIEW_DROP_FRAME_NUMBER = 28,
  GET_USER_ACCOUNT_DATA_INFO = 29,
  SET_SUPPORT_CFG_CLOUD_UPGRADE = 30,
  DEV_TOKEN_ERROR_LISTENER = 31,
  QUERY_P2P_STATUS_ENABLE_FORM_SERVER = 32,
  QUERY_P2P_STATUS_ENABLE = 33,
  SET_CLOUD_DOWNLOAD_NETPTL = 34,
  SUP_HISI_H265_DEC = 35,
  DEV_LOGIN_ENC_TOKEN_WHERE_TO_GET_IT = 36,
  MQTT_CLIENTID = 37,
  SET_NETIP_PTL_SEND_PKT_MAX_SIZE = 38,
  EOA_DEVICE_ID = 10000,
  EOA_CHANNEL_ID = 10001,
  EOA_IP = 10002,
  EOA_PORT = 10003,
  EOA_IP_PORT = 10004,
  EOA_STREAM_TYPE = 10005,
  EOA_NET_MODE = 10006,
  EOA_COM_TYPE = 10007,
  EOA_VIDEO_WIDTH_HEIGHT = 10008,
  EOA_VIDEO_FRATE = 10009,
  EOA_VIDEO_BUFFER_SIZE = 10010,
  EOA_PLAY_INFOR = 10011,
  EOA_PCM_SET_SOUND = 10012,
  EOA_CUR_PLAY_TIME = 10013,
  EOA_MEDIA_YUV_USER = 10014,
  EOA_SET_MEDIA_VIEW_VISUAL = 10015,
  EOA_SET_MEDIA_DATA_USER_AND_NO_DEC = 10016,
  EOA_SET_MEDIA_DATA_USER = 10017,
  EOA_DISABLE_DSS_FUN = 10018,
  EOA_DEV_REAL_PLAY_TYPE = 10019,
  EOA_SET_PLAYER_USER = 10020,
  EOA_GET_ON_FRAME_USER_DATA = 10021,
  EOA_GET_XTSC_CONNECT_QOS = 10022,
  EOA_GET_ON_AUDIO_FRAME_DATA = 10023,
  EOA_SET_AUDIO_FRAME_SAMPLES_TYPE = 10024,
  EOA_SET_DEV_TALK_DATA_USER = 10025,
  EDOPT_STORAGEMANAGE = 1,
  EDOPT_DEV_CONTROL = 2,
  EDOPT_DEV_GET_IMAGE = 3,
  EDA_STATE_CHN = 1,
  EDA_OPT_ALARM = 2,
  EDA_OPT_RECORD = 3,
  EDA_DEV_INFO = 4,
  EDA_DEV_OPEN_TANSPORT_COM = 5,
  EDA_DEV_CLOSE_TANSPORT_COM = 6,
  EDA_DEV_TANSPORT_COM_READ = 7,
  EDA_DEV_TANSPORT_COM_WRITE = 8,
  EDA_NET_KEY_CLICK = 9,
}

export type DeviceInfoType = {
  HardWareVersion: string;
  TalkInChannel: number;
  DeviceRunTime: string;
  DigChannel: number;
  ExtraChannel: number;
  VideoInChannel: number;
  TalkOutChannel: number;
  AudioInChannel: number;
  DeviceType: number;
  HardWare: string;
  AlarmOutChannel: number;
  UpdataType: string;
  VideoOutChannel: number;
  UpdataTime: string;
  BuildTime: string;
  EncryptVersion: string;
  AlarmInChannel: number;
  CombineSwitch: number;
  SerialNo: string;
  SoftWareVersion: string;
  DeviceModel: string;
};
