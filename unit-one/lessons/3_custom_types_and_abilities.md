# 커스텀 타입과 능력

이 섹션에서는 Hello World 예제 컨트랙트를 단계별로 작성하면서 Sui Move의 기본 개념인 커스텀 타입과 능력(Abilities)을 설명하겠습니다.

## 패키지 초기화

(이전 섹션을 건너뛰었다면) [Sui 바이너리를 설치](./1_set_up_environment.md#sui-바이너리-로컬-설치)한 후, 다음 명령어로 Hello World Sui 패키지를 초기화할 수 있습니다:

`sui move new hello_world`

## 컨트랙트 소스 파일 생성

선호하는 편집기를 사용하여 `sources` 하위 폴더에 `hello.move`라는 Move 스마트 컨트랙트 소스 파일을 생성하세요.

그리고 다음과 같이 빈 모듈을 작성합니다:

```rust
module hello_world::hello_world {
    // 모듈 내용
}
```

### 임포트 구문

Move에서는 모듈을 주소로 직접 임포트할 수 있지만, 코드 가독성을 높이기 위해 use 키워드를 사용하여 임포트를 정리할 수 있습니다.

```rust
use <Address/Alias>::<ModuleName>;
```

예시에서는 다음 모듈들을 임포트해야 합니다:

```rust
use std::string;
use sui::object::{Self, UID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};
```

## 커스텀 타입

Sui Move에서 구조체는 키-값 쌍을 포함하는 커스텀 타입으로, 키는 속성의 이름이며 값은 저장되는 데이터를 나타냅니다. struct 키워드를 사용하여 정의되며, 구조체는 최대 4개의 능력(ability)을 가질 수 있습니다.

### 능력 (Abilities)

능력은 Sui Move에서 타입이 컴파일러 수준에서 어떻게 동작할지를 정의하는 키워드입니다.

능력은 Sui Move에서 객체의 동작 방식을 정의하는 중요한 요소입니다. Sui Move에서 각기 다른 능력의 조합은 고유한 디자인 패턴을 형성합니다. 이 튜토리얼 과정 동안 능력과 그 사용 방법을 계속해서 학습할 것입니다.

지금은 Sui Move에 4가지 능력이 있다는 것만 기억하세요:

- **copy**: 값을 복사(또는 값으로 복제)할 수 있음
- **drop**: 범위(scope)가 끝날 때 값을 삭제할 수 있음
- **key**: 글로벌 스토리지에서 키로 사용할 수 있음
- **store**: 글로벌 스토리지의 구조체(object) 내에 값을 저장할 수 있음

#### 자산 (Assets)

key와 store 능력을 가진 커스텀 타입은 Sui Move에서 **자산(Asset)**으로 간주됩니다. 자산은 글로벌 저장소에 저장되며 계정 간에 전송될 수 있습니다. 대표적인 예로 COIN 타입은 key와 store 능력을 가진 타입(자산)이기 때문에 계정 간에 코인을 주고 받을 수 있는 것입니다.

### Hello World 커스텀 타입

Hello World 예제에서 객체(Object)는 다음과 같이 정의됩니다:

```rust
/// HelloWorldObject 구조체를 정의합니다.
/// key, store 능력을 가지고 있기 때문에 글로벌 스토리지에서 Sui Object로 사용됩니다.
public struct HelloWorldObject has key, store {
  	id: UID,
  	text: string::String
}
```

여기서 UID는 Sui 프레임워크 타입(sui::object::UID)으로, 객체(Object)의 전역 고유 ID를 정의합니다. key 능력을 가진 커스텀 타입은 반드시 ID 필드를 포함해야 합니다. key 능력을 가지면서 ID 필드를 포함한다는 것은 곧, 해당 커스텀 타입은 Sui 글로벌 스토리지에서 Object로 간주된다는 뜻입니다. 

