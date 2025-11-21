# 🇷🇺 **Аналитика задач в JIRA (Python + SQL)**

## 📌 Описание проекта

Этот проект автоматизирует процесс выгрузки, обработки и аналитики задач Jira для проекта **SPD**.
В него входят два основных компонента:

1. **Python-скрипт (`get_jira_task.py`)** — выгружает задачи из Jira и формирует таблицу сотрудников-репортеров.
2. **SQL-скрипт (`checking-jira-tasks.sql`)** — производит многоступенчатую аналитику:

   * объединение данных Jira с оргструктурой,
   * анализ закрытых задач,
   * расчёт процента выполнения по департаментам и группам,
   * аналитика открытых задач (Backlog, In Progress, Block).

---

# 🧩 1. Python-скрипт: `get_jira_task.py`

### Что делает:

* Подключается к Jira через API.
* Выполняет JQL-запрос:

```
project=SPD AND created > "2023-04-30"
```

* Для каждой задачи получает:

  * ключ задачи,
  * дату создания,
  * тип,
  * имя и email репортера,
  * логин (часть email до "@").
* Создаёт DataFrame `spd_tasks`.
* Отправляет данные в хранилище GP.

### 📊 Пример таблицы `spd_tasks`

| issue     | creation_date       | issue_type | reporter       | email                                                 | login      |
| --------- | ------------------- | ---------- | -------------- | ----------------------------------------------------- | ---------- |
| SPD-12345 | 2023-05-12 14:33:01 | Bug        | Ivan Petrov    | [i.petrov@company.ru](mailto:i.petrov@company.ru)     | i.petrov   |
| SPD-12346 | 2023-05-12 17:20:12 | TCRM Call  | Maria Smirnova | [smirnova.m@company.ru](mailto:smirnova.m@company.ru) | smirnova.m |
| SPD-12347 | 2023-05-13 09:11:44 | Task       | Sergey Ivanov  | [s.ivanov@company.ru](mailto:s.ivanov@company.ru)     | s.ivanov   |

---

# 🧩 2. SQL-скрипт: `checking-jira-tasks.sql`

## 2.1. Формирование полной таблицы закрытых задач

Создаётся таблица `spd_tasks_reporters_full`, где данные задач объединяются:

* со статусами Jira,
* оргструктурой (management unit, lvl6, lvl8, legal unit),
* датой решения задачи.

### 📊 Пример таблицы

| issue     | status_name | creation_date | resolution_dttm     | type_nm   | login      | management_unit_nm | lvl8_mngt_unit_nm | legal_unit_nm |
| --------- | ----------- | ------------- | ------------------- | --------- | ---------- | ------------------ | ----------------- | ------------- |
| SPD-12345 | Done        | 2023-05-12    | 2023-05-15 14:11:22 | TCRM Call | i.petrov   | Support Group 1    | Contact Center    | Tinkoff Bank  |
| SPD-12346 | Done        | 2023-06-02    | 2023-06-03 09:17:44 | TCRM Call | smirnova.m | Support Group 3    | Digital Support   | Tinkoff Bank  |

---

## 2.2. Подсчёт закрытых задач по месяцам

Таблица `spd_tasks_month`:

| y    | mes_num | mes  | tasks_amount |
| ---- | ------- | ---- | ------------ |
| 2023 | 5       | May  | 412          |
| 2023 | 6       | June | 398          |
| 2023 | 7       | July | 450          |

---

## 2.3. Общая статистика по подразделениям

Таблица `spd_tasks_full_count_data`

| y    | mes_num | mes | lvl6_mngt_unit_nm | management_unit_nm | tasks_amount |
| ---- | ------- | --- | ----------------- | ------------------ | ------------ |
| 2023 | 5       | May | Digital Support   | Support Group 1    | 150          |
| 2023 | 5       | May | Digital Support   | Support Group 3    | 120          |
| 2023 | 5       | May | Contact Center    | Hotline Team       | 142          |

---

## 2.4. Процент закрытия задач по департаментам

| y    | mes_num | mes | lvl6_mngt_unit_nm | tasks_amount | percentage |
| ---- | ------- | --- | ----------------- | ------------ | ---------- |
| 2023 | 5       | May | Digital Support   | 270          | 65.53%     |
| 2023 | 5       | May | Contact Center    | 142          | 34.47%     |

---

## 2.5. Процент закрытия задач по группам

| y    | mes_num | mes | management_unit_nm | tasks_amount | percentage |
| ---- | ------- | --- | ------------------ | ------------ | ---------- |
| 2023 | 5       | May | Support Group 1    | 150          | 36.4%      |
| 2023 | 5       | May | Support Group 3    | 120          | 29.1%      |
| 2023 | 5       | May | Hotline Team       | 142          | 34.4%      |

---

## 2.6. Аналитика открытых задач

Таблица `spd_tasks_reporters_full_open` заполняется задачами, у которых статус:

### Назначение main_status:

| Jira статус                           | main_status |
| ------------------------------------- | ----------- |
| Ready for Specification, New, Backlog | Backlog     |
| Development, Review, To Do            | In Progress |
| Остальные                             | Block       |

### 📊 Пример

| issue     | status_name | main_status | creation_date | management_unit_nm |
| --------- | ----------- | ----------- | ------------- | ------------------ |
| SPD-12900 | Backlog     | Backlog     | 2024-02-01    | Support Group 2    |
| SPD-12911 | Review      | In Progress | 2024-02-02    | Support Group 1    |
| SPD-12913 | Blocked     | Block       | 2024-02-03    | Hotline Team       |

