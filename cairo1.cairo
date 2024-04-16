use core::{
    hash::{HashStateTrait, HashStateExTrait, Hash},
    integer::U128BitAnd,
    pedersen::PedersenTrait,
};
use poseidon::{hades_permutation, poseidon_hash_span};

fn main(index_a: u32, array_a: Array<u32>, index_b: u32, array_b: Array<u32>) -> (bool, felt252, u128, felt252) {
    let range_check = *array_a.at(index_a) + *array_b.at(index_b) > 10;

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
