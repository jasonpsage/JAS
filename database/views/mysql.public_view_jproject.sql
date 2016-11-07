CREATE OR REPLACE VIEW public_view_jproject AS
select * from jproject where
((JProj_Deleted_b=false)OR(JProj_Deleted_b is null)) AND
(
  (JProj_JProject_UID=1604282136168840003  ) or  /* JAS */
  (JProj_JProject_UID=1602240144581540013  ) or  /* Jegas API */
  (JProj_JProject_UID=1604282201042440012  ) or  /* JegasBackup */
  (JProj_JProject_UID=1604282146284290007  ) or  /* JegasEdit */
  (JProj_JProject_UID=1604282205528750014  )     /* Retro Hack-n-Slash */
);




