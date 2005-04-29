alter table pm_tasks_revisions add column priority integer;
alter table pm_tasks_revisions alter column priority set default 0;
update pm_tasks_revisions set priority = 0;

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

drop view pm_tasks_revisionsx;

create or replace view pm_tasks_revisionsx as
 SELECT acs_objects.object_id, acs_objects.object_type, acs_objects.context_id, acs_objects.security_inherit_p, acs_objects.creation_user, acs_objects.creation_date, acs_objects.creation_ip, acs_objects.last_modified, acs_objects.modifying_user, acs_objects.modifying_ip, acs_objects.tree_sortkey, acs_objects.max_child_sortkey, cr.revision_id, cr.title, cr.item_id, cr.description, cr.publish_date, cr.mime_type, cr.nls_language, i.name, i.parent_id, pm_tasks_revisions.task_revision_id, pm_tasks_revisions.end_date, pm_tasks_revisions.percent_complete, pm_tasks_revisions.estimated_hours_work, pm_tasks_revisions.estimated_hours_work_min, pm_tasks_revisions.estimated_hours_work_max, pm_tasks_revisions.actual_hours_worked, pm_tasks_revisions.earliest_start, pm_tasks_revisions.earliest_finish, pm_tasks_revisions.latest_start, pm_tasks_revisions.latest_finish, pm_tasks_revisions.priority
   FROM acs_objects, cr_revisions cr, cr_items i, cr_text, pm_tasks_revisions
  WHERE acs_objects.object_id = cr.revision_id AND cr.item_id = i.item_id AND acs_objects.object_id = pm_tasks_revisions.task_revision_id;


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
