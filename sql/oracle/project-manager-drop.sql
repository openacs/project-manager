-- packages/project-manager/sql/project-manager-drop.sql
-- drop script
--
-- @author jade@bread.com
-- @creation-date 2003-05-15
-- @cvs-id $Id$
--

--------
-- TASKS
--------

@project-manager-custom-drop.sql
@project-manager-notifications-drop.sql

drop table pm_task_logger_proj_map;

declare
begin
        for row in (select 
                item_id
                from 
                cr_items
                where 
                content_type = 'pm_task')
        LOOP
                pm_task.delete_task_item(row.item_id);
        end loop;
end;
/
show errors

-- unregister content_types from folder
declare
    v_folder_id   cr_folders.folder_id%TYPE;
    v_item_id     cr_items.item_id%TYPE;
begin
    -- delete all contents of projects folder
    FOR row IN
        (select
        item_id
        from
        cr_items
        where
        content_type = 'pm_task')
    LOOP
        pm_task.delete_task_item(row.item_id);
    END LOOP;

    -- this table must not hold reference to 'pm_tasks' type
    delete from cr_folder_type_map where content_type = 'pm_tasks';
end;
/
show errors


-- unregister content_types from folder
declare
    v_folder_id   cr_folders.folder_id%TYPE;
    v_item_id     cr_items.item_id%TYPE;
begin
    -- delete all contents of projects folder
    FOR row IN
        (select
        item_id
        from
        cr_items
        where
        content_type = 'pm_project')
    LOOP
        pm_project.delete_project_item(row.item_id);
    END LOOP;
end;
/
show errors


-- unregister content_types from folder
declare
    v_folder_id   cr_folders.folder_id%TYPE;
    v_item_id     cr_items.item_id%TYPE;
begin
    FOR row IN 
        (select folder_id from cr_folders where description='Project Repository' )
    LOOP
    content_folder.unregister_content_type (
        row.folder_id,   -- folder_id
        'pm_project',         -- content_type
        't'                   -- include_subtypes
    );
    content_folder.del(row.folder_id);
    END LOOP;

    -- this table must not hold reference to 'pm_project' type
    delete from cr_folder_type_map where content_type = 'pm_project';
end;
/
show errors


-- task dependency types
drop table pm_task_dependency_types cascade constraints;
drop table pm_task_dependency cascade constraints;
drop sequence pm_task_dependency_seq;
drop sequence pm_tasks_number_seq;

begin
content_type.drop_attribute ('pm_task', 'end_date', 't');
content_type.drop_attribute ('pm_task', 'percent_complete', 't');
content_type.drop_attribute ('pm_task', 'estimated_hours_work', 't');
content_type.drop_attribute ('pm_task', 'estimated_hours_work_min', 't');
content_type.drop_attribute ('pm_task', 'estimated_hours_work_max', 't');
content_type.drop_attribute ('pm_task', 'actual_hours_worked', 't');
content_type.drop_attribute ('pm_task', 'earliest_start', 't');
content_type.drop_attribute ('pm_task', 'earliest_finish', 't');
content_type.drop_attribute ('pm_task', 'latest_start', 't');
content_type.drop_attribute ('pm_task', 'latest_finish', 't');
end;
/
show errors

-------------
-- WORKGROUPS
-------------

drop sequence pm_workgroup_seq;
drop table pm_workgroup_parties;
drop table pm_workgroup;

------------
-- PROCESSES
------------

drop sequence pm_process_seq;
drop sequence pm_process_task_seq;
drop sequence pm_process_task_dependency_seq;

drop table pm_process_task_assignment cascade constraints;
drop table pm_process_task_dependency cascade constraints;
drop table pm_process_task cascade constraints;
drop table pm_process cascade constraints;

---------
-- OTHERS
---------
drop table pm_default_roles cascade constraints;
drop table pm_project_assignment cascade constraints;
drop table pm_task_assignment cascade constraints;
drop table pm_roles cascade constraints;
drop sequence pm_role_seq;


drop package pm_task;


-----------
-- PROJECTS
-----------

--drop permissions
delete from acs_permissions where object_id in (select project_id from pm_projects);


-- drop package, which drops all functions created with define_function_args
drop package pm_project;

--drop table
drop table pm_projects cascade constraints;

drop sequence pm_project_status_seq;
drop table pm_project_status cascade constraints;



drop sequence pm_task_status_seq;
drop table pm_task_status cascade constraints;

drop table pm_tasks cascade constraints;
drop table pm_tasks_revisions cascade constraints;

begin
content_type.drop_type('pm_task', 't', 'f');
content_type.drop_type('pm_project', 't', 'f');
end;
/
show errors

drop table pm_task_xref cascade constraints; 
drop table pm_users_viewed cascade constraints;
drop sequence pm_process_instance_seq;
drop table pm_process_instance cascade constraints;
-- note that the Project Repository folder is not deleted

