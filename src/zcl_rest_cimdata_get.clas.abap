class ZCL_REST_CIMDATA_GET definition
  public
  final
  create public .

public section.

  interfaces ZIF_REST_CI .

  methods CONSTRUCTOR
    importing
      !IO_REQUEST type ref to IF_HTTP_REQUEST
      !IO_RESPONSE type ref to IF_HTTP_RESPONSE .
protected section.
private section.

  methods GET_MDATA
    importing
      value(IO_REQUEST) type ref to IF_HTTP_REQUEST
    returning
      value(ET_MDATA) type ZCI_TTMDATAREG .
ENDCLASS.



CLASS ZCL_REST_CIMDATA_GET IMPLEMENTATION.


  method CONSTRUCTOR.
    ME->ZIF_REST_CI~RESPONSE = IO_RESPONSE.
    ME->ZIF_REST_CI~REQUEST = IO_REQUEST.
  endmethod.


  method GET_MDATA.
***************************************************************************
" VARIABLES
***************************************************************************
DATA: LS_MDATA TYPE zci_stmdata,
      w_mdatv TYPE zci_stmdatv,
      w_mdatvs TYPE zci_stmdatvs,
      w_mdatareg TYPE zci_stmdatareg,
      t_mdata TYPE zci_ttmdata.
************************************* *************************************
" GET MASTER DATA SELECT
***************************************************************************
SELECT spras,ktokd,txt30 INTO TABLE @DATA(it_t077x) FROM t077x
  WHERE spras = 'E'.
LS_MDATA-TABLE = '01'.
LS_MDATA-DESCR = 'Account Group Names'.
LS_MDATA-FIELD = 'KTOKD'.
LOOP AT it_t077x INTO DATA(wa_t077x).
  w_mdatv-lang = wa_t077x-spras.
  w_mdatv-item = wa_t077x-ktokd.
  w_mdatv-name = wa_t077x-txt30.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT bukrs,butxt INTO TABLE @DATA(it_t001) FROM t001
  WHERE land1 = 'MX'.
LS_MDATA-TABLE = '02'.
LS_MDATA-DESCR = 'Company Codes'.
LS_MDATA-FIELD = 'BUKRS'.
LOOP AT it_t001 INTO DATA(wa_t001).
  w_mdatv-lang = 'E'.
  w_mdatv-item = wa_t001-bukrs.
  w_mdatv-name = wa_t001-butxt.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT b~spras,a~bukrs,a~vkorg,b~vtext INTO TABLE @DATA(it_tvko)
  FROM tvko AS a
  INNER JOIN tvkot AS b
     ON b~vkorg = a~vkorg
  WHERE a~waers = 'MXN'
    AND b~spras = 'E'.
LS_MDATA-TABLE = '03'.
LS_MDATA-DESCR = 'Sales Organizations'.
LS_MDATA-FIELD = 'VKORG'.
LS_MDATA-FIDEP = 'BUKRS'.
SORT it_tvko BY bukrs vkorg.
LOOP AT it_tvko INTO DATA(wa_tvko).
  w_mdatv-lang = wa_tvko-spras.
  w_mdatv-item = wa_tvko-vkorg.
  w_mdatv-name = wa_tvko-vtext.
  w_mdatv-idep = wa_tvko-bukrs.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,vtweg,vtext INTO TABLE @DATA(it_tvtwt) FROM tvtwt
  WHERE spras = 'E'.
LS_MDATA-TABLE = '04'.
LS_MDATA-DESCR = 'Distribution Channels'.
LS_MDATA-FIELD = 'VTWEG'.
LOOP AT it_tvtwt INTO DATA(wa_tvtwt).
  w_mdatv-lang = wa_tvtwt-spras.
  w_mdatv-item = wa_tvtwt-vtweg.
  w_mdatv-name = wa_tvtwt-vtext.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,spart,vtext INTO TABLE @DATA(it_tspat) FROM tspat
  WHERE spras = 'E'.
