<master>

  <link rel="stylesheet" href="style.css" type="text/css">

    <property name="title">@title@</property>
    <property name="context">@context;noquote@</property>

    Click on one of the following items to set it up:

    <P />

    <table border="1" cellpadding="3" cellspacing="0">

      <tr>
        <th>Section</th>
        <th>Action</th>
        <th>Description</th>
      </tr>

      <tr>
        <th>Roles</th>
        <td><a href="roles">View</a></td>
        <td>The roles people can take on projects and tasks, such as
        manager, sales contact, tech support person, etc.. Currently,
        can only be edited directly in the database.</td>
      </tr>

      <tr>
        <th>Default roles</th>
        <td><a href="default-project-roles">View</a></td>
        <td>The data model has a facility for default roles, although
        it is not currently used at all. This shows what is in the
        database for default roles. Currently unimplemented.</td>
      </tr>
      
      <tr>
        <th>Workgroups</th>
        <td><a href="workgroups">View</a></td>
        <td>There is a data model for workgroups, but it is not a part
        of the UI. Shows what is in the database (currently, nothing!)</td>
      </tr>
      
      <tr>
        <th>Dependency types</th>
        <td>No UI</td>
        <td>When implemented, this page will allow you to view and
        edit the descriptions given to various dependency types (such
        as finish before start, etc..) Currently, the only dependency
        used is finish before start, so it's not exposed in the UI</td>
      </tr>
      
      <tr>
        <th>Status types</th>
        <td>No UI</td>
        <td>Valid status codes, for example, 'Open' and 'Closed'</td>
      </tr>
      
      <tr>
        <th>Project categories</th>
        <td><a href="@categories_link;noquote@">Edit categories</a></td>
        <td>Projects can be categorized according to multiple 'trees'
        of categories. What this means is you can have multiple ways
        of categorizing your projects. This section sets up your
        categories and allows you to link them to projects. Currently,
        there is a bug in the categories package that prevents the
        context bar at the top of the screen from returning you to the
        project-manager pages.</td>
      </tr>

      <tr>
        <th rowspan="3">Logger integration</th>
        <td><a href="@logger_link@">Set up</a></td>
        <td>Logger is a package that lets you log time, expenses, and
          other <i>variables</i>. Project manager requires you to
          install and mount at least one instance of logger, because it
          uses logger to log time and other variables against projects
          and tasks. However, you can have varying levels of integration
          with logger. This section sets up which logger instances you
          want to be fully integrated with project-manager, so that new
          project-manager projects appear in the logger instance.<p />
          @logger_warning;noquote@
        </td>
      </tr>

      <tr>
        <td><a href="@logger_primary_link@">Set up</a></td>
        <td>You must choose a logger instance to be the primary
        logger linked in with project-manager. This is closely linked
        in with project-manager, so you can view reports of a project, etc.
          <p />
          @logger_primary_warning;noquote@
        </td>
      </tr>

      <tr>
        <td><a href="@logger_sync_link@">Sync</a></td>
        <td>Once you have chosen logger instances to be integrated
        with project-manager, you may have a lot of older
        project-manager projects that are not synchronized with
        logger. This page lets you synchronize older project-manager
        projects with logger, so that they are all linked in correctly
        with that instance. This does not add in logger projects to
        project-manager (although someone can certainly add that
        functionality if they wish).
      </tr>

      <tr>
        <th>Parameters</th>
        <td><a href="@parameters_link@">Edit</a></td>
        <td>The parameters allow you to do things such as set up daily
        reminder emails, change what fields are shown in the project
        view and edit pages, and so on. Highly recommended if you're
        setting up project-manager.</td>
      </tr>
      
      <tr>
        <th>Projects</th>
        <td><a href="@update_projects_link@">Update all</a></td>
        <td>This page allows you to update the deadlines of all the
        projects in your installation. It will take a while.</td>
      </tr>

    </table>
    
