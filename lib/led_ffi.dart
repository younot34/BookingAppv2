// import 'dart:ffi';
// import 'dart:io';
//
// // Load .so library
// final DynamicLibrary ledLib = Platform.isAndroid
//     ? DynamicLibrary.open("libjnielc.so")
//     : throw UnsupportedError("This platform is not supported");
//
// // Definisikan fungsi native
// typedef LedOnNative = Int32 Function();
// typedef LedOn = int Function();
//
// typedef LedOffNative = Int32 Function();
// typedef LedOff = int Function();
//
// final LedOn ledOn = ledLib.lookupFunction<LedOnNative, LedOn>("led_on");
// final LedOff ledOff = ledLib.lookupFunction<LedOffNative, LedOff>("led_off");
