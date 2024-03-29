/*�*-----------------------------------------------------------------*/
/*�* DYNAMISCHER SPEICHER (MAPDTA)                                 */
/*�*---------------------------------------------------------------  */
/*�*                                                                 */
/*�* AUTOR         :  A. PIEGER                                      */
/*�*                                                                 */
/*�* ERSTELLT AM   :  23.08.2010                                     */
/*�*                                                                 */
/*�* FUNKTION      :  SPEICHER                                       */
/*�*                                                                 */
/*�* �NDERUNGEN:                                                     */
/*�*�DATUM      VON   GRUND DER �NDERUNG                             */
/*�*                                                                 */
/*�****************************************************************  */
#include "APGGLOBAL.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define KEYLEN 100

typedef struct MAPDTA_arrayRec
{
  char recKey[KEYLEN];
  char *recData;
  void *recPtr;
};

typedef struct MAPDTA_pgmStruct
{
  int arrayCurrentSize;
  int arrayMaxSize;
  int arraySorted;
  int arrayCount;
  char maxKeyVal[KEYLEN];
  struct MAPDTA_arrayRec *dataArray;
};

struct MAPDTA_arrayRec MAPDTA_searchRec;
struct MAPDTA_arrayRec *MAPDTA_searchResult;
int MAPDTA_retcode;
int MAPDTA_i;

static int sortcomp(const void *value1, const void *value2) {
            struct MAPDTA_arrayRec *mi1 = (struct MAPDTA_arrayRec *) value1;
            struct MAPDTA_arrayRec *mi2 = (struct MAPDTA_arrayRec *) value2;
            return memcmp(mi1->recKey, mi2->recKey, KEYLEN);
}