LS_MDATA-TABLE = '05'.
LS_MDATA-DESCR = 'Sales Division'.
LS_MDATA-FIELD = 'SPART'.
LOOP AT it_tspat INTO DATA(wa_tspat).
  w_mdatv-lang = wa_tspat-spras.
  w_mdatv-item = wa_tspat-spart.
  w_mdatv-name = wa_tspat-vtext.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,land1,landx INTO TABLE @DATA(it_t005t) FROM t005t
  WHERE spras = 'E'.
LS_MDATA-TABLE = '06'.
LS_MDATA-DESCR = 'Country Names'.
LS_MDATA-FIELD = 'COUNTRY'.
LOOP AT it_t005t INTO DATA(wa_t005t).
  w_mdatv-lang = wa_t005t-spras.
  w_mdatv-item = wa_t005t-land1.
  w_mdatv-name = wa_t005t-landx.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,land1,bland,bezei INTO TABLE @DATA(it_t005u) FROM t005u
  WHERE spras = 'E'.
LS_MDATA-TABLE = '07'.
LS_MDATA-DESCR = 'Region Key'.
LS_MDATA-FIELD = 'REGION'.
LS_MDATA-FIDEP = 'COUNTRY'.
LOOP AT it_t005u INTO DATA(wa_t005u).
  w_mdatv-lang = wa_t005u-spras.
  w_mdatv-item = wa_t005u-bland.
  w_mdatv-name = wa_t005u-bezei.
  w_mdatv-idep = wa_t005u-land1.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,katr6,vtext INTO TABLE @DATA(it_tvk6t) FROM tvk6t
  WHERE spras = 'E'.
LS_MDATA-TABLE = '08'.
LS_MDATA-DESCR = 'Tax Group'.
LS_MDATA-FIELD = 'KATR6'.
LOOP AT it_tvk6t INTO DATA(wa_tvk6t).
  w_mdatv-lang = wa_tvk6t-spras.
  w_mdatv-item = wa_tvk6t-katr6.
  w_mdatv-name = wa_tvk6t-vtext.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,katr7,vtext INTO TABLE @DATA(it_tvk7t) FROM tvk7t
  WHERE spras = 'E'.
LS_MDATA-TABLE = '09'.
LS_MDATA-DESCR = 'P&L Group'.
LS_MDATA-FIELD = 'KATR7'.
LOOP AT it_tvk7t INTO DATA(wa_tvk7t).
  w_mdatv-lang = wa_tvk7t-spras.
  w_mdatv-item = wa_tvk7t-katr7.
  w_mdatv-name = wa_tvk7t-vtext.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,katr9,vtext INTO TABLE @DATA(it_tvk9t) FROM tvk9t
  WHERE spras = 'E'.
LS_MDATA-TABLE = '10'.
LS_MDATA-DESCR = 'Designates Demand Forecast Source'.
LS_MDATA-FIELD = 'KATR9'.
LOOP AT it_tvk9t INTO DATA(wa_tvk9t).
  w_mdatv-lang = wa_tvk9t-spras.
  w_mdatv-item = wa_tvk9t-katr9.
  w_mdatv-name = wa_tvk9t-vtext.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,kdkgr,vtext INTO TABLE @DATA(it_tvkggt) FROM tvkggt
  WHERE spras = 'E'.
LS_MDATA-TABLE = '11'.
LS_MDATA-DESCR = 'Customer Condition Groups'.
LS_MDATA-FIELD = 'KDKGR'.
LOOP AT it_tvkggt INTO DATA(wa_tvkggt).
  w_mdatv-lang = wa_tvkggt-spras.
  w_mdatv-item = wa_tvkggt-kdkgr.
  w_mdatv-name = wa_tvkggt-vtext.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,niels,bezei INTO TABLE @DATA(it_tnlst) FROM tnlst
  WHERE spras = 'E'.
LS_MDATA-TABLE = '12'.
LS_MDATA-DESCR = 'Nielsen Indicators'.
LS_MDATA-FIELD = 'NIELS'.
LOOP AT it_tnlst INTO DATA(wa_tnlst).
  w_mdatv-lang = wa_tnlst-spras.
  w_mdatv-item = wa_tnlst-niels.
  w_mdatv-name = wa_tnlst-bezei.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT b~spras,a~bukrs,a~saknr,b~txt50 INTO TABLE @DATA(it_skb1)
  FROM skb1 AS a
  INNER JOIN skat AS b
    ON b~saknr = a~saknr
  WHERE a~mitkz = 'D'
    AND b~spras = 'E'
    AND b~ktopl = 'WECO'.
