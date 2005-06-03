create function inline_0 ()
returns integer as '
declare
    lp RECORD;
begin
  for lp in select logger_project, item_id, creation_user, creation_ip
            from pm_projectsx
  loop
    select acs_rel__new (
                         null,
                         'application_data_link',
                         lp.item_id,
                         lp.logger_project,
                         lp.item_id,
                         lp.creation_user,
                         lp.creation_ip
    );

    select acs_rel__new (
                         null,
                         'application_data_link',
                         lp.logger_project,
                         lp.item_id,
                         lp.item_id,
                         lp.creation_user,
                         lp.creation_ip
    );
  end loop;
end;' language 'plpgsql';

select inline_0();
drop function inline_0();


alter table pm_projects drop column logger_project cascade;

drop table pm_task_logger_proj_map;

select define_function_args('pm_project__new_project_item', 'project_name, project_code, parent_id, goal, description, mime_type, planned_start_date, planned_end_date, actual_start_date, actual_end_date, ongoing_p, status_id, customer_id, creation_date, creation_user, creation_ip, package_id');

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
        p_ongoing_p                             alias for $11;
        p_status_id                             alias for $12;
        p_customer_id                           alias for $13;
        p_creation_date                         alias for $14;
        p_creation_user                         alias for $15;
        p_creation_ip                           alias for $16;
        p_package_id                            alias for $17;

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
                ''pm_project'',         -- item_subtype
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
                ongoing_p, estimated_finish_date, 
                earliest_finish_date, latest_finish_date,
                actual_hours_completed, 
                estimated_hours_total, status_id, customer_id) 
        values (
                v_revision_id, p_project_code, 
                p_goal, p_planned_start_date, 
                p_planned_end_date, p_actual_start_date, 
                p_actual_end_date, p_ongoing_p, 
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


select define_function_args('pm_project__new_project_revision', 'item_id, project_name, project_code, parent_id, goal, description, planned_start_date, planned_end_date, actual_start_date, actual_end_date, ongoing_p, status_id, organization_id, creation_date, creation_user, creation_ip, package_id');

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
        p_ongoing_p                             alias for $11;
        p_status_id                             alias for $12;
        p_customer_id                           alias for $13;
        p_creation_date                         alias for $14;
        p_creation_user                         alias for $15;
        p_creation_ip                           alias for $16;
        p_package_id                            alias for $17;

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
                ongoing_p, status_id, customer_id) 
        values (
                v_revision_id, p_project_code, 
                p_goal, p_planned_start_date, 
                p_planned_end_date, p_actual_start_date, 
                p_actual_end_date, 
                p_ongoing_p, p_status_id, p_customer_id);

        PERFORM acs_permission__grant_permission(
                v_revision_id,
                p_creation_user,
                ''admin''
        );

        return v_revision_id;
end;' language 'plpgsql';


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
                ''pm_task'',            -- item_subtype
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

        update acs_objects set context_id = p_project_id where object_id = task_id;

        PERFORM acs_permission__grant_permission(
                v_revision_id,
                p_creation_user,
                ''admin''
        );

        return v_revision_id;
end;' language 'plpgsql';
