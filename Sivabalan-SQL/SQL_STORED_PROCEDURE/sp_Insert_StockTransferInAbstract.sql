
CREATE Procedure sp_Insert_StockTransferInAbstract (  
 @DocumentDate datetime,      
 @WareHouseID nvarchar(50),      
 @NetValue Decimal(18,6),      
 @DocReference nvarchar(255),      
 @ReferenceSerial nvarchar(255),      
 @UserName nvarchar(255),      
 @TaxAmount Decimal(18,6),@skip int=-128,@TaxOnMRP Int = 0 ,@VatTaxAmount Decimal(18,6) = 0,  
 @Sti_lr_no NVarchar(100)=N'', @Sti_tran_info NVarchar(100)=N'', @Sti_narration NVarchar(100)=N'', @Sti_Rec_date DateTime=N'',
 @Taxtype int = 0
,@GSTFlag Int = 0, @FromStateCode Int = 0, @ToStateCode Int = 0 , @GSTIN nVarChar(15) = ''
 )       
As      

Declare @StateType Int
IF @GSTFlag = 1
Begin
Set @StateType = @Taxtype
Set @Taxtype = 0
End
 
Declare @DocID int      
Declare @DocPrefix nvarchar(50)      
if @Sti_Rec_date=N''  
 Set @Sti_Rec_date=GetDate()  
if(@skip=-128)    
Begin      
Begin Tran      
Update DocumentNumbers Set DocumentID = DocumentID + 1 Where DocType = 16      
Select @DocID = DocumentID - 1 From DocumentNumbers Where DocType = 16      
Commit Tran      
End    
Else    
Begin    
Select @DocID=DocumentId from StockTransferInabstract where DocSerial=@Skip    
End    
Select @DocPrefix = Prefix From VoucherPrefix Where TranID = 'STOCK TRANSFER IN'      
Insert into StockTransferInAbstract(DocumentID,      
 DocumentDate,      
 WareHouseID,      
 NetValue,      
 Status,      
 DocReference,      
 ReferenceSerial,      
 DocPrefix,      
 UserName,      
 TaxAmount,TaxOnMRP,VatTaxAmount,  
 Sti_lr_no, Sti_tran_info, Sti_narration, Sti_Rec_date, Taxtype
,GSTFlag, StateType, FromStatecode, ToStatecode ,GSTIN
 )      
Values(@DocID,      
 @DocumentDate,      
 @WareHouseID,      
 @NetValue,      
 0,      
 @DocReference,      
 @ReferenceSerial,      
 @DocPrefix,      
 @UserName,      
 @TaxAmount,@TaxOnMRP,@VatTaxAmount,  
 @Sti_lr_no, @Sti_tran_info, @Sti_narration, @Sti_Rec_date, @Taxtype
,@GSTFlag ,@StateType , @FromStateCode , @ToStateCode , @GSTIN 
 )      
Select @@Identity, @DocID      
  
