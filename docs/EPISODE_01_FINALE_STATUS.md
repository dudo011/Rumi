# Episode 1 최종 추리·결말 구현 상태

- 작성일: 2026-07-28
- 대상: Episode 1 「사라진 별빛 씨앗」 최종 추리와 결말
- 상태: 코드 구현 완료, Flutter 명령 검증 대기

## 구현 완료 범위

- P5 완료 후 전체 화면 최종 추리 Overlay 자동 표시
- 설계서 기준 핵심 증거 3개 카드
  1. 옆으로 이어진 긁힘과 별가루
  2. 바람 뒤의 젖은 발자국과 은빛 털
  3. 따뜻한 이끼와 감싼 씨앗
- 세 가지 가설 중 사건의 시간 순서를 설명하는 정답 선택
- 오답 시 벌점·진행 초기화 없이 증거 기반 피드백 후 재선택
- 정답 확인 후 씨앗의 중앙 정원 귀환과 별빛 꽃 개화 연출
- 연출 시작 1초 후 건너뛰기 기능
- 포포의 보호 행동을 설명하는 결말 대사
- 새로운 꽃 `별빛 꽃` 보상 표시
- 기존 `ProgressStore.completeAdventure()`를 사용한 `+110 XP` 반영
- 완료한 모험 횟수 1 증가와 갱신된 꽃숲 성장 단계 표시
- 저장 실패 시 완료 기록 재시도 화면
- 다음 Episode를 암시하는 꽃숲 깊은 곳의 별종 대사
- 별정원으로 돌아갈 때 Home 화면까지 복귀해 진행 정보를 다시 불러오는 흐름

## 추가 파일

```text
lib/features/adventure/escape/episode_one/widgets/
└── episode_one_finale_overlay.dart

test/
└── episode_one_finale_test.dart
```

## 수정 파일

```text
lib/features/adventure/escape/episode_one/episode_one_escape_screen.dart
lib/features/adventure/garden_exploration_screen.dart
```

## 추가 테스트

- 핵심 증거 3개 표시
- 첫 번째·세 번째 가설 오답 피드백 구조
- 오답 후 재선택 가능 여부
- 두 번째 가설 정답 확인
- 최종 개화 연출과 결말 화면 이동
- `+110 XP` 전달값과 저장 호출 횟수 1회 보장
- 완료 횟수·누적 XP·꽃숲 단계 표시
- 저장 실패 후 재시도
- 360×640 작은 화면 최종 추리 오버플로 확인

## 검증 명령

```bash
dart format --output=none --set-exit-if-changed \
  lib/features/adventure/escape/episode_one \
  lib/features/adventure/garden_exploration_screen.dart \
  test/episode_one_escape_foundation_test.dart \
  test/episode_one_fountain_test.dart \
  test/episode_one_greenhouse_test.dart \
  test/episode_one_finale_test.dart

flutter analyze
flutter test
flutter build web --release --base-href /Rumi/ --pwa-strategy=none
```

현재 연결된 실행 환경에는 Flutter와 Dart 실행 명령이 없어 결과를 아직 확정하지 않았다. 전체 검증 성공 뒤 `PROJECT_CONTEXT.md`에 Episode 1 구현 완료 상태를 반영한다.

## 검증 후 남은 작업

1. Galaxy 태블릿에서 P0~P5와 최종 추리 전체 플레이
2. 실제 기기에서 효과음·SafeArea·터치 영역 확인
3. 사용자 10분 플레이 테스트
4. 사용자 피드백을 반영한 난이도와 문구 조정
