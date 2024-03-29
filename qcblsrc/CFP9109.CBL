       IDENTIFICATION DIVISION.
     *
         PROGRAM-ID.              CFP9109.
           COPY COPYRIGHT  OF APG-QCPYSRC.
     *
     *---------------------------------------------------------------*
     * ABMELDEN EINES USERS                                          *
     *---------------------------------------------------------------*
     *                                                               *
     * AUTOR         :  A. PIEGER                                    *
     *                                                               *
     * ERSTELLT AM   :  13.08.2009                                   *
     *                                                               *
     * FUNKTION      :  ABMELDEN                                     *
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

       01  PGM-WRK                       PIC X(10) VALUE "CFP9109".
       01  PGM-TYP                       PIC X(8)  VALUE "CONFIG".

      /
     *-------------------------------------------------------------
       LINKAGE SECTION.
     *-------------------------------------------------------------
       PROCEDURE DIVISION.
     *-------------------------------------------------------------
       STEUER SECTION.
       ANFANG.

     * FάLLEN PGM-WRK
           MOVE     "CFP9109 " TO PGM-WRK.
           PERFORM  COPY-PGM-INIT.

           CALL     "CLP0014"
           END-CALL.
           CALL     "CLP0015"
           END-CALL.

       ENDE.
           PERFORM  COPY-PGM-EXIT.

           GOBACK.
      /
     *---------------------------------------------------------------
     * COPY-PGM-INIT/COPY-PGM-EXIT: STANDARDROUTINEN START UND ENDE
     *---------------------------------------------------------------

           COPY     PGMWRK     OF APG-QCPYSRC.
      /
