# Пример использования новых методов поиска и добавления устройств

## Новые методы

### 1. startDeviceSearch - Поиск устройств

```typescript
import { startDeviceSearch } from 'react-native-funsdk';

// Поиск устройств
const searchDevice = async () => {
  try {
    const deviceData = await startDeviceSearch({
      ssidWifi: 'MyWiFiNetwork',
      passwordWifi: 'MyWiFiPassword',
    });

    console.log('Найдено устройство:', deviceData);
    // deviceData содержит:
    // {
    //   deviceMac: "1234567890123456",
    //   deviceName: "Camera_001",
    //   deviceType: 24,
    //   loginName: "admin",
    //   loginPassword: "123456",
    //   withRandomPassword: true,
    //   randomUserData: {
    //     userName: "admin",
    //     password: "123456",
    //     random: true
    //   }
    // }
  } catch (error) {
    console.error('Ошибка поиска устройства:', error);
  }
};
```

### 2. addFoundDevice - Добавление найденного устройства

```typescript
import { addFoundDevice } from 'react-native-funsdk';

// Добавление устройства
const addDevice = async (deviceData: DEVICE.FoundDeviceData) => {
  try {
    const result = await addFoundDevice({
      deviceMac: deviceData.deviceMac,
      deviceName: deviceData.deviceName,
      loginName: deviceData.loginName,
      loginPassword: deviceData.loginPassword,
      deviceType: deviceData.deviceType,
    });

    console.log('Результат добавления:', result);
    // result содержит:
    // {
    //   success: true,
    //   deviceMac: "1234567890123456",
    //   deviceName: "Camera_001",
    //   message: "Устройство успешно добавлено"
    // }
  } catch (error) {
    console.error('Ошибка добавления устройства:', error);
  }
};
```

## Полный пример использования

```typescript
import React, { useState } from 'react';
import { View, Button, Text } from 'react-native';
import {
  startDeviceSearch,
  addFoundDevice,
  FoundDeviceData,
} from 'react-native-funsdk';

const DeviceSearchExample = () => {
  const [deviceData, setDeviceData] = useState<FoundDeviceData | null>(null);
  const [isSearching, setIsSearching] = useState(false);
  const [isAdding, setIsAdding] = useState(false);

  const handleSearch = async () => {
    setIsSearching(true);
    try {
      const foundDevice = await startDeviceSearch({
        ssidWifi: 'MyWiFiNetwork',
        passwordWifi: 'MyWiFiPassword',
      });

      setDeviceData(foundDevice);
      console.log('Устройство найдено:', foundDevice);
    } catch (error) {
      console.error('Ошибка поиска:', error);
    } finally {
      setIsSearching(false);
    }
  };

  const handleAddDevice = async () => {
    if (!deviceData) return;

    setIsAdding(true);
    try {
      const result = await addFoundDevice({
        deviceMac: deviceData.deviceMac,
        deviceName: deviceData.deviceName,
        loginName: deviceData.loginName,
        loginPassword: deviceData.loginPassword,
        deviceType: deviceData.deviceType,
      });

      console.log('Устройство добавлено:', result);
      setDeviceData(null); // Очищаем данные после успешного добавления
    } catch (error) {
      console.error('Ошибка добавления:', error);
    } finally {
      setIsAdding(false);
    }
  };

  return (
    <View>
      <Button
        title={isSearching ? 'Поиск...' : 'Найти устройство'}
        onPress={handleSearch}
        disabled={isSearching}
      />

      {deviceData && (
        <View>
          <Text>Найдено устройство: {deviceData.deviceName}</Text>
          <Text>MAC: {deviceData.deviceMac}</Text>
          <Text>Тип: {deviceData.deviceType}</Text>
          <Text>Логин: {deviceData.loginName}</Text>
          <Text>
            Случайный пароль: {deviceData.withRandomPassword ? 'Да' : 'Нет'}
          </Text>

          <Button
            title={isAdding ? 'Добавление...' : 'Добавить устройство'}
            onPress={handleAddDevice}
            disabled={isAdding}
          />
        </View>
      )}
    </View>
  );
};

export default DeviceSearchExample;
```

## Типы данных

### SearchDeviceParams

```typescript
interface SearchDeviceParams {
  ssidWifi: string; // Имя WiFi сети
  passwordWifi: string; // Пароль WiFi сети
}
```

### FoundDeviceData

```typescript
interface FoundDeviceData {
  deviceMac: string; // MAC адрес устройства
  deviceName: string; // Имя устройства
  deviceType: number; // Тип устройства
  loginName: string; // Имя пользователя для входа
  loginPassword: string; // Пароль для входа
  withRandomPassword: boolean; // Использует ли случайные учетные данные
  randomUserData?: {
    // Данные случайных учетных данных
    userName: string;
    password: string;
    random: boolean;
  };
}
```

### AddDeviceParams

```typescript
interface AddDeviceParams {
  deviceMac: string; // MAC адрес устройства (обязательно)
  deviceName?: string; // Имя устройства
  loginName?: string; // Имя пользователя
  loginPassword?: string; // Пароль
  deviceType?: number; // Тип устройства
}
```

### AddDeviceResult

```typescript
interface AddDeviceResult {
  success: boolean; // Успешность операции
  deviceMac: string; // MAC адрес устройства
  deviceName: string; // Имя устройства
  message: string; // Сообщение о результате
}
```

## Обработка ошибок

```typescript
try {
  const deviceData = await startDeviceSearch({
    ssidWifi: 'MyWiFi',
    passwordWifi: 'MyPassword',
  });
} catch (error) {
  if (error.code === 'timeout') {
    console.log('Превышен таймаут поиска');
  } else if (error.code === 'search_error') {
    console.log('Ошибка поиска устройства:', error.message);
  } else if (error.code === 'random_pwd_error') {
    console.log('Ошибка получения случайных учетных данных');
  }
}
```

## Примечания

1. **Таймаут поиска**: Поиск устройства автоматически прерывается через 180 секунд
2. **Случайные учетные данные**: Если устройство поддерживает случайные учетные данные, они будут автоматически получены и настроены
3. **Остановка поиска**: Можно остановить поиск в любой момент с помощью `stopSetWiFi()`
4. **События**: Методы также отправляют события через `wifiEventEmitter` для отслеживания прогресса
