CREATE Procedure sp_Get_BatchInfo (@PriceOption  int,@ItemCode nvarchar(20),@Mode int = 0,@TaxType int = 0)      
As      
BEGIN
/*Default mode*/
Declare @GSTEnable Int  
Select @GSTEnable = Isnull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'GSTaxEnabled' 

if @mode = 0
BEGIN
	If @PriceOption = 1       
	Begin      
	 If exists(Select Batch_Code From Batch_Products Where Product_Code = @ItemCode And IsNull(Free, 0) = 0)      
	 Begin      
	  Select Top 1 bp.Batch_Number,  bp.Expiry,  bp.PKD, items.PTS, items.PTR, items.ECP, items.Company_Price,  Items.Purchase_Price,bp.TaxSuffered,  
		Case When IsNull(bp.Taxtype,1)=2  
		Then IsNull((Select min(Tax_Code) from Tax Where IsNull(Tax.GSTFlag,0) = Case When @GSTEnable = 1 Then IsNull(Tax.GSTFlag,0) Else 0 End And 
		CST_Percentage=bp.TaxSuffered and CSTApplicableOn=bp.ApplicableOn and CSTPartOff=bp.PartofPercentage), 0)   
		Else IsNull((Select min(Tax_Code) from Tax Where IsNull(Tax.GSTFlag,0) = Case When @GSTEnable = 1 Then IsNull(Tax.GSTFlag,0) Else 0 End And 
		Percentage=bp.TaxSuffered and LSTApplicableOn=bp.ApplicableOn and LSTPartOff=bp.PartofPercentage), 0)   
		 End  , isnull(bp.PFM,0) PFM, isnull(bp.MRPFORTAX,0) MRPFORTAX		
	  From Batch_Products as bp, Items Where items.product_code =  bp.product_code   
	  and bp.Batch_Code in (Select Batch_Code From Batch_Products       
	  Where Product_Code = @ItemCode And IsNull(Free, 0) = 0)       
	  Order By  bp.Batch_Code Desc      
	 End      
	 Else      
	 Begin      
	  Select Null, Null, Null, PTS, PTR,ECP, Company_Price, Purchase_Price,Tax.Percentage,
	  Tax.Tax_Code From Items
		left outer join Tax  on Items.TaxSuffered = Tax.Tax_Code 
	  Where Items.Product_Code = @ItemCode        
	    
	 End      
	End       
	Else      
	Begin      
	 If exists(Select Batch_Code From Batch_Products Where Product_Code = @ItemCode And IsNull(Free, 0) = 0)      
	 Begin      
	  Select Top 1 Batch_Products.Batch_Number, Batch_Products.Expiry, Batch_Products.PKD, Items.PTS, Items.PTR, Items.ECP,      
	   Items.Company_Price, Items.Purchase_Price, Batch_Products.TaxSuffered,    
	  Case When IsNull(Batch_Products.Taxtype,1)=2  
		Then IsNull((Select min(Tax_Code) from Tax Where IsNull(Tax.GSTFlag,0) = Case When @GSTEnable = 1 Then IsNull(Tax.GSTFlag,0) Else 0 End And 
		CST_Percentage=Batch_Products.TaxSuffered and CSTApplicableOn=Batch_Products.ApplicableOn and CSTPartOff=Batch_Products.PartofPercentage), 0)   
		Else IsNull((Select min(Tax_Code) from Tax Where IsNull(Tax.GSTFlag,0) = Case When @GSTEnable = 1 Then IsNull(Tax.GSTFlag,0) Else 0 End And 
		Percentage=Batch_Products.TaxSuffered and LSTApplicableOn=Batch_Products.ApplicableOn and LSTPartOff=Batch_Products.PartofPercentage), 0)   
	  End  ,Isnull(Batch_Products.PFM,0) PFM ,isnull(Batch_Products.MRPFORTAX,0) MRPFORTAX
	  From Batch_Products, Items      
	  Where Batch_Products.Product_Code = Items.Product_Code And      
	  Batch_Products.Batch_Code in (Select Batch_Code From Batch_Products       
	  Where Product_Code = @ItemCode And IsNull(Free, 0) = 0) Order By Batch_Products.Batch_Code Desc      
	 End      
	 Else      
	 Begin      
	  Select Null, Null, Null, PTS, PTR, ECP, Company_Price, Purchase_Price,      
	  Tax.Percentage,
      Tax.Tax_Code From Items
		left outer join Tax  on Items.TaxSuffered = Tax.Tax_Code   
	  Where Product_Code = @ItemCode        
	  
	 End      
	End      
