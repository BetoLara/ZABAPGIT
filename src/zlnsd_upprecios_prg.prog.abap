*&---------------------------------------------------------------------*
*& Report ZLNSD_UPPRECIOS_PRG
*&---------------------------------------------------------------------*
*& Description: Cambios Masivos de Precios  VK11 Cond.Type(Z017, Z026)
*& Date/Author: 1/MARCH/2021 - Heriberto Lara Llanas
*& Analyst: Dante Maltos
*&---------------------------------------------------------------------*
REPORT ZLNSD_UPPRECIOS_PRG.

TYPES: BEGIN OF ty_data, "#EC NEEDED
        vbeln TYPE vbak-vbeln,
        vkorg TYPE vbak-vkorg,
        vtweg TYPE vbak-vtweg,
        matnr TYPE komg-matnr,
        ordcr TYPE n LENGTH 8,
        kdgrp TYPE komg-kdgrp,
        kunag TYPE komg-kunag,
        werks TYPE komg-werks,
        kschl TYPE konv-kschl,
        zzprcshtnr TYPE komg-zzprcshtnr,
        kbetr TYPE c LENGTH 15,
        konwa TYPE konp-konwa,
        datab TYPE KODATAB,
        datbi TYPE KODATBI,
        text TYPE c LENGTH 100,
        color TYPE c LENGTH 4,
        ct TYPE lvc_t_scol,
        order TYPE n LENGTH 1,
      END OF ty_data.
DATA: it_data TYPE STANDARD TABLE OF ty_data, "#EC NEEDED
      wa_data TYPE ty_data. "#EC NEEDED
DATA: ti_alv_field_cat TYPE slis_t_fieldcat_alv, "#EC NEEDED
      wa_alv_field_cat LIKE LINE OF ti_alv_field_cat, "#EC NEEDED
      ti_alv_layout    TYPE slis_layout_alv. "#EC NEEDED
DATA: vg_error TYPE c LENGTH 1, "#EC NEEDED
      vg_sales TYPE c LENGTH 1. "#EC NEEDED
DATA: i_bdcdata TYPE TABLE OF bdcdata, "#EC NEEDED
      w_bdcdata LIKE LINE OF i_bdcdata, "#EC NEEDED
      t_mensaje TYPE TABLE OF bdcmsgcoll, "#EC NEEDED
      w_mensaje LIKE LINE OF t_mensaje. "#EC NEEDED
TYPES: BEGIN OF ty_matnr, "#EC NEEDED
        matnr TYPE MATNR,
      END OF ty_matnr.
DATA: it_matnr TYPE STANDARD TABLE OF ty_matnr, "#EC NEEDED
      wa_matnr TYPE ty_matnr. "#EC NEEDED
CONSTANTS: c_x TYPE c VALUE 'X'.
SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
  PARAMETERS: p_fname TYPE rlgrap-filename OBLIGATORY,
              p_batch AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN : END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fname.
  PERFORM get_filename USING p_fname.

START-OF-SELECTION.

PERFORM upload_file.
PERFORM alv_caract.
PERFORM alv_columnas.

 IF p_batch EQ '' AND vg_error EQ ''.
    PERFORM eje_batch.
 ENDIF.

 IF p_batch EQ '' AND NOT vg_error IS INITIAL.
   MESSAGE text-e03 TYPE 'S' DISPLAY LIKE 'E'.
 ENDIF.

PERFORM eje_report.
*&---------------------------------------------------------------------*
*&      Form  eje_batch
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM eje_batch.
TYPES: BEGIN OF ty_vbap,
        posnr TYPE posnr,
       END OF ty_vbap.
DATA: it_vbap TYPE STANDARD TABLE OF ty_vbap,
      wa_vbap TYPE ty_vbap.
DATA: csp type lvc_s_scol,
*cta es la tabla donde meteremos cs y luego se la pasamos a CT
      ctap type lvc_t_scol.
