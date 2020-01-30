CREATE Procedure spr_list_CustomerwiseSchemes_Detail(@CustomerID nvarchar(255),@FromDate DateTime,                          
              @ToDate DateTime,@SchemeName nvarchar(2550))                          
As                          
Begin                          
Declare @Delimeter as Char(1)                                    
Set @Delimeter=Char(15)                                   
Create table #tmpSch(SchemeName nvarchar(255))                                    
If @SchemeName='%'                          
   Insert into #tmpSch select SchemeName from Schemes                          
Else                          
   Insert into #tmpSch select * from dbo.sp_SplitIn2Rows(@SchemeName,@Delimeter)                          
    
Declare @Prefix as nvarchar(2)    
select @Prefix = Prefix from VoucherPrefix where TranID = 'RETAIL INVOICE'    
          
--ItemBased Same/Diff Prod Free  & InvoiceBased FreeItems For Value        
--& InvoiceBased Items Worth X Amount Free & Item Based Invoice Discount FreeItem                                        
Select Inv.DocumentID,"Inv No" = @Prefix + Cast(Inv.DocumentID as nvarchar), "DocRef" = Inv.DocReference, "InvDate" = Inv.InvoiceDate,                   
"SchName" = Sch.SchemeName,"ItemName" = Items.ProductName,                   
"Qty" = Cast(SchS.Free as nvarchar) , "FreeItemCost (%c)" = Cast(Schs.Cost as nvarchar),                          
"% Dis" = Cast(Inv.DiscountPercentage as nvarchar), "AmtDis (%c)" = Cast(Inv.DiscountValue as nvarchar)                          
From InvoiceAbstract Inv,Schemes Sch,SchemeSale SchS ,Items        
Where Inv.CustomerID like @CustomerID                          
And Inv.InvoiceDate BetWeen @FromDate And @Todate                          
And (IsNull(Inv.Status,0) & 192) =0                  
And SchS.InvoiceID=Inv.InvoiceId                  
And Sch.SchemeName In (Select SchemeName From #tmpsch)                          
And SchS.Type=Sch.SchemeID                          
And SchS.Product_Code=Items.Product_Code                
And (SchS.Quantity > 0  Or Sch.SchemeType in (3,4,97))                        
            
--ItemBased Percentage              
Union              
Select Inv.DocumentID,"Inv No" = @Prefix + Cast(Inv.DocumentID as nvarchar), "DocRef" = Inv.DocReference, "InvDate" = Inv.InvoiceDate,                   
"SchName" = Sch.SchemeName,"ItemName" = Items.ProductName,                   
"Qty" = Null , "FreeItemCost (%c)" = Null,                          
"% Dis" = Cast(SchS.Cost as nvarchar), "AmtDis (%c)" = Cast((SchS.Value*SchS.Cost)/100 as nvarchar)                          
From InvoiceAbstract Inv,Schemes Sch,SchemeSale SchS ,Items                      
Where Inv.CustomerID like @CustomerID                          
And Inv.InvoiceDate BetWeen @FromDate And @Todate                          
And (IsNull(Inv.Status,0) & 192) =0                  
And SchS.InvoiceID=Inv.InvoiceId                  
And Sch.SchemeName In (Select SchemeName From #tmpsch)                          
And SchS.Type=Sch.SchemeID          
And Sch.SchemeType Not in (3,4,20,97)          
And SchS.Product_Code=Items.Product_Code                
And SchS.Quantity =0                          
--And SchS.Flags=0                             
          
--ItemBased Amount              
Union              
Select Inv.DocumentID,"Inv No" = @Prefix + Cast(Inv.DocumentID as nvarchar), "DocRef" = Inv.DocReference, "InvDate" = Inv.InvoiceDate,                   
"SchName" = Sch.SchemeName,"ItemName" = Items.ProductName,                   
"Qty" = Null , "FreeItemCost (%c)" = Null,                          
"% Dis" = Null, "AmtDis (%c)" = Cast(SchS.Cost as nvarchar)                          
From InvoiceAbstract Inv,Schemes Sch,SchemeSale SchS ,Items        
Where Inv.CustomerID like @CustomerID                          
And Inv.InvoiceDate BetWeen @FromDate And @Todate                          
And (IsNull(Inv.Status,0) & 192) =0                  
And SchS.InvoiceID=Inv.InvoiceId                  
And Sch.SchemeName In (Select SchemeName From #tmpsch)                          
And SchS.Type=Sch.SchemeID          
And Sch.SchemeType = 20                              
And SchS.Product_Code=Items.Product_Code                
And SchS.Quantity =0                          
--And SchS.Flags=0                             
          
--InvoiceBased Percentage/Amount          
Union                        
Select Inv.DocumentID,@Prefix + Cast(Inv.DocumentID as nvarchar), "DocRef" = Inv.DocReference, "InvDate" = Inv.InvoiceDate,                   
"SchName" = Sch.SchemeName, "ItemName" = Null,       
"Qty" = Null, "FreeItemCost (%c)" = Null,                          
"% Dis" = Cast(Inv.SchemeDiscountPercentage as nvarchar), "AmtDis (%c)" = Cast(Inv.SchemeDiscountAmount as nvarchar)                          
From InvoiceAbstract Inv,InvoiceDetail InvDet,Schemes Sch            
Where Inv.CustomerID like @CustomerID                          
And Inv.InvoiceDate BetWeen @FromDate And @Todate                          
And Sch.SchemeName In (Select SchemeName From #tmpsch)                          
And Inv.SchemeID=Sch.SchemeID                          
And Inv.InvoiceId=InvDet.InvoiceID                          
And (IsNull(Inv.Status,0) & 192) =0        
And Sch.SchemeType Not in (3,4,97)                      
Drop Table #tmpSch                          
End          
              
            
          
          
        
      
    
  
  


