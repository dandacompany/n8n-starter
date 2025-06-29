#!/bin/bash
set -e

echo "🚀 n8n 앱을 최신 버전으로 업데이트합니다."
echo "Dockerfile에 명시된 'n8nio/n8n:latest' 이미지를 사용하여 재배포를 시도합니다."
echo ""

# 스크립트가 실행된 디렉토리로 이동하여 경로 문제를 해결합니다.
cd "$(dirname "$0")"

# fly.toml 파일 존재 확인
if [ ! -f "fly.toml" ]; then
    echo "오류: 'fly.toml' 파일을 현재 디렉토리에서 찾을 수 없습니다."
    exit 1
fi

# fly.toml에서 앱 이름 읽기
APP_NAME=$(grep -E '^\s*app\s*=' "fly.toml" | cut -d'=' -f2 | tr -d ' ' | tr -d '"' | tr -d "'")

if [ -z "$APP_NAME" ]; then
    echo "오류: 'fly.toml'에서 앱 이름(app)을 찾을 수 없습니다."
    exit 1
fi

echo "업데이트할 앱의 이름: $APP_NAME"
echo ""

# 사용자에게 업데이트 확인 요청
read -p "정말로 '$APP_NAME' 앱을 최신 이미지로 업데이트하시겠습니까? (yes/no): " confirmation

if [[ "$confirmation" != "yes" ]]; then
    echo "업데이트 작업이 취소되었습니다."
    exit 0
fi

echo ""
echo "📦 앱을 재배포하여 업데이트합니다. 이 과정은 몇 분 정도 소요될 수 있습니다..."

# fly.io 앱 재배포 명령어 실행
# Dockerfile을 기반으로 새로운 이미지를 빌드하고, 기존 머신에 업데이트된 이미지를 배포합니다.
flyctl deploy --app "$APP_NAME" --dockerfile Dockerfile

echo ""
echo "✅ 업데이트 배포가 완료되었습니다."
echo "앱의 최종 상태를 확인합니다."
flyctl status --app "$APP_NAME" 