LS_MDATA-TABLE = '13'.
LS_MDATA-DESCR = 'Reconciliation account'.
LS_MDATA-FIELD = 'AKONT'.
LS_MDATA-FIDEP = 'BUKRS'.
SORT it_skb1 BY bukrs saknr.
LOOP AT it_skb1 INTO DATA(wa_skb1).
  w_mdatv-lang = wa_skb1-spras.
  w_mdatv-item = wa_skb1-saknr.
  w_mdatv-name = wa_skb1-txt50.
  w_mdatv-idep = wa_skb1-bukrs.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,grupp,textl INTO TABLE @DATA(it_t035t) FROM t035t
  WHERE spras = 'E'.
LS_MDATA-TABLE = '14'.
LS_MDATA-DESCR = 'Planning group'.
LS_MDATA-FIELD = 'FDGRV'.
LOOP AT it_t035t INTO DATA(wa_t035t).
  w_mdatv-lang = wa_t035t-spras.
  w_mdatv-item = wa_t035t-grupp.
  w_mdatv-name = wa_t035t-textl.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT bukrs,lockb,hbkid INTO TABLE @DATA(it_t049l) FROM t049l.
LS_MDATA-TABLE = '15'.
LS_MDATA-DESCR = 'Lockbox'.
LS_MDATA-FIELD = 'LOCKB'.
LS_MDATA-FIDEP = 'BUKRS'.
SORT it_t049l BY bukrs lockb.
LOOP AT it_t049l INTO DATA(wa_t049l).
  w_mdatv-lang = 'E'.
  w_mdatv-item = wa_t049l-lockb.
  w_mdatv-name = wa_t049l-hbkid.
  w_mdatv-idep = wa_t049l-bukrs.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,bzirk,bztxt INTO TABLE @DATA(it_t171t) FROM t171t
  WHERE spras = 'E'.
LS_MDATA-TABLE = '16'.
LS_MDATA-DESCR = 'Sales districts'.
LS_MDATA-FIELD = 'BZIRK'.
LOOP AT it_t171t INTO DATA(wa_t171t).
  w_mdatv-lang = wa_t171t-spras.
  w_mdatv-item = wa_t171t-bzirk.
  w_mdatv-name = wa_t171t-bztxt.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,vkbur,bezei INTO TABLE @DATA(it_tvkbt) FROM tvkbt
  WHERE spras = 'E'.
LS_MDATA-TABLE = '17'.
LS_MDATA-DESCR = 'Sales Offices'.
LS_MDATA-FIELD = 'VKBUR'.
LOOP AT it_tvkbt INTO DATA(wa_tvkbt).
  w_mdatv-lang = wa_tvkbt-spras.
  w_mdatv-item = wa_tvkbt-vkbur.
  w_mdatv-name = wa_tvkbt-bezei.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,vkgrp,bezei INTO TABLE @DATA(it_tvgrt) FROM tvgrt
  WHERE spras = 'E'.
LS_MDATA-TABLE = '18'.
LS_MDATA-DESCR = 'Sales Groups'.
LS_MDATA-FIELD = 'VKGRP'.
LOOP AT it_tvgrt INTO DATA(wa_tvgrt).
  w_mdatv-lang = wa_tvgrt-spras.
  w_mdatv-item = wa_tvgrt-vkgrp.
  w_mdatv-name = wa_tvgrt-bezei.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,kdgrp,ktext INTO TABLE @DATA(it_t151t) FROM t151t
  WHERE spras = 'E'.
LS_MDATA-TABLE = '19'.
LS_MDATA-DESCR = 'Customer groups'.
LS_MDATA-FIELD = 'KDGRP'.
LOOP AT it_t151t INTO DATA(wa_t151t).
  w_mdatv-lang = wa_t151t-spras.
  w_mdatv-item = wa_t151t-kdgrp.
  w_mdatv-name = wa_t151t-ktext.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,waers,ltext INTO TABLE @DATA(it_tcurt) FROM tcurt
  WHERE spras = 'E'.
