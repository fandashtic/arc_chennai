Create procedure sp_listinvoiceSR
(@fromdate datetime,
@todate datetime, 
@CUSTOMER nvarchar(15) = '%',
@SalesMan nVarchar(500) = N'',  
@Beat nVarchar(500) = N'',  
@Channel Int = 0,  
@SubChannel Int =0)   
As
Begin

Create Table #tblSalesman(SalesManID Int)      
Create Table #tblBeat(BeatID Int)      
Create Table #tblChannel(ChannelID Int)  
Create Table #tblSubChannel(SubChannelID Int)  
      
If @SalesMan = N''      
    Insert InTo #tblSalesman Select SalesmanID From SalesMan Where Active = 1      
Else      
	Insert InTo #tblSalesman Select * From sp_SplitIn2Rows(@SalesMan,N',')       
  
      
If @Beat = N''       
	Insert InTo #tblBeat Select BeatID From Beat Where Active = 1      
Else  
	Insert InTo #tblBeat Select * From sp_SplitIn2Rows(@Beat,N',')      
    

If @Channel = 0 
	Begin 
		Insert Into #tblChannel Values(0)
		Insert Into #tblChannel Select ChannelType From Customer_Channel Where Active = 1    
	End
Else  
	Insert Into #tblChannel Values(@Channel)  
   

If @SubChannel = 0  
	Begin
		Insert Into #tblSubChannel Values(0)
		Insert Into #tblSubChannel Select  SubChannelID From SubChannel Where Active =1    
	End
Else  
	Insert Into #tblSubChannel Values(@SubChannel)  
  
  
select 
	Customer.CustomerID, Customer.Company_Name, InvoiceID, InvoiceDate, NetValue, 
	InvoiceType, DocumentID,DocReference,DocSerialType,
  "CatGrp" = Case When IsNull(InvoiceAbstract.GroupID,'0') = '0'
  --Then 'All Category' Else ProductCategoryGroupAbstract.GroupName End
	Then 'All Category' Else dbo.mERP_fn_Get_GroupNames(GroupID) End,isnull(GSTFullDocID, '') as GSTFullDocID
from 
	InvoiceAbstract, Customer --, ProductCategoryGroupAbstract
where   
	invoicedate between @fromdate and @todate and 
	invoicetype <> 4 and invoicetype <> 2 and
	InvoiceAbstract.CustomerID like @CUSTOMER and
	Status & 128 = 0 And
	InvoiceAbstract.CustomerID = Customer.CustomerID
  --And InvoiceAbstract.GroupID *= ProductCategoryGroupAbstract.GroupID
	And Isnull(InvoiceAbstract.BeatID,0) In (Select  BeatId From #tblBeat)    
	And Isnull(InvoiceAbstract.SalesmanID,0) In (Select SalesmanID From #tblSalesman)  
	And IsNull(Customer.ChannelType,0) In (Select ChannelID From #tblChannel)  
	And IsNull(Customer.SubChannelID,0) In (Select SubChannelID From #tblSubChannel)  
order by 
	Customer.Company_Name, InvoiceID Desc

Drop Table #tblSalesman      
Drop Table #tblBeat
Drop Table #tblChannel
Drop Table #tblSubChannel

End

