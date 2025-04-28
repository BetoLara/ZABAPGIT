*&---------------------------------------------------------------------*
*&  Include           ZQM_NCM_DISPLAY_001_COPY
*&---------------------------------------------------------------------*
* ----------------------------------------------------------------------
* - Modification log
* -
* - Date        Programmer    Task        Description
* - ----------  ------------  ----------  ------------------------------
* - 05.10.2019  LARAH2       NEDK946860   Copy from ZQM_NCM_DISPLAY_001
* ----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  F_ARCHIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_archivo .

  DATA: vg_system     TYPE sy-sysid,
        vg_arch       TYPE rlgrap-filename,
        vg_regs(2000),
        vg_file       TYPE rlgrap-filename,
        v_bzmng(20),
        v_dmbtr(20),
        v_rkmng(20),
        v_erdat(10),
        v_qmdat(10),
        v_qmdab(10),
        v_mzeit(8),
        v_qmzab(8).

  CONSTANTS:
    c_path01(12) VALUE '/data//xfer/',
    c_path02(17) VALUE '/mexico/'.

  vg_system = sy-sysid.
  TRANSLATE vg_system TO LOWER CASE.
  CONCATENATE c_path01 vg_system c_path02 INTO vg_arch.

  CONDENSE vg_arch.

  AUTHORITY-CHECK OBJECT 'S_DATASET'
    ID 'PROGRAM' FIELD sy-cprog
    ID 'ACTVT' FIELD '34'
    ID 'FILENAME' FIELD vg_arch. ##AUTH_FLD_LEN.

  IF sy-subrc NE 0.

    MESSAGE e001(00) ##MG_MISSING
       WITH 'No Write Authorization to file!' ##NO_TEXT.

  ENDIF.

  CONCATENATE vg_arch 'MXFR_SCRAP.csv' INTO vg_file.

  SORT ti_salida
    BY aenam.

  OPEN DATASET vg_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

  CONCATENATE TEXT-001 "'Notification'
              TEXT-002 "'Description'
              TEXT-003 "'Material'
              TEXT-004 "'Ref.Quantity'
              TEXT-005 "'MAT TOTAL'
              TEXT-006 "'Unit of measure'
              TEXT-007 "'Storage Location'
              TEXT-008 "'Vendor'
              TEXT-009 "'Created By'
              TEXT-010 "'Created On'
              TEXT-011 "'Changed By'
              TEXT-012 "'Notification date'
              TEXT-013 "'Notification Time'
              TEXT-014 "'Priority text'
              TEXT-015 "'Completion by date'
              TEXT-016 "'Completion time'
              TEXT-017 "'Complaint quantity'
              TEXT-018 "'Work center'
              TEXT-019 "'Code group'
              TEXT-020 "'Damage Code'
              TEXT-021 "'Item text'
              TEXT-022 "'Status Text'
              TEXT-023 "'Material Document'
              TEXT-024 "'Cost Center'
              TEXT-025 "'Description'
              TEXT-026 "'Material Description'
              TEXT-027 "'Reference'
              TEXT-028 "'Plant'
              INTO vg_regs SEPARATED BY ','.
  TRANSFER vg_regs TO vg_file.

  LOOP AT ti_salida INTO t_salida.
    WRITE t_salida-bzmng DECIMALS 3 NO-GROUPING TO v_bzmng ##UOM_IN_MES.
    WRITE t_salida-dmbtr DECIMALS 2 NO-GROUPING TO v_dmbtr ##UOM_IN_MES.
    WRITE t_salida-rkmng DECIMALS 3 NO-GROUPING TO v_rkmng ##UOM_IN_MES.

     PERFORM f_sign USING v_bzmng.
     PERFORM f_sign USING v_dmbtr.
     PERFORM f_sign USING v_rkmng.

    CONDENSE: v_bzmng,v_dmbtr, v_rkmng.

    CONCATENATE t_salida-erdat+4(2)
                t_salida-erdat+6(2)
                t_salida-erdat+0(4) INTO v_erdat SEPARATED BY '/'.

    CONCATENATE t_salida-qmdat+4(2)
                t_salida-qmdat+6(2)
                t_salida-qmdat+0(4) INTO v_qmdat SEPARATED BY '/'.


    CONCATENATE t_salida-qmdab+4(2)
                t_salida-qmdab+6(2)
                t_salida-qmdab+0(4) INTO v_qmdab SEPARATED BY '/'.

    CONCATENATE t_salida-mzeit+0(2)
                t_salida-mzeit+2(2)
                t_salida-mzeit+4(2) INTO v_mzeit SEPARATED BY ':'.


    CONCATENATE t_salida-qmzab+0(2)
                t_salida-qmzab+2(2)
                t_salida-qmzab+4(2) INTO v_qmzab SEPARATED BY ':'.

*Como algunos textos tienen ',' sin espacio se agrega el espacio luego se quita la ','
    REPLACE ALL OCCURRENCES OF ',' IN t_salida-qmtxt WITH ' ,'.
    REPLACE ALL OCCURRENCES OF ',' IN t_salida-qmtxt WITH ''.

    REPLACE ALL OCCURRENCES OF ',' IN t_salida-fetxt WITH ' ,'.
    REPLACE ALL OCCURRENCES OF ',' IN t_salida-fetxt WITH ''.

    REPLACE ALL OCCURRENCES OF ',' IN t_salida-ltext WITH ' ,'.
    REPLACE ALL OCCURRENCES OF ',' IN t_salida-ltext WITH ''.

    REPLACE ALL OCCURRENCES OF ',' IN t_salida-maktx WITH ' , '.
    REPLACE ALL OCCURRENCES OF ',' IN t_salida-maktx WITH ''.
    "move t_salida-maktx to v_maktx.
    "OVERLAY v_maktx WITH blank ONLY ','.

    CONCATENATE t_salida-qmnum
    t_salida-qmtxt
    t_salida-matnr
    v_bzmng
    v_dmbtr
    t_salida-mgein
    t_salida-lgort
    t_salida-lifnum
    t_salida-ernam
    v_erdat
    t_salida-aenam
    v_qmdat
    v_mzeit
    t_salida-priokx
    v_qmdab
    v_qmzab
    v_rkmng
    t_salida-arbpl
    t_salida-fegrp
    t_salida-fecod
    t_salida-fetxt
    t_salida-line_long
    t_salida-mblnr
    t_salida-kostl
    t_salida-ltext
    t_salida-maktx
    t_salida-qwrnum
    t_salida-mawerk
                  INTO vg_regs SEPARATED BY ','.

    TRANSFER vg_regs TO vg_file.
    clear:  v_bzmng,
            v_dmbtr,
            v_rkmng,
            v_erdat,
            v_qmdat,
            v_qmdab,
            v_mzeit,
            v_qmzab.
  ENDLOOP.
  CLOSE DATASET vg_file.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_SIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_BZMNG  text
*----------------------------------------------------------------------*
FORM f_sign  USING     p_sign ##PERF_NO_TYPE.

   CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
    CHANGING
      value = p_sign.

ENDFORM.
