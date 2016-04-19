function CD2_init

subst=get_param([gcs '/CD Parameters'],'subst');
subst=subst(2:end-1);
CD2_set_substances(subst);
