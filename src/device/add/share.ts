// import { NativeModules } from 'react-native';
import { getAccessToken, getSecret } from '..';

// const funsdk = NativeModules.FunSDKDevShareManagerModule;

// Нет необходимости использовать
// export function userQuery(params: { searchUserName: string }): Promise<string> {
//   return funsdk.userQuery(params);
// }

// rsserver
export const RS_BASE_URL = 'https://rs.xmeye.net';
// jlinkserver
export const VOES_BASE_URL = 'https://jvss.xmcsrv.net/';

// {
//   "DP_ModifyConfig": 0,//Modify device configuration
//   "DP_ModifyPwd": 0,//Modify the device password. Modification is not available yet.
//   "DP_CloudServer": 0,//Access cloud services. Modification is not available yet.
//   "DP_Intercom": 1,//Intercom
//   "DP_PTZ": 1,//PTZ
//   "DP_LocalStorage": 1,//Local storage
//   "DP_ViewCloudVideo": 0,//View cloud video
//   "DP_DeleteCloudVideo": 0,//Delete cloud video. No modification is available yet.
//   "DP_AlarmPush": 0, //Push (including viewing alarm messages)
//   "DP_DeleteAlarmInfo": 0//Delete alarm messages (including pictures) without modification.
// },
// the information is transparently transmitted. After generating the QR code, scan to obtain the information and parse it directly;

// /**
//  * 查询用户
//  *
//  * @param version        协议版本
//  * @param timeMillis     时间戳
//  * @param secret         签名
//  * @param searchUserName 查询的账号
//  * @return
//  */
// @POST("usersearch/{version}/{timeMillis}/{secret}.rs")
// @Headers("urlname:rsserver")
// Call<ResponseBody> userQuery(
//         @Path("version") String version,
//         @Path("timeMillis") String timeMillis,
//         @Path("secret") String secret,
//         @Query("search") String searchUserName);

// Function to perform a server request to search for a user
export const userQuery = async (
  searchUserName: string, // Username to search for
  options: {
    host?: string; // Host (default is 'https://rs.xmeye.net')
    fetchInit?: RequestInit; // Fetch request settings
  } = {
    host: RS_BASE_URL, // Default host is 'https://rs.xmeye.net'
  }
) => {
  // Get the access token
  const accessToken = await getAccessToken();
  // Get the secret data
  const secretWithData = await getSecret();

  // Extract the necessary data from the secret data
  const { secret, timeMillis, uuid, appKey } = secretWithData;

  // Create an object to store query parameters
  const params = new URLSearchParams();
  // Set the "search" parameter to the searchUserName
  // (!) https://stackoverflow.com/questions/75757771/getting-the-urlsearchparams-set-is-not-implemented-error-when-trying-to-fetch
  // URLSearchParams.set is not implemented in React Native
  params.set('search', searchUserName);

  // Perform a fetch request
  const response = await fetch(
    // Construct the URL for the request, adding parameters from URLSearchParams
    `${
      options.host
    }/usersearch/v1/${timeMillis}/${secret}.rs?${params.toString()}`,
    {
      ...options.fetchInit, // Add additional fetch request settings
      headers: {
        // Add request headers, including Authorization, UUID, and appKey
        Authorization: accessToken,
        uuid,
        appKey,
        ...options.fetchInit?.headers, // Additional headers from options
      },
    }
  );

  // Get the response text from the server
  const res = await response.text();
  // Decode the received string
  const decodedString = decodeURIComponent(res);

  // Return the decoded string
  return decodedString;
};

// /**
//  * 取消分享
//  *
//  * @param version    协议版本
//  * @param timeMillis 时间戳
//  * @param secret     签名
//  * @param shareId    分享的ID
//  * @return
//  */
// @POST("mdsharedel/{version}/{timeMillis}/{secret}.rs")
// @Headers("urlname:rsserver")
// Call<ResponseBody> cancelShare(
//         @Path("version") String version,
//         @Path("timeMillis") String timeMillis,
//         @Path("secret") String secret,
//         @Query("devId") String shareId);

// /**
//  * 获取我分享出去的设备列表
//  *
//  * @param version    协议版本
//  * @param timeMillis 时间戳
//  * @param secret     签名
//  * @return
//  */
// @POST("mdsharemylist/{version}/{timeMillis}/{secret}.rs")
// @Headers("urlname:rsserver")
// Call<ResponseBody> getMySharedDevList(
//         @Path("version") String version,
//         @Path("timeMillis") String timeMillis,
//         @Path("secret") String secret);

// /**
//  * 获取好友分享过来的设备列表
//  *
//  * @param version    协议版本
//  * @param timeMillis 时间戳
//  * @param secret     签名
//  * @return
//  */
// @POST("mdsharelist/{version}/{timeMillis}/{secret}.rs")
// @Headers("urlname:rsserver")
// Call<ResponseBody> getOtherShareDevList(
//         @Path("version") String version,
//         @Path("timeMillis") String timeMillis,
//         @Path("secret") String secret);

