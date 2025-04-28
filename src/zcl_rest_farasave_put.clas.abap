class ZCL_REST_FARASAVE_PUT definition
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

  methods PUT_FARASAVE
    importing
      value(IO_REQUEST) type ref to IF_HTTP_REQUEST
    returning
      value(ET_FARASAVE) type ZMX_TTFARASAVE .
ENDCLASS.



CLASS ZCL_REST_FARASAVE_PUT IMPLEMENTATION.


  method CONSTRUCTOR.
   ME->ZIF_REST_FARANCEL~RESPONSE = IO_RESPONSE.
   ME->ZIF_REST_FARANCEL~REQUEST = IO_REQUEST.
  endmethod.


  method PUT_FARASAVE.
DATA: LV_MATERIAL TYPE MATNR,
      LV_FARANCEL TYPE STAWN,
      LT_FARASAVE TYPE ZMX_STFARASAVE.

DATA: head_data TYPE bapimathead,
      plant_data TYPE bapi_marc,
      plant_datax TYPE bapi_marcx,
      return TYPE bapiret2,
      it_messages TYPE TABLE OF bapi_matreturn2.

***************************************************************************
" GET HEADER PARAMETERS VALUE FROM URL
***************************************************************************
LV_MATERIAL = ME->ZIF_REST_FARANCEL~REQUEST->GET_FORM_FIELD('matnr').
LV_FARANCEL = ME->ZIF_REST_FARANCEL~REQUEST->GET_FORM_FIELD('stawn').

FREE LT_FARASAVE.
LT_FARASAVE-MATNR = LV_MATERIAL.

IF NOT LV_FARANCEL IS INITIAL.
* Populate the header data
    head_data-material = LV_MATERIAL.
* Populate the plant data
    plant_data-plant = 'RS01'.
    plant_data-comm_code = LV_FARANCEL.
    plant_datax-plant = 'RS01'.
    plant_datax-comm_code = 'X'.

  FREE: return, it_messages.
  CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
    EXPORTING
      headdata     = head_data
      plantdata    = plant_data
      plantdatax   = plant_datax
    IMPORTING
      return       = return
    TABLES
      returnmessages = it_messages.

  READ TABLE it_messages TRANSPORTING NO FIELDS WITH KEY type = 'E'.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.

    LT_FARASAVE-STAWN = LV_FARANCEL.
  ENDIF.
ENDIF.
  APPEND LT_FARASAVE TO ET_FARASAVE.
  endmethod.


  method ZIF_REST_FARANCEL~HANDLE_REQUEST.
***************************************************************************
" VARIABLES
***************************************************************************
DATA: LT_FARASAVE       TYPE ZMX_TTFARASAVE.
DATA: LV_STRING_WRITER  TYPE REF TO CL_SXML_STRING_WRITER.
DATA: LV_XSTRING        TYPE XSTRING.

***************************************************************************
" EXECUTE PUT_FARASAVE METHOD
***************************************************************************
TRY.

LT_FARASAVE = PUT_FARASAVE( ME->ZIF_REST_FARANCEL~REQUEST ).

***************************************************************************
" CONVERT TO JSON
***************************************************************************
LV_STRING_WRITER = CL_SXML_STRING_WRITER=>CREATE( TYPE = IF_SXML=>CO_XT_JSON ).
CALL TRANSFORMATION ID SOURCE ARRAY =  LT_FARASAVE RESULT XML LV_STRING_WRITER.
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
