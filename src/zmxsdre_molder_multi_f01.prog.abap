************************************************************************
* 2/9/17   smartShift project

************************************************************************

*&---------------------------------------------------------------------*
*&  Include           ZMXSDRE_MOLDER_MULTI_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZMXSDRE_MOLDER_MULTI
*-------------------------------------------------------------
* Project : MOLDERS
* Requirement N°:
* Program : ZMXSDRE_MOLDER_MULTI
* Created by : CASTAI
* Creation date : 08/15/2016
* Description : Interfaz para administracion de facturacion molders
* Transport : NDVK9A1SFV.
*----------------------------------------------------------------------*
* Modification : Remove ITEMNO_ACC to BAPI_ACC_DOCUMENT_POST           *
* Programmer   : Heriberto Lara (LARAH2)                               *
* Date         : 18/FEB/2020                                           *
* Transport    : NEDK952228                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F0001_DATA_EXTRACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f0001_data_extraction .

  DATA: v_datum       TYPE sy-datum,
        w_output_alv  TYPE ty_log,
        s_kunnr       TYPE RANGE OF kna1-kunnr,
        w_kunnr       LIKE LINE OF s_kunnr,
        s_lifnr       TYPE RANGE OF lfa1-lifnr,
        w_lifnr       LIKE LINE OF s_lifnr,
        v_tabix       TYPE sy-tabix,
        s_estcr       TYPE RANGE OF ztmxsd_molders-estatus,
        w_estcr       LIKE LINE OF s_estcr,
        s_estsh       TYPE RANGE OF ztmxsd_molders-estatus,
        w_estsh       LIKE LINE OF s_estsh,
        w_stylerow    TYPE lvc_s_styl,
        t_stylerow    TYPE STANDARD TABLE OF lvc_s_styl.

  REFRESH: t_kna1, s_kunnr, s_lifnr, t_molder_load, t_knvv.

  CLEAR w_estsh.
  w_estsh-sign = c_i.
  w_estsh-option = c_eq.
  w_estsh-low = c_b1.
  APPEND w_estsh TO s_estsh.

  CLEAR w_estsh.
  w_estsh-sign = c_i.
  w_estsh-option = c_eq.
  w_estsh-low = c_c1.
  APPEND w_estsh TO s_estsh.

  CLEAR w_estcr.
  w_estcr-sign = c_i.
  w_estcr-option = c_eq.
  w_estcr-low = c_fin.
  APPEND w_estcr TO s_estcr.

  CLEAR w_estcr.
  w_estcr-sign = c_i.
  w_estcr-option = c_eq.
  w_estcr-low = c_c1.
  APPEND w_estcr TO s_estcr.

  CLEAR w_estcr.
  w_estcr-sign = c_i.
  w_estcr-option = c_eq.
  w_estcr-low = c_b1.
  APPEND w_estcr TO s_estcr.

*  IF p_crea = c_x OR p_edit = c_x.
  SELECT MAX( datum )
  FROM t007v
  INTO v_datum
  WHERE aland = c_mx
    AND mwskz = c_v0.

  IF NOT v_datum IS INITIAL.


*$smart (E) 2/9/17 - #601 Usage of unordered SELECT result set (views and transparent tables). (SINGLE -
*$smart (E) 2/9/17 - #601 existence check) (K)

    SELECT SINGLE trkorr
                  aland
                  mwskz
                  txjcd
                  datam
                  kschl
                  kbetr
                  datum
     FROM t007v
     INTO w_t007vv
     WHERE aland = c_mx
       AND mwskz = c_v0
       AND datum = v_datum.

  ENDIF.

  CLEAR v_datum.
  SELECT MAX( datum )
  FROM t007v
  INTO v_datum
  WHERE aland = c_mx
    AND mwskz = c_p2.

  IF NOT v_datum IS INITIAL.


*$smart (E) 2/9/17 - #601 Usage of unordered SELECT result set (views and transparent tables). (SINGLE -
*$smart (E) 2/9/17 - #601 existence check) (K)

    SELECT SINGLE trkorr
                  aland
                  mwskz
                  txjcd
                  datam
                  kschl
                  kbetr
                  datum
     FROM t007v
     INTO w_t007vp
     WHERE aland = c_mx
       AND mwskz = c_p2
       AND datum = v_datum.

  ENDIF.
*  ENDIF.

  IF p_show = c_x AND p_tbar IS INITIAL.

    REFRESH t_molder_load.

    SELECT  kunnr
            lifnr
            pbeln
            ibeln
            matnr
            fecha_save
            agrupador
            maktx
            fechaap
            net_qty
            net_cost
            subtotal
            iva_fac
            iva_cap
            total
            comments
            procesado
            estatus
            proc_by_pedido
            proc_by_factura
            proc_by_cargoap
            fecha_pedido
            fecha_factura
            fecha_cargo_ap
            numpedido
            numfactura
            numcargoap
    FROM ztmxsd_molders
    INTO TABLE t_molder_load
    WHERE kunnr             IN s_kunnr
      AND lifnr             IN s_lifnr
      AND ibeln             IN s_vbeln
      AND pbeln             IN s_ebeln
      AND fecha_pedido      IN s_datep
      AND fecha_factura     IN s_datef
      AND fecha_cargo_ap    IN s_datec
      AND numpedido         IN s_noped
      AND numfactura        IN s_nofac
      AND numcargoap        IN s_nocar
      AND matnr             IN s_matnr
      AND ( estatus         IN s_estat AND
            estatus         NE c_b1    AND
            estatus         NE c_c1 )
      AND procesado         IN s_procc.

    DELETE t_molder_load WHERE estatus IN s_estsh[].

  ELSEIF ( p_show = c_x AND p_tbar = c_x ) OR ( p_edit = c_x ).

    SELECT  kunnr
            lifnr
            pbeln
            ibeln
            matnr
            fecha_save
            agrupador
            maktx
            fechaap
            net_qty
            net_cost
            subtotal
            iva_fac
            iva_cap
            total
            comments
            procesado
            estatus
            proc_by_pedido
            proc_by_factura
            proc_by_cargoap
            fecha_pedido
            fecha_factura
            fecha_cargo_ap
            numpedido
            numfactura
            numcargoap
    FROM ztmxsd_molders
    INTO TABLE t_molder_load
    WHERE kunnr           IN s_kunnr
    AND lifnr             IN s_lifnr
    AND ibeln             IN s_vbeln
    AND pbeln             IN s_ebeln
    AND fecha_pedido      IN s_datep
    AND fecha_factura     IN s_datef
    AND fecha_cargo_ap    IN s_datec
    AND numpedido         IN s_noped
    AND numfactura        IN s_nofac
    AND numcargoap        IN s_nocar
    AND matnr             IN s_matnr
    AND estatus           IN s_estat
    AND procesado         IN s_procc.

    DELETE t_molder_load[] WHERE estatus IN s_estcr[].

  ENDIF.

  LOOP AT t_molder_load INTO w_molder_load.

    CLEAR w_kunnr.
    w_kunnr-sign   = c_i.
    w_kunnr-option = c_eq.
    w_kunnr-low    = w_molder_load-kunnr.
    COLLECT w_kunnr INTO s_kunnr.

    CLEAR w_lifnr.
    w_lifnr-sign   = c_i.
    w_lifnr-option = c_eq.
    w_lifnr-low    = w_molder_load-lifnr.
    COLLECT w_lifnr INTO s_lifnr.

  ENDLOOP.

  IF NOT s_kunnr[] IS INITIAL.
    SELECT kunnr
           name1
           name2
    FROM kna1
    INTO TABLE t_kna1
    WHERE kunnr IN s_kunnr[].

    IF sy-subrc = 0.
      SORT t_kna1 BY kunnr ASCENDING.
    ENDIF.

    SELECT  kunnr
            vkorg
            vtweg
            spart
            zterm
     FROM knvv
     INTO TABLE t_knvv
     WHERE kunnr IN s_kunnr[].

    IF sy-subrc = 0.
      SORT t_knvv[] BY kunnr ASCENDING.
    ENDIF.
  ENDIF.

  IF NOT s_lifnr[] IS INITIAL.
    SELECT lifnr
           name1
           name2
    FROM lfa1
    INTO TABLE t_lfa1
    WHERE lifnr IN s_lifnr[].

    IF sy-subrc = 0.
      SORT t_lfa1 BY lifnr ASCENDING.
    ENDIF.
*{ INSERT - NDVK9A1XM8 - Cond.Pago de Acreedor - 5. Buscar dato
    PERFORM f0024_buscar_condpago_acreedor USING s_lifnr.
*} INSERT - NDVK9A1XM8 - Cond.Pago de Acreedor - 5. Buscar dato
  ENDIF.

  IF NOT t_kna1 IS INITIAL.

*$smart (I) 2/9/17 - #728 SELECT INTO itab followed by SELECT FOR ALL ENTRIES IN itab. Driver table used after
*$smart (I) 2/9/17 - #728 the 2nd SELECT (K)

    SELECT kunnr
           vkorg
           vtweg
           spart
           parvw
           kunn2
    FROM knvp
    INTO TABLE t_knvp
    FOR ALL ENTRIES IN t_kna1
    WHERE kunnr = t_kna1-kunnr
      AND vkorg = c_vkorg
      AND vtweg = c_vtweg
      AND spart = c_spart.

    IF sy-subrc = 0.
      SORT t_knvp[] BY kunnr ASCENDING.
    ENDIF.
  ENDIF.

  IF p_show = c_x .
    IF NOT t_molder_load[] IS INITIAL.
      REFRESH t_alv_output_proc.

      LOOP AT t_molder_load INTO w_molder_load.
        CLEAR w_alv_output_proc.
        MOVE-CORRESPONDING w_molder_load TO w_alv_output_proc.
        SHIFT w_alv_output_proc-net_qty  LEFT DELETING LEADING space.
        SHIFT w_alv_output_proc-net_cost LEFT DELETING LEADING space.
        REPLACE ALL OCCURRENCES OF ',' IN w_alv_output_proc-net_qty WITH ''.
        REPLACE ALL OCCURRENCES OF ',' IN w_alv_output_proc-net_cost WITH ''.

        READ TABLE t_kna1 INTO w_kna1
        WITH KEY kunnr = w_molder_load-kunnr
        BINARY SEARCH.
        IF sy-subrc = 0.
          CONCATENATE w_kna1-name1 w_kna1-name2 INTO w_alv_output_proc-molder SEPARATED BY space.
        ENDIF.

        READ TABLE t_lfa1 INTO w_lfa1
        WITH KEY lifnr = w_molder_load-lifnr
        BINARY SEARCH.
        IF sy-subrc = 0.
          CONCATENATE w_lfa1-name1 w_lfa1-name2 INTO w_alv_output_proc-name SEPARATED BY space.
        ENDIF.

        APPEND w_alv_output_proc TO t_alv_output_proc.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF p_edit = c_x.
    IF NOT t_molder_load[] IS INITIAL.
      REFRESH t_alv_output.

      LOOP AT t_molder_load INTO w_molder_load.
        CLEAR w_alv_output.
        MOVE-CORRESPONDING w_molder_load TO w_alv_output.
        SHIFT w_alv_output-net_qty  LEFT DELETING LEADING space.
        SHIFT w_alv_output-net_cost LEFT DELETING LEADING space.

        READ TABLE t_kna1 INTO w_kna1
        WITH KEY kunnr = w_alv_output-kunnr
        BINARY SEARCH.
        IF sy-subrc = 0.
          CONCATENATE w_kna1-name1 w_kna1-name2 INTO w_alv_output-molder SEPARATED BY space.
        ENDIF.

        READ TABLE t_lfa1 INTO w_lfa1
        WITH KEY lifnr = w_alv_output-lifnr
        BINARY SEARCH.
        IF sy-subrc = 0.
          CONCATENATE w_lfa1-name1 w_lfa1-name2 INTO w_alv_output-name SEPARATED BY space.
        ENDIF.
        IF w_molder_load-estatus = c_error1 OR w_molder_load-estatus = c_error2 OR
           w_molder_load-estatus = c_error3 OR w_molder_load-estatus = c_error4.
          REFRESH: w_alv_output-field_style, t_stylerow.
          CLEAR w_stylerow.
          w_stylerow-fieldname = 'MAKTX' .
          w_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          APPEND w_stylerow  TO t_stylerow.
          CLEAR w_stylerow.
          w_stylerow-fieldname = 'FECHAAP'.
          w_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          APPEND w_stylerow  TO t_stylerow.
          CLEAR w_stylerow.
          w_stylerow-fieldname = 'IVA_FAC'.
          w_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          APPEND w_stylerow  TO t_stylerow.
          CLEAR w_stylerow.
          w_stylerow-fieldname = 'IVA_CAP'.
          w_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          APPEND w_stylerow  TO t_stylerow.
          CLEAR w_stylerow.
          w_stylerow-fieldname = 'NET_QTY' .
          w_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          APPEND w_stylerow  TO t_stylerow.
          CLEAR w_stylerow.
          w_stylerow-fieldname = 'NET_COST' .
          w_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          APPEND w_stylerow  TO t_stylerow.
          CLEAR w_stylerow.
          w_stylerow-fieldname = 'COMMENTS' .
          w_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          APPEND w_stylerow  TO t_stylerow.
          w_alv_output-field_style = t_stylerow[].
        ENDIF.
        APPEND w_alv_output TO t_alv_output.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " F0001_DATA_EXTRACTION
*&---------------------------------------------------------------------*
*&      Form  F0002_SHOW_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f0002_show_report.


