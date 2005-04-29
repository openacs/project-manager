--
-- packages/project-manager/sql/postgresql/project-manager-functions-create.sql
--
-- @author jade@bread.com, ncarroll@ee.usyd.edu.au
-- @creation-date 2003-05-15
-- @cvs-id $Id$
--
--

-- When we created the acs object type above, we specified a
-- 'name_method'.  This is the name of a function that will return the
-- name of the object.  This is a convention ensuring that all objects
-- can be identified.  Now we have to build that function.  In this case,
-- we'll return a field called title as the name. 

select define_function_args('pm_project__name', 'project_id');

create or replace function pm_project__name (integer)
returns varchar as '
declare
    p_pm_project_id      alias for $1;
    v_pm_project_name    pm_projectsx.name%TYPE;
begin
        select name || ''_'' || p_pm_project_id into v_pm_project_name
                from pm_projectsx
                where item_id = p_pm_project_id;
    return v_pm_project_name;
end;
' language 'plpgsql';


-- Create a new root folder

select define_function_args('pm_project__new_root_folder', 'package_id');

create or replace function pm_project__new_root_folder (integer)
returns integer as '
declare
        p_package_id            alias for $1;

        v_folder_id             cr_folders.folder_id%TYPE;
        v_folder_name           cr_items.name%TYPE;
begin

        -- raise notice ''in new root folder'';

        -- Set the folder name
        v_folder_name := pm_project__new_unique_name (p_package_id);

        v_folder_id := content_folder__new (
            v_folder_name,                              -- name
            ''Projects'',                               -- label
            ''Project Repository'',                     -- description
            null,                                       -- parent_id
            p_package_id,                               -- context_id
            null,                                       -- folder_id
            null,                                       -- creation_date
            null,                                       -- creation_user
            null                                        -- creation_ip
        );

        -- Register the standard content types
        PERFORM content_folder__register_content_type (
                v_folder_id,            -- folder_id
                ''pm_project'',         -- content_type
                ''f''                   -- include_subtypes
        );

        -- there is no facility in the API for adding in the package_id,
        -- so we have to do it ourselves

        update cr_folders 
        set package_id = p_package_id 
        where folder_id = v_folder_id;

        -- TODO: Handle Permissions here for this folder.

        return v_folder_id;
end;' language 'plpgsql';


-- Returns the root folder corresponding to a particular package instance.
-- Creates a new root folder if one does not exist for the specified package
-- instance.

select define_function_args('pm_project__get_root_folder', 'package_id,create_if_not_present_p');

create or replace function pm_project__get_root_folder (integer, boolean)
returns integer as '
declare
        p_package_id            alias for $1;
        p_create_if_not_present_p alias for $2;

        v_folder_id             cr_folders.folder_id%TYPE;
        v_count                 integer;
begin

        -- raise notice ''in get root folder p_create_if_not_present_p = %'',p_create_if_not_present_p;

        select count(*) into v_count
        from cr_folders
        where package_id = p_package_id;

        -- raise notice ''count is % for package_id %'', v_count, p_package_id;

        if v_count > 1 then
                raise exception ''More than one project repository for this application instance'';
        elsif v_count = 1 then
                select folder_id into v_folder_id
                from cr_folders 
                where package_id = p_package_id;
        else
                if p_create_if_not_present_p = true then
                        -- Must be a new instance.  Create a new root folder.
                        raise notice ''creating a new root repository folder'';
                        v_folder_id := pm_project__new_root_folder(p_package_id);
                else
                        -- raise notice ''setting to null'';
                        v_folder_id := null;
                end if;
        end if;

        -- raise notice ''v_folder_id is %'', v_folder_id;

        return v_folder_id;

end; ' language 'plpgsql';


-- Create a project item.

-- A project item should be placed within a folder.  Therefore a new project
-- item is associated with creating a new project folder that will contain
-- the project item.  A new root project folder will be created if parent_id
-- is null.  Otherwise a project folder will be created as a sub-folder
-- of an existing project folder.

select define_function_args('pm_project__new_project_item', 'project_name, project_code, parent_id, goal, description, mime_type, planned_start_date, planned_end_date, actual_start_date, actual_end_date, logger_project, ongoing_p, status_id, customer_id, creation_date, creation_user, creation_ip, package_id');

