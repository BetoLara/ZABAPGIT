class ZCL_REST_CICUSTOMER_PUT definition
  public
  final
  create public .

public section.

  interfaces ZIF_REST_CI .

  methods CONSTRUCTOR
    importing
      !IO_REQUEST type ref to IF_HTTP_REQUEST
      !IO_RESPONSE type ref to IF_HTTP_RESPONSE
      value(IN_CUST) type ZCI_TTCUSTREG .
protected section.

  data IN_PCUST type ZCI_TTCUSTREG .
private section.

  methods PUT_CUSTOMER_CRE
    importing
      value(IN_CUST) type ZCI_TTCUSTREG
    returning
      value(OU_RESP) type ZCI_TTRESPONSE .
  methods PUT_CUSTOMER_UPD
    importing
      !IN_CUST type ZCI_TTCUSTREG
    returning
      value(OU_RESP) type ZCI_TTRESPONSE .
ENDCLASS.



CLASS ZCL_REST_CICUSTOMER_PUT IMPLEMENTATION.


  method CONSTRUCTOR.
   ME->ZIF_REST_CI~RESPONSE = IO_RESPONSE.
   ME->ZIF_REST_CI~REQUEST = IO_REQUEST.
   IN_PCUST = IN_CUST.
  endmethod.


  method PUT_CUSTOMER_CRE.
DATA: LT_RESP TYPE ZCI_STRESPONSE,
      lv_messa TYPE CHAR50,
      lv_kunnr TYPE kunnr,
      lv_waers TYPE waers,
      lv_flag TYPE CHAR01,
      ls_kna1 TYPE kna1,
      ls_knb1 TYPE knb1,
      ls_knvv TYPE knvv,
      ls_BAPIADDR1 TYPE BAPIADDR1,
      it_xknvi TYPE STANDARD TABLE OF FKNVI,
      ls_xknvi TYPE FKNVI,
      it_xknvp TYPE STANDARD TABLE OF FKNVP,
      ls_xknvp TYPE FKNVP.

DATA: KNKA TYPE KNKA,
      KNKK TYPE KNKK,
      UPD_KNKA TYPE CDPOS-CHNGIND,
      UPD_KNKK TYPE CDPOS-CHNGIND,
      YKNKA TYPE KNKA,
      YKNKK TYPE KNKK.

READ TABLE IN_CUST INDEX 1 INTO DATA(LS_CUSTREG).
IF sy-subrc EQ 0.
  READ TABLE LS_CUSTREG-CUSTOMER INDEX 1 INTO DATA(LS_CUST).
  IF sy-subrc NE 0.
    LT_RESP-KUNNR = ''.
    LT_RESP-MESSA = 'Missing customer information'.
    APPEND LT_RESP TO OU_RESP.
    EXIT.
  ENDIF.
  MOVE-CORRESPONDING LS_CUST TO ls_kna1.
  IF LS_CUST-KTOKD = 'ZCPD'.
    ls_kna1-XCPDK = 'X'.
  ENDIF.

  MOVE-CORRESPONDING LS_CUST TO ls_BAPIADDR1.
  ls_BAPIADDR1-NAME = LS_CUST-NAME1.
  ls_BAPIADDR1-NAME_2 = LS_CUST-NAME2.
  ls_BAPIADDR1-NAME_3 = LS_CUST-NAME3.
  ls_BAPIADDR1-NAME_4 = LS_CUST-NAME4.
  ls_BAPIADDR1-SORT1 = LS_CUST-SORT1.
  ls_BAPIADDR1-CITY = LS_CUST-CITY1.
  ls_BAPIADDR1-DISTRICT = LS_CUST-CITY2.
  ls_BAPIADDR1-TRANSPZONE = LS_CUST-LZONE.
  ls_BAPIADDR1-STREET = LS_CUST-STREET.
  ls_BAPIADDR1-HOUSE_NO = LS_CUST-HOUSE_NUM1.
  ls_BAPIADDR1-POSTL_COD1 = LS_CUST-POST_CODE1.
  ls_BAPIADDR1-REGION = LS_CUST-REGION.
  ls_BAPIADDR1-E_MAIL = LS_CUST-SMTP_ADDR.
  ls_BAPIADDR1-TEL1_NUMBR = LS_CUST-TEL_NUMBER.
  ls_BAPIADDR1-TEL1_EXT = LS_CUST-TEL_EXTENS.
  ls_BAPIADDR1-TIME_ZONE = 'UTC-6'.

  READ TABLE LS_CUST-COCDE INDEX 1 INTO DATA(LS_COCDE).
  IF sy-subrc NE 0.
    LT_RESP-KUNNR = ''.
    LT_RESP-MESSA = 'Missing company code information'.
    APPEND LT_RESP TO OU_RESP.
    EXIT.
  ENDIF.
  MOVE-CORRESPONDING LS_COCDE TO ls_knb1.

  SELECT SINGLE waers INTO lv_waers FROM t001 WHERE bukrs = LS_COCDE-BUKRS.

  SORT LS_CUST-SALES BY BUKRS VKORG VTWEG SPART.
  READ TABLE LS_CUST-SALES WITH KEY BUKRS = LS_COCDE-BUKRS INTO DATA(LS_SALES).
  IF sy-subrc NE 0.
    LT_RESP-KUNNR = ''.
    LT_RESP-MESSA = 'Missing sales information'.
    APPEND LT_RESP TO OU_RESP.
    EXIT.
  ELSE.
    LOOP AT LS_CUST-SALES INTO DATA(LS_SALESV).
      SELECT SINGLE * FROM tvakz INTO @DATA(ls_tvakz)
        WHERE vkorg = @LS_SALESV-VKORG
          AND vtweg = @LS_SALESV-VTWEG
          AND spart = @LS_SALESV-SPART.
      IF sy-subrc NE 0.
        LT_RESP-KUNNR = ''.
        CONCATENATE 'Sales Area Not Valid' LS_SALESV-VKORG LS_SALESV-VTWEG LS_SALESV-SPART
        INTO lv_messa SEPARATED BY SPACE.
        LT_RESP-MESSA = lv_messa.
        APPEND LT_RESP TO OU_RESP.
        lv_flag = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF lv_flag = abap_true.
    EXIT.
  ENDIF.

  SORT LS_CUST-PARTNER BY BUKRS VKORG VTWEG SPART.
  READ TABLE LS_CUST-PARTNER WITH KEY BUKRS = LS_SALES-BUKRS
                                      VKORG = LS_SALES-VKORG
                                      VTWEG = LS_SALES-VTWEG
                                      SPART = LS_SALES-SPART INTO DATA(LS_PARTNER).
  IF sy-subrc NE 0.
    LT_RESP-KUNNR = ''.
    LT_RESP-MESSA = 'Missing partners information'.
    APPEND LT_RESP TO OU_RESP.
    EXIT.
  ENDIF.

  READ TABLE LS_CUST-TAXIND INDEX 1 INTO DATA(LS_TAXIND).
  IF sy-subrc NE 0.
    LT_RESP-KUNNR = ''.
    LT_RESP-MESSA = 'Missing tax information'.
    APPEND LT_RESP TO OU_RESP.
    EXIT.
  ENDIF.

  READ TABLE LS_CUST-CREDIT INDEX 1 INTO DATA(LS_CREDIT).
  IF sy-subrc NE 0.
    LT_RESP-KUNNR = ''.
    LT_RESP-MESSA = 'Missing credit information'.
    APPEND LT_RESP TO OU_RESP.
    EXIT.
  ENDIF.
