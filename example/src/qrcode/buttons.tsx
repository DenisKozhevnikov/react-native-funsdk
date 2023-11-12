import React, { useEffect, useState } from 'react';
import {
  FlatList,
  Image,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import { styles } from '../styles';
import { askPermissionLocation } from '../utils/permisiion';
import {
  OnAddQRDeviceStatusType,
  QRCodeListenersEnum,
  qrCodeEventEmitter,
  startSetByQRCode,
  stopSetByQRCode,
} from 'react-native-funsdk';

const Button = ({ onPress, text }: { onPress: () => void; text: string }) => {
  return (
    <TouchableOpacity onPress={onPress} style={styles.button}>
      <Text style={styles.buttonText}>{text}</Text>
    </TouchableOpacity>
  );
};

export const Buttons = () => {
  const [ConnectStatus, setConnectStatus] = useState<any[]>([]);
  const [wifiPassword, setWifiPassword] = useState('');
  const [base64Image, setBase64Image] = useState('');

  const handleGetQRAndStartFindDevice = async () => {
    setConnectStatus([]);
    await askPermissionLocation();
    startSetByQRCode({
      passwordWifi: wifiPassword,
      isDevDeleteFromOthersUsers: false,
    });
  };

  const stopFindByQRDevice = async () => {
    await askPermissionLocation();
    const res = await stopSetByQRCode();
    console.log('res: ', res);
    setConnectStatus((prev) => {
      return [...prev, 'поиск остановлен'];
    });
  };

  useEffect(() => {
    // debug
    let eventListener = qrCodeEventEmitter.addListener(
      QRCodeListenersEnum.ON_SET_WIFI,
      (event) => {
        console.log('eventListener: ', event); // "someValue"
        setConnectStatus((prev) => {
          return [...prev, JSON.stringify(event)];
        });
      }
    );

    let eventDeviceListener = qrCodeEventEmitter.addListener(
      QRCodeListenersEnum.ON_ADD_DEVICE_STATUS,
      (event: OnAddQRDeviceStatusType) => {
        if (event.base64Image) {
          setBase64Image(event.base64Image);
        } else {
          console.log('eventDeviceListener: ', event); // "someValue"
          setConnectStatus((prev) => {
            return [...prev, JSON.stringify(event)];
          });
        }
      }
    );

    // Removes the listener once unmounted
    return () => {
      eventListener.remove();
      eventDeviceListener.remove();
    };
  }, []);

  return (
    <>
      <View style={styles.view}>
        <Button
          text="handleGetQRAndStartFindDevice"
          onPress={() => handleGetQRAndStartFindDevice()}
        />
        <Button text="stopFindDevice" onPress={() => stopFindByQRDevice()} />
      </View>
      <Text>Введённый пароль: {wifiPassword}</Text>
      <TextInput
        onChangeText={(text) => setWifiPassword(text)}
        style={{
          borderColor: 'black',
          borderWidth: 2,
        }}
      />
      {/* base64img */}
      {base64Image && (
        <Image
          source={{
            uri: `data:image/jpg;base64,${base64Image}`,
          }}
          resizeMode="cover"
          style={{ width: 200, height: 200 }}
        />
      )}
      <FlatList
        data={ConnectStatus}
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
