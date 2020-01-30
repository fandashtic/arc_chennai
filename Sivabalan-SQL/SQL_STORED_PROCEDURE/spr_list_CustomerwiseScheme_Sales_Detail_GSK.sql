CREATE PROCEDURE spr_list_CustomerwiseScheme_Sales_Detail_GSK(        
 @SchemeIDName nvarchar(400),        
 @FromDate DateTime,        
 @ToDate DateTime ,
 @SchemeNm nvarchar(255)      
)As        
Declare @prefix as nvarchar(255)
Declare @SchemeType as int
Declare @SchemeID as int
Declare @index as int
Declare @TOBEDEFINED nVarchar(50)

Set @TOBEDEFINED=dbo.LookupDictionaryItem(N'To be defined', Default)

set @index=CHARINDEX ('|',@SchemeIDName)
select @prefix=prefix from VoucherPrefix Where TranId Like'Invoice'
set @SchemeType =cast( substring(@SchemeIDName,1,CHARINDEX ('|',@SchemeIDName)-1)as integer)
set @SchemeID = cast(substring(@SchemeIDName,CHARINDEX ('|',@SchemeIDName)+1,Len(@SchemeIDName)) as integer)

-- Channel type name changed, and new channel classifications added

CREATE TABLE #OLClassMapping (OLClassID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)  

Insert Into #OLClassMapping 
Select  olcm.OLClassID, olcm.CustomerId, olc.Channel_Type_Desc, olc.Outlet_Type_Desc, 
olc.SubOutlet_Type_Desc 
From tbl_merp_olclass olc, tbl_merp_olclassmapping olcm
Where olc.ID = olcm.OLClassID And
olc.Channel_Type_Active = 1 And olc.Outlet_Type_Active = 1 And olc.SubOutlet_Type_Active = 1 And 
olcm.Active = 1 

Begin 
if @SchemeType=3                    
Begin                        
--InvoiceBased Free Items For Value                                  
Select               
Inv.InvoiceDate,
"Invoice Date"=Inv.InvoiceDate,               
"Invoice ID"=cast(@Prefix as nvarchar)+Cast(Inv.DocumentID as Varchar),              
"Doc Reference"=DocReference,
"Customer Name"=Company_Name,
"Customer Type"=ChannelDesc,
"Channel Type" = IsNull(olcm.[Channel Type], @TOBEDEFINED),
"Outlet Type" = IsNull(olcm.[Outlet Type], @TOBEDEFINED),
"Loyalty Program" = IsNull(olcm.[Loyalty Program], @TOBEDEFINED),
"Sub Channel"=Description,
"Qty Sold"=(Select Sum(Quantity) from InvoiceDetail where InvoiceID=Inv.InvoiceId),
"Invoice Amount"=(Select sum(Amount) from InvoiceDetail Where InvoiceId=Inv.InvoiceId),
--"Scheme Value"=Schs.cost
"Scheme Value"=(Select sum(isnull(cost,0)) from SchemeSale where Type=sch.Schemeid And InvoiceId=Inv.InvoiceId)
From InvoiceAbstract Inv
Inner Join Customer  Cust On Inv.CustomerID=Cust.CustomerID
Left Outer Join Customer_Channel CC On Cust.ChannelType=CC.ChannelType
Left Outer Join SubChannel SC On Cust.SubChannelID= SC.SubChannelID 
Inner Join SchemeSale SchS On Inv.InvoiceId=Schs.InvoiceID
Inner Join Schemes Sch On Schs.Type=sch.Schemeid
Left Outer Join #OLClassMapping olcm On Cust.CustomerID=olcm.CustomerID 
Where 
Inv.InvoiceDate BetWeen @FromDate And @ToDate 
And (IsNull(Inv.Status,0) & 192) =0
And Sch.SchemeType=@SchemeType
And Sch.SchemeID =@SchemeID
Group By Inv.InvoiceID,sch.Schemeid,InvoiceDate,Inv.DocumentId,
DocReference,Company_Name,ChannelDesc,Description,
olcm.[Channel Type], olcm.[Outlet Type], olcm.[Loyalty Program]
End                  
                  
