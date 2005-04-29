-- 
-- 
-- 
-- @author Jade Rubick (jader@bread.com)
-- @creation-date 2004-06-02
-- @arch-tag: 91272478-d825-42e8-b628-534886dffd84
-- @cvs-id $Id$
--

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
            null,                                       -- parent_id
            p_package_id,                               -- context_id
            null,                                       -- folder_id
            null,                                       -- creation_date
            null,                                       -- creation_user
            null                                        -- creation_ip
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
