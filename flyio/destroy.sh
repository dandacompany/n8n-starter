#!/bin/bash
set -e

echo "⚠️ 경고: 이 스크립트는 fly.io 앱과 관련된 모든 리소스(머신, 볼륨, IP 등)를 영구적으로 삭제합니다."
echo "이 작업은 되돌릴 수 없습니다. 계속 진행하기 전에 신중하게 결정해주세요."
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

echo "삭제할 앱의 이름: $APP_NAME"
echo ""

# 사용자에게 삭제 확인 요청
read -p "정말로 '$APP_NAME' 앱을 삭제하시겠습니까? 확인을 위해 'yes'를 입력하세요: " confirmation

if [[ "$confirmation" != "yes" ]]; then
    echo "삭제 작업이 취소되었습니다."
    exit 0
fi

echo ""
echo "🗑️ '$APP_NAME' 앱과 모든 관련 리소스를 삭제합니다..."

# fly.io 앱 삭제 명령어 실행
flyctl apps destroy "$APP_NAME" -y

echo "✅ '$APP_NAME' 앱이 성공적으로 삭제되었습니다." 