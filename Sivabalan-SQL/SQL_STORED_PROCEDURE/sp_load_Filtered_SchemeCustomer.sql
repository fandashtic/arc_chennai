CREATE procedure [dbo].[sp_load_Filtered_SchemeCustomer](                        
 @Segment nvarchar(250),                        
 @Channel nvarchar(250),                        
 @Beat nvarchar(250),                    
 @Active integer)                        
as        
Begin  
Declare @Delimeter char(1)                
Declare @Cur_Seg Cursor  
Declare @SegmentID Int  
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
 
Set @Cur_Seg = Cursor For Select SegmentID From #tmpSegment    
Open @Cur_Seg      
Fetch Next From @Cur_Seg Into @SegmentID  
While @@Fetch_status=0      
Begin      
 Insert Into #tmpSegmentID Select * From dbo.Fn_GetLeafLevelSegment(@SegmentID)      
 Fetch Next From @Cur_Seg Into @SegmentID  
End      
close @Cur_Seg        

If @Beat='%' and @Channel='%'
Begin    
	Select  C.CustomerID,C.Company_Name,    
	Isnull((Select Salesman_Name From SalesMan Where SalesManID=BS.SalesManID),N''),    
	Isnull((Select Description From Beat Where BeatID=BS.BeatID),N''),    
	Isnull(S.SegmentName,N'')    
	From Customer C,Beat_Salesman BS,Beat B,CustomerSegment S 
	Where(C.Active=1 or C.Active=@Active)    
	And C.CustomerID*=BS.CustomerID    
	And (C.ChannelType In(Select isnull(ChannelType,0) From  #tmpChannel) or C.ChannelType <= 0)    
	And C.SegmentID=S.SegmentID    
	And C.SegmentID In(Select isnull(SegmentID,0) From #tmpSegmentID)        
	--And BS.BeatID In(Select isnull(BeatID,0) From #tmpBeat)    
	And C.CustomerID Not In(Select CustomerID From Beat_salesman Where BeatID In(Select BeatID From Beat Where Active=0))
End
Else if @Beat='%' and @Channel<>'%'
Begin
	Select  C.CustomerID,C.Company_Name,    
	Isnull((Select Salesman_Name From SalesMan Where SalesManID=BS.SalesManID),N''),    
	Isnull((Select Description From Beat Where BeatID=BS.BeatID),N''),    
	Isnull(S.SegmentName,N'')    
	From Customer C,Beat_Salesman BS,Beat B,CustomerSegment S 
	Where(C.Active=1 or C.Active=@Active)    
	And C.CustomerID*=BS.CustomerID    
	And C.ChannelType In(Select isnull(ChannelType,0) From  #tmpChannel)
	And C.SegmentID=S.SegmentID    
	And C.SegmentID In(Select isnull(SegmentID,0) From #tmpSegmentID)        
	--And BS.BeatID In(Select isnull(BeatID,0) From #tmpBeat)    
	And C.CustomerID Not In(Select CustomerID From Beat_salesman Where BeatID In(Select BeatID From Beat Where Active=0))
End
Else if @Beat<>'%' And @Channel='%'
Begin
	Select  C.CustomerID,C.Company_Name,    
	Isnull((Select Salesman_Name From SalesMan Where SalesManID=BS.SalesManID),N''),    
	Isnull((Select Description From Beat Where BeatID=BS.BeatID),N''),    
	Isnull(S.SegmentName,N'')    
	From Customer C,Beat_Salesman BS,Beat B,CustomerSegment S 
	Where(C.Active=1 or C.Active=@Active)    
	And C.CustomerID=BS.CustomerID    
	And (C.ChannelType In(Select Isnull(ChannelType,0) From  #tmpChannel) or C.ChannelType <= 0)
	And C.SegmentID=S.SegmentID    
	And C.SegmentID In(Select Isnull(SegmentID,0) From #tmpSegmentID)        
	And BS.BeatID In(Select Isnull(BeatID,0) From #tmpBeat)    
	And C.CustomerID Not In(Select CustomerID From Beat_salesman Where BeatID In(Select BeatID From Beat Where Active=0))
End
Else
Begin
	Select  C.CustomerID,C.Company_Name,    
	Isnull((Select Salesman_Name From SalesMan Where SalesManID=BS.SalesManID),N''),    
	Isnull((Select Description From Beat Where BeatID=BS.BeatID),N''),    
	Isnull(S.SegmentName,N'')    
	From Customer C,Beat_Salesman BS,Beat B,CustomerSegment S 
	Where(C.Active=1 or C.Active=@Active)    
	And C.CustomerID=BS.CustomerID    
	And C.ChannelType In(Select Isnull(ChannelType,0) From  #tmpChannel)
	And C.SegmentID=S.SegmentID    
	And C.SegmentID In(Select Isnull(SegmentID,0) From #tmpSegmentID)        
	And BS.BeatID In(Select Isnull(BeatID,0) From #tmpBeat)    
	And C.CustomerID Not In(Select CustomerID From Beat_salesman Where BeatID In(Select BeatID From Beat Where Active=0))
End

 
    
Drop Table #tmpBeat    
Drop Table #tmpChannel    
Drop Table #tmpSegment        
Drop Table #tmpSegmentID  
Deallocate @Cur_Seg    
  
End
