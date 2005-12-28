-- 
-- packages/project-manager/sql/postgresql/upgrade/upgrade-3.0d14-3.0d15.sql
-- 
-- @author Malte Sussdorff (sussdorff@sussdorff.de)
-- @creation-date 2005-08-25
-- @arch-tag: 50b73044-86d2-4d42-9798-55b036d4550f
-- @cvs-id $Id$
--

create index pm_project_assignment_role_id_idx on pm_project_assignment(role_id);
create index pm_project_assignment_project_id_idx on pm_project_assignment(project_id);
create index pm_project_assignment_party_id_idx on pm_project_assignment(party_id);