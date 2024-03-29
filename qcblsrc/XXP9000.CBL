       IDENTIFICATION DIVISION.
     �*
         PROGRAM-ID.              XXP9000.
           COPY COPYRIGHT  OF APG-QCPYSRC.
     �*
     �*---------------------------------------------------------------*
     �* FEHLERAFTES PGM F�R FALSCHEN PARAMETER AUFRUF                 *
     �*---------------------------------------------------------------*
     �*                                                               *
     �* AUTOR         :  A. PIEGER                                    *
     �*                                                               *
     �* ERSTELLT AM   :  15.10.2009                                   *
     �*                                                               *
     �* FUNKTION      :  FEHLERHAFTES BEISPIEL-PGM�!!!�               *
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

       01  PARM-WRK1                     PIC X(50).
       01  PARM-WRK2                     PIC X(50).
      /
     �*-------------------------------------------------------------
       LINKAGE SECTION.
     �*-------------------------------------------------------------
       PROCEDURE DIVISION.
     �*-------------------------------------------------------------
       STEUER SECTION.
       ANFANG.

     �* IN XXP9001 SIND ALLE PARAMETER 1000 ZEICHEN GRO� (=3000)
           MOVE     "HALLO" TO PARM-WRK1.
           MOVE     "#"     TO PARM-WRK1(50:1).
           MOVE     "WELT"  TO PARM-WRK2.
           CALL     "XXP9001" USING PARM-WRK1
                                    PARM-WRK2
           END-CALL.

     �* MIT DEM CANCEL WIRD DAF�R GESORGT, DAS BEIM N�CHSTEN AUFRUF
     �* ALLE WERTE INITIALISIERT SIND
           CANCEL   "XXP9001".

       ENDE.

           GOBACK.
      /
