import React, { useState } from 'react';
import {
  StyleSheet,
  View,
  TouchableOpacity,
  Text,
  ScrollView,
  RefreshControl,
} from 'react-native';
import {
  Monitor,
  devicePTZcontrol,
  // getChannelCount,
  getChannelInfo,
  // isDeviceFunctionSupport,
  // getDeviceModel,
  // getSoftWareVersion,
  // getBuildTime,
  EPTZCMD,
  DevicePTZControlParams,
  STREAM_TYPE,
  // getHardWare,
  // getUpdataTime,
  // getNetworkMode,
  // getDigChannel,
} from 'react-native-funsdk';
import { DEVICE_ID } from '../topsecret';
import { MonitorView } from './MonitorView';
import { handleImageSaver } from './ImageSaver';

export const monitorsList = new Map<number, React.RefObject<Monitor>>();

export const MonitorPage = ({ isAuth }: { isAuth: boolean }) => {
  // const [numberOfCameras, setNumberOfCameras] = useState<number | null>(null);
  const [numberOfCameras, setNumberOfCameras] = useState<number | null>(5);
  const [activeChannel, setActiveChannel] = useState(0);
  const [PTZSpeed, setPTZSpeed] =
    useState<NonNullable<DevicePTZControlParams['speed']>>(4);
  const [isLogged, setIsLogged] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const getMonitor = (channelId: number) => {
    const hasMonitor = monitorsList.has(channelId);
    console.log('hasMonitor: ', hasMonitor);
    if (!hasMonitor) {
      return;
    }

    return monitorsList.get(channelId);
  };

  const handleDeviceLogin = async () => {
    try {
      setIsLoading(true);
      const info = await getChannelInfo({ deviceId: DEVICE_ID });
      console.log('info getChannelInfo: ', info);
      const nChnCount = info?.value?.nChnCount;
      if (typeof nChnCount === 'number') {
        if (!nChnCount) {
          setNumberOfCameras(1);
        } else {
          setNumberOfCameras(nChnCount);
        }
      }
      setIsLogged(true);
    } catch (error) {
      console.log('error login: ', error);
    } finally {
      setIsLoading(false);
    }
  };

  const openVoice = () => {
    getMonitor(activeChannel)?.current?.openVoice();
  };

  const closeVoice = () => {
    getMonitor(activeChannel)?.current?.closeVoice();
  };

  const loadChannelsInfo = async () => {
    try {
      const info = await getChannelInfo({ deviceId: DEVICE_ID });
      console.log('channels info is: ', info);
    } catch (error) {
      console.log('loadChannelsInfo error: ', error);
    }
  };

  // const loadChannelsCount = async () => {
  //   try {
  //     const count = await getChannelCount({ deviceId: DEVICE_ID });
  //     console.log('channels count is: ', count);
  //   } catch (error) {
  //     console.log('loadChannelCount error: ', error);
  //   }
  // };

  const devicePTZSend = async (command: number, bStop: boolean) => {
    try {
      const count = await devicePTZcontrol({
        deviceId: DEVICE_ID,
        deviceChannel: activeChannel,
        command,
        bStop,
        speed: PTZSpeed,
      });
      console.log('channels count is: ', count);
    } catch (error) {
      console.log('devicePTZSend error: ', error);
    }
  };

  // const checkDeviceFunctionSupport = async () => {
  //   try {
  //     const result = await isDeviceFunctionSupport({
  //       deviceId: DEVICE_ID,
  //       functionName: 'OtherFunction',
  //       functionCommandStr: 'SupportPTZTour',
  //     });
  //     console.log('OtherFunction is: ', result);
  //   } catch (error) {
  //     console.log('checkDeviceFunctionSupport error: ', error);
  //   }
  // };

  // const loadDeviceModel = async () => {
  //   try {
  //     const result = await getDeviceModel({
  //       deviceId: DEVICE_ID,
  //     });
  //     console.log('getDeviceModel is: ', result);
  //   } catch (error) {
  //     console.log('getDeviceModel error: ', error);
  //   }
  // };

  // const loadSoftWareVersion = async () => {
  //   try {
  //     const result = await getSoftWareVersion({
  //       deviceId: DEVICE_ID,
  //     });
  //     console.log('getDeviceModel is: ', result);
  //   } catch (error) {
  //     console.log('getDeviceModel error: ', error);
  //   }
  // };

  // const loadDeviceInfo = async () => {
  //   try {
  //     const result = await getBuildTime({
  //       deviceId: DEVICE_ID,
  //     });
  //     console.log('getBuildTime is: ', result);
  //   } catch (error) {
  //     console.log('getDeviceModel error: ', error);
  //   }
  // };

  const startPlay = () => {
    console.log('startPlay');
    // console.log('startPlay', getMonitor(activeChannel));
    getMonitor(activeChannel)?.current?.playVideo();
    // monitorRef.current?.playVideo();
    // monitorRef2.current?.playVideo();
  };

  const handleCapture = () => {
    handleImageSaver(DEVICE_ID, activeChannel, (path) => {
      getMonitor(activeChannel)?.current?.captureImage(path);
    });
  };

  // const handleChangeVideoRatio = () => {
  //   handleImageSaver(DEVICE_ID, activeChannel, () => {
  //     getMonitor(activeChannel)?.current?.changeVideoRatio();
  //   });
  // };

  if (!isAuth) {
    return null;
  }

  if (!isLogged) {
    return (
      <View style={styles.container}>
        <TouchableOpacity style={styles.button} onPress={handleDeviceLogin}>
          <Text style={styles.buttonText}>device login</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <ScrollView
        refreshControl={
          <RefreshControl
            onRefresh={handleDeviceLogin}
            refreshing={isLoading}
          />
        }
        style={{
          marginTop: 30,
          flexDirection: 'row',
          flexWrap: 'wrap',
          height: 400,
          backgroundColor: 'blue',
        }}
      >
        {!!numberOfCameras &&
          [...Array(numberOfCameras >= 3 ? 3 : numberOfCameras).keys()].map(
            (val) => (
              <MonitorView
                key={val}
                devId={DEVICE_ID}
                channelId={val}
                isActive={activeChannel === val}
                onPress={() => setActiveChannel(val)}
              />
            )
          )}
        {/* {!!numberOfCameras &&
          [...Array(numberOfCameras).keys()].map((val) => (
            <MonitorView
              key={val}
              devId={DEVICE_ID}
              channelId={val}
              isActive={activeChannel === val}
              onPress={() => setActiveChannel(val)}
            />
          ))} */}
      </ScrollView>
      <ScrollView>
        {/* <TouchableOpacity
          onPress={handleChangeVideoRatio}
          style={styles.button}
        >
          <Text style={styles.buttonText}>change video ratio</Text>
        </TouchableOpacity> */}
        <TouchableOpacity onPress={handleCapture} style={styles.button}>
          <Text style={styles.buttonText}>capture image</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={startPlay} style={styles.button}>
          <Text style={styles.buttonText}>startPlay</Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={() => {
            getMonitor(activeChannel)?.current?.getStreamType();
          }}
          style={styles.button}
        >
          <Text style={styles.buttonText}>getStreamType</Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={() => {
            getMonitor(activeChannel)?.current?.switchStreamTypeMonitor();
          }}
          style={styles.button}
        >
          <Text style={styles.buttonText}>swtichStream</Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={() => {
            getMonitor(activeChannel)?.current?.updateStreamTypeMonitor(
              STREAM_TYPE.MAIN
            );
          }}
          style={styles.button}
        >
          <Text style={styles.buttonText}>stream type MAIN (hd)</Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={() => {
            getMonitor(activeChannel)?.current?.updateStreamTypeMonitor(
              STREAM_TYPE.EXTRA
            );
          }}
          style={styles.button}
        >
          <Text style={styles.buttonText}>stream type EXTRA (sd)</Text>
        </TouchableOpacity>
        {/* <Text style={styles.buttonText}>{PTZSpeed}</Text> */}
        <View style={{ flexDirection: 'row' }}>
          <TouchableOpacity
            onPress={() => setPTZSpeed((prev) => (prev + 1 > 8 ? 8 : prev + 1))}
            style={styles.button}
          >
            <Text style={styles.buttonText}>speed up</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => setPTZSpeed((prev) => (prev - 1 < 1 ? 1 : prev - 1))}
            style={styles.button}
          >
            <Text style={styles.buttonText}>speed down</Text>
          </TouchableOpacity>
        </View>
        <View style={{ flexDirection: 'row' }}>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.TILT_UP, false)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>up</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.TILT_UP, true)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>up stop</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.TILT_DOWN, false)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>down</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.TILT_DOWN, true)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>down stop</Text>
          </TouchableOpacity>
        </View>
        <View style={{ flexDirection: 'row' }}>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.PAN_LEFT, false)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>left start</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.PAN_LEFT, true)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>left stop</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.PAN_RIGHT, false)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>right start</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.PAN_RIGHT, true)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>right stop</Text>
          </TouchableOpacity>
        </View>
        <View style={{ flexDirection: 'row' }}>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.ZOOM_IN, false)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>zoomin</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.ZOOM_IN, true)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>zoomin stop</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.ZOOM_OUT, false)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>zoomout</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.ZOOM_OUT, true)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>zoomout stop</Text>
          </TouchableOpacity>
        </View>
        <View style={{ flexDirection: 'row' }}>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.FOCUS_FAR, true)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>focus far</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => devicePTZSend(EPTZCMD.FOCUS_NEAR, true)}
            style={styles.button}
          >
            <Text style={styles.buttonText}>focus near</Text>
          </TouchableOpacity>
        </View>
        {/* <TouchableOpacity onPress={loadChannelsCount} style={styles.button}>
          <Text style={styles.buttonText}>channel count</Text>
        </TouchableOpacity> */}
        <TouchableOpacity onPress={loadChannelsInfo} style={styles.button}>
          <Text style={styles.buttonText}>channel info</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={openVoice} style={styles.button}>
          <Text style={styles.buttonText}>open voice</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={closeVoice} style={styles.button}>
          <Text style={styles.buttonText}>closeVoice</Text>
        </TouchableOpacity>
        {/* <TouchableOpacity
          onPress={checkDeviceFunctionSupport}
          style={styles.button}
        >
          <Text style={styles.buttonText}>check support func</Text>
        </TouchableOpacity> */}
        {/* <TouchableOpacity onPress={loadDeviceModel} style={styles.button}>
          <Text style={styles.buttonText}>loadDeviceModel</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={loadSoftWareVersion} style={styles.button}>
          <Text style={styles.buttonText}>loadSoftWareVersion</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={loadDeviceInfo} style={styles.button}>
          <Text style={styles.buttonText}>loadDeviceInfo</Text>
        </TouchableOpacity> */}
        {/* <TouchableOpacity
          onPress={async () => {
            try {
              const result = await getHardWare({
                deviceId: DEVICE_ID,
              });
              console.log('getHardWare is: ', result);
            } catch (error) {
              console.log('getHardWare error: ', error);
            }
          }}
          style={styles.button}
        >
          <Text style={styles.buttonText}>hardware</Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={async () => {
            try {
              const result = await getUpdataTime({
                deviceId: DEVICE_ID,
              });
              console.log('getUpdataTime is: ', result);
            } catch (error) {
              console.log('getUpdataTime error: ', error);
            }
          }}
          style={styles.button}
        >
          <Text style={styles.buttonText}>getUpdataTime</Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={async () => {
            try {
              const result = await getNetworkMode({
                deviceId: DEVICE_ID,
              });
              console.log('getNetworkMode is: ', result);
            } catch (error) {
              console.log('getNetworkMode error: ', error);
            }
          }}
          style={styles.button}
        >
          <Text style={styles.buttonText}>getNetworkMode</Text>
        </TouchableOpacity> */}
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    paddingTop: 100,
    flex: 1,
    backgroundColor: 'pink',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
    padding: 20,
  },
  monitor: {
    width: '100%',
    aspectRatio: 16 / 9,
    backgroundColor: 'yellow',
  },
  button: {
    // width: 100,
    // height: 50,
    margin: 10,
    padding: 10,
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'green',
  },
  buttonText: {
    color: 'white',
  },
  view: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
  },
});