ENDIF.

CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
  EXPORTING
    i_kna1                     = ls_kna1
    i_knb1                     = ls_knb1
    I_BAPIADDR1                = ls_BAPIADDR1
    i_maintain_address_by_kna1 = ' '
  IMPORTING
    E_KUNNR                    = lv_kunnr
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

  LT_RESP-KUNNR = lv_kunnr.
  LT_RESP-MESSA = 'Successful entry'.
  APPEND LT_RESP TO OU_RESP.

  "BAPI commit to update the changes in Data Base
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = abap_true.

  LOOP AT LS_CUST-COCDE INTO DATA(LS_COCDEX).
    MOVE-CORRESPONDING LS_COCDEX TO ls_knb1.
    ls_knb1-kunnr = lv_kunnr.
    LOOP AT LS_CUST-SALES INTO DATA(LS_SALESX) WHERE BUKRS = LS_COCDEX-BUKRS.
      MOVE-CORRESPONDING LS_SALESX TO ls_knvv.
      ls_kna1-kunnr = lv_kunnr.
      ls_kna1-erdat = sy-datum.
      ls_kna1-ernam = sy-uname.
      ls_knvv-kunnr = lv_kunnr.
      ls_knvv-awahr = '100'.
      ls_knvv-antlf = '9'.

      FREE: IT_XKNVP[], ls_xknvp.
      LOOP AT LS_CUST-PARTNER INTO DATA(LS_PARTNERX)
        WHERE BUKRS = LS_SALESX-BUKRS
          AND VKORG = LS_SALESX-VKORG
          AND VTWEG = LS_SALESX-VTWEG
          AND SPART = LS_SALESX-SPART.

        IF LS_PARTNERX-PARVW IS INITIAL. CONTINUE. ENDIF.

        MOVE-CORRESPONDING LS_PARTNERX TO ls_xknvp.

        ls_xknvp-kunnr = lv_kunnr.
        IF ls_xknvp-kunn2 IS INITIAL.
          ls_xknvp-kunn2 = lv_kunnr.
        ELSE.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = ls_xknvp-kunn2
            IMPORTING
              output = ls_xknvp-kunn2.
        ENDIF.
        APPEND ls_xknvp TO IT_XKNVP.
      ENDLOOP.

      CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
        EXPORTING
          i_kna1                     = ls_kna1
          i_knb1                     = ls_knb1
          i_knvv                     = ls_knvv
          i_maintain_address_by_kna1 = ' '
         TABLES
          T_XKNVP                    = IT_XKNVP
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
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ENDIF.
    ENDLOOP.
  ENDLOOP. "LS_CUST-COCDE

* Tax Indicator Information
  LOOP AT LS_CUST-TAXIND INTO DATA(LS_TAXINDX).
    FREE: IT_XKNVI[], ls_xknvi.
    ls_xknvi-KUNNR = lv_kunnr.
    ls_xknvi-ALAND = LS_TAXINDX-ALAND.
    ls_xknvi-TATYP = LS_TAXINDX-TATYP.
    ls_xknvi-TAXKD = LS_TAXINDX-TAXKD.
    APPEND ls_xknvi TO it_xknvi.

    CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
      EXPORTING
        i_kna1                     = ls_kna1
        i_maintain_address_by_kna1 = ' '
       TABLES
        T_XKNVI                    = IT_XKNVI
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
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
    ELSE.
      CONCATENATE 'Invalid Tax Indicator' LS_TAXINDX-ALAND LS_TAXINDX-TATYP LS_TAXINDX-TAXKD
                   INTO lv_messa SEPARATED BY SPACE.
      LT_RESP-KUNNR = lv_kunnr.
      LT_RESP-MESSA = lv_messa.
      APPEND LT_RESP TO OU_RESP.
    ENDIF.
  ENDLOOP. "LS_CUST-TAXIND

* Credit Information
  LOOP AT LS_CUST-CREDIT INTO DATA(LS_CREDITX).
* Central Data
    SELECT SINGLE * FROM knka INTO KNKA
      WHERE kunnr = lv_kunnr.
    IF sy-subrc NE 0.
      UPD_KNKA = 'I'.
      knka-KUNNR = lv_kunnr.
      knka-KLIMG = '1'.
      knka-KLIME = '1'.
      knka-WAERS = lv_waers.
    ELSE.
      UPD_KNKA = 'U'.
      knka-KUNNR = lv_kunnr.
      knka-KLIMG = '1'.
      knka-KLIME = '1'.
      knka-WAERS = lv_waers.
    ENDIF.

* Control Area Data
    SELECT SINGLE * FROM knkk INTO KNKK
      WHERE kunnr = lv_kunnr
        AND KKBER = LS_CREDITX-KKBER.
    IF sy-subrc NE 0.
      UPD_KNKK = 'I'.
      knkk-KUNNR = lv_kunnr.
      knkk-KKBER = LS_CREDITX-KKBER.
      knkk-KLIMK = LS_CREDITX-KLIMK.
      knkk-KNKLI = lv_kunnr.
      knkk-CTLPC = LS_CREDITX-CTLPC.
      knkk-SBGRP = LS_CREDITX-SBGRP.
      knkk-erdat = sy-datum.
      knkk-ernam = sy-uname.
      knkk-aedat = sy-datum.
      knkk-aenam = sy-uname.
    ENDIF.

    CALL FUNCTION 'CREDITLIMIT_CHANGE'
      EXPORTING
        I_KNKA   = KNKA
        I_KNKK   = KNKK
        UPD_KNKA = UPD_KNKA
        UPD_KNKK = UPD_KNKK
        XNEUA    = ''
        XREFL    = ''
        YKNKA    = YKNKA
        YKNKK    = YKNKK.
    IF sy-subrc EQ 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
    ENDIF.
  ENDLOOP.
