# Экспорт диагностик из АПК для Sonar

## Минимальные требования

* SonarQube 7.5 и выше
* Плаформа 1С 8.3.10 и выше
* 1С: АПК 1.2.1.53
* Установленный плагин для SonarQube https://github.com/1c-syntax/sonar-bsl-plugin-community
* Установленный Sonar Scanner https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner

## Пример использования

1. Выполняем проверку конфигурации через 1С: АПК
2. Создаем каталог проекта для Sonar. Из каталога **Sample** копируем файл с настройками sonar-scaner **sonar-project.properties**. В файле меняем настройки:
   * sonar.host.url - адрес сервера SonarQube
   * sonar.projectKey - ключ проекта в SonarQube
3. Выгружаем в папку **src** в каталоге проекта файлы конфигурации (можно сделать из конфигуратора 1С)
4. Если используются обычные формы, нужно извлечь form.bin. Для этого в каталог проекта копируем из папки **Sample** `run.os`. Запускаем выполнение скрипта в каталоге проекта `oscript run.os`.
5. Из конфигурации 1С: АПК запускаем обработку `ВыгрузкаРезультатовПроверки.epf`. Заполняем реквизиты: "конфигурация", "каталог проекта". Нажимаем "Выполнить".
6. Получаем результаты проверки bsl-language-server. Прочитать можно по ссылке https://github.com/1c-syntax/bsl-language-server.
7. Запускаем sonar-scanner.

Пример скрипта для пунктов 6 и 7. Используем версию **bsl-language-server-0.2.1** Скрипт:

```
java -jar \path\to\file\bsl-language-server-0.2.1.jar --analyze --srcDir ./src --reporter json
\path\to\file\sonar-scanner.bat -X -D"sonar.login=687caef36034bdf6b1e535fa8f060c518739958d"
```

## Проблемые ситуации

Вы можете столкнуться с проблемами исходных кодов конфигурации 1C. Например, в файле модуля могут использоваться одновременно окончания строк LFCR и/или LF(Linux) и\или CR(MacOS). Эту проблему можно исправить, используя Notepad++. Ищем в каталоге **src** по регулярной строке `(\r)[^\n]` и меняем на \r\n (LFCR).