DATA: v_kbetr TYPE c LENGTH 16,
      v_datab TYPE c LENGTH 10,
      v_datbi TYPE c LENGTH 10,
      v_mode TYPE c LENGTH 1 value 'N',
      v_error TYPE c LENGTH 1.

DATA: salesdoc TYPE BAPIVBELN-VBELN, "#EC NEEDED
      ls_order_header_inx TYPE BAPISDH1X, "#EC NEEDED
      logic_switch TYPE bapisdls, "#EC NEEDED
      lt_return TYPE STANDARD TABLE OF BAPIRET2, "#EC NEEDED
      wa_return TYPE BAPIRET2, "#EC NEEDED
      lt_order_item_in TYPE STANDARD TABLE OF BAPISDITM, "#EC NEEDED
      wa_order_item_in TYPE BAPISDITM, "#EC NEEDED
      lt_order_item_inx TYPE STANDARD TABLE OF BAPISDITMX, "#EC NEEDED
      wa_order_item_inx TYPE BAPISDITMX, "#EC NEEDED
      wa_lnsd_upprecios TYPE zlnsd_upprecios. "#EC NEEDED

SORT it_data BY ordcr kschl vkorg matnr.
LOOP AT it_data INTO wa_data.

  PERFORM p_zlnsd_bdc USING v_kbetr v_datab v_datbi v_mode.

    CLEAR v_error.
    LOOP AT t_mensaje INTO w_mensaje.

      CALL FUNCTION 'MASS_MESSAGE_GET' "To get the Message Text
        EXPORTING
          arbgb    = w_mensaje-msgid
          msgnr    = w_mensaje-msgnr
          msgv1    = w_mensaje-msgv1
          msgv2    = w_mensaje-msgv2
          msgv3    = w_mensaje-msgv3
          msgv4    = w_mensaje-msgv4
        IMPORTING
          msgtext  = wa_data-text
        EXCEPTIONS
          message_not_found = 1
        OTHERS            = 2.
      IF sy-subrc <> 0.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      IF w_mensaje-msgtyp EQ 'E'.
        FREE ctap.
        CLEAR csp.
        csp-fname = 'TEXT'.
        csp-color-col = 6.
        csp-nokeycol = 'X'.
        APPEND csp to ctap.
        APPEND lines of ctap to wa_data-ct.
        CLEAR csp.
        v_error = 'X'.
      ENDIF.
      MODIFY it_data FROM wa_data.
    ENDLOOP.

    IF v_error IS INITIAL AND NOT wa_data-vbeln IS INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = wa_data-vbeln
            IMPORTING
              OUTPUT = salesdoc.

      FREE: lt_return[], it_vbap, lt_order_item_in[], lt_order_item_inx[].
      logic_switch-pricing = 'C'.
      logic_switch-cond_handl = 'X'.
      ls_order_header_inx-updateflag = 'U'.

      SELECT posnr INTO TABLE it_vbap FROM vbap
        WHERE vbeln = salesdoc
          AND matnr = wa_data-matnr.

      LOOP AT it_vbap INTO wa_vbap.
        wa_order_item_in-itm_number = wa_vbap-posnr.
        APPEND wa_order_item_in TO lt_order_item_in.
        wa_order_item_inx-itm_number = wa_vbap-posnr.
        wa_order_item_inx-updateflag  = 'U'.
        APPEND wa_order_item_inx TO lt_order_item_inx.
      ENDLOOP.

      CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
        EXPORTING
          salesdocument    = salesdoc
          order_header_inx = ls_order_header_inx
          logic_switch     = logic_switch
        TABLES
          return           = lt_return
          order_item_in    = lt_order_item_in
          order_item_inx   = lt_order_item_inx.

      LOOP AT lt_return INTO wa_return.
        MOVE: wa_return-id TO w_mensaje-msgid,
              wa_return-number TO w_mensaje-msgnr,
              wa_return-message_v1 TO w_mensaje-msgv1,
              wa_return-message_v2 TO w_mensaje-msgv2,
              wa_return-message_v3 TO w_mensaje-msgv3,
              wa_return-message_v4 TO w_mensaje-msgv4.
        CALL FUNCTION 'MASS_MESSAGE_GET' "To get the Message Text
          EXPORTING
            arbgb    = w_mensaje-msgid
            msgnr    = w_mensaje-msgnr
            msgv1    = w_mensaje-msgv1
            msgv2    = w_mensaje-msgv2
            msgv3    = w_mensaje-msgv3
            msgv4    = w_mensaje-msgv4
          IMPORTING
            msgtext  = wa_data-text
          EXCEPTIONS
            message_not_found = 1
          OTHERS            = 2.
        IF sy-subrc <> 0.
            MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
        IF wa_return-type EQ 'E'.
          FREE ctap.
          CLEAR csp.
          csp-fname = 'TEXT'.
          csp-color-col = 6.
          csp-nokeycol = 'X'.
          APPEND csp to ctap.
          APPEND lines of ctap to wa_data-ct.
          CLEAR csp.
          v_error = 'X'.
        ENDIF.
        MODIFY it_data FROM wa_data.
      ENDLOOP.

      READ TABLE lt_return INTO wa_return WITH KEY type = 'E'.
      IF sy-subrc NE 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        LOOP AT it_vbap INTO wa_vbap.
          wa_lnsd_upprecios-vbeln = salesdoc.
          wa_lnsd_upprecios-posnr = wa_vbap-posnr.
          wa_lnsd_upprecios-aendate = sy-datum.
          wa_lnsd_upprecios-kunag = wa_data-kunag.
          wa_lnsd_upprecios-zzprcshtnr = wa_data-zzprcshtnr.
          wa_lnsd_upprecios-kschl = wa_data-kschl.
          wa_lnsd_upprecios-matnr = wa_data-matnr.
          wa_lnsd_upprecios-kbetr = wa_data-kbetr.
          wa_lnsd_upprecios-aenuser = sy-uname.
          MODIFY zlnsd_upprecios FROM wa_lnsd_upprecios.
        ENDLOOP.
      ENDIF.
    ENDIF.
