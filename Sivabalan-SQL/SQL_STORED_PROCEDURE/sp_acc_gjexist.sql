CREATE Procedure sp_acc_gjexist
As
Declare @Flag INT
Set IMPLICIT_TRANSACTIONS OFF
/* check whether the journal entries are made for existing transactions */
Select @Flag=isnull(Flag,0) from Setup
If @Flag=0
Begin

/* Procedure to upgrade the database for FinancialAccounts for the existing clients */
If Not Exists (Select Id From sysobjects Where Name =  'TempImplicitCollection' and Type = 'U')
Begin
	Create Table TempImplicitCollection(ColDocumentID Int) --store the implicit collection document in from invoice table to avoid posting of journal in collections
End
If Not Exists (Select Id From sysobjects Where Name =  'TempOpeningDetails' and Type = 'U')
Begin
	Create Table TempOpeningDetails(AccountID Int,Amount Decimal(18,6),Type Int) --stores all the pending documents details
End

Execute sp_acc_gjexist_updateaccount /*Insert customer,vendor,bank,branch office to the accountmaster & update defauld AccountID to the DebitNote & CreditNote tables */
Execute sp_acc_gjexist_GRN /* GRN transactions */
Execute sp_acc_gjexist_dispatch /* Dispatch transactions */
Execute sp_acc_gjexist_invoice /* Invoice dependent transactions */
Execute sp_acc_gjexist_bill /* Bill dependent transactions */
Execute sp_acc_gjexist_purchasereturn /* Purchase return dependent transactions */
Execute sp_acc_gjexist_collections /* Collection dependent transactions */
Execute sp_acc_gjexist_Payments /* Payment dependent transactions */
Execute sp_acc_gjexist_others /* CreditNote,DebitNote for both customer/Vendor and ClaimesNote transactions */
Execute sp_acc_gjexist_StockTransferIn 
Execute sp_acc_gjexist_StockTransferOut
Execute sp_acc_gjexist_updateaccountsmasteropening
--Execute sp_acc_gjexist_Claims --dont want

Drop Table TempImplicitCollection
Drop Table TempOpeningDetails
/* After journal entries are made for the existing transactions update flag of the setup table  */
update Setup set flag=(isnull(Flag,0) | 1)
End
Set IMPLICIT_TRANSACTIONS ON

