Create Procedure FSU_sp_getMessages(@nEvent Int, @nServer Int)
As 

    If (@nServer = 1 )
    Begin

    	Select Count(*) from dbo.tblMessageDetail MD 
    	inner join dbo.tblReleaseDetail RD on MD.ReleaseID = RD.ReleaseId 
    	WHERE (MD.Event & @nEvent = @nEvent and MD.Event & 1 = 1 and MD.status & 1 = 0)
        or (MD.Event & @nEvent = @nEvent and MD.Event & 1 <> 1)
    	and (Getdate() Between ScheduleFrom and ScheduleTo )

    	Select MD.Message, MD.MessageType, RD.ReleaseID  from dbo.tblMessageDetail MD 
    	inner join dbo.tblReleaseDetail RD on MD.ReleaseID = RD.ReleaseId 
    	WHERE (MD.Event & @nEvent = @nEvent and MD.Event & 1 = 1 and MD.status & 1 = 0)
        or (MD.Event & @nEvent = @nEvent and MD.Event & 1 <> 1)
    	and (Getdate() Between ScheduleFrom and ScheduleTo )

    End
    Else
    Begin

    	Select count(*) from dbo.tblMessageDetail MD 
    	inner join dbo.tblReleaseDetail RD on MD.ReleaseID = RD.ReleaseId 
        WHERE MD.Event & @nEvent = @nEvent 
    	and (Getdate() Between ScheduleFrom and ScheduleTo )

    	Select MD.Message, MD.MessageType, RD.ReleaseID  from dbo.tblMessageDetail MD 
    	inner join dbo.tblReleaseDetail RD on MD.ReleaseID = RD.ReleaseId 
    	WHERE MD.Event & @nEvent = @nEvent 
    	and (Getdate() Between ScheduleFrom and ScheduleTo )
    End
