# DevFlow 테스트 가이드

---

## 테스트 전략 개요

| 테스트 종류 | 대상 | 도구 |
|---|---|---|
| 단위 테스트 | Domain Service, ViewModel | `flutter_test` |
| 위젯 테스트 | UI 컴포넌트 | `flutter_test` |
| 통합 테스트 | 주요 사용자 흐름 | `integration_test` |

---

## 1. 단위 테스트

핵심 비즈니스 로직인 스트릭 계산과 업적 판정을 테스트합니다.

### 테스트 파일 위치
```
test/
├── domain/
│   ├── streak_service_test.dart
│   └── achievement_service_test.dart
└── application/
    ├── routine_view_model_test.dart
    └── schedule_view_model_test.dart
```

### 예시 — 스트릭 계산 테스트

```dart
void main() {
  group('StreakService', () {
    test('연속 3일 달성 시 스트릭이 3이어야 한다', () {
      final service = StreakService();
      final dates = [
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 2),
        DateTime(2026, 6, 3),
      ];
      expect(service.calculate(dates), 3);
    });

    test('하루 빠진 경우 스트릭이 1로 초기화되어야 한다', () {
      final service = StreakService();
      final dates = [
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 3), // 6/2 누락
      ];
      expect(service.calculate(dates), 1);
    });
  });
}
```

### 실행

```bash
flutter test test/domain/streak_service_test.dart
```

---

## 2. 위젯 테스트

UI 컴포넌트가 올바르게 렌더링되는지 확인합니다.

### 예시 — 루틴 카드 렌더링 테스트

```dart
void main() {
  testWidgets('루틴 카드에 루틴 이름이 표시되어야 한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RoutineCard(routineName: '알고리즘 풀기'),
      ),
    );
    expect(find.text('알고리즘 풀기'), findsOneWidget);
  });
}
```

### 실행

```bash
flutter test test/
```

---

## 3. 전체 테스트 실행

```bash
# 전체 테스트
flutter test

# 커버리지 포함
flutter test --coverage
```

---

## 4. 테스트 체크리스트

| 항목 | 확인 |
|---|---|
| 스트릭 계산 — 연속 달성 | [ ] |
| 스트릭 계산 — 중간 누락 시 초기화 | [ ] |
| 업적 판정 — 7일·30일 조건 | [ ] |
| 루틴 CRUD Repository | [ ] |
| 일정 CRUD Repository | [ ] |
| 루틴 카드 UI 렌더링 | [ ] |
| 진행률 바 UI 렌더링 | [ ] |
