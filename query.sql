WITH NumericData AS(

    SELECT  
        entity_id AS ID,
        CAST(last_reported AS datetime) AS TIMESTAMP,
        context.id as entry_id,

    CASE state
        WHEN 'unavailable' THEN CAST(NaN AS float)
        WHEN 'unknown' THEN CAST(NaN AS float)
        ELSE CAST(state AS float)
    END AS measurement

    FROM FlowerPowerHub TIMESTAMP BY last_reported
    WHERE entity_id LIKE 'sensor.%'
      AND entity_id NOT LIKE '%address' 
)

SELECT * INTO NumericRealTimeData FROM NumericData

SELECT 
    entity_id AS ID,
    CAST(last_reported AS datetime) AS TIMESTAMP,
    context.id as entry_id,
    state

INTO BooleanRealTimeData
FROM FlowerPowerHub TIMESTAMP BY last_reported

WHERE entity_id LIKE 'button%'
    OR entity_id LIKE 'switch%'
    OR entity_id LIKE 'bin%'