//
//  Cyber170CP+Instructions.swift
//  Cyber
//
//  Copyright © 2024-2025 Christopher M. Hanson
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


extension Cyber170CP {

    /// Protocol to which all instructions conform.
    protocol Instruction {

        /// The parcel that produced this instruction.
        var parcel: any Parcel { get }

        /// The instruction's opcode.
        var opcode: Word6 { get }

        /// Primary initializer.
        init?(from parcel: any Parcel)

        /// Perform the operation specified by the instruction.
        func execute(on processor: Cyber170CP)

        /// Disassemble the instruction.
        func disassemble() -> String
    }

    /// Integer Arithmetic Instructions (15-bit)
    enum IntegerArithmeticInstruction: Instruction {
        case P(i: Word3, j: Word3, k: Word3)
        case U(i: Word3, j: Word3, k: Word3)
        case ISum(i: Word3, j: Word3, k: Word3)
        case IDiff(i: Word3, j: Word3, k: Word3)

        var parcel: any Parcel {
            Parcel15(opcode: self.opcode, i: self.i, j: self.j, k: self.k)
        }

        var opcode: Word6 {
            switch self {
            case .P(i: _, j: _, k: _): return 0o27
            case .U(i: _, j: _, k: _): return 0o26
            case .ISum(i: _, j: _, k: _): return 0o36
            case .IDiff(i: _, j: _, k: _): return 0o37
            }
        }

        var i: Word3 {
            switch self {
            case .P(i: let i, j: _, k: _): return i
            case .U(i: let i, j: _, k: _): return i
            case .ISum(i: let i, j: _, k: _): return i
            case .IDiff(i: let i, j: _, k: _): return i
            }
        }

        var j: Word3 {
            switch self {
            case .P(i: _, j: let j, k: _): return j
            case .U(i: _, j: let j, k: _): return j
            case .ISum(i: _, j: let j, k: _): return j
            case .IDiff(i: _, j: let j, k: _): return j
            }
        }

        var k: Word3 {
            switch self {
            case .P(i: _, j: _, k: let k): return k
            case .U(i: _, j: _, k: let k): return k
            case .ISum(i: _, j: _, k: let k): return k
            case .IDiff(i: _, j: _, k: let k): return k
            }
        }