*$smart (W) 2/9/17 - #166 Data declaration uses obsolete data type. (A)

  DATA: v_repid      TYPE REPID,                                                                 "$smart: #166
        w_layout     TYPE slis_layout_alv,
        v_pfstatus   TYPE slis_formname,
        v_times      TYPE i VALUE 50 ,
        v_number     TYPE i.

  REFRESH t_alv_fieldcat_save.
  CLEAR: w_alv_fieldcat, w_layout.
  v_repid = sy-repid.
  w_layout-zebra = c_x.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'AGRUPADOR'.
  w_alv_fieldcat-seltext_m   = text-001.    "Number
  w_alv_fieldcat-seltext_s   = text-001.    "Number
  w_alv_fieldcat-seltext_l   = text-001.    "Number
  w_alv_fieldcat-col_pos     = 0.
  w_alv_fieldcat-outputlen   = 5.
  w_alv_fieldcat-edit = c_x.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_save.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'KUNNR'.
  w_alv_fieldcat-seltext_m   = text-002.    "Client
  w_alv_fieldcat-seltext_s   = text-002.    "Client
  w_alv_fieldcat-seltext_l   = text-002.    "Client
  w_alv_fieldcat-col_pos     = 1.
  w_alv_fieldcat-outputlen   = 25.
  w_alv_fieldcat-ref_fieldname = 'KUNNR'.
  w_alv_fieldcat-ref_tabname   = 'KNA1'.
  w_alv_fieldcat-edit = c_x.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_save.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'MOLDER'.
  w_alv_fieldcat-seltext_m   = text-003.    "Molder "CLIENT NAME"
  w_alv_fieldcat-seltext_s   = text-003.    "Molder "CLIENT NAME"
  w_alv_fieldcat-seltext_l   = text-003.    "Molder "CLIENT NAME"
  w_alv_fieldcat-col_pos     = 2.
  w_alv_fieldcat-outputlen   = 35.
  w_alv_fieldcat-edit = ''.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_save.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'LIFNR'.
  w_alv_fieldcat-seltext_m   = text-006.    "Resin Supplier
  w_alv_fieldcat-seltext_s   = text-006.    "Resin Supplier
  w_alv_fieldcat-seltext_l   = text-006.    "Resin Supplier
  w_alv_fieldcat-col_pos     = 3.
  w_alv_fieldcat-outputlen   = 25.
  w_alv_fieldcat-ref_fieldname = 'LIFNR'.
  w_alv_fieldcat-ref_tabname   = 'LFA1'.
  w_alv_fieldcat-edit = c_x.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_save.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'NAME'.
  w_alv_fieldcat-seltext_m   = text-009.    "Resin Name
  w_alv_fieldcat-seltext_s   = text-009.    "Resin Name
  w_alv_fieldcat-seltext_l   = text-009.    "Resin Name
  w_alv_fieldcat-col_pos     = 4.
  w_alv_fieldcat-outputlen   = 35.
  w_alv_fieldcat-edit = ''.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_save.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'PBELN'.
  w_alv_fieldcat-seltext_m   = text-017.    "PO NUMBER
  w_alv_fieldcat-seltext_s   = text-017.    "PO NUMBER
  w_alv_fieldcat-seltext_l   = text-017.    "PO NUMBER
  w_alv_fieldcat-col_pos     = 5.
  w_alv_fieldcat-outputlen   = 25.
  w_alv_fieldcat-edit = c_x.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_save.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'IBELN'.
  w_alv_fieldcat-seltext_m   = text-028.    "INVOICE
  w_alv_fieldcat-seltext_s   = text-028.    "INVOICE
  w_alv_fieldcat-seltext_l   = text-028.    "INVOICE
  w_alv_fieldcat-col_pos     = 6.
  w_alv_fieldcat-outputlen   = 25.
  w_alv_fieldcat-edit = c_x.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_save.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'MATNR'.
  w_alv_fieldcat-seltext_m   = text-007.    "MATERIAL
  w_alv_fieldcat-seltext_s   = text-007.    "MATERIAL
  w_alv_fieldcat-seltext_l   = text-007.    "MATERIAL
  w_alv_fieldcat-col_pos     = 7.
  w_alv_fieldcat-outputlen   = 25.
  w_alv_fieldcat-ref_fieldname = 'MATNR'.
  w_alv_fieldcat-ref_tabname   = 'MARA'.
  w_alv_fieldcat-edit = c_x.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_save.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'MAKTX'.
  w_alv_fieldcat-seltext_m   = text-026.    "Descripcion Material
  w_alv_fieldcat-seltext_s   = text-026.    "Descripcion Material
  w_alv_fieldcat-seltext_l   = text-026.    "Descripcion Material
  w_alv_fieldcat-col_pos     = 8.
  w_alv_fieldcat-outputlen   = 40.
  w_alv_fieldcat-edit = c_x.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_save.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'FECHAAP'.
  w_alv_fieldcat-seltext_m   = text-033.    "Fecha Cargo AP
  w_alv_fieldcat-seltext_s   = text-033.    "Fecha Cargo AP
  w_alv_fieldcat-seltext_l   = text-033.    "Fecha Cargo AP
  w_alv_fieldcat-col_pos     = 9.
  w_alv_fieldcat-outputlen   = 25.
  w_alv_fieldcat-ref_fieldname = 'ERSDA'.
  w_alv_fieldcat-ref_tabname   = 'MARA'.
  w_alv_fieldcat-edit = c_x.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_save.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'NET_QTY'.
  w_alv_fieldcat-seltext_m   = text-010.    "NET QUANTITY
  w_alv_fieldcat-seltext_s   = text-010.    "NET QUANTITY
  w_alv_fieldcat-seltext_l   = text-010.    "NET QUANTITY
  w_alv_fieldcat-col_pos     = 10.
  w_alv_fieldcat-outputlen   = 25.
  w_alv_fieldcat-edit = c_x.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_save.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'NET_COST'.
  w_alv_fieldcat-seltext_m   = text-011.    "NET COST
  w_alv_fieldcat-seltext_s   = text-011.    "NET COST
  w_alv_fieldcat-seltext_l   = text-011.    "NET COST
  w_alv_fieldcat-col_pos     = 11.
  w_alv_fieldcat-outputlen   = 25.
  w_alv_fieldcat-edit = c_x.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_save.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'SUBTOTAL'.
  w_alv_fieldcat-seltext_m   = text-012.    "SUBTOTAL
  w_alv_fieldcat-seltext_s   = text-012.    "SUBTOTAL
  w_alv_fieldcat-seltext_l   = text-012.    "SUBTOTAL
  w_alv_fieldcat-col_pos     = 12.
  w_alv_fieldcat-outputlen   = 25.
  w_alv_fieldcat-edit = ''.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_save.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'IVA_FAC'.
  w_alv_fieldcat-seltext_m   = text-013.    "IVA FACTURA
  w_alv_fieldcat-seltext_s   = text-013.    "IVA FACTURA
  w_alv_fieldcat-seltext_l   = text-013.    "IVA FACTURA
  w_alv_fieldcat-col_pos     = 13.
  w_alv_fieldcat-outputlen   = 20.
  w_alv_fieldcat-ref_fieldname = 'IVA_FAC'.
  w_alv_fieldcat-ref_tabname   = 'ZTMXSD_MOLDERS'.
  w_alv_fieldcat-edit = c_x.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_save.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'IVA_CAP'.
  w_alv_fieldcat-seltext_m   = text-015.    "IVA CAP
  w_alv_fieldcat-seltext_s   = text-015.    "IVA CAP
  w_alv_fieldcat-seltext_l   = text-015.    "IVA CAP
  w_alv_fieldcat-col_pos     = 14.
  w_alv_fieldcat-outputlen   = 20.
  w_alv_fieldcat-ref_fieldname = 'IVA_CAP'.
  w_alv_fieldcat-ref_tabname   = 'ZTMXSD_MOLDERS'.
  w_alv_fieldcat-edit = c_x.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_save.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'TOTAL'.
  w_alv_fieldcat-seltext_m   = text-016.    "TOTAL
  w_alv_fieldcat-seltext_s   = text-016.    "TOTAL
  w_alv_fieldcat-seltext_l   = text-016.    "TOTAL
  w_alv_fieldcat-col_pos     = 15.
  w_alv_fieldcat-outputlen   = 25.
  w_alv_fieldcat-edit = ''.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_save.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'COMMENTS'.
  w_alv_fieldcat-seltext_m   = text-018.    "COMMENTS
  w_alv_fieldcat-seltext_s   = text-018.    "COMMENTS
  w_alv_fieldcat-seltext_l   = text-018.    "COMMENTS
  w_alv_fieldcat-col_pos     = 16.
  w_alv_fieldcat-outputlen   = 50.
  w_alv_fieldcat-edit = c_x.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_save.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = v_repid
      i_callback_pf_status_set = 'F0004_PF_STATUS'
      i_callback_user_command  = 'F0007_USER_COMMAND'
      is_layout                = w_layout
      it_fieldcat              = t_alv_fieldcat_save[]
    TABLES
      t_outtab                 = t_alv_output[]
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

ENDFORM.                    " F0002_SHOW_REPORT

*&---------------------------------------------------------------------*
*&      Form  F0007_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f0007_user_command USING r_ucomm     LIKE sy-ucomm
                              rs_selfield TYPE slis_selfield.

  DATA: v_limit         TYPE sy-dbcnt,
        v_consc         TYPE i,
        v_impresion     TYPE char1,
        v_value         TYPE char10,
        v_ans           TYPE string,
        v_tabix         TYPE sy-tabix,
        w_molder_lcl    TYPE ztmxsd_molders,
        w_molders_temp  TYPE ztmxsd_molders,
        w_molders_tem2  TYPE ztmxsd_molders,
        t_molder_lcl    TYPE STANDARD TABLE OF ztmxsd_molders,
        t_alv_back      TYPE STANDARD TABLE OF ty_log,
        t_alv_back_ctrl TYPE STANDARD TABLE OF ty_log.

  REFRESH t_alv_back.

  IF o_ref_grid IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = o_ref_grid.
  ENDIF.

  IF NOT o_ref_grid IS INITIAL.
    CALL METHOD o_ref_grid->check_changed_data.
  ENDIF.

  CALL METHOD o_ref_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.

  CALL METHOD o_ref_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.
*HLL
  create object g_event_receiver.
  set handler g_event_receiver->handle_data_changed for o_ref_grid.

  CASE r_ucomm.
      "SUMARIZE AND TEXTS FUNCTIONALITY
    WHEN '&TOTALS'.

      "TOTALS & SUBTOTALS CALCULATION
      PERFORM f0015_totals CHANGING t_alv_output[].
      "CLIENT & MATERIAL TEXTS
      PERFORM f0016_check_texts CHANGING t_alv_output[].

      rs_selfield-col_stable = 'X'.
      rs_selfield-row_stable = 'X'.
      rs_selfield-refresh = 'X'.

      "ADD FUCNTIONALITY
    WHEN '&ADD'.

      DESCRIBE TABLE t_alv_output[] LINES v_limit.
      READ TABLE t_alv_output INTO w_alv_output INDEX v_limit.
      v_consc = w_alv_output-agrupador + 1.
      CLEAR w_alv_output.
      w_alv_output-agrupador = v_consc.
      APPEND w_alv_output TO t_alv_output.
      SORT t_alv_output[] BY agrupador ASCENDING.

      rs_selfield-col_stable = 'X'.
      rs_selfield-row_stable = 'X'.
      rs_selfield-refresh = 'X'.

      "DELETE FUNCTIONALITY
    WHEN '&DELER'.
      REFRESH t_molder_lcl.

      IF p_crea = c_x.

        DELETE t_alv_output[] INDEX rs_selfield-tabindex.
        rs_selfield-col_stable = 'X'.
        rs_selfield-row_stable = 'X'.
        rs_selfield-refresh = 'X'.

      ELSEIF p_edit = c_x.
        SORT t_molder_load[] BY kunnr lifnr pbeln ibeln matnr ASCENDING.

        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar       = text-047
            text_question  = text-048
            text_button_1  = text-049
            text_button_2  = text-051
            default_button = '1'
            start_column   = 60
            start_row      = 6
          IMPORTING
            answer         = v_ans.

        IF v_ans = '1'.  "Borrar

          READ TABLE t_alv_output[] INTO w_alv_output INDEX rs_selfield-tabindex.
          READ TABLE t_molder_load[] INTO w_molder_load
            WITH KEY kunnr = w_alv_output-kunnr
                     lifnr = w_alv_output-lifnr
                     pbeln = w_alv_output-pbeln
                     ibeln = w_alv_output-ibeln
                     matnr = w_alv_output-matnr
          BINARY SEARCH.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING w_molder_load TO w_molder_lcl.
          ENDIF.

          IF NOT w_molder_lcl IS INITIAL.
            IF w_molder_lcl-estatus = c_error1 OR w_molder_lcl-estatus = c_error2 OR
               w_molder_lcl-estatus = c_error3 OR w_molder_lcl-estatus = c_error4 .
              w_molder_lcl-estatus = c_c1.
              w_molder_lcl-procesado = c_si.
            ELSEIF w_molder_lcl-estatus = c_inicio.
              w_molder_lcl-estatus = c_b1.
              w_molder_lcl-procesado = c_si.
            ENDIF.
            APPEND w_molder_lcl TO t_molder_lcl.
            IF NOT t_molder_lcl[] IS INITIAL.
              MODIFY ztmxsd_molders FROM TABLE t_molder_lcl.
              COMMIT WORK AND WAIT.
            ENDIF.
          ENDIF.
          DELETE t_alv_output[] INDEX rs_selfield-tabindex.
          rs_selfield-col_stable = 'X'.
          rs_selfield-row_stable = 'X'.
          rs_selfield-refresh = 'X'.

        ENDIF.
      ENDIF.

      "SAVE FUNCTIONALITY
    WHEN '&DATA_SAVE'.

      DELETE t_alv_output_proc[] WHERE kunnr IS INITIAL AND lifnr IS INITIAL AND pbeln IS INITIAL
                                   AND ibeln IS INITIAL AND matnr IS INITIAL AND fecha_save IS INITIAL
                                   AND agrupador IS INITIAL
                                   AND fechaap IS INITIAL AND net_qty IS INITIAL AND net_cost IS INITIAL
                                   AND iva_fac IS INITIAL AND iva_cap IS INITIAL AND comments IS INITIAL.

      CLEAR v_no_save.
      "DATA VALIDATIONS
      PERFORM f0009_data_check CHANGING v_no_save t_alv_output[] .

      IF v_no_save = ''.
        "CHECKS DATA DUPLICATE
        PERFORM f0013_data_duplicate CHANGING t_alv_output[] t_log_output[] .
        "TOTALS & SUBTOTALS CALCULATION,
        PERFORM f0015_totals CHANGING t_alv_output[].
        "CLIENT & MATERIAL TEXTS
        PERFORM f0016_check_texts CHANGING t_alv_output[].
        "SAVES DATA ON ZTMXSD_MOLDERS
        IF p_crea = c_x.
          PERFORM f0014_data_save CHANGING t_alv_output[] t_log_output[] .
        ELSEIF p_edit = c_x.
          PERFORM f0023_data_save CHANGING t_alv_output[] t_log_output[] t_molder_load[].
        ENDIF.
      ENDIF.

      rs_selfield-col_stable = 'X'.
      rs_selfield-row_stable = 'X'.
      rs_selfield-refresh = 'X'.

      "PROCESSING LOG DISPLAY
      IF NOT t_log_output[] IS INITIAL.
        PERFORM f0008_show_log.
      ENDIF.


      "PROCESS FUNCTIONALITY
    WHEN '&PROCESS'.
      REFRESH t_log_output.
*      "CHECKS DATA DUPLICATE
*      PERFORM f0010_data_duplicate CHANGING t_alv_output_proc[] t_log_output[] .
      t_alv_back[] = t_alv_output_proc[].
      t_alv_back_ctrl[] = t_alv_output_proc[].

      DELETE t_alv_output_proc[] WHERE kunnr IS INITIAL AND lifnr IS INITIAL AND pbeln IS INITIAL
                                   AND ibeln IS INITIAL AND matnr IS INITIAL AND fecha_save IS INITIAL
                                   AND agrupador IS INITIAL
                                   AND fechaap IS INITIAL AND net_qty IS INITIAL AND net_cost IS INITIAL
                                   AND iva_fac IS INITIAL AND iva_cap IS INITIAL AND comments IS INITIAL.
      SORT t_alv_output_proc[] BY kunnr lifnr pbeln ibeln matnr  ASCENDING.
      SORT t_alv_back_ctrl[] BY kunnr lifnr pbeln ibeln fecha_save agrupador ASCENDING.
      DELETE ADJACENT DUPLICATES FROM t_alv_back_ctrl[] COMPARING kunnr lifnr pbeln ibeln fecha_save agrupador.

