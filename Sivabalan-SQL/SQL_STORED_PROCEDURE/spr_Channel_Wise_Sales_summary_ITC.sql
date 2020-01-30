Create Procedure spr_Channel_Wise_Sales_summary_ITC(@FROMDATE DateTime,   
      @TODATE DateTime)       
As    
Declare @ChannelDesc varchar(255)        
Declare @StrQuery Varchar(8000)        
Declare @chnl Varchar(8000)        
Declare @Chnl1 Varchar(8000)        
Declare @Quantity Decimal(18, 6)    
Declare @ProductCode VarChar(255)  
  
Declare @NetValue As Decimal(18,6)  
Declare @SKU Varchar(50)      
Declare @SUBTOTAL Varchar(50)      
Declare @GRNTOTAL Varchar(50)      
Declare @WDCode Varchar(255), @WDDest Varchar(255)  
Declare @CompaniesToUploadCode Varchar(255)      
Declare @SPRExist Int   
  
Set @SKU = dbo.LookupDictionaryItem(N'Market SKU', Default)       
Set @SUBTOTAL = dbo.LookupDictionaryItem(N'SubTotal:', Default)       
Set @GRNTOTAL = dbo.LookupDictionaryItem(N'GrandTotal:', Default)       
  
-- Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload      
-- Select Top 1 @WDCode = RegisteredOwner From Setup        
      
-- If @CompaniesToUploadCode='ITC001'      
--  Set @WDDest= @WDCode      
-- Else      
-- Begin      
--  Set @WDDest= @WDCode      
--  Set @WDCode= @CompaniesToUploadCode      
-- End      
  
-- Create Table #TempConsolidate (  
  
Create table #tempCategory1 (IDS int Identity(1, 1),  CategoryID Int, Category Varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)  
Exec sp_CatLevelwise_ItemSorting  
  
Create Table #ChannelWiseSales (repid int, sid int,   
TempCat Varchar(256)COLLATE SQL_Latin1_General_CP1_CI_AS,        
Category Varchar(256)COLLATE SQL_Latin1_General_CP1_CI_AS,        
UOM Varchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)        
    
DECLARE Channel_Cursor CURSOR FOR         
 SELECT  distinct ChannelDesc FROM Customer_Channel Where IsNull(Active,0) = 1  
 Order By ChannelDesc   
OPEN Channel_Cursor          
FETCH NEXT FROM Channel_Cursor INTO @ChannelDesc          
WHILE @@FETCH_STATUS = 0        
BEGIN        
 Set @StrQuery = 'Alter Table #ChannelWiseSales Add [' + @ChannelDesc + '] Decimal(18, 6) Default 0 Not Null'      
 Set @chnl = IsNull(@chnl, '') + ', [' + IsNull(@ChannelDesc, '') + ']'  
 Set @Chnl1 = IsNull(@Chnl1, '') + ', [' + IsNull(@ChannelDesc, '') + '] = Sum([' + @ChannelDesc + '])'  

-- Exec sp_executesql @StrQuery         
 Exec (@StrQuery)

 FETCH NEXT FROM Channel_Cursor INTO @ChannelDesc      
END        
CLOSE Channel_Cursor        
DEALLOCATE Channel_Cursor        
  
----------  
create table #tab(ids Int Identity(1, 1),   
colfield Varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,   
recid Int, repid Int)  
  
Declare @recid int  
Declare @repid int  
  
create table #tmpcustchnl(chnlname Varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
fieldname Varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,   
wdssname Varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, repid Int)  
  
Declare @fldcount Int  
Declare @chnlName Varchar(255)  
Declare @wddsname Varchar(255)  
Declare @tempnocolumns int  
Declare @tempinicount int  
Declare @cpres Int  
Set @cpres = 0  
  
set @tempinicount = 1  
  
Create Table #tempnocolumns(ids int identity(1, 1), colmname Varchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)  
   
