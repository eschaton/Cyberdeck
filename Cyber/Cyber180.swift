//
//  Cyber180.swift
//  Cyberdeck
//
//  Created by Chris Hanson on 1/9/25.
//  Copyright © 2025 Christopher M. Hanson. All rights reserved.
//


/// A Cyber180 system.
///
/// A system consists of:
/// - One Central Memory
/// - Several I/O Channels
/// - One or more Central Processors
/// - One or more Peripheral Processors
class Cyber180 {

    /// The Central Memory subsystem.
    var centralMemory: CyberMemory

    /// The I/O channels.
    var channels: [Cyber180IOChannel]

    /// The Central Processors.
    var centralProcessors: [Cyber180CP]

    /// The Peripheral Processors.
    var peripheralProcessors: [Cyber180PP]

    init(memorySize: Int, channels: Int = 12, centralProcessors: Int = 1, peripheralProcessors: Int = 2) {
        self.centralMemory = CyberMemory()
        self.channels = []
        self.centralProcessors = []
        self.peripheralProcessors = []

        // TODO: Initialize standard I/O channels

        for _ in 0..<centralProcessors {
            let centralProcessor = Cyber180CP(system: self)
            centralProcessor.system = self
            self.centralProcessors.append(centralProcessor)
        }

        for _ in 0..<peripheralProcessors {
            self.peripheralProcessors.append(Cyber180PP(system: self))
        }

        // TODO: Connect the different subsystems together.
    }
}
