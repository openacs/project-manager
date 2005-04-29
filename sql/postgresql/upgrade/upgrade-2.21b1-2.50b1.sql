-- 
-- 
-- 
-- @author Jade Rubick (jader@bread.com)
-- @creation-date 2004-10-11
-- @arch-tag: b03e1fb8-aee1-4429-b6fd-e3e754a5f30a
-- @cvs-id $Id$
--

-- each time a process is used, it creates an instance of that process
-- we use this to allow a user to see overviews of process status, etc..

create sequence pm_process_instance_seq start 1;

create table pm_process_instance (
        instance_id                     integer
                                        constraint pm_process_instance_id_pk
                                        primary key,
        name                            varchar(200),
        process_id                      integer
                                        constraint pm_process_instance_process_fk
                                        references pm_process on delete cascade,
        project_item_id                 integer
                                        constraint pm_process_project_fk
                                        references cr_items
);

alter table pm_tasks add column 
        process_instance        integer
                                constraint pm_tasks_process_instance_fk
                                references pm_process_instance;

drop view pm_tasks_active;

CREATE view 
  pm_tasks_active as 
  SELECT task_id, task_number, status, process_instance FROM pm_tasks where deleted_p = 'f';


select define_function_args('pm_task__new_task_item', 'project_id, title, description, html_p, end_date, percent_complete, estimated_hours_work, estimated_hours_work_min, estimated_hours_work_max, status_id, process_instance_id, creation_date, creation_user, creation_ip, package_id');

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
        integer         -- package_id
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
                task_revision_id, end_date, percent_complete, estimated_hours_work, estimated_hours_work_min, estimated_hours_work_max, actual_hours_worked)
        values (
                v_revision_id, p_end_date, p_percent_complete, p_estimated_hours_work, p_estimated_hours_work_min, p_estimated_hours_work_max, ''0'');

        PERFORM acs_permission__grant_permission(
                v_revision_id,
                p_creation_user,
                ''admin''
        );

        return v_revision_id;
end;' language 'plpgsql';


alter table pm_process_task add column
      mime_type     varchar(200)
                    constraint pm_process_task_mime_type_fk
                    references cr_mime_types(mime_type)
                    on update no action on delete no action;

alter table pm_process_task alter column mime_type set default 'text/plain';

update pm_process_task set mime_type = 'text/plain';

alter table pm_process add column 
        deleted_p char(1);

alter table pm_process alter column deleted_p set default 'f';

update pm_process set deleted_p = 'f';

alter table pm_process add constraint pm_process_deleted_p_ck
  check (deleted_p in ('t','f'));


create or replace view 
pm_process_active as 
  SELECT *  FROM pm_process where deleted_p = 'f';
