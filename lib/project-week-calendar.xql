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

        SELECT  DISTINCT
        to_char(p.planned_end_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_start_date,
        to_char(p.planned_end_date, 'YYYY-MM-DD HH24:MI:SS') as ansi_end_date,
        to_number(to_char(p.planned_start_date,'HH24'),'90') as start_hour,
        to_number(to_char(p.planned_end_date,'HH24'),'90') as end_hour,
        to_number(to_char(p.planned_end_date,'MI'),'90') as end_minutes,
        p.title as name,
        p.status_id as status_summary,
	p.object_id as item_id,
	i.item_id as project_id,
        f.package_id as instance_id
	$additional_select_clause
        FROM pm_projectsx p 
             LEFT JOIN pm_project_assignment pa 
                ON p.item_id = pa.project_id
             LEFT JOIN organizations o ON p.customer_id =
                o.organization_id 
             LEFT JOIN (
                        select 
                        om.category_id, 
                        om.object_id, 
                        t.name as category_name 
                        from 
                        category_object_map om, 
                        category_translations t, 
                        categories ctg 
                        where 
                        om.category_id = t.category_id and 
                        ctg.category_id = t.category_id and 
                        ctg.deprecated_p = 'f')
                 c ON p.item_id = c.object_id, 
        cr_items i, 
	cr_folders f
        WHERE 
        p.project_id = i.live_revision 
	and i.parent_id = f.folder_id
	and i.item_id = p.item_id
	$instance_clause
        $selected_users_clause
        and exists (select 1 from acs_object_party_privilege_map ppm 
                    where ppm.object_id = p.project_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id) and
	p.planned_end_date between $interval_limitation_clause
        $additional_limitations_clause
  </querytext>
</fullquery>

<partialquery name="week_interval_limitation">      
  <querytext>
 to_date(:first_weekday_of_the_week_tz, 'YYYY-MM-DD HH24:MI:SS') and to_date(:last_weekday_of_the_week_tz, 'YYYY-MM-DD HH24:MI:SS') + 1
  </querytext>
</partialquery>

    <fullquery name="assignees">
    <querytext>
    select distinct
    p.first_names || ' ' || p.last_name as name,
    p.person_id as party_id
    FROM
    persons p,
    pm_project_assignment pa
    WHERE
    p.person_id = pa.party_id 
    $users_clause

    </querytext>
  </fullquery>

    <fullquery name="users">
    <querytext>
	select distinct 1 
	from pm_project_assignment 
        where party_id=:user and project_id=:project_id
	

    </querytext>
  </fullquery>

</queryset>
