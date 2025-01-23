# Retrieving closed tasks from unloading

drop table if exists spd_tasks_reporters_full;
create table spd_tasks_reporters_full as

SELECT issue,
prod_v_emart.jira_issue_cur.status_name,
creation_date::date,
resolution_dttm,
type_nm,
spd_tasks.login,
management_unit_nm,
lvl8_mngt_unit_nm,
legal_unit_nm,
lvl6_mngt_unit_nm
FROM spd_tasks, 
prod_v_emart.jira_issue_cur, 
prod_v_sse.frankenstein
WHERE spd_tasks.issue=prod_v_emart.jira_issue_cur.issue_full_nm 
AND prod_v_emart.jira_issue_cur.type_nm='TCRM Call'
AND prod_v_emart.jira_issue_cur.resolution_dttm is not null
AND prod_v_emart.jira_issue_cur.status_name IN('Done')
AND spd_tasks.login=prod_v_sse.frankenstein.ad_login
AND spd_tasks.email=prod_v_sse.frankenstein.wrk_email_address_txt
AND spd_tasks.creation_date::date=prod_v_sse.frankenstein.calendar_dt::date ;

# Counting closed tasks per month

drop table if exists spd_tasks_month;
create table spd_tasks_month as

SELECT EXTRACT(year from creation_date::date) as y, 
EXTRACT(month from creation_date::date) as mes_num,
to_char(creation_date::date, 'Month') AS mes,
COUNT(issue)as tasks_amount
FROM spd_tasks_reporters_full
GROUP BY y, mes_num, 
mes
ORDER BY y, mes_num;

# General unloading of closed tasks

drop table if exists spd_tasks_full_count_data;
create table spd_tasks_full_count_data as

SELECT EXTRACT(year from creation_date::date) as y,
EXTRACT(month from creation_date::date) as mes_num,
to_char(creation_date::date, 'Month') AS mes,
lvl6_mngt_unit_nm,
legal_unit_nm,
lvl8_mngt_unit_nm,
management_unit_nm,
COUNT(issue)as tasks_amount
FROM spd_tasks_reporters_full
GROUP BY y, mes_num, 
mes,
lvl6_mngt_unit_nm,
legal_unit_nm,
lvl8_mngt_unit_nm,
management_unit_nm
ORDER BY y, mes_num;

# Calculation of the results of closed tasks as a percentage by Department

SELECT y, mes_num,
mes,
lvl6_mngt_unit_nm,
SUM(tasks_amount),
CASE
WHEN y=2023 and mes_num=5
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2023 and mes_num=5
    ),2)
WHEN y=2023 and mes_num=6
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2023 and mes_num=6
    ),2)
WHEN y=2023 and mes_num=7
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2023 and mes_num=7
    ),2)
WHEN y=2023 and mes_num=8
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2023 and mes_num=8
    ),2)
WHEN y=2023 and mes_num=9
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2023 and mes_num=9
    ),2)
WHEN y=2023 and mes_num=10
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2023 and mes_num=10
    ),2)
WHEN y=2023 and mes_num=11
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2023 and mes_num=11
    ),2)
WHEN y=2023 and mes_num=12
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2023 and mes_num=12
    ),2)
WHEN y=2024 and mes_num=1
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2024 and mes_num=1
    ),2)
WHEN y=2024 and mes_num=2
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2024 and mes_num=2
    ),2)
WHEN y=2024 and mes_num=3
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2024 and mes_num=3
    ),2)
WHEN y=2024 and mes_num=4
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2024 and mes_num=4
    ),2)
WHEN y=2024 and mes_num=5
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2024 and mes_num=5
    ),2)
END AS percentage
FROM spd_tasks_full_count_data
GROUP BY y,mes_num, mes, lvl6_mngt_unit_nm
ORDER BY y, mes_num;

# Calculation of the results of closed tasks as a percentage by Group

SELECT y, mes_num,
mes,
management_unit_nm,
SUM(tasks_amount),
CASE
WHEN y=2023 and mes_num=5
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2023 and mes_num=5
    ),2)
WHEN y=2023 and mes_num=6
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2023 and mes_num=6
    ),2)
WHEN y=2023 and mes_num=7
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2023 and mes_num=7
    ),2)
WHEN y=2023 and mes_num=8
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2023 and mes_num=8
    ),2)
WHEN y=2023 and mes_num=9
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2023 and mes_num=9
    ),2)
WHEN y=2023 and mes_num=10
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2023 and mes_num=10
    ),2)
WHEN y=2023 and mes_num=11
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2023 and mes_num=11
    ),2)
WHEN y=2023 and mes_num=12
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2023 and mes_num=12
    ),2)
WHEN y=2024 and mes_num=1
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2024 and mes_num=1
    ),2)
WHEN y=2024 and mes_num=2
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2024 and mes_num=2
    ),2)
WHEN y=2024 and mes_num=3
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2024 and mes_num=3
    ),2)
WHEN y=2024 and mes_num=4
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2024 and mes_num=4
    ),2)
WHEN y=2024 and mes_num=5
THEN ROUND(SUM(tasks_amount)*100/(
    SELECT tasks_amount
    FROM spd_tasks_month 
    WHERE y=2024 and mes_num=5
    ),2)
END AS percentage
FROM spd_tasks_full_count_data
GROUP BY y,mes_num, mes, management_unit_nm
ORDER BY y, mes_num;

# General upload for open jira tasks

drop table if exists spd_tasks_reporters_full_open;
create table spd_tasks_reporters_full_open as

SELECT issue,
prod_v_emart.jira_issue_cur.status_name,
CASE
WHEN prod_v_emart.jira_issue_cur.status_name IN('Ready for Specification', 'New', 'Backlog', 'Specification')
THEN 'Backlog'
WHEN prod_v_emart.jira_issue_cur.status_name IN('Development', 'Review', 'To Do', 'Ready to start')
THEN 'In Progress'
ELSE 'Block'
END AS main_status ,
creation_date::date,
type_nm,
spd_tasks.login,
management_unit_nm,
lvl8_mngt_unit_nm,
legal_unit_nm,
lvl6_mngt_unit_nm
FROM spd_tasks, 
prod_v_emart.jira_issue_cur, 
prod_v_sse.frankenstein
WHERE spd_tasks.issue=prod_v_emart.jira_issue_cur.issue_full_nm 
AND prod_v_emart.jira_issue_cur.type_nm='TCRM Call'
AND prod_v_emart.jira_issue_cur.status_name NOT IN('Documentation', 'Trashed', 'Done', 'Released', 'Ready')
AND spd_tasks.login=prod_v_sse.frankenstein.ad_login
AND spd_tasks.email=prod_v_sse.frankenstein.wrk_email_address_txt
AND spd_tasks.creation_date::date=prod_v_sse.frankenstein.calendar_dt::date;

# Counting jira tasks with status Backlog

SELECT to_char(creation_date::date, 'Month') AS mes,
main_status,
management_unit_nm,
COUNT(issue)
FROM spd_tasks_reporters_full_open
WHERE main_status='Backlog'
GROUP BY EXTRACT(month from creation_date::date), mes, main_status, management_unit_nm
ORDER BY EXTRACT(month from creation_date::date), main_status, management_unit_nm;

# Counting jira tasks with status In Progress

SELECT to_char(creation_date::date, 'Month') AS mes,
main_status,
management_unit_nm,
COUNT(issue)
FROM spd_tasks_reporters_full_open
WHERE main_status='In Progress'
GROUP BY EXTRACT(month from creation_date::date), mes, main_status, management_unit_nm
ORDER BY EXTRACT(month from creation_date::date), main_status, management_unit_nm;

