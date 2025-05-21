import React, { useEffect, useState } from 'react';
import {
  FlatList,
  Platform,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import {
  WiFiListenersEnum,
  addDevice,
  // deleteDevice,
  startSetWiFi,
  stopSetWiFi,
  wifiEventEmitter,
} from 'react-native-funsdk';
import { styles } from '../styles';
import { askPermissionLocation } from '../utils/permisiion';
import { WIFI_PASSWORD, WIFI_SSID } from '../topsecret';

const Button = ({ onPress, text }: { onPress: () => void; text: string }) => {
  return (
    <TouchableOpacity onPress={onPress} style={styles.button}>
      <Text style={styles.buttonText}>{text}</Text>
    </TouchableOpacity>
  );
};

export const Buttons = () => {
  const [wifiConnectStatus, setWifiConnectStatus] = useState<any[]>([]);
  const [wifiPassword, setWifiPassword] = useState(WIFI_PASSWORD);
  const [wifiSSID, setWifiSSID] = useState(WIFI_SSID);

  const startFindDevice = async () => {
    setWifiConnectStatus([]);
    if (Platform.OS === 'android') {
      await askPermissionLocation();
    }
    startSetWiFi({
      ssidWifi: wifiSSID,
      passwordWifi: wifiPassword,
      isDevDeleteFromOthersUsers: false,
    });
  };

  const stopFindDevice = async () => {
    if (Platform.OS === 'android') {
      await askPermissionLocation();
    }
    const res = await stopSetWiFi();
    console.log('res: ', res);
    setWifiConnectStatus((prev) => {
      return [...prev, 'поиск остановлен'];
    });
  };

  useEffect(() => {
    let eventListener = wifiEventEmitter.addListener(
      WiFiListenersEnum.ON_SET_WIFI,
      (event) => {
        console.log('eventListener: ', event);
        setWifiConnectStatus((prev) => {
          return [...prev, JSON.stringify(event)];
        });
      }
    );
    let eventDeviceListener = wifiEventEmitter.addListener(
      WiFiListenersEnum.ON_ADD_DEVICE_STATUS,
      (event) => {
        console.log('eventDeviceListener: ', event);
        if (event.status === 'readyToAdd' && event?.deviceData) {
          const { deviceData } = event;
          addDevice({
            deviceId: deviceData?.devId || '',
            username: deviceData?.devUserName || '',
            password: deviceData?.devPassword || '',
            // deviceType: 'no need',
            deviceName: deviceData?.devId || '',
          })
            .then((res) => {
              console.log('🚀 ~ :82 ~ useEffect ~ res:', res);
              setWifiConnectStatus((prev) => {
                return [...prev, { status: 'success', xmDevInfo: deviceData }];
              });
            })
            .catch((err) => {
              console.log('🚀 ~ :89 ~ useEffect ~ err:', err);
              setWifiConnectStatus((prev) => {
                return [...prev, { status: 'error', xmDevInfo: deviceData }];
              });
            });
        }
        setWifiConnectStatus((prev) => {
          return [...prev, JSON.stringify(event)];
        });
      }
    );

    return () => {
      eventListener.remove();
      eventDeviceListener.remove();
    };
  }, []);

  return (
    <>
      <View style={styles.view}>
        <Button text="findDevice" onPress={() => startFindDevice()} />
        <Button text="stopFindDevice" onPress={() => stopFindDevice()} />
        {/* <Button
          text="deleteDev"
          onPress={async () => {
            const res = await deleteDevice({ deviceId: '' });
            console.log('deleted: ', res);
          }}
        /> */}
      </View>
      <Text>Введённый пароль: {wifiPassword}</Text>
      <TextInput
        onChangeText={(text) => setWifiPassword(text)}
        style={{
          borderColor: 'black',
          borderWidth: 2,
        }}
      />
      <Text>Введённый ssid: {wifiSSID}</Text>
      <TextInput
        onChangeText={(text) => setWifiSSID(text)}
        style={{
          borderColor: 'black',
          borderWidth: 2,
        }}
      />
      <FlatList
        data={wifiConnectStatus}
        renderItem={({ item, index }) => {
          return (
            <Text>
              {index} {JSON.stringify(item, null, 2)}
            </Text>
          );
        }}
      />
    </>
  );
};
