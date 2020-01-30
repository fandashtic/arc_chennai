CREATE PROCEDURE [sp_insert_SalesStaff]	(@Staff_Name [nvarchar](100),
					 @Addr nvarchar(510), 
					 @phone nvarchar(50), 
					 @Commission Decimal(18,6),
					 @Active int)
AS 
declare @StaffID int
 
INSERT INTO [salesstaff] (Staff_Name, Address, Phone, Commission, Active) 
VALUES 	(@Staff_Name, @Addr, @phone, @Commission, 1 )
Select @@identity

select @StaffID = @@identity 
print @StaffID
if @StaffID   > 0
begin
	INSERT INTO [salesstaff] ([Staff_ID])
	VALUES (@StaffID)
end