ENDLOOP.
IF sy-subrc EQ 0.
  MESSAGE ID '00' TYPE 'S' NUMBER '000'.
ENDIF.
ENDFORM.                    " eje_batch
*&---------------------------------------------------------------------*
*&      Form  p_zlnsd_bdc.
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p_zlnsd_bdc USING v_kbetr TYPE ANY
                       v_datab TYPE ANY
                       v_datbi TYPE ANY
                       v_mode TYPE ANY.

    CLEAR i_bdcdata.
    FREE i_bdcdata.

    PERFORM f_dynpro  USING:
        c_x   'SAPMV13A'      '0100',
        space 'BDC_CURSOR'    'RV13A-KSCHL',
        space 'BDC_OKCODE'    '=ANTA',
        space 'RV13A-KSCHL'   wa_data-kschl.

    PERFORM f_dynpro  USING:
        c_x   'SAPLV14A'      '0100',
        space 'BDC_CURSOR'    'RV130-SELKZ(02)',
        space 'BDC_OKCODE'    '=WEIT',
        space 'RV130-SELKZ(01)' '',
        space 'RV130-SELKZ(02)' 'X'.

    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        DATE_INTERNAL = wa_data-datab
      IMPORTING
        DATE_EXTERNAL = v_datab
      EXCEPTIONS
        DATE_INTERNAL_IS_INVALID = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        DATE_INTERNAL = wa_data-datbi
      IMPORTING
        DATE_EXTERNAL = v_datbi
      EXCEPTIONS
        DATE_INTERNAL_IS_INVALID = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    v_kbetr = wa_data-kbetr.

    IF NOT wa_data-kunag IS INITIAL.
      wa_data-zzprcshtnr = ''.
    ENDIF.

    PERFORM f_dynpro  USING:
        c_x   'SAPMV13A'      '1875',
        space 'BDC_CURSOR'    'RV13A-DATBI(01)',
        space 'BDC_OKCODE'    '=SICH',
        space 'KOMG-VKORG(01)'  wa_data-vkorg,
        space 'KOMG-VTWEG(01)'  wa_data-vtweg,
        space 'KOMG-KDGRP(01)'  wa_data-kdgrp,
        space 'KOMG-KUNAG(01)'  wa_data-kunag,
        space 'KOMG-ZZPRCSHTNR(01)' wa_data-zzprcshtnr,
        space 'KOMG-WERKS(01)'  wa_data-werks,
        space 'KOMG-MATNR(01)'  wa_data-matnr,
        space 'KONP-KBETR(01)'  v_kbetr,
        space 'KONP-KONWA(01)'  wa_data-konwa,
        space 'KONP-KMEIN(01)'  'EA',
        space 'RV13A-DATAB(01)' v_datab,
        space 'RV13A-DATBI(01)' v_datbi.

    CLEAR: t_mensaje.
    FREE: t_mensaje.

    CALL TRANSACTION 'VK11' WITH AUTHORITY-CHECK USING i_bdcdata MODE v_mode UPDATE 'S'
      MESSAGES INTO t_mensaje.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
