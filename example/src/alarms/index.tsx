import React, { useState } from 'react';
import {
  FlatList,
  Image,
  Platform,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import {
  AlarmInfo,
  deleteAlarmInfo,
  deleteOneAlarmInfo,
  getAlarmState,
  searchAlarmMsg,
  searchAlarmMsgByTime,
  setAlarmState,
} from 'react-native-funsdk';
import { DEVICE_ID } from '../topsecret';
import { asyncFunc } from '../utils/asyncFunc';

const Button = ({ onPress, text }: { onPress: () => void; text: string }) => {
  return (
    <TouchableOpacity onPress={onPress} style={styles.button}>
      <Text style={styles.buttonText}>{text}</Text>
    </TouchableOpacity>
  );
};
export const Alarms = () => {
  const [alarmMsgs, setAlarmMsgs] = useState<AlarmInfo[]>([]);
  const [updatedTime, setUpdatedTime] = useState('');

  const handleSearch = async () => {
    // 1000 - 1 мс
    // 60 - 1 минута
    // 60 - 1 час
    // 24 - 1 сутки
    // 2 - 2 дня
    const date = Date.now() - 1000 * 60 * 60 * 24 * 3;
    // const date = Date.now() - 1000 * 60 * 60;

    try {
      let res;
      if (Platform.OS === 'android') {
        res = await searchAlarmMsg({
          deviceId: DEVICE_ID,
          deviceChannel: 0,
          alarmType: 0,
          searchTime: date,
          searchDays: 1,
          imgSizes: {
            imgHeight: 900,
            imgWidth: 1600,
          },
        });
      } else {
        res = await searchAlarmMsgByTime({
          deviceId: DEVICE_ID,
          deviceChannel: 0,
          alarmType: 0,
          startTime: date,
          endTime: Date.now(),
        });
      }
      console.log('handleSearch res: ', JSON.stringify(res, null, 2));

      setAlarmMsgs(res || []);
      setUpdatedTime(new Date().toString());
    } catch (error) {
      console.log('error: ', error);
    }
  };

  const handleDeleteAlarm = async (id: string) => {
    try {
      let res;
      if (Platform.OS === 'ios') {
        res = await deleteOneAlarmInfo({
          deviceId: DEVICE_ID,
          deleteType: 'MSG',
          alarmID: id,
        });
      } else {
        res = await deleteAlarmInfo({
          deviceId: DEVICE_ID,
          deleteType: 'MSG',
          alarmInfos: [
            {
              id,
            },
          ],
        });
      }
      console.log('handleDeleteAlarm res: ', res);
    } catch (error) {
      console.log('error: ', error);
    }
  };

  // const handleDeleteAllAlarms = async () => {
  //   try {
  //     const res = await deleteAllAlarmMsg({
  //       deviceId: DEVICE_ID,
  //       deleteType: 'MSG',
  //     });
  //     console.log('handleDeleteAllAlarms res: ', res);
  //   } catch (error) {
  //     console.log('error: ', error);
  //   }
  // };

  // const handleLinkAlarm = async () => {
  //   try {
  //     const res = await linkAlarm({
  //       deviceId: DEVICE_ID,
  //       deviceLogin: DEVICE_LOGIN,
  //       devicePassword: DEVICE_PASSWORD,
  //       // deviceName: `name_${DEVICE_ID}`,
  //     });

  //     console.log('handleLinkAlarm res: ', res);
  //   } catch (error) {
  //     console.log('handleLinkAlarm error: ', error);
  //   }
  // };

  // const handleUnlinkAlarm = async () => {
  //   try {
  //     const res = await unlinkAlarm({
  //       deviceId: DEVICE_ID,
  //     });

  //     console.log('handleUnlinkAlarm res: ', res);
  //   } catch (error) {
  //     console.log('handleLinkAlarm error: ', error);
  //   }
  // };

  // const handleInitAlarmServer = async () => {
  //   try {
  //     const res = await initAlarmServer({
  //       username: USER_NAME,
  //       password: USER_PASSWORD,
  //       token: 'randomuuidtokenkakoito',
  //     });

  //     console.log('handleUnlinkAlarm res: ', res);
  //   } catch (error) {
  //     console.log('handleLinkAlarm error: ', error);
  //   }
  // };

  // pObject: { "Name" : "NetWork.PMS", "NetWork.PMS" : { "BoxID" : "", "Enable" : false, "Port" : 80, "PushInterval" : 10, "ServName" : "push.umeye.cn" }, "Ret" : 100, "SessionID" : "0x00000001" }
  // {"ID":"2410705712","AlarmInfo":{"Channel":"0","Event":"VideoMotion","StartTime":"2024-10-01 00:57:12","Status":"Start","MsgStatus":"0","DevName":"12312312","Pic":"https://*.jpeg"},"picSize":"0"}
  return (
    <View style={styles.container}>
      <Text>всего alarm найдено: {alarmMsgs.length}</Text>
      <Text>время обновления: {updatedTime}</Text>
      {/* <Button
        text="Инициализация сервера Alarm"
        onPress={handleInitAlarmServer}
      /> */}
      {/* <Button text="Подписка на Alarm" onPress={handleLinkAlarm} />
      <Button text="Отписка от Alarm" onPress={handleUnlinkAlarm} />*/}
      <Button text="Поиск Alarm" onPress={handleSearch} />
      {/* <Button text="Удалить все Alarm" onPress={handleDeleteAllAlarms} /> */}
      <Button
        text="Проверить работает ли Alarm"
        onPress={() => asyncFunc({ deviceId: DEVICE_ID }, getAlarmState)}
      />
      <Button
        text="Включить Alarm на устройстве"
        onPress={() =>
          asyncFunc(
            { deviceId: DEVICE_ID, isAlertEnabled: true },
            setAlarmState
          )
        }
      />
      <Button
        text="Выключить Alarm на устройстве"
        onPress={() =>
          asyncFunc(
            { deviceId: DEVICE_ID, isAlertEnabled: false },
            setAlarmState
          )
        }
      />
      <FlatList
        data={alarmMsgs}
        renderItem={({ item }) => {
          return (
            <View
              style={{
                borderWidth: 2,
                borderColor: 'red',
                margin: 8,
                padding: 4,
              }}
            >
              <Button
                text="delete alarm"
                onPress={() => {
                  if (Platform.OS === 'ios') {
                    // console.log(typeof item.ID);
                    handleDeleteAlarm(item.ID);
                  } else {
                    handleDeleteAlarm(item.id);
                  }
                }}
              />
              {Object.entries(item).map(([key, value]) => {
                if (key === 'pic' && value !== null) {
                  return (
                    <Image
                      style={{
                        width: '100%',
                        aspectRatio: 16 / 9,
                        // height: 90,
                      }}
                      key={key}
                      //@ts-expect-error
                      source={{ uri: value }}
                    />
                  );
                }

                if (value !== null) {
                  return (
                    <Text key={key}>
                      {key}:{' '}
                      {typeof value === 'object'
                        ? JSON.stringify(value, null, 2)
                        : String(value)}
                    </Text>
                  );
                }

                return null;
              })}
            </View>
          );
        }}
      />
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
