# 제네릭 소개

제네릭(Generic)은 구체적인 타입이나 다른 속성에 대한 추상적인 대체물입니다. Rust에서의 [제네릭](https://doc.rust-lang.org/stable/book/ch10-00-generics.html)과 유사하게 동작하며, Sui Move 코드를 작성할 때 더 큰 유연성을 제공하고, 중복된 로직을 피할 수 있도록 도와줍니다.

제네릭은 Sui Move에서 중요한 개념이므로, 이 섹션을 천천히 읽고 모든 부분을 완전히 이해하는 것이 중요합니다.

## 제네릭 사용법

### 구조체에서 제네릭 사용

제네릭을 사용하여 Sui Move에서 어떤 타입이든 담을 수 있는 `Box` 컨테이너를 만드는 기본적인 예시를 살펴보겠습니다.

우선, 제네릭 없이 `u64` 타입을 담는 `Box`를 다음과 같이 정의할 수 있습니다:

```rust
module  generics::storage {
    public struct Box {
        value: u64
    }
}
```

하지만 이 타입은 `u64` 타입의 값만 담을 수 있습니다. `Box`가 어떤 제네릭 타입이든 담을 수 있도록 하려면 제네릭을 사용해야 합니다. 코드는 다음과 같이 수정됩니다:

```rust
module  generics::storage {
    public struct Box<T> {
        value: T
    }
}
```

#### 능력 제약 (Ability Constraints)

제네릭에 특정 능력을 가진 타입만 전달되도록 조건을 추가할 수 있습니다. 구문은 다음과 같습니다:

```rust
module  generics::storage {
    // T는 store, drop 능력을 가진 타입이어야 합니다.
    public struct Box<T: store + drop> has key, store {
        value: T
    }
}
```

💡여기서 중요한 점은, 외부 컨테이너 타입의 제약으로 인해 내부 타입 `T`도 특정 능력 제약을 충족해야 한다는 것입니다. 이 예시에서는 `Box`가 `store`와 `key` 능력을 가지고 있기 때문에 `T`도 `store` 능력을 가져야 합니다. 하지만 `T`는 컨테이너가 가지지 않은 다른 능력도 가질 수 있습니다. 이 예시에서는 `drop`이 그 예입니다.

컨테이너가 자신과 동일한 규칙을 따르지 않는 타입을 포함할 수 있다면, 컨테이너는 자신의 능력을 위반하게 됩니다. 내용물이 저장될 수(storable) 없다면, 박스 자체가 어떻게 저장될 수(storable) 있겠습니까?

다음 섹션에서 이 규칙을 회피할 수 있게 특정 경우에 사용할 수 있는 `phantom`이라는 특별한 키워드를 소개할 것입니다.

*💡`example_projects` 아래에 있는 [generics 프로젝트](../example_projects/generics/)에서 제네릭 타입의 예시를 확인할 수 있습니다.*

### 함수에서 제네릭 사용

`value` 필드에 어떤 타입의 매개변수든 받을 수 있는 `Box` 인스턴스를 반환하는 함수를 작성하려면, 함수 정의에서도 제네릭을 사용해야 합니다. 함수는 다음과 같이 정의할 수 있습니다:

```rust
public fun create_box<T>(value: T): Box<T> {
        Box<T> { value }
    }
```

특정 타입의 `value`만 받도록 함수를 제한하고 싶다면, 함수 시그니처에 해당 타입을 명시하면 됩니다:

```rust
public fun create_box(value: u64): Box<u64> {
        Box<u64>{ value }
    }
```

이 함수는 여전히 제네릭 `Box` 구조체를 사용하면서도 `u64` 타입의 값만 입력으로 받습니다.

#### 제네릭 함수 호출

제네릭을 포함한 함수 시그니처를 가진 함수를 호출할 때는 꺾쇠 괄호를 사용해 타입을 명시해야 합니다. 구문은 다음과 같습니다:

```rust
// value는 storage::Box<bool> 타입입니다.
    let bool_box = storage::create_box<bool>(true);
// value는 storage::Box<u64> 타입입니다.
    let u64_box = storage::create_box<u64>(1000000);
```

#### Sui CLI를 사용한 제네릭 함수 호출

Sui CLI에서 제네릭을 포함한 함수 시그니처를 호출하려면, `--type-args` 플래그를 사용해 인수의 타입을 정의해야 합니다.

다음은 `create_box` 함수를 호출하여 `0x2::sui::SUI` 타입의 코인을 포함하는 박스를 만드는 예시입니다:

```bash
sui client call --package $PACKAGE --module $MODULE --function "create_box" --args $OBJECT_ID --type-args 0x2::sui::SUI --gas-budget 10000000
```

## 고급 제네릭 문법

여러 제네릭 타입을 사용하는 등의 고급 제네릭 문법에 대해서는 Move Book의 [제네릭 섹션](https://move-book.com/advanced-topics/understanding-generics.html)을 참고하세요.

하지만 현재 대체 가능 토큰 수업에서는 제네릭이 어떻게 작동하는지에 대해 지금까지 배운 내용으로 충분히 이해할 수 있습니다. 
