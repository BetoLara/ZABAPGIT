class ZCL_REST_CICUSTOMER definition
  public
  final
  create public .

public section.

  interfaces IF_HTTP_EXTENSION .
protected section.
private section.

  methods GET_REST
    importing
      !IO_SERVER type ref to IF_HTTP_SERVER
    returning
      value(EO_REST) type ref to ZIF_REST_CI .
ENDCLASS.



CLASS ZCL_REST_CICUSTOMER IMPLEMENTATION.


  method GET_REST.
***************************************************************************
" VARIABLES
***************************************************************************
DATA: LV_CLASS_NAME           TYPE SEOCLSNAME.
DATA: LV_REQUEST_METHOD       TYPE STRING.

DATA: LV_REQ_BODY             TYPE STRING,
      LS_DATA                 TYPE ZCI_TTCUSTREG.

DATA: cl_fdt_json             TYPE REF TO cl_fdt_json,
      lx_root                 TYPE REF TO cx_root.
***************************************************************************
" APPEND REQUEST METHOD TO BASE CLASS
***************************************************************************
LV_REQUEST_METHOD = IO_SERVER->REQUEST->GET_HEADER_FIELD( '~request_method' ).
CONCATENATE 'ZCL_REST_CICUSTOMER_' LV_REQUEST_METHOD INTO LV_CLASS_NAME.

IF LV_REQUEST_METHOD = 'PUT'.
LV_REQ_BODY = IO_SERVER->REQUEST->GET_CDATA( ).

IF LV_REQ_BODY IS NOT INITIAL.
  REPLACE ALL OCCURRENCES OF REGEX '[^[:print:]]' IN LV_REQ_BODY WITH SPACE.
  REPLACE ALL OCCURRENCES OF REGEX '#' IN LV_REQ_BODY WITH SPACE.
  CONDENSE LV_REQ_BODY.
  CREATE OBJECT cl_fdt_json.
  TRY.
      CALL METHOD cl_fdt_json=>json_to_data
        EXPORTING
          iv_json = LV_REQ_BODY
        CHANGING
          ca_data = LS_DATA.
    CATCH cx_root INTO lx_root.
  ENDTRY.
ENDIF.

***************************************************************************
" RETURN CLASS OBJECT
***************************************************************************
TRY.
CREATE OBJECT EO_REST
TYPE (LV_CLASS_NAME)
EXPORTING
IO_REQUEST   = IO_SERVER->REQUEST
IO_RESPONSE  = IO_SERVER->RESPONSE
IN_CUST      = LS_DATA.

***************************************************************************
" ERRORS
***************************************************************************
CATCH CX_SY_CREATE_OBJECT_ERROR.
ENDTRY.
ENDIF.

IF LV_REQUEST_METHOD = 'GET'.
***************************************************************************
" RETURN CLASS OBJECT
***************************************************************************
TRY.
CREATE OBJECT EO_REST
TYPE (LV_CLASS_NAME)
EXPORTING
IO_REQUEST   = IO_SERVER->REQUEST
IO_RESPONSE  = IO_SERVER->RESPONSE.

***************************************************************************
" ERRORS
***************************************************************************
CATCH CX_SY_CREATE_OBJECT_ERROR.
ENDTRY.
ENDIF.
  endmethod.


  method IF_HTTP_EXTENSION~HANDLE_REQUEST.
***************************************************************************
" VARIABLES
***************************************************************************
DATA: LO_REST_CLASS     TYPE REF TO ZIF_REST_CI.
DATA: LO_ERROR          TYPE REF TO CX_ROOT.
DATA: LV_REASON         TYPE STRING.

***************************************************************************
" GET THE CLASS OBJECT
***************************************************************************
TRY.

LO_REST_CLASS ?= GET_REST( IO_SERVER = SERVER ).

***************************************************************************
" EXECUTE THE RETRIEVED CLASS
***************************************************************************
LO_REST_CLASS->HANDLE_REQUEST( ).

***************************************************************************
" ERROR
***************************************************************************
CATCH CX_ROOT INTO LO_ERROR.

LV_REASON = LO_ERROR->GET_TEXT( ).
SERVER->RESPONSE->SET_STATUS( CODE = 500
REASON = LV_REASON ).

ENDTRY.
  endmethod.
ENDCLASS.
