# ADF Synspase Pipeline Overview

If data is migrated from an on-premises system to a modern data warehouse, then very often there is the need to load historical data to the new data structures in Azure. </br>
Target can be the data lake, data lake + database (e.g. SQL or ADX). Because of the fact that historical data can be huge it's not recommended to load all data in one job/one transaction. 
</br>
</br>
The following database objects and corresponding Data Factory/Synapse pipeline artifacts help to load datasets in slices. The slice size can be defined by the consumer and it is possible to re-run slices if the transfer is not successful.
</br>
</br>
## Database table

|Attribute name | Data type | Null | Default | Description |
| --- | --- | --- | --- | --- |
| [SlicedImportObject_Id]  |UNIQUEIDENTIFIER | NOT NULL | newid() | Primary key of the table. If it is not specified, then the system provides a value. |
| [SourceSystemName]      |  [sysname]        |  NOT NULL  |                      | String to identify objects that belong together | 
| [SourceSchema]          |  [sysname]        |  NOT NULL  |                      | Name of the schema in the source database. Used for documentation purpose. | 
| [SourceObject]          |  [sysname]        |  NOT NULL  |  | Name of the source table/view in the source system. Used for documentation purpose. | 
| [GetDataCommand]        |  NVARCHAR (MAX)   |  NULL      |                      |  select statement to read data from the source system. The attribute that can be used to slice the table must be included in the select list. A select * from table/view is valid, if all attributes should be transferred.               | 
| [FilterDataCommand]     |  NVARCHAR (1024)  |  NULL      |                      | Where condition to slice the data. It must start with the WHERE keyword. </br> The [FilterDataCommand] will be concatenated with the [GetDataCommand] to fetch data. | 
| [DestinationSchema]     |  [sysname]        |  NOT NULL  |                      | Schema name in the destination database.                 | 
| [DestinationObject]     |  [sysname]        |  NOT NULL  |                      | Table name in the destination database.                | 
| [ContainerName]         |  [sysname]        |  NULL      |                      | Container name in the datalake.                 | 
| [DestinationPath]       |  [sysname]        |  NULL      |                      | Directory path in the data lake e.g. raw/AdventureWorks/Sales/Product/202201                | 
| [DestinationFileName]   |  [sysname]        |  NULL      |                      | Filename (without extension)                | 
| [DestinationPostfix]    |  [sysname]        |  NULL      |                      |                 | 
| [DestinationFileFormat] |  VARCHAR (10)     |  NOT NULL  | ('.parquet')         |                 | 
| [MaxRowsPerFile]        |  INT              |  NULL      |                      | Maximal number of rows per File in data lake               | 
| [CreationTimeHint]      |  VARCHAR (255)    |  NULL      |                      |  -- for ADX     | 
| [LastStart]             |  DATETIME         |  NULL      |                      | Last start of transfer pipeline for this slice                | 
| [LastSuccessEnd]        |  DATETIME         |  NULL      |                      | Last succesful end to end data transfer of this slice                | 
| [RowsTransferred]       |  INT              |  NULL      |                      | Number of rows transferred | 
| [LastErrorMessage]      |  NVARCHAR (MAX)   |  NULL      |                      | Last known error                | 

</br>

### Sample data
</br>


| SlicedImportObject_Id | SourceSystemName | SourceSchema | SourceObject    | GetDataCommand                                                                                             | FilterDataCommand         | DestinationSchema             | DestinationObject | ContainerName    | DestinationPath                                                                         | DestinationFileName              | DestinationPostfix | DestinationFileFormat | MaxRowsPerFile | CreationTimeHint       | LastStart             | LastSuccessEnd        | RowsTransferred | LastErrorMessage | CreatedBy                      | CreatedAt               |
|-----------------------|------------------|--------------|----------------|------------------------------------------------------------------------------------------------------------|---------------------------|-------------------------------|-------------------|-----------------|-----------------------------------------------------------------------------------------|----------------------------------|--------------------|-----------------------|----------------|------------------------|-----------------------|-----------------------|----------------|------------------|--------------------------------|------------------------|
| 37C8B38B-B913-4593-B1F2-68EDCB5DC60F | AdventureWorksLT | SalesLT      | SalesOrderHeader | "SELECT [SalesOrderID], [RevisionNumber], [OrderDate], [Status] FROM [SalesLT].[SalesOrderHeader]" | WHERE [SalesOrderID] < 71815 | AdventureWorksLT_SalesLT_Sliced | SalesOrderHeader  | adf-to-powerbi  | raw/SlicedImport/AdventureWorksLT/SalesLT/SalesOrder/SalesOrderID_lt71815 | SalesOrderHeader_lt71815 | NULL               | .parquet              | 5              | NULL                   | NULL | NULL | NULL              | NULL             | XYZ@microsoft.com | 2023-04-24 13:02:44.487 |
| 2A1ACA0A-F6F4-4E66-8210-BDA581CD28B8 | AdventureWorksLT | SalesLT      | SalesOrderHeader | "SELECT [SalesOrderID], [RevisionNumber], [OrderDate], [Status] FROM [SalesLT].[SalesOrderHeader]" | WHERE [SalesOrderID] >= 71815 | AdventureWorksLT_SalesLT_Sliced | SalesOrderHeader  | adf-to-powerbi  | raw/SlicedImport/AdventureWorksLT/SalesLT/SalesOrder/SalesOrderID_ge71815 | SalesOrderHeader_ge71815 | NULL               | .parquet              | 5              | NULL                   | NULL | NULL | NULL             | NULL             | XYZ@microsoft.com | 2023-04-24 13:02:44.493 |



## Stored Procedures

| Name                        | Description |
|-----------------------------| ---|
| GetSetSlicedImportObjectToLoad | Get a list of slices that are not already loaded |
| ResetSlicedImportObject       | Reset a single slice or all slices for a specified SourceSystem |
| SetSlicedImportObjectEnd      | Mark a slice as successfully transferred |
| SetSlicedImportObjectStart    | Mark a slice as transfer started |

## Sample Pipeline

![Overview Picture](images/GetSlicedDataToSQL_singleFileOverview.png "Get Sliced Data To SQL_ single File Overview")

