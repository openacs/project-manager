-- 
-- Upgrade script for project-manager 1.03
-- 
-- @author Jade Rubick (jader@bread.com)
-- @creation-date 2004-05-14
-- @cvs-id $Id$
--

-- the only change in this function is to change the project when
-- editing tasks. Previously, it would always leave the task in the
-- same project.

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
        integer         -- package_id
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
                task_revision_id, end_date, percent_complete, estimated_hours_work, estimated_hours_work_min, estimated_hours_work_max, actual_hours_worked)
        values (
                v_revision_id, p_end_date, p_percent_complete, p_estimated_hours_work, p_estimated_hours_work_min, p_estimated_hours_work_max, p_actual_hours_worked);

        update pm_tasks set status = p_status_id where task_id = p_task_id;

        PERFORM acs_permission__grant_permission(
                v_revision_id,
                p_creation_user,
                ''admin''
        );

        return v_revision_id;
end;' language 'plpgsql';
