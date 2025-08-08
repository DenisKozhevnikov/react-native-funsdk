import React from 'react';
import { ScrollView } from 'react-native';
import { Buttons } from './buttons';
import { DeviceSearch } from './device-search';
import { styles } from '../styles';

export const WIFIDevice = () => {
  return (
    <ScrollView style={styles.container}>
      <Buttons />
    </ScrollView>
  );
};

// Новый компонент для экспорта
export const WIFIDeviceSearch = () => {
  return <DeviceSearch />;
};
