-- 
-- 
-- 
-- @author Jade Rubick (jader@bread.com)
-- @creation-date 2004-05-19
-- @arch-tag: 551cfc66-62c5-4f75-a321-e879d75b44b1
-- @cvs-id $Id$
--

-- fixes name function

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


-- untested fix for bug #1796

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
            p_package_id                                -- parent_id
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

-- upgrade script to fix bug #1796

update cr_items set parent_id = (select package_id from cr_folders where folder_id = item_id and label = 'Projects') where item_id = (select folder_id from cr_folders where label = 'Projects' and description = 'Project Repository');
