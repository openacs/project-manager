-- packages/project-manager/sql/postgresql/project-manager-table-create.sql
--
-- @author jader@bread.com
-- @author ncarroll@ee.usyd.edu.au was involved in creating the initial CR version
-- @author everyone else involved in this thread: http://openacs.org/forums/message-view?message_id=90742
-- @creation-date 2003-05-15
--

-- PROJECTS

create sequence pm_project_status_seq start with 3;

create table pm_project_status (
        status_id               integer
                                constraint pm_project_status_pk
                                primary key,
        description             varchar(100),
        -- closed or open
        status_type             char(1) default 'c'
                                constraint pm_projects_status_type_ck
                                check (status_type in ('c','o'))
);

insert into pm_project_status (status_id, description, status_type) values
(1, 'Open', 'o');
insert into pm_project_status (status_id, description, status_type) values
(2, 'Closed', 'c');


-- project revisions, items are kept in cr_items

create table pm_projects (
        project_id     integer
                                constraint pm_proj_rev_fk
                                references cr_revisions on delete cascade
                                constraint pm_proj_rev_pk
                                primary key,
        -- a user-specified project code
        project_code            varchar(255),
        goal                    varchar(4000),
        planned_start_date      date,
        planned_end_date        date,
        actual_start_date       date,
        actual_end_date         date,
        status_id               integer
                                constraint pm_projects_status_id_nn
                                not null
                                constraint pm_projects_status_id_fk
                                references pm_project_status,
        -- if ongoing_p is true, then actual_end_date must be null
        ongoing_p               char(1) default 'f' 
                                constraint pm_projects_ongoing_p_ck
                                check (ongoing_p in ('t','f')),
        estimated_finish_date   date,
        earliest_finish_date    date,
        latest_finish_date      date,
        -- denormalized, taken from logger
        actual_hours_completed  numeric,
        estimated_hours_total   numeric,
        -- The logger package keeps its own projects table
        logger_project          integer
                                constraint pm_projects_logger_pj_nn
                                not null
                                constraint pm_projects_logger_pj_fk
                                references logger_projects
);

-- create type
begin 
    content_type.create_type (
                      content_type  => 'pm_project',
                      supertype     => 'content_revision', 
                      pretty_name   => 'Project',  
                      pretty_plural => 'Projects', 
                      table_name    => 'pm_projects',     
                      id_column     => 'project_id',       
                      name_method   => 'pm_project.name'
                 );
end;
/
show errors

-- other fields are added in too. See the -custom script.


-- ROLES

create sequence pm_role_seq start with 4;

create table pm_roles (
        role_id                 integer
                                constraint pm_role_id_pk
                                primary key,
        one_line                varchar(100)
                                constraint pm_role_one_line_uq
                                unique,
        description             varchar(2000),
        sort_order              integer,
        is_observer_p           char(1) default 'f'
                                constraint pm_role_is_observer_ck
                                check (is_observer_p in ('t','f'))
);


comment on table pm_roles is '
  Roles represent the way in which a party participates in a project
  or task. For example, they could be a manager, or client, or
  participant.. The sort order determines what order it is displayed
  in.  The is_observer_p specifies whether they are directly
  responsible for the task, or are just observers on it. 
';

insert into pm_roles (role_id, one_line, description, sort_order) values ('1','Lead','Team members who are responsible for the completion of the project','10');
insert into pm_roles (role_id, one_line, description, sort_order) values ('2','Player','A person on the team responsible for completion of the project','20');
insert into pm_roles (role_id, one_line, description, sort_order, is_observer_p) values ('3','Watcher','A person interested in developments, possibly helping out on it.','30','t');


create table pm_default_roles (
        role_id                 integer
                                constraint pm_default_role_fk
                                references pm_roles
                                on delete cascade,
        party_id                integer
                                constraint pm_default_role_party_fk 
                                references parties(party_id)
                                on delete cascade,
        constraint pm_default_roles_uq
        unique (role_id, party_id)
);

comment on table pm_default_roles is '
  Specifies what role a person is a part of by default
';

-- PROJECT ASSIGNMENT

create table pm_project_assignment (
        project_id              integer
                                constraint pm_proj_role_map_project_fk
                                references cr_items
                                on delete cascade,
        role_id                 integer
                                constraint pm_project_role_map_role_fk
                                references pm_roles,
        party_id                integer
                                constraint pm_project_role_map_user_id_fk 
                                references parties(party_id)
                                on delete cascade,
        constraint pm_project_assignment_uq
        unique (project_id, role_id, party_id)
);


comment on table pm_project_assignment is '
  Maps who is a part of what project, and in what capacity
';


-- TASKS

-- we create two tables to store task information
-- the information that we keep revisions on is in the 
-- pm_task_revisions table, the rest is in pm_task

