import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const EarStockApp());
}

class EarStockApp extends StatelessWidget {
  const EarStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EarStock',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final TextEditingController stockController = TextEditingController();
  final TextEditingController lowController = TextEditingController();
  final TextEditingController highController = TextEditingController();

  List<Map<String, dynamic>> stockList = [];

  List<Map<String, dynamic>> alertLogs = [];

  Timer? autoRefreshTimer;
  bool isAutoRefreshOn = false;
  bool isAddFormOpen = false;
  bool isSettingOpen = false;
  bool isLogOpen = false;
  Set<String> loadingStocks = {};
  Map<String, Color> priceColors = {};
  Map<String, Timer> cooldownTimers = {};
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool pushEnabled = true;

  final String apiKey = '여기에_네_API_KEY_붙여넣기';
  // 실제 배포 시에는 API Key 분리 예정

  final AudioPlayer audioPlayer =
      AudioPlayer();

  final FlutterLocalNotificationsPlugin localNotifications =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    listenStocksRealtime();
    listenAlertLogsRealtime();
    setupFCM();
    setupLocalNotifications();
    //startAutoRefresh();
  }

  @override
  void dispose() {
    autoRefreshTimer?.cancel();

    for (final timer in cooldownTimers.values) {
      timer.cancel();
    }

    stockController.dispose();
    lowController.dispose();
    highController.dispose();
    audioPlayer.dispose();

    super.dispose();
  }

  Future<void> addStock() async {

    final stockName = stockController.text.trim();
    final lowText = lowController.text.trim();
    final highText = highController.text.trim();

    if (stockName.isEmpty || lowText.isEmpty || highText.isEmpty) {
      showMessage('모든 값을 입력해주세요.');
      return;
    }

    final lowPrice = int.tryParse(lowText);
    final highPrice = int.tryParse(highText);

    if (lowPrice == null || highPrice == null) {
      showMessage('가격은 숫자로 입력해주세요.');
      return;
    }

    if (lowPrice >= highPrice) {
      showMessage('하락 기준 가격은 상승 기준 가격보다 낮아야 합니다.');
      return;
    }

    final alreadyExists = stockList.any(
          (stock) =>
      stock['name'].toString().toUpperCase() ==
          stockName.toUpperCase(),
    );

    if (alreadyExists) {
      showMessage('이미 추가된 종목입니다.');
      return;
    }

    final docRef =
    await FirebaseFirestore.instance
        .collection('watch_stocks')
        .add({

      'name': stockName,
      'low': lowPrice,
      'high': highPrice,
      'currentPrice': 0,
      'status': '감시중',
      'lastAlertStatus': '',
      'updatedAt': '',
      'createdAt':
      FieldValue.serverTimestamp(),

    });

    setState(() {

      stockList.add({

        'id': docRef.id,
        'name': stockName,
        'low': lowPrice.toString(),
        'high': highPrice.toString(),
        'currentPrice': '0',
        'status': '감시중',
        'updatedAt': '',

      });

      stockController.clear();
      lowController.clear();
      highController.clear();

    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> setupFCM() async {
    final messaging = FirebaseMessaging.instance;

    final permission = await messaging.requestPermission();

    print('알림 권한 상태: ${permission.authorizationStatus}');

    final token = await messaging.getToken();

    print('FCM Token: $token');

    await messaging.subscribeToTopic(
      'earstock_test',
    );

    print('topic 구독 완료');

    //showMessage('FCM 토큰을 콘솔에 출력했습니다.');
  }

  Future<void> setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await localNotifications.initialize(initSettings);

    print('로컬 알림 초기화 완료');
  }

  Future<void> showLocalNotification(
      String title,
      String body,
      ) async {

    if (!pushEnabled) return;

    const androidDetails =
    AndroidNotificationDetails(

      'earstock_channel',

      'EarStock Alerts',

      importance:
      Importance.max,

      priority:
      Priority.high,
    );

    const details =
    NotificationDetails(
      android: androidDetails,
    );

    await localNotifications.show(
      0,
      title,
      body,
      details,
    );
  }

  String formatTime(String? dateTimeText) {
    if (dateTimeText == null || dateTimeText.isEmpty) {
      return '아직 없음';
    }

    final dateTime = DateTime.tryParse(dateTimeText);

    if (dateTime == null) {
      return '아직 없음';
    }

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second';
  }

  Future<void> loadStocks() async {

    final snapshot =
    await FirebaseFirestore.instance
        .collection('watch_stocks')
        .get();

    final loadedStocks =
    snapshot.docs.map((doc) {

      final data = doc.data();

      return {
        'id': doc.id,
        'name': data['name'],
        'low': data['low'].toString(),
        'high': data['high'].toString(),
        'currentPrice': data['currentPrice'].toString(),
        'status': data['status'],
        'updatedAt': data['updatedAt'] ?? '',
      };

    }).toList();

    setState(() {
      stockList = loadedStocks;
    });
  }

  void listenStocksRealtime() {

    FirebaseFirestore.instance
        .collection('watch_stocks')
        .snapshots()
        .listen((snapshot) {

      final loadedStocks =
        snapshot.docs.map((doc) {

        final data = doc.data();

        return {

          'id': doc.id,
          'name': data['name'],
          'low': data['low'].toString(),
          'high': data['high'].toString(),
          'currentPrice':
          data['currentPrice'].toString(),
          'status': data['status'],
          'updatedAt':
          data['updatedAt'] ?? '',
          'lastAlertStatus': data['lastAlertStatus'] ?? '',

        };

      }).toList();

      loadedStocks.sort((a, b) {

        int getPriority(String status) {

          if (status == '🚨 위험') return 0;

          if (status == '🎯 목표 도달') return 1;

          return 2;
        }

        return getPriority(a['status'])
            .compareTo(
            getPriority(b['status']));
      });

      setState(() {

        stockList = loadedStocks;

      });
    });
  }

  void listenAlertLogsRealtime() {
    FirebaseFirestore.instance
        .collection('alert_logs')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .listen((snapshot) {
      final loadedLogs = snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          'stockName': data['stockName'],
          'status': data['status'],
          'message': data['message'],
          'createdAt': data['createdAt'],
        };
      }).toList();

      setState(() {
        alertLogs = loadedLogs;
      });
    });
  }

  Future<double?> fetchStockPrice(String symbol) async {
    final cleanSymbol = symbol.trim().toUpperCase();

    final url = Uri.parse(
      'https://api.twelvedata.com/price?symbol=$cleanSymbol&apikey=$apiKey',
    );

    final response = await http.get(url);

    print('요청 심볼: $cleanSymbol');
    print('응답 코드: ${response.statusCode}');
    print('응답 내용: ${response.body}');

    if (response.statusCode != 200) {
      showMessage('주가 정보를 가져오지 못했습니다.');
      return null;
    }

    final data = jsonDecode(response.body);

    if (data['price'] == null) {
      showMessage('주가 데이터 없음: ${data['message'] ?? '종목명/API키 확인'}');
      return null;
    }

    return double.tryParse(data['price'].toString());
  }

  Future<void> playAlertSound(
      String status) async {

    if (!soundEnabled) return;

    if (status == '🚨 위험') {

      await audioPlayer.play(
        AssetSource(
          'sounds/warning.mp3',
        ),
      );

    }
    else if (status == '🎯 목표 도달') {

      await audioPlayer.play(
        AssetSource(
          'sounds/success.mp3',
        ),
      );
    }
  }

  Future<void> playVibration(String status) async {

    if (!vibrationEnabled) return;

    if (status == '🚨 위험') {
      await HapticFeedback.heavyImpact();
    } else if (status == '🎯 목표 도달') {
      await HapticFeedback.lightImpact();
    }
  }

  Future<void> saveAlertLog(
      String stockName,
      String status,
      ) async {
    await FirebaseFirestore.instance
        .collection('alert_logs')
        .add({
      'stockName': stockName,
      'status': status,
      'message': '$stockName $status 상태입니다.',
      'createdAt': DateTime.now().toString(),
    });
  }

  Future<void> clearAlertLogs() async {

    final snapshot =
    await FirebaseFirestore.instance
        .collection('alert_logs')
        .get();

    for (var doc in snapshot.docs) {

      await FirebaseFirestore.instance
          .collection('alert_logs')
          .doc(doc.id)
          .delete();
    }

    showMessage('알림 기록을 삭제했습니다.');
  }

  void startAutoRefresh() {

    autoRefreshTimer =
        Timer.periodic(
            const Duration(minutes: 3),

                (timer) async {

                  print('3분 자동 감시 타이머 실행됨: ${DateTime.now()}');

                  for (int i = 0;
                  i < stockList.length;
                  i++) {

                  final stock = stockList[i];

                  final stockId =
                  stock['id'];

                  if (stockId == null) {
                    continue;
                  }

                  final fetchedPrice =
                  await fetchStockPrice(
                      stock['name']);

                  if (fetchedPrice == null) {
                    continue;
                  }

                  final currentPrice =
                  fetchedPrice.toInt();

                  final previousStatus = stock['status'];

                  final previousPrice =
                      double.tryParse(
                        stock['currentPrice']
                            .toString(),
                      ) ?? 0;

                  String status = '감시중';

                  final lowPrice =
                  int.parse(stock['low']);

                  final highPrice =
                  int.parse(stock['high']);

                  if (currentPrice <= lowPrice) {

                    status = '🚨 위험';

                  }
                  else if (currentPrice >= highPrice) {

                    status = '🎯 목표 도달';

                  }

                  final updatedAt = DateTime.now().toString();

                  await FirebaseFirestore
                      .instance
                      .collection(
                      'watch_stocks')
                      .doc(stockId)
                      .update({

                    'currentPrice':
                    currentPrice,

                    'status': status,

                    'updatedAt': updatedAt,

                  });

                  setState(() {
                    stockList[i]['currentPrice'] = currentPrice.toString();
                    stockList[i]['status'] = status;
                    stockList[i]['updatedAt'] = updatedAt;
                  });

                  final latestAlertDoc =
                  await FirebaseFirestore.instance
                      .collection('watch_stocks')
                      .doc(stockId)
                      .get();

                  final latestAlertData =
                  latestAlertDoc.data();

                  final lastAlertStatus =
                      latestAlertData?['lastAlertStatus'] ?? '';

                  if (status != '감시중' &&
                      lastAlertStatus != status &&
                      cooldownTimers[stockId] == null) {

                    cooldownTimers[stockId] =
                        Timer(
                          const Duration(seconds: 3),
                              () async {

                            final latestDoc =
                            await FirebaseFirestore.instance
                                .collection('watch_stocks')
                                .doc(stockId)
                                .get();

                            final latestData =
                            latestDoc.data();

                            if (latestData == null) {
                              return;
                            }

                            final latestStatus =
                            latestData['status'];

                            if (latestStatus == status) {

                              showMessage(
                                '${stock['name']} $status 상태입니다.',
                              );

                              await playAlertSound(status);

                              await playVibration(status);

                              await showLocalNotification(
                                stock['name'],
                                '$status 상태입니다.',
                              );

                              await saveAlertLog(
                                stock['name'],
                                status,
                              );

                              await FirebaseFirestore.instance
                                  .collection('watch_stocks')
                                  .doc(stockId)
                                  .update({

                                'lastAlertStatus': status,
                              });
                            }

                            cooldownTimers.remove(stockId);
                          },
                        );
                }

                if (status == '감시중' &&
                    lastAlertStatus != '') {

                  await FirebaseFirestore.instance
                      .collection('watch_stocks')
                      .doc(stockId)
                      .update({

                    'lastAlertStatus': '',
                  });
                }
              }
            });
  }

  Future<bool> confirmAutoRefreshStart() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('자동 감시를 시작할까요?'),
          content: const Text(
            '자동 감시를 시작하면 3분마다 모든 종목의 주가를 가져옵니다.\n\n'
                'API 사용량이 증가할 수 있습니다.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('시작'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> toggleAutoRefresh() async {
    if (isAutoRefreshOn) {
      autoRefreshTimer?.cancel();

      setState(() {
        isAutoRefreshOn = false;
      });

      showMessage('자동 감시를 중지했습니다.');
    } else {
      final shouldStart = await confirmAutoRefreshStart();

      if (!shouldStart) {
        return;
      }

      for (int i = 0; i < stockList.length; i++) {

        final stock = stockList[i];

        final fetchedPrice =
        await fetchStockPrice(stock['name']);

        if (fetchedPrice == null) continue;

        final currentPrice =
        fetchedPrice.toInt();

        String status = '감시중';

        final lowPrice =
        int.parse(stock['low']);

        final highPrice =
        int.parse(stock['high']);

        if (currentPrice <= lowPrice) {
          status = '🚨 위험';
        }
        else if (currentPrice >= highPrice) {
          status = '🎯 목표 도달';
        }

        await FirebaseFirestore.instance
            .collection('watch_stocks')
            .doc(stock['id'])
            .update({

          'currentPrice': currentPrice,
          'status': status,
          'updatedAt': DateTime.now().toString(),
        });

        final lastAlertStatus =
            stock['lastAlertStatus'] ?? '';

        if (status != '감시중' &&
            lastAlertStatus != status) {

          showMessage('${stock['name']} $status 상태입니다.');

          await playAlertSound(status);

          await playVibration(status);

          await showLocalNotification(
            stock['name'],
            '$status 상태입니다.',
          );

          await saveAlertLog(
            stock['name'],
            status,
          );

          await FirebaseFirestore.instance
              .collection('watch_stocks')
              .doc(stock['id'])
              .update({
            'lastAlertStatus': status,
          });
        }
      }

      startAutoRefresh();

      setState(() {
        isAutoRefreshOn = true;
      });

      showMessage('자동 감시를 시작했습니다.');
    }
  }

  Future<void> editStock(
      Map<String, dynamic> stock) async {

    final lowController =
    TextEditingController(
      text: stock['low'],
    );

    final highController =
    TextEditingController(
      text: stock['high'],
    );

    final result =
    await showDialog<bool>(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: Text(
            '${stock['name']} 수정',
          ),

          content: Column(
            mainAxisSize:
            MainAxisSize.min,

            children: [

              TextField(
                controller:
                lowController,

                keyboardType:
                TextInputType.number,

                decoration:
                const InputDecoration(
                  labelText:
                  '하락 기준 가격',
                ),
              ),

              const SizedBox(
                  height: 12),

              TextField(
                controller:
                highController,

                keyboardType:
                TextInputType.number,

                decoration:
                const InputDecoration(
                  labelText:
                  '상승 기준 가격',
                ),
              ),
            ],
          ),

          actions: [

            TextButton(
              onPressed: () {

                Navigator.pop(
                    context,
                    false);
              },
              child:
              const Text('취소'),
            ),

            ElevatedButton(
              onPressed: () {

                Navigator.pop(
                    context,
                    true);
              },
              child:
              const Text('저장'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final lowPrice =
    int.tryParse(
        lowController.text);

    final highPrice =
    int.tryParse(
        highController.text);

    if (lowPrice == null ||
        highPrice == null) {

      showMessage(
          '숫자를 입력해주세요.');
      return;
    }

    if (lowPrice >= highPrice) {

      showMessage(
        '하락 기준 가격은 상승 기준 가격보다 낮아야 합니다.',
      );

      return;
    }

    await FirebaseFirestore
        .instance
        .collection(
        'watch_stocks')
        .doc(stock['id'])
        .update({

      'low': lowPrice,
      'high': highPrice,

    });

    showMessage(
        '감시 기준이 수정되었습니다.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        title: const Text('📈 EarStock'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    isAddFormOpen = !isAddFormOpen;
                  });
                },
                child: Text(
                  isAddFormOpen
                      ? '입력창 닫기'
                      : '+ 감시 종목 추가',
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (isAddFormOpen) ...[

              TextField(
                controller: stockController,
                decoration: const InputDecoration(
                  labelText:
                  '미국 주식 심볼 예: AAPL, TSLA',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: lowController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '하락 기준 가격',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: highController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '상승 기준 가격',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: addStock,
                  child: const Text('감시 시작'),
                ),
              ),

              const SizedBox(height: 12),
            ],

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAutoRefreshOn
                      ? Colors.red.withOpacity(0.7)
                      : null,
                ),
                onPressed: toggleAutoRefresh,
                child: Text(
                  isAutoRefreshOn ? '자동 감시 중지' : '자동 감시 시작',
                ),
              ),
            ),

            const SizedBox(height: 24),

            InkWell(
              onTap: () {
                setState(() {
                  isSettingOpen = !isSettingOpen;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '알림 설정',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    isSettingOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            if (isSettingOpen)
              Card(
                color: const Color(0xFF1A1A1F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      value: soundEnabled,
                      onChanged: (value) {
                        setState(() {
                          soundEnabled = value;
                        });
                      },
                      title: const Text('소리 알림'),
                    ),

                    SwitchListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      value: vibrationEnabled,
                      onChanged: (value) {
                        setState(() {
                          vibrationEnabled = value;
                        });
                      },
                      title: const Text('진동 알림'),
                    ),

                  SwitchListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    value: pushEnabled,
                    onChanged: (value) {
                      setState(() {
                        pushEnabled = value;
                      });
                    },
                    title: const Text('푸시 알림'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '감시 목록',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: stockList.isEmpty
                  ? const Center(
                child: Text(
                  '아직 감시 중인 종목이 없습니다.\nAAPL, TSLA 같은 미국 주식 심볼을 추가해보세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: stockList.length,

                itemBuilder: (context, index) {

                  final stock = stockList[index];

                  final stockId = stock['id'];

                  Color cardColor = const Color(0xFF1E1E1E);

                  if (stock['status'] == '🚨 위험') {

                    cardColor = Colors.red.withOpacity(0.25);

                  }
                  else if (stock['status'] == '🎯 목표 도달') {

                    cardColor = Colors.green.withOpacity(0.25);

                  }

                  return Card(
                      margin: const EdgeInsets.only(bottom: 12),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),

                      color: cardColor,

                      child: Padding(
                        padding: const EdgeInsets.all(8),

                        child: ListTile(

                      onTap: () {
                        editStock(stock);
                      },
                      title: Text(stock['name']!),

                      subtitle: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          const SizedBox(height: 6),

                          Text(
                            '\$${stock['currentPrice']}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color:
                              priceColors[stockId] ??
                                  Colors.white,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            crossAxisAlignment:
                                WrapCrossAlignment.center,
                            children: [

                              Container(
                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),

                                decoration: BoxDecoration(
                                  color:
                                  stock['status'] == '🚨 위험'
                                      ? Colors.red
                                      .withOpacity(0.25)
                                      : stock['status'] ==
                                      '🎯 목표 도달'
                                      ? Colors.green
                                      .withOpacity(0.25)
                                      : Colors.grey
                                      .withOpacity(0.2),

                                  borderRadius:
                                  BorderRadius.circular(20),
                                ),

                                child: Text(
                                  stock['status'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Text(
                                '하락 ${stock['low']} | 상승 ${stock['high']}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            '마지막 갱신 ${formatTime(stock['updatedAt'])}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          IconButton(
                            icon: loadingStocks.contains(stockId)
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(Icons.refresh),

                            onPressed: () async {

                              if (stockId == null) return;

                              setState(() {
                                loadingStocks.add(stockId);
                              });

                              final fetchedPrice = await fetchStockPrice(stock['name']);

                              if (fetchedPrice == null) return;

                              final mockPrice = fetchedPrice.toInt();

                              final previousStatus = stock['status'];

                              final previousPrice =
                                  double.tryParse(
                                    stock['currentPrice'].toString(),
                                  ) ?? 0;

                              String status = '감시중';

                              final lowPrice =
                              int.parse(stock['low']);

                              final highPrice =
                              int.parse(stock['high']);

                              if (mockPrice <= lowPrice) {

                                status = '🚨 위험';

                              }
                              else if (mockPrice >= highPrice) {

                                status = '🎯 목표 도달';

                              }

                              await FirebaseFirestore.instance
                                  .collection('watch_stocks')
                                  .doc(stockId)
                                  .update({

                                'currentPrice': mockPrice,
                                'status': status,
                                'updatedAt': DateTime.now().toString(),
                              });

                              setState(() {

                                stockList[index]['currentPrice'] =
                                    mockPrice.toString();

                                stockList[index]['status'] = status;

                                stockList[index]['updatedAt'] =
                                    DateTime.now().toString();

                                if (mockPrice > previousPrice) {
                                  priceColors[stockId] =
                                      Colors.greenAccent;
                                } else if (mockPrice < previousPrice) {
                                  priceColors[stockId] =
                                      Colors.redAccent;
                                } else {
                                  priceColors[stockId] =
                                      Colors.white;
                                }
                              });

                              final lastAlertStatus = stock['lastAlertStatus'] ?? '';

                              if (status != '감시중' &&
                                  lastAlertStatus != status &&
                                  cooldownTimers[stockId] == null) {

                                cooldownTimers[stockId] =
                                    Timer(
                                      const Duration(seconds: 3),
                                          () async {

                                        final latestDoc =
                                        await FirebaseFirestore.instance
                                            .collection('watch_stocks')
                                            .doc(stockId)
                                            .get();

                                        final latestData =
                                        latestDoc.data();

                                        if (latestData == null) {
                                          return;
                                        }

                                        final latestStatus =
                                        latestData['status'];

                                        if (latestStatus == status) {

                                          showMessage(
                                            '${stock['name']} $status 상태입니다.',
                                          );

                                          await playAlertSound(status);

                                          await playVibration(status);

                                          await showLocalNotification(
                                            stock['name'],
                                            '$status 상태입니다.',
                                          );

                                          await saveAlertLog(
                                            stock['name'],
                                            status,
                                          );

                                          await FirebaseFirestore.instance
                                              .collection('watch_stocks')
                                              .doc(stockId)
                                              .update({

                                            'lastAlertStatus': status,
                                          });
                                        }

                                        cooldownTimers.remove(stockId);
                                      },
                                    );
                              }

                              if (status == '감시중' && lastAlertStatus != '') {
                                await FirebaseFirestore.instance
                                    .collection('watch_stocks')
                                    .doc(stockId)
                                    .update({
                                  'lastAlertStatus': '',
                                });
                              }

                              setState(() {
                                loadingStocks.remove(stockId);
                              });
                            },
                          ),

                          IconButton(
                            icon: const Icon(Icons.delete),

                            onPressed: () async {

                              final stockId = stock['id'];

                              if (stockId != null) {

                                await FirebaseFirestore.instance
                                    .collection('watch_stocks')
                                    .doc(stockId)
                                    .delete();
                              }

                              setState(() {

                                stockList.removeAt(index);

                              });
                            },
                          ),
                        ],
                      ),
                    ),
                      ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: () {
                setState(() {
                  isLogOpen = !isLogOpen;
                });
              },

              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [

                  const Text(
                    '최근 알림',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    children: [

                      TextButton(
                        onPressed: clearAlertLogs,
                        child: const Text('전체 삭제'),
                      ),

                      Icon(
                        isLogOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,

                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            if (isLogOpen)
              SizedBox(
                height: 120,
                child: alertLogs.isEmpty
                    ? const Center(
                  child: Text(
                    '아직 알림 기록이 없습니다.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: alertLogs.length,
                  itemBuilder: (context, index) {
                    final log = alertLogs[index];

                    return ListTile(
                      dense: true,
                      title: Text(
                        log['message'],
                      ),
                      subtitle: Text(
                        formatTime(log['createdAt']),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}