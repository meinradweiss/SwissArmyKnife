/* SQL Source



aamew4bg4iotsqlserver.database.windows.net

Synpase Pipeline (and ADX) must have a login in the Azure SQL Database


*/

/* ADX destination


.create-or-alter function  with (folder='Source', docstring='Get Measurement data from a SQL Server Database') Source_GetMeasurementFromSQL(Ts_Day: string)
{ 
let tbl =  
     evaluate 
       sql_request('Server=tcp:<serverName>.database.windows.net,1433;Authentication="Active Directory Integrated";Initial Catalog=aamew4bg4iotsqldb',
                   strcat('select Measurement.* from Core.Measurement /*cross join core.signal */ where Ts_Day = ', Ts_Day))
                   : (Ts: datetime, Ts_Day: int, SignalId: int, MeasurementValue: real, MeasurementText: string, MeasurementContext: string, CreatedAt: datetime) 
                  ;
tbl
}

.execute database script <|
.drop table Core_Measurement ifexists 
.set-or-append  Core_Measurement with (folder='Core')
 <| Source_GetMeasurementFromSQL('20221209') | take 0

*/

    DECLARE  @LowWaterMark     DATE         = '2022-11-18'   -- GE
            ,@HigWaterMark     DATE         = '2022-11-20'   -- LT   
            ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
     	    ,@SourceSystemName sysname      = 'SQLtoADXusingADXFetch'
     	    ,@ContainerName    sysname      = 'N/A'
       
    EXEC [Helper].[GenerateSliceMetaData] 
             @LowWaterMark            = @LowWaterMark
            ,@HigWaterMark            = @HigWaterMark
            ,@Resolution              = @Resolution
            ,@SourceSystemName        = @SourceSystemName
     	    ,@SourceSchema            = 'N/A'
     		,@SourceObject            = 'N/A'
     		,@GetDataCommand          = 'Source_GetMeasurementFromSQL'
     		,@DateFilterAttributeName = 'N/A'
     		,@DateFilterAttributeType = 'N/A' 
     		,@DestinationObject       = 'Core_Measurement'
     		,@ContainerName           = @ContainerName
            ,@TransferMode            = 'ADXFetch'


SELECT *
FROM   [Mart].[SlicedImportObject]
WHERE  SourceSystemName  = 'SQLtoADXusingADXFetch'
