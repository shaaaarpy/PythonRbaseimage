FROM ubuntu:18.04

LABEL maintainer="Amit Jaggi <amit15013@iiitd.ac.in>"

# Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \ 
	&& apt-get install -y --no-install-recommends \
	    apt-utils \
		ed \
		less \
		locales \
		vim-tiny \
		wget \
		ca-certificates \
		apt-transport-https \
		gsfonts \
		gnupg2 \
		libxml2 \
		libxml2-dev \
		libpq-dev \
	&& rm -rf /var/lib/apt/lists/*

# Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" > /etc/apt/sources.list.d/cran.list

# note the proxy for gpg
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9

ENV R_BASE_VERSION 3.6.1

# Now install R and littler, and create a link for littler in /usr/local/bin
# Also set a default CRAN repo, and make sure littler knows about it too
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		littler \
        r-cran-littler \
		r-base=${R_BASE_VERSION}* \
		r-base-dev=${R_BASE_VERSION}* \
		r-recommended=${R_BASE_VERSION}* \
        && echo 'options(repos = c(CRAN = "https://cloud.r-project.org/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site \
        && echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r \
	&& ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r \
	&& ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r \
	&& ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
	&& ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
	&& install.r docopt \
	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
	&& rm -rf /var/lib/apt/lists/*

CMD ["R"]

RUN apt-get clean -y
RUN apt-get update -y
RUN apt-get install apt-utils -y
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8

# install python3.6
RUN wget https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tgz
RUN tar -xvf Python-3.6.3.tgz
RUN apt-get install libsqlite3-dev
RUN apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev
RUN cd Python-3.6.3 && ./configure --enable-optimizations && ./configure --enable-loadable-sqlite-extensions && make -j8 && make install
RUN cd ..

RUN rm -rf Python-3.6.3*

#Setting up the pip url for internal packages
ENV PIP_IP=54.245.179.143
ENV PIP_PORT=80
ENV PIP_URL="http://$PIP_IP:$PIP_PORT/"
ENV PIP_EXTRA_INDEX_URL=$PIP_URL
RUN mkdir ~/.pip
RUN touch ~/.pip/pip.conf
RUN echo "[global]\nextra-index-url = $PIP_URL\n[install]\ntrusted-host=$PIP_IP" > ~/.pip/pip.conf
#Installing dependencies for R
RUN  apt-get install -y --no-install-recommends \
		libcurl4-openssl-dev \
		libxml2-dev \
		libfftw3-dev 

COPY r_packages/install-packages.R /tmp/
RUN cd /tmp && R -f /tmp/install-packages.R && rm -rf /tmp/*