ELSE.
  CASE sy-subrc.
    WHEN 1.
      LT_RESP-MESSA = 'client error'.
    WHEN 2.
      LT_RESP-MESSA = 'kna1 incomplete'.
    WHEN 3.
      LT_RESP-MESSA = 'knb1 incomplete'.
    WHEN 4.
      LT_RESP-MESSA = 'knb5 incomplete'.
    WHEN 5.
      LT_RESP-MESSA = 'knvv incomplete'.
    WHEN 6.
      LT_RESP-MESSA = 'kunnr not unique'.
    WHEN 7.
      LT_RESP-MESSA = 'sales area not unique'.
    WHEN 8.
      LT_RESP-MESSA = 'sales area not valid'.
    WHEN 9.
      LT_RESP-MESSA = 'insert update conflict'.
    WHEN 10.
      LT_RESP-MESSA = 'number assignment error'.
    WHEN 11.
      LT_RESP-MESSA = 'number not in range'.
    WHEN 12.
      LT_RESP-MESSA = 'number range not extern'.
    WHEN 13.
      LT_RESP-MESSA = 'number range not intern'.
    WHEN 14.
      LT_RESP-MESSA = 'account group not valid'.
    WHEN 15.
      LT_RESP-MESSA = 'parnr invalid'.
    WHEN 16.
      LT_RESP-MESSA = 'bank address invalid'.
    WHEN 17.
      LT_RESP-MESSA = 'tax data not valid'.
    WHEN 18.
      LT_RESP-MESSA = 'no authority'.
    WHEN 19.
      LT_RESP-MESSA = 'company code not unique'.
    WHEN 20.
      LT_RESP-MESSA = 'dunning data not valid'.
    WHEN 21.
      LT_RESP-MESSA = 'knb1 reference invalid'.
    WHEN 22.
      LT_RESP-MESSA = 'cam error'.
    WHEN 23.
      LT_RESP-MESSA = 'customer error'.
    WHEN OTHERS.
      LT_RESP-MESSA = 'customer error'.
  ENDCASE.
  APPEND LT_RESP TO OU_RESP.
ENDIF.
  endmethod.


  method PUT_CUSTOMER_UPD.
DATA: LT_RESP TYPE ZCI_STRESPONSE,
      lv_messa TYPE CHAR50,
      lv_flag TYPE CHAR01,
      lv_change TYPE CHAR01,
      lv_chtran TYPE CHAR01,
      lv_chproc TYPE CHAR01,
      lv_chcred TYPE CHAR01,
      ls_kna1 TYPE kna1,
      ls_knb1 TYPE knb1,
      ls_knvv TYPE knvv,
      ls_BAPIADDR1 TYPE BAPIADDR1,
      it_xknvi TYPE STANDARD TABLE OF FKNVI,
      ls_xknvi TYPE FKNVI,
      it_xknvp TYPE STANDARD TABLE OF FKNVP,
      ls_xknvp TYPE FKNVP,
      it_knvv TYPE STANDARD TABLE OF KNVV.

DATA: KNKA TYPE KNKA,
      KNKK TYPE KNKK,
      UPD_KNKA TYPE CDPOS-CHNGIND,
      UPD_KNKK TYPE CDPOS-CHNGIND,
      YKNKA TYPE KNKA,
      YKNKK TYPE KNKK,
      lv_waers TYPE waers.

DATA: it_node TYPE STANDARD TABLE OF bapikna1_knvh_process,
      ls_node TYPE bapikna1_knvh_process,
      it_return TYPE STANDARD TABLE OF bapiret2.

DEFINE MChange.
  IF &1 NE &2.
    lv_change = 'X'.
  ELSE.
    lv_change = ''.
  ENDIF.
END-OF-DEFINITION.

READ TABLE IN_CUST INDEX 1 INTO DATA(LS_CUSTREG).
IF sy-subrc EQ 0.
  READ TABLE LS_CUSTREG-CUSTOMER INDEX 1 INTO DATA(LS_CUST).

* Validate Sales Information
  LOOP AT LS_CUST-SALES INTO DATA(LS_SALESV).
    SELECT SINGLE * FROM tvakz INTO @DATA(ls_tvakz)
      WHERE vkorg = @LS_SALESV-VKORG
        AND vtweg = @LS_SALESV-VTWEG
        AND spart = @LS_SALESV-SPART.
    IF sy-subrc NE 0.
      LT_RESP-KUNNR = ''.
      CONCATENATE 'Sales Area Not Valid' LS_SALESV-VKORG LS_SALESV-VTWEG LS_SALESV-SPART
      INTO lv_messa SEPARATED BY SPACE.
      LT_RESP-MESSA = lv_messa.
      APPEND LT_RESP TO OU_RESP.
      lv_flag = abap_true.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF lv_flag = abap_true.
    EXIT.
  ENDIF.

