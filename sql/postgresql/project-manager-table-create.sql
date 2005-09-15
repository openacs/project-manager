-- packages/project-manager/sql/postgresql/project-manager-table-create.sql
--
-- @author jader@bread.com
-- @author ncarroll@ee.usyd.edu.au was involved in creating the initial CR version
-- @author everyone else involved in this thread: http://openacs.org/forums/message-view?message_id=90742
-- @creation-date 2003-05-15
--

-- PROJECTS

create sequence pm_project_status_seq start 3;

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

-- I'm not sure if this shouldn't be a category, but well...
insert into pm_project_status (status_id, description, status_type) values
(1, '#acs-kernel.common_Open#', 'o');
insert into pm_project_status (status_id, description, status_type) values
(2, '#acs-kernel.common_Closed#', 'c');


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
        planned_start_date      timestamptz,
        planned_end_date        timestamptz,
        actual_start_date       timestamptz,
        actual_end_date         timestamptz,
        status_id               integer
                                constraint pm_projects_status_id_nn
                                not null
                                constraint pm_projects_status_id_fk
                                references pm_project_status,
        -- if ongoing_p is true, then actual_end_date must be null
        ongoing_p               char(1) default 'f' 
                                constraint pm_projects_ongoing_p_ck
                                check (ongoing_p in ('t','f')),
        estimated_finish_date   timestamptz,
        earliest_finish_date    timestamptz,
        latest_finish_date      timestamptz,
        -- denormalized, taken from logger
        actual_hours_completed  numeric,
        estimated_hours_total   numeric,
        dform                   varchar(100) default 'implicit'
);


-- other fields are added in too. See the -custom script.


-- ROLES

create sequence pm_role_seq start 4;

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
                                check (is_observer_p in ('t','f')),
        is_lead_p               char(1) default 'f'
                                constraint pm_role_is_lead_ck
                                check (is_lead_p in ('t','f'))
);


comment on table pm_roles is '
  Roles represent the way in which a party participates in a project
  or task. For example, they could be a manager, or client, or
  participant.. The sort order determines what order it is displayed
  in.  The is_observer_p specifies whether they are directly
  responsible for the task, or are just observers on it. 
';

insert into pm_roles (role_id, one_line, description, sort_order, is_lead_p) values ('1','#project-manager.Lead#','#project-manager.lt_Team_members_who_are_#','10','t');
insert into pm_roles (role_id, one_line, description, sort_order) values ('2','#project-manager.Player#','#project-manager.lt_A_person_on_the_team_#','20');
insert into pm_roles (role_id, one_line, description, sort_order, is_observer_p) values ('3','#project-manager.Watcher#','#project-manager.lt_A_person_interested_i#','30','t');


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

create index pm_project_assignment_role_id_idx on pm_project_assignment(role_id);
create index pm_project_assignment_project_id_idx on pm_project_assignment(project_id);
create index pm_project_assignment_party_id_idx on pm_project_assignment(party_id);

comment on table pm_project_assignment is '
  Maps who is a part of what project, and in what capacity
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
        creation_date                   timestamptz,
        deleted_p                       char(1) default 'f'
                                        constraint pm_process_deleted_p_ck
                                        check (deleted_p in ('t','f'))
);

comment on table pm_process is '
 Processes are a set of templates for tasks, so that people can 
 create sets of tasks quickly. Their structure needs to match that of
 tasks. The process holds the meta information, and is also an identifier
 that is used by the user to select which process they''d like to copy or
 use 
';

create or replace view 
pm_process_active as 
  SELECT *  FROM pm_process where deleted_p = 'f';

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
        mime_type                       varchar(200)
                                        constraint pm_process_task_mime_type_fk
                                        references cr_mime_types(mime_type)
                                        on update no action on delete no action
                                        default 'text/plain',
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

insert into pm_task_dependency_types (short_name, description) values ('start_before_start','#project-manager.lt_Starts_before_this_st#');
insert into pm_task_dependency_types (short_name, description) values ('start_before_finish','#project-manager.lt_Starts_before_this_fi#');
insert into pm_task_dependency_types (short_name, description) values ('finish_before_start','#project-manager.lt_Finishes_before_this_#');
insert into pm_task_dependency_types (short_name, description) values ('finish_before_finish','#project-manager.lt_Finishes_before_this__1#');

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
        dependency_type                 varchar
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
                                constraint pm_task_assignment_role_fk
                                references pm_roles,
        party_id                integer
                                constraint pm_task_assignment_party_fk 
                                references parties(party_id)
                                on delete cascade,
        constraint pm_proc_task_assgn_uq
        unique (process_task_id, role_id, party_id)
);


comment on table pm_process_task_assignment is '
  Maps who is assigned to process tasks. These will be the default people
  assigned to the new tasks
';



-- TASKS

