import 'package:flutter/material.dart';

import '../config/api_service.dart';
import '../services/auth_service.dart';
import '../services/fcm_registration_service.dart';
import 'login_page.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState
    extends State<AccountSettingsPage> {
  static const backgroundColor = Color(0xff151329);
  static const panelColor = Color(0xff211E3A);
  static const accentColor = Color(0xff00F5C8);
  static const dangerColor = Color(0xffFF5C7A);

  late final AuthService authService;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    authService = AuthService(
      baseUrl: ApiService.baseUrl,
    );
  }

  Future<void> showChangeLoginIdDialog() async {
    final currentPasswordController =
        TextEditingController();

    final newLoginIdController =
        TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: panelColor,
          title: const Text(
            '아이디 변경',
          ),
          content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              TextField(
                controller:
                    currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '현재 비밀번호',
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller:
                    newLoginIdController,
                decoration: const InputDecoration(
                  labelText: '새 아이디',
                ),
              ),
                ],
            ),
          ),
            actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                '취소',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                '변경',
              ),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    final currentPassword =
        currentPasswordController.text;

    final newLoginId =
        newLoginIdController.text.trim();

    if (currentPassword.isEmpty ||
        newLoginId.isEmpty) {
      showMessage(
        '현재 비밀번호와 새 아이디를 입력해주세요.',
      );
      return;
    }

    await changeLoginId(
      currentPassword: currentPassword,
      newLoginId: newLoginId,
    );
  }

  Future<void> changeLoginId({
    required String currentPassword,
    required String newLoginId,
  }) async {
    if (isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await authService.changeLoginId(
        currentPassword: currentPassword,
        newLoginId: newLoginId,
      );

      await authService.logout();

      FcmRegistrationService.reset();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '아이디가 변경되었습니다. '
            '새 아이디로 다시 로그인해주세요.',
          ),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      showMessage(
        cleanExceptionMessage(e),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> showChangePasswordDialog() async {
    final currentPasswordController =
        TextEditingController();

    final newPasswordController =
        TextEditingController();

    final confirmPasswordController =
        TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: panelColor,
          title: const Text(
            '비밀번호 변경',
          ),
          content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                TextField(
                    controller:
                        currentPasswordController,
                    obscureText: true,
                    textInputAction:
                        TextInputAction.next,
                    decoration:
                        const InputDecoration(
                    labelText: '현재 비밀번호',
                    ),
                ),

                const SizedBox(height: 12),

                TextField(
                    controller:
                        newPasswordController,
                    obscureText: true,
                    textInputAction:
                        TextInputAction.next,
                    decoration:
                        const InputDecoration(
                    labelText: '새 비밀번호',
                    ),
                ),

                const SizedBox(height: 12),

                TextField(
                    controller:
                        confirmPasswordController,
                    obscureText: true,
                    textInputAction:
                        TextInputAction.done,
                    decoration:
                        const InputDecoration(
                    labelText: '새 비밀번호 확인',
                    ),
                ),
                ],
            ),
            ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                '취소',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                '변경',
              ),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    final currentPassword =
        currentPasswordController.text;

    final newPassword =
        newPasswordController.text;

    final confirmPassword =
        confirmPasswordController.text;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage(
        '모든 값을 입력해주세요.',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      showMessage(
        '새 비밀번호가 서로 일치하지 않습니다.',
      );
      return;
    }

    if (newPassword.length < 8) {
      showMessage(
        '새 비밀번호는 8자 이상이어야 합니다.',
      );
      return;
    }

    await changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      await authService.logout();

      FcmRegistrationService.reset();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '비밀번호가 변경되었습니다. '
            '새 비밀번호로 다시 로그인해주세요.',
          ),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      showMessage(
        cleanExceptionMessage(e),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String cleanExceptionMessage(
    Object error,
  ) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }

  void showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
  }

  Widget buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(
              0.12,
            ),
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: accentColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding:
              const EdgeInsets.only(
            top: 4,
          ),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.white54,
        ),
        onTap:
            isLoading ? null : onTap,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          '계정 설정',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding:
                const EdgeInsets.all(16),
            children: [
              const Text(
                '계정',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              buildSettingTile(
                icon:
                    Icons.person_outline_rounded,
                title: '아이디 변경',
                subtitle:
                    '로그인에 사용하는 아이디를 변경합니다.',
                onTap:
                    showChangeLoginIdDialog,
              ),

              buildSettingTile(
                icon:
                    Icons.lock_outline_rounded,
                title: '비밀번호 변경',
                subtitle:
                    '현재 비밀번호 확인 후 새 비밀번호로 변경합니다.',
                onTap:
                    showChangePasswordDialog,
              ),

              const SizedBox(height: 10),

              Container(
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      dangerColor.withOpacity(
                    0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                  border: Border.all(
                    color:
                        dangerColor.withOpacity(
                      0.18,
                    ),
                  ),
                ),
                child: const Text(
                  '계정 정보를 변경하면 보안을 위해 '
                  '다시 로그인해야 합니다.',
                  style: TextStyle(
                    color: Colors.white60,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),

          if (isLoading)
            Container(
              color:
                  Colors.black.withOpacity(
                0.35,
              ),
              child: const Center(
                child:
                    CircularProgressIndicator(
                  color: accentColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}