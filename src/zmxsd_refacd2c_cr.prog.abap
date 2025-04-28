*&---------------------------------------------------------------------*
*& Report ZMXSD_REFACD2C_CR
*&---------------------------------------------------------------------*
*& Description: Refacturación D2C Process
*& Date/Author: 29/SEP/2022 - Heriberto Lara LARAH2
*& Functional: Idalia Rodriguez
*& Transport: NEDK990931
*&---------------------------------------------------------------------*
************************************************************************
*                    M O D I F I C A T I O N L O G
************************************************************************
* Date     Programmer  Request    Description                          *
* ---------------------------------------------------------------------*
* 08/29/23 RAMYAK      N3DK900752 Project RESEGMENTATION               *
*                                  Selection screen paramter added     *
*                                  for BUKRS 0360                      *
************************************************************************
* 14/DIC/23 LARAH2     NEDK9A0ARI Post RESEGMENTATION                  *
*                                  Get BUKRS from Delivery             *
************************************************************************
REPORT ZMXSD_REFACD2C_CR.

INCLUDE ZMXSD_REFACD2C_CR_TOP.  " global Data
INCLUDE ZMXSD_REFACD2C_CR_F01.  " FORM-Routines

START-OF-SELECTION.
PERFORM AUTHORITY_CHECK.

SELECT mandt vbeln uuid vbeld stcd1 rfcty stkzn name1 name4 street house_num1
       city2 post_code1 city1 region regimen zuse zpay canvbeln canuuid newvbeln
       newuuid status ernam erdat message
  INTO TABLE it_refac
  FROM zmxsd_refac_d2c
  WHERE vbeln IN s_vbeln
    AND status EQ 'SAVED'. "#EC NOTEXT

IF ( 0 < lines( it_refac[] ) ).
  SELECT vbeln vbelv vbtyp_v FROM vbfa INTO TABLE it_doctos "#CI_NO_TRANSFORM
    FOR ALL ENTRIES IN it_refac
    WHERE vbeln = it_refac-vbeln
      AND vbtyp_n = 'M'
      AND vbtyp_v IN ('C', 'J'). "#EC CI_NO_TRANSFORM

  SELECT vbelv posnv vbeln FROM vbfa INTO TABLE it_posn "#CI_NO_TRANSFORM
    FOR ALL ENTRIES IN it_refac
    WHERE vbelv = it_refac-vbeld
      AND vbeln = it_refac-vbeln
      AND vbtyp_n = 'M'. "#EC CI_NO_TRANSFORM

  SELECT a~vbeln a~vstel b~bukrs "NEDK9A0ARI
    FROM likp AS a
    INNER JOIN tvko AS b "NEDK9A0ARI
        ON b~vkorg EQ a~vkorg INTO TABLE it_plant "#CI_NO_TRANSFORM
    FOR ALL ENTRIES IN it_refac
    WHERE a~vbeln = it_refac-vbeld. "#EC CI_NO_TRANSFORM
ENDIF.

IF ( 0 < lines( it_doctos[] ) ).
  SELECT vbeln posnr parvw stcd1 stcd2 stkzn FROM vbpa3 INTO TABLE it_vbpa3
    FOR ALL ENTRIES IN it_doctos
  WHERE vbeln = it_doctos-vbelv
    AND parvw IN ('AG','RE','WE','RG'). "#EC CI_NO_TRANSFORM

  SELECT vbeln posnr parvw kunnr lifnr pernr parnr adrnr ablad land1 adrda xcpdk
         hityp prfre bokre histunr knref lzone hzuor stceg parvw_ff adrnp kale
    INTO TABLE it_vbpa_adr
    FROM vbpa
    FOR ALL ENTRIES IN it_doctos
    WHERE vbeln = it_doctos-vbelv
      AND parvw IN ('AG','RE', 'RG'). "#EC CI_NO_TRANSFORM
ENDIF.

SELECT parvw fehgr nrart INTO TABLE it_tpar FROM tpar
  WHERE parvw IN ('AG','RE','WE','RG').

