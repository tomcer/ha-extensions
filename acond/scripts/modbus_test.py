#!/usr/bin/env python3
"""
Acond TČ - Modbus TCP test skript
Testuje čtení i zápis na všechny registry z PDF v2.34.
Spouštěj z venv: /tmp/modbus_test/bin/python3 modbus_test.py
"""

import sys
import time
from pymodbus.client import ModbusTcpClient
from pymodbus.exceptions import ModbusException

HOST = "192.168.5.30"
PORT = 502
SLAVE_IDS = [0, 1]  # Test both

# Input registers (FC4) - read only
INPUT_REGS = [
    (0,  "T_set_indoor1",    0.1, "°C"),
    (1,  "T_act_indoor1",    0.1, "°C"),
    (2,  "T_set_indoor2",    0.1, "°C"),
    (3,  "T_act_indoor2",    0.1, "°C"),
    (4,  "T_set_TUV",        0.1, "°C"),
    (5,  "T_act_TUV",        0.1, "°C"),
    (6,  "TC_status",        1,   "word"),
    (7,  "T_set_water_back", 0.1, "°C"),
    (8,  "T_act_water_back", 0.1, "°C"),
    (9,  "T_act_air",        0.1, "°C"),
    (10, "T_act_solar",      0.1, "°C"),
    (11, "T_act_pool",       0.1, "°C"),
    (12, "T_set_pool",       0.1, "°C"),
    (13, "rezim_pan",        1,   "enum"),
    (14, "typ_reg_pan",      1,   "enum"),
    (15, "T_solanka",        0.1, "°C"),
    (16, "HeartBeat",        1,   ""),
    (17, "T_act_water_outlet", 0.1, "°C"),
    (18, "T_set_water_outlet", 0.1, "°C"),
    (19, "Comp_rpm_max",     1,   "rpm"),
    (20, "err_number",       1,   ""),
    (21, "err_number_SECMono", 1, ""),
    (22, "err_number_driver", 1,  ""),
    (23, "comp_rpm_actual",  1,   "rpm"),
]

# Holding registers (FC3 read, FC6/16 write)
HOLDING_REGS = [
    (0,  "T_set_indoor1",    0.1, "°C"),
    (1,  "T_act_indoor1",    0.1, "°C"),
    (2,  "T_set_indoor2",    0.1, "°C"),
    (3,  "T_act_indoor2",    0.1, "°C"),
    (4,  "T_set_TUV",        0.1, "°C"),
    (5,  "TC_set",           1,   "word"),
    (6,  "TC_set_reg",       1,   "enum"),
    (7,  "T_set_water_back", 0.1, "°C"),
    (8,  "T_air",            0.1, "°C"),
    (9,  "T_act_solar",      0.1, "°C"),
    (10, "T_act_pool",       0.1, "°C"),
    (11, "T_set_pool",       0.1, "°C"),
    (12, "T_set_water_cool", 0.1, "°C"),
    (13, "Comp_rpm_max",     1,   "rpm"),
]


def test_read(client, slave_id):
    """Test all input and holding register reads."""
    print(f"\n{'='*60}")
    print(f"SLAVE ID: {slave_id}")
    print(f"{'='*60}")

    # --- Input registers (FC4) ---
    print(f"\n--- Input Registers (FC4) - slave {slave_id} ---")
    for addr, name, scale, unit in INPUT_REGS:
        time.sleep(0.3)
        try:
            result = client.read_input_registers(addr, 1, device_id=slave_id)
            if result.isError():
                print(f"  [{addr:2d}] {name:25s} ERROR: {result}")
            else:
                raw = result.registers[0]
                # Handle signed int16
                if raw > 32767:
                    raw = raw - 65536
                val = raw * scale
                print(f"  [{addr:2d}] {name:25s} = {val:8.1f} {unit:5s}  (raw: {result.registers[0]})")
        except Exception as e:
            print(f"  [{addr:2d}] {name:25s} EXCEPTION: {e}")

    # --- Holding registers (FC3) ---
    print(f"\n--- Holding Registers (FC3) - slave {slave_id} ---")
    for addr, name, scale, unit in HOLDING_REGS:
        time.sleep(0.3)
        try:
            result = client.read_holding_registers(addr, 1, device_id=slave_id)
            if result.isError():
                print(f"  [{addr:2d}] {name:25s} ERROR: {result}")
            else:
                raw = result.registers[0]
                if raw > 32767:
                    raw = raw - 65536
                val = raw * scale
                print(f"  [{addr:2d}] {name:25s} = {val:8.1f} {unit:5s}  (raw: {result.registers[0]})")
        except Exception as e:
            print(f"  [{addr:2d}] {name:25s} EXCEPTION: {e}")


