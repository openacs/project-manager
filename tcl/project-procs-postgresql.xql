<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.3</version></rdbms>
  
  <fullquery name="pm::project::default_status_open.get_default_status_open">
    <querytext>
      select status_id 
      from pm_project_status 
      where status_type = 'o'
      limit 1
    </querytext>
  </fullquery>

  <fullquery name="pm::project::default_status_closed.get_default_status_closed">
    <querytext>
      select status_id 
      from pm_project_status 
      where status_type = 'c'
      limit 1
    </querytext>
  </fullquery>

  <fullquery name="pm::project::compute_parent_status.get_root_folder">
    <querytext>
        select pm_project__get_root_folder (:package_id, 'f')
    </querytext>
  </fullquery>

  <fullquery name="pm::project::assigned_p.assigned_p">
    <querytext>
      SELECT
      party_id
      FROM
      pm_project_assignment
      WHERE
      project_id = :project_item_id and
      party_id = :party_id
      LIMIT 1
    </querytext>
  </fullquery>

  <fullquery name="pm::project::edit.update_project">
    <querytext>
        select pm_project__new_project_revision (
                :project_item_id,
                :project_name,
                :project_code,
                :parent_id,
                :goal,
                :description,
                to_timestamp(:planned_start_date,'YYYY MM DD HH24 MI SS'),
                to_timestamp(:planned_end_date,'YYYY MM DD HH24 MI SS'),
                null,
                null,
                :logger_project,
                :ongoing_p,
                :status_id,
                :organization_id,
                now(),
                :creation_user,
                :creation_ip,
                :package_id
        )
    </querytext>
  </fullquery>

  <fullquery name="pm::project::new.new_project_item">
    <querytext>
        select pm_project__new_project_item (
                :project_name,
                :project_code,
                :parent_id,
                :goal,
                :description,
                :mime_type,
                to_timestamp(:planned_start_date,'YYYY MM DD HH24 MI SS'),
                to_timestamp(:planned_end_date,'YYYY MM DD HH24 MI SS'),
                null,
                null,
                :logger_project,
                :ongoing_p,
                :status_id,
                :organization_id,
                current_timestamp,
                :creation_user,
                :creation_ip,
                :package_id
        )
    </querytext>
  </fullquery>

</queryset>
