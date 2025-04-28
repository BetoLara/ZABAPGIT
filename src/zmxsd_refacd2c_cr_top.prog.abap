*&---------------------------------------------------------------------*
*&  Include           ZMXSD_REFACD2C_CR_TOP
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
DATA: vbrk TYPE vbrk.

TYPES: BEGIN OF ty_refac,
        mandt TYPE mandt,
        vbeln TYPE VBELN_VF,
        uuid TYPE ZDEUUID,
        vbeld TYPE VBELN_VL,
        stcd1 TYPE STCD1,
        rfcty TYPE P08_TXREG,
        stkzn TYPE STKZN,
        name1 TYPE AD_NAME1,
        name4 TYPE AD_NAME4,
        street TYPE AD_STREET,
        house_num1 TYPE AD_HSNM1,
        city2 TYPE AD_CITY2,
        post_code1 TYPE AD_PSTCD1,
        city1 TYPE AD_CITY1,
        region TYPE REGIO,
        regimen TYPE PPTP_REGIME,
        zuse TYPE ZUSOCFDI,
        zpay TYPE ZMETODO,
        canvbeln TYPE VBELN_VF,
        canuuid TYPE ZDEUUID,
        newvbeln TYPE VBELN_VF,
        newuuid TYPE ZDEUUID,
        status TYPE ZSTATUS,
        ernam TYPE ERNAM,
        erdat TYPE ERDAT,
        message TYPE SO_TEXT,
       END OF ty_refac,
       BEGIN OF ty_doctos,
        vbeln TYPE VBELN_VF,
        vbelv TYPE VBELN_VON,
        vbtyp_v TYPE VBTYP_V,
       END OF ty_doctos,
       BEGIN OF ty_posn,
        vbelv TYPE VBELN_VON,
        posnv TYPE POSNR_VON,
        vbeln TYPE VBELN_VF,
       END OF ty_posn,
       BEGIN OF ty_plant,
        vbeln TYPE VBELN_VL,
        vstel TYPE VSTEL,
        bukrs TYPE BUKRS, "NEDK9A0ARI
       END OF ty_plant,
       BEGIN OF ty_uuid,
        vbeln TYPE VBELN_VF,
        uuid TYPE ZDEUUID,
       END OF ty_uuid,
       BEGIN OF ty_vbpa3,
        vbeln TYPE vbpa3-vbeln,
        posnr TYPE vbpa3-posnr,
        parvw TYPE vbpa3-parvw,
        stcd1 TYPE vbpa3-stcd1,
        stcd2 TYPE vbpa3-stcd2,
        stkzn TYPE vbpa3-stkzn,
       END OF ty_vbpa3,
       BEGIN OF ty_tpar,
         parvw TYPE tpar-parvw,
         fehgr TYPE tpar-fehgr,
         nrart TYPE tpar-nrart,
       END OF ty_tpar,
       BEGIN OF ty_vbpa,
        vbeln    TYPE vbpa-vbeln,
        posnr    TYPE vbpa-posnr,
        parvw    TYPE vbpa-parvw,
        kunnr    TYPE vbpa-kunnr,
        lifnr    TYPE vbpa-lifnr,
        pernr    TYPE vbpa-pernr,
        parnr    TYPE vbpa-parnr,
        adrnr    TYPE vbpa-adrnr,
        ablad    TYPE vbpa-ablad,
        land1    TYPE vbpa-land1,
        adrda    TYPE vbpa-adrda,
        xcpdk    TYPE vbpa-xcpdk,
        hityp    TYPE vbpa-hityp,
        prfre    TYPE vbpa-prfre,
        bokre    TYPE vbpa-bokre,
        histunr  TYPE vbpa-histunr,
        knref    TYPE vbpa-knref,
        lzone    TYPE vbpa-lzone,
        hzuor    TYPE vbpa-hzuor,
        stceg    TYPE vbpa-stceg,
        parvw_ff TYPE vbpa-parvw_ff,
        adrnp    TYPE vbpa-adrnp,
        kale     TYPE vbpa-kale,
      END OF ty_vbpa.
