%builtins output pedersen range_check ecdsa bitwise ec_op poseidon

from bootloader.starknet.run_simple_bootloader import (
    run_simple_bootloader,
)
from common.cairo_builtins import HashBuiltin, PoseidonBuiltin
from common.registers import get_fp_and_pc

func main{
    output_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
    ecdsa_ptr,
    bitwise_ptr,
    ec_op_ptr,
    poseidon_ptr: PoseidonBuiltin*,
}() {
    alloc_locals;
    local compiled_class;

    %{
        from bootloader.objects import ContractBootloaderInput
        contract_bootloader_input = ContractBootloaderInput.Schema().load(program_input)
    %}

    // Fetch contract data form hints.
    %{
        from starkware.starknet.core.os.contract_class.compiled_class_hash import create_bytecode_segment_structure
        from contract_class.compiled_class_hash_utils import get_compiled_class_struct

        bytecode_segment_structure = create_bytecode_segment_structure(
            bytecode=contract_bootloader_input.compiled_class.bytecode,
            bytecode_segment_lengths=contract_bootloader_input.compiled_class.bytecode_segment_lengths,
            visited_pcs=None,
        )

        cairo_contract = get_compiled_class_struct(
            compiled_class=contract_bootloader_input.compiled_class,
            bytecode=bytecode_segment_structure.bytecode_with_skipped_segments()
        )
        ids.compiled_class = segments.gen_arg(cairo_contract)
    %}

    // // Execute tasks.
    // run_simple_bootloader();

    // %{
    //     # Dump fact topologies to a json file.
    //     from bootloader.utils import (
    //         configure_fact_topologies,
    //         write_to_fact_topologies_file,
    //     )

    //     # The task-related output is prefixed by a single word that contains the number of tasks.
    //     tasks_output_start = output_builtin.base + 1

    //     if not simple_bootloader_input.single_page:
    //         # Configure the memory pages in the output builtin, based on fact_topologies.
    //         configure_fact_topologies(
    //             fact_topologies=fact_topologies, output_start=tasks_output_start,
    //             output_builtin=output_builtin,
    //         )

    //     if simple_bootloader_input.fact_topologies_path is not None:
    //         write_to_fact_topologies_file(
    //             fact_topologies_path=simple_bootloader_input.fact_topologies_path,
    //             fact_topologies=fact_topologies,
    //         )
    // %}
    return ();
}