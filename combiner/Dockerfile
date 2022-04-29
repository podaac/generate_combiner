# Stage 0 - Create from Perl 5.34.1-slim-buster image and install dependencies
# FROM perl:5.34.1-slim-buster as stage0
FROM perl:5.34.1-slim-buster
RUN apt update && apt install -y tcsh libfreetype6 libxpm4 libxmu6 libidn11 procps build-essential wget
RUN ln -s /usr/lib/x86_64-linux-gnu/libXpm.so.4.11.0 /usr/lib/x86_64-linux-gnu/libXp.so.6

# Stage 1 - Copy Generate code
# FROM stage0 as stage1
RUN /bin/mkdir /data
COPY . /app

# Stage 2 - Local Perl Library
# FROM stage1 as stage2
RUN /usr/bin/wget -P /root https://cpan.metacpan.org/authors/id/H/HA/HAARG/local-lib-2.000029.tar.gz 
RUN /bin/tar -xzf /root/local-lib-2.000029.tar.gz -C /root/
WORKDIR "/root/local-lib-2.000029"
RUN /usr/local/bin/perl Makefile.PL --bootstrap 
RUN /usr/bin/make test 
RUN /usr/bin/make install 
RUN echo 'eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"' >>~/.bashrc
ENV PATH="/root/perl5/bin${PATH:+:${PATH}}"
ENV PERL5LIB="/root/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
ENV PERL_LOCAL_LIB_ROOT="/root/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
ENV PERL_MB_OPT="--install_base \"/root/perl5\""
ENV PERL_MM_OPT="INSTALL_BASE=/root/perl5"
ENV PERL_MM_USE_DEFAULT=1 
ENV PERL_EXTUTILS_AUTOINSTALL="--defaultdeps" 
RUN /usr/local/bin/perl -MCPAN -Mlocal::lib -e 'CPAN::install(Date::Calc)'
RUN /usr/local/bin/perl -MCPAN -Mlocal::lib -e 'CPAN::install(File::NFSLock)'
RUN /bin/rm -rf /root/local-lib-2.000029*

# Stage 3 - Execute code
# FROM stage2 as stage3
LABEL version="0.1" \
    description="Containerized Generate: Combiner"
ENTRYPOINT [ "/bin/tcsh", "/app/shell/startup_level2_combiners.csh" ]