# Cairo1->Cairo0Bootloader

This project implements a modified version of the Cairo0 bootloader to facilitate the loading and execution of Cairo1 compiled PIE (Proof-Carrying Code) zip files. This enables interoperability between Cairo1 and Cairo0, allowing Cairo1 tasks to run within the Cairo0 bootloader environment.

## Getting Started

To set up the project environment and run the bootloader, follow these steps:

0. **Clone Repository**: Clone the repository and initialize submodules:
   ```bash
   git clone https://github.com/Okm165/cairo1-cairo0bootloader.git
   cd cairo1-cairo0bootloader
   git submodule update --init
   ```

1. **Setup Python Environment**: Ensure you have a Python 3.9.0 environment set up.

2. **Installation**: Run `python setup.py` to install the necessary dependencies and set up the project.

3. **Compile Cairo1**: Compile Cairo1 files into the Cairo PIE format by running `python compile.py`.

4. **Run Bootloader**: Start the bootloader by running `python run.py`, which will initiate the loading and execution of Cairo1 tasks within the Cairo0 environment.

This example demonstrates running a simple Cairo1 program within the Cairo0 provable environment:

```cairo
fn poly(a: felt252, b: felt252, c: felt252, x: felt252) -> felt252 {
    a * x * x + b * x + c
}

fn main() -> felt252 {
    let a: felt252 = 2;
    let b: felt252 = 3;
    let c: felt252 = 1;
    let x: felt252 = 10;

    // (200 + 30 + 1) + (100 + 30 + 2) = 363 bootloader will output this value as the output of the task
    poly(a, b, c, x) + poly(c, b, a, x)
}
```

The execution of Cairo0 bootloader can then be proven using a STARK prover like [stone-prover](https://github.com/starkware-libs/stone-prover).

## Work in Progress

Currently, only output builtin is supported. More builtins will be added soon!
