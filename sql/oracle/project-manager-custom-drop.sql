-- packages/project-manager/sql/project-manager-drop.sql
-- drop script
--
-- @author jade@bread.com
-- @creation-date 2003-12-05
-- @cvs-id $Id$
--

-- drop any custom tables here.

select content_type__drop_attribute ('pm_project', 'customer_id', 't');

