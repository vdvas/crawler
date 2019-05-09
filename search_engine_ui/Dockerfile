From ubuntu:16.04

ENV UI_HOME /ui
WORKDIR $UI_HOME

COPY . $UI_HOME/

ENV MONGO mongo
ENV MONGO_PORT 27017
ENV FLASK_APP ui.py

RUN apt-get update && apt-get install -y python-pip
RUN pip install -r requirements.txt
WORKDIR /$UI_HOME/ui
ENTRYPOINT ["gunicorn","ui:app","-b","0.0.0.0"]
