# Episode 1 P5 구현 상태

- 작성일: 2026-07-28
- 대상: Episode 1 「사라진 별빛 씨앗」 달빛 온실 구간
- 상태: 코드 구현 완료, Flutter 명령 검증 대기

## 구현 완료 범위

- 분수대에서 획득한 달빛 손잡이 선택과 온실 문 사용
- 잘못된 아이템 사용 시 아이템 유지와 구체적인 안내
- 달빛 손잡이 소모, 문 개방 연출과 입력 잠금
- 별 에너지 18개와 달 에너지 24개의 화단 분배 장치
- 화단 수 2·3·4·6·8 선택
- 선택별 몫과 나머지 표시
- 2개·3개 선택 시 더 많은 공통 화단이 있다는 피드백
- 4개·8개 선택 시 남는 에너지 피드백
- 최대공약수 6을 적용한 6개 화단에서만 P5 해결
- 화단마다 별 3개와 달 4개 배치
- 이끼 보관대 개방, 별빛 씨앗과 포포 발견
- `따뜻한 이끼와 감싼 씨앗` 핵심 증거를 단서 수첩에 기록
- 기존 P0~P4 상태, 인벤토리와 단서 유지
- 360×640 작은 화면을 위한 스크롤 구조

## 추가 파일

```text
lib/features/adventure/escape/episode_one/widgets/
└── episode_one_greenhouse_overlay.dart

test/
└── episode_one_greenhouse_test.dart
```

## 수정 파일

```text
lib/features/adventure/escape/episode_one/
├── episode_one_puzzles.dart
├── episode_one_state.dart
└── episode_one_escape_screen.dart

lib/features/adventure/garden_exploration_screen.dart
```

## 추가 테스트

- P5 규칙과 선택별 결과
- 달빛 손잡이 선택·소모와 문 개방
- 잘못된 아이템 보존
- 2개·4개 화단 오답 피드백
- 6개 화단 정답과 입력 잠금
- 씨앗·포포 발견과 핵심 증거 기록
- 실제 위젯 조작 흐름
- 단서 수첩 확인
- 360×640 작은 화면 오버플로 확인

## 검증 명령

```bash
dart format --output=none --set-exit-if-changed \
  lib/features/adventure/escape/episode_one \
  lib/features/adventure/garden_exploration_screen.dart \
  test/episode_one_escape_foundation_test.dart \
  test/episode_one_fountain_test.dart \
  test/episode_one_greenhouse_test.dart

flutter analyze
flutter test
flutter build web --release --base-href /Rumi/ --pwa-strategy=none
```

현재 연결된 실행 환경에는 Flutter와 Dart 명령 실행 기능이 없어 위 검증 결과는 아직 확정하지 않았다. 검증이 완료된 뒤 `PROJECT_CONTEXT.md`에 P5 완료 상태를 반영한다.

## 다음 구현 범위

1. 핵심 증거 3개를 사용하는 최종 추리 Overlay
2. 포포의 보호 행동을 설명하는 결말 대사
3. 씨앗의 중앙 정원 귀환과 별빛 꽃 개화
4. +110 XP와 Episode 1 완료 기록
