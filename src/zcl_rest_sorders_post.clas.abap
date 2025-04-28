class ZCL_REST_SORDERS_POST definition
  public
  final
  create public .

public section.

  interfaces ZIF_REST_SORDERS .

  methods CONSTRUCTOR
    importing
      !IO_REQUEST type ref to IF_HTTP_REQUEST
      !IO_RESPONSE type ref to IF_HTTP_RESPONSE
      value(IN_SORDER) type ZSO_TTSALES .
protected section.

  data IN_PSORDER type ZSO_TTSALES .
private section.

  methods POST_SORDERS
    importing
      value(IO_REQUEST) type ref to IF_HTTP_REQUEST
    returning
      value(ET_SORDER) type ZSO_TTORDER .
ENDCLASS.



CLASS ZCL_REST_SORDERS_POST IMPLEMENTATION.


  method CONSTRUCTOR.
   ME->ZIF_REST_SORDERS~RESPONSE = IO_RESPONSE.
   ME->ZIF_REST_SORDERS~REQUEST = IO_REQUEST.
   IN_PSORDER = IN_SORDER.
  endmethod.


  method POST_SORDERS.
DATA: LT_SORDER TYPE ZSO_STORDER,
      wa_order_header_in TYPE bapisdhd1,
      lv_salesdocument TYPE bapivbeln-vbeln,
      it_return TYPE STANDARD TABLE OF bapiret2,
      it_order_items_in TYPE STANDARD TABLE OF bapisditm,
      wa_order_items_in TYPE bapisditm,
      it_order_schedules_in TYPE STANDARD TABLE OF bapischdl,
      wa_order_schedules_in TYPE bapischdl,
      it_order_conditions_in TYPE STANDARD TABLE OF bapicond,
      wa_order_conditions_in TYPE bapicond,
      it_order_text TYPE STANDARD TABLE OF bapisdtext,
      wa_order_text TYPE bapisdtext,
      it_order_partners TYPE STANDARD TABLE OF bapiparnr,
      wa_order_partners TYPE bapiparnr.

TYPES: BEGIN OF ty_vbpa3,
        vbeln TYPE VBELN,
        stcd1 TYPE STCD1,
        stcd2 TYPE STCD2,
        stkzn TYPE STKZN,
        name1 TYPE NAME1,
      END OF ty_vbpa3.
DATA: it_vbpa3 TYPE STANDARD TABLE OF ty_vbpa3,
      wa_vbpa3 TYPE ty_vbpa3.

DATA: i_xvbadr TYPE STANDARD TABLE OF sadrvb,
      i_xvbpa  TYPE STANDARD TABLE OF vbpavb,
      w_xvbpa  TYPE vbpavb,
      i_yvbadr TYPE STANDARD TABLE OF sadrvb,
      i_yvbpa  TYPE STANDARD TABLE OF vbpavb.

