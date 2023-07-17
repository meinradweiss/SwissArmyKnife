CREATE TABLE [Core].[SlicedImportObject] (
    [SlicedImportObject_Id] UNIQUEIDENTIFIER CONSTRAINT [Core_SlicedImportObject_id_df] DEFAULT (newsequentialid()) NOT NULL,
    [SourceSystemName]      [sysname]        NOT NULL,
    [SourceSchema]          [sysname]        NULL,
    [SourceObject]          [sysname]        NULL,
    [GetDataCommand]        NVARCHAR (MAX)   NULL,
    [FilterDataCommand]     NVARCHAR (1024)  NULL,
    [GetDataADXCommand]     NVARCHAR (MAX)   NULL,
    [FilterDataADXCommand]  VARCHAR  (10)    NULL,
    [DestinationSchema]     [sysname]        NULL,
    [DestinationObject]     [sysname]        NULL,
    [ContainerName]         [sysname]        NULL,
    [DestinationPath]       [sysname]        NULL,
    [DestinationFileName]   [sysname]        NULL,
    [DestinationFileFormat] VARCHAR (10)     DEFAULT ('.parquet') NOT NULL,
    [MaxRowsPerFile]        INT              NULL,
    [AdditionalContext]     VARCHAR (255)    NULL, -- e.g. for ADX '{"creationTime": "2022.01.01"}'
    [IngestionMappingName]  [sysname]        NULL,
    [Active]                BIT              DEFAULT ((1)) NOT NULL,
    [PipelineRunId]         VARCHAR(128)     NULL,
    [ExtentFingerprint]     VARCHAR(128)     NULL,
    [LastStart]             DATETIME         NULL,
    [LastSuccessEnd]        DATETIME         NULL,
    [LastErrorEnd]          DATETIME         NULL,
    [RowsTransferred]       INT              NULL,
    [LastErrorMessage]      NVARCHAR (MAX)   NULL,
    [CreatedBy]             [sysname]        CONSTRAINT [Core_SlicedImportObject_createdby_df] DEFAULT (suser_sname()) NOT NULL,
    [ValidFrom]             DATETIME2        GENERATED ALWAYS AS ROW START NOT NULL,
    [ValidTo]               DATETIME2        GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    CONSTRAINT [Core_SlicedImportObject_pk] PRIMARY KEY CLUSTERED ([SlicedImportObject_Id] ASC), 
    CONSTRAINT [CK_SlicedImportObject_ValidSourceSpecification] CHECK ( (([SourceSchema]      IS NOT NULL) AND ([SourceObject] IS NOT NULL))
	                                                                OR   ([GetDataCommand]    IS NOT NULL)
	                                                                OR   ([GetDataADXCommand] IS NOT NULL)),
)WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Core].[SlicedImportObjectHistory])
);

