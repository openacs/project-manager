-- 
-- 
-- 
-- @author Jade Rubick (jader@bread.com)
-- @creation-date 2004-07-16
-- @arch-tag: aa453882-e63e-4582-a1d4-097df7792d23
-- @cvs-id $Id$
--

alter table pm_tasks add column deleted_p char(1);

alter table pm_tasks alter column deleted_p set default 'f';
update pm_tasks set deleted_p = 'f';

alter table pm_tasks add constraint pm_tasks_deleted_p_ck 
  check (deleted_p in ('t','f'));
