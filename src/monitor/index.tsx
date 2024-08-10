import React, { RefObject } from 'react';
import type { ViewProps } from 'react-native';
import {
  requireNativeComponent,
  UIManager,
  findNodeHandle,
} from 'react-native';
import { FUNSDK_MEDIA_PLAY_STATE_ENUM, STREAM_TYPE } from '../types/stream';

const Commands = {
  // setVideoFlip: 'setVideoFlip',
  startMonitor: 'startMonitor',
  pauseMonitor: 'pauseMonitor',
  replayMonitor: 'replayMonitor',
  stopMonitor: 'stopMonitor',
  destroyMonitor: 'destroyMonitor',
  captureImage: 'captureImage',
  getStreamType: 'getStreamType',
  startVideoRecord: 'startVideoRecord',
  stopVideoRecord: 'stopVideoRecord',
  openVoice: 'openVoice',
  closeVoice: 'closeVoice',
  // depreceated
  // setSpeakerType: 'setSpeakerType',
  startSingleIntercomAndSpeak: 'startSingleIntercomAndSpeak',
  stopSingleIntercomAndSpeak: 'stopSingleIntercomAndSpeak',
  startDoubleIntercom: 'startDoubleIntercom',
  stopDoubleIntercom: 'stopDoubleIntercom',
  switchStreamTypeMonitor: 'switchStreamTypeMonitor',
  updateStreamTypeMonitor: 'updateStreamTypeMonitor',
  setVideoFullScreen: 'setVideoFullScreen',
  capturePicFromDevAndSave: 'capturePicFromDevAndSave',
  seekToTime: 'seekToTime',
  changeVideoRatio: 'changeVideoRatio',
} as const;

export type MonitorViewNativeProps = ViewProps & {
  devId: string;
  channelId: number;
  streamType: STREAM_TYPE;
  onMediaPlayState: (event: {
    nativeEvent: { state: FUNSDK_MEDIA_PLAY_STATE_ENUM | number };
  }) => void;
  onShowRateAndTime: (event: {
    nativeEvent: { time: string; rate: string };
  }) => void;
  onVideoBufferEnd: (event: { nativeEvent: { isBufferEnd: boolean } }) => void;
  onGetInfo: (event: {
    nativeEvent: { type: 'streamType'; streamType: number };
  }) => void;
  onFailed: (event: {
    nativeEvent: { msgId: number; errorId: number };
  }) => void;
  onStartInit: (event: { nativeEvent: {} }) => void;
  onDebugState: (event: { nativeEvent: { state: string } }) => void;
  onCapture: (event: { nativeEvent: { path: string } }) => void;
};

export const MonitorView =
  requireNativeComponent<MonitorViewNativeProps>('RCTMonitor');

const dispatchCommand = (viewId: number, command: string, args: any[] = []) => {
  UIManager.dispatchViewManagerCommand(
    viewId,
    // we are calling the 'setVideoFlip' command
    // UIManager.RCTMonitor.Commands.setVideoFlip,
    // UIManager.RCTMonitor.Commands[command],
    UIManager.getViewManagerConfig('RCTMonitor').Commands[command] || '',
    args
  );
};

export type MonitorProps = ViewProps & {
  devId: string;
  channelId: number;
  streamType?: STREAM_TYPE;
  onStartInit?: () => void;
  onMediaPlayState?: (obj: {
    state: FUNSDK_MEDIA_PLAY_STATE_ENUM | number;
  }) => void;
  onShowRateAndTime?: (obj: { time: string; rate: string }) => void;
  onVideoBufferEnd?: (obj: { isBufferEnd: boolean }) => void;
  onGetInfo?: (obj: { type: 'streamType'; streamType: number }) => void;
  onFailed?: (obj: { msgId: number; errorId: number }) => void;
  onDebugState?: (obj: { state: string }) => void;
  onCapture?: (obj: { path: string }) => void;
};

export class Monitor extends React.Component<MonitorProps, any> {
  private myRef: RefObject<any>;

  constructor(props: MonitorProps) {
    super(props);
    this.myRef = React.createRef();
  }

  // flipVideo() {
  //   const viewId = findNodeHandle(this.myRef.current);

  //   if (typeof viewId !== 'number') {
  //     return;
  //   }

  //   dispatchCommand(viewId, Commands.setVideoFlip);
  // }