DATA: it_refac TYPE STANDARD TABLE OF ty_refac, "#EC NEEDED
      wa_refac TYPE ty_refac, "#EC NEEDED
      it_doctos TYPE STANDARD TABLE OF ty_doctos, "#EC NEEDED
      wa_doctos TYPE ty_doctos, "#EC NEEDED
      it_posn TYPE STANDARD TABLE OF ty_posn, "#EC NEEDED
      wa_posn TYPE ty_posn, "#EC NEEDED
      it_plant TYPE STANDARD TABLE OF ty_plant, "#EC NEEDED
      wa_plant TYPE ty_plant, "#EC NEEDED
      it_canc TYPE STANDARD TABLE OF ty_posn, "#EC NEEDED
      wa_canc TYPE ty_posn, "#EC NEEDED
      it_new TYPE STANDARD TABLE OF ty_doctos, "#EC NEEDED
      wa_new TYPE ty_doctos, "#EC NEEDED
      it_invoice TYPE STANDARD TABLE OF ty_doctos, "#EC NEEDED
      wa_invoice TYPE ty_doctos, "#EC NEEDED
      it_uuid TYPE STANDARD TABLE OF ty_uuid, "#EC NEEDED
      wa_uuid TYPE ty_uuid, "#EC NEEDED
      it_vbpa3 TYPE STANDARD TABLE OF ty_vbpa3,
      wa_vbpa3 TYPE ty_vbpa3, "#EC NEEDED
      it_tpar TYPE STANDARD TABLE OF ty_tpar, "#EC NEEDED
      wa_tpar TYPE ty_tpar, "#EC NEEDED
      it_vbpa TYPE STANDARD TABLE OF ty_vbpa, "#EC NEEDED
      wa_vbpa TYPE ty_vbpa, "#EC NEEDED
      it_vbpa_adr TYPE STANDARD TABLE OF ty_vbpa, "#EC NEEDED
      it_vbpa_nadr TYPE STANDARD TABLE OF ty_vbpa. "#EC NEEDED

DATA: it_return TYPE STANDARD TABLE OF BAPIRETURN1, "#EC NEEDED
      wa_return TYPE BAPIRETURN1, "#EC NEEDED
      it_success TYPE STANDARD TABLE OF BAPIVBRKSUCCESS, "#EC NEEDED
      wa_success TYPE BAPIVBRKSUCCESS. "#EC NEEDED

DATA: wa_msg TYPE msg_log, "#EC NEEDED
      gt_msg_texts TYPE STANDARD TABLE OF msg_text, "#EC NEEDED
      wa_msg_texts TYPE msg_text. "#EC NEEDED

DATA: st_addr_sel TYPE addr1_sel, "#EC NEEDED
      st_addr_val TYPE addr1_val, "#EC NEEDED
      it_adrc_u TYPE STANDARD TABLE OF adrc, "#EC NEEDED
      wa_adrc_u TYPE adrc, "#EC NEEDED
      it_adr3_u TYPE STANDARD TABLE OF adr3, "#EC NEEDED
      wa_adr3_u TYPE adr3, "#EC NEEDED
      it_adr3_i TYPE STANDARD TABLE OF adr3, "#EC NEEDED
      wa_adr3_i TYPE adr3. "#EC NEEDED

DATA: i_xvbadr TYPE STANDARD TABLE OF sadrvb, "#EC NEEDED
      i_xvbpa TYPE STANDARD TABLE OF vbpavb,
      wa_xvbpa TYPE vbpavb, "#EC NEEDED
      i_yvbadr TYPE STANDARD TABLE OF sadrvb, "#EC NEEDED
      i_yvbpa TYPE STANDARD TABLE OF vbpavb. "#EC NEEDED

