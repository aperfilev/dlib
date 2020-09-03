/*
Copyright (c) 2015-2020 Timur Gafarov

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
 * Prototype-based OOP system for structs.
 * Uses some template black magic to implement:
 * - Multiple inheritance
 * - Parametric polymorphism (struct interfaces)
 * - Interface inheritance
 * Copyright: Timur Gafarov 2015-2020.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.core.oop;

import std.traits;

/**
 * Inheritance mixin
 */
mixin template Inherit(PT...)
{
    PT _parent;
    alias _parentTypeTuple = PT;
    alias _parent this;

    template opDispatch(string s)
    {
        enum e = tupleElemWithMember!(s, PT);

        static if (hasMethod!(typeof(_parent[e]), s))
        {
            @property auto ref opDispatch(T...)(T params)
            {
                return __traits(getMember, _parent[e], s)(params);
            }
        }
        else
        {
            @property auto ref opDispatch()
            {
                return __traits(getMember, _parent[e], s);
            }

            @property auto ref opDispatch(T)(T val)
            {
                return __traits(getMember, _parent[e], s) = val;
            }
        }
    }
}

/**
 * Returns index of a tuple element which has specified member (s)
 */
size_t tupleElemWithMember(string s, T...)()
{
    foreach(i, type; T)
    {
        static if (__traits(hasMember, type, s))
            return i;
    }
    assert(0);
}

/**
 * Test if type (T) has specified method (m), local or derived
 */
bool hasMethod(T, string m)()
{
    static if (__traits(hasMember, T, m))
    {
        static if (isMethod!(__traits(getMember, T, m)))
        {
            return true;
        }
    }

    static if (__traits(hasMember, T, "_parentTypeTuple"))
    {
        foreach(i, parentType; T._parentTypeTuple)
        {
            static if (hasMethod!(parentType, m))
            {
                return true;
            }
        }

        return false;
    }
    else
    {
        return false;
    }
}

/**
 * Check if given type (T) corresponds to given signature (I)
 */
bool implements(T, I)()
{
    foreach(i, name; __traits(allMembers, I))
    {
        static if (name == "_parentTypeTuple") {}
        else static if (name == "_parent")
        {
            foreach(ParI; I._parentTypeTuple)
            {
                static if (!implements!(T, ParI))
                    return false;
            }
        }
        else static if (isMethod!(__traits(getMember, I, name)))
        {
            static if (!hasMethod!(T, name))
                return false;
        }
        else
        {
            static if (!__traits(hasMember, T, name))
                return false;
            else
            {
                alias t1 = typeof(__traits(getMember, T, name));
                alias t2 = typeof(__traits(getMember, I, name));
                static if (!is(t1 == t2))
                    return false;
            }
        }
    }
    return true;
}

/**
 * Test if F is a method
 */
template isMethod(alias F)
{
    enum isMethod =
           isSomeFunction!F &&
          !isFunctionPointer!F &&
          !isDelegate!F;
}

///
unittest
{
    struct Foo
    {
        int x = 100;
        int foo() { return 11; }
    }

    struct Bar
    {
        int y = 99;
        int bar() { return 22; }
    }

    struct TestObj
    {
        mixin Inherit!(Foo, Bar);
    }

    TestObj obj;

    obj.x *= 2;
    obj.y = 10;

    assert(obj.x == 200);
    assert(obj.y == 10);

    assert(obj.foo() == 11);
    assert(obj.bar() == 22);
}