* Customer Information
  SELECT SINGLE * FROM kna1 INTO @DATA(lsb_kna1)
    WHERE kunnr = @LS_CUST-KUNNR.
  IF sy-subrc EQ 0.
    CLEAR lv_chtran.
    MChange lsb_kna1-KATR6 LS_CUST-KATR6.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_kna1-KATR7 LS_CUST-KATR7.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_kna1-KATR9 LS_CUST-KATR9.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_kna1-STCD1 LS_CUST-STCD1.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_kna1-STKZN LS_CUST-STKZN.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_kna1-NIELS LS_CUST-NIELS.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_kna1-LZONE LS_CUST-LZONE.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_kna1-KATR10 LS_CUST-KATR10.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_kna1-KDKG2 LS_CUST-KDKG2.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_kna1-STCDT LS_CUST-STCDT.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_kna1-FITYP LS_CUST-FITYP.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_kna1-GFORM LS_CUST-GFORM.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_kna1-KUKLA LS_CUST-KUKLA.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    IF lv_chtran IS NOT INITIAL.
      MOVE-CORRESPONDING lsb_kna1 TO ls_kna1.
      MOVE-CORRESPONDING LS_CUST TO ls_kna1.
      lv_chproc = 'X'.
    ELSE.
      MOVE-CORRESPONDING lsb_kna1 TO ls_kna1.
    ENDIF.
  ENDIF.

  SELECT SINGLE * FROM adrc INTO @DATA(lsb_adrc)
    WHERE addrnumber = @lsb_kna1-adrnr
      AND date_from = '00010101'.
  IF sy-subrc EQ 0.
    CLEAR lv_chtran.
    MChange lsb_adrc-NAME1 LS_CUST-NAME1.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_adrc-NAME2 LS_CUST-NAME2.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_adrc-NAME3 LS_CUST-NAME3.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_adrc-NAME4 LS_CUST-NAME4.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_adrc-SORT1 LS_CUST-SORT1.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_adrc-STR_SUPPL1 LS_CUST-STR_SUPPL1.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_adrc-STR_SUPPL2 LS_CUST-STR_SUPPL2.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_adrc-STREET LS_CUST-STREET.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_adrc-HOUSE_NUM1 LS_CUST-HOUSE_NUM1.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_adrc-CITY2 LS_CUST-CITY2.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_adrc-POST_CODE1 LS_CUST-POST_CODE1.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_adrc-CITY1 LS_CUST-CITY1.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_adrc-COUNTRY LS_CUST-COUNTRY.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_adrc-REGION LS_CUST-REGION.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_adrc-TAXJURCODE LS_CUST-TAXJURCODE.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_adrc-LANGU LS_CUST-LANGU.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_adrc-TEL_NUMBER LS_CUST-TEL_NUMBER.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    MChange lsb_adrc-TEL_EXTENS LS_CUST-TEL_EXTENS.
    IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.

    SELECT SINGLE * FROM adr6 INTO @DATA(lsb_adr6)
      WHERE addrnumber = @lsb_kna1-adrnr
        AND date_from = '00010101'.
    IF sy-subrc EQ 0.
      MChange lsb_adr6-SMTP_ADDR LS_CUST-SMTP_ADDR.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
    ELSE.
      lv_chtran = 'X'.
    ENDIF.

    IF lv_chtran IS NOT INITIAL.
      MOVE-CORRESPONDING lsb_adrc TO ls_BAPIADDR1.
      ls_BAPIADDR1-ADDR_NO = lsb_kna1-adrnr.
      ls_BAPIADDR1-NAME = LS_CUST-NAME1.
      ls_BAPIADDR1-NAME_2 = LS_CUST-NAME2.
      ls_BAPIADDR1-NAME_3 = LS_CUST-NAME3.
      ls_BAPIADDR1-NAME_4 = LS_CUST-NAME4.
      ls_BAPIADDR1-SORT1 = LS_CUST-SORT1.
      ls_BAPIADDR1-STR_SUPPL1 = LS_CUST-STR_SUPPL1.
      ls_BAPIADDR1-STR_SUPPL2 = LS_CUST-STR_SUPPL2.
      ls_BAPIADDR1-STREET = LS_CUST-STREET.
      ls_BAPIADDR1-HOUSE_NO = LS_CUST-HOUSE_NUM1.
      ls_BAPIADDR1-DISTRICT = LS_CUST-CITY2.
      ls_BAPIADDR1-POSTL_COD1 = LS_CUST-POST_CODE1.
      ls_BAPIADDR1-CITY = LS_CUST-CITY1.
      ls_BAPIADDR1-COUNTRY = LS_CUST-COUNTRY.
      ls_BAPIADDR1-REGION = LS_CUST-REGION.
      ls_BAPIADDR1-TAXJURCODE = LS_CUST-TAXJURCODE.
      ls_BAPIADDR1-LANGU = LS_CUST-LANGU.
      ls_BAPIADDR1-TEL1_NUMBR = LS_CUST-TEL_NUMBER.
      ls_BAPIADDR1-TEL1_EXT = LS_CUST-TEL_EXTENS.
      ls_BAPIADDR1-E_MAIL = LS_CUST-SMTP_ADDR.
      lv_chproc = 'X'.
    ENDIF.
  ENDIF.

  IF lv_chproc IS NOT INITIAL.
    CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
      EXPORTING
        i_kna1                     = ls_kna1
        I_BAPIADDR1                = ls_BAPIADDR1
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
      IF OU_RESP[] IS INITIAL.
        LT_RESP-KUNNR = LS_CUST-KUNNR.
        LT_RESP-MESSA = 'Successful change'.
        APPEND LT_RESP TO OU_RESP.
      ENDIF.

      "BAPI commit to update the changes in Data Base
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
    ENDIF.
  ENDIF.

