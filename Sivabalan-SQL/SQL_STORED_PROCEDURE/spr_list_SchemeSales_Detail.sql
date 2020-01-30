CREATE procedure spr_list_SchemeSales_Detail(@SchemeID Integer,                    
 @FromDate DateTime,@ToDate DateTime)                            
As                          
Begin                          
    
Declare @Prefix as nvarchar(2)    
select @Prefix = Prefix from VoucherPrefix where TranID = 'RETAIL INVOICE'    
    
--ItemBased Same/Diff Prod Free  & InvoiceBased Free Items For Value              
--& InvoiceBased Items Worth X Amount Free & ItemBased Invoice Discount FreeItem             
Select Inv.DocumentID,"Inv No" =@Prefix + Cast(Inv.DocumentID as nvarchar) , "Doc Ref" = Inv.DocReference,                  
"Cust Name" =Cust.Company_Name ,                     
"Cust Id" = Cust.CustomerID,                          
"Inv Date" = Inv.InvoiceDate,"Qty of SchItem" = Sum(SchS.Free),                          
"Cost/Unit (%c)" = Sum(SchS.Cost/SchS.Free), "Total Cost (%c)" = Sum(SchS.Cost)                          
From InvoiceAbstract Inv,Customer Cust,SchemeSale SchS, Schemes Sch                          
Where SchS.Type=@SchemeID                          
And Inv.InvoiceId=Schs.InvoiceID                  
And Inv.CustomerID=Cust.CustomerID                          
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                            
And (IsNull(Inv.Status,0) & 192) =0              
And Sch.SchemeId = @SchemeID                
And (SchS.Quantity > 0 Or Sch.SchemeType in (3,4,97))              
Group by Inv.DocumentID,Inv.DocReference,Cust.Company_Name,Cust.CustomerID,Inv.InvoiceDate                          

Union                
--ItemBased Percentage                
Select Inv.DocumentID,"Inv No" = @Prefix + Cast(Inv.DocumentID as nvarchar) , "Doc Ref" = Inv.DocReference,                  
"Cust Name" =Cust.Company_Name ,                     
"Cust Id" = Cust.CustomerID,                          
"Inv Date" = Inv.InvoiceDate,"Qty of SchItem" = Null,                          
"Cost/Unit (%c)" = Null, "Total Cost (%c)" = Sum((SchS.Value*SchS.Cost)/100)                          
From InvoiceAbstract Inv,Customer Cust,SchemeSale SchS,Schemes Sch                
Where SchS.Type=@SchemeID                          
And Inv.InvoiceId=Schs.InvoiceID                  
And Inv.CustomerID=Cust.CustomerID                          
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                            
And (IsNull(Inv.Status,0) & 192) =0                
And SchS.Quantity = 0                
And Sch.SchemeID= SchS.Type                  
And Sch.SchemeType Not in (3,4,20,97)                  
Group by Inv.DocumentID,Inv.DocReference,Cust.Company_Name,Cust.CustomerID,Inv.InvoiceDate,                 
Sch.SchemeID,Sch.SchemeType                
Union                
--ItemBased Amount                
Select Inv.DocumentID,"Inv No" = @Prefix + Cast(Inv.DocumentID as nvarchar) , "Doc Ref" = Inv.DocReference,                  
"Cust Name" =Cust.Company_Name ,                     
"Cust Id" = Cust.CustomerID,                          
"Inv Date" = Inv.InvoiceDate,"Qty of SchItem" = Null,                          
"Cost/Unit (%c)" = Null, "Total Cost (%c)" = Sum(SchS.Cost)                          
From InvoiceAbstract Inv,Customer Cust,SchemeSale SchS,Schemes Sch                
Where SchS.Type=@SchemeID                          
And Inv.InvoiceId=Schs.InvoiceID                  
And Inv.CustomerID=Cust.CustomerID                          
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                            
And (IsNull(Inv.Status,0) & 192) =0                
And SchS.Quantity = 0                
And Sch.SchemeID= SchS.Type                  
And Sch.SchemeType = 20                  
Group by Inv.DocumentID,Inv.DocReference,Cust.Company_Name,Cust.CustomerID,Inv.InvoiceDate,                          
Sch.SchemeID,Sch.SchemeType                
--InvoiceBased Percentage/Amount & ItemBased Invoice Discount Percentage      
Union 
Select Inv.DocumentID,"Inv No" = @Prefix + Cast(Inv.DocumentID as nvarchar) , "Doc Ref" = Inv.DocReference,                
"Cust Name" =Cust.Company_Name ,                           
"Cust Id" = Cust.CustomerID, "Inv Date" = Inv.InvoiceDate,"Qty of SchItem" = Null,      
"Cost/Unit (%c)" = Null , "Total Cost (%c)" = Inv.SchemeDiscountAmount                          
From InvoiceAbstract Inv,Customer Cust,SchemeSale SchS                          
Where Inv.CustomerID=Cust.CustomerID                          
And Inv.SchemeID=@SchemeID              
And Inv.SchemeID Not in (Select Type From SchemeSale Where InvoiceID = Inv.InvoiceID)              
And (IsNull(Inv.Status,0) & 192) =0                          
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                            
Group by Inv.DocumentID,Inv.DocReference,Cust.Company_Name,Cust.CustomerID,Inv.InvoiceDate,                          
Inv.SchemeDiscountAmount                          
End              
          
        
      
    
  


