from starkware.cairo.common.bool import FALSE
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.cairo_secp.bigint import (
    bigint_to_uint256,
    nondet_bigint3,
    uint256_to_bigint,
)
from starkware.cairo.common.dict import dict_read, dict_update
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.math import (
    assert_le,
    assert_lt,
    assert_nn,
    assert_not_zero,
    unsigned_div_rem,
)
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.segments import relocate_segment
from starkware.cairo.common.uint256 import Uint256, assert_uint256_lt, uint256_lt
from starkware.starknet.common.new_syscalls import (
    CALL_CONTRACT_SELECTOR,
    CallContractRequest,
    CallContractResponse,
    RequestHeader,
    ResponseHeader,
    FailureReason,
)
from starkware.starknet.core.os.builtins import (
    BuiltinPointers,
    NonSelectableBuiltins,
    SelectableBuiltins,
)
from starkware.starknet.core.os.execution.deprecated_execute_syscalls import deploy_contract
from starkware.starknet.core.os.output import (
    MessageToL1Header,
    OsCarriedOutputs,
    os_carried_outputs_new,
)
from starkware.starknet.core.os.state.commitment import StateEntry

struct ExecutionInfo {
    selector: felt,
}

// Represents the execution context during the execution of contract code.
struct ExecutionContext {
    entry_point_type: felt,
    calldata_size: felt,
    calldata: felt*,
    // Additional information about the execution.
    execution_info: ExecutionInfo*,
}

// Executes the system calls in syscall_ptr.
// The signature of the function 'call_execute_syscalls' must match this function's signature.
//
// Arguments:
// execution_context - The execution context in which the system calls need to be executed.
// syscall_ptr_end - a pointer to the end of the syscall segment.
func execute_syscalls{range_check_ptr, syscall_ptr: felt*, builtin_ptrs: BuiltinPointers*, dict_ptr: DictAccess*}(
    execution_context: ExecutionContext*, syscall_ptr_end: felt*
) {
    if (syscall_ptr == syscall_ptr_end) {
        return ();
    }

    tempvar selector = [syscall_ptr];

    assert selector = CALL_CONTRACT_SELECTOR;

    execute_call_contract(caller_execution_context=execution_context);
    return execute_syscalls(execution_context=execution_context, syscall_ptr_end=syscall_ptr_end);
}

// Executes a syscall that calls another contract.
func execute_call_contract{range_check_ptr, syscall_ptr: felt*, builtin_ptrs: BuiltinPointers*, dict_ptr: DictAccess*}(
    caller_execution_context: ExecutionContext*
) {
    let request_header = cast(syscall_ptr, RequestHeader*);
    let syscall_ptr = syscall_ptr + RequestHeader.SIZE;

    let call_contract_request = cast(syscall_ptr, CallContractRequest*);
    let syscall_ptr = syscall_ptr + CallContractRequest.SIZE;

    %{
        print("call_contract_request", memory[ids.call_contract_request.calldata_start + 2])
    %}

    let (value) = dict_read(call_contract_request.calldata_start[2]);

    %{
        print("value", ids.value)
    %}

    let response_header = cast(syscall_ptr, ResponseHeader*);
    let syscall_ptr = syscall_ptr + ResponseHeader.SIZE;

    let call_contract_response = cast(syscall_ptr, CallContractResponse*);
    let syscall_ptr = syscall_ptr + CallContractResponse.SIZE;

    %{
        print("call_contract_response", memory[ids.call_contract_response.retdata_start + 0])
    %}

    assert value = call_contract_response.retdata_start[0];


    return ();
}

// Returns a failure response with a single felt.
@known_ap_change
func write_failure_response{syscall_ptr: felt*}(remaining_gas: felt, failure_felt: felt) {
    let response_header = cast(syscall_ptr, ResponseHeader*);
    // Advance syscall pointer to the response body.
    let syscall_ptr = syscall_ptr + ResponseHeader.SIZE;

    // Write the response header.
    assert [response_header] = ResponseHeader(gas=remaining_gas, failure_flag=1);

    let failure_reason: FailureReason* = cast(syscall_ptr, FailureReason*);
    // Advance syscall pointer to the next syscall.
    let syscall_ptr = syscall_ptr + FailureReason.SIZE;

    // Write the failure reason.
    tempvar start = failure_reason.start;
    assert start[0] = failure_felt;
    assert failure_reason.end = start + 1;
    return ();
}