// /**
//  * 获取我分享出去设备的用户列表
//  *
//  * @param version    协议版本
//  * @param timeMillis 时间戳
//  * @param secret     签名
//  * @param devId      设备序列号
//  * @return
//  */
// @POST("mdsharemylist/{version}/{timeMillis}/{secret}.rs")
// @Headers("urlname:rsserver")
// Call<ResponseBody> getMyShareUserList(
//         @Path("version") String version,
//         @Path("timeMillis") String timeMillis,
//         @Path("secret") String secret,
//         @Query("shareUuid") String devId);

// /**
//  * 分享设备
//  *
//  * @param version     协议版本
//  * @param timeMillis  时间戳
//  * @param secret      签名
//  * @param shareUuid   分享的设备序列号
//  * @param acceptId    被分享的账户（搜索账户时返回的id）
//  * @param powers      扩展能力
//  * @param permissions 设备权限
//  * @return
//  */
// @POST("mdshareadd/{version}/{timeMillis}/{secret}.rs")
// @Headers("urlname:rsserver")
// Call<ResponseBody> shareDev(
//         @Path("version") String version,
//         @Path("timeMillis") String timeMillis,
//         @Path("secret") String secret,
//         @Query("shareUuid") String shareUuid,
//         @Query("acceptId") String acceptId,
//         @Query("powers") String powers,
//         @Query("permissions") String permissions);

// /**
//  * 接受分享
//  *
//  * @param version    协议版本
//  * @param timeMillis 时间戳
//  * @param secret     签名
//  * @param shareUuid  分享的设备序列号
//  * @return
//  */
// @POST("mdshareaccept/{version}/{timeMillis}/{secret}.rs")
// @Headers("urlname:rsserver")
// Call<ResponseBody> accpetShare(
//         @Path("version") String version,
//         @Path("timeMillis") String timeMillis,
//         @Path("secret") String secret,
//         @Query("devId") String shareUuid);

// /**
//  * 拒绝分享
//  *
//  * @param version    协议版本
//  * @param timeMillis 时间戳
//  * @param secret     签名
//  * @param shareUuid  分享的设备序列号
//  * @return
//  */
// @POST("mdsharerefuse/{version}/{timeMillis}/{secret}.rs")
// @Headers("urlname:rsserver")
// Call<ResponseBody> rejectShare(
//         @Path("version") String version,
//         @Path("timeMillis") String timeMillis,
//         @Path("secret") String secret,
//         @Query("devId") String shareUuid);

// /**
//  * 添加分享过来的设备
//  *
//  * @param version    协议版本
//  * @param timeMillis 时间戳
//  * @param secret     签名
//  * @param devId      分享的设备序列号
//  * @param powers     扩展能力
//  * @return
//  */
// @POST("mdshareadd2/{version}/{timeMillis}/{secret}.rs")
// @Headers("urlname:rsserver")
// Call<ResponseBody> addDevFromShared(
//         @Path("version") String version,
//         @Path("timeMillis") String timeMillis,
//         @Path("secret") String secret,
//         @Query("shareUuid") String devId,
//         @Query("acceptId") String userId,
//         @Query("powers") String powers,
//         @Query("permissions") String permissions);

// /**
//  * 修改分享权限
//  *
//  * @param version     协议版本
//  * @param timeMillis  时间戳
//  * @param secret      签名
//  * @param shareId     分享id
//  * @param permissions 设备权限
//  * @return
//  */
// @POST("mdsharesetpermission/{version}/{timeMillis}/{secret}.rs")
// @Headers("urlname:rsserver")
// Call<ResponseBody> setSharePermission(
//         @Path("version") String version,
//         @Path("timeMillis") String timeMillis,
//         @Path("secret") String secret,
//         @Query("shareId") String shareId,
//         @Query("permissions") String permissions);

// interface Share {
//   /**
//    * 分享设备给某用户
//    */
//   static String shareDevice = "/v3/deviceShare/shareDevice/{timeMillis}/{sign}";
//   /**
//    * 查询别人分享给当前用户的设备列表 (当前用户已接收)
//    */
//   static String getSharedDeviceList = "/v3/deviceShare/getSharedDeviceList/{timeMillis}/{sign}";
//   /**
//    * 查询当前用户收到的分享请求
//    */
//   static String queryRecShareList = "/v3/deviceShare/selRecShare/{timeMillis}/{sign}";
//   /**
//    * 接受或拒绝分享请求
//    */
//   static String acceptOrRefuseShare = "/v3/deviceShare/acceptOrRefuse/{timeMillis}/{sign}";
//   /**
//    * 根据设备序列号查询分享给了哪些用户
//    */
//   static String queryDevShareList = "/v3/deviceShare/recShareUserList/{timeMillis}/{sign}";
//   /**
//    * 分享者删除分享关系
//    */
//   static String delSharedDevice = "/v3/deviceShare/delSharedDevice/{timeMillis}/{sign}";
//   /**
//    * 被分享者删除分享关系
//    */
//   static String delRecDevice = "/v3/deviceShare/delRecDevice/{timeMillis}/{sign}";
//   /**
//    * 根据主pid查询可分享权限列表
//    */
//   static String searchCanSharePrivileges = "/v3/deviceShare/selPrivilege/{timeMillis}/{sign}";

