CREATE PROCEDURE sp_get_bookstock_return_BatchSelect(@PRODUCT_CODE nvarchar(15),
@TRACK_BATCH int,
@CAPTURE_PRICE int,
@CUSTOMER_TYPE int,
@CustomerID nvarchar(15) = '',
@InvoiceId int = 0,
@SerialNo int = 0)
AS

Declare @ChannelTypeCode nvarchar(15)
Declare @RegisterStatus int

Select @RegisterStatus = Case When isnull(IsRegistered,0) = 0 Then 1 Else 2 End From Customer Where CustomerID = @CustomerID

Select Top 1 @ChannelTypeCode = Channel_Type_Code From tbl_mERP_OLClassMapping OLMap
Inner Join tbl_mERP_OLClass OLClass ON OLMap.OLClassID = OLClass.ID
Where OLMap.CustomerID = @CustomerID and isnull(OLMap.Active,0) = 1

Select BP.*, Case When isnull(C.ChannelPTR, 0) = 0 Then BP.PTR Else C.ChannelPTR End 'ChannelPTR'
Into #TmpBatchChannelPTR From Batch_Products BP
Left Join BatchWiseChannelPTR C ON BP.Batch_Code = C.Batch_Code
and C.ChannelTypeCode = @ChannelTypeCode and isnull(C.RegisterStatus,0) & @RegisterStatus <> 0
Where BP.Product_Code= @PRODUCT_CODE And ISNULL(BP.Damage, 0) = 0


Create Table #TmpInvBatch (Batch_Code int)

IF Exists(Select 'x' From InvoiceAbstract Where InvoiceID = @InvoiceID and isnull(Status,0) & 16 <> 0)
Insert Into #TmpInvBatch(Batch_Code)
Select VD.Batch_Code From InvoiceDetail ID
Inner Join VanStatementDetail VD ON ID.Batch_Code = VD.ID and ID.Product_Code = VD.Product_Code
Where ID.InvoiceID = @InvoiceId and ID.Product_Code = @PRODUCT_CODE
and ID.Serial = @SerialNo
Else
Insert Into #TmpInvBatch(Batch_Code)
Select Batch_Code From InvoiceDetail where InvoiceID = @InvoiceId and Product_Code = @PRODUCT_CODE
and Serial = @SerialNo

