# 동일 타입 컬렉션 (Homogeneous Collections)

Sui에서 마켓플레이스를 구축하는 메인 주제를 다루기 전에, 먼저 Move 언어에서 사용하는 컬렉션(collection)에 대해 알아보겠습니다.

## 벡터(vectors)

Move에서 `Vector`는 C++ 등 다른 언어의 벡터와 유사합니다. 런타임에 동적으로 메모리를 할당하여 단일 타입의 데이터를 관리할 수 있습니다. 이 타입은 특정 타입일 수도 있고 [제네릭 타입](../../unit-three/lessons/2_intro_to_generics.md)일 수도 있습니다.

아래는 `vector`를 정의하고 기본적인 작업을 수행하는 예제 코드입니다:

```rust
module collection::vector {
    use std::vector;

    public struct Widget {
    }

    // 특정 타입을 위한 벡터
    public struct WidgetVector {
        widgets: vector<Widget>
    }

    // 제네릭 타입을 위한 벡터
    public struct GenericVector<T> {
        values: vector<T>
    }

    // 제네릭 타입 T를 보관하는 GenericVector 생성
    public fun create<T>(): GenericVector<T> {
        GenericVector<T> {
            values: vector::empty<T>()
        }
    }

    // GenericVector에 타입 T의 값을 추가
    public fun put<T>(vec: &mut GenericVector<T>, value: T) {
        vector::push_back<T>(&mut vec.values, value);
    }

    // GenericVector에서 타입 T의 값을 제거
    public fun remove<T>(vec: &mut GenericVector<T>): T {
        vector::pop_back<T>(&mut vec.values)
    }

    // GenericVector의 크기 반환
    public fun size<T>(vec: &mut GenericVector<T>): u64 {
        vector::length<T>(&vec.values)
    }
}
```

제네릭 타입으로 정의된 벡터는 임의의 타입을 수용할 수 있지만, 벡터 내부의 모든 객체는 반드시 동일한 타입이어야 합니다. 즉, 컬렉션은 **동일 타입 컬렉션(homogeneous collection)**입니다.

## 테이블(Table)

`Table`은 키-값 쌍을 동적으로 저장하는 컬렉션으로, 맵(map)과 유사합니다. 하지만 전통적인 맵 컬렉션과 달리, `Table`의 키와 값은 `Table` 객체 내부에 저장되는 것이 아니라 Sui의 객체(Object) 시스템을 사용해 저장됩니다. `Table` 구조체는 이 객체(Object) 시스템에 대한 핸들 역할을 하여 키와 값을 조회할 수 있게 합니다.

`Table`의 `key` 타입은 `copy + drop + store` 능력 제약 조건을 가져야 하며, `value` 타입은 `store` 능력 제약 조건을 가져야 합니다.

`Table`도 동일 타입 컬렉션으로, 컬렉션의 모든 키와 모든 값이 반드시 같은 타입이어야 합니다.

*퀴즈: 동일한 키-값 쌍을 가진 두 Table 객체를 === 연산자로 비교하면 두 객체는 같을까요? 직접 실험해 보세요.*

아래는 `Table` 컬렉션을 사용하는 예제 코드입니다:

```rust
module collection::table {
    use sui::table::{Table, Self};
    use sui::tx_context::{TxContext};

    /// 키와 값의 타입이 지정된 테이블 정의
    public struct IntegerTable {
        table_values: Table<u8, u8>
    }

    /// 키와 값의 타입이 제네릭으로 정의된 테이블
    public struct GenericTable<phantom K: copy + drop + store, phantom V: store> {
        table_values: Table<K, V>
    }

    /// 키 타입 K와 값 타입 V를 가진 빈 GenericTable 생성
    public fun create<K: copy + drop + store, V: store>(ctx: &mut TxContext): GenericTable<K, V> {
        GenericTable<K, V> {
            table_values: table::new<K, V>(ctx)
        }
    }

    /// GenericTable에 키-값 쌍 추가
    public fun add<K: copy + drop + store, V: store>(table: &mut GenericTable<K, V>, k: K, v: V) {
        table::add(&mut table.table_values, k, v);
    }

    /// GenericTable에서 키-값 쌍을 제거하고 값을 반환
    public fun remove<K: copy + drop + store, V: store>(table: &mut GenericTable<K, V>, k: K): V {
        table::remove(&mut table.table_values, k)
    }

    /// GenericTable에서 키에 해당하는 값에 대한 불변 참조 반환
    public fun borrow<K: copy + drop + store, V: store>(table: &GenericTable<K, V>, k: K): &V {
        table::borrow(&table.table_values, k)
    }

    /// GenericTable에서 키에 해당하는 값에 대한 가변 참조 반환
    public fun borrow_mut<K: copy + drop + store, V: store>(table: &mut GenericTable<K, V>, k: K): &mut V {
        table::borrow_mut(&mut table.table_values, k)
    }

    /// GenericTable에 특정 키가 존재하는지 확인
    public fun contains<K: copy + drop + store, V: store>(table: &GenericTable<K, V>, k: K): bool {
        table::contains<K, V>(&table.table_values, k)
    }

    /// GenericTable의 크기(키-값 쌍의 개수) 반환
    public fun length<K: copy + drop + store, V: store>(table: &GenericTable<K, V>): u64 {
        table::length(&table.table_values)
    }
}
```
