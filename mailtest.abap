DATA: l_o_send_request     TYPE REF TO cl_bcs,
      l_o_recipient        TYPE REF TO if_recipient_bcs,
      l_o_document         TYPE REF TO cl_document_bcs,

      l_t_body             TYPE soli_tab,

      l_length             TYPE i,
      l_t_attachment       TYPE soli_tab,
      l_t_attachment_x     TYPE solix_tab,
      l_size_memory        TYPE abap_msize,
      l_size               TYPE sood-objlen.

DATA:
  lx_document_bcs TYPE REF TO cx_document_bcs,
  lx_bcs          TYPE REF TO cx_bcs.


* create_document
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS:
  p_type   TYPE so_obj_tp DEFAULT 'RAW' OBLIGATORY,
  p_subjec TYPE so_obj_des DEFAULT 'Testmail' OBLIGATORY,
  p_length TYPE so_obj_len,
  p_langua TYPE so_obj_la,
  p_import TYPE bcs_docimp,
  p_sensit TYPE so_obj_sns,

  p_receiv TYPE ADR6-SMTP_ADDR DEFAULT 'mail@domain.de'.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS:
  p_string TYPE string DEFAULT 'Test;123'.

PARAMETERS:
  p_soli  TYPE c RADIOBUTTON GROUP att,
  p_solix TYPE c RADIOBUTTON GROUP att.

PARAMETERS:
  p_codepa TYPE abap_encod,
  p_addbom TYPE os_boolean.

PARAMETERS:
  p_atttyp TYPE soodk-objtp OBLIGATORY DEFAULT 'CSV',
  p_attsub TYPE sood-objdes OBLIGATORY DEFAULT 'test.csv',
  p_attlan TYPE sood-objla DEFAULT space.

SELECTION-SCREEN END OF BLOCK b2.


***** REQUEST
l_o_send_request = cl_bcs=>create_persistent( ).


***** DOCUMENT
TRY.
    l_o_document = cl_document_bcs=>create_document(
        i_type         = p_type
        i_subject      = p_subjec
        i_length       = p_length
        i_language     = p_langua
        i_importance   = p_import
        i_sensitivity  = p_sensit
        i_text         = l_t_body "empty
*    i_hex          =
*    i_header       =
*    i_sender       =
*    iv_vsi_profile =
           ).
  CATCH cx_document_bcs INTO lx_document_bcs.
    BREAK-POINT.
ENDTRY.

DATA:
  lv_size TYPE so_obj_len.

***** ATTACHMENT
CASE 'X'.
  WHEN p_soli.
    TRY.
        cl_bcs_convert=>string_to_tab(
          EXPORTING
            iv_string = p_string
          IMPORTING
            et_ctab   = l_t_attachment
               ).

        cl_abap_memory_utilities=>get_memory_size_of_object(
          EXPORTING object = l_t_attachment
          IMPORTING sizeof_used = l_size_memory ).

      CATCH cx_bcs INTO lx_bcs.
        BREAK-POINT.
    ENDTRY.
  WHEN p_solix.
    TRY.
        cl_bcs_convert=>string_to_solix(
          EXPORTING
            iv_string   = p_string
            iv_codepage = p_codepa
            iv_add_bom  = p_addbom
          IMPORTING
            et_solix    = l_t_attachment_x
            ev_size     = lv_size
               ).

        cl_abap_memory_utilities=>get_memory_size_of_object(
          EXPORTING object = l_t_attachment_x
          IMPORTING sizeof_used = l_size_memory ).
      CATCH cx_bcs INTO lx_bcs.
        BREAK-POINT.
    ENDTRY.
ENDCASE.

l_size = l_size_memory.

CASE 'X'.
  WHEN p_soli.
    TRY.
        l_o_document->add_attachment(
            i_attachment_type     = p_atttyp
            i_attachment_subject  = p_attsub
            i_attachment_size     = lv_size
            i_attachment_language = p_attlan
            i_att_content_text    = l_t_attachment
*    i_att_content_hex     =
*    i_attachment_header   =
*    iv_vsi_profile        =
               ).
      CATCH cx_document_bcs INTO lx_document_bcs.
        BREAK-POINT.
    ENDTRY.
  WHEN p_solix.
    TRY.
        l_o_document->add_attachment(
            i_attachment_type     = p_atttyp
            i_attachment_subject  = p_attsub
            i_attachment_size     = lv_size
            i_attachment_language = p_attlan
*    i_att_content_text    =
            i_att_content_hex     = l_t_attachment_x
*    i_attachment_header   =
*    iv_vsi_profile        =
               ).
      CATCH cx_document_bcs INTO lx_document_bcs.
        BREAK-POINT.
    ENDTRY.
ENDCASE.

CALL METHOD l_o_send_request->set_document( l_o_document ).

l_o_recipient = cl_cam_address_bcs=>create_internet_address( p_receiv ).

l_o_send_request->add_recipient( i_recipient  = l_o_recipient
                                   i_express    = 'X' ).

l_o_send_request->set_send_immediately( 'X' ).

l_o_send_request->send( 'X' ).

COMMIT WORK.
