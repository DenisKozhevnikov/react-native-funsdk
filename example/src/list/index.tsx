import React from 'react';
import { useEffect, useState } from 'react';
import { Button, ScrollView, Text, TouchableOpacity, View } from 'react-native';
import {
  DetailDeviceType,
  getDetailDeviceList,
  deleteDevice,
  getDigChannel,
  getChannelInfo,
  isDeviceFunctionSupport,
} from 'react-native-funsdk';
import Base64 from './utils';

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
        setStatus(`${func.name}: success ` + JSON.stringify(res));
      } else {
        setStatus(`${func.name}: success ` + res);
      }
    } catch (error) {
      console.log(`error deleteDevice: `, error);
      setStatus(`${func.name}: error`);
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