/*�Wert in dynamischen Container schreiben, auslesen oder l�schen    */
/*�Parameter:                                                        */
/*�1. Aktionscode, PIC X(1), (1 = Schreiben,                         */
/*�                           2 = Abfragen,                          */
/*�                           3 = L�schen,                           */
/*�                           4 = Alles f�r ein Programm l�schen),   */
/*�                           5 = N�chsten Satz lesen,               */
/*�                           6 = Vorherigen Satz lesen              */
/*�                           7 = Mit ArrayCount aufsetzten          */
/*�                         8/9 = Key �ber ArrayCount �ndern         */
/*�                               zuvor muss auf den Array aufgesetzt*/
/*�                               werden (Auswahl 2,5,6,7)           */
/*�                               8=ohne Sort                        */
/*�                               9=mit  Sort                        */
/*�                           S = Array sortieren                    */
/*�                           C = Anzahl Eintr�ge zur�ckgeben        */
/*�                           P = Nur einen Datenpointer generieren  */
/*�                                                                  */
/*�2. Zeigerstruktur, USAGE POINTER                                  */
/*�   dient zur Zuordnung von einem Speicherbereich zu einem Programm*/
/*�   Wird beim ersten Aufruf zur�ckgegeben und muss bei den         */
/*�   folgenden Aufrufen wieder mitgegeben werden                    */
/*�3. Zugriffschl�ssel f�r die Daten, PIC X(75)                      */
/*�4. Datensatz (Input/Output), Beliebige L�nge                      */
/*�5. L�nge des Datensatzes, PIC S9(9) COMP-4                        */
/*�6. Zahl zum Aufsetzten �ber ArrayCount PIC S9(9) COMP-4           */
/*�7. Return-Code, PIC X(1)                                          */
DLLEXPORT
void MAPDTA (char *x_action, struct MAPDTA_pgmStruct **x_pgmStruct,     char *x_key,
               char *x_data, void **x_recPtr, int *x_dataLen, int *x_lfdn,
               char *x_retcode)
{
  /*�Wurde die PGMSTRUCT schonmal ermittelt? */
  if(*x_pgmStruct == NULL)
  {
    /*�Speicher reservieren und zur�ckgeben */
    *x_pgmStruct = calloc(1, sizeof(struct MAPDTA_pgmStruct));
    if(*x_pgmStruct == NULL)
    {
      x_retcode[0] = '1';
      return;
    }
    /*�Elemente werden durch calloc initialisiert */
    (*x_pgmStruct)->arraySorted = 1;
  }

  /*�Je nach Aktionscode nun die jeweilige Aktion durchf�hren */
  switch(x_action[0])
  {
    /*�Setzen */
    case '1':
    /*�Ist noch genug Platz im Array? */
      if((*x_pgmStruct)->arrayMaxSize == (*x_pgmStruct)->arrayCurrentSize)
      {
        /*�Falls nicht, dann Array vergr��ern */
        (*x_pgmStruct)->arrayMaxSize+= 100;
        /*�Realloc funktioniert auch beim ersten Aufruf wenn dataArray noch NULL ist*/
        (*x_pgmStruct)->dataArray =
          realloc((*x_pgmStruct)->dataArray,
          (*x_pgmStruct)->arrayMaxSize * sizeof(struct MAPDTA_arrayRec));
      }

      /*�Ist das Element gr��er als, das bisher gr��te eingef�gte, dann muss es neu sein */
      MAPDTA_retcode = memcmp((*x_pgmStruct)->maxKeyVal, x_key, KEYLEN);
      if(MAPDTA_retcode < 0)
      {
        (*x_pgmStruct)->arrayCurrentSize++;
        memcpy((*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCurrentSize - 1].recKey, x_key, KEYLEN);
        (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCurrentSize - 1].recData = malloc(*x_dataLen);
        memcpy((*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCurrentSize - 1].recData, x_data, *x_dataLen);
        (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCurrentSize - 1].recPtr = *x_recPtr;
        /*�Neuen gr��ten Key festhalten */
        memcpy(&(*x_pgmStruct)->maxKeyVal, x_key, KEYLEN);
      }else
      {
        /*�Pr�fen ob das Element schon vorhanden ist */
        /*�Ggf. vorher sortieren */
        if((*x_pgmStruct)->arraySorted == 0)
        {
          /*�Array nun neu sortieren */
          qsort((*x_pgmStruct)->dataArray, (*x_pgmStruct)->arrayCurrentSize,
                sizeof(struct MAPDTA_arrayRec), sortcomp);
          (*x_pgmStruct)->arraySorted = 1;
        }
        /*�Wenn der Key gleich dem gr��ten Key ist, dann kann dieser direkt ersetzt werden */
        if(MAPDTA_retcode != 0)
        {
          memcpy(&MAPDTA_searchRec.recKey, x_key, KEYLEN);
          MAPDTA_searchResult = bsearch(&MAPDTA_searchRec, (*x_pgmStruct)->dataArray,
                  (*x_pgmStruct)->arrayCurrentSize, sizeof(struct MAPDTA_arrayRec), sortcomp);
        }else
        {
          MAPDTA_searchResult = &(*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCurrentSize - 1];
        }
        /*�Nicht gefunden -> Neuer Eintrag*/
        if(MAPDTA_searchResult == NULL)
        {
          (*x_pgmStruct)->arrayCurrentSize++;
          memcpy((*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCurrentSize - 1].recKey, x_key, KEYLEN);
          (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCurrentSize - 1].recData = malloc(*x_dataLen);
          memcpy((*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCurrentSize - 1].recData,
                 x_data, *x_dataLen);
          (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCurrentSize - 1].recPtr = *x_recPtr;
          /*�Da dieser Key NICHT gr��er ist als der bisher gr��te ist, muss sortiert werden */
          (*x_pgmStruct)->arraySorted = 0;
        }else
        /*�Gefunden -> Bestehenden Eintrag �ndern */
        {
          memcpy(MAPDTA_searchResult->recKey, x_key, KEYLEN);
          memcpy(MAPDTA_searchResult->recData, x_data, *x_dataLen);
          MAPDTA_searchResult->recPtr = *x_recPtr;
          /*�Es wurde ein bestehender Eintrag ge�ndert => Keine Sortierung n�tig */
          (*x_pgmStruct)->arraySorted = 1;
        }
      }

      x_retcode[0] = ' ';
      break;

    /*�Abfragen/Aufsetzen */
    case '2':
      if((*x_pgmStruct)->arraySorted == 0)
      {
        /*�Array nun neu sortieren */
        qsort((*x_pgmStruct)->dataArray, (*x_pgmStruct)->arrayCurrentSize,
              sizeof(struct MAPDTA_arrayRec), sortcomp);
        (*x_pgmStruct)->arraySorted = 1;
      }
      memcpy(&MAPDTA_searchRec.recKey, x_key, KEYLEN);
      MAPDTA_searchResult = bsearch(&MAPDTA_searchRec, (*x_pgmStruct)  ->dataArray,
              (*x_pgmStruct)->arrayCurrentSize, sizeof(struct MAPDTA_arrayRec), sortcomp);
      if(MAPDTA_searchResult == NULL)
      {
        memset(x_data, ' ', *x_dataLen);
        x_retcode[0] = '3';
      }
      else
      {
        memcpy(x_data, MAPDTA_searchResult->recData, *x_dataLen);
        *x_recPtr = MAPDTA_searchResult->recPtr;
        (*x_pgmStruct)->arrayCount = (int)(MAPDTA_searchResult - (*x_pgmStruct)->dataArray);
        *x_lfdn                    = (*x_pgmStruct)->arrayCount;
        x_retcode[0] = ' ';
      }
      break;

    /*�Einen Eintrag entfernen */
    case '3':
      /*�Gibt es �berhaupt Daten f�r dieses Programm */
      if(*x_pgmStruct == NULL)
      {
        x_retcode[0] = ' ';
        return;
      }
      /*�Gibt es schon das Datenarry Daten f�r dieses Programm */
      if((*x_pgmStruct)->dataArray == NULL)
      {
        free(*x_pgmStruct);
        *x_pgmStruct = NULL;
        x_retcode[0] = ' ';
        return;
      }
      /*�Programmzeiger vorhanden, aber gibt es auch Eintr�ge darin? */
      if((*x_pgmStruct)->arrayMaxSize == 0 || (*x_pgmStruct)->arrayCurrentSize == 0)
      {
        /*�Keine Eintr�ge vorhanden, dann Zeiger freigeben und Ende */
        free((*x_pgmStruct)->dataArray);
        free(*x_pgmStruct);
        *x_pgmStruct = NULL;
        x_retcode[0] = ' ';
        return;
      }

      if((*x_pgmStruct)->arraySorted == 0)
      {
        /*�Array nun neu sortieren */
        qsort((*x_pgmStruct)->dataArray, (*x_pgmStruct)->arrayCurrentSize,
              sizeof(struct MAPDTA_arrayRec), sortcomp);
        (*x_pgmStruct)->arraySorted = 1;
      }
      /*�Ist der zu l�schende Wert der gr��te im Array? */
      /*�Dann direkt entfernen */
      if(memcmp(x_key, &(*x_pgmStruct)->maxKeyVal, KEYLEN) == 0)
      {
        /*�Wert im Array l�schen */
        free((*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCurrentSize - 1].recData);
        (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCurrentSize - 1].recData = NULL;
        memset(&(*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCurrentSize - 1].recKey,
               0, KEYLEN);
        (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCurrentSize - 1].recPtr = NULL;

        /*�Array verkleinern */
        (*x_pgmStruct)->arrayCurrentSize--;

        /*�Neuen gr��ten Wert ermitteln */
        /*�Sofern noch ein Element im Array ist */
        if((*x_pgmStruct)->arrayCurrentSize > 0)
        {
          memcpy(&(*x_pgmStruct)->maxKeyVal,
                 &(*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCurrentSize - 1].recKey,
                 KEYLEN);
        }
        else
        {
          /*�Wenn das Array ansonsten leer ist, dann wird der max. Keywert geleert */
          memset(&(*x_pgmStruct)->maxKeyVal, 0, KEYLEN);
        }
        x_retcode[0] = ' ';
        break;
      }

      /*�Element im Array suchen */
      memcpy(&MAPDTA_searchRec.recKey, x_key, KEYLEN);
      MAPDTA_searchResult = bsearch(&MAPDTA_searchRec, (*x_pgmStruct)->dataArray,
              (*x_pgmStruct)->arrayCurrentSize, sizeof(struct MAPDTA_arrayRec), sortcomp);
      if(MAPDTA_searchResult == NULL)
      {
        memset(x_data, ' ', *x_dataLen);
        x_retcode[0] = '3';
      }
      else
      {
        /*�Nun das Element entfernen und die L�cke schlie�en */
        /*�LFDN ermitteln */
        (*x_pgmStruct)->arrayCount = (int)(MAPDTA_searchResult - (*x_pgmStruct)->dataArray);
        *x_lfdn                    = (*x_pgmStruct)->arrayCount;
        /*�Wert im Array l�schen */
        free((*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recData);
        (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recData = NULL;
        memset(&(*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recKey,
               0, KEYLEN);
        (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recPtr = NULL;

        /*�Array verkleinern */
        (*x_pgmStruct)->arrayCurrentSize--;

        /*�Neuen gr��ten Wert ermitteln */
        /*�Sofern noch ein Element im Array ist */
        if((*x_pgmStruct)->arrayCurrentSize > 0)
        {
          /*�Jetzt noch alle Eintr�ge nach dem gel�schten nach vorne schieben */
          for(MAPDTA_i=(*x_pgmStruct)->arrayCount;
              MAPDTA_i<(*x_pgmStruct)->arrayCurrentSize;MAPDTA_i++)
          {
             (*x_pgmStruct)->dataArray[MAPDTA_i] = (*x_pgmStruct)->dataArray[MAPDTA_i + 1];
          }
          memcpy(&(*x_pgmStruct)->maxKeyVal,
                 &(*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCurrentSize - 1].recKey,
                 KEYLEN);
          (*x_pgmStruct)->arrayCount--;
        }
        else
        {
          /*�Wenn das Array ansonsten leer ist, dann wird der max. Keywert geleert */
          memset(&(*x_pgmStruct)->maxKeyVal, 0, KEYLEN);
        }
        x_retcode[0] = ' ';
      }
      break;

    /*�Alle Daten f�r ein Programm l�schen */
    case '4':
      /*�Gibt es �berhaupt Daten f�r dieses Programm */
      if(*x_pgmStruct == NULL)
      {
        x_retcode[0] = ' ';
        return;
      }
      /*�Gibt es schon das Datenarry Daten f�r dieses Programm */
      if((*x_pgmStruct)->dataArray == NULL)
      {
        free(*x_pgmStruct);
        *x_pgmStruct = NULL;
        x_retcode[0] = ' ';
        return;
      }
      /*�Programmzeiger vorhanden, aber gibt es auch Eintr�ge darin? */
      if((*x_pgmStruct)->arrayMaxSize == 0 || (*x_pgmStruct)->arrayCurrentSize == 0)
      {
        /*�Keine Eintr�ge vorhanden, dann Zeiger freigeben und Ende */
        free((*x_pgmStruct)->dataArray);
        free(*x_pgmStruct);
        *x_pgmStruct = NULL;
        x_retcode[0] = ' ';
        return;
      }
      /*�Eintr�ge vorhanden, nun alle Eintr�ge die Belegt sind freigeben */
      for(MAPDTA_retcode = 0;MAPDTA_retcode<(*x_pgmStruct)->arrayCurrentSize;MAPDTA_retcode++)
      {
        if((*x_pgmStruct)->dataArray[MAPDTA_retcode].recData != NULL)
        {
          free((*x_pgmStruct)->dataArray[MAPDTA_retcode].recData);
        }
      }

      /*�Nun auch noch den Datenbereich und den Programmzeiger freigeben */
      free((*x_pgmStruct)->dataArray);
      free(*x_pgmStruct);
      *x_pgmStruct = NULL;
      x_retcode[0] = ' ';
      break;

    /*�N�chsten Satz lesen */
    case '5':
      /*�Ggf. vorher sortieren */
      if((*x_pgmStruct)->arraySorted == 0)
      {
        /*�Array nun neu sortieren */
        qsort((*x_pgmStruct)->dataArray, (*x_pgmStruct)->arrayCurrentSize,
              sizeof(struct MAPDTA_arrayRec), sortcomp);
        (*x_pgmStruct)->arraySorted = 1;
      }
      /*�Wenn ArrayCount kleiner Null, dann Null einf�gen */
      if ((*x_pgmStruct)->arrayCount < 0)
      {
          (*x_pgmStruct)->arrayCount = 0;
      }

      if (((*x_pgmStruct)->arrayCount + 1) < (*x_pgmStruct)->arrayCurrentSize
       && (*x_pgmStruct)->dataArray != NULL)
      {
        (*x_pgmStruct)->arrayCount++;
        memcpy(x_data, (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recData
        , *x_dataLen);
        *x_recPtr = (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recPtr;
        memcpy(x_key, (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recKey
        , KEYLEN);
        *x_lfdn = (*x_pgmStruct)->arrayCount;
        x_retcode[0] = ' ';
      }
      else
      {
        memset(x_data, ' ', *x_dataLen);
        x_retcode[0] = '5';
      }
      return;
      break;

    /*�Vorherigen Satz lesen */
    case '6':
      /*�Ggf. vorher sortieren */
      if((*x_pgmStruct)->arraySorted == 0)
      {
        /*�Array nun neu sortieren */
        qsort((*x_pgmStruct)->dataArray, (*x_pgmStruct)->arrayCurrentSize,
              sizeof(struct MAPDTA_arrayRec), sortcomp);
        (*x_pgmStruct)->arraySorted = 1;
      }
      /*�Wenn ArrayCount gr��er als ArrayCurrentSize ist, dann ArrayCount auf die */
      /*�letzte Position setzen (ArrayCurrentSize - 1) */
      if (((*x_pgmStruct)->arrayCount - 1)>= (*x_pgmStruct)->arrayCurrentSize)
      {
          (*x_pgmStruct)->arrayCount  = (*x_pgmStruct)->arrayCurrentSize;
      }

      if ((*x_pgmStruct)->arrayCount >= 0
       && (*x_pgmStruct)->dataArray != NULL)
      {
        (*x_pgmStruct)->arrayCount--;
        memcpy(x_data, (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recData
        , *x_dataLen);
        *x_recPtr = (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recPtr;
        memcpy(x_key, (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recKey
        , KEYLEN);
        *x_lfdn = (*x_pgmStruct)->arrayCount;
        x_retcode[0] = ' ';
      }
      else
      {
        memset(x_data, ' ', *x_dataLen);
        x_retcode[0] = '6';
      }
      return;
      break;

    /*�Mit ArrayCount aufsetzten */
    case '7':
      /*�Ggf. vorher sortieren */
      if((*x_pgmStruct)->arraySorted == 0)
      {
        /*�Array nun neu sortieren */
        qsort((*x_pgmStruct)->dataArray, (*x_pgmStruct)->arrayCurrentSize,
              sizeof(struct MAPDTA_arrayRec), sortcomp);
        (*x_pgmStruct)->arraySorted = 1;
      }
      if (*x_lfdn >= 0 && *x_lfdn < (*x_pgmStruct)->arrayCurrentSize)
      {
        (*x_pgmStruct)->arrayCount = *x_lfdn;
        memcpy(x_key, (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recKey, KEYLEN);
        memcpy(x_data, (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recData, *x_dataLen);
        *x_recPtr = (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recPtr;
        x_retcode[0] = ' ';
      }
      else
      {
        memset(x_data, ' ', *x_dataLen);
        x_retcode[0] = '7';
      }
      return;
      break;

    /*�Key + Datensatz �ber LFDN �ndern ohne Sort */
    case '8':
      /*�Ggf. vorher sortieren */
      if((*x_pgmStruct)->arraySorted == 0)
      {
        /*�Array nun neu sortieren */
        qsort((*x_pgmStruct)->dataArray, (*x_pgmStruct)->arrayCurrentSize,
              sizeof(struct MAPDTA_arrayRec), sortcomp);
        (*x_pgmStruct)->arraySorted = 1;
      }
      if ((*x_pgmStruct)->arrayCount >= 0
       && (*x_pgmStruct)->arrayCount < (*x_pgmStruct)->arrayCurrentSize)
      {
        memcpy((*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recKey, x_key, KEYLEN);
        memcpy((*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recData, x_data, *x_dataLen);
        (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recPtr = *x_recPtr;

        MAPDTA_retcode = memcmp((*x_pgmStruct)->maxKeyVal, x_key, KEYLEN);
        if(MAPDTA_retcode < 0)
        {
          memcpy(&(*x_pgmStruct)->maxKeyVal, x_key, KEYLEN);
        }
        x_retcode[0] = ' ';
      }
      else
      {
        memset(x_data, ' ', *x_dataLen);
        x_retcode[0] = '8';
      }
      return;
      break;

    /*�Key + Datensatz �ber LFDN �ndern mit Sort */
    case '9':
      /*�Ggf. vorher sortieren */
      if((*x_pgmStruct)->arraySorted == 0)
      {
        /*�Array nun neu sortieren */
        qsort((*x_pgmStruct)->dataArray, (*x_pgmStruct)->arrayCurrentSize,
              sizeof(struct MAPDTA_arrayRec), sortcomp);
        (*x_pgmStruct)->arraySorted = 1;
      }
      if ((*x_pgmStruct)->arrayCount >= 0
       && (*x_pgmStruct)->arrayCount < (*x_pgmStruct)->arrayCurrentSize)
      {
        memcpy((*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recKey, x_key, KEYLEN);
        memcpy((*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recData, x_data, *x_dataLen);
        (*x_pgmStruct)->dataArray[(*x_pgmStruct)->arrayCount].recPtr = *x_recPtr;
        x_retcode[0] = ' ';
        MAPDTA_retcode = memcmp((*x_pgmStruct)->maxKeyVal, x_key, KEYLEN);
        if(MAPDTA_retcode < 0)
        {
          memcpy(&(*x_pgmStruct)->maxKeyVal, x_key, KEYLEN);
        }
        /*�Array nun neu sortieren */
        qsort((*x_pgmStruct)->dataArray, (*x_pgmStruct)->arrayCurrentSize,
              sizeof(struct MAPDTA_arrayRec), sortcomp);
        (*x_pgmStruct)->arraySorted = 1;
      }
      else
      {
        memset(x_data, ' ', *x_dataLen);
        x_retcode[0] = '8';
      }
      return;
      break;

    /*�Array sortieren */
    case 'S':
        /*�Array nun neu sortieren */
        qsort((*x_pgmStruct)->dataArray, (*x_pgmStruct)->arrayCurrentSize,
              sizeof(struct MAPDTA_arrayRec), sortcomp);
        (*x_pgmStruct)->arraySorted = 1;
      return;
      break;

    /*�Array Anzahl zur�ckgeben */
    case 'C':
      *x_lfdn = (*x_pgmStruct)->arrayCurrentSize;
      return;
      break;

    /*�Nur einen Pointer zur�ckgeben, also hier nichts tun */
    case 'P':
      if(*x_pgmStruct == NULL)
      {
        x_retcode[0] = '4';
      }
      return;
      break;

    /*�Bei anderen Aktionen -> Fehler */
    default:
      x_retcode[0] = '2';
      return;
      break;
  }

  return;
}
