-- 
-- Create Indexes to speed up project manager
-- 
-- @author Alex Kroman <alexk@bread.com>
-- @creation-date 2005-06-24
-- @arch-tag: 02283125-116e-44d1-b006-7810050e8a9c
-- @cvs-id $Id$
--

CREATE OR REPLACE INDEX pm_workgroup_parties_party_id_inx ON pm_workgroup_parties(party_id);
CREATE OR REPLACE INDEX pm_workgroup_parties_role_id_inx ON pm_workgroup_parties(role_id);
CREATE OR REPLACE INDEX pm_users_viewed_viewed_user_inx ON pm_users_viewed(viewed_user);
CREATE OR REPLACE INDEX pm_users_viewed_viewing_user_inx ON pm_users_viewed(viewing_user);
CREATE OR REPLACE INDEX pm_tasks_process_instance_inx ON pm_tasks(process_instance);
CREATE OR REPLACE INDEX pm_tasks_status_inx ON pm_tasks(status);
CREATE OR REPLACE INDEX pm_task_xref_task_id_2_inx ON pm_task_xref(task_id_2);
CREATE OR REPLACE INDEX pm_task_xref_task_id_1_inx ON pm_task_xref(task_id_1);
CREATE OR REPLACE INDEX pm_task_logger_proj_map_logger_entry_inx ON pm_task_logger_proj_map(logger_entry);
CREATE OR REPLACE INDEX pm_task_dependency_dependency_type_inx ON pm_task_dependency(dependency_type);
CREATE OR REPLACE INDEX pm_task_dependency_parent_task_id_inx ON pm_task_dependency(parent_task_id);
CREATE OR REPLACE INDEX pm_task_assignment_party_id_inx ON pm_task_assignment(party_id);
CREATE OR REPLACE INDEX pm_task_assignment_role_id_inx ON pm_task_assignment(role_id);
CREATE OR REPLACE INDEX pm_projects_logger_project_inx ON pm_projects(logger_project);
CREATE OR REPLACE INDEX pm_projects_status_id_inx ON pm_projects(status_id);
CREATE OR REPLACE INDEX pm_project_assignment_party_id_inx ON pm_project_assignment(party_id);
CREATE OR REPLACE INDEX pm_project_assignment_role_id_inx ON pm_project_assignment(role_id);
CREATE OR REPLACE INDEX pm_process_task_dependency_dependency_type_inx ON pm_process_task_dependency(dependency_type);
CREATE OR REPLACE INDEX pm_process_task_dependency_parent_task_id_inx ON pm_process_task_dependency(parent_task_id);
CREATE OR REPLACE INDEX pm_process_task_assignment_party_id_inx ON pm_process_task_assignment(party_id);
CREATE OR REPLACE INDEX pm_process_task_assignment_role_id_inx ON pm_process_task_assignment(role_id);
CREATE OR REPLACE INDEX pm_process_task_mime_type_inx ON pm_process_task(mime_type);
CREATE OR REPLACE INDEX pm_process_task_process_id_inx ON pm_process_task(process_id);
CREATE OR REPLACE INDEX pm_process_instance_project_item_id_inx ON pm_process_instance(project_item_id);
CREATE OR REPLACE INDEX pm_process_instance_process_id_inx ON pm_process_instance(process_id);
CREATE OR REPLACE INDEX pm_process_party_id_inx ON pm_process(party_id);
CREATE OR REPLACE INDEX pm_default_roles_party_id_inx ON pm_default_roles(party_id);
CREATE OR REPLACE INDEX pm_project_assignment_project_id ON pm_project_assignment(project_id);
CREATE OR REPLACE INDEX pm_task_dependency_task_id ON pm_task_dependency(task_id);
CREATE OR REPLACE INDEX pm_project_status_status_type_inx ON pm_project_status(status_type);
