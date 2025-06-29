# n8n 자동 배포 for fly.io

이 프로젝트는 [n8n](https://n8n.io/)을 [fly.io](https://fly.io/)에 자동으로 배포하고 설정하기 위한 스크립트를 제공합니다. macOS, Linux, Windows 환경을 모두 지원합니다.

## 주요 기능

- **플랫폼별 배포 자동화**: macOS/Linux용 `build.sh`와 Windows용 `build.ps1` 스크립트 제공
- **`flyctl` 자동 설치**: `flyctl`이 설치되어 있지 않은 경우 스크립트가 자동으로 설치
- **자동 앱 생성 및 설정**: `fly.toml` 파일을 기반으로 Fly.io 앱을 생성하고 초기 설정 진행
- **안전한 비밀키 관리**: `N8N_ENCRYPTION_KEY`를 자동으로 생성하여 Fly.io의 Secrets 기능으로 안전하게 관리
- **원클릭 배포**: 스크립트 실행 한 번으로 배포부터 스케일링까지 모든 과정 완료

## 사전 준비

- [fly.io](https://fly.io/) 계정이 필요합니다.
- (macOS) [Homebrew](https://brew.sh/index_ko)가 설치되어 있으면 `flyctl` 설치 과정이 더 원활합니다.

---

## 🚀 시작하기

### 1. 저장소 복제 (Git Clone)

먼저, 이 저장소를 로컬 컴퓨터로 복제합니다.

```bash
git clone https://github.com/dandacompany/n8n-starter.git
```

### 2. 디렉터리 이동

복제한 폴더로 이동합니다.

```bash
cd n8n-starter/flyio
```

---

## ⚙️ 사용 방법

### 1. 배포 스크립트 실행

이제 설정 파일을 미리 수정할 필요 없이 바로 배포 스크립트를 실행하면 됩니다.

`flyio` 디렉터리에서 스크립트를 실행하면, **배포할 앱의 이름**을 입력하라는 메시지가 표시됩니다. 원하는 고유한 앱 이름을 입력하면 `fly.toml` 파일에 자동으로 반영됩니다.

**참고 (선택 사항): 배포 지역 변경**

기본 배포 지역은 `nrt`(도쿄)로 설정되어 있습니다. 다른 지역(예: `sin`, `sea` 등)에 배포하려면 스크립트 실행 전에 `fly.toml` 파일의 `primary_region` 값을 직접 수정하세요.

```toml
# fly.toml

# app = "your-unique-app-name"  <-- 이 부분은 스크립트 실행 시 입력한 이름으로 자동 변경됩니다.
primary_region = "nrt"            # 배포 지역을 변경하고 싶을 때 이 값을 수정하세요.
```

#### macOS & Linux (`bash`)

1.  **실행 권한 부여 (최초 1회)**
    ```bash
    chmod +x build.sh
    ```

2.  **배포 스크립트 실행**
    ```bash
    ./build.sh
    ```

#### Windows (`PowerShell`)

1.  **실행 정책 변경 (최초 1회)**
    PowerShell을 **관리자 권한**으로 열고, 아래 명령어를 실행하여 스크립트를 실행할 수 있도록 허용합니다.
    ```powershell
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```
    확인 메시지가 나오면 `Y`를 입력하고 Enter를 누릅니다.

2.  **배포 스크립트 실행**
    ```powershell
    ./build.ps1
    ```

스크립트가 실행되면 fly.io 로그인, 앱 이름 설정, 앱 생성, 배포, 스케일링이 자동으로 진행됩니다.

---

## 🔄 앱 업데이트 방법

배포된 n8n 앱을 최신 버전으로 업데이트합니다. 이 스크립트는 `Dockerfile`에 정의된 `n8nio/n8n:latest` 이미지를 가져와 앱을 다시 배포합니다. 데이터는 그대로 유지됩니다.

#### macOS & Linux (`bash`)

1.  **실행 권한 부여 (최초 1회)**
    ```bash
    chmod +x update.sh
    ```
2.  **업데이트 스크립트 실행**
    ```bash
    ./update.sh
    ```

#### Windows (`PowerShell`)

```powershell
./update.ps1
```

---

## 🗑️ 앱 삭제 방법

프로젝트를 완전히 삭제하고 싶을 때 사용합니다. 이 스크립트는 **앱과 관련된 모든 리소스(머신, 볼륨, IP 주소 등)를 영구적으로 삭제**하므로 신중하게 사용해야 합니다.

#### macOS & Linux (`bash`)

1.  **실행 권한 부여 (최초 1회)**
    ```bash
    chmod +x destroy.sh
    ```
2.  **삭제 스크립트 실행**
    ```bash
    ./destroy.sh
    ```

#### Windows (`PowerShell`)

```powershell
./destroy.ps1
```

---

## 기타 유용한 명령어

배포 후 앱을 관리할 때 사용할 수 있는 몇 가지 유용한 `flyctl` 명령어입니다.

- **앱 상태 확인**
  ```bash
  fly status --app <your-app-name>
  ```

- **실시간 로그 확인**
  ```bash
  fly logs --app <your-app-name>
  ```

- **앱 삭제**
  **주의:** 이 명령어는 앱과 관련된 모든 리소스를 영구적으로 삭제합니다.
  ```bash
  fly apps destroy <your-app-name> -y
  ```