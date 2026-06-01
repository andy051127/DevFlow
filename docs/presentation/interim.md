---
marp: true
theme: default
paginate: true
size: 16:9
style: |
  section {
    font-family: 'Segoe UI', sans-serif;
    background: #0f172a;
    color: #f1f5f9;
  }
  h1 { color: #60a5fa; font-size: 2em; }
  h2 { color: #93c5fd; border-bottom: 2px solid #2563eb; padding-bottom: 8px; }
  strong { color: #60a5fa; }
  table { font-size: 0.8em; }
  th { background: #1e3a5f; color: #93c5fd; }
  td { background: #1e293b; }
  code { background: #1e293b; color: #60a5fa; }
  blockquote { border-left: 4px solid #2563eb; color: #94a3b8; }
---

# DevFlow 💻
## 중간 발표

> 개발자의 루틴과 일정을 한 곳에서 관리하고, **꾸준함을 숫자로 증명한다.**

김찬희 · 2026.06.01

---

## 🔥 문제 정의

개발자에겐 **두 가지 숙제**가 있다.

| 매일 반복 | 장기 목표 |
|---|---|
| 알고리즘 풀기 | 포트폴리오 제출 |
| 기술 블로그 읽기 | 코딩 테스트 |
| 사이드 프로젝트 | 취업 준비 |

> 기존 앱은 이 둘을 **따로** 관리한다.
> DevFlow는 **하나의 흐름**으로 연결한다.

---

## 🏗️ 아키텍처

```
Presentation  →  루틴 카드, 진행률 바, 캘린더
      ↓
Application   →  Riverpod ViewModel (상태 관리)
      ↓
Domain        →  스트릭 계산, 업적 판정 로직
      ↓
Data          →  SQLite Repository (오프라인 완전 지원)
```

**Flutter** · **Riverpod** · **SQLite(sqflite)**

---

## ✅ 진행 상황

| 기능 | 상태 |
|---|---|
| 루틴 추가·수정·삭제 | ✅ 완료 |
| 루틴 완료 체크 + 진행률 바 | ✅ 완료 |
| 스트릭(연속 달성일) 계산 | ✅ 완료 |
| 일정 추가·수정·삭제 | ✅ 완료 |
| 통계 히트맵 | ✅ 완료 |
| 로컬 푸시 알림 | ⏳ 예정 |
| 업적 시스템 UI | ⏳ 예정 |

전체 Must 기능 진척: **약 70%**

---

## 📅 남은 일정

| 주차 | 목표 |
|---|---|
| 13주차 | 일정 완료 체크 UI, 스트릭 홈 표시, 테스트 |
| 14주차 | 알림, 히트맵 고도화, 문서 완비 |
| 15주차 | **최종 발표** |

**WBS 전체 현황** →
