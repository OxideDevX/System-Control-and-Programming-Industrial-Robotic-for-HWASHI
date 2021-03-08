# Add a pause (please enter miliseconds)
program.Pause(2000) # pause motion 2 second(correct for you situation)

# Stop the program so that it can be resumed
# It provokes a STOP (pause until the operator desires to resume)
program.Pause() 

# Add a program call or specific code in the program:
program.RunInstruction('ChangeTool(2)',INSTRUCTION_CALL_PROGRAM)
program.RunInstruction('ChangeTool(2);',INSTRUCTION_INSERT_CODE)

# Set a digital output
program.setDO('DO_NAME', 1)
# Wait for a digital input:
program.waitDI('DI_NAME', 1)
