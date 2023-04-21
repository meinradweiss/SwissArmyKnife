IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Core')
BEGIN
    EXEC sp_executesql @statement = 'CREATE SCHEMA Core;'
END;


DROP TABLE IF EXISTS [Core].[SlicedImportObject];


CREATE TABLE [Core].[SlicedImportObject](
	[SlicedImportObject_Id] [uniqueidentifier] NOT NULL,
	[SourceSchema] [sysname] NOT NULL,
	[SourceObject] [sysname] NOT NULL,
	[GetDataCommand] [nvarchar](max) NULL,
	[FilterDataCommand] [nvarchar](1024) NULL,
	[DestinationSchema] [sysname] NOT NULL,
	[DestinationObject] [sysname] NOT NULL,
	[DestinationPath] [sysname] NOT NULL,
	[DestinationFileName] [sysname] NOT NULL,
	[DestinationPostfix] [sysname] NULL,
	[DestinationFileFormat] [varchar](10) NOT NULL,
    [CreationTimeHint] [varchar](255) NOT NULL,       -- For ADX
	[LastStart] [datetime] NULL,
	[LastSuccessEnd] [datetime] NULL,
    [RowsTransferred] [int] NULL,
	[LastErrorMessage] [nvarchar](max) NULL,
	[CreatedBy] [sysname] NOT NULL,
	[CreatedAt] [datetime] NOT NULL
) 
GO
ALTER TABLE [Core].[SlicedImportObject] ADD  CONSTRAINT [Core_SlicedImportObject_pk] PRIMARY KEY CLUSTERED 
(
	[SlicedImportObject_Id] ASC
)
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [Core].[SlicedImportObject] ADD  CONSTRAINT [Core_SlicedImportObject_uk_Destination] UNIQUE NONCLUSTERED 
(
    [SourceSchema]
   ,[SourceObject]
  ,[FilterDataCommand]
)
GO
ALTER TABLE [Core].[SlicedImportObject] ADD  CONSTRAINT [Core_SlicedImportObject_id_df]  DEFAULT (newid()) FOR [SlicedImportObject_Id]
GO
ALTER TABLE [Core].[SlicedImportObject] ADD  DEFAULT ('.parquet') FOR [DestinationFileFormat]
GO
ALTER TABLE [Core].[SlicedImportObject] ADD  CONSTRAINT [Core_SlicedImportObject_createdby_df]  DEFAULT (suser_sname()) FOR [CreatedBy]
GO
ALTER TABLE [Core].[SlicedImportObject] ADD  CONSTRAINT [Core_SlicedImportObject_createdat_df]  DEFAULT (getdate()) FOR [CreatedAt]
GO

DROP PROCEDURE [Core].[SetSlicedImportObjectStart];
GO

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
	    ,[SourceSchema] 
	    ,[SourceObject] 
	    ,[GetDataCommand] 
	    ,[FilterDataCommand]
        ,CONCAT([GetDataCommand], ' ', [FilterDataCommand]) AS [SelectCommand]
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
GO


DROP PROCEDURE [Core].[SetSlicedImportObjectEnd];
GO

CREATE PROCEDURE [Core].[SetSlicedImportObjectEnd]
     @SlicedImportObject_Id uniqueidentifier
    ,@RowsTransferred int
AS
BEGIN
    -- Update LastStart to the current time
    UPDATE [Core].[SlicedImportObject]
    SET [LastSuccessEnd]   = GETUTCDATE()
       ,[RowsTransferred]  = @RowsTransferred
    WHERE [SlicedImportObject_Id] = @SlicedImportObject_Id;

    -- Select all attributes for the given SlicedImportObject_Id
    SELECT 'DONE' [ForPipeline];
END;

GO
DROP PROCEDURE [Core].[GetSetSlicedImportObject];
GO

CREATE PROCEDURE [Core].[GetSetSlicedImportObject]
(    @SourceSchema sysname
    ,@SourceObject sysname
)
AS
BEGIN
  SELECT
	[SlicedImportObject_Id]
  FROM  [Core].[SlicedImportObject]
  WHERE [SourceSchema] = @SourceSchema
    AND	[SourceObject] = @SourceObject
END

GO