Insert Into #tempnocolumns Select IsNull(Field51, '') From Reports, ReportAbstractReceived   
Where Reports.ReportID In (Select Distinct ReportID From Reports Where   
ReportName = 'Channel Wise Sales Summary' And ParameterID In   
(Select ParameterID From dbo.GetReportParametersForChnLpNplCws('Channel Wise Sales Summary')   
Where   
FromDate = dbo.StripDateFromTime(@FromDate) And   
ToDate = dbo.StripDateFromTime(@ToDate))) And   
ReportAbstractReceived.Field2 = @SKU And   
ReportAbstractReceived.Field1 <>  @SUBTOTAL And   
ReportAbstractReceived.Field1 <> @GRNTOTAL And  
ReportAbstractReceived.ReportID = Reports.ReportID    
--And IsNull(Field' + Cast(@flc As Varchar) + ', '''') <> ''TotalQtySold'''  
  
Select ChannelDesc, Active Into #tempcc From customer_channel Where Active = 1  
  
select @tempnocolumns = Count(*) From #tempnocolumns  
  
--------------------  
-- select * from #tempnocolumns  
-- update #tempnocolumns set colmname = 'colone' where ids = 2  
--  select * from #tempnocolumns  
------------------------  
  
While @tempinicount <= @tempnocolumns  
Begin  
 Select @chnlName = colmname From #tempnocolumns where ids = @tempinicount  
-- select @chnlName  
 If @chnlName = ''  
 Begin  
  Set @fldcount = 50  
 End  
 Else   
 Begin  
  Set @fldcount = 512  
--  select @fldcount   
  break  
 End  
 set @tempinicount = @tempinicount + 1  
  
End  
  
Set @tempinicount = 1  
-------------------------------------------------------  
  
-- Select IsNull(Field51, '') From Reports, ReportAbstractReceived   
-- Where Reports.ReportID In (Select Distinct ReportID From Reports Where   
-- ReportName = 'Channel Wise Sales Summary' And ParameterID In   
-- (Select ParameterID From dbo.GetReportParametersForChnLpNplCws('Channel Wise Sales Summary')   
-- Where FromDate = dbo.StripDateFromTime(@FromDate) And   
-- ToDate = dbo.StripDateFromTime(@ToDate))) And   
-- ReportAbstractReceived.ReportID = Reports.ReportID   
-- And ReportAbstractReceived.Field2 = @SKU And   
-- ReportAbstractReceived.Field1 <>  @SUBTOTAL   
-- And ReportAbstractReceived.Field1 <> @GRNTOTAL   
  
-- select @fldcount  
  
---------------------------------------------------------  
  
If @chnlName = ''  
Begin  
 Set @fldcount = 50  
End  
Else   
Begin  
 Set @fldcount = 512  
End  
  
If (Select Count(*) From Reports Where ReportName = 'Channel Wise Sales Summary'   
And ParameterID In (Select ParameterID From   
dbo.GetReportParametersForChnLpNplCws('Channel Wise Sales Summary') Where       
FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))>=1      
Begin      
 Declare @flc Int  
-- Declare @chnlName Varchar(255)  
 Set @flc = 4  
 set @SPRExist =1    
 While @flc <= @fldcount  
 Begin  
--   Declare @chnlName Varchar(255)  
--   Set @chnlName = ''  
   Set @StrQuery = 'Insert Into #tab Select "col" = IsNull(Field' + Cast(@flc As Varchar) + ', ''''), RecordID, ReportAbstractReceived.ReportID  
   From Reports, ReportAbstractReceived   
   Where Reports.ReportID in               
   (Select Distinct ReportID From Reports    
   Where   
   ReportName = ''Channel Wise Sales Summary'' And   
   ParameterID in   
   (Select ParameterID From dbo.GetReportParametersForChnLpNplCws(''Channel Wise Sales Summary'')   
   Where   
   FromDate = dbo.StripDateFromTime(''' + Cast(@FromDate As Varchar) + ''') And   
   ToDate = dbo.StripDateFromTime(''' + Cast(@ToDate As Varchar) + ''')  
   ))      
   And ReportAbstractReceived.Field2 = ''' + @SKU + '''   
   And ReportAbstractReceived.Field1 <> ''' + @SUBTOTAL + '''   
   And ReportAbstractReceived.Field1 <> ''' + @GRNTOTAL + '''  
   And IsNull(Field' + Cast(@flc As Varchar) + ', '''') <> ''TotalQtySold''  
   And ReportAbstractReceived.ReportID = Reports.ReportID'  
--   select @StrQuery    
--   Exec sp_executesql @StrQuery  
   Exec (@StrQuery)
   ----------------------------------  
--   select * from #tab  
   ----------------------------------  
--   Select * From #tab  
    Select @tempnocolumns = Count(*) From #tab  
    While @tempinicount <= @tempnocolumns  
    Begin   
    Select @chnlName = Colfield, @recid = recid, @repid = repid From #tab Where ids = @tempinicount  
    Select @wddsname = Field1 From ReportAbstractReceived   
    Where RecordID = @recid + 1  
--    Truncate Table #tab  
--    Select * from #tab   
--    set @StrQuery = 'Select @chnlName'  
--    select @chnlName  
--    Select @chnlName, @flc, @wddsname, @repid   
    If @chnlName <> ''  
    Begin  
      
     Set @StrQuery = 'Insert Into #tmpcustchnl Values (''' + @chnlName + ''', ''Field' + Cast(@flc As Varchar) + ''', ''' + @wddsname + ''', ''' + Cast(@repid As Varchar) + '''  )'  

