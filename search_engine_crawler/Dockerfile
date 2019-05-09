From ubuntu:16.04

ENV APP_HOME /app
WORKDIR $APP_HOME

COPY crawler $APP_HOME/crawler
COPY tests $APP_HOME/tests
COPY requirements.txt $APP_HOME/
COPY requirements-test.txt $APP_HOME/

RUN apt-get update && apt-get install -y python3-pip
ENV MONGO mongo
ENV MONGO_PORT 27017
ENV RMQ_HOST=rabbitmq
ENV RMQ_QUEUE=rabbitmq
ENV RMQ_USERNAME=rabbitmq
ENV RMQ_PASSWORD=rabbitmq
ENV CHECK_INTERVAL=1
ENV EXCLUDE_URLS='.*github.com'
ENV URL=https://vitkhab.github.io/search_engine_test_site

RUN pip3 install -r requirements.txt
RUN pip3 install -r requirements-test.txt
ENTRYPOINT python3 -u crawler/crawler.py $URL
