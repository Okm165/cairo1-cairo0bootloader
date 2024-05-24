from starkware.cairo.builtin_selection.select_input_builtins import select_input_builtins
from starkware.cairo.builtin_selection.validate_builtins import validate_builtins
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import KeccakBuiltin
from starkware.cairo.common.dict import dict_read
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.find_element import find_element, search_sorted
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.registers import get_ap
from starkware.starknet.builtins.segment_arena.segment_arena import (
    SegmentArenaBuiltin,
    validate_segment_arena,
)
from starkware.starknet.common.syscalls import TxInfo as DeprecatedTxInfo
from starkware.starknet.core.os.block_context import BlockContext
from starkware.starknet.core.os.builtins import (
    BuiltinEncodings,
    BuiltinParams,
    BuiltinPointers,
    NonSelectableBuiltins,
    SelectableBuiltins,
    update_builtin_ptrs,
)
from starkware.starknet.core.os.constants import (
    DEFAULT_ENTRY_POINT_SELECTOR,
    ENTRY_POINT_GAS_COST,
    ENTRY_POINT_TYPE_CONSTRUCTOR,
    ENTRY_POINT_TYPE_EXTERNAL,
    ENTRY_POINT_TYPE_L1_HANDLER,
    NOP_ENTRY_POINT_OFFSET,
)
from contract_class.compiled_class import (
    CompiledClass,
    CompiledClassEntryPoint,
    CompiledClassFact,
)
from starkware.starknet.core.os.output import OsCarriedOutputs

struct BuiltinData {
    output: felt,
    pedersen: felt,
    range_check: felt,
    ecdsa: felt,
    bitwise: felt,
    ec_op: felt,
    keccak: felt,
    poseidon: felt,
}

struct ExecutionInfo {
    caller_address: felt,
    // The execution is done in the context of the contract at this address.
    // It controls the storage being used, messages sent to L1, calling contracts, etc.
    contract_address: felt,
    // The entry point selector.
    selector: felt,
}

// Represents the execution context during the execution of contract code.
struct ExecutionContext {
    entry_point_type: felt,
    // The hash of the contract class to execute.
    class_hash: felt,
    calldata_size: felt,
    calldata: felt*,
    // Additional information about the execution.
    execution_info: ExecutionInfo*,
    // Information about the transaction that triggered the execution.
    deprecated_tx_info: DeprecatedTxInfo*,
}

// Represents the arguments pushed to the stack before calling an entry point.
struct EntryPointCallArguments {
    gas_builtin: felt,
    syscall_ptr: felt*,
    calldata_start: felt*,
    calldata_end: felt*,
}

// Represents the values returned by a call to an entry point.
struct EntryPointReturnValues {
    gas_builtin: felt,
    syscall_ptr: felt*,
    // The failure_flag is 0 if the execution succeeded and 1 if it failed.
    failure_flag: felt,
    retdata_start: felt*,
    retdata_end: felt*,
}

// Performs a Cairo jump to the function 'execute_syscalls'.
// This function's signature must match the signature of 'execute_syscalls'.
func call_execute_syscalls{
    range_check_ptr,
    syscall_ptr: felt*,
    builtin_ptrs: BuiltinPointers*,
    contract_state_changes: DictAccess*,
    contract_class_changes: DictAccess*,
    outputs: OsCarriedOutputs*,
}(block_context: BlockContext*, execution_context: ExecutionContext*, syscall_ptr_end: felt*) {
    %{
        print("call_execute_syscalls")
    %}
}

// Returns the CompiledClassEntryPoint, based on 'compiled_class' and 'execution_context'.
func get_entry_point{range_check_ptr}(
    compiled_class: CompiledClass*, execution_context: ExecutionContext*
) -> (entry_point: CompiledClassEntryPoint*) {
    alloc_locals;
    // Get the entry points corresponding to the transaction's type.
    local entry_points: CompiledClassEntryPoint*;
    local n_entry_points: felt;

    tempvar entry_point_type = execution_context.entry_point_type;
    if (entry_point_type == ENTRY_POINT_TYPE_L1_HANDLER) {
        entry_points = compiled_class.l1_handlers;
        n_entry_points = compiled_class.n_l1_handlers;
    } else {
        if (entry_point_type == ENTRY_POINT_TYPE_EXTERNAL) {
            entry_points = compiled_class.external_functions;
            n_entry_points = compiled_class.n_external_functions;
        } else {
            assert entry_point_type = ENTRY_POINT_TYPE_CONSTRUCTOR;
            entry_points = compiled_class.constructors;
            n_entry_points = compiled_class.n_constructors;

            if (n_entry_points == 0) {
                return (entry_point=cast(0, CompiledClassEntryPoint*));
            }
        }
    }

    // The key must be at offset 0.
    static_assert CompiledClassEntryPoint.selector == 0;
    let (entry_point_desc: CompiledClassEntryPoint*, success) = search_sorted(
        array_ptr=cast(entry_points, felt*),
        elm_size=CompiledClassEntryPoint.SIZE,
        n_elms=n_entry_points,
        key=execution_context.execution_info.selector,
    );
    if (success != 0) {
        return (entry_point=entry_point_desc);
    }

    // If the selector was not found, verify that the first entry point is the default entry point,
    // and call it.
    assert_not_zero(n_entry_points);
    assert entry_points[0].selector = DEFAULT_ENTRY_POINT_SELECTOR;
    return (entry_point=&entry_points[0]);
}

