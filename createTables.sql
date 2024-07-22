CREATE TABLE IF NOT EXIST FloristicData (
    ID VARCHAR(50),
    temperature float,
    humidity float,
    velocity float,
    fuelLevel float,
    TIMESTAMP DATETIME,
);

CREATE TABLE IF NOT EXIST BooleanRealTimeData (
    ID VARCHAR(50),
    state VARCHAR(50),
    TIMESTAMP DATETIME,
    entry_id VARCHAR(50) NOT NULL,
    PRIMARY KEY(entry_id),
);

CREATE TABLE NumericRealTimeData (
    ID VARCHAR(50),
    measurement float,
    TIMESTAMP DATETIME,
    entry_id VARCHAR(50) NOT NULL,
    PRIMARY KEY(entry_id),
);