IF @TRACK_BATCH = 1
BEGIN
IF @CUSTOMER_TYPE = 1
BEGIN
Select Batch_Number, Expiry, SUM(Quantity), PTS, PKD,
isnull(Free, 0), IsNull(TaxSuffered, 0) ,isnull(ecp , 0) , IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),
Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),Isnull(MRPPerPack,0), Tax.Tax_Description
From Batch_Products Batch_Products Join #TmpInvBatch InvBP On Batch_Products.batch_code = InvBP.batch_code
Left Join Tax ON BP.GRNTaxID = Tax.Tax_Code
where Product_Code= @PRODUCT_CODE And ISNULL(Damage, 0) = 0
Group By Batch_Number, Expiry, PTS, PKD, isnull(Free, 0) ,isnull(ecp , 0),IsNull(TaxSuffered, 0),
Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),Isnull(MRPPerPack,0),isnull(GRNTaxID,0),Tax.Tax_Description
Order By Isnull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Products.Batch_Code)
END
ELSE IF @CUSTOMER_TYPE = 2
BEGIN
Select Batch_Number, Expiry, SUM(Quantity), ChannelPTR PTR, PKD,
isnull(Free, 0), IsNull(TaxSuffered, 0) ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),
Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),Isnull(MRPPerPack,0), Tax.Tax_Description
From #TmpBatchChannelPTR Batch_Products Join #TmpInvBatch InvBP On Batch_Products.batch_code = InvBP.batch_code
Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code
where Product_Code= @PRODUCT_CODE And ISNULL(Damage, 0) = 0
Group By Batch_Number, Expiry, PTR, PKD, isnull(Free, 0)  ,isnull(ecp , 0), IsNull(TaxSuffered, 0),
Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),Isnull(MRPPerPack,0),isnull(GRNTaxID,0),Tax.Tax_Description, ChannelPTR
Order By Isnull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Products.Batch_Code)
END
ELSE IF @CUSTOMER_TYPE = 3
BEGIN
Select Batch_Number, Expiry, SUM(Quantity), Company_Price, PKD,
isnull(Free, 0), IsNull(TaxSuffered, 0) ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),
Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),Isnull(MRPPerPack,0), Tax.Tax_Description
From Batch_Products Join #TmpInvBatch InvBP On Batch_Products.batch_code = InvBP.batch_code
Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code
where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0
Group By Batch_Number, Expiry, Company_Price, PKD, isnull(Free, 0) ,isnull(ecp , 0), IsNull(TaxSuffered, 0),
Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),Isnull(MRPPerPack,0),isnull(GRNTaxID,0),Tax.Tax_Description
Order By Isnull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Products.Batch_Code)
END
ELSE IF @CUSTOMER_TYPE = 4
BEGIN
Select Batch_Number, Expiry, SUM(Quantity), ECP, PKD,
isnull(Free, 0), IsNull(TaxSuffered, 0) ,isnull(ecp , 0) , IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),
Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),Isnull(MRPPerPack,0), Tax.Tax_Description
From Batch_Products Join #TmpInvBatch InvBP On Batch_Products.batch_code = InvBP.batch_code
Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code
where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0
and  Batch_Products.Batch_Code in (Select distinct Batch_Code from #TmpInvBatch)
Group By Batch_Number, Expiry, ECP, PKD, isnull(Free, 0), IsNull(TaxSuffered, 0),
Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),Isnull(MRPPerPack,0),isnull(GRNTaxID,0),Tax.Tax_Description
Order By Isnull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Products.Batch_Code)
END
END
ELSE
BEGIN
IF @CUSTOMER_TYPE = 1
BEGIN
Select N'', '', SUM(Quantity), PTS, PKD, isnull(Free, 0),
IsNull(TaxSuffered, 0) ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),
Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),Isnull(MRPPerPack,0), Tax.Tax_Description
From Batch_Products Join #TmpInvBatch InvBP On Batch_Products.batch_code = InvBP.batch_code
Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code
where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0
Group By PTS, PKD, isnull(Free, 0)  ,isnull(ecp , 0), IsNull(TaxSuffered, 0),
Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),Isnull(MRPPerPack,0),isnull(GRNTaxID,0),Tax.Tax_Description
Order By Isnull(Free, 0), PKD, MIN(Batch_Products.Batch_Code)
END
ELSE IF @CUSTOMER_TYPE = 2
BEGIN
Select N'', '', SUM(Quantity), ChannelPTR PTR, PKD, isnull(Free, 0),
IsNull(TaxSuffered, 0) ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),
Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),Isnull(MRPPerPack,0), Tax.Tax_Description
From #TmpBatchChannelPTR Batch_Products Join #TmpInvBatch InvBP On Batch_Products.batch_code = InvBP.batch_code
Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code
where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0
Group By PTR, PKD, isnull(Free, 0)  ,isnull(ecp , 0), IsNull(TaxSuffered, 0),
Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),Isnull(MRPPerPack,0),isnull(GRNTaxID,0),Tax.Tax_Description, ChannelPTR
Order By Isnull(Free, 0), PKD, MIN(Batch_Products.Batch_Code)
END
ELSE IF @CUSTOMER_TYPE = 3
BEGIN
Select N'', '', SUM(Quantity), Company_Price, PKD, isnull(Free, 0),
IsNull(TaxSuffered, 0) ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),
Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),Isnull(MRPPerPack,0), Tax.Tax_Description
From Batch_Products Join #TmpInvBatch InvBP On Batch_Products.batch_code = InvBP.batch_code
Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code
where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0
Group By Company_Price, PKD, isnull(Free, 0)  ,isnull(ecp , 0), IsNull(TaxSuffered, 0),
Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),Isnull(MRPPerPack,0),isnull(GRNTaxID,0),Tax.Tax_Description
Order By Isnull(Free, 0), PKD, MIN(Batch_Products.Batch_Code)
END
ELSE IF @CUSTOMER_TYPE = 4
BEGIN
Select N'', '', SUM(Quantity), ECP, PKD, isnull(Free, 0),
IsNull(TaxSuffered, 0) ,isnull(ecp , 0), IsNull(Max(PTS),0) ,IsNull(Max(PTR),0),IsNull(Max(Company_Price),0),
Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),Isnull(MRPPerPack,0), Tax.Tax_Description
From Batch_Products Join #TmpInvBatch InvBP On Batch_Products.batch_code = InvBP.batch_code
Left Join Tax ON Batch_Products.GRNTaxID = Tax.Tax_Code
where Product_Code= @PRODUCT_CODE AND ISNULL(Damage, 0) = 0
and  Batch_Products.Batch_Code in (Select distinct Batch_Code from #TmpInvBatch)
Group By ECP, PKD, isnull(Free, 0), IsNull(TaxSuffered, 0),
Isnull(ApplicableOn,0), Isnull(Partofpercentage,0),Isnull(MRPPerPack,0),isnull(GRNTaxID,0),Tax.Tax_Description
Order By Isnull(Free, 0), PKD, MIN(Batch_Products.Batch_Code)
END
END

Drop Table #TmpBatchChannelPTR
Drop table #TmpInvBatch

