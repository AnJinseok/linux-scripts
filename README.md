# linux-scripts

리눅스·서버 관리용 쉘 스크립트 모음. **Linux 전용**이며, 기능별로 디렉터리를 나눠 두었습니다.

## 디렉터리 구조

```
linux-scripts/
├── README.md
├── wifi/              # Wi-Fi 연결/해제
│   └── wifi-connect.sh
├── system/            # 패키지 설치, 시스템 유틸
│   └── install_from_list.sh
├── shell/             # source 로 쓸 alias/함수 (서버용)
│   └── aliases.sh
├── git/               # git 배치 작업
│   └── git-pull.sh
└── ...
```

- **wifi/** — Wi-Fi 관련
- **system/** — apt 패키지 일괄 설치 등
- **shell/** — 포트 조회/종료, 워크스페이스 alias (서버에 배치 후 `source` 사용)
- **git/** — 여러 저장소 일괄 `git pull` 등

## 요구 사항

- **Linux** (다른 OS에서는 실행하지 않음)
- Bash
- 필요한 스크립트는 `sudo` 권한 필요할 수 있음

## 사용 방법

1. 저장소 클론 후 해당 디렉터리로 이동
2. 실행할 스크립트에 `chmod +x 스크립트명.sh` 로 실행 권한 부여
3. 사용법은 `./스크립트명.sh` (인자 없이 실행) 또는 파일 상단 주석 참고

---

## wifi/

Wi-Fi 연결/해제 (wpa_supplicant). NetworkManager가 인터페이스를 unavailable로 볼 때 사용.

### wifi-connect.sh

| 동작     | 입력할 것 |
|----------|------------|
| 연결 끊기 | `disconnect` (추가 인자 없음) |
| 연결하기 | `connect` + `"공유기 이름(SSID)"` + `"비밀번호"` (따옴표 권장) |

**예시**

```bash
cd wifi
chmod +x wifi-connect.sh

sudo ./wifi-connect.sh disconnect
sudo ./wifi-connect.sh connect "MyHomeWiFi" "mypassword123"
```

**환경변수:** `WIFI_IFACE` (기본 `wlp1s0`), `WPA_CONF_DIR` (기본 `/tmp`)

---

## system/

Ubuntu(apt) 패키지 관리·시스템 유틸.

### install_from_list.sh

패키지 목록 파일을 읽어, 현재 OS에서 설치 가능한 것만 필터한 뒤 `apt install` 로 일괄 설치.  
설치 가능 목록·미존재 목록·로그를 타임스탬프 파일로 남깁니다.

**입력할 것**

- `[list_file]` — 한 줄에 패키지 이름 하나. `#` 주석·빈 줄 허용. 생략 시 `./manual-packages.list` 사용.

**예시**

```bash
cd system
chmod +x install_from_list.sh

# 목록 파일이 있을 때 (기본: ./manual-packages.list)
./install_from_list.sh

# 다른 목록 파일 지정
./install_from_list.sh /path/to/my-packages.list
```

**생성 파일** (목록 파일이 있는 디렉터리 기준)

- `manual-packages.resolved.<ts>.list` — 설치한 패키지 목록
- `manual-packages.missing.<ts>.list` — 저장소에 없던 패키지
- `manual-packages.install.<ts>.log` — 설치 로그

---

## shell/

서버에서 `source` 해서 쓰는 alias·함수 (포트 조회/종료, Maple 워크스페이스 등).  
서버에 배치할 때는 예: `/usr/local/workspace/bin/` 에 두고 `source /usr/local/workspace/bin/aliases.sh` 로 로드합니다.

### aliases.sh

- **findport \<포트>** — 해당 포트 사용 프로세스 표시 (`ss`)
- **killport \<포트>** — 해당 포트 프로세스 종료
- **killport9 \<포트>** — 강제 종료 (`kill -9`)
- **maple-web / mweb** — maple-front 로 이동 후 `npm run dev`
- **maple-api / mapi** — maple-api 로 이동 후 `./gradlew bootRun`
- **gitpull** — `git-pull.sh` 실행 (여러 저장소 일괄 pull)

**사용**

```bash
source /path/to/shell/aliases.sh
# 또는 배치 후
source /usr/local/workspace/bin/aliases.sh
```

---

## git/

여러 저장소에서 `git pull` 을 순서대로 실행하는 배치 스크립트.

### git-pull.sh

스크립트 안 `WORKSPACE` 와 "배치 작업" 구간을 vi 등으로 수정해, 필요한 경로/저장소를 넣어 사용합니다.

**예시**

```bash
cd git
chmod +x git-pull.sh
./git-pull.sh
```

서버에 둘 때는 예: `/usr/local/workspace/bin/git-pull.sh` 에 두고, `aliases.sh` 의 `gitpull` 로 실행할 수 있습니다.

---

## 추후 추가 예정

- 네트워크 진단/설정 스크립트
- 로그 정리·백업/복원 스크립트
- 기타 서버 관리용 유틸

새 스크립트는 용도에 맞는 **기능별 디렉터리**를 만들어 그 안에 두면 됩니다.
