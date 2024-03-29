[EN](README.md) | ***RU***

# WebP Utility

Набор утилит для быстрой и удобной установки, настройки и использования инструментария для работы с форматом изображений *WebP*.

## Это необходимо сделать перед работой со скриптами PowerShell

По умолчанию выполнение скриптов в системе Windows выключено, следовательно при работе с системой "По умолчанию" PowerShell откажется от работы со скриптами и вы не сможете использовать утилиты из набора.

Чтобы решить эту проблему достаточно открыть PowerShell "От администратора":

`Ввести в поиск Windows "PowerShell" -> *Правая кнопка мыши по PowerShell* -> Запуск от имени администратора`

После этого вам необходимо выполнить следующую команду:

`Set-ExecutionPolicy RemoteSigned`

Теперь вы можете выполнять скрипты в своей системе.

Если вы хотите обезопасить себя после установки пакета WebP, вы можете там же ввести следующую команду, чтобы вернуть настройки по-умолчанию:

`Set-ExecutionPolicy Restricted`

## Что у нас тут?

### **Установщик пакетов WebP** *(Необходимо для работы)*

Для установки *WebP* на ваше устройство достаточно запустить в *PowerShell* файл *PS_WebP_Installer.ps1*.

`Правая кнопка мыши -> Выполнить с помощью PowerShell`

Установщик сам скачает последнюю версию библиотек для работы с *WebP*, установит необходимые материалы и внедрит путь к ним в *Переменные Среды*.

### **Конвертер** *(Работает для всех изображений в папке)*

Если вам необходимо просто переконвертировать формат *JPG/PNG* в *WebP* вы можете запустить файл *PS_All_Images_To_WebP.ps1* который, по умолчанию, переконвертирует лежащие с ним в одной папке изображения формата *JPG/PNG* в изображения формата *WebP*.

## Настройка

Каждая из утилит в самом начале имеет блок доступных настроек с необходимыми пояснениями функционала. 

Для изменения настроек необходимо сделать так:

`*Правая кнопка мыши* -> Открыть с помощью -> *Выбрать любой подходящий вам текстовый редактор*`

После этого вы можете видеть/изменять настройки каждой из утилит.