*&---------------------------------------------------------------------*
*&  Include           ZMXSDRE_SCRAP_TOP
*&---------------------------------------------------------------------*
* Project       : Facturacion SCRAP
* Program       : ZMXSDRE_SCRAP
* Created by    : LARAH2
* Creation date : 12/JUN/2018
* Description   : Interfaz para Administracion de Facturacion SCRAP
* Transport     : NEDK919572
*&---------------------------------------------------------------------*
DATA lfcode TYPE TABLE OF sy-ucomm. "#EC NEEDED
CONSTANTS: c_x    type char1 value 'X',
           c_rfac type char4 value 'RFAC',
           c_reph type char4 value 'REPH',
           c_pfac type char4 value 'PFAC',
           c_efac type char4 value 'EFAC',
           c_back type char4 value 'BACK',
           c_exit type char4 value '&F15',
           c_emal type char4 value 'EMAL'.
