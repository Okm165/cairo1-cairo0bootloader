from starkware.cairo.common.cairo_builtins import (
    HashBuiltin,
    PoseidonBuiltin,
    BitwiseBuiltin,
    KeccakBuiltin,
    SignatureBuiltin,
    EcOpBuiltin,
)
from starkware.cairo.common.registers import get_fp_and_pc
from contract_class.compiled_class import CompiledClass
from starkware.starknet.builtins.segment_arena.segment_arena import new_arena, SegmentArenaBuiltin
from starkware.starknet.core.os.builtins import (
    BuiltinEncodings,
    BuiltinParams,
    BuiltinPointers,
    NonSelectableBuiltins,
    BuiltinInstanceSizes,
    SelectableBuiltins,
    update_builtin_ptrs,
)
from bootloader.contract.execute_entry_point import execute_entry_point
from bootloader.contract.execute_syscalls import ExecutionContext, ExecutionInfo
from starkware.starknet.core.os.constants import ENTRY_POINT_TYPE_EXTERNAL

// Loads the programs and executes them.
//
// Hint Arguments:
// compiled_class - contains the contract to execute.
//
// Returns:
// Updated builtin pointers after executing all programs.
// fact_topologies - that corresponds to the tasks (hint variable).
func run_contract_bootloader{
    output_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
    ecdsa_ptr,
    bitwise_ptr: BitwiseBuiltin*,
    ec_op_ptr,
    keccak_ptr: KeccakBuiltin*,
    poseidon_ptr: PoseidonBuiltin*,
}(compiled_class: CompiledClass*) {
    alloc_locals;

    // Prepare builtin pointers.
    let segment_arena_ptr = new_arena();

    let (__fp__, _) = get_fp_and_pc();
    local local_builtin_ptrs: BuiltinPointers = BuiltinPointers(
        selectable=SelectableBuiltins(
            pedersen=pedersen_ptr,
            range_check=nondet %{ segments.add() %},
            ecdsa=ecdsa_ptr,
            bitwise=bitwise_ptr,
            ec_op=ec_op_ptr,
            poseidon=poseidon_ptr,
            segment_arena=segment_arena_ptr,
        ),
        non_selectable=NonSelectableBuiltins(keccak=keccak_ptr),
    );
    let builtin_ptrs = &local_builtin_ptrs;

    %{ print("builtin_ptrs.selectable.range_check: ", ids.builtin_ptrs.selectable.range_check) %}

    local local_builtin_encodings: BuiltinEncodings = BuiltinEncodings(
        pedersen='pedersen',
        range_check='range_check',
        ecdsa='ecdsa',
        bitwise='bitwise',
        ec_op='ec_op',
        poseidon='poseidon',
        segment_arena='segment_arena',
    );

    local local_builtin_instance_sizes: BuiltinInstanceSizes = BuiltinInstanceSizes(
        pedersen=HashBuiltin.SIZE,
        range_check=1,
        ecdsa=SignatureBuiltin.SIZE,
        bitwise=BitwiseBuiltin.SIZE,
        ec_op=EcOpBuiltin.SIZE,
        poseidon=PoseidonBuiltin.SIZE,
        segment_arena=SegmentArenaBuiltin.SIZE,
    );

    local local_builtin_params: BuiltinParams = BuiltinParams(
        builtin_encodings=&local_builtin_encodings,
        builtin_instance_sizes=&local_builtin_instance_sizes,
    );
    let builtin_params = &local_builtin_params;

    local calldata: felt*;
    %{ ids.calldata = segments.add() %}

    assert calldata[0] = 0x0;

    local execution_info: ExecutionInfo = ExecutionInfo(
        selector=0x00e2054f8a912367e38a22ce773328ff8aabf8082c4120bad9ef085e1dbf29a7
    );

    local execution_context: ExecutionContext = ExecutionContext(
        entry_point_type=ENTRY_POINT_TYPE_EXTERNAL,
        calldata_size=1,
        calldata=calldata,
        execution_info=&execution_info,
    );

    with builtin_ptrs, builtin_params {
        let (retdata_size, retdata) = execute_entry_point(compiled_class, &execution_context);
    }

    return ();
}