READ TABLE IN_PSORDER INDEX 1 INTO DATA(LS_PSORDER).
IF sy-subrc EQ 0.
  READ TABLE LS_PSORDER-HEADERDATA INDEX 1 INTO wa_order_header_in.
  IF sy-subrc EQ 0.

    SELECT SINGLE bezei INTO wa_order_header_in-incoterms2
      FROM tinct
      WHERE spras EQ sy-langu
        AND inco1 EQ wa_order_header_in-incoterms1.

    LOOP AT LS_PSORDER-ITEMSDATA INTO wa_order_items_in.
      wa_order_items_in-pmnttrms = wa_order_header_in-pmnttrms.
      wa_order_items_in-incoterms1 = wa_order_header_in-incoterms1.
      wa_order_items_in-incoterms2 = wa_order_header_in-incoterms2.
      APPEND wa_order_items_in TO it_order_items_in.


      wa_order_schedules_in-itm_number = wa_order_schedules_in-itm_number + 10.
      wa_order_schedules_in-req_qty    = wa_order_items_in-target_qty.
      APPEND wa_order_schedules_in TO it_order_schedules_in.
    ENDLOOP.

    LOOP AT LS_PSORDER-CONDITIONS INTO wa_order_conditions_in.
      APPEND wa_order_conditions_in TO it_order_conditions_in.
    ENDLOOP.

    LOOP AT LS_PSORDER-PARTNERS INTO DATA(LS_PARTNERS).
      MOVE-CORRESPONDING LS_PARTNERS TO wa_order_partners.
      APPEND wa_order_partners TO it_order_partners.
    ENDLOOP.

    LOOP AT LS_PSORDER-TEXTS INTO wa_order_text.
      wa_order_text-format_col = '*'.
      APPEND wa_order_text TO it_order_text.
    ENDLOOP.

    CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
      EXPORTING
        order_header_in     = wa_order_header_in
      IMPORTING
        salesdocument       = lv_salesdocument
      TABLES
        return              = it_return
        order_items_in      = it_order_items_in
        order_partners      = it_order_partners
        order_schedules_in  = it_order_schedules_in
        order_conditions_in = it_order_conditions_in
        order_text          = it_order_text.
    IF lv_salesdocument IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

      LT_SORDER-SALESORDER = lv_salesdocument.
      APPEND LT_SORDER TO ET_SORDER.

      LOOP AT LS_PSORDER-PARTNERS INTO DATA(LS_PARTNERSX).
        wa_vbpa3-stcd1 = LS_PARTNERSX-stcd1.
        wa_vbpa3-stcd2 = LS_PARTNERSX-stcd2.
        wa_vbpa3-stkzn = LS_PARTNERSX-stkzn.
        wa_vbpa3-name1 = LS_PARTNERSX-name.

        IF wa_vbpa3-stcd1 IS NOT INITIAL AND
           wa_vbpa3-stkzn IS NOT INITIAL OR
           wa_vbpa3-stcd2 IS NOT INITIAL.

          wa_vbpa3-vbeln = lv_salesdocument.
          APPEND wa_vbpa3 TO it_vbpa3.
        ENDIF.
      ENDLOOP.

    SELECT vbeln,posnr,parvw,kunnr,lifnr,pernr,parnr,adrnr,ablad,land1,adrda,xcpdk,hityp,prfre,
           bokre,histunr,knref,lzone,hzuor,stceg,parvw_ff,adrnp,kale
    INTO TABLE @DATA(it_vbpa)
    FROM vbpa
    FOR ALL ENTRIES IN @it_vbpa3
    WHERE vbeln = @it_vbpa3-vbeln
      AND parvw IN ('AG','RE','RG','WE').

    SELECT parvw,fehgr,nrart
    INTO TABLE @DATA(it_tpar)
    FROM tpar
    WHERE parvw IN ('AG','RE','RG','WE').

    SORT: it_vbpa3 BY vbeln,
          it_vbpa  BY vbeln posnr parvw,
          it_tpar  BY parvw.

    READ TABLE it_vbpa3 INDEX 1 INTO DATA(wa_vbpa3a).
    IF sy-subrc EQ 0.

      FREE i_xvbpa[].
      LOOP AT it_vbpa INTO DATA(wa_vbpa) WHERE vbeln = wa_vbpa3a-vbeln.

        MOVE-CORRESPONDING wa_vbpa3a TO w_xvbpa.
        MOVE-CORRESPONDING wa_vbpa TO w_xvbpa.
        w_xvbpa-vbeln = lv_salesdocument.

        READ TABLE it_tpar WITH KEY parvw = wa_vbpa-parvw INTO DATA(wa_tpar)
        BINARY SEARCH.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING wa_tpar TO w_xvbpa.
        ENDIF.

        w_xvbpa-updkz = 'U'.
        w_xvbpa-spras = 'E'.

        APPEND w_xvbpa TO i_xvbpa.
        CLEAR w_xvbpa.
      ENDLOOP.

      CALL FUNCTION 'SD_PARTNER_UPDATE'
        EXPORTING
          f_vbeln  = lv_salesdocument
          object   = 'VBPA'
        TABLES
          i_xvbadr = i_xvbadr
          i_xvbpa  = i_xvbpa  "LLENAR
          i_yvbadr = i_yvbadr
          i_yvbpa  = i_yvbpa.
    ENDIF.
    ENDIF.
  ENDIF.
ENDIF.
  endmethod.


  method ZIF_REST_SORDERS~HANDLE_REQUEST.
***************************************************************************
" VARIABLES
***************************************************************************
DATA: LT_SORDER         TYPE ZSO_TTORDER.
DATA: LV_STRING_WRITER  TYPE REF TO CL_SXML_STRING_WRITER.
DATA: LV_XSTRING        TYPE XSTRING.

***************************************************************************
" EXECUTE POST_SORDERS METHOD
***************************************************************************
TRY.

LT_SORDER = POST_SORDERS( ME->ZIF_REST_SORDERS~REQUEST ).

***************************************************************************
" CONVERT TO JSON
***************************************************************************
LV_STRING_WRITER = CL_SXML_STRING_WRITER=>CREATE( TYPE = IF_SXML=>CO_XT_JSON ).
CALL TRANSFORMATION ID SOURCE ARRAY = LT_SORDER RESULT XML LV_STRING_WRITER.
LV_XSTRING = LV_STRING_WRITER->GET_OUTPUT( ).

***************************************************************************
" ADD THE JSON TO THE RESPONSE
***************************************************************************
ME->ZIF_REST_SORDERS~RESPONSE->SET_DATA( DATA = LV_XSTRING ).

CATCH CX_ROOT.
ENDTRY.
  endmethod.


  method ZIF_REST_SORDERS~SET_RESPONSE.
    CALL METHOD ME->ZIF_REST_SORDERS~RESPONSE->SET_DATA
      EXPORTING
        DATA = IS_DATA.
  endmethod.
ENDCLASS.
