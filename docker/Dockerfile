FROM mambaorg/micromamba:1.3.0
COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes

USER root

RUN apt-get update && apt-get install -y git && \
    cd $HOME && \
    git clone https://github.com/Bek/leafcutter.git --branch workflows --depth 1

USER $MAMBA_USER
WORKDIR $HOME/$MAMBA_USER/leafcutter