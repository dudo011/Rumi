from pathlib import Path


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if old not in text:
        raise SystemExit(f"Expected text not found in {path}: {old!r}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


state_path = Path(
    "lib/features/adventure/escape/episode_one_v2/episode_one_redesign_state.dart"
)
replace_once(
    state_path,
    "EpisodeOneRedesignActivity.values[activityIndex.clamp(0, 13)]",
    "EpisodeOneRedesignActivity.values[activityIndex.clamp(0, 13).toInt()]",
)
replace_once(
    state_path,
    "final nextLevel = (value.hintLevel + 1).clamp(1, 3);",
    "final nextLevel = (value.hintLevel + 1).clamp(1, 3).toInt();",
)
replace_once(
    state_path,
    "activityIndex: nextIndex.clamp(0, 13),",
    "activityIndex: nextIndex.clamp(0, 13).toInt(),",
)

screen_path = Path(
    "lib/features/adventure/escape/episode_one_v2/episode_one_redesign_screen.dart"
)
screen_text = screen_path.read_text(encoding="utf-8")
screen_text = screen_text.replace("    this.singleChoice = false,\n", "")
screen_text = screen_text.replace("  final bool singleChoice;\n", "")
screen_text = screen_text.replace("        singleChoice: true,\n", "")
screen_path.write_text(screen_text, encoding="utf-8")

home_path = Path("lib/features/home/home_screen.dart")
replace_once(
    home_path,
    "import '../adventure/escape/episode_one/episode_one_escape_screen.dart';",
    "import '../adventure/escape/episode_one_v2/episode_one_redesign_screen.dart';",
)
replace_once(
    home_path,
    "builder: (_) => EpisodeOneEscapeScreen(store: widget.store),",
    "builder: (_) => EpisodeOneRedesignScreen(store: widget.store),",
)
replace_once(home_path, "'새로운 사건',", "'Chapter 1 · Episode 1',")
replace_once(home_path, "'사라진 별빛 씨앗',", "'중앙 정원의 흔적',")
replace_once(
    home_path,
    "'오늘 밤 피어날 별빛 꽃의 씨앗이 사라졌어요. 꽃루미와 정원을 탐험하고 단서를 찾아보세요.',",
    "'별빛 씨앗이 사라진 순서를 밝히기 위해 중앙 정원의 물건을 조사하고 약수 규칙으로 흔적을 해석하세요.',",
)
replace_once(
    home_path,
    "_Tag(icon: Icons.calculate_rounded, label: '약수와 배수'),",
    "_Tag(icon: Icons.calculate_rounded, label: '약수'),",
)
replace_once(
    home_path,
    "_Tag(icon: Icons.schedule_rounded, label: '약 10분'),",
    "_Tag(icon: Icons.schedule_rounded, label: '15~18분'),",
)
replace_once(
    home_path,
    "_Tag(icon: Icons.search_rounded, label: '단서 3개'),",
    "_Tag(icon: Icons.search_rounded, label: '단서 6개'),",
)

context_path = Path("PROJECT_CONTEXT.md")
context = context_path.read_text(encoding="utf-8")
heading = "## 23. Episode 1 학습 확장 개편"
if heading not in context:
    context += """

## 23. Episode 1 학습 확장 개편

### 확정 구조

- Chapter 1 `사라진 별빛 씨앗`은 4개 Episode로 구성한다.
- Episode 1 `중앙 정원의 흔적`은 약수의 의미와 약수 찾기에 집중한다.
- 필수 학습 활동 14개, 조건부 보강·도전 활동 최대 2개를 사용한다.
- 핵심 단서는 6개이며 씨앗과 포포의 최종 발견은 Episode 4로 이동한다.
- Episode 1 완료 보상은 +60 XP다.

### 구현 원칙

- 학습 활동은 별도의 문제지 화면이 아니라 조사, 묶기, 배열, 기록 복구와 추리 행동으로 제공한다.
- 12, 18, 24를 반복 사용해 약수 판별, 곱셈 짝, 목록 완성, 반례 판단과 상황 적용을 다룬다.
- 두 번 이상 어려움을 보이면 무벌점 보강 힌트를 제안한다.
- 빠르게 해결한 사용자는 30의 약수를 찾는 선택 도전으로 정원사의 별도장을 얻을 수 있다.
- 설치형 앱을 기준으로 상태바, 노치와 하단 제스처 영역을 피하는 안전영역 레이아웃을 사용한다.

### 구현 경로

```text
lib/features/adventure/escape/episode_one_v2/
├── episode_one_redesign_screen.dart
└── episode_one_redesign_state.dart
```

Home의 `사건 조사하기`는 개편된 Episode 1을 직접 실행한다.
"""
    context_path.write_text(context, encoding="utf-8")
