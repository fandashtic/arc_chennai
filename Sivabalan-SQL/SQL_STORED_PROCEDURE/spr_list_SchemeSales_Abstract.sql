CREATE procedure spr_list_SchemeSales_Abstract(@SchemeName nvarchar(2550),                  
@FromDate Datetime, @ToDate DateTime)                              
As                              
Begin                              
Declare @Delimeter as Char(1)                                
Set @Delimeter=Char(15)                               
Create table #tmpSch(SchemeName nvarchar(255))                                
                              
If @SchemeName='%'                                 
   Insert into #tmpSch select SchemeName from Schemes                                
Else                                
   Insert into #tmpSch select * from dbo.sp_SplitIn2Rows(@SchemeName,@Delimeter)                                
      
--ItemBased Same/Diff Prod Free & InvoiceBased Free Items For Value           
--& InvoiceBased Items Worth X Amount Free & ItemBased Invoice Discount FreeItem                          
Select Sch.SchemeID,"Scheme Name" = sch.schemename,                   
"Scheme Type" = dbo.GetSchemeType(Sch.SchemeType),                              
"Scheme Cost (%c)" = Sum(SchS.Cost),"Free Items" = dbo.GetCSVItems(Sch.schemeID)                      
From Schemes Sch,SchemeSale SchS,InvoiceAbstract Inv                        
Where Sch.SchemeName in (Select SchemeName From #tmpSch)                             
And SchS.Type=Sch.schemeID                
And Inv.InvoiceID=SchS.InvoiceID                            
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                      
And (IsNull(Inv.Status,0) & 192) =0              
And (SchS.Quantity > 0 Or Sch.SchemeType in (3,4,97))             
Group by sch.schemeID, sch.schemename, Sch.SchemeType            
Union              
--ItemBased Percentage & ItemBased Percentage Discount On Cheaper/Expensive Item             
Select Sch.SchemeID,"Scheme Name" = sch.schemename,                   
"Scheme Type" = dbo.GetSchemeType(Sch.SchemeType),                              
"Scheme Cost (%c)" = Sum((SchS.Value*SchS.Cost)/100),"Free Items" = Null              
From Schemes Sch,SchemeSale SchS,InvoiceAbstract Inv                               
Where Sch.SchemeName in (Select SchemeName From #tmpSch)                             
And SchS.Type=Sch.schemeID                
And Inv.InvoiceID=SchS.InvoiceID                            
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                      
And (IsNull(Inv.Status,0) & 192) =0              
And SchS.Quantity = 0              
And Sch.SchemeType not in (3,4,20,97)               
Group by sch.schemeid, sch.schemename, Sch.SchemeType                              
Union              
--ItemBased Amount              
Select Sch.SchemeID,"Scheme Name" = sch.schemename,                   
"Scheme Type" = dbo.GetSchemeType(Sch.SchemeType),                              
"Scheme Cost (%c)" = Sum(SchS.Cost),"Free Items" = Null              
From Schemes Sch,SchemeSale SchS,InvoiceAbstract Inv                             
Where Sch.SchemeName in (Select SchemeName From #tmpSch)                             
And SchS.Type=Sch.schemeID                
And Inv.InvoiceID=SchS.InvoiceID                            
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                      
And (IsNull(Inv.Status,0) & 192) =0              
And SchS.Quantity = 0              
And Sch.SchemeType = 20             
Group by sch.schemeid, sch.schemename, Sch.SchemeType                              
Union              
--InvoiceBased Percentage/Amount & ItemBased Invoice Discount Percentage             
Select Sch.SchemeID,"Scheme Name" = sch.schemename,                   
"Scheme Type" = dbo.GetSchemeType(Sch.SchemeType),                              
"Scheme Cost (%c)" = Sum(Inv.SchemeDiscountAmount),"Free Items" = Null                              
From Schemes Sch,InvoiceAbstract Inv                              
Where Sch.SchemeName in (Select SchemeName From #tmpSch)                             
And Sch.schemeID = Inv.SchemeID                               
And (IsNull(Inv.Status,0) & 192) =0    
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                
And Sch.SchemeType not in (3,4,97)                             
Group by sch.schemeid, sch.schemename, Sch.SchemeType                                     
End              
      
    
  


