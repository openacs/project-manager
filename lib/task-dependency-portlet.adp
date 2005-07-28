<master src="/packages/project-manager/lib/portlet" />
<property name="portlet_title">#project-manager.Dependencies#</property>
        <include src="/packages/project-manager/lib/dependency-portlet"
	         task_id="@task_id@"
		 task_term="@task_term@"
		 type="to_other" />
        
        <P />
        
        <include src="/packages/project-manager/lib/dependency-portlet"
	         task_id="@task_id@"
		 task_term="@task_term@"
		 type="from_other" />
        
        <p />
        
        <include src="/packages/project-manager/lib/related-tasks-portlet"
	         task_id="@task_id@"
		 task_term="@task_term@"
		 return_url="@return_url@" />
        
