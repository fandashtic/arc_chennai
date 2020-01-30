CREATE Function  fn_han_Get_SchemeTypeCust(@SchemeType int)  
Returns @Result Table    
(      
  SchemeID int,
  GroupID int,  
  CustomerID nvarchar(30)  
)   
AS 
Begin  
---------------------------------------
 declare @schemeID int 
 Declare @GroupId int
 Declare TmpCursor Cursor Keyset For 
 select distinct TSA.schemeID,TSSD.Groupid from tbl_mERP_SchemeAbstract TSA
 inner join tbl_mERP_SchemeSlabDetail TSSD on TSSD.SchemeID = TSA.SchemeID 
 where isnull(TSSD.GroupID,0)<>0 and TSA.SchemeType = @SchemeType
 Open TmpCursor    
 Fetch From TmpCursor Into @schemeID,@GroupId        
 While @@Fetch_Status = 0        
 Begin 
------------------------------------------

			--	OutletID Filter	
			 if exists(select * from tbl_mERP_SchemeOutlet TSO where TSO.SchemeID = @SchemeID and GroupID = @GroupId and OutletID <>N'ALL')  
			 Begin  
			  INSERT INTO @Result 
			  select @SchemeID,@GroupId,c.CustomerID  from Customer C   
			  inner join tbl_mERP_SchemeOutlet TSO on TSO.OutletID = C.CustomerID  
			  inner join  
				(
					--If tbl_mERP_SchemeChannel doesn't have 'ALL' for Current scheme
					select distinct c.CustomerID from customer c 
					inner join  Customer_channel CC on c.channelType=cc.ChannelType
					inner join tbl_mERP_SchemeChannel TSSC on TSSC.channel = CC.channeldesc
					WHERE TSSC.SchemeID = @SchemeID and GroupID = @GroupId and (select count(*) from  tbl_mERP_SchemeChannel where SchemeID = @SchemeID and GroupID = @GroupId and channel =N'ALL')=0
					and c.CustomerCategory <> 5 
					union 
					--If tbl_mERP_SchemeChannel have atleast on 'ALL' for Current scheme
					select distinct c.CustomerID from customer c 
					inner join  Customer_channel CC on c.channelType=cc.ChannelType
					where (select count(*) from  tbl_mERP_SchemeChannel where SchemeID = @SchemeID and GroupID = @GroupId and channel =N'ALL')>0
					and c.CustomerCategory <> 5   
				) TSELC on TSELC.CustomerID=c.CustomerID 

			  inner join  
				(
					--If tbl_mERP_SchemeOutletClass doesn't have 'ALL' for Current scheme
					select distinct c.CustomerID from customer c
					inner join subchannel SC on c.subchannelid=SC.subchannelid
					inner join tbl_mERP_SchemeOutletClass TSOC on TSOC.outletclass=SC.description
					WHERE TSOC.SchemeID = @SchemeID and GroupID = @GroupId and (select count(*) from  tbl_mERP_SchemeOutletClass where SchemeID = @SchemeID and GroupID = @GroupId and outletclass =N'ALL')=0
					and c.CustomerCategory <> 5 
					union
					--If tbl_mERP_SchemeOutletClass have atleast on 'ALL' for Current scheme
					select distinct c.CustomerID from customer c
					inner join subchannel SC on c.subchannelid=SC.subchannelid
					where (select count(*) from  tbl_mERP_SchemeOutletClass where SchemeID = @SchemeID and GroupID = @GroupId and outletclass =N'ALL')>0
					and c.CustomerCategory <> 5  
				) TSELS on TSELS.CustomerID=c.CustomerID

			  WHERE TSO.SchemeID = @SchemeID
			  and TSO.GroupID = @GroupId 
			Fetch Next From TmpCursor Into @schemeID,@GroupId
			continue 
			End 
			 -- Outlet Class Filter  
			 if exists(select * from tbl_mERP_SchemeOutletClass TSOC where TSOC.SchemeID = @SchemeID and GroupID = @GroupId and OutletClass <>N'ALL')  
			 Begin  
			  INSERT INTO @Result 
			  select @SchemeID,@GroupId,c.CustomerID  from Customer C   
			  inner join Subchannel SC on SC.SubChannelID  = C.SubChannelID  
			  inner join tbl_mERP_SchemeOutletClass TSOC on TSOC.OutletClass = SC.Description
			  inner join  
			--and C.ChannelType in 
				(
					--If tbl_mERP_SchemeChannel doesn't have 'ALL' for Current scheme
					select distinct c.CustomerID from customer c 
					inner join  Customer_channel CC on c.channelType=cc.ChannelType
					inner join tbl_mERP_SchemeChannel TSSC on TSSC.channel = CC.channeldesc
					WHERE TSSC.SchemeID = @SchemeID and GroupID = @GroupId and (select count(*) from  tbl_mERP_SchemeChannel where SchemeID = @SchemeID and GroupID = @GroupId and channel =N'ALL')=0
					and c.CustomerCategory <> 5 
					union 
					--If tbl_mERP_SchemeChannel have atleast on 'ALL' for Current scheme
					select distinct c.CustomerID from customer c 
					inner join  Customer_channel CC on c.channelType=cc.ChannelType
					where (select count(*) from  tbl_mERP_SchemeChannel where SchemeID = @SchemeID and GroupID = @GroupId and channel =N'ALL')>0
					and c.CustomerCategory <> 5  
				) TSELC on TSELC.CustomerID=c.CustomerID
			  WHERE TSOC.SchemeID = @SchemeID   
			  and TSOC.GroupID = @GroupId
			Fetch Next From TmpCursor Into @schemeID,@GroupId
			continue 
			 End 

			--- Outlet Channel Filter  
			if exists(select * from tbl_mERP_SchemeChannel SC where SC.SchemeID = @SchemeID and GroupID = @GroupId and Channel =N'ALL')  
			Begin  
			 INSERT INTO @Result  
			 select @SchemeID,@GroupId, CustomerID  from Customer  where CustomerCategory <> 5  
			End  
			Else  
			 Begin  
			 INSERT INTO @Result  
			 select @SchemeID,@GroupId, CustomerID  from customer C   
			 inner join Customer_channel CC on CC.ChannelType = c.ChannelType  
			 inner join tbl_mERP_SchemeChannel  SC on SC.Channel = CC.ChannelDesc   
			 WHERE SC.SchemeID = @SchemeID   
			 and GroupID = @GroupId
			 and c.CustomerCategory <> 5   
			End
------------------------------------------------------------------------------

   Fetch Next From TmpCursor Into @schemeID,@GroupId    
 End    
 Close TmpCursor    
 DeAllocate TmpCursor 
------------------------------------------------------------------------------
RETURN  
END
