# Witness 디자인 패턴

다음으로, Sui Move에서 대체 가능 토큰이 어떻게 구현되는지 이해하기 위해 **Witness 패턴**을 살펴보겠습니다.

**Witness**는 특정 리소스나 타입 `A`가 일회성 리소스인 `witness`가 소모된 후에만 한 번 초기화될 수 있음을 보장하는 디자인 패턴입니다. `witness` 리소스는 사용 후 즉시 소모되거나 삭제되어야 하며, 이를 통해 여러 인스턴스를 생성하는 데 재사용되지 않도록 합니다. 즉 `A` 는 단 한 번만 초기화됩니다.

## Witness 패턴 예제

다음 예제에서 `witness` 리소스는 `PEACE`이며, 초기화하려는 타입 `A`는 `Guardian`입니다.

`witness` 리소스 타입에는 `drop` 키워드가 필요하며, 이를 통해 함수에 전달된 후 삭제할 수 있습니다. `PEACE` 리소스의 인스턴스는 `create_guardian` 메서드로 전달되어 바로 소모됩니다(변수 앞의 언더스코어에 주목). 이렇게 함으로써 `Guardian`의 인스턴스가 단 한 번만 생성되도록 보장합니다.

```rust
    /// 제네릭 타입 `Guardian<T>`를 정의하는 모듈로, 이 타입은
    /// witness를 통해서만 초기화될 수 있습니다.
    module witness::peace {
        use sui::object::{Self, UID};
        use sui::transfer;
        use sui::tx_context::{Self, TxContext};

        /// Phantom 매개변수 T는 `create_guardian` 함수에서만 초기화 가능합니다.
        /// T는 `drop` 능력을 가져야 합니다.
        public struct Guardian<phantom T: drop> has key, store {
            id: UID
        }

        /// 이 타입은 witness 리소스이며, 일회성 사용을 의도합니다.
        public struct PEACE has drop {}

        /// 이 함수의 첫 번째 인수는 `drop` 능력을 가진 T 타입의 실제 인스턴스입니다.
        /// 수신 즉시 소모됩니다.
        public fun create_guardian<T: drop>(
            _witness: T, ctx: &mut TxContext
        ): Guardian<T> {
            Guardian { id: object::new(ctx) }
        }

        /// 모듈 초기화(init) 함수는 한 번만 호출되도록 보장하는 좋은 방법입니다.
        /// Witness 패턴과 함께 사용하는 경우 가장 좋은 관행입니다.
        fun init(witness: PEACE, ctx: &mut TxContext) {
            transfer::transfer(
                create_guardian(witness, ctx),
                tx_context::sender(ctx)
            )
        }
    }
```

*위 예제는 [Damir Shamanaev](https://github.com/damirka)의 책 [Sui Move by Example](https://examples.sui.io/patterns/witness.html)을 기반으로 수정한 것입니다.*

### `phantom` 키워드

위 예제에서 `Guardian` 타입은 `key`와 `store` 능력을 가져야 하며, 이를 통해 자산으로 취급되고 전송 가능하며 글로벌 저장소에 유지될 수 있습니다.

또한 `witness` 리소스인 `PEACE`를 `Guardian`에 전달하고자 하지만, `PEACE`는 `drop` 능력만 가지고 있습니다. 이전에 살펴본 [능력 제약(Ability Constraints)](./2_intro_to_generics.md#능력-제약-(Ability-Constraints))에 따르면, 외부 타입 `Guardian`이 `key`와 `store` 능력을 가지므로 `PEACE`도 이 능력을 가져야 합니다. 그러나 이 경우, `witness` 타입에 불필요한 능력을 추가하면 원하지 않는 동작이나 취약점을 초래할 수 있습니다.

이 문제를 해결하기 위해 `phantom` 키워드를 사용할 수 있습니다. 타입 매개변수가 구조체 정의에서 사용되지 않거나 다른 `phantom` 타입 매개변수에 인수로만 사용될 경우, `phantom` 키워드를 사용하여 Move 타입 시스템이 내부 타입의 능력 제약 규칙을 완화하도록 할 수 있습니다. `Guardian`이 필드에서 타입 `T`를 사용하지 않기 때문에 `T`를 `phantom` 타입으로 선언해도 안전합니다.

`phantom` 키워드에 대한 자세한 설명은 Move 언어 문서의 [관련 섹션](https://github.com/move-language/move/blob/main/language/documentation/book/src/generics.md#phantom-type-parameters)을 참고하세요.

## 일회성 Witness

일회성 Witness (One Time Witness - OTW)는 Witness 패턴의 하위 패턴으로, 모듈의 `init` 함수를 사용하여 `witness` 리소스가 한 번만 생성되도록 보장합니다. 따라서 타입 `A`가 싱글톤으로 보장됩니다.

Sui Move에서 타입이 OTW로 간주되려면 다음 속성을 충족해야 합니다:

- 타입은 모듈 이름을 따서 대문자로 이름 지어야 합니다.
- 타입은 `drop` 능력만 가져야 합니다.

이 타입의 인스턴스를 얻으려면 위 예제와 같이 모듈 `init` 함수의 첫 번째 인수로 추가해야 합니다. 그러면 Sui 런타임이 모듈 게시 시 자동으로 OTW 구조체를 생성합니다.

위 예제는 One Time Witness 디자인 패턴을 사용하여 `Guardian`이 싱글톤임을 보장합니다.
