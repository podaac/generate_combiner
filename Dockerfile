# Stage 0 - Create from Perl 5.34.1-slim-buster image and install dependencies
# FROM perl:5.34.1-slim-buster as stage0
FROM perl:5.34.1-slim-buster
RUN apt update && apt install -y tcsh libfreetype6 libxpm4 libxmu6 libidn11 procps build-essential libxinerama-dev
RUN ln -s /usr/lib/x86_64-linux-gnu/libXpm.so.4.11.0 /usr/lib/x86_64-linux-gnu/libXp.so.6

# Stage 1 - Copy Generate code
# FROM stage0 as stage1
RUN /bin/mkdir /data
COPY . /app

# Stage 2 - IDL installation
# FROM stage1 AS stage2
ARG IDL_INSTALLER
ARG IDL_VERSION
RUN /bin/mkdir /root/idl_install \
    && /bin/tar -xf /app/idl/install/$IDL_INSTALLER -C /root/idl_install/ \
    && /bin/cp /app/idl/install/idl_answer_file /root/idl_install/ \
    && /root/idl_install/install.sh -s < /root/idl_install/idl_answer_file \
    && /bin/cp /app/idl/install/lic_server.dat /usr/local/idl/license/ \
    && /bin/ln -s /usr/local/idl/$IDL_VERSION/bin/idl /usr/local/bin \
    && /bin/rm -rf /app/idl/install/$IDL_INSTALLER \
    && /bin/rm -rf /root/idl_install

# Stage 2 - Local Perl Library
# FROM stage1 as stage2
RUN /usr/bin/yes | /usr/local/bin/cpan App::cpanminus \
    && /usr/local/bin/cpanm Date::Calc \
    && /usr/local/bin/cpanm Bundle::LWP \
    && /usr/local/bin/cpanm File::NFSLock \
    && /usr/local/bin/cpanm JSON

# Stage 3 - Execute code
# FROM stage2 as stage3
LABEL version="0.1" \
    description="Containerized Generate: Combiner"
ENTRYPOINT [ "/bin/tcsh", "/app/shell/startup_level2_combiners.csh" ]