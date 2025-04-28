class ZCL_REST_FAREMAIL_GET definition
  public
  final
  create public .

public section.

  interfaces ZIF_REST_FARANCEL .

  methods CONSTRUCTOR
    importing
      !IO_REQUEST type ref to IF_HTTP_REQUEST
      !IO_RESPONSE type ref to IF_HTTP_RESPONSE .
protected section.
private section.

  methods GET_FAREMAIL
    importing
      value(IO_REQUEST) type ref to IF_HTTP_REQUEST
    returning
      value(ET_FAREMAIL) type ZMX_TTFAREMAIL .
ENDCLASS.



CLASS ZCL_REST_FAREMAIL_GET IMPLEMENTATION.


  method CONSTRUCTOR.
    ME->ZIF_REST_FARANCEL~RESPONSE = IO_RESPONSE.
    ME->ZIF_REST_FARANCEL~REQUEST = IO_REQUEST.
  endmethod.


  method GET_FAREMAIL.
DATA: LV_MATERIAL TYPE MATNR,
      LT_FAREMAIL TYPE ZMX_STFAREMAIL.

TYPES: BEGIN OF ty_type_txt,
        text(200) TYPE c,
       END OF ty_type_txt.

TYPES: BEGIN OF ty_final,
        filler1 TYPE string,
        ebeln   TYPE EBELN,
        ebelp   TYPE EBELP,
        filler2 TYPE string,
       END OF ty_final.

TYPES: BEGIN OF ty_ekpo,
        ebeln  TYPE EBELN,
        ebelp  TYPE EBELP,
        menge  TYPE BSTMG,
        matnr  TYPE MATNR,
        lifnr  TYPE LIFNR,
       END OF ty_ekpo.

DATA : it_tab1  TYPE STANDARD TABLE OF abaplist, "#EC NEEDED
       it_tab2  TYPE STANDARD TABLE OF ty_type_txt, "#EC NEEDED
       it_final TYPE TABLE OF ty_final, "#EC NEEDED
       wa_tab2  TYPE ty_type_txt, "#EC NEEDED
       wa_final TYPE ty_final, "#EC NEEDED
       it_ekpo TYPE STANDARD TABLE OF ty_ekpo, "#EC NEEDED
       wa_ekpo TYPE ty_ekpo. "#EC NEEDED

***************************************************************************
" GET HEADER PARAMETERS VALUE FROM URL
***************************************************************************
LV_MATERIAL = ME->ZIF_REST_FARANCEL~REQUEST->GET_FORM_FIELD('matnr').

LT_FAREMAIL-MATNR = LV_MATERIAL.

IF LV_MATERIAL+0(2) = 'WP'.
  SELECT SINGLE stlnr
    FROM mast
    WHERE matnr EQ @LV_MATERIAL
      AND werks EQ @('F002') INTO @DATA(lv_stlnr).

  IF NOT lv_stlnr IS INITIAL.
    SELECT SINGLE idnrk
      FROM stpo
      WHERE stlnr EQ @lv_stlnr
        AND idnrk EQ @LV_MATERIAL+2(16)
        AND postp EQ @('L') INTO @DATA(lv_idnrk).

     IF NOT lv_idnrk IS INITIAL.
       LV_MATERIAL = lv_idnrk.
     ENDIF.
  ENDIF.
ENDIF.

SUBMIT RM06EM00 AND RETURN EXPORTING LIST TO MEMORY
                  WITH EM_MATNR EQ LV_MATERIAL
                  WITH EM_WERKS EQ 'RS01'
                  WITH LISTU    = 'ZREPORT'
                  WITH SELPA EQ 'WE101'. "#EC CI_SUBMIT.

CALL FUNCTION 'LIST_FROM_MEMORY'
  TABLES
    listobject = it_tab1
  EXCEPTIONS
    not_found  = 1
    OTHERS     = 2.

