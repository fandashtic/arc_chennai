CREATE procedure [dbo].[spr_list_CustomerWise_Monthwise_Sales_GSK_ITC](@FromDate DateTime,  
@ToDate DateTime,@CustName nvarchar(2250))  
as  
Begin  
Declare @Mon varchar(2)  
Declare @MonthName VarChar(20)  
Declare @Qry nVarchar(4000)  
Declare @CustID AS nVarchar(255)  
Declare @MonthSales as cursor  
set dateformat dmy      
Declare @Delimeter as Char(1)                                                      
Set @Delimeter=Char(15)                                                     
  
Declare @TOBEDEFINED nVarchar(50)

Set @TOBEDEFINED=dbo.LookupDictionaryItem(N'To be defined', Default)

Declare @tmpCustId table(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)                                                      
Declare @tmpCustName Table(CustomerName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
  
If @CustName='%'                                            
   Insert into @tmpCustId select CustomerId From Customer where customerid <>'0' and CustomerCategory not in (4,5)  
Else                                            
Begin  
   Insert into @tmpCustName select * from dbo.sp_SplitIn2Rows(@CustName,@Delimeter)   
   insert into @tmpCustId select CustomerId From Customer where Company_Name   
    In(select * from  @tmpCustName) and CustomerCategory not in (4,5)  
end  
  
Create table #tmpCustMonthSales([Customer Code] nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,[Customer Name] nvarchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,  
[Customer Type] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Sub Channel] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
April Decimal(18,6),May Decimal(18,6),June Decimal(18,6),July Decimal(18,6),
August Decimal(18,6),September Decimal(18,6),October Decimal(18,6),November Decimal(18,6),December Decimal(18,6),  
January Decimal(18,6),February Decimal(18,6),March Decimal(18,6))  
  
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

insert into  #tmpCustMonthSales([Customer Code],[Customer Name],[Customer Type], [Channel Type], [Outlet Type], [Loyalty Program], [Sub Channel])  
select C.CustomerId, Company_Name,  
ChannelDesc, IsNull(olcm.[Channel Type], @TOBEDEFINED), IsNull(olcm.[Outlet Type], @TOBEDEFINED), IsNull(olcm.[Loyalty Program], @TOBEDEFINED),
SC.Description Channel  
From Customer C Left Join Customer_Channel CC On C.ChannelType  = CC.ChannelType  
Left Join SubChannel SC On  C.SubChannelId = SC.SubChannelId Left Join #OLClassMapping olcm
On C.CustomerId = olcm.CustomerID
Where C.CustomerId in (Select * from @tmpCustId)  

--Declare @tmpSalesSum table(CustomerId nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
--Mon VarChar(20)COLLATE SQL_Latin1_General_CP1_CI_AS,Amount Decimal(18,6))  

Create table #tmpSalesSum (CustomerId nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Mon VarChar(20)COLLATE SQL_Latin1_General_CP1_CI_AS,Amount Decimal(18,6))  


-- Select CustomerId,Month(InvoiceDate) Mon,  
-- Sum(Case InvoiceType When  1 Then  Amount  When  3 Then  Amount  Else  (-1) * Amount End) As Amount  
-- Into @tmpSalesSum  
-- From InvoiceAbstract Ia,  InvoiceDetail Idt   
-- Where  Ia.InvoiceId = Idt.InvoiceId  
-- And  Status & 128 = 0 And  InvoiceType Not In (2,5,6)  
-- And InvoiceDate BetWeen @FromDate And @ToDate  
-- And CustomerId in (Select * from @tmpCustId)  
-- Group By Month(InvoiceDate), CustomerId  
Insert Into #tmpSalesSum
Select CustomerId,Month(InvoiceDate) Mon,  
Sum(Case InvoiceType When  1 Then  Amount  When  3 Then  Amount  Else  (-1) * Amount End) As Amount  
From InvoiceAbstract Ia,  InvoiceDetail Idt   
Where  Ia.InvoiceId = Idt.InvoiceId  
And  Status & 128 = 0 And  InvoiceType Not In (2,5,6)  
And InvoiceDate BetWeen @FromDate And @ToDate  
And CustomerId in (Select * from @tmpCustId)  
Group By Month(InvoiceDate), CustomerId    

set @MonthSales =Cursor For   
Select customerID,Month(InvoiceDate) , DateName(m,InvoiceDate)   
From InvoiceAbstract Ia, InvoiceDetail Idt  
Where Ia.InvoiceId = Idt.InvoiceId  
And  Status & 128 = 0 And  InvoiceType Not In (2,5,6)  
And InvoiceDate BetWeen @FromDate And @ToDate  
And CustomerId in (Select * from @tmpCustId)  
  
Open @MonthSales  
Fetch Next From @MonthSales Into @CustID,@Mon, @MonthName  
While @@Fetch_Status =  0  
Begin  
      Set @Qry = 'Update #tmpCustMonthSales  Set ' +  @MonthName + ' =  Amount  From #tmpCustMonthSales T, #tmpSalesSum S Where S.Mon = ' + @Mon + ' And T.[Customer Code] = S.CustomerId '  
      Exec sp_Executesql @Qry  
Fetch Next From @MonthSales Into @CustID,@Mon, @MonthName  
End  
Close @MonthSales  
DeAllocate @MonthSales  
  
Select  
"Customer Code1"=[Customer Code],  
"Customer Code"=[Customer Code],  
"Customer Name"=[Customer Name],  
"Beat"=(Select Description From Beat Where BeatID=(Select DefaultBeatID From Customer   
Where CustomerId = T.[Customer Code])) ,  
"Customer Type"=[Customer Type], 
"Channel Type" = [Channel Type], 
"Outlet Type" = [Outlet Type], 
"Loyalty Program" = [Loyalty Program],
"Sub Channel"=[Sub Channel],  
"April"=April,  
"May"=May,  
"June"=June,  
"July"=July,  
"August"=August,  
"September"=September,  
"October"=October,  
"November"=November,  
"December"=December,  
"January"=January,  
"February"=February,  
"March"=March  
from #tmpCustMonthSales T order by [Customer Code]  
  
Drop Table #tmpCustMonthSales  
Drop Table #OLClassMapping
end  
