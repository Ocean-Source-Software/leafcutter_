FROM mambaorg/micromamba:1.3.0
COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes

RUN apt-get install -y git && \
    git clone https://github.com/Bek/leafcutter.git --branch workflows --depth 1