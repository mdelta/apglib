       IDENTIFICATION DIVISION.
     �*
         PROGRAM-ID.              CFP0019.
           COPY COPYRIGHT  OF APG-QCPYSRC.
     �*
     �*---------------------------------------------------------------*
     �* SCHREIBEN EINES LOG-EINTRAGS                                  *
     �*---------------------------------------------------------------*
     �*                                                               *
     �* AUTOR         :  A. PIEGER                                    *
     �*                                                               *
     �* ERSTELLT AM   :  15.10.2009                                   *
     �*                                                               *
     �* FUNKTION      :  SCHREIBEN EINES NEUEN LOG-EINTRAGS           *
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
     �* PCFGSTS: STLFDN
     �*-------------------------------------------------------------
           SELECT PCFGSTS-DP
                  ASSIGN       TO  DATABASE-PCFGSTS
                  ORGANIZATION IS  INDEXED
                  RECORD KEY   IS  EXTERNALLY-DESCRIBED-KEY
                  ACCESS       IS  DYNAMIC
                  FILE STATUS  IS  FILE-STATUS.

      /
       DATA DIVISION.
       FILE SECTION.
     �*--- PCFGSTS: STLFDN
       FD  PCFGSTS-DP
           LABEL RECORDS ARE STANDARD.
       01  PCFGSTS-P.
           COPY DDS-ALL-FORMATS OF PCFGSTS.
      /
       WORKING-STORAGE SECTION.

     �* STANDARDFELDER
           COPY WRKSTD      OF APG-QCPYSRC.

     �* WORKBEREICH LOG-CPY
           COPY WRKLOGCPY   OF APG-QCPYSRC.

       01  PGM-WRK                       PIC X(10) VALUE "CFP0019".

     �* PARAMETER F�R DAS CFP0028
       01  OPL-TYPE                      PIC X(10).
     �*-------------------------------------------------------------
       LINKAGE SECTION.
       01  X-LOG-CPY                     LIKE LOG-CPY.
       01  X-PGM                         LIKE PGM-WRK.
     �*-------------------------------------------------------------

     �*-------------------------------------------------------------
       PROCEDURE DIVISION USING X-LOG-CPY
                                X-PGM.
     �*-------------------------------------------------------------
       STEUER SECTION.
       ANFANG.

     �* F�LLEN PGM-WRK UND AUSF�HREN STANDARDROUTINEN
           MOVE     "CFP0019" TO PGM-WRK.
           PERFORM  COPY-PGM-INIT.

           OPEN     I-O   PCFGSTS-DP.

           INITIALIZE PCFGSTSF OF PCFGSTS-P.
           MOVE     X-LOG-CPY TO PCFGSTSF OF PCFGSTS-P.

     �* PROGRAMM NUR F�LLEN WENN NOCH NICHT GEF�LLT
           IF       STAPGM OF PCFGSTS-P = SPACES
                    IF   X-PGM = SPACES
                         MOVE PGM-WRK    TO STLPGM OF PCFGSTS-P
                    ELSE
                         MOVE X-PGM      TO STLPGM OF PCFGSTS-P
                    END-IF
           END-IF.

     �* USER/TERMINAL NUR F�LLEN WENN NOCH NICHT GEF�LLT
           IF       STAUSR OF PCFGSTS-P = SPACES
            OR      STABS  OF PCFGSTS-P = SPACES
                    MOVE T-USER          TO STLUSR OF PCFGSTS-P
                    MOVE T-TERM          TO STLBS  OF PCFGSTS-P
           END-IF.

     �* DATUM/UHRZEIT ERMITTELN
           PERFORM  COPY-GET-TIME.
     �* DATUM/UHRZEIT NUR F�LLEN WENN NOCH NICHT GEF�LLT
           IF       STADTA OF PCFGSTS-P = ZEROES
            OR      STATIA OF PCFGSTS-P = ZEROES
                    MOVE DATE-8          TO STLDTA OF PCFGSTS-P
                    MOVE TIME-6          TO STLTIA OF PCFGSTS-P
           END-IF.

     �* ANLAGEDATEN F�LLEN
           MOVE     PGM-WRK         TO STAPGM OF PCFGSTS-P.
           MOVE     T-USER          TO STAUSR OF PCFGSTS-P.
           MOVE     T-TERM          TO STABS  OF PCFGSTS-P.
           MOVE     DATE-8          TO STADTA OF PCFGSTS-P.
           MOVE     TIME-6          TO STATIA OF PCFGSTS-P.

     �* KEY F�LLEN
           INITIALIZE LFDN-ID, LFDN-WRK.
           MOVE     "PCFGSTS" TO LFDN-ID.
           CALL     "CFP0020" USING LFDN-ID
                                    LFDN-WRK
           END-CALL.
           MOVE     LFDN-WRK        TO STLFDN OF PCFGSTS-P.

           WRITE    PCFGSTS-P.
     �* DATENSATZ GGF. IN DIE POPLLST �BERNEHMEN
           IF       FILE-STATUS             = ZEROES
            AND     STTID  OF PCFGSTS-P NOT = SPACES
                    MOVE "LOG" TO OPL-TYPE
                    CALL "CFP0028" USING STLFDN OF PCFGSTS-P
                                         OPL-TYPE
                    END-CALL
           END-IF.

       ENDE.
           CLOSE                 PCFGSTS-DP.

           PERFORM  COPY-PGM-EXIT.

           GOBACK.
      /
     �*---------------------------------------------------------------
     �* COPY-GET-TIME: DATUM UND UHRZEIT ERMITTELN
     �*---------------------------------------------------------------

           COPY     GETTIME    OF APG-QCPYSRC.
      /
     �*---------------------------------------------------------------
     �* COPY-PGM-INIT/COPY-PGM-EXIT: STANDARDROUTINEN START UND ENDE
     �*---------------------------------------------------------------

           COPY     PGMWRK     OF APG-QCPYSRC.
      /
