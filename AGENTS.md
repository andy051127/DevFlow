# AGENTS.md — DevFlow AI Agent 지시서

이 파일은 Claude Code 등 AI Agent가 DevFlow 프로젝트를 다룰 때
따라야 할 규칙과 컨텍스트를 정의합니다.

---

## 프로젝트 개요

- **앱 이름**: DevFlow
- **플랫폼**: Flutter (Android / iOS)
- **목적**: 개발자 전용 루틴/일정 통합 관리 모바일 앱
- **아키텍처**: 레이어드 아키텍처 (Presentation / Application / Domain / Data)
- **상태관리**: Riverpod
- **로컬 DB**: SQLite (sqflite)

---

## 디렉토리 규칙

| 추가할 것 | 위치 |
|---|---|
| 새 화면 | `lib/presentation/screens/{기능명}/` |
| 새 위젯 | `lib/presentation/widgets/` |
| 새 ViewModel | `lib/application/view_models/` |
| 새 Entity | `lib/domain/entities/` |
| 새 Service (비즈니스 로직) | `lib/domain/services/` |
| 새 Repository | `lib/data/repositories/` |
| DB 관련 코드 | `lib/data/local/` |

> 레이어 경계를 반드시 지킨다.
> Presentation에서 직접 DB를 호출하는 코드는 작성하지 않는다.

---

## 코딩 규칙

- 상태관리는 **Riverpod**만 사용한다. `setState`, `Provider` 혼용 금지.
- 모든 비즈니스 로직은 **Domain Layer**에 위치한다.
- Repository는 인터페이스와 구현체를 분리한다.
- 새 기능 추가 시 반드시 `test/` 에 단위 테스트를 함께 작성한다.

---

## 금지 사항

- Firebase 관련 코드 작성 금지 (Could 항목 — 현재 버전 범위 외)
- `setState` 사용 금지
- Presentation Layer에서 SQLite 직접 호출 금지
- 외부 유료 API 연동 코드 작성 금지

---

## Must 기능 목록

구현 우선순위 기준입니다. 이 기능들을 먼저 완성합니다.

- M-01: 루틴 추가·수정·삭제
- M-02: 루틴 완료 체크
- M-03: 진행률 표시 (N/M 완료 + 프로그레스 바)
- M-04: 스트릭(연속 달성일) 표시
- M-05: 일정 추가·수정·삭제
- M-06: 일정 완료 체크
- M-07: 오늘/내일 일정 요약

---

## 자주 쓰는 명령어

```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run

# 전체 테스트
flutter test

# 릴리즈 APK 빌드
flutter build apk --release
```

---

## 주요 문서 위치

| 문서 | 경로 |
|---|---|
| 비전·목표 | `.planning/00-vision.md` |
| 요구사항 (MoSCoW) | `.planning/01-requirements.md` |
| WBS | `.planning/02-wbs.md` |
| 일정표 | `.planning/04-schedule.md` |
| 아키텍처 | `docs/architecture.md` |
| 환경 설정 | `docs/setup.md` |
| 배포 가이드 | `docs/deploy.md` |
| 테스트 가이드 | `docs/testing.md` |
| ADR | `.planning/decisions/` |
