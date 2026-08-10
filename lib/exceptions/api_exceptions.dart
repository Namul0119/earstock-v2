class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException([
    this.message = '로그인이 만료되었습니다. 다시 로그인해주세요.',
  ]);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  NetworkException([
    this.message = '서버에 연결할 수 없습니다.',
  ]);

  @override
  String toString() => message;
}