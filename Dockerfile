# Utilizar CentOS Stream 8 como imagen base
FROM quay.io/centos/centos:stream8

# Etiquetar la imagen para identificar al mantenedor
LABEL maintainer="marko"

# Definir argumentos que pueden ser modificados en tiempo de construcción
ARG USER=centos
ARG V_ENV=boto3env
ARG VOLUME=/local-git

# Ejecutar como root para instalar paquetes y configurar el sistema
USER root

# Instalar herramientas necesarias, incluyendo Python 3 y pip
RUN dnf -y update && \
    dnf -y install python3 python3-pip && \
    dnf clean all

# Actualizar pip a la última versión
RUN pip3 install --upgrade pip

# Crear un nuevo usuario para la aplicación (en lugar de usar root)
RUN useradd -ms /bin/bash ${USER}

# Crear directorio para almacenar las credenciales de AWS y ajustar los permisos adecuados
RUN mkdir -p /home/${USER}/.aws && \
    chown -R ${USER}:${USER} /home/${USER}/.aws

# Asegúrate de tener un archivo `credentials` en tu contexto de construcción Docker
COPY credentials /home/${USER}/.aws/credentials

# Ajustar los permisos para asegurar que el archivo es privado
RUN chmod 600 /home/${USER}/.aws/credentials && \
    chown ${USER}:${USER} /home/${USER}/.aws/credentials

# Cambiar al usuario no root
USER ${USER}

# Instalar virtualenv usando pip
RUN pip3 install virtualenv

# Crear un entorno virtual para el proyecto
# Establecer el directorio de trabajo en el home del usuario
WORKDIR /home/${USER}

# Crear el entorno virtual en el directorio home del usuario
RUN python3 -m venv ${V_ENV}

# Establecer la variable de entorno PYTHONPATH para incluir el volumen montado
ENV PYTHONPATH=${VOLUME}

# Actualizar el PATH para usar las herramientas del entorno virtual
ENV PATH="/home/${USER}/${V_ENV}/bin:${PATH}"

# Asegurarse de copiar el archivo requirements.txt antes de ejecutar pip install
COPY requirements.txt ./
RUN pip3 install -r requirements.txt

# Copiar el resto del código de la aplicación al contenedor
COPY . .

# Configurar el comando predeterminado para ejecutar el script de Python
CMD ["python3","1.0.list_bucket.py"]