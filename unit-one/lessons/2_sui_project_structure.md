# Sui 프로젝트 구조

## Sui 모듈과 패키지

- Sui 모듈은 함수와 타입들이 함께 묶인 집합으로, 개발자가 특정 주소에 게시하는 형태입니다.

- Sui 표준 라이브러리는 `0x2` 주소에 게시되며, 사용자가 배포한 모듈은 Sui Move VM에 의해 할당된 임의의 주소에 게시됩니다.

- 모듈은 `module` 키워드로 시작하며, 그 뒤에 모듈 이름과 중괄호가 옵니다. 중괄호 안에 모듈의 내용이 작성됩니다:
    
    ex. hello_world 패키지의 hello_world 모듈
    ```rust
    module hello_world::hello_world {
        // 모듈 내용
    }
    ```

- 게시된 모듈은 Sui에서 변경할 수 없는 불변 객체(Immutable Object)로 취급됩니다. 불변 객체는 절대 변경되거나, 전송되거나, 삭제될 수 없으며, 주인이 없기 때문에 누구나 사용할 수 있습니다.

- Move 패키지는 `Move.toml`이라는 매니페스트 파일을 가진 모듈들의 모음입니다. 즉, 하나의 패키지 안에는 여러 개의 모듈이 포함될 수 있습니다.

## Sui Move 패키지 초기화

다음 Sui CLI 명령어를 사용하여 기본 Sui 패키지를 시작할 수 있습니다:

`sui move new <패키지 이름>`

이 단원에서 다룰 예시로 Hello World 프로젝트를 시작해보겠습니다:

`sui move new hello_world`

이 명령어는 다음과 같은 구조를 생성합니다:
- 프로젝트 루트 폴더 `hello_world`
- `Move.toml` 매니페스트 파일
- Sui Move 스마트 컨트랙트 소스 파일이 포함될 `sources` 하위 폴더

### `Move.toml` 매니페스트 구조

`Move.toml`은 패키지의 매니페스트 파일로, 프로젝트 루트 폴더에 자동으로 생성됩니다.

`Move.toml`은 세 가지 섹션으로 구성됩니다:

- `[package]` 패키지의 이름과 버전 번호를 정의합니다.
- `[dependencies]` 이 패키지가 의존하는 다른 패키지를 정의하며, Sui 표준 라이브러리나 기타 외부 종속성도 여기에 추가됩니다.
- `[addresses]` 패키지 소스 코드에서 주소에 대한 별칭을 정의합니다. 소스 코드에서 특정 주소에 접근할 때 별칭을 사용해서 긴편하게 접근할 수 있습니다.

#### 예시 `Move.toml` 파일

다음은 Sui CLI로 생성된 `hello_world` 패키지의 `Move.toml` 파일입니다:

```rust
[package]
name = "hello_world"
version = "0.0.1"
edition = "2024.beta"


[dependencies]
Sui = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "framework/testnet" }


[addresses]
hello_world =  "0x0"
```

여기서 Sui 표준 라이브러리는 GitHub 저장소를 통해 의존성이 정의되어 있지만, 로컬 바이너리 경로로도 지정할 수 있습니다. 예를 들어, 상대 또는 절대 파일 경로를 사용할 수 있습니다:

```rust
[dependencies]
Sui = { local = "../sui/crates/sui-framework/packages/sui-framework" } 
```

## Sui 모듈과 패키지 이름 규칙

- Sui Move 모듈과 패키지의 이름 규칙은 snake casing(스네이크 케이스)을 사용합니다, 예를 들어, this_is_snake_casing 형식입니다.
- Sui 모듈 이름은 Rust 경로 구분자인 ::를 사용하여 패키지 이름과 모듈 이름을 나눕니다. 예시는 다음과 같습니다:
	1.	unit_one::hello_world - unit_one 패키지의 hello_world 모듈
	2.	capy::capy - capy 패키지의 capy 모듈

- Move의 네이밍 규칙에 대한 자세한 내용은 Move 책의 [스타일 섹션](https://move-language.github.io/move/coding-conventions.html#naming)을 참고하세요.
