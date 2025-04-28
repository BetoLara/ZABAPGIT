*&---------------------------------------------------------------------*
*& Report  ZMX_CREATE_SALES_ORDERS_ACT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*                     MODIFICATION LOG                                 *
*&---------------------------------------------------------------------*
* Description        : Do not generate duplicate orders                *
* Functional         : Ricardo D. Garza                                *
* Developer          : Iris A. Ruiz Mtz  user (RUIZIA)    TEKNNA       *
* Created on         : 04.12.2013                                      *
* Order              : NDVK9A10UW                                      *
*&---------------------------------------------------------------------*


************************************************************************
* 12/11/16   smartShift project
* Rule ids applied: #166 #723
************************************************************************
************************************************************************
*  Date: 07/01/2018 User: AGA (LARAH2) CTS:NEDK919942  Change:CHG0085456
*  Description: New fields have been added to the table
*               processed by this program, fields and positions have been
*               updated.
**********************************************************************
*  Date: 07/08/2018 User: AGA (LARAH2) CTS:NEDK922336  Change:CHG0087785
*  Description: New fields have been added to the Z table


*   07/17/2020  NEDK957220 CHG0124096 GARCA59
*  Eliminate submit call to Create Sales Orders
*-------------------------------------------------------------------------

REPORT  zmx_create_sales_orders_act.

*  *  *  *  *  DECLARACIONES  *  *  *  *  *
TYPE-POOLS slis.

TABLES: zmx_sales_orders,
        zuser_act_order.

TYPES: BEGIN OF ty_hd,
         vbeln           TYPE vbeln_va,
         num_int         TYPE ad_roomnum,
         betwstreets     TYPE zsde_hd_btstr,
         hometype        TYPE zsde_hd_hmtyp,
         del_floor       TYPE ad_floor,
         stairs          TYPE zsde_hd_stairs,
         elevator        TYPE zsde_hd_elevat,
         private_distr   TYPE zsde_hd_privdi,
         access_docum    TYPE zsde_hd_accdc,
         del_shift       TYPE zsde_hd_delsh,
         delivery_nextd  TYPE zsde_hd_expr,
         scnd_floor      TYPE  zsde_hd_scndflr, " AGA 08/08/2018 CHG0087785
         thrdfifht_floor TYPE  zsde_hd_thrfflr,  " AGA 08/08/2018 CHG0087785
         fixed_day       TYPE zsde_hd_fixed,
         time_frame      TYPE zsde_hd_sptimfr, "  GARCA59 CHG0093826 11/22/2018
         weeknd_del      TYPE zsde_hd_weeknd, "  GARCA59 CHG0093826 11/22/2018
         specific_time   TYPE zsde_hd_specif, "  GARCA59 CHG0093826 11/22/2018
         unpack          TYPE zsde_hd_unpack, "  GARCA59 CHG0093826 11/22/2018
         install         TYPE zsde_hd_install, "  GARCA59 CHG0093826 11/22/2018
         pickup          TYPE zsde_hd_pickup, "  GARCA59 CHG0093826 11/22/2018
       END OF ty_hd,

       BEGIN OF ty_hd_it,
         vbeln          TYPE  vbeln_va,
         posnr          TYPE  posnr_va,
         cond_type      TYPE kschl,
         cond_value     TYPE kwert,
         top_floors     TYPE zsde_hd_topflrs,
         fixed_day      TYPE zsde_hd_fixed,
         time_frame     TYPE zsde_hd_sptimfr,
         weeknd_del     TYPE zsde_hd_weeknd,
         specific_time  TYPE zsde_hd_specif,
         pickup         TYPE zsde_hd_pickup,
         delivery_nextd TYPE zsde_hd_expr,
         del_shift      TYPE zsde_hd_delsh,
         install        TYPE zsde_hd_install,
         unpack         TYPE zsde_hd_unpack,
       END OF ty_hd_it,

       BEGIN OF ty_reqdldt,
         vbeln TYPE vbeln_va,
         contr TYPE count,
         reqdi TYPE zsde_cp_reqdi,
         reqdf TYPE zsde_cp_reqdf,
       END OF ty_reqdldt.

DATA: BEGIN OF it_zmx_sales_orders OCCURS 10,
        taw_order        LIKE  zmx_sales_orders-taw_order,
        localfile        LIKE  zmx_sales_orders-localfile,
        vbeln_create     LIKE  zmx_sales_orders-vbeln_create,
        status           LIKE  zmx_sales_orders-status,
        secue            LIKE  zmx_sales_orders-secue,
        doc_type         LIKE  zmx_sales_orders-doc_type,
        sales_org        LIKE  zmx_sales_orders-sales_org,
        distr_chan       LIKE  zmx_sales_orders-distr_chan,
        division         LIKE  zmx_sales_orders-division,
        sales_grp        LIKE  zmx_sales_orders-sales_grp,
        sales_off        LIKE  zmx_sales_orders-sales_off,
        req_date_h       LIKE  zmx_sales_orders-req_date_h,
        purch_date       LIKE  zmx_sales_orders-purch_date,
        po_method        LIKE  zmx_sales_orders-po_method,
        ref_1            LIKE  zmx_sales_orders-ref_1,
        pmnttrms         LIKE  zmx_sales_orders-pmnttrms,
        purch_no_c       LIKE  zmx_sales_orders-purch_no_c,
        doc_date         LIKE  zmx_sales_orders-doc_date,
        ship_cond        LIKE  zmx_sales_orders-ship_cond,
        accnt_asgn       LIKE   zmx_sales_orders-accnt_asgn,
        partn_role_ag    LIKE  zmx_sales_orders-partn_role_ag,
        partn_numb_ag    LIKE  zmx_sales_orders-partn_numb_ag,
        name_ag          LIKE  zmx_sales_orders-name_ag,
        name_2_ag        LIKE  zmx_sales_orders-name_2_ag,
        name_3_ag        LIKE  zmx_sales_orders-name_3_ag,
        name_4_ag        LIKE  zmx_sales_orders-name_4_ag,
        street_ag        LIKE  zmx_sales_orders-street_ag,
        house_num1       TYPE  ad_hsnm1, " AGA CHG0085456 07/13/18
        country_ag       LIKE  zmx_sales_orders-country_ag,
        postl_code_ag    LIKE  zmx_sales_orders-postl_code_ag,
        city_ag          LIKE  zmx_sales_orders-city_ag,
        district_ag      LIKE  zmx_sales_orders-district_ag,
        region_ag        LIKE  zmx_sales_orders-region_ag,
        telephone_ag     LIKE  zmx_sales_orders-telephone_ag,
        mob_number       TYPE  ad_mbnmbr1, " AGA CHG0085456 07/13/18
        email            TYPE  zsde_hd_smtpadr, " AGA CHG0085456 07/13/18
        transpzone_ag    LIKE  zmx_sales_orders-transpzone_ag,
        partn_role_we    LIKE  zmx_sales_orders-partn_role_we,
        partn_numb_we    LIKE  zmx_sales_orders-partn_numb_we,
        name_we          LIKE  zmx_sales_orders-name_we,
        name_2_we        LIKE  zmx_sales_orders-name_2_we,
        name_3_we        LIKE  zmx_sales_orders-name_3_we,
        name_4_we        LIKE  zmx_sales_orders-name_4_we,
        street_we        LIKE  zmx_sales_orders-street_we,
        house_num2       TYPE  ad_hsnm2, " AGA CHG0085456 07/13/18
        country_we       LIKE  zmx_sales_orders-country_we,
        postl_code_we    LIKE  zmx_sales_orders-postl_code_we,
        city_we          LIKE  zmx_sales_orders-city_we,
        district_we      LIKE  zmx_sales_orders-district_we,
        region_we        LIKE  zmx_sales_orders-region_we,
        telephone_we     LIKE  zmx_sales_orders-telephone_we,
        mob_number2      TYPE  ad_mbnmbr1, " AGA CHG0085456 07/13/18
        email2           TYPE  zsde_hd_smtpadr, " AGA CHG0085456 07/13/18
        transpzone_we    LIKE  zmx_sales_orders-transpzone_we,
        partn_role_rg    LIKE  zmx_sales_orders-partn_role_rg,
        partn_numb_rg    LIKE  zmx_sales_orders-partn_numb_rg,
        name_rg          LIKE  zmx_sales_orders-name_rg,
        name_2_rg        LIKE  zmx_sales_orders-name_2_rg,
        name_3_rg        LIKE  zmx_sales_orders-name_3_rg,
        name_4_rg        LIKE  zmx_sales_orders-name_4_rg,
        street_rg        LIKE  zmx_sales_orders-street_rg,
        house_num3       TYPE  ad_hsnm2, " AGA CHG0085456 07/13/18
        country_rg       LIKE  zmx_sales_orders-country_rg,
        postl_code_rg    LIKE  zmx_sales_orders-postl_code_rg,
        city_rg          LIKE  zmx_sales_orders-city_rg,
        district_rg      LIKE  zmx_sales_orders-district_rg,
        region_rg        LIKE  zmx_sales_orders-region_rg,
        telephone_rg     LIKE  zmx_sales_orders-telephone_rg,
        mob_number3      TYPE  ad_mbnmbr1, " AGA CHG0085456 07/13/18
        email3           TYPE  zsde_hd_smtpadr, " AGA CHG0085456 07/13/18
        transpzone_rg    LIKE  zmx_sales_orders-transpzone_rg,
        text_id_note     LIKE  zmx_sales_orders-text_id_note,
        langu_note       LIKE  zmx_sales_orders-langu_note,
        text_line_note   LIKE  zmx_sales_orders-text_line_note,
        text_line_note_1 LIKE  zmx_sales_orders-text_line_note_1,
        text_id_ship     LIKE  zmx_sales_orders-text_id_ship,
        langu_ship       LIKE  zmx_sales_orders-langu_ship,
        text_line_ship   LIKE  zmx_sales_orders-text_line_ship,
        text_line_ship_1 LIKE  zmx_sales_orders-text_line_ship_1,
        itm_number       LIKE  zmx_sales_orders-itm_number,
        cond_type        LIKE  zmx_sales_orders-cond_type,
        cond_value       LIKE  zmx_sales_orders-cond_value,
        currency         LIKE  zmx_sales_orders-currency,
        condcoinhd       LIKE  zmx_sales_orders-condcoinhd,
        stcd1            LIKE  zmx_sales_orders-stcd1,
        stcd2            LIKE  zmx_sales_orders-stcd2,
        stkzn            LIKE  zmx_sales_orders-stkzn,
        dlv_block        LIKE  zmx_sales_orders-dlv_block,
        material         LIKE  zmx_sales_orders-material,
        plant            LIKE  zmx_sales_orders-plant,
        store_loc        LIKE  zmx_sales_orders-store_loc,
        target_qty       LIKE  zmx_sales_orders-target_qty,
        price_list       LIKE  zmx_sales_orders-price_list,
        itm_number_1     LIKE  zmx_sales_orders-itm_number_1,
        cond_type_1      LIKE  zmx_sales_orders-cond_type_1,
        cond_value_1     LIKE  zmx_sales_orders-cond_value_1,
        currency_1       LIKE  zmx_sales_orders-currency_1,
        condcoinhd_1     LIKE  zmx_sales_orders-condcoinhd_1,
*        BEGIN AGA CHG0085456 07/13/18
        pricingdate      TYPE  prsdt,
        incoterm         TYPE  inco1,
        fullorder        TYPE  zsde_cp_fullord,
        num_int          TYPE  ad_roomnum,
        betwstreets      TYPE  zsde_hd_btstr,
        hometype         TYPE  zsde_hd_hmtyp,
        del_floor        TYPE  ad_floor,
        stairs           TYPE  zsde_hd_stairs,
        elevator         TYPE  zsde_hd_elevat,
        private_distr    TYPE  zsde_hd_privdi,
        access_docum     TYPE  zsde_hd_accdc,
        del_shift        TYPE  zsde_hd_delsh,
        delivery_nextd   TYPE  zsde_hd_expr,
        scnd_floor       TYPE  zsde_hd_scndflr, " AGA 08/08/2018 CHG0087785
        thrdfifht_floor  TYPE  zsde_hd_thrfflr, " AGA 08/08/2018 CHG0087785
        reqdi            TYPE  zsde_cp_reqdi,
        reqdf            TYPE  zsde_cp_reqdf,
*        END AGA CHG0085456 07/13/18
        top_floors       TYPE zsde_hd_topflrs,
        fixed_day        TYPE zsde_hd_fixed,
        time_frame       TYPE zsde_hd_sptimfr, "  GARCA59 CHG0093826 11/22/2018
        weeknd_del       TYPE zsde_hd_weeknd, "  GARCA59 CHG0093826 11/22/2018
        specific_time    TYPE zsde_hd_specif, "  GARCA59 CHG0093826 11/22/2018
        unpack           TYPE zsde_hd_unpack, "  GARCA59 CHG0093826 11/22/2018
        install          TYPE zsde_hd_install, "  GARCA59 CHG0093826 11/22/2018
        pickup           TYPE zsde_hd_pickup, "  GARCA59 CHG0093826 11/22/2018
        folio1           TYPE CHAR28,
        banco1           TYPE CHAR28,
        monto1           TYPE NETPR,
        folio2           TYPE CHAR28,
        banco2           TYPE CHAR28,
        monto2           TYPE NETPR,
        folio3           TYPE CHAR28,
        banco3           TYPE CHAR28,
        monto3           TYPE NETPR,
      END OF it_zmx_sales_orders.

