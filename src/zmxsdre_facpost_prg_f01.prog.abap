*&---------------------------------------------------------------------*
*&  Include           ZMXSDRE_FACPOST_PRG_F01
*&---------------------------------------------------------------------*
************************************************************************
*                    MODIFICATION LOG                                  *
* Modified by : LARAH2                                                 *
* Modification date : 13/MAY/2020                                      *
* Description : Delete delivery quantity validation                    *
* Request #: CHG0122555  CTS: NEDK955445                               *
************************************************************************
*& Description: Add Valid Date to ZMXBILCOND table                     *
*& Date/Author: 8/NOV/2024 - Heriberto Lara Llanas  LARAH2             *
*& Functional: Ricardo Zavala                                          *
*& Transport: NEDK9A0JEY                                               *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload_file .
DATA: it_file TYPE STANDARD TABLE OF ty_file,
      wa_file TYPE ty_file,
      wa_cellcolor  TYPE lvc_s_scol.

DATA: lv_fname TYPE STRING,
      lv_break TYPE NUMC1 value '0',
      lv_fecha TYPE CHAR08.

lv_fname = p_fname.
CALL FUNCTION 'GUI_UPLOAD'
  EXPORTING
    filename                = lv_fname
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
  MESSAGE text-e03 TYPE 'S' DISPLAY LIKE 'E'.
