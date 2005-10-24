-- 
-- 
-- 
-- @author  (root@dev.bread.com)
-- @creation-date 2005-09-20
-- @arch-tag: 027c06b8-87d7-4cd1-8957-8570da49e749
-- @cvs-id $Id$
--

create sequence pm_process_subproject_seq;

create table pm_process_subproject (
        process_subproject_id           integer
                                        constraint pm_process_subproject_id_pk
                                        primary key,
        process_id                      integer
                                        constraint pm_process_process_id_fk
                                        references
                                        pm_process
                                        constraint pm_process_process_id_nn
                                        not null,
        one_line                        varchar(200)
                                        constraint pm_process_subproject_one_line_nn
                                        not null,
        description                     varchar(4000),
        mime_type                       varchar(200)
                                        constraint pm_process_subproject_mime_type_fk
                                        references cr_mime_types(mime_type)
                                        on update no action on delete no action
                                        default 'text/plain'
        );

comment on table pm_process_subproject is '
  A template for the subprojects that will be created by the process
';


create table pm_process_subproject_assignment (
        process_subproject_id         integer
                                constraint pm_proc_subproject_assign_subproject_fk
                                references pm_process_subproject(process_subproject_id)
                                on delete cascade,
        role_id                 integer
                                constraint pm_subproject_assignment_role_fk
                                references pm_roles,
        party_id                integer
                                constraint pm_subproject_assignment_party_fk 
                                references parties(party_id)
                                on delete cascade,
        constraint pm_proc_subproject_assgn_uq
        unique (process_subproject_id, role_id, party_id)
);


comment on table pm_process_subproject_assignment is '
  Maps who is assigned to process subprojects. These will be the default people
  assigned to the new subprojects
';

