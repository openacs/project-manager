-- Update the package ids for projects
create function inline_0 ()
returns integer as '
declare
    ct RECORD;
begin
  for ct in select package_id, item_id 
	from cr_items ci, cr_folders cf
	where ci.parent_id = cf.folder_id 
	and ci.content_type = ''pm_project''
  loop
	update acs_objects set package_id = ct.package_id where object_id = ct.item_id;
  end loop;

  return null;
end;' language 'plpgsql';

select inline_0();
drop function inline_0();

-- Update the package ids of project_revisions
create function inline_0 ()
returns integer as '
declare
    ct RECORD;
begin
  for ct in select package_id, revision_id 
	from cr_items ci, cr_folders cf, cr_revisions cr 
	where ci.parent_id = cf.folder_id 
	and ci.item_id = cr.item_id
	and ci.content_type = ''pm_project''
  loop
	update acs_objects set package_id = ct.package_id where object_id = ct.revision_id;
  end loop;

  return null;
end;' language 'plpgsql';

select inline_0();
drop function inline_0();

-- Update the package ids for subprojects
create function inline_0 ()
returns integer as '
declare
    ct RECORD;
begin
  for ct in select package_id, c2.item_id 
	from cr_items ci, cr_folders cf, cr_items c2
	where ci.parent_id = cf.folder_id 
	and c2.content_type = ''pm_project''
	and c2.parent_id = ci.item_id
  loop
	update acs_objects set package_id = ct.package_id where object_id = ct.item_id;
  end loop;

  return null;
end;' language 'plpgsql';

select inline_0();
drop function inline_0();

-- Update the package ids of project_revisions
create function inline_0 ()
returns integer as '
declare
    ct RECORD;
begin
  for ct in select package_id, revision_id 
	from cr_items ci, cr_folders cf, cr_revisions cr, cr_items c2 
	where ci.parent_id = cf.folder_id 
	and c2.item_id = cr.item_id
	and c2.content_type = ''pm_project''
	and c2.parent_id = ci.item_id
  loop
	if ct.package_id is not null then
		update acs_objects set package_id = ct.package_id where object_id = ct.revision_id;
	end if;
  end loop;

  return null;
end;' language 'plpgsql';

select inline_0();
drop function inline_0();
