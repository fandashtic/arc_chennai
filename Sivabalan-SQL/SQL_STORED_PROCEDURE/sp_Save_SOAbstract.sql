CREATE Procedure sp_Save_SOAbstract  
(  
 @SODate DateTime,@DeliveryDate DateTime,@CustomerID NVarChar (15),@Value Decimal(18,6),  
 @POReference NVarChar(255),@BillAddress NVarChar(255),@ShipAddress NVarChar(255),  
 @Status Int,@CreditTerm Int,@PODocReference NVarChar(255),@IsAmEnd Int = 0,@SORef Int = 0,  
 @SalesmanID Int = 0,@BeatID Int = 0,@IsSIDFromDB Int = -1,@VATTaxAmount Decimal(18,6) = 0,  
 @GroupID Int = NULL  
)  
AS  
DECLARE @DocumentID Int  
Declare @FromStateCode int
Declare @ToStateCode int
Declare @GSTIN nvarchar(30)
Declare @GSTFlag int

Select Top 1 @FromStateCode = isnull(ShippingStateID,0) From Setup
Select @ToStateCode = isnull(BillingStateID,0), @GSTIN = GSTIN From Customer Where CustomerID = @CUSTOMERID
  
If @IsSIDFromDB = -1  
Begin  
	Select @SalesmanID = ISNULL((Select SalesmanID From Beat_Salesman Where CustomerID = @CustomerID), 0)  
End  

Select @GSTFlag = isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'GSTaxEnabled'

  
If (@IsAmEnd=0)  
Begin  
 Begin Tran  
 Update DocumentNumbers SET DocumentID = DocumentID + 1 Where DocType = 2  
 Select @DocumentID = DocumentID - 1 From DocumentNumbers Where DocType = 2  
 Commit Tran  
End  
Else  
Begin  
 Select @DocumentID=DocumentID From SoAbstract Where SoNumber=@SORef  
End  
  
Insert Into SOAbstract  
(  
 SODate,DeliveryDate,CustomerID,Value,POReference,BillingAddress,ShippingAddress,Status,    
 CreditTerm,DocumentID,PODocReference,SalesmanID,SoRef,BeatID,VatTaxAmount,GroupID,FromStateCode,ToStateCode,GSTIN,GSTFlag 
)  
Values    
(  
 @SODate,@DeliveryDate,@CustomerID,@Value,@POReference,@BillAddress,@ShipAddress,@Status,    
 @CreditTerm,@DocumentID,@PODocReference,@SalesmanID,@SORef,@BeatID,@VATTaxAmount,@GroupID,@FromStateCode,@ToStateCode,@GSTIN,@GSTFlag
)  
  
Select @@Identity, @DocumentID  

