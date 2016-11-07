create database if not exists jas;
/*
  GRANT
    priv_type [(column_list)]
      [, priv_type [(column_list)]] ...
    ON [object_type] priv_level
    TO user_specification [, user_specification] ...
    [REQUIRE {NONE | tsl_option [[AND] tsl_option] ...}]
    [WITH {GRANT OPTION | resource_option} ...]
*/

/*
  ACCESS JAS
*/
grant
 Select,
 Insert,
 Update,
 Delete,
 Create,
 Drop,
 /*Grant,*/
 /*References,*/
 Index,
 Alter
 /*Create_tmp_table,*/
 /*Lock_tables, <--incorrect keyword - i keep so you know they are there, and can search for em */
 /*Create_view, <--incorrect keyword */
 /*Show_view, <--incorrect keyword */
 /*Create_routine, <--incorrect keyword */
 /*Alter_routine, <--incorrect keyword */
 /*Execute_priv, <--incorrect keyword */
 /*Event_priv, <--incorrect keyword */
 /*Trigger_priv <--incorrect keyword */
on jas.*
to "jas"@"localhost"
identified by "jas";



