﻿

CREATE VIEW [Mart].[SlicedImportObject]
AS

WITH SourcePlusDuration
AS
(
  SELECT [SlicedImportObject_Id]
        ,[SourceSystemName]     
        ,[SourceSchema]         
        ,[SourceObject]         
        ,[GetDataCommand]       
        ,[FilterDataCommand]    
        ,[GetDataADXCommand]    
        ,[FilterDataADXCommand] 
        ,[DestinationSchema]    
        ,[DestinationObject]    
        ,[ContainerName]        
        ,[DestinationPath]      
        ,[DestinationFileName]  
        ,[DestinationFileFormat]
        ,[MaxRowsPerFile]       
        ,[AdditionalContext]    
        ,[IngestionMappingName] 
        ,[Active]               
        ,[PipelineRunId]        
        ,[ExtentFingerprint]    
        ,[LastStart]            
        ,[LastSuccessEnd]       
        ,[LastErrorEnd]
        ,DATEDIFF(SECOND, [LastStart], COALESCE([LastSuccessEnd], [LastErrorEnd], GETUTCDATE())) AS [DurationInSecond]
        ,[RowsTransferred]      
        ,[LastErrorMessage]     
        ,[CreatedBy]            
        ,[ValidFrom]
        ,[ValidTo]  
  FROM [Core].[SlicedImportObject]
) 
   SELECT
         [SlicedImportObject_Id]
        ,[SourceSystemName]     
        ,[SourceSchema]         
        ,[SourceObject]         
        ,[GetDataCommand]       
        ,[FilterDataCommand]    
        ,[GetDataADXCommand]    
        ,[FilterDataADXCommand] 
        ,[DestinationSchema]    
        ,[DestinationObject]    
        ,[ContainerName]        
        ,[DestinationPath]      
        ,[DestinationFileName]  
        ,[DestinationFileFormat]
        ,[MaxRowsPerFile]       
        ,[AdditionalContext]    
        ,[IngestionMappingName] 
        ,[Active]               
        ,[PipelineRunId]        
        ,[ExtentFingerprint]    
        ,[LastStart]            
        ,[LastSuccessEnd]       
        ,[LastErrorEnd]
        ,[DurationInSecond]
        ,[RowsTransferred]      
        ,[LastErrorMessage]
      ,CASE WHEN [LastStart] IS     NULL                                                                     THEN 'Ready to load'
	        WHEN [LastStart] IS NOT NULL AND [LastSuccessEnd] IS     NULL AND [LastErrorMessage] IS     NULL THEN 'Loading'
	        WHEN [LastStart] IS NOT NULL AND [LastSuccessEnd] IS     NULL AND [LastErrorMessage] IS NOT NULL THEN 'Stopped with Error'
	        WHEN [LastStart] IS NOT NULL AND [LastSuccessEnd] IS NOT NULL                                    THEN 'Successfully load'
       END  AS [LoadStatus]
      ,[CreatedBy]
      ,[ValidFrom]
      ,[ValidTo]  
  FROM SourcePlusDuration