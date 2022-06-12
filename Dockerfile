# base image
FROM python:3.9.13-slim

RUN apt-get update 
WORKDIR /app

# add and install requirements
COPY ./requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt
RUN pip install flask
RUN pip install requests

# add app
COPY . /app
ENV PORT 5000
EXPOSE 5000
ENTRYPOINT flask run --host=0.0.0.0
# ENTRYPOINT flask run
# CMD ["chmod +x startapp.sh"]
# ENTRYPOINT ["./startapp.sh"]
# # run server
# ENTRYPOINT ["flask run"]