--     Exec sp_executesql @StrQuery  
     Exec (@StrQuery)

--     Select * From #tmpcustchnl  
     If (Select Count(*) From #tempcc Where Active = 1 And ChannelDesc = @chnlName) = 0  
     Begin  
--       Set @flc = @flc + 1  
--      End  
--      Else  
--      Begin  
--      select @chnlName  
      Insert InTo #tempcc Values (@chnlName, 2)  
--      Select * From #tempcc  
      If @cpres < 1   
      Begin  
       Set @cpres = 1  
       Set @chnlName = 'Other Channels'  
        Set @StrQuery = 'Alter Table #ChannelWiseSales Add [' + @chnlName + '] Decimal(18, 6) Default 0 Not Null'      
       Set @chnl = IsNull(@chnl, '') + ', [' + IsNull(@chnlName, '') + ']'  
       Set @Chnl1 = IsNull(@Chnl1, '') + ', [' + IsNull(@chnlName, '') + '] = Sum([' + @chnlName + '])'  

--       Exec sp_executesql @StrQuery         
       Exec (@StrQuery)
 --      Set @flc = @flc + 1  
       Set @chnlName = ''  
      End  
     End  
    End  
--     Else  
--     Begin  
--      Set @flc = @flc + 1  
--     End  
     Set @tempinicount = @tempinicount + 1  
    End  
   Truncate Table #tab  
   Set @flc = @flc + 1  
   Set @tempinicount = 1  
 End  
End  
  
-----------  
-- select @chnl  
--Select * from #tab   
-- select * from #tmpcustchnl  
----------  
  
Set @StrQuery = 'Alter Table #ChannelWiseSales Add TotalQtySold Decimal(18, 6) Default 0 Not Null'      
--Exec sp_executesql @StrQuery    
Exec (@StrQuery)
  
Declare @regown Varchar(255)  
  
Declare @ChannelType int  
Declare @StrPivotSql Varchar(8000)  
Declare @strPivotSql1 Varchar(8000)  
Declare @strPivotSql2 Varchar(8000)  
  
Set @strPivotSql1 = ''  
Set @strPivotSql2 = ''  
  
DECLARE Channel_Cursor CURSOR FOR         
 SELECT  distinct ChannelType,ChannelDesc FROM Customer_Channel Where IsNull(Active,0) = 1  
 Order By ChannelDesc   
OPEN Channel_Cursor          
FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc  
WHILE @@FETCH_STATUS = 0        
BEGIN        
 Set @strPivotSql1 = @strPivotSql1 + ', [' + @ChannelDesc + '] '  
 Set @strPivotSql2 = @strPivotSql2 + ', Sum(Case CT.ChannelType When ' + Cast(@ChannelType As Varchar) + 'Then IND.Quantity Else 0 End)'  
 FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc      
END        
CLOSE Channel_Cursor        
DEALLOCATE Channel_Cursor        
  
Set @strPivotSql1 = @strPivotSql1 + ', [TotalQtySold] '  
Set @strPivotSql2 = @strPivotSql2 + ', Sum(IND.Quantity) '  
Set @StrPivotSql = 'Insert Into #ChannelWiseSales (RepID, SID, TempCat, Category, UOM ' + LTrim(@strPivotSql1) +   
') Select 0,TCat.Ids, s.RegisteredOwner, itc.Category_Name, UOM.[Description] ' + LTrim(@strPivotSql2) +  
'From Setup s, ItemCategories itc, Items itm , UOM, #tempCategory1 TCat,  
InvoiceAbstract IA, InvoiceDetail IND, Customer CM, Customer_Channel CT  
Where IsNull(IA.Status,0) & 192 = 0    
And IA.InvoiceType IN (1,3)    
And IA.InvoiceDate Between '''+ Cast(@FromDate As Varchar)+ ''' And ''' + Cast(@ToDate As Varchar) +  
''' And IA.InvoiceID = IND.InvoiceID    
And itm.Product_code = IND.Product_Code  
And CM.ChannelType = CT.ChannelType    
And IA.CustomerID = CM.CustomerID   
And itc.CategoryID = itm.CategoryID   
And UOM.UOM = itm.UOM    
And TCat.CategoryID = itc.CategoryID  
Group By TCat.Ids, s.RegisteredOwner, itc.Category_Name, UOM.[Description]'  
  
--Exec sp_executesql @StrPivotSql  
Exec (@StrPivotSql)
  
-- Select @StrPivotSql  
  
Insert Into #ChannelWiseSales (repid, sid, TempCat, Category, UOM)    
select 0, #tempCategory1.Ids, s.RegisteredOwner, itc.Category_Name, UOM.[Description]  
From Setup s, ItemCategories itc, Items itm , UOM, #tempCategory1  
Where itc.CategoryID = itm.Categoryid  
And UOM.UOM = itm.UOM    
And itc.CategoryID = #tempCategory1.CategoryID  
And #tempCategory1.CategoryID Not In (Select Distinct SID from #ChannelWiseSales)  
Group By #tempCategory1.Ids, s.RegisteredOwner, itc.Category_Name, UOM.[Description]  
  
  
-- Insert Into #ChannelWiseSales (repid, sid, TempCat, Category, UOM)    
-- select 0, #tempCategory1.Ids, s.RegisteredOwner, itc.Category_Name, UOM.[Description]  
-- From Setup s, ItemCategories itc, Items itm , UOM, #tempCategory1  
-- Where itc.CategoryID = itm.Categoryid  
-- And UOM.UOM = itm.UOM    
-- And itc.CategoryID = #tempCategory1.CategoryID  
-- Group By #tempCategory1.Ids, s.RegisteredOwner, itc.Category_Name, UOM.[Description]  
--   
-- Set @Quantity = 0    
-- DECLARE Channel_Cursor CURSOR FOR         
--  SELECT  Distinct ChannelDesc FROM Customer_Channel Where IsNull(Active,0) = 1        
-- OPEN Channel_Cursor          
-- FETCH NEXT FROM Channel_Cursor INTO @ChannelDesc          
-- WHILE @@FETCH_STATUS = 0        
-- BEGIN        
--  DECLARE Product_Cursor CURSOR FOR         
--  Select Category, TempCat From #ChannelWiseSales Where TempCat In (Select top 1 Registeredowner from   
--  setup)  
--  OPEN Product_Cursor    
--  FETCH NEXT FROM Product_Cursor INTO @ProductCode, @regown   
--  WHILE @@FETCH_STATUS = 0        
--  BEGIN        
--   select @Quantity = Sum(IND.Quantity)  
--   From InvoiceAbstract IA, InvoiceDetail IND, Customer CM,   
--   Customer_Channel CT, Items its, ItemCategories itc  
--   Where IsNull(IA.Status,0) & 192 = 0    
--   And IA.InvoiceType IN (1,3)    
--   And IA.InvoiceDate Between @FromDate And @ToDate    
--   And itc.Category_Name = @ProductCode    
--   And CT.ChannelDesc = @ChannelDesc    
--   And IA.InvoiceID = IND.InvoiceID    
--   And CM.ChannelType = CT.ChannelType    
--   And IA.CustomerID = CM.CustomerID    
--   And its.CategoryID = itc.CategoryID  
--   And IND.Product_Code = its.Product_code  
--   
--   
--   Set @StrQuery ='Update #ChannelWiseSales Set ['+ @ChannelDesc +'] = '  + Convert(Varchar, @Quantity) + '   
--   Where Category = ''' + @ProductCode + ''' And TempCat = ''' + @regown + ''''      
--   Exec sp_executesql @StrQuery          
--   
--   If @Quantity > 0     
--   Begin    
--    Set @StrQuery ='Update #ChannelWiseSales Set [TotalQtySold] = IsNull(TotalQtySold,0) + Convert(Decimal(18, 6), '  + Convert(Varchar, @Quantity) + ')   
--    Where Category = ''' + @ProductCode + ''' And TempCat = ''' + @regown + ''''   
--    Exec sp_executesql @StrQuery          
--   End    
--   FETCH NEXT FROM Product_Cursor INTO @ProductCode, @regown  
--  END         
--  CLOSE Product_Cursor        
--  DEALLOCATE Product_Cursor        
--  FETCH NEXT FROM Channel_Cursor INTO @ChannelDesc      
-- END         
-- CLOSE Channel_Cursor        
-- DEALLOCATE Channel_Cursor        
  
