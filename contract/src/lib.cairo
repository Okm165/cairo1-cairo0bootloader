#[starknet::contract]
mod Factorial {
    use starknet::{ContractAddress, SyscallResult, SyscallResultTrait};
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