def test_write(client, slave_id, addr, value, name):
    """Test writing a single holding register."""
    print(f"\n  WRITE [{addr}] {name} = {value} (slave {slave_id})")
    time.sleep(0.3)
    try:
        # FC6 - write single register
        result = client.write_register(addr, value, device_id=slave_id)
        if result.isError():
            print(f"    FC6 ERROR: {result}")
        else:
            print(f"    FC6 OK: {result}")
    except Exception as e:
        print(f"    FC6 EXCEPTION: {e}")

    time.sleep(0.3)
    try:
        # FC16 - write multiple registers
        result = client.write_registers(addr, [value], device_id=slave_id)
        if result.isError():
            print(f"    FC16 ERROR: {result}")
        else:
            print(f"    FC16 OK: {result}")
    except Exception as e:
        print(f"    FC16 EXCEPTION: {e}")


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "read"

    client = ModbusTcpClient(HOST, port=PORT, timeout=5)
    if not client.connect():
        print(f"ERROR: Cannot connect to {HOST}:{PORT}")
        sys.exit(1)
    print(f"Connected to {HOST}:{PORT}")

    if mode == "read":
        for slave_id in SLAVE_IDS:
            test_read(client, slave_id)

    elif mode == "write":
        # Test write to various holding registers
        slave_id = int(sys.argv[2]) if len(sys.argv) > 2 else 0
        print(f"\n--- Write Tests - slave {slave_id} ---")

        # Read current values first
        print("\nCurrent input register values:")
        for addr in [0, 1, 2, 3, 4]:
            time.sleep(0.3)
            r = client.read_input_registers(addr, 1, device_id=slave_id)
            if not r.isError():
                raw = r.registers[0]
                if raw > 32767:
                    raw = raw - 65536
                print(f"  Input [{addr}] = {raw * 0.1:.1f}°C (raw: {r.registers[0]})")

        # Test writes
        print("\nWriting T_set_indoor1 (addr 0) = 220 (22.0°C):")
        test_write(client, slave_id, 0, 220, "T_set_indoor1")

        print("\nWriting T_act_indoor2 (addr 3) = 201 (20.1°C):")
        test_write(client, slave_id, 3, 201, "T_act_indoor2")

        # Wait and re-read
        print("\nWaiting 5s and re-reading...")
        time.sleep(5)
        for addr in [0, 1, 2, 3, 4]:
            time.sleep(0.3)
            r = client.read_input_registers(addr, 1, device_id=slave_id)
            if not r.isError():
                raw = r.registers[0]
                if raw > 32767:
                    raw = raw - 65536
                print(f"  Input [{addr}] = {raw * 0.1:.1f}°C (raw: {r.registers[0]})")

        # Revert setpoint
        print("\nReverting T_set_indoor1 to 215 (21.5°C):")
        test_write(client, slave_id, 0, 215, "T_set_indoor1")

    elif mode == "scan-write":
        # Try writing to all holding register addresses with both slave IDs
        slave_id = int(sys.argv[2]) if len(sys.argv) > 2 else 0
        print(f"\n--- Scan Write Test - slave {slave_id} ---")
        for addr, name, scale, unit in HOLDING_REGS:
            time.sleep(0.5)
            # Read current value first
            r = client.read_input_registers(addr if addr <= 17 else 0, 1, device_id=slave_id)
            try:
                result = client.write_register(addr, 0, device_id=slave_id)
                if result.isError():
                    print(f"  [{addr:2d}] {name:25s} FC6 write 0: ERROR {result}")
                else:
                    print(f"  [{addr:2d}] {name:25s} FC6 write 0: OK")
            except Exception as e:
                print(f"  [{addr:2d}] {name:25s} FC6 write 0: EXCEPTION {e}")

    client.close()
    print("\nDone.")


if __name__ == "__main__":
    main()
