# Проект от курса OTUS DevOps 2018-11  
За основу взято приложение, предложенное в курсе.  
Ссылка на гитхаб crawler https://github.com/express42/search_engine_crawler  
Ссылка на гитхаб ui https://github.com/express42/search_engine_ui  

# CI/CD. Настройка Gitlab CI.  
Создадим ВМ в GCP, используя образ ubuntu 16.04 и поставим галочки 'Разрешить трафик HTTP' и 'Разрешить трафик HTTPS'.  
Установим Gitlab CI, при помощи выполнения скрипта.  
Склонируем репозиторий  
`git clone https://github.com/vdvas/crawler.git`  
В файл docker-compose-gitlab.yml внесем правку в строке external_url, указав правильный url.  
Выполним установку Gitlab `./crawler/install-gitlab.sh`  
Зайдем на вэб интерфейс Gitlab, создадим проект под названием crawler, перейдем в настройки Runner и используя url и token, зарегестрируем Runner.  
`sudo docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false --url http://some_url --registration-token some_token --docker-privileged --executor docker`  
   
# Подготовка GCP.  
Для управления ресурсами GCP нам необходимо заранее создать файл ключа для сервисного аккаунта через IAM.  
Для провижининга ВМ средствами terraform необходимо создать ssh ключи для проекта в GCP.  
# Создание ключа для сервисного аккаунта GCP.  
В консоли GCP в меню навигации переходим в IAM и администрирование.  
Переходим в раздел сервисные аккаунты.  
Создаем ключ для дефолтной учетной записи сервисного аккаунта в формате json.  
Ключ должен находиться в репозитории, в директории terraform и иметь имя account.json (из репозитория на Github я этот ключ удалил).  
# Создание ssh ключей.
Выполним команду для генерации пары ключей на ВМ  
ssh-keygen -t rsa -f ~/.ssh/appuser -C appuser  
Перейдем в GCP консоль - compute engine - метаданные - ssh ключи.  
Вставим содержимое ~/.ssh/appuser.pub в новый ssh ключ.  
Ssh ключи должны находиться в репозитории, в директории terraform/ssh  
`cp -f ~/.ssh/appuser* ~/crawler/terraform/ssh/`  
# Terraform variables.  
В репозитории в файле terraform/terraform.tfvars поменять параметр project на правильный.  

# Описание pipeline.
В пайплайне происходит тестирование контейнеров crawler и ui.  
На этапе деплоя runner при помощи terraform создает в GCP ВМ и создает инфраструктуру при помощи docker-compose.  

# Push to Gitlab repository.   
Запушим наш репозиторий из Github в Gitlab.  
```
cd ~/crawler  
git remote add gitlab http://35.228.195.238/root/crawler.git  
git push gitlab master  
```
# Проверка работоспособности  
При успешном завершении всех этапов пайплайна можно зайти на вэб интерфейс приложения, чтобы убедиться что оно работает.  
Определим внешний ip адрес ВМ, созданной на этапе деплоя.  
Зайдет по адресу http://ip:8000  