DATA: it_alv LIKE it_zmx_sales_orders OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF it_zmx_sales_orders_paso,
        taw_order        LIKE  zmx_sales_orders-taw_order,
        localfile        LIKE  zmx_sales_orders-localfile,
        vbeln_create     LIKE  zmx_sales_orders-vbeln_create,
        status           LIKE  zmx_sales_orders-status,
        secue            LIKE  zmx_sales_orders-secue,
        doc_type         LIKE  zmx_sales_orders-doc_type,
        sales_org        LIKE  zmx_sales_orders-sales_org,
        distr_chan       LIKE  zmx_sales_orders-distr_chan,
        division         LIKE  zmx_sales_orders-division,
        sales_grp        LIKE  zmx_sales_orders-sales_grp,
        sales_off        LIKE  zmx_sales_orders-sales_off,
        req_date_h       LIKE  zmx_sales_orders-req_date_h,
        purch_date       LIKE  zmx_sales_orders-purch_date,
        po_method        LIKE  zmx_sales_orders-po_method,
        ref_1            LIKE  zmx_sales_orders-ref_1,
        pmnttrms         LIKE  zmx_sales_orders-pmnttrms,
        purch_no_c       LIKE  zmx_sales_orders-purch_no_c,
        doc_date         LIKE  zmx_sales_orders-doc_date,
        ship_cond        LIKE  zmx_sales_orders-ship_cond,
        accnt_asgn       LIKE   zmx_sales_orders-accnt_asgn,
        partn_role_ag    LIKE  zmx_sales_orders-partn_role_ag,
        partn_numb_ag    LIKE  zmx_sales_orders-partn_numb_ag,
        name_ag          LIKE  zmx_sales_orders-name_ag,
        name_2_ag        LIKE  zmx_sales_orders-name_2_ag,
        name_3_ag        LIKE  zmx_sales_orders-name_3_ag,
        name_4_ag        LIKE  zmx_sales_orders-name_4_ag,
        street_ag        LIKE  zmx_sales_orders-street_ag,
        house_num1       TYPE  ad_hsnm1, " AGA CHG0085456 07/13/18
        country_ag       LIKE  zmx_sales_orders-country_ag,
        postl_code_ag    LIKE  zmx_sales_orders-postl_code_ag,
        city_ag          LIKE  zmx_sales_orders-city_ag,
        district_ag      LIKE  zmx_sales_orders-district_ag,
        region_ag        LIKE  zmx_sales_orders-region_ag,
        telephone_ag     LIKE  zmx_sales_orders-telephone_ag,
        mob_number       TYPE  ad_mbnmbr1, " AGA CHG0085456 07/13/18
        email            TYPE  zsde_hd_smtpadr, " AGA CHG0085456 07/13/18
        transpzone_ag    LIKE  zmx_sales_orders-transpzone_ag,
        partn_role_we    LIKE  zmx_sales_orders-partn_role_we,
        partn_numb_we    LIKE  zmx_sales_orders-partn_numb_we,
        name_we          LIKE  zmx_sales_orders-name_we,
        name_2_we        LIKE  zmx_sales_orders-name_2_we,
        name_3_we        LIKE  zmx_sales_orders-name_3_we,
        name_4_we        LIKE  zmx_sales_orders-name_4_we,
        street_we        LIKE  zmx_sales_orders-street_we,
        house_num2       TYPE  ad_hsnm2,
        country_we       LIKE  zmx_sales_orders-country_we,
        postl_code_we    LIKE  zmx_sales_orders-postl_code_we,
        city_we          LIKE  zmx_sales_orders-city_we,
        district_we      LIKE  zmx_sales_orders-district_we,
        region_we        LIKE  zmx_sales_orders-region_we,
        telephone_we     LIKE  zmx_sales_orders-telephone_we,
        mob_number2      TYPE  ad_mbnmbr1, " AGA CHG0085456 07/13/18
        email2           TYPE  zsde_hd_smtpadr, " AGA CHG0085456 07/13/18
        transpzone_we    LIKE  zmx_sales_orders-transpzone_we,
        partn_role_rg    LIKE  zmx_sales_orders-partn_role_rg,
        partn_numb_rg    LIKE  zmx_sales_orders-partn_numb_rg,
        name_rg          LIKE  zmx_sales_orders-name_rg,
        name_2_rg        LIKE  zmx_sales_orders-name_2_rg,
        name_3_rg        LIKE  zmx_sales_orders-name_3_rg,
        name_4_rg        LIKE  zmx_sales_orders-name_4_rg,
        street_rg        LIKE  zmx_sales_orders-street_rg,
        house_num3       TYPE  ad_hsnm2, " AGA CHG0085456 07/13/18
        country_rg       LIKE  zmx_sales_orders-country_rg,
        postl_code_rg    LIKE  zmx_sales_orders-postl_code_rg,
        city_rg          LIKE  zmx_sales_orders-city_rg,
        district_rg      LIKE  zmx_sales_orders-district_rg,
        region_rg        LIKE  zmx_sales_orders-region_rg,
        telephone_rg     LIKE  zmx_sales_orders-telephone_rg,
        mob_number3      TYPE  ad_mbnmbr1, " AGA CHG0085456 07/13/18
        email3           TYPE  zsde_hd_smtpadr, " AGA CHG0085456 07/13/18
        transpzone_rg    LIKE  zmx_sales_orders-transpzone_rg,
        text_id_note     LIKE  zmx_sales_orders-text_id_note,
        langu_note       LIKE  zmx_sales_orders-langu_note,
        text_line_note   LIKE  zmx_sales_orders-text_line_note,
        text_line_note_1 LIKE  zmx_sales_orders-text_line_note_1,
        text_id_ship     LIKE  zmx_sales_orders-text_id_ship,
        langu_ship       LIKE  zmx_sales_orders-langu_ship,
        text_line_ship   LIKE  zmx_sales_orders-text_line_ship,
        text_line_ship_1 LIKE  zmx_sales_orders-text_line_ship_1,
        itm_number       LIKE  zmx_sales_orders-itm_number,
        cond_type        LIKE  zmx_sales_orders-cond_type,
        cond_value       LIKE  zmx_sales_orders-cond_value,
        currency         LIKE  zmx_sales_orders-currency,
        condcoinhd       LIKE  zmx_sales_orders-condcoinhd,
        stcd1            LIKE  zmx_sales_orders-stcd1,
        stcd2            LIKE  zmx_sales_orders-stcd2,
        stkzn            LIKE  zmx_sales_orders-stkzn,
        dlv_block        LIKE  zmx_sales_orders-dlv_block,
        itm_number_1     LIKE  zmx_sales_orders-itm_number_1,
        cond_type_1      LIKE  zmx_sales_orders-cond_type_1,
        cond_value_1     LIKE  zmx_sales_orders-cond_value_1,
        currency_1       LIKE  zmx_sales_orders-currency_1,
        condcoinhd_1     LIKE  zmx_sales_orders-condcoinhd_1,
*        BEGIN AGA CHG0085456 07/13/18
        pricingdate      TYPE  prsdt,
        incoterm         TYPE  inco1,
        fullorder        TYPE  zsde_cp_fullord,
        num_int          TYPE  ad_roomnum,
        betwstreets      TYPE  zsde_hd_btstr,
        hometype         TYPE  zsde_hd_hmtyp,
        del_floor        TYPE  ad_floor,
        stairs           TYPE  zsde_hd_stairs,
        elevator         TYPE  zsde_hd_elevat,
        private_distr    TYPE  zsde_hd_privdi,
        access_docum     TYPE  zsde_hd_accdc,
        scnd_floor       TYPE  zsde_hd_scndflr, " AGA 08/08/2018 CHG0087785
        thrdfifht_floor  TYPE  zsde_hd_thrfflr, " AGA 08/08/2018 CHG0087785
        reqdi            TYPE  zsde_cp_reqdi,
        reqdf            TYPE  zsde_cp_reqdf,
*        END AGA CHG0085456 07/13/18
        fixed_day        TYPE zsde_hd_fixed,
        time_frame       TYPE zsde_hd_sptimfr, "  GARCA59 CHG0093826 11/22/2018
        weeknd_del       TYPE zsde_hd_weeknd, "  GARCA59 CHG0093826 11/22/2018
        specific_time    TYPE zsde_hd_specif, "  GARCA59 CHG0093826 11/22/2018
        unpack           TYPE zsde_hd_unpack, "  GARCA59 CHG0093826 11/22/2018
        install          TYPE zsde_hd_install, "  GARCA59 CHG0093826 11/22/2018
        pickup           TYPE zsde_hd_pickup, "  GARCA59 CHG0093826 11/22/2018
        delivery_nextd   TYPE  zsde_hd_expr,
        del_shift        TYPE zsde_hd_delsh,
*MATERIAL LIKE  ZMX_SALES_ORDERS-MATERIAL,
*PLANT    LIKE  ZMX_SALES_ORDERS-PLANT,
*STORE_LOC  LIKE  ZMX_SALES_ORDERS-STORE_LOC,
*TARGET_QTY LIKE  ZMX_SALES_ORDERS-TARGET_QTY,
      END OF it_zmx_sales_orders_paso.

DATA: BEGIN OF it_zuser_act_order OCCURS 10,
        usuario LIKE  zuser_act_order-usuario,
      END OF it_zuser_act_order.

DATA: it_fldcat        TYPE slis_t_fieldcat_alv,
      st_defvar        LIKE disvariant,

*$smart (W) 12/11/16 - #166 Data declaration uses obsolete data type. (A)

      repid            TYPE repid,                                                                  "$smart: #166
      gt_event_exit    TYPE slis_t_event_exit,
      it_vbeln         LIKE zmx_sales_orders-vbeln_create,
      it_status        LIKE zmx_sales_orders-status,
      ws_tabix         LIKE sy-tabix,
      target_qty_n(13) TYPE n.

DATA: w_field(4000)    TYPE c,
      cond_value_c(28) TYPE c.

DATA: w_field_paso LIKE w_field OCCURS 0 WITH HEADER LINE.

DATA: t_hd      TYPE TABLE OF ty_hd,
      t_hd_it   TYPE TABLE OF ty_hd_it,
      t_reqdldt TYPE TABLE OF ty_reqdldt.


*  *  *  *  *  PARAMETROS  *  *  *  *  *
SELECTION-SCREEN BEGIN OF BLOCK blk01 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: so_tawo FOR it_zmx_sales_orders-taw_order.
SELECTION-SCREEN END OF BLOCK blk01.

SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE TEXT-002.

PARAMETER: p_sapl RADIOBUTTON GROUP rd2,    "Aplicados
           p_napl RADIOBUTTON GROUP rd2,    "No aplicados
           p_ambo RADIOBUTTON GROUP rd2.    "Ambos
SELECTION-SCREEN END OF BLOCK blk2.


*  *  *  *  *  INITIALIZATION  *  *  *  *  *
INITIALIZATION.
  repid = sy-repid.

  p_ambo = 'X'.

*  *  *  *  *  START OF SELECTION  *  *  *  *  *
START-OF-SELECTION.

  PERFORM datos.

  PERFORM crea_vista.

  PERFORM reporte.

*&---------------------------------------------------------------------*
*&      Form  datos
*&---------------------------------------------------------------------*
*       Extraccion de materiales y datos
*----------------------------------------------------------------------*
FORM datos .

  DATA: lt_sales_orders LIKE TABLE OF it_zmx_sales_orders.

*Aplicados
  IF p_sapl = 'X'.
    SELECT taw_order localfile vbeln_create status secue doc_type sales_org distr_chan division sales_grp
           sales_off req_date_h purch_date po_method ref_1 pmnttrms purch_no_c doc_date ship_cond accnt_asgn
           partn_role_ag partn_numb_ag name_ag name_2_ag name_3_ag name_4_ag street_ag
           house_num1 " AGA CHG0085456 07/13/18
           country_ag postl_code_ag city_ag district_ag region_ag telephone_ag
           mob_number " AGA CHG0085456 07/13/18
           email " AGA CHG0085456 07/13/18
           transpzone_ag
           partn_role_we partn_numb_we name_we name_2_we name_3_we name_4_we street_we
           house_num2 " AGA CHG0085456 07/13/18
           country_we postl_code_we city_we district_we region_we telephone_we
           mob_number2 " AGA CHG0085456 07/13/18
           email2 " AGA CHG0085456 07/13/18
           transpzone_we
           partn_role_rg partn_numb_rg name_rg name_2_rg name_3_rg name_4_rg street_rg
           house_num3
           country_rg postl_code_rg city_rg district_rg region_rg telephone_rg
           mob_number3 " AGA CHG0085456 07/13/18
           email3 " AGA CHG0085456 07/13/18
           transpzone_rg
           text_id_note langu_note text_line_note text_line_note_1 text_id_ship langu_ship text_line_ship text_line_ship_1 itm_number cond_type cond_value currency condcoinhd stcd1 stcd2 stkzn dlv_block
           material plant store_loc target_qty price_list itm_number_1 cond_type_1 cond_value_1 currency_1 condcoinhd_1
           pricingdate " AGA CHG0085456 07/13/18
           incoterm " AGA CHG 0085456 07/13/18
           fullorder " AGA CHG0085456 07/13/18
    INTO TABLE it_zmx_sales_orders
    FROM zmx_sales_orders
    WHERE taw_order IN so_tawo
      AND status    = 'APLICADO'.

