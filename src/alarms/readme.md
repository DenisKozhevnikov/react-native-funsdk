события (в фансдк они называются alarms)
https://github.com/DenisKozhevnikov/react-native-funsdk/blob/main/src/alarms/index.tsx

пример использования:
https://github.com/DenisKozhevnikov/react-native-funsdk/blob/main/example/src/alarms/index.tsx

метод для поиска событий:
searchAlarmMsg

пример поиска событий

```
// 2 дня назад
const date = Date.now() - 1000 * 60 * 60 * 24 * 2;

const res = await searchAlarmMsg({
  deviceId: DEVICE_ID,
  deviceChannel: 0,
  // alarmType - не знаю что это, пробовал отправлять разные числа и результат всегда был одинаковый, в коде тоже грустно
  alarmType: 0,
  // отправляется timestamp нужного дня (именно дня, остальное время дальше подставляется самостоятельно)
  searchTime: date,
  // в библиотеке вроде как предусмотрено, что можно запрашивать несколько дней, но почему-то не работает и ищет только за тот день который был запрошен в searchTime
  searchDays: 1,
  // размеры запрашиваемых изображений
  imgSizes: {
    imgHeight: 900,
    imgWidth: 1600,
  },
});
```

пример удаления события(-ий)

```
const res = await deleteAlarmInfo({
  deviceId: DEVICE_ID,
  // есть два варианта MSG или VIDEO
  deleteType: 'MSG',
  // массив состоящий из объектов с ключем id и значением из id найденного события
  alarmInfos: [
    {
      id,
    },
  ],
});
```

пример удаления всех событий со всего(!) устройства

```
const res = await deleteAllAlarmMsg({
   deviceId: DEVICE_ID,
   deleteType: 'MSG',
});
```

тип для событий - AlarmInfo, бОльшая часть данных в нём будет null, самое интересное и необходимое это:
id - уникальный id события на устройстве по которому мы его потом можем удалить
pic - ссылка на изображение (если есть) связанное с событием
event - имя события которое произошло, в enum AlarmType есть все варианты видов Событий которые могут быть
