# Maple 워크스페이스 + 포트 조회/종료 (리눅스 서버용)
# 사용: source /usr/local/workspace/bin/aliases.sh
# 등록된 명령어 보기: ws-help (또는 maple-help)

ws-help() {
    echo "=== Maple 워크스페이스 alias/함수 (linux-scripts/shell/aliases.sh) ==="
    echo ""
    echo "  [경로]  ws, workspace  → /usr/local/workspace"
    echo "          wsl            → linux-scripts"
    echo "          wsa            → maple-api"
    echo "          wsf            → maple-front"
    echo "          wsm            → maple-misc-scripts"
    echo ""
    echo "  [포트]  findport 8080   → 포트 사용 프로세스 표시"
    echo "          killport 8080   → 포트 프로세스 종료"
    echo "          killport9 8080  → 강제 종료"
    echo ""
    echo "  [실행]  mweb, maple-web → 프론트 dev"
    echo "          mapi, maple-api → API bootRun (foreground)"
    echo ""
    echo "  [screen] sl, screenls   → 세션 목록"
    echo "           sr [이름]      → 세션 접속"
    echo "           sra            → maple-api 세션 접속"
    echo "           sd [이름]      → 떼고 접속"
    echo "           so, out        → 지금 세션에서 나가기 (떼기)"
    echo "           sk [이름]      → 세션 강제 종료 (kill)"
    echo "           ska            → maple-api 세션 종료"
    echo ""
    echo "  [기타]  gitpull         → git-pull.sh 실행"
    echo ""
}
alias maple-help='ws-help'

# ----- 포트 번호로 찾기 / 종료 (인자로 포트번호) -----
# 사용: findport 8080   → 8080 포트 사용 중인 프로세스 표시
# 사용: killport 8080   → 8080 포트 사용 프로세스 종료
findport() {
    if [ -z "$1" ]; then echo "사용법: findport <포트번호>"; return 1; fi
    ss -tlnp | grep ":$1 "
}
killport() {
    if [ -z "$1" ]; then echo "사용법: killport <포트번호>"; return 1; fi
    local pid
    pid=$(lsof -t -i :"$1" 2>/dev/null)
    if [ -z "$pid" ]; then echo "포트 $1 사용 중인 프로세스 없음"; return 1; fi
    kill $pid && echo "PID $pid (포트 $1) 종료됨"
}
killport9() {
    if [ -z "$1" ]; then echo "사용법: killport9 <포트번호> (강제 종료)"; return 1; fi
    local pid
    pid=$(lsof -t -i :"$1" 2>/dev/null)
    if [ -z "$pid" ]; then echo "포트 $1 사용 중인 프로세스 없음"; return 1; fi
    kill -9 $pid && echo "PID $pid (포트 $1) 강제 종료됨"
}

# ----- 워크스페이스 경로 (cd) -----
# 사용: ws   → /usr/local/workspace
# 사용: wsl  → linux-scripts
# 사용: wsa  → maple-api
# 사용: wsf  → maple-front
# 사용: wsm  → maple-misc-scripts
alias ws='cd /usr/local/workspace'
alias workspace='cd /usr/local/workspace'
alias wsl='cd /usr/local/workspace/linux-scripts'
alias wsa='cd /usr/local/workspace/maple-api'
alias wsf='cd /usr/local/workspace/maple-front'
alias wsm='cd /usr/local/workspace/maple-misc-scripts'

# ----- Maple 웹/API 실행 -----
alias maple-web='cd /usr/local/workspace/maple-front && npm run dev'
alias mweb='cd /usr/local/workspace/maple-front && npm run dev'
alias maple-api='cd /usr/local/workspace/maple-api && ./gradlew bootRun --args="--server.address=0.0.0.0"'
alias mapi='cd /usr/local/workspace/maple-api && ./gradlew bootRun --args="--server.address=0.0.0.0"'

# ----- screen (세션 목록/접속/떼기) -----
# 사용: sl          → 세션 목록
# 사용: sr [이름]   → 세션 접속 (이름 없으면 첫 번째)
# 사용: sra         → maple-api 세션 접속
# 사용: sd [이름]   → 다른 터미널에서 붙어 있으면 떼고 내가 접속
# 사용: so / out    → 지금 세션에서 나가기 (떼기, Ctrl+A D 와 동일)
# 사용: sk [이름] / screenkill [이름] → 세션 강제 종료. ska → maple-api 세션 종료
alias sl='screen -ls'
alias screenls='screen -ls'
alias sr='screen -r'
alias screenr='screen -r'
alias sra='screen -r maple-api'
alias sd='screen -d -r'
alias so='screen -d'
alias out='screen -d'
alias ska='screen -X -S maple-api quit'
alias skf='screen -X -S maple-front quit'

screenkill() {
    if [ -z "$1" ]; then echo "사용법: screenkill <세션이름>  (목록: sl)"; return 1; fi
    screen -X -S "$1" quit && echo "세션 '$1' 종료됨"
}
sk() { screenkill "$@"; }

# ----- git pull 배치 -----
alias gitpull='sh /usr/local/workspace/bin/git-pull.sh'