*No Aplicados
  ELSEIF p_napl = 'X'.
    SELECT taw_order localfile vbeln_create status secue doc_type sales_org distr_chan division sales_grp
           sales_off req_date_h purch_date po_method ref_1 pmnttrms purch_no_c doc_date ship_cond accnt_asgn
           partn_role_ag partn_numb_ag name_ag name_2_ag name_3_ag name_4_ag street_ag
           house_num1 " AGA CHG0085456 07/13/18
           country_ag postl_code_ag city_ag district_ag region_ag telephone_ag
           mob_number " AGA CHG0085456 07/13/18
           email " AGA CHG0085456 07/13/18
           transpzone_ag
           partn_role_we partn_numb_we name_we name_2_we name_3_we name_4_we street_we
           house_num2 " AGA CHG0085456 07/13/18
           country_we postl_code_we city_we district_we region_we telephone_we
           mob_number2 " AGA CHG0085456 07/13/18
           email2 " AGA CHG0085456 07/13/18
           transpzone_we
           partn_role_rg partn_numb_rg name_rg name_2_rg name_3_rg name_4_rg street_rg
           house_num3 " AGA CHG0085456 07/13/18
           country_rg postl_code_rg city_rg district_rg region_rg telephone_rg
           mob_number3 " AGA CHG0085456 07/13/18
           email3 " AGA CHG0085456 07/13/18
           transpzone_rg
           text_id_note langu_note text_line_note text_line_note_1 text_id_ship langu_ship text_line_ship text_line_ship_1 itm_number cond_type cond_value currency condcoinhd stcd1 stcd2 stkzn dlv_block
           material plant store_loc target_qty price_list itm_number_1 cond_type_1 cond_value_1 currency_1 condcoinhd_1
           pricingdate " AGA CHG0085456 07/13/18
           incoterm " AGA CHG0085456 07/13/18
           fullorder " AGA CHG0085456 07/13/18
    INTO TABLE it_zmx_sales_orders
    FROM zmx_sales_orders
    WHERE taw_order IN so_tawo
      AND status    = 'ERROR'.

*Ambos
  ELSEIF p_ambo = 'X'.
    SELECT taw_order localfile vbeln_create status secue doc_type sales_org distr_chan division sales_grp
           sales_off req_date_h purch_date po_method ref_1 pmnttrms purch_no_c doc_date ship_cond accnt_asgn
           partn_role_ag partn_numb_ag name_ag name_2_ag name_3_ag name_4_ag street_ag
           house_num1 " AGA CHG0085456 07/13/18
           country_ag postl_code_ag city_ag district_ag region_ag telephone_ag
           mob_number " AGA CHG0085456 07/13/18
           email " AGA CHG0085456 07/13/18
           transpzone_ag
           partn_role_we partn_numb_we name_we name_2_we name_3_we name_4_we street_we
           house_num2 " AGA CHG0085456 07/13/18
           country_we postl_code_we city_we district_we region_we telephone_we
           mob_number2 " AGA CHG0085456 07/13/18
           email2 " AGA CHG0085456 07/13/18
           transpzone_we
           partn_role_rg partn_numb_rg name_rg name_2_rg name_3_rg name_4_rg street_rg
           house_num3 " AGA CHG0085456 07/13/18
           country_rg postl_code_rg city_rg district_rg region_rg telephone_rg
           mob_number3 " AGA CHG0085456 07/13/18
           email3 " AGA CHG0085456 07/13/18
           transpzone_rg
           text_id_note langu_note text_line_note text_line_note_1 text_id_ship langu_ship text_line_ship text_line_ship_1 itm_number cond_type cond_value currency condcoinhd stcd1 stcd2 stkzn dlv_block
           material plant store_loc target_qty price_list itm_number_1 cond_type_1 cond_value_1 currency_1 condcoinhd_1
           pricingdate " AGA CHG0085456 07/13/18
           incoterm " AGA CHG0085456 07/13/18
           fullorder " AGA CHG0085456 07/13/18
    INTO TABLE it_zmx_sales_orders
    FROM zmx_sales_orders
    WHERE taw_order IN so_tawo.
  ENDIF.

*  BEGIN AGA CHG0085456 07/13/18 Obtain info from new table
  IF sy-subrc EQ 0.

    lt_sales_orders = it_zmx_sales_orders[].

    DELETE lt_sales_orders
     WHERE status NE 'APLICADO'.

    SORT lt_sales_orders
      BY vbeln_create.

    DELETE ADJACENT DUPLICATES FROM lt_sales_orders
     COMPARING vbeln_create.

    SELECT vbeln
           num_int
           betwstreets
           hometype
           del_floor
           stairs
           elevator
           private_distr
           access_docum
           del_shift
           delivery_nextd
            scnd_floor " AGA 08/08/2018 CHG0087785
            thrdfifht_floor " AGA 08/08/2018 CHG0087785
            fixed_day "  GARCA59 CHG0093826 11/22/2018
            time_frame "  GARCA59 CHG0093826 11/22/2018
            weeknd_del "  GARCA59  CHG0093826 11/22/2018
            specific_time "  GARCA59 CHG0093826 11/22/2018
            unpack "  GARCA59 CHG0093826 11/22/2018
            install "  GARCA59 CHG0093826 11/22/2018
            pickup "  GARCA59 CHG0093826 11/22/2018
       INTO
      TABLE t_hd
       FROM zsdt_hd_webso
      FOR ALL ENTRIES IN lt_sales_orders
      WHERE vbeln EQ lt_sales_orders-vbeln_create.

    IF sy-subrc EQ 0.

      SORT t_hd
        BY vbeln.

      SELECT vbeln
             posnr
            cond_type
            cond_value
            top_floors
            fixed_day
            time_frame
            weeknd_del
            specific_time
            pickup
            delivery_nextd
            del_shift
            install
            unpack
        INTO
       TABLE t_hd_it
        FROM zsdt_hd_webso_it
       FOR ALL ENTRIES IN t_hd
       WHERE vbeln EQ t_hd-vbeln.

      IF sy-subrc EQ 0.

        SORT t_hd_it
          BY vbeln
             posnr.

      ENDIF.

    ENDIF.

    SELECT vbeln
           contr
           reqdi
           reqdf
      INTO
     TABLE t_reqdldt
      FROM zsdt_cp_reqdldt
     FOR ALL ENTRIES IN lt_sales_orders
     WHERE vbeln EQ lt_sales_orders-vbeln_create.

    IF sy-subrc EQ 0.

      SORT t_reqdldt
        BY vbeln
           contr DESCENDING.

      DELETE ADJACENT DUPLICATES FROM t_reqdldt
       COMPARING vbeln.

      SORT t_reqdldt
        BY vbeln.

    ENDIF.

  ENDIF.
*  END AGA CHG0085456 07/13/18

*Obtiene Usuaruios que pueden actualizar
  SELECT usuario
  INTO TABLE it_zuser_act_order
  FROM zuser_act_order.


  SORT it_zuser_act_order BY usuario.

ENDFORM.                    " datos
*&---------------------------------------------------------------------*
*&      Form  crea_vista
*&---------------------------------------------------------------------*
*       Crea vista para alv
*----------------------------------------------------------------------*
FORM crea_vista .
  DATA: lw_hd      TYPE ty_hd,
        lw_reqdldt TYPE ty_reqdldt,
        lv_xml TYPE CHAR255,
        lv_of_mat1 TYPE i,
        lv_of_mat2 TYPE i,
        lv_of_mat3 TYPE i,
        lv_dat1 TYPE CHAR120,
        lv_dat2 TYPE CHAR120,
        lv_dat3 TYPE CHAR120,
        lv_mon1 TYPE CHAR20,
        lv_mon2 TYPE CHAR20,
        lv_mon3 TYPE CHAR20.

  SORT it_zmx_sales_orders BY taw_order.

  CLEAR   it_alv.
  REFRESH it_alv.

  LOOP AT it_zmx_sales_orders.
    CLEAR it_alv.
    MOVE-CORRESPONDING it_zmx_sales_orders TO it_alv.

*   BEGIN AGA CHG0085456 12/07/2018 " Set new info in ALV fields
    READ TABLE t_hd
       WITH KEY vbeln = it_alv-vbeln_create
       INTO lw_hd
     BINARY SEARCH.

    IF sy-subrc EQ 0.

      it_alv-num_int = lw_hd-num_int.
      it_alv-betwstreets = lw_hd-betwstreets.
      it_alv-hometype    = lw_hd-hometype.
      it_alv-del_floor   = lw_hd-del_floor.
      it_alv-stairs      = lw_hd-stairs.
      it_alv-elevator    = lw_hd-elevator.
      it_alv-private_distr = lw_hd-private_distr.
      it_alv-access_docum = lw_hd-access_docum.
      it_alv-del_shift    = lw_hd-del_shift.
      it_alv-delivery_nextd = lw_hd-delivery_nextd.
      it_alv-scnd_floor      = lw_hd-scnd_floor. " AGA 08/08/2018 CHG0087785
      it_alv-thrdfifht_floor = lw_hd-thrdfifht_floor. " AGA 08/08/2018 CHG0087785
*      BEGIN OF GARCA59 CHG0093826 11/22/2018
*      it_alv-fixed_day  = lw_hd-fixed_day.
*      it_alv-time_frame = lw_hd-time_frame.
*      it_alv-weeknd_del = lw_hd-weeknd_del.
*      it_alv-specific_time = lw_hd-specific_time.
*      it_alv-unpack = lw_hd-unpack.
*      it_alv-install = lw_hd-install.
*      it_alv-pickup = lw_hd-pickup.
*      END OF GARCA59 CHG0093826 11/22/2018


    ENDIF.

    lv_xml = it_alv-text_line_note.
    FIND FIRST OCCURRENCE OF '</R1>' IN lv_xml.
    IF sy-subrc EQ 0.
      REPLACE FIRST OCCURRENCE OF '<R1>' IN lv_xml WITH ''.
      FIND FIRST OCCURRENCE OF '</R1>' IN lv_xml MATCH OFFSET lv_of_mat1.
      lv_dat1 = lv_xml(lv_of_mat1).
      REPLACE FIRST OCCURRENCE OF '</R1>' IN lv_xml WITH ''.
      SPLIT lv_dat1 AT ',' INTO it_alv-folio1 it_alv-banco1 lv_mon1.
      IF lv_mon1 CN '0123456789.'.
        it_alv-monto1 = lv_mon1.
      ENDIF.
      CONDENSE: it_alv-folio1, it_alv-banco1.
    ENDIF.

    FIND FIRST OCCURRENCE OF '</R2>' IN lv_xml.
    IF sy-subrc EQ 0.
      REPLACE FIRST OCCURRENCE OF '<R2>' IN lv_xml WITH ''.
      FIND FIRST OCCURRENCE OF '</R2>' IN lv_xml MATCH OFFSET lv_of_mat2.
      lv_of_mat2 = lv_of_mat2 - lv_of_mat1.
      lv_dat2 = lv_xml+lv_of_mat1(lv_of_mat2).
      REPLACE FIRST OCCURRENCE OF '</R2>' IN lv_xml WITH ''.
      SPLIT lv_dat2 AT ',' INTO it_alv-folio2 it_alv-banco2 lv_mon2.
      IF lv_mon2 CN '0123456789.'.
        it_alv-monto2 = lv_mon2.
      ENDIF.
      CONDENSE: it_alv-folio2, it_alv-banco2.
    ENDIF.

    FIND FIRST OCCURRENCE OF '</R3>' IN lv_xml.
    IF sy-subrc EQ 0.
      REPLACE FIRST OCCURRENCE OF '<R3>' IN lv_xml WITH ''.
      FIND FIRST OCCURRENCE OF '</R3>' IN lv_xml MATCH OFFSET lv_of_mat3.
      lv_of_mat3 = lv_of_mat3 - lv_of_mat2 - lv_of_mat1.
      lv_of_mat1 = lv_of_mat1 + lv_of_mat2.
      lv_dat3 = lv_xml+lv_of_mat1(lv_of_mat3).
      SPLIT lv_dat3 AT ',' INTO it_alv-folio3 it_alv-banco3 lv_mon3.
      IF lv_mon3 CN '0123456789.'.
        it_alv-monto3 = lv_mon3.
      ENDIF.
      CONDENSE: it_alv-folio3, it_alv-banco3.
    ENDIF.

    READ TABLE t_reqdldt
      WITH KEY vbeln = it_alv-vbeln_create
    INTO lw_reqdldt
    BINARY SEARCH.

    IF sy-subrc EQ 0.

      it_alv-reqdi = lw_reqdldt-reqdi.
      it_alv-reqdf = lw_reqdldt-reqdf.

    ENDIF.
*      END AGA CHG0085456 12/07/2018

    APPEND it_alv.
  ENDLOOP.

ENDFORM.                    " crea_vista
*&---------------------------------------------------------------------*
*&      Form  reporte
*&---------------------------------------------------------------------*
*       Muestra el reporte en pantalla
*----------------------------------------------------------------------*
FORM reporte .
  DATA: st_print      TYPE slis_print_alv,
        st_layout     TYPE slis_layout_alv,
        it_sort       TYPE slis_t_sortinfo_alv WITH HEADER LINE,
        st_handlevent TYPE slis_formname.

  READ TABLE it_zuser_act_order WITH KEY usuario = sy-uname
             BINARY SEARCH.
  IF sy-subrc = 0.
    PERFORM columnas.
  ELSE.
    PERFORM columnas_no_edicion.
  ENDIF.


  PERFORM alv_exits_make CHANGING gt_event_exit.

  st_handlevent = 'USER_COMMAND'.

* SORT

  CLEAR it_sort.
  it_sort-spos   = 1.
  it_sort-fieldname	 = 'TAW_ORDER'.
  it_sort-tabname	 = 'IT_ALV'.
  it_sort-up          = 'X'.
  it_sort-group       = '*'.       " PARA QUE RESPETE EL TOP-OF-PAGE
*  it_sort-subtot	 = 'X'.
*  it_sort-comp        = 'X'.
*  it_sort-expa        = 'X'.
  APPEND it_sort.

  CLEAR it_sort.
  it_sort-spos   = 2.
  it_sort-fieldname	 = 'LOCALFILE'.
  it_sort-tabname	 = 'IT_ALV'.
  it_sort-up          = 'X'.
  it_sort-group       = '*'.       " PARA QUE RESPETE EL TOP-OF-PAGE
