*&---------------------------------------------------------------------*
*&  Include           ZQM_NCM_DISPLAY_F01_COPY
*&---------------------------------------------------------------------*
************************************************************************
*                 M O D I F I C A T I O N  L O G                       *
************************************************************************
*  Date       Developer  Transport Req. Description                    *
* - 05.10.2019  LARAH2       NEDK946860   Copy from ZQM_NCM_DISPLAY_F01*
* ----------------------------------------------------------------------
* - 26.11.2019  LARAH2       NEDK949346   Add Screen Selection
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_INFORMATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_information.

  PERFORM f_get_qmel.
  PERFORM f_get_qfme.
  PERFORM f_get_cskt.
  PERFORM f_get_priokx.
  PERFORM f_get_ddtext.
  PERFORM f_get_makt.
  PERFORM f_get_lfa1.
ENDFORM.                    " F_GET_INFORMATION
*&---------------------------------------------------------------------*
*&      Form  F_GET_QMEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_qmel .

  SELECT qmel~qmnum
         qmel~qmart
         qmel~qmtxt
         qmel~mawerk
         qmel~matnr
         qmel~revlv
         qmel~lifnum
         qmel~ernam
         qmel~erdat
         qmel~aenam
         qmel~qmdat
         qmel~mzeit
         qmel~priok
         qmel~qmdab
         qmel~qmzab
         qmel~qmgrp
         qmel~qmcod
         qmel~prueflos
         qmel~mgein
         qmel~bzmng
         qmel~rkmng
         qmel~crobjty
         crhd~arbpl
         qmel~refnum
         qmel~arbplwerk
         qmel~objnr
         qmel~idnlf
         qmel~deviceid
         qmel~qwrnum
         qmel~mblnr
         qmel~funktion
         INTO TABLE ti_qmel ##TOO_MANY_ITAB_FIELDS
         FROM qmel LEFT JOIN crhd
           ON ( crhd~objty EQ qmel~crobjty AND
                crhd~objid EQ qmel~arbpl   AND
                crhd~werks EQ qmel~arbplwerk )
         WHERE qmel~qmart  IN s_notift  "->> NEDK949346
           AND qmel~erdat  IN s_notifd
           AND qmel~mawerk IN s_werks.  "<<- NEDK949346

  IF sy-subrc EQ 0.

    SORT ti_qmel
             BY qmnum
                qmart.

  ENDIF.

ENDFORM.                    " F_GET_QMEL
*&---------------------------------------------------------------------*
*&      Form  F_GET_PRIOKX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_priokx.

  SELECT priok
         priokx
    INTO TABLE ti_priok
    FROM t356_t
   WHERE spras EQ sy-langu
     AND artpr EQ 'NS'.

  IF sy-subrc EQ 0.
    SORT ti_priok BY priok.
  ENDIF.

ENDFORM.                    " F_GET_PRIOKX
*&---------------------------------------------------------------------*
*&      Form  F_GET_DDTEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_ddtext .

  SELECT domvalue_l
         ddtext
    INTO TABLE ti_dd07t
    FROM dd07t
   WHERE domname EQ 'ZDOMRESPONS'
     AND ddlanguage EQ sy-langu.

ENDFORM.                    " F_GET_DDTEXT
*&---------------------------------------------------------------------*
*&      Form  F_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process.
*<NEDK932633> Begin of Addition.
  DATA lv_subrc TYPE sy-subrc.
  CONSTANTS: lc_z_mfg_mx TYPE zmfgdev-function VALUE 'Z_MFG_MX',
             lc_*        TYPE zmfgdev-lgnum VALUE '*'.
*<NEDK932633> End of Addition.
  LOOP AT ti_qmel INTO t_qmel.

    CLEAR t_salida.
    MOVE-CORRESPONDING t_qmel TO t_salida.

