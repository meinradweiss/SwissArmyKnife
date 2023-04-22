
CREATE PROCEDURE [Core].[GetSetSlicedImportObjectToLoad]
(   
    @SourceSystemName sysname
)
AS
BEGIN
  SELECT
	 [SlicedImportObject_Id]
    ,[SourceSystemName] 
	,[SourceSchema] 
	,[SourceObject] 
  FROM  [Core].[SlicedImportObject]
  WHERE [SourceSystemName] = @SourceSystemName
    AND	[LastStart] IS NULL


END