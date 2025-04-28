*&---------------------------------------------------------------------*
*& Report  ZMX_REFAC_D2C_REP
*&
*&---------------------------------------------------------------------*
*& Description: Refacturación D2C Report
*& Date/Author: 29/SEP/2022 - Heriberto Lara LARAH2
*& Functional: Idalia Rodriguez
*& Transport: NEDK990931
*&---------------------------------------------------------------------*
REPORT ZMX_REFAC_D2C_REP.

DATA: vbrk TYPE vbrk,
      zmxsd_refac_d2c TYPE zmxsd_refac_d2c.

DATA: it_refac TYPE STANDARD TABLE OF zmxsd_refac_d2c, "#EC NEEDED
      wa_refac TYPE zmxsd_refac_d2c, "#EC NEEDED
      it_alv_field_cat TYPE slis_t_fieldcat_alv, "#EC NEEDED
      wa_alv_field_cat LIKE LINE OF it_alv_field_cat, "#EC NEEDED
      wa_alv_layout TYPE slis_layout_alv. "#EC NEEDED

INCLUDE ZMX_REFAC_D2C_REP_TOP.    " global Data

START-OF-SELECTION.
PERFORM AUTHORITY_CHECK.

SELECT vbeln uuid vbeld stcd1 rfcty stkzn name1 name4 street house_num1
       city2 post_code1 city1 region regimen zuse zpay canvbeln canuuid
       newvbeln newuuid status ernam erdat message
  INTO CORRESPONDING FIELDS OF TABLE it_refac FROM zmxsd_refac_d2c
  WHERE vbeln IN s_vbeln
    AND canvbeln IN s_cvbeln
    AND newvbeln IN s_nvbeln
    AND ernam IN s_ernam
    AND erdat IN s_erdat ##TOO_MANY_ITAB_FIELDS.
SORT it_refac BY vbeln.

PERFORM alv_caract.
PERFORM alv_columnas.
PERFORM eje_report.

*&---------------------------------------------------------------------*
*&      Form  alv_caract
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM alv_caract .
  wa_alv_layout-zebra   = 'X'.
  wa_alv_layout-detail_popup = 'X'.
  wa_alv_layout-colwidth_optimize = 'X'.
ENDFORM.                    " alv_caract
*&---------------------------------------------------------------------*
*&      Form  alv_columnas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_columnas .
  PERFORM alv_monta_columnas USING:
*1 2   3             4              5       6          7   8   9   10
*-----------------------------------------------------------------------
*------*
 0  '1' 'VBELN' 'IT_REFAC'  'X'  'Billing Document', "#EC NOTEXT
 0  '2' 'UUID' 'IT_REFAC'  ''  'UUID', "#EC NOTEXT
 0  '3' 'VBELD' 'IT_REFAC'  ''  'Delivery', "#EC NOTEXT
 0  '4' 'STCD1' 'IT_REFAC'  ''  'RFC', "#EC NOTEXT
 0  '5' 'RFCTY' 'IT_REFAC'  ''  'Type', "#EC NOTEXT
 0  '6' 'STKZN' 'IT_REFAC'  ''  'Natural Person', "#EC NOTEXT
 0  '7' 'NAME1' 'IT_REFAC'  ''  'Name', "#EC NOTEXT
 0  '8' 'NAME4' 'IT_REFAC'  ''  'Email', "#EC NOTEXT
 0  '9' 'STREET' 'IT_REFAC'  ''  'Street', "#EC NOTEXT
 0 '10' 'HOUSE_NUM1' 'IT_REFAC'  ''  'House Number', "#EC NOTEXT
 0 '11' 'CITY2' 'IT_REFAC'  ''  'District', "#EC NOTEXT
 0 '12' 'POST_CODE1' 'IT_REFAC'  ''  'Zip Code', "#EC NOTEXT
 0 '13' 'CITY1' 'IT_REFAC'  ''  'City', "#EC NOTEXT
 0 '14' 'REGION' 'IT_REFAC'  ''  'Region', "#EC NOTEXT
 0 '15' 'REGIMEN' 'IT_REFAC'  ''  'Regimen', "#EC NOTEXT
 0 '16' 'ZUSE' 'IT_REFAC'  ''  'Use', "#EC NOTEXT
 0 '17' 'ZPAY' 'IT_REFAC'  ''  'Pay', "#EC NOTEXT
 0 '18' 'CANVBELN' 'IT_REFAC'  ''  'Cancelation document', "#EC NOTEXT
 0 '19' 'CANUUID' 'IT_REFAC'  ''  'UUID of cancelation', "#EC NOTEXT
 0 '20' 'NEWVBELN' 'IT_REFAC'  ''  'New billing document', "#EC NOTEXT
 0 '21' 'NEWUUID' 'IT_REFAC'  ''  'New UUID', "#EC NOTEXT
 0 '22' 'STATUS' 'IT_REFAC'  ''  'Status', "#EC NOTEXT
 0 '23' 'ERNAM' 'IT_REFAC'  ''  'Created By', "#EC NOTEXT
 0 '24' 'ERDAT' 'IT_REFAC'  ''  'Created On', "#EC NOTEXT
 0 '25' 'MESSAGE' 'IT_REFAC'  ''  'Message'. "#EC NOTEXT
