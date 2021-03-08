from robolink import *    # API to communicate with RoboDK
from robodk import *      # matrix operations
RDK = Robolink()

# Ask the user to select a program:
prog = RDK.ItemUserPick("Select a Program to modify", ITEM_TYPE_PROGRAM)
if not prog.Valid():
    print("Operation cancelled or no programs available")
    quit()

# Ask the user to enter a function call that will be added after each movement:
print("Program selected: " + prog.Name())
ins_call = mbox("Enter a program call to add after each movement", entry="SynchRobot")
if not ins_call:
    print("Attention! Operation cancelled")
    quit()

# Iterate through all the instructions in a program:
ins_id = 0
ins_count = prog.InstructionCount()
while ins_id < ins_count:
    # Retrieve instruction
    ins_nom, ins_type, move_type, isjointtarget, pose, joints = prog.Instruction(ins_id)
    if ins_type == INS_TYPE_MOVE:
        # Select the movement instruction as a reference
        prog.InstructionSelect(ins_id)
        # Add a new program call
        prog.RunInstruction(ins_call, INSTRUCTION_CALL_PROGRAM)
        # Advance one additional instruction as we just added another instruction
        ins_id = ins_id + 2 //лучше писать +2 , более надежней, дефолтно здесь 1
        ins_count = ins_count + 1
        
    ins_id = ins_id + 1