ENDFORM.                    " p_zlnsd_bdc
*&---------------------------------------------------------------------*
*&      Form  upload_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload_file.
DATA: v_mandt TYPE sy-mandt,
      v_fname TYPE STRING,
      v_waerk TYPE WAERK,
      v_prsdt TYPE PRSDT,
      v_kunnr TYPE KUNAG.
TYPES: BEGIN OF ty_file,
        vbeln TYPE vbak-vbeln,
        vkorg TYPE vbak-vkorg,
        vtweg TYPE vbak-vtweg,
        matnr TYPE komg-matnr,
        kdgrp TYPE komg-kdgrp,
        kunag TYPE komg-kunag,
        werks TYPE komg-werks,
        kschl TYPE konv-kschl,
        zzprcshtnr TYPE komg-zzprcshtnr,
        kbetr TYPE CHAR30,
        konwa TYPE konp-konwa,
        datab TYPE CHAR30,
        datbi TYPE CHAR30,
       END OF ty_file.
DATA: it_file TYPE STANDARD TABLE OF ty_file,
      w_file TYPE ty_file.

*cs es la estructura de la tabla de colores
DATA: cs type lvc_s_scol,
*cta es la tabla donde meteremos cs y luego se la pasamos a CT
      cta type lvc_t_scol.

  v_fname = p_fname.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = v_fname
      filetype                = 'ASC'
      has_field_separator     = 'X'
    TABLES
      data_tab                = IT_FILE
    EXCEPTIONS
      file_open_error         = '1'
      file_read_error         = '2'
      no_batch                = '3'
      gui_refuse_filetransfer = '4'
      invalid_type            = '5'
      no_authority            = '6'
      unknown_error           = '7'
      bad_data_format         = '8'
      header_not_allowed      = '9'
      separator_not_allowed   = '10'
      header_too_long         = '11'
      unknown_dp_error        = '12'
      access_denied           = '13'
      dp_out_of_memory        = '14'
      disk_full               = '15'
      dp_timeout              = '16'
      OTHERS                  = '17'.
   IF sy-subrc <> 0.
     MESSAGE text-e02 TYPE 'S' DISPLAY LIKE 'E'.
   ENDIF.

   IF it_file[] IS INITIAL.
    MESSAGE text-e04 TYPE 'S' DISPLAY LIKE 'E'.
   ELSE.
    DELETE it_file INDEX 1.
    LOOP AT it_file INTO w_file.

       ADD 1 TO wa_data-ordcr.
       MOVE-CORRESPONDING w_file TO wa_data.
       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  INPUT  = w_file-vbeln
                IMPORTING
                  OUTPUT = wa_data-vbeln.

       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  INPUT  = w_file-vkorg
                IMPORTING
                  OUTPUT = wa_data-vkorg.

        REPLACE ALL OCCURRENCES OF '"' IN w_file-kbetr WITH ''.
        REPLACE ALL OCCURRENCES OF ',' IN w_file-kbetr WITH ''.
             wa_data-kbetr = w_file-kbetr.
             IF NOT w_file-datab IS INITIAL.
              CALL FUNCTION 'DATE_STRING_CONVERT'
                EXPORTING
                  date_format = '2'  "DD/MM/AAAA
                  date_string = w_file-datab
                IMPORTING
                  result_date = wa_data-datab.
             ENDIF.
             IF NOT w_file-datbi IS INITIAL.
              CALL FUNCTION 'DATE_STRING_CONVERT'
                EXPORTING
                  date_format = '2' "DD/MM/AAAA
                  date_string = w_file-datbi
                IMPORTING
                  result_date = wa_data-datbi.
             ENDIF.
      APPEND wa_data TO it_data.
    ENDLOOP.
   ENDIF.

  LOOP AT it_data INTO wa_data.
    CLEAR: vg_error, vg_sales.
    wa_data-order = '2'.
    IF NOT wa_data-kschl EQ 'Z017' AND
       NOT wa_data-kschl EQ 'Z026'.
      wa_data-text = 'Condicion de precios invalida'. "#EC NOTEXT
      wa_data-order = '1'.
      vg_error = 'x'.

      FREE cta.
      CLEAR cs.
      cs-fname = 'TEXT'.
      cs-color-col = 6.
      cs-nokeycol = 'X'.
      APPEND cs to cta.
      APPEND lines of cta to wa_data-ct.
      CLEAR cs.
    ENDIF.

    IF NOT wa_data-vbeln IS INITIAL.
      SELECT SINGLE waerk kunnr INTO ( v_waerk, v_kunnr ) FROM vbak WHERE vbeln EQ wa_data-vbeln.
      IF sy-subrc NE 0.
        wa_data-text = 'Sales Order invalid'. "#EC NOTEXT
        wa_data-order = '1'.
        vg_error = 'x'.

        FREE cta.
        CLEAR cs.
        cs-fname = 'TEXT'.
        cs-color-col = 6.
        cs-nokeycol = 'X'.
        APPEND cs to cta.
        APPEND lines of cta to wa_data-ct.
        CLEAR cs.
      ELSE.
        vg_sales = 'x'.
        IF wa_data-konwa IS INITIAL.
          wa_data-konwa = v_waerk.
        ENDIF.
        SELECT SINGLE prsdt INTO v_prsdt FROM vbkd
          WHERE vbeln EQ wa_data-vbeln
            AND posnr EQ '000000'.
        IF sy-subrc EQ 0.
          IF wa_data-datab EQ ''.
            wa_data-datab = v_prsdt.
          ENDIF.
          IF wa_data-datbi EQ ''.
            wa_data-datbi = v_prsdt.
          ENDIF.
        ENDIF.
