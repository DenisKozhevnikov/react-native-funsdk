/**
 * Обратные вызовы для состояний воспроизведения
 * -1; // Не инициализировано
 * 0; // Воспроизведение
 * 1; // Пауза
 * 2; // Получение данных
 * 3; // Обновление
 * 4; // Остановка
 * 5; // Возобновление
 * 6; // Невозможно воспроизвести
 * 7; // Готово к воспроизведению
 * 8; // Разрыв медиасоединения
 * 9; // Звук включен
 * 10; // Звук выключен
 * 11; // Повторное соединение
 * 12; // Режим виртуальной реальности
 * -5; // Сбой аппаратной декодирования
 * 13; // Ошибка подключения, пожалуйста, обновите (используется в xmeye)
 * 14; // Видео отсутствует (используется в xmeye)
 * 15; // Обратный вызов для настройки воспроизведения
 * 16; // Воспроизведение завершено, обычно используется для воспроизведения записей
 * 17; // Поиск при воспроизведении записей
 * 18; // Сохранение записи успешно
 * 19; // Сохранение изображения успешно
 */
export enum FUNSDK_MEDIA_PLAY_STATE_ENUM {
  E_HARDDECODER_FAILURE = -5,
  E_STATE_UNINIT = -1,
  E_STATE_PlAY = 0,
  E_STATE_PAUSE = 1,
  E_STATE_BUFFER = 2,
  E_STATE_REFRESH = 3,
  E_STATE_STOP = 4,
  E_STATE_RESUME = 5,
  E_STATE_CANNOT_PLAY = 6,
  E_STATE_READY_PLAY = 7,
  E_STATE_MEDIA_DISCONNECT = 8,
  E_STATE_MEDIA_SOUND_ON = 9,
  E_STATE_MEDIA_SOUND_OFF = 10,
  E_STATE_RECONNECT = 11,
  E_STATE_CHANGE_VR_MODE = 12,
  E_OPEN_FAILED = 13,
  E_NO_VIDEO = 14,
  E_STATE_SET_PLAY_VIEW = 15,
  E_STATE_PLAY_COMPLETED = 16,
  E_STATE_PLAY_SEEK = 17,
  E_STATE_SAVE_RECORD_FILE_S = 18,
  E_STATE_SAVE_PIC_FILE_S = 19,
}

export enum FUNSDK_DOWNLOAD_STATE_ENUM {
  DOWNLOAD_STATE_UNINT = 0,
  DOWNLOAD_STATE_START = 1,
  DOWNLOAD_STATE_PROGRESS = 2,
  DOWNLOAD_STATE_COMPLETE = 3,
  DOWNLOAD_STATE_STOP = 4,
  DOWNLOAD_STATE_FAILED = 5,
  DOWNLOAD_STATE_COMPLETE_ALL = 6,
}

export enum STREAM_TYPE {
  MAIN = 0,
  EXTRA = 1,
  ALL = 2,
}

// typedef enum SDK_File_Type
// {
//     SDK_RECORD_ALL = 0,         // 全部录像(查询类型:h264/子类型:*)
//     SDK_RECORD_ALARM = 1,       // 外部报警录像(查询类型:h264/子类型:A)
//     SDK_RECORD_DETECT = 2,      // 视频侦测录像(查询类型:h264/子类型:M)
//     SDK_RECORD_REGULAR = 3,     // 普通录像(查询类型:h264/子类型:*)
//     SDK_RECORD_MANUAL = 4,      // 手动录像(查询类型:h264//子类型:H)
//     SDK_RECORD_KEY = 5,         // 关键录像(查询类型:h264/子类型:K)
//     SDK_RECORD_URGENT = 6,      // 紧急录像(查询类型:h264/子类型:V)
//     SDK_RECORD_ORIGINAL = 7,    // 原始录像(查询类型:mp4/子类型:R)
//     SDK_PIC_ALL = 10,           // 全部图片(查询类型:jpg/子类型:*）
//     SDK_PIC_ALARM = 11,         // 外部报警图片(查询类型:jpg/子类型:A）
//     SDK_PIC_DETECT = 12,    // 视频侦测图片(查询类型:jpg/子类型:M）
//     SDK_PIC_REGULAR = 13,       // 普通图片(查询类型:jpg/子类型:R）
//     SDK_PIC_MANUAL = 14,        // 手动图片(查询类型:jpg/子类型:H）
//     SDK_PIC_IDXIMG = 15,    // 索引图片(查询类型:jpg/子类型:*）
//   SDK_PIC_KEY = 16,        // 关键图片(查询类型:jpg/子类型:K）
//   SDK_PIC_INDUCTION = 17,      // 感应图片(查询子类型:P）
// }SDK_File_Type;

export enum FILE_TYPE {
  SDK_RECORD_ALL = 0,
  SDK_RECORD_ALARM = 1,
  SDK_RECORD_DETECT = 2,
  SDK_RECORD_REGULAR = 3,
  SDK_RECORD_MANUAL = 4,
  SDK_PIC_ALL = 10,
  SDK_PIC_ALARM = 11,
  SDK_PIC_DETECT = 12,
  SDK_PIC_REGULAR = 13,
  SDK_PIC_MANUAL = 14,
  SDK_TYPE_NUM = 15,
}