Declare @wddCode Varchar(25)  
  
  
Insert Into #ChannelWiseSales (repid, sid, TempCat, Category, UOM)    
Select ReportAbstractReceived.ReportID, #tempCategory1.Ids, Field1, Field2, Field3  
 From Reports, ReportAbstractReceived, #tempCategory1, itemcategories  
 Where ReportAbstractReceived.Field2 <> @SKU      
 and ReportAbstractReceived.Field1 <> @SUBTOTAL          
 and ReportAbstractReceived.Field1 <> @GRNTOTAL       
 And Reports.ReportID in               
 (Select Distinct ReportID From Reports                     
  Where ReportName = 'Channel Wise Sales Summary'  
  And ParameterID in   
  (Select ParameterID From dbo.GetReportParametersForChnLpNplCws('Channel Wise Sales Summary')   
   Where FromDate = dbo.StripDateFromTime(@FromDate) And   
      ToDate = dbo.StripDateFromTime(@ToDate)  
 ))   
 And itemcategories.CategoryID = #tempCategory1.CategoryID  
 And itemcategories.Category_Name = ReportAbstractReceived.Field2  
 And ReportAbstractReceived.ReportID = Reports.ReportID                  
 --And ReportAbstractReceived.Field3 In (Select * From #TempMarketSKU)      
  
Set @Quantity = 0    
Declare @fldname Varchar(255)  
Create Table #tmpqty(qty decimal (18, 6) --,   
--wddsn Varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, repid Int  
)  
Declare @fldqty Decimal(18, 6)  
Declare @wddsn Varchar(255)  
Declare @wdssname Varchar(255)  
Declare @repids Int  
Declare @OchnlD Varchar(255)  
Declare @Oids Int  
-- #tempcc  
--select *  from #ChannelWiseSales  
  