*        IF wa_data-datab = '' OR wa_data-datbi = ''.
*          wa_data-datab = v_audat.
*          IF NOT wa_data-kunag IS INITIAL.
*            wa_data-datbi = v_audat.
*          ELSE.
*            wa_data-datbi = '99991231'.
*          ENDIF.
*        ENDIF.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = v_kunnr
          IMPORTING
            OUTPUT = v_kunnr.
        IF v_kunnr NE wa_data-kunag AND NOT wa_data-kunag IS INITIAL.
          wa_data-text = 'Sold-To different in Sales Order'. "#EC NOTEXT
          wa_data-order = '1'.
          vg_error = 'x'.

          FREE cta.
          CLEAR cs.
          cs-fname = 'TEXT'.
          cs-color-col = 6.
          cs-nokeycol = 'X'.
          APPEND cs to cta.
          APPEND lines of cta to wa_data-ct.
          CLEAR cs.
        ENDIF.
        SELECT matnr INTO TABLE it_matnr FROM vbap WHERE vbeln EQ wa_data-vbeln.
        IF sy-subrc EQ 0.
          READ TABLE it_matnr INTO wa_matnr WITH KEY matnr = wa_data-matnr.
          IF sy-subrc NE 0.
            wa_data-text = 'Material no exist in Sales Order'. "#EC NOTEXT
            wa_data-order = '1'.
            vg_error = 'x'.

            FREE cta.
            CLEAR cs.
            cs-fname = 'TEXT'.
            cs-color-col = 6.
            cs-nokeycol = 'X'.
            APPEND cs to cta.
            APPEND lines of cta to wa_data-ct.
            CLEAR cs.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = wa_data-vbeln
          IMPORTING
            OUTPUT = wa_data-vbeln.

   IF wa_data-konwa IS INITIAL AND vg_sales IS INITIAL AND vg_error EQ ''.
      wa_data-text = 'Currency invalid'. "#EC NOTEXT
      wa_data-order = '1'.
      vg_error = 'x'.

      FREE cta.
      CLEAR cs.
      cs-fname = 'TEXT'.
      cs-color-col = 6.
      cs-nokeycol = 'X'.
      APPEND cs to cta.
      APPEND lines of cta to wa_data-ct.
      CLEAR cs.
    ENDIF.

    IF wa_data-datab EQ '' AND vg_sales IS INITIAL AND vg_error EQ ''.
      wa_data-text = 'Valid From invalid'. "#EC NOTEXT
      wa_data-order = '1'.
      vg_error = 'x'.

      FREE cta.
      CLEAR cs.
      cs-fname = 'TEXT'.
      cs-color-col = 6.
      cs-nokeycol = 'X'.
      APPEND cs to cta.
      APPEND lines of cta to wa_data-ct.
      CLEAR cs.
    ENDIF.

    IF wa_data-datbi EQ '' AND vg_sales IS INITIAL AND vg_error EQ ''.
      wa_data-text = 'Valid To invalid'. "#EC NOTEXT
      wa_data-order = '1'.
      vg_error = 'x'.

      FREE cta.
      CLEAR cs.
      cs-fname = 'TEXT'.
      cs-color-col = 6.
      cs-nokeycol = 'X'.
      APPEND cs to cta.
      APPEND lines of cta to wa_data-ct.
      CLEAR cs.
    ENDIF.

    SELECT SINGLE mandt INTO v_mandt
      FROM tvko
      WHERE vkorg EQ wa_data-vkorg.
    IF sy-subrc NE 0.
      wa_data-text = 'Sales Org invalid'. "#EC NOTEXT
      wa_data-order = '1'.
      vg_error = 'x'.

      FREE cta.
      CLEAR cs.
      cs-fname = 'TEXT'.
      cs-color-col = 6.
      cs-nokeycol = 'X'.
      APPEND cs to cta.
      APPEND lines of cta to wa_data-ct.
      CLEAR cs.
    ENDIF.

    SELECT SINGLE mandt INTO v_mandt
      FROM mara
      WHERE matnr EQ wa_data-matnr.
    IF sy-subrc NE 0.
      wa_data-text = 'Material invalid'. "#EC NOTEXT
      wa_data-order = '1'.
      vg_error = 'x'.

      FREE cta.
      CLEAR cs.
      cs-fname = 'TEXT'.
      cs-color-col = 6.
      cs-nokeycol = 'X'.
      APPEND cs to cta.
      APPEND lines of cta to wa_data-ct.
      CLEAR cs.
    ENDIF.

    IF NOT wa_data-kunag IS INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
       EXPORTING
         INPUT  = wa_data-kunag
       IMPORTING
         OUTPUT = wa_data-kunag.

      SELECT SINGLE mandt INTO v_mandt
        FROM kna1
        WHERE kunnr EQ wa_data-kunag.
      IF sy-subrc NE 0.
        wa_data-text = 'Sold-To invalid'. "#EC NOTEXT
        wa_data-order = '1'.
        vg_error = 'x'.

        FREE cta.
        CLEAR cs.
        cs-fname = 'TEXT'.
        cs-color-col = 6.
        cs-nokeycol = 'X'.
        APPEND cs to cta.
        APPEND lines of cta to wa_data-ct.
        CLEAR cs.
      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
       EXPORTING
         INPUT  = wa_data-kunag
       IMPORTING
         OUTPUT = wa_data-kunag.
    ENDIF.

    IF wa_data-kbetr CN '0123456789. '.
      wa_data-text = 'Amount invalid'. "#EC NOTEXT
      wa_data-order = '1'.
      vg_error = 'x'.

      FREE cta.
      CLEAR cs.
      cs-fname = 'TEXT'.
      cs-color-col = 6.
      cs-nokeycol = 'X'.
      APPEND cs to cta.
      APPEND lines of cta to wa_data-ct.
      CLEAR cs.
    ENDIF.
    MODIFY it_data FROM wa_data.
  ENDLOOP.