create or replace function pm_project__new_project_item (
        varchar,        -- project_name
        varchar,        -- project_code
        integer,        -- parent_id
        varchar,        -- goal
        varchar,        -- description
        varchar,        -- mime_type
        timestamptz,    -- planned_start_date
        timestamptz,    -- planned_end_date
        timestamptz,    -- actual_start_date
        timestamptz,    -- actual_end_date
        integer,        -- logger_project
        char(1),        -- ongoing_p
        integer,        -- status_id
        integer,        -- customer_id (organization_id)
        timestamptz,    -- creation_date
        integer,        -- creation_user
        varchar,        -- creation_ip
        integer         -- package_id
) returns integer 
as '
declare
        p_project_name                          alias for $1;
        p_project_code                          alias for $2;
        p_parent_id                             alias for $3;
        p_goal                                  alias for $4;
        p_description                           alias for $5;
        p_mime_type                             alias for $6;
        p_planned_start_date                    alias for $7;
        p_planned_end_date                      alias for $8;
        p_actual_start_date                     alias for $9;
        p_actual_end_date                       alias for $10;
        p_logger_project                        alias for $11;
        p_ongoing_p                             alias for $12;
        p_status_id                             alias for $13;
        p_customer_id                           alias for $14;
        p_creation_date                         alias for $15;
        p_creation_user                         alias for $16;
        p_creation_ip                           alias for $17;
        p_package_id                            alias for $18;

        v_item_id               cr_items.item_id%TYPE;
        v_revision_id           cr_revisions.revision_id%TYPE;
        v_id                    cr_items.item_id%TYPE;
        v_parent_id             cr_items.parent_id%TYPE;
begin
        select acs_object_id_seq.nextval into v_id from dual;

        v_parent_id := pm_project__get_root_folder (p_package_id, ''t'');

        -- raise notice ''v_parent_id (%) p_parent_id (%)'', v_parent_id, p_parent_id;

        if p_parent_id is not null
        then
                v_parent_id = p_parent_id;
        end if;

        -- raise notice ''v_parent_id (%) p_parent_id (%)'', v_parent_id, p_parent_id;

        v_item_id := content_item__new (
                v_id::varchar,          -- name
                v_parent_id,            -- parent_id
                v_id,                   -- item_id
                null,                   -- locale
                now(),                  -- creation_date
                p_creation_user,        -- creation_user
                p_parent_id,            -- context_id
                p_creation_ip,          -- creation_ip
                ''content_item'',       -- item_subtype
                ''pm_project'',         -- content_type
                p_project_name,         -- title
                p_description,          -- description
                p_mime_type,            -- mime_type
                null,                   -- nls_language
                null                    -- data
        );

        v_revision_id := content_revision__new (
                p_project_name,         -- title
                p_description,          -- description
                now(),                  -- publish_date
                p_mime_type,            -- mime_type
                NULL,                   -- nls_language
                NULL,                   -- data
                v_item_id,              -- item_id
                NULL,                   -- revision_id
                now(),                  -- creation_date
                p_creation_user,        -- creation_user
                p_creation_ip           -- creation_ip
        );

        PERFORM content_item__set_live_revision (v_revision_id);

        insert into pm_projects (
                project_id, project_code, 
                goal, planned_start_date, 
                planned_end_date, actual_start_date, actual_end_date, 
                logger_project, ongoing_p, estimated_finish_date, 
                earliest_finish_date, latest_finish_date,
                actual_hours_completed, 
                estimated_hours_total, status_id, customer_id) 
        values (
                v_revision_id, p_project_code, 
                p_goal, p_planned_start_date, 
                p_planned_end_date, p_actual_start_date, 
                p_actual_end_date, p_logger_project, p_ongoing_p, 
                p_planned_end_date,
                p_planned_end_date, p_planned_end_date, ''0'',
                ''0'', p_status_id, p_customer_id
                );

        PERFORM acs_permission__grant_permission(
                v_revision_id,
                p_creation_user,
                ''admin''
        );

        return v_revision_id;
end;' language 'plpgsql';


-- The delete function deletes a record and all related overhead. 

