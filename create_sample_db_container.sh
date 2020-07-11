#!/bin/sh -e

# Create SQL Server Container with the following DB pre-installed 

CONTAINER_NAME="mssql_sample_container"


echo "Start docker run"
docker run \
    --name "$CONTAINER_NAME" \
    -e 'ACCEPT_EULA=Y' \
    -e 'SA_PASSWORD=!Pass01234' \
    -p 1433:1433 \
    -d \
    --rm \
    mcr.microsoft.com/mssql/server:2017-CU8-ubuntu


echo "Waiting for the SQL Server instance to start..."
for (( i=0; i<=10; i++ )); do
    if (docker logs "$CONTAINER_NAME" | grep -q "SQL Server is now ready for client connections."); then
        echo "ok"
        break
    else
        echo "Attempt: $i. Waiting another 5 seconds..."
        sleep 5
    fi
done


docker exec -it "$CONTAINER_NAME" wget -O /tmp/WideWorldImporters-Full.bak https://github.com/microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak
docker exec -it "$CONTAINER_NAME" wget -O /tmp/AdventureWorks2017.bak https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2017.bak
docker exec -it "$CONTAINER_NAME" wget -O /tmp/AdventureWorksDW2017.bak https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksDW2017.bak
docker exec -it "$CONTAINER_NAME" wget -O /tmp/WideWorldImportersDW-Full.bak https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImportersDW-Full.bak
docker exec -it "$CONTAINER_NAME" /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '!Pass01234' -Q 'RESTORE DATABASE WideWorldImporters FROM DISK = "/tmp/WideWorldImporters-Full.bak" WITH MOVE "WWI_Primary" TO "/var/opt/mssql/data/WideWorldImporters.mdf", MOVE "WWI_UserData" TO "/var/opt/mssql/data/WideWorldImporters_userdata.ndf", MOVE "WWI_Log" TO "/var/opt/mssql/data/WideWorldImporters.ldf", MOVE "WWI_InMemory_Data_1" TO "/var/opt/mssql/data/WideWorldImporters_InMemory_Data_1"'
docker exec -it "$CONTAINER_NAME" /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '!Pass01234' -Q 'RESTORE DATABASE AdventureWorks FROM DISK = "/tmp/AdventureWorks2017.bak" WITH MOVE "AdventureWorks2017" TO "/var/opt/mssql/data/AdventureWorks2017.mdf", MOVE "AdventureWorks2017_Log" TO "/var/opt/mssql/data/AdventureWorks2017.ldf"'
docker exec -it "$CONTAINER_NAME" /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '!Pass01234' -Q 'RESTORE DATABASE AdventureWorksDW FROM DISK = "/tmp/AdventureWorksDW2017.bak" WITH MOVE "AdventureWorksDW2017" TO "/var/opt/mssql/data/AdventureWorksDW2017.mdf", MOVE "AdventureWorksDW2017_Log" TO "/var/opt/mssql/data/AdventureWorksDW2017.ldf"'
docker exec -it "$CONTAINER_NAME" /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '!Pass01234' -Q 'RESTORE DATABASE WideWorldImportersDW FROM DISK = "/tmp/WideWorldImportersDW-Full.bak" WITH MOVE "WWI_Primary" TO "/var/opt/mssql/data/WideWorldImportersDW.mdf", MOVE "WWI_UserData" TO "/var/opt/mssql/data/WideWorldImportersDW_userdata.ndf", MOVE "WWI_Log" TO "/var/opt/mssql/data/WideWorldImportersDW.ldf", MOVE "WWIDW_InMemory_Data_1" TO "/var/opt/mssql/data/WideWorldImportersDW_InMemory_Data_1"'

docker commit "$CONTAINER_NAME" "$CONTAINER_NAME"
docker kill "$CONTAINER_NAME"

echo run container with \'docker run -itd -p 1433:1433 $CONTAINER_NAME\'
