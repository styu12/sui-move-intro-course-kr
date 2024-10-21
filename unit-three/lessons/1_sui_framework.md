# Sui 프레임워크

스마트 컨트랙트의 일반적인 사용 사례 중 하나는 커스텀 fungible token, 대체 가능 토큰(예: 이더리움의 ERC-20 토큰)을 발행하는 것입니다. 
이번에는 Sui 프레임워크를 사용해 Sui에서 이러한 작업을 어떻게 수행할 수 있는지, 그리고 클래식 대체 가능 토큰의 변형에 대해 알아보겠습니다.

## Sui 프레임워크

[Sui 프레임워크](https://github.com/MystenLabs/sui/tree/main/crates/sui-framework/docs)는 Sui의 Move VM에 대한 구현 코드입니다. 이 프레임워크에는 Move 표준 라이브러리의 구현뿐만 아니라 Sui 고유의 API와 [암호화 기본 요소](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui-framework/groth16.md), [데이터 구조](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui-framework/url.md)와 같은 Sui 전용 작업들이 포함되어 있습니다. 

Sui에서 커스텀 대체 가능 토큰을 구현하려면 Sui 프레임워크의 여러 라이브러리를 많이 활용해야 합니다.

## `sui::coin`

Sui에서 커스텀 대체 가능 토큰을 구현할 때 사용할 주요 라이브러리는 [`sui::coin`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui-framework/coin.md) 모듈입니다.

대체 가능 토큰 예제에서 직접 사용할 리소스와 메서드는 다음과 같습니다:

- 리소스: [Coin](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui-framework/coin.md#resource-coin)
- 리소스: [TreasuryCap](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui-framework/coin.md#resource-treasurycap)
- 리소스: [CoinMetadata](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui-framework/coin.md#resource-coinmetadata)
- 메서드: [coin::create_currency](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui-framework/coin.md#0x2_coin_create_currency)

다음 몇 개의 섹션에서 새로운 개념을 소개한 후, 위에서 언급한 내용들을 더 깊이 살펴보겠습니다.
