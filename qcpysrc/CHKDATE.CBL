     �*--------------------------------------------------------------
     �* PR�FEN EINES DATUMS
     �*--------------------------------------------------------------
       COPY-CHECK-DATE SECTION.
       CPY-CHD-00C.

           INITIALIZE DATUM-RETCODE.
     �* PR�FPROGRAMM AUFRUFEN
           CALL     "CFP9009" USING DATE-DB
                                    DATUM-RETCODE
           END-CALL.

       CPY-CHD-90C.
           EXIT.
      /
