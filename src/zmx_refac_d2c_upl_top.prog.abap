*&---------------------------------------------------------------------*
*& Include ZMX_REFAC_D2C_UPL_TOP
*&
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_txt,
         line(300),
       END OF ty_txt,
       BEGIN OF ty_arch,
         fld01(10) TYPE c,
         fld02(16) TYPE c,
         fld03(01) TYPE c,
         fld04(40) TYPE c,
         fld05(40) TYPE c,
         fld06(60) TYPE c,
         fld07(10) TYPE c,
         fld08(40) TYPE c,
         fld09(10) TYPE c,
         fld10(40) TYPE c,
         fld11(03) TYPE c,
         fld12(06) TYPE c,
         fld13(05) TYPE c,
         fld14(03) TYPE c,
         fld15(25) TYPE c,
       END OF ty_arch,
       BEGIN OF ty_uuid,
         vbeln TYPE vbrk-vbeln,
         uuid TYPE ztmxefact-uuid,
       END OF ty_uuid,
       BEGIN OF ty_vbrk,
         vbeln TYPE vbrk-vbeln,
         vbtyp TYPE vbrk-vbtyp,
         vkorg TYPE vbrk-vkorg,
         vtweg TYPE vbrk-vtweg,
         fksto TYPE vbrk-fksto,
       END OF ty_vbrk,
       BEGIN OF ty_deliv,
         vbeln TYPE VBELN_VF,
         vbelv TYPE VBELN_VL,
       END OF ty_deliv,
       BEGIN OF ty_region,
         bland TYPE t005u-bland,
       END OF ty_region,
       BEGIN OF ty_varia,
         name TYPE RVARI_VNAM,
         low TYPE RVARI_VAL_255,
       END OF ty_varia,
       BEGIN OF ty_refac,
         vbeln TYPE zmxsd_refac_d2c-vbeln,
         stcd1 TYPE zmxsd_refac_d2c-stcd1,
         rfcty TYPE zmxsd_refac_d2c-rfcty,
         name1 TYPE zmxsd_refac_d2c-name1,
         name4 TYPE zmxsd_refac_d2c-name4,
         street TYPE zmxsd_refac_d2c-street,
         house_num1 TYPE zmxsd_refac_d2c-house_num1,
         city2 TYPE zmxsd_refac_d2c-city2,
         post_code1 TYPE zmxsd_refac_d2c-post_code1,
         city1 TYPE zmxsd_refac_d2c-city1,
         region TYPE zmxsd_refac_d2c-region,
         regimen TYPE zmxsd_refac_d2c-regimen,
         zuse TYPE zmxsd_refac_d2c-zuse,
         zpay TYPE zmxsd_refac_d2c-zpay,
         celltab TYPE lvc_t_styl,
         error TYPE char300,
         cellcolors  TYPE lvc_t_scol,
         index TYPE lvc_index ,
         field TYPE CHAR12,
       END OF ty_refac.
*----------------------------------------------------------------------
* Internal Tables
*----------------------------------------------------------------------
DATA: i_txt TYPE STANDARD TABLE OF ty_txt, "#EC NEEDED
      i_arch TYPE STANDARD TABLE OF ty_arch, "#EC NEEDED
      i_vbrk TYPE STANDARD TABLE OF ty_vbrk, "#EC NEEDED
      i_deliv TYPE STANDARD TABLE OF ty_deliv, "#EC NEEDED
      i_refac TYPE STANDARD TABLE OF ty_refac, "#EC NEEDED
      i_refac_aux TYPE STANDARD TABLE OF zmxsd_refac_d2c, "#EC NEEDED
      i_uuid TYPE STANDARD TABLE OF ty_uuid, "#EC NEEDED
      i_region TYPE STANDARD TABLE OF ty_region, "#EC NEEDED
      i_varia TYPE STANDARD TABLE OF ty_varia, "#EC NEEDED
      i_exclude TYPE ui_functions, "#EC NEEDED
      i_celltab TYPE lvc_t_styl, "#EC NEEDED
      i_fcat TYPE lvc_t_fcat, "#EC NEEDED
      i_rows TYPE lvc_t_row. "#EC NEEDED
