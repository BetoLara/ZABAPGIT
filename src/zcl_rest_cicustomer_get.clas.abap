class ZCL_REST_CICUSTOMER_GET definition
  public
  final
  create public .

public section.

  interfaces ZIF_REST_CI .

  methods CONSTRUCTOR
    importing
      !IO_REQUEST type ref to IF_HTTP_REQUEST
      !IO_RESPONSE type ref to IF_HTTP_RESPONSE .
protected section.
private section.

  methods GET_CUSTOMER
    importing
      value(IO_REQUEST) type ref to IF_HTTP_REQUEST
    returning
      value(ET_CUSTOMER) type ZCI_TTCUSTREG .
ENDCLASS.



CLASS ZCL_REST_CICUSTOMER_GET IMPLEMENTATION.


  method CONSTRUCTOR.
    ME->ZIF_REST_CI~RESPONSE = IO_RESPONSE.
    ME->ZIF_REST_CI~REQUEST = IO_REQUEST.
  endmethod.


  method GET_CUSTOMER.
***************************************************************************
" VARIABLES
***************************************************************************
DATA: w_custreg TYPE zci_stcustreg,
      w_customer TYPE zci_stcustomer,
      w_cocode TYPE zci_stcocode,
      w_sales TYPE zci_stsales,
      w_taxin TYPE zci_sttaxin,
      w_partner TYPE zci_stpartner,
      w_credit TYPE zci_stcredit,
      t_customer TYPE zci_ttcustomer,
      lv_ktokd TYPE KTOKD,
      lv_kunnr TYPE KUNNR,
      lr_kunnr TYPE RANGE OF KUNNR.

***************************************************************************
" GET HEADER PARAMETERS VALUE FROM URL
***************************************************************************
LV_KTOKD = ME->ZIF_REST_CI~REQUEST->GET_FORM_FIELD('ktokd').
LV_KUNNR = ME->ZIF_REST_CI~REQUEST->GET_FORM_FIELD('kunnr').

CHECK LV_KTOKD IS NOT INITIAL.

IF LV_KUNNR IS NOT INITIAL.
  UNPACK LV_KUNNR TO LV_KUNNR.
  lr_kunnr = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = LV_KUNNR ) ).
ENDIF.
************************************* *************************************
" GET CUSTOMER SELECT
***************************************************************************
SELECT kunnr,ktokd,adrnr,katr6,katr7,katr9,stcd1,stkzn,niels,lzone,katr10,kdkg2,
       stcdt,fityp,gform,kukla
  INTO TABLE @DATA(it_kna1)
  FROM kna1
  WHERE land1 = 'MX'
    AND ktokd = @lv_ktokd
    AND kunnr IN @lr_kunnr.
SORT it_kna1 BY kunnr.

IF ( 0 < LINES( it_kna1[] ) ).
SELECT addrnumber,name1,name2,name3,name4,sort1,str_suppl1,str_suppl2,street,house_num1,city2,
       post_code1,city1,country,region,taxjurcode,langu,tel_number,tel_extens
  INTO TABLE @DATA(it_adrc)
  FROM adrc
  FOR ALL ENTRIES IN @it_kna1
    WHERE addrnumber = @it_kna1-adrnr
      AND date_from = '00010101'.
SORT it_adrc BY addrnumber.

SELECT addrnumber,smtp_addr INTO TABLE @DATA(it_adr6)
  FROM adr6
  FOR ALL ENTRIES IN @it_kna1
    WHERE addrnumber = @it_kna1-adrnr
      AND date_from = '00010101'.
SORT it_adr6 BY addrnumber.

LOOP AT it_kna1 INTO DATA(wa_kna1).
  MOVE-CORRESPONDING wa_kna1 TO W_CUSTOMER.

  READ TABLE it_adrc WITH KEY addrnumber = wa_kna1-adrnr BINARY SEARCH
    INTO DATA(wa_adrc).
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING wa_adrc TO W_CUSTOMER.
  ENDIF.

  READ TABLE it_adr6 WITH KEY addrnumber = wa_kna1-adrnr BINARY SEARCH
    INTO DATA(wa_adr6).
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING wa_adr6 TO W_CUSTOMER.
  ENDIF.

  APPEND W_CUSTOMER TO T_CUSTOMER.
ENDLOOP.

SELECT kunnr,bukrs,akont,fdgrv,lockb,zuawa,xzver,wakon,zwels,zterm INTO TABLE @DATA(it_cocode)
  FROM knb1
  FOR ALL ENTRIES IN @it_kna1
    WHERE kunnr = @it_kna1-kunnr.
SORT it_cocode BY kunnr bukrs.

SELECT a~kunnr,b~bukrs,a~vkorg,a~vtweg,a~spart,a~bzirk,a~vkbur,a~vkgrp,a~kdgrp,a~waers,a~konda,a~kalks,
       a~pltyp,a~versg,a~inco1,a~zterm,a~vsbed,a~vwerk,a~kvgr1,a~kvgr4,a~kvgr5,a~lprio,a~bokre,a~inco2,
       a~ktgrd
  INTO TABLE @DATA(it_sales)
  FROM knvv AS a
  INNER JOIN tvko AS b
          ON b~vkorg = a~vkorg
  FOR ALL ENTRIES IN @it_kna1
    WHERE a~kunnr = @it_kna1-kunnr.
SORT it_sales BY kunnr bukrs vkorg vtweg spart.

SELECT kunnr,vkorg,vtweg,spart,hkunnr
  INTO TABLE @DATA(it_knvh)
  FROM knvh
  FOR ALL ENTRIES IN @it_kna1
    WHERE hityp = 'A'
      AND kunnr = @it_kna1-kunnr
      AND datbi = '99991231'.
