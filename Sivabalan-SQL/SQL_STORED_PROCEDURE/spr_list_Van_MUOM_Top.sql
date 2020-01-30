CREATE PROCEDURE [dbo].[spr_list_Van_MUOM_Top]( @Van nvarchar(100),
                                     @Salesman nvarchar(100),    @VanDate datetime )                 AS     
      DECLARE @INV AS NVARCHAR(50)                 DECLARE @CASH AS NVARCHAR(50)     DECLARE @CREDIT AS NVARCHAR(50)    
             DECLARE @CHEQUE AS NVARCHAR(50)     DECLARE @DD AS NVARCHAR(50)     
SELECT @CASH = DBO.LookUpDictionaryItem(N'Cash',default)    
 SELECT @CREDIT = DBO.LookUpDictionaryItem(N'Credit',default)   
  SELECT @CHEQUE = DBO.LookUpDictionaryItem(N'Cheque',default)     
SELECT @DD = DBO.LookUpDictionaryItem(N'DD',default)     
SELECT VanStatementAbstract.DocumentID,"DocID"=Convert(varchar(25),VanStatementAbstract.DocSerial),  
 "VanID"= RTRIM(VanStatementAbstract.VanID),"Salesman" = Salesman.Salesman_Name ,    
"Date" = Convert(Char(10),VanStatementAbstract.DocumentDate,3) into #RSV   From VanStatementAbstract, Salesman   
Where 
--VanStatementAbstract.VanID like @Van And   
VanStatementAbstract.SalesmanID IN(Select SalesmanID From Salesman where Salesman_Name like @Salesman)
--And   
--VanStatementAbstract.SalesmanID = Salesman.SalesmanID   
Select * into #tem From #RSV where #RSV.VanID like @Van and #RSV.Date=@VanDate   
SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'               
  SELECT  InvoiceID,                   "InvoiceID" = @INV + CAST(DocumentID AS nVARCHAR),     
 "Date" = InvoiceDate,            "CustomerID" = Customer.CustomerID,                 
  "Customer" = Customer.Company_Name,                  "Goods Value" = GoodsValue,        
           "Product Discount" = ProductDiscount,       "Total SalesTax Value" = TotalTaxApplicable,     
     "Trade Discount" = Cast(InvoiceAbstract.GoodsValue * (DiscountPercentage /100) as Decimal(18,6)),   
               "Addl Discount" = InvoiceAbstract.GoodsValue * (AdditionalDiscount / 100),            
      Freight,    "Net Value" = NetValue,     "Round Off" = RoundOffAmount,               
   "Adjusted Amount" = IsNull(InvoiceAbstract.AdjustedAmount, 0),            
      "Balance" = InvoiceAbstract.Balance,          
        "Van Loading Slip" = InvoiceAbstract.NewReference,          
        "Payment Mode" = case IsNull(PaymentMode,0)                  When 0 Then @Credit                  When 1 Then @Cash                  When 2 Then @Cheque                  When 3 Then @DD                  Else @Credit                  End      FROM InvoiceAbstract, Customer               WHERE   InvoiceAbstract.ReferenceNumber In(Select DocID from #tem )   And InvoiceType in (1,3) AND                 InvoiceAbstract.CustomerID = Customer.CustomerID AND                 (InvoiceAbstract.Status & 128) = 0   Order By  InvoiceAbstract.DocumentID     Drop Table #RSV   Drop Table #tem
