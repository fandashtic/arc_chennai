CREATE PROCEDURE [dbo].[sp_load_Points_Customer](        
 @Segment nvarchar(250),                                
 @Channel nvarchar(250),                                
 @Beat nvarchar(250),                            
 @Active integer)                                
As                
Declare @Delimeter char(1)                        
Declare @SegmentID int      
Declare @cur_Seg as cursor        
Set @Delimeter=','                      
      
Create Table #tmpBeat(BeatID INT)                      
Create Table #tmpChannel(ChannelType Int)            
Create Table #tmpSegment(SegmentID Int)            
Create Table #tmpSegmentID(SegmentID Int,SegmentName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
      
If @Beat =N'%'                    
 Insert Into #tmpBeat(BeatID)  Select BeatID from Beat where Active=1                    
Else                    
 Insert Into #tmpBeat(BeatID)  Select * from dbo.Sp_SplitIn2Rows(@Beat ,@Delimeter)                      
                    
If @Channel=N'%'                    
 Insert Into #tmpChannel(ChannelType) Select ChannelType from Customer_Channel Where Active=1            
Else                    
 Insert Into #tmpChannel(ChannelType) Select * from dbo.Sp_SplitIn2Rows(@Channel,@Delimeter)                      
                    
If @Segment=N'%'                    
 Insert Into #tmpSegment(SegmentID) Select SegmentID From CustomerSegment Where Active=1            
Else                    
 Insert Into #tmpSegment(SegmentID) Select * From dbo.Sp_SplitIn2Rows(@Segment,@Delimeter)                      
              
--Gets the leaflevel segment for the passed segment        
Set @Cur_Seg = Cursor For Select SegmentID From #tmpSegment        
Open @Cur_Seg          
Fetch Next From @Cur_Seg Into @SegmentID          
While @@Fetch_status=0          
Begin          
 Insert Into #tmpSegmentID Select * From dbo.Fn_GetLeafLevelSegment(@SegmentID)          
 Fetch Next From @Cur_Seg Into @SegmentID          
End          
close @cur_Seg        
            
--Beat - Active Beat customers+ Customers For  whom the beat is not defined
--Channel - Active Channel customers+ Customers for whom the channel is not defined
--Segment - Specified segment customers
If @Beat='%' And @Channel='%'
Begin        
	Select Distinct C.CustomerID,C.Company_Name,        
	Isnull((Select Salesman_Name From SalesMan Where SalesManID=BS.SalesManID),N''),        
	Isnull((Select Description From Beat Where BeatID=BS.BeatID),N''),        
	Isnull(ChannelDesc,N''),        
	Isnull(S.SegmentName,N'')        
	From Customer C,Beat_Salesman BS,CustomerSegment S,Customer_Channel CH        
	Where        
	C.CustomerID*=BS.CustomerID        
	And C.SegmentID=S.SegmentID        
	And C.ChannelType*=CH.ChannelType        
	And (C.ChannelType In(Select isnull(ChannelType,0) From  #tmpChannel) or C.ChannelType <= 0)       
	And C.SegmentID In(Select isnull(SegmentID,0) From #tmpSegmentID)            
    And C.CustomerID Not In(Select isnull(CustomerID,'') From Beat_Salesman where BeatID In(Select BeatID From Beat Where Active=0))		
	And (C.Active=1 or C.Active=@Active)
	Order By Company_Name Asc        
End
--Beat - Active Beat customers+ Customers For  whom the beat is not defined
--Channel - Specified  Channel customers
--Segment - Specified segment customers
Else if @Beat='%' And @Channel<>'%'
Begin
	Select Distinct C.CustomerID,C.Company_Name,        
	Isnull((Select Salesman_Name From SalesMan Where SalesManID=BS.SalesManID),N''),        
	Isnull((Select Description From Beat Where BeatID=BS.BeatID),N''),        
	Isnull(ChannelDesc,N''),        
	Isnull(S.SegmentName,N'')        
	From Customer C,Beat_Salesman BS,CustomerSegment S,Customer_Channel CH        
	Where        
	C.CustomerID*=BS.CustomerID        
	And C.SegmentID=S.SegmentID        
	And C.ChannelType=CH.ChannelType        
	And C.ChannelType In(Select isnull(ChannelType,0) From  #tmpChannel)        
	And C.SegmentID In(Select isnull(SegmentID,0) From #tmpSegmentID)            
	And C.CustomerID Not In(Select isnull(CustomerID,'') From Beat_Salesman where BeatID In(Select BeatID From Beat Where Active=0))		
	And (C.Active=1 or C.Active=@Active)
	Order By Company_Name Asc        
End
--Beat - Specified Beat customers
--Channel - All Active Channel customers + Customers for whom the channel not defined
--Segment - Specified segment customers
Else if @Beat <>'%' And @Channel='%'
Begin
	Select Distinct C.CustomerID,C.Company_Name,        
	Isnull((Select Salesman_Name From SalesMan Where SalesManID=BS.SalesManID),N''),        
	Isnull((Select Description From Beat Where BeatID=BS.BeatID),N''),        
	Isnull(ChannelDesc,N''),        
	Isnull(S.SegmentName,N'')        
	From Customer C,Beat_Salesman BS,CustomerSegment S,Customer_Channel CH        
	Where        
	C.CustomerID=BS.CustomerID        
	And C.SegmentID=S.SegmentID        
	And C.ChannelType*=CH.ChannelType        
	And (C.ChannelType In(Select isnull(ChannelType,0) From  #tmpChannel)  or C.ChannelType <= 0)       
	And C.SegmentID In(Select isnull(SegmentID,0) From #tmpSegmentID)            
	And BS.BeatID In(Select isnull(BeatID,0) From #tmpBeat)        
	And (C.Active=1 or C.Active=@Active)
	Order By Company_Name Asc        
End
Else
--Beat - Specified Beat customers
--Channel -Specified Channel Customers
--Segment - Specified segment customers
Begin
	Select Distinct C.CustomerID,C.Company_Name,        
	Isnull((Select Salesman_Name From SalesMan Where SalesManID=BS.SalesManID),N''),        
	Isnull((Select Description From Beat Where BeatID=BS.BeatID),N''),        
	Isnull(ChannelDesc,N''),        
	Isnull(S.SegmentName,N'')        
	From Customer C,Beat_Salesman BS,CustomerSegment S,Customer_Channel CH        
	Where        
	C.CustomerID=BS.CustomerID        
	And C.SegmentID=S.SegmentID        
	And C.ChannelType=CH.ChannelType        
	And C.ChannelType In(Select isnull(ChannelType,0) From  #tmpChannel)        
	And C.SegmentID In(Select isnull(SegmentID,0) From #tmpSegmentID)            
	And BS.BeatID In(Select isnull(BeatID,0) From #tmpBeat)        
	And (C.Active=1 or C.Active=@Active)
	Order By Company_Name Asc        
End
        
Drop Table #tmpBeat            
Drop Table #tmpChannel            
Drop Table #tmpSegment                
Drop Table #tmpSegmentID          
Deallocate @cur_Seg