*  it_sort-subtot	 = 'X'.
*  it_sort-comp        = 'X'.
*  it_sort-expa        = 'X'.
  APPEND it_sort.

  CLEAR it_sort.
  it_sort-spos   = 3.
  it_sort-fieldname	 = 'VBELN_CREATE'.
  it_sort-tabname	 = 'IT_ALV'.
  it_sort-up          = 'X'.
  it_sort-group       = '*'.       " PARA QUE RESPETE EL TOP-OF-PAGE
*  it_sort-subtot	 = 'X'.
*  it_sort-comp        = 'X'.
*  it_sort-expa        = 'X'.
  APPEND it_sort.

  CLEAR it_sort.
  it_sort-spos   = 4.
  it_sort-fieldname	 = 'STATUS'.
  it_sort-tabname	 = 'IT_ALV'.
  it_sort-up          = 'X'.
  it_sort-group       = '*'.       " PARA QUE RESPETE EL TOP-OF-PAGE
*  it_sort-subtot	 = 'X'.
*  it_sort-comp        = 'X'.
*  it_sort-expa        = 'X'.
  APPEND it_sort.

  CLEAR it_sort.
  it_sort-spos   = 5.
  it_sort-fieldname	 = 'SECUE'.
  it_sort-tabname	 = 'IT_ALV'.
  it_sort-up          = 'X'.
  it_sort-group       = '*'.       " PARA QUE RESPETE EL TOP-OF-PAGE
*  it_sort-subtot	 = 'X'.
*  it_sort-comp        = 'X'.
*  it_sort-expa        = 'X'.
  APPEND it_sort.


  st_print-no_print_selinfos  = 'X'.
  st_print-no_coverpage       = 'X'.
  st_print-reserve_lines      = 1.
  st_print-no_print_listinfos = 'X'.

* st_layout-zebra             = 'X'.
  st_layout-no_min_linesize   = 'X'.
  st_layout-colwidth_optimize = 'X'.
  st_layout-window_titlebar   = 'Actualizador Sales Orders'.

  MOVE  'X'   TO st_layout-group_change_edit.

  SORT it_alv STABLE BY taw_order localfile vbeln_create status secue.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK       = ' '
*     I_BYPASSING_BUFFER      =
*     I_BUFFER_ACTIVE         = ' '
      i_callback_program      = repid
*     i_callback_pf_status_set       = st_events
      i_callback_user_command = st_handlevent
*     I_STRUCTURE_NAME        =
      is_layout               = st_layout
      it_fieldcat             = it_fldcat
*     IT_EXCLUDING            =
*     IT_SPECIAL_GROUPS       =
      it_sort                 = it_sort[]
*     IT_FILTER               =
*     IS_SEL_HIDE             =
      i_default               = 'X'
      i_save                  = 'A'
*     is_variant              = st_defvar
*     IT_EVENTS               =
      it_event_exit           = gt_event_exit
      is_print                = st_print
*     IS_REPREP_ID            =
*     I_SCREEN_START_COLUMN   = 0
*     I_SCREEN_START_LINE     = 0
*     I_SCREEN_END_COLUMN     = 0
*     I_SCREEN_END_LINE       = 0
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER =
*     ES_EXIT_CAUSED_BY_USER  =
    TABLES
      t_outtab                = it_alv
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " reporte
*&---------------------------------------------------------------------*
*&      Form  columnas
*&---------------------------------------------------------------------*
*       Genera las columnas del reporte
*----------------------------------------------------------------------*
FORM columnas .
  PERFORM agrega_columnas USING:
'TAW_ORDER'      'ZMX_SALES_ORDERS'  'TAW_ORDER'          space 'X'    ' ' 'X' space,
'LOCALFILE'      'ZMX_SALES_ORDERS'  'LOCALFILE'          space 'X'    ' ' 'X' 'X',
'VBELN_CREATE'   'ZMX_SALES_ORDERS'  'VBELN_CREATE'       space 'X'    ' ' 'X' space,
'STATUS'         'ZMX_SALES_ORDERS'  'STATUS'             space 'X'    ' ' 'X' space,
'SECUE'          'ZMX_SALES_ORDERS'  'SECUE'              space 'X'    ' ' 'X' space,
'DOC_TYPE'       'ZMX_SALES_ORDERS'  'DOC_TYPE'           space space  'X' 'X' space,
'SALES_ORG'      'ZMX_SALES_ORDERS'  'SALES_ORG'          space space  'X' 'X' space,
'DISTR_CHAN'     'ZMX_SALES_ORDERS'  'DISTR_CHAN'         space space  'X' 'X' space,
'DIVISION'       'ZMX_SALES_ORDERS'  'DIVISION'           space space  'X' 'X' space,
'SALES_GRP'      'ZMX_SALES_ORDERS'  'SALES_GRP'          space space  'X' 'X' space,
'SALES_OFF'      'ZMX_SALES_ORDERS'  'SALES_OFF'          space space  'X' 'X' space,
'REQ_DATE_H'     'ZMX_SALES_ORDERS'  'REQ_DATE_H'         space space  'X' 'X' space,
'PURCH_DATE'     'ZMX_SALES_ORDERS'  'PURCH_DATE'         space space  'X' 'X' space,
'PO_METHOD'      'ZMX_SALES_ORDERS'  'PO_METHOD'          space space  'X' 'X' space,
'REF_1'          'ZMX_SALES_ORDERS'  'REF_1'              space space  'X' 'X' space,
'PMNTTRMS'       'ZMX_SALES_ORDERS'  'PMNTTRMS'           space space  'X' 'X' space,
'PURCH_NO_C'     'ZMX_SALES_ORDERS'  'PURCH_NO_C'         space space  'X' 'X' space,
'DOC_DATE'       'ZMX_SALES_ORDERS'  'DOC_DATE'           space space  'X' 'X' space,
'SHIP_COND'      'ZMX_SALES_ORDERS'  'SHIP_COND'          space space  'X' 'X' space,
'ACCNT_ASGN'     'ZMX_SALES_ORDERS'  'ACCNT_ASGN'         space space  'X' 'X' space,
'PARTN_ROLE_AG'  'ZMX_SALES_ORDERS'  'PARTN_ROLE_AG'      space space  'X' 'X' space,
'PARTN_NUMB_AG'  'ZMX_SALES_ORDERS'  'PARTN_NUMB_AG'      space space  'X' 'X' space,
'NAME_AG'        'ZMX_SALES_ORDERS'  'NAME_AG'            space space  'X' 'X' space,
'NAME_2_AG'      'ZMX_SALES_ORDERS'  'NAME_2_AG'          space space  'X' 'X' space,
'NAME_3_AG'      'ZMX_SALES_ORDERS'  'NAME_3_AG'          space space  'X' 'X' space,
'NAME_4_AG'      'ZMX_SALES_ORDERS'  'NAME_4_AG'          space space  'X' 'X' space,
'STREET_AG'      'ZMX_SALES_ORDERS'  'STREET_AG'          space space  'X' 'X' space,
'HOUSE_NUM1'     'ZMX_SALES_ORDERS'  'HOUSE_NUM1'         space space  'X' 'X' space,
'COUNTRY_AG'     'ZMX_SALES_ORDERS'  'COUNTRY_AG'         space space  'X' 'X' space,
'POSTL_CODE_AG'  'ZMX_SALES_ORDERS'  'POSTL_CODE_AG'      space space  'X' 'X' space,
'CITY_AG'        'ZMX_SALES_ORDERS'  'CITY_AG'            space space  'X' 'X' space,
'DISTRICT_AG'    'ZMX_SALES_ORDERS'  'DISTRICT_AG'        space space  'X' 'X' space,
'REGION_AG'      'ZMX_SALES_ORDERS'  'REGION_AG'          space space  'X' 'X' space,
'TELEPHONE_AG'   'ZMX_SALES_ORDERS'  'TELEPHONE_AG'       space space  'X' 'X' space,
'MOB_NUMBER'     'ZMX_SALES_ORDERS'  'MOB_NUMBER'         space space  'X' 'X' space,
'EMAIL'          'ZMX_SALES_ORDERS'  'EMAIL'              space space  'X' 'X' space,
'TRANSPZONE_AG'  'ZMX_SALES_ORDERS'  'TRANSPZONE_AG'      space space  'X' 'X' space,
'PARTN_ROLE_WE'  'ZMX_SALES_ORDERS'  'PARTN_ROLE_WE'      space space  'X' 'X' space,
'PARTN_NUMB_WE'  'ZMX_SALES_ORDERS'  'PARTN_NUMB_WE'      space space  'X' 'X' space,
'NAME_WE'        'ZMX_SALES_ORDERS'  'NAME_WE'            space space  'X' 'X' space,
'NAME_2_WE'      'ZMX_SALES_ORDERS'  'NAME_2_WE'          space space  'X' 'X' space,
'NAME_3_WE'      'ZMX_SALES_ORDERS'  'NAME_3_WE'          space space  'X' 'X' space,
'NAME_4_WE'      'ZMX_SALES_ORDERS'  'NAME_4_WE'          space space  'X' 'X' space,
'STREET_WE'      'ZMX_SALES_ORDERS'  'STREET_WE'          space space  'X' 'X' space,
'HOUSE_NUM2'     'ZMX_SALES_ORDERS'  'HOUSE_NUM2'         space space  'X' 'X' space,
'COUNTRY_WE'     'ZMX_SALES_ORDERS'  'COUNTRY_WE'         space space  'X' 'X' space,
'POSTL_CODE_WE'  'ZMX_SALES_ORDERS'  'POSTL_CODE_WE'      space space  'X' 'X' space,
'CITY_WE'        'ZMX_SALES_ORDERS'  'CITY_WE'            space space  'X' 'X' space,
'DISTRICT_WE'    'ZMX_SALES_ORDERS'  'DISTRICT_WE'        space space  'X' 'X' space,
'REGION_WE'      'ZMX_SALES_ORDERS'  'REGION_WE'          space space  'X' 'X' space,
'TELEPHONE_WE'   'ZMX_SALES_ORDERS'  'TELEPHONE_WE'       space space  'X' 'X' space,
'MOB_NUMBER2'    'ZMX_SALES_ORDERS'  'MOB_NUMBER2'        space space  'X' 'X' space,
'EMAIL2'         'ZMX_SALES_ORDERS'  'EMAIL2'             space space  'X' 'X' space,
'TRANSPZONE_WE'  'ZMX_SALES_ORDERS'  'TRANSPZONE_WE'      space space  'X' 'X' space,
'PARTN_ROLE_RG'  'ZMX_SALES_ORDERS'  'PARTN_ROLE_RG'      space space  'X' 'X' space,
'PARTN_NUMB_RG'  'ZMX_SALES_ORDERS'  'PARTN_NUMB_RG'      space space  'X' 'X' space,
'NAME_RG'        'ZMX_SALES_ORDERS'  'NAME_RG'            space space  'X' 'X' space,
'NAME_2_RG'      'ZMX_SALES_ORDERS'  'NAME_2_RG'          space space  'X' 'X' space,
'NAME_3_RG'      'ZMX_SALES_ORDERS'  'NAME_3_RG'          space space  'X' 'X' space,
'NAME_4_RG'      'ZMX_SALES_ORDERS'  'NAME_4_RG'          space space  'X' 'X' space,
'STREET_RG'      'ZMX_SALES_ORDERS'  'STREET_RG'          space space  'X' 'X' space,
'HOUSE_NUM3'     'ZMX_SALES_ORDERS'  'HOUSE_NUM3'         space space  'X' 'X' space,
'COUNTRY_RG'     'ZMX_SALES_ORDERS'  'COUNTRY_RG'         space space  'X' 'X' space,
'POSTL_CODE_RG'  'ZMX_SALES_ORDERS'  'POSTL_CODE_RG'      space space  'X' 'X' space,
'CITY_RG'        'ZMX_SALES_ORDERS'  'CITY_RG'            space space  'X' 'X' space,
'DISTRICT_RG'    'ZMX_SALES_ORDERS'  'DISTRICT_RG'        space space  'X' 'X' space,
'REGION_RG'      'ZMX_SALES_ORDERS'  'REGION_RG'          space space  'X' 'X' space,
'TELEPHONE_RG'   'ZMX_SALES_ORDERS'  'TELEPHONE_RG'       space space  'X' 'X' space,
'MOB_NUMBER3'    'ZMX_SALES_ORDERS'  'MOB_NUMBER3'        space space  'X' 'X' space,
'EMAIL3'         'ZMX_SALES_ORDERS'  'EMAIL3'             space space  'X' 'X' space,
'TRANSPZONE_RG'  'ZMX_SALES_ORDERS'  'TRANSPZONE_RG'      space space  'X' 'X' space,
'TEXT_ID_NOTE'   'ZMX_SALES_ORDERS'  'TEXT_ID_NOTE'       space space  'X' 'X' space,
'LANGU_NOTE'     'ZMX_SALES_ORDERS'  'LANGU_NOTE'         space space  'X' 'X' space,
'TEXT_LINE_NOTE' 'ZMX_SALES_ORDERS'  'TEXT_LINE_NOTE'     space space  'X' 'X' space,
'TEXT_LINE_NOTE_1' 'ZMX_SALES_ORDERS'  'TEXT_LINE_NOTE_1'     space space  'X' 'X' space,
'TEXT_ID_SHIP'   'ZMX_SALES_ORDERS'  'TEXT_ID_SHIP'       space space  'X' 'X' space,
'LANGU_SHIP'     'ZMX_SALES_ORDERS'  'LANGU_SHIP'         space space  'X' 'X' space,
'TEXT_LINE_SHIP' 'ZMX_SALES_ORDERS'  'TEXT_LINE_SHIP'     space space  'X' 'X' space,
'TEXT_LINE_SHIP_1' 'ZMX_SALES_ORDERS'  'TEXT_LINE_SHIP_1'     space space  'X' 'X' space,