*      t_salida-lgort = t_qmel-funktion.  "<NEDK932633>--

    t_salida-mjahr = t_qmel-qmdat(4).

    READ TABLE ti_dd07t INTO t_dd07t
              WITH KEY domvalue_l = t_salida-qmcod.

    IF sy-subrc EQ 0.

      t_salida-ddtext = t_dd07t-ddtext.

    ENDIF.

    READ TABLE ti_priok INTO t_priok
              WITH KEY priok = t_salida-priok.

    IF sy-subrc EQ 0.
      t_salida-priokx = t_priok-priokx.
    ENDIF.

    READ TABLE ti_qmfe INTO t_qmfe
             WITH KEY qmnum = t_salida-qmnum.

    IF sy-subrc EQ 0.
      t_salida-fegrp = t_qmfe-fegrp.
      t_salida-fecod = t_qmfe-fecod.
      t_salida-fetxt = t_qmfe-fetxt.

    ENDIF.

    READ TABLE ti_cskt INTO t_cskt
             WITH KEY spras = sy-langu
                      kostl = t_qmel-deviceid(10).

    IF sy-subrc EQ 0.
      t_salida-kostl = t_cskt-kostl.
      t_salida-ltext = t_cskt-ltext.
    ELSE.
      READ TABLE ti_cskt INTO t_cskt
            WITH KEY spras = 'E'
                     kostl = t_qmel-deviceid(10).
      IF sy-subrc EQ 0.
        t_salida-kostl = t_cskt-kostl.
        t_salida-ltext = t_cskt-ltext.
      ENDIF.
    ENDIF.

    READ TABLE ti_makt INTO t_makt WITH KEY matnr = t_qmel-matnr.
    IF sy-subrc EQ 0.
      t_salida-maktx = t_makt-maktx.
    ENDIF.

    READ TABLE ti_lfa1 INTO t_lfa1 WITH KEY lifnr = t_qmel-lifnum.
    IF sy-subrc EQ 0.
      t_salida-name1 = t_lfa1-name1.
    ENDIF.

    PERFORM f_text_defcod.
    PERFORM f_defcod.
    PERFORM f_update_icon.
    PERFORM f_get_mseg.
    PERFORM f_get_mseg2. "SYCNOS.

    SELECT SINGLE * INTO zmx_qmel "LARAH2 16/DIC/2017 CC/AREA
      FROM zmx_qmel
      WHERE qmnum = t_salida-qmnum.
    IF sy-subrc EQ 0.
*<NEDK932633> Begin of Addition.
      IF t_qmel-funktion IS INITIAL.
        CALL FUNCTION 'Z_MAN_FUNCT_BELONGSTO_MFG'
          EXPORTING
            i_werks     = t_salida-mawerk
            i_lgnum     = lc_*
            i_routine   = lc_z_mfg_mx
          IMPORTING
            sysubrc     = lv_subrc
          EXCEPTIONS ##FM_SUBRC_OK
            check_error = 1
            OTHERS      = 2.
        IF lv_subrc = 0.
          t_salida-lgort = zmx_qmel-lgort2.
        ENDIF.
        CLEAR lv_subrc.
      ELSE.
        t_salida-lgort = t_qmel-funktion.
      ENDIF.
*<NEDK932633> End of Addition.
      SELECT SINGLE zncmad INTO t_salida-zncmad
        FROM zncm_areas
        WHERE werks = t_salida-mawerk
          AND zncmai = zmx_qmel-zncmai.

      SELECT SINGLE zncmad INTO t_salida-zncmsd
        FROM zncm_subareas
        WHERE werks = t_salida-mawerk
          AND zncmai = zmx_qmel-zncmai
          AND zncmsi = zmx_qmel-zncmsi.

      SELECT SINGLE zncmad INTO t_salida-zncmzd
        FROM zncm_zones
        WHERE werks = t_salida-mawerk
          AND zncmai = zmx_qmel-zncmai
          AND zncmsi = zmx_qmel-zncmsi
          AND zncmzi = zmx_qmel-zncmzi.
    ENDIF.

    APPEND t_salida TO ti_salida.

  ENDLOOP.
  SORT ti_salida BY qmnum.
ENDFORM.                    " F_PROCESS
*&---------------------------------------------------------------------*
*&      Form  F_GET_USER_PARAMETERS_PLANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_user_parameters_plant .
  DATA: v_fechai(8) TYPE c.