IF ( 0 < lines( it_vbpa3[] ) ).
  SELECT vbeln posnr parvw kunnr lifnr pernr parnr adrnr ablad land1
         adrda xcpdk hityp prfre bokre histunr knref lzone hzuor stceg
         parvw_ff adrnp kale FROM vbpa INTO TABLE it_vbpa
    FOR ALL ENTRIES IN it_vbpa3
    WHERE vbeln = it_vbpa3-vbeln
      AND parvw IN ('AG','RE', 'WE','RG'). "#EC CI_NO_TRANSFORM
ENDIF.

SORT: it_refac BY vbeln,
      it_doctos BY vbeln,
      it_vbpa3 BY vbeln,
      it_vbpa BY vbeln posnr parvw,
      it_vbpa_adr BY vbeln posnr parvw,
      it_tpar BY parvw.
LOOP AT it_refac INTO wa_refac WHERE canvbeln = ''.
  FREE: it_return[], it_success[].
  CALL FUNCTION 'BAPI_BILLINGDOC_CANCEL1'
    EXPORTING
      billingdocument = wa_refac-vbeln
      billingdate = sy-datum
    TABLES
      return          = it_return
      success         = it_success.
  IF it_success[] IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
    WAIT UP TO 5 SECONDS.
    READ TABLE it_success INTO wa_success INDEX 1.
    IF sy-subrc EQ 0.
      wa_refac-canvbeln = wa_success-bill_doc.
      wa_refac-message = ''.
      PERFORM f_chg_fkdat USING wa_refac-canvbeln.

      CLEAR s_vbelnc[].
      w_vbeln-sign = 'I'.
      w_vbeln-option = 'EQ'.
      w_vbeln-low = wa_refac-canvbeln.
      APPEND w_vbeln TO s_vbelnc.
      CONCATENATE wa_refac-canvbeln sy-uname INTO v_memid.

      READ TABLE it_plant INTO wa_plant WITH KEY vbeln = wa_refac-vbeld.

      SUBMIT zsdfofax_cpy TO SAP-SPOOL  "#EC CI_SUBMIT