SORT it_knvh BY kunnr vkorg vtweg spart.

SELECT kunnr,aland,tatyp,taxkd INTO TABLE @DATA(it_taxin)
  FROM knvi
  FOR ALL ENTRIES IN @it_kna1
    WHERE kunnr = @it_kna1-kunnr.
SORT it_taxin BY kunnr aland tatyp.

SELECT a~kunnr,b~bukrs,a~vkorg,a~vtweg,a~spart,a~parvw,a~parza,a~kunn2 INTO TABLE @DATA(it_partner)
  FROM knvp AS a
  INNER JOIN tvko AS b
          ON b~vkorg = a~vkorg
  FOR ALL ENTRIES IN @it_kna1
    WHERE a~kunnr = @it_kna1-kunnr.
SORT it_partner BY kunnr bukrs vkorg vtweg spart parvw parza.

SELECT kunnr,kkber,klimk,ctlpc,sbgrp INTO TABLE @DATA(it_credit)
  FROM knkk
  FOR ALL ENTRIES IN @it_kna1
    WHERE kunnr = @it_kna1-kunnr.
SORT it_credit BY kunnr kkber.
ENDIF. "0 < LINES

LOOP AT T_CUSTOMER INTO DATA(LS_CUSTOMER).
  LOOP AT it_cocode INTO DATA(ls_cocode) WHERE kunnr = LS_CUSTOMER-KUNNR.
    MOVE-CORRESPONDING ls_cocode TO w_cocode.
    APPEND w_cocode TO LS_CUSTOMER-COCDE.
  ENDLOOP.

  LOOP AT it_sales INTO DATA(ls_sales) WHERE kunnr = LS_CUSTOMER-KUNNR.
    MOVE-CORRESPONDING ls_sales TO w_sales.

    READ TABLE it_knvh WITH KEY kunnr = ls_sales-kunnr
                                vkorg = ls_sales-vkorg
                                vtweg = ls_sales-vtweg
                                spart = ls_sales-spart BINARY SEARCH INTO DATA(wa_knvh).
    IF sy-subrc EQ 0.
      MOVE wa_knvh-hkunnr TO w_sales-hkunnr.
    ENDIF.
    APPEND w_sales TO LS_CUSTOMER-SALES.
    CLEAR w_sales-hkunnr.
  ENDLOOP.

  LOOP AT it_taxin INTO DATA(ls_taxin) WHERE kunnr = LS_CUSTOMER-KUNNR.
    MOVE-CORRESPONDING ls_taxin TO w_taxin.
    APPEND w_taxin TO LS_CUSTOMER-TAXIND.
  ENDLOOP.

  LOOP AT it_partner INTO DATA(ls_partner) WHERE kunnr = LS_CUSTOMER-KUNNR.
    MOVE-CORRESPONDING ls_partner TO w_partner.
    APPEND w_partner TO LS_CUSTOMER-PARTNER.
  ENDLOOP.

  LOOP AT it_credit INTO DATA(ls_credit) WHERE kunnr = LS_CUSTOMER-KUNNR.
    MOVE-CORRESPONDING ls_credit TO w_credit.
    APPEND w_credit TO LS_CUSTOMER-CREDIT.
  ENDLOOP.
  MODIFY T_CUSTOMER FROM LS_CUSTOMER.
ENDLOOP.

W_CUSTREG-CUSTREG = 'NAR'.
APPEND w_custreg TO ET_CUSTOMER.

LOOP AT ET_CUSTOMER INTO DATA(LS_ETCUSTOMER).
  LOOP AT T_CUSTOMER INTO DATA(LS_TCUSTOMER).
    APPEND LS_TCUSTOMER TO LS_ETCUSTOMER-CUSTOMER.
  ENDLOOP.
  MODIFY ET_CUSTOMER FROM LS_ETCUSTOMER.
ENDLOOP.

  endmethod.


  method ZIF_REST_CI~HANDLE_REQUEST.
***************************************************************************
" VARIABLES
***************************************************************************
DATA: LT_CUSTOMER       TYPE ZCI_TTCUSTREG.
DATA: LV_STRING_WRITER  TYPE REF TO CL_SXML_STRING_WRITER.
DATA: LV_XSTRING        TYPE XSTRING.

***************************************************************************
" EXECUTE GET_CUSTOMER METHOD
***************************************************************************
TRY.

LT_CUSTOMER = GET_CUSTOMER( ME->ZIF_REST_CI~REQUEST ).

***************************************************************************
" CONVERT EQUIPMENTS TO JSON
***************************************************************************
LV_STRING_WRITER = CL_SXML_STRING_WRITER=>CREATE( TYPE = IF_SXML=>CO_XT_JSON ).
CALL TRANSFORMATION ID SOURCE ARRAY =  LT_CUSTOMER RESULT XML LV_STRING_WRITER.
LV_XSTRING = LV_STRING_WRITER->GET_OUTPUT( ).

***************************************************************************
" ADD THE JSON EQUIPMENTS TO THE RESPONSE
***************************************************************************
ME->ZIF_REST_CI~RESPONSE->SET_DATA( DATA = LV_XSTRING ).

CATCH CX_ROOT.
ENDTRY.
  endmethod.


  method ZIF_REST_CI~SET_RESPONSE.
    CALL METHOD ME->ZIF_REST_CI~RESPONSE->SET_DATA
      EXPORTING
        DATA = IS_DATA.
  endmethod.
ENDCLASS.
