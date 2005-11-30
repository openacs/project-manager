<?xml version="1.0"?>

<queryset>

<rdbms><type>oracle</type><version>9.2</version></rdbms>

  <fullquery name="pm::status::default_closed.get_closed_status">
    <querytext>
        SELECT
        status_id
        FROM
        pm_project_status
        WHERE
        status_type = 'c'
        and rownum = 1
    </querytext>
  </fullquery>

  <fullquery name="pm::status::default_open.get_open_status">
    <querytext>
        SELECT
        status_id
        FROM
        pm_project_status
        WHERE
        status_type = 'o'
        where rownum = 1
    </querytext>
  </fullquery>

</queryset>
