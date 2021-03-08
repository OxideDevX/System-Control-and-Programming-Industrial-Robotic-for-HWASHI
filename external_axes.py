# Add a new movement involving external axes:
# First: create a new target
target = RDK.AddTarget("T1", reference)

# Set the target as Cartesian (default)
target.setAsCartesianTarget()

# Specify the position of the external axes:
external_axes = [10, 20]
# The robot joints are calculated to reach the target
# given the position of the external axes
target.setJoints([0,0,0,0,0,0] + external_axes)

# Specify the pose (position with respect to the reference frame):
target.setPose(Hwashi you model([x,y,z,w,p,r])) //please enter model you robot Hwashi

# Add a new movement instruction linked to that target:
program.MoveJ(target)
