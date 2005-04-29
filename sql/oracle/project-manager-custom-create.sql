--
-- packages/project-manager/sql/postgresql/project-manager-customize.sql
--
-- @author jader@bread.com
-- @creation-date 2003-12-05
--

-- this file is used to add custom columns to the projects table. 
-- you can then customize the columns shown 

-- if you do set this up, you need to set the parameter in the admin
-- UI, so that the add-edit page will know that there is custom code,
-- You'll need to create an add-edit-custom page, filling in the skeleton there

-- you should use the content_type__create_attribute procedure to add
-- in columns so that the views are correctly recreated.

-- PROJECTS

-- example, using customer
-- this is actually done in the table-create script

-- this adds in the customer column. This is an example of how
-- the custom columns are added in. I put this here as a reminder
-- that other columns can be added in as well. These custom items
-- are in the custom-create.sql script

declare 
    attribute_id integer; 
begin 
    attribute_id := content_type.create_attribute (
                        content_type    => 'pm_project',
                        attribute_name  => 'customer_id',
                        datatype        => 'integer',
                        pretty_name     => 'Customer',
                        pretty_plural   => 'Customers',
                        sort_order      => null,
                        default_value   => null,
                        column_spec     => 'integer constraint pm_project_customer_fk references organizations'
                    );
end;
/

show errors

