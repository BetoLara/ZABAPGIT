*&---------------------------------------------------------------------*
*&  Include           ZMXSDRE_SCRAP_F01
*&---------------------------------------------------------------------*
* Project       : Facturacion SCRAP
* Program       : ZMXSDRE_SCRAP
* Created by    : LARAH2
* Creation date : 12/JUN/2018
* Description   : Interfaz para Administracion de Facturacion SCRAP
* Transport     : NEDK919572
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  APPEND 'SAVE' TO lfcode.
  APPEND 'EXIT' TO lfcode.
  APPEND 'CANCEL' TO lfcode.
  SET PF-STATUS 'SCRAP0100' EXCLUDING lfcode.
  SET TITLEBAR 'SCRAPTIT1'.

ENDMODULE.                 " STATUS_0100  OUTPUT

MODULE USER_COMMAND_0100 INPUT.

"Comandos de usuario
PERFORM f0001_user_command_0100.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  F0001_USER_COMMAND_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f0001_user_command_0100 .

  DATA: v_ucomm TYPE sy-ucomm.

  CLEAR v_ucomm.
  v_ucomm = sy-ucomm.
  CLEAR sy-ucomm.

  CASE v_ucomm.
    WHEN c_rfac. "Registro de Facturas
      SUBMIT ZMXSDRE_SCRAP_MULTI   "#EC CI_SUBMIT
      WITH p_crea EQ c_x
      WITH p_save EQ c_x
      AND RETURN.
    WHEN c_efac.
      SUBMIT zmxsdre_scrap_multi VIA SELECTION-SCREEN "#EC CI_SUBMIT
      WITH p_edit EQ c_x
      AND RETURN.
    WHEN c_pfac.     "Procesar Facturas
      SUBMIT zmxsdre_scrap_multi VIA SELECTION-SCREEN "#EC CI_SUBMIT
      WITH p_show EQ c_x
      WITH p_tbar EQ c_x
      AND RETURN.
    WHEN c_reph.     "Reporte Historico
      SUBMIT zmxsdre_scrap_multi VIA SELECTION-SCREEN "#EC CI_SUBMIT
      WITH p_show EQ c_x
      AND RETURN.
    WHEN c_emal.     "Notificacion Email
      PERFORM ejecuta_actualizador.
    WHEN c_back or c_exit.
      SET SCREEN 0.
  ENDCASE.

ENDFORM.                    " F0001_USER_COMMAND_0100
*&---------------------------------------------------------------------*
*&      Form  ejecuta_actualizador
*&---------------------------------------------------------------------*
FORM ejecuta_actualizador .
DATA: g_view_name TYPE dd02v-tabname.
g_view_name = 'ZTMXSD_SCRAP_EM'.
  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
  EXPORTING
    action                               = 'U'
    view_name                            = g_view_name
   EXCEPTIONS
      client_reference                     = '1'
      foreign_lock                         = '2'
      invalid_action                       = '3'
      no_clientindependent_auth            = '4'
      no_database_function                 = '5'
      no_editor_function                   = '6'
      no_show_auth                         = '7'
      no_tvdir_entry                       = '8'
      no_upd_auth                          = '9'
      only_show_allowed                    = '10'
      system_failure                       = '11'
      unknown_field_in_dba_sellist         = '12'
      view_not_found                       = '13'
      maintenance_prohibited               = '14'
      OTHERS                               = '15'.
    IF sy-subrc NE 0.
      MESSAGE e208(00) WITH text-001.
    ENDIF.
ENDFORM.                    " ejecuta_actualizador
