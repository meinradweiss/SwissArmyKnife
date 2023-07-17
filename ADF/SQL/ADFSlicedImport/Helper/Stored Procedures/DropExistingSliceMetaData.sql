
CREATE PROCEDURE [Helper].[DropExistingSliceMetaData] (
            @SourceSystemName        sysname
		   ,@SourceSchema            sysname   = NULL
		   ,@SourceObject            sysname   = NULL
		   ,@GetDataCommand          nvarchar (max) = NULL
           ,@GetDataADXCommand       nvarchar (max) = NULL
		   ,@IncludeHistoryData      bit            = 0)
AS		  
BEGIN

  SET NOCOUNT ON

  BEGIN TRANSACTION

		

        DELETE FROM [Core].[SlicedImportObject]
		WHERE [SourceSystemName]             like          @SourceSystemName 
          AND CONCAT([SourceSchema],'')      like COALESCE(@SourceSchema, '%')     
          AND CONCAT([SourceObject],'')      like COALESCE(@SourceObject, '%')         
          AND CONCAT([GetDataCommand],'')    like COALESCE(@GetDataCommand, '%')         
          AND CONCAT([GetDataADXCommand],'') like COALESCE(@GetDataADXCommand, '%')       ;


		IF @IncludeHistoryData = 1
		BEGIN
          ALTER TABLE [Core].[SlicedImportObject] SET ( SYSTEM_VERSIONING = OFF );

		  DECLARE @SQL_Command NVARCHAR(MAX)
		         ,@Params      NVARCHAR(MAX) = '@SourceSystemName sysname, @SourceSchema sysname, @SourceObject sysname, @GetDataCommand nvarchar (max), @GetDataADXCommand nvarchar (max)'


		  SET @SQL_Command = 'DELETE FROM [Core].[SlicedImportObjectHistory]
                              WHERE [SourceSystemName]               like COALESCE(@SourceSystemName,  ''%'')  
                                AND CONCAT([SourceSchema],'''')      like COALESCE(@SourceSchema,      ''%'')     
                                AND CONCAT([SourceObject],'''')      like COALESCE(@SourceObject,      ''%'')         
                                AND CONCAT([GetDataCommand],'''')    like COALESCE(@GetDataCommand,    ''%'')         
                                AND CONCAT([GetDataADXCommand],'''') like COALESCE(@GetDataADXCommand, ''%'')'

          EXEC SP_EXECUTESQL @SQL_Command, @Params, @SourceSystemName=@SourceSystemName, @SourceSchema=@SourceSchema,  @SourceObject= @SourceObject, @GetDataCommand=@GetDataCommand,  @GetDataADXCommand= @GetDataADXCommand

          ALTER TABLE [Core].[SlicedImportObject] SET ( SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Core].[SlicedImportObjectHistory]));
		END


  COMMIT TRANSACTION

END