Create Procedure mERP_SP_validateDepositdate (@CollectionID nvarchar(4000),@BouncedDate Datetime)
AS
BEGIN
	Set dateformat dmy
	Declare @Collections Table (CollectionID int)
	Declare @DDate Table (Depositdate datetime,status int)
	insert into @Collections(CollectionID) Select * from dbo.sp_SplitIn2Rows(@CollectionID,',')	

	insert into @DDate(Depositdate)
	Select dbo.stripdatefromtime(isnull(DepositDate,getdate())) 
	from Collections where DocumentID in (Select CollectionID from @Collections)
	
	update @DDate set status = 1 where Depositdate > @BouncedDate

	If exists (select * from @DDate where status=1)
	Select 1
	Else
	Select 0

END
