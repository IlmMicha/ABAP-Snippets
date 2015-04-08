*----------------------------------------------------------------------*
* Show ALV-Grid using CL_SALV_TABLE including a Header showing
* the number of lines in the displayed table* 
*----------------------------------------------------------------------*

DATA:
  gr_alv     TYPE REF TO cl_salv_table,
  gr_header  TYPE REF TO cl_salv_form_text,
  gv_lines   TYPE i,
  gv_message TYPE string,
  gv_table   TYPE TABLE OF mara. " any table
  
DESCRIBE TABLE gt_table LINES gv_lines.
MOVE gv_lines TO gv_message.
CONCATENATE gv_message 'Zeilen' INTO gv_message SEPARATED BY space.

cl_salv_table=>factory(
  IMPORTING
    r_salv_table   = gr_alv
  CHANGING
    t_table        = gt_table ).

gr_alv->get_functions( )->set_all( ).

CREATE OBJECT gr_header.
gr_header->set_text( value = gv_message ).

gr_alv->set_top_of_list( value = gr_header ).

gr_alv->get_columns( )->set_optimize( ).

gr_alv->display( ).
