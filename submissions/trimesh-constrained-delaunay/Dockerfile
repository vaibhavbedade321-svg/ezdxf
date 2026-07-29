FROM public.ecr.aws/d3j8x8q7/olympus-base-python:latest

WORKDIR /app

COPY . .

# Pinned so the image is reproducible, and installed at build time because the
# container runs offline. The package under test is imported straight from
# /app, so it needs no install step of its own.
RUN pip install --no-cache-dir \
      numpy==2.4.6 \
      scipy==1.17.1 \
      shapely==2.1.2 \
      networkx==3.6.1 \
      mapbox_earcut==2.0.0 \
      manifold3d==3.5.2 \
      rtree==1.4.1 \
      lxml==6.1.1 \
      jsonschema==4.26.0 \
      pillow==12.3.0 \
      xxhash==3.8.1 \
      colorlog==6.12.0 \
      charset-normalizer==3.4.6 \
      svg.path==7.1 \
      pycollada==0.9.3 \
      httpx==0.28.1 \
      vhacdx==0.0.10 \
      pytest==9.1.1

CMD ["/bin/bash"]
