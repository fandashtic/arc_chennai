
CREATE PROCEDURE sp_insert_TargetPeriod(@Period	nvarchar(50))
AS
INSERT INTO TargetPeriod(Period) Values(@Period)
select @@identity


