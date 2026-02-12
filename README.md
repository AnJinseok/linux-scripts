# linux-scripts

리눅스·서버 관리용 쉘 스크립트 모음. **Linux 전용**이며, 기능별로 디렉터리를 나눠 두었습니다.

---

## 실행·작업 순서

### 로컬(Windows 등)에서 커밋·푸시할 때

1. 스크립트 수정 후 **실행 비트를 저장소에 기록** (한 번만 해 두면 이후 pull 시에도 유지됨)
   ```bash
   cd linux-scripts
   bash git/record-executable-bit.sh
   ```
2. `git add` → `git commit` → `git push`

### 서버에서 pull 후

1. **일괄 pull** (여러 저장소 한 번에, pull 후 `.sh` 실행 권한 자동 복구)
   ```bash
   cd /usr/local/workspace/linux-scripts
   ./git/git-pull.sh
   ```
2. 필요하면 `source shell/aliases.sh` 등으로 alias 재로드

### 크론 스케줄 적용·변경할 때

1. `cron/crontab` 파일을 편집해 항목 추가/수정
2. 서버에서 **crontab 전체 적용** (기존 crontab 백업 후 덮어씀)
   ```bash
   cd /usr/local/workspace/linux-scripts
   sudo bash cron/install-crontab.sh
   ```
3. 확인: `crontab -l`

### 현재 크론 스케줄 (cron/crontab 기준)

| 실행 시각 | 작업 | 비고 |
|-----------|------|------|
| 매일 09:00 | nginx 로그 DB 접속 검사 | 결과: `/var/reports/nginx-db-check/` |

---

## 디렉터리 구조

```
linux-scripts/
├── README.md
├── wifi/              # Wi-Fi 연결/해제
│   └── wifi-connect.sh
├── system/            # 패키지 설치, 시스템 유틸
│   └── install_from_list.sh
├── shell/             # alias·실행 스크립트 (서버용)
│   ├── aliases.sh
│   ├── check-nginx-db-access.sh
│   ├── start-maple-api-screen.sh
│   └── start-maple-front-screen.sh
├── git/               # git 배치·권한
│   ├── git-pull.sh
│   └── record-executable-bit.sh
└── cron/              # 크론 항목 모음·적용
    ├── crontab
    ├── install-crontab.sh
    └── .gitignore
```

| 디렉터리 | 설명 |
|----------|------|
| **wifi/** | Wi-Fi 연결/해제 (wpa_supplicant) |
| **system/** | apt 패키지 일괄 설치 등 |
| **shell/** | 포트 조회/종료, Maple alias·screen, nginx 로그 검사 등 |
| **git/** | 여러 저장소 일괄 `git pull`, pull 후 실행 권한 복구, 실행 비트 기록 |
| **cron/** | 크론 항목 모음(`crontab`), 전체 적용(`install-crontab.sh`) |

---

## 요구 사항

- **Linux**
- Bash
- 일부 스크립트는 `sudo` 권한 필요

---

## 사용 방법

1. 저장소 클론 후 해당 디렉터리로 이동
2. `chmod +x 스크립트명.sh` 로 실행 권한 부여
3. `./스크립트명.sh` 또는 파일 상단 주석 참고

---

## wifi/

Wi-Fi 연결/해제 (wpa_supplicant).

### wifi-connect.sh

| 동작 | 사용법 |
|------|--------|
| 연결 끊기 | `sudo ./wifi-connect.sh disconnect` |
| 연결하기 | `sudo ./wifi-connect.sh connect "SSID" "비밀번호"` |

환경변수: `WIFI_IFACE` (기본 `wlp1s0`), `WPA_CONF_DIR` (기본 `/tmp`)

---

## system/

### install_from_list.sh

패키지 목록 파일을 읽어 `apt install` 로 일괄 설치.  
인자 생략 시 `./manual-packages.list` 사용.

```bash
./install_from_list.sh
./install_from_list.sh /path/to/my-packages.list
```

생성 파일: `*.resolved.*.list`, `*.missing.*.list`, `*.install.*.log`

---

## shell/

서버에 배치 후 `source` 해서 사용하는 alias·함수 및 Maple 실행 스크립트.

### aliases.sh

- **findport / killport / killport9** — 포트 조회·종료
- **ws, wsa, wsf** — 워크스페이스 경로
- **mweb, mapi** — 프론트 dev / API bootRun
- **screen** — sl, sr, sra, sk, ska 등 (세션 목록·접속·종료)
- **gitpull** — git-pull.sh 실행

```bash
source /path/to/shell/aliases.sh
# 도움말
ws-help
```

### start-maple-api-screen.sh / start-maple-front-screen.sh

`screen` 세션으로 Maple API 또는 Front 개발 서버를 백그라운드 실행.  
스크립트 내 경로를 서버 환경에 맞게 수정한 뒤 사용하세요.

```bash
chmod +x start-maple-api-screen.sh start-maple-front-screen.sh
./start-maple-api-screen.sh
./start-maple-front-screen.sh
```

### check-nginx-db-access.sh

`/var/log/nginx` 의 access/error 로그에서 DB·관리 도구 접속 시도 패턴 검사. 결과는 화면과 파일에 동시 출력.

- 기본 저장: 현재 디렉터리 `nginx-db-access-check-YYYYMMDD-HHMMSS.txt`
- 환경변수: `NGINX_DB_CHECK_DIR`, `NGINX_DB_CHECK_OUTPUT` (스크립트 상단 주석 참고)

```bash
sudo bash shell/check-nginx-db-access.sh
```

---

## git/

### git-pull.sh

스크립트 내 `WORKSPACE` 및 배치할 저장소 경로를 수정한 뒤, 여러 저장소에서 순서대로 `git pull` 실행.  
linux-scripts pull 직후 `shell/*.sh`, `git/*.sh`, `cron/*.sh` 에 대해 `chmod +x` 로 실행 권한을 복구함.

```bash
./git-pull.sh
```

### record-executable-bit.sh

저장소에 `.sh` 파일의 실행 비트를 기록. **로컬에서 한 번만 실행** 후 커밋·푸시하면, 이후 서버에서 pull 해도 실행 권한이 유지됨.

```bash
bash git/record-executable-bit.sh
# 이어서 git add, commit, push
```

---

## cron/

크론 항목을 한 파일에 모아 두고, 그 파일 전체를 crontab에 적용하는 방식.

### crontab

크론 항목을 모아 두는 파일. 항목 추가·수정은 이 파일만 편집하면 됨.

### install-crontab.sh

`cron/crontab` 내용 전체를 현재 사용자 crontab으로 적용. 적용 전 기존 crontab은 `cron/crontab.backup.YYYYMMDD-HHMMSS` 로 백업됨.

```bash
sudo bash cron/install-crontab.sh
```

---

## 추후 추가 예정

- 네트워크 진단/설정
- 로그 정리·백업/복원
- 기타 서버 관리 유틸