*        WITH p_bukrs EQ '0360'   "(-)RAMYAK CTS 08/29/2023 RESEGMENTATION
*        WITH p_bukrs EQ p_bukrs1 "(+)RAMYAK CTS 08/29/2023 RESEGMENTATION
        WITH p_bukrs EQ wa_plant-bukrs "NEDK9A0ARI
        WITH p_werks EQ wa_plant-vstel
        WITH p_langu EQ 'EN'
        WITH s_vbeln IN s_vbelnc
        WITH p_extc  EQ 'X'
        WITHOUT SPOOL DYNPRO
        SPOOL PARAMETERS params
        AND RETURN.

      IMPORT v_spool TO v_spool FROM MEMORY ID v_memid.
      FREE MEMORY ID v_memid.
    ENDIF.
  ELSE.
    FREE: wa_msg, wa_msg_texts, gt_msg_texts[], gv_message.
    LOOP AT it_return INTO wa_return WHERE type = 'E'.
      wa_msg-msgty = wa_return-type.
      wa_msg-msgid = wa_return-id.
      wa_msg-msgno = wa_return-number.
      wa_msg-msgv1 = wa_return-message_v1.
      wa_msg-msgv2 = wa_return-message_v2.
      wa_msg-msgv3 = wa_return-message_v3.
      wa_msg-msgv4 = wa_return-message_v4.

      CALL FUNCTION 'MESSAGE_TEXTS_READ'
        EXPORTING
          msg_log_imp = wa_msg
        IMPORTING
          msg_text_exp = wa_msg_texts
        TABLES
          t_msg_texts_exp = gt_msg_texts.

      LOOP AT gt_msg_texts INTO wa_msg_texts.
        CONCATENATE gv_message wa_msg_texts-msgtx INTO gv_message.
      ENDLOOP.
      CONDENSE gv_message.
    ENDLOOP.
    wa_refac-message = gv_message.
  ENDIF.

  IF NOT wa_refac-canvbeln IS INITIAL.
    READ TABLE it_doctos INTO wa_doctos WITH KEY vbeln = wa_refac-vbeln
                                                 vbtyp_v = 'J'.
    IF sy-subrc EQ 0.
      PERFORM f_vl02n USING '02'.
    ENDIF.

    FREE: lt_pach[], lt_paad[], lt_return[], it_vbpa_nadr[].
    READ TABLE it_doctos INTO wa_doctos WITH KEY vbeln = wa_refac-vbeln
                                                 vbtyp_v = 'C'.
    IF sy-subrc EQ 0.
      LOOP AT it_vbpa_adr INTO wa_vbpa WHERE vbeln = wa_doctos-vbelv.
        st_addr_sel-addrnumber = wa_vbpa-adrnr.

        CALL FUNCTION 'ADDR_GET'
          EXPORTING
            address_selection = st_addr_sel
          IMPORTING
           address_value = st_addr_val
          EXCEPTIONS
            parameter_error = 1
            address_not_exist = 2
            version_not_exist = 3
            internal_error = 4
            OTHERS = 5.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING st_addr_val TO lw_paad ##ENH_OK.

          lw_pach-address = wa_vbpa-adrnr.
          lw_pach-document  = wa_doctos-vbelv.
          lw_pach-itm_number = '000000'.
          lw_pach-updateflag = 'U'.
          lw_pach-addr_link =  '999999'.
          lw_pach-partn_role = wa_vbpa-parvw.
          lw_pach-p_numb_old = wa_vbpa-kunnr.
          lw_pach-p_numb_new = wa_vbpa-kunnr.
          APPEND lw_pach TO lt_pach.

          lw_paad-addr_no = '999999'.
          lw_paad-name = wa_refac-name1.
          lw_paad-name_4 = wa_refac-name4.
          lw_paad-city = wa_refac-city1.
          lw_paad-district = wa_refac-city2.
          lw_paad-postl_cod1 = wa_refac-post_code1.
          lw_paad-street = wa_refac-street.
          lw_paad-house_no = wa_refac-house_num1.
          CONCATENATE wa_refac-regimen '-' wa_refac-zuse
            INTO lw_paad-fax_number.
          CONDENSE lw_paad-fax_number NO-GAPS.
          lw_paad-region = wa_refac-region.
          APPEND lw_paad TO lt_paad.
        ENDIF.
      ENDLOOP.

      lw_ordchghdx-updateflag = 'U'.
      CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
        EXPORTING
          salesdocument    = wa_doctos-vbelv
          order_header_inx = lw_ordchghdx
        TABLES
          return           = lt_return
          partnerchanges   = lt_pach
          partneraddresses = lt_paad.
      IF sy-subrc EQ 0 ##FM_SUBRC_OK.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
        WAIT UP TO 5 SECONDS.

        SELECT vbeln posnr parvw kunnr lifnr pernr parnr adrnr ablad land1 adrda
               xcpdk hityp prfre bokre histunr knref lzone hzuor stceg parvw_ff
               adrnp kale INTO TABLE it_vbpa_nadr
        FROM vbpa AS a
        WHERE a~vbeln = wa_doctos-vbelv
          AND a~parvw IN ('AG','RE', 'RG'). "#EC CI_NO_TRANSFORM
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        WAIT UP TO 5 SECONDS.
      ENDIF.
    ENDIF.

    READ TABLE it_doctos INTO wa_doctos WITH KEY vbeln = wa_refac-vbeln
                                                 vbtyp_v = 'C'.
    IF sy-subrc EQ 0.
      LOOP AT it_vbpa_nadr INTO wa_vbpa WHERE vbeln = wa_doctos-vbelv.
        FREE: it_adrc_u[], it_adr3_u[], it_adr3_i[].

        st_addr_sel-addrnumber = wa_vbpa-adrnr.

        CALL FUNCTION 'ADDR_GET'
          EXPORTING
            address_selection = st_addr_sel
          IMPORTING
           address_value = st_addr_val
          EXCEPTIONS
            parameter_error = 1
            address_not_exist = 2
            version_not_exist = 3
            internal_error = 4
            OTHERS = 5.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING st_addr_val TO wa_adrc_u ##ENH_OK.

          wa_adrc_u-name1 = wa_refac-name1.
          wa_adrc_u-name4 = wa_refac-name4.
          wa_adrc_u-city1 = wa_refac-city1.
          wa_adrc_u-city2 = wa_refac-city2.
          wa_adrc_u-post_code1 = wa_refac-post_code1.
          wa_adrc_u-street = wa_refac-street.
          wa_adrc_u-house_num1 = wa_refac-house_num1.
          CONCATENATE wa_refac-regimen '-' wa_refac-zuse
            INTO wa_adrc_u-fax_number.
          CONDENSE wa_adrc_u-fax_number NO-GAPS.
          wa_adrc_u-flagcomm3 = 'X'.
          wa_adrc_u-region = wa_refac-region.
          APPEND wa_adrc_u TO it_adrc_u.

          SELECT SINGLE addrnumber INTO gv_addrnumber FROM adr3
            WHERE addrnumber = wa_adrc_u-addrnumber
              AND persnumber = ''
              AND date_from  = wa_adrc_u-date_from
              AND consnumber = gv_consnum.
          IF sy-subrc EQ 0.
            wa_adr3_u-addrnumber = wa_adrc_u-addrnumber.
            wa_adr3_u-date_from = wa_adrc_u-date_from.
            wa_adr3_u-consnumber = gv_consnum.
            wa_adr3_u-fax_number = wa_adrc_u-fax_number.
            wa_adr3_u-country = wa_adrc_u-country.
            wa_adr3_u-flgdefault = 'X'.
            wa_adr3_u-home_flag = 'X'.
            APPEND wa_adr3_u TO it_adr3_u.
          ELSE.
            wa_adr3_i-addrnumber = wa_adrc_u-addrnumber.
            wa_adr3_i-date_from = wa_adrc_u-date_from.
            wa_adr3_i-consnumber = gv_consnum.
            wa_adr3_i-fax_number = wa_adrc_u-fax_number.
            wa_adr3_i-country = wa_adrc_u-country.
            wa_adr3_i-flgdefault = 'X'.
            wa_adr3_i-home_flag = 'X'.
            APPEND wa_adr3_i TO it_adr3_i.
          ENDIF.

          CALL FUNCTION 'ADDR_SAVE_INTERN'
            TABLES
              adrc_d    = adrc_d
              adrc_u    = it_adrc_u
              adrc_i    = adrc_i
              adrct_d   = adrct_d
              adrct_u   = adrct_u
              adrct_i   = adrct_i
              adrp_d    = adrp_d
              adrp_u    = adrp_u
              adrp_i    = adrp_i
              adcp_d    = adcp_d
              adcp_u    = adcp_u
              adcp_i    = adcp_i
              adrt_d    = adrt_d
              adrt_u    = adrt_u
              adrt_i    = adrt_i
              adr2_d    = adr2_d
              adr2_u    = adr2_u
              adr2_i    = adr2_i
              adr3_d    = adr3_d
              adr3_u    = it_adr3_u
              adr3_i    = it_adr3_i
              adr4_d    = adr4_d
              adr4_u    = adr4_u
              adr4_i    = adr4_i
              adr5_d    = adr5_d
              adr5_u    = adr5_u
              adr5_i    = adr5_i
              adr6_d    = adr6_d
              adr6_u    = adr6_u
              adr6_i    = adr6_i
              adr7_d    = adr7_d
              adr7_u    = adr7_u
              adr7_i    = adr7_i
              adr8_d    = adr8_d
              adr8_u    = adr8_u
              adr8_i    = adr8_i
              adr9_d    = adr9_d
              adr9_u    = adr9_u
              adr9_i    = adr9_i
              adr10_d   = adr10_d
              adr10_u   = adr10_u
              adr10_i   = adr10_i
              adr11_d   = adr11_d
              adr11_u   = adr11_u
              adr11_i   = adr11_i
              adr12_d   = adr12_d
              adr12_u   = adr12_u
              adr12_i   = adr12_i
              adr13_d   = adr13_d
              adr13_u   = adr13_u
              adr13_i   = adr13_i
              adrcomc_d = adrcomc_d
              adrcomc_u = adrcomc_u
              adrcomc_i = adrcomc_i
              adrv_d    = adrv_d
              adrv_u    = adrv_u
              adrv_i    = adrv_i
              adrvp_d   = adrvp_d
              adrvp_u   = adrvp_u
              adrvp_i   = adrvp_i ##FM_SUBRC_OK
            EXCEPTIONS
              database_error = '01'
              internal_error = '02'.
          IF sy-subrc EQ 0.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = abap_true.
            WAIT UP TO 3 SECONDS.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT it_doctos INTO wa_doctos WHERE vbeln = wa_refac-vbeln.
      LOOP AT it_vbpa3 INTO wa_vbpa3 WHERE vbeln = wa_doctos-vbelv.
        CLEAR: wa_xvbpa, i_xvbpa[], i_yvbpa[].
        LOOP AT it_vbpa INTO wa_vbpa WHERE vbeln = wa_vbpa3-vbeln
                                       AND posnr = wa_vbpa3-posnr
                                       AND parvw = wa_vbpa3-parvw.

          MOVE-CORRESPONDING wa_vbpa3 TO wa_xvbpa.
          MOVE-CORRESPONDING wa_vbpa TO wa_xvbpa.

          READ TABLE it_tpar INTO wa_tpar WITH KEY parvw = wa_vbpa-parvw BINARY SEARCH.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING wa_tpar TO wa_xvbpa.
          ENDIF.

          wa_xvbpa-spras = 'E'.

          wa_xvbpa-updkz = 'U'.
          wa_xvbpa-stcd1 = wa_refac-stcd1.
          wa_xvbpa-stkzn = wa_refac-stkzn.
          APPEND wa_xvbpa TO i_xvbpa.

          wa_xvbpa-updkz = ''.
          wa_xvbpa-stcd1 = wa_vbpa3-stcd1.
          wa_xvbpa-stkzn = wa_vbpa3-stkzn.
          APPEND wa_xvbpa TO i_yvbpa.
        ENDLOOP.

        CALL FUNCTION 'SD_PARTNER_UPDATE' ##FM_SUBRC_OK
          EXPORTING
            f_vbeln  = wa_vbpa3-vbeln
            object   = 'VBPA'
          TABLES
            i_xvbadr = i_xvbadr
            i_xvbpa  = i_xvbpa
            i_yvbadr = i_yvbadr
            i_yvbpa  = i_yvbpa
          EXCEPTIONS
            OTHERS   = 1.
        IF sy-subrc EQ 0.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = abap_true.
          WAIT UP TO 3 SECONDS.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
    READ TABLE it_doctos INTO wa_doctos WITH KEY vbeln = wa_refac-vbeln
                                                 vbtyp_v = 'J'.
    IF sy-subrc EQ 0.
      PERFORM f_vl02n USING ''.
    ENDIF.
  ENDIF.
  MODIFY it_refac FROM wa_refac TRANSPORTING canvbeln message.