-- we create two tables to store task information
-- the information that we keep revisions on is in the 
-- pm_task_revisions table, the rest is in pm_task

create sequence pm_task_status_seq start 3;

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
(1, '#acs-kernel.common_Open#', 'o');
insert into pm_task_status (status_id, description, status_type) values
(2, '#acs-kernel.common_Closed#', 'c');


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
                                        check (deleted_p in ('t','f')),
        process_instance                integer
                                        constraint pm_tasks_process_instance_fk
                                        references 
                                        pm_process_instance
);

CREATE OR REPLACE view 
pm_tasks_active as 
  SELECT task_id, task_number, status, process_instance FROM pm_tasks where deleted_p = 'f';


create table pm_tasks_revisions (
        task_revision_id                integer
                                        constraint pm_task_revs_id_fk
                                        references cr_revisions 
                                        on delete cascade
                                        constraint pm_task_revs_id_pk
                                        primary key,
        -- dates are optional, because it may be computed in reference
        -- to all other items, or simply not have a deadline
        end_date                        timestamptz,
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
        earliest_start                  timestamptz,
        earliest_finish                 timestamptz,
        latest_start                    timestamptz,
        latest_finish                   timestamptz,
	-- How important is this task
	priority			integer default 0,
        dform                           varchar(100) default 'implicit'
);



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
        dependency_type                 varchar
                                        constraint pm_tasks_const_type_nn
                                        not null
                                        constraint pm_tasks_const_type_fk
                                        references pm_task_dependency_types,
        constraint pm_task_dependency_uq
        unique (task_id, parent_task_id)
);


-- WORKGROUPS: currently not used

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

-- TASK CROSS REFERENCES

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


create table pm_users_viewed (
        viewing_user    integer constraint
                        pm_users_viewed_viewing_user_fk
                        references parties,
        viewed_user     integer constraint
                        pm_users_viewed_viewed_user_fk
                        references parties
);

comment on table pm_users_viewed is '
  Used to keep track of what users to see on the task calendar and other
  views.
';


-- Create missing indexes
CREATE INDEX pm_workgroup_parties_party_id_inx ON pm_workgroup_parties(party_id);
CREATE INDEX pm_workgroup_parties_role_id_inx ON pm_workgroup_parties(role_id);
CREATE INDEX pm_users_viewed_viewed_user_inx ON pm_users_viewed(viewed_user);
CREATE INDEX pm_users_viewed_viewing_user_inx ON pm_users_viewed(viewing_user);
CREATE INDEX pm_tasks_process_instance_inx ON pm_tasks(process_instance);
CREATE INDEX pm_tasks_status_inx ON pm_tasks(status);
CREATE INDEX pm_task_xref_task_id_2_inx ON pm_task_xref(task_id_2);
CREATE INDEX pm_task_xref_task_id_1_inx ON pm_task_xref(task_id_1);
CREATE INDEX pm_task_dependency_dependency_type_inx ON pm_task_dependency(dependency_type);
CREATE INDEX pm_task_dependency_parent_task_id_inx ON pm_task_dependency(parent_task_id);
CREATE INDEX pm_task_assignment_party_id_inx ON pm_task_assignment(party_id);
CREATE INDEX pm_task_assignment_role_id_inx ON pm_task_assignment(role_id);
CREATE INDEX pm_projects_status_id_inx ON pm_projects(status_id);
CREATE INDEX pm_project_assignment_party_id_inx ON pm_project_assignment(party_id);
CREATE INDEX pm_project_assignment_role_id_inx ON pm_project_assignment(role_id);
CREATE INDEX pm_process_task_dependency_dependency_type_inx ON pm_process_task_dependency(dependency_type);
CREATE INDEX pm_process_task_dependency_parent_task_id_inx ON pm_process_task_dependency(parent_task_id);
CREATE INDEX pm_process_task_assignment_party_id_inx ON pm_process_task_assignment(party_id);
CREATE INDEX pm_process_task_assignment_role_id_inx ON pm_process_task_assignment(role_id);
CREATE INDEX pm_process_task_mime_type_inx ON pm_process_task(mime_type);
CREATE INDEX pm_process_task_process_id_inx ON pm_process_task(process_id);
CREATE INDEX pm_process_instance_project_item_id_inx ON pm_process_instance(project_item_id);
CREATE INDEX pm_process_instance_process_id_inx ON pm_process_instance(process_id);
CREATE INDEX pm_process_party_id_inx ON pm_process(party_id);
CREATE INDEX pm_default_roles_party_id_inx ON pm_default_roles(party_id);
CREATE INDEX pm_project_assignment_project_id ON pm_project_assignment(project_id);
CREATE INDEX pm_task_dependency_task_id ON pm_task_dependency(task_id);
CREATE INDEX pm_project_status_status_type_inx ON pm_project_status(status_type);
