# 루미아의 별정원 (Rumi)

Flutter로 만드는 게임형 학습 앱입니다.

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

### 최초 한 번 필요한 GitHub 설정

1. GitHub 저장소에서 **Settings → Pages**로 이동합니다.
2. **Build and deployment → Source**를 **GitHub Actions**로 선택합니다.
3. **Actions** 탭에서 `Test and deploy Flutter web`을 선택합니다.
4. 아직 실행 이력이 없으면 **Run workflow**를 눌러 최초 배포를 시작합니다.

자동 배포가 실패하면 **Actions** 탭에서 실패한 단계를 확인하세요. 소스 분석이나
테스트가 실패한 경우에는 잘못된 버전이 웹사이트에 배포되지 않습니다.

## 기본 확인 명령

```bash
flutter analyze
flutter test
flutter build web --release --base-href /Rumi/
```
