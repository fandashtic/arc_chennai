CREATE Procedure mERP_sp_get_Bill_BatchInfo(@BillID Int)
As    
Begin
Declare @GRNIDs nVarChar(255)
Create Table #GRNTemp (GRNID Int)
Select @GRNIDs = GRNID from BillAbstract Where BillID = @BillID
Insert Into #GRNTemp Select * from dbo.sp_SplitIn2Rows(@GRNIDs,',')

Select 
"Code" = BP.Product_Code,
"Name" = I.ProductName,
"Qty" = Case IsNull(BP.Free,0) When 1 Then 0 Else QuantityReceived End,
"FreeQty" = Case IsNull(BP.Free,0) When 1 Then QuantityReceived Else 0 End,
"UOMID" = BP.UOM,
"OrgPTS" = Case IsNull(BP.Free,0) When 1 Then 0 Else BP.OrgPTS End,
"Batch" = BP.Batch_Number,
"Exp" = BP.Expiry,
"PKD" = BP.PKD,
"PTS" = Case IsNull(BP.Free,0) When 1 Then 0 Else BP.PTS End,
"PFM" = Case IsNull(BP.Free,0) When 1 Then 0 Else BP.PFM End,
"PTR" = Case IsNull(BP.Free,0) When 1 Then 0 Else BP.PTR End,
"ECP" = Case IsNull(BP.Free,0) When 1 Then 0 Else BP.ECP End,
"SplPrice" = 0,
"TaxSuffered" = Case IsNull(BP.Free,0) When 1 Then 0 Else GRNTaxSuffered End,
"TaxID" = Case IsNull(BP.Free,0) When 1 Then 0 Else GRNTaxID End,
"GRNApplicableOn" = Case IsNull(BP.Free,0) When 1 Then 0 Else GRNApplicableOn End,
"GRNPartOff" = Case IsNull(BP.Free,0) When 1 Then 0 Else GRNPartOff End,
"DiscPer" = Case IsNull(BP.Free,0) When 1 Then 0 Else IsNull((Select Max(DiscPer) From GRNDetail Where GRNID = BP.GRN_ID And Serial = BP.Serial),0) End,
"DiscPerUnit" = Case IsNull(BP.Free,0) When 1 Then 0 Else IsNull((Select Max(DiscPerUnit) From GRNDetail Where GRNID = BP.GRN_ID And Serial = BP.Serial),0) End,
"Batch_Code" = Batch_Code,
"GRNID"  = IsNull(BP.GRN_ID,0),
"GRNSERIAL" = BP.Serial,
"VAT" = IsNull(I.VAT,0),
"PriceOption" = ICA.Price_Option,
"TrackBatch" = I.Virtual_Track_Batches,
"TrackPKD" = I.TrackPKD,
"InvDiscPer" = Case IsNull(BP.Free,0) When 1 Then 0 Else IsNull((Select Max(InvDiscPer) From GRNDetail Where GRNID = BP.GRN_ID And Serial = BP.Serial),0) End,
"InvDiscPerUnit" = Case IsNull(BP.Free,0) When 1 Then 0 Else IsNull((Select Max(InvDiscPerUnit) From GRNDetail Where GRNID = BP.GRN_ID And Serial = BP.Serial),0) End,
"InvDiscAmt" = Case IsNull(BP.Free,0) When 1 Then 0 Else IsNull((Select Max(InvDiscAmt) From GRNDetail Where GRNID = BP.GRN_ID And Serial = BP.Serial),0) End,
"OtherDiscPer" = Case IsNull(BP.Free,0) When 1 Then 0 Else IsNull((Select Max(OtherDiscPer) From GRNDetail Where GRNID = BP.GRN_ID And Serial = BP.Serial),0) End,
"OtherDiscPerUnit" = Case IsNull(BP.Free,0) When 1 Then 0 Else IsNull((Select Max(OtherDiscPerUnit) From GRNDetail Where GRNID = BP.GRN_ID And Serial = BP.Serial),0) End,
"OtherDiscAmt" = Case IsNull(BP.Free,0) When 1 Then 0 Else IsNull((Select Max(OtherDiscAmt) From GRNDetail Where GRNID = BP.GRN_ID And Serial = BP.Serial),0) End,
"DiscType" = Case IsNull(BP.Free,0) When 1 Then 0 Else IsNull((Select Max(DiscType) From GRNDetail Where GRNID = BP.GRN_ID And Serial = BP.Serial),0) End
,"MRPPerPack" = BP.MRPPerPack
,"MRPForTax" = BP.MRPForTax
,"TOQ"=isnull(BP.TOQ,0)
From Batch_Products BP, Items I, ItemCategories ICA
Where IsNull(GRN_ID,0) In (Select GRNID from #GRNTemp)
And IsNull(DocType,0) = 0
And IsNull(QuantityReceived,0) > 0
And BP.Product_Code = I.Product_Code
And I.CategoryID = ICA.CategoryID
Order By Batch_Code

End
