FROM public.ecr.aws/d3j8x8q7/olympus-base:latest

WORKDIR /app

# Copy the repository contents (the build context is the repo at the
# challenge commit hash) into the image.
COPY . .

# Install ezdxf's runtime dependencies and pytest. The fonttools dependency
# is required for the public ezdxf package import even though the buffer
# module itself does not use it.
RUN pip install --no-cache-dir \
        "typing_extensions>=4.6.0" \
        "pyparsing>=3.0.0" \
        numpy \
        fonttools \
        pytest && \
    pip install --no-cache-dir -e .

CMD ["/bin/bash"]
