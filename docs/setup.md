# DevFlow 개발 환경 설정

> 이 문서만 보고 5분 안에 실행할 수 있도록 작성되었습니다.

---

## 필요한 도구

| 도구 | 버전 | 확인 명령 |
|---|---|---|
| Flutter | 3.x 이상 | `flutter --version` |
| Dart | 3.x 이상 | `dart --version` |
| Android Studio / Xcode | 최신 | - |
| Git | 2.x 이상 | `git --version` |

---

## 1. 저장소 클론

```bash
git clone https://github.com/{username}/devflow.git
cd devflow
```

---

## 2. 의존성 설치

```bash
flutter pub get
```

---

## 3. 환경 확인

Flutter 개발 환경이 올바르게 설정되었는지 확인합니다.

```bash
flutter doctor
```

모든 항목에 ✅ 표시가 있어야 합니다.
Android / iOS 중 사용할 플랫폼의 항목만 통과하면 됩니다.

---

## 4. 실행

### Android (에뮬레이터 또는 실기기)
```bash
flutter run
```

### 특정 기기 지정
```bash
flutter devices          # 연결된 기기 목록 확인
flutter run -d {기기ID}
```

---

## 5. 빌드

### Android APK
```bash
flutter build apk --release
```

### iOS (macOS 필요)
```bash
flutter build ios --release
```

---

## FAQ (자주 겪는 문제)

**Q. `flutter pub get` 실패**
> Flutter SDK 경로가 PATH에 등록되어 있는지 확인하세요.
> `flutter doctor`로 SDK 설치 상태를 점검하세요.

**Q. Android 에뮬레이터가 보이지 않음**
> Android Studio → Virtual Device Manager에서 에뮬레이터를 생성하세요.

**Q. `flutter doctor`에서 Android 라이선스 경고**
> 아래 명령으로 라이선스를 수락하세요.
> ```bash
> flutter doctor --android-licenses
> ```

**Q. iOS 빌드 실패 (macOS)**
> Xcode Command Line Tools가 설치되어 있는지 확인하세요.
> ```bash
> xcode-select --install
> ```

**Q. 패키지 버전 충돌**
> `pubspec.lock` 파일을 삭제 후 `flutter pub get`을 다시 실행하세요.
