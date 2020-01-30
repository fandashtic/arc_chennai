CREATE Procedure sp_acc_filtergroup(@GroupType integer,@GrpID Int=0,@KeyField nvarchar(30)=N'%',
@Direction int = 0, @BookMark nvarchar(128) = N'')
As
If @GrpID=0
	IF @Direction = 1
	Begin
		Select Top 9 GroupID,GroupName from AccountGroup
		where AccountType=@GroupType and GroupName like @KeyField and active=1
		and GroupName > @BookMark
		order by GroupName		
	end
	Else
	begin
		Select Top 9 GroupID,GroupName from AccountGroup
		where AccountType=@GroupType and GroupName like @KeyField and active=1
	end
else if @GrpID = 500
	IF @Direction = 1
	Begin
		Select Top 9 GroupID,GroupName from AccountGroup
		where GroupName like @KeyField
		And GroupID <> 500 and GroupName > @BookMark

	end
	Else
	begin
		Select Top 9 GroupID,GroupName from AccountGroup
		where GroupName like @KeyField
		And GroupID <> 500
	end

Else	IF @Direction = 1
	Begin
		Select Top 9 GroupID,GroupName from AccountGroup
		where AccountType=@GroupType and GroupName like @KeyField and active=1 
		and GroupId <> @GrpID and GroupName > @BookMark
		order by GroupName
	End
	Else
	Begin
		Select Top 9 GroupID,GroupName from AccountGroup
		where AccountType=@GroupType and GroupName like @KeyField and active=1
		and GroupId <> @GrpID
	End

