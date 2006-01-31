alter table pm_projects add album_id	integer
                                	constraint pm_projects_album_fk
                                	references cr_items;
alter table pm_projects add image_id    integer 
                                	constraint pm_projects_image_fk
                                	references cr_items;

comment on column pm_projects.album_id is '
	Album (from photo-album package) to use for project image.  Only used 
	if package parameter PhotoAlbumURL is defined.
';

comment on column pm_projects.image_id is '
	Image (from photo-album package) to use for project image.  Only used 
	if package parameter PhotoAlbumURL is defined.
';

select content_type__create_attribute (
  'pm_project',	-- content_type
  'album_id',		-- attribute_name
  'integer',		-- datatype
  'Album',		-- pretty_name
  'Albums',		-- pretty_plural
  null,			-- sort order
  null,			-- default value
  'integer'		-- column_spec
);

select content_type__create_attribute (
  'pm_project',	-- content_type
  'image_id',		-- attribute_name
  'integer',		-- datatype
  'Image',		-- pretty_name
  'Images',		-- pretty_plural
  null,			-- sort order
  null,			-- default value
  'integer'		-- column_spec
);
