FROM python:3.9

# Set the working directory
WORKDIR /code

COPY ./requirements.txt /code/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt


COPY . /code

CMD ["python", "main.py"]