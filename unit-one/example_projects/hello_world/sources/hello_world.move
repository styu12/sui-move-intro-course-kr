// Copyright (c) 2022, Sui Foundation
// SPDX-License-Identifier: Apache-2.0

/// A basic Hello World example for Sui Move, part of the Sui Move intro course:
/// https://github.com/sui-foundation/sui-move-intro-course
///
module hello_world::hello_world {
    use std::string;

    /// Defines the HelloWorldObject structure.
    /// It has key and store abilities, so it is used as a Sui Object in global storage.
    public struct HelloWorldObject has key, store {
        id: UID,
        text: string::String,
    }

    #[allow(lint(self_transfer))]
    public entry fun mint(ctx: &mut TxContext) {
        let object = HelloWorldObject {
            id: object::new(ctx),
            text: string::utf8(b"Hello, World!"),
        };
        transfer::public_transfer(object, tx_context::sender(ctx));
    }
}

