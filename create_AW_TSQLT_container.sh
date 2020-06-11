#!/bin/sh -e

CONTAINER_NAME="aw_tsqlt_container"


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
docker exec -it "$CONTAINER_NAME" /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '!Pass01234' -Q 'RESTORE DATABASE WideWorldImporters FROM DISK = "/tmp/WideWorldImporters-Full.bak" WITH MOVE "WWI_Primary" TO "/var/opt/mssql/data/WideWorldImporters.mdf", MOVE "WWI_UserData" TO "/var/opt/mssql/data/WideWorldImporters_userdata.ndf", MOVE "WWI_Log" TO "/var/opt/mssql/data/WideWorldImporters.ldf", MOVE "WWI_InMemory_Data_1" TO "/var/opt/mssql/data/WideWorldImporters_InMemory_Data_1"'
docker cp ./tSQLt.sql "$CONTAINER_NAME":/tmp/.
docker exec -it "$CONTAINER_NAME" /opt/mssql-tools/bin/sqlcmd -i /tmp/tSQLt.sql -S localhost -U SA -P '!Pass01234' -d WideWorldImporters

docker commit "$CONTAINER_NAME" "$CONTAINER_NAME":created
docker kill "$CONTAINER_NAME"