ELSE.
  DELETE it_file INDEX 1.
  FREE it_data[].
  CLEAR gv_error.
  LOOP AT it_file INTO wa_file.

    REPLACE ALL OCCURRENCES OF '"' IN wa_file-lfima WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN wa_file-lfima WITH ''.
    REPLACE ALL OCCURRENCES OF '"' IN wa_file-lfimg WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN wa_file-lfimg WITH ''.
    REPLACE ALL OCCURRENCES OF '"' IN wa_file-netpc WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN wa_file-netpc WITH ''.
    REPLACE ALL OCCURRENCES OF '"' IN wa_file-npedi WITH ''.
    REPLACE ALL OCCURRENCES OF '"' IN wa_file-fentm WITH ''.
    REPLACE ALL OCCURRENCES OF '"' IN wa_file-aduan WITH ''.

    TRY.
      MOVE-CORRESPONDING wa_file TO wa_data.
    CATCH CX_SY_CONVERSION_NO_NUMBER.
      MESSAGE text-e01 TYPE 'S' DISPLAY LIKE 'E'.
      EXIT.
    ENDTRY.

    wa_data-vbent = wa_file-vbeln.
    wa_data-vbelt = wa_file-vbelv.
    wa_data-matnt = wa_file-matnr.
    CALL FUNCTION 'DATE_STRING_CONVERT'
      EXPORTING
        date_format = '2'  "DD/MM/AAAA
        date_string = wa_file-lfdat
      IMPORTING
        result_date = wa_data-lfdat.

    CALL FUNCTION 'DATE_STRING_CONVERT'
      EXPORTING
        date_format = '2'  "DD/MM/AAAA
        date_string = wa_file-lfdtg
      IMPORTING
        result_date = wa_data-lfdtg.

    CALL FUNCTION 'DATE_STRING_CONVERT'
      EXPORTING
        date_format = '2'  "DD/MM/AAAA
        date_string = wa_file-lfdta
      IMPORTING
        result_date = wa_data-lfdta.

    IF NOT wa_file-fentm IS INITIAL.
      CONCATENATE wa_file-fentm+6(4)
                  wa_file-fentm+0(2)
                  wa_file-fentm+3(2) INTO lv_fecha.
      CALL FUNCTION 'RP_CHECK_DATE'
      EXPORTING
        DATE = lv_fecha
      EXCEPTIONS
        DATE_INVALID = 1.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'DATE_STRING_CONVERT'
        EXPORTING
          date_format = '2'  "DD/MM/AAAA
          date_string = wa_file-fentm
        IMPORTING
          result_date = wa_data-fentm.
      ELSE.
        wa_data-text = 'Fecha Ent México No Format'. "#EC NOTEXT
        gv_error = 'x'.

        CLEAR wa_cellcolor.
        wa_cellcolor-fname = 'TEXT'.
        wa_cellcolor-color-col = 6.
        wa_cellcolor-nokeycol = 'X'.
        APPEND wa_cellcolor TO wa_data-cellcolor.
      ENDIF.
    ENDIF.

     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  =  wa_data-vbeln
        IMPORTING
          OUTPUT =  wa_data-vbeln.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  =  wa_data-vbelv
        IMPORTING
          OUTPUT =  wa_data-vbelv.

    SELECT SINGLE kunnr INTO wa_data-kunnr FROM vbak
      WHERE vbeln EQ wa_data-vbeln.
    IF sy-subrc NE 0.
      wa_data-text = 'Order No SAP'. "#EC NOTEXT
      gv_error = 'x'.

      CLEAR wa_cellcolor.
      wa_cellcolor-fname = 'TEXT'.
      wa_cellcolor-color-col = 6.
      wa_cellcolor-nokeycol = 'X'.
      APPEND wa_cellcolor TO wa_data-cellcolor.
    ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  =  wa_data-matnr
        IMPORTING
          OUTPUT =  wa_data-matnr.

    SELECT SINGLE matnr INTO wa_data-matnr FROM mara
      WHERE matnr EQ wa_data-matnr.
    IF sy-subrc NE 0.
      wa_data-text = 'Material No SAP'. "#EC NOTEXT
      gv_error = 'x'.

      CLEAR wa_cellcolor.
      wa_cellcolor-fname = 'TEXT'.
      wa_cellcolor-color-col = 6.
      wa_cellcolor-nokeycol = 'X'.
      APPEND wa_cellcolor TO wa_data-cellcolor.
    ENDIF.

    SELECT SINGLE fkdat INTO wa_data-fkdat FROM likp
      WHERE vbeln EQ wa_data-vbelv.
    IF sy-subrc NE 0.
      wa_data-text = 'Delivery No SAP'. "#EC NOTEXT
      gv_error = 'x'.

      CLEAR wa_cellcolor.
      wa_cellcolor-fname = 'TEXT'.
      wa_cellcolor-color-col = 6.
      wa_cellcolor-nokeycol = 'X'.
      APPEND wa_cellcolor TO wa_data-cellcolor.
    ELSE.
      SELECT SINGLE matnr INTO wa_data-matnr FROM vbfa
        WHERE vbelv EQ wa_data-vbelv
          AND vbtyp_n EQ 'R'
          AND matnr EQ wa_data-matnr ##WARN_OK. "#EC CI_NOORDER
      IF sy-subrc NE 0.
        wa_data-text = 'Delivery Material Sin GI'. "#EC NOTEXT
        gv_error = 'x'.

        CLEAR wa_cellcolor.
        wa_cellcolor-fname = 'TEXT'.
        wa_cellcolor-color-col = 6.
        wa_cellcolor-nokeycol = 'X'.
        APPEND wa_cellcolor TO wa_data-cellcolor.
      ENDIF.

      SELECT SINGLE vbelv INTO wa_data-vbeln FROM vbfa "#EC CI_NOORDER
        WHERE vbelv EQ wa_data-vbeln
          AND vbeln EQ wa_data-vbelv
          AND vbtyp_v EQ 'C' ##WARN_OK. "#EC CI_NOORDER
      IF sy-subrc NE 0.
        wa_data-text = 'Delivery No en Order'. "#EC NOTEXT
        gv_error = 'x'.

        CLEAR wa_cellcolor.
        wa_cellcolor-fname = 'TEXT'.
        wa_cellcolor-color-col = 6.
        wa_cellcolor-nokeycol = 'X'.
        APPEND wa_cellcolor TO wa_data-cellcolor.
      ENDIF.

      IF wa_data-fkdat NE wa_data-lfdtg.
        wa_data-text = 'Fecha GI Diferente'. "#EC NOTEXT
        gv_error = 'x'.

        CLEAR wa_cellcolor.
        wa_cellcolor-fname = 'TEXT'.
        wa_cellcolor-color-col = 6.
        wa_cellcolor-nokeycol = 'X'.
        APPEND wa_cellcolor TO wa_data-cellcolor.
      ENDIF.
    ENDIF.

    IF wa_data-npedi IS INITIAL.
      SELECT SINGLE pedimento fecha aduana INTO (wa_data-npedi, wa_data-fentm, wa_data-aduan)
        FROM zmxpedim
        WHERE matnr EQ wa_data-matnr
          AND vbeln EQ wa_data-vbelv.
    ENDIF.

    APPEND wa_data TO it_data.
    CLEAR wa_data.
  ENDLOOP.