//   /**
//    * 生成设备分享码
//    */
//   static String createDevShareCode = "/v3/deviceShare/getShareCode/{timeMillis}/{sign}";

//   /**
//    * 解析设备分享码
//    */
//   static String decodeDevShareCode = "/v3/deviceShare/decodeShareCode/{timeMillis}/{sign}";

//   /**
//    * 通过分享码接受分享
//    */
//   static String acceptShareByCode = "/v3/deviceShare/acceptShareByCode/{timeMillis}/{sign}";
// }

// /**
//  * 分享设备给某用户
//  */
// @POST(ApiUrl.Share.shareDevice)
// @Headers("urlname: jlinkserver")
// Call<ResponseBody> shareDevice(
//         @Path("timeMillis") String timeMillis,
//         @Path("sign") String sign,
//         @Body HashMap<String, Object> requestBody);

// /**
//  * 查询别人分享给当前用户的设备列表（当前用户已接收）
//  */
// @POST(ApiUrl.Share.getSharedDeviceList)
// @Headers("urlname: jlinkserver")
// Call<ResponseBody> getSharedDeviceList(
//         @Path("timeMillis") String timeMillis,
//         @Path("sign") String sign,
//         @Body HashMap<String, Object> requestBody);

// /**
//  * 查询当前用户收到的分享请求
//  * @param timeMillis
//  * @param sign
//  */
// @POST(ApiUrl.Share.queryRecShareList)
// @Headers("urlname: jlinkserver")
// Call<ResponseBody> getShareRecInfo(@Path("timeMillis") String timeMillis,
//                                    @Path("sign") String sign);

// /**
//  * 接受或拒绝分享请求
//  */
// @POST(ApiUrl.Share.acceptOrRefuseShare)
// @Headers("urlname: jlinkserver")
// Call<ResponseBody> acceptOrRefuseShare(
//         @Path("timeMillis") String timeMillis,
//         @Path("sign") String sign,
//         @Body HashMap<String, Object> requestBody);

// /**
//  * 根据设备序列号查询分享给了哪些用户
//  */
// @POST(ApiUrl.Share.queryDevShareList)
// @Headers("urlname: jlinkserver")
// Call<ResponseBody> queryDevShareList(
//         @Path("timeMillis") String timeMillis,
//         @Path("sign") String sign,
//         @Body HashMap<String, Object> requestBody);

// /**
//  * 分享者删除分享关系
//  */
// @POST(ApiUrl.Share.delSharedDevice)
// @Headers("urlname: jlinkserver")
// Call<ResponseBody> delSharedRecByAdmin(
//         @Path("timeMillis") String timeMillis,
//         @Path("sign") String sign,
//         @Body HashMap<String, Object> requestBody);

// /**
//  * 被分享者删除分享关系
//  */
// @POST(ApiUrl.Share.delRecDevice)
// @Headers("urlname: jlinkserver")
// Call<ResponseBody> delSharedRecByMember(
//         @Path("timeMillis") String timeMillis,
//         @Path("sign") String sign,
//         @Body HashMap<String, Object> requestBody);

// /**
//  * 根据主pid查询可分享权限列表
//  */
// @POST(ApiUrl.Share.searchCanSharePrivileges)
// @Headers("urlname: jlinkserver")
// Call<ResponseBody> searchCanSharePrivileges(
//         @Path("timeMillis") String timeMillis,
//         @Path("sign") String sign,
//         @Body HashMap<String, Object> requestBody);

// /**
//  * 生成设备分享码
//  */
// @POST(ApiUrl.Share.createDevShareCode)
// @Headers("urlname: jlinkserver")
// Call<ResponseBody> createDevShareCode(
//         @Path("timeMillis") String timeMillis,
//         @Path("sign") String sign,
//         @Body HashMap<String, Object> requestBody);

// /**
//  * 解析设备分享码
//  */
// @POST(ApiUrl.Share.decodeDevShareCode)
// @Headers("urlname: jlinkserver")
// Call<ResponseBody> decodeDevShareCode(
//         @Path("timeMillis") String timeMillis,
//         @Path("sign") String sign,
//         @Body HashMap<String, Object> requestBody);

// /**
//  * 通过分享码接受分享
//  */
// @POST(ApiUrl.Share.acceptShareByCode)
// @Headers("urlname: jlinkserver")
// Call<ResponseBody> acceptShareByCode(
//         @Path("timeMillis") String timeMillis,
//         @Path("sign") String sign,
//         @Body HashMap<String, Object> requestBody);
