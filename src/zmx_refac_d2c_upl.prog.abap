*&---------------------------------------------------------------------*
*& Report  ZMX_REFAC_D2C_UPL
*&
*&---------------------------------------------------------------------*
*& Description: Invoice D2C
*& Date/Author: 29/SEP/2022 - Heriberto Lara LARAH2
*& Functional: Idalia Rodriguez
*& Transport: NEDK990931
*&---------------------------------------------------------------------*
PROGRAM ZMX_REFAC_B2C_UPL.

INCLUDE ZMX_REFAC_D2C_UPL_TOP.  " global Data
INCLUDE ZMX_REFAC_D2C_UPL_F01.  " FORM-Routines
INCLUDE ZMX_REFAC_D2C_UPL_LCL.  " Class
*----------------------------------------------------------------------
* Data Monitor
*----------------------------------------------------------------------
DATA: o_ges_equi TYPE REF TO lcl_tyftd_monitor. "#EC NEEDED

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fname.
  PERFORM f_get_file_name CHANGING p_fname.

START-OF-SELECTION.
PERFORM AUTHORITY_CHECK.
  CREATE OBJECT o_ges_equi.

  o_ges_equi->get_data( ).

  o_ges_equi->process_data( ).

  IF NOT i_refac[] IS INITIAL.
    o_ges_equi->display_data( ).
  ENDIF.
