"#autoformat
*&---------------------------------------------------------------------*
*& Report ytm_ghost_variant
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ytm_ghost_variant.

DATA: l_s_varsel  TYPE rsvar,
      l_t_variant TYPE TABLE OF rsparams.

PARAMETERS: delete TYPE rs_bool.

SELECT *
  FROM tbtcp AS job
  INTO TABLE @DATA(l_t_job)
 WHERE progname = 'RSPROCESS'
   AND EXISTS (
SELECT *
  FROM tbtco
 WHERE jobname = job~jobname
   AND jobcount = job~jobcount
   AND status = 'S' ).


LOOP AT l_t_job REFERENCE INTO DATA(ls_job).
  l_s_varsel-report = ls_job->progname.
  l_s_varsel-variant = ls_job->variant.

  CALL FUNCTION 'RS_VARIANT_CONTENTS'
    EXPORTING
      report               = l_s_varsel-report
      variant              = l_s_varsel-variant
      execute_direct       = 'X'
    TABLES
      valutab              = l_t_variant
    EXCEPTIONS
      variant_non_existent = 1
      variant_obsolete     = 2
      OTHERS               = 3.

  IF sy-subrc <> 0.
    WRITE: / ls_job->jobname, ls_job->jobcount.
    IF delete = 'X'.
      CALL FUNCTION 'BP_JOB_DELETE'
        EXPORTING
          jobcount = ls_job->jobcount
          jobname  = ls_job->jobname
        EXCEPTIONS
          OTHERS   = 1.

      IF sy-subrc <> 0.
        WRITE 'not deleted'.
      ELSE.
        WRITE 'successfully deleted'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDLOOP.
