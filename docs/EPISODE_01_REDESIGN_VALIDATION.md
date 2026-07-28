# Episode 1 학습 확장 개편 검증 결과

- 검증일: 2026-07-28
- 검증 기준 커밋: 04b3b2deab48ef3975181284bc5524b7faed5425
- flutter pub get: 성공
- dart format: 성공
- flutter analyze: 실패
- flutter test: 실패
- flutter build web: 성공

## 최종 판정

실패 항목이 있어 추가 수정과 재검증이 필요하다.

## analyze 오류
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
Analyzing Rumi...                                               

   info • 'groupValue' is deprecated and shouldn't be used. Use a RadioGroup ancestor to manage group value instead. This feature was deprecated after v3.32.0-0.0.pre. Try replacing the use of the deprecated member with the replacement • lib/features/adventure/escape/episode_one_v2/episode_one_redesign_screen.dart:1204:7 • deprecated_member_use
   info • 'onChanged' is deprecated and shouldn't be used. Use RadioGroup to handle value change instead. This feature was deprecated after v3.32.0-0.0.pre. Try replacing the use of the deprecated member with the replacement • lib/features/adventure/escape/episode_one_v2/episode_one_redesign_screen.dart:1205:7 • deprecated_member_use
   info • Statements in an if should be enclosed in a block. Try wrapping the statement in a block • lib/features/adventure/escape/episode_one_v2/episode_one_redesign_state.dart:310:7 • curly_braces_in_flow_control_structures

3 issues found. (ran in 8.4s)
```

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
::group::❌ /home/runner/work/Rumi/Rumi/test/home_episode_one_navigation_test.dart: 메인 화면에서 최종 Episode 1로 직접 이동한다 (failed)
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _KeyWidgetFinder:<Found 0 widgets with key [<'episode-one-foundation-back'>]: []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///home/runner/work/Rumi/Rumi/test/home_episode_one_navigation_test.dart:19:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///home/runner/work/Rumi/Rumi/test/home_episode_one_navigation_test.dart line 19
The test description was:
  메인 화면에서 최종 Episode 1로 직접 이동한다
════════════════════════════════════════════════════════════════════════════════════════════════════
Test failed. See exception logs above.
The test description was: 메인 화면에서 최종 Episode 1로 직접 이동한다

::endgroup::
✅ /home/runner/work/Rumi/Rumi/test/episode_one_greenhouse_test.dart: 온실 화면에서 문 개방과 P5 전체 조작을 완료할 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_greenhouse_test.dart: 온실의 마지막 증거를 단서 수첩에서 확인할 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_greenhouse_test.dart: 작은 화면에서도 온실 장면이 스크롤되고 넘치지 않는다
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 스플래시 화면에 별정원 소개가 표시된다
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 작은 화면에서도 스플래시 화면이 표시된다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart: 최종 추리 오답은 증거 기반 피드백 후 다시 선택할 수 있다
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 스플래시 후 닉네임 입력 화면으로 이동한다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart: 정답 추리 후 별빛 꽃이 피고 110 XP가 한 번만 기록된다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart: 완료 기록 실패 시 재시도해 결말로 이동할 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart: 작은 화면에서도 최종 추리 화면이 스크롤되고 넘치지 않는다
::group::❌ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 올바른 닉네임을 입력하면 꽃루미를 만난다 (failed)
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "사라진 별빛 씨앗": []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///home/runner/work/Rumi/Rumi/test/widget_test.dart:71:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///home/runner/work/Rumi/Rumi/test/widget_test.dart line 71
The test description was:
  올바른 닉네임을 입력하면 꽃루미를 만난다
════════════════════════════════════════════════════════════════════════════════════════════════════
Test failed. See exception logs above.
The test description was: 올바른 닉네임을 입력하면 꽃루미를 만난다

::endgroup::
::group::❌ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 저장된 닉네임이 있으면 메인 화면으로 이동한다 (failed)
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "사라진 별빛 씨앗": []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///home/runner/work/Rumi/Rumi/test/widget_test.dart:82:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///home/runner/work/Rumi/Rumi/test/widget_test.dart line 82
The test description was:
  저장된 닉네임이 있으면 메인 화면으로 이동한다
════════════════════════════════════════════════════════════════════════════════════════════════════
Test failed. See exception logs above.
The test description was: 저장된 닉네임이 있으면 메인 화면으로 이동한다

::endgroup::
✅ /home/runner/work/Rumi/Rumi/test/progress_store_test.dart: 닉네임과 모험 진행 상황을 기기에 저장한다
✅ /home/runner/work/Rumi/Rumi/test/progress_store_test.dart: 경험치가 100을 넘으면 꽃숲 성장 단계가 오른다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_installed_app_viewport_test.dart: 설치형 앱 안전영역 안에 상단 HUD와 인벤토리를 배치한다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_fountain_test.dart: 분수대 돌 선택은 연못 단서가 있어야 성공할 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_fountain_test.dart: P4는 바람끈·젖은 발자국·별열쇠를 연결해 달빛 손잡이를 준다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_fountain_test.dart: 잘못된 아이템은 분수대에서 사라지지 않는다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_redesign_test.dart: 필수 학습 활동 14개를 완료하면 단서 6개와 중간 결론을 얻는다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_redesign_test.dart: 두 번 틀리면 보강 힌트를 제안하고 진행 보상은 차감하지 않는다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_redesign_test.dart: 선택 도전에서 30의 약수를 모두 찾으면 별도장을 얻는다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_redesign_test.dart: 설치형 앱 안전영역 안에 HUD와 메시지 바를 배치한다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_fountain_test.dart: 분수대 화면에서 P4 전체 연쇄 조작을 완료할 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_fountain_test.dart: 작은 화면에서도 분수대 연쇄 장면이 스크롤되고 넘치지 않는다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_redesign_test.dart: 첫 별조각을 누르면 두 번째 학습 활동으로 이어진다
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

::error::38 tests passed, 3 failed.
```

