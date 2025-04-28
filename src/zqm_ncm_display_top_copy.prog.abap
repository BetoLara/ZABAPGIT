*&---------------------------------------------------------------------*
*&  Include           ZQM_NCM_DISPLAY_TOP_COPY
*&---------------------------------------------------------------------*
* ----------------------------------------------------------------------
* - Modification log
* -
* - Date        Programmer    Task        Description
* - ----------  ------------  ----------  ------------------------------
* - 05.10.2019  LARAH2       NEDK946860   Copy from ZQM_NCM_DISPLAY_TOP*
* ----------------------------------------------------------------------
* - 26.11.2019  LARAH2       NEDK949346   Add Screen Selection
*&---------------------------------------------------------------------*
  TABLES:
    zmx_qmel.


*----------------------------------------------------------------------*
* DECLARACION DE TABLAS INTERNAS                                       *
*----------------------------------------------------------------------*

  TYPES: BEGIN OF ty_salida ,
           icon           TYPE icons-text,
           qmnum          TYPE  qmel-qmnum,
           qmart          TYPE  qmel-qmart,
           qmtxt          TYPE  qmel-qmtxt,
           mawerk         TYPE  qmel-mawerk,
           matnr          TYPE  qmel-matnr,
           lgort          TYPE  mard-lgort,
           maktx          TYPE  makt-maktx,
           revlv          TYPE  qmel-revlv,
           lifnum         TYPE  qmel-lifnum,
           name1          TYPE  lfa1-name1,
           ernam          TYPE  qmel-ernam,
           erdat          TYPE  qmel-erdat,
           aenam          TYPE  qmel-aenam,
           qmdat          TYPE  qmel-qmdat,
           mzeit          TYPE  qmel-mzeit,
           priok          TYPE  qmel-priok,
           priokx         TYPE  t356_t-priokx,
           qmdab          TYPE  qmel-qmdab,
           qmzab          TYPE  qmel-qmzab,
           qmgrp          TYPE  qmel-qmgrp,
           qmcod          TYPE  qmel-qmcod,
           ddtext         TYPE  dd07t-ddtext,
           prueflos       TYPE  qmel-prueflos,
           mgein          TYPE  qmel-mgein,
           bzmng          TYPE  qmel-bzmng,
           rkmng          TYPE  qmel-rkmng,
           crobjty        TYPE  qmel-crobjty,
           arbpl          TYPE  crhd-arbpl,
           refnum         TYPE  qmel-refnum,
           arbplwerk      TYPE  qmel-arbplwerk,
           sttxt          TYPE  bsvx-sttxt,
           kurztextcd     TYPE qcodetext,
           sttxt2         TYPE  bsvx-sttxt,
           fegrp          TYPE  qmfe-fegrp,
           fecod          TYPE  qmfe-fecod,
           fetxt          TYPE  qmfe-fetxt,
           line(40)       TYPE c,
           line_long(100) TYPE c,
           mblnr          TYPE mseg-mblnr,
           mjahr          TYPE mseg-mjahr,
           bwart          TYPE bwart,
           prueflos2      TYPE qplos,
           mblnr311       TYPE  mseg-mblnr,
           mjahr311       TYPE  mseg-mjahr,
           bwart311       TYPE bwart,
           objnr          TYPE qmel-objnr,
           idnlf          TYPE qmel-idnlf,
           kostl          TYPE qmfe-kostl,
           ltext          TYPE cskt-ltext,
           qwrnum         TYPE qmel-qwrnum,
           mblpo          TYPE qmel-mblpo, "SYCNOS
           dmbtr          TYPE mseg-dmbtr, "SYCNOS
           erfme          TYPE mseg-erfme, "SYCNOS
           zncmad         TYPE zncm_areas-zncmad,
           zncmsd         TYPE zncm_areas-zncmad,
           zncmzd         TYPE zncm_areas-zncmad,
         END OF ty_salida.
  DATA t_salida TYPE ty_salida ##NEEDED.
  DATA: ti_salida TYPE STANDARD TABLE OF ty_salida ##NEEDED.

  TYPES: BEGIN OF ty_qmel ,
           qmnum     TYPE  qmel-qmnum,
           qmart     TYPE  qmel-qmart,
           qmtxt     TYPE  qmel-qmtxt,
           mawerk    TYPE  qmel-mawerk,
           matnr     TYPE  qmel-matnr,
           revlv     TYPE  qmel-revlv,
           lifnum    TYPE  qmel-lifnum,
           ernam     TYPE  qmel-ernam,
           erdat     TYPE  qmel-erdat,
           aenam     TYPE  qmel-aenam,
           qmdat     TYPE  qmel-qmdat,
           mzeit     TYPE  qmel-mzeit,
           priok     TYPE  qmel-priok,
           qmdab     TYPE  qmel-qmdab,
           qmzab     TYPE  qmel-qmzab,
           qmgrp     TYPE  qmel-qmgrp,
           qmcod     TYPE  qmel-qmcod,
           prueflos  TYPE  qmel-prueflos,
           mgein     TYPE  qmel-mgein,
           bzmng     TYPE  qmel-bzmng,
           rkmng     TYPE  qmel-rkmng,
           crobjty   TYPE  qmel-crobjty,
           arbpl     TYPE  crhd-arbpl,
           refnum    TYPE  qmel-refnum,
           arbplwerk TYPE  qmel-arbplwerk,
           objnr     TYPE  qmel-objnr,
           idnlf     TYPE  qmel-idnlf,
           deviceid  TYPE  qmel-deviceid,
           qwrnum    TYPE  qmel-qwrnum,
           mblnr     TYPE  qmel-mblnr,
           funktion  TYPE  qmel-funktion,
           lgort     TYPE  mard-lgort,
           mjahr     TYPE  qmel-mjahr,
         END OF ty_qmel.
  DATA t_qmel TYPE ty_qmel ##NEEDED.
  DATA: ti_qmel TYPE STANDARD TABLE OF ty_qmel ##NEEDED.

  TYPES: BEGIN OF ty_qmfe,
           qmnum TYPE qmel-qmnum,
           fegrp TYPE qmfe-fegrp,
           fecod TYPE qmfe-fecod,
           fetxt TYPE qmfe-fetxt,
           kostl TYPE qmfe-kostl,
           ltext TYPE cskt-ltext,
         END OF ty_qmfe.
  DATA t_qmfe TYPE ty_qmfe ##NEEDED.
  DATA: ti_qmfe TYPE STANDARD TABLE OF ty_qmfe ##NEEDED.

  TYPES: BEGIN OF ty_cskt,
           spras TYPE cskt-spras,
           kostl TYPE cskt-kostl,
           ltext TYPE cskt-ltext,
         END OF ty_cskt.
  DATA t_cskt TYPE ty_cskt ##NEEDED.
  DATA: ti_cskt TYPE STANDARD TABLE OF ty_cskt ##NEEDED.

  types: BEGIN OF ty_mseg,
          mblnr TYPE mseg-mblnr,
          matnr TYPE mseg-matnr,
          dmbtr TYPE mseg-dmbtr,
          erfme TYPE mseg-erfme,
        END OF ty_mseg.
