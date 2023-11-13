import React from 'react';
import { Text, TouchableOpacity, View } from 'react-native';
import { styles } from '../styles';
import { InitGoogleFunSDKPush } from 'react-native-funsdk';

const Button = ({ onPress, text }: { onPress: () => void; text: string }) => {
  return (
    <TouchableOpacity onPress={onPress} style={styles.button}>
      <Text style={styles.buttonText}>{text}</Text>
    </TouchableOpacity>
  );
};

export const Buttons = () => {
  const HandleInitLinkPUsh = () => {
    InitGoogleFunSDKPush({
      token: '',
      deviceId: '',
      type: 2,
    });
  };

  const HandleInitLinkPUshV2 = () => {
    InitGoogleFunSDKPush({
      token: '',
      deviceId: '',
      type: 11,
    });
  };

  return (
    <>
      <View style={styles.view}>
        <Button
          text="HandleInitLinkPUsh"
          onPress={() => HandleInitLinkPUsh()}
        />
        <Button
          text="HandleInitLinkPUshV2"
          onPress={() => HandleInitLinkPUshV2()}
        />
      </View>
      {/* <Text>Введённый пароль: {wifiPassword}</Text>
      <TextInput
        onChangeText={(text) => setWifiPassword(text)}
        style={{
          borderColor: 'black',
          borderWidth: 2,
        }}
      /> */}
    </>
  );
};
