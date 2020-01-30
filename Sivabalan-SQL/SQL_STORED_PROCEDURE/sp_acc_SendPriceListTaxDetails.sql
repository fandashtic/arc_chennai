CREATE Procedure sp_acc_SendPriceListTaxDetails(@DocumentID As Int)
As
/*Update Tax Master 1st*/
Update Tax Set LSTApplicableOn = 1 Where IsNULL(LSTApplicableOn, 0)= 0
Update Tax Set CSTApplicableOn = 1 Where IsNULL(CSTApplicableOn, 0)= 0
Update Tax Set LSTPartOff = 100 Where IsNULL(LSTPartOff, 0)= 0
Update Tax Set CSTPartOff = 100 Where IsNULL(CSTPartOff, 0)= 0
/*Tax Suffered*/
Select 'ID'=Tax_Code, 'Description'=Tax_Description, 'CST'=CST_Percentage, 
'ApplOnCST'=CSTApplicableOn, 'PartofCST'=CSTPartOff, 'LST'=Percentage, 
'ApplOnLST'=LSTApplicableOn, 'PartofLST'=LSTPartOff from Tax
Where Tax_Code In (Select Distinct IsNULL(TaxSuffered,0) from SendPriceListItem 
Where DocumentID = @DocumentID)
Union
/*Sales Tax*/
Select 'ID'=Tax_Code, 'Description'=Tax_Description, 'CST'=CST_Percentage, 
'ApplOnCST'=CSTApplicableOn, 'PartofCST'=CSTPartOff, 'LST'=Percentage, 
'ApplOnLST'=LSTApplicableOn, 'PartofLST'=LSTPartOff from Tax
Where Tax_Code In (Select Distinct IsNULL(TaxApplicable,0) from SendPriceListItem 
Where DocumentID = @DocumentID)


