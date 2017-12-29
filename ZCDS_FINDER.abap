*&---------------------------------------------------------------------*
*& Report ZCDS_FINDER
*&---------------------------------------------------------------------*
*& Author: atcher4sap / Date : 30 Aug 2017
*& Program finds common ABAP CDS views for SAP tables
*&---------------------------------------------------------------------*
REPORT zcds_finder.

TYPES : BEGIN OF ty_output,
          view_name TYPE objectname,
        END OF ty_output.

DATA : wa_output TYPE ty_output,
       lt_output TYPE TABLE OF ty_output.

PARAMETERS : table1 TYPE vibastab OBLIGATORY,
             table2 TYPE vibastab OBLIGATORY,
             table3 TYPE vibastab.

START-OF-SELECTION.

  IF table3 IS INITIAL. " If Table 3 is NOT present on selection screen
    SELECT DISTINCT viewname
        FROM dd27s
        INTO TABLE @DATA(lt_table1)
        WHERE tabname = @table1.
    IF sy-subrc IS INITIAL.
      SELECT DISTINCT viewname
      FROM dd27s
      INTO TABLE @DATA(lt_table2)
      WHERE tabname = @table2.
      IF sy-subrc IS INITIAL.

        LOOP AT lt_table1 ASSIGNING FIELD-SYMBOL(<fs_table>).
          READ TABLE lt_table2 WITH KEY viewname = <fs_table>-viewname ASSIGNING FIELD-SYMBOL(<fs_view1>).
          IF sy-subrc IS INITIAL.
            APPEND <fs_view1>-viewname TO lt_output.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDIF.

  ELSE. " If Table 3 is present on selection screen

    SELECT DISTINCT viewname
        FROM dd27s
        INTO TABLE @lt_table1
        WHERE tabname = @table1.
    IF sy-subrc IS INITIAL.
      SELECT DISTINCT viewname
        FROM dd27s
        INTO TABLE @lt_table2
        WHERE tabname = @table2.
      IF sy-subrc IS INITIAL.
        SELECT DISTINCT viewname
          FROM dd27s
          INTO TABLE @DATA(lt_table3)
          WHERE tabname = @table3.
        IF sy-subrc IS INITIAL.


          LOOP AT lt_table1 ASSIGNING <fs_table>.
            READ TABLE lt_table2 WITH KEY viewname = <fs_table>-viewname ASSIGNING <fs_view1>.
            IF sy-subrc IS INITIAL.
              READ TABLE lt_table3 WITH KEY viewname = <fs_table>-viewname ASSIGNING <fs_view1>.
              IF sy-subrc IS INITIAL.
                APPEND <fs_view1>-viewname TO lt_output.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.

  " Fetching CDS view name
  IF lt_output IS NOT INITIAL.
    SELECT ddls_name  FROM acm_ddlstbviw_1r
      INTO TABLE @DATA(lt_acm_ddlstbviw_1r)
      FOR ALL ENTRIES IN @lt_output
      WHERE view_name = @lt_output-view_name .
  ENDIF.

  IF lt_acm_ddlstbviw_1r IS INITIAL.
    WRITE : TEXT-001.
  ELSE.
    cl_demo_output=>display( lt_acm_ddlstbviw_1r ).
  ENDIF.
