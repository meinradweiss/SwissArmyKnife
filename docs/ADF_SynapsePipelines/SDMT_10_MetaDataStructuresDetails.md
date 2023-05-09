
# SDMT - Sliced data migration toolbox


### Meta data database objects

The following database objects and corresponding Data Factory/Synapse pipeline artifacts help to load datasets in slices. 
</br>
The core of the solutions build a small metadata/control table. A few Views/Store Procedures and Data Factory/Sypanpse pipelines are then used to transfer data and log the activity in the metadata table.
</br>
</br>
## Meatadata/Control Database Table

</br>


| Attribute Name          | Data Type         | Null    | Default                      | Description                                              |
|-------------------------|-------------------|---------|------------------------------|----------------------------------------------------------|
| SlicedImportObject_Id   | UNIQUEIDENTIFIER  | NOT NULL| newsequentialid()            | Unique identifier for the sliced import object.           |
| SourceSystemName        | sysname           | NOT NULL|                              | Name of the source system. Used to group slices          |
| SourceSchema            | sysname           | NOT NULL|                              | Schema of the source object.                             |
| SourceObject            | sysname           | NOT NULL|                              | Name of the source object.                               |
| GetDataCommand          | NVARCHAR(MAX)     | NULL    |                              | Select statement to read data from the source system. The attribute that can be used to slice the table must be included in the select list. </br> A select * from table/view is valid, if all attributes should be transferred.                 |
| FilterDataCommand       | NVARCHAR(1024)    | NULL    |                              | Command to filter the retrieved data. It must start with the WHERE keyword. </br> The [FilterDataCommand] will be concatenated with the [GetDataCommand] to fetch data.                   |
| DestinationSchema       | sysname           | NOT NULL|                              | Schema of the destination object.                        |
| DestinationObject       | sysname           | NOT NULL|                              | Name of the destination object.                          |
| ContainerName           | sysname           | NULL    |                              | Name of the container for storage.                       |
| DestinationPath         | sysname           | NULL    |                              | Path to the destination location. e.g. raw/AdventureWorks/Sales/Product/202201.                        |
| DestinationFileName     | sysname           | NULL    |                              | Name of the destination file (without extension) .       |
| DestinationFileFormat   | VARCHAR(10)       | NOT NULL| '.parquet'                   | File format of the destination file.                     |
| MaxRowsPerFile          | INT               | NULL    |                              | Maximum number of rows per file.                         |
| AdditionalContext       | VARCHAR(255)      | NULL    |                              | Additional context information. e.g. for ADX '{"creationTime": "2022.01.01"}'. |
| IngestionMappingName    | sysname           | NULL    |                              | Name of the (ADX) ingestion mapping.                           |
| Active                  | BIT               | NOT NULL| 1                            | Flag indicating whether the object is active or not.     |
| LastStart               | DATETIME          | NULL    |                              | Timestamp of the last start.                             |
| LastSuccessEnd          | DATETIME          | NULL    |                              | Timestamp of the last successful end.                    |
| RowsTransferred         | INT               | NULL    |                              | Number of rows transferred.                              |
| LastErrorMessage        | NVARCHAR(MAX)     | NULL    |                              | Last error message encountered.                          |
| CreatedBy               | sysname           | NOT NULL| suser_sname()                | Name of the user who created the object.                 |
| CreatedAt               | DATETIME          | NOT NULL| getutcdate()                 | Timestamp of when the object was created.                |



### Sample data for a data transfer from a relational database, via data lake to another relational database
</br>


