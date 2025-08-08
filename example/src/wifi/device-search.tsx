import React, { useEffect, useState } from 'react';
import {
  FlatList,
  Platform,
  Text,
  TextInput,
  TouchableOpacity,
  View,
  Alert,
  ScrollView,
} from 'react-native';
import {
  WiFiListenersEnum,
  startQuickDeviceSearch,
  addFoundDevice,
  stopSetWiFi,
  wifiEventEmitter,
  QuickSearchDeviceParams,
  FoundDeviceData,
  AddFoundDeviceParams,
} from 'react-native-funsdk';
import { styles } from '../styles';
import { askPermissionLocation } from '../utils/permisiion';
import { WIFI_PASSWORD, WIFI_SSID } from '../topsecret';

const Button = ({
  onPress,
  text,
  disabled = false,
}: {
  onPress: () => void;
  text: string;
  disabled?: boolean;
}) => {
  return (
    <TouchableOpacity
      onPress={onPress}
      style={[styles.button, disabled && styles.buttonDisabled]}
      disabled={disabled}
    >
      <Text style={styles.buttonText}>{text}</Text>
    </TouchableOpacity>
  );
};

export const DeviceSearch = () => {
  const [wifiConnectStatus, setWifiConnectStatus] = useState<any[]>([]);
  const [wifiPassword, setWifiPassword] = useState(WIFI_PASSWORD);
  const [wifiSSID, setWifiSSID] = useState(WIFI_SSID);
  const [isSearching, setIsSearching] = useState(false);
  const [isAdding, setIsAdding] = useState(false);
  const [foundDevice, setFoundDevice] = useState<FoundDeviceData | null>(null);

  const startFindDevice = async () => {
    setWifiConnectStatus([]);
    setFoundDevice(null);
    setIsSearching(true);

    if (Platform.OS === 'android') {
      await askPermissionLocation();
    }

    try {
      const searchParams: QuickSearchDeviceParams = {
        ssidWifi: wifiSSID,
        passwordWifi: wifiPassword,
      };

      console.log('🔍 Начинаем поиск устройства с параметрами:', searchParams);

      startQuickDeviceSearch(searchParams);
      // const deviceData = await startDeviceSearch(searchParams);

      // console.log('✅ Устройство найдено:', deviceData);
      // setFoundDevice(deviceData);

      // setWifiConnectStatus((prev) => {
      //   return [
      //     ...prev,
      //     `✅ Устройство найдено: ${deviceData.deviceName} (${deviceData.deviceMac})`,
      //   ];
      // });
    } catch (error: any) {
      console.error('❌ Ошибка поиска устройства:', error);

      // let errorMessage = 'Неизвестная ошибка';
      // if (error.code === 'timeout') {
      //   errorMessage = 'Превышен таймаут поиска (180 секунд)';
      // } else if (error.code === 'search_error') {
      //   errorMessage = `Ошибка поиска: ${error.message}`;
      // } else if (error.code === 'random_pwd_error') {
      //   errorMessage = 'Ошибка получения случайных учетных данных';
      // }

      // setWifiConnectStatus((prev) => {
      //   return [...prev, `❌ ${errorMessage}`];
      // });

      // Alert.alert('Ошибка поиска', errorMessage);
    } finally {
      // setIsSearching(false);
    }
  };

  const addFoundDeviceToSystem = async () => {
    if (!foundDevice) {
      Alert.alert('Ошибка', 'Сначала найдите устройство');
      return;
    }

    setIsAdding(true);

    try {
      const addParams: AddFoundDeviceParams = {
        deviceMac: foundDevice.devId,
        deviceName: foundDevice.devName,
        loginName: foundDevice.devUserName,
        loginPassword: foundDevice.devPassword,
        deviceType: foundDevice.devType,
      };
      // const addParams: AddFoundDeviceParams = {
      //   deviceMac: foundDevice.deviceMac,
      //   deviceName: foundDevice.deviceName,
      //   loginName: foundDevice.loginName,
      //   loginPassword: foundDevice.loginPassword,
      //   deviceType: foundDevice.deviceType,
      // };

      console.log('➕ Добавляем устройство с параметрами:', addParams);

      const result = await addFoundDevice(addParams);

      console.log('✅ Устройство добавлено:', result);

      setWifiConnectStatus((prev) => {
        return [
          ...prev,
          `✅ Устройство успешно добавлено: ${result.deviceName}`,
        ];
      });

      Alert.alert('Успех', 'Устройство успешно добавлено в систему');

      // Очищаем найденное устройство после успешного добавления
      setFoundDevice(null);
    } catch (error: any) {
      // Если -604101 то уже добавлено
      console.error('❌ Ошибка добавления устройства:', error);

      let errorMessage = 'Неизвестная ошибка';
      if (error.code === 'add_device_error') {
        errorMessage = error.message;
      } else if (error.code === 'random_user_error') {
        errorMessage = `Ошибка изменения случайных учетных данных: ${error.message}`;
      }

      setWifiConnectStatus((prev) => {
        return [...prev, `❌ ${errorMessage}`];
      });

      Alert.alert('Ошибка добавления', errorMessage);
    } finally {
      setIsAdding(false);
    }
  };

  const stopFindDevice = async () => {
    if (Platform.OS === 'android') {
      await askPermissionLocation();
    }

    try {
      const res = await stopSetWiFi();
      console.log('🛑 Поиск остановлен:', res);
      setWifiConnectStatus((prev) => {
        return [...prev, '🛑 Поиск остановлен'];
      });
    } catch (error) {
      console.error('❌ Ошибка остановки поиска:', error);
    } finally {
      setIsSearching(false);
    }
  };

  const clearLogs = () => {
    setWifiConnectStatus([]);
    setFoundDevice(null);
  };

  useEffect(() => {
    let eventListener = wifiEventEmitter.addListener(
      WiFiListenersEnum.ON_SET_WIFI,
      (event) => {
        console.log('📡 WiFi Event:', event);
        setWifiConnectStatus((prev) => {
          return [...prev, `📡 WiFi: ${JSON.stringify(event)}`];
        });
      }
    );

    let eventDeviceListener = wifiEventEmitter.addListener(
      WiFiListenersEnum.ON_ADD_DEVICE_STATUS,
      (event) => {
        console.log('📡 Device Status Event:', event);

        if (event.status === 'readyToAdd' && event?.deviceData) {
          const { deviceData } = event;
          console.log('📡 Готово к добавлению:', deviceData);

          setWifiConnectStatus((prev) => {
            return [
              ...prev,
              `✅ Устройство найдено: ${deviceData?.deviceName} (${deviceData?.deviceMac})`,
            ];
          });
          setWifiConnectStatus((prev) => {
            return [
              ...prev,
              `📡 Готово к добавлению: ${JSON.stringify(deviceData, null, 2)}`,
            ];
          });

          setIsSearching(false);
          setFoundDevice(deviceData);
          stopFindDevice();
        } else if (event.status === 'error') {
          setWifiConnectStatus((prev) => {
            return [...prev, `❌ Ошибка поиска: ${JSON.stringify(event)}`];
          });
          stopFindDevice();
        } else if (event.status === 'connected') {
          setWifiConnectStatus((prev) => {
            return [...prev, `✅ Устройство найдено:`];
          });
        } else if (event.status === 'start') {
          setWifiConnectStatus((prev) => {
            return [...prev, `🔍 Поиск начат:`];
          });
        } else {
          setWifiConnectStatus((prev) => {
            return [...prev, `📡 Device Status: ${JSON.stringify(event)}`];
          });
        }
      }
    );

    return () => {
      eventListener.remove();
      eventDeviceListener.remove();
    };
  }, []);

  const renderLogItem = ({ item, index }: { item: string; index: number }) => (
    <View style={styles.logItem}>
      <Text style={styles.logText}>{`${index + 1}. ${item}`}</Text>
    </View>
  );

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={true}>
      <Text style={styles.title}>Поиск и добавление устройств</Text>

      {/* Поля ввода WiFi */}
      <View style={styles.inputContainer}>
        <Text style={styles.label}>WiFi SSID:</Text>
        <TextInput
          style={styles.input}
          value={wifiSSID}
          onChangeText={setWifiSSID}
          placeholder="Введите SSID WiFi сети"
        />
      </View>

      <View style={styles.inputContainer}>
        <Text style={styles.label}>WiFi Пароль:</Text>
        <TextInput
          style={styles.input}
          value={wifiPassword}
          onChangeText={setWifiPassword}
          placeholder="Введите пароль WiFi"
          secureTextEntry
        />
      </View>

      {/* Кнопки управления */}
      <View style={styles.buttonContainer}>
        <Button
          onPress={startFindDevice}
          text={isSearching ? '🔍 Поиск...' : '🔍 Найти устройство'}
          disabled={isSearching}
        />

        <Button
          onPress={stopFindDevice}
          text="🛑 Остановить поиск"
          disabled={!isSearching}
        />

        <Button
          onPress={addFoundDeviceToSystem}
          text={isAdding ? '➕ Добавление...' : '➕ Добавить устройство'}
          disabled={!foundDevice || isAdding}
        />

        <Button onPress={clearLogs} text="🗑️ Очистить логи" />
      </View>

      {/* Информация о найденном устройстве */}
      {foundDevice && (
        <View style={styles.deviceInfo}>
          <Text style={styles.deviceInfoTitle}>📱 Найденное устройство:</Text>
          <Text style={styles.deviceInfoText}>Имя: {foundDevice.devName}</Text>
          <Text style={styles.deviceInfoText}>MAC: {foundDevice.devId}</Text>
          <Text style={styles.deviceInfoText}>Тип: {foundDevice.devType}</Text>
          <Text style={styles.deviceInfoText}>
            Логин: {foundDevice.devUserName}
          </Text>
          <Text style={styles.deviceInfoText}>
            Случайный пароль: {foundDevice.withRandomPassword ? 'Да' : 'Нет'}
          </Text>
          {foundDevice.randomUserData && (
            <Text style={styles.deviceInfoText}>
              Случайные данные: {JSON.stringify(foundDevice.randomUserData)}
            </Text>
          )}
        </View>
      )}

      {/* Логи */}
      <View style={styles.logsContainer}>
        <Text style={styles.logsTitle}>📋 Логи событий:</Text>
        <FlatList
          data={wifiConnectStatus}
          renderItem={renderLogItem}
          keyExtractor={(_, index) => index.toString()}
          style={styles.logsList}
          showsVerticalScrollIndicator={true}
          scrollEnabled={true}
          nestedScrollEnabled={true}
        />
      </View>
    </ScrollView>
  );
};
