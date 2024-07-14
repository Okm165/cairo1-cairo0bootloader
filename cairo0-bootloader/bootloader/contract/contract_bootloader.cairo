%builtins output pedersen range_check ecdsa bitwise ec_op keccak poseidon

from bootloader.contract.run_contract_bootloader import run_contract_bootloader
from starkware.cairo.common.cairo_builtins import (
    HashBuiltin,
    PoseidonBuiltin,
    BitwiseBuiltin,
    KeccakBuiltin,
)
from starkware.cairo.common.registers import get_fp_and_pc
from contract_class.compiled_class import CompiledClass, compiled_class_hash

func main{
    output_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
    ecdsa_ptr,
    bitwise_ptr: BitwiseBuiltin*,
    ec_op_ptr,
    keccak_ptr: KeccakBuiltin*,
    poseidon_ptr: PoseidonBuiltin*,
}() {
    alloc_locals;
    local compiled_class: CompiledClass*;

    %{
        from bootloader.objects import ContractBootloaderInput
        compiled_class = ContractBootloaderInput.Schema().load(program_input).compiled_class
    %}

    // Fetch contract data form hints.
    %{
        from starkware.starknet.core.os.contract_class.compiled_class_hash import create_bytecode_segment_structure
        from contract_class.compiled_class_hash_utils import get_compiled_class_struct

        bytecode_segment_structure_no_footer = create_bytecode_segment_structure(
            bytecode=compiled_class.bytecode,
            bytecode_segment_lengths=compiled_class.bytecode_segment_lengths,
            visited_pcs=None,
        )

        # Append necessary footer to the bytecode of the contract
        compiled_class.bytecode.append(0x208b7fff7fff7ffe)
        compiled_class.bytecode_segment_lengths[-1] += 1

        bytecode_segment_structure_with_footer = create_bytecode_segment_structure(
            bytecode=compiled_class.bytecode,
            bytecode_segment_lengths=compiled_class.bytecode_segment_lengths,
            visited_pcs=None,
        )

        bytecode_segment_structure = bytecode_segment_structure_with_footer

        cairo_contract = get_compiled_class_struct(
            compiled_class=compiled_class,
            bytecode=bytecode_segment_structure.bytecode_with_skipped_segments()
        )
        ids.compiled_class = segments.gen_arg(cairo_contract)
    %}

    assert compiled_class.bytecode_ptr[compiled_class.bytecode_length] = 0x208b7fff7fff7ffe;

    %{ bytecode_segment_structure = bytecode_segment_structure_no_footer %}

    let (local program_hash) = compiled_class_hash(compiled_class=compiled_class);

    %{ bytecode_segment_structure = bytecode_segment_structure_with_footer %}

    %{ print("program_hash", hex(ids.program_hash)) %}

    %{
        vm_load_program(
            compiled_class.get_runnable_program(entrypoint_builtins=[]),
            ids.compiled_class.bytecode_ptr
        )
    %}

    run_contract_bootloader(compiled_class);

    return ();
}
