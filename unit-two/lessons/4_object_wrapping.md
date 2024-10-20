# 객체 래핑(Object Wrapping)

Sui Move에서는 객체를 다른 객체 안에 중첩하는 여러 가지 방법이 있습니다. 그중 첫 번째로 소개할 방법은 **객체 래핑**입니다.

이전의 성적표 예제를 이어가 보겠습니다. 여기서 새로운 `WrappableTranscript` 타입과 관련된 래퍼 타입인 `Folder`를 정의합니다.

```rust
public struct WrappableTranscript has store {
    history: u8,
    math: u8,
    literature: u8,
}

public struct Folder has key {
    id: UID,
    transcript: WrappableTranscript,
}
```

위 예시에서 `Folder`는 `WrappableTranscript`를 래핑하고 있으며, `Folder`는 `key` 능력을 가지고 있어 객체 ID를 통해 접근할 수 있습니다.

## 객체 래핑의 특성

일반적으로 `key` 능력을 가진 Sui 객체 구조체에 다른 구조체를 포함하려면, 포함될 구조체는 `store` 능력을 가져야 합니다.

객체가 래핑되면, 더 이상 해당 객체에 객체 ID로 직접 접근할 수 없으며, 래퍼 객체의 일부로만 존재하게 됩니다. 더 중요한 점은, 래핑된 객체는 Move 호출에서 독립적으로 인수로 전달될 수 없고, 오직 래퍼 객체를 통해서만 접근이 가능합니다.

이러한 특성 때문에 객체 래핑은 특정 컨트랙트 호출 외부에서는 객체에 접근하지 못하도록 하는 방법으로 사용할 수 있습니다. 객체 래핑에 대한 자세한 정보는 [여기](https://docs.sui.io/devnet/build/programming-with-objects/ch4-object-wrapping)에서 확인할 수 있습니다.
