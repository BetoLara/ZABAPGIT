class ZCL_REST_ARSERIAL_GET definition
  public
  final
  create public .

public section.

  interfaces ZIF_REST_AUTOREG .

  methods CONSTRUCTOR
    importing
      !IO_REQUEST type ref to IF_HTTP_REQUEST
      !IO_RESPONSE type ref to IF_HTTP_RESPONSE .
protected section.
private section.

  methods GET_SERIAL
    importing
      value(IO_REQUEST) type ref to IF_HTTP_REQUEST
    returning
      value(ET_SERIAL) type ZAR_TTSERIAL .
ENDCLASS.



CLASS ZCL_REST_ARSERIAL_GET IMPLEMENTATION.


  method CONSTRUCTOR.
    ME->ZIF_REST_AUTOREG~RESPONSE = IO_RESPONSE.
    ME->ZIF_REST_AUTOREG~REQUEST = IO_REQUEST.
  endmethod.


  method GET_SERIAL.
***************************************************************************
" VARIABLES
***************************************************************************
DATA: lt_serial TYPE zar_stserial,
      lt_bstnk TYPE zar_stbstnk,
      lt_vbeln TYPE zar_stvbeln,
      lt_matnr TYPE zar_stmatnr,
      lt_sernr TYPE zar_stsernr.
************************************* *************************************
" GET SERIAL DATA SELECT
***************************************************************************

SELECT bstnk,vbeln,matnr,sernr INTO TABLE @DATA(it_serial) FROM zsd_autoreg_ser.
SORT it_serial BY bstnk vbeln matnr sernr.

LOOP AT it_serial INTO DATA(wa_serial).
  lt_sernr = wa_serial-sernr.
  APPEND lt_sernr TO lt_matnr-serials.

  AT END OF matnr.
    lt_matnr-matnr = wa_serial-matnr.
    APPEND lt_matnr TO lt_vbeln-materials.
    FREE lt_matnr-serials.
  ENDAT.

  AT END OF vbeln.
    lt_vbeln-vbeln = wa_serial-vbeln.
    APPEND lt_vbeln TO lt_bstnk-orders.
    FREE lt_vbeln-materials.
  ENDAT.

  AT END OF bstnk.
    lt_bstnk-bstnk = wa_serial-bstnk.
    APPEND lt_bstnk TO lt_serial-ponumbers.
    FREE: lt_bstnk-orders.
  ENDAT.
ENDLOOP.
APPEND lt_serial TO ET_SERIAL.

*DELETE FROM zsd_autoreg_ser.
  endmethod.


  method ZIF_REST_AUTOREG~HANDLE_REQUEST.
***************************************************************************
" VARIABLES
***************************************************************************
DATA: LT_SERIAL         TYPE ZAR_TTSERIAL.
DATA: LV_STRING_WRITER  TYPE REF TO CL_SXML_STRING_WRITER.
DATA: LV_XSTRING        TYPE XSTRING.

***************************************************************************
" EXECUTE GET_SERIAL METHOD
***************************************************************************
TRY.

LT_SERIAL = GET_SERIAL( ME->ZIF_REST_AUTOREG~REQUEST ).

***************************************************************************
" CONVERT SERIALS TO JSON
***************************************************************************
LV_STRING_WRITER = CL_SXML_STRING_WRITER=>CREATE( TYPE = IF_SXML=>CO_XT_JSON ).
CALL TRANSFORMATION ID SOURCE ARRAY = LT_SERIAL RESULT XML LV_STRING_WRITER.
LV_XSTRING = LV_STRING_WRITER->GET_OUTPUT( ).

***************************************************************************
" ADD THE JSON SERIALS TO THE RESPONSE
***************************************************************************
ME->ZIF_REST_AUTOREG~RESPONSE->SET_DATA( DATA = LV_XSTRING ).

CATCH CX_ROOT.
ENDTRY.
  endmethod.


  method ZIF_REST_AUTOREG~SET_RESPONSE.
    CALL METHOD ME->ZIF_REST_AUTOREG~RESPONSE->SET_DATA
      EXPORTING
        DATA = IS_DATA.
  endmethod.
ENDCLASS.