*      "CLIENT & MATERIAL TEXTS
*      PERFORM f0019_check_texts CHANGING t_alv_back[].

      LOOP AT t_alv_back_ctrl INTO w_alv_output_proc.
        CLEAR: w_molders_save, w_log_output.
        w_molders_save-mandt = sy-mandt.
        MOVE-CORRESPONDING w_alv_output_proc TO w_molders_save.
        MOVE-CORRESPONDING w_alv_output_proc TO w_log_output.

        IF NOT w_alv_output_proc-numpedido IS INITIAL.
          w_molders_save-numpedido = w_alv_output_proc-numpedido.
        ENDIF.
        IF NOT w_alv_output_proc-numfactura IS INITIAL.
          w_molders_save-numfactura = w_alv_output_proc-numfactura.
        ENDIF.
        IF NOT w_alv_output_proc-numcargoap IS INITIAL.
          w_molders_save-numcargoap = w_alv_output_proc-numcargoap.
        ENDIF.

        "SALES ORDER PROCESSING
        IF ( w_alv_output_proc-estatus = c_inicio OR w_alv_output_proc-estatus = c_error1 )
        AND ( w_molders_save-numpedido IS INITIAL ).
          PERFORM f0003_sales_document      TABLES t_alv_back
                                            CHANGING w_alv_output_proc
                                                     w_molders_save
                                                     w_log_output.      "E1
        ENDIF.
        "INVOICE PROCESSING
        IF ( w_alv_output_proc-estatus = c_error1 OR w_alv_output_proc-estatus = c_error2 OR
             w_alv_output_proc-estatus = '' )
        AND ( NOT w_molders_save-numpedido IS INITIAL ) AND ( w_molders_save-numfactura IS INITIAL ) .
          PERFORM f0011_invoice_document    TABLES t_alv_back
                                            CHANGING w_alv_output_proc
                                                     w_molders_save
                                                     w_log_output.       "E2
        ENDIF.
        "ACCOUNTS PAYABLE PROCESSING
        IF ( w_alv_output_proc-estatus = c_error1 OR w_alv_output_proc-estatus = c_error3 OR
             w_alv_output_proc-estatus = c_error2 OR w_alv_output_proc-estatus = '' )
        AND ( NOT w_molders_save-numfactura IS INITIAL ) AND ( w_molders_save-numcargoap IS INITIAL ) .
          PERFORM f0005_account_payable_doc TABLES t_alv_back
                                            CHANGING w_alv_output_proc
                                                     w_molders_save
                                                     w_log_output.       "E3
        ENDIF.
        "PRINTING PROCESSING
        IF ( w_alv_output_proc-estatus = c_error1  OR w_alv_output_proc-estatus = c_error3 OR
             w_alv_output_proc-estatus = c_error2  OR w_alv_output_proc-estatus = c_error4 OR
             w_alv_output_proc-estatus = '') AND ( NOT w_molders_save-numfactura IS INITIAL AND NOT
             w_molders_save-numcargoap IS INITIAL AND NOT w_molders_save-numpedido IS INITIAL )
        AND ( NOT w_molders_save-numfactura IS INITIAL ).
          PERFORM f0006_impresion_factura   USING w_alv_output_proc
                                            CHANGING w_molders_save
                                                     v_impresion
                                                     w_log_output.        "E4 ZIMPBILL
        ENDIF.

        APPEND w_molders_save TO t_molders_save_aux.
        APPEND w_log_output   TO t_log_output.

      ENDLOOP.

      SORT t_molders_save_aux[] BY kunnr lifnr pbeln ibeln matnr ASCENDING.
      LOOP AT t_alv_output_proc INTO w_alv_output_proc.

        CLEAR v_tabix.
        v_tabix = sy-tabix.

        READ TABLE t_molders_save_aux INTO w_molders_temp
        WITH KEY kunnr = w_alv_output_proc-kunnr
                 lifnr = w_alv_output_proc-lifnr
                 pbeln = w_alv_output_proc-pbeln
                 ibeln = w_alv_output_proc-ibeln
                 matnr = w_alv_output_proc-matnr
        BINARY SEARCH.
        IF sy-subrc = 0.
          w_molders_tem2 = w_molders_temp.
          CONTINUE.
        ELSEIF sy-subrc NE 0.
          CLEAR w_molders_temp.
          MOVE-CORRESPONDING w_alv_output_proc TO w_molders_temp.
          w_molders_temp-procesado       = w_molders_tem2-procesado.
          w_molders_temp-estatus         = w_molders_tem2-estatus.
          w_molders_temp-proc_by_pedido  = w_molders_tem2-proc_by_pedido.
          w_molders_temp-proc_by_factura = w_molders_tem2-proc_by_factura.
          w_molders_temp-proc_by_cargoap = w_molders_tem2-proc_by_cargoap.
          w_molders_temp-fecha_pedido    = w_molders_tem2-fecha_pedido.
          w_molders_temp-fecha_factura   = w_molders_tem2-fecha_factura.
          w_molders_temp-fecha_cargo_ap  = w_molders_tem2-fecha_cargo_ap.
          w_molders_temp-numpedido       = w_molders_tem2-numpedido.
          w_molders_temp-numfactura      = w_molders_tem2-numfactura.
          w_molders_temp-numcargoap      = w_molders_tem2-numcargoap.
          APPEND w_molders_temp TO t_molders_save_aux2.
        ENDIF.
      ENDLOOP.

      APPEND LINES OF t_molders_save_aux[] TO t_molders_save_aux2[].
      IF NOT t_molders_save_aux2[] IS INITIAL.
        MODIFY ztmxsd_molders FROM TABLE t_molders_save_aux2.
        COMMIT WORK AND WAIT.
      ENDIF.

      "PROCESSING LOG DISPLAY
      PERFORM f0008_show_log.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.                    "F0007_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  F0004_PF_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_EXTAB    text
*----------------------------------------------------------------------*
FORM f0004_pf_status USING p_extab TYPE slis_t_extab.

  DATA: t_func TYPE TABLE OF sy-ucomm.
  REFRESH t_func.
  IF NOT p_edit IS INITIAL.
    APPEND '&ADD' TO t_func.
    SET PF-STATUS c_pf001 EXCLUDING  t_func.  "w/save AND w/O ADD
    IF sy-langu = c_s.
      SET TITLEBAR 'TIT004'.
    ELSEIF sy-langu = c_e.
      SET TITLEBAR 'TIT008'.
    ENDIF.
  ENDIF.
*  IF NOT p_save IS INITIAL.
*    SET PF-STATUS c_pf001.  "w/save
*  ELSEIF p_save IS INITIAL.
*    SET PF-STATUS c_pf003.  "wo/save
*  ENDIF.
  IF NOT p_save IS INITIAL.
    SET PF-STATUS c_pf001.  "w/save
    IF sy-langu = c_s.
      SET TITLEBAR 'TIT001'.
    ELSEIF sy-langu = c_e.
      SET TITLEBAR 'TIT005'.
    ENDIF.
  ENDIF.
  IF NOT p_show IS INITIAL.
    SET PF-STATUS c_pf003.  "wo/save
    IF sy-langu = c_s.
      SET TITLEBAR 'TIT003'.
    ELSEIF sy-langu = c_e.
      SET TITLEBAR 'TIT007'.
    ENDIF.
  ENDIF.
  IF NOT p_tbar IS INITIAL.
    SET PF-STATUS c_pf004.  "Process
    IF sy-langu = c_s.
      SET TITLEBAR 'TIT002'.
    ELSEIF sy-langu = c_e.
      SET TITLEBAR 'TIT006'.
    ENDIF.
  ENDIF.

ENDFORM.                    "F0004_PF_STATUS
*&---------------------------------------------------------------------*
*&      Form  F0003_SALES_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f0003_sales_document TABLES    pt_alv_back       TYPE tty_log  "Tabla actual de referencia
                          CHANGING  pw_alv_output_prc TYPE ty_log   "Estructura actual referencia
                                    pw_molders        TYPE ztmxsd_molders
                                    pw_log_output     TYPE ty_log.

  DATA: w_header     TYPE bapisdhd1,
        w_headerx    TYPE bapisdhd1x,
        t_item       TYPE STANDARD TABLE OF bapisditm ,
        w_item       TYPE bapisditm ,
        t_itemx      TYPE STANDARD TABLE OF bapisditmx ,
        w_itemx      TYPE bapisditmx ,
        t_partner    TYPE STANDARD TABLE OF bapiparnr  ,
        w_partner    TYPE bapiparnr  ,
        t_return     TYPE STANDARD TABLE OF bapiret2 ,
        w_return     TYPE bapiret2 ,
        t_schedule   TYPE STANDARD TABLE OF bapischdl  ,
        w_schedule   TYPE bapischdl  ,
        t_schedulex  TYPE STANDARD TABLE OF bapischdlx ,
        w_schedulex  TYPE bapischdlx ,
        t_condition  TYPE STANDARD TABLE OF bapicond,
        w_condition  TYPE bapicond,
        t_conditionx TYPE STANDARD TABLE OF bapicondx,
        w_conditionx TYPE bapicondx,
        t_text       TYPE STANDARD TABLE OF bapisdtext ,
        w_text       TYPE bapisdtext,
        v_pedido     TYPE bapivbeln-vbeln,
        w_alv_back   TYPE ty_log,
        v_matnr      TYPE char18,
        v_item       TYPE int1,
        v_string     TYPE string,
        v_count      TYPE int1,
        v_lines      TYPE sy-dbcnt,
        t_bapiparex  TYPE STANDARD TABLE OF bapiparex ,
        w_bapiparex  TYPE bapiparex.

  CLEAR w_text.
  w_text-text_id   = '0002'.
  w_text-langu     = c_e.
  CONCATENATE pw_alv_output_prc-pbeln pw_alv_output_prc-comments INTO w_text-text_line SEPARATED BY space.
  APPEND w_text TO t_text.
  CLEAR w_text.
  w_text-text_id   = '0002'.
  w_text-langu     = c_s.
  CONCATENATE pw_alv_output_prc-pbeln pw_alv_output_prc-comments INTO w_text-text_line SEPARATED BY space.
  APPEND w_text TO t_text.

  w_header-purch_date = sy-datum.
  IF NOT w_header-purch_date IS INITIAL.
    w_headerx-purch_date = c_x.
  ENDIF.
  w_header-po_method  = c_schr.
  IF NOT w_header-po_method IS INITIAL.
    w_headerx-po_method = c_x.
  ENDIF.
  w_header-price_date = sy-datum.
  IF NOT w_header-price_date IS INITIAL.
    w_headerx-price_date = c_x.
  ENDIF.
  w_header-doc_type   = c_ziis.
  IF NOT w_header-doc_type IS INITIAL.
    w_headerx-doc_type = c_x.
  ENDIF.
  w_header-sales_org  = c_vkorg.
  IF NOT w_header-sales_org IS INITIAL.
    w_headerx-sales_org = c_x.
  ENDIF.
  w_header-distr_chan = c_vtweg.
  IF NOT w_header-distr_chan IS INITIAL.
    w_headerx-distr_chan = c_x.
  ENDIF.
  w_header-division   = c_spart.
  IF NOT w_header-division IS INITIAL.
    w_headerx-division = c_x.
  ENDIF.
  CONCATENATE pw_alv_output_prc-name(24) pw_alv_output_prc-ibeln INTO w_header-purch_no_c SEPARATED BY space.
  IF NOT w_header-purch_no_c IS INITIAL.
    w_headerx-purch_no_c = c_x.
  ENDIF.
  CONCATENATE pw_alv_output_prc-name(24) pw_alv_output_prc-ibeln INTO w_header-purch_no_s SEPARATED BY space.
  IF NOT w_header-purch_no_s IS INITIAL.
    w_headerx-purch_no_s = c_x.
  ENDIF.
  w_header-currency   = c_usd.
  IF NOT w_header-currency IS INITIAL.
    w_headerx-currency = c_x.
  ENDIF.

  CLEAR w_partner.
  w_partner-partn_role = c_ag.
  w_partner-partn_numb = pw_alv_output_prc-kunnr.
  APPEND w_partner TO t_partner.

  READ TABLE t_knvp INTO w_knvp
  WITH KEY kunnr = pw_alv_output_prc-kunnr
           vkorg = c_vkorg
           vtweg = c_vtweg
           spart = c_spart
           parvw = c_we
  BINARY SEARCH.
  IF sy-subrc = 0.
    CLEAR w_partner.
    w_partner-partn_role = c_we.
    w_partner-partn_numb = pw_alv_output_prc-kunnr.
    APPEND w_partner TO t_partner.
  ENDIF.

  LOOP AT pt_alv_back INTO w_alv_back
  WHERE agrupador  = pw_alv_output_prc-agrupador
    AND fecha_save = pw_alv_output_prc-fecha_save
    AND kunnr      = pw_alv_output_prc-kunnr
    AND lifnr      = pw_alv_output_prc-lifnr
    AND pbeln      = pw_alv_output_prc-pbeln
    AND ibeln      = pw_alv_output_prc-ibeln.

    CLEAR: v_matnr, w_item, w_itemx, w_schedule, w_schedulex, w_condition, w_conditionx.
    v_item = v_item + 10.
    v_count = v_count + 1.

    w_itemx-updateflag = c_x.
    w_item-itm_number = v_item.
    IF NOT w_item-itm_number IS INITIAL.
      w_itemx-itm_number = v_item.
    ENDIF.
    w_item-material = w_alv_back-matnr.
    IF NOT w_item-material IS INITIAL.
      w_itemx-material = c_x.
    ENDIF.
    w_item-plant = c_m022.
    IF NOT w_item-plant IS INITIAL.
      w_itemx-plant = c_x.
    ENDIF.
    w_item-short_text = w_alv_back-maktx.
    IF NOT w_item-short_text IS INITIAL.
      w_itemx-short_text = c_x.
    ENDIF.
    w_item-target_qty = w_alv_back-net_qty.
    IF NOT w_item-target_qty IS INITIAL.
      w_itemx-target_qty = c_x.
    ENDIF.
    w_item-target_qu = c_kg.
    IF NOT w_item-target_qu IS INITIAL.
      w_itemx-target_qu = c_x.
    ENDIF.

    w_schedule-itm_number = v_item.
    IF NOT w_schedule-itm_number IS INITIAL.
      w_schedulex-itm_number = v_item.
    ENDIF.
    w_schedule-req_qty = w_alv_back-net_qty.
    IF NOT w_schedule-req_qty IS INITIAL.
      w_schedulex-req_qty = c_x.
    ENDIF.

    w_condition-itm_number  = v_item.
    IF NOT w_condition-itm_number IS INITIAL.
      w_conditionx-itm_number = v_item.
    ENDIF.
    w_condition-cond_type   = c_cond_prec.
    IF NOT w_condition-cond_type IS INITIAL.
      w_conditionx-cond_type = c_x.
    ENDIF.
    w_condition-cond_value  = w_alv_back-net_cost.
    IF NOT w_condition-cond_value IS INITIAL.
      w_conditionx-cond_value = c_x.
    ENDIF.
    w_condition-currency    = c_usd.
    IF NOT w_condition-currency IS INITIAL.
      w_conditionx-currency = c_x.
    ENDIF.
    w_condition-condcoinhd  = v_count.

    CLEAR: bape_vbap, w_bapiparex.
    bape_vbap-posnr         = v_item.
    bape_vbak-kostl         = c_ceco.
    w_bapiparex-structure   = 'BAPE_VBAK'.
    v_extension = bape_vbak.
    w_bapiparex-valuepart1 = v_extension.
    APPEND w_bapiparex TO t_bapiparex.

    CLEAR: bape_vbap, w_bapiparex.
    bape_vbakx-kostl      = c_x.
    w_bapiparex-structure = 'BAPE_VBAKX'.
    w_bapiparex-valuepart1 = v_extension.
    APPEND w_bapiparex TO t_bapiparex.
*{ INSERT - NDVK9A1XM8 - IVA Factura - 1. Asignar Clasif.IVA Material
    CLEAR w_item-tax_class1.
    CLEAR w_itemx-tax_class1.
    CLEAR w_header-alttax_cls.
    CLEAR w_headerx-alttax_cls.
    CASE w_alv_back-iva_fac.
      WHEN 'V0'. w_item-tax_class1   = '0'.
                 w_header-alttax_cls = '0'.
      WHEN 'P2'. w_item-tax_class1   = '1'.
                 w_header-alttax_cls = '2'.
      WHEN OTHERS.
    ENDCASE.
    if w_item-tax_class1 IS NOT INITIAL.
      w_itemx-tax_class1   = 'X'.
      w_headerx-alttax_cls = 'X'.
    endif.
*} INSERT - NDVK9A1XM8 - IVA Factura - 1. Asignar Clasif.IVA Material

    APPEND w_item       TO t_item.
    APPEND w_itemx      TO t_itemx.
    APPEND w_schedule   TO t_schedule.
    APPEND w_schedulex  TO t_schedulex.
    APPEND w_condition  TO t_condition.
    APPEND w_conditionx TO t_conditionx.

    ADD 1 TO v_lines.

  ENDLOOP.

  CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
    EXPORTING
      order_header_in      = w_header
      order_header_inx     = w_headerx
    IMPORTING
      salesdocument        = v_pedido
    TABLES
      return               = t_return
      order_items_in       = t_item
      order_items_inx      = t_itemx
      order_partners       = t_partner
      order_schedules_in   = t_schedule
      order_schedules_inx  = t_schedulex
      order_conditions_in  = t_condition
      order_conditions_inx = t_conditionx
      order_text           = t_text
      extensionin          = t_bapiparex.

*  MOVE-CORRESPONDING w_alv_back TO pw_molders.
*  MOVE-CORRESPONDING w_alv_back TO pw_log_output.

  IF NOT v_pedido IS INITIAL.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = c_x.

    PERFORM f0017_conv_exit_input CHANGING v_pedido.
    pw_molders-numpedido = v_pedido.
    pw_log_output-numpedido = v_pedido.
    pw_log_output-estatus = ''.
    pw_molders-estatus    = ''.
    pw_alv_output_prc-estatus = ''.
    pw_log_output-procesado = c_si.
    pw_molders-procesado = c_si.
    pw_alv_output_prc-procesado = c_si.
    pw_molders-proc_by_pedido = sy-uname.
    pw_molders-fecha_pedido = sy-datum.

  ELSE."ERROR

    LOOP AT t_return INTO w_return WHERE type = c_e.
      CONCATENATE v_string w_return-message INTO v_string SEPARATED BY space.
    ENDLOOP.

    pw_log_output-estatus = c_error1.
    pw_molders-estatus    = c_error1.
    pw_log_output-procesado = c_si.
    pw_molders-procesado = c_si.
    pw_log_output-mensaje = v_string.
    pw_molders-proc_by_pedido = sy-uname.
    pw_molders-fecha_pedido = sy-datum.

  ENDIF.

