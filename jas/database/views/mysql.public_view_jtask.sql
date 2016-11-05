CREATE OR REPLACE VIEW public_view_jtask AS
select * from jtask where
((JTask_Deleted_b=false)OR(JTask_Deleted_b is null)) AND
(
  (JTask_JProject_ID=1604282136168840003  ) or  /* JAS */
  (JTask_JProject_ID=1602240144581540013  ) or  /* Jegas API */
  (JTask_JProject_ID=1604282201042440012  ) or  /* JegasBackup */
  (JTask_JProject_ID=1604282146284290007  ) or  /* JegasEdit */
  (JTask_JProject_ID=1604282205528750014  )     /* Retro Hack-n-Slash */
);

