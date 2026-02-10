import hmac
import hashlib

def hook__hmac_SHA256_step(cpu, _):
    bus = cpu.Bus

    input_len = cpu.GetRegister(15).RawValue
    input = cpu.GetRegister(14).RawValue
    key_len = cpu.GetRegister(13).RawValue
    key = cpu.GetRegister(12).RawValue
    mask = cpu.GetRegister(11).RawValue
    output = cpu.GetRegister(10).RawValue
    
    if mask == 0x5c:
        cpu.PC = cpu.RA
        return

    _list = []
    for i in range(key_len):
        _list.append(bus.ReadByte(key))
        key += 1
    _key = bytes(_list)

    _list = []
    for i in range(input_len):
        _list.append(bus.ReadByte(input))
        input += 1
    _input = bytes(_list)

    signature = hmac.new(_key, _input, hashlib.sha256).digest()
    _bytes = [b for b in bytearray(signature)]

    for b in _bytes:
        bus.WriteByte(output, b)
        output += 1
    cpu.PC = cpu.RA

def hook__test_sha256(cpu, _):
    bus = cpu.Bus

    output = cpu.GetRegister(12).RawValue
    input_len = cpu.GetRegister(11).RawValue
    input = cpu.GetRegister(10).RawValue

    _list = []
    for i in range(input_len):
        _list.append(bus.ReadByte(input))
        input += 1

    data = bytes(_list)
    digest = hashlib.sha256(data).digest()
    _bytes = [b for b in bytearray(digest)]

    for b in _bytes:
        bus.WriteByte(output, b)
        output += 1
    cpu.PC = cpu.RA

def hook__sx_hash_feed_rw(cpu, _):
    global digest
    global _bytes
    bus = cpu.Bus

    cnt = cpu.GetRegister(12).RawValue
    addr = cpu.GetRegister(11).RawValue
    _list = []
    for i in range(cnt):
        _list.append(bus.ReadByte(addr))
        addr += 1

    data = bytes(_list)
    digest = hashlib.sha256(data).digest()

    _bytes = [b for b in bytearray(digest)]
    cpu.PC = cpu.RA

def hook__sx_hash_digest_rw(cpu, _):
    bus = cpu.Bus

    addr = cpu.GetRegister(11).RawValue
    for b in _bytes:
        bus.WriteByte(addr, b)
        addr += 1
    cpu.PC = cpu.RA

def mc_AddCustomPythonHooks(cpu):
    try:
        results = cpu.Bus.GetAllSymbolAddresses("sx_hash_feed")
        for addr in results:
            cpu.AddHook(addr, hook__sx_hash_feed_rw)
    except:
        pass

    try:
        results = cpu.Bus.GetAllSymbolAddresses("sx_hash_digest")
        for addr in results:
            cpu.AddHook(addr, hook__sx_hash_digest_rw)
    except:
        pass

    try:
        results = cpu.Bus.GetAllSymbolAddresses("hmac_SHA256_step")
        for addr in results:
            cpu.AddHook(addr, hook__hmac_SHA256_step)
    except:
        pass

    try:
        results = cpu.Bus.GetAllSymbolAddresses("test_sha256")
        for addr in results:
            cpu.AddHook(addr, hook__test_sha256)
    except:
        pass