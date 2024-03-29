#FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS base
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

#FROM mcr.microsoft.com/dotnet/sdk:3.1-alpine AS build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
USER root
COPY . .
RUN dotnet restore "pfs.csproj"

FROM build AS publish
RUN dotnet publish ./pfs.csproj -c release -o /app/publish
USER root

FROM base AS final
USER root
RUN apt update && apt install -y libglibd-2.0-0 fuse
WORKDIR /app
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
COPY --from=publish /app/publish .
RUN cp /app/runtimes/linux-x64/native/libMonoFuseHelper.so /lib/libMonoFuseHelper
VOLUME /mnt
ENTRYPOINT ["dotnet", "pfs.dll"]