*  rwa_werks-sign = 'I'.
*  rwa_werks-option = 'EQ'.
*  rwa_werks-low = 'ML24'.
*  APPEND rwa_werks TO r_werks.
*
*  CONCATENATE sy-datum(6) '01' INTO v_fechai.
*
*  rwa_notifd-sign = 'I'.
*  rwa_notifd-option = 'BT'.
*  rwa_notifd-low = v_fechai.
*  rwa_notifd-high = sy-datum.
*  APPEND rwa_notifd TO r_notifd.
*
*  rwa_notift-sign = 'I'.
*  rwa_notift-option = 'EQ'.
*  rwa_notift-low    = 'Z3'.
*  APPEND rwa_notift TO r_notift.

ENDFORM.                    " F_GET_USER_PARAMETERS_PLANT
*&---------------------------------------------------------------------*
*&      Form  F_GET_QFME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_qfme .

  IF ti_qmel[] IS NOT INITIAL.

*$smart (I) 12/12/16 - #728 SELECT INTO itab followed by SELECT FOR ALL ENTRIES IN itab. Driver table used
*$smart (I) 12/12/16 - #728 after the 2nd SELECT (K)

    SELECT qmnum
           fegrp
           fecod
           fetxt
           kostl
      INTO TABLE ti_qmfe ##TOO_MANY_ITAB_FIELDS
      FROM qmfe
       FOR ALL ENTRIES IN ti_qmel
     WHERE qmnum EQ ti_qmel-qmnum.

    IF sy-subrc EQ 0.
      SORT ti_qmfe BY qmnum.
    ENDIF.

  ENDIF.

ENDFORM.                    " F_GET_QFME
*&---------------------------------------------------------------------*
*&      Form  F_TEXT_DEFCOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_text_defcod .

  DATA: t_qpk1cdtab   TYPE  qpk1cd,
        ti_qpk1cdtab  TYPE STANDARD TABLE OF  qpk1cd,
        ti_codegrptab TYPE STANDARD TABLE OF  qpk1codegrp.

  IF t_qmfe-fegrp IS INITIAL.
    RETURN.
  ENDIF.
  CALL FUNCTION 'QPK1_GP_CODE_SELECTION'
    EXPORTING
      i_katalogart           = '9'
      i_codegruppe           = t_qmfe-fegrp
      i_code                 = t_qmfe-fecod
      i_sprache              = sy-langu
      i_display_mode         = ''
      i_return_if_one        = 'X'
      i_pickup_mode          = 'X'
*     i_return_if_many       = 'X'
    TABLES
      t_qpk1cdtab            = ti_qpk1cdtab
      t_codegrptab           = ti_codegrptab
    EXCEPTIONS
      no_match_in_range      = 1
      no_user_selection      = 2
      no_authorization       = 3
      no_selection_specified = 4
      object_locked          = 5
      lock_error             = 6
      object_missing         = 7
      OTHERS                 = 8.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF NOT ti_qpk1cdtab[] IS INITIAL.
      READ TABLE ti_qpk1cdtab into t_qpk1cdtab INDEX 1.

      t_salida-kurztextcd = t_qpk1cdtab-kurztextcd.

    ENDIF.
  ENDIF.

ENDFORM.                    " F_TEXT_DEFCOD
*&---------------------------------------------------------------------*
*&      Form  F_DEFCOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_defcod.

  CALL FUNCTION 'STATUS_TEXT_EDIT_LONG'
    EXPORTING
      client           = sy-mandt
      objnr            = t_salida-objnr
      only_active      = 'X'
      spras            = sy-langu
    IMPORTING
      line             = t_salida-line
      line_long        = t_salida-line_long
    EXCEPTIONS
      object_not_found = 1
      OTHERS           = 2.
  IF sy-subrc <> 0 ##NEEDED.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " F_DEFCOD

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_ICON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_update_icon .

  IF t_salida-line CS 'OSNO' OR t_salida-line CS 'MEAB'.

    t_salida-icon = '@9O\QRequest contains errors@' ##NO_TEXT.
  ENDIF.

  IF t_salida-line CS 'NOPR' OR t_salida-line CS 'METR'.

    t_salida-icon = '@M3\QWorkflow process@' ##NO_TEXT.
  ENDIF.

  IF t_salida-line CS 'NOCO' OR t_salida-line CS 'MECE'.

    t_salida-icon = '@01\QChecked; OK@' ##NO_TEXT.
  ENDIF.

  IF t_salida-line CS 'DLFL' OR t_salida-line CS 'PTBO'.

    t_salida-icon = '@11\QDelete@' ##NO_TEXT.
  ENDIF.

  CLEAR: gv_reject, gv_reverse, gv_errormigo.

