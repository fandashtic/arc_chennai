Create Procedure mERP_SP_LoadQuoCustomer(@ChannelID as nvarchar(2000)) 
As Declare @Delimeter as char(1) 
Begin 
Set @Delimeter = char(15) 
Create table #TmpChannel(ChannelType nvarchar(200)) 
Insert into #TmpChannel select * from dbo.sp_splitIn2Rows(@ChannelID,@Delimeter) 
select CustomerID,Company_name from Customer,Customer_Channel 
where Customer.ChannelType=Customer_Channel.ChannelType 
and  Customer_Channel.ChannelDesc in (Select ChannelType from #TmpChannel) 
and Customer.Active=1 order by Company_name 
Truncate Table #TmpChannel Drop table #TmpChannel 
End