LS_MDATA-TABLE = '20'.
LS_MDATA-DESCR = 'Currency Codes'.
LS_MDATA-FIELD = 'WAERS'.
LOOP AT it_tcurt INTO DATA(wa_tcurt).
  w_mdatv-lang = wa_tcurt-spras.
  w_mdatv-item = wa_tcurt-waers.
  w_mdatv-name = wa_tcurt-ltext.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,konda,vtext INTO TABLE @DATA(it_t188t) FROM t188t
  WHERE spras = 'E'.
LS_MDATA-TABLE = '21'.
LS_MDATA-DESCR = 'Price group'.
LS_MDATA-FIELD = 'KONDA'.
LOOP AT it_t188t INTO DATA(wa_t188t).
  w_mdatv-lang = wa_t188t-spras.
  w_mdatv-item = wa_t188t-konda.
  w_mdatv-name = wa_t188t-vtext.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,kalks,vtext INTO TABLE @DATA(it_tvkdt) FROM tvkdt
  WHERE spras = 'E'.
LS_MDATA-TABLE = '22'.
LS_MDATA-DESCR = 'Cust.pric.proc.'.
LS_MDATA-FIELD = 'KALKS'.
LOOP AT it_tvkdt INTO DATA(wa_tvkdt).
  w_mdatv-lang = wa_tvkdt-spras.
  w_mdatv-item = wa_tvkdt-kalks.
  w_mdatv-name = wa_tvkdt-vtext.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,pltyp,ptext INTO TABLE @DATA(it_t189t) FROM t189t
  WHERE spras = 'E'.
LS_MDATA-TABLE = '23'.
LS_MDATA-DESCR = 'Price list'.
LS_MDATA-FIELD = 'PLTYP'.
LOOP AT it_t189t INTO DATA(wa_t189t).
  w_mdatv-lang = wa_t189t-spras.
  w_mdatv-item = wa_t189t-pltyp.
  w_mdatv-name = wa_t189t-ptext.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,stgku,bezei20 INTO TABLE @DATA(it_tvsdt) FROM tvsdt
  WHERE spras = 'E'.
LS_MDATA-TABLE = '24'.
LS_MDATA-DESCR = 'Cust.Stats.Grp'.
LS_MDATA-FIELD = 'VERSG'.
LOOP AT it_tvsdt INTO DATA(wa_tvsdt).
  w_mdatv-lang = wa_tvsdt-spras.
  w_mdatv-item = wa_tvsdt-stgku.
  w_mdatv-name = wa_tvsdt-bezei20.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,lprio,bezei INTO TABLE @DATA(it_tprit) FROM tprit
  WHERE spras = 'E'.
LS_MDATA-TABLE = '25'.
LS_MDATA-DESCR = 'Delivery Priority'.
LS_MDATA-FIELD = 'LPRIO'.
SORT it_tprit BY lprio.
LOOP AT it_tprit INTO DATA(wa_tprit).
  w_mdatv-lang = wa_tprit-spras.
  w_mdatv-item = wa_tprit-lprio.
  w_mdatv-name = wa_tprit-bezei.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,land1,landx INTO TABLE @DATA(it_aland) FROM t005t
  WHERE spras = 'E'.
LS_MDATA-TABLE = '26'.
LS_MDATA-DESCR = 'Country Names'.
LS_MDATA-FIELD = 'ALAND'.
LOOP AT it_aland INTO DATA(wa_aland).
  w_mdatv-lang = wa_aland-spras.
  w_mdatv-item = wa_aland-land1.
  w_mdatv-name = wa_aland-landx.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT tax_cty,tax_type,tatyp,taxkd INTO TABLE @DATA(it_tb072_cm)
  FROM tb072_cm.

SELECT a~spras,b~talnd,a~kschl,a~vtext INTO TABLE @DATA(it_t685t)
  FROM t685t AS a
  INNER JOIN tstl AS b
    ON b~tatyp = a~kschl
  WHERE a~spras = 'E'
    AND a~kvewe = 'A'
    AND a~kappl = 'V'.
