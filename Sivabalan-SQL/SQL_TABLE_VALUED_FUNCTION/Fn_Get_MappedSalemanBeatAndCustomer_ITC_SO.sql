Create Function Fn_Get_MappedSalemanBeatAndCustomer_ITC_SO  
(  
 @SalesManID Int =0,  
 @BeatID Int = 0,  
 @Customer NVarchar(300) = ''  
)  
Returns @MappingTable Table  
(  
 SalesManID Int,  
 SalesMan_Name NVarchar(100)COLLATE SQL_Latin1_General_CP1_CI_AS,  
 BeatID Int,  
 BeatName NVarchar(510)COLLATE SQL_Latin1_General_CP1_CI_AS , 
 CustomerID NVarchar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,  
 Company_Name NVarchar(300)COLLATE SQL_Latin1_General_CP1_CI_AS,  
 Address NVarchar(510)COLLATE SQL_Latin1_General_CP1_CI_AS  
)  
As  
Begin  
--Declare @TSalesMan Table (SalesManID Int)  
--Declare @TBeat Table (BeatID Int)  
--Declare @TCustomer Table (CustomerID nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Declare @CustomerID As NVarChar(30)  
  
Select @CustomerID = CustomerID From Customer Where Company_Name = @Customer  
  
If IsNull(@CustomerID,'') = ''  
 Set @CustomerID = @Customer  
  
--If @SalesManID = 0   
-- Insert Into @TSalesMan Select SalesManID from SalesMan Where Active = 1   
--Else  
-- Insert Into @TSalesMan Values (@SalesManID)   
--  
--If @BeatID = 0   
-- Insert Into @TBeat Select BeatID from Beat Where Active = 1   
--Else  
-- Insert Into @TBeat Values (@BeatID)   
--  
--If @CustomerID = ''   
-- Insert Into @TCustomer Select CustomerID from Customer Where Active = 1   
--Else  
-- Insert Into @TCustomer Values (@CustomerID)  
  
If @SalesManID <> 0 And @BeatID = 0 And @CustomerID = ''  
	Insert Into @MappingTable  
	Select   
			Beat_SalesMan.SalesManID,"SalesMan_Name"=dbo.GetSalesManNameFromID(SalesManID),  
			BeatID,"Description"=dbo.GetBeatDescriptionFromID(BeatID),
			Beat_SalesMan.CustomerID,"Company_Name"=dbo.GetCustomerNameFromID(Beat_SalesMan.CustomerID),   
			Customer.BillingAddress as Address  
	From   
			Beat_SalesMan , Customer   
	Where   
			SalesManID=@SalesManID   
			And Beat_SalesMan.CustomerID = Customer.CustomerID  
	Order By  
			Beat_SalesMan.SalesManID,SalesMan_Name,
			Beat_SalesMan.BeatID,  
			Description  ,Beat_SalesMan.CustomerID,Company_Name  
Else  
	Insert Into @MappingTable  
	Select   
			Beat_SalesMan.SalesManID,SalesMan_Name,Beat_SalesMan.BeatID,  
			Beat.Description,Customer.CustomerID,Company_Name,  
			Customer.BillingAddress as Address  
	From   
			Beat_salesMan, 
			(Select BeatID,Description,Active From Beat Where Active = 1) Beat, 
			(Select SalesManID,SalesMan_Name,Active From Salesman Where Active = 1)	SalesMan,
			(Select CustomerID,Company_Name,BillingAddress From Customer Where Active = 1) Customer   
	Where  
			Beat.BeatID = (Case When @BeatID <> 0 Then @BeatID Else Beat.BeatID End) 
			And SalesMan.SalesManID = (Case When @SalesManID <> 0 Then @SalesManID Else SalesMan.SalesManID End) 
			And Customer.CustomerID = (Case When @CustomerID <> '' Then @CustomerID Else Customer.CustomerID End)
			and Beat_SalesMan.BeatID =  Beat.BeatID 
			And Beat_SalesMan.SalesManID = SalesMan.SalesManID 
			And Beat_SalesMan.CustomerID = Customer.CustomerID
			-- And Beat_SalesMan.SalesManID In (Select SalesManID From @TSalesMan)  
			--And Beat_SalesMan.BeatID In (Select BeatID from @TBeat)  
			--And Beat_SalesMan.CustomerID In (Select CustomerID from @TCustomer)  
	Order By  
			Beat_SalesMan.SalesManID,SalesMan_Name,Beat_SalesMan.BeatID,  
			Beat.Description,Customer.CustomerID,Company_Name  
Return  
End  

