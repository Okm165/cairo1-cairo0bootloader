use core::{
    hash::{HashStateTrait, HashStateExTrait, Hash},
    integer::U128BitAnd,
    pedersen::PedersenTrait,
};
use poseidon::{hades_permutation, poseidon_hash_span};

#[derive(Drop, Serde)]
struct Input {
    a: u32,
    b: u32,
    c: u32,
}

struct Output {
    a_2: u32,
    b_2: u32,
    c_2: u32,
}

fn main(input: Array<felt252>) -> Output {
    let mut input_span = input.span();
    let input = Serde::<Input>::deserialize(ref input_span).unwrap();

    let a_2 = input.a * input.a;
    let b_2 = input.b * input.b;
    let c_2 = input.c * input.c;
    assert (a_2 + b_2 == c_2, 'invalid value');

    Output {
        a_2,
        b_2,
        c_2,
    }
}
