FROM public.ecr.aws/d3j8x8q7/olympus-base-python:latest

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir \
        pytest==9.1.1 \
        pytest-cov==7.1.0 \
        pytest-xdist==3.8.0 \
        pytest-gitconfig==0.9.0 \
        jsonschema==4.26.0 \
        colorama==0.4.6 && \
    pip install --no-cache-dir --no-deps -e packages/griffelib -e packages/griffecli

CMD ["/bin/bash"]