END
/*Stock Transfer IN - PFM is handled*/
ELSE if @mode = 3 
BEGIN
	If @PriceOption = 1       
	Begin      
	 If exists(Select Batch_Code From Batch_Products Where Product_Code = @ItemCode And IsNull(Free, 0) = 0)      
	 Begin      
	  Select Top 1 bp.Batch_Number,  bp.Expiry,  bp.PKD, items.PTS, items.PTR, items.ECP, items.Company_Price,  Items.Purchase_Price,      
	   --bp.TaxSuffered, 
	  case @TaxType 
		--Changes done for STI screen
		--LST   
		when 0 then 
		IsNull((Select min(Percentage) from Tax Where IsNull(Tax.GSTFlag,0) = Case When @GSTEnable = 1 Then IsNull(Tax.GSTFlag,0) Else 0 End And 
		Percentage=bp.TaxSuffered and LSTApplicableOn=bp.ApplicableOn and LSTPartOff=bp.PartofPercentage),0) 
		--CST
		when 1 then
		IsNull((Select min(cst_Percentage) from Tax Where IsNull(Tax.GSTFlag,0) = Case When @GSTEnable = 1 Then IsNull(Tax.GSTFlag,0) Else 0 End And 
		CST_Percentage=bp.TaxSuffered and CSTApplicableOn=bp.ApplicableOn and CSTPartOff=bp.PartofPercentage),0) 
		--FLST
		when 2 then
		IsNull((Select min(Percentage) from Tax Where IsNull(Tax.GSTFlag,0) = Case When @GSTEnable = 1 Then IsNull(Tax.GSTFlag,0) Else 0 End And 
		Percentage=bp.TaxSuffered and LSTApplicableOn=bp.ApplicableOn and LSTPartOff=bp.PartofPercentage),0) 
	  else
		bp.TaxSuffered end,  
		Case When IsNull(bp.Taxtype,1)=2  
		Then IsNull((Select min(Tax_Code) from Tax Where IsNull(Tax.GSTFlag,0) = Case When @GSTEnable = 1 Then IsNull(Tax.GSTFlag,0) Else 0 End And 
		CST_Percentage=bp.TaxSuffered and CSTApplicableOn=bp.ApplicableOn and CSTPartOff=bp.PartofPercentage), 0)   
		Else IsNull((Select min(Tax_Code) from Tax Where IsNull(Tax.GSTFlag,0) = Case When @GSTEnable = 1 Then IsNull(Tax.GSTFlag,0) Else 0 End And 
		Percentage=bp.TaxSuffered and LSTApplicableOn=bp.ApplicableOn and LSTPartOff=bp.PartofPercentage), 0)   
		 End,isnull(items.PFM,0)  ,  isnull(bp.MRPFORTAX,0) MRPFORTAX
		, IsNull(bp.MRPPerPack,0)
	  From Batch_Products as bp, Items Where items.product_code =  bp.product_code   
	  and bp.Batch_Code in (Select Batch_Code From Batch_Products       
	  Where Product_Code = @ItemCode And IsNull(Free, 0) = 0)       
	  Order By  bp.Batch_Code Desc      
	 End      
	 Else      
	 Begin      
	  Select Null, Null, Null, PTS, PTR,ECP, Company_Price, Purchase_Price,       
--	  Tax.Percentage,
	  case @TaxType 
		--Changes done for STI screen
		--LST   
		when 0 then 
		IsNull((Select min(Percentage) from Tax Where Tax_Code=Items.TaxSuffered),0) 
		--CST
		when 1 then
		IsNull((Select min(cst_Percentage) from Tax Where Tax_Code=Items.TaxSuffered),0) 
		--FLST
		when 2 then
		IsNull((Select min(Percentage) from Tax Where Tax_Code=Items.TaxSuffered),0) 
	  else
		Tax.Percentage end,  
