class ZCL_REST_CIMDATA definition
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



CLASS ZCL_REST_CIMDATA IMPLEMENTATION.


  method GET_REST.
***************************************************************************
" VARIABLES
***************************************************************************
DATA: LV_CLASS_NAME           TYPE SEOCLSNAME.
DATA: LV_REQUEST_METHOD       TYPE STRING.

***************************************************************************
" APPEND REQUEST METHOD TO BASE CLASS
***************************************************************************
LV_REQUEST_METHOD = IO_SERVER->REQUEST->GET_HEADER_FIELD( '~request_method' ).

CONCATENATE 'ZCL_REST_CIMDATA_' LV_REQUEST_METHOD INTO LV_CLASS_NAME.

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