If @SchemeType=17  or @SchemeType=18                
--Item Based Same product free /Different Product Free
Begin                        
Select               
Inv.InvoiceDate,
"Invoice Date"=Inv.InvoiceDate,               
"Invoice ID"=cast(@Prefix as nvarchar)+Cast(Inv.DocumentID as Varchar),              
"Doc Reference"=DocReference,
"Customer Name"=Company_Name,
"Customer Type"=ChannelDesc,
"Channel Type" = IsNull(olcm.[Channel Type], @TOBEDEFINED),
"Outlet Type" = IsNull(olcm.[Outlet Type], @TOBEDEFINED),
"Loyalty Program" = IsNull(olcm.[Loyalty Program], @TOBEDEFINED),
"Sub Channel"=Description,
"Qty Sold"=(Select Sum(Quantity) from InvoiceDetail where InvoiceID=Inv.InvoiceId),
"Invoice Amount"=(Select sum(Amount) from InvoiceDetail Where InvoiceId=Inv.InvoiceId),
--"Scheme Value"=Schs.cost
"Scheme Value"=(Select sum(isnull(cost,0)) from SchemeSale where Type=sch.Schemeid And InvoiceId=Inv.InvoiceId )
From InvoiceAbstract Inv
Inner Join Customer  Cust On Inv.CustomerID=Cust.CustomerID
Left Outer Join Customer_Channel CC On Cust.ChannelType=CC.ChannelType
Left Outer Join SubChannel SC On Cust.SubChannelID= SC.SubChannelID 
Inner Join SchemeSale SchS On Inv.InvoiceId=Schs.InvoiceID
Inner Join Schemes Sch On Schs.Type=sch.Schemeid
Left Outer Join  #OLClassMapping olcm On Cust.CustomerID=olcm.CustomerID 
Where 
Inv.InvoiceDate BetWeen @FromDate And @ToDate 
And (IsNull(Inv.Status,0) & 192) =0
And Sch.SchemeType =@SchemeType
And Sch.SchemeID =@SchemeID
Group By Inv.InvoiceID,sch.Schemeid,InvoiceDate,Inv.DocumentId,
DocReference,Company_Name,ChannelDesc,Description,
olcm.[Channel Type], olcm.[Outlet Type], olcm.[Loyalty Program]
End  

                 
--Item Based Percentage/Amount
if  @SchemeType=19  or  @SchemeType=81 or @SchemeType=20 or  @SchemeType=82                
begin
Select               
Inv.InvoiceDate,
"Invoice Date"=Inv.InvoiceDate,               
"Invoice ID"=cast(@Prefix as nvarchar)+Cast(Inv.DocumentID as Varchar),              
"Doc Reference"=DocReference,
"Customer Name"=Company_Name,
"Customer Type"=ChannelDesc,
"Channel Type" = IsNull(olcm.[Channel Type], @TOBEDEFINED),
"Outlet Type" = IsNull(olcm.[Outlet Type], @TOBEDEFINED),
"Loyalty Program" = IsNull(olcm.[Loyalty Program], @TOBEDEFINED),
"Sub Channel"=Description,
"Qty Sold"=(Select Sum(Quantity) from InvoiceDetail where InvoiceID=Inv.InvoiceId),
"Invoice Amount"=(Select sum(Amount) from InvoiceDetail Where InvoiceId=Inv.InvoiceId),
"Scheme Value"=(Select sum(DiscountValue) from InvoiceDetail where InvoiceID=Inv.InvoiceId)
From InvoiceAbstract Inv
Inner Join Customer  Cust On Inv.CustomerID=Cust.CustomerID
Left Outer Join Customer_Channel CC On Cust.ChannelType=CC.ChannelType
Left Outer Join SubChannel SC On Cust.SubChannelID= SC.SubChannelID 
Inner Join SchemeSale SchS On Inv.InvoiceId=Schs.InvoiceID
Inner Join Schemes Sch On Schs.Type=sch.Schemeid
Left Outer Join #OLClassMapping olcm On Cust.CustomerID=olcm.CustomerID 
Where 
Inv.InvoiceDate BetWeen @FromDate  And @ToDate
And (IsNull(Inv.Status,0) & 192) =0
And Sch.SchemeType =@SchemeType
And Sch.SchemeID =@SchemeID  
Group By Inv.InvoiceID,sch.Schemeid,InvoiceDate,Inv.DocumentId,
DocReference,Company_Name,ChannelDesc,Description,
olcm.[Channel Type], olcm.[Outlet Type], olcm.[Loyalty Program]
end                  
 
--Invoice Based Amount/Percentage               
if @SchemeType=1 or @SchemeType=2
begin
Select               
Inv.InvoiceDate,
"Invoice Date"=Inv.InvoiceDate,               
"Invoice ID"=cast(@Prefix as nvarchar)+Cast(Inv.DocumentID as Varchar),              
"Doc Reference"=DocReference,
"Customer Name"=Company_Name,
"Customer Type"=ChannelDesc,
"Channel Type" = IsNull(olcm.[Channel Type], @TOBEDEFINED),
"Outlet Type" = IsNull(olcm.[Outlet Type], @TOBEDEFINED),
"Loyalty Program" = IsNull(olcm.[Loyalty Program], @TOBEDEFINED),
"Sub Channel"=Description,
"Qty Sold"=(Select Sum(Quantity) from InvoiceDetail where InvoiceID=Inv.InvoiceId),
"Invoice Amount"=(Select sum(Amount) from InvoiceDetail Where InvoiceId=Inv.InvoiceId),
"Scheme Value"=(select SchemeDiscountAmount from invoiceabstract where Schemeid=Sch.SchemeId And InvoiceId=Inv.InvoiceId)
From InvoiceAbstract Inv
Inner Join Customer  Cust On Inv.CustomerID=Cust.CustomerID
Left Outer Join Customer_Channel CC On Cust.ChannelType=CC.ChannelType
Left Outer Join SubChannel SC On Cust.SubChannelID= SC.SubChannelID 
Inner Join Schemes Sch On Sch.schemeID = Inv.SchemeID  
Left Outer Join #OLClassMapping olcm On Cust.CustomerID=olcm.CustomerID 
Where 
Inv.InvoiceDate BetWeen @FromDate And @ToDate
And (IsNull(Inv.Status,0) & 192) =0 
And Sch.SchemeType=@SchemeType
And Sch.SchemeID =@SchemeID
Group By Inv.InvoiceID,sch.Schemeid,InvoiceDate,Inv.DocumentId,
DocReference,Company_Name,ChannelDesc,Description,
olcm.[Channel Type], olcm.[Outlet Type], olcm.[Loyalty Program]
end 
end                  

