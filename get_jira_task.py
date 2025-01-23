from jira import JIRA
import pandas as pd

#                МЕНЯТЬ ЛОГИН И ПАРОЛЬ ТУТ
# --------------------------------------------------------
user = Z_ENV_KAZARMENKOVA_LOG  # ЛОГИН
password = Z_ENV_KAZARMENKOVA_PW  # ПАРОЛЬ
# --------------------------------------------------------

# Подключение к Jira
jira = JIRA(server='https://jira.tcsbank.ru', basic_auth=(user, password))

# Запрос для получения задач с полем "reporter"
jql_query = 'project=SPD AND created > "2023-04-30"'
issues = jira.search_issues(jql_query, fields="reporter,issuetype,created", maxResults=None)

# Извлечение информации о "reporter" для каждой задачи
# Создание списка данных для таблицы
data = []
for issue in issues:
    created = issue.fields.created
    issue_type = issue.fields.issuetype.name
    reporter = issue.fields.reporter
    reporter_name = reporter.displayName
    reporter_email = reporter.emailAddress
    reporter_login = reporter.emailAddress.split('@')[0]
    data.append({'issue': issue.key, 'creation_date': created, 'issue_type': issue_type, 'reporter': reporter_name, 'email': reporter_email, 'login':reporter_login})

# Создание таблицы с помощью pandas
df = pd.DataFrame(data)

# Вывод таблицы
print(df)

spd_tasks = pd.DataFrame(data)
tf.df_to_gp(spd_tasks, 'spd_tasks', gp_service = 'gp')
