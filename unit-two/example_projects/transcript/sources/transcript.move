// Copyright (c) 2022, Sui Foundation
// SPDX-License-Identifier: Apache-2.0

/// A basic object example for Sui Move, part of the Sui Move intro course:
/// https://github.com/sui-foundation/sui-move-intro-course
/// 
module transcript::transcript {

    public struct Transcript has key {
        id: UID,
        history: u8,
        math: u8,
        literature: u8,
    }

    public entry fun create_transcript_object(history: u8, math: u8, literature: u8, ctx: &mut TxContext) {
        let transcriptObject = Transcript {
            id: object::new(ctx),
            history,
            math,
            literature,
        };
        transfer::transfer(transcriptObject, tx_context::sender(ctx));
    }
}