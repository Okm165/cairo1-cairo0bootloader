### Cairo1 -> Cairo0 Bootloader

[![Continuous Integration - run](https://github.com/Okm165/cairo1-cairo0bootloader/actions/workflows/run.yaml/badge.svg)](https://github.com/Okm165/cairo1-cairo0bootloader/actions/workflows/run.yaml)

This project implements a modified Cairo0 bootloader to streamline the loading and execution of Cairo1 Sierra projects. This facilitates seamless interoperability between Cairo1 and Cairo0, enabling Cairo1 Scarb projects to operate within the Cairo0 bootloader environment.

## Getting Started

To set up the project environment and run the bootloader, follow these steps:

1. **Python Environment Setup**: It's recommended to install Python 3.9.0.

2. **Installation**: Execute `python install.py` to install dependencies and configure the project.

3. **Cairo1 Compilation**: Convert Cairo1 Scarb projects into the Sierra format by running `python compile.py`.

4. **Running the Bootloader**: Start the bootloader with `python run.py`, which will load and execute the compiled Cairo1 contract within the Cairo0 environment.

---

This example showcases merge of Cairo0 host provable environment and a Cairo1 developer frendly language:

```cairo
#[starknet::interface]
pub trait IHelloBootloader<TContractState> {
    fn main(ref self: TContractState, input: Array<felt252>) -> Array<felt252>;
}

#[starknet::contract]
mod HelloBootloader {
    #[derive(Drop, Serde)]
    struct Input {
        a: u32,
        b: u32,
        c: u32,
    }

    #[derive(Drop, Serde)]
    struct Output {
        a_2: u32,
        b_2: u32,
        c_2: u32,
    }

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl HelloBootloaderImpl of super::IHelloBootloader<ContractState> {
        fn main(ref self: ContractState, input: Array<felt252>) -> Array<felt252> {
            let mut input_span = input.span();
            let input = Serde::<Input>::deserialize(ref input_span).unwrap();

            let a_2 = input.a * input.a;
            let b_2 = input.b * input.b;
            let c_2 = input.c * input.c;
            assert(a_2 + b_2 == c_2, 'invalid value');

            let mut output = array![];
            Output { a_2, b_2, c_2, }.serialize(ref output);
            output
        }
    }
}
```

The Cairo0 bootloader's execution can be proven using a STARK prover like [stone-prover](https://github.com/starkware-libs/stone-prover).

## Work in Progress

Currently, the project supports the following builtins: `[output, range_check, pedersen, bitwise, poseidon]`. Expect further updates!