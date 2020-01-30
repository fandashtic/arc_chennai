Create procedure sp_han_UpdateScheme_Details(@OrderNumber nvarchar(200),@Status as int = 1)
as
begin
declare @tmp int,@MsgType nvarchar(100),@MsgAction nvarchar(100),@SalesmanID nvarchar(100)
set @tmp=0
 if exists(select * from Scheme_Details where ordernumber=@OrderNumber)
 begin
 update Scheme_Details set @tmp=(case when ((len(SchemeID) > 5) 
 and (right(cast(SchemeID as varchar(30)),5)>1 and right(cast(SchemeID as varchar(30)),5)<20000) 
 and (left(cast(SchemeID as varchar(30)),len(cast(SchemeID as varchar(30)))-5)>0)) 
 then 1 else 0 end),SchemeID_HH=case when(@tmp=1) then SchemeID else SchemeID_HH  end,
 GroupID=case when(@tmp=1) then left(cast(SchemeID as varchar(30)),len(cast(SchemeID as varchar(30)))-5) else GroupID end
 ,SchemeID=case when(@tmp=1) then right(cast(SchemeID as varchar(30)),4) else SchemeID end
 ,ID_Split_Flag=@tmp
 where ordernumber=@OrderNumber
 if @tmp=0
  begin 
	set @MsgAction=case when @Status=1 then 'Processed' when @Status=2 then 'Aborted' end 
	select Top 1 @SalesmanID=SalesmanID from Order_header where Ordernumber=@OrderNumber
	exec sp_han_InsertErrorlog @OrderNumber,1,'Error',@MsgAction ,'Invalid SchemID.SchemeID has not been Splited',@SalesmanID
  end
 end
end
