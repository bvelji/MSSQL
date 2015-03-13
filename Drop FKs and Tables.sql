/* Drop all foreign keys and tables in a schema.
To use: 
	Provide a database for the using statement 
	Provide a schema name
	Set @debug:
		1: Select objects to be dropped 
		0: Print and execute drop statements
*/

USE /*DB name*/
GO

DECLARE
     @schemaName varchar(100) = ''
    ,@debug bit = 1;

DECLARE @schemaID int = 
	(SELECT schema_id
	 FROM sys.schemas
	 WHERE name = @schemaName);

IF @debug = 1
BEGIN
    SELECT 
		 fk.name AS ForeignKey
		,t.name AS [Table]
    FROM 
		sys.foreign_keys fk
		INNER JOIN sys.tables t 
			ON fk.parent_object_id = t.object_id
    WHERE fk.schema_id = @schemaID;

	SELECT t.name AS [Table] 
	FROM sys.tables t
	WHERE t.schema_id = @schemaID;
END;

DECLARE 
	 @tableName varchar(100)
    ,@FKName varchar(255)
    ,@FKCount int = 
		(SELECT COUNT(*)
		 FROM sys.foreign_keys
		 WHERE schema_id = @schemaID);
    

WHILE @FKCount > 0
BEGIN
    SELECT TOP 1
         @tableName = t.name
        ,@FKName = fk.name
    FROM
        sys.foreign_keys fk
        INNER JOIN sys.tables t
            ON fk.parent_object_id = t.object_id
    WHERE fk.schema_id = @schemaID;

    IF @debug = 0
	BEGIN
		PRINT('ALTER TABLE ' + @schemaName + '.[' + @tableName + '] DROP ' + @FKName);
        EXEC('ALTER TABLE ' + @schemaName + '.[' + @tableName + '] DROP ' + @FKName);
    END;

    SET @FKCount -= 1;
END;

DECLARE @tableCount int = 
	(SELECT COUNT(*)
	 FROM sys.tables
	 WHERE schema_id = @schemaID);

WHILE @tableCount > 0
BEGIN
    SELECT TOP 1 @tableName = t.name
    FROM sys.tables t
    WHERE t.schema_id = @schemaID;

    IF @debug = 0
    BEGIN
		PRINT('DROP TABLE ' + @schemaName + '.[' + @tableName + ']');
        EXEC('DROP TABLE ' + @schemaName + '.[' + @tableName + ']');
    END;

    SET @tableCount -= 1;
END;
