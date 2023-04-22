DELETE FROM [Core].[SlicedImportObject] WHERE [SourceSystemName] = 'AdventureWorksLT';

INSERT INTO [Core].[SlicedImportObject]
           ([SourceSystemName]
           ,[SourceSchema]
           ,[SourceObject]
           ,[GetDataCommand]
           ,[FilterDataCommand]
           ,[DestinationSchema]
           ,[DestinationObject]
           ,[DestinationPath]
           ,[DestinationFileName]
           )
     VALUES
           ('AdventureWorksLT'
           ,'SalesLT'
           ,'SalesOrderHeader'
           ,'SELECT [SalesOrderID], [RevisionNumber], [OrderDate], [Status] FROM [SalesLT].[SalesOrderHeader]'
           ,'WHERE [SalesOrderID] < 71815'
           ,'AdventureWorksLT_SalesLT'
           ,'SalesOrderHeader'
           ,'AdventureWorksLT_SalesLT/SalesOrderID_lt71815'
           ,'SalesOrderHeader_lt71815'
           );


INSERT INTO [Core].[SlicedImportObject]
           ([SourceSystemName]
           ,[SourceSchema]
           ,[SourceObject]
           ,[GetDataCommand]
           ,[FilterDataCommand]
           ,[DestinationSchema]
           ,[DestinationObject]
           ,[DestinationPath]
           ,[DestinationFileName]
           )
     VALUES
           ('AdventureWorksLT'
           ,'SalesLT'
           ,'SalesOrderHeader'
           ,'SELECT [SalesOrderID], [RevisionNumber], [OrderDate], [Status] FROM [SalesLT].[SalesOrderHeader]'
           ,'WHERE [SalesOrderID] >= 71815'
           ,'AdventureWorksLT_SalesLT'
           ,'SalesOrderHeader'
           ,'AdventureWorksLT_SalesLT/SalesOrderID_ge71815'
           ,'SalesOrderHeader_ge71815'
           )
GO


EXEC [Core].[GetSetSlicedImportObjectToLoad] 'AdventureWorksLT'
EXEC [Core].[SetSlicedImportObjectStart] '31E8E33A-CEFA-4934-B38F-645761C692CF'
EXEC [Core].[GetSetSlicedImportObjectToLoad] 'AdventureWorksLT'
EXEC [Core].[SetSlicedImportObjectEnd] '31E8E33A-CEFA-4934-B38F-645761C692CF', 33

SELECT * FROM [Core].[SlicedImportObject]

