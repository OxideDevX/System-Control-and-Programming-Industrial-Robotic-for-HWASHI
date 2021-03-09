from __future__ import print_function
import struct
import copy

class RobotStateRT(object):
    @staticmethod
    def unpack(buf):
        rs = RobotStateRT()
        (plen, ptype) = struct.unpack_from("!IB", buf)
        if plen == 756:
            return RobotStateRT_V15.unpack(buf)        
        elif plen == 812:
            return RobotStateRT_V18.unpack(buf)
        elif plen == 1044:
            return RobotStateRT_V30.unpack(buf)
        else:
            print("RobotStateRT has wrong length: " + str(plen))
            return rs

class RobotStateRT_V15(object):
    __slots__ = ['time', 
                 'q_target', 'qd_target', 'qdd_target', 'i_target', 'm_target', 
                 'q_actual', 'qd_actual', 'i_actual', 'tool_acc_values', 
                 'unused', 
                 'tcp_force', 'tool_vector', 'tcp_speed', 
                 'digital_input_bits', 'motor_temperatures', 'controller_timer', 
                 'test_value']

    @staticmethod
    def unpack(buf):
        offset = 0
        message_size = struct.unpack_from("!i", buf, offset)[0]
        offset+=4
        if message_size != len(buf):
            print(("MessageSize: ", message_size, "; BufferSize: ", len(buf)))
            raise Exception("Could not unpack RobotStateRT packet: length field is incorrect")

        rs = RobotStateRT_V15()
        rs.time = struct.unpack_from("!d",buf, offset)[0]
        offset+=8
        
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.q_target = copy.deepcopy(all_values)
        
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.qd_target = copy.deepcopy(all_values)
        
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.qdd_target = copy.deepcopy(all_values)
        
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.i_target = copy.deepcopy(all_values)
        
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.m_target = copy.deepcopy(all_values)
        
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.q_actual = copy.deepcopy(all_values)
        
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.qd_actual = copy.deepcopy(all_values)
        
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.i_actual = copy.deepcopy(all_values)

        ###
        
        #tool_acc_values: 
        all_values = list(struct.unpack_from("!ddd",buf, offset))
        offset+=3*8
        rs.tool_acc_values = copy.deepcopy(all_values)
        offset+=120
        rs.unused = []
        
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.tcp_force = copy.deepcopy(all_values)
        
        #tool_vector
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.tool_vector = copy.deepcopy(all_values)
        
        #tcp_speed
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.tcp_speed = copy.deepcopy(all_values)
        rs.digital_input_bits = struct.unpack_from("!d",buf, offset)[0]
        offset+=8

        #motor_temperatures: 
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.motor_temperatures = copy.deepcopy(all_values)
        
        #controller_timer: 
        rs.controller_timer = struct.unpack_from("!d",buf, offset)[0]
        offset+=8
        
        #test_value: 
        rs.test_value = struct.unpack_from("!d",buf, offset)[0]
        offset+=8

        return rs  


class HWASHI ROBOT(object):
    __slots__ = ['time', 
                 'q_target', 'qd_target', 'qdd_target', 'i_target', 'm_target', 
                 'q_actual', 'qd_actual', 'i_actual', 'tool_acc_values', 
                 'unused', 
                 'tcp_force', 'tool_vector', 'tcp_speed', 
                 'digital_input_bits', 'motor_temperatures', 'controller_timer', 
                 'test_value', 
                 'robot_mode', 'joint_modes']

    @staticmethod
    def unpack(buf):
        offset = 0
        message_size = struct.unpack_from("!i", buf, offset)[0]
        offset+=4
        if message_size != len(buf):
            print(("MessageSize: ", message_size, "; BufferSize: ", len(buf)))
            raise Exception("Could not unpack RobotStateRT packet: length field is incorrect")

        rs = HWASHI ROBOT()
        #time
        rs.time = struct.unpack_from("!d",buf, offset)[0]
        offset+=8
        
        #q_target:
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.q_target = copy.deepcopy(all_values)
        
        #qd_target:
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.qd_target = copy.deepcopy(all_values)
        
        #qdd_target:
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.qdd_target = copy.deepcopy(all_values)
        
        #i_target: 
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.i_target = copy.deepcopy(all_values)
        
        #m_target: 
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.m_target = copy.deepcopy(all_values)
        
        #q_actual: 
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.q_actual = copy.deepcopy(all_values)
        
        #qd_actual:
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.qd_actual = copy.deepcopy(all_values)
        
        #i_actual: 
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.i_actual = copy.deepcopy(all_values)
        
        #tool_acc_values:
        all_values = list(struct.unpack_from("!ddd",buf, offset))
        offset+=3*8
        rs.tool_acc_values = copy.deepcopy(all_values)
        
        #unused: 
        offset+=120
        rs.unused = []
        
        #tcp_force
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.tcp_force = copy.deepcopy(all_values)
        
        #tool_vector
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.tool_vector = copy.deepcopy(all_values)
        
        #tcp_speed
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.tcp_speed = copy.deepcopy(all_values)
        
        #digital_input_bits
        rs.digital_input_bits = struct.unpack_from("!d",buf, offset)[0]
        offset+=8

        #motor_temperatures
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.motor_temperatures = copy.deepcopy(all_values)
        
        #controller_timer
        rs.controller_timer = struct.unpack_from("!d",buf, offset)[0]
        offset+=8
        
        #test_value
        rs.test_value = struct.unpack_from("!d",buf, offset)[0]
        offset+=8
        
        #robot_mode
        rs.robot_mode = struct.unpack_from("!d",buf, offset)[0]
        offset+=8
        
        #joint_mode
        all_values = list(struct.unpack_from("!dddddd",buf, offset))
        offset+=6*8
        rs.joint_modes = copy.deepcopy(all_values)

        return rs

#this parses for versions >=3.0 (i.e. 3.0)
class HWASHI ROBOT (object):
    __slots__ = ['time', 
                 'q_target', 'qd_target', 'qdd_target', 'i_target', 'm_target', 
                 'q_actual', 'qd_actual', 'i_actual', 'i_control', 
                 'tool_vector_actual', 'tcp_speed_actual', 'tcp_force', 
                 'tool_vector_target', 'tcp_speed_target', 
                 'digital_input_bits', 'motor_temperatures', 'controller_timer', 
                 'test_value', 
                 'robot_mode', 'joint_modes', 'safety_mode', 
                 'tool_acc_values', 
                 'speed_scaling', 'linear_momentum_norm', 
                 'v_main', 'v_robot', 'i_robot', 'v_actual']

    @staticmethod
    def unpack(buf):
        offset = 0
        message_size = struct.unpack_from("!i", buf, offset)[0]
        offset+=4
        if message_size != len(buf):
            print(("MessageSize: ", message_size, "; BufferSize: ", len(buf)))
            raise Exception("Could not unpack RobotStateRT packet: length field is incorrect")

        return rs