'ITM_NUMBER_1'     'ZMX_SALES_ORDERS'  'ITM_NUMBER_1'     'Condition item'    space  'X' 'X' space,
'COND_TYPE_1'      'ZMX_SALES_ORDERS'  'COND_TYPE_1'      'Condition type'    space  'X' 'X' space,
'COND_VALUE_1'     'ZMX_SALES_ORDERS'  'COND_VALUE_1'     'Condition rate'    space  'X' 'X' space,
'CURRENCY_1'       'ZMX_SALES_ORDERS'  'CURRENCY_1'       'Currency Key'      space  'X' 'X' space,
'CONDCOINHD_1'     'ZMX_SALES_ORDERS'  'CONDCOINHD_1'     'Condition counter' space  'X' 'X' space,

'PRICINGDATE'     'ZMX_SALES_ORDERS'  'PRICINGDATE'       space space  'X' 'X' space,
'INCOTERM'     'ZMX_SALES_ORDERS'  'INCOTERM'             space space  'X' 'X' space,
'FULLORDER'     'ZMX_SALES_ORDERS'  'FULLORDER'           space space  'X' 'X' space,

'NUM_INT'         'ZSDT_HD_WEBSO'  'NUM_INT'           space space  'X' 'X' space,
'BETWSTREETS'         'ZSDT_HD_WEBSO'  'BETWSTREETS'           space space  'X' 'X' space,
'HOMETYPE'         'ZSDT_HD_WEBSO' 'HOMETYPE'           space space  'X' 'X' space,
'DEL_FLOOR'         'ZSDT_HD_WEBSO'  'DEL_FLOOR'           space space  'X' 'X' space,
'STAIRS'         'ZSDT_HD_WEBSO'  'STAIRS'           space space  'X' 'X' space,
'ELEVATOR'         'ZSDT_HD_WEBSO'  'ELEVATOR'           space space  'X' 'X' space,
'PRIVATE_DISTR'         'ZSDT_HD_WEBSO'  'PRIVATE_DISTR'           space space  'X' 'X' space,
'ACCESS_DOCUM'         'ZSDT_HD_WEBSO'  'ACCESS_DOCUM'           space space  'X' 'X' space,
'DEL_SHIFT'         'ZSDT_HD_WEBSO'  'DEL_SHIFT'           space space  'X' 'X' 'X',
'DELIVERY_NEXTD'         'ZSDT_HD_WEBSO'  'DELIVERY_NEXTD'           space space  'X' 'X' 'X',
'SCND_FLOOR'         'ZSDT_HD_WEBSO'  'SCND_FLOOR'           space space  'X' 'X' space, " AGA 08/08/2018 CHG0087785
'THRDFIFHT_FLOOR'         'ZSDT_HD_WEBSO'  'THRDFIFHT_FLOOR'           space space  'X' 'X' space, " AGA 08/08/2018 CHG0087785

'FIXED_DAY'     'ZSDT_HD_WEBSO' 'FIXED_DAY'  space space  'X' 'X' space, "  GARCA59 CHG0093826 11/22/2018
'TIME_FRAME'    'ZSDT_HD_WEBSO' 'TIME_FRAME'  space space  'X' 'X' space, "  GARCA59 CHG0093826 11/22/2018
'WEEKND_DEL'    'ZSDT_HD_WEBSO' 'WEEKND_DEL'  space space  'X' 'X' space, "  GARCA59 CHG0093826 11/22/2018
'SPECIFIC_TIME' 'ZSDT_HD_WEBSO' 'SPECIFIC_TIME'  space space  'X' 'X' space, "  GARCA59 CHG0093826 11/22/2018
'UNPACK'        'ZSDT_HD_WEBSO' 'UNPACK'     space space  'X' 'X' space, "  GARCA59 CHG0093826 11/22/2018
'INSTALL'       'ZSDT_HD_WEBSO' 'INSTALL'   space space  'X' 'X' space, "  GARCA59 CHG0093826 11/22/2018
'PICKUP'        'ZSDT_HD_WEBSO' 'PICKUP'  space space  'X' 'X' space, "  GARCA59 CHG0093826 11/22/2018



'REQDI'         'ZSDT_CP_REQDLDT'  'REQDI'           space space  'X' 'X' space,
'REQDF'         'ZSDT_CP_REQDLDT'  'REQDF'           space space  'X' 'X' space,
*'ITM_NUMBER'     'ZMX_SALES_ORDERS'  'ITM_NUMBER'         space space  'X' 'X' space,
*'COND_TYPE'      'ZMX_SALES_ORDERS'  'COND_TYPE'          space space  'X' 'X' space,
*'COND_VALUE'     'ZMX_SALES_ORDERS'  'COND_VALUE'         space space  'X' 'X' space,
*'CURRENCY'       'ZMX_SALES_ORDERS'  'CURRENCY'           space space  'X' 'X' space,
*'CONDCOINHD'     'ZMX_SALES_ORDERS'  'CONDCOINHD'         space space  'X' 'X' space,

'STCD1'          'ZMX_SALES_ORDERS'  'STCD1'              space space  'X' 'X' space,
'STCD2'          'ZMX_SALES_ORDERS'  'STCD2'              space space  'X' 'X' space,
'STKZN'          'ZMX_SALES_ORDERS'  'STKZN'              space space  'X' 'X' space,
'DLV_BLOCK'      'ZMX_SALES_ORDERS'  'DLV_BLOCK'          space space  'X' 'X' space,
'MATERIAL'       'ZMX_SALES_ORDERS'  'MATERIAL'           space space  'X' 'X' space,
'PLANT'          'ZMX_SALES_ORDERS'  'PLANT'              space space  'X' 'X' space,
'STORE_LOC'      'ZMX_SALES_ORDERS'  'STORE_LOC'          space space  'X' 'X' space,
'TARGET_QTY'     'ZMX_SALES_ORDERS'  'TARGET_QTY'         space space  'X' 'X' space,
'PRICE_LIST'     'ZMX_SALES_ORDERS'  'PRICE_LIST'         space space  'X' 'X' space,
'FOLIO1'         'IT_ALV'  'FOLIO1'         'Folio 1' space  '' 'X' space,
'BANCO1'         'IT_ALV'  'BANCO1'         'Banco 1' space  '' 'X' space,
'MONTO1'         'VBAP'    'NETPR'          'Monto 1' space  '' 'X' space,
'FOLIO2'         'IT_ALV'  'FOLIO2'         'Folio 2' space  '' 'X' space,
'BANCO2'         'IT_ALV'  'BANCO2'         'Banco 2' space  '' 'X' space,
'MONTO2'         'VBAP'    'NETPR'          'Monto 2' space  '' 'X' space,
'FOLIO3'         'IT_ALV'  'FOLIO3'         'Folio 3' space  '' 'X' space,
'BANCO3'         'IT_ALV'  'BANCO3'         'Banco 3' space  '' 'X' space,
'MONTO3'         'VBAP'    'NETPR'          'Monto 3' space  '' 'X' space.
ENDFORM.                    "columnas
*&---------------------------------------------------------------------*
*&      Form  columnas no edicion
*&---------------------------------------------------------------------*
*       Genera las columnas del reporte
*----------------------------------------------------------------------*
FORM columnas_no_edicion .
  PERFORM agrega_columnas USING:
'TAW_ORDER'      'ZMX_SALES_ORDERS'  'TAW_ORDER'          space 'X'    ' ' 'X' space,
'LOCALFILE'      'ZMX_SALES_ORDERS'  'LOCALFILE'          space 'X'    ' ' 'X' 'X',
'VBELN_CREATE'   'ZMX_SALES_ORDERS'  'VBELN_CREATE'       space 'X'    ' ' 'X' space,
'STATUS'         'ZMX_SALES_ORDERS'  'STATUS'             space 'X'    ' ' 'X' space,
'SECUE'          'ZMX_SALES_ORDERS'  'SECUE'              space 'X'    ' ' 'X' space,
'DOC_TYPE'       'ZMX_SALES_ORDERS'  'DOC_TYPE'           space space  ' ' 'X' space,
'SALES_ORG'      'ZMX_SALES_ORDERS'  'SALES_ORG'          space space  ' ' 'X' space,
'DISTR_CHAN'     'ZMX_SALES_ORDERS'  'DISTR_CHAN'         space space  ' ' 'X' space,
'DIVISION'       'ZMX_SALES_ORDERS'  'DIVISION'           space space  ' ' 'X' space,
'SALES_GRP'      'ZMX_SALES_ORDERS'  'SALES_GRP'          space space  ' ' 'X' space,
'SALES_OFF'      'ZMX_SALES_ORDERS'  'SALES_OFF'          space space  ' ' 'X' space,
'REQ_DATE_H'     'ZMX_SALES_ORDERS'  'REQ_DATE_H'         space space  ' ' 'X' space,
'PURCH_DATE'     'ZMX_SALES_ORDERS'  'PURCH_DATE'         space space  ' ' 'X' space,
'PO_METHOD'      'ZMX_SALES_ORDERS'  'PO_METHOD'          space space  ' ' 'X' space,
'REF_1'          'ZMX_SALES_ORDERS'  'REF_1'              space space  ' ' 'X' space,
'PMNTTRMS'       'ZMX_SALES_ORDERS'  'PMNTTRMS'           space space  ' ' 'X' space,
'PURCH_NO_C'     'ZMX_SALES_ORDERS'  'PURCH_NO_C'         space space  ' ' 'X' space,
'DOC_DATE'       'ZMX_SALES_ORDERS'  'DOC_DATE'           space space  ' ' 'X' space,
'SHIP_COND'      'ZMX_SALES_ORDERS'  'SHIP_COND'          space space  ' ' 'X' space,
'ACCNT_ASGN'     'ZMX_SALES_ORDERS'  'ACCNT_ASGN'         space space  ' ' 'X' space,
'PARTN_ROLE_AG'  'ZMX_SALES_ORDERS'  'PARTN_ROLE_AG'      space space  ' ' 'X' space,
'PARTN_NUMB_AG'  'ZMX_SALES_ORDERS'  'PARTN_NUMB_AG'      space space  ' ' 'X' space,
'NAME_AG'        'ZMX_SALES_ORDERS'  'NAME_AG'            space space  ' ' 'X' space,
'NAME_2_AG'      'ZMX_SALES_ORDERS'  'NAME_2_AG'          space space  ' ' 'X' space,
'NAME_3_AG'      'ZMX_SALES_ORDERS'  'NAME_3_AG'          space space  ' ' 'X' space,
'NAME_4_AG'      'ZMX_SALES_ORDERS'  'NAME_4_AG'          space space  ' ' 'X' space,
'STREET_AG'      'ZMX_SALES_ORDERS'  'STREET_AG'          space space  ' ' 'X' space,
'HOUSE_NUM1'     'ZMX_SALES_ORDERS'  'HOUSE_NUM1'         space space  ' ' 'X' space,
'COUNTRY_AG'     'ZMX_SALES_ORDERS'  'COUNTRY_AG'         space space  ' ' 'X' space,
'POSTL_CODE_AG'  'ZMX_SALES_ORDERS'  'POSTL_CODE_AG'      space space  ' ' 'X' space,
'CITY_AG'        'ZMX_SALES_ORDERS'  'CITY_AG'            space space  ' ' 'X' space,
'DISTRICT_AG'    'ZMX_SALES_ORDERS'  'DISTRICT_AG'        space space  ' ' 'X' space,
'REGION_AG'      'ZMX_SALES_ORDERS'  'REGION_AG'          space space  ' ' 'X' space,
'TELEPHONE_AG'   'ZMX_SALES_ORDERS'  'TELEPHONE_AG'       space space  ' ' 'X' space,
'MOB_NUMBER'     'ZMX_SALES_ORDERS'  'MOB_NUMBER'         space space  ' ' 'X' space,
'EMAIL'          'ZMX_SALES_ORDERS'  'EMAIL'              space space  ' ' 'X' space,
'TRANSPZONE_AG'  'ZMX_SALES_ORDERS'  'TRANSPZONE_AG'      space space  ' ' 'X' space,
'PARTN_ROLE_WE'  'ZMX_SALES_ORDERS'  'PARTN_ROLE_WE'      space space  ' ' 'X' space,
'PARTN_NUMB_WE'  'ZMX_SALES_ORDERS'  'PARTN_NUMB_WE'      space space  ' ' 'X' space,
'NAME_WE'        'ZMX_SALES_ORDERS'  'NAME_WE'            space space  ' ' 'X' space,
'NAME_2_WE'      'ZMX_SALES_ORDERS'  'NAME_2_WE'          space space  ' ' 'X' space,
'NAME_3_WE'      'ZMX_SALES_ORDERS'  'NAME_3_WE'          space space  ' ' 'X' space,
'NAME_4_WE'      'ZMX_SALES_ORDERS'  'NAME_4_WE'          space space  ' ' 'X' space,
'STREET_WE'      'ZMX_SALES_ORDERS'  'STREET_WE'          space space  ' ' 'X' space,
'HOUSE_NUM2'     'ZMX_SALES_ORDERS'  'HOUSE_NUM2'         space space  ' ' 'X' space,
'COUNTRY_WE'     'ZMX_SALES_ORDERS'  'COUNTRY_WE'         space space  ' ' 'X' space,
'POSTL_CODE_WE'  'ZMX_SALES_ORDERS'  'POSTL_CODE_WE'      space space  ' ' 'X' space,
'CITY_WE'        'ZMX_SALES_ORDERS'  'CITY_WE'            space space  ' ' 'X' space,
'DISTRICT_WE'    'ZMX_SALES_ORDERS'  'DISTRICT_WE'        space space  ' ' 'X' space,
'REGION_WE'      'ZMX_SALES_ORDERS'  'REGION_WE'          space space  ' ' 'X' space,
'TELEPHONE_WE'   'ZMX_SALES_ORDERS'  'TELEPHONE_WE'       space space  ' ' 'X' space,
'MOB_NUMBER2'    'ZMX_SALES_ORDERS'  'MOB_NUMBER2'        space space  ' ' 'X' space,
'EMAIL2'         'ZMX_SALES_ORDERS'  'EMAIL2'             space space  ' ' 'X' space,
'TRANSPZONE_WE'  'ZMX_SALES_ORDERS'  'TRANSPZONE_WE'      space space  ' ' 'X' space,
'PARTN_ROLE_RG'  'ZMX_SALES_ORDERS'  'PARTN_ROLE_RG'      space space  ' ' 'X' space,
'PARTN_NUMB_RG'  'ZMX_SALES_ORDERS'  'PARTN_NUMB_RG'      space space  ' ' 'X' space,
'NAME_RG'        'ZMX_SALES_ORDERS'  'NAME_RG'            space space  ' ' 'X' space,
'NAME_2_RG'      'ZMX_SALES_ORDERS'  'NAME_2_RG'          space space  ' ' 'X' space,
'NAME_3_RG'      'ZMX_SALES_ORDERS'  'NAME_3_RG'          space space  ' ' 'X' space,
'NAME_4_RG'      'ZMX_SALES_ORDERS'  'NAME_4_RG'          space space  ' ' 'X' space,
'STREET_RG'      'ZMX_SALES_ORDERS'  'STREET_RG'          space space  ' ' 'X' space,
'HOUSE_NUM3'     'ZMX_SALES_ORDERS'  'HOUSE_NUM3'         space space  ' ' 'X' space,
'COUNTRY_RG'     'ZMX_SALES_ORDERS'  'COUNTRY_RG'         space space  ' ' 'X' space,
'POSTL_CODE_RG'  'ZMX_SALES_ORDERS'  'POSTL_CODE_RG'      space space  ' ' 'X' space,
'CITY_RG'        'ZMX_SALES_ORDERS'  'CITY_RG'            space space  ' ' 'X' space,
'DISTRICT_RG'    'ZMX_SALES_ORDERS'  'DISTRICT_RG'        space space  ' ' 'X' space,
'REGION_RG'      'ZMX_SALES_ORDERS'  'REGION_RG'          space space  ' ' 'X' space,
'TELEPHONE_RG'   'ZMX_SALES_ORDERS'  'TELEPHONE_RG'       space space  ' ' 'X' space,
'MOB_NUMBER3'    'ZMX_SALES_ORDERS'  'MOB_NUMBER3'        space space  ' ' 'X' space,
'EMAIL3'         'ZMX_SALES_ORDERS'  'EMAIL3'             space space  ' ' 'X' space,
'TRANSPZONE_RG'  'ZMX_SALES_ORDERS'  'TRANSPZONE_RG'      space space  ' ' 'X' space,
'TEXT_ID_NOTE'   'ZMX_SALES_ORDERS'  'TEXT_ID_NOTE'       space space  ' ' 'X' space,
'LANGU_NOTE'     'ZMX_SALES_ORDERS'  'LANGU_NOTE'         space space  ' ' 'X' space,
'TEXT_LINE_NOTE' 'ZMX_SALES_ORDERS'  'TEXT_LINE_NOTE'     space space  ' ' 'X' space,
'TEXT_LINE_NOTE_1' 'ZMX_SALES_ORDERS'  'TEXT_LINE_NOTE_1'     space space  ' ' 'X' space,
'TEXT_ID_SHIP'   'ZMX_SALES_ORDERS'  'TEXT_ID_SHIP'       space space  ' ' 'X' space,
'LANGU_SHIP'     'ZMX_SALES_ORDERS'  'LANGU_SHIP'         space space  ' ' 'X' space,
'TEXT_LINE_SHIP' 'ZMX_SALES_ORDERS'  'TEXT_LINE_SHIP'     space space  ' ' 'X' space,
'TEXT_LINE_SHIP_1' 'ZMX_SALES_ORDERS'  'TEXT_LINE_SHIP_1'     space space  ' ' 'X' space,

