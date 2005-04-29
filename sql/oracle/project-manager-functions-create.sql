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


create or replace package pm_project as
    
    function name ( p_pm_project_id  in pm_projects.project_id%TYPE
    )  return  varchar2;
    
    function new_root_folder (p_package_id in apm_packages.package_id%TYPE
    )   return  integer;

    function get_root_folder (p_package_id in apm_packages.package_id%TYPE ,
                                         p_create_if_not_present_p in char
    )   return integer;

    function new_project_item (
        p_project_name        in    varchar2 ,
        p_project_code        in    pm_projects.project_code%TYPE,
        p_parent_id           in    integer ,
        p_goal                in    pm_projects.goal%TYPE,
        p_description         in    varchar2 ,  
        p_mime_type           in    varchar2 ,
        p_planned_start_date  in pm_projects.planned_start_date%TYPE ,
        p_planned_end_date    in pm_projects.planned_end_date%TYPE ,
        p_actual_start_date   in pm_projects.actual_start_date%TYPE ,
        p_actual_end_date     in pm_projects.actual_end_date%TYPE,
        p_logger_project      in pm_projects.logger_project%TYPE ,
        p_ongoing_p           in pm_projects.ongoing_p%TYPE ,
        p_status_id           in pm_projects.status_id%TYPE ,
        p_customer_id         in pm_projects.customer_id%TYPE ,
        p_creation_date       in date default sysdate,
        p_creation_user       in integer,
        p_creation_ip         in varchar2,
        p_package_id          in integer
    ) return integer;

    procedure delete_project_item ( p_project_id  in pm_projects.project_id%TYPE);

    function new_project_revision ( 
        p_item_id             in    integer , 
        p_project_name        in    varchar2 ,
        p_project_code        in    pm_projects.project_code%TYPE,
        p_parent_id           in    integer ,
        p_goal                in    pm_projects.goal%TYPE,
        p_description         in    varchar2 ,  
        p_planned_start_date  in pm_projects.planned_start_date%TYPE ,
        p_planned_end_date    in pm_projects.planned_end_date%TYPE ,
        p_actual_start_date   in pm_projects.actual_start_date%TYPE ,
        p_actual_end_date     in pm_projects.actual_end_date%TYPE,
        p_logger_project      in pm_projects.logger_project%TYPE ,
        p_ongoing_p           in pm_projects.ongoing_p%TYPE ,
        p_status_id           in pm_projects.status_id%TYPE ,
        p_customer_id         in pm_projects.customer_id%TYPE ,
        p_creation_date       in date default sysdate,
        p_creation_user       in integer,
        p_creation_ip         in varchar2,
        p_package_id          in integer
    ) return integer; 

    function new_unique_name (p_package_id  in integer
    ) return varchar;  

end pm_project;
/

show errors

