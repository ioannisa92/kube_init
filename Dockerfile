
#FROM pytorch/pytorch as tensor-base
FROM pytorch/pytorch:1.4-cuda10.1-cudnn7-devel as torch-base

WORKDIR /root/
COPY . /root

RUN pip install --no-cache-dir -r requirements.txt

# where s3 data will be stored
RUN mkdir /root/data/
RUN mkdir /root/results/
RUN mkdir /root/saved_models/


