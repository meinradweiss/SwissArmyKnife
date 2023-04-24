
CREATE PROCEDURE [Core].[SetSlicedImportObjectStart]
    @SlicedImportObject_Id uniqueidentifier
AS
BEGIN
    -- Update LastStart to the current time
    UPDATE [Core].[SlicedImportObject]
    SET [LastStart] = GETUTCDATE()
       ,[LastSuccessEnd] = NULL
       ,[LastErrorMessage] = NULL
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
		,CONCAT('IF OBJECT_ID(''', QUOTENAME([DestinationSchema]), '.',QUOTENAME([DestinationObject]) ,''') IS NOT NULL DELETE FROM ', QUOTENAME([DestinationSchema]), '.',QUOTENAME([DestinationObject]), ' ', [FilterDataCommand]) AS [EmptyDestinationSliceCommand]
	    ,[DestinationSchema] 
	    ,[DestinationObject] 
		,[ContainerName]
	    ,[DestinationPath] 
	    ,[DestinationFileName] 
	    ,[DestinationPostfix] 
	    ,[DestinationFileFormat] 
		,CONCAT([DestinationFileName], [DestinationFileFormat]) AS [FullDestinationFileName]
		,[MaxRowsPerFile]
	    ,[LastStart] 
    FROM [Core].[SlicedImportObject]
    WHERE [SlicedImportObject_Id] = @SlicedImportObject_Id;
END;