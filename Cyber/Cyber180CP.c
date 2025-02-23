//
//  CentralProcessor.c
//  Cyber
//
//  Copyright © 2025 Christopher M. Hanson
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

#include "Cyber180CP_Internal.h"

#include "Cyber180Cache_Internal.h"
#include "Cyber180CMPort_Internal.h"
#include "Cyber180CPInstructions_Internal.h"
#include "CyberThread.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


CYBER_SOURCE_BEGIN


static void Cyber180CPMainLoop(struct CyberThread *thread, void * _Nullable cpv);

static void Cyber180CPSingleStep(struct Cyber180CP *cp);


/// The default size of a Cyber 180 CP cache line, in bytes.
const size_t Cyber180CPDefaultCacheLineSize = 64;

/// The default number of Cyber 180 CP cache lines,.
const size_t Cyber180CPDefaultCacheLineCount = 512;


struct Cyber180CP * _Nullable Cyber180CPCreate(struct Cyber962 * _Nonnull system, int index)
{
    assert(system != NULL);
    assert((index >= 0) && (index <= 1));

    struct Cyber180CP *cp = calloc(1, sizeof(struct Cyber180CP));

    cp->_system = system;
    cp->_index = index;

    cp->_mode = Cyber180CPModeMonitor;

    cp->_cache = Cyber180CacheCreate(cp);

    static struct CyberThreadFunctions Cyber180CPThreadFunctions = {
        .start = NULL,
        .loop = Cyber180CPMainLoop,
        .stop = NULL,
        .terminate = NULL,
    };

    char name[32];
    snprintf(name, 32, "Cyber180CP-%d", index);

    cp->_thread = CyberThreadCreate(name, &Cyber180CPThreadFunctions, cp);

    return cp;
}


void Cyber180CPDispose(struct Cyber180CP * _Nullable cp)
{
    if (cp == NULL) return;

    Cyber180CacheDispose(cp->_cache);
    CyberThreadDispose(cp->_thread);

    free(cp);
}


void Cyber180CPStart(struct Cyber180CP *cp)
{
    assert(cp != NULL);

    CyberThreadStart(cp->_thread);
}

void Cyber180CPStop(struct Cyber180CP *cp)
{
    assert(cp != NULL);

    CyberThreadStop(cp->_thread);
}

void Cyber180CPShutDown(struct Cyber180CP *cp)
{
    assert(cp != NULL);

    CyberThreadTerminate(cp->_thread);
}


void Cyber180CPMainLoop(struct CyberThread *thread, void * _Nullable cpv)
{
    struct Cyber180CP *cp = (struct Cyber180CP *)cpv;
    assert(cp != NULL);

    // Run the main loop once.
    Cyber180CPSingleStep(cp);
}


struct Cyber180CMPort * _Nonnull Cyber180CPGetCentralMemoryPort(struct Cyber180CP *cp)
{
    assert(cp != NULL);

    return cp->_centralMemoryPort;
}


void Cyber180CPSetCentralMemoryPort(struct Cyber180CP *cp, struct Cyber180CMPort *port)
{
    assert(cp != NULL);
    assert(port != NULL);
    assert(cp->_centralMemoryPort == NULL);

    cp->_centralMemoryPort = port;
}


CyberWord48 Cyber180CPGetA(struct Cyber180CP *cp, int i)
{
    assert(cp != NULL);
    assert((i >= 0) && (i <= 0xf));

    return cp->_regA[i] & 0x0000FFFFFFFFFFFF;
}

void Cyber180CPSetA(struct Cyber180CP *cp, int i, CyberWord48 value)
{
    assert(cp != NULL);
    assert((i >= 0) && (i <= 0xf));

    if (i != 0) {
        cp->_regA[i] = value & 0x0000FFFFFFFFFFFF;
    }
}

CyberWord64 Cyber180CPGetX(struct Cyber180CP *cp, int i)
{
    assert(cp != NULL);
    assert((i >= 0) && (i <= 0xf));

    return cp->_regX[i];
}

CyberWord64 Cyber180CPGetXOr0(struct Cyber180CP *cp, int i)
{
    assert(cp != NULL);
    assert((i >= 0) && (i <= 0xf));

    if (i != 0) {
        return cp->_regX[i];
    } else {
        return 0;
    }
}

void Cyber180CPSetX(struct Cyber180CP *cp, int i, CyberWord64 value)
{
    assert(cp != NULL);
    assert((i >= 0) && (i <= 0xf));

    cp->_regX[i] = value;
}


