from Antmicro.Renode.Peripherals.CPU import RegisterValue
import ctypes
from array import array

# Structure based on: https://chromium.googlesource.com/chromiumos/platform/ec/+/6898a6542ed0238cc182948f56e3811534db1a38/chip/npcx/header.c#43
class FirmwareHeader(ctypes.LittleEndianStructure):
    _pack_ = 1
    _fields_ = [
        ("anchor", ctypes.c_uint32),
        ("ext_anchor", ctypes.c_uint16),
        ("spi_max_freq", ctypes.c_uint8),
        ("spi_read_mode", ctypes.c_uint8),
        ("cfg_err_detect", ctypes.c_uint8),
        ("fw_load_addr", ctypes.c_uint32),
        ("fw_entry", ctypes.c_uint32),
        ("err_detect_start_addr", ctypes.c_uint32),
        ("err_detect_end_addr", ctypes.c_uint32),
        ("fw_length", ctypes.c_uint32),
        ("flash_size", ctypes.c_uint8),
        ("reserved", ctypes.c_uint8 * 26),
        ("sig_header", ctypes.c_uint32),
        ("sig_fw_image", ctypes.c_uint32),
    ]

HEADER_SIZE = ctypes.sizeof(FirmwareHeader)

def bootloader(cpu, addr):
    flash = self.Machine["sysbus.internal_flash"]

    header_data = flash.ReadBytes(0x0, HEADER_SIZE)
    header = FirmwareHeader.from_buffer(array('B', header_data))

    firmware = flash.ReadBytes(HEADER_SIZE, header.fw_length)
    self.Machine.SystemBus.WriteBytes(firmware, header.fw_load_addr)

    cpu.PC = RegisterValue.Create(header.fw_entry, 32)

    self.Machine.InfoLog("Firmware loaded at: 0x{0:X} ({1} bytes). PC = 0x{2:X}", header.fw_load_addr, header.fw_length, header.fw_entry)

def mc_register_bootloader():
    self.Machine["sysbus.cpu"].AddHook(0x0, bootloader)