IF sy-subrc = 0.
  FREE it_tab2.
  CALL FUNCTION 'LIST_TO_ASCI'
    TABLES
      listasci           = it_tab2
      listobject         = it_tab1
    EXCEPTIONS
      empty_list         = 1
      list_index_invalid = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.
ENDIF.

  CALL FUNCTION 'LIST_FREE_MEMORY'
    TABLES
      listobject = it_tab1.

  FREE it_final.
  LOOP AT it_tab2 INTO wa_tab2 FROM 4.
    IF wa_tab2(1) EQ '|' .
      SPLIT wa_tab2 AT '|'
        INTO wa_final-filler1
             wa_final-ebeln
             wa_final-ebelp
             wa_final-filler2.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_final-ebeln
        IMPORTING
          output = wa_final-ebeln.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_final-ebelp
        IMPORTING
          output = wa_final-ebelp.

      APPEND wa_final TO it_final.
      CLEAR wa_tab2.
    ENDIF.
  ENDLOOP.

IF it_final[] IS NOT INITIAL.
  SELECT a~ebeln a~ebelp a~menge a~matnr b~lifnr INTO TABLE it_ekpo
    FROM ekpo AS a
    INNER JOIN ekko AS b
            ON b~ebeln = a~ebeln
    FOR ALL ENTRIES IN it_final
    WHERE a~ebeln EQ it_final-ebeln
      AND a~ebelp EQ it_final-ebelp.

  DELETE it_ekpo WHERE lifnr IS INITIAL.
  SORT it_ekpo BY menge DESCENDING.

  READ TABLE it_ekpo INDEX 1 INTO wa_ekpo.
  IF sy-subrc EQ 0.
    SELECT a~lifnr, b~smtp_addr INTO TABLE @DATA(it_email)
      FROM lfa1 AS a
      INNER JOIN adr6 AS b
              ON b~addrnumber = a~adrnr
      WHERE a~lifnr EQ @wa_ekpo-lifnr.

    SORT it_email BY lifnr.
    READ TABLE it_email INDEX 1 INTO DATA(wa_email). "#EC NEEDED
    IF sy-subrc EQ 0.
      LT_FAREMAIL-SMTP_ADDR = wa_email-smtp_addr.
      FREE it_ekpo.
    ENDIF.
  ENDIF.
ENDIF.

APPEND LT_FAREMAIL TO ET_FAREMAIL.
  endmethod.


  method ZIF_REST_FARANCEL~HANDLE_REQUEST.
***************************************************************************
" VARIABLES
***************************************************************************
DATA: LT_FAREMAIL       TYPE ZMX_TTFAREMAIL.
DATA: LV_STRING_WRITER  TYPE REF TO CL_SXML_STRING_WRITER.
DATA: LV_XSTRING        TYPE XSTRING.

***************************************************************************
" EXECUTE GET_EQUIPMENTS METHOD
***************************************************************************
TRY.

LT_FAREMAIL = GET_FAREMAIL( ME->ZIF_REST_FARANCEL~REQUEST ).

***************************************************************************
" CONVERT TO JSON
***************************************************************************
LV_STRING_WRITER = CL_SXML_STRING_WRITER=>CREATE( TYPE = IF_SXML=>CO_XT_JSON ).
CALL TRANSFORMATION ID SOURCE ARRAY =  LT_FAREMAIL RESULT XML LV_STRING_WRITER.
LV_XSTRING = LV_STRING_WRITER->GET_OUTPUT( ).

***************************************************************************
" ADD THE JSON TO THE RESPONSE
***************************************************************************
ME->ZIF_REST_FARANCEL~RESPONSE->SET_DATA( DATA = LV_XSTRING ).

CATCH CX_ROOT.
ENDTRY.
  endmethod.


  method ZIF_REST_FARANCEL~SET_RESPONSE.
    CALL METHOD ME->ZIF_REST_FARANCEL~RESPONSE->SET_DATA
      EXPORTING
        DATA = IS_DATA.
  endmethod.
ENDCLASS.
