CREATE procedure mERP_sp_get_HHSRDet
(
@ReturnNumber nVarChar(100),
@nFlag Int,
@CatGrpID nVarchar(1000))
As

Create table #temp(GrpID int)
Insert Into #temp
Select * from dbo.sp_splitin2Rows(@CatGrpID, ',')

Select
"ProductCode" = SR.Product_Code,
"Quantity" = Sum(SR.Quantity),
"UOM" = SR.UOM,
--"Price" = SR.Price,
"Reason" = (Select Reason_Description From ReasonMaster 
Where Reason_Type_ID = SR.Reason And Reason_SubType = SR.ReturnType),
"ProductName" = Max(I.ProductName),
"Track_Batches" = Max(I.Track_Batches),
"TrackPKD" = Max(I.TrackPKD),
"Price_Option" = Max(IC.Price_Option),
"Track_Inventory" = Max(IC.Track_Inventory),
"IPTS" = ISNULL(Max(I.PTS), 0),
"IPTR" = ISNULL(Max(I.PTR), 0),
"IECP" = ISNULL(Max(I.ECP), 0),
"ICompany_Price" = ISNULL(Max(I.Company_Price), 0),
"IAdhocAmount" = ISNULL(Max(I.AdhocAmount), 0),
"VAT" = Max(I.VAT),
"CollectTaxSuffered" = Max(I.CollectTaxSuffered)
From Stock_Return SR, Items I, ItemCategories IC
WHERE SR.ReturnNumber = @ReturnNumber 
And SR.ReturnType = @nFlag
-- And SR.CategoryGroupID = @CatGrpID
And SR.CategoryGroupID In (Select GrpID from #temp)
AND SR.Product_Code = I.Product_Code
AND I.CategoryID = IC.CategoryID
Group By SR.Product_Code, SR.UOM, SR.Reason, SR.ReturnType

Drop table #temp

