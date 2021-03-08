from robolink import *    # API to communicate with RoboDK
from robodk import *      # basic matrix operations

# Start the with RoboDK
RDK = Robolink()

# Select the robot
ROBOT = RDK.ItemUserPick('Select a robot', ITEM_TYPE_ROBOT)

FRAME = RDK.Item('Path Reference', ITEM_TYPE_FRAME)
TOOL = RDK.Item('Tool Reference', ITEM_TYPE_TOOL)
if not FRAME.Valid() or not TOOL.Valid():
    raise Exception("Select appropriate FRAME and TOOL references")

# Check if the user selected a robot
if not ROBOT.Valid():
    quit()

# csv_file = 'C:/Users/Albert/Desktop/Var_P.csv'
csv_file = getOpenFile(RDK.getParam('PATH_OPENSTATION'))

# Load P_Var.CSV data as a list of poses, including links to reference and tool frames
def load_targets(strfile):
    csvdata = LoadList(strfile, ',', 'utf-8')
    poses = []
    idxs = []
    for i in range(0, len(csvdata)):
        x,y,z,rx,ry,rz = csvdata[i][0:6]
        poses.append(transl(x,y,z)*rotz(rz*pi/180)*roty(ry*pi/180)*rotx(rx*pi/180))
        idxs.append(csvdata[i][6])
    return poses, idxs

# Load and display Targets from the CSV file
def load_targets_GUI(strfile):
    poses, idxs = load_targets(strfile)
    program_name = getFileName(strfile)
    program_name = program_name.replace('-','_').replace(' ','_')
    program = RDK.Item(program_name, ITEM_TYPE_PROGRAM)
    if program.Valid():
        program.Delete()
        
    program = RDK.AddProgram(program_name, ROBOT)
    program.setFrame(FRAME)
    program.setTool(TOOL)
    ROBOT.MoveJ(ROBOT.JointsHome())
    
    for pose, idx in zip(poses, idxs):
        name = '%s-%i' % (program_name, idx)
        target = RDK.Item(name, ITEM_TYPE_TARGET)
        if target.Valid():
            target.Delete()
        target = RDK.AddTarget(name, FRAME, ROBOT)
        target.setPose(pose)
        
        try:
            program.MoveJ(target)
        except:
            print('Warning: %s can not be reached. It will not be added to the program' % name)


def load_targets_move(strfile):
    poses, idxs = load_targets(strfile)
    
    ROBOT.setFrame(FRAME)
    ROBOT.setTool(TOOL)

    ROBOT.MoveJ(ROBOT.JointsHome())
    
    for pose, idx in zip(poses, idxs):
        try:
            ROBOT.MoveJ(pose)
        except:
            RDK.ShowMessage('Target %i can not be reached' % idx, False)
        

# Force just moving the robot after double clicking
#load_targets_move(csv_file)
#quit()

# Recommended mode of operation:
# 1-Double click the python file creates a program in RoboDK station
# 2-Generate program generates the program directly

MAKE_GUI_PROGRAM = False

ROBOT.setFrame(FRAME)
ROBOT.setTool(TOOL)


if RDK.RunMode() == RUNMODE_SIMULATE:
    MAKE_GUI_PROGRAM = True
    # MAKE_GUI_PROGRAM = mbox('Do you want to create a new program? If not, the robot will just move along the tagets', 'Yes', 'No')
    
else:
    # if we run in program generation mode just move the robot
    MAKE_GUI_PROGRAM = False


if MAKE_GUI_PROGRAM:
    RDK.Render(False) # Faster if we turn render off
    load_targets_GUI(csv_file)
else:
    load_targets_move(csv_file)
