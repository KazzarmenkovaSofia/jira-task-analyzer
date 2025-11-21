# Theme Statistic & First Chat Analyzer — SQL Pipeline  
### RU 🇷🇺 | EN 🇺🇸

---

## 🇷🇺 Описание проекта

Этот SQL-процесс строит две таблицы:

1. **theme_statistic**  
   Используется для извлечения данных о консультациях, разборе текстового поля `consultation_desc` на отдельные колонки (`type`, `brand`, `provider`, `process`, `topic`, `subTopic`, `subTopic2`) и связывания консультаций с коммуникациями и чат-переписками.

2. **first_chat_analiser**  
   Построение таблицы, содержащей первый момент появления сообщения в чат-треде (по `chat_thread_rk`) за период.

Основная задача — получить чистые аналитические данные для последующей обработки, дэшбордов, статистики тем обращений и анализа чатов.

---

## 🇷🇺 Логика работы SQL

### 1. Создание таблицы `theme_statistic`
- Удаляет таблицу, если такая уже существует.  
- Создает новую таблицу на основе данных из:
  - `prod_v_dds.consultation`
  - `prod_v_dds.communication`
  - `prod_v_dds.COMMUNICATION_X_CHAT_THREAD`
  - `prod_v_dds.CHAT_THREAD`
- Фильтрует консультации:
  - тематика: `Auto.Travel.Partners`
  - период: `2024-10-01` — `2024-11-01`
- Распарсивает строковое поле `consultation_desc`, где данные хранятся в формате, напоминающем JSON.
- Извлекает отдельные атрибуты: `type`, `brand`, `provider`, `order`, `process`, `topic`, `subTopic`, `subTopic2`.
- Добавляет ключи коммуникации и идентификаторы тредов.

### 2. Создание таблицы `first_chat_analiser`
- Удаляет таблицу при наличии.
- Создает таблицу с минимальным временем создания сообщения (`min(create_dttm)`) по каждому `chat_thread_rk`.
- Используется таблица `prod_v_dds.CHAT_MESSAGE`.

---

## 🇺🇸 Project Description

This SQL pipeline generates two analytical tables:

1. **theme_statistic**  
   Parses consultation descriptions, extracts structured fields (`type`, `brand`, `provider`, `process`, `topic`, etc.), and joins consultation records with communication and chat-thread metadata.

2. **first_chat_analiser**  
   Builds a table containing the first message timestamp for each chat thread within the specified date range.

The goal is to prepare structured analytical data for reporting, dashboards, and chat topic analytics.

---

## 🇺🇸 SQL Logic Overview

### 1. Creating `theme_statistic`
- Drops the table if it already exists.  
- Creates a new table based on:
  - `prod_v_dds.consultation`
  - `prod_v_dds.communication`
  - `prod_v_dds.COMMUNICATION_X_CHAT_THREAD`
  - `prod_v_dds.CHAT_THREAD`
- Filters consultations by:
  - subject: `Auto.Travel.Partners`
  - date range: `2024-10-01` — `2024-11-01`
- Parses the semi-JSON string `consultation_desc`.
- Extracts components: `type`, `brand`, `provider`, `order`, `process`, `topic`, `subTopic`, `subTopic2`.
- Adds communication keys and chat thread identifiers.

### 2. Creating `first_chat_analiser`
- Drops the table if it exists.
- Creates a table with the earliest message timestamp (`min(create_dttm)`) for each `chat_thread_rk`.
- Uses `prod_v_dds.CHAT_MESSAGE`.

---

## 📌 SQL Code (Used for This Pipeline)

```sql
drop table if exists theme_statistic;

create table theme_statistic as
SELECT 
    c.create_dttm::date,
    consultation_rk,
    consultation_desc,
    trim(both from substring(split_part(consultation_desc,',',1), '"type":([ ()0-9A-zА-я"-]+)'), '"') AS type,
    trim(both from substring(split_part(consultation_desc,',',2), '"brand":([ ()0-9A-zА-я"-]+)'), '"') AS brand,
    trim(both from substring(split_part(consultation_desc,',',3), '"provider":([ ()0-9A-zА-я"-]+)'), '"') AS provider,
    trim(both from substring(split_part(consultation_desc,',',4), '"order":([ ()0-9A-zА-я"-]+)'), '"') AS ord,
    trim(both from substring(split_part(consultation_desc,',',5), '"process":([ ()0-9A-zА-я"-]+)'), '"') AS process,
    trim(both from substring(split_part(consultation_desc,',',6), '"topic":([ () ()0-9A-zА-я"-]+)'), '"') AS topic,
    trim(both from substring(split_part(consultation_desc,',',7), '"subTopic":([ ()0-9A-zА-я"-]+)'), '"') AS subTopic,
    trim(both from substring(split_part(consultation_desc,',',8), '"subTopic2":([ ()0-9A-zА-я"-]+)'), '"') AS subTopic2,
    c.communication_rk,
    prod_v_dds.communication.communication_id,
    prod_v_dds.communication.communication_method_cd,
    prod_v_dds.communication.communication_direction_cd,
    prod_v_dds.COMMUNICATION_X_CHAT_THREAD.chat_thread_rk,
    prod_v_dds.CHAT_THREAD.chat_thread_id
FROM prod_v_dds.consultation c, prod_v_dds.communication
LEFT JOIN prod_v_dds.COMMUNICATION_X_CHAT_THREAD 
    ON prod_v_dds.communication.communication_rk = prod_v_dds.COMMUNICATION_X_CHAT_THREAD.communication_rk
LEFT JOIN prod_v_dds.CHAT_THREAD 
    ON prod_v_dds.COMMUNICATION_X_CHAT_THREAD.chat_thread_rk = prod_v_dds.CHAT_THREAD.chat_thread_rk
WHERE true
    AND c.consultation_subject_dk = 'Auto.Travel.Partners'
    AND c.create_dttm::date BETWEEN '2024-10-01' AND '2024-11-01'
    AND c.communication_rk = prod_v_dds.communication.communication_rk;

drop table if exists first_chat_analiser;

create table first_chat_analiser as
SELECT 
    chat_thread_rk, 
    min(create_dttm)
FROM prod_v_dds.CHAT_MESSAGE
WHERE create_dttm::date BETWEEN '2024-10-01' AND '2024-11-01'
GROUP BY chat_thread_rk;
