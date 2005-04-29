-- 
-- 
-- 
-- @author Jade Rubick (jader@bread.com)
-- @creation-date 2004-07-16
-- @arch-tag: 99b969e0-4944-4656-b5f9-61df7e10344c
-- @cvs-id $Id$
--

CREATE OR REPLACE view 
pm_tasks_active as 
  SELECT task_id, task_number, status FROM pm_tasks where deleted_p = 'f';
