/*
Copyright (c) 2018 Timur Gafarov, Oleg Baharev

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

module dlib.image.filters.histogram;

import dlib.image.image;
import dlib.image.color;

int[256] createHistogram(SuperImage img)
{
	int[256] histogram;

	foreach (x; 0..img.width)
	foreach (y; 0..img.height)
	{
		int luma = cast(int)(img[x,y].luminance * 255);
		histogram[luma] += 1; 
	}

	return histogram;
}

SuperImage histogramImage(SuperImage img, Color4f background, Color4f diagram)
{
    SuperImage res = img.createSameFormat(256, 256);
    int[256] h = createHistogram(img);

    int vmax = 0;
    foreach(v; h)
    {
        if (v > vmax)
            vmax = v;
    }

    foreach(ref v; h)
    {
        v = cast(int)(cast(float)v / cast(float)vmax * 255.0f);
    }

	foreach (x; 0..res.width)
	foreach (y; 0..res.height)
	{
        int v = h[x];
        if (y < 255 - v)
            res[x, y] = background;
        else
            res[x, y] = diagram;
    }
    return res;
}
