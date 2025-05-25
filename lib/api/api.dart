import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class API {
  // static String BASE_URL = EnvironmentConfig.environment == Environment.dev ?
  // 'http://elsimil-test.axara.co.id/api/v1' : "https://elsimil.bkkbn.go.id/api/v1";

  // static String BASE_URL = 'http://192.168.0.109/e_commerce';
  // static String BASE_URL = 'http://10.0.2.2/e_commerce';
  // static String BASE_URL = 'https://lightz.tiaragatzu.co.id';
  static String BASE_URL = 'https://modisyst.com/tokoonline/point_app';

  // static String BASE_URL = 'https://dharmaguna.id/tokool';

  static basePost(
      String module,
      Map<String, dynamic> post,
      Map<String, String> headers,
      bool encode,
      void callback(dynamic, Exception)) async {
    print("URL ${BASE_URL + module}");
    print("POST Header ${json.encode(headers)}");
    print("POST VALUE ${json.encode(post)}");
    String ada = json.encode(post);

    var mapError = new Map();
    try {
      final response = await http
          .post(Uri.parse(BASE_URL + module),
              // ignore: missing_return
              headers: headers,
              body: encode ? json.encode(post) : post)
          .timeout(
            Duration(seconds: 30),
            // onTimeout: (){
            //   mapError.putIfAbsent('message', () => 'Koneksi timout, gagal terhubung dengan service');
            //   recallback(null, mapError);
            // }
          );
      if (response != null) {
        int responseCode = response.statusCode;
        var sdad = response.body;
        var mapJson = json.decode(response.body);
        var dads = jsonEncode(mapJson);

        if (responseCode == 200) {
          callback(mapJson, null);
        } else if (responseCode == 401 ||
            responseCode == 403 ||
            responseCode == 401 ||
            responseCode == 403) {
          callback(null, mapJson);
        } else {
          callback(null, mapJson);
        }
      } else {
        mapError.putIfAbsent('message', () => 'Gagal memuat data.');
        callback(null, mapError);
      }
    } on RangeError catch (e) {
      mapError.putIfAbsent('message', () => 'Range error: ${e.message}');
      callback(null, mapError);
    } catch (e) {
      mapError.putIfAbsent(
          'message', () => 'Gagal memuat data.' + e.toString());
      callback(null, mapError);
    }
  }

  static basePost2(
      String url,
      Map<String, dynamic> post,
      Map<String, String> headers,
      bool encode,
      void callback(dynamic, Exception)) async {
    print("URL ${url}");
    print("POST Header ${json.encode(headers)}");
    print("POST VALUE ${json.encode(post)}");

    var mapError = new Map();
    try {
      final response = await http
          .post(Uri.parse(url),
              // ignore: missing_return
              headers: headers,
              body: encode ? json.encode(post) : post)
          .timeout(
            Duration(seconds: 30),
            //   onTimeout: (){
            // // callback(null, HTTPStatusFailedException('Koneksi terputus, silahkan coba lagi'));
            //     mapError.putIfAbsent('message', () => 'Koneksi timout, Gagal memuat data.');
            //     callback(null, mapError);
            //   }
          );
      if (response != null) {
        int responseCode = response.statusCode;
        var mapJson = json.decode(response.body);
        print("POST RESULT ${json.encode(mapJson)}");
        if (mapJson['code'] == 200) {
          callback(mapJson, null);
        } else if (responseCode == 401 ||
            responseCode == 403 ||
            mapJson['code'] == 401 ||
            mapJson['code'] == 403) {
          callback(null, mapJson);
        } else {
          callback(null, mapJson);
        }
      } else {
        mapError.putIfAbsent('message', () => 'Gagal memuat data.');
        callback(null, mapError);
      }
    } on SocketException catch (e) {
      mapError.putIfAbsent('message', () => 'Gagal memuat data.');
      callback(null, mapError);
    } catch (e) {
      mapError.putIfAbsent('message', () => 'Gagal memuat data.');
      callback(null, mapError);
    }
  }

  // static postLogin(String username, String pas, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['username'] = username;
  //   post['password'] = pas;
  //   var playerId = await LocalData.getPlayerId();
  //   var imei = '';//await DeviceImei.getImei();
  //   if(playerId != null){
  //     post['player_id'] = playerId;
  //   }
  //   if(playerId != null){
  //     post['imei'] = imei;
  //   }
  //   basePost('/login', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static postRegister(
  //     String name,
  //     String email,
  //     String password,
  //     String no_telp,
  //     String no_ktp,
  //     String foto_name,
  //     String foto_ktp,
  //     String tempat_lahir,
  //     String tgl_lahir,
  //     String gender,
  //     String alamat,
  //     String provinsi_id,
  //     String kabupaten_id,
  //     String kecamatan_id,
  //     String kelurahan_id,
  //     String rt,
  //     String rw,
  //     String kodepos,
  //     String tglNikah,
  //     String statusNikah,
  //     String lat,
  //     String lon,
  //     void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['name'] = name;
  //   post['no_telp'] = no_telp;
  //   post['email'] = email;
  //   post['password'] = password;
  //   post['no_ktp'] = no_ktp;
  //   post['foto_name'] = foto_name;
  //   post['foto_ktp'] = foto_ktp;
  //   post['tempat_lahir'] = tempat_lahir;
  //   post['tgl_lahir'] = tgl_lahir;
  //   post['gender'] = gender;
  //   post['alamat'] = alamat;
  //   post['provinsi_id'] = provinsi_id;
  //   post['kabupaten_id'] = kabupaten_id;
  //   post['kecamatan_id'] = kecamatan_id;
  //   post['kelurahan_id'] = kelurahan_id;
  //   post['rt'] = rt;
  //   post['rw'] = rw;
  //   post['kodepos'] = kodepos;
  //   post['rencana_pernikahan'] = tglNikah;
  //   post['status_pernikahan'] = statusNikah;
  //   post['lat'] = lat;
  //   post['lon'] = lon;
  //   var playerId = await LocalData.getPlayerId();
  //   var imei = '';//await DeviceImei.getImei();
  //   if(playerId != null){
  //     post['player_id'] = playerId;
  //   }
  //   if(playerId != null){
  //     post['imei'] = imei;
  //   }
  //   // var dsad = jsonEncode(post);
  //   // var dasad = dsad;
  //   basePost('/register', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static emailChecking(String email,  void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['email'] = email;
  //   basePost('/emailcheck', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static getProvinsi(void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   basePost('/provinsi', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static getKabupaten(String provinsiId, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['provinsi_code'] = provinsiId;
  //   basePost('/kabupaten', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static getKecamatan(String kabId, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['kabupaten_code'] = kabId;
  //   basePost('/kecamatan', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static getKelurahan(String kecId, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['kecamatan_code'] = kecId;
  //   basePost('/kelurahan', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static forgotPassword(String email, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['email'] = email;
  //   post['tipe'] = '2';
  //   basePost('/forgot', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static quizList(String id, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   basePost('/kuislist', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static quizIntro(int id, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   basePost('/kuisintro', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static listPertanyaanQuiz(int id, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   basePost('/pertanyaan', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static submitQuiz(String userId, List data, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['user_id'] = userId;
  //   post['data'] = data;
  //   basePost('/submitkuis', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static checkVerifyAccount(String userId, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = userId;
  //   basePost('/checkverify', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static newsCategory(void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   basePost('/newskategori', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static listArtikel(String kategoriId, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['kategori_id'] = kategoriId;
  //   basePost('/newslist', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static detailArtikel(String newsId, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['news_id'] = newsId;
  //   basePost('/newsdetail', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static relatedArtikel(void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   basePost('/newsrelated', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static bantuan(void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   basePost('/pagelist', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static detailBantuan(String id, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   basePost('/pagedetail', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static home(String id, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   basePost('/home', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static quizCategory(String id, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   basePost('/kuiscategory', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static getprofile(String id, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   basePost('/profile', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static updateprofile(
  //     String id,
  //     String name,
  //     String no_telp,
  //     String email,
  //     String no_ktp,
  //     String tempat_lahir,
  //     String tgl_lahir,
  //     String gender,
  //     String alamat,
  //     String provinsi_id,
  //     String kabupaten_id,
  //     String kecamatan_id,
  //     String kelurahan_id,
  //     String rt,
  //     String rw,
  //     String kodepos,
  //     String foto_name,
  //     String foto_ktp,
  //     String lat,
  //     String lon,
  //     void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   post['name'] = name;
  //   post['no_telp'] = no_telp;
  //   post['email'] = email;
  //   post['no_ktp'] = no_ktp;
  //   post['tempat_lahir'] = tempat_lahir;
  //   post['tgl_lahir'] = tgl_lahir;
  //   post['gender'] = gender;
  //   post['alamat'] = alamat;
  //   post['provinsi_id'] = provinsi_id;
  //   post['kabupaten_id'] = kabupaten_id;
  //   post['kecamatan_id'] = kecamatan_id;
  //   post['kelurahan_id'] = kelurahan_id;
  //   post['rt'] = rt;
  //   post['rw'] = rw;
  //   post['kodepos'] = kodepos;
  //   post['pic_name'] = foto_name;
  //   post['foto_pic'] = foto_ktp;
  //   post['lat'] = lat;
  //   post['lon'] = lon;
  //   basePost('/updateprofile', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static listSpouse(String userId, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = userId;
  //   basePost('/couplelist', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static addSpouse(String userId, String ktp, String profileId, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = userId;
  //   post['no_ktp'] = ktp;
  //   post['profile_id'] = profileId;
  //   basePost('/addcouple', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static pendingSpouse(String userId, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = userId;
  //   basePost('/pendingcouple', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static confirmSpouse(String userId, String requestId, String action, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = userId;
  //   post['request_id'] = requestId;
  //   post['action'] = action;
  //   basePost('/confirmcouple', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static riwayatQuiz(String userId, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = userId;
  //   basePost('/resultlist', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static riwayatQuizDetail(String id, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   basePost('/resultdetail', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static listChat(String id, String type, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   post['page'] = '1';
  //   post['type'] = type;
  //   basePost('/chatlist', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static postChat(String id, String mesage, String type, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   post['message'] = mesage;
  //   post['type'] = type;
  //   basePost('/chatsubmit', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static listNotif(String id, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   basePost('/notiflist', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static deletetNotif(String id, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   basePost('/notifdelete', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static insertNotif(void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   basePost('/notifinsert', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static riwayatPasangan(String id, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   basePost('/resultcouple', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static inboxNotif(String id, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   basePost('/infonotif', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static checkVersion(void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   if (Platform.isAndroid) {
  //     post['tipe'] = 'android';
  //   }else{
  //     post['tipe'] = 'ios';
  //   }
  //   basePost('/version', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static changePassword(String id, String oldPass, String newPass, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   post['old_password'] = oldPass;
  //   post['new_password'] = newPass;
  //   basePost('/changepassword', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static deklarasiHamil(String id, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   basePost('/hamil/updatestatus', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static listJanin(String id, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   basePost('/hamil/listjanin', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static listAnak(String id, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   // post['id'] = '9389';
  //   post['id'] = id;
  //   basePost('/baduta/listbaduta', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static resultQuizHamil(String id, String janinID, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id; //113;
  //   post['janin_id'] = janinID; //3;
  //   basePost('/hamil/resultkuis', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static resultQuizBaduta(String id, String badutaID, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   // post['id'] = '9389';
  //   // post['baduta_id'] = 1;
  //   post['id'] = id;
  //   post['baduta_id'] = badutaID;
  //   basePost('/baduta/resultkuis', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static detailQuizHamil(String id, String janinID, String quizHamilId,  void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   post['janin_id'] = janinID;
  //   post['kuis_hamil_id'] = quizHamilId;
  //   basePost('/hamil/resultkuisdetail', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static resultDetailQuizHamil(String id, String janinId, String quizId, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   post['janin_id'] = janinId;
  //   post['kuis_hamil_id'] = quizId;
  //   basePost('/hamil/resultkuisdetail', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static updateStatusHamil(String id, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   basePost('/hamil/updatestatus', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static updateStatusBaduta(String id, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['id'] = id;
  //   basePost('/baduta/updatestatus', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static checkNik(String nik, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   post['nik'] = nik;
  //   basePost('/checknik', post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static resendVerificaion(String url, List<Additional> params, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   header['Content-Type'] = 'application/json';
  //   if(params.isNotEmpty){
  //     for(Additional add in params){
  //       post[add.params!] = add.value;
  //     }
  //   }
  //   basePost2(url, post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }
  //
  // static finding(String url, String param, String valueParam, void callback(Map, Exception)) async {
  //   var header = new Map<String, String>();
  //   var post = new Map<String, dynamic>();
  //   var user = await LocalData.getUser();
  //   header['Content-Type'] = 'application/json';
  //   post[param] = valueParam;
  //   post['user_id '] = user.id;
  //   basePost2(url, post, header, true, (result, error){
  //     callback(result, error);
  //   });
  // }

  static baseGetFile(String module, Map<String, String> headers,
      String namaFile, void callback(File file)) async {
    // Utils.log("URL ${BASE_URL + module}");
    try {
      final response =
          await http.get(Uri.parse(BASE_URL + module), headers: headers);
      if (response.contentLength == 0) {
        return callback(File(''));
      }
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      File file = new File('$tempPath/$namaFile');
      await file.writeAsBytes(response.bodyBytes);
      callback(file);
    } catch (e) {
      // callback(null, HTTPStatusFailedException('Koneksi sedang tidak stabil'));
    }
  }

  static baseGet(String module, Map<String, String> headers,
      void callback(dynamic, exception)) async {
    // Utils.log("URL ${BASE_URL + module}");

    var mapError = new Map();
    try {
      // ignore: missing_return
      final response = await http
          .get(Uri.parse(BASE_URL + module), headers: headers)
          .timeout(
            Duration(seconds: 30),
            //   onTimeout: (){
            // // callback(null, HTTPStatusFailedException('Koneksi terputus, silahkan coba lagi'));
            //   mapError.putIfAbsent('message', () => 'Koneksi timout, Gagal memuat data.');
            //   callback(null, mapError);
            // }
          );
      int responseCode = response.statusCode;
      var mapJson = json.decode(response.body);

      // Utils.log("RESPONSE ${mapJson.toString()}");

      if (mapJson['code'] == 200) {
        callback(mapJson, null);
      } else if (responseCode == 401 ||
          responseCode == 403 ||
          mapJson['code'] == 401 ||
          mapJson['code'] == 403 ||
          mapJson['code'] == 422) {
        callback(null, mapJson);
      } else {
        mapError.putIfAbsent('message', () => 'Gagal memuat data.');
        callback(null, mapError);
      }
    } catch (e) {
      mapError.putIfAbsent('message', () => 'Gagal memuat data.');
      callback(null, mapError);
    }
  }

  // static getUserProfile(void callback(Map, Exception)) {
  //   var header = new Map<String, String>();
  //   header['Content-Type'] = 'application/json';
  //   baseGet('/user', header, (result, error) {
  //     callback(result, error);
  //   });
  // }
  //
  // static getChatType(int id, void callback(Map, Exception)) {
  //   var header = new Map<String, String>();
  //   header['Content-Type'] = 'application/json';
  //   baseGet('/chattype?id=${id}', header, (result, error) {
  //     callback(result, error);
  //   });
  // }
  //
  // static getStatusHamil(int id, void callback(Map, Exception)) {
  //   var header = new Map<String, String>();
  //   header['Content-Type'] = 'application/json';
  //   baseGet('/hamil/checkstatus/${id}', header, (result, error) {
  //     callback(result, error);
  //   });
  // }
  //
  // static getStatusBaduta(int id, void callback(Map, Exception)) {
  //   var header = new Map<String, String>();
  //   header['Content-Type'] = 'application/json';
  //   baseGet('/baduta/checkstatus/${id}', header, (result, error) {
  //     callback(result, error);
  //   });
  // }
  //
  // static Future<bool> isConnected() async {
  //   try {
  //     final result = await InternetAddress.lookup('google.com');
  //     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
  //       return true;
  //     }
  //   } on SocketException catch (_) {
  //     return false;
  //   }
  //   return false;
  // }
  //
  // // static Future<bool> isConnected2() async {
  // //   var connectivityResult = await (Connectivity().checkConnectivity());
  // //   // if (connectivityResult == ConnectivityResult.none) {
  // //   //   setState(() {
  // //   //     isInternetOn = false;
  // //   //   });
  // //   // }
  // //   return false;
  // // }
  //
  // static baseDelete(String module, Map<String, String> headers,
  //     void callback(dynamic, exception)) async {
  //   Utils.log("URL ${BASE_URL + module}");
  //   Utils.log("Header ${json.encode(headers)}");
  //   // var connect = await isConnected();
  //   // if(!connect){
  //   //   callback(null, 'Tidak ada koneksi');
  //   //   return;
  //   // }
  //
  //   try {
  //     final response = await http.delete(Uri.parse(BASE_URL + module), headers: headers);
  //     int responseCode = response.statusCode;
  //     var mapJson = json.decode(response.body);
  //
  //     Utils.log("RESPONSE ${mapJson.toString()}");
  //
  //     if (mapJson['code'] == 200) {
  //       callback(mapJson, null);
  //     } else if (responseCode == 401 ||
  //         responseCode == 403 ||
  //         mapJson['code'] == 401 ||
  //         mapJson['code'] == 403 ||
  //         mapJson['code'] == 422) {
  //       // callback(null, TokenException());
  //     } else {
  //       // callback(null, HTTPStatusFailedException(mapJson['message']));
  //     }
  //   } catch (e) {
  //     // callback(null, HTTPStatusFailedException('Koneksi sedang tidak stabil'));
  //   }
  // }
  //
  //
  //
  // static basePut(
  //     String module,
  //     Map<String, dynamic> post,
  //     Map<String, String> headers,
  //     bool encode,
  //     void callback(dynamic, Exception)) async {
  //
  //   Utils.log("URL ${BASE_URL + module}");
  //   Utils.log("POST Header ${json.encode(headers)}");
  //   Utils.log("POST VALUE ${json.encode(post)}");
  //
  //   var mapError = new Map();
  //   try{
  //         final response = await http.put(Uri.parse(BASE_URL+module),
  //         // ignore: missing_return
  //       //   headers: headers, body: encode ? json.encode(post) : post).timeout(Duration(seconds: 30),
  //       //       onTimeout: (){
  //       // // callback(null, HTTPStatusFailedException('Koneksi terputus, silahkan coba lagi'));
  //       //     mapError.putIfAbsent('message', () => 'Koneksi terputus, silahkan coba lagi');
  //       //     callback(null, mapError);
  //       //   }
  //     );
  //     if(response != null){
  //       int responseCode = response.statusCode;
  //       var mapJson = json.decode(response.body);
  //       Utils.log("POST RESULT ${json.encode(mapJson)}");
  //       if (mapJson['code'] == 200) {
  //         callback(mapJson, null);
  //       } else if (responseCode == 401 ||
  //           responseCode == 403 ||
  //           mapJson['code'] == 401 ||
  //           mapJson['code'] == 403) {
  //         callback(null, mapJson);
  //       } else {
  //         callback(null, mapJson);
  //       }
  //     }else{
  //       mapError.putIfAbsent('message', () => 'Gagal memuat data.');
  //       callback(null, mapError);
  //     }
  //   } on SocketException catch(e){
  //     mapError.putIfAbsent('message', () => 'Gagal memuat data.');
  //     callback(null, mapError);
  //   } catch (e){
  //     mapError.putIfAbsent('message', () => 'Gagal memuat data.');
  //     callback(null, mapError);
  //   }
  // }
  //
  // static getDeliveryOrder(String doCode, String uniqueCode, void callback(Map, Exception)) {
  //   var header = new Map<String, String>();
  //   header['Content-Type'] = 'application/json';
  //   header['unique_code'] = uniqueCode;
  //   baseGet('/deliveryorder/${doCode}', header, (result, error) {
  //     callback(result, error);
  //   });
  // }
}
