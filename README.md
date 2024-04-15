# Cairo1->Cairo0Bootloader

This project implements a modified version of the Cairo0 bootloader to facilitate the loading and execution of Cairo1 compiled PIE zip files. This enables interoperability between Cairo1 and Cairo0, allowing Cairo1 tasks to run within the Cairo0 bootloader environment.

## Getting Started

To set up the project environment and run the bootloader, follow these steps:

0. **Clone Repository**: Clone the repository and initialize submodules:
   ```bash
   git clone https://github.com/Okm165/cairo1-cairo0bootloader.git
   cd cairo1-cairo0bootloader
   git submodule update --init
   ```

1. **Setup Python Environment**: Ensure you have a Python 3.9.0 environment set up & `pip install colorama` for pretty outputs.

2. **Installation**: Run `python setup.py` to install the necessary dependencies and set up the project.

3. **Compile Cairo1**: Compile Cairo1 files into the Cairo PIE format by running `python compile.py`.

4. **Run Bootloader**: Start the bootloader by running `python run.py`, which will initiate the loading and execution of Cairo1 tasks within the Cairo0 environment.

---

This example demonstrates running a simple Cairo1 program within the Cairo0 provable environment:

```cairo
use core::{
    hash::{HashStateTrait, HashStateExTrait, Hash},
    integer::U128BitAnd
    pedersen::PedersenTrait,
};
use poseidon::{hades_permutation, poseidon_hash_span};

fn main() -> (bool, felt252, u128, felt252) {
    let range_check = 2_u128 > 1_u128;
    assert(range_check == true, 'Invalid value');

    let mut state = PedersenTrait::new(2);
    state = state.update_with(2);
    let pedersen = state.finalize();
    assert(pedersen == 1180550645873507273865212362837104046225859416703538577277065670066180087996, 'Invalid value');

    let bitwise = U128BitAnd::bitand(0x4, 0x5);
    assert(bitwise == 4, 'Invalid value');

    let (poseidon, _, _) = hades_permutation(1, 2, 3);
    assert(poseidon == 442682200349489646213731521593476982257703159825582578145778919623645026501, 'Invalid value');

    (range_check, pedersen, bitwise, poseidon)
}
```

The execution of Cairo0 bootloader can then be proven using a STARK prover like [stone-prover](https://github.com/starkware-libs/stone-prover).

## Work in Progress

At the moment, the following builtins are supported: `[output, range_check, pedersen, bitwise, poseidon]`. Stay tuned for more additions!