LS_MDATA-TABLE = '27'.
LS_MDATA-DESCR = 'Tax category'.
LS_MDATA-FIELD = 'TATYP'.
LS_MDATA-FIDEP = 'COUNTRY'.
LOOP AT it_t685t INTO DATA(wa_t685t).
  w_mdatv-lang = wa_t685t-spras.
  w_mdatv-item = wa_t685t-kschl.
  w_mdatv-name = wa_t685t-vtext.
  w_mdatv-idep = wa_t685t-talnd.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,tatyp,taxkd,vtext INTO TABLE @DATA(it_tskdt) FROM tskdt
  WHERE spras = 'E'.
LS_MDATA-TABLE = '28'.
LS_MDATA-DESCR = 'Tax classification'.
LS_MDATA-FIELD = 'TAXKD'.
LS_MDATA-FIDEP = 'TATYP'.
SORT it_tskdt BY tatyp taxkd.
LOOP AT it_tskdt INTO DATA(wa_tskdt).
  w_mdatv-lang = wa_tskdt-spras.
  w_mdatv-item = wa_tskdt-taxkd.
  w_mdatv-name = wa_tskdt-vtext.
  w_mdatv-idep = wa_tskdt-tatyp.
  CLEAR: w_mdatv-ideps,w_mdatvs.
  LOOP AT it_tb072_cm INTO DATA(wa_tb072_cm)
    WHERE tax_type = wa_tskdt-tatyp
      AND tatyp = wa_tskdt-tatyp
      AND taxkd = wa_tskdt-taxkd.
     w_mdatvs-name = 'COUNTRY'.
     w_mdatvs-idep = wa_tb072_cm-tax_cty.
     APPEND w_mdatvs TO w_mdatv-ideps.
  ENDLOOP.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,kvgr1,bezei INTO TABLE @DATA(it_tvv1t) FROM tvv1t
  WHERE spras = 'E'.
LS_MDATA-TABLE = '29'.
LS_MDATA-DESCR = 'Customer Segment Code'.
LS_MDATA-FIELD = 'KVGR1'.
LOOP AT it_tvv1t INTO DATA(wa_tvv1t).
  w_mdatv-lang = wa_tvv1t-spras.
  w_mdatv-item = wa_tvv1t-kvgr1.
  w_mdatv-name = wa_tvv1t-bezei.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,kvgr4,bezei INTO TABLE @DATA(it_tvv4t) FROM tvv4t
  WHERE spras = 'E'.
LS_MDATA-TABLE = '30'.
LS_MDATA-DESCR = 'APO Trade Partner Group'.
LS_MDATA-FIELD = 'KVGR4'.
LOOP AT it_tvv4t INTO DATA(wa_tvv4t).
  w_mdatv-lang = wa_tvv4t-spras.
  w_mdatv-item = wa_tvv4t-kvgr4.
  w_mdatv-name = wa_tvv4t-bezei.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,kvgr5,bezei INTO TABLE @DATA(it_tvv5t) FROM tvv5t
  WHERE spras = 'E'.
LS_MDATA-TABLE = '31'.
LS_MDATA-DESCR = 'APO Demand Forecast Source'.
LS_MDATA-FIELD = 'KVGR5'.
LOOP AT it_tvv5t INTO DATA(wa_tvv5t).
  w_mdatv-lang = wa_tvv5t-spras.
  w_mdatv-item = wa_tvv5t-kvgr5.
  w_mdatv-name = wa_tvv5t-bezei.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT b~spras,a~bukrs,a~kkber,b~kkbtx INTO TABLE @DATA(it_t001cm)
  FROM t001cm AS a
  INNER JOIN t014t AS b
    ON b~kkber = a~kkber
  WHERE spras = 'E'.
LS_MDATA-TABLE = '32'.
LS_MDATA-DESCR = 'Credit control area'.
LS_MDATA-FIELD = 'KKBER'.
LS_MDATA-FIDEP = 'BUKRS'.
SORT it_t001cm BY bukrs kkber.
LOOP AT it_t001cm INTO DATA(wa_it_t001cm).
  w_mdatv-lang = wa_it_t001cm-spras.
  w_mdatv-item = wa_it_t001cm-kkber.
  w_mdatv-name = wa_it_t001cm-kkbtx.
  w_mdatv-idep = wa_it_t001cm-bukrs.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,kkber,ctlpc,rtext INTO TABLE @DATA(it_t691t) FROM t691t
  WHERE spras = 'E'.
