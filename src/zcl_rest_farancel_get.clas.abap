class ZCL_REST_FARANCEL_GET definition
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

  methods GET_FARANCEL
    importing
      value(IO_REQUEST) type ref to IF_HTTP_REQUEST
    returning
      value(ET_FARANCEL) type ZMX_JSON_TT .
ENDCLASS.



CLASS ZCL_REST_FARANCEL_GET IMPLEMENTATION.


  method CONSTRUCTOR.
    ME->ZIF_REST_FARANCEL~RESPONSE = IO_RESPONSE.
    ME->ZIF_REST_FARANCEL~REQUEST = IO_REQUEST.
  endmethod.


  method GET_FARANCEL.
***************************************************************************
" VARIABLES
***************************************************************************
DATA: LV_MATERIAL TYPE MATNR,
*      lv_req_body TYPE string,
      gs_fara TYPE ZMX_JSON_TEST,
      lw_tara TYPE ZMX_JSON_TARA.

***************************************************************************
" GET HEADER PARAMETERS VALUE FROM URL
***************************************************************************
LV_MATERIAL = ME->ZIF_REST_FARANCEL~REQUEST->GET_FORM_FIELD('matnr').
*lv_req_body = ME->ZIF_REST_FARANCEL~REQUEST->GET_CDATA().
*UNPACK LV_MATERIAL TO LV_MATERIAL.

************************************* **************************************
" GET FRACCION ARANCELARIA SELECT
***************************************************************************
IF LV_MATERIAL IS INITIAL.
  SELECT matnr maktx INTO CORRESPONDING FIELDS OF TABLE ET_FARANCEL
    FROM zmx_sendfarancel.

  SORT ET_FARANCEL BY matnr.

  DELETE FROM zmx_sendfarancel.
ELSE.
  SELECT a~matnr b~maktx INTO CORRESPONDING FIELDS OF TABLE ET_FARANCEL
  FROM marc AS a
  LEFT OUTER JOIN makt AS b
        ON b~matnr = a~matnr
       AND b~spras = 'E'
  WHERE ( a~matnr EQ LV_MATERIAL or a~matnr EQ '8533954' )
    AND a~werks EQ 'RS01'.

*  LOOP AT ET_FARANCEL INTO DATA(ls_farancel).
*    APPEND ls_farancel TO gs_fara-FRACS.
*  ENDLOOP.

*  LOOP AT gs_fara-FRACS INTO DATA(lsx_farancel).
*  ENDLOOP.

  LOOP AT ET_FARANCEL INTO DATA(lsa_farancel).
*    LOOP AT lsa_farancel-FRACS INTO DATA(ls_stawn).
*      write:/ ls_stawn-stawn.
*    ENDLOOP.
*    ls_STAWN-stawn = '265490'.
    lw_tara-stawn = '265492'.
*    APPEND ls_stawn TO lsa_farancel-FRACS.
    APPEND lw_tara TO lsa_farancel-FRACS.
*    ls_STAWN-stawn = '265491'.
    lw_tara-stawn = '265493'.
*    APPEND ls_stawn TO lsa_farancel-FRACS.
    APPEND lw_tara TO lsa_farancel-FRACS.
    MODIFY ET_FARANCEL FROM lsa_farancel.
  ENDLOOP.
ENDIF.
  endmethod.


  method ZIF_REST_FARANCEL~HANDLE_REQUEST.
***************************************************************************
" VARIABLES
***************************************************************************
*DATA: LT_FARANCEL       TYPE ZMX_TTFARANCEL.
DATA: LT_FARANCEL       TYPE ZMX_JSON_TT.
DATA: LV_STRING_WRITER  TYPE REF TO CL_SXML_STRING_WRITER.
DATA: LV_XSTRING        TYPE XSTRING.

***************************************************************************
" EXECUTE GET_EQUIPMENTS METHOD
***************************************************************************
TRY.

LT_FARANCEL = GET_FARANCEL( ME->ZIF_REST_FARANCEL~REQUEST ).

***************************************************************************
" CONVERT EQUIPMENTS TO JSON
***************************************************************************
LV_STRING_WRITER = CL_SXML_STRING_WRITER=>CREATE( TYPE = IF_SXML=>CO_XT_JSON ).
CALL TRANSFORMATION ID SOURCE ARRAY =  LT_FARANCEL RESULT XML LV_STRING_WRITER.
LV_XSTRING = LV_STRING_WRITER->GET_OUTPUT( ).

***************************************************************************
" ADD THE JSON EQUIPMENTS TO THE RESPONSE
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