*----------------------------------------------------------------------
* Structures
*----------------------------------------------------------------------
DATA: wa_txt TYPE ty_txt, "#EC NEEDED
      wa_arch TYPE ty_arch, "#EC NEEDED
      wa_arch_aux TYPE ty_arch, "#EC NEEDED
      wa_vbrk TYPE ty_vbrk, "#EC NEEDED
      wa_deliv TYPE ty_deliv, "#EC NEEDED
      wa_refac TYPE ty_refac, "#EC NEEDED
      wa_refac_aux TYPE zmxsd_refac_d2c, "#EC NEEDED
      wa_uuid TYPE ty_uuid, "#EC NEEDED
      wa_region TYPE ty_region, "#EC NEEDED
      wa_varia TYPE ty_varia, "#EC NEEDED
      wa_celltab TYPE lvc_s_styl, "#EC NEEDED
      wa_fcat TYPE lvc_s_fcat, "#EC NEEDED
      wa_color TYPE lvc_s_scol, "#EC NEEDED
      wa_layout TYPE lvc_s_layo, "#EC NEEDED
      wa_rows TYPE lvc_s_row. "#EC NEEDED
*----------------------------------------------------------------------
* Variables
*----------------------------------------------------------------------
DATA: gv_edit TYPE char01, "#EC NEEDED
      gv_cont TYPE n LENGTH 2, "#EC NEEDED
      gv_name TYPE c LENGTH 11, "#EC NEEDED
      ok_code TYPE sy-ucomm, "#EC NEEDED
      gv_index TYPE sy-tabix, "#EC NEEDED
      container TYPE REF TO cl_gui_custom_container, "#EC NEEDED
      ref_grid TYPE REF TO cl_gui_alv_grid, "#EC NEEDED
      gv_nums TYPE CHAR10 VALUE '0123456789',
      gv_chars TYPE CHAR30 VALUE 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', "#EC NEEDED
      gv_nchar TYPE CHAR40 VALUE 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', "#EC NEEDED
      gv_regimen TYPE CHAR01, "#EC NEEDED
      lv_answer. "#EC NEEDED

CLASS lcl_event_receiver DEFINITION DEFERRED.
DATA: g_event_receiver TYPE REF TO lcl_event_receiver. "#EC NEEDED
*----------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_events_d0100 DEFINITION ##CLASS_FINAL.
  PUBLIC SECTION.
*Controlling data changes when ALV Grid is editable
    METHODS handle_data_changed
      FOR EVENT data_changed
                  OF cl_gui_alv_grid
      IMPORTING er_data_changed.
ENDCLASS.                    "lcl_events_d0100 DEFINITION
*----------------------------------------------------------------------
* CLASS lcl_event_receiver DEFINITION
*----------------------------------------------------------------------
CLASS lcl_event_receiver DEFINITION ##CLASS_FINAL.
  PUBLIC SECTION.

    METHODS handle_double_click
      FOR EVENT double_click
                  OF cl_gui_alv_grid
      IMPORTING e_row
                  e_column
                  es_row_no. "#EC NEEDED
ENDCLASS. "lcl_event_receiver DEFINITION
*----------------------------------------------------------------------
* CLASS lcl_tyftd_monitor DEFINITION
*----------------------------------------------------------------------
CLASS lcl_tyftd_monitor DEFINITION ##CLASS_FINAL.

  PUBLIC SECTION.
    METHODS:
*      clearstruct,
      get_data,
      process_data,
      display_data.
ENDCLASS.               "LCL_TYFTD_MONITOR
*----------------------------------------------------------------------
* Constants
*----------------------------------------------------------------------
CONSTANTS: c_x            TYPE c VALUE 'X',
           c_s            TYPE c VALUE 'S',
           c_e            TYPE c VALUE 'E',
           c_1            TYPE c VALUE '1',
           c_co           TYPE c VALUE ',',
           cao_*dot*(003) TYPE c VALUE '*.*',
           cao_cbsl(003)  TYPE c VALUE 'C:\',
           c_asc(10)      TYPE c VALUE 'ASC',
           c_do           TYPE i VALUE 15,
           c_csv(4)       TYPE c VALUE '.csv' ##NO_TEXT.
*----------------------------------------------------------------------
* Selection Parameters
*----------------------------------------------------------------------
SELECTION-SCREEN  BEGIN OF BLOCK b1 WITH FRAME.
  PARAMETERS: p_fname TYPE rlgrap-filename.
SELECTION-SCREEN END OF BLOCK b1.
