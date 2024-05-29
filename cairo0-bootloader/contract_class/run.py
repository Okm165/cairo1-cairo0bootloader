from contract_class.contract_class import *

with open("../../cairo1/contract.json") as contract_file:
    contract = CompiledClass.deserialize(contract_file.read().encode())
    print(contract.get_runnable_program("output"))