ENDFORM.                    " F0003_SALES_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  F0004_INVOICE_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f0011_invoice_document TABLES   pt_alv_back       TYPE tty_log
                            CHANGING pw_alv_output_prc TYPE ty_log
                                     pw_molders        TYPE ztmxsd_molders
                                     pw_log_output     TYPE ty_log.

  DATA: t_billing_data       TYPE STANDARD TABLE OF bapivbrk,
        w_billing_data       TYPE bapivbrk,
        t_condition_data     TYPE STANDARD TABLE OF bapikomv,
        w_condition_data     TYPE bapikomv,
        t_return             TYPE STANDARD TABLE OF bapireturn1,
        w_return             TYPE bapireturn1,
        t_card_data          TYPE STANDARD TABLE OF bapiccard_vf,
        w_alv_back           TYPE ty_log,
        v_vbeln              TYPE vbrk-vbeln,
        v_item               TYPE int1,
        v_string             TYPE string.

  CLEAR v_item.
  LOOP AT pt_alv_back INTO w_alv_back
     WHERE agrupador  = pw_alv_output_prc-agrupador
       AND fecha_save = pw_alv_output_prc-fecha_save

       AND kunnr      = pw_alv_output_prc-kunnr
       AND lifnr      = pw_alv_output_prc-lifnr
       AND pbeln      = pw_alv_output_prc-pbeln
       AND ibeln      = pw_alv_output_prc-ibeln.


    CLEAR: w_billing_data.
    v_item = v_item + 10.

    READ TABLE t_knvp INTO w_knvp
    WITH KEY kunnr = pw_alv_output_prc-kunnr
             vkorg = c_vkorg
             vtweg = c_vtweg
             spart = c_spart
             parvw = c_we
    BINARY SEARCH.
    IF sy-subrc = 0.
      w_billing_data-sold_to = w_knvp-kunn2.
    ENDIF.

    READ TABLE t_knvp INTO w_knvp
    WITH KEY kunnr = pw_alv_output_prc-kunnr
             vkorg = c_vkorg
             vtweg = c_vtweg
             spart = c_spart
             parvw = c_re
    BINARY SEARCH.
    IF sy-subrc = 0.
      w_billing_data-bill_to = w_knvp-kunn2.
    ENDIF.

    READ TABLE t_knvp INTO w_knvp
    WITH KEY kunnr = pw_alv_output_prc-kunnr
             vkorg = c_vkorg
             vtweg = c_vtweg
             spart = c_spart
             parvw = c_rg
    BINARY SEARCH.
    IF sy-subrc = 0.
      w_billing_data-payer = w_knvp-kunn2.
    ENDIF.

    READ TABLE t_knvp INTO w_knvp
    WITH KEY kunnr = pw_alv_output_prc-kunnr
             vkorg = c_vkorg
             vtweg = c_vtweg
             spart = c_spart
             parvw = c_ag
    BINARY SEARCH.
    IF sy-subrc = 0.
      w_billing_data-ship_to = w_knvp-kunn2.
    ENDIF.

    w_billing_data-salesorg    = c_vkorg.
    w_billing_data-distr_chan  = c_vtweg.
    w_billing_data-division    = c_spart.
    w_billing_data-doc_type    = c_ziis.
    w_billing_data-ordbilltyp  = c_ziis.
    w_billing_data-bill_date   = sy-datum.
    w_billing_data-price_date  = sy-datum.
    w_billing_data-plant       = c_m022.
    w_billing_data-ref_doc     = pw_molders-numpedido.
    w_billing_data-material    = pw_alv_output_prc-matnr.
*{ REPLACE - NDVK9A1XM8 - Cantidad repetida - 1. Corrección
*\    w_billing_data-req_qty     = pw_alv_output_prc-net_qty.
    w_billing_data-req_qty     = w_alv_back-net_qty.
*} REPLACE - NDVK9A1XM8 - Cantidad repetida - 1. Corrección
    w_billing_data-currency    = c_usd.
    w_billing_data-ref_item    = v_item.
    w_billing_data-name        = pw_alv_output_prc-name(35).
    w_billing_data-name_2      = pw_alv_output_prc-name+35(35).
    w_billing_data-purch_ord   = pw_alv_output_prc-pbeln.
    w_billing_data-doc_number  = pw_molders-numpedido.
    w_billing_data-itm_number  = v_item.
    w_billing_data-origindoc   = pw_molders-numpedido.
    w_billing_data-item        = v_item.
    w_billing_data-ref_doc_ca  = c_c.
    w_billing_data-costcenter  = c_ceco.
**{ INSERT - NDVK9A1XM8 - IVA Factura - 1. Asignar Clasif.IVA Material
*    CASE w_alv_back-iva_fac.
*      WHEN 'V0'. w_billing_data-taxcl_1mat = '0'.
*      WHEN 'P2'. w_billing_data-taxcl_1mat = '1'.
*      WHEN OTHERS.
*    ENDCASE.
**} INSERT - NDVK9A1XM8 - IVA Factura - 1. Asignar Clasif.IVA Material

    APPEND w_billing_data TO  t_billing_data.

  ENDLOOP.

  CALL FUNCTION 'BAPI_BILLINGDOC_CREATEFROMDATA'
    TABLES
      billing_data_in   = t_billing_data
      condition_data_in = t_condition_data
      returnlog_out     = t_return
      ccard_data_in     = t_card_data.

  READ TABLE t_return INTO w_return
  WITH KEY type   = c_s
           id     = c_vf
           number = c_311.
  IF sy-subrc = 0.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = c_x.

    v_vbeln = w_return-message_v1.
    PERFORM f0017_conv_exit_input CHANGING v_vbeln.
    pw_molders-numfactura = v_vbeln.
    pw_log_output-numfactura = v_vbeln.
    pw_log_output-estatus = ''.
    pw_molders-estatus    = ''.
    pw_alv_output_prc-estatus = ''.
    pw_log_output-procesado = c_si.
    pw_molders-procesado = c_si.
    pw_alv_output_prc-procesado = c_si.
    pw_molders-proc_by_factura = sy-uname.
    pw_molders-fecha_factura = sy-datum.

  ELSE. "Error

    LOOP AT t_return INTO w_return WHERE type = c_e.
      CONCATENATE v_string w_return-message INTO v_string SEPARATED BY space.
    ENDLOOP.

    pw_log_output-estatus = c_error2.
    pw_molders-estatus    = c_error2.
    pw_log_output-procesado = c_si.
    pw_molders-procesado = c_si.
    pw_log_output-mensaje = v_string.
    pw_molders-proc_by_factura = sy-uname.
    pw_molders-fecha_factura = sy-datum.

  ENDIF.

ENDFORM.                    " F0004_INVOICE_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  F0005_ACCOUNT_PAYABLE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f0005_account_payable_doc TABLES    pt_alv_back       TYPE tty_log
                               CHANGING  pw_alv_output_prc TYPE ty_log
                                         pw_molders        TYPE ztmxsd_molders
                                         pw_log_output     TYPE ty_log.

  DATA: w_alv_back   TYPE ty_log,
        v_float      TYPE f,
        v_item       TYPE int1,
        w_log        TYPE bdcmsgcoll,
        t_log        TYPE STANDARD TABLE OF bdcmsgcoll,
        v_belnr      TYPE belnr_d,
        w_header     TYPE bapiache09,
        v_obj_type   TYPE bapiache09-obj_type,
        v_obj_key    TYPE bapiache09-obj_key,
        v_obj_sys    TYPE bapiache09-obj_sys,
        w_accountgl  TYPE bapiacgl09,
        t_accountgl  TYPE STANDARD TABLE OF bapiacgl09,
        w_accountpy  TYPE bapiacap09,
        t_accountpy  TYPE STANDARD TABLE OF bapiacap09,
        w_accounttx  TYPE bapiactx09,
        t_accounttx  TYPE STANDARD TABLE OF bapiactx09,
        w_currencyam TYPE bapiaccr09,
        t_currencyam TYPE STANDARD TABLE OF bapiaccr09,
        w_return     TYPE bapiret2,
        t_return     TYPE STANDARD TABLE OF bapiret2,
        v_total      TYPE invfo-wrbtr,
        v_subtotal   TYPE invfo-wrbtr,
        v_tax        TYPE invfo-wrbtr,
        v_message    TYPE string,
        v_impuesto   TYPE invfo-wrbtr.
*{ INSERT - NDVK9A1XM8 - Cond.Pago de Acreedor - 6. Declarar apuntador
  FIELD-SYMBOLS <w_lfb1> like LINE OF ht_lfb1.
*} INSERT - NDVK9A1XM8 - Cond.Pago de Acreedor - 6. Declarar apuntador

  LOOP AT pt_alv_back INTO w_alv_back
     WHERE agrupador  = pw_alv_output_prc-agrupador
       AND fecha_save = pw_alv_output_prc-fecha_save
       AND kunnr      = pw_alv_output_prc-kunnr
       AND lifnr      = pw_alv_output_prc-lifnr
       AND pbeln      = pw_alv_output_prc-pbeln
       AND ibeln      = pw_alv_output_prc-ibeln.

    v_total = v_total + w_alv_back-total.
  ENDLOOP.

  READ TABLE pt_alv_back INTO w_alv_back
       WITH KEY agrupador  = pw_alv_output_prc-agrupador
                fecha_save = pw_alv_output_prc-fecha_save
                kunnr      = pw_alv_output_prc-kunnr
                lifnr      = pw_alv_output_prc-lifnr
                pbeln      = pw_alv_output_prc-pbeln
                ibeln      = pw_alv_output_prc-ibeln.


  READ TABLE t_knvv INTO w_knvv
  WITH KEY kunnr = w_alv_back-kunnr
           vkorg = c_vkorg
           vtweg = c_vtweg
           spart = c_spart
  BINARY SEARCH.

  IF w_alv_back-iva_cap = c_p2.
    IF NOT w_t007vp-kbetr IS INITIAL.
      v_float = w_t007vp-kbetr / 1000.
      v_tax   =  v_total * v_float .
    ELSE.
      v_tax   = '0'.
    ENDIF.
  ELSEIF w_alv_back-iva_cap = c_v0.
    IF NOT w_t007vv-kbetr IS INITIAL.
      v_float = w_t007vv-kbetr / 1000.
      v_tax   =  v_total * v_float .
    ELSE.
      v_tax   = '0'.
    ENDIF.
  ENDIF.

  IF NOT v_tax IS INITIAL.
    v_subtotal = v_total - v_tax.
  ELSE.
    v_subtotal = v_total - v_tax.
  ENDIF.

  w_header-username    = sy-uname.
  w_header-comp_code   = c_vkorg.
  w_header-doc_date    = w_alv_back-fechaap.
  w_header-pstng_date  = sy-datum.
  w_header-fisc_year   = sy-datum(4).
  w_header-fis_period  = sy-datum+4(2).
  w_header-ref_doc_no  = w_alv_back-ibeln.
  w_header-doc_type    = c_kr.

  v_item = 10.
  w_accountgl-itemno_acc = v_item.
  w_accountgl-gl_account = c_account_gl.
  w_accountgl-costcenter = c_ceco.
  w_accountgl-alloc_nmbr = w_alv_back-ibeln.
  PERFORM f0017_conv_exit_input CHANGING w_accountgl-costcenter.
  w_accountgl-tax_code   = w_alv_back-iva_cap.
  APPEND w_accountgl TO t_accountgl.

  CLEAR w_currencyam.
  w_currencyam-itemno_acc   = v_item.
  w_currencyam-currency_iso = c_usd.
*  w_currencyam-exch_rate    =
*{ INSERT - NDVK9A1XM8 - Doc.Contable - Corrección de importes
*= BUSCAR FACTURA Y ESTABLECER SUS IMPORTES AL DOC. CONTABLE
  DATA LX_DOC   TYPE BAPIVBRKSUCCESS-BILL_DOC.
  DATA LWA_DET  TYPE BAPIVBRKOUT.
  DATA LI_COUNT TYPE I.
  LX_DOC   = W_MOLDERS_SAVE-NUMFACTURA.
  LI_COUNT = 0.
  DO.
    CLEAR LWA_DET.
    CALL FUNCTION 'BAPI_BILLINGDOC_GETDETAIL'
      EXPORTING
        BILLINGDOCUMENT             = LX_DOC
      IMPORTING
        BILLINGDOCUMENTDETAIL       = LWA_DET
*       RETURN                      =
              .
    IF LWA_DET IS NOT INITIAL.
      EXIT.
    ENDIF.
    ADD 1 TO LI_COUNT.
    IF LI_COUNT >= 20.
      EXIT.
    ENDIF.
    WAIT UP TO '1' SECONDS.
  ENDDO.
*- Obtener importes de factura
  v_subtotal = lwa_det-net_value.
  v_tax      = lwa_det-tax_value.
*HLL
  IF w_alv_back-iva_cap = c_v0.
    CLEAR v_tax.
  ENDIF.
  v_total    = v_subtotal + v_tax.
*} INSERT - NDVK9A1XM8 - Doc.Contable - Corrección de importes
  w_currencyam-amt_base     = v_total.
  w_currencyam-disc_base    = v_total.
  w_currencyam-amt_doccur   = v_subtotal.
  w_currencyam-tax_amt      = v_tax.
  APPEND w_currencyam TO t_currencyam.

  v_item = v_item + 10.
  w_accountpy-itemno_acc = v_item.
  w_accountpy-vendor_no  = w_alv_back-lifnr.
  w_accountpy-tax_code   = w_alv_back-iva_cap.
*{ REPLACE - NDVK9A1XM8 - Cond.Pago de Acreedor - 7. Asignar
*\  w_accountpy-pmnttrms   = w_knvv-zterm.
  READ TABLE ht_lfb1 ASSIGNING <w_lfb1>
    WITH TABLE KEY lifnr = pw_alv_output_prc-lifnr.
  IF syst-subrc eq 0.
    w_accountpy-pmnttrms = <w_lfb1>-zterm.
  ENDIF.
*} REPLACE - NDVK9A1XM8 - Cond.Pago de Acreedor - 7. Asignar
  w_accountpy-alloc_nmbr = w_alv_back-ibeln.
  APPEND w_accountpy TO t_accountpy.

  CLEAR w_currencyam.
  w_currencyam-itemno_acc   = v_item.
  w_currencyam-currency_iso = c_usd.
*  w_currencyam-exch_rate    =
  w_currencyam-amt_doccur   = v_total * ( -1 ).
  APPEND w_currencyam TO t_currencyam.

  IF w_alv_back-iva_cap = c_p2.
    v_item = v_item + 10.
    w_accounttx-itemno_acc  = v_item.
    w_accounttx-gl_account  = c_taxaccount.
*    w_accounttx-itemno_tax  = v_item - 10.  "NEDK952228
*  w_accounttx-acct_key    = c_vst.
    w_accounttx-tax_code    = w_alv_back-iva_cap.
    APPEND w_accounttx TO t_accounttx.


    IF w_alv_back-iva_cap = c_p2.
      CLEAR w_currencyam.
      w_currencyam-itemno_acc   = v_item.
      w_currencyam-currency_iso = c_usd.
*  w_currencyam-exch_rate    =
      w_currencyam-amt_base     = v_subtotal.
      w_currencyam-amt_doccur   = v_tax.
      APPEND w_currencyam TO t_currencyam.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader = w_header
    IMPORTING
      obj_type       = v_obj_type
      obj_key        = v_obj_key
      obj_sys        = v_obj_sys
    TABLES
      accountgl      = t_accountgl
      accountpayable = t_accountpy
      accounttax     = t_accounttx
      currencyamount = t_currencyam
      return         = t_return.

  IF NOT v_obj_key = c_$.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = c_x.

    v_belnr = v_obj_key(10).
    PERFORM f0017_conv_exit_input CHANGING v_belnr.
    pw_molders-numcargoap = v_belnr.
    pw_log_output-numcargoap = v_belnr.
    pw_log_output-estatus = ''.
    pw_molders-estatus    = ''.
    pw_log_output-procesado = c_si.
    pw_molders-procesado = c_si.
    pw_molders-proc_by_cargoap = sy-uname.
    pw_molders-fecha_cargo_ap = sy-datum.

  ELSE. "ERROR

    LOOP AT t_return INTO w_return WHERE type = c_e.
      CONCATENATE v_message w_return-message INTO v_message SEPARATED BY space.
    ENDLOOP.

    pw_log_output-estatus = c_error3.
    pw_molders-estatus    = c_error3.
    pw_log_output-procesado = c_si.
    pw_molders-procesado = c_si.
    pw_log_output-mensaje = v_message.
    pw_molders-proc_by_cargoap = sy-uname.
    pw_molders-fecha_cargo_ap = sy-datum.

  ENDIF.