create sequence pm_task_status_seq start with 3;

create table pm_task_status (
        status_id               integer
                                constraint pm_task_status_pk
                                primary key,
        description             varchar(100),
        -- closed or open
        status_type             char(1) default 'c'
                                constraint pm_task_status_type_ck
                                check (status_type in ('c','o'))
);

insert into pm_task_status (status_id, description, status_type) values
(1, 'Open', 'o');
insert into pm_task_status (status_id, description, status_type) values
(2, 'Closed', 'c');


create sequence pm_tasks_number_seq;

create table pm_tasks (
        task_id                         integer
                                        constraint pm_tasks_task_id_fk
                                        references cr_items 
                                        on delete cascade
                                        constraint pm_task_task_id_pk
                                        primary key,
        task_number                     integer,
        status                          integer
                                        constraint pm_tasks_task_status_fk
                                        references pm_task_status,
        deleted_p                       char(1) default 'f'
                                        constraint pm_tasks_deleted_p_ck
                                        check (deleted_p in ('t','f'))
);

CREATE OR REPLACE view 
pm_tasks_active as 
  SELECT task_id, task_number, status FROM pm_tasks where deleted_p = 'f';


create table pm_tasks_revisions (
        task_revision_id                integer
                                        constraint pm_task_revs_id_fk
                                        references cr_revisions 
                                        on delete cascade
                                        constraint pm_task_revs_id_pk
                                        primary key,
        -- dates are optional, because it may be computed in reference
        -- to all other items, or simply not have a deadline
        end_date                        date,
        -- keep track of completion status
        percent_complete                numeric
                                        constraint pm_task_per_complete_gt_ck
                                        check(percent_complete >= 0)
                                        constraint pm_task_per_complete_lt_ck
                                        check(percent_complete <= 100),
        estimated_hours_work            numeric,
        -- PERT charts require minimum and maximum estimates
        -- these are optionally used
        estimated_hours_work_min        numeric,
        estimated_hours_work_max        numeric,
        -- this should be computed by checking with logger? The actual
        -- data should be in logger, logged by who did it, when etc..
        -- or we can create a separate table to keep track of task hours
        -- and make sure its data model is similar to logger? 
        actual_hours_worked             numeric,
        -- network diagram stuff, computed
        earliest_start                  date,
        earliest_finish                 date,
        latest_start                    date,
        latest_finish                   date
);

-- create the content type
begin 
    content_type.create_type (
                     content_type  => 'pm_task',                  
                     supertype     => 'content_revision',          
                     pretty_name   => 'Task',        
                     pretty_plural => 'Tasks', 
                     table_name    => 'pm_tasks_revisions',       
                     id_column     => 'task_revision_id',          
                     name_method   => 'pm_task__name'   
                 );
end;
/
show errors

-- add in attributes

declare 
    attribute_id  integer;
begin 
    attribute_id := content_type.create_attribute (
                     content_type   => 'pm_task', 
                     attribute_name => 'end_date', 
                     datatype       => 'date',     
                     pretty_name    => 'End date', 
                     pretty_plural  => 'End dates', 
                     sort_order     => null, 
                     default_value  => null, 
                     column_spec    => 'date' 
                 );

    attribute_id := content_type.create_attribute (
                    content_type   => 'pm_task', 
                    attribute_name => 'percent_complete', 
                    datatype       => 'number',           
                    pretty_name    => 'Percent complete', 
                    pretty_plural  => 'Percents complete', 
                    sort_order     => null, 
                    default_value  => null, 
                    column_spec    => 'numeric'
                 );

    attribute_id := content_type.create_attribute (
                     content_type   => 'pm_task', 
                     attribute_name => 'estimated_hours_work', 
                     datatype       => 'number',          
                     pretty_name    => 'Estimated hours work', 
                     pretty_plural  => 'Estimated hours work', 
                     sort_order     =>  null, 
                     default_value  =>  null, 
                     column_spec    => 'numeric'
    );

    attribute_id := content_type.create_attribute (
                     content_type   => 'pm_task', 
                     attribute_name => 'estimated_hours_work_min', 
                     datatype       => 'number',           
                     pretty_name    => 'Estimated minimum hours', 
                     pretty_plural  => 'Estimated minimum hours', 
                     sort_order     => null, 
                     default_value  => null,
                     column_spec    => 'numeric'
    );

    attribute_id := content_type.create_attribute (
                     content_type   => 'pm_task', 
                     attribute_name => 'estimated_hours_work_max', 
                     datatype       => 'number',          
                     pretty_name    => 'Estimated maximum hours', 
                     pretty_plural  => 'Estimated maximum hours',
                     sort_order     => null, 
                     default_value  => null, 
                     column_spec    => 'numeric'
    );

    attribute_id := content_type.create_attribute (   
                     content_type   => 'pm_task', 
                     attribute_name => 'actual_hours_worked', 
                     datatype       => 'number',  
                     pretty_name    => 'Actual hours worked', 
                     pretty_plural  => 'Actual hours worked', 
                     sort_order     => null, 
                     default_value  => null,
                     column_spec    => 'numeric' 
    );

    attribute_id := content_type.create_attribute (
                     content_type   => 'pm_task', 
                     attribute_name => 'earliest_start', 
                     datatype       => 'date',     
                     pretty_name    => 'Earliest start date', 
                     pretty_plural  => 'Earliest start dates', 
                     sort_order     => null, 
                     default_value  => null, 
                     column_spec    => 'date' 
    );

    attribute_id := content_type.create_attribute (
                     content_type   => 'pm_task', 
                     attribute_name => 'earliest_finish', 
                     datatype       => 'date',     
                     pretty_name    => 'Earliest finish date', 
                     pretty_plural  => 'Earliest finish dates', 
                     sort_order     => null, 
                     default_value  => null, 
                     column_spec    => 'date' 
    );

    attribute_id := content_type.create_attribute (    
                     content_type   => 'pm_task', 
                     attribute_name => 'latest_start', 
                     datatype       => 'date',     
                     pretty_name    => 'Latest start date', 
                     pretty_plural  => 'Latest start dates',
                     sort_order     => null, 
                     default_value  => null, 
                     column_spec    => 'date'
    );

    attribute_id := content_type.create_attribute (    
                     content_type   => 'pm_task', 
                     attribute_name => 'latest_finish', 
                     datatype       => 'date',   
                     pretty_name    => 'Latest finish date', 
                     pretty_plural  => 'Latest finish dates', 
                     sort_order     => null, 
                     default_value  => null, 
                     column_spec    => 'date'
    );
