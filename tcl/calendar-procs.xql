<?xml version="1.0"?>

<queryset>

  <fullquery name="pm::calendar::users_to_view.get_users">
    <querytext>
      SELECT
      viewed_user
      FROM
      pm_users_viewed
      WHERE
      viewing_user = :user_id
    </querytext>
  </fullquery>

</queryset>