DECLARE Channel_Cursor CURSOR FOR         
 SELECT  chnlname, fieldname, wdssname, repid FROM #tmpcustchnl --Where IsNull(Active,0) = 1        
OPEN Channel_Cursor          
FETCH NEXT FROM Channel_Cursor INTO @ChannelDesc, @fldname, @wdssname, @repids  
WHILE @@FETCH_STATUS = 0        
BEGIN        
-- select @ChannelDesc, @fldname  
 DECLARE Product_Cursor CURSOR FOR         
 Select Category From #ChannelWiseSales  where TempCat = @wdssname And repid = @repids  
 OPEN Product_Cursor    
 FETCH NEXT FROM Product_Cursor INTO @ProductCode          
 WHILE @@FETCH_STATUS = 0        
 BEGIN     
    
  Set @StrQuery = 'insert into #tmpqty select [' + @fldname + ']   
  From ReportAbstractReceived, Reports  
  Where ReportAbstractReceived.Field2 = ''' + @ProductCode + '''  
  And Reports.ReportID in               
  (Select Distinct ReportID From Reports                     
  Where ReportName = ''Channel Wise Sales Summary''  
  And ParameterID in (Select ParameterID From dbo.GetReportParametersForChnLpNplCws(''Channel Wise Sales Summary'')   
                            Where FromDate = dbo.StripDateFromTime(''' + Cast(@FromDate As Varchar) + ''')   
       And ToDate = dbo.StripDateFromTime(''' + Cast(@ToDate as Varchar) + ''')  
       ))      
    
  and ReportAbstractReceived.Field2 <> ''' + @SKU + '''  
  and ReportAbstractReceived.Field1 <> ''' + @SUBTOTAL + '''  
  and ReportAbstractReceived.Field1 <> ''' + @GRNTOTAL + '''  
  and ReportAbstractReceived.Field1 = ''' + @wdssname + '''  
  and ReportAbstractReceived.ReportID = ' + Cast(@repids As Varchar) +'  
  And ReportAbstractReceived.ReportID = Reports.ReportID'  
  