ENDFORM.                    " F0005_ACCOUNT_PAYABLE_DOC
*&---------------------------------------------------------------------*
*&      Form  F0006_IMPRESION_FACTURA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f0006_impresion_factura USING    pw_alv_output_prc TYPE ty_log
                             CHANGING pw_molders        TYPE ztmxsd_molders
                                      pv_impresion      TYPE char1
                                      pw_log_output     TYPE ty_log.

  DATA: s_vbeln TYPE RANGE OF vbrk-vbeln,
        w_vbeln LIKE LINE OF s_vbeln,
        v_spool TYPE sy-spono,
        v_memid TYPE char22.

  w_vbeln-sign = c_i.
  w_vbeln-option = c_eq.
  w_vbeln-low = pw_molders-numfactura.
  APPEND w_vbeln TO s_vbeln.
  CONCATENATE pw_molders-numfactura sy-uname INTO v_memid.

  SUBMIT zsdfofax_cpy TO SAP-SPOOL
  WITH p_bukrs EQ c_vkorg
  WITH p_werks EQ c_v01
  WITH p_langu EQ c_en
  WITH s_vbeln IN s_vbeln
  WITH p_extc  EQ c_x
  WITHOUT SPOOL DYNPRO
  AND RETURN.

  IMPORT v_spool FROM MEMORY ID v_memid.
  FREE MEMORY ID v_memid.

  IF NOT v_spool IS INITIAL.

    pw_log_output-estatus = c_fin.
    pw_molders-estatus    = c_fin.
    pw_log_output-procesado = c_si.
    pw_molders-procesado = c_si.

  ELSE. "ERROR

    pw_log_output-estatus = c_error4.
    pw_molders-estatus    = c_error4.
    pw_log_output-procesado = c_si.
    pw_molders-procesado = c_si.
    pw_log_output-mensaje = text-042."Error en la impresion de factura

  ENDIF.

ENDFORM.                    " F0006_IMPRESION_FACTURA
*&---------------------------------------------------------------------*
*&      Form  F0009_DATA_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f0009_data_check  CHANGING pv_no_save    TYPE char1
                                pt_alv_output TYPE tty_alv_reg_fac.

  TYPES: BEGIN OF ty_mara,
      matnr TYPE mara-matnr,
    END OF ty_mara,

    BEGIN OF ty_kna1,
      kunnr TYPE kna1-kunnr,
      name1 TYPE kna1-name1,
      name2 TYPE kna1-name2,
    END OF ty_kna1.

  DATA: t_mara   TYPE STANDARD TABLE OF ty_mara,
        w_mara   TYPE ty_mara,
        t_kna1   TYPE STANDARD TABLE OF ty_kna1,
        w_kna1   TYPE ty_kna1,
        s_kunnr  TYPE RANGE OF kna1-kunnr,
        w_kunnr  LIKE LINE OF s_kunnr,
        s_lifnr  TYPE RANGE OF lfa1-lifnr,
        w_lifnr  LIKE LINE OF s_lifnr,
        s_matnr  TYPE RANGE OF mara-matnr,
        w_matnr  LIKE LINE OF s_matnr,
        v_tabix  TYPE sy-tabix,
        v_string TYPE string.

  LOOP AT pt_alv_output INTO w_alv_output.

    CLEAR w_matnr.
    w_matnr-sign   = c_i.
    w_matnr-option = c_eq.
    w_matnr-low    = w_alv_output-matnr.
    COLLECT w_matnr INTO s_matnr.

    CLEAR w_kunnr.
    w_kunnr-sign   = c_i.
    w_kunnr-option = c_eq.
    w_kunnr-low    = w_alv_output-kunnr.
    COLLECT w_kunnr INTO s_kunnr.

    CLEAR w_lifnr.
    w_lifnr-sign   = c_i.
    w_lifnr-option = c_eq.
    w_lifnr-low    = w_alv_output-lifnr.
    COLLECT w_lifnr INTO s_lifnr.

  ENDLOOP.

  IF NOT s_kunnr[] IS INITIAL.
    SELECT kunnr
           name1
           name2
    FROM kna1
    INTO TABLE t_kna1
    WHERE kunnr IN s_kunnr[].

    IF sy-subrc = 0.
      SORT t_kna1 BY kunnr ASCENDING.
    ENDIF.
  ENDIF.

  IF NOT s_lifnr[] IS INITIAL.
    SELECT lifnr
           name1
           name2
    FROM lfa1
    INTO TABLE t_lfa1
    WHERE lifnr IN s_lifnr[].

    IF sy-subrc = 0.
      SORT t_lfa1 BY lifnr ASCENDING.
    ENDIF.
  ENDIF.

  IF NOT s_matnr[] IS INITIAL.
    SELECT matnr
    FROM mara
    INTO TABLE t_mara
    WHERE matnr IN s_matnr[].
    IF sy-subrc = 0.
      SORT t_mara BY matnr ASCENDING.
    ENDIF.
  ENDIF.

  LOOP AT pt_alv_output INTO w_alv_output.

    IF w_alv_output-lifnr IS INITIAL.
      pv_no_save = c_x.
      MESSAGE s001(00) WITH text-025 text-053 "Tiene aun campos en blanco sin capturar, favor de llenar todos los campos
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

    IF w_alv_output-kunnr IS INITIAL.
      pv_no_save = c_x.
      MESSAGE s001(00) WITH text-025 text-053 "Tiene aun campos en blanco sin capturar, favor de llenar todos los campos
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

    IF w_alv_output-agrupador IS INITIAL.
      pv_no_save = c_x.
      MESSAGE s001(00) WITH text-025 text-053 "Tiene aun campos en blanco sin capturar, favor de llenar todos los campos
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

    IF w_alv_output-pbeln IS INITIAL.
      pv_no_save = c_x.
      MESSAGE s001(00) WITH text-025 text-053 "Tiene aun campos en blanco sin capturar, favor de llenar todos los campos
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

    IF w_alv_output-ibeln IS INITIAL.
      pv_no_save = c_x.
      MESSAGE s001(00) WITH text-025 text-053 "Tiene aun campos en blanco sin capturar, favor de llenar todos los campos
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

    IF w_alv_output-matnr IS INITIAL.
      pv_no_save = c_x.
      MESSAGE s001(00) WITH text-025 text-053 "Tiene aun campos en blanco sin capturar, favor de llenar todos los campos
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

    IF w_alv_output-net_qty IS INITIAL.
      pv_no_save = c_x.
      MESSAGE s001(00) WITH text-025 text-053 "Tiene aun campos en blanco sin capturar, favor de llenar todos los campos
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

    IF w_alv_output-net_cost IS INITIAL.
      pv_no_save = c_x.
      MESSAGE s001(00) WITH text-025 text-053 "Tiene aun campos en blanco sin capturar, favor de llenar todos los campos
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

    IF w_alv_output-maktx IS INITIAL.
      pv_no_save = c_x.
      MESSAGE s001(00) WITH text-025 text-053 "Tiene aun campos en blanco sin capturar, favor de llenar todos los campos
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

    IF w_alv_output-fechaap IS INITIAL.
      pv_no_save = c_x.
      MESSAGE s001(00) WITH text-025 text-053 "Tiene aun campos en blanco sin capturar, favor de llenar todos los campos
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

    IF w_alv_output-iva_fac IS INITIAL.
      pv_no_save = c_x.
      MESSAGE s001(00) WITH text-025 text-053 "Tiene aun campos en blanco sin capturar, favor de llenar todos los campos
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

    IF w_alv_output-iva_cap IS INITIAL.
      pv_no_save = c_x.
      MESSAGE s001(00) WITH text-025 text-053 "Tiene aun campos en blanco sin capturar, favor de llenar todos los campos
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

    IF w_alv_output-comments IS INITIAL.
      pv_no_save = c_x.
      MESSAGE s001(00) WITH text-025 text-053 "Tiene aun campos en blanco sin capturar, favor de llenar todos los campos
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

    READ TABLE t_mara INTO w_mara
    WITH KEY matnr = w_alv_output-matnr
    BINARY SEARCH.
    IF sy-subrc NE 0.
      pv_no_save = c_x.
      CLEAR v_string.
      CONCATENATE text-037            "El material
                  w_alv_output-matnr  "No Material
                  text-039            "No existe
      INTO v_string SEPARATED BY space.
      MESSAGE s001(00) WITH v_string
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

    READ TABLE t_kna1 INTO w_kna1
    WITH KEY kunnr = w_alv_output-kunnr
    BINARY SEARCH.
    IF sy-subrc NE 0.
      pv_no_save = c_x.
      CLEAR v_string.
      CONCATENATE text-040            "El cliente
                  w_alv_output-kunnr  "No cliente
                  text-039            "No existe
      INTO v_string SEPARATED BY space.
      MESSAGE s001(00) WITH v_string
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

    READ TABLE t_lfa1 INTO w_lfa1
    WITH KEY lifnr = w_alv_output-lifnr
    BINARY SEARCH.
    IF sy-subrc NE 0.
      pv_no_save = c_x.
      CLEAR v_string.
      CONCATENATE text-041            "El resinero
                  w_alv_output-lifnr  "No resinero
                  text-039            "No existe
      INTO v_string SEPARATED BY space.
      MESSAGE s001(00) WITH v_string
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

    IF NOT w_alv_output-iva_cap = c_v0 AND
       NOT w_alv_output-iva_cap = c_p2.
      pv_no_save = c_x.
      MESSAGE s001(00) WITH text-054 "Seleccione clave P2 o V0 unicamente
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

    IF NOT w_alv_output-iva_fac = c_v0 AND
       NOT w_alv_output-iva_fac = c_p2.
      pv_no_save = c_x.
      MESSAGE s001(00) WITH text-054 "Seleccione clave P2 o V0 unicamente
      DISPLAY LIKE c_e.
      EXIT.
    ENDIF.

  ENDLOOP.

  DELETE pt_alv_output[] WHERE kunnr IS INITIAL AND lifnr IS INITIAL AND pbeln IS INITIAL
                           AND ibeln IS INITIAL AND matnr IS INITIAL AND fecha_save IS INITIAL
                           AND agrupador IS INITIAL.


ENDFORM.                    " F0009_DATA_CHECK

*&---------------------------------------------------------------------*
*&      Form  f0013_data_duplicate
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_ALV_OUTPUT  text
*      -->PT_LOG_OUTPUT  text
*----------------------------------------------------------------------*
FORM f0013_data_duplicate CHANGING pt_alv_output TYPE tty_alv_reg_fac
                                   pt_log_output TYPE tty_log.

  TYPES: BEGIN OF ty_molder,
    kunnr     TYPE kna1-kunnr,
    lifnr     TYPE kna1-kunnr,
    pbeln     TYPE ekko-ebeln,
    ibeln     TYPE vbak-vbeln,
    matnr     TYPE mara-matnr,
  END OF ty_molder.

  DATA: t_backup_alv   TYPE STANDARD TABLE OF ty_alv_reg_fac,
        w_backup_alv   TYPE ty_alv_reg_fac,
        v_tabix        TYPE sy-tabix,
        v_counter      TYPE i,
        t_molder       TYPE STANDARD TABLE OF ty_molder,
        w_molder       TYPE ty_molder.

  REFRESH : t_backup_alv[], pt_log_output[], t_molder[].

  t_backup_alv[]  = pt_alv_output[].

  SORT t_backup_alv[]   BY kunnr lifnr pbeln ibeln matnr ASCENDING.
  SORT pt_alv_output[]  BY kunnr lifnr pbeln ibeln matnr ASCENDING.
  DELETE ADJACENT DUPLICATES FROM t_backup_alv[] COMPARING kunnr lifnr pbeln ibeln matnr.

  "COMPARE AGAINTS TYPED REGISTERS
  LOOP AT t_backup_alv[] INTO w_backup_alv.

    CLEAR v_counter.

    LOOP AT pt_alv_output INTO w_alv_output
    WHERE kunnr  = w_backup_alv-kunnr
      AND lifnr  = w_backup_alv-lifnr
      AND pbeln  = w_backup_alv-pbeln
      AND ibeln  = w_backup_alv-ibeln
      AND matnr  = w_backup_alv-matnr.

      ADD 1 TO v_counter.
      IF v_counter GT 1.
        CLEAR v_tabix.
        v_tabix = sy-tabix.

        CLEAR w_log_output.
        MOVE-CORRESPONDING w_alv_output TO w_log_output.
        w_log_output-mensaje = text-027.   "Registro duplicado
        APPEND w_log_output TO pt_log_output.

        DELETE pt_alv_output INDEX v_tabix.
      ENDIF.

    ENDLOOP.
  ENDLOOP.

  SORT pt_alv_output[] BY agrupador ASCENDING.

  "COMPARE AGAINST EXISTING RECORDS
  IF p_edit NE c_x.

    LOOP AT pt_alv_output INTO w_alv_output.
      CLEAR v_tabix.
      v_tabix = sy-tabix.
      PERFORM f0017_conv_exit_input CHANGING w_alv_output-lifnr.
      PERFORM f0017_conv_exit_input CHANGING w_alv_output-kunnr.
      PERFORM f0017_conv_exit_input CHANGING w_alv_output-ibeln.
      PERFORM f0017_conv_exit_input CHANGING w_alv_output-pbeln.
      PERFORM f0018_conv_exit_input CHANGING w_alv_output-matnr.
      MODIFY pt_alv_output FROM w_alv_output INDEX v_tabix.
    ENDLOOP.

    IF NOT pt_alv_output[] IS INITIAL.
      SELECT kunnr
             lifnr
             pbeln
             ibeln
             matnr
      FROM ztmxsd_molders
      INTO TABLE t_molder
      FOR ALL ENTRIES IN pt_alv_output
      WHERE   kunnr  = pt_alv_output-kunnr
          AND lifnr  = pt_alv_output-lifnr
          AND pbeln  = pt_alv_output-pbeln
          AND ibeln  = pt_alv_output-ibeln
          AND matnr  = pt_alv_output-matnr
          AND ( estatus = c_error1 OR
                estatus = c_error2 OR
                estatus = c_error3 OR
                estatus = c_error4 OR
                estatus = c_inicio OR
                estatus = c_fin ).

      IF sy-subrc = 0.

        "RE-SEARCH DUPLICATES
        LOOP AT t_molder[] INTO w_molder.

          CLEAR v_counter.

          LOOP AT pt_alv_output INTO w_alv_output
          WHERE kunnr  = w_molder-kunnr
            AND lifnr  = w_molder-lifnr
            AND pbeln  = w_molder-pbeln
            AND ibeln  = w_molder-ibeln
            AND matnr  = w_molder-matnr.

            ADD 1 TO v_counter.
            IF v_counter EQ 1.
              CLEAR v_tabix.
              v_tabix = sy-tabix.

              CLEAR w_log_output.
              MOVE-CORRESPONDING w_alv_output TO w_log_output.
              w_log_output-mensaje = text-027.
              APPEND w_log_output TO pt_log_output.

              DELETE pt_alv_output INDEX v_tabix.
            ENDIF.

          ENDLOOP.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "f0013_data_duplicate
*&---------------------------------------------------------------------*
*&      Form  F0010_DATA_DUPLICATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f0010_data_duplicate CHANGING pt_alv_output TYPE tty_log
                                   pt_log_output TYPE tty_log.

  DATA: t_backup_alv   TYPE STANDARD TABLE OF ty_alv_reg_fac,
        w_backup_alv   TYPE ty_alv_reg_fac,
        v_tabix        TYPE sy-tabix,
        v_counter      TYPE i,
        w_alv          TYPE ty_log.

  REFRESH : t_backup_alv, pt_log_output.


*$smart (E) 2/9/17 - #109 Incompatible variables in expression (e.g. MOVE, COMPUTE, etc.). (M)

  t_backup_alv[]  = pt_alv_output[].

*  SORT t_backup_alv[]   BY kunnr molder LIFNR pbeln ibeln matnr ASCENDING.
*  SORT pt_alv_output[]  BY kunnr molder LIFNR pbeln ibeln matnr ASCENDING.
  SORT t_backup_alv[]   BY kunnr lifnr pbeln ibeln matnr ASCENDING.
  SORT pt_alv_output[]  BY kunnr lifnr pbeln ibeln matnr ASCENDING.
*  DELETE ADJACENT DUPLICATES FROM t_backup_alv[] COMPARING kunnr molder LIFNR pbeln ibeln matnr.
  DELETE ADJACENT DUPLICATES FROM t_backup_alv[] COMPARING kunnr lifnr pbeln ibeln matnr.

  "COMPARE AGAINTS TYPED REGISTERS
  LOOP AT t_backup_alv[] INTO w_backup_alv.

    CLEAR v_counter.

    LOOP AT pt_alv_output INTO w_alv
    WHERE kunnr  = w_backup_alv-kunnr