*$smart (I) 12/12/16 - #712 SELECT * should be avoided, instead only required fields should be selected if
*$smart (I) 12/12/16 - #712 applicable (A)

  SELECT SINGLE zstat FROM zmx_qmel INTO CORRESPONDING FIELDS OF zmx_qmel                        "$smart: #712
    WHERE qmnum EQ t_qmel-qmnum.
  IF sy-subrc EQ 0.
    IF zmx_qmel-zstat EQ 2.
      gv_reject = 'X'.
    ENDIF.
    IF zmx_qmel-zstat EQ 3.
      gv_reverse = 'X'.
    ENDIF.
    IF zmx_qmel-zstat EQ 4.
      gv_errormigo = 'X'.
    ENDIF.
  ENDIF.

  IF gv_reject EQ  'X'.
    t_salida-icon = '@F1\QNot completed; errors@' ##NO_TEXT.
  ENDIF.

  IF gv_reverse EQ  'X'.
    t_salida-icon = '@BA\QCancellation@'.
  ENDIF.

  IF gv_errormigo EQ  'X'.
    t_salida-icon = '@8O\QError message@' ##NO_TEXT.
  ENDIF.

  IF NOT t_salida-refnum IS INITIAL.
    IF t_salida-line CS 'NOCO' OR t_salida-line CS 'MECE'.
      RETURN.
    ENDIF.
    t_salida-icon = '@8Y\QReject@'.

  ENDIF.

ENDFORM.                    " F_UPDATE_ICON
*&---------------------------------------------------------------------*
*&      Form  F_GET_MSEG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_mseg .

  DATA: lv_objkey    TYPE borident-objkey.
  DATA: et_nodes_tab TYPE qnqmbelegnodes.
  DATA: ti_et_nodes_tab TYPE STANDARD TABLE OF qnqmbelegnodes.

  lv_objkey = t_qmel-qmnum.

  CALL FUNCTION 'QM11_LESEN_BELEGDATEN_ALLG'
    EXPORTING
      i_objkey       = lv_objkey
      i_objtyp       = 'BUS2078'
*     i_max_hops     = '00' " Commented by RATHID-- NDVK9A16I2
      i_max_hops     = '01'  " Added by RATHID++ NDVK9A16I2
      i_no_ui_output = 'X'
    TABLES
*     ET_LINKS_TAB   =
      et_nodes_tab   = ti_et_nodes_tab
    EXCEPTIONS
      no_relation    = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.

    READ TABLE ti_et_nodes_tab INTO et_nodes_tab
                   WITH KEY objtype = 'BUS2017'.
    IF sy-subrc EQ 0.

*$smart (E) 12/12/16 - #601 Usage of unordered SELECT result set (views and transparent tables). (A)

      SELECT bwart
        INTO t_salida-bwart
        FROM mseg UP TO 1 ROWS                                                                   "$smart: #601
       WHERE mblnr = et_nodes_tab-objkey"t_salida-mblnr
         AND mjahr = et_nodes_tab-objkey+10(4) ORDER BY PRIMARY KEY.                             "$smart: #601
      ENDSELECT."t_salida-mjahr.                                                                 "$smart: #601

      IF t_salida-bwart = '322'.
        t_salida-mblnr = et_nodes_tab-objkey(10).
        t_salida-mjahr = et_nodes_tab-objkey+10(4).
      ENDIF.
      IF t_salida-bwart = '311'.
        t_salida-bwart311 = t_salida-bwart.
        t_salida-mblnr311 = et_nodes_tab-objkey(10).
        t_salida-mjahr311 = et_nodes_tab-objkey+10(4).
        CLEAR t_salida-bwart.
      ENDIF.

    ENDIF.

    READ TABLE ti_et_nodes_tab INTO et_nodes_tab
                   WITH KEY objtype = 'BUS2045'.
    IF sy-subrc EQ 0.
      t_salida-prueflos2 = et_nodes_tab-objkey.

    ENDIF.

  ENDIF.