ENDFORM.                    " upload_file

*---------------------------------------------------------------------*
*&      Form  get_filename
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FILENAME  text
*----------------------------------------------------------------------*
FORM get_filename USING p_fname TYPE ANY.

*****To read the file from Presentation Server
 CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
   EXPORTING
     program_name     =  sy-repid
     dynpro_number    =  syst-dynnr
     field_name       = p_fname
*   STATIC              = ' '
      mask            = '*.XLS'
   CHANGING
      file_name       = p_fname
   EXCEPTIONS
     mask_too_long    = 1
   OTHERS             = 2
            .
 IF sy-subrc <> 0.
   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
 ENDIF.

ENDFORM.                    " get_filename
*&---------------------------------------------------------------------*
*&      Form  alv_caract
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM alv_caract .

*- Monta Layout
  ti_alv_layout-zebra   = 'X'.         " Linhas diferenciadas por cores
  ti_alv_layout-detail_popup = 'X'.
  ti_alv_layout-colwidth_optimize = 'X'.
  ti_alv_layout-coltab_fieldname = 'CT'.
ENDFORM.                    " alv_caract
*&---------------------------------------------------------------------*
*&      Form  alv_columnas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_columnas .
  PERFORM alv_monta_columnas USING:
*1 2   3             4              5       6          7   8   9   10
*-----------------------------------------------------------------------
*------*
 0  1  'VBELN' 'IT_DATA'   ''  'Sales Order'   ''  ''  ''  '', "#EC NOTEXT
 0  2  'VKORG' 'IT_DATA'   ''  'Sales Org'  ''  ''  ''  '', "#EC NOTEXT
 0  3  'VTWEG' 'IT_DATA'   ''  'DChl'  ''  ''  ''  '', "#EC NOTEXT
 0  4  'MATNR' 'IT_DATA'   ''  'Material'   ''  ''  ''  '', "#EC NOTEXT
 0  5  'KDGRP' 'IT_DATA'   ''  'Cust.group'  ''  ''  ''  '', "#EC NOTEXT
 0  6  'KUNAG' 'IT_DATA'   ''  'Sold-To'  ''  ''  ''  '', "#EC NOTEXT
 0  7  'WERKS' 'IT_DATA'   ''  'Plant'  ''  ''  ''  '', "#EC NOTEXT
 0  8  'KSCHL' 'IT_DATA'   ''  'Condition'  ''  ''  ''  '', "#EC NOTEXT
 0  9  'ZZPRCSHTNR' 'IT_DATA'   ''  'Price Sheet'  ''  ''  ''  '', "#EC NOTEXT
 0  9  'KBETR' 'IT_DATA'   ''  'Amount'     ''  ''  ''  '', "#EC NOTEXT
 0  9  'KONWA' 'IT_DATA'   ''  'Currency'     ''  ''  ''  '', "#EC NOTEXT
 0  9  'DATAB' 'IT_DATA'   ''  'Valid From (mm/dd/aaaa)' ''  ''  ''  '', "#EC NOTEXT
 0  9  'DATBI' 'IT_DATA'   ''  'Valid To (mm/dd/aaaa)'   ''  ''  ''  '', "#EC NOTEXT
 0  9  'TEXT'  'IT_DATA'   ''  'Message'  ''  ''  ''  ''. "#EC NOTEXT
