import React, { useEffect, useState } from 'react';
import {
  FlatList,
  NativeEventEmitter,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import {
  WiFiListenersEnum,
  startSetWiFi,
  stopSetWiFi,
  wifiEventEmitter,
  wifiEventModule,
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

  const handleFindDevice = async () => {
    setWifiConnectStatus([]);
    await askPermissionLocation();
    startSetWiFi({ passwordWifi: wifiPassword });
  };

  const stopFindDevice = async () => {
    await askPermissionLocation();
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
        console.log('event: ', event); // "someValue"
        setWifiConnectStatus((prev) => {
          return [...prev, JSON.stringify(event)];
        });
      }
    );

    // Removes the listener once unmounted
    return () => {
      eventListener.remove();
    };
  }, []);

  return (
    <>
      <View style={styles.view}>
        <Button text="handleFindDevice" onPress={() => handleFindDevice()} />
        <Button text="stopFindDevice" onPress={() => stopFindDevice()} />
      </View>
      <Text>Введённый пароль: {wifiPassword}</Text>
      <TextInput
        onChangeText={(text) => setWifiPassword(text)}
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