CyberWord48 Cyber180CPTranslatePVAToSVA(struct Cyber180CP *cp, CyberWord48 processVirtualAddress)
{
    CyberWord48 systemVirtualAddress = 0;

    assert(cp != NULL);

    // A Process VIrtual Address is structured as:
    // 4 bits Ring Number (RN)
    // 12 bits Segment Number (SEG)
    // 32 bits Byte Number (BN)

    CyberWord48 RN  = (processVirtualAddress & 0xF00000000000) >> 44;
    CyberWord48 SEG = (processVirtualAddress & 0x0FFF00000000) >> 12;
    CyberWord48 BN  = (processVirtualAddress & 0x0000FFFFFFFF) >>  0;

    // TODO: Implement virtual memory.

    CyberWord48 ASID = SEG; // should look up ASID from SEG

    (void)RN; // should use for checking privilege
    systemVirtualAddress |= ASID << 32;
    systemVirtualAddress |= BN;

    return systemVirtualAddress;
}

CyberWord32 Cyber180CPTranslateSVAToRMA(struct Cyber180CP *cp, CyberWord48 systemVirtualAdddress)
{
    CyberWord32 realMemoryAddress = 0;

    assert(cp != NULL);

    // A System Virtual Address is structured as:
    // 16 bits Active Segment Identifier (ASID)
    // 15-22 bits Page Number (PN)
    // 16-9 bits Page Offset (PO)

    // While bringing things up, assume 20 bits for PN and 12 bits for PO.

    CyberWord48 ASID = (systemVirtualAdddress & 0xFFFF00000000) >> 32;
    CyberWord48   PN = (systemVirtualAdddress & 0x0000FFFFF000) >> 12;
    CyberWord48   PO = (systemVirtualAdddress & 0x000000000FFF) >>  0;

    // TODO: Implement virtual memory.

    (void)ASID;
    realMemoryAddress |= PN << 12;
    realMemoryAddress |= PO <<  0;

    return realMemoryAddress;
}

static inline CyberWord32 Cyber180CPTranslatePVAToRMA(struct Cyber180CP *cp, CyberWord48 processVirtualAdddress)
{
    CyberWord64 systemVirtualAddress = Cyber180CPTranslatePVAToSVA(cp, processVirtualAdddress);
    CyberWord32 realMemoryAddress = Cyber180CPTranslateSVAToRMA(cp, systemVirtualAddress);

    return realMemoryAddress;
}