end;
/

show errors

create table pm_task_logger_proj_map (
        task_item_id    integer
                        constraint pm_task_log_proj_map_t_nn
                        not null
                        constraint pm_task_log_proj_map_t_fk
                        references pm_tasks
                        on delete cascade,
        logger_entry    integer
                        constraint pm_task_log_proj_map_l_nn
                        not null
                        constraint pm_task_log_proj_map_l_fk
                        references logger_entries
                        on delete cascade,
        constraint pm_task_logger_proj_map_uq
        unique (task_item_id, logger_entry)
);


-- DEPENDENCIES

-- dependency types
-- such as:
-- cannot start until Task X finishes
-- cannot start until Task X begins
-- cannot finish until Task X finishes
-- cannot finish until Task X begins

create table pm_task_dependency_types (
        short_name                      varchar(100)
                                        constraint pm_task_const_sn_pk
                                        primary key,
        description                     varchar(1000)
);

insert into pm_task_dependency_types (short_name, description) values ('start_before_start','Starts before this starts');
insert into pm_task_dependency_types (short_name, description) values ('start_before_finish','Starts before this finishes');
insert into pm_task_dependency_types (short_name, description) values ('finish_before_start','Finishes before this starts');
insert into pm_task_dependency_types (short_name, description) values ('finish_before_finish','Finishes before this finishes');


create sequence pm_task_dependency_seq;

create table pm_task_dependency (
        dependency_id                   integer
                                        constraint pm_task_const_id_pk
                                        primary key,
        task_id                         integer
                                        constraint pm_task_const_task_id_nn
                                        not null
                                        constraint pm_task_const_task_id_fk
                                        references pm_tasks
                                        on delete cascade,
        parent_task_id                  integer
                                        constraint pm_tasks_const_parent_id_nn
                                        not null
                                        constraint pm_tasks_const_parent_id_fk
                                        references pm_tasks
                                        on delete cascade,
        dependency_type                 varchar(100)
                                        constraint pm_tasks_const_type_nn
                                        not null
                                        constraint pm_tasks_const_type_fk
                                        references pm_task_dependency_types,
        constraint pm_task_dependency_uq unique (task_id, parent_task_id)
);


-- WORKGROUPS

create sequence pm_workgroup_seq;

create table pm_workgroup (
        workgroup_id            integer
                                constraint pm_workgroup_id_pk
                                primary key,
        one_line                varchar(100)
                                constraint pm_workgroup_one_line_uq
                                unique,
        description             varchar(2000),
        sort_order              integer
);

create table pm_workgroup_parties (
        workgroup_id            integer
                                constraint pm_workgroup_parties_wg_id_fk
                                references pm_workgroup(workgroup_id)
                                on delete cascade,
        party_id                integer
                                constraint pm_workgroup_party_fk 
                                references parties(party_id)
                                on delete cascade,
        role_id                 integer
                                constraint pm_workgroup_role_id
                                references pm_roles,
        constraint pm_workgroup_parties_uq
        unique (workgroup_id, party_id, role_id)
);