|SlicedImportObject_Id|SourceSystemName|SourceSchema|SourceObject|GetDataCommand|FilterDataCommand|DestinationSchema|DestinationObject|ContainerName|DestinationPath|DestinationFileName|MaxRowsPerFile|AdditionalContext|Active|LastStart|LastSuccessEnd|RowsTransferred|LastErrorMessage|CreatedBy|CreatedAt|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|942dc3dd-c3e9-ed11-8e89-000d3a22bf79|AdventureWorksLT|SalesLT|Product|SELECT [ProductID], [Name], [ProductNumber], [Color], [SellStartDate] FROM [SalesLT].[Product]|WHERE [SellStartDate] &gt;= CONVERT(DATETIME, &#39;2002-06-01&#39;,120) AND [SellStartDate]  &lt; CONVERT(DATETIME, &#39;2002-07-01&#39;,120)|SalesLT_SDMT|Product|adftopowerbi|AdventureWorksLT/SalesLT/Product/2002/06/01|AdventureWorksLT_SalesLT_Product_20020601_20020630|NULL|{&quot;creationTime&quot;: &quot;2002-06-01&quot;,&quot;tags&quot;:[&quot;Source:PipelineLoad&quot;]}|1|2023-05-03 15:05:29.650|NULL|NULL|NULL|xxx.yyy@microsoft.com|2023-05-03 15:04:57.670|
|952dc3dd-c3e9-ed11-8e89-000d3a22bf79|AdventureWorksLT|SalesLT|Product|SELECT [ProductID], [Name], [ProductNumber], [Color], [SellStartDate] FROM [SalesLT].[Product]|WHERE [SellStartDate] &gt;= CONVERT(DATETIME, &#39;2002-07-01&#39;,120) AND [SellStartDate]  &lt; CONVERT(DATETIME, &#39;2002-08-01&#39;,120)|SalesLT_SDMT|Product|adftopowerbi|AdventureWorksLT/SalesLT/Product/2002/07/01|AdventureWorksLT_SalesLT_Product_20020701_20020731|NULL|{&quot;creationTime&quot;: &quot;2002-07-01&quot;,&quot;tags&quot;:[&quot;Source:PipelineLoad&quot;]}|1|2023-05-03 15:05:30.723|2023-05-03 15:06:05.353|0|NULL|xxx.yyy@microsoft.com|2023-05-03 15:04:57.677|



### Sample data for a data transfer from a relational database to an Azure Data Explorer
</br>

SlicedImportObject_Id | SourceSystemName      | SourceSchema | SourceObject   | GetDataCommand                                                                   | FilterDataCommand | DestinationSchema | DestinationObject | ContainerName | DestinationPath | DestinationFileName | DestinationPostfix | DestinationFileFormat | MaxRowsPerFile | AdditionalContext                | LastStart | LastSuccessEnd | RowsTransferred | LastErrorMessage | CreatedBy                  | CreatedAt
----------------------|----------------------|--------------|----------------|---------------------------------------------------------------------------------|-------------------|-------------------|-------------------|---------------|----------------|---------------------|--------------------|-----------------------|----------------|----------------------------------|-----------|----------------|----------------|------------------|----------------------------|-----------
37C8B38B-B913-4593-B1F2-68EDCB5DC600 | AdventureWorksLT_ADX | SalesLT      | SalesOrderHeader | "SELECT [SalesOrderID], [RevisionNumber], [OrderDate], [Status] FROM [SalesLT].[SalesOrderHeader]" | WHERE [SalesOrderID] < 71816 | na                | SalesOrderHeader  | na            | na             | na                  | NULL               | .parquet              | NULL           | {"creationTime": "2022.01.01"}    | NULL  | NULL        | NULL              | NULL             | XYZ@microsoft.com | 31:31.4
2A1ACA0A-F6F4-4E66-8210-BDA581CD28B7 | AdventureWorksLT_ADX | SalesLT      | SalesOrderHeader | "SELECT [SalesOrderID], [RevisionNumber], [OrderDate], [Status] FROM [SalesLT].[SalesOrderHeader]" | WHERE [SalesOrderID] >= 71816 | na                | SalesOrderHeader  | na            | na             | na                  | NULL               | .parquet              | NULL           | {"creationTime": "2023.01.01"}    | NULL  | NULL        | NULL             | NULL             | XYZ@microsoft.com | 31:31.5

</br>
The most important column from ADX perspective is `AdditionalContext` there you can specify the creationTime value (e.g.{"creationTime": "2023.01.01"}) that will be used for the extent in ADX.

</br>
</br>

## Stored Procedures


------

## [Core].[GetSetSlicedImportObjectToLoad]

This stored procedure retrieves a list of sliced import objects to load based on the specified source system name and mode.

**Parameters:**

| Name                       | Data Type   | Default Value | Purpose                                                                 |
|----------------------------|-------------|---------------|-------------------------------------------------------------------------|
| @SourceSystemName          | sysname     |               | The name of the source system. If only this value is provided, then all slices with this name will be retrieved.                                         |
| @SourceSchema              | sysname     | '%'           | The schema of the source object.                                        |
| @SourceObject              | sysname     | '%'           | The name of the source object.                                          |
| @SlicedImportObject_Id     | varchar(64) | '%'           | The ID of the sliced import object.                                     |
| @Mode                      | VARCHAR(25) | 'REGULAR'     | An optional parameter to specify the mode of operation. </br> If set to `REGULAR`, the procedure will only retrieve sliced import objects where the `LastStart` column is null. </br> If set to `RESTART`, it will only retrieve sliced import objects where the `LastStart` column is not null and the `LastSuccessEnd` column is null. </br> If set to `ALL`, it will retrieve all sliced import objects regardless of their status. |


</br>

## [Core].[ResetSlicedImportObject]

The stored procedure resets the values of `LastStart`, `LastSuccessEnd`, `LastErrorMessage`, and `RowsTransferred` columns of a row in the `[Core].[SlicedImportObject]` table. This procedure takes two optional parameters: `@SourceSystemName` and `@SlicedImportObject_Id`. If `@SourceSystemName` is provided, the procedure updates all rows with the matching source system name. If `@SlicedImportObject_Id` is provided, the procedure updates only the row with the matching SlicedImportObject_Id. If both parameters are provided, the procedure updates only the row with the matching SlicedImportObject_Id and source system name.

Table of Parameters:

| Parameter Name | Data Type         | Purpose                                                      |
|----------------|------------------|--------------------------------------------------------------|
| @SourceSystemName | sysname (optional) | Specifies the source system name to filter the rows to update. |
| @SlicedImportObject_Id | uniqueidentifier (optional) | Specifies the SlicedImportObject_Id of the row to update. If provided with @SourceSystemName, only the row with the matching SlicedImportObject_Id and source system name will be updated. If provided alone, only the row with the matching SlicedImportObject_Id will be updated. If not provided, all rows with the matching @SourceSystemName will be updated. |

</br>

## [Core].[SetSlicedImportObjectEnd]

This stored procedure updates the `LastSuccessEnd` and `RowsTransferred` columns of the sliced import objects table for the specified sliced import object ID.

| Parameter Name | Data Type | Purpose |
| -------------- | --------- | ------- |
| @SlicedImportObject_Id | uniqueidentifier | The ID of the sliced import object to update. |
| @RowsTransferred | int | The number of rows transferred for the sliced import object. |

</br>

## [Core].[SetSlicedImportObjectStart]

This stored procedure updates the `LastStart`, `LastSuccessEnd`, and `LastErrorMessage` columns of the sliced import objects table for the specified sliced import object ID.

| Parameter Name | Data Type | Purpose |
| -------------- | --------- | ------- |
| @SlicedImportObject_Id | uniqueidentifier | The ID of the sliced import object to update. |


</br>

## [Core].[SetSlicedImportObjectError]

The stored procedure "SetSlicedImportObjectError" updates the `LastSuccessEnd` and `LastErrorMessage` columns in the `Core.SlicedImportObject` table for a given `SlicedImportObject_Id`. 


Table of Parameters:

| Parameter Name | Data Type  | Purpose                                                    |
|----------------|------------|------------------------------------------------------------|
| SlicedImportObject_Id | uniqueidentifier | Identifier for the SlicedImportObject whose LastSuccessEnd and LastErrorMessage values need to be updated |
| Error | NVARCHAR(MAX) | Error message to be stored in the LastErrorMessage column for the SlicedImportObject_Id |






## [Core].[GetADXDropExtentsCommand]

This stored procedure returns a command that can be executed to drop extents for a specified source system name and mode. The command includes the destination object name and creation time for each slice.

| Parameter | Data Type | Purpose |
|-----------|-----------|---------|
| @SourceSystemName | sysname | Specifies the name of the source system for which to generate the drop extents command. |
| @Mode | VARCHAR(25) | Specifies the mode for which to generate the drop extents command. Valid values are 'StartedSlices' and 'AllSlices'. </br>If 'StartedSlices' is specified, only slices that have been started but not successfully ended will be included in the command. </br>If 'AllSlices' is specified, all slices will be included in the command. |


The stored procedure returns a result set with a single column named 'DropExtends'. The column contains concatenated strings that represent ADX commands to drop extents for the specified source system name and mode.
</br> The command can be exectuted in the ADX cluster to drop data extents. It is useful if the data load of some slices not 100% succeeded and if the slice should be reloaded.


<pre>
.execute database script <| 
.drop extents <| .show table SalesOrderHeader extents  |  where MinCreatedOn ==  '2023-01-01'
.drop extents <| .show table SalesOrderHeader extents  |  where MinCreatedOn ==  '2022-01-01'
</pre>


</br>
</br>
</br>


## [Helper].[GenerateSliceMetaData]

This stored procedure generates slice metadata based on the provided parameters. It creates slices of the source object based on the specified resolution (day or month) within the given date range. The generated metadata includes information such as source system name, source schema, source object, data commands, filter commands, destination schema, destination object, container name, destination path, destination file name, maximum rows per file, additional context, and ingestion mapping name.

### Parameters

| Name                      | Data Type     | Default Value | Purpose                                                                                      |
|---------------------------|---------------|---------------|----------------------------------------------------------------------------------------------|
| @LowWaterMark             | DATE          | '2022.01.01'  | The lower bound of the date range (inclusive).                                                |
| @HigWaterMark             | DATE          | '2022.03.01'  | The upper bound of the date range (exclusive).                                                |
| @Resolution               | VARCHAR(25)   | 'day'         | The resolution of the slices to be generated (either 'day' or 'month').                       |
| @SourceSystemName         | sysname       |               | The name of the source system.                                                               |
| @SourceSchema             | sysname       |               | The name of the source schema.                                                               |
| @SourceObject             | sysname       |               | The name of the source object.                                                               |
| @GetDataCommand           | nvarchar(max) |               | The command used to retrieve data from the source object.                                     |
| @DateFilterAttributeName  | sysname       |               | The name of the attribute used as a date filter in the filter command.                        |
| @DateFilterAttributeType  | sysname       |               | The data type of the date filter attribute.                                                   |
| @DestinationSchema        | sysname       | 'n/a'         | The name of the destination schema. If 'n/a', it indicates no specific destination schema.    |
| @DestinationObject        | sysname       |               | The name of the destination object.                                                          |
| @ContainerName            | sysname       |               | The name of the container where the slices will be stored.                                    |
| @AlternativeRootFolder    | sysname       | NULL          | If provided, this value is used instead of the @SourceSystemName to create the directory path. |
| @MaxRowsPerFile           | int           | NULL          | The maximum number of rows per file. If NULL, there is no limit.                              |
| @IngestionMappingName     | sysname       | NULL          | The name of the ingestion mapping to be used. If NULL, no specific mapping is specified.      |


</br>
</br>
