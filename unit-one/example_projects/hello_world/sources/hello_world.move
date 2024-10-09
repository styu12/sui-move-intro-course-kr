// Copyright (c) 2022, Sui Foundation
// SPDX-License-Identifier: Apache-2.0

/// A basic Hello World example for Sui Move, part of the Sui Move intro course:
/// https://github.com/sui-foundation/sui-move-intro-course
///
module hello_world::hello_world {
    use std::string;
    use sui::object::UID;

    /// HelloWorldObject 구조체를 정의합니다.
    /// key, store 능력을 가지고 있기 때문에 글로벌 스토리지에서 Sui Object로 사용됩니다.
    public struct HelloWorldObject has key, store {
        id: UID,
        text: string::String,
    }
}