*      AND molder = w_backup_alv-molder
      AND lifnr  = w_backup_alv-lifnr
      AND pbeln  = w_backup_alv-pbeln
      AND ibeln  = w_backup_alv-ibeln
      AND matnr  = w_backup_alv-matnr.

      ADD 1 TO v_counter.
      IF v_counter GT 1.
        CLEAR v_tabix.
        v_tabix = sy-tabix.

        CLEAR w_log_output.
        MOVE-CORRESPONDING w_alv TO w_log_output.
        w_log_output-mensaje = text-027.
        APPEND w_log_output TO pt_log_output.

        DELETE pt_alv_output INDEX v_tabix.
      ENDIF.

    ENDLOOP.
  ENDLOOP.

  "COMPARE AGAINST EXISTING RECORDS
  SORT pt_alv_output[] BY agrupador ASCENDING.

ENDFORM.                    " F0010_DATA_DUPLICATE
*&---------------------------------------------------------------------*
*&      Form  F0008_SHOW_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f0008_show_log .


*$smart (W) 2/9/17 - #166 Data declaration uses obsolete data type. (A)

  DATA  : v_repid      TYPE REPID,                                                               "$smart: #166
          w_layout     TYPE slis_layout_alv,
          v_pfstatus   TYPE slis_formname,
          v_times      TYPE i VALUE 30 ,
          v_number     TYPE i.

  REFRESH t_alv_fieldcat_log.
  CLEAR: w_alv_fieldcat, w_layout.
  v_repid = sy-repid.
  w_layout-zebra = c_x.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'AGRUPADOR'.
  w_alv_fieldcat-seltext_m   = text-001.    "Number
  w_alv_fieldcat-seltext_s   = text-001.    "Number
  w_alv_fieldcat-seltext_l   = text-001.    "Number
  w_alv_fieldcat-col_pos     = 0.
  w_alv_fieldcat-outputlen   = 5.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'KUNNR'.
  w_alv_fieldcat-seltext_m   = text-002.    "Client
  w_alv_fieldcat-seltext_s   = text-002.    "Client
  w_alv_fieldcat-seltext_l   = text-002.    "Client
  w_alv_fieldcat-col_pos     = 1.
  w_alv_fieldcat-outputlen   = 25.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'MOLDER'.
  w_alv_fieldcat-seltext_m   = text-003.    "Molder
  w_alv_fieldcat-seltext_s   = text-003.    "Molder
  w_alv_fieldcat-seltext_l   = text-003.    "Molder
  w_alv_fieldcat-col_pos     = 2.
  w_alv_fieldcat-outputlen   = 35.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'LIFNR'.
  w_alv_fieldcat-seltext_m   = text-006.    "Resin Supplier
  w_alv_fieldcat-seltext_s   = text-006.    "Resin Supplier
  w_alv_fieldcat-seltext_l   = text-006.    "Resin Supplier
  w_alv_fieldcat-col_pos     = 3.
  w_alv_fieldcat-outputlen   = 25.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'NAME'.
  w_alv_fieldcat-seltext_m   = text-009.    "Resin Name
  w_alv_fieldcat-seltext_s   = text-009.    "Resin Name
  w_alv_fieldcat-seltext_l   = text-009.    "Resin Name
  w_alv_fieldcat-col_pos     = 4.
  w_alv_fieldcat-outputlen   = 35.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'PBELN'.
  w_alv_fieldcat-seltext_m   = text-017.    "PO NUMBER
  w_alv_fieldcat-seltext_s   = text-017.    "PO NUMBER
  w_alv_fieldcat-seltext_l   = text-017.    "PO NUMBER
  w_alv_fieldcat-col_pos     = 5.
  w_alv_fieldcat-outputlen   = 25.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'IBELN'.
  w_alv_fieldcat-seltext_m   = text-028.    "INVOICE
  w_alv_fieldcat-seltext_s   = text-028.    "INVOICE
  w_alv_fieldcat-seltext_l   = text-028.    "INVOICE
  w_alv_fieldcat-col_pos     = 6.
  w_alv_fieldcat-outputlen   = 25.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'MATNR'.
  w_alv_fieldcat-seltext_m   = text-007.    "MATERIAL
  w_alv_fieldcat-seltext_s   = text-007.    "MATERIAL
  w_alv_fieldcat-seltext_l   = text-007.    "MATERIAL
  w_alv_fieldcat-col_pos     = 7.
  w_alv_fieldcat-outputlen   = 25.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'MAKTX'.
  w_alv_fieldcat-seltext_m   = text-026.    "Descripcion Material
  w_alv_fieldcat-seltext_s   = text-026.    "Descripcion Material
  w_alv_fieldcat-seltext_l   = text-026.    "Descripcion Material
  w_alv_fieldcat-col_pos     = 8.
  w_alv_fieldcat-outputlen   = 40.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'FECHAAP'.
  w_alv_fieldcat-seltext_m   = text-033.    "Fecha Cargo AP
  w_alv_fieldcat-seltext_s   = text-033.    "Fecha Cargo AP
  w_alv_fieldcat-seltext_l   = text-033.    "Fecha Cargo AP
  w_alv_fieldcat-col_pos     = 9.
  w_alv_fieldcat-outputlen   = 25.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'NET_QTY'.
  w_alv_fieldcat-seltext_m   = text-010.    "NET QUANTITY
  w_alv_fieldcat-seltext_s   = text-010.    "NET QUANTITY
  w_alv_fieldcat-seltext_l   = text-010.    "NET QUANTITY
  w_alv_fieldcat-col_pos     = 10.
  w_alv_fieldcat-outputlen   = 25.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'NET_COST'.
  w_alv_fieldcat-seltext_m   = text-011.    "NET COST
  w_alv_fieldcat-seltext_s   = text-011.    "NET COST
  w_alv_fieldcat-seltext_l   = text-011.    "NET COST
  w_alv_fieldcat-col_pos     = 11.
  w_alv_fieldcat-outputlen   = 25.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'SUBTOTAL'.
  w_alv_fieldcat-seltext_m   = text-012.    "SUBTOTAL
  w_alv_fieldcat-seltext_s   = text-012.    "SUBTOTAL
  w_alv_fieldcat-seltext_l   = text-012.    "SUBTOTAL
  w_alv_fieldcat-col_pos     = 12.
  w_alv_fieldcat-outputlen   = 25.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'IVA_FAC'.
  w_alv_fieldcat-seltext_m   = text-013.    "IVA FACTURA
  w_alv_fieldcat-seltext_s   = text-013.    "IVA FACTURA
  w_alv_fieldcat-seltext_l   = text-013.    "IVA FACTURA
  w_alv_fieldcat-col_pos     = 13.
  w_alv_fieldcat-outputlen   = 20.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'IVA_CAP'.
  w_alv_fieldcat-seltext_m   = text-015.    "IVA CAP
  w_alv_fieldcat-seltext_s   = text-015.    "IVA CAP
  w_alv_fieldcat-seltext_l   = text-015.    "IVA CAP
  w_alv_fieldcat-col_pos     = 14.
  w_alv_fieldcat-outputlen   = 20.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'TOTAL'.
  w_alv_fieldcat-seltext_m   = text-016.    "TOTAL
  w_alv_fieldcat-seltext_s   = text-016.    "TOTAL
  w_alv_fieldcat-seltext_l   = text-016.    "TOTAL
  w_alv_fieldcat-col_pos     = 15.
  w_alv_fieldcat-outputlen   = 25.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'COMMENTS'.
  w_alv_fieldcat-seltext_m   = text-018.    "COMMENTS
  w_alv_fieldcat-seltext_s   = text-018.    "COMMENTS
  w_alv_fieldcat-seltext_l   = text-018.    "COMMENTS
  w_alv_fieldcat-col_pos     = 16.
  w_alv_fieldcat-outputlen   = 50.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'ESTATUS'.
  w_alv_fieldcat-seltext_m   = text-030.    "STATUS
  w_alv_fieldcat-seltext_s   = text-030.    "STATUS
  w_alv_fieldcat-seltext_l   = text-030.    "STATUS
  w_alv_fieldcat-col_pos     = 17.
  w_alv_fieldcat-outputlen   = 25.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'PROCESADO'.
  w_alv_fieldcat-seltext_m   = text-031.    "PROCESS
  w_alv_fieldcat-seltext_s   = text-031.    "PROCESS
  w_alv_fieldcat-seltext_l   = text-031.    "PROCESS
  w_alv_fieldcat-col_pos     = 18.
  w_alv_fieldcat-outputlen   = 25.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'MENSAJE'.
  w_alv_fieldcat-seltext_m   = text-032.    "MESSAGE
  w_alv_fieldcat-seltext_s   = text-032.    "MESSAGE
  w_alv_fieldcat-seltext_l   = text-032.    "MESSAGE
  w_alv_fieldcat-col_pos     = 19.
  w_alv_fieldcat-outputlen   = 40.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'NUMPEDIDO'.
  w_alv_fieldcat-seltext_m   = text-034.    "SALES DOCUMENT
  w_alv_fieldcat-seltext_s   = text-034.    "SALES DOCUMENT
  w_alv_fieldcat-seltext_l   = text-034.    "SALES DOCUMENT
  w_alv_fieldcat-col_pos     = 20.
  w_alv_fieldcat-outputlen   = 20.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'NUMFACTURA'.
  w_alv_fieldcat-seltext_m   = text-035.    "INVOICE DOCUMENT
  w_alv_fieldcat-seltext_s   = text-035.    "INVOICE DOCUMENT
  w_alv_fieldcat-seltext_l   = text-035.    "INVOICE DOCUMENT
  w_alv_fieldcat-col_pos     = 21.
  w_alv_fieldcat-outputlen   = 20.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CLEAR  w_alv_fieldcat.
  w_alv_fieldcat-fieldname   = 'NUMCARGOAP'.
  w_alv_fieldcat-seltext_m   = text-036.    "ACCOUNTING DOCUMENT
  w_alv_fieldcat-seltext_s   = text-036.    "ACCOUNTING DOCUMENT
  w_alv_fieldcat-seltext_l   = text-036.    "ACCOUNTING DOCUMENT
  w_alv_fieldcat-col_pos     = 22.
  w_alv_fieldcat-outputlen   = 20.
  APPEND w_alv_fieldcat TO t_alv_fieldcat_log.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = v_repid
      is_layout          = w_layout
      it_fieldcat        = t_alv_fieldcat_log
    TABLES
      t_outtab           = t_log_output[]
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

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

ENDFORM.                    " F0008_SHOW_LOG
*&---------------------------------------------------------------------*
*&      Form  F0012_SHOW_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f0012_show_report .


*$smart (W) 2/9/17 - #166 Data declaration uses obsolete data type. (A)

  DATA:  v_repid      TYPE REPID,                                                                "$smart: #166
         w_layout     TYPE slis_layout_alv,
         v_pfstatus   TYPE slis_formname,
         v_times      TYPE i VALUE 50 ,
         v_number     TYPE i.

  IF NOT t_alv_output_proc[] IS INITIAL.
    v_repid = sy-repid.
    w_layout-zebra = c_x.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'FECHA_SAVE'.
    w_alv_fieldcat-seltext_m   = 'FECHA_SAVE'.   "Number
    w_alv_fieldcat-seltext_s   = 'FECHA_SAVE'.   "Number
    w_alv_fieldcat-seltext_l   = 'FECHA_SAVE'.   "Number
    w_alv_fieldcat-col_pos     = 1.
    w_alv_fieldcat-outputlen   = 5.
    w_alv_fieldcat-no_out = c_x.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'AGRUPADOR'.
    w_alv_fieldcat-seltext_m   = text-001.    "Number
    w_alv_fieldcat-seltext_s   = text-001.    "Number
    w_alv_fieldcat-seltext_l   = text-001.    "Number
    w_alv_fieldcat-col_pos     = 2.
    w_alv_fieldcat-outputlen   = 20.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'KUNNR'.
    w_alv_fieldcat-seltext_m   = text-002.    "Client
    w_alv_fieldcat-seltext_s   = text-002.    "Client
    w_alv_fieldcat-seltext_l   = text-002.    "Client
    w_alv_fieldcat-col_pos     = 3.
    w_alv_fieldcat-outputlen   = 25.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'MOLDER'.
    w_alv_fieldcat-seltext_m   = text-003.    "Molder
    w_alv_fieldcat-seltext_s   = text-003.    "Molder
    w_alv_fieldcat-seltext_l   = text-003.    "Molder
    w_alv_fieldcat-col_pos     = 4.
    w_alv_fieldcat-outputlen   = 35.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'LIFNR'.
    w_alv_fieldcat-seltext_m   = text-006.    "Resin Supplier
    w_alv_fieldcat-seltext_s   = text-006.    "Resin Supplier
    w_alv_fieldcat-seltext_l   = text-006.    "Resin Supplier
    w_alv_fieldcat-col_pos     = 5.
    w_alv_fieldcat-outputlen   = 25.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'NAME'.
    w_alv_fieldcat-seltext_m   = text-009.    "Resin Name
    w_alv_fieldcat-seltext_s   = text-009.    "Resin Name
    w_alv_fieldcat-seltext_l   = text-009.    "Resin Name
    w_alv_fieldcat-col_pos     = 6.
    w_alv_fieldcat-outputlen   = 35.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'PBELN'.
    w_alv_fieldcat-seltext_m   = text-017.    "PO NUMBER
    w_alv_fieldcat-seltext_s   = text-017.    "PO NUMBER
    w_alv_fieldcat-seltext_l   = text-017.    "PO NUMBER
    w_alv_fieldcat-col_pos     = 7.
    w_alv_fieldcat-outputlen   = 25.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'IBELN'.
    w_alv_fieldcat-seltext_m   = text-028.    "INVOICE
    w_alv_fieldcat-seltext_s   = text-028.    "INVOICE
    w_alv_fieldcat-seltext_l   = text-028.    "INVOICE
    w_alv_fieldcat-col_pos     = 8.
    w_alv_fieldcat-outputlen   = 25.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'MATNR'.
    w_alv_fieldcat-seltext_m   = text-007.    "MATERIAL
    w_alv_fieldcat-seltext_s   = text-007.    "MATERIAL
    w_alv_fieldcat-seltext_l   = text-007.    "MATERIAL
    w_alv_fieldcat-col_pos     = 9.
    w_alv_fieldcat-outputlen   = 25.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'MAKTX'.
    w_alv_fieldcat-seltext_m   = text-026.    "Descripcion Material
    w_alv_fieldcat-seltext_s   = text-026.    "Descripcion Material
    w_alv_fieldcat-seltext_l   = text-026.    "Descripcion Material
    w_alv_fieldcat-col_pos     = 10.
    w_alv_fieldcat-outputlen   = 40.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'FECHAAP'.
    w_alv_fieldcat-seltext_m   = text-033.    "Fecha Cargo AP
    w_alv_fieldcat-seltext_s   = text-033.    "Fecha Cargo AP
    w_alv_fieldcat-seltext_l   = text-033.    "Fecha Cargo AP
    w_alv_fieldcat-col_pos     = 11.
    w_alv_fieldcat-outputlen   = 25.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'NET_QTY'.
    w_alv_fieldcat-seltext_m   = text-010.    "NET QUANTITY
    w_alv_fieldcat-seltext_s   = text-010.    "NET QUANTITY
    w_alv_fieldcat-seltext_l   = text-010.    "NET QUANTITY
    w_alv_fieldcat-col_pos     = 12.
    w_alv_fieldcat-outputlen   = 25.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'NET_COST'.
    w_alv_fieldcat-seltext_m   = text-011.    "NET COST
    w_alv_fieldcat-seltext_s   = text-011.    "NET COST
    w_alv_fieldcat-seltext_l   = text-011.    "NET COST
    w_alv_fieldcat-col_pos     = 13.
    w_alv_fieldcat-outputlen   = 25.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'SUBTOTAL'.
    w_alv_fieldcat-seltext_m   = text-012.    "SUBTOTAL
    w_alv_fieldcat-seltext_s   = text-012.    "SUBTOTAL
    w_alv_fieldcat-seltext_l   = text-012.    "SUBTOTAL
    w_alv_fieldcat-col_pos     = 14.
    w_alv_fieldcat-outputlen   = 25.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'IVA_FAC'.
    w_alv_fieldcat-seltext_m   = text-013.    "IVA FACTURA
    w_alv_fieldcat-seltext_s   = text-013.    "IVA FACTURA
    w_alv_fieldcat-seltext_l   = text-013.    "IVA FACTURA
    w_alv_fieldcat-col_pos     = 15.
    w_alv_fieldcat-outputlen   = 20.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'IVA_CAP'.
    w_alv_fieldcat-seltext_m   = text-015.    "IVA CAP
    w_alv_fieldcat-seltext_s   = text-015.    "IVA CAP
    w_alv_fieldcat-seltext_l   = text-015.    "IVA CAP
    w_alv_fieldcat-col_pos     = 16.
    w_alv_fieldcat-outputlen   = 20.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'TOTAL'.
    w_alv_fieldcat-seltext_m   = text-016.    "TOTAL
    w_alv_fieldcat-seltext_s   = text-016.    "TOTAL
    w_alv_fieldcat-seltext_l   = text-016.    "TOTAL
    w_alv_fieldcat-col_pos     = 17.
    w_alv_fieldcat-outputlen   = 25.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'COMMENTS'.
    w_alv_fieldcat-seltext_m   = text-018.    "COMMENTS
    w_alv_fieldcat-seltext_s   = text-018.    "COMMENTS
    w_alv_fieldcat-seltext_l   = text-018.    "COMMENTS
    w_alv_fieldcat-col_pos     = 18.
    w_alv_fieldcat-outputlen   = 50.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'ESTATUS'.
    w_alv_fieldcat-seltext_m   = text-030.    "COMMENTS
    w_alv_fieldcat-seltext_s   = text-030.    "COMMENTS
    w_alv_fieldcat-seltext_l   = text-030.    "COMMENTS
    w_alv_fieldcat-col_pos     = 19.
    w_alv_fieldcat-outputlen   = 25.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'PROCESADO'.
    w_alv_fieldcat-seltext_m   = text-031.    "COMMENTS
    w_alv_fieldcat-seltext_s   = text-031.    "COMMENTS
    w_alv_fieldcat-seltext_l   = text-031.    "COMMENTS
    w_alv_fieldcat-col_pos     = 20.
    w_alv_fieldcat-outputlen   = 25.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'MENSAJE'.
    w_alv_fieldcat-seltext_m   = 'MENSAJE'.  "COMMENTS
    w_alv_fieldcat-seltext_s   = 'MENSAJE'.    "COMMENTS
    w_alv_fieldcat-seltext_l   = 'MENSAJE'.    "COMMENTS
    w_alv_fieldcat-col_pos     = 21.
    w_alv_fieldcat-outputlen   = 40.
    w_alv_fieldcat-no_out = c_x.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'NUMPEDIDO'.
    w_alv_fieldcat-seltext_m   = text-034.    "SALES DOCUMENT
    w_alv_fieldcat-seltext_s   = text-034.    "SALES DOCUMENT
    w_alv_fieldcat-seltext_l   = text-034.    "SALES DOCUMENT
    w_alv_fieldcat-col_pos     = 22.
    w_alv_fieldcat-outputlen   = 20.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'NUMFACTURA'.
    w_alv_fieldcat-seltext_m   = text-035.    "INVOICE DOCUMENT
    w_alv_fieldcat-seltext_s   = text-035.    "INVOICE DOCUMENT
    w_alv_fieldcat-seltext_l   = text-035.    "INVOICE DOCUMENT
    w_alv_fieldcat-col_pos     = 23.
    w_alv_fieldcat-outputlen   = 20.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CLEAR  w_alv_fieldcat.
    w_alv_fieldcat-fieldname   = 'NUMCARGOAP'.
    w_alv_fieldcat-seltext_m   = text-036.    "ACCOUNTING DOCUMENT
    w_alv_fieldcat-seltext_s   = text-036.    "ACCOUNTING DOCUMENT
    w_alv_fieldcat-seltext_l   = text-036.    "ACCOUNTING DOCUMENT
    w_alv_fieldcat-col_pos     = 24.
    w_alv_fieldcat-outputlen   = 20.
    w_alv_fieldcat-edit = ''.
    APPEND w_alv_fieldcat TO t_alv_fieldcat_show.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program       = v_repid
        i_callback_pf_status_set = 'F0004_PF_STATUS'
        i_callback_user_command  = 'F0007_USER_COMMAND'
        is_layout                = w_layout
        it_fieldcat              = t_alv_fieldcat_show[]
      TABLES
        t_outtab                 = t_alv_output_proc[]
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

  ELSE.
    MESSAGE s001(00) WITH text-043 "No hay informacion que coincida con su busqueda
    DISPLAY LIKE c_s.
  ENDIF.

