﻿CREATE TABLE [Core].[SlicedImportObject] (
    [SlicedImportObject_Id] UNIQUEIDENTIFIER CONSTRAINT [Core_SlicedImportObject_id_df] DEFAULT (newid()) NOT NULL,
    [SourceSystemName]      [sysname]        NOT NULL,
    [SourceSchema]          [sysname]        NOT NULL,
    [SourceObject]          [sysname]        NOT NULL,
    [GetDataCommand]        NVARCHAR (MAX)   NULL,
    [FilterDataCommand]     NVARCHAR (1024)  NULL,
    [DestinationSchema]     [sysname]        NOT NULL,
    [DestinationObject]     [sysname]        NOT NULL,
    [ContainerName]         [sysname]        NULL,
    [DestinationPath]       [sysname]        NULL,
    [DestinationFileName]   [sysname]        NULL,
    [DestinationPostfix]    [sysname]        NULL,
    [DestinationFileFormat] VARCHAR (10)     DEFAULT ('.parquet') NOT NULL,
    [MaxRowsPerFile]                     INT              NULL,
    [AdditionalContext]      VARCHAR (255)    NULL, -- e.g. for ADX '{"creationTime": "2022.01.01"}'
    [LastStart]             DATETIME         NULL,
    [LastSuccessEnd]        DATETIME         NULL,
    [RowsTransferred]       INT              NULL,
    [LastErrorMessage]      NVARCHAR (MAX)   NULL,
    [CreatedBy]             [sysname]        CONSTRAINT [Core_SlicedImportObject_createdby_df] DEFAULT (suser_sname()) NOT NULL,
    [CreatedAt]             DATETIME         CONSTRAINT [Core_SlicedImportObject_createdat_df] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [Core_SlicedImportObject_pk] PRIMARY KEY CLUSTERED ([SlicedImportObject_Id] ASC),
    CONSTRAINT [Core_SlicedImportObject_uk_Destination] UNIQUE NONCLUSTERED ([SourceSchema] ASC, [SourceObject] ASC, [FilterDataCommand] ASC)
);

