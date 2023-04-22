DELETE FROM [Core].[SlicedImportObject] WHERE [SourceSystemName] = 'AdventureWorksLT';



INSERT INTO [Core].[SlicedImportObject]
           ([SlicedImportObject_Id]
		   ,[SourceSystemName]
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
           ('37C8B38B-B913-4593-B1F2-68EDCB5DC60F'
		   ,'AdventureWorksLT'
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
           ([SlicedImportObject_Id]
		   ,[SourceSystemName]
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
           ('2A1ACA0A-F6F4-4E66-8210-BDA581CD28B8'
		   ,'AdventureWorksLT'
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
EXEC [Core].[SetSlicedImportObjectStart] '37C8B38B-B913-4593-B1F2-68EDCB5DC60F'
EXEC [Core].[GetSetSlicedImportObjectToLoad] 'AdventureWorksLT'
EXEC [Core].[SetSlicedImportObjectEnd] '37C8B38B-B913-4593-B1F2-68EDCB5DC60F', 33

SELECT * FROM [Core].[SlicedImportObject]


EXEC [Core].[SetSlicedImportObjectStart] '2A1ACA0A-F6F4-4E66-8210-BDA581CD28B8'

EXEC [Core].[ResetSlicedImportObject] '', '2A1ACA0A-F6F4-4E66-8210-BDA581CD28B8'

EXEC [Core].[ResetSlicedImportObject] 'AdventureWorksLT', '2A1ACA0A-F6F4-4E66-8210-BDA581CD28B8'

EXEC [Core].[ResetSlicedImportObject] 'AdventureWorksLT'
