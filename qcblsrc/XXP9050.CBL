       IDENTIFICATION DIVISION.
     �*
         PROGRAM-ID.              XXP9050.
           COPY COPYRIGHT  OF APG-QCPYSRC.
     �*
     �*---------------------------------------------------------------*
     �* TESTPROGRAMM                                                  *
     �*---------------------------------------------------------------*
     �*                                                               *
     �* AUTOR         :  A. PIEGER                                    *
     �*                                                               *
     �* ERSTELLT AM   :  17.10.2012                                   *
     �*                                                               *
     �* FUNKTION      :  TEST-PGM                                     *
     �*                                                               *
     �* �NDERUNGEN:                                                   *
     �* DATUM      VON   GRUND DER �NDERUNG                           *
     �*                                                               *
     �*****************************************************************
     �*
       ENVIRONMENT DIVISION.
        CONFIGURATION SECTION.
         SOURCE-COMPUTER.         IBM-AS400.
         OBJECT-COMPUTER.         IBM-AS400.
        SPECIAL-NAMES. , DECIMAL-POINT IS COMMA.
      /
       INPUT-OUTPUT SECTION.
         FILE-CONTROL.
      /
       DATA DIVISION.
       FILE SECTION.
      /
       WORKING-STORAGE SECTION.

     �* STANDARDFELDER
           COPY WRKSTD     OF APG-QCPYSRC.

       01  PGM-WRK                       PIC X(10) VALUE "XXP9050".
       01  PGM-TYP                       PIC X(8)  VALUE "TEST".

       01  STRING-WRK                     PIC X(20).
      /
     �*-------------------------------------------------------------
       LINKAGE SECTION.
     �*-------------------------------------------------------------
       PROCEDURE DIVISION.
     �*-------------------------------------------------------------
       STEUER SECTION.
       ANFANG.

     �* F�LLEN PGM-WRK UND AUSF�HREN STANDARDROUTINEN
           MOVE     "XXP9050"   TO PGM-WRK.
           PERFORM  COPY-PGM-INIT.

           MOVE     "���" TO STRING-WRK.
           INSPECT  STRING-WRK CONVERTING "���" TO "EES".
     �*�   INSPECT  STRING-WRK CONVERTING "�" TO "E".
     �*�   INSPECT  STRING-WRK CONVERTING "�" TO "E".
     �*�   INSPECT  STRING-WRK CONVERTING "�" TO "S".

       ENDE.
           PERFORM  COPY-PGM-EXIT.

           GOBACK.
      /
     �*---------------------------------------------------------------
     �* COPY-PGM-INIT/COPY-PGM-EXIT: STANDARDROUTINEN START UND ENDE
     �*---------------------------------------------------------------

           COPY     PGMWRK     OF APG-QCPYSRC.
      /