* Company Code Information
  LOOP AT  LS_CUST-COCDE INTO DATA(LS_COCDE).
    CLEAR: lv_chproc, lv_chtran, ls_knb1.
    SELECT SINGLE waers INTO lv_waers FROM t001 WHERE bukrs = LS_COCDE-BUKRS.

    SELECT SINGLE * FROM knb1 INTO @DATA(lsb_knb1)
      WHERE kunnr = @LS_CUST-KUNNR
        AND bukrs = @LS_COCDE-BUKRS.
    IF sy-subrc EQ 0.
      CLEAR lv_chtran.
      MChange lsb_knb1-AKONT LS_COCDE-AKONT.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knb1-FDGRV LS_COCDE-FDGRV.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knb1-LOCKB LS_COCDE-LOCKB.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knb1-ZUAWA LS_COCDE-ZUAWA.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knb1-XZVER LS_COCDE-XZVER.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knb1-WAKON LS_COCDE-WAKON.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knb1-ZWELS LS_COCDE-ZWELS.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knb1-ZTERM LS_COCDE-ZTERM.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.

      IF lv_chtran IS NOT INITIAL.
        MOVE-CORRESPONDING lsb_knb1 TO ls_knb1.
        MOVE-CORRESPONDING LS_COCDE TO ls_knb1.
        ls_knb1-kunnr = LS_CUST-KUNNR.
        lv_chproc = 'X'.
      ENDIF.
    ELSE.
      MOVE-CORRESPONDING LS_COCDE TO ls_knb1.
      ls_knb1-kunnr = LS_CUST-KUNNR.
      lv_chproc = 'X'.
    ENDIF.

    IF lv_chproc IS NOT INITIAL.
      CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
        EXPORTING
          i_kna1                     = ls_kna1
          i_knb1                     = ls_knb1
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
        IF OU_RESP[] IS INITIAL.
          LT_RESP-KUNNR = LS_CUST-KUNNR.
          LT_RESP-MESSA = 'Successful change'.
          APPEND LT_RESP TO OU_RESP.
        ENDIF.

        "BAPI commit to update the changes in Data Base
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Sales Information
  LOOP AT LS_CUST-SALES INTO DATA(LS_SALES).
    CLEAR: lv_chproc, lv_chtran, ls_knvv.
    SELECT SINGLE * FROM knvv INTO @DATA(lsb_knvv)
     WHERE kunnr = @LS_CUST-KUNNR
       AND vkorg = @LS_SALES-VKORG
       AND vtweg = @LS_SALES-VTWEG
       AND spart = @LS_SALES-SPART.
    IF sy-subrc EQ 0.
      CLEAR: lv_chtran, lv_chproc.
      MChange lsb_knvv-BZIRK LS_SALES-BZIRK.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-VKBUR LS_SALES-VKBUR.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-VKGRP LS_SALES-VKGRP.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-KDGRP LS_SALES-KDGRP.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-WAERS LS_SALES-WAERS.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-KONDA LS_SALES-KONDA.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-KALKS LS_SALES-KALKS.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-PLTYP LS_SALES-PLTYP.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-VERSG LS_SALES-VERSG.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-INCO1 LS_SALES-INCO1.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-ZTERM LS_SALES-ZTERM.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-VSBED LS_SALES-VSBED.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-VWERK LS_SALES-VWERK.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-KVGR1 LS_SALES-KVGR1.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-KVGR4 LS_SALES-KVGR4.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-KVGR5 LS_SALES-KVGR5.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-LPRIO LS_SALES-LPRIO.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-bokre LS_SALES-BOKRE.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-inco2 LS_SALES-INCO2.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
      MChange lsb_knvv-ktgrd LS_SALES-KTGRD.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.

      IF lv_chtran IS NOT INITIAL.
        MOVE-CORRESPONDING lsb_knvv TO ls_knvv.
        MOVE-CORRESPONDING LS_SALES TO ls_knvv.
        lv_chproc = 'X'.
      ELSE.
        MOVE-CORRESPONDING lsb_knvv TO ls_knvv.
      ENDIF.
    ELSE.
      MOVE-CORRESPONDING LS_SALES TO ls_knvv.
      ls_knvv-kunnr = LS_CUST-KUNNR.
      lv_chproc = 'X'.
    ENDIF.

* Partner Information
    FREE IT_XKNVP[].
    LOOP AT LS_CUST-PARTNER INTO DATA(LS_PARTNER)
      WHERE VKORG = LS_SALES-VKORG
        AND VTWEG = LS_SALES-VTWEG
        AND SPART = LS_SALES-SPART.

      IF LS_PARTNER-PARVW IS INITIAL. CONTINUE. ENDIF.

      CLEAR ls_xknvp.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = LS_PARTNER-KUNN2
        IMPORTING
          output = LS_PARTNER-KUNN2.

      SELECT SINGLE * FROM knvp INTO @DATA(lsb_knvp)
        WHERE kunnr = @LS_CUST-KUNNR
          AND vkorg = @LS_PARTNER-VKORG
          AND vtweg = @LS_PARTNER-VTWEG
          AND spart = @LS_PARTNER-SPART
          AND parvw = @LS_PARTNER-PARVW
          AND parza = @LS_PARTNER-PARZA.
      IF sy-subrc NE 0.
        SELECT SINGLE * FROM knvp INTO @DATA(lsb_knvpx)
          WHERE kunnr = @LS_CUST-KUNNR
            AND vkorg = @LS_PARTNER-VKORG
            AND vtweg = @LS_PARTNER-VTWEG
            AND spart = @LS_PARTNER-SPART
            AND parvw = @LS_PARTNER-PARVW
            AND kunn2 = @LS_PARTNER-KUNN2.
        IF sy-subrc NE 0.
          MOVE-CORRESPONDING LS_PARTNER TO ls_xknvp.
          ls_xknvp-KUNNR = LS_CUST-KUNNR.
          APPEND ls_xknvp TO it_xknvp.
          lv_chproc = 'X'.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lv_chproc IS NOT INITIAL.
      CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
        EXPORTING
          i_kna1                     = ls_kna1
          i_knvv                     = ls_knvv
          i_maintain_address_by_kna1 = ' '
        TABLES
          T_XKNVP                    = IT_XKNVP
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
        IF OU_RESP[] IS INITIAL.
          LT_RESP-KUNNR = LS_CUST-KUNNR.
          LT_RESP-MESSA = 'Successful change'.
          APPEND LT_RESP TO OU_RESP.
        ENDIF.

        "BAPI commit to update the changes in Data Base
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Partner Information
  SELECT vkorg,vtweg,spart INTO TABLE @DATA(it_sales)
    FROM knvv
    WHERE kunnr = @LS_CUST-KUNNR.
  SORT it_sales BY vkorg vtweg spart.

  LOOP AT it_sales INTO DATA(LS_SALESX).
    CLEAR lv_chproc.
    FREE IT_XKNVP[].
    LOOP AT LS_CUST-PARTNER INTO DATA(LS_PARTNERX)
      WHERE VKORG = LS_SALESX-VKORG
        AND VTWEG = LS_SALESX-VTWEG
        AND SPART = LS_SALESX-SPART.

      IF LS_PARTNERX-PARVW IS INITIAL. CONTINUE. ENDIF.

      CLEAR ls_xknvp.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = LS_PARTNERX-KUNN2
        IMPORTING
          output = LS_PARTNERX-KUNN2.

      SELECT SINGLE * FROM knvp INTO @DATA(lsb_knvp1)
        WHERE kunnr = @LS_CUST-KUNNR
          AND vkorg = @LS_PARTNERX-VKORG
          AND vtweg = @LS_PARTNERX-VTWEG
          AND spart = @LS_PARTNERX-SPART
          AND parvw = @LS_PARTNERX-PARVW
          AND parza = @LS_PARTNERX-PARZA.
      IF sy-subrc NE 0.
        SELECT SINGLE * FROM knvp INTO @DATA(lsb_knvpx1)
          WHERE kunnr = @LS_CUST-KUNNR
            AND vkorg = @LS_PARTNERX-VKORG
            AND vtweg = @LS_PARTNERX-VTWEG
            AND spart = @LS_PARTNERX-SPART
            AND parvw = @LS_PARTNERX-PARVW
            AND kunn2 = @LS_PARTNERX-KUNN2.
        IF sy-subrc NE 0.
          MOVE-CORRESPONDING LS_PARTNERX TO ls_xknvp.
          ls_xknvp-KUNNR = LS_CUST-KUNNR.
          APPEND ls_xknvp TO it_xknvp.
          lv_chproc = 'X'.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lv_chproc IS NOT INITIAL.
      CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
        EXPORTING
          i_kna1                     = ls_kna1
          i_maintain_address_by_kna1 = ' '
        TABLES
          T_XKNVP                    = IT_XKNVP
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
        IF OU_RESP[] IS INITIAL.
          LT_RESP-KUNNR = LS_CUST-KUNNR.
          LT_RESP-MESSA = 'Successful change'.
          APPEND LT_RESP TO OU_RESP.
        ENDIF.

        "BAPI commit to update the changes in Data Base
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Credit Information
  LOOP AT LS_CUST-CREDIT INTO DATA(LS_CREDIT).
    CLEAR lv_chcred.
    SELECT SINGLE * FROM knkk INTO @DATA(lsb_knkk)
      WHERE kunnr = @LS_CUST-KUNNR
        AND kkber = @LS_CREDIT-KKBER.
    IF sy-subrc EQ 0.
      IF lsb_knkk-KLIMK NE LS_CREDIT-KLIMK OR
         lsb_knkk-CTLPC NE LS_CREDIT-CTLPC OR
         lsb_knkk-SBGRP NE LS_CREDIT-SBGRP.
        lv_chcred = 'X'.
        UPD_KNKK = 'U'.
        MOVE-CORRESPONDING lsb_knkk TO knkk.
        knkk-klimk = LS_CREDIT-KLIMK.
        knkk-ctlpc = LS_CREDIT-CTLPC.
        knkk-sbgrp = LS_CREDIT-SBGRP.
        knkk-aedat = sy-datum.
        knkk-aenam = sy-uname.
      ENDIF.
    ELSE.
      lv_chcred = 'X'.
      UPD_KNKK = 'I'.
      knkk-KUNNR = LS_CUST-KUNNR.
      knkk-KKBER = LS_CREDIT-KKBER.
      knkk-KLIMK = LS_CREDIT-KLIMK.
      knkk-KNKLI = LS_CUST-KUNNR.
      knkk-CTLPC = LS_CREDIT-CTLPC.
      knkk-SBGRP = LS_CREDIT-SBGRP.
      knkk-erdat = sy-datum.
      knkk-ernam = sy-uname.
      knkk-aedat = sy-datum.
      knkk-aenam = sy-uname.
    ENDIF.

    IF lv_chcred IS NOT INITIAL.
