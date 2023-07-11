﻿/* SQL Source

CREATE SCHEMA [Core];

CREATE TABLE [Core].[Measurement]
(
   [Ts]                 DATETIME2(3) NOT NULL
  ,[SignalName]         NVARCHAR(50) NOT NULL
  ,[MeasurementValue]   REAL         NOT NULL
);
GO


INSERT INTO [Core].[Measurement] values ('2021-11-25 12:00:03', 'Temperature',	 23.5);
INSERT INTO [Core].[Measurement] values ('2021-11-25 12:00:04', 'Humidity',	     45.4);
INSERT INTO [Core].[Measurement] values ('2021-11-25 12:00:04', 'Temperature',	 22.5);
INSERT INTO [Core].[Measurement] values ('2021-11-26 12:00:07', 'Temperature',	 23.5);
INSERT INTO [Core].[Measurement] values ('2021-11-26 12:00:07', 'Humidity',	     44.8);
INSERT INTO [Core].[Measurement] values ('2021-11-26 12:00:09', 'Temperature',	 25.0);
INSERT INTO [Core].[Measurement] values ('2021-11-27 12:00:07', 'Humidity',	     44.8);
INSERT INTO [Core].[Measurement] values ('2021-11-27 12:00:09', 'Temperature',	 25.0);


SELECT * FROM [Core].[Measurement]
*/

/* ADX destination

.create table Measurement (Ts:datetime, SignalName:string, MeasurementValue:decimal)


*/

-- Minimal meta data, if all attributes from the source table can be transferred

DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
        ,@HigWaterMark     DATE         = '2021-11-28'   -- LT   
        ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
 	    ,@SourceSystemName sysname      = 'BuildingTelemetry_SQLtoADX'
   
EXEC [Helper].[GenerateSliceMetaData] 
         @LowWaterMark            = @LowWaterMark
        ,@HigWaterMark            = @HigWaterMark
        ,@Resolution              = @Resolution
        ,@SourceSystemName        = @SourceSystemName
 	    ,@SourceSchema            = 'Core'
 		,@SourceObject            = 'Measurement'
 		,@DateFilterAttributeName = '[Ts]'
 		,@DateFilterAttributeType = 'DATETIME2(3)' -- Datatype should match to source table
 		,@DestinationObject       = 'Measurement'

GO


-- It is also possible to specify the SQL statement instead of @SourceSchema and @SourceObject 

DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
        ,@HigWaterMark     DATE         = '2021-11-28'   -- LT   
        ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
 	    ,@SourceSystemName sysname      = 'BuildingTelemetry_SQLtoADX'
   
EXEC [Helper].[GenerateSliceMetaData] 
         @LowWaterMark            = @LowWaterMark
        ,@HigWaterMark            = @HigWaterMark
        ,@Resolution              = @Resolution
        ,@SourceSystemName        = @SourceSystemName
 		,@GetDataCommand          = 'SELECT [Ts], [SignalName], [MeasurementValue] FROM [Core].[Measurement]'
 		,@DateFilterAttributeName = '[Ts]'
 		,@DateFilterAttributeType = 'DATETIME2(3)' -- Datatype should match to source table
 		,@DestinationObject       = 'Measurement'


SELECT *
FROM   [Mart].[SlicedImportObject]
WHERE  SourceSystemName  = 'BuildingTelemetry_SQLtoADX'


GO

-- It is also possible to specify the SQL statement instead of @SourceSchema and @SourceObject 
-- If they are specified, then they can be used to filter the objects when the pipeline is executed

DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
        ,@HigWaterMark     DATE         = '2021-11-28'   -- LT   
        ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
 	    ,@SourceSystemName sysname      = 'BuildingTelemetry_SQLtoADX'
   	    ,@ContainerName    sysname      = 'adftopowerbi'
   
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
 		,@DestinationObject       = 'Measurement'
   		,@ContainerName           = @ContainerName


SELECT *
FROM   [Mart].[SlicedImportObject]
WHERE  SourceSystemName  = 'BuildingTelemetry_SQLtoADX'

