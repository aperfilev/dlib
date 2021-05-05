/*
Copyright (c) 2015-2021 Timur Gafarov

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

/**
 * Bit-level manipulations
 *
 * Copyright: Timur Gafarov 2015-2021.
 * License: $(LINK2 https://boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.core.bitio;
 
/**
 * Endianness
 */
enum Endian
{
    Little,
    Big
}

/**
 * Returns high 4 bits of a byte
 */
T hiNibble(T)(T b)
{
    return ((b >> 4) & 0x0F);
}

///
unittest
{
    assert(hiNibble(0xFE) == 0x0F);
}

/**
 * Returns low 4 bits of a byte
 */
T loNibble(T)(T b)
{
    return (b & 0x0F);
}

///
unittest
{
    assert(loNibble(0xFE) == 0x0E);
}

/**
 * Returns 16-bit integer n with swapped endianness
 * TODO: move to dlib.math.utils
 */
T swapEndian16(T)(T n)
{
    return cast(T)((n >> 8) | (n << 8));
}

///
unittest
{
    assert(swapEndian16(cast(ushort)0xFF00) == 0x00FF);
}

/**
 * Sets bit at position pos in integer b to state
 */
T setBit(T)(T b, uint pos, bool state)
{
    if (state)
        return cast(T)(b | (1 << pos));
    else
        return cast(T)(b & ~(1 << pos));
}

///
unittest
{
    assert(setBit(0, 0, true) == 1);
}

/**
 * Returns bit at position pos in integer b
 */
bool getBit(T)(T b, uint pos)
{
    return ((b & (1 << pos)) != 0);
}

///
unittest
{
    assert(getBit(1, 0) == 1);
}
