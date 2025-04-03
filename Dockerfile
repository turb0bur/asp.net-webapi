FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

COPY ["SampleWebApiAspNetCore.sln", "./"]
COPY ["SampleWebApiAspNetCore/SampleWebApiAspNetCore.csproj", "SampleWebApiAspNetCore/"]

RUN dotnet restore

COPY . .

WORKDIR "/src/SampleWebApiAspNetCore"
RUN dotnet publish "SampleWebApiAspNetCore.csproj" -c Release -o /app/publish

# ============================================

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 80

ENTRYPOINT ["dotnet", "SampleWebApiAspNetCore.dll"] 