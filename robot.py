# импортируем библиотеки
import abc
import serial
 
#создаём классы

class Robot(abc.ABC):
    @abc.abstractmethod
    def run_command(self, cmd: str, args: tuple): pass

    @abc.abstractmethod
    def _connect(self, host: str, port: int): pass

    @abc.abstractmethod
    def _disconnect(self): pass

    @abc.abstractmethod
    def _send_message(self, message: str): pass

    @abc.abstractmethod
    def _get_message(self, message: str = ''): pass


class RobotSerial(Robot):
    def __init__(self):
        self._serial = None

    @abc.abstractmethod
    def run_command(self, cmd: str, args: tuple):
        """
        Convers RoboDK command to robot command and sends it to robot.
        :param str cmd: Command (Ex: MOVEJ, CONNECT)
        :param tuple args: Command arguments (Ex: Joint angles [0, 0, 0]
        """

        pass

    def _connect(self, port: str, baud_rate: int) -> bool:
        """
        Establishes a serial connection.
        :param str port: USB serial port address
        :param int baud_rate: Baud rate of communication channel
        :return: Whether connection attempt has succeeded
        :rtype: bool
        """

        try:
            self._serial = serial.Serial(port, baudrate=baud_rate, timeout=0.5)
        except serial.serialutil.SerialException:
            return False

        return True

    def _disconnect(self) -> bool:
        """
        Ends serial connection.
        :return: Whether disconnection attempt has succeeded
        :rtype: bool
        """

        if not self._serial:
            return True

        try:
            self._serial.close()
        except serial.serialutil.SerialException:
            return False

        return True

    def _send_message(self, message: str):
        """
        Sends a line 
