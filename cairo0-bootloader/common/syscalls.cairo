from starkware.cairo.common.dict_access import DictAccess

const CALL_CONTRACT_SELECTOR = 'CallContract';

// Describes the CallContract system call format.
struct CallContractRequest {
    // The system call selector
    // (= CALL_CONTRACT_SELECTOR, DELEGATE_CALL_SELECTOR or DELEGATE_L1_HANDLER_SELECTOR).
    selector: felt,
    // The address of the L2 contract to call.
    contract_address: felt,
    // The selector of the function to call.
    function_selector: felt,
    // The size of the calldata.
    calldata_size: felt,
    // The calldata.
    calldata: felt*,
}

struct CallContractResponse {
    retdata_size: felt,
    retdata: felt*,
}

struct CallContract {
    request: CallContractRequest,
    response: CallContractResponse,
}

func call_contract{syscall_ptr: felt*}(
    contract_address: felt, function_selector: felt, calldata_size: felt, calldata: felt*
) -> (retdata_size: felt, retdata: felt*) {
    let syscall = [cast(syscall_ptr, CallContract*)];
    assert syscall.request = CallContractRequest(
        selector=CALL_CONTRACT_SELECTOR,
        contract_address=contract_address,
        function_selector=function_selector,
        calldata_size=calldata_size,
        calldata=calldata,
    );
    %{ syscall_handler.call_contract(segments=segments, syscall_ptr=ids.syscall_ptr) %}
    let response = syscall.response;

    let syscall_ptr = syscall_ptr + CallContract.SIZE;
    return (retdata_size=response.retdata_size, retdata=response.retdata);
}