create or replace package body pm_project as
    function name ( p_pm_project_id  in pm_projects.project_id%TYPE
    )   return varchar2
    is 
        v_pm_project_name varchar2(500);
    begin 
        select name || '_' || p_pm_project_id 
               into v_pm_project_name
        from pm_projectsx
        where item_id = p_pm_project_id;

        return v_pm_project_name;
    end name;
    
    function new_root_folder (p_package_id in apm_packages.package_id%TYPE
    )   return  integer
    is 
        v_folder_id             cr_folders.folder_id%TYPE;
        v_folder_name           cr_items.name%TYPE;
    begin 
        v_folder_name := new_unique_name (p_package_id);

        v_folder_id := content_folder.new (
            name          =>  v_folder_name, 
            label         => 'Projects',     
            description   => 'Project Repository', 
            parent_id     => null, 
            context_id    => p_package_id, 
            folder_id     => null, 
            creation_date => sysdate, 
            creation_user => null,
            creation_ip   => null 
        );

        -- Register the standard content types
        content_folder.register_content_type (
                folder_id        => v_folder_id, 
                content_type     => 'pm_project',
                include_subtypes => 'f' 
        );

        -- there is no facility in the API for adding in the package_id,
        -- so we have to do it ourselves

        update cr_folders 
        set package_id = p_package_id 
        where folder_id = v_folder_id;

        -- TODO: Handle Permissions here for this folder.

        return v_folder_id;
    end new_root_folder;

    function get_root_folder (p_package_id in apm_packages.package_id%TYPE ,
                              p_create_if_not_present_p  char
    )   return integer
    is
        v_folder_id             cr_folders.folder_id%TYPE;
        v_count                 integer;
    begin
        select count(*) into v_count
        from cr_folders
        where package_id = p_package_id;

        -- raise notice 'count is % for package_id %', v_count, p_package_id;

        if v_count > 1 then
            raise_application_error(-20001, 'More than one project repository for this application instance');
        elsif v_count = 1 then
            select folder_id into v_folder_id
            from cr_folders 
            where package_id = p_package_id;
        else
            if p_create_if_not_present_p = 't' then
              -- Must be a new instance.  Create a new root folder.
              --  raise notice 'creating a new root repository folder';
                   v_folder_id := new_root_folder(p_package_id);
            else
                -- raise notice 'setting to null';
                 v_folder_id := null;
            end if;
        end if;

        return v_folder_id;
    end get_root_folder;

    function new_project_item (
        p_project_name        in    varchar2 ,
        p_project_code        in    pm_projects.project_code%TYPE,
        p_parent_id           in    integer ,
        p_goal                in    pm_projects.goal%TYPE,
        p_description         in    varchar2 ,  
        p_mime_type           in    varchar2 ,
        p_planned_start_date  in pm_projects.planned_start_date%TYPE ,
        p_planned_end_date    in pm_projects.planned_end_date%TYPE ,
        p_actual_start_date   in pm_projects.actual_start_date%TYPE ,
        p_actual_end_date     in pm_projects.actual_end_date%TYPE,
        p_logger_project      in pm_projects.logger_project%TYPE ,
        p_ongoing_p           in pm_projects.ongoing_p%TYPE ,
        p_status_id           in pm_projects.status_id%TYPE ,
        p_customer_id         in pm_projects.customer_id%TYPE ,
        p_creation_date       in date default sysdate,
        p_creation_user       in integer,
        p_creation_ip         in varchar2,
        p_package_id          in integer
    ) return integer
    is
        v_item_id               cr_items.item_id%TYPE;
        v_revision_id           cr_revisions.revision_id%TYPE;
        v_id                    cr_items.item_id%TYPE;
        v_parent_id             cr_items.parent_id%TYPE;
    begin

        select acs_object_id_seq.nextval into v_id from dual;

        v_parent_id := get_root_folder (p_package_id, 't');

        -- raise notice 'v_parent_id (%) p_parent_id (%)', v_parent_id, p_parent_id;

        if p_parent_id is not null
        then
            v_parent_id := p_parent_id;
        end if;

        -- raise notice 'v_parent_id (%) p_parent_id (%)', v_parent_id, p_parent_id;

        v_item_id := content_item.new (
                name             => v_id,
                parent_id        => v_parent_id, 
                item_id          => v_id ,
                locale            => null,    
                creation_date    => p_creation_date,   
                creation_user    => p_creation_user, 
                context_id       => p_parent_id,           
                creation_ip      => p_creation_ip,         
                item_subtype     => 'content_item',      
                content_type     => 'pm_project',        
                title            => p_project_name,   
                description      => p_description,          
                mime_type        => p_mime_type,            
                nls_language     => null,   
                data             => null 
        );

        v_revision_id := content_revision.new (
                title             => p_project_name, 
                description       => p_description, 
                publish_date      => sysdate,       
                mime_type         => p_mime_type, 
                nls_language      => NULL, 
                data              => NULL, 
                item_id           => v_item_id, 
                revision_id       => NULL,  
                creation_date     => p_creation_date, 
                creation_user     => p_creation_user, 
                creation_ip       => p_creation_ip 
        );

        content_item.set_live_revision (v_revision_id);

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
                p_planned_end_date, p_planned_end_date, '0',
                '0', p_status_id, p_customer_id
                );

        acs_permission.grant_permission(
                v_revision_id,
                p_creation_user,
                'admin'
        );

        return v_revision_id;
    end new_project_item;

    procedure delete_project_item ( p_project_id  in pm_projects.project_id%TYPE)
    is
        v_child_item_id                                 cr_items.item_id%TYPE;
    begin 
        -- raise NOTICE 'Deleting pm_project...';

        for v_child in (select  item_id
                        from  cr_items
                        where parent_id = p_project_id and
                              content_type = 'pm_project')
        loop
                delete_project_item(v_child_item_id);
        end loop;

        delete from pm_projects where project_id in (select revision_id from pm_projectsx where item_id = p_project_id);

        content_item.del(p_project_id);
    end delete_project_item;


    function new_project_revision ( 
        p_item_id             in    integer , 
        p_project_name        in    varchar2 ,
        p_project_code        in    pm_projects.project_code%TYPE,
        p_parent_id           in    integer ,
        p_goal                in    pm_projects.goal%TYPE,
        p_description         in    varchar2 ,  
        p_planned_start_date  in pm_projects.planned_start_date%TYPE ,
        p_planned_end_date    in pm_projects.planned_end_date%TYPE ,
        p_actual_start_date   in pm_projects.actual_start_date%TYPE ,
        p_actual_end_date     in pm_projects.actual_end_date%TYPE,
        p_logger_project      in pm_projects.logger_project%TYPE ,
        p_ongoing_p           in pm_projects.ongoing_p%TYPE ,
        p_status_id           in pm_projects.status_id%TYPE ,
        p_customer_id         in pm_projects.customer_id%TYPE ,
        p_creation_date       in date default sysdate,
        p_creation_user       in integer,
        p_creation_ip         in varchar2,
        p_package_id          in integer
    ) return integer
    is
        v_revision_id           cr_revisions.revision_id%TYPE;
    begin

        -- the item_id is the project_id
        v_revision_id := content_revision.new (
                title          => p_project_name,   
                description    => p_description,    
                publish_date   => sysdate,            
                mime_type      => 'text/plain',     
                nls_language   => NULL,  
                data           => NULL, 
                item_id        => p_item_id, 
                revision_id    => NULL, 
                creation_date  => p_creation_date, 
                creation_user  => p_creation_user,  
                creation_ip    => p_creation_ip     
        );

        content_item.set_live_revision (v_revision_id);

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

        acs_permission.grant_permission(
                v_revision_id,
                p_creation_user,
                'admin'
        );

        return v_revision_id;

    end new_project_revision; 

    function new_unique_name (p_package_id  in integer
    ) return varchar
    is
        v_name                  cr_items.name%TYPE;
        v_package_key           apm_packages.package_key%TYPE;
        v_id                    integer;
    begin
        select package_key into v_package_key from apm_packages
            where package_id = p_package_id;

        select acs_object_id_seq.nextval into v_id from dual;

        -- Set the name
        select v_package_key || '_' || 
            to_char(sysdate, 'YYYYMMDD') || '_' ||
            v_id into v_name
        from dual;

        return v_name;

    end new_unique_name;  
