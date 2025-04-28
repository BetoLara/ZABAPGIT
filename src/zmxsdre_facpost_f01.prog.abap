*----------------------------------------------------------------------*
***INCLUDE ZMXSDRE_FACPOST_F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_1001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_1001 OUTPUT.
  APPEND 'SAVE' TO lfcode.
  APPEND 'EXIT' TO lfcode.
  APPEND 'CANCEL' TO lfcode.
  SET PF-STATUS 'ST1001' EXCLUDING lfcode.
  SET TITLEBAR 'TI1001'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1001 INPUT.
CASE ok_code.
  WHEN c_facp.
    SUBMIT zmxsdre_facpost_prg VIA SELECTION-SCREEN "#EC CI_SUBMIT
      AND RETURN.
  WHEN c_back or c_exit.
    SET SCREEN 0.
ENDCASE.
ENDMODULE.
*&--------------------------------------------------------------------*
*&      Form  AUTHORIZATION_CHECK
*&--------------------------------------------------------------------*
FORM authorization_check.

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

ENDFORM.                    "authorization_check