ENDIF.

SORT it_data BY vbeln ebeln zacre vbelv.

IF ( 0 < lines( it_data[] ) ).
SELECT customer datab datbi freightp INTO TABLE it_cond FROM zmxbilcond "#EC CI_NO_TRANSFORM
  FOR ALL ENTRIES IN it_data
  WHERE customer EQ it_data-kunnr. "NEDK9A0JEY
SORT it_cond BY kunnr datab.
ENDIF.

IF ( 0 < lines( it_data[] ) ).
SELECT vbeln posnr matnr netpr INTO TABLE it_vbap FROM vbap "#EC CI_NO_TRANSFORM
  FOR ALL ENTRIES IN it_data
  WHERE vbeln EQ it_data-vbeln.
ENDIF.

IF ( 0 < lines( it_data[] ) ).
SELECT vbeln vstel lfart INTO TABLE it_likp FROM likp "#EC CI_NO_TRANSFORM
  FOR ALL ENTRIES IN it_data
  WHERE vbeln EQ it_data-vbelv.
ENDIF.

IF ( 0 < lines( it_likp[] ) ).
SELECT vbeln posnr matnr vgbel werks lfimg FROM lips INTO TABLE it_lips "#EC CI_NO_TRANSFORM
  FOR ALL ENTRIES IN it_likp
  WHERE vbeln = it_likp-vbeln.
ENDIF.

SORT it_data BY vbeln ebeln zacre vbelv.
it_data_gi[] = it_data[].
LOOP AT it_data INTO wa_data.
  LOOP AT it_data_gi INTO wa_data_gi WHERE vbeln = wa_data-vbeln
                                       AND ebeln = wa_data-ebeln
                                       AND zacre = wa_data-zacre.
    IF wa_data-fkdat NE wa_data_gi-fkdat.
      wa_data-text = 'Fechas GI Diferentes'. "#EC NOTEXT
      gv_error = 'x'.

      CLEAR wa_cellcolor.
      wa_cellcolor-fname = 'TEXT'.
      wa_cellcolor-color-col = 6.
      wa_cellcolor-nokeycol = 'X'.
      APPEND wa_cellcolor TO wa_data-cellcolor.
      EXIT.
    ENDIF.
  ENDLOOP.

*-> NEDK955445
*  READ TABLE it_lips WITH KEY vbeln = wa_data-vbelv matnr = wa_data-matnr INTO wa_lips.
*  IF sy-subrc EQ 0.
*    wa_data-lfims = wa_lips-lfimg.
*    IF wa_data-lfimg NE wa_lips-lfimg.
*      wa_data-text = 'Unidades Diferentes'. "#EC NOTEXT
*      gv_error = 'x'.
*
*      CLEAR wa_cellcolor.
*      wa_cellcolor-fname = 'TEXT'.
*      wa_cellcolor-color-col = 6.
*      wa_cellcolor-nokeycol = 'X'.
*      APPEND wa_cellcolor TO wa_data-cellcolor.
*    ENDIF.
*<- NEDK955445
  READ TABLE it_vbap WITH KEY vbeln = wa_data-vbeln matnr = wa_data-matnr INTO wa_vbap.
  IF sy-subrc EQ 0.
    wa_data-netpr = wa_vbap-netpr.
    IF wa_data-netpc NE wa_vbap-netpr.
      wa_data-text = 'Precios Diferentes'. "#EC NOTEXT
      gv_error = 'x'.

      CLEAR wa_cellcolor.
      wa_cellcolor-fname = 'TEXT'.
      wa_cellcolor-color-col = 6.
      wa_cellcolor-nokeycol = 'X'.
      APPEND wa_cellcolor TO wa_data-cellcolor.
    ENDIF.
  ENDIF.
