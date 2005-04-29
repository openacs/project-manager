-- 
-- 
-- 
-- @author Jade Rubick (jader@bread.com)
-- @creation-date 2004-10-08
-- @arch-tag: fe217011-50b1-4ee9-a686-21dd51cc2384
-- @cvs-id $Id$
--

alter table pm_roles add column is_lead_p char(1) 
                                constraint pm_role_is_lead_ck
                                check (is_lead_p in ('t','f'));

alter table pm_roles alter column is_lead_p set default 'f';

update pm_roles set is_lead_p = 't' where one_line = 'Lead';
