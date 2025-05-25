// import 'package:flutter/material.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:analytical_reports/main.dart';

// abstract class NetworkInfoI {
//   Future<bool> isConnected();
//   Future<ConnectivityResult> get connectivityResult;
//   Stream<ConnectivityResult> get onConnectivityChanged;
// }

// class NetworkInfo implements NetworkInfoI {
//   Connectivity connectivity;
//   static final NetworkInfo _networkInfo = NetworkInfo._internal(Connectivity());
//   factory NetworkInfo() {
//     return _networkInfo;
//   }
//   NetworkInfo._internal(this.connectivity) {
//     connectivity = connectivity;
//   }
//   @override
//   Future<bool> isConnected() async {
//     final result = await connectivity.checkConnectivity();
//     if (result != ConnectivityResult.none) {
//       return true;
//     }
//     return false;
//   }

//   @override
//   Future<ConnectivityResult> get connectivityResult async {
//     return connectivity.checkConnectivity();
//   }

//   @override
//   Stream<ConnectivityResult> get onConnectivityChanged =>
//       connectivity.onConnectivityChanged;
// }

// abstract class Failure {}

// class ServerFailure extends Failure {}

// class CacheFailure extends Failure {}

// class NetworkFailure extends Failure {}

// class ServerException extends Failure {}

// class CacheException extends Failure {}

// class NetworkException extends Failure {}

// class NoInternetException extends Failure {
//   late String _message;
//   NoInternetException([String message = "NoInternetException Occured"]) {
//     if (globalMessengerKey.currentState != null) {
//       globalMessengerKey.currentState!
//           .showSnackBar(SnackBar(content: Text(message)));
//     }
//     _message = message;
//   }
//   @override
//   String toString() {
//     return _message;
//   }
// }
