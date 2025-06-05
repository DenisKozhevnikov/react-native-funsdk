import { searchDevice } from 'react-native-funsdk';
import { styles } from '../styles';
import React from 'react';
import { TouchableOpacity, Text, View, ScrollView } from 'react-native';

const Button = ({ onPress, text }: { onPress: () => void; text: string }) => {
  return (
    <TouchableOpacity onPress={onPress} style={styles.button}>
      <Text style={styles.buttonText}>{text}</Text>
    </TouchableOpacity>
  );
};

export const SearchLanDevices = () => {
  const startSearchingDevice = async () => {
    try {
      const res = await searchDevice();
      console.log('🚀 ~ :18 ~ startSearchingDevice ~ res:', res);
    } catch (error) {
      console.log('🚀 ~ :23 ~ startSearchingDevice ~ error:', error);
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.view}>
        <Button text="findDevice" onPress={startSearchingDevice} />
      </View>
    </ScrollView>
  );
};
