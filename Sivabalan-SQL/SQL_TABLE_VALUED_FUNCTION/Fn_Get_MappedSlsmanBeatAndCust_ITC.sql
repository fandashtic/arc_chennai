CREATE Function [dbo].[Fn_Get_MappedSlsmanBeatAndCust_ITC]  
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

Declare @CustomerID As NVarChar(30)  
  
Select @CustomerID = CustomerID From Customer Where Company_Name = @Customer  
  
If IsNull(@CustomerID,'') = ''  
 Set @CustomerID = @Customer  
  
  
If @SalesManID <> 0 And @BeatID = 0 And @CustomerID = ''  
	Insert Into @MappingTable  
	Select   
			Beat_SalesMan.SalesManID,"SalesMan_Name"=dbo.GetSalesManNameFromID(SalesManID),  
			BeatID,"Description"=dbo.GetBeatDescriptionFromID(BeatID),'','',''
	From   
			Beat_SalesMan 
	Where   
			SalesManID=@SalesManID   
Order By  
			Beat_SalesMan.SalesManID,SalesMan_Name,
			Beat_SalesMan.BeatID,  
			Description  
Else  
	Insert Into @MappingTable  
	Select   
			Beat_SalesMan.SalesManID,SalesMan_Name,Beat_SalesMan.BeatID,  
			Beat.Description,'','',''
	From   
			Beat_salesMan, 
			(Select BeatID,Description,Active From Beat Where Active = 1) Beat, 
			(Select SalesManID,SalesMan_Name,Active From Salesman Where Active = 1)	SalesMan--,
	Where  
			Beat.BeatID = (Case When @BeatID <> 0 Then @BeatID Else Beat.BeatID End) 
			And SalesMan.SalesManID = (Case When @SalesManID <> 0 Then @SalesManID Else SalesMan.SalesManID End) 
			and Beat_SalesMan.BeatID =  Beat.BeatID 
			And Beat_SalesMan.SalesManID = SalesMan.SalesManID 
	Order By  
			Beat_SalesMan.SalesManID,SalesMan_Name,Beat_SalesMan.BeatID,  
			Beat.Description
Return  
End
