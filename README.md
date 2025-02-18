# Cyberdeck

An emulation of the Control Data Cyber 962 series mainframe/supercomputer.

## Central Processor Instructions Implemented

This is the implementation status of the 159 distinct Cyber 180 Central Processor instructions.

| Instruction   | Implemented & Tested  | Notes                     |
| ------------- | --------------------- | ------------------------- |
|   HALT        |                       |                           |
|   SYNC        |                       |                           |
|   EXCHANGE    |                       |                           |
|   INTRUPT     |                       |                           |
|   RETURN      |                       |                           |
|   PURGE       |                       |                           |
|   POP         |                       |                           |
|   PSFSA       |                       |                           |
|   CPYTX       |                       |                           |
|   CPYAA       |                       |                           |
|   CPYXA       |                       |                           |
|   CYPAX       |                       |                           |
|   CPYRR       |                       |                           |
|   CPYXX       |                       |                           |
|   CPYSX       |                       |                           |
|   CPYXS       |                       |                           |
|   INCX        | ✔️                    | To do: Handle overflow    |
|   DECX        | ✔️                    | To do: Handle overflow    |
|   LBSET       |                       |                           |
|   TPAGE       |                       |                           |
|   LPAGE       |                       |                           |
|   IORX        |                       |                           |
|   XORX        |                       |                           |
|   ANDX        |                       |                           |
|   NOTX        |                       |                           |
|   INHX        |                       |                           |
|   MARK        |                       |                           |
|   ENTZOS      |                       |                           |
|   ADDR        | ✔️                    | To do: Handle overflow    |
|   SUBR        | ✔️                    | To do: Handle overflow    |
|   MULR        |                       |                           |
|   DIVR        |                       |                           |
|   ADDX        | ✔️                    | To do: Handle overflow    |
|   SUBX        | ✔️                    | To do: Handle overflow    |
|   MULX        |                       |                           |
|   DIVX        |                       |                           |
|   INCR        | ✔️                    | To do: Handle overflow    |
|   DECR        | ✔️                    | To do: Handle overflow    |
|   ADDAX       |                       |                           |
|   CMPR        |                       |                           |
|   CMPX        |                       |                           |
|   BRREL       |                       |                           |
|   BRDIR       |                       |                           |
|   ADDF        |                       |                           |
|   SUBF        |                       |                           |
|   MULF        |                       |                           |
|   DIVF        |                       |                           |
|   ADDD        |                       |                           |
|   SUBD        |                       |                           |
|   MULD        |                       |                           |
|   DIVD        |                       |                           |
|   ENTX        | ✔️                    |                           |
|   CNIF        |                       |                           |
|   CNFI        |                       |                           |
|   CMPF        |                       |                           |
|   ENTP        | ✔️                    |                           |
|   ENTN        | ✔️                    |                           |
|   ENTL        |                       |                           |
|   ADDFV       |                       |                           |
|   SUBFV       |                       |                           |
|   MULFV       |                       |                           |
|   DIVFV       |                       |                           |
|   ADDXV       |                       |                           |
|   SUBXV       |                       |                           |
|   IORV        |                       |                           |
|   XORV        |                       |                           |
|   ANDV        |                       |                           |
|   CNIFV       |                       |                           |
|   CNFIV       |                       |                           |
|   SHFV        |                       |                           |
|   COMPEQV     |                       |                           |
|   CMPLTV      |                       |                           |
|   CMPGEV      |                       |                           |
|   CMPNEV      |                       |                           |
|   MRGV        |                       |                           |
|   GTHV        |                       |                           |
|   SCTV        |                       |                           |
|   SUMFV       |                       |                           |
|   TPSFV       |                       |                           |
|   TPDFV       |                       |                           |
|   TSPFV       |                       |                           |
|   TDPFV       |                       |                           |
|   SUMPFV      |                       |                           |
|   GTHIV       |                       |                           |
|   SCTIV       |                       |                           |
|   ADDN        |                       |                           |
|   SUBN        |                       |                           |
|   MULN        |                       |                           |
|   DIVN        |                       |                           |
|   CMPN        |                       |                           |
|   MOVN        |                       |                           |
|   MOVB        |                       |                           |
|   CMPB        |                       |                           |
|   LMULT       |                       |                           |
|   SMULT       |                       |                           |
|   LX          | ✔️                    | To do: Handle address specification error |
|   SX          | ✔️                    | To do: Handle address specification error |
|   LA          |                       |                           |
|   SA          |                       |                           |
|   LBYTP       |                       |                           |
|   ENTC        |                       |                           |
|   LBIT        |                       |                           |
|   SBIT        |                       |                           |
|   ADDRQ       |                       |                           |
|   ADDXQ       | ✔️                    | To do: Handle overflow    |
|   MULRQ       |                       |                           |
|   ENTE        | ✔️                    |                           |
|   ADDAQ       |                       |                           |
|   ADDPXQ      |                       |                           |
|   BRREQ       |                       |                           |
|   BRRNE       |                       |                           |
|   BRRGT       |                       |                           |
|   BRRGE       |                       |                           |
|   BRXEQ       |                       |                           |
|   BRXNE       |                       |                           |
|   BRXGT       |                       |                           |
|   BRXGE       |                       |                           |
|   BRFEQ       |                       |                           |
|   BRFNE       |                       |                           |
|   BRFGT       |                       |                           |
|   BRFGE       |                       |                           |
|   BRINC       |                       |                           |
|   BRSEG       |                       |                           |
|   BRxxx       |                       |                           |
|   BRCR        |                       |                           |
|   LAI         |                       |                           |
|   SAI         |                       |                           |
|   LXI         | ✔️                    | To do: Handle address specification error |
|   SXI         | ✔️                    | To do: Handle address specification error |
|   LBYT        | ✔️                    |                           |
|   SBYT        | ✔️                    |                           |
|   ADDAD       |                       |                           |
|   SHFC        |                       |                           |
|   SHFX        |                       |                           |
|   SHFR        |                       |                           |
|   ISOM        |                       |                           |
|   ISOB        |                       |                           |
|   INSB        |                       |                           |
|   CALLREL     |                       |                           |
|   KEYPOINT    |                       |                           |
|   MULXQ       |                       |                           |
|   ENTA        |                       |                           |
|   CMPXA       |                       |                           |
|   CALLSEG     |                       |                           |
|   RESERVEDBD  |                       |                           |
|   RESERVEDBE  |                       |                           |
|   RESERVEDBF  |                       |                           |
|   EXECUTE     |                       |                           |
|   LBYTS       | ✔️                    |                           |
|   SBYTS       | ✔️                    |                           |
|   SCLN        |                       |                           |
|   SCLR        |                       |                           |
|   CMPC        |                       |                           |
|   TRANB       |                       |                           |
|   EDIT        |                       |                           |
|   SCNB        |                       |                           |
|   MOVI        |                       |                           |
|   CMPI        |                       |                           |
|   ADDI        |                       |                           |