        init?(from parcel: any Parcel) {
            guard let realParcel = parcel as? Parcel15 else {
                return nil
            }

            switch realParcel.opcode {
            case 0o27: self = .P(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o26: self = .U(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o36: self = .ISum(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o37: self = .IDiff(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            default: return nil
            }
        }

        func execute(on processor: Cyber170CP) {
            switch self {
            case .P(i: let i, j: let j, k: let k): P(on: processor, i: i, j: j, k: k)
            case .U(i: let i, j: let j, k: let k): U(on: processor, i: i, j: j, k: k)
            case .ISum(i: let i, j: let j, k: let k): ISum(on: processor, i: i, j: j, k: k)
            case .IDiff(i: let i, j: let j, k: let k): IDifference(on: processor, i: i, j: j, k: k)
            }
        }

        func disassemble() -> String {
            switch self {
            case .P(i: let i, j: let j, k: let k): return "PX\(i) B\(j), X\(k)"
            case .U(i: let i, j: let j, k: let k): return "UX\(i) B\(j), X\(k)"
            case .ISum(i: let i, j: let j, k: let k): return "IX\(i) X\(j) + X\(k)"
            case .IDiff(i: let i, j: let j, k: let k): return "IX\(i) X\(j) - X\(k)"
            }
        }

        func P(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement P
        }

        func U(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement U
        }

        func ISum(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement ISum
        }

        func IDifference(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement IDifference
        }
    }

    /// Branch Instructions (30-bit)
    enum BranchInstruction: Instruction {
        case ZR(j: Word3, K: Word18)
        case NZ(j: Word3, K: Word18)
        case PL(j: Word3, K: Word18)
        case NG(j: Word3, K: Word18)
        case IR(j: Word3, K: Word18)
        case OR(j: Word3, K: Word18)
        case DF(j: Word3, K: Word18)
        case ID(j: Word3, K: Word18)
        case EQ(i: Word3, j: Word3, K: Word18)
        case NE(i: Word3, j: Word3, K: Word18)
        case GE(i: Word3, j: Word3, K: Word18)
        case LT(i: Word3, j: Word3, K: Word18)

        var parcel: any Parcel {
            Parcel30(opcode: self.opcode, i: self.i, j: self.j, K: self.K)
        }

        var opcode: Word6 {
            switch self {
            case .ZR(j: _, K: _): return 0o03
            case .NZ(j: _, K: _): return 0o03
            case .PL(j: _, K: _): return 0o03
            case .NG(j: _, K: _): return 0o03
            case .IR(j: _, K: _): return 0o03
            case .OR(j: _, K: _): return 0o03
            case .DF(j: _, K: _): return 0o03
            case .ID(j: _, K: _): return 0o03
            case .EQ(i: _, j: _, K: _): return 0o04
            case .NE(i: _, j: _, K: _): return 0o05
            case .GE(i: _, j: _, K: _): return 0o06
            case .LT(i: _, j: _, K: _): return 0o07
            }
        }

        var i: Word3 {
            switch self {
            case .ZR(j: _, K: _): return 0o00
            case .NZ(j: _, K: _): return 0o01
            case .PL(j: _, K: _): return 0o02
            case .NG(j: _, K: _): return 0o03
            case .IR(j: _, K: _): return 0o04
            case .OR(j: _, K: _): return 0o05
            case .DF(j: _, K: _): return 0o06
            case .ID(j: _, K: _): return 0o07
            case .EQ(i: let i, j: _, K: _): return i
            case .NE(i: let i, j: _, K: _): return i
            case .GE(i: let i, j: _, K: _): return i
            case .LT(i: let i, j: _, K: _): return i
            }
        }

        var j: Word3 {
            switch self {
            case .ZR(j: let j, K: _): return j
            case .NZ(j: let j, K: _): return j
            case .PL(j: let j, K: _): return j
            case .NG(j: let j, K: _): return j
            case .IR(j: let j, K: _): return j
            case .OR(j: let j, K: _): return j
            case .DF(j: let j, K: _): return j
            case .ID(j: let j, K: _): return j
            case .EQ(i: _, j: let j, K: _): return j
            case .NE(i: _, j: let j, K: _): return j
            case .GE(i: _, j: let j, K: _): return j
            case .LT(i: _, j: let j, K: _): return j
            }
        }

        var K: Word18 {
            switch self {
            case .ZR(j: _, K: let K): return K
            case .NZ(j: _, K: let K): return K
            case .PL(j: _, K: let K): return K
            case .NG(j: _, K: let K): return K
            case .IR(j: _, K: let K): return K
            case .OR(j: _, K: let K): return K
            case .DF(j: _, K: let K): return K
            case .ID(j: _, K: let K): return K
            case .EQ(i: _, j: _, K: let K): return K
            case .NE(i: _, j: _, K: let K): return K
            case .GE(i: _, j: _, K: let K): return K
            case .LT(i: _, j: _, K: let K): return K
            }
        }

        init?(from parcel: any Parcel) {
            guard let realParcel = parcel as? Parcel30 else {
                return nil
            }

            switch realParcel.opcode {
            case 0o03:
                switch realParcel.i {
                case 0o0: self = .ZR(j: realParcel.j, K: realParcel.K)
                case 0o1: self = .NZ(j: realParcel.j, K: realParcel.K)
                case 0o2: self = .PL(j: realParcel.j, K: realParcel.K)
                case 0o3: self = .NG(j: realParcel.j, K: realParcel.K)
                case 0o4: self = .IR(j: realParcel.j, K: realParcel.K)
                case 0o5: self = .OR(j: realParcel.j, K: realParcel.K)
                case 0o6: self = .DF(j: realParcel.j, K: realParcel.K)
                case 0o7: self = .ID(j: realParcel.j, K: realParcel.K)
                default: fatalError("Should be impossible to reach.")
                }

            case 0o04: self = .EQ(i: realParcel.i, j: realParcel.j, K: realParcel.K)
            case 0o05: self = .NE(i: realParcel.i, j: realParcel.j, K: realParcel.K)
            case 0o06: self = .GE(i: realParcel.i, j: realParcel.j, K: realParcel.K)
            case 0o07: self = .LT(i: realParcel.i, j: realParcel.j, K: realParcel.K)
            default: return nil
            }
        }
        
        func execute(on processor: Cyber170CP) {
            switch self {
            case .ZR(j: let j, K: let K): ZR(on: processor, j: j, K: K)
            case .NZ(j: let j, K: let K): NZ(on: processor, j: j, K: K)
            case .PL(j: let j, K: let K): PL(on: processor, j: j, K: K)
            case .NG(j: let j, K: let K): NG(on: processor, j: j, K: K)
            case .IR(j: let j, K: let K): IR(on: processor, j: j, K: K)
            case .OR(j: let j, K: let K): OR(on: processor, j: j, K: K)
            case .DF(j: let j, K: let K): DF(on: processor, j: j, K: K)
            case .ID(j: let j, K: let K): ID(on: processor, j: j, K: K)
            case .EQ(i: let i, j: let j, K: let K): EQ(on: processor, i: i, j: j, K: K)
            case .NE(i: let i, j: let j, K: let K): NE(on: processor, i: i, j: j, K: K)
            case .GE(i: let i, j: let j, K: let K): GE(on: processor, i: i, j: j, K: K)
            case .LT(i: let i, j: let j, K: let K): LT(on: processor, i: i, j: j, K: K)
            }
        }
        
        func disassemble() -> String {
            switch self {
            case .ZR(j: let j, K: let K): "ZR X\(j), \(K)"
            case .NZ(j: let j, K: let K): "NZ X\(j), \(K)"
            case .PL(j: let j, K: let K): "PL X\(j), \(K)"
            case .NG(j: let j, K: let K): "NG X\(j), \(K)"
            case .IR(j: let j, K: let K): "IR X\(j), \(K)"
            case .OR(j: let j, K: let K): "OR X\(j), \(K)"
            case .DF(j: let j, K: let K): "DF X\(j), \(K)"
            case .ID(j: let j, K: let K): "ID X\(j), \(K)"
            case .EQ(i: let i, j: let j, K: let K): "EQ B\(i), B\(j), \(K)"
            case .NE(i: let i, j: let j, K: let K): "NE B\(i), B\(j), \(K)"
            case .GE(i: let i, j: let j, K: let K): "GE B\(i), B\(j), \(K)"
            case .LT(i: let i, j: let j, K: let K): "LT B\(i), B\(j), \(K)"
            }
        }

        func ZR(on processor: Cyber170CP, j: Word3, K: Word18) {
            // TODO: Implement ZR
        }

        func NZ(on processor: Cyber170CP, j: Word3, K: Word18) {
            // TODO: Implement NZ
        }

        func PL(on processor: Cyber170CP, j: Word3, K: Word18) {
            // TODO: Implement PL
        }

        func NG(on processor: Cyber170CP, j: Word3, K: Word18) {
            // TODO: Implement NG
        }

        func IR(on processor: Cyber170CP, j: Word3, K: Word18) {
            // TODO: Implement IR
        }

        func OR(on processor: Cyber170CP, j: Word3, K: Word18) {
            // TODO: Implement OR
        }

        func DF(on processor: Cyber170CP, j: Word3, K: Word18) {
            // TODO: Implement DF
        }

        func ID(on processor: Cyber170CP, j: Word3, K: Word18) {
            // TODO: Implement ID
        }

        func EQ(on processor: Cyber170CP, i: Word3, j: Word3, K: Word18) {
            // TODO: Implement EQ
        }

        func NE(on processor: Cyber170CP, i: Word3, j: Word3, K: Word18) {
            // TODO: Implement NE
        }

        func GE(on processor: Cyber170CP, i: Word3, j: Word3, K: Word18) {
            // TODO: Implement GE
        }

        func LT(on processor: Cyber170CP, i: Word3, j: Word3, K: Word18) {
            // TODO: Implement LT
        }
    }

    /// Block Copy Instructions (30-bit)
    enum BlockCopyInstruction: Instruction {
        /// Block copy Bj + K words from UEM to CM
        case RE(j: Word3, K: Word18)

        /// Block copy Bj + K words from CM to UEM
        case WE(j: Word3, K: Word18)

        var parcel: any Parcel {
            return Parcel30(opcode: self.opcode, i: self.i, j: self.j, K: self.K)
        }

        var opcode: Word6 {
            return 0o01
        }

        var i: Word3 {
            switch self {
            case .RE(j: _, K: _): return 0o1
            case .WE(j: _, K: _): return 0o2
            }
        }

        var j: Word3 {
            switch self {
            case .RE(j: let j, K: _): return j
            case .WE(j: let j, K: _): return j
            }
        }

        var K: Word18 {
            switch self {
            case .RE(j: _, K: let K): return K
            case .WE(j: _, K: let K): return K
            }
        }

        init?(from parcel: any Parcel) {
            guard let realParcel = parcel as? Parcel30 else {
                return nil
            }

            switch realParcel.opcode {
            case 0o01:
                switch realParcel.i {
                case 0o1: self = .RE(j: realParcel.j, K: realParcel.K)
                case 0o2: self = .WE(j: realParcel.j, K: realParcel.K)
                default: return nil
                }
            default: return nil
            }
        }
        
        func execute(on processor: Cyber170CP) {
            switch self {
            case .RE(j: let j, K: let K): RE(on: processor, j: j, K: K)
            case .WE(j: let j, K: let K): WE(on: processor, j: j, K: K)
            }
        }
        
        func disassemble() -> String {
            switch self {
            case .RE(j: let j, K: let K): return "RE B\(j) + \(K)"
            case .WE(j: let j, K: let K): return "WE B\(j) + \(K)"
            }
        }

        func RE(on processor: Cyber170CP, j: Word3, K: Word18) {
            // TODO: Implement RE
        }

        func WE(on processor: Cyber170CP, j: Word3, K: Word18) {
            // TODO: Implement WE
        }
    }

    /// Shift Instructions (15-bit)
    enum ShiftInstruction: Instruction {
        case L(i: Word3, j: Word3, k: Word3)
        case LN(i: Word3, j: Word3, k: Word3)
        case A(i: Word3, j: Word3, k: Word3)
        case AN(i: Word3, j: Word3, k: Word3)

        var parcel: any Parcel {
            return Parcel15(opcode: self.opcode, i: self.i, j: self.j, k: self.k)
        }

        var opcode: Word6 {
            switch self {
            case .L(i: _, j: _, k: _): return 0o20
            case .LN(i: _, j: _, k: _): return 0o22
            case .A(i: _, j: _, k: _): return 0o21
            case .AN(i: _, j: _, k: _): return 0o23
            }
        }

        var i: Word3 {
            switch self {
            case .L(i: let i, j: _, k: _): return i
            case .LN(i: let i, j: _, k: _): return i
            case .A(i: let i, j: _, k: _): return i
            case .AN(i: let i, j: _, k: _): return i
            }
        }

        var j: Word3 {
            switch self {
            case .L(i: _, j: let j, k: _): return j
            case .LN(i: _, j: let j, k: _): return j
            case .A(i: _, j: let j, k: _): return j
            case .AN(i: _, j: let j, k: _): return j
            }
        }

        var k: Word3 {
            switch self {
            case .L(i: _, j: _, k: let k): return k
            case .LN(i: _, j: _, k: let k): return k
            case .A(i: _, j: _, k: let k): return k
            case .AN(i: _, j: _, k: let k): return k
            }
        }

        init?(from parcel: any Parcel) {
            guard let realParcel = parcel as? Parcel15 else {
                return nil
            }

            switch realParcel.opcode {
            case 0o20: self = .L(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o22: self = .LN(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o21: self = .A(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o23: self = .AN(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            default: return nil
            }
        }
        
        func execute(on processor: Cyber170CP) {
            switch self {
            case let .L(i: i, j: j, k: k): L(i: i, j: j, k: k)
            case let .LN(i: i, j: j, k: k): LN(i: i, j: j, k: k)
            case let .A(i: i, j: j, k: k): A(i: i, j: j, k: k)
            case let .AN(i: i, j: j, k: k): AN(i: i, j: j, k: k)
            }
        }
        
        func disassemble() -> String {
            switch self {
            case .L(i: let i, j: let j, k: let k): return "LX\(i) \(j)\(k)"
            case .LN(i: let i, j: let j, k: let k): return "LX\(i) B\(j) X\(k)"
            case .A(i: let i, j: let j, k: let k): return "AX\(i) \(j)\(k)"
            case .AN(i: let i, j: let j, k: let k): return "AX\(i) B\(j) X\(k)"
            }
        }

        func L(i: Word3, j: Word3, k: Word3) {
            // TODO: Implement L
        }

        func LN(i: Word3, j: Word3, k: Word3) {
            // TODO: Implement LN
        }

        func A(i: Word3, j: Word3, k: Word3) {
            // TODO: Implement A
        }

        func AN(i: Word3, j: Word3, k: Word3) {
            // TODO: Implement AN
        }
    }

    /// Logical Instructions (15-bit)
    enum LogicalInstruction: Instruction {
        case LSum(i: Word3, j: Word3, k: Word3)
        case LSumC(i: Word3, j: Word3, k: Word3)
        case LDifference(i: Word3, j: Word3, k: Word3)
        case LDifferenceC(i: Word3, j: Word3, k: Word3)
        case LProduct(i: Word3, j: Word3, k: Word3)
        case LProductC(i: Word3, j: Word3, k: Word3)

        var parcel: any Parcel {
            return Parcel15(opcode: self.opcode, i: self.i, j: self.j, k: self.k)
        }

        var opcode: Word6 {
            switch self {
            case .LSum(i: _, j: _, k: _): return 0o12
            case .LSumC(i: _, j: _, k: _): return 0o16
            case .LDifference(i: _, j: _, k: _): return 0o13
            case .LDifferenceC(i: _, j: _, k: _): return 0o17
            case .LProduct(i: _, j: _, k: _): return 0o11
            case .LProductC(i: _, j: _, k: _): return 0o15
            }
        }

        var i: Word3 {
            switch self {
            case let .LSum(i: i, j: _, k: _): return i
            case let .LSumC(i: i, j: _, k: _): return i
            case let .LDifference(i: i, j: _, k: _): return i
            case let .LDifferenceC(i: i, j: _, k: _): return i
            case let .LProduct(i: i, j: _, k: _): return i
            case let .LProductC(i: i, j: _, k: _): return i
            }
        }

        var j: Word3 {
            switch self {
            case let .LSum(i: _, j: j, k: _): return j
            case let .LSumC(i: _, j: j, k: _): return j
            case let .LDifference(i: _, j: j, k: _): return j
            case let .LDifferenceC(i: _, j: j, k: _): return j
            case let .LProduct(i: _, j: j, k: _): return j
            case let .LProductC(i: _, j: j, k: _): return j
            }
        }

        var k: Word3 {
            switch self {
            case let .LSum(i: _, j: _, k: k): return k
            case let .LSumC(i: _, j: _, k: k): return k
            case let .LDifference(i: _, j: _, k: k): return k
            case let .LDifferenceC(i: _, j: _, k: k): return k
            case let .LProduct(i: _, j: _, k: k): return k
            case let .LProductC(i: _, j: _, k: k): return k
            }
        }

        init?(from parcel: any Parcel) {
            guard let realParcel = parcel as? Parcel15 else {
                return nil
            }

            switch realParcel.opcode {
            case 0o12: self = .LSum(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o16: self = .LSumC(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o13: self = .LDifference(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o17: self = .LDifferenceC(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o11: self = .LProduct(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o15: self = .LProductC(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            default: return nil
            }
        }
        
        func execute(on processor: Cyber170CP) {
            switch self {
            case let .LSum(i: i, j: j, k: k): LSum(on: processor, i: i, j: j, k: k)
            case let .LSumC(i: i, j: j, k: k): LSumC(on: processor, i: i, j: j, k: k)
            case let .LDifference(i: i, j: j, k: k): LDifference(on: processor, i: i, j: j, k: k)
            case let .LDifferenceC(i: i, j: j, k: k): LDifferenceC(on: processor, i: i, j: j, k: k)
            case let .LProduct(i: i, j: j, k: k): LProduct(on: processor, i: i, j: j, k: k)
            case let .LProductC(i: i, j: j, k: k): LProductC(on: processor, i: i, j: j, k: k)
            }
        }
        
        func disassemble() -> String {
            switch self {
            case let .LSum(i: i, j: j, k: k): "BX\(i) X\(j) + X\(k)"
            case let .LSumC(i: i, j: j, k: k): "BX\(i) -X\(k) + X\(j)"
            case let .LDifference(i: i, j: j, k: k): "BX\(i) X\(j) - X\(k)"
            case let .LDifferenceC(i: i, j: j, k: k): "BX\(i) -X\(k) - X\(j)"
            case let .LProduct(i: i, j: j, k: k): "BX\(i) X\(j) * X\(k)"
            case let .LProductC(i: i, j: j, k: k): "BX\(i) -X\(k) * X\(j)"
            }
        }

        func LSum(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement LSum
        }

        func LSumC(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement LSumC
        }

        func LDifference(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement LDifference
        }

        func LDifferenceC(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement LDifferenceC
        }

        func LProduct(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement LProduct
        }

        func LProductC(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement LProductC
        }
    }

    /// FP Arithmetic Instructions (15-bit)
    enum FPArithmeticInstruction: Instruction {
        case FSum(i: Word3, j: Word3, k: Word3)
        case DSum(i: Word3, j: Word3, k: Word3)
        case RSum(i: Word3, j: Word3, k: Word3)
        case FDifference(i: Word3, j: Word3, k: Word3)
        case DDifference(i: Word3, j: Word3, k: Word3)
        case RDifference(i: Word3, j: Word3, k: Word3)
        case FProduct(i: Word3, j: Word3, k: Word3)
        case RProduct(i: Word3, j: Word3, k: Word3)
        case DProduct(i: Word3, j: Word3, k: Word3)
        case FDivide(i: Word3, j: Word3, k: Word3)
        case RDivide(i: Word3,  j: Word3, k: Word3)

        var parcel: any Parcel {
            return Parcel15(opcode: self.opcode, i: self.i, j: self.j, k: self.k)
        }

        var opcode: Word6 {
            switch self {
            case .FSum(i: _, j: _, k: _): return 0o30
            case .DSum(i: _, j: _, k: _): return 0o32
            case .RSum(i: _, j: _, k: _): return 0o34
            case .FDifference(i: _, j: _, k: _): return 0o31
            case .DDifference(i: _, j: _, k: _): return 0o33
            case .RDifference(i: _, j: _, k: _): return 0o35
            case .FProduct(i: _, j: _, k: _): return 0o40
            case .RProduct(i: _, j: _, k: _): return 0o41
            case .DProduct(i: _, j: _, k: _): return 0o42
            case .FDivide(i: _, j: _, k: _): return 0o44
            case .RDivide(i: _, j: _, k: _): return 0o45
            }
        }

        var i: Word3 {
            switch self {
            case let .FSum(i: i, j: _, k: _): return i
            case let .DSum(i: i, j: _, k: _): return i
            case let .RSum(i: i, j: _, k: _): return i
            case let .FDifference(i: i, j: _, k: _): return i
            case let .DDifference(i: i, j: _, k: _): return i
            case let .RDifference(i: i, j: _, k: _): return i
            case let .FProduct(i: i, j: _, k: _): return i
            case let .RProduct(i: i, j: _, k: _): return i
            case let .DProduct(i: i, j: _, k: _): return i
            case let .FDivide(i: i, j: _, k: _): return i
            case let .RDivide(i: i, j: _, k: _): return i
            }
        }

        var j: Word3 {
            switch self {
            case let .FSum(i: _, j: j, k: _): return j
            case let .DSum(i: _, j: j, k: _): return j
            case let .RSum(i: _, j: j, k: _): return j
            case let .FDifference(i: _, j: j, k: _): return j
            case let .DDifference(i: _, j: j, k: _): return j
            case let .RDifference(i: _, j: j, k: _): return j
            case let .FProduct(i: _, j: j, k: _): return j
            case let .RProduct(i: _, j: j, k: _): return j
            case let .DProduct(i: _, j: j, k: _): return j
            case let .FDivide(i: _, j: j, k: _): return j
            case let .RDivide(i: _, j: j, k: _): return j
            }
        }

        var k: Word3 {
            switch self {
            case let .FSum(i: _, j: _, k: k): return k
            case let .DSum(i: _, j: _, k: k): return k
            case let .RSum(i: _, j: _, k: k): return k
            case let .FDifference(i: _, j: _, k: k): return k
            case let .DDifference(i: _, j: _, k: k): return k
            case let .RDifference(i: _, j: _, k: k): return k
            case let .FProduct(i: _, j: _, k: k): return k
            case let .RProduct(i: _, j: _, k: k): return k
            case let .DProduct(i: _, j: _, k: k): return k
            case let .FDivide(i: _, j: _, k: k): return k
            case let .RDivide(i: _, j: _, k: k): return k
            }
        }

        init?(from parcel: any Parcel) {
            guard let realParcel = parcel as? Parcel15 else {
                return nil
            }

            switch realParcel.opcode {
            case 0o30: self = .FSum(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o32: self = .DSum(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o34: self = .RSum(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o31: self = .FDifference(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o33: self = .DDifference(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o35: self = .RDifference(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o40: self = .FProduct(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o41: self = .RProduct(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o42: self = .DProduct(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o44: self = .FDivide(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            case 0o45: self = .RDivide(i: realParcel.i, j: realParcel.j, k: realParcel.k)
            default: return nil
            }
        }
        
        func execute(on processor: Cyber170CP) {
            switch self {
            case let .FSum(i: i, j: j, k: k): FSum(on: processor, i: i, j: j, k: k)
            case let .DSum(i: i, j: j, k: k): DSum(on: processor, i: i, j: j, k: k)
            case let .RSum(i: i, j: j, k: k): RSum(on: processor, i: i, j: j, k: k)
            case let .FDifference(i: i, j: j, k: k): FDifference(on: processor, i: i, j: j, k: k)
            case let .DDifference(i: i, j: j, k: k): FDifference(on: processor, i: i, j: j, k: k)
            case let .RDifference(i: i, j: j, k: k): FDifference(on: processor, i: i, j: j, k: k)
            case let .FProduct(i: i, j: j, k: k): FProduct(on: processor, i: i, j: j, k: k)
            case let .RProduct(i: i, j: j, k: k): RProduct(on: processor, i: i, j: j, k: k)
            case let .DProduct(i: i, j: j, k: k): DProduct(on: processor, i: i, j: j, k: k)
            case let .FDivide(i: i, j: j, k: k): FDivide(on: processor, i: i, j: j, k: k)
            case let .RDivide(i: i, j: j, k: k): FDivide(on: processor, i: i, j: j, k: k)
            }
        }
        
        func disassemble() -> String {
            switch self {
            case let .FSum(i: i, j: j, k: k): return "FX\(i) X\(j) + X\(k)"
            case let .DSum(i: i, j: j, k: k): return "DX\(i) X\(j) + X\(k)"
            case let .RSum(i: i, j: j, k: k): return "RX\(i) X\(j) + X\(k)"
            case let .FDifference(i: i, j: j, k: k): return "FX\(i) X\(j) - X\(k)"
            case let .DDifference(i: i, j: j, k: k): return "DX\(i) X\(j) - X\(k)"
            case let .RDifference(i: i, j: j, k: k): return "RX\(i) X\(j) - X\(k)"
            case let .FProduct(i: i, j: j, k: k): return "FX\(i) X\(j) * X\(k)"
            case let .RProduct(i: i, j: j, k: k): return "RX\(i) X\(j) * X\(k)"
            case let .DProduct(i: i, j: j, k: k): return "DX\(i) X\(j) * X\(k)"
            case let .FDivide(i: i, j: j, k: k): return "DX\(i) X\(j) / X\(k)"
            case let .RDivide(i: i, j: j, k: k): return "DX\(i) X\(j) / X\(k)"
            }
        }

        func FSum(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement FSum
        }

        func DSum(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement DSum
        }

        func RSum(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement RSum
        }

        func FDifference(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement FDifference
        }

        func DDifference(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement DDifference
        }

        func RDifference(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement RDifference
        }

        func FProduct(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement FProduct
        }

        func RProduct(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement RProduct
        }

        func DProduct(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement DProduct
        }

        func FDivide(on processor: Cyber170CP, i: Word3, j: Word3, k: Word3) {
            // TODO: Implement FDivide
        }

        func RDivide(on processor: Cyber170CP, i: Word3,  j: Word3, k: Word3) {
            // TODO: Implement RDivide
        }
    }

    /// Jump Instructions (30-bit)
    enum JumpInstruction: Instruction {
        case RJ(K: Word18)
        case JP(i: Word3, K: Word18)

        var parcel: any Parcel {
            return Parcel30(opcode: self.opcode, i: self.i, j: 0o0, K: self.K)
        }

        var opcode: Word6 {
            switch self {
            case .RJ(K: _): return 0o01
            case .JP(i: _, K: _): return 0o02
            }
        }

        var i: Word3 {
            switch self {
            case .RJ(K: _): return 0o0
            case .JP(i: let i, K: _): return i
            }
        }

        var K: Word18 {
            switch self {
            case .RJ(K: let K): return K
            case .JP(i: _, K: let K): return K
            }
        }

        init?(from parcel: any Parcel) {
            guard let realParcel = parcel as? Parcel30 else {
                return nil
            }

            switch realParcel.opcode {
            case 0o01:
                switch realParcel.i {
                case 0o0: self = .RJ(K: realParcel.K)
                default: return nil
                }
            case 0o02: self = .JP(i: realParcel.i, K: realParcel.K)
            default: return nil
            }
        }
        
        func execute(on processor: Cyber170CP) {
            switch self {
            case .RJ(K: let K): RJ(on: processor, K: K)
            case .JP(i: let i, K: let K): JP(on: processor, i: i, K: K)
            }
        }
        
        func disassemble() -> String {
            switch self {
            case .RJ(K: let K): return "RJ \(K)"
            case .JP(i: let i, K: let K): return "JP B\(i) + \(K)"
            }
        }
        
        func RJ(on processor: Cyber170CP, K: Word18) {
            // TODO: Implement RJ
        }

        func JP(on processor: Cyber170CP, i: Word3, K: Word18) {
            // TODO: Implement JP
        }
    }

    /// Exchange Jump Instructions (60-bit)
    enum ExchangeJumpInstruction: Instruction {
        case XJ(j: Word3, K: Word18)

        var parcel: any Parcel {
            return Parcel60(opcode: self.opcode, i: self.i, j: self.j, K: self.K, other: self.other)
        }

        var opcode: Word6 {
            return 0o01
        }

        var i: Word3 {
            return 0o3
        }

        var j: Word3 {
            switch self {
            case .XJ(j: let j, K: _): return j
            }
        }

        var K: Word18 {
            switch self {
            case .XJ(j: _, K: let K): return K
            }
        }

        var other: UInt32 {
            return 0
        }

        init?(from parcel: any Parcel) {
            guard let realParcel = parcel as? Parcel60 else {
                return nil
            }

            switch realParcel.opcode {
            case 0o01:
                switch realParcel.i {
                case 0o3: self = .XJ(j: realParcel.j, K: realParcel.K)
                default: return nil
                }
            default: return nil
            }
        }
        
        func execute(on processor: Cyber170CP) {
            switch self {
            case .XJ(j: let j, K: let K): XJ(on: processor, j: j, K: K)
            }
        }
        
        func disassemble() -> String {
            switch self {
            case .XJ(j: let j, K: let K): "XJ B\(j) + \(K)"
            }
        }
        
        func XJ(on processor: Cyber170CP, j: Word3, K: Word18) {
            // TODO: Implement XJ
        }
    }

    /// Transmit Instructions (15-bit)
    enum TransmitInstruction: Instruction {
        /// Transmit
        case B(i: Word3, j: Word3)

        /// Transmit Complement
        case BC(i: Word3, k: Word3)

        var parcel: any Parcel {
            return Parcel15(opcode: self.opcode, i: self.i, j: self.j, k: self.k)
        }

        var opcode: Word6 {
            switch self {
            case .B(i: _, j: _): return 0o10
            case .BC(i: _, k: _): return 0o14
            }
        }

        var i: Word3 {
            switch self {
            case .B(i: let i, j: _): return i
            case .BC(i: let i, k: _): return i
            }
        }

        var j: Word3 {
            switch self {
            case .B(i: _, j: let j): return j
            case .BC(i: _, k: _): return 0o0
            }
        }

        var k: Word3 {
            switch self {
            case .B(i: _, j: _): return 0o0
            case .BC(i: _, k: let k): return k
            }
        }

        init?(from parcel: any Parcel) {
            guard let realParcel = parcel as? Parcel15 else {
                return nil
            }

            switch realParcel.opcode {
            case 0o10: self = .B(i: realParcel.i, j: realParcel.j)
            case 0o14: self = .BC(i: realParcel.i, k: realParcel.k)
            default: return nil
            }
        }
        
        func execute(on processor: Cyber170CP) {
            switch self {
            case .B(i: let i, j: let j): B(on: processor, i: i, j: j)
            case .BC(i: let i, k: let k): BC(on: processor, i: i, k: k)
            }
        }
        
        func disassemble() -> String {
            switch self {
            case .B(i: let i, j: let j): return "BX\(i) X\(j)"
            case .BC(i: let i, k: let k): return "BX\(i) -X\(k)"
            }
        }
        
        func B(on processor: Cyber170CP, i: Word3, j: Word3) {
            let xj = processor.get(X: j)
            processor.set(X: i, to: xj)
        }

        func BC(on processor: Cyber170CP, i: Word3, k: Word3) {
            let xk = processor.get(X: k)
            let xkc = (~xk) & 0x0FFF_FFFF_FFFF_FFFF // mask to 60 bits
            processor.set(X: i, to: xkc)
        }
    }

    /// Compare/Move Instructions (60-bit)
    enum CompareMoveInstruction: Instruction {

        /// A Move Descriptor describes exactly what the move should do.
        struct MoveDescriptor {
            var LU: UInt16 // actually 9 bits
            var K1: Word18
            var LL: UInt8 // actually 4 bits
            var C1: UInt8 // actually 4 bits
            var C2: UInt8 // actually 4 bits
            var K2: Word18

            var L: UInt16 {
                return UInt16(LU << 9) | UInt16(LL)
            }

            var rawValue: Word60 {
                get {
                    var value: Word60 = 0
                    value |= Word60((self.LU & 0x0000_0000_0000_01FF) << 48)
                    value |= Word60((self.K1 & 0x0000_0000_0003_FFFF) << 30)
                    value |= Word60((self.LL & 0x0000_0000_0000_000F) << 26)
                    value |= Word60((self.C1 & 0x0000_0000_0000_000F) << 22)
                    value |= Word60((self.C2 & 0x0000_0000_0000_000F) << 18)
                    value |= Word60((self.K2 & 0x0000_0000_0003_FFFF) <<  0)
                    return value
                }

                set {
                    precondition(newValue <= 0x0FFF_FFFF_FFFF_FFFF)
                    self.LU = UInt16((newValue >> 48) & 0x0000_0000_0000_01FF)
                    self.K1 = Word18((newValue >> 30) & 0x0000_0000_0003_FFFF)
                    self.LL =  UInt8((newValue >> 26) & 0x0000_0000_0000_000F)
                    self.C1 =  UInt8((newValue >> 22) & 0x0000_0000_0000_000F)
                    self.C2 =  UInt8((newValue >> 18) & 0x0000_0000_0000_000F)
                    self.K2 = Word18((newValue >>  0) & 0x0000_0000_0003_FFFF)
                }
            }

            init(LU: UInt16, K1: Word18, LL: UInt8, C1: UInt8, C2: UInt8, K2: Word18) {
                self.LU = LU
                self.K1 = K1
                self.LL = LL
                self.C1 = C1
                self.C2 = C2
                self.K2 = K2
            }

            init(rawValue: Word60) {
                precondition(rawValue <= 0x0FFF_FFFF_FFFF_FFFF)
                let LU = UInt16((rawValue >> 48) & 0x0000_0000_0000_01FF)
                let K1 = Word18((rawValue >> 30) & 0x0000_0000_0003_FFFF)
                let LL =  UInt8((rawValue >> 26) & 0x0000_0000_0000_000F)
                let C1 =  UInt8((rawValue >> 22) & 0x0000_0000_0000_000F)
                let C2 =  UInt8((rawValue >> 18) & 0x0000_0000_0000_000F)
                let K2 = Word18((rawValue >>  0) & 0x0000_0000_0003_FFFF)
                self.init(LU: LU, K1: K1, LL: LL, C1: C1, C2: C2, K2: K2)
            }

            func disassemble() -> String {
                return "L=\(self.L),K1=\(self.K1),C1=\(self.C1),C2=\(self.C2),K2=\(self.K2)"
            }
        }

        /// Move Indirect
        case IM(j: Word3, K: Word18)

        /// Move Direct
        case DM(md: MoveDescriptor)

        /// Compare Collated
        case CC(md: MoveDescriptor)

        /// Compare Uncollated
        case CU(md: MoveDescriptor)

        var parcel: any Parcel {
            return Parcel60(raw: 0)//xxx
        }

        var opcode: Word6 { return 0 /*xxx*/ }

        init?(from parcel: any Parcel) {
            guard let realParcel = parcel as? Parcel60 else {
                return nil
            }

            switch realParcel.opcode {
            case 0o46:
                switch realParcel.i {
                case 0o4: self = .IM(j: realParcel.j, K: realParcel.K)
                case 0o5: self = .DM(md: MoveDescriptor(rawValue: realParcel.rawValue))
                case 0o6: self = .CC(md: MoveDescriptor(rawValue: realParcel.rawValue))
                case 0o7: self = .CU(md: MoveDescriptor(rawValue: realParcel.rawValue))
                default: return nil
                }
            default: return nil
            }
        }

        func execute(on processor: Cyber170CP) {
            switch self {
            case let .IM(j: j, K: K): IM(on: processor, j: j, K: K)
            case let .DM(md: md): DM(on: processor, md: md)
            case let .CC(md: md): CC(on: processor, md: md)
            case let .CU(md: md): CU(on: processor, md: md)
            }
        }

        func disassemble() -> String {
            switch self {
            case let .IM(j: j, K: K): "IM B\(j) + \(K)"
            case let .DM(md: md): "DM \(md.disassemble())"
            case let .CC(md: md): "CC \(md.disassemble())"
            case let .CU(md: md): "CU \(md.disassemble())"
            }
        }

        func IM(on processor: Cyber170CP, j: Word3, K: Word18) {
            // TODO: Implement IM
        }

        func DM(on processor: Cyber170CP, md: MoveDescriptor) {
            // TODO: Implement DM
        }

        func CC(on processor: Cyber170CP, md: MoveDescriptor) {
            // TODO: Implement CC
        }

        func CU(on processor: Cyber170CP, md: MoveDescriptor) {
            // TODO: Implement CU
        }
    }
}
