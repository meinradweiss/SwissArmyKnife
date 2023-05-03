﻿

CREATE PROCEDURE [Core].[GetSetSlicedImportObjectToLoad]
(   
    @SourceSystemName sysname
   ,@SourceSchema     sysname        ='%'
   ,@SourceObject     sysname        ='%'
   ,@SlicedImportObject_Id varchar(64) = '%'
   ,@Mode             VARCHAR(25) = 'REGULAR'
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
    AND ((@Mode = 'REGULAR'  AND	[LastStart] IS NULL)
     OR (@Mode = 'RESTART'  AND	[LastStart] IS NOT NULL AND [LastSuccessEnd] IS NULL)
     OR (@Mode = 'ALL'))
    AND [SourceSchema] LIKE @SourceSchema
    AND [SourceObject] LIKE @SourceObject 
    AND CONVERT(VARCHAR(64), [SlicedImportObject_Id]) = @SlicedImportObject_Id 


END