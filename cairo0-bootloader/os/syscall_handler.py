from typing import Iterable
from starkware.starknet.core.os.syscall_handler import SyscallHandlerBase, OsExecutionHelper
from starkware.cairo.lang.vm.relocatable import RelocatableValue, MaybeRelocatable
from starkware.cairo.lang.vm.memory_segments import MemorySegmentManager

class SyscallHandler(SyscallHandlerBase):
    """
    A handler for system calls; used by the BusinessLogic entry point execution.
    """

    def __init__(
        self,
        segments: MemorySegmentManager,
    ):
        super().__init__(segments=segments, initial_syscall_ptr=None)

    def set_syscall_ptr(self, syscall_ptr: RelocatableValue):
        assert self._syscall_ptr is None, "syscall_ptr is already set."
        self._syscall_ptr = syscall_ptr

    def allocate_segment(self, data: Iterable[MaybeRelocatable]) -> RelocatableValue:
        segment_start = self.segments.add()
        self.segments.write_arg(ptr=segment_start, arg=data)
        return segment_start