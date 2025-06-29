#!/bin/bash
set -e

echo "🚀 n8n fly.io 배포 스크립트를 시작합니다."

# 스크립트가 실행된 디렉토리로 이동하여 경로 문제를 해결합니다.
cd "$(dirname "$0")"

# --- 1. flyctl 설치 확인 및 설치 ---
if ! command -v flyctl &> /dev/null; then
    echo "flyctl이 설치되어 있지 않습니다. Homebrew를 사용하여 설치합니다."
    if ! command -v brew &> /dev/null; then
        echo "오류: Homebrew가 설치되어 있지 않습니다. 'flyctl'을 설치할 수 없습니다."
        echo "https://brew.sh/index_ko 에서 Homebrew를 먼저 설치해주세요."
        exit 1
    fi
    brew install flyctl
else
    echo "✅ flyctl이 이미 설치되어 있습니다."
fi

# --- 2. fly.io 로그인 확인 ---
if ! flyctl auth whoami &> /dev/null; then
    echo "⚠️ fly.io에 로그인되어 있지 않습니다."
    echo "브라우저가 열리면 fly.io에 로그인해주세요."
    flyctl auth login
else
    echo "✅ fly.io에 이미 로그인되어 있습니다."
fi

# --- 3. 앱 이름 입력받고 fly.toml에 적용 ---
if [ ! -f "fly.toml" ]; then
    echo "오류: 'fly.toml' 파일을 현재 디렉토리에서 찾을 수 없습니다."
    exit 1
fi

# 사용자에게 앱 이름 입력받기
USER_APP_NAME=""
while [ -z "$USER_APP_NAME" ]; do
  read -p "사용할 앱 이름을 입력하세요: " USER_APP_NAME
  if [ -z "$USER_APP_NAME" ]; then
    echo "앱 이름은 비워둘 수 없습니다. 다시 입력해주세요."
  fi
done

# fly.toml 파일 업데이트
# macOS와 Linux 호환성을 위해 sed 사용
sed -i.bak "s/^\s*app\s*=.*/app = \"$USER_APP_NAME\"/" "fly.toml"
rm -f "fly.toml.bak" # 백업 파일 삭제
echo "✅ fly.toml 파일에 앱 이름 '$USER_APP_NAME'을(를) 적용했습니다."


# --- 4. 앱 이름 및 지역 가져오기 ---
APP_NAME=$(grep -E '^\s*app\s*=' "fly.toml" | cut -d'=' -f2 | tr -d ' ' | tr -d '"' | tr -d "'")
REGION=$(grep -E '^\s*primary_region\s*=' "fly.toml" | cut -d'=' -f2 | tr -d ' ' | tr -d '"' | tr -d "'")

if [ -z "$APP_NAME" ] || [ -z "$REGION" ]; then
    echo "오류: 'fly.toml'에서 앱 이름(app) 또는 지역(primary_region)을 찾을 수 없습니다."
    exit 1
fi
echo "-------------------------------------"
echo "앱 이름: $APP_NAME"
echo "배포 지역: $REGION"
echo "-------------------------------------"


# --- 5. Fly.io 앱 생성 또는 확인 ---
if ! flyctl status --app "$APP_NAME" &> /dev/null; then
    echo "🛬 '$APP_NAME' 앱이 존재하지 않습니다. 새로 생성합니다."
    flyctl launch --name "$APP_NAME" --region "$REGION" --ha=false --no-deploy --copy-config
    echo "✅ 앱 '$APP_NAME' 이(가) 생성되었습니다."
else
    echo "✅ 앱 '$APP_NAME' 이(가) 이미 존재합니다."
fi


# --- 6. N8N_ENCRYPTION_KEY 시크릿 설정 ---
if ! flyctl secrets list --app "$APP_NAME" | grep -q "N8N_ENCRYPTION_KEY"; then
    echo "🔑 N8N_ENCRYPTION_KEY 시크릿이 설정되어 있지 않습니다. 자동으로 생성하여 설정합니다."
    ENCRYPTION_KEY=$(openssl rand -hex 32)
    flyctl secrets set "N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY" --app "$APP_NAME"
    echo "✅ 새로운 N8N_ENCRYPTION_KEY 시크릿이 생성 및 설정되었습니다."
else
    echo "✅ N8N_ENCRYPTION_KEY 시크릿이 이미 설정되어 있습니다."
fi


# --- 7. 앱 배포 ---
echo "📦 앱을 배포합니다. 이 과정은 몇 분 정도 소요될 수 있습니다..."
flyctl deploy --app "$APP_NAME" --dockerfile Dockerfile
echo "✅ 배포가 완료되었습니다."


# --- 8. 스케일링 ---
echo "⚖️ 앱 인스턴스 수를 1로 조정합니다."
flyctl scale count 1 --app "$APP_NAME"
echo "✅ 스케일링이 완료되었습니다."

# --- 9. 앱 정보 표시 ---
echo ""
echo "🎉 모든 배포 과정이 완료되었습니다! 앱 정보를 확인하세요."
flyctl status --app "$APP_NAME"

echo "🔗 앱 URL: https://$APP_NAME.fly.dev"
