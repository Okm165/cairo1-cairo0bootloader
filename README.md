### Cairo1 -> Cairo0 Bootloader

[![Continuous Integration - run](https://github.com/Okm165/cairo1-cairo0bootloader/actions/workflows/run.yaml/badge.svg)](https://github.com/Okm165/cairo1-cairo0bootloader/actions/workflows/run.yaml)

This project implements a modified Cairo0 bootloader to streamline the loading and execution of Cairo1 Sierra projects. This facilitates seamless interoperability between Cairo1 and Cairo0, enabling Cairo1 Scarb projects to operate within the Cairo0 bootloader environment.

## Getting Started

To set up the project environment and run the bootloader, follow these steps:

1. **Python Environment Setup**: It's recommended to install Python 3.9.0.

2. **Installation**: Execute `python install.py` to install dependencies and configure the project.

3. **Cairo1 Compilation**: Convert Cairo1 Scarb projects into the Sierra format by running `python compile.py`.

4. **Running the Bootloader**: Start the bootloader with `python run.py`, which will load and execute the compiled Cairo1 contract within the Cairo0 environment.

5. **Preparing bootloader_input.json (Optional)**:
   - Run `Scarb build` in the contract folder.
   - Use `starknet-sierra-compile INPUT OUTPUT --add-pythonic-hints`.
   - Add a return footer at the end of the contract's bytecode (increase the bytecode segment size by one).
   - Supply `bootloader_input.json` with new contract sierra class json.

---

This example showcases merge of Cairo0 host provable environment and a Cairo1 developer frendly language:

```cairo
#[starknet::contract]
mod Factorial {
    use starknet::{ContractAddress, SyscallResult, SyscallResultTraitImpl};
    use starknet::syscalls::call_contract_syscall;

    #[storage]
    struct Storage{}

    #[external(v0)]
    fn main(ref self: ContractState, address: ContractAddress) -> Span<felt252> {
        // call_contract_syscall is modified POC syscall to just return calldata it received
        let value: Span<felt252> = call_contract_syscall(
            address, 0x1, array![0xa, 0xb, 0xc, 0xe].span(),
        ).unwrap_syscall();
        value
    }
}
```

The Cairo0 bootloader's execution can be proven using a STARK prover like [stone-prover](https://github.com/starkware-libs/stone-prover).

## Work in Progress

Currently, the project supports the following builtins: `[output, range_check, pedersen, bitwise, poseidon]`. Expect further updates!