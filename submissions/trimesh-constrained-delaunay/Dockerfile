FROM public.ecr.aws/d3j8x8q7/olympus-base-python:latest

WORKDIR /app

COPY . .

# the runtime container is offline so everything is installed here
RUN pip install --no-cache-dir -e ".[easy,test]"

CMD ["/bin/bash"]
