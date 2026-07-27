from pathlib import Path


SECTION = r'''

## 18. 2D 장면형 방탈출 전환 및 기술 검증 (2026-07-27)

### 방향 확정

Rumi의 핵심 게임 형식을 2D 포인트 앤 클릭 장면형 방탈출로 확정한다.
기존 세계관, 캐릭터, Episode 1 사건과 약수·배수 학습 주제는 유지하되,
플레이 구조는 다음 흐름을 기준으로 재설계한다.

```text
장면 관찰
→ 수상한 물건 발견
→ 확대 조사
→ 단서 또는 아이템 획득
→ 다른 장면과 연결
→ 장치 조작
→ 공간이나 이야기 변화
→ 사건 해결
```

교육을 위한 퀴즈에 게임을 덧붙이지 않고, 재미있는 방탈출 게임의 장치와
사건 해결 과정에 수학을 자연스럽게 적용한다.

### 완료 문서

- `docs/ESCAPE_GAME_ANALYSIS.md`: 대표 방탈출 게임 분석 및 Rumi 채택 원칙
- `docs/FLAME_FEASIBILITY_REPORT.md`: Flame 핵심 기능 구현 가능성 검증

### 기술 검증 프로토타입

다음 파일에 독립 검증 화면을 구현했다.

```text
lib/features/adventure/flame/escape_feasibility_screen.dart
```

검증한 기능은 다음과 같다.

- 장면 이동과 진행 상태 유지
- 전체 장면에서 확대 조사 화면으로 이동하고 복귀
- 인벤토리 아이템 획득, 선택, 해제와 사용
- 잘못된 아이템 사용 시 구체적인 반응
- 드래그 조각 이동, 실패 시 원위치 복귀와 성공 시 스냅
- 장치 연쇄 애니메이션과 진행 중 입력 잠금
- Flame 장면과 Flutter 인벤토리·힌트 Overlay의 입력 분리
- 작은 화면 대응 터치 영역
- 효과음 재생 구조와 앱 생명주기 처리

효과음 구현을 위해 `flame_audio: ^2.12.2`를 추가했다.

### 자동 검증 상태

최종 커밋 `037b965`에서 다음 검사를 모두 통과했다.

- `flutter pub get`: 성공
- `dart format`: 성공
- `flutter analyze`: 성공
- `flutter test`: 전체 성공
- `flutter build web --release --base-href /Rumi/`: 성공

기존 모험과 기존 자동 테스트를 유지한 채 새 검증 화면이 함께 통과했다.

### 남은 확인

- Galaxy 태블릿에서 터치와 드래그 조작감 확인
- Android 실제 기기에서 효과음 확인
- 앱 백그라운드 전환과 복귀 확인
- 기기별 SafeArea와 버튼 겹침 확인

### 기술 결정

2D 장면형 방탈출의 핵심 기능은 현재 Flutter·Flame 구조에서 구현할 수 있다.
완전한 3D 회전, 복잡한 물리 시뮬레이션과 반사신경 중심 조작은 사용하지 않는다.
현재 단계에서 게임 엔진을 변경하지 않는다.

### 다음 작업

1. `docs/RUMI_ESCAPE_DESIGN_BIBLE.md` 작성
2. 장면, 아이템, 퍼즐, 힌트, 교육 적용과 연출 규칙 확정
3. 디자인 바이블 확정 후 Episode 1 상세 설계서 작성
4. Episode 1 상세 설계 승인 후 본편 구현

Episode 1 본편 코딩은 디자인 바이블과 상세 설계가 확정된 후 시작한다.
'''


def main() -> None:
    path = Path("PROJECT_CONTEXT.md")
    source = path.read_text(encoding="utf-8").rstrip()
    if "## 18. 2D 장면형 방탈출 전환 및 기술 검증" not in source:
        source += SECTION
    path.write_text(source.rstrip() + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
