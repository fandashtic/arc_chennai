
Create Procedure sp_Insert_StockTransferOutAbstract( 
	@WareHouseID nvarchar(50),    
	@StkDate datetime,    
	@NetValue Decimal(18,6),    
	@Address nvarchar(255),    
	@UserName nvarchar(50),    
	@Reference nvarchar(255),    
	@DocPrefix nvarchar(50),    
	@TaxAmount Decimal(18,6),    
	@Status int,   
	@Skip int=-128,  
	@Taxonmrp Decimal(18,6) = 0,@VatTaxAmount Decimal(18,6) = 0,
	@Sto_lr_no NVarchar(100)=N'', @Sto_tran_info NVarchar(100)=N'', @Sto_narration NVarchar(100)=N'')    
As    
Declare @DocID int   
Declare @GSTFlag int
Select @GSTFlag = isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'GSTaxEnabled' 

if @skip=-128  
begin  
Begin Tran    
Update DocumentNumbers Set DocumentID = DocumentID + 1 Where DocType = 15    
Select @DocID = DocumentID - 1 From DocumentNumbers Where DocType = 15    
Commit Tran    
end  
else  
begin  
select @DocId=DocumentId from stocktransferoutabstract where DocSerial=@Skip  
end  
Insert into StockTransferOutAbstract( 
	DocumentID,    
	DocumentDate,    
	WareHouseID,    
	NetValue,    
	Status,    
	Address,    
	UserName,    
	Reference,    
	DocPrefix,    
	TaxAmount,  
	TaxOnMRP,VatTaxAmount,
	Sto_lr_no, Sto_tran_info, Sto_narration,GSTFlag)    
Values(     
	@DocID,    
	@StkDate,    
	@WareHouseID,    
	@NetValue,    
	@Status,    
	@Address,    
	@UserName,    
	@Reference,    
	@DocPrefix,    
	@TaxAmount,  
	@TaxOnMRP,@VatTaxAmount,
	@Sto_lr_no, @Sto_tran_info, @Sto_narration,@GSTFlag)    
Select @@Identity, @DocID    
  
