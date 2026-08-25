.. introduction.rst

    Copyright The GRISC Contributors.

    GRISC Documentation

    This work is licensed under the Creative Commons Attribution-ShareAlike 4.0
    International License. To view a copy of this license,
    visit http://creativecommons.org/licenses/by-sa/4.0/.

************
Introduction
************

GRISC is a reduced RISC-V processor implementation written in synthesizable VHDL. The design follows a five-stage pipeline—instruction fetch (IF), instruction decode (ID), execute (EX), memory access (MEM), and write-back (WB)—and handles both data and control hazards. Its datapath is based on the five-stage implementation provided by the Ripes simulator :cite:p:`ripes` and on the reference pipeline described by Patterson and Hennessy :cite:p:`patterson2017`.

The project was developed with three goals: implement the processor hardware, validate individual blocks and the complete datapath with testbenches, and run Assembly programs that exercise the ISA and pipeline-hazard behavior. The complete original assignment specification is available online :cite:p:`specs`.

Supported ISA
*************

GRISC implements RV32I plus the RISC-V ``M`` extension (RV32IM). The minimum instruction set is grouped below by instruction class.

Load upper immediate and jumps
==============================

* ``lui rd, imm``
* ``jal rd, offset``
* ``jalr rd, rs1, offset``

Branches
========

* ``beq rs1, rs2, offset``
* ``bne rs1, rs2, offset``
* ``blt rs1, rs2, offset``
* ``bge rs1, rs2, offset``

Loads and stores
================

* ``lb rd, offset(rs1)`` and ``lw rd, offset(rs1)``
* ``sb rs2, offset(rs1)`` and ``sw rs2, offset(rs1)``

Register-immediate operations
=============================

* ``addi rd, rs1, imm``
* ``andi rd, rs1, imm``
* ``xori rd, rs1, imm``
* ``ori rd, rs1, imm``

Register-register operations
============================

* ``add``, ``sub``, ``and``, ``xor``, and ``or``
* ``sll``, ``srl``, and ``slt``

Multiplication and division extension
=====================================

The additional ``M`` extension instructions are ``mul``, ``mulh``, ``mulhu``, ``mulhsu``, ``div``, ``divu``, ``rem``, and ``remu``.