void Cyber180CPWriteBytes(struct Cyber180CP *cp, CyberWord48 processVirtualAddress, CyberWord8 *buf, CyberWord32 count)
{
    assert(cp != NULL);

    // Break the write into separate cache lines and write each one that's covered.

    struct Cyber180CMPort *port = Cyber180CPGetCentralMemoryPort(cp);

    const CyberWord48 lineOffsetMask = Cyber180CacheLineSize - 1;
    const CyberWord48 lineAddressMask = ~lineOffsetMask;

    const CyberWord48 transactionStartPVA     = processVirtualAddress;
    const CyberWord48 transactionStartLinePVA = transactionStartPVA & lineAddressMask;
    const CyberWord32 transactionStartOffset  = (CyberWord32)(transactionStartPVA & lineOffsetMask);
    const CyberWord48 transactionEndPVA       = transactionStartPVA + count - 1;
    const CyberWord48 transactionEndLinePVA   = transactionEndPVA & lineAddressMask;
    const CyberWord32 transactionEndOffset    = (CyberWord32)(transactionEndPVA & lineOffsetMask);

    // The line count can be 32 bits since that's all a byte offset can be.
    const CyberWord32 lineCount = (CyberWord32)((transactionEndLinePVA - transactionStartLinePVA) + 1);
    CyberWord32 copiedSoFar = 0;

    // Transfer each line's data, holding the port lock the entire time for coherence.
    // Since cache lines can't span page boundaries, this can get the Real Memory Address of each line and use that during the copy.
    // TODO: Optimize by only getting a new RMA when crossing a page boundary.

    Cyber180CMPortAcquireLock(port); {

        // Before doing anything else, have the cache process the port's current eviction queue.

        Cyber180CacheProcessEvictionQueue(cp->_cache, port->_cacheEvictionQueue);

        // Now transfer the data for each line.

        CyberWord8 lineBuf[Cyber180CacheLineSize];
        CyberWord48 currentLinePVA = transactionStartLinePVA;
        CyberWord32 copyCount = 0;

        for (long line = 0; line < lineCount; line++) {
            // Get the real memory address of the current line.

            CyberWord32 currentLineRMA = Cyber180CPTranslatePVAToRMA(cp, currentLinePVA);

            if (line == 0) {
                // First line, special case to cover a transaction that doesn't start on a line boundary.

                // Get the current line from the cache if it's in there, going to memory if it's not.

                if (Cyber180CacheGetDataForAddress(cp->_cache, currentLineRMA, lineBuf) == false) {
                    Cyber180CMPortReadBytesPhysical_Unlocked(port, currentLineRMA, lineBuf, Cyber180CacheLineSize);
                }

                // Copy only the covered subset of the line from the input buffer.

                if (lineCount == 1) {
                    // The transaction doesn't span lines, so just use its length.

                    copyCount = count;
                } else {
                    // The transaction does span lines, so use the remainder of the line.

                    copyCount = Cyber180CacheLineSize - transactionStartOffset;
                }

                memcpy(&lineBuf[transactionStartOffset], &buf[0], copyCount);

                // Write the updated line to the memory and update the cache.

                Cyber180CMPortWriteBytesPhysical_Unlocked(port, currentLineRMA, lineBuf, Cyber180CacheLineSize);
                Cyber180CacheAddOrUpdateDataForAddress(cp->_cache, currentLineRMA, lineBuf);
            } else if (line == (lineCount - 1)) {
                // Last line, special case to cover a transaction  that doesn't end on a line boundary.

                // Get the current line from the cache if it's in there, going to memory if it's not.

                if (Cyber180CacheGetDataForAddress(cp->_cache, currentLineRMA, lineBuf) == false) {
                    Cyber180CMPortReadBytesPhysical_Unlocked(port, currentLineRMA, lineBuf, Cyber180CacheLineSize);
                }

                // Copy only the covered subset of the line from the input buffer.

                copyCount = transactionEndOffset;
                memcpy(lineBuf, &buf[copiedSoFar], copyCount);

                // Write the updated line to the memory and update the cache.

                Cyber180CMPortWriteBytesPhysical_Unlocked(port, currentLineRMA, lineBuf, Cyber180CacheLineSize);
                Cyber180CacheAddOrUpdateDataForAddress(cp->_cache, currentLineRMA, lineBuf);
            } else {
                // Middle line, deal solely in entire lines.

                // Copy directly to memory from the input buffer.

                copyCount = Cyber180CacheLineSize;

                Cyber180CMPortWriteBytesPhysical_Unlocked(port, currentLineRMA, &buf[copiedSoFar], copyCount);
                Cyber180CacheAddOrUpdateDataForAddress(cp->_cache, currentLineRMA, &buf[copiedSoFar]);
            }

            // Go to the next line.

            currentLinePVA += Cyber180CacheLineSize;
            copiedSoFar += copyCount;
        }
    } Cyber180CMPortRelinquishLock(port);

    assert(copiedSoFar == count);
}

