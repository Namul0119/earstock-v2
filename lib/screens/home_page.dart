import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../services/stock_api.dart';
import '../services/watch_api.dart';
import '../services/settings_service.dart';
import '../services/vibration_service.dart';
import '../services/sound_service.dart';
import '../services/alert_data_service.dart';
import '../services/stock_data_service.dart';
import '../services/fcm_registration_service.dart';

import '../widgets/stock_card.dart';
import '../widgets/add_stock_form.dart';
import '../widgets/notification_setting_card.dart';
import '../widgets/earstock_message_overlay.dart';

import '../dialogs/delete_stock_dialog.dart';
import '../dialogs/warning_sound_picker.dart';
import '../dialogs/success_sound_picker.dart';
import '../dialogs/edit_stock_dialog.dart';

import '../utils/format_utils.dart';
import '../utils/market_utils.dart';
import '../utils/sound_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  static const String currentUserId = "namul";

  static const backgroundColor = Color(0xff151329);

  static const panelColor = Color(0xff211E3A);

  static const accentColor = Color(0xff00F5C8);

  static const dangerColor = Color(0xffFF5C7A);

  static const successColor = Color(0xff00F5A0);

  final TextEditingController stockController = TextEditingController();
  final TextEditingController lowController = TextEditingController();
  final TextEditingController highController = TextEditingController();

  List<Map<String, dynamic>> stockList = [];

  List<Map<String, dynamic>> alertLogs = [];

  List<Map<String, dynamic>> stockSearchResults = [];

  String? selectedStockCode;
  String? selectedStockName;

  bool isStockSearching = false;
  bool isStockSearchOpen = false;

  Timer? stockSearchDebounceTimer;

  bool isAddFormOpen = false;
  bool isSettingOpen = false;
  bool isLogOpen = false;

  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool pushEnabled = true;

  String selectedWarningSound = 'sounds/warning_01.mp3';
  String selectedSuccessSound = 'sounds/success_01.mp3';
  
  Timer? stockRefreshTimer;
  OverlayEntry? messageOverlay;
  Timer? messageOverlayTimer;

  Timer? soundStopTimer;
  int refreshRemainingSeconds = 30;

  final AudioPlayer audioPlayer =
      AudioPlayer();

  @override
  void initState() {
    super.initState();

    loadSettings();

    loadStocksFromSpring();
    loadAlertsFromSpring();

    startStockAutoRefresh();
    //startAlertPolling();

    if (!kIsWeb) {
      setupFCM();
    }
  }

  Future<void> loadSettings() async {
    try {
      final loadedSoundEnabled =
          await SettingsService.loadSoundEnabled();

      final loadedVibrationEnabled =
          await SettingsService.loadVibrationEnabled();

      final loadedPushEnabled =
          await SettingsService.loadPushEnabled();

      final loadedWarningSound =
          await SettingsService.loadWarningSound();

      final loadedSuccessSound =
          await SettingsService.loadSuccessSound();

      if (!mounted) return;

      setState(() {
        soundEnabled = loadedSoundEnabled;
        vibrationEnabled = loadedVibrationEnabled;
        pushEnabled = loadedPushEnabled;

        selectedWarningSound =
            loadedWarningSound;

        selectedSuccessSound =
            loadedSuccessSound;
      });

      print('설정 불러오기 완료');
    } catch (e) {
      print('설정 불러오기 실패: $e');
    }
  }

  void onStockSearchChanged(String value) {
    selectedStockCode = null;
    selectedStockName = null;

    stockSearchDebounceTimer?.cancel();

    final keyword = value.trim();

    if (keyword.isEmpty) {
      setState(() {
        stockSearchResults = [];
        isStockSearchOpen = false;
        isStockSearching = false;
      });

      return;
    }

    setState(() {
      isStockSearching = true;
      isStockSearchOpen = true;
    });

    stockSearchDebounceTimer = Timer(
      const Duration(milliseconds: 350),
      () async {
        try {
          final results =
              await StockApi.searchStocks(keyword);

          if (!mounted) return;

          if (stockController.text.trim() != keyword) {
            return;
          }

          setState(() {
            stockSearchResults = results;
            isStockSearching = false;
            isStockSearchOpen = true;
          });
        } catch (e) {
          if (!mounted) return;

          setState(() {
            stockSearchResults = [];
            isStockSearching = false;
            isStockSearchOpen = true;
          });

          print('종목 검색 실패: $e');
        }
      },
    );
  }

  void selectStock(
    Map<String, dynamic> stock,
  ) {
    final code =
        stock['stockCode']?.toString() ?? '';

    final name =
        stock['stockName']?.toString() ?? '';

    if (code.isEmpty || name.isEmpty) {
      return;
    }

    setState(() {
      selectedStockCode = code;
      selectedStockName = name;

      stockController.text = name;

      stockController.selection =
          TextSelection.collapsed(
        offset: stockController.text.length,
      );

      stockSearchResults = [];
      isStockSearchOpen = false;
      isStockSearching = false;
    });

    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    
    stockRefreshTimer?.cancel();

    stockSearchDebounceTimer?.cancel();

    messageOverlayTimer?.cancel();
    soundStopTimer?.cancel();
    soundStopTimer = null;
    messageOverlay?.remove();
    messageOverlay = null;

    stockController.dispose();
    lowController.dispose();
    highController.dispose();
    audioPlayer.dispose();

    super.dispose();
  }

  Future<void> addStock() async {
    final lowText = lowController.text.trim();
    final highText = highController.text.trim();

    if (selectedStockCode == null ||
        selectedStockName == null) {
      showMessage('검색 결과에서 종목을 선택해주세요.');
      return;
    }

    if (lowText.isEmpty || highText.isEmpty) {
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
      showMessage(
        '하락 기준 가격은 상승 기준 가격보다 낮아야 합니다.',
      );
      return;
    }

    final stockCode = selectedStockCode!;

    final alreadyExists = stockList.any(
      (stock) =>
          stock['stockCode'].toString() ==
          stockCode,
    );

    if (alreadyExists) {
      showMessage('이미 추가된 종목입니다.');
      return;
    }

    try {
      await WatchApi.addWatch(
        userId: currentUserId,
        stockCode: stockCode,
        lowPrice: lowPrice,
        highPrice: highPrice,
      );

      await loadStocksFromSpring();
      await loadAlertsFromSpring();

      if (!mounted) return;

      setState(() {
        stockController.clear();
        lowController.clear();
        highController.clear();

        selectedStockCode = null;
        selectedStockName = null;

        stockSearchResults = [];
        isStockSearchOpen = false;
        isStockSearching = false;

        isAddFormOpen = false;
      });

      showMessage('감시 종목이 등록되었습니다.');
    } catch (e) {
      showMessage('등록 실패: $e');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    messageOverlayTimer?.cancel();
    messageOverlay?.remove();
    messageOverlay = null;

    final overlay = Overlay.of(context);

    final isHigh = message.contains('HIGH');
    final isAlertMessage =
        message.contains('LOW') || message.contains('HIGH');

    String titleText;
    String badgeText;
    Color badgeColor;
    Color badgeBackground;

    if (isAlertMessage) {
      final parts = message.split(' ');
      titleText = parts.isNotEmpty ? parts.first : 'EarStock';

      badgeText = isHigh ? '목표 도달' : '위험';
      badgeColor = isHigh
          ? const Color(0xff006B4F)
          : const Color(0xffB3263A);
      badgeBackground = isHigh
          ? successColor.withOpacity(0.18)
          : dangerColor.withOpacity(0.18);
    } else {
      titleText = message;
      badgeText = '안내';
      badgeColor = const Color(0xff55506A);
      badgeBackground = Colors.grey.withOpacity(0.15);
    }

     messageOverlay = OverlayEntry(
      builder: (overlayContext) {
        return EarStockMessageOverlay(
          isAlertMessage: isAlertMessage,
          titleText: titleText,
          badgeText: badgeText,
          badgeColor: badgeColor,
          badgeBackground: badgeBackground,
          accentColor: accentColor,
          onConfirm: hideMessageOverlay,
        );
      },
    );

    overlay.insert(messageOverlay!);

    messageOverlayTimer = Timer(
      const Duration(seconds: 3),
      hideMessageOverlay,
    );
  }

  void hideMessageOverlay() async {

    soundStopTimer?.cancel();
    soundStopTimer = null;

    await audioPlayer.stop();

    await audioPlayer.setReleaseMode(
      ReleaseMode.release,
    );

    messageOverlayTimer?.cancel();
    messageOverlayTimer = null;

    messageOverlay?.remove();
    messageOverlay = null;
  }

  Future<void> setupFCM() async {
    await FcmRegistrationService.initialize(
      currentUserId,
    );

    //showMessage('FCM 토큰을 콘솔에 출력했습니다.');

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {

        print('포그라운드 FCM 수신');
        print('FCM 데이터: ${message.data}');

        final pushEnabled =
          await SettingsService.loadPushEnabled();

        final alertType =
            message.data['alertType']?.toString() ?? 'HIGH';

        final title =
            message.data['title']?.toString() ?? 'EarStock';

        // ① 시스템 푸시
        if (pushEnabled) {
          await NotificationService.showFromFcmData(
            message.data,
          );
        }

        // ② 앱 내부 소리
        await playAlertSound(alertType);

        // ③ 앱 내부 진동
        await playVibration(alertType);

        // ④ 앱 내부 팝업
        showMessage('$title $alertType');

        await loadAlertsFromSpring();
      },
    );
  }

  Future<void> loadStocksFromSpring() async {
    try {

      final loadedStocks =
          await StockDataService.loadStocks();

      if (!mounted) {
        return;
      }

      setState(() { 
        stockList = loadedStocks;
      });

    } catch (e) {

      print(e);

    }
  }

  void startStockAutoRefresh() {
    refreshRemainingSeconds = 30;

    stockRefreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        if (refreshRemainingSeconds > 1) {
          setState(() {
            refreshRemainingSeconds--;
          });
          return;
        }

        setState(() {
          refreshRemainingSeconds = 0;
        });

        await loadStocksFromSpring();

        if (!mounted) return;

        setState(() {
          refreshRemainingSeconds = 30;
        });
      },
    );
  }

  Future<void> loadAlertsFromSpring() async {
    try {
      final loadedAlertLogs =
          await AlertDataService.loadAlertLogs(
        currentUserId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        alertLogs = loadedAlertLogs;
      });
    } catch (e) {
      print('최근 알림 조회 실패: $e');
    }
  }

  Future<void> playAlertSound(
    String status,
  ) async {

    soundStopTimer =
        await SoundService.play(

      audioPlayer: audioPlayer,

      soundEnabled: soundEnabled,

      status: status,

      warningSound: selectedWarningSound,

      successSound: selectedSuccessSound,

      soundStopTimer: soundStopTimer,
    );
  }

  Future<void> showWarningSoundPicker() async {
    await showWarningSoundPickerSheet(
      context: context,
      panelColor: panelColor,
      dangerColor: dangerColor,
      selectedWarningSound: selectedWarningSound,

      onSoundSelected: (selectedSound) async {
        setState(() {
          selectedWarningSound = selectedSound;
        });

        await SettingsService.saveWarningSound(
          selectedSound,
        );
      },

      onPreviewSound: () async {
        await playAlertSound('LOW');
      },
    );
  }

  Future<void> showSuccessSoundPicker() async {
    await showSuccessSoundPickerSheet(
      context: context,
      panelColor: panelColor,
      successColor: successColor,
      selectedSuccessSound: selectedSuccessSound,

      onSoundSelected: (selectedSound) async {
        setState(() {
          selectedSuccessSound = selectedSound;
        });

        await SettingsService.saveSuccessSound(
          selectedSound,
        );
      },

      onPreviewSound: () async {
        await playAlertSound('HIGH');
      },
    );
  }

  Future<void> playVibration(
    String status,
  ) async {
    await VibrationService.play(
      status: status,
      vibrationEnabled: vibrationEnabled,
    );
  }

  Future<void> clearAlertLogs() async {
    try {
      await AlertDataService.clearAlertLogs(
        currentUserId,
      );

      await loadAlertsFromSpring();

      showMessage(
        '알림 기록을 모두 삭제했습니다.',
      );
    } catch (e) {
      showMessage('삭제 실패');
    }
  }

  Future<void> editStock(
    Map<String, dynamic> stock,
  ) async {
    final result = await showEditStockDialog(
      context: context,
      stock: stock,
    );

    if (result == null) {
      return;
    }

    final lowPrice = int.tryParse(
      result.lowPriceText,
    );

    final highPrice = int.tryParse(
      result.highPriceText,
    );

    if (lowPrice == null ||
        highPrice == null) {
      showMessage('숫자를 입력해주세요.');
      return;
    }

    if (lowPrice >= highPrice) {
      showMessage(
        '하락 기준 가격은 상승 기준 가격보다 낮아야 합니다.',
      );

      return;
    }

    try {
      await WatchApi.updateWatch(
        id: stock['id'].toString(),
        lowPrice: lowPrice,
        highPrice: highPrice,
      );

      await loadStocksFromSpring();

      showMessage(
        '감시 기준이 수정되었습니다.',
      );
    } catch (e) {
      showMessage(
        '감시 기준 수정에 실패했습니다.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "EarStock",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView(
          children: [

            Container(
              width: double.infinity,
              height: 56,

              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(20),

                gradient: const LinearGradient(

                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                  colors: [
                    Color(0xff00E6C0),
                    Color(0xff00D6C8),
                  ],
                ),

                boxShadow: [

                  BoxShadow(

                    color: accentColor.withOpacity(0.16),
                    blurRadius: 14,
                    spreadRadius: 0,

                    offset: Offset(0,8),
                  ),
                ],
              ),

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.transparent,

                  shadowColor: Colors.transparent,

                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(20),

                  ),
                ),

                onPressed: () {

                  setState(() {

                    isAddFormOpen = !isAddFormOpen;

                  });

                },

                child: Text(

                  isAddFormOpen
                      ? "입력창 닫기"
                      : "+ 감시 종목 추가",

                  style: const TextStyle(

                    fontSize: 16,

                    fontWeight: FontWeight.bold,

                    color: Colors.white,

                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (isAddFormOpen) ...[
              AddStockForm(
                stockController: stockController,
                lowController: lowController,
                highController: highController,

                panelColor: panelColor,
                accentColor: accentColor,

                onClearSearch: () {
                  setState(() {
                    stockController.clear();

                    selectedStockCode = null;
                    selectedStockName = null;

                    stockSearchResults = [];
                    isStockSearchOpen = false;
                    isStockSearching = false;
                  });
                },

                onStockSearchChanged: onStockSearchChanged,

                onSelectStock: selectStock,

                isStockSearchOpen: isStockSearchOpen,
                isStockSearching: isStockSearching,
                stockSearchResults: stockSearchResults,
                onAddStock: addStock,
              ),
            ],

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: panelColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: getMarketStatusColor(),
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    getMarketStatusText(),
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: accentColor,
                    size: 20,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            NotificationSettingCard(
              isSettingOpen: isSettingOpen,
              panelColor: panelColor,
              soundEnabled: soundEnabled,
              accentColor: accentColor,
              warningSoundName: getWarningSoundName(
                selectedWarningSound,
              ),
              onWarningSoundTap: showWarningSoundPicker,
              successSoundName: getSuccessSoundName(
                selectedSuccessSound,
              ),
              onSuccessSoundTap: showSuccessSoundPicker,

              vibrationEnabled: vibrationEnabled,

              onVibrationChanged: (value) async {
                setState(() {
                  vibrationEnabled = value;
                });

                await SettingsService.saveVibrationEnabled(value);
              },

              pushEnabled: pushEnabled,

              onPushChanged: (value) async {
                setState(() {
                  pushEnabled = value;
                });

                await SettingsService.savePushEnabled(value);
              },

              onSoundChanged: (value) async {
                setState(() {
                  soundEnabled = value;
                });

                await SettingsService.saveSoundEnabled(value);

                if (!value) {
                  soundStopTimer?.cancel();
                  soundStopTimer = null;

                  await SoundService.stop(
                    audioPlayer,
                  );
                }
              },

              onWarningTestTap: () async {
                await playAlertSound('LOW');
                await playVibration('LOW');
              },

              onSuccessTestTap: () async {
                await playAlertSound('HIGH');
                await playVibration('HIGH');
              },
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

            stockList.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Text(
                        '아직 감시 중인 종목이 없습니다.\n감시할 국내 주식 종목을 추가해보세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                      ),
                    ),
                  ),
                ) 
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stockList.length,
                  itemBuilder: (context, index) {
                    final stock = stockList[index];

                    return StockCard(
                      stock: stock,
                      refreshRemainingSeconds: refreshRemainingSeconds,
                      formatPrice: formatPrice,
                      onEdit: () async {
                        await editStock(stock);
                      },
                      onDelete: () async {
                        final stockId = stock['id'];

                        if (stockId == null) return;

                        final shouldDelete =
                            await showDeleteStockDialog(
                          context: context,
                          stock: stock,
                          dangerColor: dangerColor,
                        );

                        if (!shouldDelete) {
                          return;
                        }

                        try {
                          await WatchApi.deleteWatch(
                            stockId.toString(),
                          );

                          await loadStocksFromSpring();

                          showMessage(
                            '감시 종목을 삭제했습니다.',
                          );
                        } catch (e) {
                          showMessage(
                            '종목 삭제에 실패했습니다.',
                          );
                        }
                      },
                    );
                  },
                ),
            const SizedBox(height: 8),

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
                        child: const Text(
                          '전체 삭제',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      Icon(
                        isLogOpen
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: accentColor,
                        size: 20,
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

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),

                      decoration: BoxDecoration(
                        color: panelColor,
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: ListTile(
                        dense: true,

                        leading: Container(
                          width: 36,
                          height: 36,

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Icon(

                            log['status'] == '🎯 목표 도달'
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,

                            color: log['status'] == '🎯 목표 도달'
                                ? const Color(0xff00F5C8)
                                : const Color(0xff78FFD9),

                            size: 22,
                          ),
                        ),

                        title: Row(
                          children: [            

                            Text(
                              log['stockName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: log['status'] == '🎯 목표 도달'
                                    ? successColor.withOpacity(0.18)
                                    : dangerColor.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                log['status'] == '🎯 목표 도달'
                                    ? '목표 도달'
                                    : '위험',
                                style: TextStyle(
                                  color: log['status'] == '🎯 목표 도달'
                                      ? successColor
                                      : dangerColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        subtitle: Text(
                          formatTime(log['createdAt']),
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
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