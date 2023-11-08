import { Permission, PermissionsAndroid } from 'react-native';

export const askPermissionStorage = async () => {
  try {
    const granted = await PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.WRITE_EXTERNAL_STORAGE as Permission,
      {
        title: 'Разрешение на сохранение файлов',
        message:
          'Приложению нужно разрешение для сохранения файлов в галерее устройства.',
        buttonPositive: 'ОК',
      }
    );

    if (granted === PermissionsAndroid.RESULTS.GRANTED) {
      return true;
    }

    return false;
  } catch (error) {
    console.log('Ошибка при сохранении файла:', error);
    return false;
  }
};

export const askPermissionReadStorage = async () => {
  try {
    const granted = await PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.READ_EXTERNAL_STORAGE as Permission,
      {
        title: 'Разрешение на чтение файлов',
        message:
          'Приложению нужно разрешение для чтение файлов в галерее устройства.',
        buttonPositive: 'ОК',
      }
    );

    if (granted === PermissionsAndroid.RESULTS.GRANTED) {
      return true;
    }

    return false;
  } catch (error) {
    console.log('Ошибка при чтении файла:', error);
    return false;
  }
};

export const askPermissionLocation = async () => {
  try {
    const granted = await PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION as Permission,
      {
        title: 'Location permission is required for WiFi connections',
        message:
          'This app needs location permission as this is required  ' +
          'to scan for wifi networks.',
        buttonNegative: 'DENY',
        buttonPositive: 'ALLOW',
      }
    );

    if (granted === PermissionsAndroid.RESULTS.GRANTED) {
      return true;
    }

    return false;
  } catch (error) {
    console.log('Ошибка при чтении файла:', error);
    return false;
  }
};
