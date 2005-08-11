<if @exist_task_p@>
    <if @exist_task_rev_p@>
        <if @exist_order_by_p@>
            <include src="@template_src@" task_id=@task_id@ task_revision_id=@task_revision_id@ orderby_depend_to=@orderby_depend_to@ orderby_depend_from=@orderby_depend_from@ orderby_people=@orderby_people@ logger_variable_id=@logger_variable_id@ logger_days=@logger_days@>
        </if>
        <else>
            <include src="@template_src@" task_id=@task_id@ task_revision_id=@task_revision_id@ orderby_depend_to=@orderby_depend_to@ orderby_depend_from=@orderby_depend_from@ logger_variable_id=@logger_variable_id@ logger_days=@logger_days@>
        </else>
    </if>
    <else>
        <if @exist_order_by_p@>
            <include src="@template_src@" task_id=@task_id@ orderby_depend_to=@orderby_depend_to@ orderby_depend_from=@orderby_depend_from@ orderby_people=@orderby_people@ logger_variable_id=@logger_variable_id@ logger_days=@logger_days@>
        </if>
        <else>
            <include src="@template_src@" task_id=@task_id@ orderby_depend_to=@orderby_depend_to@ orderby_depend_from=@orderby_depend_from@ logger_variable_id=@logger_variable_id@ logger_days=@logger_days@>
        </else>
    </else>
</if>
<else>
    <if @exist_task_rev_p@>
        <if @exist_order_by_p@>
            <include src="@template_src@" task_revision_id=@task_revision_id@ orderby_depend_to=@orderby_depend_to@ orderby_depend_from=@orderby_depend_from@ orderby_people=@orderby_people@ logger_variable_id=@logger_variable_id@ logger_days=@logger_days@>
        </if>
        <else>
            <include src="@template_src@" task_id=@task_id@ task_revision_id=@task_revision_id@ orderby_depend_to=@orderby_depend_to@ orderby_depend_from=@orderby_depend_from@ logger_variable_id=@logger_variable_id@ logger_days=@logger_days@>
        </else>
    </if>
    <else>
        <if @exist_order_by_p@>
            <include src="@template_src@" orderby_depend_to=@orderby_depend_to@ orderby_depend_from=@orderby_depend_from@ orderby_people=@orderby_people@ logger_variable_id=@logger_variable_id@ logger_days=@logger_days@>
        </if>
        <else>
            <include src="@template_src@" orderby_depend_to=@orderby_depend_to@ orderby_depend_from=@orderby_depend_from@ logger_variable_id=@logger_variable_id@ logger_days=@logger_days@>
        </else>
    </else>
</else>
 

