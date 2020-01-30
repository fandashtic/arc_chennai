

CREATE Procedure sp_get_BeatSalesmanCustomerCount(@SmID int,@BtID int)  
As  
Begin  
	Declare @Cnt int  
	Select @Cnt=IsNull(Count(CustomerID),0) From Beat_Salesman Where SalesmanID=@SmID And BeatID=@BtID And IsNull(CustomerID,'') <> ''  

	If IsNull(@Cnt,0)=1  
		Select CustomerID,Company_Name From Customer Where CustomerID In (Select IsNull(CustomerID,0) From Beat_Salesman Where SalesmanID=@SmID And BeatID=@BtID And IsNull(CustomerID,'') <> ''  )  
	Else  
		 Select -1,-1  
End  

