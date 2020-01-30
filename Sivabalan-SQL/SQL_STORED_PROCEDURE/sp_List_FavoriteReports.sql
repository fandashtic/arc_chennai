Create Procedure sp_List_FavoriteReports
As
-- In coding while loading reports name into tree viewer 
-- ['C' + reportID] is the key for that node.
-- the report name list only with 30 char in popup menu
Select Top 15 'C' + Cast([ID] as varchar),
Case When Len(Node) > 30 Then Left(Node,30) + '...' Else Node End
from ReportData RD, FavoriteReports FR 
Where FR.ReportID = [ID] And FR.Active = 1 And RD.Action = 1 And RD.Inactive = 0
