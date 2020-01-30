Create Procedure mERP_sp_GetRFADetails(@ID Int)
As

	Select RFAID, SchemeType, ActivityCode, Description, ActiveFrom, ActiveTo, PayoutFrom, PayoutTo,
		Division, SubCategory, MarketSKU, SystemSKU, UOM, SaleQty, SaleValue, PromotedQty, PromotedValue,
		IsNull(FreeBaseUOM,'') as FreeBaseUOM , RebateQty, RebateValue, BudgetedQty, BudgetedValue, AppOn, 
		SubmissionDate, SalvageQty, SalvageValue ,IsNull(DamageOption,'') "DamageOption"  
	From tbl_mERP_RFAAbstract 
	Where RFADocID = @ID 
	Order By RFAID

	If (Select Count(*) From tbl_mERP_RFAAbstract Where RFADocID = @ID And AppOn = 'SPL_CAT') > 0
	Begin
		/* 'DocNo' Changed to  'Doc No' */
		Select RFA.RFAID, RFA.ActivityCode, RFA.CSSchemeID, RFA.Description, RFA.ActiveFrom, RFA.ActiveTo, RFA.BillRef, RFA.CustomerID as OutletCode, Cust.Company_Name as OutletName, 
			RFA.RCSID, RFA.ActiveInRCS, RFA.LineType, RFA.Division,  RFA.SubCategory, RFA.MarketSKU, RFA.SystemSKU, RFA.UOM,  RFA.SaleQty, RFA.SaleValue, RFA.PromotedQty, RFA.PromotedValue,
			RFA.RebateQty, RFA.RebateValue, RFA.Price_Excl_Tax as PriceExclTax, RFA.Tax_Percentage as TaxPercentage, RFA.Tax_Amount as TaxAmount,
			RFA.Price_Incl_Tax as PriceInclTax, RFA.BudgetedQty, RFA.BudgetedValue,isNull(RFA.DocNO,'') as 'Doc No',
			isNull(RFARea.Reason,'') as Reason  
			From tbl_mERP_RFADetail RFA Left join Customer Cust on RFA.CustomerID = Cust.CustomerID 
			Left join tbl_mERP_RFADet_Reason RDR on RDR.RFAID = RFA.RFAID and RDR.CSSchemeID = RFA.CSSchemeID
			Left join tbl_mERP_RFASubmission_Reason RFARea  on RFARea.ReasonID  = RDR.RFAReason
			Where RFA.RFAID In (Select RFAID From tbl_mERP_RFAAbstract Where RFADocID =@ID) 
			And LineType <>'Free' 
			
		Union ALL
		Select RFA.RFAID, RFA.ActivityCode, RFA.CSSchemeID, RFA.Description, RFA.ActiveFrom, RFA.ActiveTo, RFA.BillRef, RFA.CustomerID as OutletCode, Cust.Company_Name as OutletName, 
			RFA.RCSID, RFA.ActiveInRCS, RFA.LineType, RFA.Division,  RFA.SubCategory, RFA.MarketSKU, RFA.SystemSKU, RFA.UOM,  RFA.SaleQty, RFA.SaleValue, RFA.PromotedQty, RFA.PromotedValue,
			RFA.RebateQty, RFA.RebateValue, RFA.Price_Excl_Tax as PriceExclTax, RFA.Tax_Percentage as TaxPercentage, RFA.Tax_Amount as TaxAmount,
			RFA.Price_Incl_Tax as PriceInclTax, RFA.BudgetedQty, RFA.BudgetedValue,isNull(RFA.DocNo,'') as 'Doc No',
			isNull(RFARea.Reason,'') as Reason  
			From tbl_mERP_RFADetail RFA Left join Customer Cust on RFA.CustomerID = Cust.CustomerID 
			Left join tbl_mERP_RFADet_Reason RDR on RDR.RFAID = RFA.RFAID and RDR.CSSchemeID = RFA.CSSchemeID
			Left join tbl_mERP_RFASubmission_Reason RFARea  on RFARea.ReasonID  = RDR.RFAReason
			Where RFA.RFAID In (Select RFAID From tbl_mERP_RFAAbstract Where RFADocID =@ID) 
			And LineType = 'Free'
			
			--Order By RFAID
	End
	Else
		Select RFA.RFAID, RFA.ActivityCode, RFA.CSSchemeID, RFA.Description, RFA.ActiveFrom, RFA.ActiveTo, RFA.BillRef, RFA.CustomerID as OutletCode, Cust.Company_Name as OutletName, 
			RFA.RCSID, RFA.ActiveInRCS, RFA.LineType, RFA.Division,  RFA.SubCategory, RFA.MarketSKU, RFA.SystemSKU, RFA.UOM,  RFA.SaleQty, RFA.SaleValue, RFA.PromotedQty, RFA.PromotedValue,
			RFA.RebateQty, RFA.RebateValue, RFA.Price_Excl_Tax as PriceExclTax, RFA.Tax_Percentage as TaxPercentage, RFA.Tax_Amount as TaxAmount,
			RFA.Price_Incl_Tax as PriceInclTax, RFA.BudgetedQty, RFA.BudgetedValue,isNull(RFA.DocNo,'') as 'Doc No',
			isNull(RDR.Reason,'') as Reason  
			From tbl_mERP_RFADetail RFA Left join Customer Cust on RFA.CustomerID = Cust.CustomerID 
			Left join (
				Select Distinct RFAID, CSSchemeID, RFAReason,Reason 
				From tbl_mERP_RFADet_Reason X
				Join tbl_mERP_RFASubmission_Reason RFARea on RFARea.ReasonID = X.RFAReason 
				) RDR on RDR.RFAID = RFA.RFAID and RDR.CSSchemeID = RFA.CSSchemeID    			
			Where RFA.RFAID In (Select RFAID From tbl_mERP_RFAAbstract Where RFADocID =@ID) 
			
			Order By RFA.RFAID
