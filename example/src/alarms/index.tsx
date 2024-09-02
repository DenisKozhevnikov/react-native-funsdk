// import React, { useState } from 'react';
// import {
//   StyleSheet,
//   Text,
//   TouchableOpacity,
//   FlatList,
//   View,
//   Image,
// } from 'react-native';
// import {
//   deleteAlarmInfo,
//   searchAlarmMsg,
//   AlarmInfo,
//   deleteAllAlarmMsg,
// } from 'react-native-funsdk';
// import { DEVICE_ID } from '../topsecret';

// const Button = ({ onPress, text }: { onPress: () => void; text: string }) => {
//   return (
//     <TouchableOpacity onPress={onPress} style={styles.button}>
//       <Text style={styles.buttonText}>{text}</Text>
//     </TouchableOpacity>
//   );
// };
// export const Alarms = () => {
//   const [alarmMsgs, setAlarmMsgs] = useState<AlarmInfo[]>([]);
//   const [updatedTime, setUpdatedTime] = useState('');

//   const handleSearch = async () => {
//     // 1000 - 1 мс
//     // 60 - 1 минута
//     // 60 - 1 час
//     // 24 - 1 сутки
//     // 2 - 2 дня
//     // const date = Date.now() - 1000 * 60 * 60 * 24 * 2;
//     const date = Date.now() - 1000 * 60 * 60;

//     try {
//       const res = await searchAlarmMsg({
//         deviceId: DEVICE_ID,
//         deviceChannel: 0,
//         alarmType: 0,
//         searchTime: date,
//         searchDays: 1,
//         imgSizes: {
//           imgHeight: 900,
//           imgWidth: 1600,
//         },
//       });
//       console.log('handleSearch res: ', res.length);

//       setAlarmMsgs(res);
//       setUpdatedTime(new Date().toString());
//     } catch (error) {
//       console.log('error: ', error);
//     }
//   };

//   const handleDeleteAlarm = async (id: string) => {
//     try {
//       const res = await deleteAlarmInfo({
//         deviceId: DEVICE_ID,
//         deleteType: 'MSG',
//         alarmInfos: [
//           {
//             id,
//           },
//         ],
//       });
//       console.log('handleDeleteAlarm res: ', res);
//     } catch (error) {
//       console.log('error: ', error);
//     }
//   };

//   const handleDeleteAllAlarms = async () => {
//     try {
//       const res = await deleteAllAlarmMsg({
//         deviceId: DEVICE_ID,
//         deleteType: 'MSG',
//       });
//       console.log('handleDeleteAllAlarms res: ', res);
//     } catch (error) {
//       console.log('error: ', error);
//     }
//   };

//   return (
//     <View style={styles.container}>
//       <Text>всего alarm найдено: {alarmMsgs.length}</Text>
//       <Text>время обновления: {updatedTime}</Text>
//       <Button text="Поиск Alarm" onPress={handleSearch} />
//       <Button text="Удалить все Alarm" onPress={handleDeleteAllAlarms} />
//       <FlatList
//         data={alarmMsgs}
//         renderItem={({ item }) => {
//           return (
//             <View
//               style={{
//                 borderWidth: 2,
//                 borderColor: 'red',
//                 margin: 8,
//                 padding: 4,
//               }}
//             >
//               <Button
//                 text="delete alarm"
//                 onPress={() => handleDeleteAlarm(item.id)}
//               />
//               {Object.entries(item).map(([key, value]) => {
//                 if (key === 'pic' && value !== null) {
//                   return (
//                     <Image
//                       style={{
//                         width: '100%',
//                         aspectRatio: 16 / 9,
//                         // height: 90,
//                       }}
//                       key={key}
//                       //@ts-expect-error
//                       source={{ uri: value }}
//                     />
//                   );
//                 }

//                 if (value !== null) {
//                   return (
//                     <Text key={key}>
//                       {key}: {String(value)}
//                     </Text>
//                   );
//                 }

//                 return null;
//               })}
//             </View>
//           );
//         }}
//       />
//     </View>
//   );
// };

// const styles = StyleSheet.create({
//   container: {
//     flex: 1,
//     backgroundColor: 'pink',
//     paddingTop: 100,
//   },
//   box: {
//     width: 60,
//     height: 60,
//     marginVertical: 20,
//     padding: 20,
//   },
//   monitor: {
//     width: '100%',
//     aspectRatio: 16 / 9,
//     backgroundColor: 'yellow',
//   },
//   button: {
//     // width: 100,
//     // height: 50,
//     margin: 10,
//     padding: 10,
//     display: 'flex',
//     justifyContent: 'center',
//     alignItems: 'center',
//     backgroundColor: 'green',
//   },
//   buttonText: {
//     color: 'white',
//   },
//   view: {
//     flexDirection: 'row',
//     flexWrap: 'wrap',
//     justifyContent: 'center',
//   },
// });
