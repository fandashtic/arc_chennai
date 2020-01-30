CREATE PROCEDURE [dbo].[Spr_list_DSR] (@BRANDNAME Nvarchar(255),@Fromdate DateTime,@Todate DateTime)  
As    
Begin  
 Set DateFormat DMY  
  
 CREATE TABLE #Temp(  
 [Product_Code] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,  
 [Date] datetime NOT NULL,  
 [OpeningQty] [decimal](38, 6) NULL,  
 [TownRtl] Decimal(18,6) NOT NULL Default 0,  
 [TownSWD] Decimal(18,6) NOT NULL Default 0,  
 [VillageRtl] Decimal(18,6) NOT NULL Default 0,  
 [VillageSWD] Decimal(18,6) NOT NULL Default 0,  
 [OtherSales] Decimal(18,6) NOT NULL Default 0,  
 [TotalQty] Decimal(18,6) NOT NULL Default 0)  
  
 CREATE TABLE #TempInv(  
 [Invoicedate] DateTime,  
 [CustomerId] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,  
 [Product_Code] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,  
 [Quantity] [decimal](38, 6) NULL)  
  
 CREATE TABLE #TempCust(  
 [CustomerId] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,  
 Area Int,  
 [Type] Int,  
 ColID [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL)  
  
 Insert Into #TempCust  
 select Distinct CustomerId,SubChannelId,TradeCategoryId,0 from customer  
  
 Update #TempCust set ColID = 'TR' Where Area = 1 and [Type] = 1  
 Update #TempCust set ColID = 'TW' Where Area = 1 and [Type] = 2  
 Update #TempCust set ColID = 'VR' Where Area = 2 and [Type] = 1  
 Update #TempCust set ColID = 'VW' Where Area = 2 and [Type] = 2  
   
 Insert Into  #Temp  
 select I.Product_code ItemCode,OP.Opening_Date Date,Sum(OP.Opening_Quantity) OpeningQty,0 TownRtl,0 TownSWD,0 VillageRtl,0 VillageSWD,0 Othersales,0 Total   
 From OpeningDetails OP,items I , tblCGDivMapping GR, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2   
 where dbo.stripdatefromtime(Opening_Date) Between @Fromdate and @Todate And  
 I.Product_code = Op.Product_code And  
 IC4.categoryid = i.categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid   
 and IC2.Category_Name = GR.Division and GR.Division Like @BRANDNAME  
 Group by OP.Opening_Date,I.Product_Code  
  
 Insert Into #TempInv  
 select dbo.stripdatefromtime(IA.Invoicedate),(IA.CustomerId), Id.Product_Code,Sum(Case IA.InvoiceType When (1) Then Id.Quantity When (3) Then Id.Quantity When 4 Then ((-1) * (Id.Quantity)) End) Qty from invoicedetail ID, InvoiceAbstract IA   
 Where Id.InvoiceId = IA.InvoiceId  
 And dbo.stripdatefromtime(IA.Invoicedate) Between @Fromdate and @Todate  
 And IA.InvoiceType in (1,3)   
 And (IA.Status & 128) = 0  
 Group By IA.Invoicedate,IA.CustomerId,ID.Product_Code  
  
 update T Set T.TownRtl = T1.Quantity From #Temp T,#TempInv T1  Where T.Product_Code = T1.Product_Code and T.Date = T1.Invoicedate And T1.CustomerId in (select Distinct CustomerId From #TempCust Where ColID = 'TR')  
 update T Set T.TownSWD = T1.Quantity From #Temp T,#TempInv T1  Where T.Product_Code = T1.Product_Code and T.Date = T1.Invoicedate And T1.CustomerId in (select Distinct CustomerId From #TempCust Where ColID = 'TW')  
 update T Set T.VillageRtl = T1.Quantity From #Temp T,#TempInv T1  Where T.Product_Code = T1.Product_Code and T.Date = T1.Invoicedate And T1.CustomerId in (select Distinct CustomerId From #TempCust Where ColID = 'VR')  
 update T Set T.VillageSWD = T1.Quantity From #Temp T,#TempInv T1  Where T.Product_Code = T1.Product_Code and T.Date = T1.Invoicedate And T1.CustomerId in (select Distinct CustomerId From #TempCust Where ColID = 'VW')  
 update T Set T.OtherSales = T1.Quantity From #Temp T,#TempInv T1  Where T.Product_Code = T1.Product_Code and T.Date = T1.Invoicedate And T1.CustomerId in (select Distinct CustomerId From #TempCust Where ColID Not In ('TR','TW','VR','VW'))  
  
 update #Temp Set TotalQty = (TownRtl + TownSWD + VillageRtl + VillageSWD + OtherSales)  
  
 select 1, * from #Temp  
  
 Drop table #Temp  
 Drop table #TempInv  
 Drop table #TempCust  
End
