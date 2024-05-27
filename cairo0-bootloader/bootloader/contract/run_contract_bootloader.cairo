from starkware.cairo.common.cairo_builtins import (
    HashBuiltin,
    PoseidonBuiltin,
    BitwiseBuiltin,
    KeccakBuiltin,
)
from starkware.cairo.common.registers import get_fp_and_pc
from contract_class.compiled_class import CompiledClass
from starkware.starknet.builtins.segment_arena.segment_arena import new_arena
from starkware.starknet.core.os.builtins import (
    BuiltinPointers,
    NonSelectableBuiltins,
    SelectableBuiltins,
)
from bootloader.contract.execute_entry_point import (
    execute_entry_point,
    ExecutionContext,
    ExecutionInfo,
    BuiltinData,
)

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

    local local_builtin_encodings: BuiltinData = BuiltinData(
        output='output',
        pedersen='pedersen',
        range_check='range_check',
        ecdsa='ecdsa',
        bitwise='bitwise',
        ec_op='ec_op',
        keccak='keccak',
        poseidon='poseidon',
    );
    let builtin_encodings = &local_builtin_encodings;

    local calldata: felt*;
    %{ ids.calldata = segments.add() %}

    local execution_info: ExecutionInfo = ExecutionInfo(selector=0);

    from starkware.starknet.core.os.constants import (
        DEFAULT_ENTRY_POINT_SELECTOR,
        ENTRY_POINT_GAS_COST,
        ENTRY_POINT_TYPE_CONSTRUCTOR,
        ENTRY_POINT_TYPE_EXTERNAL,
        ENTRY_POINT_TYPE_L1_HANDLER,
        NOP_ENTRY_POINT_OFFSET,
    )

    local execution_context: ExecutionContext = ExecutionContext(
        entry_point_type=ENTRY_POINT_TYPE_EXTERNAL,
        calldata_size=0,
        calldata=calldata,
        execution_info=&execution_info,
    );

    with builtin_ptrs, builtin_encodings {
        let (retdata_size, retdata) = execute_entry_point(compiled_class, &execution_context);
    }

    return ();
}
