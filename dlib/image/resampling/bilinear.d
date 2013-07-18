/*
Copyright (c) 2011-2013 Timur Gafarov 

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

module dlib.image.resampling.bilinear;

private
{
    import std.math;
    import dlib.image.image;
    import dlib.image.color;
}

SuperImage resampleBilinear(SuperImage img, in uint newWidth, in uint newHeight)
in
{
    assert (img.data.length);
}
body
{
    SuperImage res = img.createSameFormat(newWidth, newHeight);

    float xFactor = cast(float)img.width  / cast(float)newWidth;
    float yFactor = cast(float)img.height / cast(float)newHeight;

    int floor_x, floor_y, ceil_x, ceil_y;
    float fraction_x, fraction_y, one_minus_x, one_minus_y;

    Color4f c1, c2, c3, c4;
    Color4f col;
    float b1, b2;

    foreach(y; 0..res.height)
    foreach(x; 0..res.width)
    {
        floor_x = cast(int)floor(x * xFactor);
        floor_y = cast(int)floor(y * yFactor);

        ceil_x = floor_x + 1;
        if (ceil_x >= img.width) 
            ceil_x = floor_x;

        ceil_y = floor_y + 1;
        if (ceil_y >= img.height)
            ceil_y = floor_y;

        fraction_x = x * xFactor - floor_x;
        fraction_y = y * yFactor - floor_y;
        one_minus_x = 1.0f - fraction_x;
        one_minus_y = 1.0f - fraction_y;

        c1 = Color4f(img[floor_x, floor_y]);
        c2 = Color4f(img[ceil_x,  floor_y]);
        c3 = Color4f(img[floor_x, ceil_y]);
        c4 = Color4f(img[ceil_x,  ceil_y]);

        // Red
        b1 = one_minus_x * c1.r + fraction_x * c2.r;
        b2 = one_minus_x * c3.r + fraction_x * c4.r;
        col.r = one_minus_y * b1 + fraction_y * b2;

        // Green
        b1 = one_minus_x * c1.g + fraction_x * c2.g;
        b2 = one_minus_x * c3.g + fraction_x * c4.g;
        col.g = one_minus_y * b1 + fraction_y * b2;

        // Blue
        b1 = one_minus_x * c1.b + fraction_x * c2.b;
        b2 = one_minus_x * c3.b + fraction_x * c4.b;
        col.b = one_minus_y * b1 + fraction_y * b2;

        // Alpha
        b1 = one_minus_x * c1.a + fraction_x * c2.a;
        b2 = one_minus_x * c3.a + fraction_x * c4.a;
        col.a = one_minus_y * b1 + fraction_y * b2;

        res[x, y] = col.convert(res.bitDepth);
    }

    return res;
}

