import React, { useState } from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import {
  EFUN_ATTR,
  devGetLocalEncToken,
  devGetLocalUserName,
  getDevType,
  getFunStrAttr,
  userQuery,
} from 'react-native-funsdk';
import { DEVICE_ID } from '../topsecret';

export const Share = () => {
  const [queryRes, setQueryRes] = useState('press findUser to see the result');

  const findUser = async () => {
    try {
      const decoded = await userQuery('asd');

      setQueryRes(decoded);
    } catch (error) {
      console.log('error: ', error);
    }
  };

  // Получение id пользователя
  const getInfo = async () => {
    try {
      const res = await getFunStrAttr({
        FunStrAttr: EFUN_ATTR.LOGIN_USER_ID,
      });
      console.log('res: ', res);
      setQueryRes(res);
    } catch (error) {
      console.log('error: ', error);
    }
  };

  // Имя логина для входа на устройство
  const qDevGetLocalUserName = async () => {
    try {
      const res = await devGetLocalUserName({
        deviceId: DEVICE_ID,
      });
      console.log('res: ', res);
      setQueryRes(res);
    } catch (error) {
      console.log('error: ', error);
    }
  };

  // Тип устройства
  const loadDevType = async () => {
    try {
      const res = await getDevType({
        deviceId: DEVICE_ID,
      });
      console.log('res: ', res);
      setQueryRes(String(res));
    } catch (error) {
      console.log('error: ', error);
    }
  };

  // Токен для входа в устройство
  const loadDevGetLocalEncToken = async () => {
    try {
      const res = await devGetLocalEncToken({
        deviceId: DEVICE_ID,
      });
      console.log('res: ', res);
      setQueryRes(String(res));
    } catch (error) {
      console.log('error: ', error);
    }
  };

  return (
    <View style={styles.container}>
      <Text>share screen</Text>
      <TouchableOpacity style={styles.button} onPress={findUser}>
        <Text style={styles.buttonText}>findUser</Text>
      </TouchableOpacity>

      <TouchableOpacity style={styles.button} onPress={getInfo}>
        <Text style={styles.buttonText}>getInfo</Text>
      </TouchableOpacity>

      <TouchableOpacity style={styles.button} onPress={qDevGetLocalUserName}>
        <Text style={styles.buttonText}>devGetLocalUserName</Text>
      </TouchableOpacity>

      <TouchableOpacity style={styles.button} onPress={loadDevType}>
        <Text style={styles.buttonText}>loadDevType</Text>
      </TouchableOpacity>

      <TouchableOpacity style={styles.button} onPress={loadDevGetLocalEncToken}>
        <Text style={styles.buttonText}>loadDevGetLocalEncToken</Text>
      </TouchableOpacity>
      <Text>{queryRes}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'pink',
    paddingTop: 100,
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
    padding: 20,
  },
  monitor: {
    width: '100%',
    aspectRatio: 16 / 9,
    backgroundColor: 'yellow',
  },
  button: {
    // width: 100,
    // height: 50,
    margin: 10,
    padding: 10,
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'green',
  },
  buttonText: {
    color: 'white',
  },
  view: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
  },
});
