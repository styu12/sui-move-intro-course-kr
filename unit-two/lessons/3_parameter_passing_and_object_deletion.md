# 파라미터 전달과 객체 삭제

## 파라미터 전달 (`value`, `ref`, `mut ref`로 전달)

Rust에 익숙하다면 소유권 시스템에 대해 잘 알고 있을 것입니다. Move 언어는 Solidity와 비교했을 때, 함수 호출이 자산(asset)에 어떤 영향을 미칠지 예측할 수 있다는 장점이 있습니다. 다음은 그에 대한 몇 가지 예시입니다:

```rust
use sui::object::{Self};

// 성적을 조회할 수 있지만 수정할 수는 없습니다.
public fun view_score(transcriptObject: &TranscriptObject): u8{
    transcriptObject.literature
}

// 성적을 조회하고 수정할 수 있지만 삭제는 할 수 없습니다.
public fun update_score(transcriptObject: &mut TranscriptObject, score: u8){
    transcriptObject.literature = score
}

// 성적을 조회, 수정 또는 전체 성적표 자체를 삭제할 수 있습니다.
public fun delete_transcript(transcriptObject: TranscriptObject){
    let TranscriptObject {id, history: _, math: _, literature: _ } = transcriptObject;
    object::delete(id);
}
```

## 객체 삭제와 구조체 언패킹(Unpacking)

위 예시의 `delete_transcript` 메서드는 Sui에서 객체를 삭제하는 방법을 보여줍니다.

1. 객체를 삭제하려면 먼저 객체를 언패킹하여 객체 ID를 가져와야 합니다. Move의 privileged struct operation 규칙에 따라 언패킹은 해당 객체를 정의한 모듈 내에서만 수행할 수 있습니다:

- 구조체 타입은 구조체를 정의한 모듈 내에서만 생성(“packed”)되고, 파괴(“unpacked”)될 수 있습니다.
- 구조체의 필드는 구조체를 정의한 모듈 내에서만 접근 가능합니다.

이 규칙에 따라, 구조체를 정의한 모듈 외부에서 구조체를 수정하고 싶다면 해당 작업을 위한 공개 메서드(public method)를 제공해야 합니다.

2. 구조체를 언패킹하여 ID를 가져온 후, `object::delete` 프레임워크 메서드를 호출하여 해당 객체 ID로 객체를 삭제할 수 있습니다.

*💡참고: 위 메서드에서 _(언더스코어)는 사용되지 않는 변수나 파라미터를 나타냅니다. 이는 변수를 즉시 소비하게 됩니다.*

**현재 작성 중인 코드의 진행 상황은 다음에서 확인할 수 있습니다: [WIP transcript.move](../example_projects/transcript/sources/transcript_1.move_wip)**


1. In order to delete an object, you must first unpack the object and retrieve its object ID. Unpacking can only be done inside the module that defines the object due to Move's privileged struct operation rules:

- Struct types can only be created ("packed"), destroyed ("unpacked") inside the module that defines the struct
- The fields of a struct are only accessible inside the module that defines the struct

Following these rules, if you want to modify your struct outside its defining module, you will need to provide public methods for these operations. 

2. After unpacking the struct and retrieving its ID, the object can be deleted by simply calling the `object::delete` framework method on its object ID. 

*💡Note: the, `_`, underscore in the above method denotes unused variables or parameters. This will consume the variable or parameter immediately.*

**Here is the work-in-progress version of what we have written so far: [WIP transcript.move](../example_projects/transcript/sources/transcript_1.move_wip)**