*  ENDIF.
  MODIFY it_data FROM wa_data TRANSPORTING netpr lfims text cellcolor.
ENDLOOP.

PERFORM p_bill.
SORT it_data BY vbeln ebeln zacre vbelv.
CLEAR: gv_nfac, wa_cellcolor.
it_data_gi[] = it_data[].
FREE it_data.
LOOP AT it_data_gi INTO wa_data.
APPEND wa_cellcolor TO wa_data-cellcolor.
*MODIFY it_data FROM wa_data TRANSPORTING cellcolor.
APPEND wa_data TO it_data.
AT END OF zacre.
  ADD 1 TO gv_nfac.
  IF lv_break EQ '1'.
    lv_break = '0'.
    wa_cellcolor-color-col = '0'.
    wa_cellcolor-color-int = '0'.
    wa_cellcolor-color-inv = '0'.
  ELSE.
    lv_break = '1'.
    wa_cellcolor-color-col = '4'.
    wa_cellcolor-color-int = '1'.
    wa_cellcolor-color-inv = '1'.
  ENDIF.
ENDAT.
ENDLOOP.
SORT it_data BY vbeln ebeln zacre vbelv.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_FNAME  text
*----------------------------------------------------------------------*
FORM get_filename  USING p_fname TYPE ANY.
*****To read the file from Presentation Server
  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
      program_name  = sy-repid
      dynpro_number = syst-dynnr
      field_name    = p_fname
*     STATIC        = ' '
      mask          = '*.XLS'
    CHANGING
      file_name     = p_fname
    EXCEPTIONS
      mask_too_long = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  alv_caract
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM alv_caract .
*- Monta Layout
  wa_alv_layout-zebra   = 'X'.         " Linhas diferenciadas por cores
*  wa_alv_layout-detail_popup = 'X'.
  wa_alv_layout-cwidth_opt = 'X'.
  wa_alv_layout-ctab_fname = 'CELLCOLOR'.
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
 0  '1'  'TEXT' 'IT_DATA'  '' 'X', "#EC NOTEXT
 0  '2'  'VBENT' 'IT_DATA'  'SAP Order' 'X', "#EC NOTEXT
 0  '3'  'EBELN' 'IT_DATA'  'PO' 'X', "#EC NOTEXT
 0  '4'  'ZACRE' 'IT_DATA'  'Acuse' 'X', "#EC NOTEXT
 0  '5'  'VBELT' 'IT_DATA'  'Delivey' 'X', "#EC NOTEXT
 0  '6'  'MATNT' 'IT_DATA'  'Material' 'X', "#EC NOTEXT
 0  '7'  'VBELF' 'IT_DATA'  'Factura Generada' 'X', "#EC NOTEXT
 0  '8'  'LFIMA' 'IT_DATA'  'Uds.' '', "#EC NOTEXT
 0  '9'  'LFIMG' 'IT_DATA'  'Uds.Recibidas' '', "#EC NOTEXT
