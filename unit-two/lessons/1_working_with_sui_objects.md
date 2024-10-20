# Sui 객체 다루기

## 소개

Sui Move는 철저히 객체 중심적인 언어입니다. Sui에서 트랜잭션은 입력과 출력 모두 객체로 이루어진 작업으로 표현됩니다. [Unit One, Lesson 3](../../unit-one/lessons/3_custom_types_and_abilities.md#커스텀-타입과-능력)에서 간단히 다뤘듯이, Sui 객체는 Sui의 기본적인 저장 단위입니다. 이 모든 것은 `struct` 키워드로 시작됩니다.

예시로 학생의 성적을 기록하는 성적표를 나타내는 코드를 살펴보겠습니다:

```rust
public struct Transcript {
    history: u8,
    math: u8,
    literature: u8,
}
```

위 정의는 일반적인 Move 구조체지만, Sui 객체는 아닙니다. 
커스텀 Move 타입을 글로벌 저장소에 있는 Sui 객체로 만들기 위해서는 (1) `key` 능력을 추가하고, (2) 구조체 정의에 전역적으로 고유한 `id: UID` 필드를 추가해야 합니다.

```rust
use sui::object::{UID};

public struct TranscriptObject has key {
    id: UID,
    history: u8,
    math: u8,
    literature: u8,
}
```

## Sui 객체 생성하기

Sui 객체를 생성하려면 고유한 ID가 필요합니다. `sui::object::new` 함수를 사용하여 현재 `TxContext`를 전달해 새로운 ID를 생성합니다.

Sui에서 모든 객체는 소유자가 있어야 합니다. 소유자는 주소, 다른 Object, 또는 “Shared Object”일 수 있습니다. 예시에서는 새로운 `transcriptObject`를 트랜잭션 발신자가 소유하도록 설정했습니다. 이를 위해 Sui 프레임워크의 `transfer` 함수를 사용하고, `tx_context::sender` 함수를 통해 현재 엔트리 호출의 발신자 주소를 가져옵니다.

객체 소유권에 대해서는 다음 섹션에서 더 자세히 다루겠습니다.

```rust
use sui::object::{Self};
use sui::tx_context::{Self, TxContext};
use sui::transfer;

public entry fun create_transcript_object(history: u8, math: u8, literature: u8, ctx: &mut TxContext) {
  let transcriptObject = TranscriptObject {
    id: object::new(ctx),
    history,
    math,
    literature,
  };
  transfer::transfer(transcriptObject, tx_context::sender(ctx))
}
```

*💡참고: 제공된 예제 코드는 경고 메시지를 발생시킵니다: warning[Lint W01001]: non-composable transfer to sender. 자세한 내용은 ("Sui Linters and Warnings Update Increases Coder Velocity")[https://blog.sui.io/linter-compile-warnings-update/#:~:text=5.%20Self%20transfer%20linter] 문서를 참조하세요.*

*💡참고: Move는 필드 명시(field punning)를 지원하며, 필드 이름이 바인딩된 변수 이름과 동일한 경우 필드 값을 생략할 수 있습니다.*
