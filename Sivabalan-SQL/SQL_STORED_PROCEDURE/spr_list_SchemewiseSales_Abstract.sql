
CREATE PROCEDURE spr_list_SchemewiseSales_Abstract(                          
@Product_Hierarchy nvarchar(2550),                     
@Category nvarchar(2550),                     
@ItemCode nVarchar(2550),          
@SchemeName NVarchar(2550),                                        
@FromDate Datetime ,                          
@ToDate DateTime                          
) As                                    
                        
Begin                                                            
                            
Declare @Delimeter as Char(1)                                                              
Set @Delimeter=Char(15)                                                             
          
Create table #tmpSch(SchemeName NVarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)                            
Create Table #ItemCode (ItemCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)              
Create Table #tempCategory(CategoryID int, Status int)                      
      
Exec GetLeafCategories @PRODUCT_HIERARCHY, @CATEGORY               
          
If @ItemCode = '%'               
 Insert Into #ItemCode Select Product_Code From Items              
Else              
 Insert Into #ItemCode Select * From DBO.sp_SplitIn2Rows(@ItemCode,@Delimeter)              
                                                            
If @SchemeName='%'                                                               
   Insert into #tmpSch select SchemeName from Schemes                                                              
Else                                                              
   Insert into #tmpSch select * from dbo.sp_SplitIn2Rows(@SchemeName,@Delimeter)                                                              
                          
--InvoiceBased Free Items For Value          
          
Select "Scheme Type" = Cast([Scheme Type] as nVarchar) + Char(15) + Cast([Scheme ID] as nVarchar),          
"Description"=[Scheme Name],          
"Total No. of Invoices"=Count(distinct [Total Invoices])          
From (          
Select          
"Scheme ID" = Cast(Sch.SchemeID as nVarchar),
"Scheme Type" = cast(Sch.SchemeType as nvarchar),          
"Scheme Name" = sch.schemename,          
"Total Invoices"=inv.invoiceid          
From Schemes Sch,SchemeSale SchS,InvoiceAbstract Inv,InvoiceDetail Idet,Items            
Where Sch.SchemeName in (Select SchemeName From #tmpSch)                            
And SchS.Type=Sch.schemeID                                              
And Inv.InvoiceID=SchS.InvoiceID            
And Inv.Invoiceid=Idet.Invoiceid            
And Idet.Product_code=Items.Product_code                                               
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                                                    
And (IsNull(Inv.Status,0) & 192) =0                                            
and inv.invoicetype in (1,2,3)      
And Sch.SchemeType in (3,4,97,99)
and Items.CategoryID In (Select CategoryID From #tempCategory)            
and Items.product_Code In (Select ItemCode From #ItemCode)            
--Group by sch.schemeID, sch.schemename, Sch.SchemeType  ,inv.invoiceid,inv.netvalue)schemes                    
Group by sch.schemename, Sch.SchemeType  ,inv.invoiceid, sch.SchemeID)schemes                    
group by [Scheme Type],[Scheme Name], [Scheme ID]
                         
Union                                            
--Item Based Same Item Free /Item Based Different Item Free                   
                  
Select "Scheme Type" = Cast([Scheme Type] as nVarchar) + Char(15) + Cast([Scheme ID] as nVarchar),
"Description"=[Scheme Name],                        
"Total No. of Invoices"=Count(distinct [Total Invoices])            
From (                        
Select                         
"Scheme ID" = Cast(Sch.SchemeID as nVarchar),
"Scheme Type" = cast(Sch.SchemeType as varchar),                    
"Scheme Name" = sch.schemename,                             
"Total Invoices"=inv.invoiceid            
From InvoiceAbstract Inv,SchemeSale SchS,Schemes Sch,Items Itm,InvoiceDetail Idet            
Where                               
Schs.product_code=Itm.product_code                              
And Sch.SchemeName in (Select SchemeName From #tmpSch)                            
And Inv.InvoiceId=Schs.InvoiceID            
And Inv.Invoiceid=Idet.Invoiceid            
And Idet.Product_code=Itm.Product_code                                               
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                   
And (IsNull(Inv.Status,0) & 192) =0                                                
And Sch.SchemeID= SchS.Type                                                  
and inv.invoicetype in (1,2,3)      
And Sch.SchemeType in ( 17, 83, 18, 84)                    
-- And SchS.SpecialCategory <> 1
and Itm.CategoryID In (Select CategoryID From #tempCategory)                       
and Itm.product_Code In (Select ItemCode COLLATE SQL_Latin1_General_CP1_CI_AS From #ItemCode)            
group by Sch.SchemeType,sch.schemename,inv.invoiceid, Sch.SchemeID
)Scheme                        
group by [Scheme Type],[Scheme Name], [Scheme ID]
                            
Union                                            
                            
--ItemBased Percentage                                            
Select "Scheme Type" = Cast([Scheme Type] as nVarchar) + Char(15) + Cast([Scheme ID] as nVarchar),  
"Description"=[Scheme Name],                        
"Total No. of Invoices"=Count(distinct [Total Invoices])            
from (                        
Select                          
"Scheme ID" = Cast(Sch.SchemeID as nVarchar),
"Scheme Type" = cast(Sch.SchemeType as varchar),                            
"Scheme Name" = sch.schemename,                        
"Total Invoices"=Idet.invoiceid            
from invoicedetail Idet                                  
inner join InvoiceAbstract Inv on Inv.InvoiceId=Idet.InvoiceId                                
left join Schemes Sch on (sch.Schemeid = Idet.Schemeid or sch.Schemeid = Idet.SPLCATSCHEMEID)
left join SchemeSale SchS on  schs.InvoiceId=Inv.InvoiceId            
left join Items On Idet.Product_code=Items.Product_code            
Where Sch.SchemeName in (Select SchemeName From #tmpSch)                        
And SchS.Type=Sch.schemeID                        
And Inv.InvoiceID=SchS.InvoiceID                        
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                        
And (IsNull(Inv.Status,0) & 192) =0                        
And SchS.Quantity = 0                        
And isnull(Idet.discountvalue,0)>0                        
and inv.invoicetype in (1,2,3)      
And Sch.SchemeType in (19,81,20,82, 21, 22)                        
-- And SchS.SpecialCategory <> 1
and Items.CategoryID In (Select CategoryID From #tempCategory)            
and Items.product_Code In (Select ItemCode COLLATE SQL_Latin1_General_CP1_CI_AS From #ItemCode)            
Group by sch.schemename, Sch.SchemeType ,Idet.Invoiceid, sch.SchemeID )dkfk                        
Group by [Scheme Type],[Scheme Name], [Scheme ID]
                            
drop table #tmpSch                            
drop table #ItemCode          
drop table #tempCategory          
End                                            
                                    
