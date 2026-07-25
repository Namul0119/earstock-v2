# 📈 EarStock

> **귀로 위험을 듣는 주식 감시 시스템**
>
> Flutter + Spring Boot 기반의 실시간 주식 감시 서비스입니다.
>
> 사용자는 원하는 종목의 목표가와 손절가를 등록하면,
> 서버가 실시간으로 가격을 감시하고 조건 충족 시 Firebase Cloud Messaging(FCM)을 통해 Push 알림을 전송합니다.

---

# 📱 프로젝트 소개

EarStock는 사용자가 항상 주식 화면을 보고 있지 않아도 되도록 만든 실시간 주식 감시 서비스입니다.

기존 증권 앱은 알림 기능이 제한적이거나 복잡한 설정이 필요한 경우가 많습니다.

EarStock는

- 목표가
- 손절가

만 등록하면

Spring Boot 서버가 주기적으로 주가를 확인하고,

조건 충족 시

Firebase Push 알림을 즉시 전송합니다.

또한 관리자 페이지를 통해

- 사용자 관리
- 감시 종목 조회
- 기기(Token) 관리
- 전체 공지 Push 발송

기능도 제공합니다.

---

# ✨ 주요 기능

### 사용자 기능

- 회원가입
- 로그인 (JWT 인증)
- 감시 종목 등록
- 감시 종목 수정
- 감시 종목 삭제
- 현재가 조회
- 최근 알림 조회
- 알림 기록 삭제
- FCM Token 자동 등록
- 로그아웃 시 Token 자동 삭제

---

### 서버 기능

- JWT 인증
- Spring Security 인증
- 실시간 주가 감시 Scheduler
- 목표가/손절가 조건 확인
- Alert Log 저장
- Firebase Push 전송
- FCM Token 관리

---

### 관리자(Admin)

- 관리자 로그인
- 전체 사용자 조회
- 사용자 상세 조회
- 감시 종목 관리
- FCM 기기 조회
- Alert Log 조회
- 전체 공지 Push 전송

---

# 🏗 시스템 아키텍처

> 아래 다이어그램 참고

![Architecture](screenshots/architecture.png)

---

# 🗄 ERD (Entity Relationship Diagram)

> 아래 ERD 참고

![ERD](screenshots/erd.png)

---

# 🔐 인증 방식

EarStock는 JWT(Json Web Token)를 이용하여 인증을 수행합니다.

로그인 성공 시 Access Token을 발급하며,

이후 모든 API 요청은 Authorization Header에 Bearer Token을 포함하여 인증합니다.

```
Authorization: Bearer {AccessToken}
```

Spring Security + JWT Filter를 통해 인증이 처리됩니다.

---

# 📡 API

(여기에 API 표 삽입)

---

# ⚙ 기술 스택

## Frontend

- Flutter
- Dart

## Backend

- Spring Boot
- Spring Security
- JWT

## Database

- MySQL
- Spring Data JPA

## Push

- Firebase Cloud Messaging

## Stock API

- KIS Open API

---

# 📂 프로젝트 구조

## Flutter

```
lib
 ├── screens
 ├── services
 ├── models
 ├── widgets
 ├── config
```

---

## Spring Boot

```
controller
service
repository
entity
dto
security
scheduler
config
```

---

# 🔄 주요 동작 흐름

1. 사용자 로그인
2. JWT 발급
3. JWT 포함 API 요청
4. 감시 종목 등록
5. Scheduler가 주가 조회
6. 목표가/손절가 확인
7. Alert Log 저장
8. Firebase Push 전송
9. 앱에서 Push 수신

---

# 📷 실행 화면

## 로그인

![Login](screenshots/login.png)

---

## 메인 화면

![Home](screenshots/home.png)
---

## 감시 종목 등록

![Watch](screenshots/watch.png)

---

## 관리자 페이지

![Admin](screenshots/admin.png)

---

# 🎥 시연 영상

(영상 링크)

---

# 🚀 향후 개선 예정

- Refresh Token 도입
- Redis Cache 적용
- WebSocket 실시간 시세
- Docker 배포
- AWS 배포
- 사용자 알림 설정 고도화
- 관리자 통계 Dashboard 확장

---

# 👨‍💻 개발 환경

Flutter

Spring Boot

MySQL

Firebase Cloud Messaging

KIS Open API

Android

---

# 📌 프로젝트 특징

- JWT 기반 인증 시스템
- Spring Security 적용
- 실시간 주가 감시 Scheduler
- Firebase Push Notification
- 관리자 Dashboard
- FCM Token Lifecycle 관리
- Alert Log 저장
- REST API 기반 구조
- Flutter + Spring Boot 완전 분리형 아키텍처

---

# 📄 License

Personal Portfolio Project
