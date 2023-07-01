﻿CREATE PROCEDURE [Core].[SetSlicedImportObjectStart]
    @SlicedImportObject_Id UNIQUEIDENTIFIER
   ,@PipelineRunId         VARCHAR(128) = NULL
AS
BEGIN
    -- Update LastStart to the current time
    UPDATE [Core].[SlicedImportObject]
    SET [LastStart]        = GETUTCDATE()
	   ,[PipelineRunId]    = @PipelineRunId
       ,[LastSuccessEnd]   = NULL
	   ,[LastErrorEnd]     = NULL
       ,[LastErrorMessage] = NULL
	   ,[RowsTransferred]  = NULL
    WHERE [SlicedImportObject_Id] = @SlicedImportObject_Id;

    -- Select all attributes for the given SlicedImportObject_Id
    SELECT 
	     [SlicedImportObject_Id]
        ,[SourceSystemName] 
	    ,[SourceSchema] 
	    ,[SourceObject] 
	    ,[GetDataCommand] 
	    ,[FilterDataCommand]
        ,CONCAT([GetDataCommand], ' ', [FilterDataCommand]) AS [SelectCommand]
		,CONCAT('.set-or-append ', [DestinationObject]
		         , ' with (', [AdditionalContext], ', tags=''['
				                                    , CONCAT('"LoadedAt:', CONVERT(VARCHAR,GETUTCDATE(),126),'"')  
													, CONCAT(',"SlicedImportObject_Id:', CONVERT(VARCHAR(64), @SlicedImportObject_Id),'"')
													, CONCAT(',"PipelineRun_Id:', CONVERT(VARCHAR(64), @PipelineRunId),'"')
													, CONCAT(',"ExtentFingerprint:', [ExtentFingerprint],'"')
													, CONCAT(',"SourceFunction:', [GetDataCommand],'"')
													,  ']''', ')'   -- ["Source:PipelineLoad","Oid=xxx"]
		         ,' <| ', [GetDataCommand], '(', [FilterDataCommand],')' ) AS [ADXFetchCommand]
		,CONCAT('IF OBJECT_ID(''', QUOTENAME([DestinationSchema]), '.',QUOTENAME([DestinationObject]) ,''') IS NOT NULL DELETE FROM ', QUOTENAME([DestinationSchema]), '.',QUOTENAME([DestinationObject]), ' ', [FilterDataCommand]) AS [EmptyDestinationSliceCommand]
	    ,[DestinationSchema] 
	    ,[DestinationObject] 
		,[ContainerName]
	    ,[DestinationPath] 
	    ,[DestinationFileName] 
	    ,[DestinationFileFormat] 
		,CONCAT([DestinationFileName], [DestinationFileFormat]) AS [FullDestinationFileName]
		,[MaxRowsPerFile]
		,[ExtentFingerprint]
    	--   //Use in ADX
	    --   .show table <YourTable> extents
        --   | extend  Timestamp = todatetime(extract("LoadedAt='(.*)'", 1, Tags))

       	,CASE WHEN [TransferMode] = 'DatasetTransfer' 
		        THEN JSON_MODIFY(
		               JSON_MODIFY(
        	             JSON_MODIFY(
        		             JSON_MODIFY([AdditionalContext], 'append $.tags', CONCAT('LoadedAt:', CONVERT(VARCHAR,GETUTCDATE(),126),''))
        		                                             ,'append $.tags', CONCAT('SlicedImportObject_Id:', CONVERT(VARCHAR(64), @SlicedImportObject_Id),''))  
        		 						            	     ,'append $.tags', CONCAT('PipelineRun_Id:', CONVERT(VARCHAR(64), @PipelineRunId),''))
        										             ,'append $.tags', CONCAT('ExtentFingerprint:', [ExtentFingerprint],''))   
                ELSE 'N/A'
		 END												 AS [AdditionalContext]


		,CONCAT('.drop extents <| .show table ' , DestinationObject , ' extents where tags has ''' ,  CONCAT('ExtentFingerprint:', [ExtentFingerprint],'') ,'''' )          AS [ADX_DropExtentCommand]
		,CONCAT('.show table ' , DestinationObject , ' extents where tags has ''' ,  CONCAT('ExtentFingerprint:', [ExtentFingerprint],'') ,''' | summarize RowCount=sum(RowCount)' ) AS [ADX_CountRowsInExtentCommand]
		,[IngestionMappingName]
	    ,[LastStart] 
    FROM [Core].[SlicedImportObject]
    WHERE [SlicedImportObject_Id] = @SlicedImportObject_Id;
	
END;