--  Exec sp_executesql @StrQuery  
  Exec (@StrQuery)
--  select * from #tmpqty  
--  select @ProductCode  
  Select @fldqty = qty --, @wddsn = wddsn   
  from #tmpqty  
  Truncate table #tmpqty  
-- Declare @OchnlD Varchar(255)  
-- Declare @Oids Int  
-- #tempcc  
  Select @Oids = Active, @OchnlD = ChannelDesc From #tempcc Where ChannelDesc = @ChannelDesc  
  If @Oids = 2   
  Begin  
   Set @ChannelDesc = 'Other Channels'  
  End  
  
  Set @StrQuery ='Update #ChannelWiseSales Set ['+ @ChannelDesc +'] = IsNull([' + @ChannelDesc +'], 0) + ' + Convert(Varchar, @fldqty) + ' Where Category = ''' + @ProductCode +'''  
    And TempCat = ''' + @wdssname + ''' And repid = ' + Cast(@repids As Varchar)  
--  Exec sp_executesql @StrQuery          
  Exec (@StrQuery)
  
  If @fldqty > 0     
  Begin     
--   select @ProductCode , @wddsn, @fldqty  
--   select TotalQtySold from #ChannelWiseSales where Category =  @ProductCode And TempCat = @wddsn   
   Set @StrQuery ='Update #ChannelWiseSales Set [TotalQtySold] = IsNull(TotalQtySold,0) + Convert(Decimal(18, 6),'  + Convert(Varchar, @fldqty) + ') Where Category = ''' + @ProductCode +'''  
     And TempCat = ''' + @wdssname + ''' And repid = ' + Cast(@repids As Varchar)  
   Exec (@StrQuery)
   Set @fldqty = 0  
  End    
  FETCH NEXT FROM Product_Cursor INTO @ProductCode      
 END         
 CLOSE Product_Cursor        
 DEALLOCATE Product_Cursor        
  FETCH NEXT FROM Channel_Cursor INTO @ChannelDesc, @fldname, @wdssname, @repids  
--select @ChannelDesc, @fldname  
END         
CLOSE Channel_Cursor        
DEALLOCATE Channel_Cursor        
  
Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload      
Select Top 1 @WDCode = RegisteredOwner From Setup        
      
If @CompaniesToUploadCode='ITC001'      
Begin  
  
Update #ChannelWiseSales Set TempCat = @WDCode   
Where TempCat In (Select WareHouseID From Warehouse)  

End  
  
-- select @Chnl1  
  
Set @StrQuery = 'Select TempCat, "WD Dest. Code" = TempCat, "Market SKU" = Category,   
"UOM" = UOM' + @Chnl1 + ',  "TotalQtySold" = Sum(TotalQtySold)  
From #ChannelWiseSales   
Group By TempCat, Category, UOM, sid  
Order By sid'  
Exec (@StrQuery)
    
Drop Table #ChannelWiseSales    
Drop Table #tempCategory1  
Drop Table #tab  
Drop table #tmpcustchnl  
  
