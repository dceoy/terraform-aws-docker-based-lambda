FROM public.ecr.aws/lambda/python:3.12

RUN set -e \
      && yum -y upgrade \
      && yum clean all \
      && rm -rf /var/cache/yum

RUN set -e \
      && /var/lang/bin/pip install -U --no-cache-dir pip \
      && /var/lang/bin/pip install -U --no-cache-dir awslambdaric

COPY app.py /var/task/app.py

ENTRYPOINT ["/var/lang/bin/python", "-m", "awslambdaric"]
CMD [ "app.lambda_handler" ]
