CREATE PROCEDURE [sp_insert_RetailPaymentDetails]    
 (@RetailInvoiceID  int,    
  @AmountReceived  decimal(18,6),    
  @AmountReturned  decimal(18,6),    
  @CustomerServicePerc decimal(18,6),    
  @CustomerServiceCharge decimal(18,6),    
  @CollectionID int,    
  @NetRecieved  decimal(18,6),    
  @PaymentMode int,
  @PaymentDetails nvarchar(3000)=N'')    
    
AS INSERT INTO RetailPaymentDetails     
  ([RetailInvoiceID],    
  [AmountReceived],    
  [AmountReturned],    
  [CustomerServicePerc],    
  [CustomerServiceCharge],    
  [CollectionID],    
  [NetRecieved],    
  [PaymentMode],[PaymentDetails])     
     
VALUES     
 ( @RetailInvoiceID,    
  @AmountReceived,    
  @AmountReturned,    
  @CustomerServicePerc,    
  @CustomerServiceCharge,    
  @CollectionID,    
  @NetRecieved,    
  @PaymentMode,@PaymentDetails)    
  



