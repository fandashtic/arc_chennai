CREATE procedure [dbo].[spr_List_Bill_Items_Cons](@BillId NVarChar(50))    
As    
	Declare		@CIDRpt As NVarChar(50)
	Declare		@CIDSetUp As NVarChar(50)
	Select @CIDSetUp=RegisteredOwner From Setup 
	Select @CIDRpt=Right(@BillId,Len(@CIDSetUp))

If @CIDRpt<>@CIDSetUp
	Begin
		Select
			RDR.Field1,"Item Code" = RDR.Field1,"Item Name" = RDR.Field2, "Batch" = RDR.Field3,    
		 "Expiry" = RDR.Field4, "Quantity" = RDR.Field5,"Rate (%c)" = RDR.Field6, "PTR (%c)" = RDR.Field7,    
		 "MRP (%c)" = RDR.Field8, "Goods Value (%c)" = RDR.Field9,"Gross Amount (%c)" = RDR.Field10, 
			"Discount (%c)" = RDR.Field11,"Tax Suffered%" = RDR.Field12, "Tax Amount (%c)" = RDR.Field13,
		 "Total (%c)" = RDR.Field14
		From
			ReportDetailReceived RDR
		Where
			RDR.RecordID =@BillId
			And RDR.Field1 <> N'Item Code' And RDR.Field1 <> N'SubTotal:' And RDR.Field1 <> N'GrandTotal:'  
	End
Else
	Begin

		Declare @BilId As NVarChar(50)
		Select @BilId=Left(@BillId,Len(@BillId)-Len(@CIDSetUp))

		Select
		 BillDetail.Product_Code, "Item Code" = BillDetail.Product_Code,     
		 "Item Name" = Items.ProductName, "Batch" = BillDetail.Batch,    
		 "Expiry" = BillDetail.Expiry, "Quantity" = BillDetail.Quantity,     
		 "Rate (%c)" = BillDetail.PurchasePrice, "PTR (%c)" = BillDetail.PTR,    
		 "MRP (%c)" = BillDetail.ECP, "Goods Value (%c)" = BillDetail.Quantity * BillDetail.PurchasePrice,    
		 "Gross Amount (%c)" = BillDetail.Amount, "Discount (%c)" = BillDetail.Discount,    
		 "Tax Suffered%" = BillDetail.TaxSuffered, "Tax Amount (%c)" = BillDetail.TaxAmount,    
		 "Total (%c)" = BillDetail.Amount + BillDetail.TaxAmount    
		From  
		 BillDetail, Items    
		Where  
		 BillDetail.BillId = @BilId AND    
		 BillDetail.Product_Code *= Items.Product_Code  
	End
