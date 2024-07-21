import ReactNativeBlobUtil from 'react-native-blob-util';
import { Permission, PermissionsAndroid, Platform } from 'react-native';
// export function createFolderIfNotExist(basePath: string, devId: string): void {
//   ReactNativeBlobUtil.fs
//     .exists(`${basePath}/${devId}/`)
//     .then((exists) => {
//       if (!exists) {
//         console.log('FolderNotExist');
//         ReactNativeBlobUtil.fs.mkdir(`${basePath}/${devId}/`);
//       }
//     })
//     .catch((error) => {
//       console.log(error);
//     });
// }
const createFolderIfNotExist = async (path: string) => {
  const isExists = await ReactNativeBlobUtil.fs.exists(path);
  console.log('createFolderIfNotExist isExists: ', isExists);
  if (!isExists) {
    ReactNativeBlobUtil.fs.mkdir(path);
  }
};

const getFilesInFolder = async (path: string) => {
  await createFolderIfNotExist(path);
  return await ReactNativeBlobUtil.fs.ls(path);
};

export const hasWriteStoragePermission = async () => {
  const getCheckPermissionPromise = () => {
    return PermissionsAndroid.check(
      PermissionsAndroid.PERMISSIONS.WRITE_EXTERNAL_STORAGE!
    );
  };

  const hasPermission = await getCheckPermissionPromise();

  if (hasPermission) {
    return true;
  }

  const getRequestPermissionPromise = () => {
    return PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.WRITE_EXTERNAL_STORAGE!
    ).then((status) => status === PermissionsAndroid.RESULTS.GRANTED);
  };

  return await getRequestPermissionPromise();
};

export const hasReadStoragePermission = async () => {
  const getCheckPermissionPromise = () => {
    return PermissionsAndroid.check(
      PermissionsAndroid.PERMISSIONS.READ_EXTERNAL_STORAGE!
    );
  };

  const hasPermission = await getCheckPermissionPromise();

  if (hasPermission) {
    return true;
  }

  const getRequestPermissionPromise = () => {
    return PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.READ_EXTERNAL_STORAGE!
    ).then((status) => status === PermissionsAndroid.RESULTS.GRANTED);
  };

  return await getRequestPermissionPromise();
};

export const hasReadImagesVideoPermission = async () => {
  const getCheckPermissionPromise = () => {
    if (Number(Platform.Version) >= 33) {
      return Promise.all([
        PermissionsAndroid.check(
          PermissionsAndroid.PERMISSIONS.READ_MEDIA_IMAGES!
        ),
        PermissionsAndroid.check(
          PermissionsAndroid.PERMISSIONS.READ_MEDIA_VIDEO!
        ),
      ]).then(
        ([hasReadMediaImagesPermission, hasReadMediaVideoPermission]) =>
          hasReadMediaImagesPermission && hasReadMediaVideoPermission
      );
    } else {
      return PermissionsAndroid.check(
        PermissionsAndroid.PERMISSIONS.READ_EXTERNAL_STORAGE!
      );
    }
  };

  const hasPermission = await getCheckPermissionPromise();

  if (hasPermission) {
    return true;
  }
  const getRequestPermissionPromise = () => {
    if (Number(Platform.Version) >= 33) {
      return PermissionsAndroid.requestMultiple([
        PermissionsAndroid.PERMISSIONS.READ_MEDIA_IMAGES!,
        PermissionsAndroid.PERMISSIONS.READ_MEDIA_VIDEO!,
      ]).then(
        (statuses) =>
          statuses[PermissionsAndroid.PERMISSIONS.READ_MEDIA_IMAGES!] ===
            PermissionsAndroid.RESULTS.GRANTED &&
          statuses[PermissionsAndroid.PERMISSIONS.READ_MEDIA_VIDEO!] ===
            PermissionsAndroid.RESULTS.GRANTED
      );
    } else {
      return PermissionsAndroid.request(
        PermissionsAndroid.PERMISSIONS.READ_EXTERNAL_STORAGE!
      ).then((status) => status === PermissionsAndroid.RESULTS.GRANTED);
    }
  };

  return await getRequestPermissionPromise();
};

export const hasAndroidPermission = async (perm: Permission | undefined) => {
  const getCheckPermissionPromise = () => {
    return PermissionsAndroid.check(perm!);
  };

  const hasPermission = await getCheckPermissionPromise();

  if (hasPermission) {
    return true;
  }

  const getRequestPermissionPromise = () => {
    return PermissionsAndroid.request(perm!).then(
      (status) => status === PermissionsAndroid.RESULTS.GRANTED
    );
  };

  return await getRequestPermissionPromise();
};

export const handleImageSaver = async (
  devId: string,
  channel: number,
  onSave: (path: string) => void
) => {
  try {
    const hasMediaPermission = await hasReadImagesVideoPermission();
    console.log('hasMediaPermission: ', hasMediaPermission);
    const hasStoragePermission = await hasWriteStoragePermission();
    console.log('hasStoragePermission: ', hasStoragePermission);
    const hasReadStPermission = await hasReadStoragePermission();
    console.log('hasReadStPermission: ', hasReadStPermission);

    const READ_MEDIA_IMAGES = await hasAndroidPermission(
      PermissionsAndroid.PERMISSIONS.READ_MEDIA_IMAGES
    );
    console.log('READ_MEDIA_IMAGES: ', READ_MEDIA_IMAGES);
    const READ_MEDIA_VIDEO = await hasAndroidPermission(
      PermissionsAndroid.PERMISSIONS.READ_MEDIA_VIDEO
    );
    console.log('READ_MEDIA_VIDEO: ', READ_MEDIA_VIDEO);
    const READ_MEDIA_AUDIO = await hasAndroidPermission(
      PermissionsAndroid.PERMISSIONS.READ_MEDIA_AUDIO
    );
    console.log('READ_MEDIA_AUDIO: ', READ_MEDIA_AUDIO);

    const folder = ReactNativeBlobUtil.fs.dirs.PictureDir;

    const path = `${folder}/${devId}/${channel}`;
    console.log('path: ', path);

    await createFolderIfNotExist(path);

    onSave(path);

    setTimeout(() => {
      getFilesInFolder(path).then((files) => {
        console.log('files: ', files);
      });
    }, 1000);
  } catch (error) {
    console.log('handleImageSaver error: ', error);
  }
};

// export const ImageSaver = () => {
//   return (

//   )
// }
