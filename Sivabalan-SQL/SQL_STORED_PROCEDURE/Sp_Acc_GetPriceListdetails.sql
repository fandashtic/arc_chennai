CREATE procedure Sp_Acc_GetPriceListdetails (@DetailsReqd Int,@PriceListID Int)
as
/*
	@DetailsReqd = 0 - General Information
	@DetailsReqd = 1 - Customer / Branch Details
	@DetailsReqd = 2 - Itemdetails
*/
If @DetailsReqd = 0 
Begin
	Select Description,PriceListFor,Active from PRICELIST
	Where PriceListID = @PriceListID
End
Else If @DetailsReqd = 1
Begin
	if (Select PriceListFor from PRICELIST Where PriceListID = @PriceListID) = 0
	Begin
		Select PLB.BranchID,C.Company_Name as Branch_Name from 
		PRICELISTBRANCH PLB,Customer C
		Where PLB.BranchID = C.CustomerID
		and PLB.PriceListID = @PriceListID
	End
	Else
	Begin
		Select PLB.BranchID,W.Warehouse_Name as Branch_Name from 
		PRICELISTBRANCH PLB,Warehouse W
		Where PLB.BranchID = W.WarehouseID
		and PLB.PriceListID = @PriceListID
	End
End
Else If @DetailsReqd = 2
Begin

	Select PLI.Product_Code,I.ProductName,
	isnull((Select Tax_Description from Tax where Tax_Code = PLI.TaxSuffered),'') as 'Tax_Suffered',
	isnull((Select Tax_Description from Tax where Tax_Code = PLI.TaxApplicable),'') as 'Tax_Applicable'
	From PriceListItem PLI,Items I
	where 
	PLI.PriceListID = @PriceListID
	and PLI.Product_Code = I.Product_Code

-- -- 
-- -- 
-- -- 	Select PLI.Product_Code,I.ProductName,
-- -- 	Case
-- -- 		When PLI.TaxSuffered <> 0 then T.Tax_description
-- -- 		Else ''
-- -- 	End as 'Tax Suffered',
-- -- 	Case
-- -- 		When PLI.TaxApplicable <> 0 then T.Tax_description
-- -- 		Else ''
-- -- 	End as 'Tax Applicable'
-- -- 	From PriceListItem PLI,Tax T,Items I
-- -- 	where 
-- -- 	PLI.PriceListID = @PriceListID
-- -- 	and PLI.TaxSuffered = T.Tax_Code
-- -- 	And PLI.TaxApplicable = T.Tax_Code
-- -- 	and PLI.Product_Code = I.Product_Code
End




