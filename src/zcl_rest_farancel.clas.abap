class ZCL_REST_FARANCEL definition
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
      value(EO_REST) type ref to ZIF_REST_FARANCEL .
ENDCLASS.



CLASS ZCL_REST_FARANCEL IMPLEMENTATION.


  method GET_REST.
***************************************************************************
" VARIABLES
***************************************************************************
DATA: LV_CLASS_NAME           TYPE SEOCLSNAME,
      cl_fdt_json             TYPE REF TO cl_fdt_json,
      lx_root                 TYPE REF TO cx_root.
DATA: LV_REQUEST_METHOD       TYPE STRING,
      lv_req_body             TYPE STRING,
      ls_data                 TYPE ZCI_TTCUSTOMER, "ZMX_JSON_TT.
*      lt_final                TYPE TABLE OF ZMX_JSON_TT.
      ls_kna1 TYPE kna1.

***************************************************************************
" APPEND REQUEST METHOD TO BASE CLASS
***************************************************************************
LV_REQUEST_METHOD = IO_SERVER->REQUEST->GET_HEADER_FIELD( '~request_method' ).
lv_req_body = IO_SERVER->REQUEST->GET_CDATA( ).

  IF lv_req_body IS NOT INITIAL.
    REPLACE ALL OCCURRENCES OF REGEX '[^[:print:]]' IN lv_req_body WITH space.
    REPLACE ALL OCCURRENCES OF REGEX '#' IN lv_req_body WITH space.
    CONDENSE lv_req_body.
    CREATE OBJECT cl_fdt_json.
    TRY.
        CALL METHOD cl_fdt_json=>json_to_data
          EXPORTING
            iv_json = lv_req_body
          CHANGING
            ca_data = ls_data.
      CATCH cx_root INTO lx_root.
    ENDTRY.
  ENDIF.

LOOP AT ls_data INTO DATA(ls_cust).
    CALL FUNCTION 'KNA1_SINGLE_READER'
      EXPORTING
        i_kunnr         = ls_cust-kunnr
      IMPORTING
        o_kna1          = ls_kna1
      EXCEPTIONS
        not_found       = 1
        parameter_error = 2
        internal_error  = 3
        kunnr_blocked   = 4.

    IF sy-subrc <> 0.
    ENDIF.
*   LOOP AT ls_fracs-FRACS INTO DATA(ls_stawn).
*    write:/ ls_stawn-stawn.
*  ENDLOOP.

      ls_kna1-STKZN = ls_cust-stkzn.
      ls_kna1-stcd1 = ls_cust-stcd1.
      CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
        EXPORTING
          i_kna1                     = ls_kna1
          i_maintain_address_by_kna1 = ' '
        EXCEPTIONS
          client_error               = 1
          kna1_incomplete            = 2
          knb1_incomplete            = 3
          knb5_incomplete            = 4
          knvv_incomplete            = 5
          kunnr_not_unique           = 6
          sales_area_not_unique      = 7
          sales_area_not_valid       = 8
          insert_update_conflict     = 9
          number_assignment_error    = 10
          number_not_in_range        = 11
          number_range_not_extern    = 12
          number_range_not_intern    = 13
          account_group_not_valid    = 14
          parnr_invalid              = 15
          bank_address_invalid       = 16
          tax_data_not_valid         = 17
          no_authority               = 18
          company_code_not_unique    = 19
          dunning_data_not_valid     = 20
          knb1_reference_invalid     = 21
          cam_error                  = 22
          OTHERS                     = 23.
      IF sy-subrc = 0.

        "BAPI commit to update the changes in Data Base
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ELSE.
      ENDIF.
ENDLOOP.

CONCATENATE 'ZCL_REST_FARANCEL_' LV_REQUEST_METHOD INTO LV_CLASS_NAME.

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
DATA: LO_REST_CLASS     TYPE REF TO ZIF_REST_FARANCEL.
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