ENDFORM.                    " alv_columnas
*&---------------------------------------------------------------------*
*&      Form  alv_monta_columnas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM alv_monta_columnas  USING  x_row TYPE ANY
                                x_col TYPE ANY
                                x_field TYPE ANY
                                x_tab TYPE ANY
                                x_ref TYPE ANY
                                x_text TYPE ANY
                                x_sum TYPE ANY
                                x_type TYPE ANY
                                x_just TYPE ANY
                                x_qfield TYPE ANY.

  wa_alv_field_cat-row_pos           =  x_row.
  wa_alv_field_cat-col_pos           =  x_col.
  wa_alv_field_cat-fieldname         =  x_field.
  wa_alv_field_cat-tabname           =  x_tab.
  wa_alv_field_cat-ref_tabname       =  x_ref.
  wa_alv_field_cat-reptext_ddic      =  x_text.
  wa_alv_field_cat-do_sum            =  x_sum.
  wa_alv_field_cat-inttype           =  x_type.
  wa_alv_field_cat-just              =  x_just.
  wa_alv_field_cat-qfieldname        =  x_qfield.

  APPEND wa_alv_field_cat TO ti_alv_field_cat.
  CLEAR wa_alv_field_cat.
ENDFORM.                    " alv_monta_columnas
*&---------------------------------------------------------------------*
*&      Form  eje_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM eje_report.
 IF vg_error EQ 'x'.
   SORT it_data BY order ordcr.
 ELSE.
   SORT it_data BY ordcr.
 ENDIF.
 CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_background_id          = ' '
      is_layout                = ti_alv_layout
      it_fieldcat              = ti_alv_field_cat[]
    TABLES
      t_outtab                 = IT_DATA
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
 IF sy-subrc <> 0.
   MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
 ENDIF.