ENDLOOP.

*New Invoice
LOOP AT it_refac INTO wa_refac WHERE canvbeln NE ''.
  CHECK wa_refac-newvbeln IS INITIAL.
  READ TABLE it_posn INTO wa_posn WITH KEY vbelv = wa_refac-vbeld.
  IF sy-subrc EQ 0.
    wa_canc-vbelv = wa_refac-vbeld.
    wa_canc-posnv = wa_posn-posnv.
    wa_canc-vbeln = wa_refac-vbeln.
    APPEND wa_canc TO it_canc.
  ENDIF.
ENDLOOP.

IF ( 0 < lines( it_canc[] ) ).
SELECT a~vbelv a~vbeln INTO TABLE it_new ##TOO_MANY_ITAB_FIELDS
  FROM vbfa AS a
  INNER JOIN vbrk AS b
          ON b~vbeln = a~vbeln
  FOR ALL ENTRIES IN it_canc
  WHERE a~vbelv = it_canc-vbelv
    AND a~posnv = it_canc-posnv
    AND a~vbtyp_n = 'M'
    AND b~fksto = '' . "#EC CI_NO_TRANSFORM
ENDIF.

LOOP AT it_new INTO wa_new.
*  READ TABLE it_doctos INTO wa_doctos WITH KEY vbelv = wa_new-vbeln.
*  IF sy-subrc EQ 0.
    READ TABLE it_refac INTO wa_refac WITH KEY vbeld = wa_new-vbeln.
    IF sy-subrc EQ 0.
      IF wa_refac-vbeln NE wa_new-vbelv.
        wa_refac-newvbeln = wa_new-vbelv.
        MODIFY it_refac FROM wa_refac INDEX sy-tabix TRANSPORTING newvbeln.
      ENDIF.
    ENDIF.