select define_function_args('pm_project__delete_project_item', 'project_id');

create or replace function pm_project__delete_project_item (integer)
returns integer as '
declare
        p_project_id                            alias for $1;
        v_child                                 cr_items%ROWTYPE;
begin
        raise NOTICE ''Deleting pm_project...'';

        for v_child in select 
                item_id
                from 
                cr_items
                where 
                parent_id = p_project_id and
                content_type = ''pm_project''
        LOOP
                PERFORM pm_project__delete_project_item(v_child.item_id);
        end loop;

        delete from pm_projects where project_id in (select revision_id from pm_projectsx where item_id = p_project_id);

        PERFORM content_item__delete(p_project_id);
        return 0;
end;' language 'plpgsql';


select define_function_args('pm_project__new_project_revision', 'item_id, project_name, project_code, parent_id, goal, description, planned_start_date, planned_end_date, actual_start_date, actual_end_date, logger_project, ongoing_p, status_id, organization_id, creation_date, creation_user, creation_ip, package_id');

create or replace function pm_project__new_project_revision (
        integer,        -- item_id
        varchar,        -- project_name
        varchar,        -- project_code
        integer,        -- parent_id
        varchar,        -- goal
        varchar,        -- description
        timestamptz,    -- planned_start_date
        timestamptz,    -- planned_end_date
        timestamptz,    -- actual_start_date
        timestamptz,    -- actual_end_date
        integer,        -- logger_project
        char(1),        -- ongoing_p
        integer,        -- status_id
        integer,        -- organization_id (customer)
        timestamptz,    -- creation_date
        integer,        -- creation_user
        varchar,        -- creation_ip
        integer         -- package_id
) returns integer 
as '
declare
        p_item_id                               alias for $1;
        p_project_name                          alias for $2;
        p_project_code                          alias for $3;
        p_parent_id                             alias for $4;
        p_goal                                  alias for $5;
        p_description                           alias for $6;
        p_planned_start_date                    alias for $7;
        p_planned_end_date                      alias for $8;
        p_actual_start_date                     alias for $9;
        p_actual_end_date                       alias for $10;
        p_logger_project                        alias for $11;
        p_ongoing_p                             alias for $12;
        p_status_id                             alias for $13;
        p_customer_id                           alias for $14;
        p_creation_date                         alias for $15;
        p_creation_user                         alias for $16;
        p_creation_ip                           alias for $17;
        p_package_id                            alias for $18;

        v_revision_id           cr_revisions.revision_id%TYPE;
begin

        -- the item_id is the project_id

        v_revision_id := content_revision__new (
                p_project_name,         -- title
                p_description,          -- description
                now(),                  -- publish_date
                ''text/plain'',         -- mime_type
                NULL,                   -- nls_language
                NULL,                   -- data
                p_item_id,              -- item_id
                NULL,                   -- revision_id
                now(),                  -- creation_date
                p_creation_user,        -- creation_user
                p_creation_ip           -- creation_ip
        );

        PERFORM content_item__set_live_revision (v_revision_id);

        insert into pm_projects (
                project_id, project_code, 
                goal, planned_start_date, 
                planned_end_date, actual_start_date, actual_end_date, 
                logger_project,
                ongoing_p, status_id, customer_id) 
        values (
                v_revision_id, p_project_code, 
                p_goal, p_planned_start_date, 
                p_planned_end_date, p_actual_start_date, 
                p_actual_end_date, 
                p_logger_project, p_ongoing_p, p_status_id, p_customer_id);

        PERFORM acs_permission__grant_permission(
                v_revision_id,
                p_creation_user,
                ''admin''
        );

        return v_revision_id;
end;' language 'plpgsql';



-- Creates and returns a unique name.

select define_function_args('pm_project__new_unique_name', 'package_id');

create or replace function pm_project__new_unique_name (integer)
returns text as '
declare
        p_package_id            alias for $1;

        v_name                  cr_items.name%TYPE;
        v_package_key           apm_packages.package_key%TYPE;
        v_id                    integer;
begin
        select package_key into v_package_key from apm_packages
            where package_id = p_package_id;

        select acs_object_id_seq.nextval into v_id from dual;

        -- Set the name
        select v_package_key || ''_'' || 
            to_char(current_timestamp, ''YYYYMMDD'') || ''_'' ||
            v_id into v_name;

        return v_name;