end pm_project;
/
show errors

----------------------------------
-- Tasks
----------------------------------

-- When we created the acs object type above, we specified a
-- 'name_method'.  This is the name of a function that will return the
-- name of the object.  This is a convention ensuring that all objects
-- can be identified.  Now we have to build that function.  In this case,
-- we'll return a field called title as the name. 
create or replace package pm_task 
as 
    function name (p_pm_task_id in integer
    ) return varchar2;

    function new_task_item (
        p_project_id               in integer , 
        p_title                    in varchar2,
        p_description              in varchar2,
        p_mime_type                in varchar2, 
        p_end_date                 in date,
        p_percent_complete         in numeric, 
        p_estimated_hours_work   in numeric, 
        p_estimated_hours_work_min in numeric,
        p_estimated_hours_work_max in numeric, 
        p_status_id                in integer,
        p_creation_date            in date default sysdate,
        p_creation_user            in integer,
        p_creation_ip              in varchar2,
        p_package_id               in integer
    ) return integer;

    function new_task_revision (
        p_task_id                  in integer, 
        p_project_id               in integer , 
        p_title                    in varchar2,
        p_description              in varchar2,
        p_mime_type                in varchar2, 
        p_end_date                 in date,
        p_percent_complete         in numeric, 
        p_estimated_hours_work   in numeric, 
        p_estimated_hours_work_min in numeric,
        p_estimated_hours_work_max in numeric, 
        p_actual_hours_worked      in numeric,
        p_status_id                in integer,
        p_creation_date            in date default sysdate,
        p_creation_user            in integer,
        p_creation_ip              in varchar2,
        p_package_id               in integer
    ) return integer;

    procedure delete_task_item (p_task_id in integer); 
    
end pm_task;
/
show errors