*  ENDIF.
ENDLOOP.

*UUID
LOOP AT it_refac INTO wa_refac WHERE canvbeln NE ''.
  IF wa_refac-vbeln NE '' AND wa_refac-uuid EQ ''.
    wa_invoice-vbeln = wa_refac-vbeln.
    APPEND wa_invoice TO it_invoice.
  ENDIF.
  IF wa_refac-canvbeln NE '' AND wa_refac-canuuid EQ ''.
    wa_invoice-vbeln = wa_refac-canvbeln.
    APPEND wa_invoice TO it_invoice.
  ENDIF.
  IF wa_refac-newvbeln NE '' AND wa_refac-newuuid EQ ''.
    wa_invoice-vbeln = wa_refac-newvbeln.
    APPEND wa_invoice TO it_invoice.
  ENDIF.
ENDLOOP.

IF ( 0 < lines( it_invoice[] ) ).
SELECT vbeln uuid INTO TABLE it_uuid
  FROM ztmxefact
  FOR ALL ENTRIES IN it_invoice
  WHERE vbeln = it_invoice-vbeln.
ENDIF.

LOOP AT it_refac INTO wa_refac.
  IF wa_refac-vbeln NE '' AND wa_refac-uuid EQ ''.
    READ TABLE it_uuid INTO wa_uuid WITH KEY vbeln = wa_refac-vbeln.
    IF sy-subrc EQ 0.
      wa_refac-uuid = wa_uuid-uuid.
    ENDIF.
  ENDIF.
  IF wa_refac-canvbeln NE '' AND wa_refac-canuuid EQ ''.
    READ TABLE it_uuid INTO wa_uuid WITH KEY vbeln = wa_refac-canvbeln.
    IF sy-subrc EQ 0.
      wa_refac-canuuid = wa_uuid-uuid.
    ENDIF.
  ENDIF.
  IF wa_refac-newvbeln NE '' AND wa_refac-newuuid EQ ''.
    READ TABLE it_uuid INTO wa_uuid WITH KEY vbeln = wa_refac-newvbeln.
    IF sy-subrc EQ 0.
      wa_refac-newuuid = wa_uuid-uuid.
    ENDIF.
  ENDIF.

  IF wa_refac-uuid NE '' AND wa_refac-canuuid NE '' AND wa_refac-newuuid NE ''.
    wa_refac-status = 'PROCESADO'. "#EC NOTEXT
    wa_refac-message = ''.
  ENDIF.
  MODIFY it_refac FROM wa_refac TRANSPORTING uuid canuuid newuuid status message.
ENDLOOP.

MODIFY zmxsd_refac_d2c FROM TABLE it_refac.
IF sy-subrc EQ 0.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
  EXPORTING
    wait = abap_true.
ENDIF.
