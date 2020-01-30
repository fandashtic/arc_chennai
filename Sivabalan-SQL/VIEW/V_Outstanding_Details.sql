CREATE     VIEW   V_Outstanding_Details         
([Invoice_number],[Product_Code],[Rate],[Quantity],[Value], [UOMQty], [UOM])          
AS          
SELECT IDET.InvoiceID, IDET.Product_code, IDET.saleprice, IDET.Quantity, IDET.amount, UOMQty, UOM          
From (Select  InvoiceID from InvoiceAbstract Where InvoiceType in (1,3) 
And Balance >0 And  
(isnull(Status,0) & 128 ) = 0           
 And  (isnull(Status,0) & 64 ) = 0 ) IA Inner Join INvoiceDEtail IDET
ON IA.InvoiceID = IDET.InvoiceID  
 
