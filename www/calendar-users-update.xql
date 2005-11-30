<?xml version="1.0"?>

<queryset>
  <fullquery name="delete_old_user_list">
    <querytext>
        DELETE FROM
        pm_users_viewed
        WHERE
        viewing_user = :user_id
    </querytext>
  </fullquery>

  <fullquery name="add_user_to_view">
    <querytext>
        INSERT INTO
        pm_users_viewed
        (viewing_user, viewed_user) values
        (:user_id, :party)
    </querytext>
  </fullquery>

</queryset>
