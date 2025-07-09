# n8n-starter: Fly.io 배포 및 Docker 로컬 실행

이 프로젝트는 [n8n](https://n8n.io/)을 [fly.io](https://fly.io/)에 자동으로 배포하거나, Puppeteer가 포함된 Docker 환경에서 로컬로 실행하기 위한 방법을 제공합니다.

## 목차

- [Fly.io에 n8n 자동 배포](#flyio에-n8n-자동-배포)
- [Docker로 Puppeteer 포함 n8n 실행](#docker로-puppeteer-포함-n8n-실행)

---

## Fly.io에 n8n 자동 배포

이 섹션은 [n8n](https://n8n.io/)을 [fly.io](https://fly.io/)에 자동으로 배포하고 설정하기 위한 스크립트를 설명합니다. macOS, Linux, Windows 환경을 모두 지원합니다.

### 주요 기능

- **플랫폼별 배포 자동화**: macOS/Linux용 `build.sh`와 Windows용 `build.ps1` 스크립트 제공
- **`flyctl` 자동 설치**: `flyctl`이 설치되어 있지 않은 경우 스크립트가 자동으로 설치
- **자동 앱 생성 및 설정**: `fly.toml` 파일을 기반으로 Fly.io 앱을 생성하고 초기 설정 진행
- **안전한 비밀키 관리**: `N8N_ENCRYPTION_KEY`를 자동으로 생성하여 Fly.io의 Secrets 기능으로 안전하게 관리
- **원클릭 배포**: 스크립트 실행 한 번으로 배포부터 스케일링까지 모든 과정 완료

### 사전 준비

- [fly.io](https://fly.io/) 계정이 필요합니다.
- (macOS) [Homebrew](https://brew.sh/index_ko)가 설치되어 있으면 `flyctl` 설치 과정이 더 원활합니다.

### 시작하기

1.  **저장소 복제 (Git Clone)**
    ```bash
    git clone https://github.com/dandacompany/n8n-starter.git
    cd n8n-starter
    ```

2.  **디렉터리 이동**
    ```bash
    cd flyio
    ```

### 사용 방법

`flyio` 디렉터리에서 스크립트를 실행하면 **배포할 앱의 이름**을 입력하라는 메시지가 표시됩니다. 원하는 고유한 앱 이름을 입력하면 `fly.toml` 파일에 자동으로 반영됩니다.

**참고 (선택 사항): 배포 지역 변경**

기본 배포 지역은 `nrt`(도쿄)로 설정되어 있습니다. 다른 지역(예: `sin`, `sea` 등)에 배포하려면 스크립트 실행 전에 `fly.toml` 파일의 `primary_region` 값을 직접 수정하세요.

```toml
# fly.toml
primary_region = "nrt"
```

#### macOS & Linux (`bash`)
1.  **실행 권한 부여 (최초 1회)**: `chmod +x build.sh`
2.  **배포 스크립트 실행**: `./build.sh`

#### Windows (`PowerShell`)
1.  **실행 정책 변경 (최초 1회, 관리자 권한)**: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
2.  **배포 스크립트 실행**: `./build.ps1`

### 앱 업데이트 방법 (`flyio` 디렉터리)
- **macOS & Linux**: `./update.sh`
- **Windows**: `./update.ps1`

### 앱 삭제 방법 (`flyio` 디렉터리)
**주의**: 이 명령어는 앱과 관련된 모든 리소스를 영구적으로 삭제합니다.
- **macOS & Linux**: `./destroy.sh`
- **Windows**: `./destroy.ps1`

---

## Docker로 Puppeteer 포함 n8n 실행

이 섹션은 `n8n-nodes-puppeteer` 커뮤니티 노드가 포함된 n8n을 Docker를 사용하여 로컬 환경에서 실행하는 방법을 설명합니다. `docker-compose`를 사용하여 간단하게 실행할 수 있습니다.

### 주요 기능

- **Puppeteer 통합**: `n8n-nodes-puppeteer`가 사전 설치되어 있어 웹 자동화 및 스크래핑 워크플로우를 바로 생성할 수 있습니다.
- **간단한 실행**: `docker-compose` 명령어로 한 번에 빌드하고 실행할 수 있습니다.
- **데이터 영속성**: n8n 데이터가 로컬 폴더에 저장되어 컨테이너를 다시 시작해도 데이터가 유지됩니다.

### 사전 준비

- [Docker](https://www.docker.com/products/docker-desktop/) 및 `docker-compose`가 설치되어 있어야 합니다.

### 시작하기

1.  **저장소 복제 (Git Clone)**
    ```bash
    git clone https://github.com/dandacompany/n8n-starter.git
    cd n8n-starter
    ```

2.  **디렉터리 이동**
    Puppeteer 설정이 있는 폴더로 이동합니다.
    ```bash
    cd docker/pupeteer
    ```

### 사용 방법

아래 명령어를 실행하면 Docker 이미지를 빌드하고 컨테이너를 백그라운드에서 시작합니다.

```bash
docker-compose up --build -d
```

이제 웹 브라우저에서 `http://localhost:5679`로 접속하여 n8n 에디터를 사용할 수 있습니다.

### n8n 중지 및 재시작

- **중지**: 컨테이너를 중지하려면 다음 명령어를 사용합니다. 데이터는 보존됩니다.
  ```bash
  docker-compose down
  ```

- **재시작**: 다시 시작하려면 `up` 명령어를 사용합니다.
  ```bash
  docker-compose up -d
  ```

### 완전히 삭제하기

컨테이너, 네트워크 및 **로컬에 저장된 n8n 데이터 볼륨까지 모두 삭제**하려면 다음 명령어를 사용하세요.

**주의**: 이 명령어는 `docker/pupeteer/n8n` 폴더의 모든 데이터를 영구적으로 삭제합니다.
```bash
docker-compose down -v
```

### 설정 참고 (`docker-compose.yml`)

`docker-compose.yml` 파일에는 다음과 같은 주요 설정이 포함되어 있습니다.

- **`build: .`**: 현재 디렉터리의 `Dockerfile`을 사용하여 이미지를 빌드합니다.
- **`ports: - "5679:5678"`**: 호스트의 5679 포트를 컨테이너의 5678 포트로 연결합니다.
- **`cap_add: - SYS_ADMIN`**: Docker 내부에서 Puppeteer가 사용하는 Chromium을 문제없이 실행하기 위해 필요한 시스템 권한을 부여합니다.
- **`volumes: - ./n8n:/home/node/.n8n`**: n8n의 데이터를 현재 디렉터리 아래의 `n8n` 폴더에 저장하여 영속성을 확보합니다.