* 0 '10'  'LFIMS' 'IT_DATA'  'Unidades SAP' '', "#EC NOTEXT " NEDK955445
 0 '11'  'NETPC' 'IT_DATA'  'Precio OC' '', "#EC NOTEXT
 0 '12'  'NETPR' 'IT_DATA'  'Precio SAP' '', "#EC NOTEXT
 0 '13'  'LFDAT' 'IT_DATA'  'Fecha Delivery' '', "#EC NOTEXT
 0 '14'  'LFDTG' 'IT_DATA'  'Fecha GI' '', "#EC NOTEXT
 0 '15'  'FKDAT' 'IT_DATA'  'Fecha GI SAP' '', "#EC NOTEXT
 0 '16'  'LFDTA' 'IT_DATA'  'Fecha Acuse' '', "#EC NOTEXT
 0 '17'  'NPEDI' 'IT_DATA'  'Número Pedimento' '', "#EC NOTEXT
 0 '18'  'FENTM' 'IT_DATA'  'Fecha Entrada México' '', "#EC NOTEXT
 0 '19'  'ADUAN' 'IT_DATA'  'Aduana Entrada' ''. "#EC NOTEXT

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
                                x_text TYPE ANY
                                x_fix TYPE ANY.

  wa_alv_catalog-row_pos           =  x_row.
  wa_alv_catalog-col_pos           =  x_col.
  wa_alv_catalog-fieldname         =  x_field.
  wa_alv_catalog-tabname           =  x_tab.
  wa_alv_catalog-coltext           =  x_text.
  wa_alv_catalog-fix_column        =  x_fix.

  APPEND wa_alv_catalog TO it_alv_catalog.
  CLEAR wa_alv_catalog .
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
CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
  EXPORTING
    i_callback_program       = sy-repid
    i_callback_pf_status_set = 'SET_PF_STATUS'
    i_callback_user_command  = 'USER_COMMAND'
    i_callback_top_of_page   = 'TOP_OF_PAGE'
    is_layout_lvc            = wa_alv_layout
    it_fieldcat_lvc          = it_alv_catalog[]
    i_save                   = 'A'
  TABLES
    t_outtab                 = it_data[]
  EXCEPTIONS
    program_error            = 1
    OTHERS                   = 2.
  IF sy-subrc <> 0.
    IF NOT sy-msgid IS INITIAL.
      MESSAGE ID sy-msgid
            TYPE 'X'
          NUMBER sy-msgno
            WITH sy-msgv1
                 sy-msgv2
                 sy-msgv3
                 sy-msgv4.
    ENDIF.
  ENDIF.
ENDFORM.                    " eje_report
FORM top_of_page ##CALLED ##NEEDED.
DATA: li_header TYPE slis_t_listheader,
      wa_header TYPE slis_listheader,
      lv_nfac TYPE CHAR6.
CLEAR wa_header.
IF gv_bill IS INITIAL.
  WRITE gv_nfac TO lv_nfac.
  wa_header-key = lv_nfac.
  wa_header-info = 'Facturas a Procesar'.  "#EC NOTEXT
  wa_header-typ = 'S'.
ELSE.
  wa_header-info = 'Deliveries Facturados'.  "#EC NOTEXT
  wa_header-typ = 'S'.
ENDIF.
APPEND wa_header TO li_header.

CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = li_header.
ENDFORM.
FORM set_pf_status USING rt_extab TYPE slis_t_extab ##CALLED ##NEEDED.
    SET PF-STATUS 'ZMXFACPOST'.
ENDFORM.
FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield  ##CALLED ##NEEDED.
DATA: lv_answer TYPE CHAR1.

IF o_ref_grid IS INITIAL.
  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      e_grid = o_ref_grid.
ENDIF.

IF NOT o_ref_grid IS INITIAL.
  CALL METHOD o_ref_grid->check_changed_data.
ENDIF.

CASE r_ucomm.
  WHEN 'FACP'.
    IF NOT gv_error IS INITIAL.
      MESSAGE text-e04 TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
    IF NOT gv_bill IS INITIAL.
      MESSAGE text-e05 TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        text_question = text-002
        popup_type    = 'ICON_MESSAGE_QUESTION'
      IMPORTING
        answer        = lv_answer.
     IF lv_answer EQ '1'.
      SORT it_data BY vbeln ebeln zacre vbelv.
      FREE it_facp.
      LOOP AT it_data INTO wa_data.
        READ TABLE it_facp INTO wa_facp WITH KEY vbelv = wa_data-vbelv.
        IF sy-subrc NE 0.
          MOVE-CORRESPONDING wa_data TO wa_facp.
          APPEND wa_facp TO it_facp.
        ENDIF.
        AT END OF zacre.
          PERFORM p_factura.
          FREE it_facp.
        ENDAT.
      ENDLOOP.
      PERFORM p_bill.
      rs_selfield-refresh = 'X'.
     ENDIF.
ENDCASE.
ENDFORM.
FORM p_factura.
DATA: lv_msgv1 TYPE sy-msgv1,
      lv_fkdat TYPE CHAR10,
      lv_freightp TYPE CHAR10,
      lv_cont TYPE NUMC2.
