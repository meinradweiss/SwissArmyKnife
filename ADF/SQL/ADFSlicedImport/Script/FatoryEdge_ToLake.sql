
    DECLARE  @LowWaterMark          DATE         = '2021-11-25'   -- GE
            ,@HigWaterMark          DATE         = '2021-11-28'   -- LT   
            ,@Resolution            VARCHAR(25)  = 'Day'   -- Day/Month
     	    ,@SourceSystemName      sysname      = 'FatoryEdge'
     	    ,@ContainerName         sysname      = 'slicedimport'
            ,@AlternativeRootFolder sysname      = 'raw'
            ,@MaxRowsPerFile   int          = 1
       
    EXEC [Helper].[GenerateSliceMetaData] 
             @LowWaterMark            = @LowWaterMark
            ,@HigWaterMark            = @HigWaterMark
            ,@Resolution              = @Resolution
            ,@SourceSystemName        = @SourceSystemName
     	    ,@SourceSchema            = 'Core'
     		,@SourceObject            = 'Measurement'
     		,@GetDataCommand          = 'SELECT [Ts], [SignalName], [MeasurementValue] FROM [Core].[Measurement]'
     		,@DateFilterAttributeName = '[Ts]'
     		,@DateFilterAttributeType = 'DATETIME2(3)' -- Datatype should match to source table
			,@DestinationSchema       = 'Core'
     		,@DestinationObject       = 'Measurement'
     		,@ContainerName           = @ContainerName
            ,@AlternativeRootFolder   = @AlternativeRootFolder
            ,@MaxRowsPerFile          = @MaxRowsPerFile


SELECT *
FROM [Core].[SlicedImportObject]
WHERE SourceSystemName  = 'FatoryEdge'

