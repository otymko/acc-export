# Экспорт диагностик из АПК для Sonar

## Минимальные требования

* SonarQube 7.9 и выше
* Плаформа 1С 8.3.10 и выше
* 1С: АПК 1.2.3.20
* Установленный плагин для SonarQube https://github.com/1c-syntax/sonar-bsl-plugin-community
* Установленный Sonar Scanner https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner

## Пример использования

1. Создаем каталог проекта для Sonar. Из каталога **Sample** копируем файл с настройками sonar-scaner **sonar-project.properties**. В файле меняем настройки:
   * sonar.host.url - адрес сервера SonarQube
   * sonar.projectKey - ключ проекта в SonarQube
2. Выгружаем в папку **src** в каталоге проекта файлы конфигурации.
    * Можно сделать из конфигуратора 1С. Если используются обычные формы, нужно извлечь form.bin. Для этого в каталог проекта копируем и `tools/run.os`. Запускаем выполнение скрипта в каталоге проекта `oscript run.os`.
    * Если используется хранилище - можно использовать `gitsync`. При использовании обычных форм - распаковать формы и переименоват модули (средствами `gitsync`).
3. Из конфигурации 1С: АПК запускаем обработку `acc-export.epf`. Заполняем реквизиты: "конфигурация", "каталог проекта". Нажимаем "Выполнить".
4. Запускаем sonar-scanner.

## Пакетный режим

Параметры пакетного режима

* `acc.propertiesPaths` - строка. Путь к файлу настроек.
* `acc.check` - булево. Запустить проверку конфигурации. Ложь, если нужно выгрузить ошибки существующей проверки.
* `acc.recreateProject` - булево. Пересоздать конфигурацию проверки. АПК кеширует часть ошибок и при перепроверке они все равно отображаются, даже если были исправлены. Установленный флаг создает новую конфигурацию и запускает ее проверку с нуля.
* `acc.projectKey` - строка. Наименование конфигурации в АПК.
* `acc.catalog` - строка. Каталог проекта **(не к src)**
* `acc.sources` - строка. Путь / каталог исходных кодов, например `src`.
* `acc.format` - строка. Формат экспорта из АПК (`reportjson` или `genericissue`). По-умолчанию `reportjson`. Для формата `reportjson` требуется использовать `acc.titleError=code`.
* `acc.titleError` - строка. Представление вывода ошибки при экспорте. Может принимать значения: `code` (только код ошибки), `name` (только наименование ошибки), `codeName` (код и наименование ошибки). По-умолчанию `code`.
* `acc.result` - строка. Путь к файлу результату. По умолчанию, КаталогПроекта/acc-generic-issue.json для формата GenericIssue или КаталогПроекта/acc-json.json для reportjson.
* `acc.objectErrors` - булево. Выгружать ошибки объектов, которые не привязаны к модулю. Например, ошибки в ролях или орфография в элементах формы. Ошибки будут привязаны к первой строке модуля объекта, модуля менеджера или модуля приложения.
* `acc.fileClassificationError` - строка. Путь к файлу, содержащему настройки серьезности и типов ошибок АПК для SonarQube. Также для ошибок можно задать время, необходимое для их исправления. Сам файл настроек можно сгенерировать из обработки `acc-export.epf`, перейдя на форму настроек по кнопке `Классификация ошибок`.

Параметры можно передать через файл настроек acc.properties или через параметры запуска. Приоритет у параметров запуска.

Для использования формата **generic issue** при загрузке отчетов через sonar scanner нужно в конфигурационном файле `sonar-project.properties` указать свойство `sonar.externalIssuesReportPaths=acc-generic-issue.json`.

Пример скрипта запуска

``` bat
@chcp 65001

@set RUNNER_IBNAME=/FC:\Sonar\acc
@set RUNNER_DBUSER=Администратор

@call runner run --command "acc.propertiesPaths=C:\Sonar\sample\acc.properties;" --execute "C:\Sonar\acc-export.epf" --ordinaryapp=1
```

Пример шага из jenkinsfile

``` groovy
script {
    def cmd_properties = "\"acc.propertiesPaths=${ACC_PROPERTIES};acc.catalog=${CURRENT_CATALOG};acc.sources=${SRC};acc.result=${TEMP_CATALOG}\\acc.json;acc.projectKey=${PROJECT_KEY};acc.check=${ACC_check};acc.recreateProject=${ACC_recreateProject}\""
    cmd("runner run --ibconnection /F${ACC_BASE} --db-user ${ACC_USER} --command ${cmd_properties} --execute \"${BIN_CATALOG}acc-export.epf\" --ordinaryapp=1")
}
```

P.S. Если скрипт не ожидает выполнения сеанса 1С, то скорее всего нужно добавить параметр с нужной версией платформы. Например:
``` bat
...

@call runner run --v8version "8.3.10.2772" --command "acc.propertiesPaths=C:\Sonar\sample\acc.properties;" --execute "C:\Sonar\acc-export.epf" --ordinaryapp=1
```

## Замена одиночных CR
Для замены одиночных CR можно использовать скрипт tools/updatecr.os. Копируем этот скрипт в каталог с проектом. Например: `/sample/updatecr.os`. Далее в консоли выполняем команду в каталоге с проектом:
``` bat
oscript updatecr.os
```

## Отладка экспорта из АПК

Для запуска обработки в пользовательском режиме 1С, нужно в параметрах сеанса указать параметр запуска `\Debug` (например через конфигуратор **Сервис** - **Параметры** - **Запуск 1С: Предприятия** - **Основные** и заполнить поле **Параметр запуска**).

## Проблемые ситуации

Вы можете столкнуться с проблемами исходных кодов конфигурации 1C. Например, в файле модуля могут использоваться одновременно окончания строк LFCR и/или LF(Linux) и\или CR(MacOS). Эту проблему можно исправить, используя Notepad++. Ищем в каталоге **src** по регулярной строке `(\r)[^\n]` и меняем на \r\n (LFCR).

## Выгрузка описаний правил АПК в файл JSON

Для выгрузки описаний правил проверки АПК в файл формата JSON реализована обработка `rules-export.epf`. Выгрузка возможно в двух режимах: ручной или через пакетный запуск.

### Ручной способ выгрузки

Открываем обработку `rules-export.epf` в пользовательноском режиме 1С, указываем в поле `Путь к файлу выгрузки` путь к сохраняемому файлу json и нажимаем ``Выполнить``.

### Пакетный способ выгрузки

Создаем файл bat с содержимым:

``` bat
@chcp 65001

@set RUNNER_IBNAME=/FC:\Sonar\acc
@set RUNNER_DBUSER=Администратор

@call runner run --v8version "8.3.10.2772" --command "acc.rulesExportPath=path\to\rules-export.json;" --execute "C:\Sonar\rules-export.epf" --ordinaryapp=1
```

где:
* `path\to\rules-export.json` - путь к файлу выгрузки описаний правил