void Cyber180CPReadBytes(struct Cyber180CP *cp, CyberWord48 processVirtualAddress, CyberWord8 *buf, CyberWord32 count)
{
    assert(cp != NULL);

    // Break the read into separate cache lines and read each one that's covered.

    struct Cyber180CMPort *port = Cyber180CPGetCentralMemoryPort(cp);

    const CyberWord48 lineOffsetMask = Cyber180CacheLineSize - 1;
    const CyberWord48 lineAddressMask = ~lineOffsetMask;

    const CyberWord48 transactionStartPVA     = processVirtualAddress;
    const CyberWord48 transactionStartLinePVA = transactionStartPVA & lineAddressMask;
    const CyberWord32 transactionStartOffset  = (CyberWord32)(transactionStartPVA & lineOffsetMask);
    const CyberWord48 transactionEndPVA       = transactionStartPVA + count - 1;
    const CyberWord48 transactionEndLinePVA   = transactionEndPVA & lineAddressMask;
    const CyberWord32 transactionEndOffset    = (CyberWord32)(transactionEndPVA & lineOffsetMask);

    // The line count can be 32 bits since that's all a byte offset can be.
    const CyberWord32 lineCount = (CyberWord32)((transactionEndLinePVA - transactionStartLinePVA) + 1);
    CyberWord32 copiedSoFar = 0;

    // Transfer each line's data, holding the port lock the entire time for coherence.
    // Since cache lines can't span page boundaries, this can get the Real Memory Address of each line and use that during the copy.
    // TODO: Optimize by only getting a new RMA when crossing a page boundary.

    Cyber180CMPortAcquireLock(port); {

        // Before doing anything else, have the cache process the port's current eviction queue.

        Cyber180CacheProcessEvictionQueue(cp->_cache, port->_cacheEvictionQueue);

        // Now transfer the data for each line.

        CyberWord8 lineBuf[Cyber180CacheLineSize];
        CyberWord48 currentLinePVA = transactionStartLinePVA;
        CyberWord32 copyCount = 0;

        for (long line = 0; line < lineCount; line++) {
            // Get the real memory address of the current line.

            CyberWord32 currentLineRMA = Cyber180CPTranslatePVAToRMA(cp, currentLinePVA);

            // Get the current line from the cache if it's in there, going to memory and updating the cache if it's not.

            if (Cyber180CacheGetDataForAddress(cp->_cache, currentLineRMA, lineBuf) == false) {
                Cyber180CMPortReadBytesPhysical_Unlocked(port, currentLineRMA, lineBuf, Cyber180CacheLineSize);
                Cyber180CacheAddOrUpdateDataForAddress(cp->_cache, currentLineRMA, lineBuf);
            }

            if (line == 0) {
                // First line, special case to cover a transaction that doesn't start on a line boundary.

                // Copy only the covered subset of the line to the output buffer.

                if (lineCount == 1) {
                    // The transaction doesn't span lines, so just use its length.

                    copyCount = count;
                } else {
                    // The transaction does span lines, so use the remainder of the line.

                    copyCount = Cyber180CacheLineSize - transactionStartOffset;
                }

                memcpy(&buf[0], &lineBuf[transactionStartOffset], copyCount);
            } else if (line == (lineCount - 1)) {
                // Last line, special case to cover a transaction  that doesn't end on a line boundary.

                // Get the line from the cache if it's in there, going to memory and updating the cache if it's not.

                bool found = Cyber180CacheGetDataForAddress(cp->_cache, currentLineRMA, lineBuf);
                if (!found) {
                    Cyber180CMPortReadBytesPhysical_Unlocked(port, currentLineRMA, lineBuf, Cyber180CacheLineSize);
                    Cyber180CacheAddOrUpdateDataForAddress(cp->_cache, currentLineRMA, lineBuf);
                }

                // Copy only the covered subset of the line to the output buffer.

                copyCount = transactionEndOffset;
                memcpy(&buf[copiedSoFar], lineBuf, copyCount);

                // Don't need to go to the next line, but keep copiedSoFar updated for debugging.

                copiedSoFar += copyCount;
            } else {
                // Middle line, deal solely in entire lines.

                // Copy directly to the output buffer.

                copyCount = Cyber180CacheLineSize;
                memcpy(&buf[copiedSoFar], lineBuf, copyCount);
            }

            // Go to the next line.

            currentLinePVA += Cyber180CacheLineSize;
            copiedSoFar += copyCount;
        }
    } Cyber180CMPortRelinquishLock(port);

    assert(copiedSoFar == count);
}


union Cyber180CPInstructionWord Cyber180CPReadInstructionWord(struct Cyber180CP *cp, CyberWord64 virtualAddress)
{
    union Cyber180CPInstructionWord result;

    assert(cp != NULL);

    CyberWord8 opcode;
    Cyber180CPReadBytes(cp, virtualAddress, &opcode, 1);
    CyberWord64 advance = Cyber180CPInstructionAdvance(opcode);
    if (advance == 2) {
        CyberWord16 instword16 = 0;
        Cyber180CPReadBytes(cp, virtualAddress, (CyberWord8 *)&instword16, 2);
        result._raw = ((CyberWord32)instword16) << 16;
    } else if (advance == 4) {
        CyberWord32 instword32 = 0;
        Cyber180CPReadBytes(cp, virtualAddress, (CyberWord8 *)&instword32, 4);
        result._raw = instword32;
    } else {
        assert(false); // should be impossible, all opcodes are accounted for at this level
    }

    return result;
}


void Cyber180CPSingleStep(struct Cyber180CP *cp)
{
    assert(cp != NULL);

    CyberWord64 oldP = cp->_regP;
    union Cyber180CPInstructionWord instructionWord = Cyber180CPReadInstructionWord(cp, oldP);
    Cyber180CPInstruction instruction = Cyber180CPInstructionDecode(cp, instructionWord, oldP);
    if (instruction) {
        CyberWord64 advance = instruction(cp, instructionWord, oldP);
        if (advance != ~0x0) {
            CyberWord64 newP = oldP + advance;
            cp->_regP = newP;
        }
    } else {
        // TODO: Illegal instruction interrupt
        assert(false);
    }
}


CYBER_SOURCE_END
