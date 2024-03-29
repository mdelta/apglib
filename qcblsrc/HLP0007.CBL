       IDENTIFICATION DIVISION.
     �*
         PROGRAM-ID.             HLP0007.
           COPY COPYRIGHT  OF APG-QCPYSRC.
     �*
     �*---------------------------------------------------------------*
     �* DIREKTES E-MAIL VERSENDEN �BER SMTP                           *
     �*---------------------------------------------------------------*
     �*                                                               *
     �* AUTOR         :  U. BENNER / L. SCZECH                        *
     �*                                                               *
     �* ERSTELLT AM   :  22.09.2009                                   *
     �*                                                               *
     �* FUNKTION      :  EMAIL �BER SMTP SENDEN (P3 18695)            *
     �*                                                               *
     �* �NDERUNGEN:                                                   *
     �* DATUM      VON   GRUND DER �NDERUNG                           *
##APG�* 02.10.2009 APG   �NDERN AUF APG-COPYMODULE UND ROUTINEN       *
     �*                                                               *
     �*****************************************************************
     �*
       ENVIRONMENT DIVISION.
        CONFIGURATION SECTION.
        SPECIAL-NAMES. , DECIMAL-POINT IS COMMA.
      /
       INPUT-OUTPUT SECTION.
         FILE-CONTROL.
       DATA DIVISION.
       FILE SECTION.

      /
       WORKING-STORAGE SECTION.

     �* STANDARDFELDER
           COPY WRKSTD      OF APG-QCPYSRC.

       01  PGM-WRK                       PIC X(10) VALUE "HLP0007".
       01  PGM-TYP                       PIC X(8)  VALUE "EMAIL   ".

     �* ANGABEN F�R L�NGEN
       01  LEN                 PIC 9(9).
       01  LEN-IN              PIC 9(9) BINARY.
       01  LEN-OUT             PIC 9(9) BINARY.
       01  SEND-LEN            PIC 9(9) BINARY.

     �* L�NGEN DER �BERGABEPARAMETER
       01  SENDER-LEN          PIC 9(2).
       01  TOPIC-LEN           PIC 9(2).
       01  DATA-LEN            PIC 9(3).

     �* VARIABLEN F�R LGTCPIO
       01  WRK-RECORD          PIC X(16710680).
       01  WRK-RECORD-FILE     PIC X(16710680).
       01  TCP-SOCK            PIC S9(9) BINARY VALUE -1.
       01  TCP-ACTION          PIC X(1) VALUE " ".
       01  TCP-BUFLEN          PIC 9(9) BINARY VALUE 0.
       01  TCP-DELIM           PIC X(24) VALUE X'0D0A'.
       01  TCP-DELIMLEN        PIC 9(9) BINARY VALUE 2.
       01  TCP-TIMEOUT         PIC 9(9) BINARY VALUE ZEROES.
       01  TCP-RETTXT          PIC X(10).
     �* PUFFER F�R "HOST:PORT"
       01  HOSTBUFFER          PIC X(30).
     �* GESAMTL�NGE ALLER GESENDETER DATEN
       01  RECORD-SIZE         PIC 9(9).

     �* DUMMY-FELDER ZUM DEFINIEREN MIT LIKE
       01  ADRLEN-DUMMY        PIC X(30).
       01  LEN-DUMMY           PIC 9(3).

     �* VARIABLEN F�R STRINGKONVERTIERUNG
       01  INT-LEN-IN          PIC S9(9) BINARY.
       01  INT-LEN-OUT         PIC S9(9) BINARY.
       01  BASE-LEN-IN         PIC S9(9) BINARY.
       01  BASE-LEN-OUT        PIC S9(9) BINARY.
       01  CCSID-IN            PIC 9(5).
       01  CODE-PAGE           PIC 9(5).
       01  NO-CONVERT          PIC 9(1).
       01  BASE64-AKTION       PIC X(1) VALUE "0".
       01  KEINE-ANTWORT       PIC X(1).
       01  EBC-ASCII           PIC X(1).
       01  RET-TXT             PIC X(1).
       01  FILE-WRK            PIC X(256).
       01  SENDER-OK           PIC X(1).
       01  LETZTER-DATENSATZ   PIC X(1).

     �* POINTER F�R DIE INTERNEN TABELLEN
       01  POS-TAB             PIC 9(2).

     �* INTERNE TABELLE F�R DIE EMPF�NGER-ADRESSE
       01  EMPF-TAB.
        05 EMPFAENG-REC          OCCURS 10 TIMES.
          10 ADRESSE        LIKE ADRLEN-DUMMY.
          10 ADRLEN         LIKE LEN-DUMMY.
     �* INTERNE TABELLE F�R DIE KOPIE-ADRESSE
       01  KOPIE-TAB.
        05 KOPIE-REC             OCCURS 10 TIMES.
          10 ADRESSE        LIKE ADRLEN-DUMMY.
          10 ADRLEN         LIKE LEN-DUMMY.
     �* INTERNE TABELLE F�R DIE BLINDKOPIEKOPIE-ADRESSE
       01  BKOPIE-TAB.
        05 BKOPIE-REC            OCCURS 10 TIMES.
          10 ADRESSE        LIKE ADRLEN-DUMMY.
          10 ADRLEN         LIKE LEN-DUMMY.
     �*-------------------------------------------------------
       LINKAGE SECTION.
       01  X-HOST                PIC X(15).
       01  X-PORT                PIC X(5).
       01  X-SENDER              PIC X(30).
     �*�INFO ZU DEN �BERGABEPARAMTERN:                     �*�
     �*�IN X-ANZAHL STEHT DIE ANZAHL DER DATENS�TZE F�R DIE�*�
     �*�JEWEILIGE TABELLE.                                 �*�
     �*�01 RECORD                                          �*�
     �*�  05 X-ANZAL                                       �*�
     �*�  05 X-TABELLE                                     �*�
     �*�     10 X-ADRESSE                                  �*�
     �* �BERNAHME DER EMPF�NGER                             *
       01  X-EMPF.
        05 X-ANZAHL              PIC 9(2) BINARY.
        05 X-EMPF-REC            OCCURS 10 TIMES.
          10 X-ADRESSE      LIKE ADRLEN-DUMMY.
     �* �BERNAHME DER KOPIEADRESSEN
       01  X-KOPIE.
        05 X-ANZAHL              PIC 9(2) BINARY.
        05 X-KOPIE-REC           OCCURS 10 TIMES.
          10 X-ADRESSE      LIKE ADRLEN-DUMMY.
     �* �BERNAHME DER BLINDKOPIEADRESSEN
       01  X-BKOPIE.
        05 X-ANZAHL              PIC 9(2) BINARY.
        05 X-BKOPIE-REC          OCCURS 10 TIMES.
          10 X-ADRESSE      LIKE ADRLEN-DUMMY.
       01  X-TOPIC               PIC X(30).
       01  X-DATA                PIC X(500).
       01  X-FILE           LIKE FILE-WRK.
     �* IM RETTXT STEHT DIE R�CKMELDUNG DES SERVERS, FALLS
     �* DIESE NEGATIV WAR
       01  X-RETTXT              PIC X(256).
     �*-------------------------------------------------------
       PROCEDURE DIVISION USING  X-HOST
                                 X-PORT
                                 X-SENDER
                                 X-EMPF
                                 X-KOPIE
                                 X-BKOPIE
                                 X-TOPIC
                                 X-DATA
                                 X-FILE
                                 X-RETTXT.
     �*-------------------------------------------------------
       STEUER SECTION.
       ANFANG.

     �* F�LLEN PGM-WRK UND AUSF�HREN STANDARDROUTINEN
           MOVE     "HLP0007" TO PGM-WRK.
           PERFORM  COPY-PGM-INIT.

     �* DARF DIESES PROGRAMM BENUTZT WERDEN?
           PERFORM  COPY-PERMISSION.
           IF       RET-CODE NOT = SPACES
                    GO TO ENDE
           END-IF.

     �* CLEAREN ALLER VARIABLEN / TABELLEN
           INITIALIZE LEN.
           INITIALIZE LEN-IN.
           INITIALIZE LEN-OUT.
           INITIALIZE SEND-LEN.
           INITIALIZE SENDER-LEN.
           INITIALIZE TOPIC-LEN.
           INITIALIZE DATA-LEN.
           INITIALIZE TCP-RETTXT.
           INITIALIZE HOSTBUFFER.
           INITIALIZE RECORD-SIZE.
           INITIALIZE INT-LEN-IN.
           INITIALIZE INT-LEN-OUT.
           INITIALIZE BASE-LEN-IN.
           INITIALIZE BASE-LEN-OUT.
           INITIALIZE CCSID-IN.
           INITIALIZE CODE-PAGE.
           INITIALIZE NO-CONVERT.
           INITIALIZE KEINE-ANTWORT.
           INITIALIZE EBC-ASCII.
           INITIALIZE RET-TXT.
           INITIALIZE FILE-WRK.
           INITIALIZE POS-TAB.
           INITIALIZE SENDER-OK.
           INITIALIZE LETZTER-DATENSATZ.
           PERFORM  LOESCHEN-TABELLEN.

     �* DATEN AUS DER �BERGABETABELLE IN EINE WRK-TABELLE
     �* �BERNEHMEN
           PERFORM  UEBERNEHME-ADRESSEN.

     �* PR�FEN, OB ALLE BEN�TIGTEN VARIABLEN B�ERGEBEN WURDEN
           IF       X-HOST                 = SPACES
            OR      X-PORT                 = SPACES
            OR      X-SENDER               = SPACES
            OR      ADRESSE OF EMPF-TAB(1) = SPACES
            OR      X-DATA                 = SPACES
            OR      X-TOPIC                = SPACES
                    MOVE "DATEN UNVOLLST�NDIG" TO X-RETTXT
                    DISPLAY X-RETTXT
                    CALL "PAUSE1"
                    GO TO ENDE
           END-IF.

     �* L�NGE DER �BERGEBENEN VARIABLEN ERMITTELN
           PERFORM  ERM-LAENGE.

     �* ZUSAMMENSETZEN DER HOSTADRESSE + HOST (HOST:PORT)
           MOVE     1 TO LEN.
           STRING   X-HOST               DELIMITED BY SPACE
                    ":"                  DELIMITED BY SIZE
                    X-PORT               DELIMITED BY SPACE
                    INTO HOSTBUFFER WITH POINTER LEN
           END-STRING.

     �* ZUM MAILSERVER VERBINDEN
           MOVE     5   TO TCP-TIMEOUT.
           MOVE     "0" TO TCP-ACTION.
           MOVE     LEN TO TCP-BUFLEN.
           INITIALIZE TCP-RETTXT.
           CALL     PROCEDURE "LGTCPIO"  USING TCP-SOCK
                                               TCP-ACTION
                                               HOSTBUFFER
                                               TCP-BUFLEN
                                               TCP-DELIM
                                               TCP-DELIMLEN
                                               TCP-TIMEOUT
                                               TCP-RETTXT
           END-CALL.
           IF       TCP-RETTXT > SPACE
                    GO TO ENDE
           END-IF.

     �* MAILSERVER IDENTIFIZIEREN
           MOVE     1 TO SEND-LEN.
           STRING   "EHLO "  DELIMITED BY SIZE
                    "'"      DELIMITED BY SIZE
                    X-HOST   DELIMITED BY " "
                    "'"      DELIMITED BY SIZE
                    INTO WRK-RECORD  WITH POINTER SEND-LEN
           END-STRING.
           PERFORM  SENDEN-STRING.
           IF       X-RETTXT > SPACES
                    GO TO ANF090
           END-IF.

     �* EMAIL SENDER
           MOVE     1 TO SEND-LEN.
           STRING   "MAIL FROM: "           DELIMITED BY SIZE
                    "<"                     DELIMITED BY SIZE
                    X-SENDER(1:SENDER-LEN)  DELIMITED BY SIZE
                    ">"                     DELIMITED BY SIZE
                    INTO WRK-RECORD WITH POINTER SEND-LEN
           END-STRING.
           PERFORM  SENDEN-STRING.
           IF       X-RETTXT > SPACES
                    GO TO ANF090
           END-IF.

     �* IN DIESER SECTION WERDEN ALLE ANGEGEBENEN EMPF�NGER AN DEN
     �* MAILSERVER �BERGEBEN
           PERFORM  ANGABE-EMPFAENGER.
           IF       SENDER-OK = SPACES
                    GO TO ANF090
           END-IF.

     �* EMAIL BODY EINLEITEN
           MOVE     "DATA" TO WRK-RECORD(1:4).
           MOVE     4 TO SEND-LEN.
           PERFORM  SENDEN.

     �* AB HIER ERHALTEN WIR KEINE ANTWORT MEHR VOM SERVER,
     �* ERST NACH ABSCHLUSS DES BODIES GIBT ES WIEDER ANTWOTREN.
           MOVE     1 TO KEINE-ANTWORT.

     �* SENDER IM DATA-BEREICH ANGEBEN
           MOVE     1 TO SEND-LEN.
           STRING   "FROM: "                DELIMITED BY SIZE
                    X-SENDER(1:SENDER-LEN)  DELIMITED BY SIZE
                    INTO WRK-RECORD WITH POINTER SEND-LEN
           END-STRING.
           PERFORM  SENDEN-STRING.

     �* DIE EMPF�NGER / KOPIEN M�SSEN NOCHMALS
     �* IM DATA-BEREICH ANGEGEBEN WERDEN, SODASS DIESE BEIM EMPF�NGER
     �* IN DER EMAIL STEHEN
           PERFORM  AUSGABE-EMPFAENGER.

     �* EMAIL BETREFF
           MOVE     "SUBJECT: "          TO WRK-RECORD(1:9).
           MOVE     X-TOPIC(1:TOPIC-LEN) TO WRK-RECORD(10:).
           COMPUTE  SEND-LEN = 9 + TOPIC-LEN.
           PERFORM  SENDEN.

     �* MIME-VERSION ANGEBEN
           MOVE     "MIME-VERSION: 1.0"  TO WRK-RECORD(1:17).
           MOVE     17 TO SEND-LEN.
           PERFORM  SENDEN.

     �* MIME PARAMETER ANGEBEN
           MOVE     1 TO SEND-LEN.
           STRING   'CONTENT-TYPE: MULTIPART/MIXED; ' DELIMITED BY SIZE
                    'BOUNDARY="XBODY"'                DELIMITED BY SIZE
                     INTO WRK-RECORD WITH POINTER SEND-LEN
           END-STRING.
           PERFORM  SENDEN-STRING.

     �* NACH DEM HEADER EINE LEERZEILE AUSGEBEN
           PERFORM  LEERZEILE.

     �* BODY ER�FFNEN
           MOVE     "--XBODY" TO WRK-RECORD(1:7).
           MOVE     7 TO SEND-LEN.
           PERFORM  SENDEN.

     �* CHARSET ANGEBEN
           MOVE     "CONTENT-TYPE: TEXT/PLAIN; CHARSET=UTF-8" TO
                    WRK-RECORD(1:39).
           MOVE     39 TO SEND-LEN.
           PERFORM  SENDEN.

     �* VOR DEM INHALT EINE LEERZEILE AUSGEBEN
           PERFORM  LEERZEILE.

     �* EMAIL INHALT
           MOVE     X-DATA(1:DATA-LEN) TO WRK-RECORD(1:DATA-LEN).
           MOVE     DATA-LEN TO SEND-LEN.
           PERFORM  SENDEN.

     �* NACH DEM INHALT EINE LEERZEILE AUSGEBEN
           PERFORM  LEERZEILE.

     �* WURDE EINE DATEI ANGEGEBEN?
           IF       X-FILE > SPACES
                    PERFORM SENDE-DATEI
           END-IF.

     �* NACH DEM DATENSATZ EINE ELERZEILE AUSGEBEN
           PERFORM  LEERZEILE.

     �* BODY SCHLIE�EN
           MOVE     "--XBODY--" TO WRK-RECORD(1:10).
           MOVE     9 TO SEND-LEN.
           PERFORM  SENDEN.

     �* AB HIER WIRD WIEDER AUF DEN HOST GEH�RT
           INITIALIZE KEINE-ANTWORT.

     �* EMAIL ABSCHLIESSEN
           MOVE     "." TO WRK-RECORD(1:1).
           MOVE     1 TO SEND-LEN
           PERFORM  SENDEN.
           IF       X-RETTXT > SPACES
                    GO TO ANF090
           END-IF.

       ANF090.
     �* IST EIN RETTXT VORHANDEN DATEN RESETTEN!
           IF       X-RETTXT > SPACES
                    MOVE "RESET" TO WRK-RECORD(1:5)
                    MOVE 5 TO SEND-LEN
                    PERFORM SENDEN
                    CALL "PAUSE1"
           END-IF.

     �* SMTP-SERVER WIEDER VERLASSEN
           MOVE     "QUIT" TO WRK-RECORD(1:4).
           MOVE     4 TO SEND-LEN
           MOVE     1 TO LETZTER-DATENSATZ.
           PERFORM  SENDEN.
           CALL     "PAUSE1".

     �* VERBINDUNG WIRD GESCHLOSSEN
           PERFORM  VERBINDUNG-SCHLIESSEN.

       ENDE.
           PERFORM  COPY-PGM-EXIT.

           GOBACK.
      /
     �*--------------------------------------------------------------
     �* L�NGE DER �BERGEBENEN VARIABLEN ERMITTELN
     �*--------------------------------------------------------------
       ERM-LAENGE SECTION.
       ERM-LEN-00.

     �* SENDER
           COMPUTE  SENDER-LEN = FUNCTION LENGTH(X-SENDER).
           PERFORM  WITH TEST BEFORE VARYING SENDER-LEN
                    FROM SENDER-LEN BY -1
                    UNTIL SENDER-LEN = ZEROES OR
                    X-SENDER(SENDER-LEN:1) NOT = SPACES
                    CONTINUE
           END-PERFORM.

     �* L�NGE F�R ALLE EMPF�NGER ERMITTELN
           MOVE     1 TO POS-TAB.
           PERFORM  WITH TEST BEFORE UNTIL
                    POS-TAB > X-ANZAHL OF X-EMPF
                    COMPUTE ADRLEN OF EMPF-TAB(POS-TAB) =
                            LENGTH OF ADRLEN-DUMMY
                    PERFORM WITH TEST BEFORE
                            VARYING ADRLEN  OF EMPF-TAB(POS-TAB)
                            FROM    ADRLEN  OF EMPF-TAB(POS-TAB) BY -1
                            UNTIL   ADRLEN  OF EMPF-TAB(POS-TAB)
                                    = ZEROES
                             OR
                                    ADRESSE OF EMPF-TAB(POS-TAB)
                                   (ADRLEN  OF EMPF-TAB(POS-TAB):1)
                                    NOT = SPACES
                            CONTINUE
                    END-PERFORM
                    ADD 1 TO POS-TAB
           END-PERFORM.
     �* L�NGE F�R KOPIEN ERMITTELN
           MOVE     1 TO POS-TAB.
           PERFORM  WITH TEST BEFORE UNTIL
                    POS-TAB > X-ANZAHL OF X-KOPIE
                    COMPUTE ADRLEN OF KOPIE-TAB(POS-TAB) =
                            LENGTH OF ADRLEN-DUMMY
                    PERFORM WITH TEST BEFORE
                            VARYING ADRLEN  OF KOPIE-TAB(POS-TAB)
                            FROM    ADRLEN  OF KOPIE-TAB(POS-TAB) BY -1
                            UNTIL   ADRLEN  OF KOPIE-TAB(POS-TAB)
                                    = ZEROES
                             OR
                                    ADRESSE OF KOPIE-TAB(POS-TAB)
                                   (ADRLEN  OF KOPIE-TAB(POS-TAB):1)
                                    NOT = SPACES
                            CONTINUE
                    END-PERFORM
                    ADD 1 TO POS-TAB
           END-PERFORM.
     �* L�NGE F�R BLINDKOPIEN ERMITTELN
           MOVE     1 TO POS-TAB.
           PERFORM  WITH TEST BEFORE UNTIL
                    POS-TAB > X-ANZAHL OF X-BKOPIE
                    COMPUTE ADRLEN OF BKOPIE-TAB(POS-TAB) =
                            LENGTH OF ADRLEN-DUMMY
                    PERFORM WITH TEST BEFORE
                            VARYING ADRLEN OF BKOPIE-TAB(POS-TAB)
                            FROM    ADRLEN OF BKOPIE-TAB(POS-TAB) BY -1
                            UNTIL   ADRLEN OF BKOPIE-TAB(POS-TAB)
                                    = ZEROES
                             OR
                                    ADRESSE OF BKOPIE-TAB(POS-TAB)
                                   (ADRLEN  OF BKOPIE-TAB(POS-TAB):1)
                                    NOT = SPACES
                            CONTINUE
                    END-PERFORM
                    ADD 1 TO POS-TAB
           END-PERFORM.

     �* TOPIC
           COMPUTE  TOPIC-LEN = FUNCTION LENGTH(X-TOPIC).
           PERFORM  WITH TEST BEFORE VARYING TOPIC-LEN
                    FROM TOPIC-LEN BY -1
                    UNTIL TOPIC-LEN = ZEROES OR
                    X-TOPIC(TOPIC-LEN:1) NOT = SPACES
                    CONTINUE
           END-PERFORM.

     �* DATA
           COMPUTE  DATA-LEN = FUNCTION LENGTH(X-DATA).
           PERFORM  WITH TEST BEFORE VARYING DATA-LEN
                    FROM DATA-LEN BY -1
                    UNTIL DATA-LEN = ZEROES OR
                    X-DATA(DATA-LEN:1) NOT = SPACES
                    CONTINUE
           END-PERFORM.

       ERM-LEN-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* SENDEN WRK-RECORD (VORHER L�NGE - 1)
     �*--------------------------------------------------------------
       SENDEN-STRING SECTION.
       SND-STR-00.

           SUBTRACT 1 FROM SEND-LEN.
           PERFORM  SENDEN.

       SND-STR-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* SENDEN WRK-RECORD
     �*--------------------------------------------------------------
       SENDEN SECTION.
       SEN-DAT-00.

     �* STRING IN ASCII KONVERTIEREN
           IF       NO-CONVERT = ZEROES
                    MOVE     "1" TO EBC-ASCII
                    PERFORM  KONVERT-STRING
           END-IF.

     �* INT-LEN-OUT+1, DAMIT DAS ENDE NICHT �BERSCHRIEBEN WIRD
           MOVE     TCP-DELIM TO WRK-RECORD(SEND-LEN + 1:2).
           ADD      2 TO SEND-LEN.

     �* SENDEN DES DATENSATZES
           MOVE     "2"      TO TCP-ACTION.
           MOVE     5        TO TCP-TIMEOUT.
           MOVE     SEND-LEN TO TCP-BUFLEN.
           INITIALIZE TCP-RETTXT.
           CALL     PROCEDURE "LGTCPIO" USING TCP-SOCK
                                              TCP-ACTION
                                              WRK-RECORD(1:SEND-LEN)
                                              TCP-BUFLEN
                                              TCP-DELIM
                                              TCP-DELIMLEN
                                              TCP-TIMEOUT
                                              TCP-RETTXT
           END-CALL.

     �* GAB ES EINEN FEHLER BEIM SENDEN?
           IF       TCP-RETTXT > SPACES
                    MOVE TCP-RETTXT TO X-RETTXT
                    GO TO SEN-DAT-90
           END-IF.

     �* NICHT BEI JEDEM SENDEVORGANG WIRD EINE ANTWORT ERWARTET.
     �* IN DER DATEN-SEKTION ERFOLGT GENERELL KEINE R�CKMELDUNG
           IF       KEINE-ANTWORT > SPACES
                    GO TO SEN-DAT-90
           END-IF.

     �* DER PUFFER WIRD SO LANGE GELESEN, BIS EIN TIMEOUT
     �* VORHANDEN IST (DANN IST DER PUFFER LEER)
       SEN-DAT-20.
           MOVE     1 TO TCP-TIMEOUT
     �* �BERPR�FEN, OB DER HOST EINE R�CKMELDUNG GEGEBEN HAT
           MOVE     "3"               TO TCP-ACTION.
           MOVE     1                 TO TCP-TIMEOUT.
           COMPUTE  TCP-BUFLEN = LENGTH OF WRK-RECORD.
           INITIALIZE TCP-RETTXT.
           CALL     PROCEDURE "LGTCPIO"  USING TCP-SOCK
                                               TCP-ACTION
                                               WRK-RECORD
                                               TCP-BUFLEN
                                               TCP-DELIM
                                               TCP-DELIMLEN
                                               TCP-TIMEOUT
                                               TCP-RETTXT
           END-CALL.

     �* R�CKMELDUNG DES PROGRAMMS ABFRAGEN
           IF       TCP-RETTXT = "*TIMEOUT"
                    GO TO SEN-DAT-90
           END-IF.

     �* PR�FEN, OB DER SERVER R�CKMELDUNG GEGEBEN HAT
           IF       TCP-BUFLEN = ZEROES
                    GO TO SEN-DAT-90
           END-IF.

     �* DER STRING VOM HOST MUSS ERST KONVERTIERT WERDEN
           MOVE     TCP-BUFLEN TO SEND-LEN.
           MOVE     SPACES TO EBC-ASCII.
           PERFORM  KONVERT-STRING.

     �* PR�FEN, OB EIN FEHLER AUFGETRETEN IST
           IF       WRK-RECORD > SPACES
            AND    (WRK-RECORD(1:1) = "4"
            OR      WRK-RECORD(1:1) = "5")
                    MOVE LENGTH OF X-RETTXT TO SEND-LEN
                    MOVE WRK-RECORD(1:SEND-LEN) TO X-RETTXT
           ELSE
                    INITIALIZE X-RETTXT
           END-IF.

     �* AUSGABE DER R�CKMELDUNG
           DISPLAY  WRK-RECORD(1:SEND-LEN).

     �* WURDE DIE VERBINDUNG BEENDET? DANN NICHT WEITER AUF DEN PORT
     �* LISTEN
           IF       LETZTER-DATENSATZ > SPACES
                    GO TO SEN-DAT-90
           END-IF.

     �* ERNEUT DEN PUFFER LESEN
           GO TO SEN-DAT-20.

       SEN-DAT-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* WRK-RECORD IN ASCII KONVERTIEREN
     �*--------------------------------------------------------------
       KONVERT-STRING SECTION.
       KON-STR-00.

           INITIALIZE RET-CODE.
           INITIALIZE INT-LEN-IN.
           INITIALIZE INT-LEN-OUT.

     �* SOLL VON ASCII VON ODER NACH ASCII KONVERTIERT WERDEN?
           IF       EBC-ASCII = SPACES
                    MOVE     819 TO CCSID-IN
                    MOVE     0   TO CODE-PAGE
           ELSE
                    MOVE     ZEROES  TO CCSID-IN
                    MOVE     819 TO CODE-PAGE
           END-IF.

           MOVE     SEND-LEN TO INT-LEN-IN.
           COMPUTE  INT-LEN-OUT = FUNCTION LENGTH (WRK-RECORD).

     �* LGPGM0818 KONVERTIERT DEN WRK-RECORD
           CALL     PROCEDURE  "LGPGM0818" USING
                                        WRK-RECORD(1:INT-LEN-IN)
                                        INT-LEN-IN
                                        INT-LEN-OUT
                                        CCSID-IN
                                        CODE-PAGE
                                        RET-CODE
           END-CALL.

     �* WAR DAS KONVERTIEREN ERFOLGREICH
           IF       RET-CODE NOT = SPACES
                    GO TO KON-STR-90
           END-IF.

           MOVE     INT-LEN-OUT TO SEND-LEN.

       KON-STR-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* SENDEN EINER DATEI
     �*--------------------------------------------------------------
       SENDE-DATEI SECTION.
       SND-FIL-00.

     �* INHALT DER ZU SENDENDEN DATEI LESEN
           COMPUTE  LEN-IN = LENGTH OF WRK-RECORD-FILE.
           CALL     PROCEDURE "LGGETIFS" USING X-FILE
                                               WRK-RECORD-FILE
                                               LEN-IN
                                               LEN-OUT
                                               RET-CODE
           END-CALL.

     �* KONNTE KEIN INHALT ERMITTELT WERDEN? BEENDEN
           IF       LEN-OUT = ZEROES
                    GO TO SND-FIL-90
           END-IF

     �* NEUEN BODY ER�FFNEN
           MOVE     "--XBODY" TO WRK-RECORD(1:7).
           MOVE     7 TO SEND-LEN.
           PERFORM  SENDEN.

     �* DEN DATEINAMEN AUS DEM IFS-VERZEICHNIS ERMITTELN
           MOVE     LENGTH OF X-FILE TO LEN-IN.
           PERFORM  WITH TEST BEFORE UNTIL
                    LEN-IN = ZEROES
            OR      X-FILE(LEN-IN:1) = "/"
                    SUBTRACT 1 FROM LEN-IN
           END-PERFORM.
           MOVE     LEN-IN TO LEN-OUT.
           PERFORM  WITH TEST BEFORE UNTIL
                    X-FILE(LEN-OUT:1) = SPACES
                    ADD 1 TO LEN-OUT
           END-PERFORM.
           MOVE     X-FILE(LEN-IN:LEN-OUT) TO FILE-WRK.

     �* DATEI + TYP ANGEBEN
           MOVE     1 TO SEND-LEN.
           STRING   "CONTENT-TYPE: MODEL; " DELIMITED BY SIZE
                    'NAME="'                DELIMITED BY SIZE
                    FILE-WRK                DELIMITED BY SIZE
                    '"'                     DELIMITED BY SIZE
                    INTO WRK-RECORD WITH POINTER SEND-LEN
           END-STRING.
           PERFORM  SENDEN-STRING.

     �* CODIERUNG DER DATEI ANGEBEN (IN UNSEREM FALL BASE64)
           MOVE     "CONTENT-TRANSFER-ENCODING: BASE64" TO
                    WRK-RECORD(1:33).
           MOVE     33 TO SEND-LEN.
           PERFORM  SENDEN

     �* AUCH HIER WIEDER VOR DEM INHALT EINE LEERZEILE AUSGEBEN
           PERFORM  LEERZEILE.

     �* DER TEXT MUSS ZUM SENDEN NACH BASE64 KONVERTIERT WERDEN
           COMPUTE  BASE-LEN-OUT = LENGTH OF WRK-RECORD-FILE.
           MOVE     LEN-OUT TO BASE-LEN-IN.
           CALL     PROCEDURE "LGBASE64" USING BASE64-AKTION
                                         WRK-RECORD-FILE(1:LEN-OUT)
                                         WRK-RECORD
                                         BASE-LEN-IN
                                         BASE-LEN-OUT
                                         RET-CODE
           END-CALL
           IF       RET-CODE NOT = SPACES
                    GO TO SND-FIL-90
           END-IF

     �* DATEI SENDEN
           MOVE    1 TO NO-CONVERT.
           MOVE    BASE-LEN-OUT TO SEND-LEN.
           PERFORM SENDEN.
           MOVE    0 TO NO-CONVERT.

       SND-FIL-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* EMPF�NGER ANGEBEN
     �*--------------------------------------------------------------
       ANGABE-EMPFAENGER SECTION.
       ANG-EMP-00.

     �* DIE ANGEGEBENEN EMPF�NGER WERDEN �BERNOMMEN
           MOVE     1 TO POS-TAB.
           PERFORM  WITH TEST BEFORE UNTIL
                    POS-TAB > X-ANZAHL OF X-EMPF
                    MOVE   1 TO SEND-LEN
                    STRING "RCPT TO: " DELIMITED BY SIZE
                           "<"         DELIMITED BY SIZE
                           ADRESSE OF EMPF-TAB(POS-TAB)
                                      (1:ADRLEN OF EMPF-TAB(POS-TAB))
                                       DELIMITED BY SIZE
                           ">"         DELIMITED BY SIZE
                           INTO WRK-RECORD WITH POINTER SEND-LEN
                    END-STRING
                    PERFORM  SENDEN-STRING
                    IF   X-RETTXT = SPACES
                         MOVE "1" TO SENDER-OK
                    END-IF
                    ADD 1 TO POS-TAB
           END-PERFORM.

     �* WURDE MINDESTENS 1 G�LTIGER EMPF�NGER ANGEGEBEN?
           IF       SENDER-OK = SPACES
                    GO TO ANG-EMP-90
           END-IF.

     �* DIE ANGEGEBENEN KOPIEN WERDEN �BERNOMMEN
           MOVE     1 TO POS-TAB.
           PERFORM  WITH TEST BEFORE UNTIL
                    POS-TAB > X-ANZAHL OF X-KOPIE
                    MOVE   1 TO SEND-LEN
                    STRING "RCPT TO: " DELIMITED BY SIZE
                           "<"         DELIMITED BY SIZE
                           ADRESSE OF KOPIE-TAB(POS-TAB)
                                     (1:ADRLEN OF KOPIE-TAB(POS-TAB))
                                      DELIMITED BY SIZE
                           ">"        DELIMITED BY SIZE
                           INTO WRK-RECORD WITH POINTER SEND-LEN
                    END-STRING
                    PERFORM  SENDEN-STRING
                    ADD 1 TO POS-TAB
           END-PERFORM.

     �* DIE ANGEGEBENEN BLINDKOPIEN WERDEN �BERNOMMEN
           MOVE     1 TO POS-TAB.
           PERFORM  WITH TEST BEFORE UNTIL
                    POS-TAB > X-ANZAHL OF X-BKOPIE
                    MOVE   1 TO SEND-LEN
                    STRING "RCPT TO: " DELIMITED BY SIZE
                           "<"         DELIMITED BY SIZE
                           ADRESSE OF BKOPIE-TAB(POS-TAB)
                                      (1:ADRLEN OF BKOPIE-TAB(POS-TAB))
                                       DELIMITED BY SIZE
                           ">"         DELIMITED BY SIZE
                           INTO WRK-RECORD WITH POINTER SEND-LEN
                    END-STRING
                    PERFORM  SENDEN-STRING
                    ADD 1 TO POS-TAB
           END-PERFORM.

       ANG-EMP-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* CLEAREN ALLER TABELLEN
     �*--------------------------------------------------------------
       LOESCHEN-TABELLEN SECTION.
       LOE-TAB-00.

     �* L�SCHEN EMPF�NGERTABELLE
           MOVE     1 TO POS-TAB.
           PERFORM  WITH TEST BEFORE
                    UNTIL ADRESSE OF EMPF-TAB(POS-TAB) = SPACES
                    MOVE SPACES TO ADRESSE OF EMPF-TAB(POS-TAB)
                    MOVE ZEROES TO ADRLEN  OF EMPF-TAB(POS-TAB)
                    ADD 1 TO POS-TAB
           END-PERFORM.

     �* L�SCHEN KOPIENTABLLE
           MOVE     1 TO POS-TAB.
           PERFORM  WITH TEST BEFORE
                    UNTIL ADRESSE OF KOPIE-TAB(POS-TAB) = SPACES
                    MOVE SPACES TO ADRESSE OF KOPIE-TAB(POS-TAB)
                    MOVE ZEROES TO ADRLEN  OF KOPIE-TAB(POS-TAB)
                    ADD 1 TO POS-TAB
           END-PERFORM.

     �* L�SCHEN BLINDKOPIENTABELLE
           MOVE     1 TO POS-TAB.
           PERFORM  WITH TEST BEFORE
                    UNTIL ADRESSE OF BKOPIE-TAB(POS-TAB) = SPACES
                    MOVE SPACES TO ADRESSE OF BKOPIE-TAB(POS-TAB)
                    MOVE ZEROES TO ADRLEN  OF BKOPIE-TAB(POS-TAB)
                    ADD 1 TO POS-TAB
           END-PERFORM.

       LOE-TAB-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* �BERNAHME ADRESSDATEN AUS DEM CL-PROGRAMM
     �*--------------------------------------------------------------
       UEBERNEHME-ADRESSEN SECTION.
       UEB-ADR-00.

     �* �BERNAHME ALLER EMPF�NGER
           MOVE     1 TO POS-TAB.
           PERFORM  WITH TEST BEFORE
                    UNTIL POS-TAB > X-ANZAHL OF X-EMPF
                    MOVE X-ADRESSE OF X-EMPF(POS-TAB) TO
                           ADRESSE OF EMPF-TAB(POS-TAB)
                    ADD 1 TO POS-TAB
           END-PERFORM.

     �* �BERNAHME ALLER KOPIEN
           MOVE     1 TO POS-TAB.
           PERFORM  WITH TEST BEFORE
                    UNTIL POS-TAB > X-ANZAHL OF X-KOPIE
                    MOVE X-ADRESSE OF X-KOPIE(POS-TAB) TO
                           ADRESSE OF KOPIE-TAB(POS-TAB)
                    ADD 1 TO POS-TAB
           END-PERFORM.

     �* �BERNAHME ALLER BLINDKOPIEN
           MOVE     1 TO POS-TAB.
           PERFORM  WITH TEST BEFORE
                    UNTIL POS-TAB > X-ANZAHL OF X-BKOPIE
                    MOVE X-ADRESSE OF X-BKOPIE(POS-TAB) TO
                           ADRESSE OF BKOPIE-TAB(POS-TAB)
                    ADD 1 TO POS-TAB
           END-PERFORM.

       UEB-ADR-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* AUSGABE EMPF�NGER / KOPIEN IM DATA-BEREICH
     �*--------------------------------------------------------------
       AUSGABE-EMPFAENGER SECTION.
       AUS-EMP-00.

     �* DIE ANGEGEBENEN EMPF�NGER WERDEN �BERNOMMEN
           MOVE     1 TO POS-TAB.
           PERFORM  WITH TEST BEFORE UNTIL
                    POS-TAB > X-ANZAHL OF X-EMPF
                    MOVE   1 TO SEND-LEN
                    STRING "TO: " DELIMITED BY SIZE
                           ADRESSE OF EMPF-TAB(POS-TAB)
                                      (1:ADRLEN OF EMPF-TAB(POS-TAB))
                                       DELIMITED BY SIZE
                           INTO WRK-RECORD WITH POINTER SEND-LEN
                    END-STRING
                    PERFORM  SENDEN-STRING
                    ADD 1 TO POS-TAB
           END-PERFORM.

     �* DIE ANGEGEBENEN KOPIEN WERDEN �BERNOMMEN
           MOVE     1 TO POS-TAB.
           PERFORM  WITH TEST BEFORE UNTIL
                    POS-TAB > X-ANZAHL OF X-KOPIE
                    MOVE   1 TO SEND-LEN
                    STRING "CC: " DELIMITED BY SIZE
                           ADRESSE OF KOPIE-TAB(POS-TAB)
                                    (1:ADRLEN OF KOPIE-TAB(POS-TAB))
                                     DELIMITED BY SIZE
                           INTO WRK-RECORD WITH POINTER SEND-LEN
                    END-STRING
                    PERFORM  SENDEN-STRING
                    ADD 1 TO POS-TAB
           END-PERFORM.

       AUS-EMP-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* LEERZEILE AUSGEBEN
     �*--------------------------------------------------------------
       LEERZEILE SECTION.
       AUS-LER-00.

     �* AUSGABE EINER LEERZEILE
           MOVE     SPACES TO WRK-RECORD(1:1)
           MOVE     1 TO SEND-LEN.
           PERFORM  SENDEN.

       AUS-LER-90.
           EXIT.
      /
     �*--------------------------------------------------------------
     �* VERBINDUNG SCHLIE�EN
     �*--------------------------------------------------------------
       VERBINDUNG-SCHLIESSEN SECTION.
       VER-SCH-00.

     �* VERBINDUNG SCHLIESSEN
           MOVE     5          TO TCP-TIMEOUT.
           MOVE     "1"        TO TCP-ACTION.
           INITIALIZE TCP-RETTXT.
           CALL     PROCEDURE "LGTCPIO"  USING TCP-SOCK
                                               TCP-ACTION
                                               RECORD-SIZE
                                               TCP-BUFLEN
                                               TCP-DELIM
                                               TCP-DELIMLEN
                                               TCP-TIMEOUT
                                               TCP-RETTXT
           END-CALL.

       VER-SCH-90.
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
