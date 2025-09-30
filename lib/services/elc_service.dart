// import 'package:flutter/services.dart';
//
// class ElcService {
//   static const MethodChannel _channel = MethodChannel('elc_channel');
//
//   static Future<int?> ledSeek(int color, int value) async {
//     final result = await _channel.invokeMethod<int>(
//       'ledSeek',
//       {"color": color, "value": value},
//     );
//     return result;
//   }
//
//   static Future<int?> ledSeek3(int color, int value) async {
//     final result = await _channel.invokeMethod<int>(
//       'ledSeek3',
//       {"color": color, "value": value},
//     );
//     return result;
//   }
//
//   static Future<int?> seekStart() async {
//     return await _channel.invokeMethod<int>('seekStart');
//   }
//
//   static Future<int?> seekStop() async {
//     return await _channel.invokeMethod<int>('seekStop');
//   }
// }
