import 'package:flutter/material.dart';

import '../config/api_service.dart';
import '../services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() =>
      _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
    static const Color backgroundColor =
        Color(0xff151329);

    static const Color panelColor =
        Color(0xff211E3A);

    static const Color accentColor =
        Color(0xff00F5C8);

    final TextEditingController loginIdController =
        TextEditingController();

    final TextEditingController passwordController =
        TextEditingController();

    final TextEditingController
        passwordConfirmController =
        TextEditingController();

    final TextEditingController nicknameController =
        TextEditingController();

    late final AuthService authService;

    bool isLoading = false;
    bool isPasswordVisible = false;
    bool isPasswordConfirmVisible = false;

    @override
    void initState() {
        super.initState();

        authService = AuthService(
        baseUrl: ApiService.baseUrl,
        );
    }

    @override
    void dispose() {
        loginIdController.dispose();
        nicknameController.dispose();
        passwordController.dispose();
        passwordConfirmController.dispose();

        super.dispose();
    }

    Future<void> signup() async {
        final loginId =
            loginIdController.text.trim();

        final nickname =
            nicknameController.text.trim();

        final password =
            passwordController.text;

        final passwordConfirm =
            passwordConfirmController.text;

        if (loginId.isEmpty ||
                nickname.isEmpty ||
                password.isEmpty ||
                passwordConfirm.isEmpty) {
            showMessage('모든 항목을 입력해주세요.');
            return;
        }

        if (password != passwordConfirm) {
        showMessage('비밀번호가 일치하지 않습니다.');
        return;
        }

        setState(() {
        isLoading = true;
        });

        try {
        await authService.signup(
            loginId: loginId,
            password: password,
            nickname: nickname,
        );

        if (!mounted) return;

        await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
            return AlertDialog(
                backgroundColor: panelColor,
                title: const Text(
                '회원가입 완료',
                ),
                content: const Text(
                '계정이 생성되었습니다.\n'
                '새 계정으로 로그인해주세요.',
                ),
                actions: [
                TextButton(
                    onPressed: () {
                    Navigator.of(
                        dialogContext,
                    ).pop();
                    },
                    child: const Text(
                    '확인',
                    style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                    ),
                    ),
                ),
                ],
            );
            },
        );

        if (!mounted) return;

        Navigator.of(context).pop(loginId);
        } catch (e) {
        if (!mounted) return;

        final message = e
            .toString()
            .replaceFirst('Exception: ', '');

        showMessage(message);
        } finally {
        if (mounted) {
            setState(() {
            isLoading = false;
            });
        }
        }
    }

    void showMessage(String message) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    28,
                ),
                backgroundColor: panelColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                ),
                content: Text(
                    message,
                    style: const TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    ),
                ),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            title: const Text(
            '회원가입',
            style: TextStyle(
                fontWeight: FontWeight.bold,
            ),
            ),
        ),
        body: SafeArea(
            child: Center(
            child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
                ),
                child: Column(
                children: [
                    Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                        color:
                            accentColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                    ),
                    child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: accentColor,
                        size: 38,
                    ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                    'EarStock 계정 만들기',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                    ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                    '감시 종목과 알림 기록을\n'
                    '내 계정에 안전하게 저장합니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        height: 1.5,
                    ),
                    ),

                    const SizedBox(height: 32),

                    Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: panelColor,
                        borderRadius:
                            BorderRadius.circular(24),
                    ),
                    child: Column(
                        children: [
                        TextField(
                            controller:
                                loginIdController,
                            textInputAction:
                                TextInputAction.next,
                            enabled: !isLoading,
                            decoration: InputDecoration(
                            labelText: '아이디',
                            prefixIcon: const Icon(
                                Icons.person_outline,
                            ),
                            filled: true,
                            fillColor: Colors.white
                                .withOpacity(0.05),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                16,
                                ),
                                borderSide:
                                    BorderSide.none,
                            ),
                            ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                            controller: nicknameController,
                            textInputAction: TextInputAction.next,
                            enabled: !isLoading,
                            decoration: InputDecoration(
                                labelText: '닉네임',
                                prefixIcon: const Icon(
                                Icons.badge_outlined,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                                ),
                            ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                            controller:
                                passwordController,
                            obscureText:
                                !isPasswordVisible,
                            textInputAction:
                                TextInputAction.next,
                            enabled: !isLoading,
                            decoration: InputDecoration(
                            labelText: '비밀번호',
                            prefixIcon: const Icon(
                                Icons.lock_outline,
                            ),
                            suffixIcon: IconButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                        isPasswordVisible =
                                            !isPasswordVisible;
                                        });
                                    },
                                icon: Icon(
                                isPasswordVisible
                                    ? Icons
                                        .visibility_off_outlined
                                    : Icons
                                        .visibility_outlined,
                                ),
                            ),
                            filled: true,
                            fillColor: Colors.white
                                .withOpacity(0.05),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                16,
                                ),
                                borderSide:
                                    BorderSide.none,
                            ),
                            ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                            controller:
                                passwordConfirmController,
                            obscureText:
                                !isPasswordConfirmVisible,
                            textInputAction:
                                TextInputAction.done,
                            enabled: !isLoading,
                            onSubmitted: (_) {
                            if (!isLoading) {
                                signup();
                            }
                            },
                            decoration: InputDecoration(
                            labelText: '비밀번호 확인',
                            prefixIcon: const Icon(
                                Icons.lock_reset_rounded,
                            ),
                            suffixIcon: IconButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                        isPasswordConfirmVisible =
                                            !isPasswordConfirmVisible;
                                        });
                                    },
                                icon: Icon(
                                isPasswordConfirmVisible
                                    ? Icons
                                        .visibility_off_outlined
                                    : Icons
                                        .visibility_outlined,
                                ),
                            ),
                            filled: true,
                            fillColor: Colors.white
                                .withOpacity(0.05),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                16,
                                ),
                                borderSide:
                                    BorderSide.none,
                            ),
                            ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                            onPressed:
                                isLoading ? null : signup,
                            style:
                                ElevatedButton.styleFrom(
                                backgroundColor:
                                    accentColor,
                                foregroundColor:
                                    backgroundColor,
                                disabledBackgroundColor:
                                    accentColor.withOpacity(
                                0.45,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                    18,
                                ),
                                ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child:
                                        CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color:
                                            backgroundColor,
                                    ),
                                    )
                                : const Text(
                                    '회원가입',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.bold,
                                    ),
                                    ),
                            ),
                        ),
                        ],
                    ),
                    ),
                ],
                ),
            ),
            ),
        ),
        );
    }
}