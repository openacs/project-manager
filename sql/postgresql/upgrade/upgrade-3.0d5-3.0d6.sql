select define_function_args('pm_task__new_task_item', 'project_id, task_id, title, description, html_p, end_date, percent_complete, estimated_hours_work, estimated_hours_work_min, estimated_hours_work_max, status_id, process_instance_id, dform, creation_date, creation_user, creation_ip, package_id, priority');

create or replace function pm_task__new_task_item (
        integer,        -- project_id
        integer,        -- task_id
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
        varchar,        -- dform
        timestamptz,    -- creation_date
        integer,        -- creation_user
        varchar,        -- creation_ip
        integer,        -- package_id
	integer		-- priority
) returns integer 
as '
declare
        p_project_id                            alias for $1;
        p_task_id                               alias for $2;
        p_title                                 alias for $3;
        p_description                           alias for $4;
        p_mime_type                             alias for $5;
        p_end_date                              alias for $6;
        p_percent_complete                      alias for $7;
        p_estimated_hours_work                  alias for $8;
        p_estimated_hours_work_min              alias for $9;
        p_estimated_hours_work_max              alias for $10;
        p_status_id                             alias for $11;
        p_process_instance_id                   alias for $12;
        p_dform                                 alias for $13;
        p_creation_date                         alias for $14;
        p_creation_user                         alias for $15;
        p_creation_ip                           alias for $16;
        p_package_id                            alias for $17;
        p_priority                              alias for $18;

        v_item_id               cr_items.item_id%TYPE;
        v_revision_id           cr_revisions.revision_id%TYPE;
        v_task_number           integer;
begin
        -- We want to put the task under the project item

        -- create the task_number
        
        v_item_id := content_item__new (
                p_task_id::varchar      -- name
                p_project_id,           -- parent_id
                p_task_id,              -- item_id
                null,                   -- locale
                now(),                  -- creation_date
                p_creation_user,        -- creation_user
                p_package_id,           -- context_id
                p_creation_ip,          -- creation_ip
                ''pm_task'',            -- item_subtype
                ''pm_task'',            -- content_type
                p_title,                -- title
                p_description,          -- description
                p_mime_type,            -- mime_type
                null,                   -- nls_language
                null,                   -- data
                p_package_id            -- package_id
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
                p_creation_ip,          -- creation_ip
                p_package_id            -- package_id
        );

        PERFORM content_item__set_live_revision (v_revision_id);

        insert into pm_tasks (
                task_id, task_number, status, process_instance)
        values (
                v_item_id, v_task_number, p_status_id, p_process_instance_id);

        insert into pm_tasks_revisions (
                task_revision_id, end_date, percent_complete, estimated_hours_work, estimated_hours_work_min, estimated_hours_work_max, actual_hours_worked, priority, dform)
        values (
                v_revision_id, p_end_date, p_percent_complete, p_estimated_hours_work, p_estimated_hours_work_min, p_estimated_hours_work_max, ''0'', p_priority, p_dform);

        update acs_objects set context_id = p_project_id where object_id = v_item_id;

        PERFORM acs_permission__grant_permission(
                v_revision_id,
                p_creation_user,
                ''admin''
        );

        return v_revision_id;
end;' language 'plpgsql';

select define_function_args('pm_task__new_task_item', 'project_id, title, description, html_p, end_date, percent_complete, estimated_hours_work, estimated_hours_work_min, estimated_hours_work_max, status_id, process_instance_id, dform, creation_date, creation_user, creation_ip, package_id, priority');

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
        varchar,        -- dform
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
        p_dform                                 alias for $12;
        p_creation_date                         alias for $13;
        p_creation_user                         alias for $14;
        p_creation_ip                           alias for $15;
        p_package_id                            alias for $16;
        p_priority                              alias for $17;

        v_task_id               cr_items.item_id%TYPE;
        v_revision_id           cr_revisions.revision_id%TYPE;
begin
        select acs_object_id_seq.nextval into v_task_id from dual;

        v_revision_id := pm_task__new_task_item (
                p_project_id,                 -- project_id
                v_task_id,                    -- task_item_id
                p_title,                      -- title
                p_description,                -- description
                p_mime_type,                  -- mime_type
                p_end_date,                   -- end_date
                p_percent_complete,           -- percent_complete
                p_estimated_hours_work,       -- estimated_hours_work
                p_estimated_hours_work_min,   -- estimated_hours_work_min
                p_estimated_hours_work_max,   -- estimated_hours_work_max
                p_status_id,                  -- status_id
                p_process_instance_id,        -- process_instance_id
                p_dform,                      -- dfom
                p_creation_date,              -- creation_date
                p_creation_user,              -- creation_user
                p_creation_ip,                -- creation_ip
                p_package_id,                 -- package_id
                p_priority                    -- priority
        );

        return v_revision_id;
end;' language 'plpgsql';