---

## 2.7. Подсчёт Backlog задач

| mes | main_status | management_unit_nm | count |
| --- | ----------- | ------------------ | ----- |
| May | Backlog     | Support Group 1    | 23    |
| May | Backlog     | Support Group 3    | 17    |

---

## 2.8. Подсчёт задач In Progress

| mes | main_status | management_unit_nm | count |
| --- | ----------- | ------------------ | ----- |
| May | In Progress | Support Group 1    | 15    |
| May | In Progress | Support Group 3    | 8     |

---

# 🚀 Итог

Проект полностью автоматизирует:

* сбор Jira-данных,
* маппинг на оргструктуру,
* подсчёт и анализ закрытых задач,
* мониторинг открытых задач по статусам,
* аналитическую отчётность для менеджмента.

---

# 🇬🇧 **Jira Task Analytics (Python + SQL)**

## 📌 Project Overview

This project automates the extraction, processing, and analysis of Jira tasks for the **SPD** project.
It consists of two main parts:

1. **Python script (`get_jira_task.py`)** — extracts tasks from Jira and builds a reporter dataset.
2. **SQL script (`checking-jira-tasks.sql`)** — performs multi-level analytics:

   * joining Jira data with org structure,
   * closed task analytics,
   * percent contribution by department and team,
   * open task analytics (Backlog, In Progress, Block).

---

# 🧩 1. Python script: `get_jira_task.py`

### What it does:

* Connects to Jira API.
* Executes:

```
project=SPD AND created > "2023-04-30"
```

* Extracts for each task:

  * issue key,
  * creation date,
  * issue type,
  * reporter's name and email,
  * login (email prefix).
* Builds a pandas DataFrame.
* Uploads the table to GP storage.

### 📊 Example DataFrame: `spd_tasks`

| issue     | creation_date       | issue_type | reporter       | email                                                 | login      |
| --------- | ------------------- | ---------- | -------------- | ----------------------------------------------------- | ---------- |
| SPD-12345 | 2023-05-12 14:33:01 | Bug        | Ivan Petrov    | [i.petrov@company.ru](mailto:i.petrov@company.ru)     | i.petrov   |
| SPD-12346 | 2023-05-12 17:20:12 | TCRM Call  | Maria Smirnova | [smirnova.m@company.ru](mailto:smirnova.m@company.ru) | smirnova.m |
| SPD-12347 | 2023-05-13 09:11:44 | Task       | Sergey Ivanov  | [s.ivanov@company.ru](mailto:s.ivanov@company.ru)     | s.ivanov   |

---

# 🧩 2. SQL script: `checking-jira-tasks.sql`

## 2.1. Full closed task dataset

Creates table `spd_tasks_reporters_full` with:

* Jira statuses,
* org units (lvl6, lvl8, management unit, legal unit),
* resolution date.

### 📊 Example

| issue     | status_name | creation_date | resolution_dttm     | type_nm   | login    | management_unit_nm | lvl8_mngt_unit_nm | legal_unit_nm |
| --------- | ----------- | ------------- | ------------------- | --------- | -------- | ------------------ | ----------------- | ------------- |
| SPD-12345 | Done        | 2023-05-12    | 2023-05-15 14:11:22 | TCRM Call | i.petrov | Support Group 1    | Contact Center    | Tinkoff Bank  |

---

## 2.2. Monthly closed task count

| y    | mes_num | mes  | tasks_amount |
| ---- | ------- | ---- | ------------ |
| 2023 | 5       | May  | 412          |
| 2023 | 6       | June | 398          |

---

## 2.3. Department-level statistics

| y    | mes_num | mes | lvl6_mngt_unit_nm | management_unit_nm | tasks_amount |
| ---- | ------- | --- | ----------------- | ------------------ | ------------ |
| 2023 | 5       | May | Digital Support   | Support Group 1    | 150          |

---

## 2.4. Percentage of closed tasks by department

| y    | mes_num | mes | lvl6_mngt_unit_nm | tasks_amount | percentage |
| ---- | ------- | --- | ----------------- | ------------ | ---------- |
| 2023 | 5       | May | Digital Support   | 270          | 65.53%     |

---

## 2.5. Percentage of closed tasks by team

| y    | mes_num | mes | management_unit_nm | tasks_amount | percentage |
| ---- | ------- | --- | ------------------ | ------------ | ---------- |
| 2023 | 5       | May | Support Group 1    | 150          | 36.4%      |

---

## 2.6. Open task analytics

Table `spd_tasks_reporters_full_open` categorizes tasks into:

| Jira statuses               | main_status |
| --------------------------- | ----------- |
| New, Backlog, Specification | Backlog     |
| Development, Review, To Do  | In Progress |
| Others                      | Block       |

---

## 2.7. Backlog task count

| mes | main_status | management_unit_nm | count |
| --- | ----------- | ------------------ | ----- |
| May | Backlog     | Support Group 1    | 23    |

---

## 2.8. In Progress task count

| mes | main_status | management_unit_nm | count |
| --- | ----------- | ------------------ | ----- |
| May | In Progress | Support Group 1    | 15    |

---

# 🚀 Summary

The project fully automates Jira analytics:

* data extraction,
* org structure enrichment,
* closed task calculation,
* open task tracking,
* month-by-month reporting,
* performance contribution by teams and departments.

---


