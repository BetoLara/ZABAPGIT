*&---------------------------------------------------------------------*
*&  Include           ZMX_REFAC_D2C_UPL_LCL
*&---------------------------------------------------------------------*
CLASS lcl_tyftd_monitor IMPLEMENTATION.
  METHOD get_data.
    PERFORM f_load_file USING p_fname.
    PERFORM f_get_tables.
  ENDMETHOD.                    "get_data
  METHOD process_data.
    PERFORM f_load_table.
  ENDMETHOD.                    "process_data
  METHOD display_data.
    PERFORM f_field_cat.
    PERFORM f_exclude.
    PERFORM f_alv.
  ENDMETHOD.                    "display_data

ENDCLASS.                    "lcl_tyftd_monitor IMPLEMENTATION
CLASS lcl_events_d0100 IMPLEMENTATION.
*Handle Data Changed
  METHOD handle_data_changed.
    PERFORM handle_data_changed USING er_data_changed .
  ENDMETHOD.
ENDCLASS.                    "lcl_events_d0100 IMPLEMENTATION
*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_receiver IMPLEMENTATION.

  METHOD handle_double_click.

    CLEAR: wa_refac.
    IF e_column-fieldname = 'VBELN'.
      READ TABLE i_refac INTO wa_refac INDEX e_row-index.
      IF sy-subrc EQ 0.
        READ TABLE i_vbrk INTO wa_vbrk WITH KEY vbeln = wa_refac-vbeln.
        IF sy-subrc EQ 0.
          SET PARAMETER ID 'VF'  FIELD wa_refac-vbeln.
          CALL TRANSACTION 'VF03' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "handle_double_Click
ENDCLASS. "lcl_event_receiver IMPLEMENTATION
