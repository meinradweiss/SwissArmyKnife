
CREATE PROCEDURE [Helper].[GenerateSliceMetaData] (
            @LowWaterMark DATE = '2022.01.01'   -- GE
           ,@HigWaterMark DATE = '2022.03.01'   -- LT
    	   ,@Resolution   VARCHAR(25) = 'day'   -- Day/Month
           ,@SourceSystemName        sysname
		   ,@SourceSchema            sysname
		   ,@SourceObject            sysname
		   ,@GetDataCommand          nvarchar (max)
		   ,@DateFilterAttributeName sysname
		   ,@DateFilterAttributeType sysname
		   ,@DestinationSchema       sysname   = 'n/a'
		   ,@DestinationObject       sysname
		   ,@ContainerName           sysname   
		   ,@AlternativeRootFolder   sysname   = NULL  -- If provided, then this value is used, insetad of the @SourceSystemName to create the directory path,
		   ,@MaxRowsPerFile          int       = NULL
           ,@IngestionMappingName    sysname   = NULL

		   ) 
AS
BEGIN
    
	/* Usage

    DECLARE 
                @LowWaterMark     DATE        = '2002-06-01'   -- GE
               ,@HigWaterMark     DATE        = '2002-07-05'   -- LT   05
        	   ,@Resolution       VARCHAR(25) = 'Day'   -- Day/Month
    		   ,@SourceSystemName sysname     = 'AdventureWorksLT_ADX'
    		   ,@ContainerName    sysname     = 'N/A'
    
    
    EXEC [Helper].[GenerateSliceMetaData] 
                @LowWaterMark            = @LowWaterMark
               ,@HigWaterMark            = @HigWaterMark
               ,@Resolution              = @Resolution
               ,@SourceSystemName        = @SourceSystemName
    		   ,@SourceSchema            = 'SalesLT'
    		   ,@SourceObject            = 'Product'
    		   ,@GetDataCommand          = 'SELECT [ProductID], [Name], [ProductNumber], [Color], [SellStartDate] FROM [SalesLT].[Product]'
    		   ,@DateFilterAttributeName = '[SellStartDate]'
    		   ,@DateFilterAttributeType = 'DATETIME'
    		   ,@DestinationSchema       = 'N/A'
    		   ,@DestinationObject       = 'Product'
    		   ,@ContainerName           = @ContainerName
    		   ,@AlternativeRootFolder   = NULL
    		   ,@MaxRowsPerFile          = NULL

    GO

     DECLARE    @LowWaterMark     DATE         = '2002-06-01'   -- GE
               ,@HigWaterMark     DATE         = '2002-08-01'   -- LT   05
        	   ,@Resolution       VARCHAR(25)  = 'Month'   -- Day/Month
    		   ,@SourceSystemName sysname      = 'AdventureWorksLT'
    		   ,@ContainerName    sysname      = 'adftopowerbi'
    



    EXEC [Helper].[GenerateSliceMetaData] 
                @LowWaterMark            = @LowWaterMark
               ,@HigWaterMark            = @HigWaterMark
               ,@Resolution              = @Resolution
               ,@SourceSystemName        = @SourceSystemName
    		   ,@SourceSchema            = 'SalesLT'
    		   ,@SourceObject            = 'Customer'
    		   ,@GetDataCommand          = 'SELECT * FROM [SalesLT].[Customer]'
    		   ,@DateFilterAttributeName = '[RegistrationDate]'
    		   ,@DateFilterAttributeType = 'DATETIME'
    		   ,@DestinationSchema       = 'SalesLT_SDMT'
    		   ,@DestinationObject       = 'Customer'
    		   ,@ContainerName           = @ContainerName
    		   ,@AlternativeRootFolder   = NULL
    		   ,@MaxRowsPerFile          = NULL

    EXEC [Helper].[GenerateSliceMetaData] 
                @LowWaterMark            = @LowWaterMark
               ,@HigWaterMark            = @HigWaterMark
               ,@Resolution              = @Resolution
               ,@SourceSystemName        = @SourceSystemName
    		   ,@SourceSchema            = 'SalesLT'
    		   ,@SourceObject            = 'Customer'
    		   ,@GetDataCommand          = 'SELECT * FROM [SalesLT].[Customer]'
    		   ,@DateFilterAttributeName = '[RegistrationDate]'
    		   ,@DateFilterAttributeType = 'DATETIME'
    		   ,@DestinationSchema       = 'SalesLT_SDMT'
    		   ,@DestinationObject       = 'Customer'
    		   ,@ContainerName           = @ContainerName
    		   ,@AlternativeRootFolder   = NULL
    		   ,@MaxRowsPerFile          = NULL




	*/


    
    DECLARE @NumberOfDays   INT
           ,@NumberOfMonths INT
		   ,@TheDate        DATE
		   ,@NextDate       DATE
    
    
    SET @NumberOfDays   = DATEDIFF(DAY,   @LowWaterMark, @HigWaterMark)
    SET @NumberOfMonths = DATEDIFF(MONTH, @LowWaterMark, @HigWaterMark)
    

	-- Delete existing slices of the same source object
    DELETE 
	FROM [Core].[SlicedImportObject] 
	WHERE [SourceSystemName]  = @SourceSystemName 
	  AND [SourceSchema]      = @SourceSchema     
	  AND [SourceObject]      = @SourceObject     

	DECLARE @SliceCursor CURSOR

	IF  @Resolution  = 'Day'
	BEGIN
	  SET @SliceCursor = CURSOR FOR
	  SELECT TOP (@NumberOfDays) DATEADD(DAY, RowNumber, @LowWaterMark) AS TheDate, DATEADD(DAY, RowNumber +1, @LowWaterMark) AS NextDate
	  FROM  [Helper].[RowNumberList100K]
	END

	IF  @Resolution  = 'Month'
	BEGIN
	  SET @SliceCursor = CURSOR FOR
	  SELECT TOP (@NumberOfMonths) DATEADD(MONTH, RowNumber, @LowWaterMark) AS TheDate, DATEADD(MONTH, RowNumber +1, @LowWaterMark) AS NextDate
	  FROM  [Helper].[RowNumberList100K]
	END

	OPEN @SliceCursor

	FETCH NEXT FROM @SliceCursor INTO @TheDate, @NextDate;

    -- Loop through cursor data
    WHILE @@FETCH_STATUS = 0
    BEGIN
       -- Do something with cursor data
       PRINT 'Column 1: ' + CONVERT(VARCHAR(10),@TheDate) + ' ' + CONVERT(VARCHAR(10),@NextDate);


       INSERT INTO [Core].[SlicedImportObject]
           ([SourceSystemName]
           ,[SourceSchema]
           ,[SourceObject]
           ,[GetDataCommand]
           ,[FilterDataCommand]
           ,[DestinationSchema]
           ,[DestinationObject]
           ,[ContainerName]
           ,[DestinationPath]
           ,[DestinationFileName]
           ,[MaxRowsPerFile]
           ,[AdditionalContext]
           ,[IngestionMappingName]
		   )
       SELECT  
            @SourceSystemName  AS [SourceSystemName]
           ,@SourceSchema      AS [SourceSchema]
           ,@SourceObject      AS [SourceObject]
           ,@GetDataCommand    AS [GetDataCommand]
           ,CONCAT('WHERE ', @DateFilterAttributeName, ' >= CONVERT(', @DateFilterAttributeType ,', ''', CONVERT(VARCHAR, @TheDate,23),  ''',120) AND '
	                       , @DateFilterAttributeName, '  < CONVERT(', @DateFilterAttributeType ,', ''', CONVERT(VARCHAR, @NextDate,23), ''',120)')       
		                       AS [FilterDataCommand]
           ,@DestinationSchema AS [DestinationSchema]
           ,@DestinationObject AS [DestinationObject]
           ,@ContainerName     AS [ContainerName]
           ,CONCAT(COALESCE(@AlternativeRootFolder, @SourceSystemName),'/',@SourceSchema,'/',@SourceObject,'/'
		                                                                    , CONVERT(VARCHAR, DATEPART(YEAR,  @TheDate))     ,'/'
		                                                        ,RIGHT('00' + CONVERT(VARCHAR, DATEPART(MONTH, @TheDate)), 2) ,'/'
		                                                        ,RIGHT('00' + CONVERT(VARCHAR, DATEPART(DAY,   @TheDate)), 2) 
				  ) AS [DestinationPath]
           ,CONCAT(@SourceSystemName,'_',@SourceSchema,'_',@SourceObject,'_', CONVERT(VARCHAR, DATEPART(YEAR,  @TheDate))     
		                                                        ,RIGHT('00' + CONVERT(VARCHAR, DATEPART(MONTH, @TheDate)), 2) 
		                                                        ,RIGHT('00' + CONVERT(VARCHAR, DATEPART(DAY,   @TheDate)), 2) 
			       ,CASE WHEN @Resolution = 'Month' THEN CONCAT('_',          CONVERT(VARCHAR, DATEPART(YEAR,  DATEADD(DAY, -1, @NextDate)))     
		                                                        ,RIGHT('00' + CONVERT(VARCHAR, DATEPART(MONTH, DATEADD(DAY, -1, @NextDate))), 2) 
		                                                        ,RIGHT('00' + CONVERT(VARCHAR, DATEPART(DAY,   DATEADD(DAY, -1, @NextDate))), 2) 
																) ELSE '' END)
                               AS [DestinationFileName]
           ,@MaxRowsPerFile    AS [MaxRowsPerFile]
           ,CONCAT('{"creationTime": "', CONVERT(VARCHAR, @TheDate) ,'","tags":["Source:PipelineLoad"]}')  -- Take the last day of the month       
		                       AS [AdditionalContext]
           ,@IngestionMappingName AS [IngestionMappingName]





       FETCH NEXT FROM @SliceCursor INTO @TheDate, @NextDate;
    END
    
    -- Close cursor
    CLOSE @SliceCursor;
    
    -- Deallocate cursor
    DEALLOCATE @SliceCursor;

END