DATA: i_bdc_tab TYPE STANDARD TABLE OF bdcdata, "#EC NEEDED
      w_bdc_tab TYPE bdcdata, "#EC NEEDED
      i_bdc_msg TYPE STANDARD TABLE OF bdcmsgcoll, "#EC NEEDED
      w_bdc_msg TYPE bdcmsgcoll. "#EC NEEDED

DATA: gv_program TYPE string, "#EC NEEDED
      gv_screen TYPE string, "#EC NEEDED
      gv_field TYPE string, "#EC NEEDED
      gv_value TYPE string, "#EC NEEDED
      gv_message TYPE string, "#EC NEEDED
      gv_addrnumber TYPE AD_ADDRNUM, "#EC NEEDED
      gv_consnum TYPE AD_CONSNUM VALUE '1'. "#EC NEEDED

DATA: s_vbelnc TYPE RANGE OF vbrk-vbeln, "#EC NEEDED
      w_vbeln LIKE LINE OF s_vbelnc, "#EC NEEDED
      v_spool TYPE sy-spono, "#EC NEEDED
      v_memid TYPE char22, "#EC NEEDED
      params TYPE pri_params. "#EC NEEDED

DATA:
ADRC_D TYPE STANDARD TABLE OF  ADRC, "#EC NEEDED
ADRC_I TYPE STANDARD TABLE OF  ADRC, "#EC NEEDED
ADRCT_D TYPE STANDARD TABLE OF  ADRCT, "#EC NEEDED
ADRCT_U TYPE STANDARD TABLE OF  ADRCT, "#EC NEEDED
ADRCT_I TYPE STANDARD TABLE OF  ADRCT, "#EC NEEDED
ADRP_D TYPE STANDARD TABLE OF  ADRP, "#EC NEEDED
ADRP_U TYPE STANDARD TABLE OF  ADRP, "#EC NEEDED
ADRP_I TYPE STANDARD TABLE OF  ADRP, "#EC NEEDED
ADCP_D TYPE STANDARD TABLE OF  ADCP, "#EC NEEDED
ADCP_U TYPE STANDARD TABLE OF  ADCP, "#EC NEEDED
ADCP_I TYPE STANDARD TABLE OF  ADCP, "#EC NEEDED
ADRT_D TYPE STANDARD TABLE OF  ADRT, "#EC NEEDED
ADRT_U TYPE STANDARD TABLE OF  ADRT, "#EC NEEDED
ADRT_I TYPE STANDARD TABLE OF  ADRT, "#EC NEEDED
ADR2_D TYPE STANDARD TABLE OF  ADR2, "#EC NEEDED
ADR2_U TYPE STANDARD TABLE OF  ADR2, "#EC NEEDED
ADR2_I TYPE STANDARD TABLE OF  ADR2, "#EC NEEDED
ADR3_D TYPE STANDARD TABLE OF  ADR3, "#EC NEEDED
ADR3_U TYPE STANDARD TABLE OF  ADR3, "#EC NEEDED
ADR3_I TYPE STANDARD TABLE OF  ADR3, "#EC NEEDED
ADR4_D TYPE STANDARD TABLE OF  ADR4, "#EC NEEDED
ADR4_U TYPE STANDARD TABLE OF  ADR4, "#EC NEEDED
ADR4_I TYPE STANDARD TABLE OF  ADR4, "#EC NEEDED
ADR5_D TYPE STANDARD TABLE OF  ADR5, "#EC NEEDED
ADR5_U TYPE STANDARD TABLE OF  ADR5, "#EC NEEDED
ADR5_I TYPE STANDARD TABLE OF  ADR5, "#EC NEEDED
ADR6_D TYPE STANDARD TABLE OF  ADR6, "#EC NEEDED
ADR6_U TYPE STANDARD TABLE OF  ADR6, "#EC NEEDED
ADR6_I TYPE STANDARD TABLE OF  ADR6, "#EC NEEDED
ADR7_D TYPE STANDARD TABLE OF  ADR7, "#EC NEEDED
ADR7_U TYPE STANDARD TABLE OF  ADR7, "#EC NEEDED
ADR7_I TYPE STANDARD TABLE OF  ADR7, "#EC NEEDED
ADR8_D TYPE STANDARD TABLE OF  ADR8, "#EC NEEDED
ADR8_U TYPE STANDARD TABLE OF  ADR8, "#EC NEEDED
ADR8_I TYPE STANDARD TABLE OF  ADR8, "#EC NEEDED
ADR9_D TYPE STANDARD TABLE OF  ADR9, "#EC NEEDED
ADR9_U TYPE STANDARD TABLE OF  ADR9, "#EC NEEDED
ADR9_I TYPE STANDARD TABLE OF  ADR9, "#EC NEEDED
ADR10_D TYPE STANDARD TABLE OF  ADR10, "#EC NEEDED
ADR10_U TYPE STANDARD TABLE OF  ADR10, "#EC NEEDED
ADR10_I TYPE STANDARD TABLE OF  ADR10, "#EC NEEDED
ADR11_D TYPE STANDARD TABLE OF  ADR11, "#EC NEEDED
ADR11_U TYPE STANDARD TABLE OF  ADR11, "#EC NEEDED
ADR11_I TYPE STANDARD TABLE OF  ADR11, "#EC NEEDED
ADR12_D TYPE STANDARD TABLE OF  ADR12, "#EC NEEDED
ADR12_U TYPE STANDARD TABLE OF  ADR12, "#EC NEEDED
ADR12_I TYPE STANDARD TABLE OF  ADR12, "#EC NEEDED
ADR13_D TYPE STANDARD TABLE OF  ADR13, "#EC NEEDED
ADR13_U TYPE STANDARD TABLE OF  ADR13, "#EC NEEDED
ADR13_I TYPE STANDARD TABLE OF  ADR13, "#EC NEEDED
ADRCOMC_D TYPE STANDARD TABLE OF  ADRCOMC, "#EC NEEDED
ADRCOMC_U TYPE STANDARD TABLE OF  ADRCOMC, "#EC NEEDED
ADRCOMC_I TYPE STANDARD TABLE OF  ADRCOMC, "#EC NEEDED
ADRV_D TYPE STANDARD TABLE OF  ADRV, "#EC NEEDED
ADRV_U TYPE STANDARD TABLE OF  ADRV, "#EC NEEDED
ADRV_I TYPE STANDARD TABLE OF  ADRV, "#EC NEEDED
ADRVP_D TYPE STANDARD TABLE OF  ADRVP, "#EC NEEDED
ADRVP_U TYPE STANDARD TABLE OF  ADRVP, "#EC NEEDED
ADRVP_I TYPE STANDARD TABLE OF  ADRVP. "#EC NEEDED

DATA: lt_pach TYPE TABLE OF bapiparnrc, "#EC NEEDED
      lw_pach TYPE bapiparnrc, "#EC NEEDED
      lt_paad TYPE TABLE OF bapiaddr1, "#EC NEEDED
      lw_paad TYPE bapiaddr1, "#EC NEEDED
      lw_ordchghdx TYPE bapisdh1x, "#EC NEEDED
      lt_return TYPE TABLE OF bapiret2. "#EC NEEDED

SELECTION-SCREEN  BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
  SELECT-OPTIONS: s_vbeln FOR vbrk-vbeln.
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN  BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.   "(+)RAMYAK CTS 08/29/2023 RESEGMENTATION
  PARAMETERS: p_bukrs1 TYPE BUKRS.  "(+)RAMYAK CTS 08/29/2023 RESEGMENTATION
SELECTION-SCREEN END OF BLOCK b2.  "(+)RAMYAK CTS 08/29/2023 RESEGMENTATION