FREE: it_bdcdata[], it_msg[].
PERFORM bdc_start_dynpro USING  'SAPMV60A' '0102'.
CLEAR: lv_cont, gv_cont.
LOOP AT it_facp INTO wa_facp.
  ADD 1 TO gv_cont.
  ADD 1 TO lv_cont.
  CONCATENATE 'KOMFK-VBELN(' gv_cont ')' INTO gv_komfkvbeln.

  PERFORM bdc_add_field USING: 'BDC_CURSOR'         gv_komfkvbeln,
                               gv_komfkvbeln        wa_facp-vbelv.
  IF gv_cont GT '1'.
    PERFORM bdc_add_field USING 'BDC_OKCODE' '=FKAN'.
    PERFORM bdc_start_dynpro USING  'SAPMV60A' '0102'.
    gv_cont = 1.
  ENDIF.
ENDLOOP.

READ TABLE it_facp INDEX 1 INTO wa_facp.

PERFORM bdc_add_field USING: 'BDC_CURSOR'         gv_komfkvbeln,
                             'BDC_OKCODE'         '/00'.
IF lv_cont GT '1'.
PERFORM bdc_start_dynpro USING 'SAPMV60A' '0102'.
PERFORM bdc_add_field    USING: 'BDC_CURSOR'            gv_komfkvbeln,
                                'BDC_OKCODE'            '=FAKT'.
ENDIF.
PERFORM bdc_start_dynpro USING 'SAPMV60A' '0104'.
PERFORM bdc_add_field    USING: 'BDC_CURSOR'            'VBRK-FKART',
                                'BDC_OKCODE'            '=KFDE'.

   CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        date_internal            = sy-datum
      IMPORTING
        date_external            = lv_fkdat
      EXCEPTIONS
        date_internal_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

PERFORM bdc_start_dynpro  USING          'SAPMV60A' '6001'.
PERFORM bdc_add_field    USING: 'BDC_CURSOR'            'VBRK-FKDAT',
                                'VBRK-FKDAT'            lv_fkdat,
                                'VBRK-KTGRD'            'MA',
                                'BDC_OKCODE'            '=KFKO'.

PERFORM bdc_start_dynpro USING 'SAPMV60A' '6001'.
PERFORM bdc_add_field    USING: 'BDC_CURSOR'            'KOMV-KSCHL(01)',
                                'BDC_OKCODE'            '=V69A_KOAN'.

*READ TABLE it_cond WITH KEY kunnr = wa_facp-kunnr INTO wa_cond.
*IF sy-subrc EQ 0.
*  WRITE wa_cond-freightp CURRENCY 'MXN' TO lv_freightp.
*  PERFORM bdc_start_dynpro USING          'SAPMV60A' '6001'.
*  PERFORM bdc_add_field  USING: 'BDC_CURSOR'            'KOMV-KBETR(02)',
*                                'BDC_OKCODE'            '/00',
*                                'KOMV-KSCHL(02)'        'ZFL2',
*                                'KOMV-KBETR(02)'        lv_freightp.
*ENDIF.

LOOP AT it_cond INTO wa_cond WHERE kunnr = wa_facp-kunnr
                               AND datab LE sy-datum  "NEDK9A0JEY
                               AND datbi GE sy-datum. "NEDK9A0JEY
  WRITE wa_cond-freightp CURRENCY 'MXN' TO lv_freightp.
  PERFORM bdc_start_dynpro USING          'SAPMV60A' '6001'.
  PERFORM bdc_add_field  USING: 'BDC_CURSOR'            'KOMV-KBETR(02)',
                                'BDC_OKCODE'            '/00',
                                'KOMV-KSCHL(02)'        'ZFL2',
                                'KOMV-KBETR(02)'        lv_freightp.
  EXIT.
ENDLOOP.

PERFORM bdc_start_dynpro USING 'SAPMV60A' '6001'.
PERFORM bdc_add_field    USING: 'BDC_CURSOR'            'KOMV-KSCHL(03)',
                                'BDC_OKCODE'            '=V69A_KOAK'.

