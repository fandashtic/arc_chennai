Create Procedure sp_Add_Remove_FavoriteReport(@RepID Int,@Option int)
As
-- To add a report to favorite list

-- This stored procedure returns respective messages

-- @Option = 12  for Add to favorite
-- @Option = 13  for Remove from favorite


If @Option = 12
	Begin
		If Exists (Select ReportID From FavoriteReports where ReportID = @RepID and Active = 1)
			Begin
				Select 'Already exists.'
			End
		Else if Exists (Select ReportID From FavoriteReports where ReportID = @RepID)
			Begin
				If ((Select Count(*) From FavoriteReports Where Active = 1) < 15) 
				Begin
	
					UPdate FavoriteReports Set Active = 1 where ReportID = @RepID
					Select 'Added Successfully.'
				End
				Else
					Select 'We cannot add more than 15 reports.'
			End
		Else
			Begin
				If ((Select Count(*) From FavoriteReports Where Active = 1) < 15) 
				Begin
					Insert Into FavoriteReports Values (@RepID,1)
					Select 'Added Successfully.'
				End
				Else
					Select 'We cannot add more than 15 reports.'
			End
	End
Else If @Option = 13
	Begin
		If Exists (Select ReportID From FavoriteReports where ReportID = @RepID and Active = 0)
			Begin
				Select 'Already removed.'
			End
		Else if Exists (Select ReportID From FavoriteReports where ReportID = @RepID And Active = 1)
			Begin
				UPdate FavoriteReports Set Active = 0 where ReportID = @RepID
				Select 'Removed Successfully.'
			End
		Else
			Begin
				Select 'Not exists to remove.'
			End
	End
