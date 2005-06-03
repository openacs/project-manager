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

\i project-manager-custom-drop.sql
\i project-manager-notifications-drop.sql

create function inline_0 ()
returns integer as '
declare
    v_item RECORD;
        
begin
        for v_item in select 
                item_id
                from 
                cr_items
                where 
                content_type = ''pm_task''
        LOOP
                PERFORM pm_task__delete_task_item(v_item.item_id);
        end loop;

    return 0;
end;
' language 'plpgsql';

select inline_0();
drop function inline_0();

-- unregister content_types from folder
create function inline_0 ()
returns integer as '
declare
    v_folder_id   cr_folders.folder_id%TYPE;
    v_item_id     cr_items.item_id%TYPE;
    v_item_cursor RECORD;
begin

    -- delete all contents of projects folder
    FOR v_item_cursor IN
        select
        item_id
        from
        cr_items
        where
        content_type = ''pm_task''
    LOOP
        PERFORM pm_project__delete_task_item(v_item_cursor.item_id);
    END LOOP;

    -- this table must not hold reference to ''pm_tasks'' type
    delete from cr_folder_type_map where content_type = ''pm_tasks'';

    return 0;
end;
' language 'plpgsql';

select inline_0();
drop function inline_0();

-- unregister content_types from folder
create function inline_0 ()
returns integer as '
declare
    v_folder_id   cr_folders.folder_id%TYPE;
    v_item_id     cr_items.item_id%TYPE;
    v_item_cursor RECORD;
begin

    -- delete all contents of projects folder
    FOR v_item_cursor IN
        select
        item_id
        from
        cr_items
        where
        content_type = ''pm_project''
    LOOP
        PERFORM pm_project__delete_project_item(v_item_cursor.item_id);
    END LOOP;

    return 0;
end;
' language 'plpgsql';

select inline_0();
drop function inline_0();

-- unregister content_types from folder
create function inline_0 ()
returns integer as '
declare
    v_folder_id   cr_folders.folder_id%TYPE;
    v_item_id     cr_items.item_id%TYPE;
    v_item_cursor RECORD;
begin

    FOR v_item_cursor IN 
        select folder_id from cr_folders where description=''Project Repository'' 
    LOOP
    PERFORM content_folder__unregister_content_type (
        v_item_cursor.folder_id,   -- folder_id
        ''pm_project'',         -- content_type
        ''t''                   -- include_subtypes
    );
    PERFORM content_folder__delete(v_item_cursor.folder_id);
    END LOOP;

    -- this table must not hold reference to ''pm_project'' type
    delete from cr_folder_type_map where content_type = ''pm_project'';

    return 0;
end;
' language 'plpgsql';

select inline_0();
drop function inline_0();


-- task dependency types
drop table pm_task_dependency_types cascade;
drop table pm_task_dependency cascade;
drop sequence pm_task_dependency_seq;
drop sequence pm_tasks_number_seq;

select content_type__drop_attribute ('pm_task', 'end_date', 't');
select content_type__drop_attribute ('pm_task', 'percent_complete', 't');
select content_type__drop_attribute ('pm_task', 'estimated_hours_work', 't');
select content_type__drop_attribute ('pm_task', 'estimated_hours_work_min', 't');
select content_type__drop_attribute ('pm_task', 'estimated_hours_work_max', 't');
select content_type__drop_attribute ('pm_task', 'actual_hours_worked', 't');
select content_type__drop_attribute ('pm_task', 'earliest_start', 't');
select content_type__drop_attribute ('pm_task', 'earliest_finish', 't');
select content_type__drop_attribute ('pm_task', 'latest_start', 't');
select content_type__drop_attribute ('pm_task', 'latest_finish', 't');

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

drop table pm_process_task_assignment cascade;
drop table pm_process_task_dependency cascade;
drop table pm_process_task cascade;
drop table pm_process cascade;

---------
-- OTHERS
---------
drop table pm_default_roles cascade;
drop table pm_project_assignment cascade;
drop table pm_task_assignment cascade;
drop table pm_roles cascade;
drop sequence pm_role_seq cascade;


select drop_package('pm_task');


-----------
-- PROJECTS
-----------

--drop permissions
delete from acs_permissions where object_id in (select project_id from pm_projects);


-- drop package, which drops all functions created with define_function_args
select drop_package('pm_project');

--drop table
drop table pm_projects cascade;

drop sequence pm_project_status_seq;
drop table pm_project_status cascade;



drop sequence pm_task_status_seq;
drop table pm_task_status cascade;

drop table pm_tasks cascade;
drop table pm_tasks_revisions cascade;

select content_type__drop_type('pm_task', 't', 'f');

select content_type__drop_type('pm_project', 't', 'f');

drop table pm_task_xref cascade;
drop table pm_users_viewed cascade;
drop sequence pm_process_instance_seq;
drop table pm_process_instance cascade;
drop table pm_process cascade;
-- note that the Project Repository folder is not deleted