ENDFORM.                    " F0012_SHOW_REPORT
*&---------------------------------------------------------------------*
*&      Form  F0014_DATA_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_T_ALV_OUTPUT[]  text
*----------------------------------------------------------------------*
FORM f0014_data_save  CHANGING pt_alv_output TYPE tty_alv_reg_fac
                               pt_log_output TYPE tty_log.

  DATA: w_log_output TYPE ty_log,
        v_net_qty    TYPE mseg-menge,
        vc_net_qty   TYPE char17,
        v_net_cost   TYPE konp-pkwrt,
        vc_net_cost  TYPE char21.

  REFRESH t_molders_save[].


  LOOP AT pt_alv_output INTO w_alv_output.
    CLEAR: w_molders_save, vc_net_cost, vc_net_cost, v_net_qty, v_net_cost.
    vc_net_qty = w_alv_output-net_qty.
    vc_net_cost = w_alv_output-net_cost.
    SHIFT vc_net_qty LEFT DELETING LEADING space.
    SHIFT vc_net_cost  LEFT DELETING LEADING space.
    REPLACE ALL OCCURRENCES OF ',' IN vc_net_qty WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN vc_net_cost WITH ''.
    v_net_qty  = vc_net_qty.
    v_net_cost = vc_net_cost.
    w_molders_save-mandt = sy-mandt.
    PERFORM f0017_conv_exit_input CHANGING w_alv_output-kunnr.
    w_molders_save-kunnr = w_alv_output-kunnr.
    PERFORM f0017_conv_exit_input CHANGING w_alv_output-lifnr.
    w_molders_save-lifnr = w_alv_output-lifnr.
    PERFORM f0017_conv_exit_input CHANGING w_alv_output-pbeln.
    w_molders_save-pbeln = w_alv_output-pbeln.
    PERFORM f0017_conv_exit_input CHANGING w_alv_output-ibeln.
    w_molders_save-ibeln = w_alv_output-ibeln.
    PERFORM f0018_conv_exit_input CHANGING w_alv_output-matnr.
    w_molders_save-matnr = w_alv_output-matnr.
    w_molders_save-maktx = w_alv_output-maktx.
    w_molders_save-agrupador = w_alv_output-agrupador.
    w_molders_save-fecha_save = sy-datum.
    w_molders_save-fechaap = w_alv_output-fechaap.
    w_molders_save-net_qty = v_net_qty.
    w_molders_save-net_cost = v_net_cost.
    w_molders_save-subtotal = w_alv_output-subtotal.
    w_molders_save-iva_fac = w_alv_output-iva_fac.
    w_molders_save-iva_cap = w_alv_output-iva_cap.
    w_molders_save-total = w_alv_output-total.
    w_molders_save-comments = w_alv_output-comments.
    w_molders_save-procesado = c_no.
    w_molders_save-estatus = c_inicio.
    APPEND w_molders_save TO t_molders_save.
    MOVE-CORRESPONDING w_alv_output TO w_log_output.
    w_log_output-mensaje = text-046.
    APPEND w_log_output TO pt_log_output.
  ENDLOOP.

  IF NOT t_molders_save[] IS INITIAL.
    MODIFY ztmxsd_molders FROM TABLE t_molders_save.
    COMMIT WORK AND WAIT.
    MESSAGE s001(00) WITH text-045 "Datos guardados exitosamente
    DISPLAY LIKE c_s.
  ENDIF.

ENDFORM.                    " F0014_DATA_SAVE
*&---------------------------------------------------------------------*
*&      Form  F0015_TOTALS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_T_ALV_OUTPUT[]  text
*----------------------------------------------------------------------*
FORM f0015_totals CHANGING  pt_alv_output TYPE tty_alv_reg_fac.

  DATA: v_float     TYPE f,
        v_tabix     TYPE sy-tabix,
        v_net_qty   TYPE mseg-menge,
        vc_net_qty  TYPE char17,
        v_net_cost  TYPE konp-pkwrt,
        vc_net_cost TYPE char21.

  LOOP AT pt_alv_output INTO w_alv_output.
    CLEAR: vc_net_cost, vc_net_cost, v_net_qty, v_net_cost.
    vc_net_qty = w_alv_output-net_qty.
    vc_net_cost = w_alv_output-net_cost.
    SHIFT vc_net_qty LEFT DELETING LEADING space.
    SHIFT vc_net_cost  LEFT DELETING LEADING space.
    REPLACE ALL OCCURRENCES OF ',' IN vc_net_qty WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN vc_net_cost WITH ''.
    v_net_qty  = vc_net_qty.
    v_net_cost = vc_net_cost.
    w_alv_output-subtotal = v_net_qty * v_net_cost.
    CLEAR: v_float, v_tabix.
    v_tabix = sy-tabix.

    IF w_alv_output-iva_cap = c_p2.       "16%
      IF NOT w_t007vp-kbetr IS INITIAL.
        v_float = w_t007vp-kbetr / 1000.
        w_alv_output-total   = w_alv_output-subtotal + ( w_alv_output-subtotal * v_float ) .
      ELSE.
        w_alv_output-total = w_alv_output-subtotal.
      ENDIF.
    ELSEIF w_alv_output-iva_cap = c_v0.
      IF NOT w_t007vv-kbetr IS INITIAL.
        v_float = w_t007vv-kbetr / 1000.
        w_alv_output-total   = w_alv_output-subtotal + ( w_alv_output-subtotal * v_float ) .
      ELSE.
        w_alv_output-total = w_alv_output-subtotal.
      ENDIF.
    ENDIF.
    MODIFY pt_alv_output FROM w_alv_output INDEX v_tabix.

  ENDLOOP.

ENDFORM.                    " F0015_TOTALS
*&---------------------------------------------------------------------*
*&      Form  F0016_CHECK_TEXTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_T_ALV_OUTPUT[]  text
*----------------------------------------------------------------------*
FORM f0016_check_texts  CHANGING pt_alv_output TYPE tty_alv_reg_fac.

  DATA: s_kunnr TYPE RANGE OF kna1-kunnr,
        w_kunnr LIKE LINE OF s_kunnr,
        s_lifnr TYPE RANGE OF lfa1-lifnr,
        w_lifnr LIKE LINE OF s_lifnr,
        v_tabix TYPE sy-tabix.

  REFRESH t_kna1.

  LOOP AT pt_alv_output INTO w_alv_output.

    CLEAR w_kunnr.
    w_kunnr-sign   = c_i.
    w_kunnr-option = c_eq.
    w_kunnr-low    = w_alv_output-kunnr.
    COLLECT w_kunnr INTO s_kunnr.

    CLEAR w_lifnr.
    w_lifnr-sign   = c_i.
    w_lifnr-option = c_eq.
    w_lifnr-low    = w_alv_output-lifnr.
    COLLECT w_lifnr INTO s_lifnr.

  ENDLOOP.

  IF NOT s_kunnr[] IS INITIAL.
    SELECT kunnr
           name1
           name2
    FROM kna1
    INTO TABLE t_kna1
    WHERE kunnr IN s_kunnr[].

    IF sy-subrc = 0.
      SORT t_kna1 BY kunnr ASCENDING.
    ENDIF.
  ENDIF.

  IF NOT s_lifnr[] IS INITIAL.
    SELECT lifnr
           name1
           name2
    FROM lfa1
    INTO TABLE t_lfa1
    WHERE lifnr IN s_lifnr[].

    IF sy-subrc = 0.
      SORT t_lfa1 BY lifnr ASCENDING.
    ENDIF.
  ENDIF.

  LOOP AT pt_alv_output INTO w_alv_output.
    CLEAR v_tabix.
    v_tabix = sy-tabix.

    READ TABLE t_kna1 INTO w_kna1
    WITH KEY kunnr = w_alv_output-kunnr
    BINARY SEARCH.
    IF sy-subrc = 0.
      CONCATENATE w_kna1-name1 w_kna1-name2 INTO w_alv_output-molder SEPARATED BY space.
      MODIFY pt_alv_output FROM w_alv_output INDEX v_tabix.
    ENDIF.

    READ TABLE t_lfa1 INTO w_lfa1
    WITH KEY lifnr = w_alv_output-lifnr
    BINARY SEARCH.
    IF sy-subrc = 0.
      CONCATENATE w_lfa1-name1 w_lfa1-name2 INTO w_alv_output-name SEPARATED BY space.
      MODIFY pt_alv_output FROM w_alv_output INDEX v_tabix.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " F0016_CHECK_TEXTS
*&---------------------------------------------------------------------*
*&      Form  F0017_CONV_EXIT_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_W_ALV_OUTPUT_KUNNR  text
*----------------------------------------------------------------------*
FORM f0017_conv_exit_input  CHANGING pv_value TYPE char10.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = pv_value
    IMPORTING
      output = pv_value.

ENDFORM.                    " F0017_CONV_EXIT_INPUT
*&---------------------------------------------------------------------*
*&      Form  F0018_CONV_EXIT_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_W_ALV_OUTPUT_MATNR  text
*----------------------------------------------------------------------*
FORM f0018_conv_exit_input  CHANGING pv_value TYPE char18.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = pv_value
    IMPORTING
      output = pv_value.

ENDFORM.                    " F0018_CONV_EXIT_INPUT
*&---------------------------------------------------------------------*
*&      Form  F0019_CHECK_TEXTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_T_ALV_OUTPUT[]  text
*----------------------------------------------------------------------*
FORM f0019_check_texts  CHANGING pt_alv_output TYPE tty_log.

  DATA: w_output_alv  TYPE ty_log,
        s_kunnr       TYPE RANGE OF kna1-kunnr,
        w_kunnr       LIKE LINE OF s_kunnr,
        s_lifnr       TYPE RANGE OF lfa1-lifnr,
        w_lifnr       LIKE LINE OF s_lifnr,
        v_tabix       TYPE sy-tabix.

  REFRESH t_kna1.

  LOOP AT pt_alv_output INTO w_output_alv.

    CLEAR w_kunnr.
    w_kunnr-sign   = c_i.
    w_kunnr-option = c_eq.
    w_kunnr-low    = w_output_alv-kunnr.
    COLLECT w_kunnr INTO s_kunnr.

    CLEAR w_lifnr.
    w_lifnr-sign   = c_i.
    w_lifnr-option = c_eq.
    w_lifnr-low    = w_output_alv-lifnr.
    COLLECT w_lifnr INTO s_lifnr.

  ENDLOOP.

  IF NOT s_kunnr[] IS INITIAL.
    SELECT kunnr
           name1
           name2
    FROM kna1
    INTO TABLE t_kna1
    WHERE kunnr IN s_kunnr[].

    IF sy-subrc = 0.
      SORT t_kna1 BY kunnr ASCENDING.
    ENDIF.
  ENDIF.

  IF NOT s_lifnr[] IS INITIAL.
    SELECT lifnr
           name1
           name2
    FROM lfa1
    INTO TABLE t_lfa1
    WHERE lifnr IN s_lifnr[].

    IF sy-subrc = 0.
      SORT t_lfa1 BY lifnr ASCENDING.
    ENDIF.
  ENDIF.

ENDFORM.                    " F0019_CHECK_TEXTS

*&---------------------------------------------------------------------*
*&      Form  f0020_bdc_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PV_PROGRAM text
*      -->PV_DYNPRO  text
*----------------------------------------------------------------------*
FORM f0020_bdc_dynpro USING pv_program pv_dynpro.
  CLEAR w_bdcdata.
  w_bdcdata-program  = pv_program.
  w_bdcdata-dynpro   = pv_dynpro.
  w_bdcdata-dynbegin = c_x.
  APPEND w_bdcdata TO t_bdcdata.
ENDFORM.                    "f0020_bdc_dynpro
*&---------------------------------------------------------------------*
*&      Form  f0021_bdc_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PV_FNAM    text
*      -->PV_FVAL    text
*----------------------------------------------------------------------*
FORM f0021_bdc_field USING pv_fnam pv_fval.

  CLEAR w_bdcdata.
  w_bdcdata-fnam = pv_fnam.
  w_bdcdata-fval = pv_fval.
  APPEND w_bdcdata TO t_bdcdata.