LS_MDATA-TABLE = '33'.
LS_MDATA-DESCR = 'Risk category'.
LS_MDATA-FIELD = 'CTLPC'.
LS_MDATA-FIDEP = 'KKBER'.
SORT it_t691t BY kkber ctlpc.
LOOP AT it_t691t INTO DATA(wa_t691t).
  w_mdatv-lang = wa_t691t-spras.
  w_mdatv-item = wa_t691t-ctlpc.
  w_mdatv-name = wa_t691t-rtext.
  w_mdatv-idep = wa_t691t-kkber.
  CLEAR: w_mdatv-ideps,w_mdatvs.
  LOOP AT it_t001cm INTO DATA(warc_t001cm)
    WHERE kkber = wa_t691t-kkber.
     w_mdatvs-name = 'BUKRS'.
     w_mdatvs-idep = warc_t001cm-bukrs.
     APPEND w_mdatvs TO w_mdatv-ideps.
  ENDLOOP.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT kkber,sbgrp,stext INTO TABLE @DATA(it_t024b) FROM t024b.
LS_MDATA-TABLE = '34'.
LS_MDATA-DESCR = 'Credit representative group'.
LS_MDATA-FIELD = 'SBGRP'.
LS_MDATA-FIDEP = 'KKBER'.
SORT it_t024b BY kkber sbgrp.
LOOP AT it_t024b INTO DATA(wa_t024b).
  w_mdatv-lang = 'E'.
  w_mdatv-item = wa_t024b-sbgrp.
  w_mdatv-name = wa_t024b-stext.
  w_mdatv-idep = wa_t024b-kkber.
  CLEAR: w_mdatv-ideps,w_mdatvs.
  LOOP AT it_t001cm INTO DATA(wacr_t001cm)
    WHERE kkber = wa_t024b-kkber.
     w_mdatvs-name = 'BUKRS'.
     w_mdatvs-idep = wacr_t001cm-bukrs.
     APPEND w_mdatvs TO w_mdatv-ideps.
  ENDLOOP.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,land1,zone1,vtext INTO TABLE @DATA(it_tzont) FROM tzont
  WHERE spras = 'E'.
LS_MDATA-TABLE = '35'.
LS_MDATA-DESCR = 'Transportation Zone'.
LS_MDATA-FIELD = 'LZONE'.
LS_MDATA-FIDEP = 'COUNTRY'.
SORT it_tzont BY land1 zone1.
LOOP AT it_tzont INTO DATA(wa_tzont).
  w_mdatv-lang = wa_tzont-spras.
  w_mdatv-item = wa_tzont-zone1.
  w_mdatv-name = wa_tzont-vtext.
  w_mdatv-idep = wa_tzont-land1.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,parvw,vtext INTO TABLE @DATA(it_tpart) FROM tpart
  WHERE spras = 'E'.
LS_MDATA-TABLE = '36'.
LS_MDATA-DESCR = 'Partner Function'.
LS_MDATA-FIELD = 'PARVW'.
LOOP AT it_tpart INTO DATA(wa_tpart).
  w_mdatv-lang = wa_tpart-spras.
  w_mdatv-item = wa_tpart-parvw.
  w_mdatv-name = wa_tpart-vtext.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,ktgrd,vtext INTO TABLE @DATA(it_tvktt) FROM tvktt
  WHERE spras = 'E'.
LS_MDATA-TABLE = '37'.
LS_MDATA-DESCR = 'Account assignment group'.
LS_MDATA-FIELD = 'KTGRD'.
LOOP AT it_tvktt INTO DATA(wa_tvktt).
  w_mdatv-lang = wa_tvktt-spras.
  w_mdatv-item = wa_tvktt-ktgrd.
  w_mdatv-name = wa_tvktt-vtext.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,werks,name1 INTO TABLE @DATA(it_t001w) FROM t001w
  WHERE spras = 'E'
    AND land1 = 'MX'.
