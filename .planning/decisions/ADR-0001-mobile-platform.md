# ADR-0001: 모바일 플랫폼 선택

## 상태
확정

## 배경
DevFlow는 Android/iOS 모두를 타겟으로 하는 모바일 앱이다.
플랫폼 선택은 개발 생산성, 학습 곡선, 발표 안정성에 직접 영향을 미친다.

## 검토한 대안
| 플랫폼 | 장점 | 단점 |
|---|---|---|
| Flutter | 단일 코드로 Android/iOS 동시 지원, UI 풍부 | Dart 학습 필요 |
| React Native | JS/TS 생태계, 웹 경험자에게 친숙 | 네이티브 모듈 연동 시 복잡 |
| Android (Kotlin) | 풀 네이티브, 도구 성숙 | iOS 별도 개발 필요 |

## 결정
**Flutter** 를 선택한다.

## 이유
- 단일 코드베이스로 Android/iOS를 동시에 지원하여 1인 개발 부담 최소화
- `sqflite`, `flutter_local_notifications`, `fl_chart` 등
  DevFlow에 필요한 패키지가 Flutter 생태계에 모두 존재
- 로컬 SQLite 기반 앱 특성상 네이티브 모듈 복잡도가 낮아
  Flutter의 단점이 해당 프로젝트에서 발현되지 않음

## 결과
- Dart 언어 학습이 필요하나 AI Agent로 코드 생성 보완 가능
- 모든 구현은 Flutter 기준으로 진행