end;' language 'plpgsql';

----------------------------------
-- Tasks
----------------------------------

-- When we created the acs object type above, we specified a
-- 'name_method'.  This is the name of a function that will return the
-- name of the object.  This is a convention ensuring that all objects
-- can be identified.  Now we have to build that function.  In this case,
-- we'll return a field called title as the name. 

select define_function_args('pm_task__name', 'task_id');

create or replace function pm_task__name (integer)
returns varchar as '
declare
    p_pm_task_id         alias for $1;
    v_pm_task_name       cr_items.name%TYPE;
begin
        select i.name || ''_'' || p_pm_task_id into v_pm_task_name
                from cr_items i
                where i.item_id = p_pm_task_id;
    return v_pm_task_name;
end;
' language 'plpgsql';


-- Create a task item.

-- A task should be placed within a project or another task.
-- If it is not associated with a project, then it is placed in the root
-- project repository folder.

select define_function_args('pm_task__new_task_item', 'project_id, title, description, html_p, end_date, percent_complete, estimated_hours_work, estimated_hours_work_min, estimated_hours_work_max, status_id, process_instance_id, creation_date, creation_user, creation_ip, package_id, priority');

create or replace function pm_task__new_task_item (
        integer,        -- project_id
        varchar,        -- title
        varchar,        -- description
        varchar,        -- html_p
        timestamptz,    -- end_date
        numeric,        -- percent_complete
        numeric,        -- estimated_hours_work
        numeric,        -- estimated_hours_work_min
        numeric,        -- estimated_hours_work_max,
        integer,        -- status_id
        integer,        -- process_instance_id
        timestamptz,    -- creation_date
        integer,        -- creation_user
        varchar,        -- creation_ip
        integer,        -- package_id
	integer		-- priority
) returns integer 
as '
declare
        p_project_id                            alias for $1;
        p_title                                 alias for $2;
        p_description                           alias for $3;
        p_mime_type                             alias for $4;
        p_end_date                              alias for $5;
        p_percent_complete                      alias for $6;
        p_estimated_hours_work                  alias for $7;
        p_estimated_hours_work_min              alias for $8;
        p_estimated_hours_work_max              alias for $9;
        p_status_id                             alias for $10;
        p_process_instance_id                   alias for $11;
        p_creation_date                         alias for $12;
        p_creation_user                         alias for $13;
        p_creation_ip                           alias for $14;
        p_package_id                            alias for $15;
        p_priority                              alias for $16;

        v_item_id               cr_items.item_id%TYPE;
        v_revision_id           cr_revisions.revision_id%TYPE;
        v_id                    cr_items.item_id%TYPE;
        v_task_number           integer;
begin
        select acs_object_id_seq.nextval into v_id from dual;

        -- We want to put the task under the project item

        -- create the task_number
        
        v_item_id := content_item__new (
                v_id::varchar,          -- name
                p_project_id,           -- parent_id
                v_id,                   -- item_id
                null,                   -- locale
                now(),                  -- creation_date
                p_creation_user,        -- creation_user
                p_package_id,           -- context_id
                p_creation_ip,          -- creation_ip
                ''content_item'',       -- item_subtype
                ''pm_task'',            -- content_type
                p_title,                -- title
                p_description,          -- description
                p_mime_type,            -- mime_type
                null,                   -- nls_language
                null                    -- data
        );

        v_revision_id := content_revision__new (
                p_title,                -- title
                p_description,          -- description
                now(),                  -- publish_date
                p_mime_type,            -- mime_type
                NULL,                   -- nls_language
                NULL,                   -- data
                v_item_id,              -- item_id
                NULL,                   -- revision_id
                now(),                  -- creation_date
                p_creation_user,        -- creation_user
                p_creation_ip           -- creation_ip
        );

        PERFORM content_item__set_live_revision (v_revision_id);

        insert into pm_tasks (
                task_id, task_number, status, process_instance)
        values (
                v_item_id, v_task_number, p_status_id, p_process_instance_id);

        insert into pm_tasks_revisions (
                task_revision_id, end_date, percent_complete, estimated_hours_work, estimated_hours_work_min, estimated_hours_work_max, actual_hours_worked, priority)
        values (
                v_revision_id, p_end_date, p_percent_complete, p_estimated_hours_work, p_estimated_hours_work_min, p_estimated_hours_work_max, ''0'', p_priority);

        PERFORM acs_permission__grant_permission(
                v_revision_id,
                p_creation_user,
                ''admin''
        );

        return v_revision_id;
