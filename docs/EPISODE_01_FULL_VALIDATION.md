# Episode 1 전체 자동 검증 결과

- 검증일: 2026-07-28
- 검증 기준 커밋: 29a02e6ad7abbffb014bc96338260d1f044e88b2
- flutter pub get: 성공
- dart format: 성공
- flutter analyze: 성공
- flutter test: 실패
- flutter build web: 성공

## 최종 판정

실패 항목이 있어 수정과 재검증이 필요하다.

## test 오류
```text
Resolving dependencies...
Downloading packages...
  hooks 2.0.2 (2.1.0 available)
  matcher 0.12.19 (0.12.20 available)
  meta 1.18.0 (1.19.0 available)
  record_use 0.6.0 (1.0.0 available)
  test_api 0.7.11 (0.7.13 available)
  vector_math 2.2.0 (2.4.1 available)
Got dependencies!
6 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

✅ /home/runner/work/Rumi/Rumi/test/episode_one_greenhouse_test.dart: P5는 별 18개와 달 24개를 가장 많은 6개 화단에 나눈다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_greenhouse_test.dart: 달빛 손잡이와 P5를 연결해 씨앗과 포포를 발견한다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_greenhouse_test.dart: 잘못된 아이템은 온실 문에서 사라지지 않는다
::group::❌ /home/runner/work/Rumi/Rumi/test/episode_one_greenhouse_test.dart: 온실 화면에서 문 개방과 P5 전체 조작을 완료할 수 있다 (failed)
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _KeyWidgetFinder:<Found 2 widgets with key [<'episode-one-greenhouse-discovery'>]: [
            Container-[<'episode-one-greenhouse-discovery'>](padding: EdgeInsets.all(15.0), bg:
BoxDecoration(border: Border.all(BorderSide(color: Color(alpha: 1.0000, red: 1.0000, green: 0.8902,
blue: 0.6039, colorSpace: ColorSpace.sRGB), width: 2.0)), borderRadius: BorderRadius.circular(22.0),
gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors:
[Color(alpha: 0.4667, red: 0.3725, green: 0.8902, blue: 0.7529, colorSpace: ColorSpace.sRGB),
Color(alpha: 0.4667, red: 0.4706, green: 0.3725, blue: 0.5725, colorSpace: ColorSpace.sRGB)],
tileMode: TileMode.clamp)), constraints: BoxConstraints(w=Infinity, 0.0<=h<=Infinity)),
            Container-[<'episode-one-greenhouse-discovery'>](padding: EdgeInsets.all(15.0), bg:
BoxDecoration(border: Border.all(BorderSide(color: Color(alpha: 1.0000, red: 1.0000, green: 0.8902,
blue: 0.6039, colorSpace: ColorSpace.sRGB), width: 2.0)), borderRadius: BorderRadius.circular(22.0),
gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors:
[Color(alpha: 0.4667, red: 0.3725, green: 0.8902, blue: 0.7529, colorSpace: ColorSpace.sRGB),
Color(alpha: 0.4667, red: 0.4706, green: 0.3725, blue: 0.5725, colorSpace: ColorSpace.sRGB)],
tileMode: TileMode.clamp)), constraints: BoxConstraints(w=Infinity, 0.0<=h<=Infinity)),
          ]>
   Which: is too many

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///home/runner/work/Rumi/Rumi/test/episode_one_greenhouse_test.dart:123:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///home/runner/work/Rumi/Rumi/test/episode_one_greenhouse_test.dart line 123
The test description was:
  온실 화면에서 문 개방과 P5 전체 조작을 완료할 수 있다
════════════════════════════════════════════════════════════════════════════════════════════════════
Test failed. See exception logs above.
The test description was: 온실 화면에서 문 개방과 P5 전체 조작을 완료할 수 있다

::endgroup::
✅ /home/runner/work/Rumi/Rumi/test/episode_one_greenhouse_test.dart: 온실의 마지막 증거를 단서 수첩에서 확인할 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_greenhouse_test.dart: 작은 화면에서도 온실 장면이 스크롤되고 넘치지 않는다
✅ /home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart: 별받침대는 관찰 후 별가루를 직접 묶어 해결한다
✅ /home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart: 조사 대상이 증거에 따라 단계적으로 열린다
✅ /home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart: 세 조사 장면과 추리 보드를 거쳐 사건을 해결한다
✅ /home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart: 작은 화면에서도 시작 화면과 목표 영역이 넘치지 않는다
✅ /home/runner/work/Rumi/Rumi/test/starlight_seed_episode_test.dart: 사건을 조사하고 세 장소의 단서를 모아 진실을 밝힌다
✅ /home/runner/work/Rumi/Rumi/test/starlight_seed_episode_test.dart: 온실은 연못과 숲의 단서를 찾기 전에는 잠겨 있다
::group::❌ /home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart: 최종 추리 오답은 증거 기반 피드백 후 다시 선택할 수 있다 (failed)
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _KeyWidgetFinder:<Found 0 widgets with key [<'episode-one-deduction-wrong'>]: []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart:58:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart line 58
The test description was:
  최종 추리 오답은 증거 기반 피드백 후 다시 선택할 수 있다
════════════════════════════════════════════════════════════════════════════════════════════════════
Test failed. See exception logs above.
The test description was: 최종 추리 오답은 증거 기반 피드백 후 다시 선택할 수 있다

::endgroup::
::group::❌ /home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart: 정답 추리 후 별빛 꽃이 피고 110 XP가 한 번만 기록된다 (failed)
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _KeyWidgetFinder:<Found 0 widgets with key [<'episode-one-deduction-correct'>]: []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart:107:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart line 107
The test description was:
  정답 추리 후 별빛 꽃이 피고 110 XP가 한 번만 기록된다
════════════════════════════════════════════════════════════════════════════════════════════════════
Test failed. See exception logs above.
The test description was: 정답 추리 후 별빛 꽃이 피고 110 XP가 한 번만 기록된다

::endgroup::
::group::❌ /home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart: 완료 기록 실패 시 재시도해 결말로 이동할 수 있다 (failed)
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _KeyWidgetFinder:<Found 0 widgets with key [<'episode-one-finale-save-error'>]: []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart:183:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart line 183
The test description was:
  완료 기록 실패 시 재시도해 결말로 이동할 수 있다
════════════════════════════════════════════════════════════════════════════════════════════════════
Test failed. See exception logs above.
The test description was: 완료 기록 실패 시 재시도해 결말로 이동할 수 있다

::endgroup::
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 스플래시 화면에 별정원 소개가 표시된다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart: 작은 화면에서도 최종 추리 화면이 스크롤되고 넘치지 않는다
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 작은 화면에서도 스플래시 화면이 표시된다
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 스플래시 후 닉네임 입력 화면으로 이동한다
✅ /home/runner/work/Rumi/Rumi/test/progress_store_test.dart: 닉네임과 모험 진행 상황을 기기에 저장한다
✅ /home/runner/work/Rumi/Rumi/test/progress_store_test.dart: 경험치가 100을 넘으면 꽃숲 성장 단계가 오른다
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 올바른 닉네임을 입력하면 꽃루미를 만난다
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 저장된 닉네임이 있으면 메인 화면으로 이동한다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_fountain_test.dart: 분수대 돌 선택은 연못 단서가 있어야 성공할 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_fountain_test.dart: P4는 바람끈·젖은 발자국·별열쇠를 연결해 달빛 손잡이를 준다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_fountain_test.dart: 잘못된 아이템은 분수대에서 사라지지 않는다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_fountain_test.dart: 분수대 화면에서 P4 전체 연쇄 조작을 완료할 수 있다
✅ /home/runner/work/Rumi/Rumi/test/adventure_screen_test.dart: 힌트를 보고 문제를 풀면 결과와 경험치를 보여준다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_fountain_test.dart: 작은 화면에서도 분수대 연쇄 장면이 스크롤되고 넘치지 않는다
✅ /home/runner/work/Rumi/Rumi/test/question_bank_test.dart: 약수와 배수 문제 은행은 15개의 유효한 문제를 제공한다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: P1은 별가루 12개를 4·4·4로 나눈 경우에만 해결된다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: P2는 4와 6의 첫 공배수인 12번째 칸에서만 해결된다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: P3은 0·2·4·6 순서의 실제 발자국만 허용한다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: P0와 P1 완료 전후에 실제 경로 잠금 상태가 달라진다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 불균형 배치는 유지한 채 별가루를 다시 옮길 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 별무늬 렌즈를 사용해 연못 기억거울과 P3 단서를 해결한다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 시계꽃 숲은 오답을 유지하지 않고 12번째 칸에서 은빛 바람끈을 준다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 연못과 시계꽃 숲은 원하는 순서로 해결할 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 인벤토리에서 별무늬 렌즈를 선택하고 해제할 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 시계꽃 시간고리에서 12번째 칸을 눌러 바람끈을 얻는다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 연못 단서를 수첩에서 확인할 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 작은 화면에서도 HUD·인벤토리·시계꽃 화면이 넘치지 않는다
✅ /home/runner/work/Rumi/Rumi/test/features/adventure/garden_exploration_screen_test.dart: 별받침대는 문제지보다 조사 지점을 먼저 제공한다
✅ /home/runner/work/Rumi/Rumi/test/features/adventure/garden_exploration_screen_test.dart: 세 지점을 조사하면 별가루 직접 묶기가 열린다
✅ /home/runner/work/Rumi/Rumi/test/features/adventure/garden_exploration_screen_test.dart: 상자와 돌은 발자국 증거 전에는 나타나지 않는다
✅ /home/runner/work/Rumi/Rumi/test/features/adventure/flame/escape_feasibility_screen_test.dart: 기술 검증 상태는 초기 인벤토리와 진행 메시지를 보존한다
✅ /home/runner/work/Rumi/Rumi/test/features/adventure/flame/escape_feasibility_screen_test.dart: 기술 검증 화면은 독립 StatefulWidget으로 제공된다

::error::43 tests passed, 4 failed.
```