'ITM_NUMBER_1'     'ZMX_SALES_ORDERS'  'ITM_NUMBER_1'     'Condition item'    space  ' ' 'X' space,
'COND_TYPE_1'      'ZMX_SALES_ORDERS'  'COND_TYPE_1'      'Condition type'    space  ' ' 'X' space,
'COND_VALUE_1'     'ZMX_SALES_ORDERS'  'COND_VALUE_1'     'Condition rate'    space  ' ' 'X' space,
'CURRENCY_1'       'ZMX_SALES_ORDERS'  'CURRENCY_1'       'Currency Key'      space  ' ' 'X' space,
'CONDCOINHD_1'     'ZMX_SALES_ORDERS'  'CONDCOINHD_1'     'Condition counter' space  ' ' 'X' space,

'PRICINGDATE'     'ZMX_SALES_ORDERS'  'PRICINGDATE'       space space  ' ' 'X' space,
'INCOTERM'     'ZMX_SALES_ORDERS'  'INCOTERM'             space space  ' ' 'X' space,
'FULLORDER'     'ZMX_SALES_ORDERS'  'FULLORDER'           space space  ' ' 'X' space,

'NUM_INT'         'ZSDT_HD_WEBSO'  'NUM_INT'           space space  ' ' 'X' space,
'BETWSTREETS'         'ZSDT_HD_WEBSO'  'BETWSTREETS'           space space  ' ' 'X' space,
'HOMETYPE'         'ZSDT_HD_WEBSO'  'HOMETYPE'           space space  ' ' 'X' space,
'DEL_FLOOR'         'ZSDT_HD_WEBSO'  'DEL_FLOOR'           space space  ' ' 'X' space,
'STAIRS'         'ZSDT_HD_WEBSO'  'STAIRS'           space space  ' ' 'X' space,
'ELEVATOR'         'ZSDT_HD_WEBSO'  'ELEVATOR'           space space  ' ' 'X' space,
'PRIVATE_DISTR'         'ZSDT_HD_WEBSO'  'PRIVATE_DISTR'           space space  ' ' 'X' space,
'ACCESS_DOCUM'         'ZSDT_HD_WEBSO'  'ACCESS_DOCUM'           space space  ' ' 'X' space,
'DEL_SHIFT'         'ZSDT_HD_WEBSO'  'DEL_SHIFT'           space space  ' ' 'X' 'X',
'DELIVERY_NEXTD'         'ZSDT_HD_WEBSO'  'DELIVERY_NEXTD'           space space  ' ' 'X' 'X',

'SCND_FLOOR'         'ZSDT_HD_WEBSO'  'SCND_FLOOR'           space space  ' ' 'X' space, " AGA 08/08/2018 CHG0087785
'THRDFIFHT_FLOOR'         'ZSDT_HD_WEBSO'  'THRDFIFHT_FLOOR'           space space  ' ' 'X' space, " AGA 08/08/2018 CHG0087785

'FIXED_DAY'     'ZSDT_HD_WEBSO' 'FIXED_DAY'  space space  ' ' 'X' space, "  GARCA59 CHG0093826 11/22/2018
'TIME_FRAME'    'ZSDT_HD_WEBSO' 'TIME_FRAME'  space space  ' ' 'X' space, "  GARCA59 CHG0093826 11/22/2018
'WEEKND_DEL'    'ZSDT_HD_WEBSO' 'WEEKND_DEL'  space space  ' ' 'X' space, "  GARCA59 CHG0093826 11/22/2018
'SPECIFIC_TIME' 'ZSDT_HD_WEBSO' 'SPECIFIC_TIME'  space space  ' ' 'X' space, "  GARCA59 CHG0093826 11/22/2018
'UNPACK'        'ZSDT_HD_WEBSO' 'UNPACK'     space space  ' ' 'X' space, "  GARCA59 CHG0093826 11/22/2018
'INSTALL'       'ZSDT_HD_WEBSO' 'INSTALL'   space space  ' ' 'X' space, "  GARCA59 CHG0093826 11/22/2018
'PICKUP'        'ZSDT_HD_WEBSO' 'PICKUP'  space space  ' ' 'X' space, "  GARCA59 CHG0093826 11/22/2018


'REQDI'         'ZSDT_CP_REQDLDT'  'REQDI'           space space  ' ' 'X' space,
'REQDF'         'ZSDT_CP_REQDLDT'  'REQDF'           space space  ' ' 'X' space,

*'ITM_NUMBER'     'ZMX_SALES_ORDERS'  'ITM_NUMBER'         space space  'X' 'X' space,
*'COND_TYPE'      'ZMX_SALES_ORDERS'  'COND_TYPE'          space space  'X' 'X' space,
*'COND_VALUE'     'ZMX_SALES_ORDERS'  'COND_VALUE'         space space  'X' 'X' space,
*'CURRENCY'       'ZMX_SALES_ORDERS'  'CURRENCY'           space space  'X' 'X' space,
*'CONDCOINHD'     'ZMX_SALES_ORDERS'  'CONDCOINHD'         space space  'X' 'X' space,

'STCD1'          'ZMX_SALES_ORDERS'  'STCD1'              space space  ' ' 'X' space,
'STCD2'          'ZMX_SALES_ORDERS'  'STCD2'              space space  ' ' 'X' space,
'STKZN'          'ZMX_SALES_ORDERS'  'STKZN'              space space  ' ' 'X' space,
'DLV_BLOCK'      'ZMX_SALES_ORDERS'  'DLV_BLOCK'          space space  ' ' 'X' space,
'MATERIAL'       'ZMX_SALES_ORDERS'  'MATERIAL'           space space  ' ' 'X' space,
'PLANT'          'ZMX_SALES_ORDERS'  'PLANT'              space space  ' ' 'X' space,
'STORE_LOC'      'ZMX_SALES_ORDERS'  'STORE_LOC'          space space  ' ' 'X' space,
'TARGET_QTY'     'ZMX_SALES_ORDERS'  'TARGET_QTY'         space space  ' ' 'X' space,
'PRICE_LIST'     'ZMX_SALES_ORDERS'  'PRICE_LIST'         space space  ' ' 'X' space,
'FOLIO1'         'IT_ALV'  'FOLIO1'         'Folio 1' space  '' 'X' space,
'BANCO1'         'IT_ALV'  'BANCO1'         'Banco 1' space  '' 'X' space,
'MONTO1'         'VBAP'    'NETPR'          'Monto 1' space  '' 'X' space,
'FOLIO2'         'IT_ALV'  'FOLIO2'         'Folio 2' space  '' 'X' space,
'BANCO2'         'IT_ALV'  'BANCO2'         'Banco 2' space  '' 'X' space,
'MONTO2'         'VBAP'    'NETPR'          'Monto 2' space  '' 'X' space,
'FOLIO3'         'IT_ALV'  'FOLIO3'         'Folio 3' space  '' 'X' space,
'BANCO3'         'IT_ALV'  'BANCO3'         'Banco 3' space  '' 'X' space,
'MONTO3'         'VBAP'    'NETPR'          'Monto 3' space  '' 'X' space.
ENDFORM.                    "columnas no edicion
*&---------------------------------------------------------------------*
*&      Form  agrega_columnas
*&---------------------------------------------------------------------*
*       Agrega columnas al reporte
*----------------------------------------------------------------------*
FORM agrega_columnas USING nombre
                           tabla
                           campo
                           texto    TYPE c
                           llave    TYPE c
                           x_edit   TYPE c
                           x_input  TYPE c
                           x_no_out TYPE c.

  DATA: st_cat TYPE slis_fieldcat_alv.

  DESCRIBE TABLE it_fldcat.

  st_cat-col_pos       = sy-tfill + 1.
  st_cat-fieldname     = nombre.
  st_cat-ref_fieldname = campo.
  st_cat-ref_tabname   = tabla.
  st_cat-seltext_l     = texto.
  st_cat-seltext_m     = texto.
  st_cat-seltext_s     = texto.
  st_cat-key           = llave.
  st_cat-edit          = x_edit.
  st_cat-input         = x_input.
  st_cat-no_out        = x_no_out.

  IF texto IS NOT INITIAL.
    st_cat-ddictxt = 'L'.
  ENDIF.

  IF nombre = 'FOLIO1' OR nombre = 'BANCO1' OR
     nombre = 'FOLIO2' OR nombre = 'BANCO2' OR
     nombre = 'FOLIO3' OR nombre = 'BANCO3'.
    st_cat-outputlen = '28'.
  ENDIF.

  IF nombre = 'MONTO1'.
    st_cat-reptext_ddic = 'Monto1'.
  ENDIF.
  IF nombre = 'MONTO2'.
    st_cat-reptext_ddic = 'Monto2'.
  ENDIF.
    IF nombre = 'MONTO3'.
    st_cat-reptext_ddic = 'Monto3'.
  ENDIF.

  APPEND st_cat TO it_fldcat.

ENDFORM.                    " agrega_columnas
*&---------------------------------------------------------------------*
*&      Form  ALV_EXITS_MAKE
*&---------------------------------------------------------------------*
FORM alv_exits_make CHANGING rt_event_exit TYPE slis_t_event_exit.
  DATA: wa_event_exit TYPE slis_event_exit.

*... okcode = SELECCIONA TODO
  wa_event_exit-ucomm  = '&ALL'.
  wa_event_exit-after = 'X'.
*  wa_event_exit-before = 'X'.
  APPEND wa_event_exit TO rt_event_exit.
  CLEAR wa_event_exit.

*... okcode = DESMARCA TODO
  wa_event_exit-ucomm  = '&SAL'.
  wa_event_exit-after = 'X'.
  APPEND wa_event_exit TO rt_event_exit.
  CLEAR wa_event_exit.

  wa_event_exit-ucomm  = '&F03'.
