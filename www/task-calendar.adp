<if @format@ ne print>
    <master src="lib/master">
</if>
<include src="../lib/task-calendar" format="@format@" date="@date@" julian_date="@julian_date@" hide_closed_p="@hide_closed_p@" display_p="t" view="@view@" package_id=@package_id@>
