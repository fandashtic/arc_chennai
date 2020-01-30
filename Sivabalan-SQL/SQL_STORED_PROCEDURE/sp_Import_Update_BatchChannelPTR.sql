CREATE PROCEDURE sp_Import_Update_BatchChannelPTR
(
@ItemCode nVarChar(30),
@BatchCode int,
@PFM Decimal(18,6),
@PFMWithTax Decimal(18,6),
@Date DateTime = Null
)
AS
Begin
Declare @MarginID int
Declare @MarginPercentage Decimal(18,6)
Declare @PTRWithMargin Decimal(18,6)
Declare @GSTFlag int
Declare @TaxType int
Declare @GSTTaxType int

Select @GSTFlag = isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'GSTaxEnabled'
IF @GSTFlag > 0
Begin
Set @TaxType = 5
Set @GSTTaxType = 1
End
Else
Begin
Set @TaxType = 1
Set @GSTTaxType = Null
End

Create Table #TmpPTRMargin(MarginPercentage Decimal(18,6), MarginID int)

Insert Into #TmpPTRMargin(MarginPercentage, MarginID)
Exec mERP_sp_get_PTRMargin @ItemCode, @Date
--Exec mERP_sp_get_PTRMargin '215', @Date

Select @MarginID = MarginID, @MarginPercentage = MarginPercentage From #TmpPTRMargin
Set @PTRWithMargin = IsNull(@PFM,0) + IsNull(@PFMWithTax,0) * IsNull(@MarginPercentage,0)/100

If IsNull(@BatchCode,0) > 0
Begin
Update Batch_Products Set PTR = @PTRWithMargin, MarginDetID = @MarginID, MarginPerc = @MarginPercentage,
MarginOn = @PFMWithTax, MarginAddOn = @PFM, TaxType = @TaxType, GSTTaxType = @GSTTaxType Where Batch_Code = @BatchCode

Insert Into BatchWiseChannelPTR (Batch_Code, ChannelMarginID, ChannelTypeCode, RegisterStatus, ChannelPTR)
Select @BatchCode, ID, ChannelTypeCode, RegFlag, "ChannelPTR" = IsNull(@PFM,0) + IsNull(@PFMWithTax,0) * IsNull(MarginPerc,0)/100
From tbl_mERP_ChannelMarginDetail Where MarginDetID =  IsNull(@MarginID,0)
End

Select IsNull(@PTRWithMargin,0)

Drop Table #TmpPTRMargin
End
