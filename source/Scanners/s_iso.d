/*
 * s_iso.d : ISO file scanner
 */

module s_iso;

import std.stdio, dfile, utils;

enum ISO = "CD001";

void scan_iso(File file)
{
    enum { // volume type
        BOOT = 0,
        PRIMARY_VOL_DESC,
        /*SUPP_VOL_DESC,
        VOL_PART_DESC,
        VOL_TER = 255*/
    }
    enum s = 1024; // Half the data
    ulong fs = file.size;
    long volume_size;
    int t;
    char[s] buf;
    bool bootable;
    /*
     * ISO strings
     */
        // PRIMARY_VOL_DESC
    string label,
        system, voliden,
        copyright, publisher, app, abst, biblio,
        ctime, mtime, etime, eftime,
        // BOOT
        bootsysiden, bootiden;
    file.seek(0x8000);
    goto ISO_READ;
ISO_P0:
    if (fs < 0x8800) goto ISO_END;
    file.seek(0x8800);
    goto ISO_READ;
ISO_P1:
    if (fs < 0x9000) goto ISO_END;
    file.seek(0x9000);
ISO_READ:
    file.rawRead(buf);
    if (buf[1..6] == ISO)
        switch (buf[0])
        {
            case BOOT:
                bootable = true;
                if (More)
                {
                    bootsysiden = isostr(buf[7 .. 39]);
                    bootiden = isostr(buf[39 .. 71]);
                }
                break;
            case PRIMARY_VOL_DESC:
                label = isostr(buf[40 .. 71]);
                uint size = make_uint(buf[80..84]);
                ushort blocksize = make_ushort(buf[128..130]);
                volume_size = size * blocksize;
                if (More)
                {
                    system = isostr(buf[8 .. 40]);
                    voliden = isostr(buf[190 .. 318]);
                    publisher = isostr(buf[318 .. 446]);
                    app = isostr(buf[574 .. 702]);
                    copyright = isostr(buf[702 .. 739]);
                    abst = isostr(buf[739 .. 776]);
                    biblio = isostr(buf[776 .. 813]);
                    ctime = isostr(buf[813 .. 830]);
                    mtime = isostr(buf[830 .. 847]);
                    etime = isostr(buf[847 .. 864]);
                    eftime = isostr(buf[864 .. 881]);
                }
                break;
            default:
        }
    switch (t++) // Dumb system but hey, good stuff.
    {
        case  0: goto ISO_P0;
        case  1: goto ISO_P1;
        default: goto ISO_END;
    }
ISO_END:
    report("ISO-9660 CD/DVD image", false);
    if (label)
        write(` "`, label, `"`);
    if (volume_size)
        write(", ", formatsize(volume_size));
    if (bootable)
        write(", Bootable");
    writeln();

    if (More)
    {
        writeln("Boot System Identifier: ", bootsysiden);
        writeln("Boot Identifier: ", bootiden);
        writeln("System: ", system);
        writeln("Volume Set Indentifier: ", voliden);
        writeln("Publisher: ", publisher);
        writeln("Copyrights: ", copyright);
        writeln("Application: ", app);
        writeln("Abstract Identifier: ", abst);
        writeln("Bibliographic: ", biblio);
        writeln("Created: ", isodate(ctime));
        writeln("Modified: ", isodate(mtime));
        writeln("Expires: ", isodate(etime));
        writeln("Effective at: ", isodate(eftime));
    }
}

string isodate(string stamp)
{
    import std.format : format;
    return format("%s/%s/%s %s:%s:%s.%s+%d",
        stamp[0..4], stamp[4..6], stamp[6..8],
        stamp[8..10], stamp[10..12], stamp[12..14], stamp[14..16], stamp[16] * 15);
}