ENDFORM.                    "f0021_bdc_field
*&---------------------------------------------------------------------*
*&      Form  F0022_EDIT_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f0022_edit_report .


*$smart (W) 2/9/17 - #166 Data declaration uses obsolete data type. (A)

  DATA: v_repid               TYPE REPID,                                                        "$smart: #166
        w_layout              TYPE lvc_s_layo,
        v_pfstatus            TYPE slis_formname,
        v_times               TYPE i VALUE 50 ,
        v_number              TYPE i.

  REFRESH t_catalog_lvc_edit.
  CLEAR: w_catalog_lvc_edit, w_layout.
  v_repid = sy-repid.
  w_layout-zebra = c_x.
  w_layout-stylefname = 'FIELD_STYLE'.

  CLEAR  w_catalog_lvc_edit.
  w_catalog_lvc_edit-fieldname   = 'AGRUPADOR'.
  w_catalog_lvc_edit-scrtext_s   = text-001.    "Number
  w_catalog_lvc_edit-scrtext_m   = text-001.    "Number
  w_catalog_lvc_edit-scrtext_l   = text-001.    "Number
  w_catalog_lvc_edit-col_pos     = 0.
  w_catalog_lvc_edit-outputlen   = 5.
  w_catalog_lvc_edit-edit = ''.
  APPEND w_catalog_lvc_edit TO t_catalog_lvc_edit.

  CLEAR  w_catalog_lvc_edit.
  w_catalog_lvc_edit-fieldname   = 'KUNNR'.
  w_catalog_lvc_edit-scrtext_s   = text-002.    "Client
  w_catalog_lvc_edit-scrtext_m   = text-002.    "Client
  w_catalog_lvc_edit-scrtext_l   = text-002.    "Client
  w_catalog_lvc_edit-col_pos     = 1.
  w_catalog_lvc_edit-outputlen   = 10.
  w_catalog_lvc_edit-ref_field   = 'KUNNR'.
  w_catalog_lvc_edit-ref_table   = 'KNA1'.
  w_catalog_lvc_edit-edit = ''.
  APPEND w_catalog_lvc_edit TO t_catalog_lvc_edit.

  CLEAR  w_catalog_lvc_edit.
  w_catalog_lvc_edit-fieldname   = 'MOLDER'.
  w_catalog_lvc_edit-scrtext_s   = text-003.    "Molder "CLIENT NAME"
  w_catalog_lvc_edit-scrtext_m   = text-003.    "Molder "CLIENT NAME"
  w_catalog_lvc_edit-scrtext_l   = text-003.    "Molder "CLIENT NAME"
  w_catalog_lvc_edit-col_pos     = 2.
  w_catalog_lvc_edit-outputlen   = 35.
  w_catalog_lvc_edit-edit = ''.
  APPEND w_catalog_lvc_edit TO t_catalog_lvc_edit.

  CLEAR  w_catalog_lvc_edit.
  w_catalog_lvc_edit-fieldname   = 'LIFNR'.
  w_catalog_lvc_edit-scrtext_s   = text-006.    "Resin Supplier
  w_catalog_lvc_edit-scrtext_m   = text-006.    "Resin Supplier
  w_catalog_lvc_edit-scrtext_l   = text-006.    "Resin Supplier
  w_catalog_lvc_edit-col_pos     = 3.
  w_catalog_lvc_edit-outputlen   = 10.
  w_catalog_lvc_edit-ref_field   = 'KUNNR'.
  w_catalog_lvc_edit-ref_table   = 'KNA1'.
  w_catalog_lvc_edit-edit = ''.
  APPEND w_catalog_lvc_edit TO t_catalog_lvc_edit.

  CLEAR  w_catalog_lvc_edit.
  w_catalog_lvc_edit-fieldname   = 'NAME'.
  w_catalog_lvc_edit-scrtext_s   = text-009.    "Resin Name
  w_catalog_lvc_edit-scrtext_m   = text-009.    "Resin Name
  w_catalog_lvc_edit-scrtext_l   = text-009.    "Resin Name
  w_catalog_lvc_edit-col_pos     = 4.
  w_catalog_lvc_edit-outputlen   = 30.
  w_catalog_lvc_edit-edit = ''.
  APPEND w_catalog_lvc_edit TO t_catalog_lvc_edit.

  CLEAR  w_catalog_lvc_edit.
  w_catalog_lvc_edit-fieldname   = 'PBELN'.
  w_catalog_lvc_edit-scrtext_s   = text-017.    "PO NUMBER
  w_catalog_lvc_edit-scrtext_m   = text-017.    "PO NUMBER
  w_catalog_lvc_edit-scrtext_l   = text-017.    "PO NUMBER
  w_catalog_lvc_edit-col_pos     = 5.
  w_catalog_lvc_edit-outputlen   = 10.
  w_catalog_lvc_edit-edit = ''.
  APPEND w_catalog_lvc_edit TO t_catalog_lvc_edit.

  CLEAR  w_catalog_lvc_edit.
  w_catalog_lvc_edit-fieldname   = 'IBELN'.
  w_catalog_lvc_edit-scrtext_s   = text-028.    "INVOICE
  w_catalog_lvc_edit-scrtext_m   = text-028.    "INVOICE
  w_catalog_lvc_edit-scrtext_l   = text-028.    "INVOICE
  w_catalog_lvc_edit-col_pos     = 6.
  w_catalog_lvc_edit-outputlen   = 10.
  w_catalog_lvc_edit-edit = ''.
  APPEND w_catalog_lvc_edit TO t_catalog_lvc_edit.

  CLEAR  w_catalog_lvc_edit.
  w_catalog_lvc_edit-fieldname   = 'MATNR'.
  w_catalog_lvc_edit-scrtext_s   = text-007.    "MATERIAL
  w_catalog_lvc_edit-scrtext_m   = text-007.    "MATERIAL
  w_catalog_lvc_edit-scrtext_l   = text-007.    "MATERIAL
  w_catalog_lvc_edit-col_pos     = 7.
  w_catalog_lvc_edit-outputlen   = 15.
  w_catalog_lvc_edit-ref_field   = 'MATNR'.
  w_catalog_lvc_edit-ref_table   = 'MARA'.
  w_catalog_lvc_edit-edit = ''.
  APPEND w_catalog_lvc_edit TO t_catalog_lvc_edit.

  CLEAR  w_catalog_lvc_edit.
  w_catalog_lvc_edit-fieldname   = 'MAKTX'.
  w_catalog_lvc_edit-scrtext_s   = text-026.    "Descripcion Material
  w_catalog_lvc_edit-scrtext_m   = text-026.    "Descripcion Material
  w_catalog_lvc_edit-scrtext_l   = text-026.    "Descripcion Material
  w_catalog_lvc_edit-col_pos     = 8.
  w_catalog_lvc_edit-outputlen   = 40.
  w_catalog_lvc_edit-edit = c_x.
  APPEND w_catalog_lvc_edit TO t_catalog_lvc_edit.

  CLEAR  w_catalog_lvc_edit.
  w_catalog_lvc_edit-fieldname   = 'FECHAAP'.
  w_catalog_lvc_edit-scrtext_s   = text-033.    "Fecha Cargo AP
  w_catalog_lvc_edit-scrtext_m   = text-033.    "Fecha Cargo AP
  w_catalog_lvc_edit-scrtext_l   = text-033.    "Fecha Cargo AP
  w_catalog_lvc_edit-col_pos     = 9.
  w_catalog_lvc_edit-outputlen   = 10.
  w_catalog_lvc_edit-ref_field   = 'ERSDA'.
  w_catalog_lvc_edit-ref_table   = 'MARA'.
  w_catalog_lvc_edit-edit = c_x.
  APPEND w_catalog_lvc_edit TO t_catalog_lvc_edit.

  CLEAR  w_catalog_lvc_edit.
  w_catalog_lvc_edit-fieldname   = 'NET_QTY'.
  w_catalog_lvc_edit-scrtext_s   = text-010.    "NET QUANTITY
  w_catalog_lvc_edit-scrtext_m   = text-010.    "NET QUANTITY
  w_catalog_lvc_edit-scrtext_l   = text-010.    "NET QUANTITY
  w_catalog_lvc_edit-col_pos     = 10.
  w_catalog_lvc_edit-outputlen   = 20.
  w_catalog_lvc_edit-edit = c_x.
  APPEND w_catalog_lvc_edit TO t_catalog_lvc_edit.

  CLEAR  w_catalog_lvc_edit.
  w_catalog_lvc_edit-fieldname   = 'NET_COST'.
  w_catalog_lvc_edit-scrtext_s   = text-011.    "NET COST
  w_catalog_lvc_edit-scrtext_m   = text-011.    "NET COST
  w_catalog_lvc_edit-scrtext_l   = text-011.    "NET COST
  w_catalog_lvc_edit-col_pos     = 11.
  w_catalog_lvc_edit-outputlen   = 20.
  w_catalog_lvc_edit-edit = c_x.
  APPEND w_catalog_lvc_edit TO t_catalog_lvc_edit.

  CLEAR  w_catalog_lvc_edit.
  w_catalog_lvc_edit-fieldname   = 'SUBTOTAL'.
  w_catalog_lvc_edit-scrtext_s   = text-012.    "SUBTOTAL
  w_catalog_lvc_edit-scrtext_m   = text-012.    "SUBTOTAL
  w_catalog_lvc_edit-scrtext_l   = text-012.    "SUBTOTAL
  w_catalog_lvc_edit-col_pos     = 12.
  w_catalog_lvc_edit-outputlen   = 20.
  w_catalog_lvc_edit-edit = ''.
  APPEND w_catalog_lvc_edit TO t_catalog_lvc_edit.

  CLEAR  w_catalog_lvc_edit.
  w_catalog_lvc_edit-fieldname   = 'IVA_FAC'.
  w_catalog_lvc_edit-scrtext_s   = text-013.    "IVA FACTURA
  w_catalog_lvc_edit-scrtext_m   = text-013.    "IVA FACTURA
  w_catalog_lvc_edit-scrtext_l   = text-013.    "IVA FACTURA
  w_catalog_lvc_edit-col_pos     = 13.
  w_catalog_lvc_edit-outputlen   = 4.
  w_catalog_lvc_edit-ref_field   = 'IVA_FAC'.
  w_catalog_lvc_edit-ref_table   = 'ZTMXSD_MOLDERS'.
  w_catalog_lvc_edit-edit = c_x.
  APPEND w_catalog_lvc_edit TO t_catalog_lvc_edit.

  CLEAR  w_catalog_lvc_edit.
  w_catalog_lvc_edit-fieldname   = 'IVA_CAP'.
  w_catalog_lvc_edit-scrtext_s   = text-015.    "IVA CAP
  w_catalog_lvc_edit-scrtext_m   = text-015.    "IVA CAP
  w_catalog_lvc_edit-scrtext_l   = text-015.    "IVA CAP
  w_catalog_lvc_edit-col_pos     = 14.
  w_catalog_lvc_edit-outputlen   = 4.
  w_catalog_lvc_edit-ref_field   = 'IVA_CAP'.
  w_catalog_lvc_edit-ref_table   = 'ZTMXSD_MOLDERS'.
  w_catalog_lvc_edit-edit = c_x.
  APPEND w_catalog_lvc_edit TO t_catalog_lvc_edit.

  CLEAR  w_catalog_lvc_edit.
  w_catalog_lvc_edit-fieldname   = 'TOTAL'.
  w_catalog_lvc_edit-scrtext_s   = text-016.    "TOTAL
  w_catalog_lvc_edit-scrtext_m   = text-016.    "TOTAL
  w_catalog_lvc_edit-scrtext_l   = text-016.    "TOTAL
  w_catalog_lvc_edit-col_pos     = 15.
  w_catalog_lvc_edit-outputlen   = 20.
  w_catalog_lvc_edit-edit = ''.
  APPEND w_catalog_lvc_edit TO t_catalog_lvc_edit.

  CLEAR  w_catalog_lvc_edit.
  w_catalog_lvc_edit-fieldname   = 'COMMENTS'.
  w_catalog_lvc_edit-scrtext_s   = text-018.    "COMMENTS
  w_catalog_lvc_edit-scrtext_m   = text-018.    "COMMENTS
  w_catalog_lvc_edit-scrtext_l   = text-018.    "COMMENTS
  w_catalog_lvc_edit-col_pos     = 16.
  w_catalog_lvc_edit-outputlen   = 50.
  w_catalog_lvc_edit-edit = c_x.
  APPEND w_catalog_lvc_edit TO t_catalog_lvc_edit.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = v_repid
      i_callback_pf_status_set = 'F0004_PF_STATUS'
      i_callback_user_command  = 'F0007_USER_COMMAND'
      is_layout_lvc            = w_layout
      it_fieldcat_lvc          = t_catalog_lvc_edit[]
    TABLES
      t_outtab                 = t_alv_output[]
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

ENDFORM.                    " F0022_EDIT_REPORT
*&---------------------------------------------------------------------*
*&      Form  F0023_DATA_SAVE
*&---------------------------------------------------------------------*
FORM f0023_data_save  CHANGING pt_alv_output TYPE tty_alv_reg_fac
                               pt_log_output TYPE tty_log
                               pt_molders    TYPE tty_molder_load.

  DATA: w_log_output TYPE ty_log.

  REFRESH t_molders_save[].
  SORT pt_molders[] BY kunnr lifnr pbeln ibeln matnr ASCENDING.

  LOOP AT pt_alv_output INTO w_alv_output.
    CLEAR w_molders_save.

    READ TABLE pt_molders INTO w_molder_load
    WITH KEY kunnr = w_alv_output-kunnr
             lifnr = w_alv_output-lifnr
             pbeln = w_alv_output-pbeln
             ibeln = w_alv_output-ibeln
             matnr = w_alv_output-matnr
    BINARY SEARCH.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING w_molder_load TO w_molders_save.
    ENDIF.
    w_molders_save-mandt = sy-mandt.

    PERFORM f0017_conv_exit_input CHANGING w_molders_save-kunnr.
    w_molders_save-kunnr = w_alv_output-kunnr.
    PERFORM f0017_conv_exit_input CHANGING w_molders_save-lifnr.
    w_molders_save-lifnr = w_alv_output-lifnr.
    PERFORM f0017_conv_exit_input CHANGING w_molders_save-pbeln.
    w_molders_save-pbeln = w_alv_output-pbeln.
    PERFORM f0017_conv_exit_input CHANGING w_molders_save-ibeln.
    w_molders_save-ibeln = w_alv_output-ibeln.
    PERFORM f0018_conv_exit_input CHANGING w_molders_save-matnr.
    w_molders_save-maktx    = w_alv_output-maktx.
    w_molders_save-fechaap  = w_alv_output-fechaap.
    w_molders_save-net_qty  = w_alv_output-net_qty.
    w_molders_save-net_cost = w_alv_output-net_cost.
    w_molders_save-iva_fac  = w_alv_output-iva_fac.
    w_molders_save-iva_cap  = w_alv_output-iva_cap.
    w_molders_save-comments = w_alv_output-comments.
    w_molders_save-total    = w_alv_output-total.
    APPEND w_molders_save TO t_molders_save.
    MOVE-CORRESPONDING w_molders_save TO w_log_output.
    w_log_output-mensaje = text-046.
    APPEND w_log_output TO pt_log_output.
  ENDLOOP.

  IF NOT t_molders_save[] IS INITIAL.
    MODIFY ztmxsd_molders FROM TABLE t_molders_save.
    COMMIT WORK AND WAIT.
    MESSAGE s001(00) WITH text-045 "Datos guardados exitosamente
    DISPLAY LIKE c_s.
  ENDIF.


ENDFORM.                    " F0023_DATA_SAVE
*{ INSERT - NDVK9A1XM8 - Cond.Pago de Acreedor - 4. Definición de rutina
*&---------------------------------------------------------------------*
*&      Form  F0024_BUSCAR_CONDPAGO_ACREEDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F0024_BUSCAR_CONDPAGO_ACREEDOR USING _S_LIFNR TYPE STANDARD TABLE.
  SELECT
      LIFNR
      ZTERM
    INTO TABLE HT_LFB1
    FROM LFB1
   WHERE LIFNR IN _S_LIFNR
     AND BUKRS EQ C_BUKRS.
ENDFORM.                    " F0024_BUSCAR_CONDPAGO_ACREEDOR
*} INSERT - NDVK9A1XM8 - Cond.Pago de Acreedor - 4. Definición de rutina
