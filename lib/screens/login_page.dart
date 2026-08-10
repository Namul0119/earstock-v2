import 'package:flutter/material.dart';

import '../config/api_service.dart';
import '../services/auth_service.dart';
import '../services/fcm_registration_service.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    static const Color backgroundColor = Color(0xff151329);
    static const Color panelColor = Color(0xff211E3A);
    static const Color accentColor = Color(0xff00F5C8);

    final TextEditingController loginIdController =
        TextEditingController();

    final TextEditingController passwordController =
        TextEditingController();

    late final AuthService authService;

    bool isLoading = false;
    bool isPasswordVisible = false;

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
        passwordController.dispose();

        super.dispose();
    }

    Future<void> login() async {
        final loginId = loginIdController.text.trim();
        final password = passwordController.text;

        if (loginId.isEmpty || password.isEmpty) {
            showMessage('아이디와 비밀번호를 입력해주세요.');
            return;
        }

        setState(() {
            isLoading = true;
        });

        try {
            await authService.login(
                loginId: loginId,
                password: password,
            );

            try {
                await FcmRegistrationService.initialize();
            } catch (e) {
                debugPrint(
                    '로그인 후 FCM 초기화 실패: $e',
                );
            }

            if (!mounted) return;

            Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (_) => const HomePage(),
                ),
            );
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
            body: SafeArea(
                child: Center(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                        ),
                        child: Column(
                            children: [
                                Container(
                                    width: 84,
                                    height: 84,
                                    decoration: BoxDecoration(
                                        color: accentColor.withOpacity(0.12),
                                        shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.graphic_eq_rounded,
                                        color: accentColor,
                                        size: 44,
                                    ),
                                ),

                                const SizedBox(height: 24),

                                const Text(
                                    'EarStock',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                    ),
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                    '귀로 위험을 듣는 주식 감시 앱',
                                    style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 15,
                                    ),
                                ),

                                const SizedBox(height: 40),

                                Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                        color: panelColor,
                                        borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Column(
                                        children: [
                                            TextField(
                                                controller: loginIdController,
                                                textInputAction: TextInputAction.next,
                                                enabled: !isLoading,
                                                decoration: InputDecoration(
                                                    labelText: '아이디',
                                                    prefixIcon: const Icon(
                                                        Icons.person_outline,
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
                                            controller: passwordController,
                                            obscureText: !isPasswordVisible,
                                            textInputAction: TextInputAction.done,
                                            enabled: !isLoading,
                                            onSubmitted: (_) => login(),
                                            decoration: InputDecoration(
                                                labelText: '비밀번호',
                                                prefixIcon: const Icon(
                                                    Icons.lock_outline,
                                                ),
                                                suffixIcon: IconButton(
                                                    onPressed: () {
                                                        setState(() {
                                                            isPasswordVisible =
                                                                !isPasswordVisible;
                                                        });
                                                    },
                                                    icon: Icon(
                                                        isPasswordVisible
                                                            ? Icons.visibility_off_outlined
                                                            : Icons.visibility_outlined,
                                                    ),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white.withOpacity(0.05),
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                    borderSide: BorderSide.none,
                                                ),
                                            ),
                                        ),

                                        const SizedBox(height: 24),

                                        SizedBox(
                                            width: double.infinity,
                                            height: 54,
                                            child: ElevatedButton(
                                                onPressed: isLoading ? null : login,
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: accentColor,
                                                    foregroundColor: backgroundColor,
                                                    disabledBackgroundColor:
                                                        accentColor.withOpacity(0.45),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(18),
                                                    ),
                                                ),
                                                child: isLoading
                                                    ? const SizedBox(
                                                        width: 22,
                                                        height: 22,
                                                        child:
                                                            CircularProgressIndicator(
                                                            strokeWidth: 2.5,
                                                            color: backgroundColor,
                                                        ),
                                                    )
                                                    : const Text(
                                                        '로그인',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                        ),
                                                    ),
                                            ),
                                        ),

                                        const SizedBox(height: 20),

                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                                const Text(
                                                    '계정이 없으신가요?',
                                                    style: TextStyle(
                                                        color: Colors.white60,
                                                    ),
                                                ),

                                                TextButton(
                                                    onPressed: isLoading
                                                        ? null
                                                        : () async {
                                                            final result =
                                                                await Navigator.of(context).push<String>(
                                                                MaterialPageRoute(
                                                                    builder: (_) =>
                                                                        const SignupPage(),
                                                                ),
                                                            );

                                                            if (!mounted) return;

                                                            if (result != null &&
                                                                result.isNotEmpty) {
                                                                loginIdController.text =
                                                                    result;

                                                                passwordController.clear();

                                                                showMessage(
                                                                    '회원가입이 완료되었습니다. 로그인해주세요.',
                                                                );
                                                            }
                                                        },
                                                        child: const Text(
                                                            '회원가입',
                                                            style: TextStyle(
                                                                color: accentColor,
                                                                fontWeight: FontWeight.bold,
                                                            ),
                                                        ),
                                                ),
                                            ],
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