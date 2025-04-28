*&---------------------------------------------------------------------*
*& Report ZMXSDRE_FACPOST_PRG
*&---------------------------------------------------------------------*
*& Description: Facturación Automática Liverpool                       *
*& Date/Author: 8/ABR/2019 - Heriberto Lara Llanas  LARAH2             *
*& Functional: Ricardo Zavala                                          *
*& Transport: NEDK937062                                               *
*&---------------------------------------------------------------------*
*& Description: Add Valid Date to ZMXBILCOND table                     *
*& Date/Author: 8/NOV/2024 - Heriberto Lara Llanas  LARAH2             *
*& Functional: Ricardo Zavala                                          *
*& Transport: NEDK9A0JEY                                               *
*&---------------------------------------------------------------------*
REPORT ZMXSDRE_FACPOST_PRG.

TYPES: BEGIN OF ty_file,
        vbeln TYPE VBELN_VA,
        ebeln TYPE EBELN,
        zacre TYPE ZACRE,
        vbelv TYPE VBELN_VL,
        matnr TYPE MATNR,
        lfima TYPE CHAR10,
        lfimg TYPE CHAR10,
        netpc TYPE CHAR10,
        lfdat TYPE CHAR10,
        lfdtg TYPE CHAR10,
        lfdta TYPE CHAR10,
        npedi TYPE CHAR120,
        fentm TYPE CHAR10,
        aduan TYPE CHAR120,
       END OF ty_file.

TYPES: BEGIN OF ty_data,
        vbeln TYPE VBELN_VA,
        ebeln TYPE EBELN,
        zacre TYPE ZACRE,
        vbelv TYPE VBELN_VL,
        matnr TYPE MATNR,
        lfima TYPE P LENGTH 10 DECIMALS 0,
        lfimg TYPE P LENGTH 10 DECIMALS 0,
        netpc TYPE NETPR,
        lfdat TYPE BUDAT,
        lfdtg TYPE BUDAT,
        lfdta TYPE BUDAT,
        npedi TYPE CHAR120,
        fentm TYPE BUDAT,
        aduan TYPE CHAR120,
        vbent TYPE VBELN_VA,
        vbelt TYPE VBELN_VL,
        netpr TYPE NETPR,
        lfims TYPE P LENGTH 10 DECIMALS 0,
        fkdat TYPE FKDAT,
        kunnr TYPE KUNNR,
        text TYPE CHAR30,
        vbelf TYPE VBELN_VF,
        matnt TYPE MATNR,
        cellcolor TYPE lvc_t_scol,
       END OF ty_data.

TYPES: BEGIN OF ty_facp,
        vbelv TYPE VBELN_VL,
        zacre TYPE ZACRE,
        lfdat TYPE BUDAT,
        lfdta TYPE BUDAT,
        kunnr TYPE KUNNR,
       END OF ty_facp.

TYPES: BEGIN OF ty_likp,
        vbeln TYPE VBELN,
        vstel TYPE VSTEL,
        lfart TYPE LFART,
       END OF ty_likp.

TYPES: BEGIN OF ty_lips,
        vbeln TYPE VBELN,
        posnr TYPE POSNR,
        matnr TYPE MATNR,
        vgbel TYPE VGBEL,
        werks TYPE WERKS,
        lfimg TYPE LFIMG,
       END OF ty_lips.

TYPES: BEGIN OF ty_bill,
        vbelv TYPE VBELN_VL,
        vbeln TYPE VBELN_VF,
       END OF ty_bill.

TYPES: BEGIN OF ty_vbap,
        vbeln TYPE VBELN_VA,
        posnr TYPE POSNR,
        matnr TYPE MATNR,
        netpr TYPE NETPR,
       END OF ty_vbap.

TYPES: BEGIN OF ty_cond,
        kunnr TYPE KUNNR,
        datab TYPE DATAB, "NEDK9A0JEY
        datbi TYPE DATBI, "NEDK9A0JEY
        freightp TYPE ZFREIGHT,
       END OF ty_cond.

DATA: it_data TYPE STANDARD TABLE OF ty_data, "#EC NEEDED
      wa_data TYPE ty_data, "#EC NEEDED
      it_data_gi TYPE STANDARD TABLE OF ty_data, "#EC NEEDED
      wa_data_gi TYPE ty_data, "#EC NEEDED
      it_facp TYPE STANDARD TABLE OF ty_facp, "#EC NEEDED
      wa_facp TYPE ty_facp, "#EC NEEDED
      it_vbap TYPE STANDARD TABLE OF ty_vbap, "#EC NEEDED
      wa_vbap TYPE ty_vbap, "#EC NEEDED
      it_bill TYPE STANDARD TABLE OF ty_bill, "#EC NEEDED
      wa_bill TYPE ty_bill, "#EC NEEDED
      it_likp TYPE STANDARD TABLE OF ty_likp, "#EC NEEDED
      wa_likp TYPE ty_likp, "#EC NEEDED
      it_lips TYPE STANDARD TABLE OF ty_lips, "#EC NEEDED
      wa_lips TYPE ty_lips, "#EC NEEDED
      it_cond TYPE STANDARD TABLE OF ty_cond, "#EC NEEDED
      wa_cond TYPE ty_cond, "#EC NEEDED
      gv_nfac TYPE P LENGTH 6 DECIMALS 0.

DATA: wa_alv_layout TYPE lvc_s_layo, "#EC NEEDED
      it_alv_catalog TYPE STANDARD TABLE OF lvc_s_fcat, "#EC NEEDED
      wa_alv_catalog TYPE lvc_s_fcat, "#EC NEEDED
      o_ref_grid TYPE REF TO cl_gui_alv_grid. "#EC NEEDED

DATA: it_bdcdata TYPE STANDARD TABLE OF bdcdata, "#EC NEEDED
      wa_bdcdata TYPE bdcdata. "#EC NEEDED

DATA: it_msg TYPE STANDARD TABLE OF bdcmsgcoll, "#EC NEEDED
      wa_msg TYPE bdcmsgcoll. "#EC NEEDED

DATA: gv_cont TYPE NUMC2,  "#EC NEEDED
      gv_komfkvbeln TYPE C LENGTH 59,  "#EC NEEDED
      gv_mode TYPE CHAR1,  "#EC NEEDED
      gv_error TYPE CHAR1,  "#EC NEEDED
      gv_bill TYPE CHAR1.  "#EC NEEDED

SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_fname TYPE rlgrap-filename OBLIGATORY.
SELECTION-SCREEN : END OF BLOCK b1.
INCLUDE ZMXSDRE_FACPOST_PRG_F01.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fname.
  PERFORM get_filename USING p_fname.

START-OF-SELECTION.
  PERFORM upload_file.

  PERFORM alv_caract.

  PERFORM alv_columnas.

  PERFORM eje_report.
