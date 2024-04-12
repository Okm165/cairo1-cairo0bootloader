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
