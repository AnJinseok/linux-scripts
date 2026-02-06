# Maple 워크스페이스 + 포트 조회/종료 (리눅스 서버용)
# 사용: source /usr/local/workspace/bin/aliases.sh

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

# ----- Maple 웹/API 실행 -----
alias maple-web='cd /usr/local/workspace/maple-front && npm run dev'
alias mweb='cd /usr/local/workspace/maple-front && npm run dev'
alias maple-api='cd /usr/local/workspace/maple-api && ./gradlew bootRun --args="--server.address=0.0.0.0"'
alias mapi='cd /usr/local/workspace/maple-api && ./gradlew bootRun --args="--server.address=0.0.0.0"'

# ----- git pull 배치 -----
alias gitpull='sh /usr/local/workspace/bin/git-pull.sh'
