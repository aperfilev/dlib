/*
Copyright (c) 2017-2019 Timur Gafarov

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

module dlib.image.animation;

import dlib.core.memory;
import dlib.image.image;

interface SuperAnimatedImage: SuperImage
{
    @property size_t frameSize();
    @property uint numFrames();
    @property uint currentFrame();
    @property void currentFrame(uint f);
    uint advanceFrame();
}

/*
 * AnimatedImage is an extension of standard Image that handles animation.
 * It can store more than one frame of pixel data.
 * Current frame can be switched with currentFrame property.
 * All usual image operations work on current frame, so
 * you can use this class with any existing dlib.image
 * functionality: save to file, apply filters, etc.
 */
class AnimatedImage(PixelFormat fmt): Image!(fmt), SuperAnimatedImage
{
    protected:
    uint _numFrames;
    uint _currentFrame = 0;
    size_t _frameSize;

    public:
    this(uint w, uint h, uint frames)
    {
        _numFrames = frames;
        super(w, h);
        _frameSize = _width * _height * _pixelSize;
    }

    override @property SuperImage dup()
    {
        auto res = new AnimatedImage!(fmt)(_width, _height, _numFrames);
        res.data[] = data[];
        return res;
    }

    override SuperImage createSameFormat(uint w, uint h)
    {
        return new AnimatedImage!(fmt)(w, h, _numFrames);
    }

    @property size_t frameSize()
    {
        return _frameSize;
    }

    @property uint numFrames()
    {
        return _numFrames;
    }

    @property uint currentFrame()
    {
        return _currentFrame;
    }

    @property void currentFrame(uint f)
    {
        if (f >= _numFrames)
            _currentFrame = _numFrames - 1;
        else
            _currentFrame = f;
    }

    uint advanceFrame()
    {
        currentFrame = currentFrame + 1;
        return _currentFrame;
    }

    override @property ubyte[] data()
    {
        if (_currentFrame >= _numFrames)
            _currentFrame = _numFrames - 1;
        size_t offset = _frameSize * _currentFrame;
        return _data[offset..offset+_frameSize];
    }

    protected override void allocateData()
    {
        _data = new ubyte[_width * _height * _pixelSize * _numFrames];
    }
}

alias AnimatedImageL8 = AnimatedImage!(PixelFormat.L8);
alias AnimatedImageLA8 = AnimatedImage!(PixelFormat.LA8);
alias AnimatedImageRGB8 = AnimatedImage!(PixelFormat.RGB8);
alias AnimatedImageRGBA8 = AnimatedImage!(PixelFormat.RGBA8);

alias AnimatedImageL16 = AnimatedImage!(PixelFormat.L16);
alias AnimatedImageLA16 = AnimatedImage!(PixelFormat.LA16);
alias AnimatedImageRGB16 = AnimatedImage!(PixelFormat.RGB16);
alias AnimatedImageRGBA16 = AnimatedImage!(PixelFormat.RGBA16);

class AnimatedImageFactory: SuperImageFactory
{
    SuperImage createImage(uint w, uint h, uint channels, uint bitDepth, uint numFrames = 1)
    {
        return animatedImage(w, h, channels, bitDepth, numFrames);
    }
}

private AnimatedImageFactory _defaultAnimatedImageFactory;

AnimatedImageFactory animatedImageFactory()
{
    if (!_defaultAnimatedImageFactory)
        _defaultAnimatedImageFactory = new AnimatedImageFactory();
    return _defaultAnimatedImageFactory;
}

