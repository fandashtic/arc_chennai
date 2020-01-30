CREATE Procedure sp_Update_TransactionSerial            
(@TranType int,@DocType nVarchar(100),@IDNO int,@VoucherPrefix nVarchar(100),@IsSerial int=0)            
As            
Declare @LastCount int            
Declare @TranSerial nvarchar(100)            
            
IF (@IsSerial=1)            
Begin            
BEGIN TRAN            
  UPDATE TransactionDocNumber SET LastCount = LastCount + 1 WHERE TransactionType = @Trantype And DocumentType=@DOCTYPE            
  SELECT @LastCount = LastCount - 1 FROM TransactionDocNumber WHERE TransactionType = @Trantype And DocumentType=@DOCTYPE            
COMMIT TRAN            
End            
            
-- IF IsSerial=1 then New Serial Number has to be Generated else passed id has to be set            
-- Since It is Common for all Moved here            
if (@IsSerial=1)            
 Select @TranSerial=dbo.fn_GetTransactionSerial(@TranType,@DocType,@LastCount)             
Else             
 Select @TranSerial=@VoucherPrefix            
            
            
--Invoice------------------------------------            
If (@TranType=1)            
begin             
If IsNull(@IsSerial,0) = 0 And (Select IsNull(InvoiceType,0) From InvoiceAbstract Where InvoiceID=@IDNO) = 1
	Update InvoiceAbstract Set DocReference=GSTFullDocID ,DocSerialType='' Where InvoiceID=@IDNO And InvoiceType = 1
Else
	Update InvoiceAbstract Set DocReference=@TranSerial,DocSerialType=@DocType Where InvoiceID=@IDNO And InvoiceType in (1,3)            
End            
            
------Retail Invoice-------------------------            
Else If (@TranType=2)            
Begin
If IsNull(@IsSerial,0) = 0 
 Update InvoiceAbstract Set DocReference=GSTFullDocID ,DocSerialType='' Where InvoiceID=@IDNO And InvoiceType=2            
Else
 Update InvoiceAbstract Set DocReference=@TranSerial,DocSerialType=@DocType Where InvoiceID=@IDNO And InvoiceType=2            
End            
            
------Sales Return---------------------------            
Else If (@TranType=3)            
begin            
If IsNull(@IsSerial,0) = 0 
 Update InvoiceAbstract Set DocReference=GSTFullDocID ,DocSerialType='' Where InvoiceID=@IDNO And InvoiceType=4            
Else
 Update InvoiceAbstract Set DocReference=@TranSerial,DocSerialType=@DocType Where InvoiceID=@IDNO And InvoiceType=4            
End            
            
------Sales Confirmation--------------------            
Else If (@TranType=4)            
begin             
 Update SOAbstract Set DocumentReference=@TranSerial,DocSerialType=@DocType Where SoNumber=@IDNO            
End            
            
------Dispatch Note-----------------------            
Else If (@TranType=5)            
begin            
 Update DispatchAbstract Set DocRef=@TranSerial,DocSerialType=@DocType Where DispatchID=@IDNO            
End            
            
------Purchase Return-----------------------            
Else If (@TranType=6)            
begin            
 Update AdjustmentReturnAbstract Set Reference=@TranSerial,DocSerialType=@DocType Where AdjustmentID=@IDNO            
End            
            
------GRN-----------------------            
Else If (@TranType=7)            
begin            
 Update GRNAbstract Set DocumentReference=@TranSerial,DocSerialType=@DocType Where GRNID=@IDNO            
End            
            
------Bill-----------------------            
Else If (@TranType=8)            
begin            
 Update BillAbstract Set DocIDReference=@TranSerial,DocSerialType=@DocType Where BillID=@IDNO            
End            
            
------Credit Note-----------------------            
Else If (@TranType=9)            
begin            
 Update CreditNote Set DocumentReference=@TranSerial,DocSerialType=@DocType Where CreditID=@IDNO            
End            
            
------Debit Note-----------------------            
Else If (@TranType=10)            
begin            
 Update DebitNote Set DocumentReference=@TranSerial,DocSerialType=@DocType Where DebitID=@IDNO            
End            
            
------Collections-----------------------            
Else If (@TranType=11)            
begin            
 Update Collections Set DocumentReference=@TranSerial,DocSerialType=@DocType Where DocumentID=@IDNO            
End            
            
------Payments-----------------------            
Else If (@TranType=12)            
begin            
 Update Payments Set DocumentReference=@TranSerial,DocSerialType=@DocType Where DocumentID=@IDNO            
End            
            
-----Physical Stock Reconciliation-------------            
            
Else If (@TranType=13)            
begin            
 Update ReconcileAbstract Set DocumentReference=@TranSerial,DocSerialType=@DocType Where ReconcileID=@IDNO            
End            
--------Van Stock Transfer-------------------            
Else If (@TranType=14)            
begin            
 Update VanTransferAbstract set DocumentReference=@TranSerial,DocSerialType=@DocType where DocSerial=@IDNO            
end            
       
------STOCK OUT-----------------------              
Else If (@TranType=15)              
begin              
 Update StockOutAbstract Set DocumentType=@DocType Where StockOutID=@IDNO              
End              
            
------Customer Point Redemption-----------            
Else If (@TranType=16)              
begin              
 Update RedemptionAbstract Set DocumentReference=@TranSerial,DocumentType=@DocType Where DocSerial=@IDNO              
End              
          
------RetailInvoice SalesReturn-------------          
Else If (@TranType=17)            
begin            
 Update InvoiceAbstract Set DocReference=@TranSerial,DocSerialType=@DocType Where InvoiceID=@IDNO And InvoiceType in(5,6)            
End            
      
--wcp--      
Else If (@TranType=58)          
begin          
 Update WcpAbstract set docRef=@transerial,DocSeriesType=@doctype where code=@IDNO       
End      
        
------Sales Visit-------------          
Else If (@TranType=59)            
begin             
 Update SVAbstract Set DocumentReference=@TranSerial,DocSerialType=@DocType Where SVNumber=@IDNO            
End            
      
-----Invoicewise Collections----------------      
Else If (@TranType=60)          
begin          
 Update InvoiceWiseCollectionAbstract Set DocReference=@TranSerial,DocSerialType=@DocType Where DocumentID=@IDNO          
End          
      
Select @TranSerial            
