CREATE procedure [dbo].[Sp_Load_Customer](@CustomerID nVarchar(255))    
As    
Begin    
	Select Distinct     
	Isnull((Select Salesman_Name From SalesMan Where SalesManID=BS.SalesManID),N''),      
	Isnull((Select Description From Beat Where BeatID=BS.BeatID And Active=1),N''),      
	Isnull(ChannelDesc,N''),      
	Isnull(S.SegmentName,N'')      
	From Customer C,Beat_Salesman BS,Beat B,CustomerSegment S,SalesMan SM,Customer_Channel CH      
	Where      
	C.CustomerID*=BS.CustomerID      
	And C.SegmentID=S.SegmentID      
	And C.ChannelType=CH.ChannelType      
	And C.CustomerID=@CustomerID    
End
