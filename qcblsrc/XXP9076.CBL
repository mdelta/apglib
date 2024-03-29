       IDENTIFICATION DIVISION.
     *
         PROGRAM-ID.              XXP9076.
           COPY COPYRIGHT  OF APG-QCPYSRC.
     *
     *---------------------------------------------------------------*
     * LOW-VALUE/HIGH VALUE                                          *
     *---------------------------------------------------------------*
     *                                                               *
     * AUTOR         :  A. PIEGER                                    *
     *                                                               *
     * ERSTELLT AM   :  13.01.2015                                   *
     *                                                               *
     * FUNKTION      :  TEST PROGRAM                                 *
     *                                                               *
     * ΔNDERUNGEN:                                                   *
     * DATUM      VON   GRUND DER ΔNDERUNG                           *
     *                                                               *
     *****************************************************************
     *
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

     * STANDARDFELDER
           COPY WRKSTD      OF APG-QCPYSRC.

       01  PGM-WRK                        PIC X(10) VALUE "XXP9076".

       01  VARIABLE1                      PIC X(20).
       01  VARIABLE2                 LIKE VARIABLE1 (+5).
      /
     *-------------------------------------------------------------
       LINKAGE SECTION.
     *-------------------------------------------------------------

     *-------------------------------------------------------------
       PROCEDURE DIVISION.
     *-------------------------------------------------------------
       STEUER SECTION.
       ANFANG.

       ENDE.
           GOBACK.
      /
