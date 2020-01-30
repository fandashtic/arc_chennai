CREATE Procedure [dbo].[spr_list_SalesManwiseItemWiseReport](@SManName nvarchar(2550),@FromDate Datetime,@ToDate Datetime)  
as  
Declare @StrSql1 nVarchar(4000)  
Declare @SalesManName nvarchar(100)  
Declare @Columns nVarchar(4000)  
Declare @Product_Code nvarchar(30)  
Declare @ItemValue Decimal(18,6)  
Declare @SManID int  
Declare @OldSManid INT  
  
Set @OldSManID= -1  
set @Columns = ''  
Set @StrSql1 = ''  
 
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
Create table #tmpSalesMan(SalesMan_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS) 
If @SManName='%'
	Insert Into #tmpSalesMan Select SalesMan_Name From SalesMan
Else
	Insert Into #tmpSalesMan Select * From dbo.Sp_SplitIn2Rows(@SManName, @Delimeter)	
 
  
Create Table #Temp(SalesManID int,SalesManName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,Product_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,ItemValue Decimal(18,6))  
Create Table #Temp5(SalesManID int,SalesManName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Declare @OTHERS As NVarchar(50)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)
  
IF(@SmanName='%')  
Begin   
 Insert into #Temp  
  Select InvoiceAbstract.SalesManid,  
  (Case InvoiceAbstract.SalesManid when 0 then @OTHERS else SalesMan.SalesMan_Name end),  
  InvoiceDetail.Product_Code,  
  Sum(Case When InvoiceAbstract.InvoiceType In (4, 5, 6) Then 0-InvoiceDetail.Amount Else InvoiceDetail.Amount End)  
  From InvoiceDetail
  Inner Join InvoiceAbstract on InvoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID
  Left Outer Join SalesMan on InvoiceAbstract.SalesManID =SalesMan.SalesManID
  Where 
  --InvoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID  
  --And InvoiceAbstract.SalesManID *=SalesMan.SalesManID  
  --And 
  InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate  
  And InvoiceAbstract.Status & 128 = 0  
  Group By InvoiceAbstract.SalesManID,InvoiceDetail.Product_Code  
  ,SalesMan.SalesMan_Name  
End  
Else  
Begin  
 Insert into #Temp  
  Select InvoiceAbstract.SalesManid,  
  SalesMan.SalesMan_Name,  
  InvoiceDetail.Product_Code,  
  Sum(Case When InvoiceAbstract.InvoiceType In (4, 5, 6) Then 0-InvoiceDetail.Amount Else InvoiceDetail.Amount End)  
  From InvoiceDetail,InvoiceAbstract,SalesMan   
  Where InvoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID  
  And InvoiceAbstract.SalesManID =SalesMan.SalesManID  
  And SalesMan.SalesMan_Name IN ( Select SalesMan_Name COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpSalesMan)  
  And InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate  
  And InvoiceAbstract.Status & 128 = 0  
  Group By InvoiceAbstract.SalesManID,InvoiceDetail.Product_Code  
  ,SalesMan.SalesMan_Name  
End  
--Get the Columns of the Table  
Declare TableColumn Cursor FOR  
 Select Distinct Product_Code From #Temp Order by Product_Code Asc  
Open TableColumn  
FETCH NEXT FROM TableColumn into @Product_Code  
WHILE @@FETCH_STATUS =0  
BEGIN  
 SELECT @Columns = 'Alter table #temp5 Add [' + @Product_Code + '] Decimal(18,6) default(0)'  
 Exec(@Columns)  
 FETCH NEXT FROM TableColumn into @Product_Code  
END   
Close TableColumn  
Deallocate TableColumn  
Exec('Alter table #temp5 Add [Total] Decimal(18,6)')  
  
  
Declare SalesManTotal Cursor FOR  
 Select SalesManID,SalesManName,Product_Code,Isnull(ItemValue,0) From #Temp Order by SalesManID Asc,Product_code Asc  
Open SalesManTotal    
FETCH NEXT FROM SalesManTotal into @SManID,@SalesManName,@Product_Code,@ItemValue  
WHILE @@FETCH_STATUS =0   
BEGIN  
 IF (@OldSmanid <> @SManID)   
 Begin  
  Select @StrSql1='Insert into #Temp5(SalesManID,SalesManName) Values ('+ Cast(@SManID as nvarchar) + ',N''' + @SalesManName + ''') ;'  
   Exec(@strSql1)  
 End  
 Select @oldSManID=@SManID  
 Select @StrSql1='Update #Temp5 Set ['+ @Product_Code + '] = ' + Cast(@ItemValue as nvarchar) + ' , [Total] = ISnull(Total,0) + ' + Cast(@ItemValue as nvarchar) + ' Where SalesManID='+ Cast(@SManId as nvarchar) + ' ;'  
 Exec(@StrSql1)  
 FETCH NEXT FROM SalesManTotal into @SManID,@SalesManName,@Product_Code,@ItemValue  
END  
Close SalesManTotal  
Deallocate SalesManTotal  
  
Select @StrSql1 ='Select * from #Temp5 order by SalesManID Desc'  
Exec(@StrSql1)  
  
Drop Table #Temp  
Drop Table #Temp5  
Drop Table #tmpSalesMan  
