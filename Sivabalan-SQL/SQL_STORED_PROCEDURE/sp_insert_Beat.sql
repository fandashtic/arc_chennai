
CREATE PROCEDURE [sp_insert_Beat](@Description_2 [nvarchar](255))
AS 
declare @BeatID int
INSERT INTO [Beat] ([Description]) 
VALUES (@Description_2)
Select @@identity

select @BeatId = @@identity 
print @beatid
if @BeatID   > 0
begin
	INSERT INTO [Beat_Salesman] ([BeatID], [SalesmanID], [CustomerID]) 
	VALUES (@BeatID, 0, ' ')
end