*  wa_event_exit-after = 'X'.
  wa_event_exit-before = 'X'.
  APPEND wa_event_exit TO rt_event_exit.
  CLEAR wa_event_exit.

  wa_event_exit-ucomm  = '&F12'.
*  wa_event_exit-after = 'X'.
  wa_event_exit-before = 'X'.
  APPEND wa_event_exit TO rt_event_exit.
  CLEAR wa_event_exit.

  wa_event_exit-ucomm  = '&F15'.
*  wa_event_exit-after = 'X'.
  wa_event_exit-before = 'X'.
  APPEND wa_event_exit TO rt_event_exit.
  CLEAR wa_event_exit.

  wa_event_exit-ucomm  = '&IC1'.
*  wa_event_exit-after = 'X'.
  wa_event_exit-before = 'X'.
  APPEND wa_event_exit TO rt_event_exit.
  CLEAR wa_event_exit.

ENDFORM.                    "alv_exits_make

*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       Manejo de comandos
*----------------------------------------------------------------------*
*   >>  r_ucomm        Comando
*   >>  rs_selfield    Informacion
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  DATA: z_taw_order    LIKE zmx_sales_orders-taw_order,
        x_conta        TYPE i,
        x_pag          TYPE i,
        x_lin          TYPE i,
        lv_hd_new_serv TYPE flag.


  rs_selfield-refresh    = 'X'.
  rs_selfield-col_stable = 'X'.
  rs_selfield-row_stable = 'X'.
*
*
*  CASE r_ucomm.
**SALIDA DEL PROCESO
*    WHEN '&F03' OR '&F12' OR'&F15' OR c_enter OR '&SAVE'.
*      PERFORM GRABA.
*      EXIT.
*
*  ENDCASE.

*DOBLE CLIK
  CASE r_ucomm.
    WHEN '&IC1'.
*PRESENTA SALES ORDERS
      IF rs_selfield-fieldname = 'VBELN_CREATE'.
        it_vbeln = rs_selfield-value.

        IF it_vbeln IS NOT INITIAL.
          SET PARAMETER ID: 'AUN' FIELD it_vbeln.
          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
        ENDIF.

      ENDIF.


      IF rs_selfield-fieldname = 'STATUS'.
        it_status = rs_selfield-value.

        READ TABLE it_alv INDEX rs_selfield-tabindex.
        IF sy-subrc = 0.

          IF it_status = 'ERROR'.
            SUBMIT zmx_create_sales_orders_error
              WITH so_tawo = it_alv-taw_order
              AND RETURN.
          ENDIF.

        ENDIF.
      ENDIF.

    WHEN '&DATA_SAVE' OR '&SAVE'.

      PERFORM f_val_hd_new_serv
        CHANGING lv_hd_new_serv.

      LOOP AT it_alv WHERE status = 'ERROR'.
        ws_tabix = sy-tabix.

        AT NEW taw_order.
          READ TABLE it_alv INDEX ws_tabix.
          MOVE-CORRESPONDING it_alv TO it_zmx_sales_orders_paso.

          REFRESH w_field_paso.

          CLEAR   w_field_paso.
          w_field_paso         =  it_zmx_sales_orders_paso-doc_type .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso         =  it_zmx_sales_orders_paso-sales_org  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-distr_chan .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso         =  it_zmx_sales_orders_paso-division .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso         =  it_zmx_sales_orders_paso-sales_grp  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso         =  it_zmx_sales_orders_paso-sales_off  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-req_date_h .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-purch_date .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso         =  it_zmx_sales_orders_paso-po_method  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso         =  it_zmx_sales_orders_paso-ref_1  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso         =  it_zmx_sales_orders_paso-pmnttrms .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso          = it_zmx_sales_orders_paso-purch_no_c .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso         =  it_zmx_sales_orders_paso-doc_date .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso         =  it_zmx_sales_orders_paso-ship_cond  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso         =  it_zmx_sales_orders_paso-accnt_asgn.
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-partn_role_ag  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-partn_numb_ag  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso         =  it_zmx_sales_orders_paso-name_ag  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso          = it_zmx_sales_orders_paso-name_2_ag  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso          = it_zmx_sales_orders_paso-name_3_ag  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso          = it_zmx_sales_orders_paso-name_4_ag  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso          = it_zmx_sales_orders_paso-street_ag  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso          = it_zmx_sales_orders_paso-house_num1  .  " AGA CHG0085456 07/13/18
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso          = it_zmx_sales_orders_paso-country_ag .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-postl_code_ag  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso          = it_zmx_sales_orders_paso-city_ag  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-district_ag  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-region_ag  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-telephone_ag .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-mob_number . " AGA CHG0085456 07/13/18
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-email . " AGA CHG0085456 07/13/18
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-transpzone_ag  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-partn_role_we  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-partn_numb_we  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso          = it_zmx_sales_orders_paso-name_we  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso          = it_zmx_sales_orders_paso-name_2_we  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-name_3_we  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso          = it_zmx_sales_orders_paso-name_4_we  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-street_we  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-house_num2  . " AGA CHG0085456 07/13/18
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-num_int  . " AGA CHG0085456 07/13/18
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-betwstreets  . " AGA CHG0085456 07/13/18
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-hometype  . " AGA CHG0085456 07/13/18
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-del_floor  . " AGA CHG0085456 07/13/18
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-stairs. " AGA CHG0085456 07/13/18
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-elevator . " AGA CHG0085456 07/13/18
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-private_distr  . " AGA CHG0085456 07/13/18
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-access_docum  . " AGA CHG0085456 07/13/18
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-country_we .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-postl_code_we  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso          = it_zmx_sales_orders_paso-city_we  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso          = it_zmx_sales_orders_paso-district_we  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso          = it_zmx_sales_orders_paso-region_we  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-telephone_we .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-mob_number2 .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-email2 .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-transpzone_we  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-partn_role_rg  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-partn_numb_rg  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso          = it_zmx_sales_orders_paso-name_rg  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-name_2_rg  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-name_3_rg  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-name_4_rg  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-street_rg  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-house_num3  . " AGA CHG0085456 07/13/18
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-country_rg .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-postl_code_rg  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso          = it_zmx_sales_orders_paso-city_rg  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-district_rg  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-region_rg  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-telephone_rg .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-mob_number3 .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-email3 .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-transpzone_rg  .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-text_id_note .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-langu_note .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          CONCATENATE it_zmx_sales_orders_paso-text_line_note
                      it_zmx_sales_orders_paso-text_line_note_1
                 INTO w_field_paso.

*         w_field_paso        = it_ZMX_SALES_ORDERS_PASO-TEXT_LINE_NOTE .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-text_id_ship .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso        = it_zmx_sales_orders_paso-langu_ship .
          APPEND w_field_paso.
          CLEAR   w_field_paso.


          CONCATENATE it_zmx_sales_orders_paso-text_line_ship
                      it_zmx_sales_orders_paso-text_line_ship_1
                 INTO w_field_paso.

*         w_field_paso      =   it_ZMX_SALES_ORDERS_PASO-TEXT_LINE_SHIP .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso      =   it_zmx_sales_orders_paso-itm_number_1 .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso      =   it_zmx_sales_orders_paso-cond_type_1 .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso      =   it_zmx_sales_orders_paso-cond_value_1.
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso      =   it_zmx_sales_orders_paso-currency_1 .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso      =   it_zmx_sales_orders_paso-condcoinhd_1.
          APPEND w_field_paso.
          CLEAR   w_field_paso.

**          w_field_paso      =   it_ZMX_SALES_ORDERS_PASO-ITM_NUMBER .
**          append w_field_paso.
**          clear   w_field_paso.
**
**          w_field_paso      =   it_ZMX_SALES_ORDERS_PASO-COND_TYPE  .
**          append w_field_paso.
**          clear   w_field_paso.
**
**          COND_VALUE_C = it_ZMX_SALES_ORDERS_PASO-COND_VALUE.
**
**          SHIFT COND_VALUE_C LEFT DELETING LEADING ' '.
**
**          w_field_paso      =   COND_VALUE_C.
**          append w_field_paso.
**          clear   w_field_paso.
**
**          w_field_paso      =   it_ZMX_SALES_ORDERS_PASO-CURRENCY .
**          append w_field_paso.
**          clear   w_field_paso.
**
**          w_field_paso      =   it_ZMX_SALES_ORDERS_PASO-CONDCOINHD.
**          append w_field_paso.
**          clear   w_field_paso.

          w_field_paso      =   it_zmx_sales_orders_paso-stcd1.
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso      =   it_zmx_sales_orders_paso-stcd2.
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso      =   it_zmx_sales_orders_paso-stkzn.
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso      =   it_zmx_sales_orders_paso-dlv_block.
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso      =   space. " AGA CHG0085456 07/13/18 Del Date I
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso      =   space. " AGA CHG0085456 07/13/18  Del Date F
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso      =   it_zmx_sales_orders_paso-pricingdate. " AGA CHG0085456 07/13/18
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso      =   it_zmx_sales_orders_paso-incoterm. " AGA CHG0085456 07/13/18
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso      =   it_zmx_sales_orders_paso-fullorder. " AGA CHG0085456 07/13/18
          APPEND w_field_paso.
          CLEAR   w_field_paso.

        ENDAT.


        CLEAR   w_field_paso.
        w_field_paso         =      it_alv-material .
        APPEND w_field_paso.
        CLEAR   w_field_paso.

        w_field_paso         =      it_alv-plant  .
        APPEND w_field_paso.
        CLEAR   w_field_paso.

        w_field_paso         =      it_alv-store_loc  .
        APPEND w_field_paso.
        CLEAR   w_field_paso.

        CLEAR: target_qty_n.
        target_qty_n = it_alv-target_qty.
        SHIFT target_qty_n LEFT DELETING LEADING '0'.

        w_field_paso         =      target_qty_n  .
        APPEND w_field_paso.
        CLEAR   w_field_paso.

        w_field_paso         =      it_alv-price_list.
        APPEND w_field_paso.

        IF lv_hd_new_serv IS NOT INITIAL.

          w_field_paso         =      space. " Cond Type (already in the conditions)
          APPEND w_field_paso.

          w_field_paso         =      space . " Cond Value (already in the conditions)
          APPEND w_field_paso.


          w_field_paso         =      space . " Cond Currency (already in the conditions)
          APPEND w_field_paso.

*        BEGIN GARCA59 CHG0093826 11/22/2018
          w_field_paso          = it_alv-top_floors.
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso         =      it_zmx_sales_orders_paso-fixed_day . "
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          IF it_zmx_sales_orders_paso-time_frame IS NOT INITIAL.
*            CONCATENATE it_zmx_sales_orders_paso-time_frame(2)
*                        it_zmx_sales_orders_paso-time_frame+2(2)
*                        it_zmx_sales_orders_paso-time_frame+4(2)
*                   INTO w_field_paso
*              SEPARATED BY ':'.
            w_field_paso         =      it_zmx_sales_orders_paso-time_frame.
          ENDIF.

          APPEND w_field_paso.
          CLEAR   w_field_paso.

          w_field_paso         =      it_zmx_sales_orders_paso-weeknd_del .
          APPEND w_field_paso.
          CLEAR   w_field_paso.

          IF it_zmx_sales_orders_paso-specific_time IS NOT INITIAL.
*            CONCATENATE it_zmx_sales_orders_paso-specific_time(2)
*                        it_zmx_sales_orders_paso-specific_time+2(2)
*                        it_zmx_sales_orders_paso-specific_time+4(2)
*                   INTO w_field_paso
*              SEPARATED BY ':'.
            w_field_paso         =      it_zmx_sales_orders_paso-specific_time.
          ENDIF.

          APPEND w_field_paso.
          CLEAR   w_field_paso.


          w_field_paso         =      it_zmx_sales_orders_paso-pickup.
          APPEND w_field_paso.
          CLEAR   w_field_paso.

        ENDIF.

        w_field_paso  =  it_zmx_sales_orders_paso-delivery_nextd.
        APPEND w_field_paso.
        CLEAR   w_field_paso.

        w_field_paso  =  it_zmx_sales_orders_paso-del_shift.
        APPEND w_field_paso.
        CLEAR   w_field_paso.

*        END GARCA59 CHG0093826 11/22/2018

