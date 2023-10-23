# Etapa 1: Compilación del código fuente
FROM alpine:latest as build

# Instala las herramientas y dependencias necesarias
RUN apk --no-cache add g++ make cmake git automake autoconf libtool libgcrypt-static libgcrypt-dev libgcrypt

# Clona el repositorio de Tripwire
RUN git clone https://github.com/Tripwire/tripwire-open-source /tripwire

# Configura y compila el código
WORKDIR /tripwire
RUN mkdir build
WORKDIR /tripwire
RUN  autoreconf --force --install
RUN  ./autogen.sh
RUN  ./configure --sysconfdir=/etc/tripwire
RUN make CXXFLAGS="-std=c++14 -static -static-libstdc++" -j24

# Etapa 2: Imagen final
FROM alpine:latest
RUN apk --no-cache add libtool libgcrypt-static

RUN mkdir /etc/tripwire
# Copia los archivos binarios compilados de la etapa anterior
COPY --from=build /tripwire/bin  /usr/bin/
COPY --from=build /tripwire/lib  /lib
COPY --from=build /tripwire/policy  /etc/tripwire/policy
COPY --from=build /tripwire/contrib  /etc/tripwire/contrib

# Define el comando por defecto al iniciar el contenedor
CMD ["tripwire"]

