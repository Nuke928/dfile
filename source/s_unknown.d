/*
 * s_unknown.d : Unknown file formats (with offset)
 */

module s_unknown;

import std.stdio;
import dfile;

//private enum BYTE_LIMIT = 1024 * 16;

static void scan_unknown(File file)
{
    import core.stdc.string : memcpy;
    // Scan by offsets.

    //ulong fs = file.tell;

    { // Tar files
        enum Tar = "usta";
        char[4] b;
        file.seek(0x101);
        file.rawRead(b);
        if (b == Tar)
        {
            report("Tar file");
            return;
        }
    }
    
    { // ISO files
        enum ISO = "CD001";
        char[5] b0, b1, b2;
        file.seek(0x8001);
        file.rawRead(b0);
        file.seek(0x8801);
        file.rawRead(b1);
        file.seek(0x9001);
        file.rawRead(b2);
        if (b0 == ISO || b1 == ISO || b2 == ISO)
        {
            report("ISO9660 CD/DVD image file (ISO)");
            return;
        }
    }

    { // Palm Database Format
        import s_mobi;
        enum { // 4 bytes for type, 4 bytes for creator
            ADOBE =      ".pdfADBE",
            BOOKMOBI =   "BOOKMOBI",
            PALMDOC =    "TEXtREAd",
            BDICTY =     "BVokBDIC",
            DB =         "DB99DBOS",
            EREADER0 =   "PNRdPPrs",
            EREADER1 =   "DataPPrs",
            FIREVIEWER = "vIMGView",
            HANDBASE =   "PmDBPmDB",
            INFOVIEW =   "InfoINDB",
            ISILO =      "ToGoToGo",
            ISILO3 =     "SDocSilX",
            JFILE =      "JbDbJBas",
            JFILEPRO =   "JfDbJFil",
            LIST =       "DATALSdb",
            MOBILEDB =   "Mdb1Mdb1",
            PLUCKER =    "DataPlkr",
            QUICKSHEET = "DataSprd",
            SUPERMEMO =  "SM01SMem",
            TEALDOC =    "TEXtTlDc",
            TEALINFO =   "InfoTlIf",
            TEALMEAL =   "DataTlMl",
            TEALPAINT =  "DataTlPt",
            THINKDB =    "dataTDBP",
            TIDES =      "TdatTide",
            TOMERAIDER = "ToRaTRPW",
            WEASEL =     "zTXTGPlm",
            WORDSMITH =  "BDOCWrdS"
        }
        char[8] b;
        file.seek(0x3C);
        file.rawRead(b);
        switch (b)
        {
            case ADOBE:
                report("Palm Database (Adobe Reader)", false);
                palmdb_name(file);
                break;
            case BOOKMOBI:
                scan_mobi(file);
                return;
            case PALMDOC:
                scan_palmdoc(file);
                break;
            case BDICTY:
                report("Palm Database (BDicty)", false);
                palmdb_name(file);
                break;
            case DB:
                report("Palm Database (DB)", false);
                palmdb_name(file);
                break;
            case EREADER0:
            case EREADER1:
                report("Palm Database (eReader)", false);
                palmdb_name(file);
                break;
            case FIREVIEWER:
                report("Palm Database (FireViewer)", false);
                palmdb_name(file);
                break;
            case HANDBASE:
                report("Palm Database (HanDBase)", false);
                palmdb_name(file);
                break;
            case INFOVIEW:
                report("Palm Database (InfoView)", false);
                palmdb_name(file);
                break;
            case ISILO:
                report("Palm Database (iSilo)", false);
                palmdb_name(file);
                break;
            case ISILO3:
                report("Palm Database (iSilo 3)", false);
                palmdb_name(file);
                break;
            case JFILE:
                report("Palm Database (JFile)", false);
                palmdb_name(file);
                break;
            case JFILEPRO:
                report("Palm Database (JFile Pro)", false);
                palmdb_name(file);
                break;
            case LIST:
                report("Palm Database (LIST)", false);
                palmdb_name(file);
                break;
            case MOBILEDB:
                report("Palm Database (MobileDB)", false);
                palmdb_name(file);
                break;
            case PLUCKER:
                report("Palm Database (Plucker)", false);
                palmdb_name(file);
                break;
            case QUICKSHEET:
                report("Palm Database (QuickSheet)", false);
                palmdb_name(file);
                break;
            case SUPERMEMO:
                report("Palm Database (SuperMemo)", false);
                palmdb_name(file);
                break;
            case TEALDOC:
                report("Palm Database (TealDoc)", false);
                palmdb_name(file);
                break;
            case TEALINFO:
                report("Palm Database (TealInfo)", false);
                palmdb_name(file);
                break;
            case TEALMEAL:
                report("Palm Database (TealMeal)", false);
                palmdb_name(file);
                break;
            case TEALPAINT:
                report("Palm Database (TailPaint)", false);
                palmdb_name(file);
                break;
            case THINKDB:
                report("Palm Database (ThinKDB)", false);
                palmdb_name(file);
                break;
            case TIDES:
                report("Palm Database (Tides)", false);
                palmdb_name(file);
                break;
            case TOMERAIDER:
                report("Palm Database (TomeRaider)", false);
                palmdb_name(file);
                break;
            case WEASEL:
                report("Palm Database (Weasel)", false);
                palmdb_name(file);
                break;
            case WORDSMITH:
                report("Palm Database (WordSmith)", false);
                palmdb_name(file);
                break;

            default: // Continue the journey
        }
    }
    
    report_unknown();

    //TODO: Scan for readable characters for n (16KB?) bytes and at least n
    //      (3?) readable characters.
}