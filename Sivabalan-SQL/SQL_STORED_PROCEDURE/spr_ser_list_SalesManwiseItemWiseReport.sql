CREATE procedure [dbo].[spr_ser_list_SalesManwiseItemWiseReport](@SManName Varchar(2550),
@FromDate Datetime,@ToDate Datetime)  
As  

Declare @SalesManName NVarchar(100)  
Declare @Product_Code NVarchar(30)  
Declare @ItemValue Decimal(18,6)  
Declare @StrSql1 Varchar(8000)  
Declare @Columns Varchar(8000)  
Declare @OldSManid Int
Declare @SManID Int


Set @OldSManid = -1  
Set @Columns = ''  
Set @StrSql1 = ''  

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  

Create table #TmpSalesMan(SalesMan_Name Varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS) 

If @SManName='%'
Insert Into #TmpSalesMan Select SalesMan_Name From SalesMan
Else
Insert Into #TmpSalesMan Select * From dbo.Sp_Ser_SplitIn2Rows(@SManName, @Delimeter)	


Create Table #Temp(SalesManID Int,
SalesManName NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
Product_Code NVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
ItemValue Decimal(18,6))  

Create Table #Temp5(SalesManID Int,
SalesManName NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)  

IF(@SmanName='%')  

Begin 
-- Invoice 
Insert into #Temp  
Select InvoiceAbstract.SalesManid,  
(Case InvoiceAbstract.SalesManid When 0 then 'Others' Else SalesMan.SalesMan_Name End),  
InvoiceDetail.Product_Code,  
Sum(Case When InvoiceAbstract.InvoiceType In (4, 5, 6) Then 0 - InvoiceDetail.Amount Else InvoiceDetail.Amount End)  
From InvoiceDetail,InvoiceAbstract,SalesMan   
Where InvoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID  
And InvoiceAbstract.SalesManID *=SalesMan.SalesManID  
And InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate  
And IsNull(InvoiceAbstract.Status,0) & 128 = 0  
Group By InvoiceAbstract.SalesManID,InvoiceDetail.Product_Code,SalesMan.SalesMan_Name  

--Service Invoice
Insert into #Temp  
Select 0,'Others', 
SerDet.SpareCode,Sum(IsNull(SerDet.NetValue,0))  
From ServiceInvoiceDetail SerDet,ServiceInvoiceAbstract SerAbs
Where SerAbs.ServiceInvoiceID=SerDet.ServiceInvoiceID  
And SerAbs.ServiceInvoiceDate Between @FromDate And @ToDate  
And IsNull(SerAbs.Status,0) & 192 = 0  
And IsNull(SpareCode,'') <> ''
And IsNull(SerAbs.ServiceInvoiceType,0) = 1
Group By SerDet.SpareCode

End  

Else  

Begin

-- Invoice 
Insert into #Temp  
Select InvoiceAbstract.SalesManid,  
SalesMan.SalesMan_Name,  
InvoiceDetail.Product_Code,  
Sum(Case When InvoiceAbstract.InvoiceType In (4, 5, 6) Then 0-InvoiceDetail.Amount Else InvoiceDetail.Amount End)  
From InvoiceDetail,InvoiceAbstract,SalesMan   
Where InvoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID  
And InvoiceAbstract.SalesManID = SalesMan.SalesManID  
And SalesMan.SalesMan_Name IN ( Select SalesMan_Name COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpSalesMan)  
And InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate  
And IsNull(InvoiceAbstract.Status,0) & 128 = 0  
Group By InvoiceAbstract.SalesManID,InvoiceDetail.Product_Code,SalesMan.SalesMan_Name  

--Service Invoice
Insert into #Temp  
Select 0,'Others', 
SerDet.SpareCode,Sum(IsNull(SerDet.NetValue,0))
From ServiceInvoiceDetail SerDet,ServiceInvoiceAbstract SerAbs
Where SerAbs.ServiceInvoiceID=SerDet.ServiceInvoiceID  
And SerAbs.ServiceInvoiceDate Between @FromDate And @ToDate  
And IsNull(SerAbs.Status,0) & 192 = 0  
And IsNull(SpareCode,'') <> ''
And IsNull(SerAbs.ServiceInvoiceType,0) = 1
Group By SerDet.SpareCode

End  

--Get the Columns From the #Temp Table  

Declare TableColumn Cursor FOR  

Select Distinct Product_Code From #Temp Order by Product_Code Asc  

Open TableColumn  

Fetch Next From TableColumn into @Product_Code  
While @@Fetch_STATUS =0  
Begin
Select @Columns = 'Alter table #Temp5 Add [' + @Product_Code + '] Decimal(18,6) Default(0)'  
Exec(@Columns)  
Fetch Next From TableColumn into @Product_Code  
End   
Close TableColumn  
Deallocate TableColumn  

Exec('Alter table #Temp5 Add [Total] Decimal(18,6)')  
	
Declare SalesManTotal Cursor FOR  

Select SalesManID,SalesManName,Product_Code,Sum(IsNull(ItemValue,0)) 
From #Temp 
Group by Salesmanid,SalesManName,Product_Code 
Order by SalesManID Asc,Product_code Asc

Open SalesManTotal    
Fetch Next From SalesManTotal into @SManID,@SalesManName,@Product_Code,@ItemValue  
While @@Fetch_STATUS =0   
Begin

IF (@OldSManid <> @SManID)   

Begin
Select @StrSql1='Insert into #Temp5(SalesManID,SalesManName) Values ('+ Cast(@SManID as Varchar) + ',''' + @SalesManName + ''') ;'  
Exec(@strSql1)  
End  

Select @OldSManid=@SManID  
Select @StrSql1='Update #Temp5 Set ['+ @Product_Code + '] = ' + Cast(@ItemValue as Varchar) + ' , 
[Total] = IsNull(Total,0) + ' + Cast(@ItemValue as Varchar) + ' 
Where SalesManID ='+ Cast(@SManId as Varchar) + ' ;'  
Exec(@StrSql1) 

Fetch Next From SalesManTotal into @SManID,@SalesManName,@Product_Code,@ItemValue  
End  

Close SalesManTotal  
Deallocate SalesManTotal  

Select @StrSql1 ='Select * From #Temp5 Order by SalesManID Desc'  
Exec(@StrSql1)  

Drop Table #Temp  
Drop Table #Temp5  
Drop Table #TmpSalesMan
