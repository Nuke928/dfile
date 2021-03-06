/*
 * utils.d : Utilities
 */

module utils;

import std.stdio, dfile : Base10;

/*
 * File utilities.
 */

/**
 * Read file with a struct or array.
 * Note: MAKE SURE THE STRUCT IS BYTE-ALIGNED.
 * Params:
 *   file = Current file
 *   s = Void pointer to the first element
 *   size = Size of the struct
 *   rewind = Rewind seeker to start of the file
 */
void scpy(File file, void* s, size_t size, bool rewind = false)
{
    import std.c.string : memcpy;
    if (rewind) file.rewind();
    ubyte[] buf = new ubyte[size];
    file.rawRead(buf);
    memcpy(s, buf.ptr, size);
}

/*
 * String utilities.
 */

/**
 * Get a string from a  null-terminated buffer.
 * Params: str = ASCIZ sting
 * Returns: String (UTF-8)
 */
string asciz(char[] str) pure
{
    if (str[0] == '\0') return null;
    char* p, ip; p = ip = &str[0];
    while (*++p != '\0') {}
    return str[0 .. p - ip].idup;
}

/**
 * Get a string from a '0'-padded buffer.
 * Params: str = tar sting
 * Returns: String (UTF-8)
 */
string tarstr(char[] str) pure
{
    size_t p;
    while (str[p] == '0') ++p;
    return str[p .. $ - 1].idup;
}

/**
 * Get a ' '-padded string from a buffer.
 * Params: str = iso-string
 * Returns: String (UTF-8)
 */
string isostr(char[] str) pure
{
    if (str[0] == ' ') return null;
    if (str[$ - 1] != ' ') return str.idup;
    size_t p = str.length - 1;
    while (str[p] == ' ') --p;
    return str[0 .. p + 1].idup;
}

/*
 * Number utilities.
 */

// https://en.wikipedia.org/wiki/Exponential-Golomb_coding
//TODO: EXP-GOLOMB UTIL
/// Get a Exp-Golomb-Encoded number
/*ulong expgol(uint n)
{
    return 0;
}*/

/**
 * Get a byte-formatted size.
 * Params: size = Size to format.
 * Returns: Formatted string.
 */
string formatsize(ulong size)
{
    import std.format : format;

    enum : double {
        KB = 1024,
        MB = KB * 1024,
        GB = MB * 1024,
        TB = GB * 1024,
        KiB = 1000,
        MiB = KiB * 1000,
        GiB = MiB * 1000,
        TiB = GiB * 1000
    }

	const double s = size;

	if (Base10)
	{
		if (size > TiB)
            return format("%0.2f TiB", s / TiB);
		else if (size > GiB)
            return format("%0.2f GiB", s / GiB);
		else if (size > MiB)
            return format("%0.2f MiB", s / MiB);
		else if (size > KiB)
            return format("%0.2f KiB", s / KiB);
		else
			return format("%d B", size);
	}
	else
	{
		if (size > TB)
            return format("%0.2f TB", s / TB);
		else if (size > GB)
            return format("%0.2f GB", s / GB);
		else if (size > MB)
            return format("%0.2f MB", s / MB);
		else if (size > KB)
            return format("%0.2f KB", s / KB);
		else
			return format("%d B", size);
	}
}

/**
 * Byte swap a 2-byte number.
 * Params: num = 2-byte number to swap.
 * Returns: Byte swapped number.
 */
ushort bswap(ushort num) pure nothrow @nogc
{
    version (X86) asm pure nothrow @nogc {
        naked;
        xchg AH, AL;
        ret;
    } else version (X86_64) {
        version (Windows) asm pure nothrow @nogc {
            naked;
            mov AX, CX;
            xchg AL, AH;
            ret;
        } else asm pure nothrow @nogc { // System V AMD64 ABI
            naked;
            mov EAX, EDI;
            xchg AL, AH;
            ret;
        }
    } else {
        if (num) {
            ubyte* p = cast(ubyte*)&num;
            return p[1] | p[0] << 8;
        }
    }
}

/**
 * Byte swap a 4-byte number.
 * Params: num = 4-byte number to swap.
 * Returns: Byte swapped number.
 */
uint bswap(uint num) pure nothrow @nogc
{
    version (X86) asm pure nothrow @nogc {
        naked;
        bswap EAX;
        ret;
    } else version (X86_64) {
        version (Windows) asm pure nothrow @nogc {
            naked;
            mov EAX, ECX;
            bswap EAX;
            ret;
        } else asm pure nothrow @nogc { // System V AMD64 ABI
            naked;
            mov RAX, RDI;
            bswap EAX;
            ret;
        }
    } else {
        if (num) {
            ubyte* p = cast(ubyte*)&num;
            return p[3] | p[2] << 8 | p[1] << 16 | p[0] << 24;
        }
    }
}

/**
 * Byte swap a 8-byte number.
 * Params: num = 8-byte number to swap.
 * Returns: Byte swapped number.
 */
ulong bswap(ulong num) pure nothrow @nogc
{
    version (X86) asm pure nothrow @nogc {
        naked;
        xchg EAX, EDX;
        bswap EDX;
        bswap EAX;
        ret;
    } else version (X86_64) {
        version (Windows) asm pure nothrow @nogc {
            naked;
            mov RAX, RCX;
            bswap RAX;
            ret;
        } else asm pure nothrow @nogc { // System V AMD64 ABI
            naked;
            mov RAX, RDI;
            bswap RAX;
            ret;
        }
    } else {
        if (num) {
            ubyte* p = cast(ubyte*)&num;
            ubyte c;
            for (int a, b = 7; a < 4; ++a, --b) {
                c = *(p + b);
                *(p + b) = *(p + a);
                *(p + a) = c;
            }
            return num;
        }
    }
}

/**
 * Turns a 2-byte buffer and transforms it into a 2-byte number.
 * Params: buf = Buffer
 * Returns: 2-byte number
 */
ushort make_ushort(char[] buf) pure
{
    return buf[0] | buf[1] << 8;
}
/**
 * Turns a 4-byte buffer and transforms it into a 4-byte number.
 * Params: buf = Buffer
 * Returns: 4-byte number
 */
uint make_uint(char[] buf) pure
{
    return buf[0] | buf[1] << 8 | buf[2] << 16 | buf[3] << 24;
}

/**
 * Prints an array on screen.
 * Params:
 *   arr = Array pointer
 *   length = Array size
 */
void print_array(void* arr, size_t length)
{
    ubyte* p = cast(ubyte*)arr;
    writef("%02X", p[0]);
    size_t i;
    while (--length) writef("-%02X", p[++i]);
    writeln;
}