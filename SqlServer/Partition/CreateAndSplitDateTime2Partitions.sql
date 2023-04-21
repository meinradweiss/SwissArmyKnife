DROP PARTITION SCHEME [monthDateTimePartitionScheme];
DROP PARTITION FUNCTION [monthDateTimePartitionFunction];
GO

CREATE PARTITION FUNCTION [monthDateTimePartitionFunction](datetime2)
    AS RANGE RIGHT
    FOR VALUES ('1900.01.01');


CREATE PARTITION SCHEME [monthDateTimePartitionScheme]
    AS PARTITION [monthDateTimePartitionFunction]
    TO ([PRIMARY], [PRIMARY]);
GO



DROP PROCEDURE [Partition].[SplitMonthDateTime2Partition];
DROP SCHEMA    [Partition];
GO

CREATE SCHEMA [Partition];
GO

CREATE PROCEDURE [Partition].[SplitMonthDateTime2Partition](@LowWaterDate  DATETIME2   -- Including
                                                          ,@HighWaterDate DATETIME2)  -- Including
AS
BEGIN                                             

    -- Usage, e.g. EXEC [Partition].[SplitMonthDateTime2Partition] @LowWaterDate = '2023.01.01', @HighWaterDate = '2024.01.01'

    DECLARE @NumberOfMonthsToConsider INT;

    DECLARE @AddSplits CURSOR;
    DECLARE @SQLString nVARCHAR(max);
    DECLARE @SplitKey  DATETIME2;

    SET @NumberOfMonthsToConsider = DATEDIFF(MONTH, @LowWaterDate,@HighWaterDate) + 1


    SET @AddSplits = CURSOR FOR
    WITH e1(n) AS
    (
        SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
        SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
        SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
    ),                                              -- 10
    e2(n) AS (SELECT 1 FROM e1 CROSS JOIN e1 AS b), -- 10 *     10 =     100
    e3(n) AS (SELECT 1 FROM e1 CROSS JOIN e2),      -- 10 *    100 =   1'000
    e4(n) AS (SELECT 1 FROM e1 CROSS JOIN e3),      -- 10 *  1'000 =  10'000
    e5(n) AS (SELECT 1 FROM e1 CROSS JOIN e4)       -- 10 * 10'000 = 100'000
    ,PartitionRangesAheadList(AheadCounter)
    AS (
    SELECT TOP(@NumberOfMonthsToConsider) n = ROW_NUMBER()  OVER (ORDER BY n) -1 -- Zero Based
    FROM e5 
    ORDER BY n
    )
    , DateList
    AS
    (
        SELECT AheadCounter
            , DATEADD(month, AheadCounter, @LowWaterDate) AS theDate
        FROM PartitionRangesAheadList
    )
    ,ExpectedSplitKeys
    AS
    (
    select theDate
    from DateList
    where theDate <= @HighWaterDate
    )
    ,ExistingSplitKey
    AS
    (
    SELECT CONVERT(DATETIME2,value)  as PartitionStartRange
    FROM sys.partition_functions AS pf 
    INNER JOIN sys.partition_range_values AS pfrv
        ON PF.function_id = pfrv.function_id
        WHERE pf.name = 'monthDateTimePartitionFunction'
    )
    ,MissingSplitRanges
    AS
    (
    SELECT theDate
    FROM   ExpectedSplitKeys
    LEFT OUTER JOIN ExistingSplitKey
        ON ExpectedSplitKeys.theDate = ExistingSplitKey.PartitionStartRange
    where PartitionStartRange is null
    )
    SELECT  * FROM MissingSplitRanges ORDER BY theDate


    OPEN @AddSplits
    FETCH next FROM @AddSplits INTO @SplitKey

    WHILE @@fetch_status = 0
    BEGIN

        SET @SQLString =  'ALTER PARTITION SCHEME   monthDateTimePartitionScheme     NEXT  USED [PRIMARY];'
        SET @SQLString += 'ALTER PARTITION FUNCTION monthDateTimePartitionFunction() SPLIT RANGE(''' + CONVERT(VARCHAR, @SplitKey) + ''');'

        PRINT @SQLString
        EXEC sp_executesql @statement = @SQLString ;

    FETCH next FROM @AddSplits INTO @SplitKey
    END


    CLOSE @AddSplits
    DEALLOCATE @AddSplits
END;

GO

-- Test it
EXEC [Partition].[SplitMonthDateTime2Partition] @LowWaterDate = '2023.01.01', @HighWaterDate = '2024.01.01'

SELECT CONVERT(DATETIME2,value)  as PartitionStartRange
    FROM sys.partition_functions AS pf 
    INNER JOIN sys.partition_range_values AS pfrv
        ON PF.function_id = pfrv.function_id
        WHERE pf.name = 'monthDateTimePartitionFunction'
