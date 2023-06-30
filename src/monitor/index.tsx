import React, { RefObject } from 'react';
import type { ViewProps } from 'react-native';
import {
  requireNativeComponent,
  UIManager,
  findNodeHandle,
} from 'react-native';

const Commands = {
  // setVideoFlip: 'setVideoFlip',
  startMonitor: 'startMonitor',
  pauseMonitor: 'pauseMonitor',
  replayMonitor: 'replayMonitor',
  stopMonitor: 'stopMonitor',
  destroyMonitor: 'destroyMonitor',
  captureImage: 'captureImage',
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
  setVideoFullScreen: 'setVideoFullScreen',
  capturePicFromDevAndSave: 'capturePicFromDevAndSave',
} as const;

export const MonitorView = requireNativeComponent('RCTMonitor');

const dispatchCommand = (viewId: number, command: string, args: any[] = []) =>
  UIManager.dispatchViewManagerCommand(
    viewId,
    // we are calling the 'setVideoFlip' command
    // UIManager.RCTMonitor.Commands.setVideoFlip,
    // UIManager.RCTMonitor.Commands[command],
    UIManager.getViewManagerConfig('RCTMonitor').Commands[command] || '',
    args
  );

type MonitorProps = ViewProps & {
  devId: string;
  // Props для компонента MonitorView
  // ...
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

  swtichStream() {
    const viewId = findNodeHandle(this.myRef.current);

    if (typeof viewId !== 'number') {
      return;
    }

    dispatchCommand(viewId, Commands.switchStreamTypeMonitor);
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

  render() {
    return <MonitorView {...this.props} ref={this.myRef} />;
  }
}
