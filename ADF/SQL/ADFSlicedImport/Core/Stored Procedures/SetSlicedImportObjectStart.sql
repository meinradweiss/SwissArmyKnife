
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
		,CONCAT('TRUNCATE TABLE ', QUOTENAME([DestinationSchema]), '.',QUOTENAME([DestinationObject])) AS [TruncateDestinationTableCommand]
	    ,[DestinationSchema] 
	    ,[DestinationObject] 
	    ,[DestinationPath] 
	    ,[DestinationFileName] 
	    ,[DestinationPostfix] 
	    ,[DestinationFileFormat] 
	    ,[LastStart] 
    FROM [Core].[SlicedImportObject]
    WHERE [SlicedImportObject_Id] = @SlicedImportObject_Id;
END;