DATA t_mseg TYPE ty_mseg ##NEEDED.
  DATA: ti_mseg TYPE STANDARD TABLE OF ty_mseg ##NEEDED.

  TYPES: BEGIN OF ty_priok,
           priok  TYPE t356_t-priok,
           priokx TYPE t356_t-priokx,
         END OF ty_priok.
  DATA t_priok TYPE ty_priok ##NEEDED.
  DATA: ti_priok TYPE STANDARD TABLE OF ty_priok ##NEEDED.

  TYPES: BEGIN OF ty_dd07t,
           domvalue_l TYPE dd07t-domvalue_l,
           ddtext     TYPE dd07t-ddtext,
         END OF ty_dd07t.
  DATA t_dd07t TYPE ty_dd07t ##NEEDED.
  DATA: ti_dd07t TYPE STANDARD TABLE OF ty_dd07t ##NEEDED.

  TYPES: BEGIN OF ty_makt,
           matnr TYPE makt-matnr,
           maktx TYPE makt-maktx,
         END OF ty_makt.
  DATA t_makt TYPE ty_makt ##NEEDED.
  DATA: ti_makt TYPE STANDARD TABLE OF ty_makt ##NEEDED.

  TYPES: BEGIN OF ty_lfa1,
           lifnr TYPE lfa1-lifnr,
           name1 TYPE lfa1-name1,
         END OF ty_lfa1.
  DATA t_lfa1 TYPE ty_lfa1 ##NEEDED.
  DATA: ti_lfa1 TYPE STANDARD TABLE OF ty_lfa1 ##NEEDED.

  DATA gv_reject(1) ##NEEDED.
  DATA gv_reverse(1) ##NEEDED.
  DATA gv_errormigo(1) ##NEEDED.

*----------------------------------------------------------------------*
* DECLARACION DE RANGOS                                                *
*----------------------------------------------------------------------*
*  DATA: r_werks  TYPE RANGE OF qmel-mawerk ##NEEDED,
*        r_notifd TYPE RANGE OF qmel-erdat ##NEEDED,
*        r_notift TYPE RANGE OF qmel-qmart ##NEEDED.
*  DATA: rwa_werks  LIKE LINE OF r_werks ##NEEDED,
*        rwa_notifd LIKE LINE OF r_notifd ##NEEDED,
*        rwa_notift LIKE LINE OF r_notift ##NEEDED.
  DATA: auth_chk TYPE c LENGTH 1. "#EC NEEDED
  DATA: qmel TYPE qmel ##NEEDED. "NEDK949346