LS_MDATA-TABLE = '38'.
LS_MDATA-DESCR = 'Delivering Plant'.
LS_MDATA-FIELD = 'VWERK'.
LOOP AT it_t001w INTO DATA(wa_t001w).
  w_mdatv-lang = wa_t001w-spras.
  w_mdatv-item = wa_t001w-werks.
  w_mdatv-name = wa_t001w-name1.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,inco1,bezei INTO TABLE @DATA(it_tinct) FROM tinct
  WHERE spras = 'E'.
LS_MDATA-TABLE = '39'.
LS_MDATA-DESCR = 'Incoterms (Part 1)'.
LS_MDATA-FIELD = 'INCO1'.
LOOP AT it_tinct INTO DATA(wa_tinct).
  w_mdatv-lang = wa_tinct-spras.
  w_mdatv-item = wa_tinct-inco1.
  w_mdatv-name = wa_tinct-bezei.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,zterm,text1 INTO TABLE @DATA(it_t052u) FROM t052u
  WHERE spras = 'E'.
LS_MDATA-TABLE = '40'.
LS_MDATA-DESCR = 'Terms of Payment Key'.
LS_MDATA-FIELD = 'ZTERM'.
LOOP AT it_t052u INTO DATA(wa_t052u).
  w_mdatv-lang = wa_t052u-spras.
  w_mdatv-item = wa_t052u-zterm.
  w_mdatv-name = wa_t052u-text1.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

SELECT spras,vsbed,vtext INTO TABLE @DATA(it_tvsbt) FROM tvsbt
  WHERE spras = 'E'.
LS_MDATA-TABLE = '41'.
LS_MDATA-DESCR = 'Shipping Conditions'.
LS_MDATA-FIELD = 'VSBED'.
LOOP AT it_tvsbt INTO DATA(wa_tvsbt).
  w_mdatv-lang = wa_tvsbt-spras.
  w_mdatv-item = wa_tvsbt-vsbed.
  w_mdatv-name = wa_tvsbt-vtext.
  APPEND w_mdatv TO LS_MDATA-DATA.
ENDLOOP.
APPEND LS_MDATA TO T_MDATA.
CLEAR: LS_MDATA,w_mdatv.

W_MDATAREG-MSTDREG = 'NAR'.
APPEND W_MDATAREG TO ET_MDATA.

LOOP AT ET_MDATA INTO DATA(LS_ETMDATA).
  LOOP AT T_MDATA INTO DATA(LS_TMDATA).
    APPEND LS_TMDATA TO LS_ETMDATA-MSTDATA.
  ENDLOOP.
  MODIFY ET_MDATA FROM LS_ETMDATA.
ENDLOOP.

  endmethod.


  method ZIF_REST_CI~HANDLE_REQUEST.
***************************************************************************
" VARIABLES
***************************************************************************
DATA: LT_MDATA          TYPE ZCI_TTMDATAREG.
DATA: LV_STRING_WRITER  TYPE REF TO CL_SXML_STRING_WRITER.
DATA: LV_XSTRING        TYPE XSTRING.

***************************************************************************
" EXECUTE GET_MDATA METHOD
***************************************************************************
TRY.

LT_MDATA = GET_MDATA( ME->ZIF_REST_CI~REQUEST ).

***************************************************************************
" CONVERT EQUIPMENTS TO JSON
***************************************************************************
LV_STRING_WRITER = CL_SXML_STRING_WRITER=>CREATE( TYPE = IF_SXML=>CO_XT_JSON ).
CALL TRANSFORMATION ID SOURCE ARRAY =  LT_MDATA RESULT XML LV_STRING_WRITER.
LV_XSTRING = LV_STRING_WRITER->GET_OUTPUT( ).

***************************************************************************
" ADD THE JSON EQUIPMENTS TO THE RESPONSE
***************************************************************************
ME->ZIF_REST_CI~RESPONSE->SET_DATA( DATA = LV_XSTRING ).

CATCH CX_ROOT.
ENDTRY.
  endmethod.


  method ZIF_REST_CI~SET_RESPONSE.
    CALL METHOD ME->ZIF_REST_CI~RESPONSE->SET_DATA
      EXPORTING
        DATA = IS_DATA.
  endmethod.
ENDCLASS.
