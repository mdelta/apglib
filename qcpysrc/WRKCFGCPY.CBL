     �*---------------------------------------------------------------*
     �* CFG-CPY                                                       *
     �*---------------------------------------------------------------*
     �*                                                               *
     �* AUTOR         :  A. PIEGER                                    *
     �*                                                               *
     �* ERSTELLT AM   :  29.08.2009                                   *
     �*                                                               *
     �* FUNKTION      :  VARIABLEN F�R CONFIG-CPY                     *
     �*                                                               *
     �* �NDERUNGEN:                                                   *
     �* DATUM      VON   GRUND DER �NDERUNG                           *
     �*                                                               *
     �*****************************************************************
     �*
       01  CFG-CPY-TYPE IS TYPEDEF.
            COPY DDS-PCONFIGF  OF PCONFIG.
                 06 CFG-DA               PIC 9(1).

       01  CFG-CPY                       TYPE CFG-CPY-TYPE.
     �*�
