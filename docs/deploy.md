# DevFlow 배포 가이드

---

## 배포 방식 개요

DevFlow는 로컬 SQLite 기반 앱으로 외부 서버 배포가 필요 없습니다.
배포는 각 플랫폼의 스토어 또는 직접 설치(APK) 방식으로 이루어집니다.

| 방식 | 대상 | 용도 |
|---|---|---|
| APK 직접 설치 | Android | 발표 데모, 테스트 배포 |
| App Bundle | Android | Google Play Store 제출 |
| IPA | iOS | TestFlight / App Store 제출 |

---

## 1. Android — APK 빌드 및 설치

### 1-1. 릴리즈 APK 빌드

```bash
flutter build apk --release
```

빌드 완료 후 파일 위치:
```
build/app/outputs/flutter-apk/app-release.apk
```

### 1-2. 기기에 직접 설치 (USB 연결)

```bash
flutter install
```

### 1-3. App Bundle 빌드 (Google Play 제출용)

```bash
flutter build appbundle --release
```

빌드 완료 후 파일 위치:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## 2. iOS — IPA 빌드 (macOS 필요)

### 2-1. 릴리즈 빌드

```bash
flutter build ios --release
```

### 2-2. Xcode에서 Archive

1. Xcode에서 프로젝트 열기: `open ios/Runner.xcworkspace`
2. 상단 메뉴 → **Product → Archive**
3. Organizer 창 → **Distribute App**
4. TestFlight 또는 App Store 선택 후 제출

---

## 3. 발표용 데모 배포 체크리스트

발표 전 반드시 확인합니다.

- [ ] 릴리즈 빌드 성공 확인
- [ ] 더미 데이터 30일치 미리 입력
- [ ] 실기기에 APK 설치 및 동작 확인
- [ ] 데모 영상 30초 백업 (mp4)
- [ ] Wi-Fi 없는 환경에서 오프라인 동작 확인

---

## 4. 버전 관리

`pubspec.yaml` 에서 버전을 관리합니다.

```yaml
version: 1.0.0+1
#        ^   ^
#        |   빌드 번호 (스토어 제출 시 증가)
#        버전명 (사용자에게 표시)
```
