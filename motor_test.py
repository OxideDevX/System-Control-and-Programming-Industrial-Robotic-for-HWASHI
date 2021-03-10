import time
from control_motores import *

MotorsSetup()

BaseSpeed(100)
print("100")
time.sleep(5)

#Direction(25)
#time.sleep(31)

MotorsStop()
print("STOP")
