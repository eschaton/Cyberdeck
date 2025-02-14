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
|   INCX        | ✔️                    | To do: Detect overflow    |
|   DECX        | ✔️                    | To do: Detect overflow    |
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
|   ADDR        |                       |                           |
|   SUBR        |                       |                           |
|   MULR        |                       |                           |
|   DIVR        |                       |                           |
|   ADDX        | ✔️                    | To do: Detect overflow    |
|   SUBX        | ✔️                    | To do: Detect overflow    |
|   MULX        |                       |                           |
|   DIVX        |                       |                           |
|   INCR        |                       |                           |
|   DECR        |                       |                           |
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
|   ADDXQ       | ✔️                    | To do: Detect overflow    |
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