  playVideo() {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.startMonitor);
  }

  pauseVideo() {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.pauseMonitor);
  }

  replayVideo() {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.replayMonitor);
  }

  stopVideo() {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.stopMonitor);
  }

  destroyVideo() {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.destroyMonitor);
  }

  getStreamType() {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.getStreamType);
  }

  captureImage(path: string) {
    const viewId = findNodeHandle(this.myRef.current);
    if (typeof viewId !== 'number' || typeof path !== 'string') {
      return;
    }

    dispatchCommand(viewId, Commands.captureImage, [path]);
  }

  startVideoRecord(path: string) {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number' || typeof path !== 'string') {
      return;
    }

    dispatchCommand(viewId, Commands.startVideoRecord, [path]);
  }

  stopVideoRecord() {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.stopVideoRecord);
  }

  openVoice() {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.openVoice);
  }

  closeVoice() {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.closeVoice);
  }

  // depreceated
  /**
   * set voice changer
   * 0 normal, 1 male ,2 female
   */
  // setSpeakerType(type: 0 | 1 | 2) {
  //   const viewId = findNodeHandle(this.myRef.current);

  //   if (typeof viewId !== 'number') {
  //     return;
  //   }

  //   dispatchCommand(viewId, Commands.setSpeakerType, [type]);
  // }

  startSingleIntercomAndSpeak() {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.startSingleIntercomAndSpeak);
  }

  stopSingleIntercomAndSpeak() {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.stopSingleIntercomAndSpeak);
  }

  startDoubleIntercom() {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.startDoubleIntercom);
  }

  stopDoubleIntercom() {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.stopDoubleIntercom);
  }

  switchStreamTypeMonitor() {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.switchStreamTypeMonitor);
  }

  updateStreamTypeMonitor(streamType: STREAM_TYPE) {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.updateStreamTypeMonitor, [streamType]);
  }

  setVideoFullScreen(isFullScreen: boolean) {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number' || typeof isFullScreen !== 'boolean') {
      return;
    }

    dispatchCommand(viewId, Commands.setVideoFullScreen, [isFullScreen]);
  }

  capturePicFromDevAndSave() {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.capturePicFromDevAndSave);
  }

  changeVideoRatio() {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.changeVideoRatio);
  }

  // seekToTime() {
  //   const viewId = findNodeHandle(this.myRef.current);
  //   if (typeof viewId !== 'number') {
  //     return;
  //   }

  //   dispatchCommand(viewId, Commands.seekToTime);
  // }

  _onStartInit = () => {
    this.props?.onStartInit && this.props?.onStartInit();
  };

  _onMediaPlayState = (
    event: Parameters<MonitorViewNativeProps['onMediaPlayState']>[0]
  ) => {
    this.props?.onMediaPlayState &&
      this.props?.onMediaPlayState(event.nativeEvent);
  };

  _onShowRateAndTime = (
    event: Parameters<MonitorViewNativeProps['onShowRateAndTime']>[0]
  ) => {
    this.props?.onShowRateAndTime &&
      this.props?.onShowRateAndTime(event.nativeEvent);
  };

  _onVideoBufferEnd = (
    event: Parameters<MonitorViewNativeProps['onVideoBufferEnd']>[0]
  ) => {
    this.props?.onVideoBufferEnd &&
      this.props?.onVideoBufferEnd(event.nativeEvent);
  };

  _onGetInfo = (event: Parameters<MonitorViewNativeProps['onGetInfo']>[0]) => {
    this.props?.onGetInfo && this.props?.onGetInfo(event.nativeEvent);
  };

  _onFailed = (event: { nativeEvent: { msgId: number; errorId: number } }) => {
    this.props?.onFailed && this.props?.onFailed(event.nativeEvent);
  };

  _onDebugState = (event: { nativeEvent: { state: string } }) => {
    this.props?.onDebugState && this.props?.onDebugState(event.nativeEvent);
  };

  _onCapture = (event: { nativeEvent: { path: string } }) => {
    this.props?.onCapture && this.props?.onCapture(event.nativeEvent);
  };

  render() {
    return (
      <MonitorView
        streamType={STREAM_TYPE.EXTRA}
        {...this.props}
        ref={this.myRef}
        onStartInit={this._onStartInit}
        onMediaPlayState={this._onMediaPlayState}
        onShowRateAndTime={this._onShowRateAndTime}
        onVideoBufferEnd={this._onVideoBufferEnd}
        onGetInfo={this._onGetInfo}
        onFailed={this._onFailed}
        onDebugState={this._onDebugState}
        onCapture={this._onCapture}
      />
    );
  }
}
