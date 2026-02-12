#!/usr/bin/env bash
# 프론트 개발 서버를 screen 세션에서 실행 (MobaXterm/SSH 끊어도 유지)
# 사용: ./start-maple-front-screen.sh (linux-scripts/shell/ 에서) 또는 경로 지정
# 나가기(세션 유지): Ctrl+A 누른 다음 D
# 다시 들어가기: screen -r maple-front
#
# 경로: MAPLE_WORKSPACE_ROOT 환경변수 또는 이 스크립트 기준 ../.. 에서 maple-front 탐색

SESSION_NAME="maple-front"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_ROOT="${MAPLE_WORKSPACE_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
PROJECT_ROOT="$WORKSPACE_ROOT/maple-front"
# 프론트 로그 파일 (tail -f 로 보려면 여기 경로 사용)
FRONT_LOG_DIR="${MAPLE_FRONT_LOG_DIR:-$PROJECT_ROOT/logs}"
FRONT_LOG_FILE="$FRONT_LOG_DIR/front.log"

if [[ ! -d "$PROJECT_ROOT" ]]; then
    echo "오류: maple-front 폴더를 찾을 수 없습니다. (기대 경로: $PROJECT_ROOT)"
    echo "MAPLE_WORKSPACE_ROOT 환경변수로 워크스페이스 루트를 지정하세요."
    exit 1
fi

mkdir -p "$FRONT_LOG_DIR"

if screen -list | grep -q "$SESSION_NAME"; then
    echo "세션 '$SESSION_NAME' 이(가) 이미 있습니다. 연결합니다."
    echo "로그 파일 보기: tail -f $FRONT_LOG_FILE"
    screen -r "$SESSION_NAME"
else
    echo "세션 '$SESSION_NAME' 에서 프론트 서버를 시작합니다. (나가기: Ctrl+A, D)"
    echo "로그 파일: $FRONT_LOG_FILE (tail -f 로 확인 가능)"
    screen -S "$SESSION_NAME" bash -c "cd \"$PROJECT_ROOT\" && npm run dev 2>&1 | tee -a \"$FRONT_LOG_FILE\"; exec bash"
fi