create or replace package body pm_task 
as 
    function name (p_pm_task_id in integer
    ) return varchar2
    is
        v_pm_task_name       cr_items.name%TYPE;
    begin
        select i.name || '_' || p_pm_task_id into v_pm_task_name
        from cr_items i
        where i.item_id = p_pm_task_id;

        return v_pm_task_name;
    end name;

    function new_task_item (
        p_project_id               in integer , 
        p_title                    in varchar2,
        p_description              in varchar2,
        p_mime_type                in varchar2, 
        p_end_date                 in date,
        p_percent_complete         in numeric, 
        p_estimated_hours_work   in numeric, 
        p_estimated_hours_work_min in numeric,
        p_estimated_hours_work_max in numeric, 
        p_status_id                in integer,
        p_creation_date            in date default sysdate,
        p_creation_user            in integer,
        p_creation_ip              in varchar2,
        p_package_id               in integer
    ) return integer
    is
        v_item_id               cr_items.item_id%TYPE;
        v_revision_id           cr_revisions.revision_id%TYPE;
        v_id                    cr_items.item_id%TYPE;
        v_task_number           integer;
    begin
        select acs_object_id_seq.nextval into v_id from dual;

        -- We want to put the task under the project item
        -- create the task_number
        
        v_item_id := content_item.new (
                name             => v_id,
                parent_id        => p_project_id,           
                item_id          => v_id, 
                locale           => null, 
                creation_date    => sysdate,                  
                creation_user    => p_creation_user, 
                context_id       => p_package_id, 
                creation_ip      => p_creation_ip,          
                item_subtype     => 'content_item', 
                content_type     => 'pm_task',
                title            => p_title, 
                description      => p_description,          
                mime_type        => p_mime_type, 
                nls_language     => null, 
                data             => null
        );

        v_revision_id := content_revision.new (
                title            => p_title,           
                description      => p_description,     
                publish_date     => sysdate,             
                mime_type        => p_mime_type,       
                nls_language     => NULL,              
                data             => NULL,              
                item_id          => v_item_id,         
                revision_id      => NULL,              
                creation_date    => sysdate,             
                creation_user    => p_creation_user,  
                creation_ip      => p_creation_ip     
        );

        content_item.set_live_revision (v_revision_id);

        insert into pm_tasks (
                task_id, task_number, status)
        values (
                v_item_id, v_task_number, p_status_id);

        insert into pm_tasks_revisions (
                task_revision_id, end_date, percent_complete, estimated_hours_work, estimated_hours_work_min, estimated_hours_work_max, actual_hours_worked)
        values (
                v_revision_id, p_end_date, p_percent_complete, p_estimated_hours_work, p_estimated_hours_work_min, p_estimated_hours_work_max, '0');

        acs_permission.grant_permission(
                v_revision_id,
                p_creation_user,
                'admin'
        );

        return v_revision_id;

    end new_task_item;

    function new_task_revision (
        p_task_id                  in integer, 
        p_project_id               in integer , 
        p_title                    in varchar2,
        p_description              in varchar2,
        p_mime_type                in varchar2, 
        p_end_date                 in date,
        p_percent_complete         in numeric, 
        p_estimated_hours_work   in numeric, 
        p_estimated_hours_work_min in numeric,
        p_estimated_hours_work_max in numeric, 
        p_actual_hours_worked      in numeric,
        p_status_id                in integer,
        p_creation_date            in date default sysdate,
        p_creation_user            in integer,
        p_creation_ip              in varchar2,
        p_package_id               in integer
    ) return integer
    is 
        v_revision_id           cr_revisions.revision_id%TYPE;
        v_id                    cr_items.item_id%TYPE;
    begin
        select acs_object_id_seq.nextval into v_id from dual;

        -- We want to put the task under the project item
        update cr_items 
        set parent_id = p_project_id 
        where item_id = p_task_id;

        v_revision_id := content_revision.new (
                title             => p_title,       
                description       => p_description, 
                publish_date      => sysdate,     
                mime_type         => p_mime_type,   
                nls_language      => NULL, 
                data              => NULL, 
                item_id           => p_task_id, 
                revision_id       => NULL, 
                creation_date     => sysdate,  
                creation_user     => p_creation_user, 
                creation_ip       => p_creation_ip 
        );

        content_item.set_live_revision (v_revision_id);

        insert into pm_tasks_revisions (
                task_revision_id, end_date, percent_complete, estimated_hours_work, estimated_hours_work_min, estimated_hours_work_max, actual_hours_worked)
        values (
                v_revision_id, p_end_date, p_percent_complete, p_estimated_hours_work, p_estimated_hours_work_min, p_estimated_hours_work_max, p_actual_hours_worked);

        update pm_tasks 
        set status = p_status_id 
        where task_id = p_task_id;

        acs_permission.grant_permission(
                v_revision_id,
                p_creation_user,
                'admin'
        );

        return v_revision_id;
    end new_task_revision;

    procedure delete_task_item (p_task_id in integer) 
    is
    begin
        delete from pm_tasks_revisions
                where task_revision_id in (select revision_id from pm_tasks_revisionsx where item_id = p_task_id);

        delete from pm_tasks
                where task_id = p_task_id;

        content_item.del(p_task_id);
    end delete_task_item ;
end pm_task;
/

show errors




