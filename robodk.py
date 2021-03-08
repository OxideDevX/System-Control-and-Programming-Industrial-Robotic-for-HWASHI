import sys 
from robodkdriver.robot import Robot

ROBOTCOM_STATUS = {
    'ready': 'Ready',
    'working': 'Working...',
    'waiting': 'Waiting...',
    'disconnected': 'Disconnected',
    'not_connected': 'Not connected',
    'connection_problems': 'Connection problems',
}


class RoboDK:
    def __init__(self, robot: Robot):
        self._robot = robot

    @classmethod
    def update_status(cls, status: str):
        if status in ROBOTCOM_STATUS:
            status = 'SMS:' + ROBOTCOM_STATUS[status]

        cls._print_message('{status}'.format(status=status))

    def run_driver(self):
        while True:
            # If input is available
            if not sys.stdin.isatty():
                command = sys.stdin.readline()
                command = self._parse_command(command)

                status = self._robot.run_command(**command)
                self.update_status(status)

    @staticmethod
    def _print_message(message):
        print(message)
        sys.stdout.flush()

    @staticmethod
    def _parse_command(command):
        parts = command[0:-1].split(' ')
        parts = list(map(str.strip, parts))

        parts = {
            'cmd': parts[0],
            'args': parts[1:]
        }

        return parts
