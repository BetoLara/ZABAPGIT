*&---------------------------------------------------------------------*
*& Include ZMX_REFAC_D2C_REP_TOP
*&
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------
* Selection Parameters
*----------------------------------------------------------------------
SELECTION-SCREEN  BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
  SELECT-OPTIONS: s_vbeln FOR vbrk-vbeln,
                  s_rfc FOR zmxsd_refac_d2c-stcd1 NO INTERVALS,
                  s_cvbeln FOR vbrk-vbeln,
                  s_nvbeln FOR vbrk-vbeln,
                  s_ernam FOR sy-uname NO INTERVALS DEFAULT sy-uname,
                  s_erdat FOR sy-datum DEFAULT sy-datum.
SELECTION-SCREEN END OF BLOCK b1.
