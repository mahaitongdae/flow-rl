# Dockerfile

FROM haitongma1/diffusion-policy-jax:blackwell

RUN apt-get update && apt-get install -y --no-install-recommends \
        git parallel && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/typoverflow/flow-rl.git

WORKDIR /app/flow-rl

RUN pip install --no-cache-dir -e ".[online]"
RUN pip install --no-cache-dir gymnasium_robotics

CMD ["/bin/bash"]
