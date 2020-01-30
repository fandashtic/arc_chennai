CREATE procedure [dbo].[spr_list_Invoicewise_Collection_Detail_Cons]    
(    
@InvoiceID NVarChar(255),    
@unused1 Nvarchar(4000),    
@Fromdate Datetime,    
@Todate Datetime    
)              
As          
      
Declare @CASH As NVarchar(50)          
Declare @CHEQUE As NVarchar(50)          
Declare @DD As NVarchar(50)          
Declare @CREDITCARD As NVarchar(50)          
Declare @COUPON As NVarchar(50)          
Declare @CREDITNOTE As NVarchar(50)          
Declare @GIFTVOUCHER As NVarchar(50)          
Declare @ComIDReport NVarchar(50)        
Declare @ComIDSetup NVarchar(50)        
      
Set @CASH = dbo.LookupDictionaryItem(N'Cash', Default)          
Set @CHEQUE = dbo.LookupDictionaryItem(N'Cheque', Default)          
Set @DD = dbo.LookupDictionaryItem(N'DD', Default)          
Set @CREDITCARD = dbo.LookupDictionaryItem(N'Credit Card', Default)          
Set @COUPON = dbo.LookupDictionaryItem(N'Coupon', Default)          
Set @CREDITNOTE = dbo.LookupDictionaryItem(N'Credit Note', Default)          
Set @GIFTVOUCHER = dbo.LookupDictionaryItem(N'Gift Voucher', Default)         
       
Select @ComIDSetup = RegisteredOwner From Setup         
Select @ComIDReport = Right(@InvoiceID,Len(@ComIDSetup))        
      
 If @ComIDReport = @ComIDSetup         
  Begin          
   Select @InvoiceID = Left(@InvoiceID,Len(@InvoiceID)-Len(@ComIDSetup))        
   Select       
    Cast(Collections.DocumentID As NVarChar),       
    "Collection ID" = Cast(Collections.FullDocID As NVarChar),      
    "Doc Ref" = Cast(DocReference As NVarChar),       
    "Date" = Cast(Collections.DocumentDate As NVarChar),       
    "Salesman" = Cast(Salesman.Salesman_Name As NVarChar),              
    "Value (%c)" = Cast(CollectionDetail.AdjustedAmount As NVarChar),       
    "Payment Mode" =Cast(       
     (Case PaymentMode             
      When 0 Then @CASH              
      When 1 Then @CHEQUE              
      When 2 Then @DD              
      When 3 Then @CREDITCARD              
      When 5 Then @COUPON               
      When 6 Then @CREDITNOTE          
      When 7 Then @GIFTVOUCHER          
     End) As NVarChar)              
   From       
    Collections, CollectionDetail, Salesman              
   Where       
    Collections.DocumentID = CollectionDetail.CollectionID And              
    Collections.SalesmanID *= Salesman.SalesmanID And             
    IsNull(Collections.Status, 0) & 128 = 0 And              
    CollectionDetail.DocumentID = Cast(@InvoiceID As Int) And              
    CollectionDetail.DocumentType In (1, 2, 4, 6, 7) And               
    Collections.CustomerID Is Not Null              
  End        
 Else        
  Begin        
   Select         
    '',"Collection ID" = RDR.Field1,"Doc Ref" = RDR.Field2,"Date" = RDR.Field3,        
    "Salesman" =RDR.Field4,"Value (%c)"=RDR.Field5,"Payment Mode" = RDR.Field6        
   From       
    ReportDetailReceived RDR,Reports    
   Where         
    RDR.RecordID = Cast(@InvoiceID As Int)     
    And Reports.ReportID In (Select Max(ReportID) From Reports Where ReportName = (N'Collections - Invoicewise')      
    And ParameterID In (Select ParameterID From dbo.GetReportParameters_INV_DAILY(N'Collections - Invoicewise') Where FromDate = dbo.StripDateFromTime(@Fromdate) And ToDate = dbo.StripDateFromTime(@TODate)))        
    And RDR.Field1 Not Like  N'Collection I%'    
    And RDR.Field1 <> N'SubTotal:'    
    And RDR.Field1 <> N'GrandTotal:'
	And RDR.Field1 <> N'InvoiceID'       
  End
