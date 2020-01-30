CREATE Procedure sp_acc_Insert_ReceivedPriceListTaxDetails(@ReceiveDocID Int, @TaxCode Int, 
@Description nVarChar(255), @CST Decimal(18,6), @ApplOnCST Int, @PartOfCST Decimal(18,2), 
@LST Decimal(18,6), @ApplOnLST Int, @PartOfLST Decimal(18,2))
As
Insert Into ReceivePriceListTaxDetail(ReceiveDocID, TaxCode, Description, CSTPercentage, 
ApplicableOnCST, PartOfCST, LSTPercentage, ApplicableOnLST, PartOfLST)
Values (@ReceiveDocID, @TaxCode, @Description, @CST, @ApplOnCST, @PartOfCST, @LST, @ApplOnLST, @PartOfLST)