ENDFORM.                    " alv_columnas
*&---------------------------------------------------------------------*
*&      Form  alv_monta_columnas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM alv_monta_columnas  USING  x_row TYPE ANY
                                x_col TYPE ANY
                                x_field TYPE ANY
                                x_tab TYPE ANY
                                x_fix TYPE ANY
                                x_text TYPE ANY.

  wa_alv_field_cat-row_pos           =  x_row.
  wa_alv_field_cat-col_pos           =  x_col.
  wa_alv_field_cat-fieldname         =  x_field.
  wa_alv_field_cat-tabname           =  x_tab.
  wa_alv_field_cat-fix_column        =  x_fix.
  wa_alv_field_cat-reptext_ddic      =  x_text.

  IF x_field = 'STKZN'.
    wa_alv_field_cat-checkbox = 'X'.
  ENDIF.

  IF x_field = 'VBELN' OR x_field = 'CANVBELN' OR x_field = 'NEWVBELN'.
    wa_alv_field_cat-hotspot = 'X'.
  ENDIF.

  APPEND wa_alv_field_cat TO it_alv_field_cat.
  CLEAR wa_alv_field_cat.
ENDFORM.                    " alv_monta_columnas
*&---------------------------------------------------------------------*
*&      Form  eje_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM  eje_report.
 CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = 'USER_COMMAND'
      i_background_id         = ' '
      is_layout               = wa_alv_layout
      it_fieldcat             = it_alv_field_cat[]
    TABLES
      t_outtab                = IT_REFAC
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
 IF sy-subrc <> 0.
   MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
 ENDIF.
ENDFORM.                    " eje_report
FORM user_command USING r_ucomm TYPE sy-ucomm
                        rs_selfield TYPE slis_selfield ##CALLED.
CASE r_ucomm.
  WHEN '&IC1'.
    IF rs_selfield-value IS NOT INITIAL.
      SET PARAMETER ID 'VF' FIELD rs_selfield-value.
      CALL TRANSACTION 'VF03' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
    ENDIF.
ENDCASE.
ENDFORM. "user_command
*&--------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK
*&--------------------------------------------------------------------*
FORM AUTHORITY_CHECK.

  DATA: vl_secu TYPE SECU.

  SELECT SINGLE secu INTO vl_secu
  FROM trdir
  WHERE name = sy-repid.

  IF sy-subrc NE 0.
    MESSAGE text-e02 TYPE 'E'.
    RETURN.
  ELSE.
    AUTHORITY-CHECK OBJECT 'S_PROGRAM'
             ID 'P_GROUP' FIELD vl_secu
             ID 'P_ACTION' FIELD 'SUBMIT'.
    IF sy-subrc NE 0.
      MESSAGE text-e01 TYPE 'E'.
      RETURN.
    ENDIF.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'S_TABU_DIS'
    ID 'ACTVT' FIELD '03'
    ID 'DICBERCLS' FIELD 'ZMFG'.
  IF sy-subrc NE 0.
    MESSAGE text-e03 TYPE 'E'.
    RETURN.
  ENDIF.
ENDFORM.                    "AUTHORITY_CHECK
