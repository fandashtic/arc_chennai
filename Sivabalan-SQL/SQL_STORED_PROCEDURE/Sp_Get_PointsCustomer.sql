CREATE procedure [dbo].[Sp_Get_PointsCustomer](@Docserial int)  
As  

Create Table #tmpCustomer(CustomerID nVarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)
Insert Into #tmpCustomer Select CustomerID FROM PointsCustomer Where DocSerial=@DocSerial  
  
Select Distinct C.CustomerID,C.Company_Name,
Isnull((Select Salesman_Name From SalesMan Where SalesManID=BS.SalesManID),N''),
Isnull((Select Description From Beat Where BeatID=BS.BeatID),N''),
Isnull(ChannelDesc,N''),
Isnull(S.SegmentName,N'')
From Customer C,Beat_Salesman BS,Beat B,CustomerSegment S,Customer_Channel CH
Where
C.CustomerID In(Select CustomerID From #tmpCustomer)
And  C.CustomerID*=BS.CustomerID
And C.SegmentID=S.SegmentID
And C.ChannelType*=CH.ChannelType

Drop Table #tmpCustomer