PERFORM bdc_start_dynpro USING          'SAPMV60A' '6001'.
PERFORM bdc_add_field    USING:
             'BDC_CURSOR'            'KOMV-KSCHL(03)',
             'BDC_OKCODE'            '=SICH'.

gv_mode = 'N'.

AUTHORITY-CHECK OBJECT 'S_TCODE'
  ID 'TCD' FIELD 'VF01'.
IF sy-subrc NE 0.
  MESSAGE e172(00) WITH 'VF01'.
ENDIF.

CALL TRANSACTION 'VF01' WITH AUTHORITY-CHECK USING it_bdcdata MODE gv_mode
      MESSAGES INTO it_msg.

WAIT UP TO 5 SECONDS.

IF sy-msgty = 'S'.
  MOVE sy-msgv1 TO lv_msgv1.
ENDIF.

*READ TABLE it_lips WITH KEY vbeln = wa_facp-vbelv INTO wa_lips.

PERFORM actualiza_pedims USING lv_msgv1.
PERFORM imprime USING lv_msgv1 'V01'.
ENDFORM.
*---------------------------------------------------------------------*
*       FORM BDC_START_DYNPRO                                         *
*---------------------------------------------------------------------*
*       initializes BDC_TABLE for next dynpro                         *
*---------------------------------------------------------------------*
*  -->  PROGRAM   name of program                                     *
*  -->  DYNPRO    dynpro number                                       *
*---------------------------------------------------------------------*
FORM bdc_start_dynpro USING program TYPE ANY
                            dynpro TYPE ANY.
  CLEAR wa_bdcdata.
  wa_bdcdata-program  = program.
  wa_bdcdata-dynpro   = dynpro.
  wa_bdcdata-dynbegin = 'X'.
  APPEND wa_bdcdata TO it_bdcdata.
ENDFORM.                    "BDC_START_DYNPRO

*---------------------------------------------------------------------*
*       FORM BDC_ADD_FIELD                                            *
*---------------------------------------------------------------------*
*       adds a new field to BDC_TABLE                                 *
*---------------------------------------------------------------------*
*  -->  FNAME     name of field                                       *
*  -->  FVALUE    value of field                                      *
*---------------------------------------------------------------------*
FORM bdc_add_field USING fname TYPE ANY
                         fvalue TYPE ANY.
  CLEAR wa_bdcdata.
  wa_bdcdata-fnam = fname.
  wa_bdcdata-fval = fvalue.
  APPEND wa_bdcdata TO it_bdcdata.
ENDFORM.                    "BDC_ADD_FIELD
*&      Form  actualiza_pedims
*&---------------------------------------------------------------------*
FORM actualiza_pedims USING p_ped TYPE ANY.
  DATA: lv_vbeln TYPE VBELN.

  TYPES: BEGIN OF tly_vbfa,
          vbelv TYPE VBELN_VON,
          vbeln TYPE VBELN,
          posnv TYPE POSNR_VON,
        END OF tly_vbfa.

  TYPES: BEGIN OF tly_lips,
          vbeln TYPE VBELN,
          posnr TYPE POSNR,
          matnr TYPE MATNR,
        END OF tly_lips.

  DATA: lt_vbfa TYPE STANDARD TABLE OF tly_vbfa, "#EC NEEDED
        lt_lips TYPE STANDARD TABLE OF tly_lips, "#EC NEEDED
        wlt_lips TYPE tly_lips. "#EC NEEDED

