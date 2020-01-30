CREATE procedure [dbo].[sp_Load_Customer_Campaign_Chevron]
(
 @ChannelType NVarChar(250),                      
 @Level Int,
 @SegmentID NVarChar(250),
 @BeatName NVarChar(250),  
 @Active Int     
)                      

As                      

Declare @Cur_SegmentId As Cursor  
Declare @Segment_ID As Int
Declare @Delimeter as Char(1)
Set @Delimeter=Char(44)

Create Table #TempChannel(ChannelID Int)  
Create Table #TmpSegmentId(SegmentId int)   
Create Table #TempSegment(SegmentId Int)  
Create Table #TempBeat(Beat Int)  
  
Insert Into #TempChannel(ChannelID) Values('')
If @ChannelType =N'%'  
 If @Active=1  
  Insert Into #TempChannel Select ChannelType From Customer_Channel Where Active=1  
 Else  
  Insert Into #TempChannel Select ChannelType From Customer_Channel   
Else  
 If @Active=1  
  Insert Into #TempChannel Select ChannelType From Customer_Channel Where ChannelDesc = @ChannelType And  Active=1  
 Else  
  Insert Into #TempChannel Select ChannelType From Customer_Channel Where ChannelDesc = @ChannelType  

If @SegmentID =N'%'  
 Insert Into #TmpSegmentId Select SegmentId From CustomerSegment Where Level = @Level And Active = 1
Else  
 Insert Into #TmpSegmentId Select * from dbo.sp_SplitIn2Rows(@SegmentID,@Delimeter)

Set @Cur_SegmentId = Cursor for Select cast(SegmentId as int) From #TmpSegmentId
Open @Cur_SegmentId
Fetch Next From @Cur_SegmentId Into @Segment_ID
While @@Fetch_Status=0
Begin    
  Insert Into #TempSegment Select SegmentId From dbo.fn_GetLeafLevelSegment(@Segment_ID)
		Fetch Next From @Cur_SegmentId Into @Segment_ID
End     
Close @Cur_SegmentId

If @BeatName ='%'  
 If @Active=1  
  Insert Into #TempBeat Select BeatID From Beat Where Active=1  
 Else  
  Insert Into #TempBeat Select BeatID From Beat   
Else  
 If @Active=1  
  Insert Into #TempBeat Select BeatID From Beat Where Description = @BeatName And  Active=1  
 Else  
  Insert Into #TempBeat Select BeatID From Beat Where Description = @BeatName  
  
