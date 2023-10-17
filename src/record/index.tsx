import React, { forwardRef, useImperativeHandle, useRef } from 'react';
import {
  requireNativeComponent,
  // UIManager,
  // findNodeHandle,
  NativeMethods,
  ViewProps,
  UIManager,
  findNodeHandle,
} from 'react-native';
import type {
  FUNSDK_DOWNLOAD_STATE_ENUM,
  FUNSDK_MEDIA_PLAY_STATE_ENUM,
} from './types';

const Commands = {
  startPlayRecord: 'startPlayRecord',
  searchRecordByFile: 'searchRecordByFile',
  capture: 'capture',
  startRecord: 'startRecord',
  stopRecord: 'stopRecord',
  isRecording: 'isRecording',
  openVoice: 'openVoice',
  closeVoice: 'closeVoice',
  pausePlay: 'pausePlay',
  rePlay: 'rePlay',
  stopPlay: 'stopPlay',
  destroyPlay: 'destroyPlay',
  isRecordPlay: 'isRecordPlay',
  downloadFile: 'downloadFile',
  setPlaySpeed: 'setPlaySpeed',
};

const dispatchCommand = (viewId: number, command: string, args: any[] = []) => {
  UIManager.dispatchViewManagerCommand(
    viewId,
    UIManager.getViewManagerConfig('RCTDevRecordMonitor').Commands[command] ||
      '',
    args
  );
};

export enum SearcResultRecordEnum {
  RECORD_FILES = 'recordfiles',
  RECORD_TIMELIST = 'recordtimelist',
}

export type SearcResultRecordFile = {
  channel: number;
  filesize: number;
  filename: string;
  startDate: string;
  startTimeOfDay: string;
  startTimeOfYear: string;
  startTimeLong: number;
  endTimeOfDay: string;
  endTimeOfYear: string;
  endTimeLong: number;
  endTimeLong24Hours: number;
  alarmExFileInfo: string;
  fileTimeLong: number;
  streamType: number;
};

export type RecordViewNativeProps = ViewProps & {
  onMediaPlayState: (event: {
    nativeEvent: { playSpeed: number; state: number };
  }) => void;
  onShowRateAndTime: (event: {
    nativeEvent: { time: string; rate: string };
  }) => void;
  onVideoBufferEnd: (event: { nativeEvent: { isBufferEnd: boolean } }) => void;
  onSearchRecordByFilesResult: (event: {
    nativeEvent: {
      type: SearcResultRecordEnum;
      list: SearcResultRecordFile[];
    };
  }) => void;
  onFailed: (event: {
    nativeEvent: { msgId: number; errorId: number };
  }) => void;
  onStartInit: (event: { nativeEvent: {} }) => void;
  onDebugState: (event: { nativeEvent: { state: string } }) => void;
  onDownloadProgress?: (event: { nativeEvent: { progress: number } }) => void;
  onDownloadState?: (event: {
    nativeEvent: {
      downloadState: FUNSDK_DOWNLOAD_STATE_ENUM;
      fileName: string;
    };
  }) => void;
};

export type RecordViewComponent = React.ComponentClass<RecordViewNativeProps>;

export const RecordView = requireNativeComponent<RecordViewNativeProps>(
  'RCTDevRecordMonitor'
);

export type RecordPlayerProps = ViewProps & {
  devId: string;
  onMediaPlayState?: (obj: {
    playSpeed: number;
    state: FUNSDK_MEDIA_PLAY_STATE_ENUM;
  }) => void;
  onShowRateAndTime?: (obj: { time: string; rate: string }) => void;
  onVideoBufferEnd?: (obj: { isBufferEnd: boolean }) => void;
  onSearchRecordByFilesResult?: (obj?: {
    type: SearcResultRecordEnum;
    list: SearcResultRecordFile[];
  }) => void;
  onFailed?: (obj: { msgId: number; errorId: number }) => void;
  onStartInit?: () => void;
  onDebugState?: (obj: { state: string }) => void;
  onDownloadProgress?: (obj: { progress: number }) => void;
  onDownloadState?: (obj: {
    downloadState: FUNSDK_DOWNLOAD_STATE_ENUM;
    fileName: string;
  }) => void;
};

export type RecordPlayerRef = {
  startPlayRecord: (position: number) => void;
  searchRecordByFile: (startTimestamp: number, endTimestamp: number) => void;
  capture: (path: string) => void;
  startRecord: (path: string) => void;
  stopRecord: () => void;
  isRecording: () => void;
  openVoice: () => void;
  closeVoice: () => void;
  pausePlay: () => void;
  rePlay: () => void;
  stopPlay: () => void;
  destroyPlay: () => void;
  isRecordPlay: () => void;
  downloadFile: (position: number, path: string) => void;
  setPlaySpeed: (playSpeed: -3 | -2 | -1 | 0 | 1 | 2 | 3 | number) => void;
};

