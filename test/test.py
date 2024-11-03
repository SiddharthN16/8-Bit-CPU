# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())
    # Reset
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 0
    dut._log.info("Reset")
    await ClockCycles(dut.clk, 1000)
    dut.rst_n.value = 1
    dut._log.info("Test NOP")
    dut.ui_in.value = 1
    await ClockCycles(dut.clk, 1000)
    dut._log.info("Test ADD")
    dut.ui_in.value = 2
    await ClockCycles(dut.clk, 1000)
    dut._log.info("Test SUB")
    dut.ui_in.value = 3
    await ClockCycles(dut.clk, 1000)
    dut._log.info("Test LDA")
    dut.ui_in.value = 4
    await ClockCycles(dut.clk, 1000)
    dut._log.info("Test OUT")
    dut.ui_in.value = 5
    await ClockCycles(dut.clk, 1000)
    dut._log.info("Test STA")
    dut.ui_in.value = 6
    await ClockCycles(dut.clk, 1000)
    dut._log.info("Test JMP")
    dut.ui_in.value = 7
    await ClockCycles(dut.clk, 1000)
    dut._log.info("Test HLT")
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 1000)
