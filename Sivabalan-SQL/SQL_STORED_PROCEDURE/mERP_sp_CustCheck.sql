Create Procedure mERP_sp_CustCheck ( @CustID nvarchar(255))
As
Declare @countCustID int
Select @countCustID  =Count(*) from Customer where CustomerID = @CustID 
Select @countCustID  
