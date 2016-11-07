CREATE OR REPLACE VIEW view_jastask AS SELECT * FROM jtask WHERE((JTask_Deleted_b=false)OR(JTask_Deleted_b IS NULL)) and (JTask_JProject_ID=1604282136168840003); 
  