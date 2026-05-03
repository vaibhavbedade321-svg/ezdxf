FROM public.ecr.aws/d3j8x8q7/olympus-base:latest

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir \
        typing_extensions==4.15.0 \
        pyparsing==3.1.1 \
        numpy==2.4.4 \
        fonttools==4.62.1 \
        pytest==9.0.3

ENV PYTHONPATH=/app/src

CMD ["/bin/bash"]