* Central Data
      SELECT SINGLE * FROM knka INTO KNKA
        WHERE kunnr = LS_CUST-KUNNR.
      IF sy-subrc NE 0.
        UPD_KNKA = 'I'.
        knka-KUNNR = LS_CUST-KUNNR.
        knka-KLIMG = '1'.
        knka-KLIME = '1'.
        knka-WAERS = lv_waers.
      ELSE.
        UPD_KNKA = 'U'.
      ENDIF.

      CALL FUNCTION 'CREDITLIMIT_CHANGE'
        EXPORTING
          I_KNKA   = KNKA
          I_KNKK   = KNKK
          UPD_KNKA = UPD_KNKA
          UPD_KNKK = UPD_KNKK
          XNEUA    = ''
          XREFL    = ''
          YKNKA    = YKNKA
          YKNKK    = YKNKK.
      IF sy-subrc EQ 0.
        IF OU_RESP[] IS INITIAL.
          LT_RESP-KUNNR = LS_CUST-KUNNR.
          LT_RESP-MESSA = 'Successful change'.
          APPEND LT_RESP TO OU_RESP.
        ENDIF.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Tax Information
  LOOP AT LS_CUST-TAXIND INTO DATA(LS_TAXIND).
    CLEAR: lv_chproc, lv_chtran.
    FREE: IT_XKNVI[], ls_xknvi.
    SELECT SINGLE * FROM knvi INTO @DATA(lsb_knvi)
      WHERE kunnr = @LS_CUST-KUNNR
        AND aland = @LS_TAXIND-ALAND
        AND tatyp = @LS_TAXIND-TATYP.
    IF sy-subrc EQ 0.
      CLEAR lv_chtran.
      MChange lsb_knvi-TAXKD LS_TAXIND-TAXKD.
      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.

      IF lv_chtran IS NOT INITIAL.
        lsb_knvi-TAXKD = LS_TAXIND-TAXKD.
        APPEND lsb_knvi TO it_xknvi.
        lv_chproc = 'X'.
      ENDIF.
    ELSE.
      ls_xknvi-KUNNR = LS_CUST-KUNNR.
      ls_xknvi-ALAND = LS_TAXIND-ALAND.
      ls_xknvi-TATYP = LS_TAXIND-TATYP.
      ls_xknvi-TAXKD = LS_TAXIND-TAXKD.
      APPEND ls_xknvi TO it_xknvi.
      lv_chproc = 'X'.
    ENDIF.

    IF lv_chproc IS NOT INITIAL.
      CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
        EXPORTING
          i_kna1                     = ls_kna1
          i_maintain_address_by_kna1 = ' '
         TABLES
          T_XKNVI                    = IT_XKNVI
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
        IF OU_RESP[] IS INITIAL.
          LT_RESP-KUNNR = LS_CUST-KUNNR.
          LT_RESP-MESSA = 'Successful change'.
          APPEND LT_RESP TO OU_RESP.
        ENDIF.

        "BAPI commit to update the changes in Data Base
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ELSE.
        CONCATENATE 'Invalid Tax Indicator' LS_TAXIND-ALAND LS_TAXIND-TATYP LS_TAXIND-TAXKD
                     INTO lv_messa SEPARATED BY SPACE.
        LT_RESP-KUNNR = LS_CUST-KUNNR.
        LT_RESP-MESSA = lv_messa.
        APPEND LT_RESP TO OU_RESP.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDIF.

