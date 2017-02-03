module s_fatelf;

import std.stdio;
import dfile;
import s_elf;

private struct fat_header
{
    uint magic;
    ushort version_;
    ubyte num_records;
    ubyte reserved0;
    //fat_subheader_v1[0] records;
}

private struct fat_subheader_v1
{
    ELF_e_machine machine; /* maps to e_machine. */
    ubyte osabi;         /* maps to e_ident[EI_OSABI]. */ 
    ubyte osabi_version; /* maps to e_ident[EI_ABIVERSION]. */
    ubyte word_size;     /* maps to e_ident[EI_CLASS]. */
    ubyte byte_order;    /* maps to e_ident[EI_DATA]. */
    ubyte reserved0;
    ubyte reserved1;
    ulong offset;
    ulong size;
}

private enum {
    magic = 0x1F0E70FA
}

void scan_fatelf(File file)
{
    fat_header fh;
    {
        import core.stdc.string;
        ubyte[fh.sizeof] buf;
        file.rewind();
        file.rawRead(buf);
        memcpy(&fh, &buf, fh.sizeof);
    }

    if (_showname)
        writef("%s: ", file.name);

    write("FatELF");
    
    switch (fh.version_)
    {
        default:
            write(" with invalid version");
            break;
        case 1: {
            fat_subheader_v1 fhv1;
            {
                import core.stdc.string;
                ubyte[fhv1.sizeof] buf;
                file.rawRead(buf);
                memcpy(&fhv1, &buf, fhv1.sizeof);
            }

            if (fhv1.word_size == 1)
                write(" 32-bit");
            else if (fhv1.word_size == 2)
                write(" 64-bit");

            if (fhv1.byte_order == 1)
                write(" LSB");
            else if (fhv1.word_size == 2)
                write(" MSB");

            write(" ");

            switch (fhv1.osabi)
            {
            default:
                write("System V");
                break;
            case 0x01:
                write("HP-UX");
                break;
            case 0x02:
                write("NetBSD");
                break;
            case 0x03:
                write("Linux");
                break;
            case 0x06:
                write("Solaris");
                break;
            case 0x07:
                write("AIX");
                break;
            case 0x08:
                write("IRIX");
                break;
            case 0x09:
                write("FreeBSD");
                break;
            case 0x0C:
                write("OpenBSD");
                break;
            case 0x0D:
                write("OpenVMS");
                break;
            case 0x0E:
                write("NonStop Kernel");
                break;
            case 0x0F:
                write("AROS");
                break;
            case 0x10:
                write("Fenix OS");
                break;
            case 0x11:
                write("CloudABI");
                break;
            case 0x53:
                write("Sortix");
                break;
            }
                
            write(" binary for ");

            switch (fhv1.machine)
            {
            case ELF_e_machine.EM_NONE:
                write("no");
                break;
            case ELF_e_machine.EM_M32:
                write("AT&T WE 32100 (M32)");
                break;
            case ELF_e_machine.EM_SPARC:
                write("SPARC");
                break;
            case ELF_e_machine.EM_386:
                write("x86");
                break;
            case ELF_e_machine.EM_68K:
                write("Motorola 68000");
                break;
            case ELF_e_machine.EM_88K:
                write("Motorola 88000");
                break;
            case ELF_e_machine.EM_860:
                write("Intel 80860");
                break;
            case ELF_e_machine.EM_MIPS:
                write("MIPS RS3000");
                break;
            case ELF_e_machine.EM_POWERPC:
                write("PowerPC");
                break;
            case ELF_e_machine.EM_ARM:
                write("ARM");
                break;
            case ELF_e_machine.EM_SUPERH:
                write("SuperH");
                break;
            case ELF_e_machine.EM_IA64:
                write("IA64");
                break;
            case ELF_e_machine.EM_AMD64:
                write("x86-64");
                break;
            case ELF_e_machine.EM_AARCH64:
                write("AArch64");
                break;
            default:
                write("unknown");
                break;
            }

            writeln(" machines");
        }
            break;
    }
    
    writeln();
}