// Executes an entry point in a contract.
// The contract entry point is selected based on execution_context.entry_point_type
// and execution_context.execution_info.selector.
//
// Arguments:
// block_context - a global context that is fixed throughout the block.
// execution_context - The context for the current execution.
func execute_entry_point{
    range_check_ptr,
    builtin_ptrs: BuiltinPointers*,
    builtin_encodings: BuiltinData*,
}(compiled_class: CompiledClass*, execution_context: ExecutionContext*) -> (
    retdata_size: felt, retdata: felt*
) {
    alloc_locals;

    let (compiled_class_entry_point: CompiledClassEntryPoint*) = get_entry_point(
        compiled_class=compiled_class, execution_context=execution_context
    );

    if (compiled_class_entry_point == cast(0, CompiledClassEntryPoint*)) {
        // Assert that there is no call data in the case of NOP entry point.
        assert execution_context.calldata_size = 0;
        %{ execution_helper.skip_call() %}
        return (retdata_size=0, retdata=cast(0, felt*));
    }

    let entry_point_offset = compiled_class_entry_point.offset;
    local range_check_ptr = range_check_ptr;
    local contract_entry_point: felt* = compiled_class.bytecode_ptr + entry_point_offset;

    local syscall_ptr: felt*;

    %{
        ids.syscall_ptr = segments.add()
    %}

    let builtin_ptrs: BuiltinPointers* = prepare_builtin_ptrs_for_execute(builtin_ptrs);

    let n_builtins = BuiltinEncodings.SIZE;
    local calldata_start: felt* = execution_context.calldata;
    local calldata_end: felt* = calldata_start + execution_context.calldata_size;
    local entry_point_n_builtins = compiled_class_entry_point.n_builtins;
    local entry_point_builtin_list: felt* = compiled_class_entry_point.builtin_list;
    // Call select_input_builtins to push the relevant builtin pointer arguments on the stack.
    select_input_builtins(
        all_encodings=builtin_encodings,
        all_ptrs=builtin_ptrs,
        n_all_builtins=n_builtins,
        selected_encodings=entry_point_builtin_list,
        n_selected_builtins=entry_point_n_builtins,
    );

    // Use tempvar to pass the rest of the arguments to contract_entry_point().
    let current_ap = ap;
    tempvar args = EntryPointCallArguments(
        gas_builtin=10000000000,
        syscall_ptr=syscall_ptr,
        calldata_start=calldata_start,
        calldata_end=calldata_end,
    );
    static_assert ap == current_ap + EntryPointCallArguments.SIZE;

    %{
        print(ids.compiled_class_entry_point.n_builtins)
        print(ids.calldata_start)
        print(ids.calldata_end)
        print(ids.contract_entry_point)
        print(ids.syscall_ptr)
    %}

    %{ vm_enter_scope() %}
    call abs contract_entry_point;
    %{ vm_exit_scope() %}

    // Retrieve returned_builtin_ptrs_subset.
    // Note that returned_builtin_ptrs_subset cannot be set in a hint because doing so will allow a
    // malicious prover to lie about the storage changes of a valid contract.
    // let (ap_val) = get_ap();
    // local return_values_ptr: felt* = ap_val - EntryPointReturnValues.SIZE;
    // local returned_builtin_ptrs_subset: felt* = return_values_ptr - entry_point_n_builtins;
    // local entry_point_return_values: EntryPointReturnValues* = cast(
    //     return_values_ptr, EntryPointReturnValues*
    // );

    return (retdata_size=0, retdata=cast(0, felt*));
}

// Prepares the builtin pointer for the execution of an entry point.
// In particular, restarts the SegmentArenaBuiltin struct if it was previously used.
func prepare_builtin_ptrs_for_execute(builtin_ptrs: BuiltinPointers*) -> BuiltinPointers* {
    let selectable_builtins = &builtin_ptrs.selectable;
    tempvar segment_arena_ptr = selectable_builtins.segment_arena;
    tempvar prev_segment_arena = &segment_arena_ptr[-1];

    // If no segment was allocated, we don't need to restart the struct.
    tempvar prev_n_segments = prev_segment_arena.n_segments;
    if (prev_n_segments == 0) {
        return builtin_ptrs;
    }

    assert segment_arena_ptr[0] = SegmentArenaBuiltin(
        infos=&prev_segment_arena.infos[prev_n_segments], n_segments=0, n_finalized=0
    );
    let segment_arena_ptr = &segment_arena_ptr[1];
    return new BuiltinPointers(
        selectable=SelectableBuiltins(
            pedersen=selectable_builtins.pedersen,
            range_check=selectable_builtins.range_check,
            ecdsa=selectable_builtins.ecdsa,
            bitwise=selectable_builtins.bitwise,
            ec_op=selectable_builtins.ec_op,
            poseidon=selectable_builtins.poseidon,
            segment_arena=segment_arena_ptr,
        ),
        non_selectable=builtin_ptrs.non_selectable,
    );
}
