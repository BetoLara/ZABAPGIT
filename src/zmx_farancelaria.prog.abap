*&---------------------------------------------------------------------*
*& Report ZMX_FARANCELARIA
*&---------------------------------------------------------------------*
*& Description: Extract Fraccion Arancelaria to Centro de Soluciones   *
*& Date/Author: 31/ENE/2024 - Heriberto Lara Llanas                    *
*&---------------------------------------------------------------------*
REPORT ZMX_FARANCELARIA.

DATA: it_marcfarancel TYPE STANDARD TABLE OF zmx_farancelaria,
      wa_marcfarancel TYPE zmx_farancelaria,
      it_farancelaria TYPE STANDARD TABLE OF zmx_farancelaria,
      wa_farancelaria TYPE zmx_farancelaria,
      it_sendfarancel TYPE STANDARD TABLE OF zmx_sendfarancel,
      wa_sendfarancel TYPE zmx_sendfarancel.

START-OF-SELECTION.

SELECT a~matnr b~maktx a~stawn INTO CORRESPONDING FIELDS OF TABLE it_marcfarancel
  FROM marc AS a
  LEFT OUTER JOIN makt AS b
        ON b~matnr = a~matnr
       AND b~spras = 'E'
  WHERE a~werks EQ 'RS01'.
SORT it_marcfarancel BY matnr.

SELECT matnr maktx stawn INTO CORRESPONDING FIELDS OF TABLE it_farancelaria
  FROM zmx_farancelaria.
SORT it_farancelaria BY matnr.

LOOP AT it_marcfarancel INTO wa_marcfarancel.
  READ TABLE it_farancelaria INTO wa_farancelaria
    WITH KEY matnr = wa_marcfarancel-matnr BINARY SEARCH.
  IF sy-subrc EQ 0.
    IF wa_marcfarancel-stawn NE wa_farancelaria-stawn.
      wa_sendfarancel-matnr = wa_marcfarancel-matnr.
      wa_sendfarancel-maktx = wa_marcfarancel-maktx.
      wa_sendfarancel-stawn = wa_marcfarancel-stawn.
      APPEND wa_sendfarancel TO it_sendfarancel.
    ENDIF.
  ELSE.
    wa_sendfarancel-matnr = wa_marcfarancel-matnr.
    wa_sendfarancel-maktx = wa_marcfarancel-maktx.
    wa_sendfarancel-stawn = wa_marcfarancel-stawn.
    APPEND wa_sendfarancel TO it_sendfarancel.
  ENDIF.
ENDLOOP.
MODIFY zmx_sendfarancel FROM TABLE it_sendfarancel.

MODIFY zmx_farancelaria FROM TABLE it_marcfarancel.

WRITE:/ 'Process completed'.
