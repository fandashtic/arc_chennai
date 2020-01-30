CREATE Function mERP_fn_GetMarginPTR(@ItemCode nVarchar(1000),@InvoiceID Int, @SchID Int)
Returns Decimal(18,6) 
As	
Begin
	Declare @InvoiceDate Datetime
	Declare @Channel nVarchar(255)
	Declare @Division nVarchar(255)
	Declare @Margin Decimal(18,6)
	Declare @MarginID Int
	Declare @PTR Decimal(18,6)
	
	Select @Channel = isNull(Channel_Type_Desc,''),@InvoiceDate = IA.InvoiceDate
	From
	InvoiceAbstract IA,
	tbl_mERP_OLClassMapping Map,
	tbl_mERP_OLClass OLClass 
	Where 
	IA.InvoiceID = @InvoiceID
	And IA.CustomerID = Map.CustomerID
	And	Map.OLClassID = OLClass.ID
	And Map.Active = 1

	Select  @Division = IC2.Category_Name
	From 
		Items I,ItemCategories IC,ItemCategories IC1,ItemCategories IC2
		
	Where 
		I.Product_Code = @ItemCode
		And	IC.CategoryID = I.CategoryID 
		And IC.ParentID = IC1.CategoryID  
		And IC1.ParentID = IC2.CategoryID   


	/* Margin % considered from the LastEffectiveDate */
	Select Top 1 @MarginID =  MarginID
	From tbl_mERP_PTRMargin
	Where CategoryName = @Division
	And Channel = isNull(@Channel,'')
	And Active = 1
	And EffectiveDate <= @InvoiceDate
	Order By EffectiveDate Desc

	If isNull(@MarginID,0) = 0 
		/* If margin Not defined for the free item then take the PTR from GRN(which is stored in Invoice) */
		Select @PTR = ID.PTR From InvoiceDetail ID Where ID.InvoiceID = @InvoiceID And ID.Product_Code = @ItemCode
			And id.flagword = 1 And (id.Schemeid  = @SchID or id.SPLCATSCHEMEID = @SchID)
	Else
	Begin
		Select @Margin = Margin From tbl_mERP_PTRMargin Where MarginID = @MarginID
	
		/* PTS + [PTS + (PTS * Purchase Tax /100)] * Margin%/100 */
		Select @PTR = --ID.PTS + ((ID.PTS + (ID.PTS * BP.TaxSuffered /100)) * @Margin /100)
		Case When ID.TaxOnQty =0 Then
			(Case IsNull(BP.Taxtype,0)	
				When 1 then (IsNull(ID.PTS,0) + ((isNull(ID.PTS,0) + (IsNull(ID.PTS,0) * IsNull(BP.TaxSuffered,0) /100)) * IsNull(@Margin,0) /100))
				When 2 then ((IsNull(ID.PTS,0) + (IsNull(ID.PTS,0) * IsNull(BP.TaxSuffered,0) /100)) + ((IsNull(ID.PTS,0) + (IsNull(ID.PTS,0) * IsNull(BP.TaxSuffered,0) /100)) * IsNull(@Margin,0) /100))
				When 3 then ((IsNull(ID.PTS,0) + (IsNull(ID.PTS,0) * IsNull(BP.TaxSuffered,0) /100)) + ((IsNull(ID.PTS,0) + (IsNull(ID.PTS,0) * IsNull(BP.TaxSuffered,0) /100)) * IsNull(@Margin,0) /100))
			end)
		Else
			(Case IsNull(BP.Taxtype,0)	
				When 1 then (IsNull(ID.PTS,0) + (((IsNull(BP.TaxSuffered,0))) * IsNull(@Margin,0) /100))
				When 2 then ((IsNull(ID.PTS,0) + IsNull(BP.TaxSuffered,0)) + ((IsNull(ID.PTS,0) + (IsNull(BP.TaxSuffered,0)) * IsNull(@Margin,0) /100)))
				When 3 then ((IsNull(ID.PTS,0) + IsNull(BP.TaxSuffered,0)) + ((IsNull(ID.PTS,0) + (IsNull(BP.TaxSuffered,0)) * IsNull(@Margin,0) /100)))
			end)
		End
		From InvoiceDetail ID,Batch_Products BP
		Where ID.InvoiceID = @InvoiceID
		And ID.Product_Code = @ItemCode
		And ID.Product_Code = BP.Product_Code
		And ID.Batch_Code = BP.Batch_Code
		And id.flagword = 1 And (id.Schemeid  = @SchID or id.SPLCATSCHEMEID = @SchID)

	End
	Return @PTR

End	