ENDFORM.                    " F_GET_MSEG
*&---------------------------------------------------------------------*
*&      Form  F_GET_CSKT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_cskt .
  IF NOT ti_qmel[] IS INITIAL.

*$smart (I) 12/12/16 - #728 SELECT INTO itab followed by SELECT FOR ALL ENTRIES IN itab. Where clause cannot
*$smart (I) 12/12/16 - #728 be converted to JOIN fields (M)

    SELECT spras
           kostl
           ltext
      INTO TABLE ti_cskt
      FROM cskt
       FOR ALL ENTRIES IN ti_qmel
     WHERE spras IN ('S', 'E')
       AND kostl EQ ti_qmel-deviceid(10).

    IF sy-subrc EQ 0.
      SORT ti_cskt BY kostl.
    ENDIF.

  ENDIF.

ENDFORM.                    " F_GET_CSKT
*&---------------------------------------------------------------------*
*&      Form  F_GET_MAKT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_makt .

*$smart (E) 12/12/16 - #703 SELECT ... FOR ALL ENTRIES IN itab is not enclosed in an 'IF itab IS NOT
*$smart (E) 12/12/16 - #703 INITIAL... .ENDIF.' block (M)

*$smart (I) 12/12/16 - #728 SELECT INTO itab followed by SELECT FOR ALL ENTRIES IN itab. Driver table used
*$smart (I) 12/12/16 - #728 after the 2nd SELECT (K)

  SELECT matnr maktx INTO TABLE ti_makt FROM makt
    FOR ALL ENTRIES IN ti_qmel
    WHERE matnr = ti_qmel-matnr
          AND spras = 'EN'.

  IF sy-subrc EQ 0.
    SORT ti_makt BY matnr.
  ENDIF.

ENDFORM.                    " F_GET_MAKT
*&---------------------------------------------------------------------*
*&      Form  F_GET_LFA1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_lfa1 .

*$smart (E) 12/12/16 - #703 SELECT ... FOR ALL ENTRIES IN itab is not enclosed in an 'IF itab IS NOT
*$smart (E) 12/12/16 - #703 INITIAL... .ENDIF.' block (M)

*$smart (I) 12/12/16 - #728 SELECT INTO itab followed by SELECT FOR ALL ENTRIES IN itab. Driver table used
*$smart (I) 12/12/16 - #728 after the 2nd SELECT (K)

  SELECT lifnr name1 INTO TABLE ti_lfa1 FROM lfa1
    FOR ALL ENTRIES IN ti_qmel
    WHERE lifnr = ti_qmel-lifnum.

  IF sy-subrc EQ 0.
    SORT ti_lfa1 BY lifnr.
  ENDIF.

ENDFORM.                    " F_GET_LFA1
*&---------------------------------------------------------------------*
*&      Form  F_GET_MSEG2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_mseg2 .

  REFRESH ti_mseg.
  CLEAR: t_mseg, t_salida-dmbtr, t_salida-erfme.

  SELECT mblnr matnr dmbtr erfme FROM mseg
      INTO TABLE ti_mseg
      WHERE mblnr = t_salida-mblnr
      AND mjahr = t_salida-mjahr.
  IF sy-subrc EQ 0.
    LOOP AT ti_mseg INTO t_mseg.
      t_salida-dmbtr = t_salida-dmbtr + t_mseg-dmbtr.

    ENDLOOP.

    SELECT SINGLE meins INTO t_salida-erfme
       FROM mara
       WHERE matnr = t_qmel-matnr.

  ENDIF.
*
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_AUTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_check_auth.

  DATA: vl_secu TYPE SECU.

  CLEAR auth_chk.

  SELECT SINGLE secu INTO vl_secu
  FROM trdir
  WHERE name = sy-repid.

  IF sy-subrc NE 0.
    MESSAGE i000(zmm) WITH text-e06.
  ELSE.

    AUTHORITY-CHECK OBJECT 'S_PROGRAM'
             ID 'P_GROUP' FIELD vl_secu
             ID 'P_ACTION' FIELD 'SUBMIT'.
    IF sy-subrc EQ 0.
      auth_chk = 'X'.
    ELSE.
      MESSAGE i000(zmm) WITH text-e05.
    ENDIF.
  ENDIF.
ENDFORM.