-- TASK ASSIGNMENTS

create table pm_task_assignment (
        task_id                 integer
                                constraint pm_task_assignment_task_fk
                                references pm_tasks(task_id)
                                on delete cascade,
        role_id                 integer
                                constraint pm_task_assignment_role_fk
                                references pm_roles,
        party_id                integer
                                constraint pm_task_assignment_party_fk 
                                references parties(party_id)
                                on delete cascade,
        constraint pm_task_assignment_uq
        unique (task_id, role_id, party_id)
);


comment on table pm_task_assignment is '
  Maps who is a part of what task, and in what capacity
';

create table pm_task_xref (
        task_id_1               integer
                                constraint pm_task_xref_task1_nn
                                not null
                                constraint pm_task_xref_task1_fk
                                references pm_tasks(task_id)
                                on delete cascade,
        task_id_2               integer
                                constraint pm_task_xref_task2_nn
                                not null
                                constraint pm_task_xref_task2_fk
                                references pm_tasks(task_id)
                                on delete cascade,
        constraint pm_task_xref_lt check (task_id_1 < task_id_2)
);

comment on table pm_task_xref is '
  Maps related tasks.
';


-- PROCESSES

create sequence pm_process_seq;

create table pm_process (
        process_id                      integer
                                        constraint pm_process_id_pk
                                        primary key,
        one_line                        varchar(200)
                                        constraint pm_process_one_line_nn
                                        not null,
        description                     varchar(1000),
        party_id                        integer
                                        constraint pm_process_party_fk
                                        references parties
                                        constraint pm_process_party_nn
                                        not null,
        creation_date                   date 
);

comment on table pm_process is '
 Processes are a set of templates for tasks, so that people can 
 create sets of tasks quickly. Their structure needs to match that of
 tasks. The process holds the meta information, and is also an identifier
 that is used by the user to select which process they''d like to copy or
 use 
';

create sequence pm_process_task_seq;

create table pm_process_task (
        process_task_id                 integer
                                        constraint pm_process_task_id_pk
                                        primary key,
        process_id                      integer
                                        constraint pm_process_process_id_fk
                                        references
                                        pm_process
                                        constraint pm_process_process_id_nn
                                        not null,
        one_line                        varchar(200)
                                        constraint pm_process_task_one_line_nn
                                        not null,
        description                     varchar(4000),
        -- dates are optional, because it may be computed in reference
        -- to all other items, or simply not have a deadline
        -- percent complete is always 0
        estimated_hours_work            numeric,
        -- PERT charts require minimum and maximum estimates
        -- these are optionally used
        estimated_hours_work_min        numeric,
        estimated_hours_work_max        numeric,
        ordering                        integer
);

comment on table pm_process_task is '
  A template for the tasks that will be created by the process
';

create sequence pm_process_task_dependency_seq;

create table pm_process_task_dependency (
        dependency_id                   integer
                                        constraint pm_proc_task_dependcy_pk
                                        primary key,
        process_task_id                 integer
                                        constraint pm_proc_task_proc_task_fk
                                        references pm_process_task
                                        on delete cascade,
        parent_task_id                  integer
                                        constraint pm_proc_task_parent_id_fk
                                        references pm_process_task
                                        on delete cascade,
        dependency_type                 varchar(100)
                                        constraint pm_process_task_dep_type
                                        references pm_task_dependency_types,
        constraint pm_proc_task_depend_uq
        unique (process_task_id, parent_task_id)
);

comment on table pm_process_task_dependency is '
  Keeps track of dependencies. Used to create the dependencies in the
  new tasks.
';

create table pm_process_task_assignment (
        process_task_id         integer
                                constraint pm_proc_task_assign_task_fk
                                references pm_process_task(process_task_id)
                                on delete cascade,
        role_id                 integer
                                constraint pm_proc_task_assign_role_fk
                                references pm_roles,
        party_id                integer
                                constraint pm_proc_task_assign_party_fk 
                                references parties(party_id)
                                on delete cascade,
        constraint pm_proc_task_assgn_uq
        unique (process_task_id, role_id, party_id)
);


comment on table pm_process_task_assignment is '
  Maps who is assigned to process tasks. These will be the default people
  assigned to the new tasks
';

create table pm_users_viewed (
        viewing_user    integer constraint
                        pm_usrs_viewed_viewing_user_fk
                        references parties,
        viewed_user     integer constraint
                        pm_usrs_viewed_viewed_user_fk
                        references parties
);

comment on table pm_users_viewed is '
  Used to keep track of what users to see on the task calendar and other
  views.
';

@@project-manager-custom-create.sql
