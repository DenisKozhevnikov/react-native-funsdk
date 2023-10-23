import ReactNativeBlobUtil from 'react-native-blob-util';

export function getListOfFiles(directory: string) {
  return new Promise(async (res, rej) => {
    const arrayFiles: { [x: string]: string[] } = {};
    try {
      const folders = await ReactNativeBlobUtil.fs.ls(directory);

      await Promise.all(
        folders.map(async (folder) => {
          try {
            const files = await ReactNativeBlobUtil.fs.ls(
              directory + '/' + folder
            );
            arrayFiles[folder] = files;
          } catch (error) {
            console.error('Ошибка при получении файлов в папке', folder, error);
          }
        })
      );
      res(arrayFiles);
    } catch (error) {
      console.log('getListOfFiles error ', error);
      rej('error');
    }
  });
}

export function createFolderIfNotExist(
  basePath: string,
  devId: string
): Promise<boolean> {
  return new Promise((res, rej) => {
    ReactNativeBlobUtil.fs
      .exists(`${basePath}/${devId}/`)
      .then((exists) => {
        if (!exists) {
          console.log('FolderNotExist');
          ReactNativeBlobUtil.fs.mkdir(`${basePath}/${devId}/`);
          res(true);
        }
        res(true);
      })
      .catch((error) => {
        console.log(error);
        rej(false);
      });
  });
}