SuperImage animatedImage(uint w, uint h, uint channels, uint bitDepth, uint numFrames = 1)
in
{
    assert(channels > 0 && channels <= 4);
    assert(bitDepth == 8 || bitDepth == 16);
}
do
{
    switch(channels)
    {
        case 1:
        {
            if (bitDepth == 8)
                return new AnimatedImageL8(w, h, numFrames);
            else
                return new AnimatedImageL16(w, h, numFrames);
        }
        case 2:
        {
            if (bitDepth == 8)
                return new AnimatedImageLA8(w, h, numFrames);
            else
                return new AnimatedImageLA16(w, h, numFrames);
        }
        case 3:
        {
            if (bitDepth == 8)
                return new AnimatedImageRGB8(w, h, numFrames);
            else
                return new AnimatedImageRGB16(w, h, numFrames);
        }
        case 4:
        {
            if (bitDepth == 8)
                return new AnimatedImageRGBA8(w, h, numFrames);
            else
                return new AnimatedImageRGBA16(w, h, numFrames);
        }
        default:
            assert(0);
    }
}

class UnmanagedAnimatedImage(PixelFormat fmt): AnimatedImage!(fmt)
{
    override @property SuperImage dup()
    {
        auto res = New!(UnmanagedAnimatedImage!(fmt))(_width, _height, _numFrames);
        res.data[] = data[];
        return res;
    }

    override SuperImage createSameFormat(uint w, uint h)
    {
        return New!(UnmanagedAnimatedImage!(fmt))(w, h, _numFrames);
    }

    this(uint w, uint h, uint frames)
    {
        super(w, h, frames);
    }

    ~this()
    {
        Delete(_data);
    }

    protected override void allocateData()
    {
        _data = New!(ubyte[])(_width * _height * _pixelSize * _numFrames);
    }

    override void free()
    {
        Delete(this);
    }
}

alias UnmanagedAnimatedImageL8 = UnmanagedAnimatedImage!(PixelFormat.L8);
alias UnmanagedAnimatedImageLA8 = UnmanagedAnimatedImage!(PixelFormat.LA8);
alias UnmanagedAnimatedImageRGB8 = UnmanagedAnimatedImage!(PixelFormat.RGB8);
alias UnmanagedAnimatedImageRGBA8 = UnmanagedAnimatedImage!(PixelFormat.RGBA8);

alias UnmanagedAnimatedImageL16 = UnmanagedAnimatedImage!(PixelFormat.L16);
alias UnmanagedAnimatedImageLA16 = UnmanagedAnimatedImage!(PixelFormat.LA16);
alias UnmanagedAnimatedImageRGB16 = UnmanagedAnimatedImage!(PixelFormat.RGB16);
alias UnmanagedAnimatedImageRGBA16 = UnmanagedAnimatedImage!(PixelFormat.RGBA16);

class UnmanagedAnimatedImageFactory: SuperImageFactory
{
    SuperImage createImage(uint w, uint h, uint channels, uint bitDepth, uint numFrames = 1)
    {
        return unmanagedAnimatedImage(w, h, channels, bitDepth, numFrames);
    }
}

SuperImage unmanagedAnimatedImage(uint w, uint h, uint channels, uint bitDepth, uint numFrames = 1)
in
{
    assert(channels > 0 && channels <= 4);
    assert(bitDepth == 8 || bitDepth == 16);
}
do
{
    switch(channels)
    {
        case 1:
        {
            if (bitDepth == 8)
                return New!UnmanagedAnimatedImageL8(w, h, numFrames);
            else
                return New!UnmanagedAnimatedImageL16(w, h, numFrames);
        }
        case 2:
        {
            if (bitDepth == 8)
                return New!UnmanagedAnimatedImageLA8(w, h, numFrames);
            else
                return New!UnmanagedAnimatedImageLA16(w, h, numFrames);
        }
        case 3:
        {
            if (bitDepth == 8)
                return New!UnmanagedAnimatedImageRGB8(w, h, numFrames);
            else
                return New!UnmanagedAnimatedImageRGB16(w, h, numFrames);
        }
        case 4:
        {
            if (bitDepth == 8)
                return New!UnmanagedAnimatedImageRGBA8(w, h, numFrames);
            else
                return New!UnmanagedAnimatedImageRGBA16(w, h, numFrames);
        }
        default:
            assert(0);
    }
}