** Sales Information Start
*  LOOP AT LS_CUST-SALES INTO DATA(LS_SALES).
*    SELECT SINGLE * FROM knvv INTO @DATA(lsb_knvv)
*     WHERE kunnr = @LS_CUST-KUNNR
*       AND vkorg = @LS_SALES-VKORG
*       AND vtweg = @LS_SALES-VTWEG
*       AND spart = @LS_SALES-SPART.
*    IF sy-subrc EQ 0.
*      CLEAR: lv_chtran, lv_chsale.
*      MChange lsb_knvv-BZIRK LS_SALES-BZIRK.
*      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
*      MChange lsb_knvv-VKBUR LS_SALES-VKBUR.
*      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
*      MChange lsb_knvv-VKGRP LS_SALES-VKGRP.
*      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
*      MChange lsb_knvv-KDGRP LS_SALES-KDGRP.
*      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
*      MChange lsb_knvv-WAERS LS_SALES-WAERS.
*      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
*      MChange lsb_knvv-KONDA LS_SALES-KONDA.
*      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
*      MChange lsb_knvv-KALKS LS_SALES-KALKS.
*      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
*      MChange lsb_knvv-PLTYP LS_SALES-PLTYP.
*      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
*      MChange lsb_knvv-VERSG LS_SALES-VERSG.
*      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
*      MChange lsb_knvv-INCO1 LS_SALES-INCO1.
*      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
*      MChange lsb_knvv-ZTERM LS_SALES-ZTERM.
*      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
*      MChange lsb_knvv-VSBED LS_SALES-VSBED.
*      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
*      MChange lsb_knvv-VWERK LS_SALES-VWERK.
*      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
*      MChange lsb_knvv-KVGR1 LS_SALES-KVGR1.
*      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
*      MChange lsb_knvv-KVGR4 LS_SALES-KVGR4.
*      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
*      MChange lsb_knvv-KVGR5 LS_SALES-KVGR5.
*      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
*      MChange lsb_knvv-LPRIO LS_SALES-LPRIO.
*      IF lv_change IS NOT INITIAL. lv_chtran = 'X'. ENDIF.
*
*      IF lv_chtran IS NOT INITIAL.
*        MOVE-CORRESPONDING lsb_knvv TO ls_knvv.
*        MOVE-CORRESPONDING LS_SALES TO ls_knvv.
*        lv_chsale = 'X'.
*      ELSE.
*        MOVE-CORRESPONDING lsb_knvv TO ls_knvv.
*      ENDIF.
*    ELSE.
*      MOVE-CORRESPONDING LS_SALES TO ls_knvv.
*      ls_knvv-kunnr = LS_CUST-KUNNR.
*      lv_chsale = 'X'.
*    ENDIF.
*
** Partner Information
*    FREE IT_XKNVP[].
*    LOOP AT LS_CUST-PARTNER INTO DATA(LS_PARTNER)
*      WHERE VKORG = LS_SALES-VKORG
*        AND VTWEG = LS_SALES-VTWEG
*        AND SPART = LS_SALES-SPART.
*
*      SELECT SINGLE * FROM knvp INTO @DATA(lsb_knvp)
*        WHERE kunnr = @LS_CUST-KUNNR
*          AND vkorg = @LS_PARTNER-VKORG
*          AND vtweg = @LS_PARTNER-VTWEG
*          AND spart = @LS_PARTNER-SPART
*          AND parvw = @LS_PARTNER-PARVW
*          AND parza = @LS_PARTNER-PARZA.
*      IF sy-subrc NE 0.
*        SELECT SINGLE * FROM knvp INTO @DATA(lsb_knvpx)
*          WHERE kunnr = @LS_CUST-KUNNR
*            AND vkorg = @LS_PARTNER-VKORG
*            AND vtweg = @LS_PARTNER-VTWEG
*            AND spart = @LS_PARTNER-SPART
*            AND parvw = @LS_PARTNER-PARVW
*            AND kunn2 = @LS_PARTNER-KUNN2.
*        IF sy-subrc NE 0.
*          MOVE-CORRESPONDING LS_PARTNER TO ls_xknvp.
*          ls_xknvp-KUNNR = LS_CUST-KUNNR.
*          APPEND ls_xknvp TO it_xknvp.
*          lv_chsale = 'X'.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*
*    IF lv_chsale IS NOT INITIAL.
*      CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
*        EXPORTING
*          i_kna1                     = ls_kna1
*          i_knvv                     = ls_knvv
*          i_maintain_address_by_kna1 = ' '
*        TABLES
*          T_XKNVI                    = IT_XKNVI
*          T_XKNVP                    = IT_XKNVP
*        EXCEPTIONS
*          client_error               = 1
*          kna1_incomplete            = 2
*          knb1_incomplete            = 3
*          knb5_incomplete            = 4
*          knvv_incomplete            = 5
*          kunnr_not_unique           = 6
*          sales_area_not_unique      = 7
*          sales_area_not_valid       = 8
*          insert_update_conflict     = 9
*          number_assignment_error    = 10
*          number_not_in_range        = 11
*          number_range_not_extern    = 12
*          number_range_not_intern    = 13
*          account_group_not_valid    = 14
*          parnr_invalid              = 15
*          bank_address_invalid       = 16
*          tax_data_not_valid         = 17
*          no_authority               = 18
*          company_code_not_unique    = 19
*          dunning_data_not_valid     = 20
*          knb1_reference_invalid     = 21
*          cam_error                  = 22
*          OTHERS                     = 23.
*      IF sy-subrc = 0.
*        IF OU_RESP[] IS INITIAL.
*          LT_RESP-KUNNR = LS_CUST-KUNNR.
*          LT_RESP-MESSA = 'Successful change'.
*          APPEND LT_RESP TO OU_RESP.
*        ENDIF.
*
*        "BAPI commit to update the changes in Data Base
*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*          EXPORTING
*            wait = abap_true.
*      ENDIF.
*    ENDIF.
*
*    CLEAR ls_knvv.
*  ENDLOOP.
** Sales Information End
  endmethod.


  method ZIF_REST_CI~HANDLE_REQUEST.
***************************************************************************
" VARIABLES
***************************************************************************
DATA: LT_RESPONSE       TYPE ZCI_TTRESPONSE,
      LS_RESP           TYPE ZCI_STRESPONSE.
DATA: LV_STRING_WRITER  TYPE REF TO CL_SXML_STRING_WRITER.
DATA: LV_XSTRING        TYPE XSTRING.

DATA: it_node TYPE STANDARD TABLE OF bapikna1_knvh_process,
      ls_node TYPE bapikna1_knvh_process,
      it_return TYPE STANDARD TABLE OF bapiret2,
      lv_chcorp TYPE CHAR01,
      lv_messa TYPE CHAR50.

***************************************************************************
" EXECUTE PUT_FARASAVE METHOD
***************************************************************************
TRY.

