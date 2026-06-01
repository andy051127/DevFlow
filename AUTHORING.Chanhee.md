# AUTHORING.Chanhee.md
> DevFlow 프로젝트에서 사용한 AI Agent 운영 기법 — Chanhee

---

## 1. 개요

이 파일은 Claude Code를 활용하여 DevFlow 프로젝트를 진행하면서
정립한 나만의 AI Agent 운영 방식을 기록한 문서입니다.

이 파일 하나로 다음을 부트스트랩할 수 있습니다.
- 프로젝트 기획 문서 세트 (`.planning/`)
- 기술 문서 세트 (`docs/`)
- AI Agent 지시서 (`AGENTS.md`)
- 서브에이전트 카탈로그 (`.github/agents/`)
- 슬래시 명령 (`/.github/prompts/`)

---

## 2. 나의 워크플로우 — 6단계

모든 프로젝트를 아래 순서로 진행합니다.

```
1. 주제 구체화   → 앱의 목적, 타겟, 기능을 텍스트로 정리
2. 기획 문서     → .planning/ 5개 문서 생성
3. 설계 문서     → docs/architecture.md + ADR 3개
4. 환경 문서     → docs/setup.md / deploy.md / testing.md
5. Agent 지시서  → AGENTS.md 생성
6. 최종 정리     → README.md 완성
```

각 단계에서 AI가 초안을 만들고, 내가 검토·수정 후 확정합니다.

---

## 3. 핵심 프롬프트 패턴

### 3-1. 초안 요청 패턴
AI에게 바로 작성을 시키지 않고, **초안을 먼저 보여달라고** 요청합니다.

```
{문서 이름} 초안 작성해줘
```

초안을 검토한 뒤 수정 사항을 전달하고, 확정되면:

```
초안 그대로 작성해줘
```

**이유**: AI가 만든 것을 내가 검토·확정하는 구조를 만들어
발표에서 모든 내용을 설명할 수 있도록 합니다.

### 3-2. 검토 요청 패턴
내가 직접 작성한 문서를 AI에게 검토시킵니다.

```
@{파일명} 읽고 수정해야 될 사항이나
기술적으로 불가능한 부분이 있으면 알려줘
```

**이유**: 기술적 오류나 범위 초과 항목을 사전에 걸러냅니다.

### 3-3. 컨텍스트 유지 패턴
AI가 프로젝트 전체 맥락을 잃지 않도록
항상 관련 파일을 `@파일명`으로 참조합니다.

```
@AGENTS.md @.planning/01-requirements.md 를 참고해서 ...
```

---

## 4. 서브에이전트 카탈로그

| 파일 | 역할 |
|---|---|
| `.github/agents/feasibility-researcher.agent.md` | 기술 타당성 검토 |
| `.github/agents/implementation-planner.agent.md` | 구현 계획 수립 |
| `.github/agents/code-reviewer.agent.md` | 코드 리뷰 |
| `.github/agents/test-writer.agent.md` | 테스트 코드 작성 |

---

## 5. 슬래시 명령 카탈로그

| 파일 | 역할 |
|---|---|
| `.github/prompts/spec.prompt.md` | 요구사항 정의 |
| `.github/prompts/plan.prompt.md` | WBS·일정 생성 |
| `.github/prompts/implement.prompt.md` | 기능 구현 |
| `.github/prompts/retro.prompt.md` | 회고 작성 |

---

## 6. 새 프로젝트 부트스트랩 절차

이 파일을 새 프로젝트에 가져가면 아래 순서로 즉시 세팅 가능합니다.

```
1. 이 파일을 프로젝트 루트에 복사
2. Claude Code에게 "AUTHORING.Chanhee.md 를 읽고
   이 프로젝트의 AGENTS.md를 생성해줘" 요청
3. 섹션 2의 6단계 워크플로우 시작
```

---

## 7. 이 기법에서 배운 것

- AI에게 바로 작성을 시키는 것보다 **초안 → 검토 → 확정** 순서가
  발표에서 설명 가능한 수준의 이해도를 만든다.
- 파일을 `@참조`로 연결하면 AI가 프로젝트 맥락을 잃지 않는다.
- 금지 사항을 AGENTS.md에 명시하면 AI가 범위를 벗어난
  코드를 생성하는 실수를 줄일 수 있다.