If @Active=1  
 If @SegmentID ='%' 
		Begin	
			If @BeatName ='%' 
				Begin
					 Select 
							CU.CustomerID As CustomerCode, CU.Company_Name As CustomerName     
					 From 
							Customer CU,customer_channel CC,Beat_Salesman BT
					 Where 
								IsNull(CU.ChannelType,'') In (Select * From #TempChannel)
						  And CU.SegmentId In (Select * From #TempSegment)
						  And CU.CustomerID *= BT.CustomerID   
						  And Bt.BeatId In (Select * From #TempBeat)
						  And CU.CustomerCategory <> 4   
						  And CU.CustomerCategory <> 5   
						  And Cu.Active=1  
						Group By 
							Cu.Customerid, Cu.Company_Name  
				End
			Else
				Begin
					 Select 
							CU.CustomerID As CustomerCode, CU.Company_Name As CustomerName     
					 From 
							Customer CU,customer_channel CC,CustomerSegment CS,Beat_Salesman BT
					 Where 
								IsNull(CU.ChannelType,'') In (Select * From #TempChannel)
						  And CU.SegmentId In (Select * From #TempSegment)
						  And CU.CustomerID = BT.CustomerID
						  And Bt.BeatId In(Select * From #TempBeat)
						  And CU.CustomerCategory <> 4   
						  And CU.CustomerCategory <> 5   
						  And Cu.Active=1  
						Group By 
							Cu.Customerid, Cu.Company_Name  
				End
		End
 Else
		Begin
			If @BeatName ='%' 
				Begin
				 Select 
						CU.CustomerID As CustomerCode, CU.Company_Name As CustomerName     
				 From 
						Customer CU,customer_channel CC,Beat_Salesman BT
				 Where 
						IsNull(CU.ChannelType,'') In (Select * From #TempChannel)
				  And CU.SegmentId In (Select * From #TempSegment)
				  And CU.CustomerID *= BT.CustomerID   
				  And Bt.BeatId In(Select * From #TempBeat)
				  And CU.CustomerCategory <> 4   
				  And CU.CustomerCategory <> 5   
				  And Cu.Active=1  
					Group By 
						Cu.Customerid, Cu.Company_Name  
				End
			Else
				Begin
					 Select 
							CU.CustomerID As CustomerCode, CU.Company_Name As CustomerName     
					 From 
							Customer CU,customer_channel CC,Beat_Salesman BT
					 Where 
							IsNull(CU.ChannelType,'') In (Select * From #TempChannel)
					  And CU.SegmentId In (Select * From #TempSegment)
					  And CU.CustomerID = BT.CustomerID   
					  And Bt.BeatId In(Select * From #TempBeat)
					  And CU.CustomerCategory <> 4   
					  And CU.CustomerCategory <> 5   
					  And Cu.Active=1  
					Group By 
						Cu.Customerid, Cu.Company_Name  
				End
		End
Else  
	If @SegmentID ='%' 
		Begin	
			If @BeatName ='%' 
				Begin
				 Select 
						CU.CustomerID As CustomerCode, CU.Company_Name As CustomerName     
				 From 
						Customer CU,customer_channel CC,Beat_Salesman BT
				 Where 
						IsNull(CU.ChannelType,'') In (Select * From #TempChannel)
				  And CU.SegmentId In (Select * From #TempSegment)
				  And CU.CustomerID *= BT.CustomerID   
				  And Bt.BeatId In(Select * From #TempBeat)
				  And CU.CustomerCategory <> 4   
				  And CU.CustomerCategory <> 5   
					Group By 
						Cu.Customerid, Cu.Company_Name  
				End
			Else
				Begin
				 Select 
						CU.CustomerID As CustomerCode, CU.Company_Name As CustomerName     
				 From 
						Customer CU,customer_channel CC,Beat_Salesman BT
				 Where 
						IsNull(CU.ChannelType,'') In (Select * From #TempChannel)
				  And CU.SegmentId In (Select * From #TempSegment)
				  And CU.CustomerID = BT.CustomerID   
				  And Bt.BeatId In(Select * From #TempBeat)
				  And CU.CustomerCategory <> 4   
				  And CU.CustomerCategory <> 5   
					Group By 
						Cu.Customerid, Cu.Company_Name  
				End
		End
 Else
		Begin
			If @BeatName ='%' 
				Begin
					 Select 
							CU.CustomerID As CustomerCode, CU.Company_Name As CustomerName     
					 From 
							Customer CU,customer_channel CC,Beat_Salesman BT
					 Where 
 						IsNull(CU.ChannelType,'') In (Select * From #TempChannel)
 				  And CU.SegmentId In (Select * From #TempSegment)
					  And CU.CustomerID *= BT.CustomerID   
					  And Bt.BeatId In(Select * From #TempBeat)
					  And CU.CustomerCategory <> 4   
					  And CU.CustomerCategory <> 5   
						Group By 
							Cu.Customerid, Cu.Company_Name  
				End
			Else
				Begin
					 Select 
							CU.CustomerID As CustomerCode, CU.Company_Name As CustomerName     
					 From 
							Customer CU,customer_channel CC,Beat_Salesman BT
					 Where 
							IsNull(CU.ChannelType,'') In (Select * From #TempChannel)
 				  And CU.SegmentId In (Select * From #TempSegment)
					  And CU.CustomerID = BT.CustomerID   
					  And Bt.BeatId In(Select * From #TempBeat)
					  And CU.CustomerCategory <> 4   
					  And CU.CustomerCategory <> 5   
						Group By 
							Cu.Customerid, Cu.Company_Name  
				End
	End

Drop Table #TmpSegmentId
Drop Table #TempSegment  
Drop Table #TempChannel  
Drop Table #TempBeat