READ TABLE IN_PCUST INDEX 1 INTO DATA(LS_PCUSTREG).
IF sy-subrc EQ 0.
  READ TABLE LS_PCUSTREG-CUSTOMER INDEX 1 INTO DATA(LS_PCUST).
  IF sy-subrc EQ 0.
    IF LS_PCUST-KUNNR IS INITIAL.
      LT_RESPONSE = PUT_CUSTOMER_CRE( IN_PCUST ).

      READ TABLE LT_RESPONSE INDEX 1 INTO DATA(LS_RESPONSE).
      IF sy-subrc EQ 0.
        IF LS_RESPONSE-KUNNR IS NOT INITIAL.
* Corporaciones
          LOOP AT LS_PCUST-SALES INTO DATA(LS_SALES).
            IF LS_SALES-HKUNNR IS NOT INITIAL.
              FREE it_node[].
              ls_node-customer = LS_RESPONSE-KUNNR.
              ls_node-salesorg = LS_SALES-VKORG.
              ls_node-distr_chan = LS_SALES-VTWEG.
              ls_node-division = LS_SALES-SPART.
              ls_node-custhityp = 'A'.
              ls_node-valid_from = sy-datum.
              ls_node-parent_customer = LS_SALES-HKUNNR.
              ls_node-parent_sales_org = LS_SALES-VKORG.
              ls_node-parent_distr_chan = LS_SALES-VTWEG.
              ls_node-parent_division = LS_SALES-SPART.
              ls_node-valid_to = '99991231'.
              APPEND ls_node TO it_node.

              CALL FUNCTION 'BAPI_CUSTOMER_HIERARCHIE_INS'
                TABLES
                  node_list = it_node
                  return = it_return.
              IF sy-subrc = 0.
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                  EXPORTING
                    wait = abap_true.

                SELECT SINGLE * FROM knvh INTO @DATA(ls_knvh)
                  WHERE hityp = 'A'
                    AND kunnr = @LS_RESPONSE-KUNNR
                    AND vkorg = @LS_SALES-VKORG
                    AND vtweg = @LS_SALES-VTWEG
                    AND spart = @LS_SALES-SPART
                    AND datbi = '99991231'
                    AND hkunnr = @LS_SALES-HKUNNR.
                IF sy-subrc EQ 0.
                  IF LT_RESPONSE[] IS INITIAL.
                    LS_RESP-KUNNR = LS_RESPONSE-KUNNR.
                    LS_RESP-MESSA = 'Successful change'.
                    APPEND LS_RESP TO LT_RESPONSE.
                  ENDIF.
                ELSE.
                   CONCATENATE 'Invalid Corporate' LS_SALES-HKUNNR
                    INTO lv_messa SEPARATED BY SPACE.
                   LS_RESP-KUNNR = LS_RESPONSE-KUNNR.
                   LS_RESP-MESSA = lv_messa.
                   APPEND LS_RESP TO LT_RESPONSE.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ELSE.
      LT_RESPONSE = PUT_CUSTOMER_UPD( IN_PCUST ).

* Corporaciones
      LOOP AT LS_PCUST-SALES INTO DATA(LS_SALESX).
        IF LS_SALESX-HKUNNR IS NOT INITIAL.
          FREE it_node[].
          SELECT SINGLE * FROM knvh INTO @DATA(lsb_knvh)
           WHERE hityp = 'A'
             AND kunnr = @LS_PCUST-KUNNR
             AND vkorg = @LS_SALESX-VKORG
             AND vtweg = @LS_SALESX-VTWEG
             AND spart = @LS_SALESX-SPART
             AND datbi = '99991231'.
          IF sy-subrc EQ 0.
            CLEAR lv_chcorp.
            IF lsb_knvh-HKUNNR NE LS_SALESX-HKUNNR.
               lv_chcorp = 'X'.
            ENDIF.
          ELSE.
            lv_chcorp = 'X'.
          ENDIF.

          IF lv_chcorp IS NOT INITIAL.
            FREE it_node[].
            ls_node-customer = LS_PCUST-KUNNR.
            ls_node-salesorg = LS_SALESX-VKORG.
            ls_node-distr_chan = LS_SALESX-VTWEG.
            ls_node-division = LS_SALESX-SPART.
            ls_node-custhityp = 'A'.
            ls_node-valid_from = sy-datum.
            ls_node-parent_customer = LS_SALESX-HKUNNR.
            ls_node-parent_sales_org = LS_SALESX-VKORG.
            ls_node-parent_distr_chan = LS_SALESX-VTWEG.
            ls_node-parent_division = LS_SALESX-SPART.
            ls_node-valid_to = '99991231'.
            APPEND ls_node TO it_node.

            CALL FUNCTION 'BAPI_CUSTOMER_HIERARCHIE_INS'
              TABLES
                node_list = it_node
                RETURN = it_return.
            IF sy-subrc = 0.
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  wait = abap_true.

              SELECT SINGLE * FROM knvh INTO @DATA(ls_knvhx)
                WHERE hityp = 'A'
                  AND kunnr = @LS_PCUST-KUNNR
                  AND vkorg = @LS_SALESX-VKORG
                  AND vtweg = @LS_SALESX-VTWEG
                  AND spart = @LS_SALESX-SPART
                  AND datbi = '99991231'
                  AND hkunnr = @LS_SALESX-HKUNNR.
              IF sy-subrc EQ 0.
                IF LT_RESPONSE[] IS INITIAL.
                  LS_RESP-KUNNR = LS_PCUST-KUNNR.
                  LS_RESP-MESSA = 'Successful change'.
                  APPEND LS_RESP TO LT_RESPONSE.
                ENDIF.
              ELSE.
                 CONCATENATE 'Invalid Corporate' LS_SALESX-HKUNNR
                  INTO lv_messa SEPARATED BY SPACE.
                 LS_RESP-KUNNR = LS_PCUST-KUNNR.
                 LS_RESP-MESSA = lv_messa.
                 APPEND LS_RESP TO LT_RESPONSE.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDIF.

***************************************************************************
" CONVERT TO JSON
***************************************************************************
LV_STRING_WRITER = CL_SXML_STRING_WRITER=>CREATE( TYPE = IF_SXML=>CO_XT_JSON ).
CALL TRANSFORMATION ID SOURCE ARRAY =  LT_RESPONSE RESULT XML LV_STRING_WRITER.
LV_XSTRING = LV_STRING_WRITER->GET_OUTPUT( ).

***************************************************************************
" ADD THE JSON TO THE RESPONSE
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
