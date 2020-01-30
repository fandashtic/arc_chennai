Create Procedure mERP_sp_List_Customer
(
@Salesman nVarchar(500)= N'',      
@Beat nVarchar(500) = N'',   
@Active Int
)
As
Begin
	Create Table #tmpSalesMan(SalesManID Int)        
	Create Table #tmpBeat(BeatID Int)
	Create Table #tmpCustomer(CustomerID nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS ,
							  CustomerName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
							  Active nVarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS)	      
	
        
	If @SalesMan = N''        
	Begin  
		Insert Into #tmpSalesMan Values(0)  
		Insert InTo #tmpSalesMan Select SalesmanID From SalesMan Where Active = 1        
	End  
	Else        
		Insert InTo #tmpSalesMan Select * From sp_SplitIn2Rows(@SalesMan,N',')         
    
        
	If @Beat = N''         
	Begin  
		Insert Into #tmpBeat Values(0)  
		Insert InTo #tmpBeat Select BeatID From Beat Where Active = 1        
	End  
	Else    
		Insert InTo #tmpBeat Select * From sp_SplitIn2Rows(@Beat,N',')      	


	Insert Into #tmpCustomer
	Select Distinct C.CustomerID ,C.Company_Name ,(Case C.Active When 1 Then 'Yes' Else 'No' End)--,C.Remarks
	From 
		Customer C,Beat_Salesman BS,Salesman SM,Beat B
	Where 
		C.Active = ( Case @Active When -1 Then C.Active When 1 Then 1 Else  0 End) And 
		C.CustomerID = BS.CustomerID And 
		SM.SalesmanID = BS.SalesmanID And
		B.BeatID = BS.BeatID And
		isNull(BS.CustomerID,'') <> '' And
		isNull(BS.SalesmanID,0) <> 0 And
		isNull(BS.BeatID,0) <> 0 And 
		SM.SalesmanID In (Select SalesmanID From #tmpSalesMan) And 
		B.BeatID In (Select BeatID From #tmpBeat)
	Order By C.Company_Name

	
	Select Count(*) From  #tmpCustomer

	Select * From #tmpCustomer

End

