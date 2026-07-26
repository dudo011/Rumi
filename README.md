# 루미아의 별정원 (Rumi)

Flutter로 만드는 게임형 학습 앱입니다.

## 현재 구현된 MVP

- 스플래시와 닉네임 입력
- 꽃루미 첫 만남과 별정원 메인 화면
- 초등학교 5학년 약수·배수 문제 은행 15개
- 첫 이야기 모험 **사라진 별빛 씨앗**: 현장 조사, 장소 탐험, 단서 수집과 최종 추리
- 중앙 정원의 오브젝트를 눌러 핵심 단서 3개를 찾는 현장 조사
- 발견 단서와 잠긴 단서를 구분하는 별지기의 단서 수첩
- 이야기 속 약수·배수 활동 4개, 단계별 힌트와 단서 기반 피드백
- 경험치, 꽃숲 성장 단계 및 완료 횟수
- 닉네임과 진행 상황의 기기 내부 저장

현재 MVP의 구체적인 구현 상태와 다음 기획 논의 주제는 [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md)에 정리되어 있습니다.

## 웹에서 최신 화면 확인하기

`main` 브랜치에 변경사항이 올라오면 GitHub Actions가 자동으로 코드를 검사하고
Flutter 웹 앱을 GitHub Pages에 배포합니다. Codespaces나 포트 설정은 필요하지
않습니다.

웹사이트 주소는 다음과 같습니다. `GITHUB_ID`를 이 저장소를 소유한 GitHub
아이디로 바꿔서 접속하세요.

```text
https://GITHUB_ID.github.io/Rumi/
```

배포에는 몇 분 정도 걸릴 수 있습니다. GitHub 저장소의 **Actions** 탭에서
`Test and deploy Flutter web` 작업에 초록색 체크가 표시된 후 웹사이트를
새로고침하세요.

## Codespaces에서 개발하기

이 저장소에는 Flutter Web 개발환경을 자동으로 준비하는 `.devcontainer` 설정이
포함되어 있습니다. GitHub 저장소에서 **Code → Codespaces → Create codespace on
main**을 선택하면 stable 채널의 Flutter, Dart·Flutter VS Code 확장, 웹 미리보기용
3000번 포트와 프로젝트 패키지가 자동으로 준비됩니다.

Codespace가 열린 뒤 변경 전후에 다음 명령으로 Actions와 동일한 핵심 검사를
실행하세요.

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release --base-href /Rumi/ --pwa-strategy=none
```

웹 앱을 직접 조작하려면 다음 명령을 실행하고 **Ports** 패널에서 `3000` 포트를
여세요.

```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3000
```

VS Code의 **Terminal → Run Task**에서 `Rumi: Check all`, `Rumi: Run web preview`,
`Rumi: Build Pages release` 작업을 선택해 같은 명령을 실행할 수도 있습니다.

### 최초 한 번 필요한 GitHub 설정

1. GitHub 저장소에서 **Settings → Pages**로 이동합니다.
2. **Build and deployment → Source**를 **GitHub Actions**로 선택합니다.
3. **Actions** 탭에서 `Test and deploy Flutter web`을 선택합니다.
4. 아직 실행 이력이 없으면 **Run workflow**를 눌러 최초 배포를 시작합니다.

자동 배포가 실패하면 **Actions** 탭에서 실패한 단계를 확인하세요. 소스 분석이나
테스트가 실패한 경우에는 잘못된 버전이 웹사이트에 배포되지 않습니다.

### 설치한 앱이 이전 화면을 보여줄 때

이 프로젝트는 항상 최신 온라인 버전을 사용하도록 빌드합니다. 이전에 설치한 앱이
오래된 화면을 계속 보여주면 아래 순서로 한 번 초기화하세요.

1. 휴대전화나 태블릿에서 설치된 Rumi 앱을 삭제합니다.
2. Chrome에서 **설정 → 사이트 설정 → 모든 사이트 → dudo011.github.io**를
   열고 저장된 데이터를 삭제합니다.
3. Chrome에서 `https://dudo011.github.io/Rumi/`를 다시 엽니다.
4. 최신 화면이 나타나는 것을 확인한 뒤 앱을 다시 설치합니다.

## 기본 확인 명령

```bash
flutter analyze
flutter test
flutter build web --release --base-href /Rumi/ --pwa-strategy=none
```
