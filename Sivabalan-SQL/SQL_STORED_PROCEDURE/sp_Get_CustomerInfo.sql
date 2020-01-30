CREATE PROCEDURE [dbo].[sp_Get_CustomerInfo](@CustomerType Int)
AS
Begin
If @CustomerType = 1
Begin
Select CustomerID,Company_Name As 'CustomerName',Case When Active = 1 Then 'Active' Else 'Inactive' End  As Active From Customer Where CustomerID <> '0'
Order by CustomerID
End
Else
Begin
Select CustomerID,Company_Name As 'CustomerName',Case When Active = 1 Then 'Active' Else 'Inactive' End  As Active From Customer Where CustomerID <> '0'
Order by Company_Name
End
End
