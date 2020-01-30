CREATE PROCEDURE sp_viewonly_RetailDetail_MUOM(@INVOICEID INT)          
AS          
SELECT  InvoiceDetail.Product_Code,         
 Items.ProductName,           
 InvoiceDetail.Batch_Number,         
 -- Mulitple uom option removed for chevron version    
 sum(InvoiceDetail.quantity),            
 InvoiceDetail.SalePrice,           
 ISNULL(Max(InvoiceDetail.TaxCode), 0),          
 SUM(InvoiceDetail.DiscountPercentage),         
 SUM(InvoiceDetail.DiscountValue),          
 SUM(InvoiceDetail.Amount), 0,         
 InvoiceDetail.SaleID,          
 ISNULL(Max(InvoiceDetail.TaxSuffered), 0)  ,        
 'Multiple',        
 InvoiceDetail.FlagWord,     
 InvoiceDetail.freeSerial, InvoiceDetail.SPLCATSerial,     
 InvoiceDetail.SpecialCategoryScheme, InvoiceDetail.SCHEMEID,     
 InvoiceDetail.SPLCATSCHEMEID, InvoiceDetail.SCHEMEDISCPERCENT,     
 InvoiceDetail.SCHEMEDISCAMOUNT, InvoiceDetail.SPLCATDISCPERCENT,     
 InvoiceDetail.SPLCATDISCAMOUNT,    
 isnull((Select SchemeType From Schemes Where SchemeID = InvoiceDetail.SchemeID),0) SCHEME_INDICATOR,    
 isnull((Select SchemeType From Schemes Where SchemeID = InvoiceDetail.SPLCATSchemeID),0) SPLCATSCHEME_INDICATOR    
 ,InvoiceDetail.SalesStaffID,    
 SUM(InvoiceDetail.TaxAmount) as TaxAmount,      
 SUM(InvoiceDetail.taxSuffAmount) as taxSuffAmount,      
 SUM(InvoiceDetail.STCredit) as STCredit,    
 invoicedetail.uom,    
 invoicedetail.uomprice,    
 SUM(InvoiceDetail.uomqty) as uomqty,  
 MIN(InvoiceDetail.Batch_Code) as batch_code,  
 Isnull(Batch_Products.Free,0) as Free,    
 Max(InvoiceDetail.TaxSuffApplicableOn) 'TaxSuffApplicableOn',   
 Max(InvoiceDetail.TaxSuffPartOff) 'TaxSuffPartOff',    
 Max(InvoiceDetail. TaxApplicableOn) 'TaxApplicableOn',   
 Max(InvoiceDetail.TaxPartOff) 'TaxPartOff'
,Max(InvoiceDetail.TaxID) 'TaxID'
 FROM InvoiceDetail
 Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code          
 Left Outer Join Batch_Products On Batch_Products.Batch_Code = InvoiceDetail.Batch_Code           
 WHERE InvoiceDetail.InvoiceID = @INVOICEID          
 GROUP BY InvoiceDetail.Serial,        
 InvoiceDetail.Product_Code,         
 Items.ProductName,           
 InvoiceDetail.Batch_Number,         
 InvoiceDetail.SalePrice,         
 InvoiceDetail.SaleID ,    
 InvoiceDetail.FlagWord, InvoiceDetail.freeSerial, InvoiceDetail.SPLCATSerial,     
 InvoiceDetail.SpecialCategoryScheme, InvoiceDetail.SCHEMEID, InvoiceDetail.SPLCATSCHEMEID,     
 InvoiceDetail.SCHEMEDISCPERCENT, InvoiceDetail.SCHEMEDISCAMOUNT,       
 InvoiceDetail.SPLCATDISCPERCENT, InvoiceDetail.SPLCATDISCAMOUNT,    
 InvoiceDetail.SalesStaffID, Isnull(Batch_Products.Free,0),  
 invoicedetail.uom,invoicedetail.uomprice    
   