export const RecordPlayer = forwardRef<RecordPlayerRef, RecordPlayerProps>(
  (
    {
      onMediaPlayState,
      onShowRateAndTime,
      onVideoBufferEnd,
      onSearchRecordByFilesResult,
      onFailed,
      onStartInit,
      onDebugState,
      onDownloadProgress,
      onDownloadState,
      ...props
    },
    ref
  ) => {
    const viewRef = useRef<
      React.Component<RecordViewNativeProps, {}, any> & Readonly<NativeMethods>
    >(null);

    useImperativeHandle(
      ref,
      () => {
        return {
          startPlayRecord(position: number) {
            const viewId = findNodeHandle(viewRef.current);

            if (typeof viewId !== 'number') {
              return;
            }

            dispatchCommand(viewId, Commands.startPlayRecord, [position]);
          },
          searchRecordByFile(startTimestamp: number, endTimestamp: number) {
            const viewId = findNodeHandle(viewRef.current);

            if (typeof viewId !== 'number') {
              return;
            }

            dispatchCommand(viewId, Commands.searchRecordByFile, [
              startTimestamp,
              endTimestamp,
            ]);
          },

          capture(path: string) {
            const viewId = findNodeHandle(viewRef.current);

            if (typeof viewId !== 'number') {
              return;
            }

            dispatchCommand(viewId, Commands.capture, [path]);
          },
          startRecord(path: string) {
            const viewId = findNodeHandle(viewRef.current);

            if (typeof viewId !== 'number') {
              return;
            }

            dispatchCommand(viewId, Commands.startRecord, [path]);
          },
          stopRecord() {
            const viewId = findNodeHandle(viewRef.current);

            if (typeof viewId !== 'number') {
              return;
            }

            dispatchCommand(viewId, Commands.stopRecord, []);
          },
          isRecording() {
            const viewId = findNodeHandle(viewRef.current);

            if (typeof viewId !== 'number') {
              return;
            }

            dispatchCommand(viewId, Commands.isRecording, []);
          },
          openVoice() {
            const viewId = findNodeHandle(viewRef.current);

            if (typeof viewId !== 'number') {
              return;
            }

            dispatchCommand(viewId, Commands.openVoice, []);
          },
          closeVoice() {
            const viewId = findNodeHandle(viewRef.current);

            if (typeof viewId !== 'number') {
              return;
            }

            dispatchCommand(viewId, Commands.closeVoice, []);
          },
          pausePlay() {
            const viewId = findNodeHandle(viewRef.current);

            if (typeof viewId !== 'number') {
              return;
            }

            dispatchCommand(viewId, Commands.pausePlay, []);
          },
          rePlay() {
            const viewId = findNodeHandle(viewRef.current);

            if (typeof viewId !== 'number') {
              return;
            }

            dispatchCommand(viewId, Commands.rePlay, []);
          },
          stopPlay() {
            const viewId = findNodeHandle(viewRef.current);

            if (typeof viewId !== 'number') {
              return;
            }

            dispatchCommand(viewId, Commands.stopPlay, []);
          },
          destroyPlay() {
            const viewId = findNodeHandle(viewRef.current);

            if (typeof viewId !== 'number') {
              return;
            }

            dispatchCommand(viewId, Commands.destroyPlay, []);
          },
          isRecordPlay() {
            const viewId = findNodeHandle(viewRef.current);

            if (typeof viewId !== 'number') {
              return;
            }

            dispatchCommand(viewId, Commands.isRecordPlay, []);
          },
          downloadFile(position: number, path: string) {
            const viewId = findNodeHandle(viewRef.current);

            if (typeof viewId !== 'number') {
              return;
            }

            dispatchCommand(viewId, Commands.downloadFile, [position, path]);
          },
          /**
           * Устанавливает скорость воспроизведения для видео или аудио.
           *
           * @param {number} playSpeed - Скорость воспроизведения. Может быть одним из следующих значений:
           *   -3, -2, -1, 0, 1, 2, 3
           * @returns {void}
           */
          setPlaySpeed(playSpeed: -3 | -2 | -1 | 0 | 1 | 2 | 3 | number): void {
            const viewId = findNodeHandle(viewRef.current);

            if (typeof viewId !== 'number') {
              return;
            }

            dispatchCommand(viewId, Commands.setPlaySpeed, [playSpeed]);
          },
        };
      },
      []
    );

    const _onMediaPlayState = (
      event: Parameters<RecordViewNativeProps['onMediaPlayState']>[0]
    ) => {
      onMediaPlayState && onMediaPlayState(event.nativeEvent);
    };

    const _onShowRateAndTime = (
      event: Parameters<RecordViewNativeProps['onShowRateAndTime']>[0]
    ) => {
      onShowRateAndTime && onShowRateAndTime(event.nativeEvent);
    };

    const _onVideoBufferEnd = (
      event: Parameters<RecordViewNativeProps['onVideoBufferEnd']>[0]
    ) => {
      onVideoBufferEnd && onVideoBufferEnd(event.nativeEvent);
    };

    const _onSearchRecordByFilesResult = (
      event: Parameters<RecordViewNativeProps['onSearchRecordByFilesResult']>[0]
    ) => {
      onSearchRecordByFilesResult &&
        onSearchRecordByFilesResult(event.nativeEvent);
    };

    const _onStartInit = () => {
      onStartInit && onStartInit();
    };

    const _onFailed = (event: {
      nativeEvent: { msgId: number; errorId: number };
    }) => {
      onFailed && onFailed(event.nativeEvent);
    };

    const _onDebugState = (event: { nativeEvent: { state: string } }) => {
      onDebugState && onDebugState(event.nativeEvent);
    };

    const _onDownloadProgress = (event: {
      nativeEvent: { progress: number };
    }) => {
      onDownloadProgress && onDownloadProgress(event.nativeEvent);
    };

    const _onDownloadState = (event: {
      nativeEvent: {
        downloadState: FUNSDK_DOWNLOAD_STATE_ENUM;
        fileName: string;
      };
    }) => {
      onDownloadState && onDownloadState(event.nativeEvent);
    };

    return (
      <RecordView
        ref={viewRef}
        {...props}
        onMediaPlayState={_onMediaPlayState}
        onShowRateAndTime={_onShowRateAndTime}
        onVideoBufferEnd={_onVideoBufferEnd}
        onSearchRecordByFilesResult={_onSearchRecordByFilesResult}
        onFailed={_onFailed}
        onStartInit={_onStartInit}
        onDebugState={_onDebugState}
        onDownloadProgress={_onDownloadProgress}
        onDownloadState={_onDownloadState}
      />
    );
  }
);