DATA: w_zped TYPE zsdnumped.

  CLEAR lv_vbeln.
  IF p_ped IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = p_ped
      IMPORTING
        output = lv_vbeln.

    SELECT vbelv
           vbeln
           posnv
      INTO TABLE lt_vbfa
      FROM vbfa
     WHERE vbeln = lv_vbeln
     AND vbtyp_v = 'J'.
    IF sy-subrc EQ 0.
      SORT lt_vbfa BY vbeln posnv.
      SELECT vbeln
             posnr
             matnr
        INTO TABLE lt_lips
        FROM lips
         FOR ALL ENTRIES IN lt_vbfa
       WHERE vbeln EQ lt_vbfa-vbelv
         AND posnr EQ lt_vbfa-posnv.

    ENDIF.

    SORT lt_lips BY matnr.
    LOOP AT lt_lips INTO wlt_lips.
        CLEAR wa_data.
        READ TABLE it_data INTO wa_data WITH KEY vbelv = wlt_lips-vbeln
                                                 matnr = wlt_lips-matnr.

        CLEAR w_zped.
        w_zped-mandt  = sy-mandt.
        w_zped-zinvn  = lv_vbeln.
        w_zped-zposn  = wlt_lips-posnr.
        w_zped-zpedn  = wa_data-npedi+0(15).
        w_zped-zremi = wlt_lips-vbeln.
        w_zped-zfere = wa_data-lfdat.
        w_zped-zacre = wa_data-zacre.
        w_zped-zfeac = wa_data-lfdta.
        w_zped-zpedd = wa_data-fentm.
        w_zped-zpedc  = wa_data-aduan+0(20).
        w_zped-zsuser = sy-uname.
        w_zped-zsdate = sy-datum.

       MODIFY zsdnumped FROM w_zped.

    ENDLOOP.
  ENDIF.
ENDFORM.                    " actualiza_pedims
*&---------------------------------------------------------------------*
*&      Form  imprime
*&---------------------------------------------------------------------*
FORM imprime  USING  p_bill TYPE ANY
                     p_werks TYPE ANY.

  DATA lv_bill TYPE vbeln.

  IF p_bill IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = p_bill
      IMPORTING
        output = lv_bill.

    FREE: it_bdcdata[], it_msg[].

      PERFORM bdc_start_dynpro USING          'ZSDFOFAX_CPY' '1000'.
      PERFORM bdc_add_field   USING:
                 'BDC_CURSOR'            'P_WERKS',
                 'BDC_OKCODE'            '=ONLI',
                 'P_WERKS'               p_werks,
*                 'P_LANGU'               'EN',
*                 'P_DECLT'               '1',
*                 'P_DIREC'               'Y',
                 'S_VBELN-LOW'           lv_bill .

      PERFORM bdc_start_dynpro USING          'SAPLSPRI' '0100'.
      PERFORM bdc_add_field   USING:
                 'BDC_CURSOR'            'PRI_PARAMS-PDEST',
                 'BDC_OKCODE'            '=PRIN'.

      PERFORM bdc_start_dynpro USING          'SAPMSSY0' '0120'.
      PERFORM bdc_add_field   USING:
                 'BDC_OKCODE'            '=%EX'.

      PERFORM bdc_start_dynpro USING          'ZSDFOFAX_CPY' '1000'.
      PERFORM bdc_add_field   USING:
                 'BDC_CURSOR'            'P_BUKRS',
                 'BDC_OKCODE'            '/EENDE'.


      AUTHORITY-CHECK OBJECT 'S_TCODE'
        ID 'TCD' FIELD 'ZIMPBILL'.
      IF sy-subrc NE 0.
        MESSAGE e172(00) WITH 'ZIMPBILL'.
      ENDIF.

      CALL TRANSACTION 'ZIMPBILL' WITH AUTHORITY-CHECK USING it_bdcdata MODE  gv_mode
           MESSAGES INTO it_msg.

*   Mensajes de la funcion
*    PERFORM manda_mensajes.

  ENDIF.

ENDFORM.                    " imprime
*&---------------------------------------------------------------------*
*&      Form  p_bill
*&---------------------------------------------------------------------*
FORM p_bill.
CLEAR gv_bill.
IF ( 0 < lines( it_data[] ) ).
SELECT vbelv vbeln INTO TABLE it_bill FROM vbfa
  FOR ALL ENTRIES IN it_data
  WHERE vbelv EQ it_data-vbelv
    AND vbtyp_n EQ 'M'.
ENDIF.

LOOP AT it_data INTO wa_data.
  READ TABLE it_bill WITH KEY vbelv = wa_data-vbelv INTO wa_bill.
  IF sy-subrc EQ 0.
    gv_bill = 'x'.
    wa_data-vbelf = wa_bill-vbeln.
    MODIFY it_data FROM wa_data TRANSPORTING vbelf.
  ENDIF.
ENDLOOP.
ENDFORM.                    " p_bill