*$smart (I) 12/11/16 - #723 Avoid data transfer between database and internal table using loops. Use INTO
*$smart (I) 12/11/16 - #723 TABLE and FROM TABLE additions instead. (no work area access) (M)

        UPDATE zmx_sales_orders   SET doc_type         =  it_zmx_sales_orders_paso-doc_type
                                      sales_org        =  it_zmx_sales_orders_paso-sales_org
                                      distr_chan  = it_zmx_sales_orders_paso-distr_chan
                                      division         =  it_zmx_sales_orders_paso-division
                                      sales_grp        =  it_zmx_sales_orders_paso-sales_grp
                                      sales_off        =  it_zmx_sales_orders_paso-sales_off
                                      req_date_h  = it_zmx_sales_orders_paso-req_date_h
                                      purch_date  = it_zmx_sales_orders_paso-purch_date
                                      po_method        =  it_zmx_sales_orders_paso-po_method
                                      ref_1          =  it_zmx_sales_orders_paso-ref_1
                                      pmnttrms         =  it_zmx_sales_orders_paso-pmnttrms
                                      purch_no_c  = it_zmx_sales_orders_paso-purch_no_c
                                      doc_date         =  it_zmx_sales_orders_paso-doc_date
                                      ship_cond          =  it_zmx_sales_orders_paso-ship_cond
                                      accnt_asgn          =	it_zmx_sales_orders_paso-accnt_asgn
                                      partn_role_ag	=	it_zmx_sales_orders_paso-partn_role_ag
                                      partn_numb_ag	=	it_zmx_sales_orders_paso-partn_numb_ag
                                      name_ag        =  it_zmx_sales_orders_paso-name_ag
                                      name_2_ag	        =	it_zmx_sales_orders_paso-name_2_ag
                                      name_3_ag	        =	it_zmx_sales_orders_paso-name_3_ag
                                      name_4_ag	        =	it_zmx_sales_orders_paso-name_4_ag
                                      street_ag	        =	it_zmx_sales_orders_paso-street_ag
                                      house_num1        =   it_zmx_sales_orders_paso-house_num1 " AGA CHG0085456 07/13/18
                                      country_ag  = it_zmx_sales_orders_paso-country_ag
                                      postl_code_ag	=	it_zmx_sales_orders_paso-postl_code_ag
                                      city_ag	        =	it_zmx_sales_orders_paso-city_ag
                                      district_ag	=	it_zmx_sales_orders_paso-district_ag
                                      region_ag      	=	it_zmx_sales_orders_paso-region_ag
                                      telephone_ag  = it_zmx_sales_orders_paso-telephone_ag
                                      mob_number    = it_zmx_sales_orders_paso-mob_number " AGA
                                      email         = it_zmx_sales_orders_paso-email " AGA
                                      transpzone_ag	=	it_zmx_sales_orders_paso-transpzone_ag
                                      partn_role_we	=	it_zmx_sales_orders_paso-partn_role_we
                                      partn_numb_we	=	it_zmx_sales_orders_paso-partn_numb_we
                                      name_we	        =	it_zmx_sales_orders_paso-name_we
                                      name_2_we	        =	it_zmx_sales_orders_paso-name_2_we
                                      name_3_we      	=	it_zmx_sales_orders_paso-name_3_we
                                      name_4_we	        =	it_zmx_sales_orders_paso-name_4_we
                                      street_we	      =	it_zmx_sales_orders_paso-street_we
                                      house_num2      = it_zmx_sales_orders_paso-house_num2  " AGA CHG0085456 07/13/18
                                      country_we  = it_zmx_sales_orders_paso-country_we
                                      postl_code_we	=	it_zmx_sales_orders_paso-postl_code_we
                                      city_we	        =	it_zmx_sales_orders_paso-city_we
                                      district_we	=	it_zmx_sales_orders_paso-district_we
                                      region_we	        =	it_zmx_sales_orders_paso-region_we
                                      telephone_we  = it_zmx_sales_orders_paso-telephone_we
                                      mob_number2   = it_zmx_sales_orders_paso-mob_number2  " AGA CHG0085456 07/13/18
                                      email2        = it_zmx_sales_orders_paso-email2  " AGA CHG0085456 07/13/18
                                      transpzone_we	=	it_zmx_sales_orders_paso-transpzone_we
                                      partn_role_rg	=	it_zmx_sales_orders_paso-partn_role_rg
                                      partn_numb_rg	=	it_zmx_sales_orders_paso-partn_numb_rg
                                      name_rg	        =	it_zmx_sales_orders_paso-name_rg
                                      name_2_rg      	=	it_zmx_sales_orders_paso-name_2_rg
                                      name_3_rg	      =	it_zmx_sales_orders_paso-name_3_rg
                                      name_4_rg	      =	it_zmx_sales_orders_paso-name_4_rg
                                      street_rg	      =	it_zmx_sales_orders_paso-street_rg
                                      house_num3      = it_zmx_sales_orders_paso-house_num3 " AGA CHG0085456 07/13/18
                                      country_rg  = it_zmx_sales_orders_paso-country_rg
                                      postl_code_rg	=	it_zmx_sales_orders_paso-postl_code_rg
                                      city_rg	        =	it_zmx_sales_orders_paso-city_rg
                                      district_rg	=	it_zmx_sales_orders_paso-district_rg
                                      region_rg	      =	it_zmx_sales_orders_paso-region_rg
                                      telephone_rg  = it_zmx_sales_orders_paso-telephone_rg
                                      mob_number3   = it_zmx_sales_orders_paso-mob_number3 " AGA CHG0085456 07/13/18
                                      email3        = it_zmx_sales_orders_paso-email3 " AGA CHG0085456 07/13/18
                                      transpzone_rg	=	it_zmx_sales_orders_paso-transpzone_rg
                                      text_id_note  = it_zmx_sales_orders_paso-text_id_note
                                      langu_note  = it_zmx_sales_orders_paso-langu_note

                                      text_line_note  = it_zmx_sales_orders_paso-text_line_note
                                      text_line_note_1  = it_zmx_sales_orders_paso-text_line_note_1

                                      text_id_ship  = it_zmx_sales_orders_paso-text_id_ship
                                      langu_ship  = it_zmx_sales_orders_paso-langu_ship

                                      text_line_ship  =   it_zmx_sales_orders_paso-text_line_ship
                                      text_line_ship_1  =   it_zmx_sales_orders_paso-text_line_ship_1

                                      itm_number         =    it_zmx_sales_orders_paso-itm_number
                                      cond_type        =    it_zmx_sales_orders_paso-cond_type
                                      cond_value         =    it_zmx_sales_orders_paso-cond_value
                                      currency         =    it_zmx_sales_orders_paso-currency
                                      condcoinhd         =    it_zmx_sales_orders_paso-condcoinhd

                                      itm_number_1         =    it_zmx_sales_orders_paso-itm_number_1
                                      cond_type_1        =    it_zmx_sales_orders_paso-cond_type_1
                                      cond_value_1         =    it_zmx_sales_orders_paso-cond_value_1
                                      currency_1         =    it_zmx_sales_orders_paso-currency_1
                                      condcoinhd_1         =    it_zmx_sales_orders_paso-condcoinhd_1

                                      stcd1                =    it_zmx_sales_orders_paso-stcd1
                                      stcd2                =    it_zmx_sales_orders_paso-stcd2
                                      stkzn                =    it_zmx_sales_orders_paso-stkzn
                                      dlv_block            =    it_zmx_sales_orders_paso-dlv_block
                                      material         =      it_alv-material
                                      plant            =      it_alv-plant
                                      store_loc        =      it_alv-store_loc
                                      target_qty       =      it_alv-target_qty
                                      price_list       =      it_alv-price_list
                                      pricingdate      =      it_zmx_sales_orders_paso-pricingdate " AGA CHG0085456 07/13/18
                                      incoterm         =      it_zmx_sales_orders_paso-incoterm " AGA CHG0085456 07/13/18
                                      fullorder        =      it_zmx_sales_orders_paso-fullorder " AGA CHG0085456 07/13/18

                                WHERE taw_order     = it_alv-taw_order
                                  AND localfile     = it_alv-localfile
                                  AND vbeln_create  = it_alv-vbeln_create
                                  AND status        = it_alv-status
                                  AND secue         = it_alv-secue.

        IF sy-subrc NE 0.



          MESSAGE 'Database error updating Sales Order, try again'
             TYPE 'I'.

          LEAVE TO SCREEN 0.

        ENDIF.

*                                  BEGIN  AGA CHG0085456 07/13/18
        IF it_alv-vbeln_create IS NOT INITIAL.

          UPDATE zsdt_hd_webso
             SET num_int    = it_alv-num_int
                betwstreets = it_alv-betwstreets
                hometype    = it_alv-hometype
                del_floor   = it_alv-del_floor
                stairs      = it_alv-stairs
                elevator    = it_alv-elevator
                private_distr = it_alv-private_distr
                access_docum  = it_alv-access_docum
                del_shift     = it_alv-del_shift
                delivery_nextd = it_alv-delivery_nextd
                scnd_floor   = it_alv-scnd_floor " AGA 08/08/2018 CHG0087785
                thrdfifht_floor = it_alv-thrdfifht_floor " AGA 08/08/2018 CHG0087785
                fixed_day  = it_alv-fixed_day   "  GARCA59 CHG0093826 11/22/2018
                time_frame  = it_alv-time_frame "  GARCA59 CHG0093826 11/22/2018
                weeknd_del = it_alv-weeknd_del "  GARCA59 CHG0093826 11/22/2018
                specific_time = it_alv-specific_time "  GARCA59 CHG0093826 11/22/2018
                unpack = it_alv-unpack "  GARCA59 CHG0093826 11/22/2018
                install = it_alv-install "  GARCA59 CHG0093826 11/22/2018
                pickup  = it_alv-pickup "  GARCA59 CHG0093826 11/22/2018

            WHERE vbeln EQ it_alv-vbeln_create.

          IF sy-subrc NE 0.

            MESSAGE 'Database error updating Sales Order, try again'
                TYPE 'I'.

            LEAVE TO SCREEN 0.

          ENDIF..

        ENDIF.
*                                END  CHG0085456 07/13/18

        AT END OF taw_order.
          READ TABLE it_alv INDEX ws_tabix.


          OPEN DATASET it_alv-localfile FOR INPUT IN TEXT MODE ENCODING DEFAULT.

          IF sy-subrc EQ 0.

            CLOSE DATASET it_alv-localfile .

            DELETE DATASET it_alv-localfile.
*         BEGIN - RUIZIA - NDVK9A10UW - 04.12.2013
*         If the file is not found for deletion (processing file),
*         not to overwrite the served


*          IF sy-subrc = 0.

*         END - RUIZIA - NDVK9A10UW- 04.12.2013
            OPEN DATASET it_alv-localfile FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

            IF sy-subrc EQ 0.

              LOOP AT w_field_paso.
                TRANSFER w_field_paso TO it_alv-localfile.
              ENDLOOP.

              CLOSE DATASET it_alv-localfile.

              COMMIT WORK AND WAIT.

            ELSE.

              ROLLBACK WORK.

              MESSAGE 'Error trying to create new file, check SU53'
                 TYPE 'E'.

              LEAVE TO SCREEN 0.

            ENDIF.

          ELSE.

              MESSAGE 'Error trying to create new file, check SU53'
                 TYPE 'E'.

              LEAVE TO SCREEN 0.

*         BEGIN - RUIZIA - NDVK9A10UW - 04.12.2013
          ENDIF.
*         END - RUIZIA - NDVK9A10UW - 04.12.2013
        ENDAT.
      ENDLOOP.

* Imprime Shipment transaccion (ZWLEHCEN)
*       BEGIN GARCA59 02/24/20
*      SUBMIT zmx_create_sales_orders_hd_as AND RETURN.
*      PERFORM datos.
*      PERFORM crea_vista.

      rs_selfield-refresh    = 'X'.
      rs_selfield-col_stable = 'X'.
      rs_selfield-row_stable = 'X'.

      MESSAGE 'Wait until next iteration of job executes and rerun this program for fresh data'
         TYPE 'I'.

      LEAVE TO SCREEN 0.
*     END GARCA59

*      r_ucomm  = '&F03'.
  ENDCASE.

ENDFORM.                    " user_command
*&---------------------------------------------------------------------*
*&      Form  GRABA
*&-----------------------------------------.----------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM graba .

*  IF it_alv[] is not initial.
*    DELETE FROM ZCAT_CLIENTES.
*    DELETE DATASET p_arch_s.
*    OPEN DATASET p_arch_s FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
*  ENDIF.
*
*  LOOP AT it_alv.
*    CLEAR ZCAT_CLIENTES.
*
*    IF it_alv-SOLD_TO is not initial.
*      MOVE-CORRESPONDING it_alv TO ZCAT_CLIENTES.
**{   INSERT         NDXK902723                                        1
*      SELECT SINGLE * FROM KNVV WHERE KUNNR = it_alv-SOLD_TO
*                                  AND VKORG = '0360'
*                                  AND VTWEG = '10'
*                                  AND SPART = '13'.
*      IF SY-SUBRC = 0.
*        ZCAT_CLIENTES-PLTYP = KNVV-PLTYP.
*      ENDIF.
**}   INSERT
*      INSERT ZCAT_CLIENTES.
*
*      CONCATENATE ZCAT_CLIENTES-SOLD_TO
*                  ZCAT_CLIENTES-SOLD_TO_TEXT
*                  ZCAT_CLIENTES-CHANNEL
*                  ZCAT_CLIENTES-DIRECTOR
*                  ZCAT_CLIENTES-GTE_REGIONAL
*                  ZCAT_CLIENTES-GERENTE
*                  ZCAT_CLIENTES-VENDEDOR
*                  ZCAT_CLIENTES-SOLD_TO_TMK
*                  ZCAT_CLIENTES-PORCE_DE_RESERVA
*                  ZCAT_CLIENTES-NAME_COTIZADOR
*                  ZCAT_CLIENTES-TIPO_CTE
*                  ZCAT_CLIENTES-PYL_CODE
**{   REPLACE        NDXK902723                                        2
**\                  ZCAT_CLIENTES-PYL_CODE_NAME INTO w_field SEPARATED BY '|'.
*                  ZCAT_CLIENTES-PLTYP INTO w_field SEPARATED BY '|'.
**}   REPLACE
*
*      TRANSFER w_field TO p_arch_s.
*
*
*    ENDIF.
*
*  ENDLOOP.
*
*  IF it_alv[] is not initial.
*    CLOSE DATASET p_arch_s.
*  ENDIF.

ENDFORM.                    " GRABA
*&---------------------------------------------------------------------*
*&      Form  F_VAL_HD_NEW_SERV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_HD_NEW_SERV  text
*----------------------------------------------------------------------*
FORM f_val_hd_new_serv  CHANGING p_val.


  SELECT low "CHG0104904 GARCA59 06/11/19
      FROM tvarvc
     INTO p_val
     UP TO 1 ROWS
   WHERE name EQ 'ZSD_HD_NEW_SERV'.
  ENDSELECT..

  IF sy-subrc EQ 0.
  ENDIF.

ENDFORM.
