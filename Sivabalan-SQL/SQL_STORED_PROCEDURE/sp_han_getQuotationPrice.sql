Create Procedure sp_han_getQuotationPrice(
@CustId	 nVarchar(30) 
,@ItemCode   nVarchar(30)
,@OrderDate DateTime)
As  
Declare @QuotationType  int  
Declare @QuotationId	int 
Declare @PurchasedAt Int

Select @PurchasedAt = IsNull(Purchased_At,0)
from Items where Product_Code = @ItemCode

Select @Quotationid = QAbs.Quotationid,@QuotationType = QuotationType 
From QuotationAbstract QAbs,QuotationCustomers QCust
Where QAbs.QuotationId = QCust.QuotationId 
And @OrderDate Between QAbs.ValidFromDate and QAbs.ValidToDate
And QCust.CustomerId = @CustId and IsNull(QAbs.Active,0) = 1

If @QuotationType = 1 --Items
Begin
	Select IsNull(QItems.RateQuoted,0) 'Rate'   
	From QuotationItems QItems 
	where QItems.Product_Code =@ItemCode
	And QItems.QuotationId = @QuotationId
End
Else If @QuotationType = 2 or @QuotationType = 3   -- 2=>Category/3=>Manufacture
Begin	
	Select 'Rate' = 
	IsNull(Case 
		When Batch.Product_Code is NUll then
			(Case QMfr.MarginOn   
				When 1 Then   
					IsNull(Items.ECP,0) - (IsNull(Items.ECP,0) * (IsNull(QMfr.MarginPercentage,0) / 100))  
				Else  
					IsNull(Items.Purchase_Price,0) + (IsNull(Items.Purchase_Price,0) * (IsNull(QMfr.MarginPercentage,0) / 100))
			End)
		Else
			(Case QMfr.MarginOn   
				When 1 Then   
					IsNull(Batch.ECP,0) - (IsNull(Batch.ECP,0) * (IsNull(QMfr.MarginPercentage,0) / 100))  
				Else  
					IsNull(Batch.PurchasePrice,0) + (IsNull(Batch.PurchasePrice,0) * (IsNull(QMfr.MarginPercentage,0) / 100))
			End)
	End,0)    
	From  QuotationMfrCategory QMfr Inner Join Items 
	On (
	(Items.ManufacturerId = QMfr.MfrCategoryID And QuotationType = 1) Or  
	(Items.CategoryID = QMfr.MfrCategoryID And QuotationType = 2)
	)   
	And QMfr.QuotationId = @QuotationId
	And Items.Product_Code =@ItemCode
	Left Outer Join 
		(Select top 1 bc.Product_Code
			,bc.ECP
			,"PurchasePrice" = Case @PurchasedAt
				When 1 Then bc.PTS
				When 2 Then	bc.PTR
				When 3 Then bc.Company_Price
				Else bc.ECP
			End 
		From batch_products bc  Where  bc.Product_Code = @ItemCode
		And bc.Quantity > 0 
		And IsNull(bc.Damage, 0) = 0     
		And IsNull(bc.Expiry, Getdate()) >= Getdate()
		Order By IsNull(bc.Free, 0), bc.Batch_Code ) Batch
	On Batch.Product_Code = Items.Product_Code
End
