-- packages/project-manager/sql/project-manager-drop.sql
-- drop script
--
-- @author jade@bread.com
-- @creation-date 2003-12-05
-- @cvs-id $Id$
--

-- drop any custom tables here.

begin
content_type.drop_attribute ('pm_project', 'customer_id', 't');
end;
/
show errors