end;' language 'plpgsql';


select define_function_args('pm_task__new_task_revision', 'task_id, project_id, title, description, mime_type, end_date, percent_complete, estimated_hours_work, estimated_hours_work_min, estimated_hours_work_max, actual_hours_worked, creation_date, creation_user, creation_ip, package_id, priority');

create or replace function pm_task__new_task_revision (
        integer,        -- task_id (the item_id)
        integer,        -- project_id
        varchar,        -- title
        varchar,        -- description
        varchar,        -- mime_type
        timestamptz,    -- end_date
        numeric,        -- percent_complete
        numeric,        -- estimated_hours_work
        numeric,        -- estimated_hours_work_min
        numeric,        -- estimated_hours_work_max
        numeric,        -- actual_hours_worked
        integer,        -- status_id
        timestamptz,    -- creation_date
        integer,        -- creation_user
        varchar,        -- creation_ip
        integer,         -- package_id
	integer		-- priority
) returns integer 
as '
declare
        p_task_id                               alias for $1;
        p_project_id                            alias for $2;
        p_title                                 alias for $3;
        p_description                           alias for $4;
        p_mime_type                             alias for $5;
        p_end_date                              alias for $6;
        p_percent_complete                      alias for $7;
        p_estimated_hours_work                  alias for $8;
        p_estimated_hours_work_min              alias for $9;
        p_estimated_hours_work_max              alias for $10;
        p_actual_hours_worked                   alias for $11;
        p_status_id                             alias for $12;
        p_creation_date                         alias for $13;
        p_creation_user                         alias for $14;
        p_creation_ip                           alias for $15;
        p_package_id                            alias for $16;
        p_priority                              alias for $17;
        v_revision_id           cr_revisions.revision_id%TYPE;
        v_id                    cr_items.item_id%TYPE;
begin
        select acs_object_id_seq.nextval into v_id from dual;

        -- We want to put the task under the project item
        update cr_items set parent_id = p_project_id where item_id = p_task_id;

        v_revision_id := content_revision__new (
                p_title,                -- title
                p_description,          -- description
                now(),                  -- publish_date
                p_mime_type,            -- mime_type
                NULL,                   -- nls_language
                NULL,                   -- data
                p_task_id,              -- item_id
                NULL,                   -- revision_id
                now(),                  -- creation_date
                p_creation_user,        -- creation_user
                p_creation_ip           -- creation_ip
        );

        PERFORM content_item__set_live_revision (v_revision_id);

        insert into pm_tasks_revisions (
                task_revision_id, end_date, percent_complete, estimated_hours_work, estimated_hours_work_min, estimated_hours_work_max, actual_hours_worked, priority)
        values (
                v_revision_id, p_end_date, p_percent_complete, p_estimated_hours_work, p_estimated_hours_work_min, p_estimated_hours_work_max, p_actual_hours_worked, p_priority);

        update pm_tasks set status = p_status_id where task_id = p_task_id;

        PERFORM acs_permission__grant_permission(
                v_revision_id,
                p_creation_user,
                ''admin''
        );

        return v_revision_id;
end;' language 'plpgsql';


-- The delete function deletes a record and all related overhead. 

select define_function_args('pm_task__delete_task_item', 'task_id');

create or replace function pm_task__delete_task_item (integer)
returns integer as '
declare
        p_task_id                               alias for $1;
begin
        delete from pm_tasks_revisions
                where task_revision_id in (select revision_id from pm_tasks_revisionsx where item_id = p_task_id);

        delete from pm_tasks
                where task_id = p_task_id;

        raise NOTICE ''Deleting pm_task...'';

        PERFORM content_item__delete(p_task_id);
        return 0;
end;' language 'plpgsql';