Tax.Tax_Code,isnull(PFM,0) PFM ,  (Select Top 1 isnull(MRPFORTAX,0) From Batch_Products Where Product_Code = @ItemCode) MRPFORTAX
, IsNull(MRPPerPack,0)
From Items
		left outer join Tax  on Items.TaxSuffered = Tax.Tax_Code   
	  Where Items.Product_Code = @ItemCode        
	    
	 End      
	End       
	Else      
	Begin      
	 If exists(Select Batch_Code From Batch_Products Where Product_Code = @ItemCode And IsNull(Free, 0) = 0)      
	 Begin      
	  Select Top 1 Batch_Products.Batch_Number, Batch_Products.Expiry, Batch_Products.PKD, Items.PTS, Items.PTR, Items.ECP,      
	   Items.Company_Price, Items.Purchase_Price, 
       --Batch_Products.TaxSuffered,    
	  case @TaxType 
		--Changes done for STI screen
		--LST   
		when 0 then 
		IsNull((Select min(Percentage) from Tax Where IsNull(Tax.GSTFlag,0) = Case When @GSTEnable = 1 Then IsNull(Tax.GSTFlag,0) Else 0 End And 
		Percentage=Batch_Products.TaxSuffered and LSTApplicableOn=Batch_Products.ApplicableOn and LSTPartOff=Batch_Products.PartofPercentage),0) 
		--CST
		when 1 then
		IsNull((Select min(cst_Percentage) from Tax Where IsNull(Tax.GSTFlag,0) = Case When @GSTEnable = 1 Then IsNull(Tax.GSTFlag,0) Else 0 End And 
		CST_Percentage=Batch_Products.TaxSuffered and CSTApplicableOn=Batch_Products.ApplicableOn and CSTPartOff=Batch_Products.PartofPercentage),0) 
		--FLST
		when 2 then
		IsNull((Select min(Percentage) from Tax Where Percentage=Batch_Products.TaxSuffered and LSTApplicableOn=Batch_Products.ApplicableOn and LSTPartOff=Batch_Products.PartofPercentage),0) 
	  else
		Batch_Products.TaxSuffered end,  
	  Case When IsNull(Batch_Products.Taxtype,1)=2  
		Then IsNull((Select min(Tax_Code) from Tax Where IsNull(Tax.GSTFlag,0) = Case When @GSTEnable = 1 Then IsNull(Tax.GSTFlag,0) Else 0 End And 
		CST_Percentage=Batch_Products.TaxSuffered and CSTApplicableOn=Batch_Products.ApplicableOn and CSTPartOff=Batch_Products.PartofPercentage), 0)   
		Else IsNull((Select min(Tax_Code) from Tax Where IsNull(Tax.GSTFlag,0) = Case When @GSTEnable = 1 Then IsNull(Tax.GSTFlag,0) Else 0 End And 
		Percentage=Batch_Products.TaxSuffered and LSTApplicableOn=Batch_Products.ApplicableOn and LSTPartOff=Batch_Products.PartofPercentage), 0)   
	  End, isnull(Items.PFM,0)  , isnull(Batch_Products.MRPFORTAX,0) MRPFORTAX
	, IsNull(Batch_Products.MRPPerPack,0)
	  From Batch_Products, Items      
	  Where Batch_Products.Product_Code = Items.Product_Code And      
	  Batch_Products.Batch_Code in (Select Batch_Code From Batch_Products       
	  Where Product_Code = @ItemCode And IsNull(Free, 0) = 0) Order By Batch_Products.Batch_Code Desc      
	 End      
	 Else      
	 Begin      
	  Select Null, Null, Null, PTS, PTR, ECP, Company_Price, Purchase_Price,      
--	  Tax.Percentage,
	  case @TaxType 
		--Changes done for STI screen
		--LST   
		when 0 then 
		IsNull((Select min(Percentage) from Tax Where Tax_Code=Items.TaxSuffered),0) 
		--CST
		when 1 then
		IsNull((Select min(cst_Percentage) from Tax Where Tax_Code=Items.TaxSuffered),0) 
		--FLST
		when 2 then
		IsNull((Select min(Percentage) from Tax Where Tax_Code=Items.TaxSuffered),0) 
	  else
		Tax.Percentage end,  
	  Tax.Tax_Code, isnull(PFM,0) , IsNull(MRPPerPack, 0)
		From Items
		left outer join Tax  on Items.TaxSuffered = Tax.Tax_Code 
	  Where Product_Code = @ItemCode        
	      
	 End      
	End      
	
END
END
