CREATE procedure [dbo].[sp_load_customer_Campaign](                      
 @SubChannel NVarchar(250),                      
 @ChannelType NVarchar(250),                      
 @BeatName NVarchar(250),  
 @Active Int     
 )                      
as                      
                      
Create Table #TempChannel ( ChannelID int)  
Create Table #TempsubChannel( SubChannelID int)  
Create Table #TempBeat (Beat Int)  
  
if @ChannelType ='%'  
 IF @Active=1  
  Insert into #TempChannel Select channelType From Customer_Channel Where Active=1  
 Else  
  Insert into #TempChannel Select channelType From Customer_Channel   
Else  
 IF @Active=1  
  Insert Into #TempChannel Select channelType From Customer_Channel Where ChannelDesc = @ChannelType And  Active=1  
 Else  
  Insert Into #TempChannel Select channelType From Customer_Channel Where ChannelDesc = @ChannelType  
if @SubChannel ='%'  
 Insert into #TempsubChannel Select SubChannelID From SubChannel   
Else  
 Insert Into #TempsubChannel Select SubChannelID From SubChannel Where Description = @SubChannel  
  
if @BeatName ='%'  
 IF @Active=1  
  Insert into #TempBeat Select BeatID From Beat Where Active=1  
 else  
  Insert into #TempBeat Select BeatID From Beat   
Else  
 IF @Active=1  
  Insert Into #TempBeat Select BeatID From Beat Where Description = @BeatName And  Active=1  
 ELSE  
  Insert Into #TempBeat Select BeatID From Beat Where Description = @BeatName  
  
--Final Selection List      
--For Active Customers only
IF @Active=1  
  If @SubChannel ='%' 
	Begin	
		If @BeatName ='%' 
--For all beat		
			Begin
				 Select CU.CustomerID As CustomerCode, CU.Company_Name As CustomerName     
				 From Customer CU , customer_channel CC , SubChannel SCH, Beat_Salesman BT, 
					#TempsubChannel TmpSub
				 Where CU.ChannelType In (Select * From #TempChannel)
					  And CU.SubChannelID  *= TmpSub.SubChannelID
					  And CU.CustomerID *= BT.CustomerID   
					  And Bt.BeatId in(select * from #TempBeat)
					  And CU.CustomerCategory <> 4   
					  And CU.CustomerCategory <> 5   
					  And Cu.Active=1  
					Group By Cu.Customerid, Cu.Company_Name  
			End
		Else
--For Given Beat only
			Begin
				 Select CU.CustomerID As CustomerCode, CU.Company_Name As CustomerName     
				 From Customer CU , customer_channel CC , SubChannel SCH, Beat_Salesman BT, 
					#TempsubChannel TmpSub
				 Where CU.ChannelType In (Select * From #TempChannel)
					  And CU.SubChannelID  *= TmpSub.SubChannelID
					  And CU.CustomerID = BT.CustomerID   
					  And Bt.BeatId in(select * from #TempBeat)
					  And CU.CustomerCategory <> 4   
					  And CU.CustomerCategory <> 5   
					  And Cu.Active=1  
					Group By Cu.Customerid, Cu.Company_Name  
			End
	End
  Else
	Begin
		If @BeatName ='%' 
-- For All beat
			Begin
				 Select CU.CustomerID As CustomerCode, CU.Company_Name As CustomerName     
				 From Customer CU , customer_channel CC , SubChannel SCH, Beat_Salesman BT, 
					#TempsubChannel TmpSub
				 Where CU.ChannelType In (Select * From #TempChannel)
					  And CU.SubChannelID In(Select * From #TempsubChannel) 
					  And CU.CustomerID *= BT.CustomerID   
					  And Bt.BeatId in(select * from #TempBeat)
					  And CU.CustomerCategory <> 4   
					  And CU.CustomerCategory <> 5   
					  And Cu.Active=1  
				Group By Cu.Customerid, Cu.Company_Name  
			End
		Else
-- For given Beat only.		
			Begin
				 Select CU.CustomerID As CustomerCode, CU.Company_Name As CustomerName     
				 From Customer CU , customer_channel CC , SubChannel SCH, Beat_Salesman BT, 
					#TempsubChannel TmpSub
				 Where CU.ChannelType In (Select * From #TempChannel)
					  And CU.SubChannelID In(Select * From #TempsubChannel) 
					  And CU.CustomerID = BT.CustomerID   
					  And Bt.BeatId in(select * from #TempBeat)
					  And CU.CustomerCategory <> 4   
					  And CU.CustomerCategory <> 5   
					  And Cu.Active=1  
				Group By Cu.Customerid, Cu.Company_Name  
			End
	End
ELSE  
--For all Customers without any verification of Active.
  If @SubChannel ='%' 
	Begin	
		If @BeatName ='%' 
--For all beat		
			Begin
				 Select CU.CustomerID As CustomerCode, CU.Company_Name As CustomerName     
				 From Customer CU , customer_channel CC , SubChannel SCH, Beat_Salesman BT, 
					#TempsubChannel TmpSub
				 Where CU.ChannelType In (Select * From #TempChannel)
					  And CU.SubChannelID  *= TmpSub.SubChannelID
					  And CU.CustomerID *= BT.CustomerID   
					  And Bt.BeatId in(select * from #TempBeat)
					  And CU.CustomerCategory <> 4   
					  And CU.CustomerCategory <> 5   
					Group By Cu.Customerid, Cu.Company_Name  
			End
		Else
--For Given Beat only
			Begin
				 Select CU.CustomerID As CustomerCode, CU.Company_Name As CustomerName     
				 From Customer CU , customer_channel CC , SubChannel SCH, Beat_Salesman BT, 
					#TempsubChannel TmpSub
				 Where CU.ChannelType In (Select * From #TempChannel)
					  And CU.SubChannelID  *= TmpSub.SubChannelID
					  And CU.CustomerID = BT.CustomerID   
					  And Bt.BeatId in(select * from #TempBeat)
					  And CU.CustomerCategory <> 4   
					  And CU.CustomerCategory <> 5   
					Group By Cu.Customerid, Cu.Company_Name  
			End
	End
  Else
	Begin
		If @BeatName ='%' 
-- For All beat
			Begin
				 Select CU.CustomerID As CustomerCode, CU.Company_Name As CustomerName     
				 From Customer CU , customer_channel CC , SubChannel SCH, Beat_Salesman BT, 
					#TempsubChannel TmpSub
				 Where CU.ChannelType In (Select * From #TempChannel)
					  And CU.SubChannelID In(Select * From #TempsubChannel) 
					  And CU.CustomerID *= BT.CustomerID   
					  And Bt.BeatId in(select * from #TempBeat)
					  And CU.CustomerCategory <> 4   
					  And CU.CustomerCategory <> 5   
				Group By Cu.Customerid, Cu.Company_Name  
			End
		Else
-- For given Beat only.		
			Begin
				 Select CU.CustomerID As CustomerCode, CU.Company_Name As CustomerName     
				 From Customer CU , customer_channel CC , SubChannel SCH, Beat_Salesman BT, 
					#TempsubChannel TmpSub
				 Where CU.ChannelType In (Select * From #TempChannel)
					  And CU.SubChannelID In(Select * From #TempsubChannel) 
					  And CU.CustomerID = BT.CustomerID   
					  And Bt.BeatId in(select * from #TempBeat)
					  And CU.CustomerCategory <> 4   
					  And CU.CustomerCategory <> 5   
				Group By Cu.Customerid, Cu.Company_Name  
			End
	End
Drop Table #TempsubChannel  
Drop Table #TempChannel  
Drop Table #TempBeat
