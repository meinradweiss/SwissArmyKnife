﻿

CREATE VIEW [Mart].[SlicedImportObject]
AS

WITH SourcePlusDuration
AS
(
  SELECT 
       [SlicedImportObject_Id]
      ,[SourceSystemName]
      ,[SourceSchema]
      ,[SourceObject]
      ,[GetDataCommand]
      ,[FilterDataCommand]
      ,[DestinationSchema]
      ,[DestinationObject]
      ,[ContainerName]
      ,[DestinationPath]
      ,[DestinationFileName]
      ,[DestinationFileFormat]
      ,[MaxRowsPerFile]
      ,[AdditionalContext]
      ,[IngestionMappingName]
      ,[LastStart]
      ,[LastSuccessEnd]
      ,DATEDIFF(SECOND, [LastStart], COALESCE([LastSuccessEnd], GETUTCDATE())) AS [DurationInSecond]
      ,[RowsTransferred]
      ,[LastErrorMessage]
      ,[CreatedBy]
      ,[CreatedAt]
  FROM [Core].[SlicedImportObject]
) 
   SELECT
       [SlicedImportObject_Id]
      ,[SourceSystemName]
      ,[SourceSchema]
      ,[SourceObject]
      ,[GetDataCommand]
      ,[FilterDataCommand]
      ,[DestinationSchema]
      ,[DestinationObject]
      ,[ContainerName]
      ,[DestinationPath]
      ,[DestinationFileName]
      ,[DestinationFileFormat]
      ,[MaxRowsPerFile]
      ,[AdditionalContext]
      ,[IngestionMappingName]
      ,[LastStart]
      ,[LastSuccessEnd]
      ,[DurationInSecond]
      ,[RowsTransferred]
      ,[LastErrorMessage]
      ,CASE WHEN [LastStart] IS     NULL                                  THEN 'Ready to load'
	        WHEN [LastStart] IS NOT NULL AND [LastSuccessEnd] IS     NULL THEN 'Loading'
	        WHEN [LastStart] IS NOT NULL AND [LastSuccessEnd] IS NOT NULL THEN 'Successfully load'
       END  AS [LoadStatus]
      ,[CreatedBy]
      ,[CreatedAt]

  FROM SourcePlusDuration