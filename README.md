# Проект от курса OTUS DevOps 2018-11  
За основу взято приложение, предложенное в курсе.  
Ссылка на гитхаб crawler https://github.com/express42/search_engine_crawler  
Ссылка на гитхаб ui https://github.com/express42/search_engine_ui  

# CI/CD. Настройка Gitlab CI.  
Создадим ВМ в GCP, используя образ ubuntu 16.04 и установим Gitlab CI, при помощи выполнения скрипта.  
Склонируем репозиторий  
`git clone https://github.com/vdvas/crawler.git`  
В файл docker-compose-gitlab.yml внесем правку в строке external_url, указав правильный url.  
Выполним установку Gitlab `./crawler/install-gitlab.sh`  
Зайдем на вэб интерфейс Gitlab, создадим проект, перейдем в настройки Runner и используя url и token, зарегестрируем Runner.  
Создадим Runner  
`sudo docker run -d --name gitlab-runner --restart always -v /srv/gitlab-runner/config:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock gitlab/g
itlab-runner:latest`  
И зарегестрируем его  
`sudo docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false --url http://35.228.195.238 --registration-token nAPEAUPXa1S5MY3PDsVS --docker-privileged --executor docker`  

Запушим наш репозиторий из Github в Gitlab.  
```
cd ~/crawler  
git remote add gitlab http://35.228.195.238/root/proj.git  
git push gitlab master  
```
  
Создадим директорию и склонируем в нее репозиторий с Dockerfile для сборки образов crawler и ui  
```
mkdir /gitrepo
git clone https://github.com/vdvas/crawler /gitrepo
cp /gitrepo/search_engine_crawler/Dockerfile ~/search_engine_crawler
cp /gitrepo/search_engine_ui/Dockerfile ~/search_engine_ui
```
Добавим в пайплайн этап сборки, используя написанные Dockerfile на этапе запуска приложения.  
Репозиторий Gitlab CI можно посмотреть здесь  
https://github.com/vdvas/crawler-gitlab  

UPD 10.05.19:  
Использовать на этапе test образа dind и docker-compose  
Использовать команду docker exec для запуска тестов на crawler и ui.  
  
Пример .gitlab-ci.yml  
```
stages:
 - build
 - test
 - deploy
test_container_crawler:
  stage: test
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - apk update && apk upgrade
    - apk add --no-cache py-pip python
    - apk add libffi-dev openssl-dev libgcc python-dev build-base
    - pip install --no-cache-dir docker-compose
#    - chmod +x /usr/local/bin/docker-compose
  script:
    - cd test-environment/crawler
    - docker-compose up -d
    - docker-compose ps
    - docker-compose exec  crawler /bin/bash -c "python3 -m unittest discover -s tests/ && coverage run -m unittest discover -s tests/ && coverage report --include crawler/crawler.py"
```  
# Запуск приложения в docker-compose.  
Для запуска нужна ВМ в GCP (используем образ ubuntu 16.04LTS).  
Установим docker и docker-compose при помощи следующих команд.  
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install  -y docker-ce docker-ce-cli containerd.io
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```
Запустим контейнеры для работы приложений.  
```
git clone https://github.com/vdvas/crawler.git
cd crawler/
sudo docker-compose up -d
```
Проверим что все контейнеры запустились `sudo docker-compose ps`  
Определим ip адрес ВМ `curl 2ip.ru` и перейдем в браузере http://ip:8000  
Пример docker exec  
`sudo docker-compose exec  crawler /bin/bash -c "python3 -m unittest discover -s tests/ && coverage run -m unittest discover -s tests/ && coverage report --include crawler/crawler.py"`
