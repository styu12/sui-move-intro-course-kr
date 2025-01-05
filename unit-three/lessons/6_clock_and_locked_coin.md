# Clock 및 Locked Coin 예제

두 번째 대체 가능한 토큰(Fungible Token) 예제에서는 Sui 블록체인에서 온체인 시간 정보를 가져오는 방법과 이를 활용하여 코인의 베스팅(Vesting) 메커니즘을 구현하는 방법을 소개합니다.

## Clock


Sui 프레임워크에는 Move 스마트 컨트랙트에서 타임스탬프를 사용할 수 있게 해주는 [clock 모듈](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui-framework/clock.md)이 기본 제공됩니다.

주로 사용하게 될 메서드는 다음과 같습니다:

```
public fun timestamp_ms(clock: &clock::Clock): u64
```

[`timestamp_ms`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui-framework/clock.md#0x2_clock_timestamp_ms) 함수는 시스템의 현재 타임스탬프를 반환하며, 특정 시점 이후 경과한 시간을 밀리초 단위로 제공합니다.

[`clock`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui-framework/clock.md#0x2_clock_Clock) 객체는 특별히 예약된 식별자 0x6을 사용하며, 해당 객체를 함수 호출 시 입력값으로 전달해야 합니다.

## Locked Coin

`clock`을 통해 온체인 시간에 접근할 수 있게 되면, 코인의 베스팅(Vesting) 메커니즘을 구현하는 것은 비교적 간단합니다.

### `Locker` 커스텀 타입

`locked_coin`은 `managed_coin` 구현을 기반으로 `Locker`라는 커스텀 타입을 추가하여 동작합니다:

```rust
    /// 베스팅 코인을 저장하기 위한 전송 가능한 객체
    ///
    public struct Locker has key, store {
        id: UID,
        start_date: u64,
        final_date: u64,
        original_balance: u64,
        current_balance: Balance<LOCKED_COIN>
    }
```

`Locker`는 토큰의 베스팅 일정 및 상태 정보를 저장해두는 전송 가능한 [자산](../../unit-one/lessons/3_custom_types_and_abilities.md#자산-assets)입니다.
- `start_date`와 `final_date`는 `clock`에서 얻은 타임스탬프로, 베스팅 기간의 시작과 종료 시점을 나타냅니다.
- `original_balance`는 `Locker`에 발행된 초기 잔액을 의미합니다.
- `current_balance`는 현재 남은 잔액으로, 이미 인출된 베스팅 금액을 반영한 값입니다.

### 발행(Minting)

`locked_mint` 메서드에서는 지정된 코인 금액과 베스팅 일정이 포함된 `Locker` 객체를 생성하여 전송합니다:

```rust
    /// 입력된 코인 금액과 베스팅 일정이 포함된 locker 객체를 발행 및 전송
    ///
    public fun locked_mint(treasury_cap: &mut TreasuryCap<LOCKED_COIN>, recipient: address, amount: u64, lock_up_duration: u64, clock: &Clock, ctx: &mut TxContext){
        let coin = coin::mint(treasury_cap, amount, ctx);
        let start_date = clock::timestamp_ms(clock);
        let final_date = start_date + lock_up_duration;

        transfer::public_transfer(Locker {
            id: object::new(ctx),
            start_date: start_date,
            final_date: final_date,
            original_balance: amount,
            current_balance: coin::into_balance(coin)
        }, recipient);
    }
```

위 코드에서 `clock`을 사용하여 현재 타임스탬프를 가져오는 것을 확인할 수 있습니다.

### 인출(Withdrawing)

`withdraw_vested` 메서드에는 베스팅된 금액을 계산하는 주요 로직이 포함되어 있습니다:

```rust
    /// 선형 베스팅을 가정하여 이용 가능한 베스팅 금액을 인출
    ///
    public fun withdraw_vested(locker: &mut Locker, clock: &Clock, ctx: &mut TxContext){
        let total_duration = locker.final_date - locker.start_date;
        let elapsed_duration = clock::timestamp_ms(clock) - locker.start_date;
        let total_vested_amount = if (elapsed_duration > total_duration) {
            locker.original_balance
        } else {
            locker.original_balance * elapsed_duration / total_duration
        };
        let available_vested_amount = total_vested_amount - (locker.original_balance-balance::value(&locker.current_balance));
        transfer::public_transfer(coin::take(&mut locker.current_balance, available_vested_amount, ctx), sender(ctx))
    }
```

이 예제는 간단한 선형 베스팅 스케줄을 가정하지만, 다양한 베스팅 로직 및 스케줄을 구현할 수 있도록 수정할 수 있습니다.

### 전체 스마트 컨트랙트

[`locked_coin`](../example_projects/locked_coin/sources/locked_coin.move)의 전체 스마트 컨트랙트는 [example_projects/locked_coin](../example_projects/locked_coin/) 폴더에서 확인할 수 있습니다.