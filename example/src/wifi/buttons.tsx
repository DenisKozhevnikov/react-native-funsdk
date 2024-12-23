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
  // deleteDevice,
  startSetWiFi,
  stopSetWiFi,
  wifiEventEmitter,
} from 'react-native-funsdk';
import { styles } from '../styles';
import { askPermissionLocation } from '../utils/permisiion';

const Button = ({ onPress, text }: { onPress: () => void; text: string }) => {
  return (
    <TouchableOpacity onPress={onPress} style={styles.button}>
      <Text style={styles.buttonText}>{text}</Text>
    </TouchableOpacity>
  );
};

export const Buttons = () => {
  const [wifiConnectStatus, setWifiConnectStatus] = useState<any[]>([]);
  const [wifiPassword, setWifiPassword] = useState('');
  const [wifiSSID, setWifiSSID] = useState('');

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
              {index} {item}
            </Text>
          );
        }}
      />
    </>
  );
};