ENDFORM.                    " eje_report
*&---------------------------------------------------------------------*
*&      Form  f_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_C_X  text
*      -->P_0233   text
*      -->P_0234   text
*----------------------------------------------------------------------*
form f_dynpro  USING l_dynbegin TYPE c        " Inicio de pantalla.
                     l_name     TYPE c        " Nombre del campo.
                     value TYPE ANY.          " Valor del campo.

  DATA: l_valor TYPE c.                      " Valor del campo.

  CLEAR w_bdcdata.
  l_valor                 =  value.

* X = indica si inicia una pantalla.
  IF l_dynbegin           =  c_x.

    w_bdcdata-program   =  l_name.         " Nombre del programa.
    w_bdcdata-dynpro    =  value.          " No. de pantalla.
    w_bdcdata-dynbegin  =  c_x.            " Inicia la pantalla.
    APPEND w_bdcdata TO i_bdcdata.         " Inserta los datos.

  ELSE.

    IF l_valor(1)         <> '|'.

      w_bdcdata-fnam    =  l_name.        " Nombre tabla-campo.
      w_bdcdata-fval    =  value.         " Valor del campo.
      APPEND w_bdcdata TO i_bdcdata.       " Inserta los datos.

    ENDIF.                                  " Fin de  L_VALOR(1).

  ENDIF.
endform.                    " f_dynpro
