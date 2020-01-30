Create PROCEDURE sp_List_SKU_HHSR(@ReturnNo nvarchar(100), @ReturnType int = 1)
AS
	Create table #TmpSKUHHSR(RowID int identity ,Product_Code nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ProductName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, UOM nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Quantity decimal(18,6), PendingQty decimal(18,6))
		
	Insert Into #TmpSKUHHSR(Product_Code,ProductName,UOM,Quantity,PendingQty)
	Select  Items.Product_Code, Items.ProductName, 'PAC' as UOM, 
	Cast(Sum(dbo.FN_Get_BaseUOMQty(Items.Product_Code,SR.UOM,SR.Quantity) / Items.UOM2_Conversion) as Decimal(18,6)) as Quantity,
	Cast(Sum(isnull(SR.PendingQty,0) / Items.UOM2_Conversion) as Decimal(18,6)) as PendingQty
	From Stock_Return SR Inner Join Items ON SR.Product_Code = Items.Product_Code
	Where ReturnNumber = @ReturnNo and SR.ReturnType = @ReturnType
	and isnull(PendingQty,0) >= 0 and Processed = 3
	Group By Items.Product_Code, Items.ProductName, Items.UOM2_Conversion, SR.UOM
	
	Select RowID, Product_Code,ProductName,UOM,Quantity,PendingQty from #TmpSKUHHSR
	
	Drop table #TmpSKUHHSR

