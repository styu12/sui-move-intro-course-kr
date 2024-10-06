# 개발 환경 설정

Sui Move 튜토리얼 과정에 오신 것을 환영합니다. 첫 번째 챕터에서는 Sui Move 개발 환경을 설정하는 과정을 안내하고, 간단한 Hello World 프로젝트를 만들어 Sui 환경에 익숙해지는 것이 목표입니다. 

## Sui 바이너리 로컬 설치

1. [운영 체제에 맞는 필수 사항 설치](https://docs.sui.io/build/install#prerequisites)

2. Sui 바이너리 설치
    
    `cargo install --locked --git https://github.com/MystenLabs/sui.git --branch devnet sui`

    설치하려는 대상이 `testnet` 또는 `mainnet`일 경우, 위 명령어의 브랜치(target) 값을 해당 네트워크로 변경하세요.

   *리눅스 사용자: 설치 과정에서 `/tmp` 디렉토리에 빌드 아티팩트가 생성됩니다. 설치 중 `디스크 공간 부족` 관련 문제가 발생하면, tmpfs 크기를 최소 11GB로 확장해야 합니다.*
    ```
   리눅스 시스템에서 tmpfs 사용량을 확인하려면:
   
   df /tmp
   
   tmpfs를 확장하려면 `/etc/fstab` 파일을 수정하여 tmpfs 크기를 20G로 설정하세요:
   
   tmpfs          /tmp        tmpfs   noatime,size=20G,mode=1777   0 0
    ```

4. 바이너리가 성공적으로 설치되었는지 확인:

    `sui --version`

    터미널에 버전 번호가 표시되면 Sui 바이너리가 정상적으로 설치된 것입니다.

## 사전 설치된 Sui 바이너리가 있는 Docker 이미지 사용

1. [Docker 설치](https://docs.docker.com/get-docker/)

2. Sui 공식 Docker 이미지 가져오기

    `docker pull mysten/sui-tools:devnet`

3. Docker 컨테이너 시작 및 접속:

    `docker run --name suidevcontainer -itd mysten/sui-tools:devnet`

    `docker exec -it suidevcontainer bash`

*💡참고: 위의 Docker 이미지가 CPU 아키텍처와 호환되지 않는 경우, 해당 CPU 아키텍처에 맞는 [Rust](https://hub.docker.com/_/rust) Docker 이미지를 사용해 시작하고, 위에서 설명한 대로 Sui 바이너리 및 필수 사항을 설치할 수 있습니다.*

## (선택 사항) VS Code에 Move Analyzer 플러그인 설정

1. VS Marketplace에서 [Move Analyzer 플러그인](https://marketplace.visualstudio.com/items?itemName=move.move-analyzer) 설치

2. Sui 스타일 지갑 주소와의 호환성 추가:

    `cargo install --git https://github.com/move-language/move move-analyzer --features "address20"`

## Sui CLI 기본 사용법

[참고 페이지](https://docs.sui.io/build/cli-client)

### 초기화
- `Sui 풀 노드 서버에 연결하시겠습니까?`에 `Y`를 입력하고 `Enter`를 눌러 Sui Devnet 풀 노드에 기본 연결
- 키 스킴 선택에서 `0`을 입력하여 [`ed25519`](https://ed25519.cr.yp.to/) 선택

### 네트워크 관리

- 네트워크 변경: `sui client switch --env [네트워크 별칭]`
- 기본 네트워크 별칭: 
    - localnet: http://0.0.0.0:9000
    - devnet: https://fullnode.devnet.sui.io:443
- 현재 모든 네트워크 별칭 목록 보기: `sui client envs`
- 새 네트워크 별칭 추가: `sui client new-env --alias <ALIAS> --rpc <RPC>`
    - 예시: `sui client new-env --alias testnet --rpc https://fullnode.testnet.sui.io:443`를 사용해 testnet 별칭 추가

### 활성 주소 및 가스 객체 확인

- 키 스토어에 있는 현재 주소 확인: `sui client addresses`
- 활성 주소 확인: `sui client active-address`
- 관리 중인 모든 가스 객체 목록 보기: `sui client gas`

## Devnet 또는 Testnet Sui 토큰 얻기

1. [Sui Discord 참여](https://discord.gg/sui)
2. 인증 절차 완료
3. Devnet 토큰은 [`#devnet-faucet`](https://discord.com/channels/916379725201563759/971488439931392130) 채널에서, Testnet 토큰은 [`#testnet-faucet`](https://discord.com/channels/916379725201563759/1037811694564560966) 채널에서 요청
4. `!faucet <지갑 주소>` 명령어 입력