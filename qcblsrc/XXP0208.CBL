       IDENTIFICATION DIVISION.
     �*
         PROGRAM-ID.              XXP0208.
           COPY COPYRIGHT  OF APG-QCPYSRC.
     �*
     �*---------------------------------------------------------------*
     �* L�SCHEN EINER BESTELLUNG                                      *
     �*---------------------------------------------------------------*
     �*                                                               *
     �* AUTOR         :  A. PIEGER                                    *
     �*                                                               *
     �* ERSTELLT AM   :  11.03.2010                                   *
     �*                                                               *
     �* FUNKTION      :  L�SCHEN EINER BESTELLUNG                     *
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

     �*-------------------------------------------------------------
     �* PHYSISCHE DATEI BESTELLUNGEN
     �*-------------------------------------------------------------
           SELECT PKDBST1-DP
                  ASSIGN       TO  DATABASE-PKDBST1
                  ORGANIZATION IS  INDEXED
                  RECORD KEY   IS  EXTERNALLY-DESCRIBED-KEY
                  ACCESS       IS  DYNAMIC
                  FILE STATUS  IS  FILE-STATUS.

      /
       DATA DIVISION.
       FILE SECTION.
     �*--- PKDBST1: KBLFDN
       FD  PKDBST1-DP
           LABEL RECORDS ARE STANDARD.
       01  PKDBST1-P.
           COPY DDS-ALL-FORMATS OF PKDBST1.
      /
       WORKING-STORAGE SECTION.

     �* STANDARDFELDER
           COPY WRKSTD      OF APG-QCPYSRC.

       01  PGM-WRK                       PIC X(10) VALUE "XXP0208".
       01  PGM-TYP                       PIC X(8)  VALUE "PLANUNG".

     �* PARAMETER F�R DAS CFP8100
       01  PARCHIV-WRK.
            COPY DDS-ALL-FORMATS OF PARCHIV.
       01  LIB-WRK                       LIKE HSLIB  OF PARCHIV-WRK.
       01  FILE-WRK                      LIKE HSFILE OF PARCHIV-WRK.
      /
     �*-------------------------------------------------------------
       LINKAGE SECTION.
       01  X-KBLFDN                      LIKE KBLFDN OF PKDBST1-P.
     �*-------------------------------------------------------------

     �*-------------------------------------------------------------
       PROCEDURE DIVISION USING X-KBLFDN.
     �*-------------------------------------------------------------
       STEUER SECTION.
       ANFANG.

     �* F�LLEN PGM-WRK UND AUSF�HREN STANDARDROUTINEN
           MOVE     "XXP0208" TO PGM-WRK.
           PERFORM  COPY-PGM-INIT.

           OPEN     I-O   PKDBST1-DP.

     �* DARF DIESES PROGRAMM BENUTZT WERDEN?
           PERFORM  COPY-PERMISSION.
           IF       RET-CODE NOT = SPACES
                    GO TO ENDE
           END-IF.

     �* ALLE PARAMETER VORHANDEN?
           IF       X-KBLFDN = ZEROES
                    GO TO ENDE
           END-IF.

     �* ERST L�SCHEN DES PROGRAMM, DANN DIE TAGS
           PERFORM  DELETE-RECORD.

       ENDE.
           CLOSE                 PKDBST1-DP.

           PERFORM  COPY-PGM-EXIT.

           GOBACK.
      /
     �*--------------------------------------------------------------
     �* L�SCHEN DES DATENSATZES
     �*--------------------------------------------------------------
       DELETE-RECORD SECTION.
       DEL-REC-00.

     �* DATENSATZ L�SCHEN
           INITIALIZE PKDBST1F OF PKDBST1-P.
           MOVE     X-KBLFDN            TO KBLFDN OF PKDBST1-P.
           READ     PKDBST1-DP.
           IF       FILE-STATUS = ZEROES
                    DELETE   PKDBST1-DP
     �*             L�SCHEN PROTOKOLLIEREN
                    MOVE     CONST-LIB   TO LIB-WRK
                    MOVE     "PKDBST1"   TO FILE-WRK
                    MOVE     PKDBST1-P   TO RECORD-WRK
                    CALL     "CFP8100" USING LIB-WRK
                                             FILE-WRK
                                             PGM-WRK
                                             RECORD-WRK
                    END-CALL
           END-IF.

       DEL-REC-90.
           EXIT.
      /
     �*---------------------------------------------------------------
     �* COPY-PERMISSION: BERECHTIGUNGSPR�FUNG
     �*---------------------------------------------------------------

           COPY     PERMISSION OF APG-QCPYSRC.
      /
     �*---------------------------------------------------------------
     �* COPY-PGM-INIT/COPY-PGM-EXIT: STANDARDROUTINEN START UND ENDE
     �*---------------------------------------------------------------

           COPY     PGMWRK     OF APG-QCPYSRC.
      /
