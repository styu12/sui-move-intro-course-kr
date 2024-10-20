# 함수

이번 섹션에서는 Sui Move에서 함수의 개념을 소개하고, Hello World 예제의 일부로 첫 번째 Sui Move 함수를 작성해 보겠습니다.

## 함수 가시성

Sui Move 함수에는 세 가지 가시성 유형이 있습니다:

- **private**: 동일한 모듈 내의 함수들만 접근할 수 있습니다. 함수의 기본 가시성으로 별도로 가시성을 지정하지 않으면 private 함수입니다. 
- **public**: 동일한 모듈 내 함수와 다른 모듈에 정의된 함수들이 접근할 수 있습니다.
- **public(package)**: 동일한 패키지 내 모듈의 함수들만 접근할 수 있습니다.

## 반환 값

함수의 반환 타입은 함수 매개변수 뒤에 콜론을 붙여 함수 시그니처에 지정합니다.

세미콜론이 없는 함수의 마지막 줄은 반환 값이 됩니다.

예시: `a + b` 를 반환합니다. 

```rust
    public fun addition (a: u8, b: u8): u8 {
        a + b    
    }
```

<!--
## 엔트리 함수

Sui Move에서 엔트리 함수는 트랜잭션으로 호출할 수 있는 함수입니다. 이러한 함수는 세 가지 요구 사항을 충족해야 합니다:

- `entry` 키워드로 표시되어야 합니다.
- 반환 값이 없어야 합니다.
- (선택 사항) 마지막 매개변수로 `TxContext` 타입의 가변 참조를 가질 수 있습니다.

-->

## 트랜잭션 컨텍스트

트랜잭션을 통해 직접 호출되는 함수는 일반적으로 마지막 매개변수로 `TxContext` 인스턴스를 가집니다. 
이 매개변수는 Sui Move VM에서 자동으로 설정되며, 사용자가 함수 호출 시 따로 지정할 필요는 없습니다.

`TxContext` 객체는 현재 실행되고 있는 트랜잭션에 대한 [필수 정보](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/tx_context.move)를 포함합니다. 
예를 들어 발신자의 주소, 트랜잭션의 digest ID, 트랜잭션의 epoch 등이 이에 해당합니다.

## mint 함수 생성

Hello World 예제에서 민팅(minting) 함수를 다음과 같이 정의할 수 있습니다:

```rust
    public fun mint(ctx: &mut TxContext) {
        let object = HelloWorldObject {
            id: object::new(ctx),
            text: string::utf8(b"Hello World!")
        };
        transfer::public_transfer(object, tx_context::sender(ctx));
    }
```

이 함수는 HelloWorldObject 커스텀 타입의 새로운 객체를 생성한 후, Sui 시스템의 [`public_transfer`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui-framework/transfer.md#function-public_transfer) 함수를 사용하여 해당 객체를 트랜잭션 호출자에게 전송합니다.
즉, 오브젝트를 생성한 뒤 트랜잭션 호출자에게 전송하는 함수입니다.
