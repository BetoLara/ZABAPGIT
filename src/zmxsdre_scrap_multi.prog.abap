*&---------------------------------------------------------------------*
*& Report ZMXSDRE_SCRAP_MULTI
*&---------------------------------------------------------------------*
* Project       : Facturacion SCRAP
* Program       : ZMXSDRE_SCRAP
* Created by    : LARAH2
* Creation date : 12/JUN/2018
* Description   : Interfaz para Administracion de Facturacion SCRAP
* Transport     : NEDK919572
*&---------------------------------------------------------------------*
REPORT ZMXSDRE_SCRAP_MULTI.

INCLUDE ZMXSDRE_SCRAP_MULTI_TOP.

CLASS lcl_event_receiver DEFINITION DEFERRED.

CLASS lcl_event_receiver DEFINITION  ##CLASS_FINAL.

  PUBLIC SECTION.
    METHODS:
      handle_data_changed
                    FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed.
ENDCLASS.

DATA: g_event_receiver TYPE REF TO lcl_event_receiver. "#EC NEEDED

INCLUDE ZMXSDRE_SCRAP_MULTI_F01.

*---------------------------------------------------------
CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD handle_data_changed.

    DATA: ls_good       TYPE lvc_s_modi,
          v_tax_kna1(2),
*          v_tax_lfa1(2),
          wt_alv_output TYPE ty_alv_reg_fac.

    LOOP AT er_data_changed->mt_good_cells INTO ls_good.
** check if column PLANETYPE of this row was changed
      CLEAR: wt_kna1. " wt_lfa1.

      IF ls_good-fieldname = 'KUNNR'.

        SELECT SINGLE kunnr land1 INTO wt_kna1 FROM kna1
          WHERE kunnr = ls_good-value.
        IF sy-subrc EQ 0.

          IF wt_kna1-land1 EQ 'MX'.
            CALL METHOD er_data_changed->modify_cell
              EXPORTING
                i_row_id    = ls_good-row_id
                i_fieldname = 'IVA_FAC'
                i_value     = 'P2'.
          ELSE.
            CALL METHOD er_data_changed->modify_cell
              EXPORTING
                i_row_id    = ls_good-row_id
                i_fieldname = 'IVA_FAC'
                i_value     = 'V0'.
          ENDIF.
        ELSE.
          CALL METHOD er_data_changed->modify_cell
            EXPORTING
              i_row_id    = ls_good-row_id
              i_fieldname = 'IVA_FAC'
              i_value     = ''.
        ENDIF.
      ENDIF.

      IF ls_good-fieldname = 'IVA_FAC'.

        READ TABLE t_alv_output INTO wt_alv_output INDEX ls_good-row_id.
        IF sy-subrc EQ 0.
          SELECT SINGLE kunnr land1 INTO wt_kna1 FROM kna1
              WHERE kunnr = wt_alv_output-kunnr.
          IF sy-subrc EQ 0.
            IF wt_kna1-land1 EQ 'MX'.
              v_tax_kna1 = 'P2'.
            ELSE.
              v_tax_kna1 = 'V0'.
            ENDIF.

            IF v_tax_kna1 NE ls_good-value.
*    'A': Abort (Stop sign)
*    'E': Error (red LED)
*    'W': Warning (yellow LED)
*    'I': Information (green LED)
              CALL METHOD er_data_changed->add_protocol_entry
                EXPORTING
                  i_msgid     = '0K'
                  i_msgno     = '000'
                  i_msgty     = 'W'
                  i_msgv1     = text-056            " 'Invoice tax'                                 "Flugzeugtyp
                  i_msgv2     = ls_good-value
                  i_msgv3     = text-057            " 'No corresponding to Client Number'           "exitstiert nicht
                  i_fieldname = ls_good-fieldname
                  i_row_id    = ls_good-row_id.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.

  AUTHORITY-CHECK OBJECT 'Z_VKORG'
    ID 'ACTVT' FIELD '03'
    ID 'VKORG' FIELD c_vkorg.

  IF sy-subrc = 0.

    "EXTRACCION DE DATOS PARA ALV
    PERFORM f0001_data_extraction.

    IF p_crea = c_x.
      PERFORM f0002_show_report.
    ENDIF.

    IF p_edit = c_x.
      PERFORM f0022_edit_report.
    ENDIF.

    IF p_show = c_x.
      PERFORM f0012_show_report.
    ENDIF.

  ELSE.
    MESSAGE s001(00) WITH TEXT-055 '' '' '' "Sin permisos para ejecutar el programa
    DISPLAY LIKE c_e.
  ENDIF.
