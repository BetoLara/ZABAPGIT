*&---------------------------------------------------------------------*
*& Report ZMXSDRE_FACPOST
*&---------------------------------------------------------------------*
*& Description: Facturación Automática Liverpool                       *
*& Date/Author: 8/ABR/2019 - Heriberto Lara Llanas  LARAH2             *
*& Functional: Ricardo Zavala                                          *
*& Transport: NEDK937062                                               *
*&---------------------------------------------------------------------*
REPORT ZMXSDRE_FACPOST.

DATA: ok_code LIKE sy-ucomm,
      lfcode TYPE TABLE OF sy-ucomm, "#EC NEEDED
      auth_chk TYPE c LENGTH 1. "#EC NEEDED

CONSTANTS: c_back type char4 value 'BACK',
           c_exit type char4 value '&F15',
           c_facp type char4 value 'FACP'.
INCLUDE zmxsdre_facpost_f01.

START-OF-SELECTION.
PERFORM authorization_check.
  CALL SCREEN 1001.
