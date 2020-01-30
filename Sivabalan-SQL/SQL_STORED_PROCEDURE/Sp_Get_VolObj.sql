CREATE Procedure Sp_Get_VolObj(@CustomerID Nvarchar(150), @Index Integer=0)  
As  
Declare @CustID NVarchar(15)
If @Index = 0
select Volume,serial from CustomerObjective where customerid = @CustomerID  order by serial  
Else
Begin
Select @CustID = CustomerID From Customer Where Company_Name = @CustomerID
select Volume,serial from CustomerObjective where customerid = @CustID  order by serial  
End


