#[starknet::interface]
pub trait IHelloStarknet<TContractState> {
    fn main(ref self: TContractState, input: Array<felt252>) -> Array<felt252>;
}

#[starknet::contract]
mod HelloStarknet {
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
    impl HelloStarknetImpl of super::IHelloStarknet<ContractState> {
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
