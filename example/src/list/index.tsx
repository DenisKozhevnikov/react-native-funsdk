import React from 'react';
import { useEffect, useState } from 'react';
import {
  Button,
  DeviceEventEmitter,
  ScrollView,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import {
  DetailDeviceType,
  getDetailDeviceList,
  deleteDevice,
  getDigChannel,
  getChannelInfo,
  isDeviceFunctionSupport,
  // getDevCmdGeneral,
  getDevConfig,
  setDevConfig,
} from 'react-native-funsdk';
import Base64 from './utils';
// import { DEVICE_ID } from '../topsecret';

const TchblButton = ({
  text,
  onPress,
}: {
  text: string;
  onPress: () => void;
}) => {
  return (
    <TouchableOpacity
      style={{
        marginVertical: 4,
        backgroundColor: '#c1bc78',
      }}
      onPress={onPress}
    >
      <Text>{text}</Text>
    </TouchableOpacity>
  );
};

type PromiseType<T extends Promise<any>> = T extends Promise<infer U>
  ? U
  : never;

type StdFunc<T extends (...args: any[]) => Promise<any>> = T;

const DeviceCard = ({ device }: { device: DetailDeviceType }) => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [status, setStatus] = useState('');
  const [deviceNameJsonina, setDeviceNameJsonina] = useState<any>(null);

  const updateChannelName = async () => {
    console.log('deviceNameJsonina: ', deviceNameJsonina);
    if (deviceNameJsonina) {
      // -_-
      const params = [...deviceNameJsonina];

      params[0].ChannelTitle.Name = 'renamed';

      const stringified = JSON.stringify(params);

      try {
        const res = await setDevConfig({
          deviceId: device.devId,
          name: 'AVEnc.VideoWidget',
          param: stringified,
          channel: -1,
          timeout: 20000,
        });

        console.log('res setDevConfig: ', res);
      } catch (error) {
        console.log(`error setDevConfig: `, error);
      }
    }
  };

  const actionDevice = async <T extends (...args: any[]) => Promise<any>>(
    func: StdFunc<T>,
    args: Parameters<T>[0],
    resFunc?: (res: PromiseType<ReturnType<StdFunc<T>>>) => void
  ) => {
    setStatus(`${func.name}: in process`);
    try {
      const res = await func(args);

      resFunc && resFunc(res);

      if (typeof res === `object`) {
        setStatus(`${func.name}: success ` + JSON.stringify(res, null, 2));
        if (args?.name === 'AVEnc.VideoWidget') {
          console.log(
            'naconsolili!',
            res?.['AVEnc.VideoWidget'][0].ChannelTitle
          );
          // console.log(
          //   'naconsolili!',
          //   JSON.stringify(res['AVEnc.VideoWidget'], null, 2)
          // );
          setDeviceNameJsonina(res?.['AVEnc.VideoWidget']);
        }
      } else {
        setStatus(`${func.name}: success ` + res);
      }
    } catch (error) {
      console.log(`error ${func.name}: `, error);
      setStatus(`${func.name}: error ${(error as Error)?.message || ''}`);
    }
  };

  return (
    <View
      style={{
        marginVertical: 8,
        padding: 4,
        backgroundColor: '#777d82',
      }}
    >
      <TouchableOpacity
        activeOpacity={0.8}
        style={{}}
        onPress={() => setIsMenuOpen((prev) => !prev)}
      >
        {Object.entries(device).map(([key, value]) => (
          <Text key={key}>
            {key}: {value}
          </Text>
        ))}
      </TouchableOpacity>

      {isMenuOpen && (
        <View
          style={{
            marginTop: 8,
            backgroundColor: '#5b666f',
          }}
        >
          <TchblButton
            text="Delete Device"
            onPress={() =>
              actionDevice(deleteDevice, { deviceId: device.devId })
            }
          />

          <TchblButton
            text="getDigChannel"
            onPress={() =>
              actionDevice(getDigChannel, { deviceId: device.devId })
            }
          />

          <TchblButton
            text="getChannelInfo"
            onPress={() =>
              actionDevice(
                getChannelInfo,
                { deviceId: device.devId },
                // Для получения имени каналов необходимо преобразовать их из base64
                (res) => {
                  if (res.value.st_channelTitle) {
                    const superRes = res.value.st_channelTitle.map((title) =>
                      Base64.atob(title)
                    );
                    console.log('channel titles: ', superRes);
                  }
                }
              )
            }
          />
          <TchblButton
            text="isDeviceFunctionSupport"
            onPress={() =>
              actionDevice(isDeviceFunctionSupport, {
                deviceId: device.devId,
                functionName: 'OtherFunction',
                functionCommandStr: 'SDsupportRecord',
              })
            }
          />
          {/* <TchblButton
            text="getDeviceTime"
            onPress={() =>
              actionDevice(getTime, {
                deviceId: device.devId,
                timeout: 3000,
              })
            }
          /> */}

          {/* <TchblButton
            text="getDeviceTime"
            onPress={() =>
              actionDevice(getDevCmdGeneral, {
                deviceId: device.devId,
                cmdReq: 1452,
                cmd: 'OPTimeQuery',
                isBinary: 0,
                timeout: 5000,
                param: null,
                inParamLen: 0,
                cmdRes: -1,
              })
            }
          />
          <TchblButton
            text="getAlarmDetectState"
            onPress={() =>
              actionDevice(getDevCmdGeneral, {
                deviceId: device.devId,
                cmdReq: 1042,
                cmd: 'NetWork.PMS',
                isBinary: 0,
                timeout: 5000,
                param: null,
                inParamLen: 0,
                cmdRes: -1,
              })
            }
          />

          <TchblButton
            text="getWifiApState"
            onPress={() =>
              actionDevice(getDevCmdGeneral, {
                deviceId: device.devId,
                cmdReq: 1020,
                cmd: 'WifiAP',
                isBinary: 0,
                timeout: 5000,
                param: null,
                inParamLen: 0,
                cmdRes: -1,
              })
            }
          />

          <TchblButton
            text="GetCloudCryNum"
            onPress={() =>
              actionDevice(getDevCmdGeneral, {
                deviceId: device.devId,
                cmdReq: 1020,
                cmd: 'GetCloudCryNum',
                isBinary: 0,
                timeout: 5000,
                param: null,
                inParamLen: 0,
                cmdRes: -1,
              })
            }
          />

          <TchblButton
            text="getMonthVideoDate"
            onPress={() =>
              actionDevice(getDevCmdGeneral, {
                deviceId: device.devId,
                cmdReq: 1446,
                cmd: 'OPSCalendar',
                isBinary: 0,
                timeout: 5000,
                param: JSON.stringify({
                  Name: 'OPSCalendar',
                  OPSCalendar: {
                    Event: '*',
                    FileType: 'h264',
                    Month: 12,
                    Rev: '',
                    Year: 2024,
                  },
                  SessionID: '0x00000001',
                }),
                inParamLen: JSON.stringify({
                  Name: 'OPSCalendar',
                  OPSCalendar: {
                    Event: '*',
                    FileType: 'h264',
                    Month: 12,
                    Rev: '',
                    Year: 2024,
                  },
                  SessionID: '0x00000001',
                }).length,
                cmdRes: -1,
              })
            }
          />

          <TchblButton
            text="getSensorList"
            onPress={() =>
              actionDevice(getDevCmdGeneral, {
                deviceId: device.devId,
                cmdReq: 2046,
                cmd: 'GetAllDevList',
                isBinary: 0,
                timeout: 10000,
                param: JSON.stringify({
                  Name: 'OPConsumerProCmd',
                  OPConsumerProCmd: {
                    Cmd: 'GetAllDevList',
                    Arg1: '',
                    Arg2: '',
                  },
                  SessionID: '0x00000002',
                }),
                inParamLen: 0,
                cmdRes: -1,
              })
            }
          />

          <TchblButton
            text="getShutDownTime"
            onPress={() =>
              actionDevice(getDevCmdGeneral, {
                deviceId: device.devId,
                cmdReq: 1042,
                cmd: 'System.ManageShutDown',
                isBinary: 0,
                timeout: 5000,
                param: null,
                inParamLen: 0,
                cmdRes: -1,
              })
            }
          />

          <TchblButton
            text="HumanRuleLimit"
            onPress={() =>
              actionDevice(getDevCmdGeneral, {
                deviceId: device.devId,
                cmdReq: 1360,
                cmd: 'HumanRuleLimit',
                isBinary: 4096,
                timeout: 5000,
                param: null,
                inParamLen: 0,
                cmdRes: -1,
              })
            }
          />

          <TchblButton
            text="WifiRouteInfo"
            onPress={() =>
              actionDevice(getDevCmdGeneral, {
                deviceId: device.devId,
                cmdReq: 1020,
                cmd: 'WifiRouteInfo',
                isBinary: 0,
                timeout: 5000,
                param: null,
                inParamLen: 0,
                cmdRes: -1,
              })
            }
          />

          <TchblButton
            text="JK_SystemFunction"
            onPress={() =>
              actionDevice(getDevCmdGeneral, {
                deviceId: device.devId,
                cmdReq: 0,
                cmd: 'SystemFunction',
                isBinary: 0,
                timeout: 5000,
                param: null,
                inParamLen: 0,
                cmdRes: -1,
              })
            }
          /> */}

          <TchblButton
            text="Dev.ElectCapacity"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Dev.ElectCapacity',
                nOutBufLen: 0,
                channel: -1,
                timeout: 10000,
              })
            }
          />

          <TchblButton
            text="SystemInfo"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'SystemInfo',
                nOutBufLen: 0,
                channel: 1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="SystemFunction"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'SystemFunction',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="OPDefaultConfig"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'OPDefaultConfig',
                nOutBufLen: 0,
                channel: 1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="General.General"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'General.General',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="Uart.PTZTour"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Uart.PTZTour',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="Tour"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Tour',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="Audio"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Audio',
                nOutBufLen: 0,
                channel: 0,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="Video"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Video',
                nOutBufLen: 0,
                channel: 1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="MainFormat"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'MainFormat',
                nOutBufLen: 0,
                channel: 1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="NetWork.Wifi"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'NetWork.Wifi',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="NetWork.NetDHCP"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'NetWork.NetDHCP',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          {/* <TchblButton
            text="OPSCalendar"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'OPSCalendar',
                nOutBufLen: 0,
                channel: 1,
                timeout: 5000,
              })
            }
          /> */}
          <TchblButton
            text="Camera.Param"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Camera.Param',
                nOutBufLen: 0,
                channel: 0,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="ExposureParam"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'ExposureParam',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          {/* <TchblButton
            text="GainParam"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'GainParam',
                nOutBufLen: 0,
                channel: 1,
                timeout: 5000,
              })
            }
          /> */}
          <TchblButton
            text="Detect.MotionDetect"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Detect.MotionDetect',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="Detect.HumanDetection"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Detect.HumanDetection',
                nOutBufLen: 0,
                channel: -1,
                timeout: 10000,
              })
            }
          />
          <TchblButton
            text="Detect.HumanDetectionDVR"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Detect.HumanDetectionDVR',
                nOutBufLen: 0,
                channel: -1,
                timeout: 10000,
              })
            }
          />
          <TchblButton
            text="Detect.DetectTrack"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Detect.DetectTrack',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="Detect.LossDetect"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Detect.LossDetect',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="Detect.BlindDetect"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Detect.BlindDetect',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="fVideo.Volume"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'fVideo.Volume',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="fVideo.InVolume"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'fVideo.InVolume',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="fVideo.OsdLogo"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'fVideo.OsdLogo',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="ChannelTitle"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'ChannelTitle',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          {/* можно указывать каналы, -1 === все каналы */}
          <TchblButton
            text="AVEnc.VideoWidget"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'AVEnc.VideoWidget',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="NetWork.SetEnableVideo"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'NetWork.SetEnableVideo',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="StorageInfo"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'StorageInfo',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="StorageGlobal"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'StorageGlobal',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="OPStorageManager"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'OPStorageManager',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="NetWork"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'NetWork',
                nOutBufLen: 0,
                channel: -1,
                timeout: 30000,
              })
            }
          />
          <TchblButton
            text="Detect"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Detect',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="AVEnc"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'AVEnc',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="fVideo"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'fVideo',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="Camera"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Camera',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="General"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'General',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="Dev"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Dev',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="Alarm"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Alarm',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="Uart"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Uart',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />

          <TchblButton
            text="Custom"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Custom',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="Consumer"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Consumer',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="Ability"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'Ability',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton
            text="AVEnc.VideoWidget"
            onPress={() =>
              actionDevice(getDevConfig, {
                deviceId: device.devId,
                name: 'AVEnc.VideoWidget',
                nOutBufLen: 0,
                channel: -1,
                timeout: 5000,
              })
            }
          />
          <TchblButton text="updateChannelName" onPress={updateChannelName} />

          <Text style={{ color: '#FFF' }}>{status}</Text>
        </View>
      )}
    </View>
  );
};

export const DeviceList = () => {
  const [detailedDeviceList, setDetailedDeviceList] = useState<
    DetailDeviceType[] | null
  >(null);

  const loadDevList = async () => {
    try {
      const res = await getDetailDeviceList();
      setDetailedDeviceList(res);
    } catch (error) {
      console.log('error on load getDetailDeviceList: ', error);
    }
  };

  useEffect(() => {
    loadDevList();
    // Android: Обновляем список при событии удаления устройства из native
    const sub = DeviceEventEmitter.addListener('ON_DEVICE_DELETED', (evt) => {
      console.log('ON_DEVICE_DELETED event:', evt);
      loadDevList();
    });
    return () => {
      sub.remove();
    };
  }, []);

  return (
    <ScrollView
      contentContainerStyle={{
        paddingTop: 130,
        paddingHorizontal: 8,
      }}
    >
      <Button onPress={loadDevList} title="reload device list" />
      {detailedDeviceList?.map((device) => (
        <DeviceCard key={device.devId} device={device} />
      ))}
    </ScrollView>
  );
};
