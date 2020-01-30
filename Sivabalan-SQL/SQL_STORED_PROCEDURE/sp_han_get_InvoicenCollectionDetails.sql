Create Procedure sp_han_get_InvoicenCollectionDetails  
(@InvoiceID Integer,@ColSerialNo nvarchar(50))  
AS  
Select   
"InvoiceID" = INA.[InvoiceID]  
,"DocumentID" = INA.[DocumentID]  
,"InvDocRef" = INA.[DocReference]  
,"InvoiceDate" = INA.[InvoiceDate]  
,"Invoice_CustID" =IsNull(INA.[CustomerID],'')  
,"NetValue" = IsNull(INA.[NetValue],0)  
,"PaymentDate" = INA.[PaymentDate]  
,"ErrorStatus" = Case IsNull(COLD.[CollectionFlag],0)  
     When 1 then Case  
      when IsNull(INA.[CustomerID],'') <> IsNull(COLD.[CustomerID],'')  
        then -1  
      when dbo.StripDateFromTime(COLD.CollectionDate)   
       < dbo.StripDateFromTime(INA.InvoiceDate) then -2  
      when dbo.StripDateFromTime(COLD.CollectionDate)   
        > dbo.StripDateFromTime (INA.PaymentDate) then 1  
      else 0  
      end  
      else 0  
      end  
,"Balance" = IsNull(INA.Balance,0)  
,"InvoiceStatus" = IsNull(INA.[Status],0)  
from Collection_Details COLD  
Inner Join InvoiceAbstract INA ON COLD.[AgainstBillNO] = INA.[InvoiceID]  
AND COLD.[Processed] = 0  
and INA.InvoiceID = @InvoiceID and INA.[InvoiceType] in (1,3) And COLD.[Collection_Serial] = @ColSerialNo

