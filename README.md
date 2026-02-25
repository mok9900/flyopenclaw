# openclawbeta on Fly.io (Ubuntu 24.04 + KasmVNC + OpenClaw)

이 저장소는 아래 요구사항을 충족하도록 Fly.io 배포 구성을 제공합니다.

- 베이스 이미지: **Ubuntu 24.04 LTS**
- 원격 데스크톱: **KasmVNC**
- AI 환경: **OpenClaw Gateway 부팅 시 자동 시작**
- 브라우저: **Google Chrome 기본 설치**
- Fly 앱 이름: **openclawbeta**
- 머신 스펙: **performance 16 vCPU(AMD EPYC), RAM 131072MB**
- 스토리지: **Volume 500GB SSD**
- 기본 VNC 비밀번호: **17891789**
- 머신/볼륨 지역: **nrt (Tokyo)**

## 지금 상태(앱 이미 생성됨): 배포만 실행하는 복붙 명령어

아래 블록은 **앱/볼륨이 이미 있을 때** 안전하게 배포만 진행합니다.

```bash
# 0) Fly CLI 설치 (Codespaces에 없을 때만)
if ! command -v flyctl >/dev/null 2>&1; then
  curl -L https://fly.io/install.sh | sh
  export FLYCTL_INSTALL="${HOME}/.fly"
  export PATH="${FLYCTL_INSTALL}/bin:${PATH}"
fi

# 1) 로그인
fly auth login

# 2) nrt 리전 확인/설정
fly regions set nrt -a openclawbeta

# 3) 비밀번호 설정(원하면 재설정)
fly secrets set VNC_PASSWORD='17891789' -a openclawbeta

# 4) Fly 원격 빌드/배포 (로컬 Docker 사용 안 함)
fly deploy --remote-only -a openclawbeta

# 5) 머신을 nrt에 고정
fly scale count 1 --region nrt -a openclawbeta

# 6) 확인
fly status -a openclawbeta
fly machine list -a openclawbeta
fly ips list -a openclawbeta
```

## 최초 1회(앱/볼륨이 아직 없을 때) 복붙 명령어

아래는 새로 만들 때만 사용하세요.

```bash
# 0) Fly CLI 설치 (Codespaces에 없을 때만)
if ! command -v flyctl >/dev/null 2>&1; then
  curl -L https://fly.io/install.sh | sh
  export FLYCTL_INSTALL="${HOME}/.fly"
  export PATH="${FLYCTL_INSTALL}/bin:${PATH}"
fi

# 1) 로그인
fly auth login

# 2) 앱 생성
fly apps create openclawbeta

# 3) 앱 리전 nrt 고정
fly regions set nrt -a openclawbeta

# 4) 500GB 볼륨 생성 (nrt)
fly volumes create openclaw_data --region nrt --size 500 --app openclawbeta

# 5) VNC 비밀번호 설정
fly secrets set VNC_PASSWORD='17891789' -a openclawbeta

# 6) Fly 원격 빌드/배포
fly deploy --remote-only -a openclawbeta

# 7) 머신 nrt 고정
fly scale count 1 --region nrt -a openclawbeta

# 8) 확인
fly status -a openclawbeta
fly machine list -a openclawbeta
fly ips list -a openclawbeta
```

> 배포는 항상 `fly deploy --remote-only`로 진행하므로 로컬에서 Docker 이미지 빌드를 하지 않습니다.


## 로그 관련 안내 (질문 주신 Fly 로그)

아래 메시지는 오류가 아니라 **정상 초기화 로그**입니다.

- `Setting up volume 'openclaw_data'`
- `Uninitialized volume 'openclaw_data', initializing...`

즉, 첫 배포에서 볼륨이 비어 있어 Fly가 초기 포맷/마운트를 수행하는 단계입니다.

실시간 로그가 길게 대기되는 것이 불편하면 아래처럼 확인하세요.

```bash
# 최근 로그만 확인(대기 없이 종료)
fly logs -a openclawbeta --no-tail

# 머신 상태 확인
fly machine list -a openclawbeta

# 특정 머신 상세/최근 이벤트
fly machine status <MACHINE_ID> -a openclawbeta
```

## 접속 포트

- `443/tcp` → KasmVNC Web UI (`:8443`)
- `18789/tcp` → OpenClaw Gateway (`:18789`)

## 기본 계정/암호

- 사용자: `kasm`
- VNC 비밀번호 기본값: `17891789`

## 동작 방식

- `supervisord` 가 컨테이너 PID 1으로 실행됩니다.
- `start-kasmvnc.sh` 가 KasmVNC 서버를 시작합니다.
- `start-openclaw.sh` 가 `openclaw gateway --port 18789 --verbose` 를 자동 실행합니다.
- `/data` 는 Fly Volume 에 마운트되어 영속 저장됩니다.
