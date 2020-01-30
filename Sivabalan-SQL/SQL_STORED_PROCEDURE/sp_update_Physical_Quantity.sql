CREATE Procedure sp_update_Physical_Quantity (@ReconcileID Integer, @ItemCode nvarchar(100), @Qty as Decimal(18,6))  
As  
Declare @UpdateSQL nvarchar(2000)  
Set @UpdateSQL = N'Update ReconcileDetail Set PhysicalQuantity = ' + Cast(@Qty as nvarchar) + N' Where ReconcileID = ' + Cast(@ReconcileID as nvarchar) + N' And Product_Code = N''' + @ItemCode + ''''   
exec sp_executesql @UpdateSQL  

