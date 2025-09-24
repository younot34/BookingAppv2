import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:testing/services/elc_service.dart';
import 'package:window_manager/window_manager.dart';
import '../model/booking.dart';
import '../services/booking_service.dart';
import '../services/device_service.dart';
import '../services/media_service.dart';
import 'Logo.dart';
import 'RoomDetailPage.dart';
import 'package:intl/intl.dart';
import 'Scanme/ScanPage.dart';
import 'package:kiosk_mode/kiosk_mode.dart';

class HomePage extends StatefulWidget {
  final String roomName;
  const HomePage({super.key, required this.roomName});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{
  bool isScanEnabled = false;
  bool isAvailable = true;
  late Timer _timer;
  late StreamSubscription _bookingSubscription;
  DateTime _currentTime = DateTime.now();
  List<Booking> bookings = [];
  final GlobalKey _leftCardKey = GlobalKey();
  double _leftCardHeight = 0;
  double buttonWidth = 220;
  int _logoTapCount = 0;
  Timer? _tapResetTimer;
  final BookingService bookingService = BookingService();
  final DeviceService deviceService = DeviceService();
  int? roomCapacity;
  String? roomLocation;
  String? logoUrlMain;
  String? logoUrlSub;
  String roomStatus = "AVAILABLE";
  final DeviceService _deviceService = DeviceService();

  Future<void> _loadMediaLogos() async {
    final mediaList = await MediaService().getAllMedia(); // ambil semua media
    if (mediaList.isNotEmpty) {
      setState(() {
        logoUrlMain = mediaList[0].logoUrl; // logo utama
        logoUrlSub = mediaList[0].subLogoUrl; // sub logo
      });
    }
  }

  Route<T> _noAnimationRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  bool get isMeetNowAllowed {
    for (var b in bookings) {
      final start = parseBookingDateTimeSafe(b.date, b.time);
      final diff = start.difference(_currentTime).inMinutes;
      if (diff > 0 && diff < 35) {
        return false;
      }
    }
    return true;
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableKioskMode();
    _listenBookings();
    _fetchDeviceData();
    _loadMediaLogos();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLeftCardHeight();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
        _updateAvailability();
        _updateBookingStatus();
      });
    });
    DeviceService.registerOrGetRoom().then((roomName) {
      DeviceService.setDeviceStatusByRoom(roomName, true);
    });

  }
  DateTime parseBookingDateTimeSafe(String date, String time) {
    // Default values jika parsing gagal
    int year = 2000, month = 1, day = 1, hour = 0, minute = 0;

    // Parse date
    try {
      if (date.contains('/')) {
        final dateParts = date.split('/');
        day = int.tryParse(dateParts[0]) ?? 1;
        month = int.tryParse(dateParts[1]) ?? 1;
        year = int.tryParse(dateParts[2]) ?? 2000;
      } else if (date.contains('T')) {
        final datePart = date.split('T')[0];
        final dateParts = datePart.split('-');
        year = int.tryParse(dateParts[0]) ?? 2000;
        month = int.tryParse(dateParts[1]) ?? 1;
        day = int.tryParse(dateParts[2]) ?? 1;
      }
    } catch (_) {}

    // Parse time
    try {
      final timeParts = time.split(':');
      hour = int.tryParse(timeParts[0]) ?? 0;
      minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;
    } catch (_) {}

    return DateTime(year, month, day, hour, minute);
  }

  void _listenBookings() {
    _bookingSubscription = bookingService
        .streamBookingsByRoom(widget.roomName)
        .listen((list) {
      setState(() {
        bookings = list;
        _updateAvailability();
      });
    });
  }

  Future<void> _fetchDeviceData() async {
    final device = await DeviceService.getDeviceByRoom(widget.roomName);
    if (device != null) {
      setState(() {
        roomCapacity = device.capacity;
        roomLocation = device.location;
      });
    } else {
      setState(() {
        roomCapacity = null;
        roomLocation = "Unknown";
      });
    }
  }

  Future<void> _enableKioskMode() async {
    if (Platform.isWindows) {
      await windowManager.setFullScreen(true);
      await windowManager.setAlwaysOnTop(true);
      await windowManager.setSkipTaskbar(true);
    } else {
      await startKioskMode();
    }
  }

  Future<void> _disableKioskMode() async {
    if (Platform.isWindows) {
      await windowManager.setAlwaysOnTop(false);
      await windowManager.setSkipTaskbar(false);
      await windowManager.setFullScreen(false);
    } else {
      await stopKioskMode();
    }
  }

  void _updateLeftCardHeight() {
    final ctx = _leftCardKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox;
      setState(() {
        _leftCardHeight = box.size.height;
      });
    }
  }

  String formatBookingTime(String startTime, String date, String? duration) {
    final start = parseBookingDateTimeSafe(date, startTime);
    final dur = int.tryParse(duration ?? '30') ?? 30;
    final end = start.add(Duration(minutes: dur));
    final formatter = DateFormat("HH:mm");
    return "${formatter.format(start)}-${formatter.format(end)} | ${dur}m";
  }

  String formatBookingDate(String isoDate) {
    final dt = DateTime.parse(isoDate);
    return DateFormat("yyyy-MM-dd").format(dt);
  }

  void _updateAvailability() {
    final now = _currentTime;
    String newStatus = "AVAILABLE";
    bool available = true;

    for (var b in bookings) {
      final start = parseBookingDateTimeSafe(b.date, b.time);
      if (start == null) continue;

      final dur = int.tryParse(b.duration ?? '30') ?? 30;
      final end = start.add(Duration(minutes: dur));
      final diff = start.difference(now).inMinutes;

      if (now.isAfter(start) && now.isBefore(end)) {
        newStatus = "NOT AVAILABLE";
        available = false;

        if (mounted) Future.microtask(() => ElcService.ledOff());
        break;
      } else if (diff > 0 && diff <= 30) {
        newStatus = "WAITING FOR NEXT MEETING";
        available = true;

        if (mounted) Future.microtask(() => ElcService.seekStart());
        break;
      }
    }

    if (mounted) {
      setState(() {
        roomStatus = newStatus;
        isAvailable = available;
      });

      // Default kalau kosong
      if (newStatus == "AVAILABLE") Future.microtask(() => ElcService.ledSeek());
    }
  }
  void _updateBookingStatus() async {
    final now = DateTime.now();

    for (var b in List<Booking>.from(bookings)) {
      final start = parseBookingDateTimeSafe(b.date, b.time);
      final dur = int.tryParse(b.duration ?? '30') ?? 30;
      final end = start.add(Duration(minutes: dur));

      if (now.isAfter(end)) {
        try {
          await bookingService.endBooking(int.parse(b.id));
          setState(() {
            bookings.remove(b);
          });
          Fluttertoast.showToast(
            msg: "Booking '${b.meetingTitle}' selesai dan dipindahkan ke history",
          );
        } catch (e) {
          print("Gagal memindahkan booking ${b.id} ke history: $e");
        }
      }
    }
  }

  Booking? get currentMeeting {
    for (var b in bookings) {
      final start = parseBookingDateTimeSafe(b.date, b.time);
      final dur = int.tryParse(b.duration ?? '30') ?? 30;
      final end = start.add(Duration(minutes: dur));

      if (_currentTime.isAfter(start) && _currentTime.isBefore(end)) {
        return b;
      }
    }
    return null;
  }


  String get formattedTime => DateFormat('HH:mm', 'id_ID').format(_currentTime);
  String get formattedDate => DateFormat('EEEE, MMMM d, y').format(_currentTime);

  void _openRoomDetail({bool meetNow = false}) async {
    DateTime? meetNowDate;
    if (meetNow) meetNowDate = _currentTime;
    final result = await Navigator.push<Booking>(
      context,
      _noAnimationRoute(
        RoomDetailPage(
          roomName: widget.roomName,
          existingBookings: bookings,
          isMeetNow: meetNow,
          meetNowDate: meetNowDate,
        ),
      ),
    );

    if (result != null) {
      final saved = await bookingService.saveBooking(result);
      setState(() {
        bookings.add(saved);
        isScanEnabled = saved.isScanEnabled;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    _bookingSubscription.cancel();
    DeviceService.registerOrGetRoom().then((roomName) {
      DeviceService.setDeviceStatusByRoom(roomName, false);
    });
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // app kembali aktif → hidupkan device
      DeviceService.setDeviceStatusByRoom(widget.roomName, true);
    } else if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      // app keluar atau background → matikan device
      DeviceService.setDeviceStatusByRoom(widget.roomName, false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final current = currentMeeting;
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage("assets/mountain.png"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    isAvailable ? const Color(0xAA168757) : const Color(0xAAA80000),
                    BlendMode.srcOver,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formattedTime,
                              key: ValueKey<String>(formattedTime),
                              style: const TextStyle(
                                fontSize: 100,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              formattedDate,
                              key: ValueKey<String>(formattedDate),
                              style: const TextStyle(
                                fontSize: 30,
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            // Animated Available / Not Available
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: Stack(
                                key: ValueKey<String>(roomStatus),
                                children: [
                                  // Stroke
                                  Text(
                                    roomStatus,
                                    style: TextStyle(
                                      fontSize: 66,
                                      fontWeight: FontWeight.bold,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 6
                                        ..color = Colors.white,
                                    ),
                                  ),
                                  // Fill
                                  Text(
                                    roomStatus,
                                    style: TextStyle(
                                      fontSize: 66,
                                      fontWeight: FontWeight.bold,
                                      color: roomStatus == "AVAILABLE"
                                          ? Colors.green[900]
                                          : roomStatus == "WAITING FOR NEXT MEETING"
                                              ? const Color.fromARGB(255, 245, 197, 23)
                                              : Colors.red[900],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Card(
                                  key: _leftCardKey,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.roomName,
                                          style: const TextStyle(
                                              fontSize: 22, fontWeight: FontWeight.bold),),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Icon(Icons.people_alt, size: 20),
                                            const SizedBox(width: 6),
                                            Text("Capacity: ${roomCapacity ?? '-'} people"),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 20),
                                            const SizedBox(width: 6),
                                            Text(roomLocation ?? 'Loading...'),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        if (current != null)
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.red[100],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Current Event",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFFA80000),
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.close, color: Colors.red),
                                                      onPressed: () async {
                                                        final booking = currentMeeting;
                                                        if (booking == null) return;

                                                        final shouldEnd = await showDialog<bool>(
                                                          context: context,
                                                          builder: (context) => AlertDialog(
                                                            title: const Text("End Event"),
                                                            content: const Text("Are you sure to end this event early?"),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () => Navigator.pop(context, false),
                                                                child: const Text("Cancel"),
                                                              ),
                                                              TextButton(
                                                                onPressed: () => Navigator.pop(context, true),
                                                                child: const Text("End"),
                                                              ),
                                                            ],
                                                          ),
                                                        );

                                                        if (shouldEnd == true) {
                                                          try {
                                                            await bookingService.endBooking(int.parse(booking.id));
                                                            Fluttertoast.showToast(msg: "Event ended and moved to history");
                                                            setState(() {
                                                              bookings.remove(booking);
                                                            });
                                                          } catch (e) {
                                                            Fluttertoast.showToast(msg: "Failed to end booking");
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  current.meetingTitle,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  formatBookingTime(current.time, current.date, current.duration),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  "Booking by ${current.hostName}",
                                                  style: const TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                if (current.numberOfPeople != null)
                                                  Text("Attendees: ${current.numberOfPeople}"),
                                                const SizedBox(height: 10),
                                                if (current.equipment.isNotEmpty)
                                                  Wrap(
                                                    spacing: 8,
                                                    children: current.equipment.map((e) {
                                                      return Chip(label: Text(e));
                                                    }).toList(),
                                                  ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFF242424),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 30,),
                  Column(
                    children: [
                      const SizedBox(height: 30),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[800],
                        child: ClipOval(
                          child:
                          LogoWidget(
                            imageUrlOrBase64: logoUrlMain,
                            width: 70,
                            height: 70,
                            onTap: () async {
                              _logoTapCount++;
                              _tapResetTimer?.cancel();
                              _tapResetTimer = Timer(const Duration(seconds: 2), () {
                                _logoTapCount = 0;
                              });
                              if (_logoTapCount >= 10) {
                                _logoTapCount = 0;
                                _tapResetTimer?.cancel();
                                await _disableKioskMode();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("App unpinned")),
                                );
                              }
                            },
                          )
                        ),
                      ),
                      const SizedBox(height: 12),
                      LogoWidget(
                        imageUrlOrBase64: logoUrlSub,
                        width: 150,
                        height: 30,
                        onTap: () async {
                          _logoTapCount++;
                          _tapResetTimer?.cancel();
                          _tapResetTimer = Timer(const Duration(seconds: 2), () {
                            _logoTapCount = 0;
                          });
                          if (_logoTapCount >= 10) {
                            _logoTapCount = 0;
                            _tapResetTimer?.cancel();
                            await _disableKioskMode();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("App unpinned")),
                            );
                          }
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: buttonWidth,
                    child: ElevatedButton(
                      onPressed: (isAvailable && isMeetNowAllowed)
                          ? () => _openRoomDetail(meetNow: true)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (isAvailable && isMeetNowAllowed) ? Colors.white : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      child: Text(
                        "Meet Now",
                        style: TextStyle(
                          fontSize: 16,
                          color: (isAvailable && isMeetNowAllowed) ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: buttonWidth,
                    child: OutlinedButton(
                      onPressed: () => _openRoomDetail(meetNow: false),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Meet Later",
                        style: TextStyle(fontSize: 16, color: Colors.black,),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: buttonWidth,
                    child: ElevatedButton(
                      onPressed: (isScanEnabled && currentMeeting != null)
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ScanPage(booking: currentMeeting!)),
                        );
                      }
                          : null,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.disabled)) {
                            return Colors.transparent;
                          }
                          return Colors.white;
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.disabled)) {
                            return Colors.white;
                          }
                          return Colors.black;
                        }),
                        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Scan Me",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: const Color(0xFF242424),
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Booking List",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: _leftCardHeight,
                              ),
                              child: Builder(
                                builder: (context) {
                                  Map<String, List<Booking>> grouped = {};
                                  for (var b in bookings) {
                                    final dateStr = b.date.contains('T') ? b.date.split('T')[0] : b.date;
                                    grouped.putIfAbsent(dateStr, () => []).add(b);
                                  }
                                  final sortedKeys = grouped.keys.toList()
                                    ..sort((a, b) {
                                      try {
                                        return DateTime.parse(a).compareTo(DateTime.parse(b));
                                      } catch (_) {
                                        return 0; // fallback kalau parse gagal
                                      }
                                    });
                                  for (var key in grouped.keys) {
                                    grouped[key]!.sort((a, b) {
                                      // Parsing time dengan aman
                                      int parseHourMinute(String time, int defaultHour, int defaultMinute) {
                                        final parts = time.split(':');
                                        final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? defaultHour : defaultHour;
                                        final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? defaultMinute : defaultMinute;
                                        return hour * 60 + minute; // convert to minutes
                                      }

                                      final aMinutes = parseHourMinute(a.time, 0, 0);
                                      final bMinutes = parseHourMinute(b.time, 0, 0);

                                      return aMinutes.compareTo(bMinutes);
                                    });
                                  }
                                  return Scrollbar(
                                    thumbVisibility: true,
                                    thickness: 8,
                                    radius: const Radius.circular(12),
                                    child: ListView.builder(
                                      itemCount: sortedKeys.length,
                                      itemBuilder: (context, idx) {
                                        final dateKey = sortedKeys[idx];
                                        final list = grouped[dateKey]!;
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            dividerColor: Colors.transparent,
                                            unselectedWidgetColor: Colors.white,
                                            colorScheme: const ColorScheme.dark(
                                              primary: Colors.white,
                                            ),
                                          ),
                                          child: ExpansionTile(
                                            leading: ShaderMask(
                                              shaderCallback: (bounds) => const LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [Colors.red, Colors.white],
                                              ).createShader(bounds),
                                              child: const Icon(
                                                Icons.calendar_month,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                            title: Text(
                                              formatBookingDate(dateKey),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            children: list.map((b) {
                                              return Column(
                                                children: [
                                                  Card(
                                                    color: Colors.grey[300],
                                                    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                                                    child: ListTile(
                                                      title: Text("Host: ${b.hostName}",
                                                          style: const TextStyle(fontWeight: FontWeight.bold ,color: Colors.black),
                                                      ),
                                                      subtitle: Text(
                                                          formatBookingTime(b.time, b.date, b.duration),
                                                        style: const TextStyle(color: Colors.black),
                                                      ),
                                                      trailing: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            padding: const EdgeInsets.only(left: 40.0),
                                                            icon: const Icon(Icons.arrow_forward_ios, color: Colors.black54),
                                                            onPressed: () {
                                                              showDialog(
                                                                context: context,
                                                                builder: (context) => AlertDialog(
                                                                  title: const Text("Booking Detail"),
                                                                  content: SizedBox(
                                                                    width: 300,
                                                                    height: 220,
                                                                    child: Stack(
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets.all(16.0),
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text("Title: ${b.meetingTitle}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                                                              const SizedBox(height: 8),
                                                                              Text("Booking by: ${b.hostName}"),
                                                                              const SizedBox(height: 8),
                                                                              Text("Date: ${ b.date.split('T')[0]}"),
                                                                              Text("Time: ${formatBookingTime(b.time, b.date, b.duration)}"),
                                                                              if (b.numberOfPeople != null) Text("Attendees: ${b.numberOfPeople}"),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      children: [
                                                                        if (b.isScanEnabled)
                                                                          ElevatedButton.icon(
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                              Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(builder: (_) => ScanPage(booking: b)),
                                                                              );
                                                                            },
                                                                            icon: const Icon(Icons.qr_code),
                                                                            label: const Text("QR"),
                                                                          ),
                                                                        const SizedBox(width: 140),
                                                                        TextButton(
                                                                          onPressed: () => Navigator.pop(context),
                                                                          child: const Text("Close"),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}