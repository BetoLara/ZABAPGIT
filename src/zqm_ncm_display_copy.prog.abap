*&---------------------------------------------------------------------*
*& Report  ZQM_NCM_DISPLAY_COPY
*&
*&---------------------------------------------------------------------*
* ----------------------------------------------------------------------
* - Modification log
* -
* - Date        Programmer    Task        Description
* - ----------  ------------  ----------  ------------------------------
* - 05.10.2019  LARAH2       NEDK946860   Copy from ZQM_NCM_DISPLAY
* ----------------------------------------------------------------------
* - 26.11.2019  LARAH2       NEDK949346   Add Screen Selection
*&---------------------------------------------------------------------*
REPORT  zqm_ncm_display_copy.
INCLUDE zqm_ncm_display_top_copy.
*->> NEDK949346
SELECTION-SCREEN  BEGIN OF BLOCK b1.
  SELECT-OPTIONS: s_werks FOR qmel-mawerk,
                  s_notifd FOR qmel-erdat,
                  s_notift FOR qmel-qmart.
SELECTION-SCREEN END OF BLOCK b1.
*<<- NEDK949346
INCLUDE zqm_ncm_display_f01_copy.
INCLUDE zqm_ncm_display_001_copy.

INITIALIZATION.
  PERFORM f_get_user_parameters_plant.

START-OF-SELECTION.
  PERFORM f_check_auth.
  PERFORM f_get_information.
  PERFORM f_process.
  PERFORM f_archivo.
