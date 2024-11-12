# `Coin` 리소스와 `create_currency` 메서드

이제 제네릭과 Witness 패턴이 어떻게 작동하는지 이해했으므로, `Coin` 리소스와 `create_currency` 메서드로 돌아가 보겠습니다.

## `Coin` 리소스


제네릭의 작동 방식을 이해했으니, `sui::coin`의 `Coin` 리소스를 다시 살펴볼 수 있습니다. `Coin` 리소스는 다음과 같이 [정의](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/coin.move#L28)됩니다:

```rust
public struct Coin<phantom T> has key, store {
        id: UID,
        balance: Balance<T>
    }
```

`Coin` 리소스 타입은 제네릭 타입 `T`와 두 개의 필드(`id`와 `balance`)를 가진 구조체입니다. `id`는 이전에 본 `sui::object::UID` 타입입니다.

`balance`는 [`sui::balance::Balance`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui-framework/balance.md#0x2_balance_Balance) 타입이며, 다음과 같이 [정의](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/balance.move#L29)됩니다:

```rust 
public struct Balance<phantom T> has store {
    value: u64
}
```

Recall our discussion on [`phantom`](./3_witness_design_pattern.md#the-phantom-keyword), The type `T` is used in `Coin` only as an argument to another phantom type for `Balance`, and in `Balance`, it's not used in any of its fields, thus `T` is a `phantom` type parameter. 

`Coin<T>` serves as a transferrable asset representation of a certain amount of the fungible token type `T` that can be transferred between addresses or consumed by smart contract function calls. 

[`phantom`](./3_witness_design_pattern.md#phantom-키워드)에 대해 논의한 내용을 기억하세요. `T` 타입은 `Coin`에서 `Balance`의 또 다른 `phantom` 타입 인수로만 사용되며, `Balance`에서는 어떤 필드에도 사용되지 않기 때문에 `T`는 `phantom` 타입 매개변수입니다.

`Coin<T>`는 특정 대체 가능 토큰 타입 `T`의 일정 양을 전송하거나 스마트 컨트랙트 함수 호출로 소모할 수 있는 자산을 나타냅니다. `T` 타입의 데이터가 실제로 사용되지는 않지만, 해당 `Coin` 객체가 `T` 토큰 타입의 `Coin`임을 알 수 있습니다.

## `create_currency` 메서드

coin::create_currency가 실제로 무엇을 수행하는지 [소스 코드](https://github.com/MystenLabs/sui/blob/e365403fb8a8debb0a5e210b29654dc11051aeec/crates/sui-framework/packages/sui-framework/sources/coin.move#L211)를 살펴보겠습니다:

```rust
    public fun create_currency<T: drop>(
        witness: T,
        decimals: u8,
        symbol: vector<u8>,
        name: vector<u8>,
        description: vector<u8>,
        icon_url: Option<Url>,
        ctx: &mut TxContext
    ): (TreasuryCap<T>, CoinMetadata<T>) {
        // Make sure there's only one instance of the type T
        assert!(sui::types::is_one_time_witness(&witness), EBadWitness);

        // Emit Currency metadata as an event.
        event::emit(CurrencyCreated<T> {
            decimals
        });

        (
            TreasuryCap {
                id: object::new(ctx),
                total_supply: balance::create_supply(witness)
            },
            CoinMetadata {
                id: object::new(ctx),
                decimals,
                name: string::utf8(name),
                symbol: ascii::string(symbol),
                description: string::utf8(description),
                icon_url
            }
        )
    }
```

```rust
    public fun create_currency<T: drop>(
        witness: T,
        decimals: u8,
        symbol: vector<u8>,
        name: vector<u8>,
        description: vector<u8>,
        icon_url: Option<Url>,
        ctx: &mut TxContext
    ): (TreasuryCap<T>, CoinMetadata<T>) {
        // 타입 T의 인스턴스가 단 하나임을 확인합니다. (OTW)
        assert!(sui::types::is_one_time_witness(&witness), EBadWitness);

        // 메타데이터를 이벤트로 발행시킵니다.
        event::emit(CurrencyCreated<T> {
            decimals
        });

        (
            TreasuryCap {
                id: object::new(ctx),
                total_supply: balance::create_supply(witness)
            },
            CoinMetadata {
                id: object::new(ctx),
                decimals,
                name: string::utf8(name),
                symbol: ascii::string(symbol),
                description: string::utf8(description),
                icon_url
            }
        )
    }
```

assert 구문은 Sui 프레임워크의 [`sui::types::is_one_time_witness`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/types.move) 메서드를 사용해 전달된 `witness` 리소스가 One Time Witness인지 확인합니다.

이 메서드는 `TreasuryCap` 리소스와 `CoinMetadata` 리소스라는 두 개의 객체를 생성하여 반환합니다.

### `TreasuryCap`

`TreasuryCap`은 자산으로서 One Time Witness 패턴에 의해 단일 객체임이 보장됩니다:

```rust
    /// `T` 타입의 코인을 발행 및 소각할 수 있는 권한 (전송 가능)
    public struct TreasuryCap<phantom T> has key, store {
        id: UID,
        total_supply: Supply<T>
    }
```

이 구조체는 `Balance::Supply` 타입의 싱글톤 필드 `total_supply`를 포함합니다:

```rust
/// T의 총량. 발행 및 소각에 사용됩니다.
/// `Coin` 모듈에서 `TreasuryCap`으로 래핑됩니다.
    public struct Supply<phantom T> has store {
        value: u64
    }
```

`Supply<T>`는 현재 유통 중인 특정 대체 가능 토큰 타입 `T`의 총량(유통량)을 추적합니다. 특정 토큰 타입에 대해 여러 `Supply` 인스턴스가 존재하는 것은 의미가 없기 때문에 이 필드는 반드시 싱글톤이어야 합니다.

### `CoinMetadata`

`CoinMetadata`는 생성된 대체 가능 토큰의 메타데이터를 저장하는 리소스입니다. 다음 필드들이 포함됩니다:

- `decimals`: 해당 대체 가능 토큰의 소수점 자리 수
- `name`: 해당 대체 가능 토큰의 이름
- `symbol`: 해당 대체 가능 토큰의 심볼
- `description`: 해당 대체 가능 토큰의 설명
- `icon_url`: 해당 대체 가능 토큰의 아이콘 파일 URL

`CoinMetadata`에 포함된 정보는 Sui의 기본적인 대체 가능 토큰 표준으로 간주할 수 있으며, 지갑과 explorer에서 `sui::coin` 모듈을 사용해 생성된 대체 가능 토큰을 표시하는 데 사용됩니다.
