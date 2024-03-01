import React, { useState } from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { userQuery } from 'react-native-funsdk';

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

  return (
    <View style={styles.container}>
      <Text>share screen</Text>
      <TouchableOpacity style={styles.button} onPress={findUser}>
        <Text style={styles.buttonText}>findUser</Text>
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
