from typing import (
    Dict,
    Iterable,
)
from starkware.cairo.lang.vm.relocatable import RelocatableValue, MaybeRelocatable
from starkware.cairo.lang.vm.memory_segments import MemorySegmentManager
from bootloader.contract.syscall_handler_base import SyscallHandlerBase
from starkware.cairo.common.structs import CairoStructProxy
from starkware.cairo.common.dict import DictManager
from starkware.starknet.business_logic.execution.objects import (
    CallResult,
)

class SyscallHandler(SyscallHandlerBase):
    """
    A handler for system calls; used by the BusinessLogic entry point execution.
    """

    def __init__(
        self,
        segments: MemorySegmentManager,
        dict_manager: DictManager,
    ):
        print("init")
        super().__init__(segments=segments, initial_syscall_ptr=None)
        self.syscall_counter: Dict[str, int] = {}
        self.dict_manager = dict_manager
        print("initialized")

    def set_syscall_ptr(self, syscall_ptr: RelocatableValue):
        assert self._syscall_ptr is None, "syscall_ptr is already set."
        self._syscall_ptr = syscall_ptr

    def allocate_segment(self, data: Iterable[MaybeRelocatable]) -> RelocatableValue:
        segment_start = self.segments.add()
        self.segments.write_arg(ptr=segment_start, arg=data)
        return segment_start

    def _allocate_segment_for_retdata(self, retdata: Iterable[int]) -> RelocatableValue:
        return self.allocate_segment(data=retdata)

    def _call_contract_helper(
        self, request: CairoStructProxy, syscall_name: str
    ) -> CallResult:
        calldata = self._get_felt_range(
            start_addr=request.calldata_start, end_addr=request.calldata_end
        )

        dictionary = self.dict_manager.get_dict(RelocatableValue.from_tuple([calldata[0], calldata[1]]))

        print("dictionary", dictionary)

        print("calldata", calldata)
        return CallResult(
            gas_consumed=0,
            failure_flag=0,
            retdata=[int(dictionary[calldata[2]])],
        )