#PUT LICENCE HERE!

"""
ft_fifo_tester Driver

"""

import sys
import os
import time
from array import array as Array

sys.path.append(os.path.join(os.path.dirname(__file__),
                             os.pardir))
from nysa.host.driver import driver

#Sub Module ID
#Use 'nysa devices' to get a list of different available devices
DEVICE_TYPE             = "Experiment"
SDB_ABI_VERSION_MINOR   = 0
SDB_VENDOR_ID           = 0

try:
    SDB_ABI_VERSION_MINOR   = 0
    SDB_VENDOR_ID           = 0x800000000000C594
except SyntaxError:
    pass

#Register Constants
CONTROL_ADDR            = 0x00000000
ZERO_BIT                = 0

class ft_fifo_testerDriver(driver.Driver):

    """ ft_fifo_tester

        Communication with a DutDriver ft_fifo_tester Core
    """
    @staticmethod
    def get_abi_class():
        return 0

    @staticmethod
    def get_abi_major():
        return driver.get_device_id_from_name(DEVICE_TYPE)

    @staticmethod
    def get_abi_minor():
        return SDB_ABI_VERSION_MINOR

    @staticmethod
    def get_vendor_id():
        return SDB_VENDOR_ID

    def __init__(self, nysa, urn, debug = False):
        super(ft_fifo_testerDriver, self).__init__(nysa, urn, debug)

    def set_control(self, control):
        self.write_register(CONTROL_ADDR, control)

    def get_control(self):
        return self.read_register(CONTROL_ADDR)

    def enable_control_0_bit(self, enable):
        self.enable_register_bit(CONTROL_ADDR, ZERO_BIT, enable)

    def is_control_0_bit_set(self):
        return self.is_register_bit_set(CONTROL_ADDR, ZERO_BIT)
