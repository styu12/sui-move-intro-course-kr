# 객체 래핑 예제

이번에는 성적표 예제에 객체 래핑을 적용해 보겠습니다. `WrappableTranscript`가 `Folder` 객체에 의해 래핑되고, `Folder` 객체는 지정된 주소나 뷰어만 언패킹할 수 있도록 하여 해당 주소/뷰어만 성적표에 접근할 수 있게 만들 것입니다.

## `WrappableTranscript`와 `Folder` 수정

먼저, 이전 섹션에서 정의한 두 커스텀 타입인 `WrappableTranscript`와 `Folder`에 몇 가지 수정을 해야 합니다.

1. `WrappableTranscript` 타입 정의에 `key` 능력을 추가해야 합니다. 이렇게 하면 이 타입이 자산(asset)으로 간주되어 전송할 수 있게 됩니다.

`key`와 `store` 능력을 가진 커스텀 타입은 Sui Move에서 자산(asset)으로 간주된다는 점을 기억하세요.

```rust
public struct WrappableTranscript has key, store {
        id: UID,
        history: u8,
        math: u8,
        literature: u8,
}
```

2. Folder 구조체에 intended_address 필드를 추가해야 하며, 이는 래핑된 성적표를 조회할 수 있는 지정된 뷰어의 주소를 나타냅니다.

``` rust
public struct Folder has key {
    id: UID,
    transcript: WrappableTranscript,
    intended_address: address
}
```

## 성적표 요청 메서드

```rust
public entry fun request_transcript(transcript: WrappableTranscript, intended_address: address, ctx: &mut TxContext){
    let folderObject = Folder {
        id: object::new(ctx),
        transcript,
        intended_address
    };
    // 래핑된 성적표 객체를 지정된 주소로 직접 전송합니다.
    transfer::transfer(folderObject, intended_address)
}
```

이 메서드는 `WrappableTranscript` 객체를 받아 `Folder` 객체로 래핑한 뒤, 래핑된 성적표를 지정된 주소로 전송하는 역할을 합니다.

## 성적표 언패킹 메서드

```rust
public fun unpack_wrapped_transcript(folder: Folder, ctx: &mut TxContext){
    // 성적표를 언패킹하는 사람이 지정된 뷰어인지 확인합니다.
    assert!(folder.intended_address == tx_context::sender(ctx), 0);
    let Folder {
        id,
        transcript,
        intended_address:_,
    } = folder;
    transfer::transfer(transcript, tx_context::sender(ctx));
    // 래퍼인 Folder 객체를 삭제합니다.
    object::delete(id)
    }
```

이 메서드는 호출자가 성적표의 지정된 뷰어일 경우 `Folder` 래퍼 객체에서 `WrappableTranscript` 객체를 언패킹하고, 그 성적표를 호출자에게 전송합니다.

*퀴즈: 여기서 래퍼 객체를 수동으로 삭제해야 하는 이유는 무엇일까요? 삭제하지 않으면 어떻게 될까요?*

### Assert

우리는 `assert!` 구문을 사용하여 성적표를 언패킹하는 트랜잭션을 보내는 주소가 `Folder` 래퍼 객체의 `intended_address` 필드와 동일한지 확인했습니다.

`assert!` 매크로는 다음 형식의 두 가지 매개변수를 받습니다:

```
assert!(<bool expression>, <code>)
```

여기서 불리언 표현식이 참이어야 하며, 그렇지 않으면 `<code>` 오류 코드와 함께 중단됩니다.

### 커스텀 에러

위에서는 기본값으로 0을 오류 코드로 사용했지만, 다음과 같이 커스텀 오류 상수를 정의할 수도 있습니다:

```rust
    const ENotIntendedAddress: u64 = 1;
```

이 오류 코드는 애플리케이션 레벨에서 처리되어 적절하게 대응할 수 있습니다.

**여기까지 작성한 두 번째 작업 진행 중인 코드 버전은 다음에서 확인할 수 있습니다: [WIP transcript.move](../example_projects/transcript/sources/transcript_2.move_wip)**

