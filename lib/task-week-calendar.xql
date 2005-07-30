<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>
	
<fullquery name="select_weekday_info">
<querytext>
        select   to_char(to_date(:start_date, 'YYYY-MM-DD HH24:MI:SS'), 'D') 
        as       day_of_the_week,
        to_char(next_day(to_date(:start_date, 'YYYY-MM-DD HH24:MI:SS')- '1 week'::interval, :first_us_weekday), 'YYYY-MM-DD HH24:MI:SS')
        as       first_weekday_of_the_week,
        to_char(next_day(to_date(:start_date, 'YYYY-MM-DD HH24:MI:SS'), :last_us_weekday), 'YYYY-MM-DD HH24:MI:SS')
        as       last_weekday_of_the_week
        from     dual
</querytext>
</fullquery>


<fullquery name="select_week_info">      
<querytext>
select   to_char(to_date(:start_date, 'YYYY-MM-DD HH24:MI:SS'), 'D') 
as day_of_the_week,
cast(next_day(to_date(:start_date, 'YYYY-MM-DD HH24:MI:SS') - cast('7 days' as interval), :first_us_weekday) as date)
as first_weekday_date,
to_char(next_day(to_date(:start_date, 'YYYY-MM-DD HH24:MI:SS') - cast('7 days' as interval), :first_us_weekday),'J')
as first_weekday_julian,
cast(next_day(to_date(:start_date, 'YYYY-MM-DD HH24:MI:SS') - cast('7 days' as interval), :first_us_weekday) + cast('6 days' as interval) as date)
as last_weekday_date,
to_char(next_day(to_date(:start_date, 'YYYY-MM-DD HH24:MI:SS') - cast('7 days' as interval), :first_us_weekday) + cast('6 days' as interval),'J') 
as last_weekday_julian,
cast(:start_date::timestamptz - cast('7 days' as interval) as date) as last_week,
to_char(:start_date::timestamptz - cast('7 days' as interval), 'Month DD, YYYY') as last_week_pretty,
cast(:start_date::timestamptz + cast('7 days' as interval) as date) as next_week,
to_char(:start_date::timestamptz + cast('7 days' as interval), 'Month DD, YYYY') as next_week_pretty
from     dual
</querytext>
</fullquery>


<fullquery name="select_items">
  <querytext>
    select   distinct to_char(end_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_start_date,
             to_char(t.end_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_end_date,
             to_number(to_char(t.earliest_start,'HH24'),'90') as start_hour,
             to_number(to_char(t.end_date,'HH24'),'90') as end_hour,
             to_number(to_char(t.end_date,'MI'),'90') as end_minutes,
	     t.title as name,
             ts.status as status_summary,
             ts.task_id as item_id,
	     i.item_id as task_item_id,
	     o.package_id as instance_id
	     $additional_select_clause

      FROM
      acs_objects o,
      pm_tasks_active ts, 
      pm_task_status s,
      cr_items i,
      pm_tasks_revisionsx t 
        LEFT JOIN pm_task_assignment ta
        ON t.item_id = ta.task_id
          LEFT JOIN persons p 
          ON ta.party_id = p.person_id
          LEFT JOIN pm_roles r
          ON ta.role_id = r.role_id,
      cr_items     projecti,
      cr_revisions projectr
      WHERE
      ts.status   = s.status_id and
      ts.task_id  = t.item_id and
      i.item_id   = t.item_id and
      t.task_revision_id = i.live_revision and
      t.parent_id = projecti.item_id and
      end_date between $interval_limitation_clause and
      o.object_id=t.item_id and
      projecti.live_revision = projectr.revision_id
      $instance_clause
      $selected_users_clause
  </querytext>
</fullquery>

<fullquery name="select_items_by_latest_finish">
  <querytext>
    select   distinct to_char(latest_finish, 'YYYY-MM-DD HH24:MI:SS') as ansi_start_date,
             to_char(t.latest_finish, 'YYYY-MM-DD HH24:MI:SS') as ansi_end_date,
             to_number(to_char(t.earliest_start,'HH24'),'90') as start_hour,
             to_number(to_char(t.latest_finish,'HH24'),'90') as end_hour,
             to_number(to_char(t.latest_finish,'MI'),'90') as end_minutes,
	     t.title as name,
             ts.status as status_summary,
             ts.task_id as item_id,
	     i.item_id as task_item_id,
	     o.package_id as instance_id
	     $additional_select_clause
	
      FROM
      acs_objects o,
      pm_tasks_active ts, 
      pm_task_status s,
      cr_items i,
      pm_tasks_revisionsx t 
        LEFT JOIN pm_task_assignment ta
        ON t.item_id = ta.task_id
          LEFT JOIN persons p 
          ON ta.party_id = p.person_id
          LEFT JOIN pm_roles r
          ON ta.role_id = r.role_id,
      cr_items     projecti,
      cr_revisions projectr
      WHERE
      ts.status   = s.status_id and
      ts.task_id  = t.item_id and
      i.item_id   = t.item_id and
      t.task_revision_id = i.live_revision and
      t.parent_id = projecti.item_id and
      latest_finish between $interval_limitation_clause and
      o.object_id=t.item_id and
      projecti.live_revision = projectr.revision_id
      $instance_clause
      $selected_users_clause
  </querytext>
</fullquery>


<partialquery name="week_interval_limitation">      
  <querytext>
 to_date(:first_weekday_of_the_week_tz, 'YYYY-MM-DD HH24:MI:SS') and to_date(:last_weekday_of_the_week_tz, 'YYYY-MM-DD HH24:MI:SS') + 1
  </querytext>
</partialquery>

    <fullquery name="community_members">
    <querytext>
    select
    p.first_names || ' ' || p.last_name as name,
    p.person_id as party_id
    FROM
    persons p,
    acs_rels r,
    membership_rels mr
    WHERE
    r.object_id_one = :community_id and
    mr.rel_id = r.rel_id and
    p.person_id = r.object_id_two and
    member_state = 'approved'
    ORDER BY
    p.first_names, p.last_name

    </querytext>
  </fullquery>

    <fullquery name="dotlrn_members">
    <querytext>
    select
    du.first_names || ' ' || du.last_name as name,
    du.user_id as party_id
    FROM
    dotlrn_users du
    </querytext>
  </fullquery>


</queryset>
